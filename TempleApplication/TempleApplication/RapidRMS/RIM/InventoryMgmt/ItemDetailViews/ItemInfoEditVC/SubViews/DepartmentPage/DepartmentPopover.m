//
//  DepartmentViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 12/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "DepartmentPopover.h"
#import "UITableView+AddBorder.h"

#import "RmsDbController.h"
#import "Department+Dictionary.h"

#import "SubDepartment+Dictionary.h"
#import "AddDepartmentVC.h"
#import "DepartmentSelectionCell.h"
#import "UpdateManager.h"
@interface DepartmentPopover ()<AddDepartmentVCDelegate,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate> {
    NSInteger IndexSound;
    NSString * strSearchMaster;
    UIColor * colorDefault;
    UIColor * colorSelected;
    UIImage * imgDefault;
    UIImage * imgSelected;
}
@property (nonatomic, strong) NSFetchedResultsController *departmentResultController;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) ItemInfoEditVC *objAddDelegate;

@property (nonatomic, strong) NSString *selectedDeptName;
@property (nonatomic, strong) NSString *selectedDeptId;
@property (nonatomic, strong) NSString *preDeptId;

@property (nonatomic, weak) IBOutlet UITextField * txtMasterName;

@property (nonatomic, strong) NSRecursiveLock *rimDeptLock;


@end

@implementation DepartmentPopover
@synthesize departmentResultController = _departmentResultController;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    IndexSound = -1;
    colorDefault = [UIColor blackColor];
    colorSelected = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    imgDefault = [UIImage imageNamed:@"radiobtn.png"];
    imgSelected = [UIImage imageNamed:@"radioselected.png"];
    strSearchMaster = @"";
}


#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)rimDeptLock {
    if (_rimDeptLock == nil) {
        _rimDeptLock = [[NSRecursiveLock alloc] init];
    }
    return _rimDeptLock;
}

-(void)lockResultController
{
    [self.rimDeptLock lock];
}

-(void)unlockResultController
{
    [self.rimDeptLock unlock];
}

-(void)setDepartmentResultController:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.rimDeptLock];
    _departmentResultController = resultController;
    [lock unlock];
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
    if (_departmentResultController.fetchedObjects.count > 0) {
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
        _departmentResultController = nil;
        [self.aTableView reloadData];
    });
}

-(void)showMessageOfChangePriceTitle:(NSString *) messageTitle withMessage:(NSString *) message{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
    };
    [self.rmsDbController popupAlertFromVC:self title:messageTitle message:message buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

#pragma mark - Fetch All Department

- (NSFetchedResultsController *)departmentResultController {
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.rimDeptLock];
    
    if (_departmentResultController != nil) {
        return _departmentResultController;
    }
    
    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    

    NSPredicate *isDisplayInPosPredicate = [NSPredicate predicateWithFormat:@"isNotDisplay != %@",@(1)];
        
    fetchRequest.predicate = isDisplayInPosPredicate;

    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deptName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    if (strSearchMaster.length > 0) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"deptName LIKE[cd] %@",[NSString stringWithFormat:@"*%@*",strSearchMaster]];
    }

    if ([UpdateManager countForContext:_managedObjectContext FetchRequest:fetchRequest] == 0) {
        fetchRequest.predicate = nil;
        [self showMessageOfChangePriceTitle:@"Item Management" withMessage:[NSString stringWithFormat:@"No Record Found for %@",strSearchMaster]];
        strSearchMaster = @"";
        _txtMasterName.text = @"";
    }
    
    // Create and initialize the fetch results controller.
    _departmentResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_departmentResultController performFetch:nil];
    _departmentResultController.delegate = self;
    
    [lock unlock];
    return _departmentResultController;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.selectedDeptId = self.getDeptId;
    self.selectedDeptName = self.getDeptName;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction) toolBarActionHandler:(id)sender {
	switch ([sender tag]) {
		case 101:
            self.objAddDelegate.itemInfoDataObject.DepartId = @(self.preDeptId.intValue);
            [self.view removeFromSuperview];
			break;
		case 102:
           self.objAddDelegate.itemInfoDataObject.DepartId = @(self.selectedDeptId.intValue);
            [self.view removeFromSuperview];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.departmentResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DepartmentSelectionCell * cell=(DepartmentSelectionCell *)[self.aTableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[DepartmentSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    Department *dept = [self.departmentResultController objectAtIndexPath:indexPath];
    NSMutableDictionary *departmentDictionary = [dept.departmentLoadDictionary mutableCopy];

    if([[departmentDictionary valueForKey:@"isNotApplyInItem"] integerValue ] == 1)
    {
        cell.userInteractionEnabled = NO;
        cell.lblDoNotApply.hidden = FALSE;
        cell.imgIsSelected.hidden = TRUE;
    }
    else
    {
        cell.userInteractionEnabled = YES;
        cell.lblDoNotApply.hidden = TRUE;
        cell.imgIsSelected.hidden = FALSE;
    }
    cell.lblDeptName.text = [NSString stringWithFormat:@"%@",[departmentDictionary valueForKey:@"DepartmentName"]];
    cell.lblDeptName.textColor = colorDefault;
    cell.imgIsSelected.image = imgDefault;

    NSString *deptID = [NSString stringWithFormat:@"%@",[departmentDictionary valueForKey:@"DeptId"]];
    if([deptID isEqualToString:self.selectedDeptId])
    {
        IndexSound = indexPath.row;
        cell.lblDeptName.textColor = colorSelected;
        cell.imgIsSelected.image = imgSelected;
        self.preDeptId = self.selectedDeptId;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Department *dept = [self.departmentResultController objectAtIndexPath:indexPath];
    NSMutableDictionary *departmentDictionary = [dept.departmentLoadDictionary mutableCopy];
    
    if(!([[departmentDictionary valueForKey:@"isNotApplyInItem"] integerValue ] == 1))
    {
        IndexSound = indexPath.row;
        self.getDeptName = @"";
        self.getDeptId = @"";
        Department *dept = [self.departmentResultController objectAtIndexPath:indexPath];
        NSMutableDictionary *departmentDictionary = [[dept departmentLoadDictionary] mutableCopy];
        
        NSMutableDictionary *dictTemp = [departmentDictionary mutableCopy];
        if([[dictTemp valueForKey:@"DeptId"] integerValue] == 0)
        {
            self.selectedDeptName = @"None";
            self.selectedDeptId = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"DeptId"]];
        }
        else
        {
            self.selectedDeptName = dictTemp[@"DepartmentName"];
            self.selectedDeptId = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"DeptId"]];
        }
        [tableView reloadData];
    }
}


- (IBAction)btnNewDeptClicked:(UIButton *)sender
{
    AddDepartmentVC *addDepartmentVC =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"AddDepartmentVC_sid"];
    addDepartmentVC.addDepartmentVCDelegate = self;
    [self presentViewController:addDepartmentVC animated:YES completion:nil];
}

-(void)didAddedNewDepartment:(NSDictionary *)addedDepatmentDict{
    if ([[addedDepatmentDict valueForKey:@"IsNotApplyInItem"] boolValue]) {
        NSDictionary *newDepartmentDictionary = @{@"DeptId": @"0",
                                                  @"DeptName": @"None"
                                                  };
        [self.departmentPopoverDelegate newDepartmentSelected:newDepartmentDictionary];
    }
    else
    {
        [self.departmentPopoverDelegate newDepartmentSelected:addedDepatmentDict];
    }
    [self.navigationController popViewControllerAnimated:YES];
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

-(IBAction)backToItemView:(id)sender
{
    [self exitTimerViewController];
}

- (void)exitTimerViewController
{
    if (self.navigationController)
    {
        if ([self.selectedDeptId isEqualToString:@"0"]) {
            self.selectedDeptName = @"None";
        }

        self.objAddDelegate.itemInfoDataObject.DepartId = @(self.selectedDeptId.intValue);
        NSDictionary *deptDict = @{
                                   @"DeptName" : self.selectedDeptName,
                                   @"DeptId" : self.selectedDeptId
                                   };
        [self.departmentPopoverDelegate didChangeSelectedDepartment:deptDict];
        [Appsee addEvent:kRIMItemDepartmentSelected withProperties:deptDict];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.view removeFromSuperview];
    }
}
/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if(controller != _departmentResultController)
    {
        [self unlockResultController];
        return;
    }
    else if (_departmentResultController == nil){
        [self unlockResultController];
        return;
    }

    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.aTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != _departmentResultController)
    {
        return;
    }
    else if (_departmentResultController == nil){
        return;
    }

    UITableView *tableView = self.aTableView;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.aTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(controller != _departmentResultController)
    {
        return;
    }
    else if (_departmentResultController == nil){
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.aTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.aTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.aTableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.aTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.aTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != _departmentResultController)
    {
        return;
    }
    else if (_departmentResultController == nil) {
        return;
    }
    [self.aTableView endUpdates];
    [self unlockResultController];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
