//
//  TaxAddRemovePage.m
//  POSFrontEnd
//
//  Created by Triforce-Nirmal-Imac on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RimTaxAddRemovePage.h"
#import "TaxMaster+Dictionary.h"
#import "RmsDbController.h"
#import "DepartmentSelectionCell.h"
#import "UITableView+AddBorder.h"

@interface RimTaxAddRemovePage ()<NSFetchedResultsControllerDelegate> {
    NSMutableArray * arrayCheckedArry;
    NSString * strSearchMaster;
    UIColor * colorDefault;
    UIColor * colorSelected;
    UIImage * imgDefault;
    UIImage * imgSelected;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * itemTaxList;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak)  IBOutlet UITableView * aTableView;
@property (nonatomic, weak) IBOutlet UITextField * txtMasterName;
@end


@implementation  RimTaxAddRemovePage


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    if (_checkedTaxItem == nil)
    {
        _checkedTaxItem = [[NSMutableArray alloc]init];
    }
    colorDefault = [UIColor blackColor];
    colorSelected = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    imgDefault = [UIImage imageNamed:@"radiobtn.png"];
    imgSelected = [UIImage imageNamed:@"radioMulti_selected.png"];
    strSearchMaster = @"";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark TableView Delegate & Data Source


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = self.itemTaxList.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DepartmentSelectionCell * cell=(DepartmentSelectionCell *)[self.aTableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[DepartmentSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    NSMutableDictionary * taxInfo = [self getTaxDictInfoAt:indexPath];
    
	
	cell.lblDeptName.text = [NSString stringWithFormat:@"%@",[taxInfo valueForKey:@"TAXNAME"]];
	cell.lblDoNotApply.text = [NSString stringWithFormat:@"%.2f%@",[[taxInfo valueForKey:@"PERCENTAGE"] floatValue],@"%"];
	
    cell.lblDeptName.textColor = colorDefault;
    cell.lblDoNotApply.textColor = colorDefault;
    cell.imgIsSelected.image = imgDefault;
    
    if ([_checkedTaxItem containsObject:taxInfo]) {
        cell.imgIsSelected.image = imgSelected;
        cell.lblDeptName.textColor = colorSelected;
        cell.lblDoNotApply.textColor = colorSelected;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * Taxdict = [self getTaxDictInfoAt:indexPath];
    if ([_checkedTaxItem containsObject:Taxdict]) {
        [_checkedTaxItem removeObject:Taxdict];
    }
    else {
        [_checkedTaxItem addObject:Taxdict];
    }
    
    [_aTableView reloadData];
}


-(NSMutableDictionary *)getTaxDictInfoAt:(NSIndexPath *)indexPath{
    TaxMaster *supplier = [self.itemTaxList objectAtIndexPath:indexPath];
    return [self getTaxDictInfo:supplier];
}

-(NSMutableDictionary *)getTaxDictInfo:(TaxMaster *)txMaster {
    NSMutableDictionary *taxDict=[[NSMutableDictionary alloc]init];
    taxDict[@"TAXNAME"] = txMaster.taxNAME;
    taxDict[@"PERCENTAGE"] = txMaster.percentage;
    taxDict[@"TaxId"] = txMaster.taxId;
    taxDict[@"Amount"] = txMaster.amount;
    return taxDict;
}

-(IBAction)backToItemView:(id)sender
{
    [self exitTimerViewController];
}

- (void)exitTimerViewController {
    arrayCheckedArry=[[NSMutableArray alloc]initWithArray:_checkedTaxItem];
    [self.rimTaxAddRemovePageDelegate didSelectTax:arrayCheckedArry];
}

#pragma mark -
#pragma mark Mamory Management

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - UITextFieldDelegate -

- (void)textFieldDidEndEditing:(UITextField *)textField {
    strSearchMaster = textField.text;
    [self reloadeMasterList];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    strSearchMaster = @"";
    [self reloadeMasterList];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    strSearchMaster = textField.text;
    [self reloadeMasterList];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {   // return NO to not change text
    if (_itemTaxList.fetchedObjects.count > 0) {
        NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.aTableView scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
    strSearchMaster = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self reloadeMasterList];
    return YES;
}

-(IBAction)btnreloadeMasterList:(id)sender {
    [self.txtMasterName resignFirstResponder];
}
-(void)reloadeMasterList{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _itemTaxList = nil;
        [self.aTableView reloadData];
    });
}

-(void)showMessageOfChangePriceTitle:(NSString *) messageTitle withMessage:(NSString *) message{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
    };
    [self.rmsDbController popupAlertFromVC:self title:messageTitle message:message buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

#pragma mark - CoreData Methods
- (NSFetchedResultsController *)itemTaxList {
    
    if (_itemTaxList != nil) {
        return _itemTaxList;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"taxNAME" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    if (strSearchMaster.length > 0) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"taxNAME LIKE[cd] %@",[NSString stringWithFormat:@"*%@*",strSearchMaster]];
    }
    
    if ([UpdateManager countForContext:_managedObjectContext FetchRequest:fetchRequest] == 0) {
        fetchRequest.predicate = nil;
        [self showMessageOfChangePriceTitle:@"Item Management" withMessage:[NSString stringWithFormat:@"No Record Found for %@",strSearchMaster]];
        strSearchMaster = @"";
        _txtMasterName.text = @"";
    }
    
    _itemTaxList = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_itemTaxList performFetch:nil];
    _itemTaxList.delegate = self;
    
    return _itemTaxList;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.itemTaxList]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [_aTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.itemTaxList]) {
        return;
    }
    
    UITableView *tableView = _aTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] != NSNotFound) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.itemTaxList]) {
        return;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.itemTaxList]) {
        return;
    }
    [_aTableView endUpdates];
}
@end
