//
//  DepartmetCollectionVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/30/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "SubDeptItemCollectionVC.h"
#import "SubDeptItemCollectionCell.h"
#import "RmsDbController.h"
#import "RcrController.h"

#import "Item+Dictionary.h"
#import "Department+Dictionary.h"

typedef NS_ENUM(NSUInteger, SubDeptOperation)
{
    INSERT_SUBDEPT,
    UPDATE_SUBDEPT,
    DELETE_SUBDEPT,
    MOVE_SUBDEPT,
    INSERT_SUBDEPT_SECTION,
    DELETE_SUBDEPT_SECTION,
};

@interface SubDeptItemCollectionVC ()
{
    NSNumber *selectedSubDeptId;
    NSNumber *selectedDeptId;
    SubDepartment *subDepartmentSelected;
    Department *departmentSelected;
}

@property (nonatomic, weak) IBOutlet UICollectionView *subDeptItemCollectionView;

@property (nonatomic, strong) NSFetchedResultsController *subDeptResultController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UIPageControl *departmentPageControl;
@property (nonatomic, strong) NSRecursiveLock *subDeptItemLock;
@property (nonatomic, strong) NSMutableArray *subDeptOperation;

@end

@implementation SubDeptItemCollectionVC
@synthesize subDeptResultController = _subDeptResultController;
@synthesize managedObjectContext = __managedObjectContext;

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
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
   // self.departmentPageControl.hidden = YES;
    self.subDeptItemCollectionView.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)loadItemsOfSubDepartment:(SubDepartment *)selectedSubDepartment
{
    subDepartmentSelected = selectedSubDepartment;
    selectedSubDeptId = selectedSubDepartment.brnSubDeptID;
//    selectedDeptId = nil;
    [self refreshItemList];
}

-(void)loadItemsOfDepartment:(Department *)selectedDepartment
{
    departmentSelected = selectedDepartment;
    subDepartmentSelected = nil;
    selectedSubDeptId = nil;
    selectedDeptId = selectedDepartment.deptId;
    [self refreshItemList];
}

-(void)refreshItemList
{
    self.subDeptResultController = nil;
    [self.subDeptItemCollectionView reloadData];
}

#pragma mark - Fetched Department results controller

- (NSFetchedResultsController *)subDeptResultController {
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.subDeptItemLock];
    if (_subDeptResultController != nil) {
        return _subDeptResultController;
    }

    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Create the predicate
    if(selectedSubDeptId == nil)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId == %@ AND itm_Type != %@ AND itemSubDepartment == %@ AND itm_Type == %@  AND active == %d", selectedDeptId, @(-1), nil, @"0",TRUE];
        fetchRequest.predicate = predicate;
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subDeptId == %@ AND itm_Type == %@  AND active == %d", selectedSubDeptId, @"0",TRUE];
        fetchRequest.predicate = predicate;
    }
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sectionLabel" ascending:YES selector:@selector(localizedCompare:)];
    
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _subDeptResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [_subDeptResultController performFetch:nil];
    _subDeptResultController.delegate = self;
    [lock unlock];
    return _subDeptResultController;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.subDeptItemCollectionView.frame.size.height;
    self.departmentPageControl.currentPage = (self.subDeptItemCollectionView.contentOffset.y + pageWidth / 2) / pageWidth;
}

#pragma mark - UICollectionView Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSArray *sections = self.subDeptResultController.sections;
    return sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sections = self.subDeptResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    [self.subDepartmetItemsCountDelegate didChangeSubDepartmentItemCount:sectionInfo.numberOfObjects];
    
    if (self.numerOfItemPerPage == 0) {
        self.numerOfItemPerPage = 9;
    }
    float Pages = ceilf(sectionInfo.numberOfObjects/self.numerOfItemPerPage);
    self.departmentPageControl.numberOfPages = Pages;
    
    if(subDepartmentSelected)
    {
        return sectionInfo.numberOfObjects+1;
    }
    
    return sectionInfo.numberOfObjects;
}

- (void)configureSubDepartmentItem:(NSIndexPath *)indexPath itemCell:(SubDeptItemCollectionCell *)itemCell
{
    Item *anItem = [self.subDeptResultController objectAtIndexPath:indexPath];
    NSMutableDictionary *itemDictionary = [anItem.itemRMSDictionary mutableCopy];
    
    NSString *checkImageName = itemDictionary[@"ItemImage"];
    if ([checkImageName isEqualToString:@""])
    {
        itemCell.itemNoImage.image = [UIImage imageNamed:@"rcr_noimageforringeduplist.png"];
        itemCell.itemImage.image = [UIImage imageNamed:@""];
        itemCell.itemNameNoImg.text = itemDictionary[@"ItemName"];
        itemCell.itemName.text = @"";

    }
    else
    {
        [itemCell.itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",itemDictionary[@"ItemImage"]]]];
        itemCell.itemNoImage.image = [UIImage imageNamed:@""];
        itemCell.itemName.text = itemDictionary[@"ItemName"];
        itemCell.itemNameNoImg.text = @"";
    }
    
    if([[itemDictionary valueForKeyPath:@"IsPriceAtPOS" ] boolValue ])
    {
        itemCell.itemSalesPrice.text = @"";
        itemCell.bgPrice.hidden = YES;
    }
    else
    {
        if([[itemDictionary valueForKeyPath:@"PriceScale" ] isEqualToString:@"WSCALE"] ||
           [[itemDictionary valueForKeyPath:@"PriceScale" ] isEqualToString:@"APPPRICE"] ||
           [[itemDictionary valueForKeyPath:@"PriceScale" ] isEqualToString:@"VARIATIONAPPROPRIATE"] )
        {
            NSNumber *sPrice = @([itemDictionary[@"SalesPrice"] floatValue]);
            itemCell.itemSalesPrice.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sPrice]];
            itemCell.bgPrice.hidden = NO;
        }
        else // VARIATION
        {
            itemCell.itemSalesPrice.text = @"";
            itemCell.bgPrice.hidden = YES;
        }
    }
    
}

//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfRowsInSection:(NSInteger)section
//{
//        NSArray *sections = [self.subDeptResultController sections];
//        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
//        return [sectionInfo numberOfObjects];
//
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubDeptItemCollectionCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SubDeptItemCollectionCell" forIndexPath:indexPath];
    
    //itemCell.layer.borderWidth = 1.0;
    //itemCell.layer.borderColor = [[UIColor lightGrayColor] CGColor ];
    itemCell.layer.cornerRadius = 10.0;
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(196/255.f) green:(237/255.f) blue:(224/255.f) alpha:1.0];
    itemCell.selectedBackgroundView = selectionColor;
    
    UIView *backColor = [[UIView alloc] init];
    backColor.backgroundColor = [UIColor clearColor];
    itemCell.backgroundView = backColor;
    
    if(subDepartmentSelected)
    {
        if(indexPath.row == 0)
        {
            Item *anItem = [self fetchAllItems:subDepartmentSelected.itemCode.stringValue ];
            NSMutableDictionary *itemDictionary = [anItem.itemRMSDictionary mutableCopy];
            
            NSString *checkImageName = itemDictionary[@"ItemImage"];
            if ([checkImageName isEqualToString:@""])
            {
                itemCell.itemNoImage.image = [UIImage imageNamed:@"rcr_noimageforringeduplist.png"];
                itemCell.itemImage.image = [UIImage imageNamed:@""];
                itemCell.itemNameNoImg.text = itemDictionary[@"ItemName"];
                itemCell.itemName.text = @"";
            }
            else
            {
                [itemCell.itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",itemDictionary[@"ItemImage"]]]];
                itemCell.itemNoImage.image = [UIImage imageNamed:@""];

                itemCell.itemName.text = itemDictionary[@"ItemName"];
                itemCell.itemNameNoImg.text = @"";
            }
            
            if([[itemDictionary valueForKeyPath:@"IsPriceAtPOS" ] boolValue ])
            {
                itemCell.itemSalesPrice.text = @"";
                itemCell.bgPrice.hidden = YES;
            }
            else
            {
                NSNumber *sPrice = @([itemDictionary[@"SalesPrice"] floatValue]);
                itemCell.itemSalesPrice.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sPrice]];
                itemCell.bgPrice.hidden = NO;
            }
        }
        else
        {
            indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            [self configureSubDepartmentItem:indexPath itemCell:itemCell];
        }
    }
    else
    {
        [self configureSubDepartmentItem:indexPath itemCell:itemCell];
    }
    [itemCell.contentView addSubview:itemCell.itemName];
    [itemCell.contentView addSubview:itemCell.itemNameNoImg];
    return itemCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(subDepartmentSelected)
    {
        if(indexPath.row == 0)
        {
            if(subDepartmentSelected.itemCode)
            {
                [self.subDepartmetItemsVcDelegate didSelectSubDeptFromItem:subDepartmentSelected department:departmentSelected];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"SubDepartment is not configuared as Item." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
        else
        {
            indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            Item *anItem = [self.subDeptResultController objectAtIndexPath:indexPath];
            [self.subDepartmetItemsVcDelegate didSelectSubDeptItem:anItem];
        }
    }
    else
    {
        Item *anItem = [self.subDeptResultController objectAtIndexPath:indexPath];
        [self.subDepartmetItemsVcDelegate didSelectSubDeptItem:anItem];
    }
    
}

- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if (![controller isEqual:self.subDeptResultController]) {
        [self unlockResultController];
        return;
    }
    else if (_subDeptResultController == nil){
        [self unlockResultController];
        return;
    }

    self.subDeptOperation = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.subDeptResultController]) {
        return;
    }
    else if (_subDeptResultController == nil){
        return;
    }

    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.subDeptOperation addObject:@{@(INSERT_SUBDEPT):[newIndexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [self.subDeptOperation addObject:@{@(DELETE_SUBDEPT):[indexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            [self.subDeptOperation addObject:@{@(UPDATE_SUBDEPT):[indexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeMove:
        {
            [self.subDeptOperation addObject:@{@(MOVE_SUBDEPT):@[[indexPath copy],[newIndexPath copy]]}];
        }
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.subDeptResultController]) {
        return;
    }
    else if (_subDeptResultController == nil){
        return;
    }

    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.subDeptOperation addObject:@{@(INSERT_SUBDEPT_SECTION):@(sectionIndex)}];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [self.subDeptOperation addObject:@{@(DELETE_SUBDEPT_SECTION):@(sectionIndex)}];
        }
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.subDeptResultController]) {
        return;
    }
    else if (_subDeptResultController == nil){
        return;
    }

    [self.subDeptItemCollectionView performBatchUpdates:^{
        for (int i = 0; i < self.subDeptOperation.count; i++)
        {
            NSDictionary *tenderDict = (self.subDeptOperation)[i];
            NSArray *tenderAllKey = tenderDict.allKeys;
            NSNumber *tenderType = tenderAllKey.firstObject;
            SubDeptOperation subDeptSection = tenderType.integerValue;
            switch (subDeptSection) {
                case INSERT_SUBDEPT:
                {
                    NSIndexPath *insertIndPath = tenderDict[tenderType];
                    [self.subDeptItemCollectionView insertItemsAtIndexPaths:@[insertIndPath]];
                }
                    break;
                    
                case DELETE_SUBDEPT:
                {
                    NSIndexPath *deleteIndPath = tenderDict[tenderType];
                    [self.subDeptItemCollectionView deleteItemsAtIndexPaths:@[deleteIndPath]];
                }
                    break;
                    
                case UPDATE_SUBDEPT:
                {
                    NSIndexPath *updateIndPath = tenderDict[tenderType];
                    [self.subDeptItemCollectionView reloadItemsAtIndexPaths:@[updateIndPath]];
                }
                    break;
                    
                case MOVE_SUBDEPT:
                {
                    NSArray *moveIndPath = tenderDict[tenderType];
                    NSIndexPath *delIndPath = moveIndPath.firstObject ;
                    NSIndexPath *insIndPath = moveIndPath[1];
                    [self.subDeptItemCollectionView moveItemAtIndexPath:delIndPath toIndexPath:insIndPath];
                }
                    break;
                    
                case INSERT_SUBDEPT_SECTION:
                {
                    NSNumber *sectionIndex = tenderDict[tenderType];
                    [self.subDeptItemCollectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue ]];
                }
                    break;
                    
                case DELETE_SUBDEPT_SECTION:
                {
                    NSNumber *sectionIndex = tenderDict[tenderType];
                    [self.subDeptItemCollectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue ]];
                }
                    break;
                    
                default:
                    break;
            }
        }
    } completion:^(BOOL finished){
        [self unlockResultController];
        NSArray *sections = self.subDeptResultController.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
        [self.subDepartmetItemsCountDelegate didChangeSubDepartmentItemCount:sectionInfo.numberOfObjects];

    }];
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)subDeptItemLock {
    if (_subDeptItemLock == nil) {
        _subDeptItemLock = [[NSRecursiveLock alloc] init];
    }
    return _subDeptItemLock;
}

-(void)lockResultController
{
    [self.subDeptItemLock lock];
}

-(void)unlockResultController
{
    [self.subDeptItemLock unlock];
}

-(void)setSubDeptResultController:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc]initWithLock:self.subDeptItemLock];
    _subDeptResultController = resultController;
    [lock unlock];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
