//
//  ICReconcileCompletePopUp.m
//  RapidRMS
//
//  Created by siya8 on 17/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ICReconcileCompletePopUp.h"
#import "DepartmentPopover.h"
#import "DepartmentSelectionCell.h"
#import "Department.h"
#import "Department+Dictionary.h"
#import "RmsDbController.h"

@interface ICReconcileCompletePopUp ()
{
    BOOL includeUncountedItem;
    Department *department;
}
@property (nonatomic, weak) IBOutlet UIButton *sendUncounted;
@property (nonatomic, weak) IBOutlet UIButton *ignoreUncounted;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *layoutDeptViewHeight;
@property (nonatomic, strong) NSFetchedResultsController *departmentResultController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) IBOutlet UITableView * aTableView;
@property (nonatomic, strong) NSRecursiveLock *rimDeptLock;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) IBOutlet UIButton * btnSelection;


@end

@implementation ICReconcileCompletePopUp
@synthesize departmentResultController = _departmentResultController;

- (void)viewDidLoad {
    [super viewDidLoad];
    includeUncountedItem = NO;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    self.layoutDeptViewHeight.constant = 0;
    [UIView animateWithDuration:0.5 animations:^{[self.view layoutIfNeeded];}];

     [self addConstraint];
    _arrSelectedDepartment = [NSMutableArray array];
    _arrSelectedDepartment = self.departmentResultController.fetchedObjects.mutableCopy;
    [self updateButtonState];
    // Do any additional setup after loading the view.
}

-(void)addConstraint{
    self.deptView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Trailing
    NSLayoutConstraint *trailing =[NSLayoutConstraint
                                   constraintWithItem:self.deptView
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.deptView
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:0.f];
    
    //Leading
    
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:self.deptView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.deptView
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    
    
    //Top
    NSLayoutConstraint *top =[NSLayoutConstraint
                                 constraintWithItem:self.deptView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.deptView
                                 attribute:NSLayoutAttributeTop
                                 multiplier:1.0f
                                 constant:0.f];
    //Bottom
    NSLayoutConstraint *bottom =[NSLayoutConstraint
                                 constraintWithItem:self.deptView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.deptView
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1.0f
                                 constant:0.f];
    

    
    [self.deptView addConstraint:trailing];
    [self.deptView addConstraint:bottom];
    [self.deptView addConstraint:leading];
    [self.deptView addConstraint:top];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sendUncounted:(id)sender
{
    includeUncountedItem = YES;
    _sendUncounted.selected = YES;
    _ignoreUncounted.selected = NO;
    self.layoutDeptViewHeight.constant = 300;
    [self updateButtonState];
    [UIView animateWithDuration:0.5 animations:^{[self.view layoutIfNeeded];}];
}

-(IBAction)ignoreUncounted:(id)sender
{
    includeUncountedItem = NO;
    _ignoreUncounted.selected = YES;
    _sendUncounted.selected = NO;
    self.layoutDeptViewHeight.constant = 0;
    [self updateButtonState];
    [UIView animateWithDuration:0.5 animations:^{[self.view layoutIfNeeded];}];
}
-(IBAction)continueComplete:(id)sender
{
    [self.reconcileCompletePopupVCDelegate completeReconcile:includeUncountedItem];
}

-(IBAction)cancelComplete:(id)sender
{
    [self.reconcileCompletePopupVCDelegate didCancel];
}

-(IBAction)selectAllDepartment:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if(sender.selected){
        [_arrSelectedDepartment removeAllObjects];
        _arrSelectedDepartment = self.departmentResultController.fetchedObjects.mutableCopy;
    }
    else{
        [_arrSelectedDepartment removeAllObjects];
    }
    [_aTableView reloadData];
}


#pragma mark TableView Delegate & Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.departmentResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DepartmentSelectionCell * cell=(DepartmentSelectionCell *)[self.aTableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[DepartmentSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    Department *dept = [self.departmentResultController objectAtIndexPath:indexPath];
    
    cell.lblDeptName.text = [NSString stringWithFormat:@"%@",dept.deptName];
    cell.lblDeptName.textColor = [UIColor blackColor];
    cell.imgIsSelected.image = [UIImage imageNamed:@"radiobtn.png"];
    
    if([_arrSelectedDepartment containsObject:dept])
    {
        cell.lblDeptName.textColor = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
        cell.imgIsSelected.image = [UIImage imageNamed:@"radioselected.png"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Department *dept = [self.departmentResultController objectAtIndexPath:indexPath];
    if([_arrSelectedDepartment containsObject:dept]){
        [_arrSelectedDepartment removeObject:dept];
    }
    else{
        [_arrSelectedDepartment addObject:dept];
    }
    [self updateButtonState];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)updateButtonState{
    if (_arrSelectedDepartment.count == _departmentResultController.fetchedObjects.count) {
        _btnSelection.selected = TRUE;
    }
    else{
        _btnSelection.selected = FALSE;
    }
}

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
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deptName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _departmentResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_departmentResultController performFetch:nil];
    _departmentResultController.delegate = self;
    
    [lock unlock];
    return _departmentResultController;
}

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

@end
