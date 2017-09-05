//
//  PaymentMasterListVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaymentMasterListVC.h"
#import "RmsDbController.h"
#import "TenderPay+Dictionary.h"
#import "PaymentMasterListCell.h"
#import "AddPaymentMasterVC.h"
#import "RimIphonePresentMenu.h"

@interface PaymentMasterListVC (){
    RimIphonePresentMenu * objMenubar;
}


@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) NSFetchedResultsController *paymentMasterResultController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet UITableView *paymentMasterListTable;

@property (nonatomic, strong) NSRecursiveLock *rimPaymentLock;


@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation PaymentMasterListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    if (IsPhone()) {
        objMenubar = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimIphonePresentMenu_sid"];
        objMenubar.sideMenuVCDelegate = self.sideMenuVCDelegate;
    }

    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _paymentMasterResultController = nil;
    [_paymentMasterListTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)paymentMasterResultController {
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.rimPaymentLock];
    if (_paymentMasterResultController != nil) {
        return _paymentMasterResultController;
    }

    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"paymentName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _paymentMasterResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_paymentMasterResultController performFetch:nil];
    _paymentMasterResultController.delegate = self;
    [lock unlock];
    return _paymentMasterResultController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.paymentMasterResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [self configurePaymentMasterCell:indexPath withTableView:tableView];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    cell.selectedBackgroundView = selectionColor;
    return cell;
}

- (UITableViewCell* )configurePaymentMasterCell:(NSIndexPath *)indexPath withTableView:(UITableView *)tableView
{
    static NSString *CellIdentifier = @"PaymentMasterListCell";
    
    PaymentMasterListCell *paymentMasterListCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    TenderPay *tenderPay = [self.paymentMasterResultController objectAtIndexPath:indexPath];
    paymentMasterListCell.paymentName.text = tenderPay.paymentName;
    paymentMasterListCell.paymentCode.text = tenderPay.payCode;
    NSString *checkImageName = tenderPay.payImage;
    
    if ([checkImageName isEqualToString:@""])
    {
        paymentMasterListCell.paymentImage.image = [UIImage imageNamed:@"favouriteNoImage.png"];
    }
    else
    {
        [paymentMasterListCell.paymentImage  loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",checkImageName]]];
    }
    return paymentMasterListCell;
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if(controller != _paymentMasterResultController)
    {
        [self unlockResultController];
        return;
    }
    else if (_paymentMasterResultController == nil){
        [self unlockResultController];
        return;
    }

    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [_paymentMasterListTable beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != _paymentMasterResultController)
    {
        return;
    }
    else if (_paymentMasterResultController == nil){
        return;
    }

    UITableView *tableView = _paymentMasterListTable;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [_paymentMasterListTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(controller != _paymentMasterResultController)
    {
        return;
    }
    else if (_paymentMasterResultController == nil){
        return;
    }

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_paymentMasterListTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_paymentMasterListTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [_paymentMasterListTable reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [_paymentMasterListTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_paymentMasterListTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != _paymentMasterResultController)
    {
        return;
    }
    else if (_paymentMasterResultController == nil){
        return;
    }

    [_paymentMasterListTable endUpdates];
    [self unlockResultController];
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)rimPaymentLock {
    if (_rimPaymentLock == nil) {
        _rimPaymentLock = [[NSRecursiveLock alloc] init];
    }
    return _rimPaymentLock;
}

-(void)lockResultController
{
    [self.rimPaymentLock lock];
}

-(void)unlockResultController
{
    [self.rimPaymentLock unlock];
}

-(void)setPaymentMasterListResultsController:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.rimPaymentLock];
    _paymentMasterResultController = resultController;
    [lock unlock];
}

#pragma mark - Add & Detail Payment Master (Segue) -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"updatePaymentMaster"]) {
        NSIndexPath *indexPath = [self.paymentMasterListTable indexPathForCell:sender];
        TenderPay *tenderPay = [self.paymentMasterResultController objectAtIndexPath:indexPath];
        
        AddPaymentMasterVC *addPaymentMaster = (AddPaymentMasterVC *)segue.destinationViewController;
        addPaymentMaster.tenderPay = tenderPay;
    }
}

@end