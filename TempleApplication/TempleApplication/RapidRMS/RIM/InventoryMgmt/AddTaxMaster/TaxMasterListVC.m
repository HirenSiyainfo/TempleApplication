//
//  TaxMasterListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 25/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "TaxMasterListVC.h"
#import "RmsDbController.h"
#import "TaxMasterCustomCell.h"
#import "TaxMaster+Dictionary.h"
#import "AddTaxMasterVC.h"
#import "RimIphonePresentMenu.h"

@interface TaxMasterListVC (){
    RimIphonePresentMenu * objMenubar;
}

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic,strong) NSFetchedResultsController *taxResultController;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UITableView *tblTaxMaster;
@property (nonatomic, strong) NSRecursiveLock *rimTaxLock;

@end

@implementation TaxMasterListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    if (IsPhone()) {
        objMenubar = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimIphonePresentMenu_sid"];
        objMenubar.sideMenuVCDelegate = self.sideMenuVCDelegate;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSFetchedResultsController *)taxResultController {
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.rimTaxLock];
    if (_taxResultController != nil) {
        return _taxResultController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"taxNAME" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _taxResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_taxResultController performFetch:nil];
    _taxResultController.delegate = self;
    [lock unlock];
    return _taxResultController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.taxResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell.backgroundColor = [UIColor clearColor];
    if(tableView == self.self.tblTaxMaster)
    {
        cell = [self configureTaxMasterCell:indexPath];
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    cell.selectedBackgroundView = selectionColor;
    return cell;
}

- (UITableViewCell *)configureTaxMasterCell:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaxMasterCustomCell";
    TaxMasterCustomCell *taxCell = [self.self.tblTaxMaster dequeueReusableCellWithIdentifier:CellIdentifier];
    
    TaxMaster *taxMaster = [self.taxResultController objectAtIndexPath:indexPath];
    NSMutableDictionary *taxDictionary = [taxMaster.taxMasterDictionary mutableCopy];
    
    taxCell.lblName.text = taxDictionary[@"TAXNAME"];
    if ([taxDictionary[@"Type"]integerValue] == 1)
    {
        taxCell.lblAmount.text = [NSString stringWithFormat:@"$ %@",taxDictionary[@"Amount"]];
    }
    else if ([taxDictionary[@"Type"]integerValue] ==0)
    {
        taxCell.lblAmount.text =  [NSString stringWithFormat:@"%.2f %%",[[taxDictionary valueForKey:@"PERCENTAGE" ] floatValue]];
    }
    
    taxCell.btnDelete.tag = indexPath.section;
    [taxCell.btnDelete addTarget:self action:@selector(deleteTaxMaster:) forControlEvents:UIControlEventTouchUpInside];

    return taxCell;

}

-(void)deleteTaxMaster:(id)sender
{
    
}

-(IBAction)iPhoneMenuPresent:(id)sender {
    
    if (IsPhone()) {
        NSArray *viewcon = (self.navigationController).viewControllers;
        for(UIViewController *tempcon in viewcon){
            if([tempcon isKindOfClass:[RimIphonePresentMenu class]])
            {
                [self.navigationController popToViewController:tempcon animated:YES];
                return;
            }
        }
    }
    [self.rmsDbController playButtonSound];
    [self presentViewController:objMenubar animated:YES completion:nil];
}

//-(IBAction)btnNewTax:(id)sender
//{
//    AddTaxMasterVC *addTaxMaster =
//    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"AddTaxMasterVC_sid"];
//    addTaxMaster.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self.sideMenuVCDelegate willPresentViewController:addTaxMaster animated:YES completion:nil];
//}
/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if(controller != _taxResultController)
    {
        [self unlockResultController];
        return;
    }
    else if (_taxResultController == nil){
        [self unlockResultController];
        return;
    }

    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblTaxMaster beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != _taxResultController)
    {
        return;
    }
    else if (_taxResultController == nil){
        return;
    }

    UITableView *tableView = self.tblTaxMaster;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tblTaxMaster reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(controller != _taxResultController)
    {
        return;
    }
    else if (_taxResultController == nil){
        return;
    }

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblTaxMaster insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblTaxMaster deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tblTaxMaster reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tblTaxMaster deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tblTaxMaster insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != _taxResultController)
    {
        return;
    }
    else if (_taxResultController == nil){
        return;
    }

    [self.tblTaxMaster endUpdates];
    [self unlockResultController];
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)rimTaxLock {
    if (_rimTaxLock == nil) {
        _rimTaxLock = [[NSRecursiveLock alloc] init];
    }
    return _rimTaxLock;
}

-(void)lockResultController
{
    [self.rimTaxLock lock];
}

-(void)unlockResultController
{
    [self.rimTaxLock unlock];
}

-(void)setTaxMasterListResultsController:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.rimTaxLock];
    _taxResultController = resultController;
    [lock unlock];
}

#pragma mark - Add & Detail Tax Master (Segue) -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"updateTaxMaster"]) {
        NSIndexPath *indexPath = [self.tblTaxMaster indexPathForCell:sender];
        TaxMaster *taxMaster = [self.taxResultController objectAtIndexPath:indexPath];
        AddTaxMasterVC *addTaxMaster = (AddTaxMasterVC *)segue.destinationViewController;
        addTaxMaster.taxMaster = taxMaster;
    }
}

@end
