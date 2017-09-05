//
//  rimDepartmentVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "GroupModifierListVC.h"
#import "RmsDbController.h"
#import "RimsController.h"

#import "Modifire_M+Dictionary.h"

#import "UITableViewCell+NIB.h"
#import "GroupModifierCustomCell.h"
#import "AddGroupModifierVC.h"

@interface GroupModifierListVC ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, strong) NSFetchedResultsController *groupModifierResultController;
@property (nonatomic, strong) NSFetchedResultsController *previousGroupMasterResultsController;

@property (nonatomic, weak) IBOutlet UITableView *tblGroupModifier;
@property (nonatomic, weak) IBOutlet UITextField *txtSearchGroupModifier;

@end

@implementation GroupModifierListVC
@synthesize groupModifierResultController = _groupModifierResultController;

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
    self.rimsController = [RimsController sharedrimController];
    
    // Discount Mix Match Cell
    NSString *departmentNib;
    if(IsPhone())
    {
        departmentNib = @"GroupModifierCustomCell";
    }
    else
    {
        departmentNib = @"GroupModifierCustomCell_iPad";
    }
    UINib *mixMatchNib = [UINib nibWithNibName:departmentNib bundle:nil];
    [self.tblGroupModifier registerNib:mixMatchNib forCellReuseIdentifier:@"GroupModifierCustomCell"];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Search Group Master

- (IBAction)btnSearchGroupModifierClick:(id)sender{

    if(self.txtSearchGroupModifier.text.length > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadDepartmentTable];
        });
    }
}

-(NSPredicate *)searchPredicateForDeptText:(NSString *)searchData
{
    NSMutableArray *textArray=[[searchData componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;

    // For - Filter the when I click "return" or "search button" - Keyword
    dbFields = @[ @"modifireName contains[cd] %@" ];

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

#pragma mark - Fetch All Department

- (NSFetchedResultsController *)departmentResultController {
    
    if (_groupModifierResultController != nil) {
        return _groupModifierResultController;
    }
    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Modifire_M" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
//    if (self.txtSearchGroupModifier.text != nil && ![self.txtSearchGroupModifier.text isEqualToString:@""]) {
//        NSPredicate *searchPredicate = [self searchPredicateForDeptText:self.txtSearchGroupModifier.text];
//        [fetchRequest setPredicate:searchPredicate];
//        NSInteger isRecordFound = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
//
//        if(isRecordFound == 0)
//        {
//            
//            groupModifierListVC * __weak myWeakReference = self;
//            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//            {
//                [myWeakReference.txtSearchGroupModifier becomeFirstResponder];
//            };
//            
//            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Group Modifier found" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
//
//            _departmentResultController = self.previousDepartmentResultsController;
//            return _departmentResultController;
//        }
//    }

    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifireName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _groupModifierResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_groupModifierResultController performFetch:nil];
    _groupModifierResultController.delegate = self;

    self.previousGroupMasterResultsController = _groupModifierResultController;

    return _groupModifierResultController;
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.departmentResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)configureGroupModifierCell:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupModifierCustomCell";
    GroupModifierCustomCell *groupModifierCell = [self.tblGroupModifier dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Modifire_M *modifire_M = [self.departmentResultController objectAtIndexPath:indexPath];
    NSMutableDictionary *departmentDictionary = [modifire_M.itemModifireMDictionary mutableCopy];
    
    AsyncImageView *oldImage = (AsyncImageView *)
    [groupModifierCell.contentView viewWithTag:999];
    [oldImage removeFromSuperview];
    
    groupModifierCell.groupModifierImage.tag = 999;
//    NSString *checkImageName = [departmentDictionary objectForKey:@"DeptImage"];
//    
//    if ([checkImageName isEqualToString:@""])
//    {
        groupModifierCell.groupModifierImage.image = [UIImage imageNamed:@"favouriteNoImage.png"];
//    }
//    else
//    {
//        [deptCell.deptImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[departmentDictionary objectForKey:@"DeptImage"]]]];
//    }
    [groupModifierCell.contentView addSubview:groupModifierCell.groupModifierImage];
    groupModifierCell.groupModifierName.text = departmentDictionary[@"Name"];
	return groupModifierCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell.backgroundColor = [UIColor clearColor];
    if(tableView == self.tblGroupModifier)
    {
        cell = [self configureGroupModifierCell:indexPath];
    }
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    cell.selectedBackgroundView = selectionColor;
	return cell;
}

#pragma mark - Textfield delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
//    if(self.txtSearchGroupModifier.text.length > 0)
//    {
//        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self reloadDepartmentTable];
//        });
//    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    textField.text = @"";
//    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self reloadDepartmentTable];
//    });
    return NO;
}

-(void)reloadDepartmentTable
{
//    self.groupModifierResultController = nil;
//    [self.tblGroupModifier reloadData];
    [_activityIndicator hideActivityIndicator];
}

//-(IBAction)btn_back:(id)sender
//{
//    [self.rmsDbController playButtonSound];
//    self._rimController.scannerButtonCalled=@"";
//    [self presentViewController:objMenubar animated:YES completion:nil];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add & Detail Group Modifire -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"updateGroupModifier"]) {
        NSIndexPath *indexPath = [self.tblGroupModifier indexPathForCell:sender];
        Modifire_M *modifire = [self.groupModifierResultController objectAtIndexPath:indexPath];
        NSMutableDictionary *modifireDictionary = [modifire.itemModifireMDictionary mutableCopy];
        AddGroupModifierVC *addGroupModifierVC = (AddGroupModifierVC *)segue.destinationViewController;
        addGroupModifierVC.updateGroupModifierDictioanry = modifireDictionary;
    }
}
@end