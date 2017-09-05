//
//  rimDepartmentVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "SubDepartmentVC.h"
#import "RmsDbController.h"
#import "RimsController.h"

#import "SubDepartment+Dictionary.h"
#import "Department+Dictionary.h"

#import "UITableViewCell+NIB.h"
#import "SubDepartmentCell.h"
#import "AddSubDepartmentVC.h"


@interface SubDepartmentVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSFetchedResultsController *subDepartmentResultController;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UITableView *tblSubDepartment;
@property (nonatomic, weak) IBOutlet UITextField *txtSearchSubDepartment;

@property (nonatomic, strong) NSRecursiveLock *subDeptLock;

@end

@implementation SubDepartmentVC
@synthesize subDepartmentResultController = _subDepartmentResultController;

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
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    // Discount Mix Match Cell
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _subDepartmentResultController = nil;
    [self.tblSubDepartment reloadData];
}

#pragma mark - Search SubDepartment

- (IBAction)btnSearchSubDepartmentClick:(id)sender{
    NSDictionary *searchDict = @{kRIMSubDepartmentSearchKey: self.txtSearchSubDepartment.text};
    [Appsee addEvent:kRIMSubDepartmentSearch withProperties:searchDict];
    if(self.txtSearchSubDepartment.text.length > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadSubDepartmentTable];
        });
    }
}

-(NSPredicate *)searchPredicateForSubDeptText:(NSString *)searchData
{
    NSMutableArray *textArray=[[searchData componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;

    // For - Filter the when I click "return" or "search button" - Keyword
        dbFields = @[ @"subDeptName contains[cd] %@" ];

    for (int i=0; i<textArray.count; i++)
    {
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
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
    return finalPredicate;
}


#pragma mark - Fetch All SubDepartment

- (NSFetchedResultsController *)subDepartmentResultController {
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.subDeptLock];
    if (_subDepartmentResultController != nil) {
        return _subDepartmentResultController;
    }

    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubDepartment" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;

    if (self.txtSearchSubDepartment.text != nil && ![self.txtSearchSubDepartment.text isEqualToString:@""]) {
        NSPredicate *searchPredicate = [self searchPredicateForSubDeptText:self.txtSearchSubDepartment.text];
        fetchRequest.predicate = searchPredicate;
        NSInteger isRecordFound = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
        NSDictionary *recordFoundCountDict = @{kRIMSubDepartmentSearchRecordFoundKey : @(isRecordFound)};
        [Appsee addEvent:kRIMSubDepartmentSearchRecordFound withProperties:recordFoundCountDict];
        if(isRecordFound == 0)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [self.txtSearchSubDepartment becomeFirstResponder];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"%@ sub-department not found",self.txtSearchSubDepartment.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            self.txtSearchSubDepartment.text = @"";
            return [self subDepartmentResultController];
        }
    }

    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"subDeptName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _subDepartmentResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_subDepartmentResultController performFetch:nil];
    _subDepartmentResultController.delegate = self;

    [lock unlock];
    return _subDepartmentResultController;
}

#pragma mark - Textfield delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(self.txtSearchSubDepartment.text.length > 0)
    {
        NSDictionary *searchDict = @{kRIMSubDepartmentSearchKey: textField.text};
        [Appsee addEvent:kRIMSubDepartmentSearch withProperties:searchDict];
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadSubDepartmentTable];
        });
    }

    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    [Appsee addEvent:kRIMSubDepartmentClearSearchText];
    textField.text = @"";
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadSubDepartmentTable];
    });

    return NO;
}

-(void)reloadSubDepartmentTable
{
    self.subDepartmentResultController = nil;
    [self.tblSubDepartment reloadData];
    [_activityIndicator hideActivityIndicator];
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.subDepartmentResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)configureDepartmentCell:(NSIndexPath *)indexPath
{
    SubDepartmentCell *subDepartmentCell = [self.tblSubDepartment dequeueReusableCellWithIdentifier:@"SubDepartmentCustomCell"];
    
    SubDepartment *subDept = [self.subDepartmentResultController objectAtIndexPath:indexPath];
    NSMutableDictionary *subDepartmentDictionary = [subDept.getSubDepartmentDictionary mutableCopy];


    
    NSString *checkImageName = subDepartmentDictionary[@"SubDeptImagePath"];
    
    if ([checkImageName isEqualToString:@""])
    {
        subDepartmentCell.subDeptImage.image = [UIImage imageNamed:@"favouriteNoImage.png"];
    }
    else
    {
        [subDepartmentCell.subDeptImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",subDepartmentDictionary[@"SubDeptImagePath"]]]];
    }
    subDepartmentCell.subDepartmentName.text = subDepartmentDictionary[@"SubDeptName"];
    subDepartmentCell.contentView.backgroundColor = [UIColor clearColor];
    subDepartmentCell.backgroundColor = [UIColor clearColor];

	return subDepartmentCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell.backgroundColor = [UIColor clearColor];
    if(tableView == self.tblSubDepartment)
    {
        cell = [self configureDepartmentCell:indexPath];
    }
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    cell.selectedBackgroundView = selectionColor;
	return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    SubDepartment *subDept = [self.subDepartmentResultController objectAtIndexPath:indexPath];
//    NSMutableDictionary *subDepartmentDictionary = [subDept.getSubDepartmentDictionary mutableCopy];
//    NSDictionary *subDeptDict = @{kRIMSubDepartmentSelectedKey : [subDepartmentDictionary valueForKey:@"BrnSubDeptID"]};
//    [Appsee addEvent:kRIMSubDepartmentSelected withProperties:subDeptDict];
//    [self showAddSubDepartment:subDepartmentDictionary];
//
//}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)subDeptLock {
    if (_subDeptLock == nil) {
        _subDeptLock = [[NSRecursiveLock alloc] init];
    }
    return _subDeptLock;
}

-(void)lockResultController
{
    [self.subDeptLock lock];
}

-(void)unlockResultController
{
    [self.subDeptLock unlock];
}

-(void)setSubDepartmentResultController:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.subDeptLock];
    _subDepartmentResultController = resultController;
    [lock unlock];
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if(controller != _subDepartmentResultController)
    {
        [self unlockResultController];
        return;
    }
    else if (_subDepartmentResultController == nil){
        [self unlockResultController];
        return;
    }

    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblSubDepartment beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != _subDepartmentResultController)
    {
        return;
    }
    else if (_subDepartmentResultController == nil){
        return;
    }

    UITableView *tableView = self.tblSubDepartment;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tblSubDepartment reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(controller != _subDepartmentResultController)
    {
        return;
    }
    else if (_subDepartmentResultController == nil){
        return;
    }

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblSubDepartment insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblSubDepartment deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //[self.tblSubDepartment reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            //[self.tblSubDepartment deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            //[self.tblSubDepartment insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != _subDepartmentResultController)
    {
        return;
    }
    else if (_subDepartmentResultController == nil){
        return;
    }

    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tblSubDepartment endUpdates];
    [self unlockResultController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add & Detail SubDepartment (Segue) -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"updateSubDepartment"]) {
        NSIndexPath *indexPath = [self.tblSubDepartment indexPathForCell:sender];
        SubDepartment *subDept = [self.subDepartmentResultController objectAtIndexPath:indexPath];
        NSMutableDictionary *subDepartmentDict = [subDept.getSubDepartmentDictionary mutableCopy];
        AddSubDepartmentVC *addSubDepartmentVC = (AddSubDepartmentVC *)segue.destinationViewController;
        addSubDepartmentVC.updateSubDepartmentDictionary = subDepartmentDict;
    }
}

@end
