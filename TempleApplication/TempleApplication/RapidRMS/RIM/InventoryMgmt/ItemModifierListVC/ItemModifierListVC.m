//
//  rimDepartmentVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemModifierListVC.h"
#import "RmsDbController.h"
#import "RimsController.h"

#import "ModifireList_M+Dictionary.h"

#import "UITableViewCell+NIB.h"
#import "ItemModifierCustomCell.h"
#import "AddGroupItemModifierVC.h"

@interface ItemModifierListVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *itemModifierResultController;
@property (nonatomic, strong) NSFetchedResultsController *previousItemMasterResultsController;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UITableView *tblGroupItemModifier;
@property (nonatomic, weak) IBOutlet UITextField *txtSearchItemModifier;

@end

@implementation ItemModifierListVC
@synthesize itemModifierResultController = _itemModifierResultController;


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
    NSString *departmentNib;
    if(IsPhone())
    {
        departmentNib = @"ItemModifierCustomCell";
    }
    else
    {
        departmentNib = @"ItemModifierCustomCell_iPad";
    }
    UINib *mixMatchNib = [UINib nibWithNibName:departmentNib bundle:nil];
    [self.tblGroupItemModifier registerNib:mixMatchNib forCellReuseIdentifier:@"ItemModifierCustomCell"];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
//    self.itemModifierResultController = nil;
//    [self groupItemModifierResultController];
//    [self.tblGroupItemModifier reloadData];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    (self.navigationItem).title = @"Item Modifier";
//    (self.navigationController.navigationBar).barTintColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
//    (self.navigationController.navigationBar).titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
//    self.navigationItem.hidesBackButton=YES;
}

#pragma mark - Search Group Master

- (IBAction)btnSearchGroupMasterClick:(id)sender{
    
    if(self.txtSearchItemModifier.text.length > 0)
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

- (NSFetchedResultsController *)groupItemModifierResultController {
    
    if (_itemModifierResultController != nil) {
        return _itemModifierResultController;
    }
    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ModifireList_M" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
//        if (self.txtSearchItemModifier.text != nil && ![self.txtSearchItemModifier.text isEqualToString:@""]) {
//            NSPredicate *searchPredicate = [self searchPredicateForDeptText:self.txtSearchItemModifier.text];
//            [fetchRequest setPredicate:searchPredicate];
//            NSInteger isRecordFound = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
//    
//            if(isRecordFound == 0)
//            {
//                            itemModifierListVC * __weak myWeakReference = self;
//                            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//                            {
//                                [myWeakReference.txtSearchItemModifier becomeFirstResponder];
//                            };
//                
//                            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Item Modifier found" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
//                _departmentResultController = self.previousDepartmentResultsController;
//                return _departmentResultController;
//            }
//        }
    
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifireItem" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _itemModifierResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_itemModifierResultController performFetch:nil];
    _itemModifierResultController.delegate = self;
    
    self.previousItemMasterResultsController = _itemModifierResultController;
    
    return _itemModifierResultController;
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.groupItemModifierResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)configureGroupModifierCell:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemModifierCustomCell";
    ItemModifierCustomCell *itemModifierCell = [self.tblGroupItemModifier dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ModifireList_M *modifireList_M = [self.groupItemModifierResultController objectAtIndexPath:indexPath];
    NSMutableDictionary *departmentDictionary = [modifireList_M.itemModifireItemMDictionary mutableCopy];
    
    AsyncImageView *oldImage = (AsyncImageView *)
    [itemModifierCell.contentView viewWithTag:999];
    [oldImage removeFromSuperview];
    
    itemModifierCell.itemModifierImage.tag = 999;
    //    NSString *checkImageName = [departmentDictionary objectForKey:@"DeptImage"];
    //
    //    if ([checkImageName isEqualToString:@""])
    //    {
    itemModifierCell.itemModifierImage.image = [UIImage imageNamed:@"favouriteNoImage.png"];
    //    }
    //    else
    //    {
    //        [deptCell.deptImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[departmentDictionary objectForKey:@"DeptImage"]]]];
    //    }
    [itemModifierCell.contentView addSubview:itemModifierCell.itemModifierImage];
    itemModifierCell.itemModifierName.text = departmentDictionary[@"ModifireItem"];
	return itemModifierCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell.backgroundColor = [UIColor clearColor];
    if(tableView == self.tblGroupItemModifier)
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
    //    if(self.txtSearchItemModifier.text.length > 0)
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
//    self.itemModifierResultController = nil;
//    [self.tblGroupItemModifier reloadData];
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

#pragma mark - Add & Detail Item Modifier (Segue) -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"updateItemModifier"]) {
        NSIndexPath *indexPath = [self.tblGroupItemModifier indexPathForCell:sender];
        ModifireList_M *modifireList_M = [self.itemModifierResultController objectAtIndexPath:indexPath];
        NSMutableDictionary *modifireItemDictionary = [modifireList_M.itemModifireItemMDictionary mutableCopy];
        AddGroupItemModifierVC *addGroupItemModifierVC = (AddGroupItemModifierVC *)segue.destinationViewController;
        addGroupItemModifierVC.updateItemModifierDictioanry = modifireItemDictionary;
    }
}
@end