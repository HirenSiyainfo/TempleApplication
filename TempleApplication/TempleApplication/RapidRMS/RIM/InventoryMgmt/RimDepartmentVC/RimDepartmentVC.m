//
//  rimDepartmentVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "rimDepartmentVC.h"
#import "RmsDbController.h"
#import "RimDepartmentVC.h"

#import "Department+Dictionary.h"

#import "UITableViewCell+NIB.h"
#import "DepartmentCustomCell.h"
#import "RimMenuVC.h"
#import "AddDepartmentVC.h"
#import "RimIphonePresentMenu.h"

@interface RimDepartmentVC () {
    RimIphonePresentMenu * objMenubar;
    UIImage * imgNornal;
    UIImage * imgSelected;
}
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *departmentResultController;
@property (nonatomic, strong) NSFetchedResultsController *previousDepartmentResultsController;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) NSIndexPath *indPath;

@property (nonatomic, weak) IBOutlet UITableView *tblDepartment;
@property (nonatomic, weak) IBOutlet UITextField *txtSearchDepartment;

@property (nonatomic, strong) NSRecursiveLock *rimDeptLock;

@end

@implementation RimDepartmentVC
@synthesize departmentResultController = _departmentResultController;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.rimsController = [RimsController sharedrimController];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    if (IsPhone()) {
        objMenubar = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimIphonePresentMenu_sid"];
        objMenubar.sideMenuVCDelegate = self.sideMenuVCDelegate;
    }
    imgNornal = [UIImage imageNamed:@"radiobtn.png"];
    imgSelected = [UIImage imageNamed:@"radioMulti_selected.png"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    _departmentResultController = nil;
    [self.tblDepartment reloadData];
}



#pragma mark - Search Department
-(IBAction)btn_back:(id)sender {
    
    if (IsPhone()) {
        NSArray *viewcon = self.navigationController.viewControllers;
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
//-(IBAction)btnAddDepartment:(id)sender {
//    
//    [Appsee addEvent:kRIMDepartmentAdd];
//    //    [self._rimController.objSideMenuiPad showAddDepartment:nil];
//    [self showAddDepartment:nil];
//}

- (IBAction)btnSearchDepartmentClick:(id)sender{
    if(self.txtSearchDepartment.text.length > 0)
    {
        NSDictionary *searchText = @{kRIMDepartmentSearchKey : self.txtSearchDepartment.text};
        [Appsee addEvent:kRIMDepartmentSearch withProperties:searchText];
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadDepartmentTable];
        });
    }
}

-(NSPredicate *)searchPredicateForDeptText:(NSString *)searchData {
    
    NSMutableArray *textArray=[[searchData componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;

    // For - Filter the when I click "return" or "search button" - Keyword
    dbFields = @[ @"deptName contains[cd] %@" ];

    for (int i=0; i<textArray.count; i++) {
        
        NSString *str=textArray[i];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        NSMutableArray *searchTextPredicates = [NSMutableArray array];
        for (NSString *dbField in dbFields)
        {
            if (![str isEqualToString:@""])
            {
                [searchTextPredicates addObject:[NSPredicate predicateWithFormat:dbField, str]];
            }
        }
        NSPredicate *compoundpred = [NSCompoundPredicate orPredicateWithSubpredicates:searchTextPredicates];
        [fieldWisePredicates addObject:compoundpred];
    }
    
    NSPredicate *isDisplayInPosPredicate = [NSPredicate predicateWithFormat:@"isNotDisplay != %@",@(1)];
    
    [fieldWisePredicates addObject:isDisplayInPosPredicate];
    
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
    return finalPredicate;
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

    if (self.txtSearchDepartment.text != nil && ![self.txtSearchDepartment.text isEqualToString:@""]) {
        NSPredicate *searchPredicate = [self searchPredicateForDeptText:self.txtSearchDepartment.text];
        fetchRequest.predicate = searchPredicate;
        NSInteger isRecordFound = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
        NSDictionary *recordFoundCountDict = @{kRIMDepartmentSearchRecordFoundKey : @(isRecordFound)};
        [Appsee addEvent:kRIMDepartmentSearchRecordFound withProperties:recordFoundCountDict];
        if(isRecordFound == 0)
        {
            
            RimDepartmentVC * __weak myWeakReference = self;
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [myWeakReference.txtSearchDepartment becomeFirstResponder];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"%@ Department not found",self.txtSearchDepartment.text] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            self.txtSearchDepartment.text = @"";
            if (self.previousDepartmentResultsController.fetchedObjects.count > 0) {
                _departmentResultController = self.previousDepartmentResultsController;
            }
            else{
                _departmentResultController = self.departmentResultController;
            }
            return _departmentResultController;
        }
    }
    else{
        NSPredicate *isDisplayInPosPredicate = [NSPredicate predicateWithFormat:@"isNotDisplay != %@",@(1)];
        
        fetchRequest.predicate = isDisplayInPosPredicate;
    }

    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deptName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _departmentResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_departmentResultController performFetch:nil];
    _departmentResultController.delegate = self;

    self.previousDepartmentResultsController = _departmentResultController;
    [lock unlock];
    return _departmentResultController;
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 73;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.departmentResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)configureDepartmentCell:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DepartmentCustomCell";
    DepartmentCustomCell *deptCell = [self.tblDepartment dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Department *dept = [self.departmentResultController objectAtIndexPath:indexPath];
    NSMutableDictionary *departmentDictionary = [dept.departmentLoadDictionary mutableCopy];
    
    deptCell.deptImage.tag = 999;
    NSString *checkImageName = departmentDictionary[@"DeptImage"];
    
    if ([checkImageName isEqualToString:@""])
    {
        (deptCell.deptImage).image = [UIImage imageNamed:@"favouriteNoImage.png"];
    }
    else
    {
        [deptCell.deptImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",departmentDictionary[@"DeptImage"]]]];
    }
    [deptCell.contentView addSubview:deptCell.deptImage];
    deptCell.departmentName.text = departmentDictionary[@"DepartmentName"];
    
    if([departmentDictionary[@"isTax"] integerValue ] == 1)
    {
        deptCell.taxApply.image = imgSelected;
    }
    else
    {
        deptCell.taxApply.image = imgNornal;
    }
    
    if([departmentDictionary[@"isDeduct"] integerValue ] == 1)
    {
        deptCell.payoutApply.image = imgSelected;
    }
    else
    {
        deptCell.payoutApply.image = imgNornal;
    }
    
    if(departmentDictionary[@"ApplyAgeDesc"] == nil || [departmentDictionary[@"ApplyAgeDesc"] isEqualToString:@"Select"])
    {
        deptCell.ageRestricted.text = @"- - -";
    }
    else
    {
        deptCell.ageRestricted.text = departmentDictionary[@"ApplyAgeDesc"];
    }
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    deptCell.selectedBackgroundView = selectionColor;
    return deptCell;
}

-(void)deleteDepartment:(id)sender
{
    [self.rmsDbController playButtonSound];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblDepartment];
    NSIndexPath *indexPath = [self.tblDepartment indexPathForRowAtPoint:buttonPosition];
    Department *department = [self.departmentResultController objectAtIndexPath:indexPath];
   
    if(department.departmentItems.count > 0 || department.departmentSubDepartments.count > 0){
     
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please remove items and subdepartment associate with this departemnt" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];

    }
    else{
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(tableView == self.tblDepartment)
    {
        cell = [self configureDepartmentCell:indexPath];
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
	return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    Department *dept = [self.departmentResultController objectAtIndexPath:indexPath];
//    NSMutableDictionary *departmentDictionary = [dept.getdepartmentLoadDictionary mutableCopy];
//    NSDictionary *deptDict = @{kRIMDepartmentSelectedKey : [departmentDictionary valueForKey:@"deptId"]};
//    [Appsee addEvent:kRIMDepartmentSelected withProperties:deptDict];
//    
//    [self showAddDepartment:departmentDictionary];
//    [self.rimsController.objSideMenuiPad showAddDepartment:departmentDictionary];
//}

#pragma mark - Textfield delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
//    if(self.txtSearchDepartment.text.length > 0)
//    {
        NSDictionary *searchText = @{kRIMDepartmentSearchKey : textField.text};
        [Appsee addEvent:kRIMDepartmentSearch withProperties:searchText];
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadDepartmentTable];
        });
    //}

    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    [Appsee addEvent:kRIMDepartmentClearSearchText];
    textField.text = @"";
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadDepartmentTable];
    });
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
        if(range.location == 0 && ([string isEqualToString:@""]))
        {
            textField.text = @"";
            [self clearTextAndReloadDepartmentData];
        }
        return YES;
}

- (void)clearTextAndReloadDepartmentData
{
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadDepartmentTable];
    });
}

-(void)reloadDepartmentTable
{
    self.departmentResultController = nil;
    [self.tblDepartment reloadData];
    [_activityIndicator hideActivityIndicator];
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
    [self.tblDepartment beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != _departmentResultController)
    {
        return;
    }
    else if (_departmentResultController == nil){
        return;
    }

    UITableView *tableView = self.tblDepartment;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tblDepartment reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            [self.tblDepartment insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblDepartment deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tblDepartment reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tblDepartment deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tblDepartment insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != _departmentResultController)
    {
        return;
    }
    else if (_departmentResultController == nil){
        return;
    }

    [self.tblDepartment endUpdates];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add & Detail Department (Segue) -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"updateDepartment"]) {
        NSIndexPath *indexPath = [self.tblDepartment indexPathForCell:sender];
        Department *dept = [self.departmentResultController objectAtIndexPath:indexPath];
        NSMutableDictionary *departmentDictionary = [dept.getdepartmentLoadDictionary mutableCopy];
        AddDepartmentVC *addDepartmentVC = (AddDepartmentVC *)segue.destinationViewController;
        addDepartmentVC.updateDepartmentDictioanry = departmentDictionary;
    }
}

@end
