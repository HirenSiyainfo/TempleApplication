//
//  MMDItemListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 20/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDItemListVC.h"
#import "RmsDbController.h"
#import "Item+Dictionary.h"
#import "MMDItemSelectionCell.h"

@interface MMDItemListVC ()<NSFetchedResultsControllerDelegate> {
    NSArray * arrAllIndexPath;
    UIColor * selectedColor;
//    UIColor * addedItemsColor;
    UIImage * imgSelectedItem;
    NSString * strSortKey;
    BOOL isAscending;
    Configuration *configuration;
}

@property (nonatomic, strong) NSFetchedResultsController * MMDiscountItemListRC;
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) RmsDbController * rmsDbController;
@property (nonatomic, weak) IBOutlet UIButton * btnSortName;
@property (nonatomic, weak) IBOutlet UIButton * btnSortPrice;

@end

@implementation MMDItemListVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.rmsDbController = [RmsDbController sharedRmsDbController];
//    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.managedObjectContext setParentContext:[RmsDbController sharedRmsDbController].managedObjectContext];
    [self.managedObjectContext setUndoManager:nil];
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    imgSelectedItem = [UIImage imageNamed:@"radioMulti_selected.png"];
    self.arrSelectedItem = [[NSMutableArray alloc]init];
    selectedColor = [UIColor colorWithRed:0.816 green:0.886 blue:0.902 alpha:1.000];
    isAscending = TRUE;
    strSortKey = @"item_Desc";
    self.tblMMDiscountItemList.tableFooterView = [[UIView alloc]init];
//    addedItemsColor = [UIColor colorWithWhite:0.914 alpha:1.000];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.Delegate respondsToSelector:@selector(didItemTitleListReloaded:)]) {
        NSMutableArray * arrTitleList = [[NSMutableArray alloc] initWithArray:_MMDiscountItemListRC.sectionIndexTitles];
        [arrTitleList addObject:@"ALL"];
        [self.Delegate didItemTitleListReloaded:arrTitleList];
    }
    [self checkAllItemSelected];
}
#pragma mark - setter -
-(void)setArrAddedItem:(NSArray *)arrAddedItem {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"itemCode IN %@",arrAddedItem];
    NSArray * arrAllObject = self.MMDiscountItemListRC.fetchedObjects;
    NSMutableArray * arrAddedObj =[[arrAllObject filteredArrayUsingPredicate:predicate] mutableCopy];
    [arrAddedObj setValue:@(1) forKeyPath:@"is_Selected"];
    _arrAddedItem = arrAddedItem;
}
-(void)setFilterMasterPredicate:(NSPredicate *)filterMasterPredicate {
    if (![_filterMasterPredicate isEqual:filterMasterPredicate] || !_filterMasterPredicate) {
        _filterTextSearchPredicate = nil;
        _filterMasterPredicate = filterMasterPredicate;
        [self.arrSelectedItem removeAllObjects];
        self.MMDiscountItemListRC = nil;
    }
    [self.tblMMDiscountItemList reloadData];
    [self checkAllItemSelected];

}
-(void)setFilterTextSearchPredicate:(NSPredicate *)filterTextSearchPredicate {
//    if (filterTextSearchPredicate) {
        _filterTextSearchPredicate = filterTextSearchPredicate;
        [self.arrSelectedItem removeAllObjects];
        self.MMDiscountItemListRC = nil;
        [self.tblMMDiscountItemList reloadData];
        [self checkAllItemSelected];
//    }
}
-(void)setStrItemSectionTitle:(NSString *)strItemSectionTitle {
    if ([strItemSectionTitle isEqualToString:@"ALL"]) {
        _filterTextSearchPredicate = nil;
        _filterMasterPredicate = nil;
        self.MMDiscountItemListRC = nil;
        [self.tblMMDiscountItemList reloadData];
        [self.tblMMDiscountItemList setContentOffset:CGPointZero animated:YES];
    }
    else {
        NSArray * attTitleList =_MMDiscountItemListRC.sectionIndexTitles;
        if (attTitleList.count>0) {
            if ([strItemSectionTitle isEqualToString:@"#"]) {
                if (isAscending) {
                    strItemSectionTitle = attTitleList.firstObject;
                }
                else{
                    strItemSectionTitle = attTitleList.lastObject;
                }
            }
            NSInteger index = [attTitleList indexOfObject:strItemSectionTitle];
            NSInteger indexForRow =  [_MMDiscountItemListRC sectionForSectionIndexTitle:strItemSectionTitle atIndex:index];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:indexForRow];
            [self.tblMMDiscountItemList scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    _strItemSectionTitle = strItemSectionTitle;
}
-(void)setIsAllSelected:(BOOL)isAllSelected {
    NSArray * arrAllObject = self.MMDiscountItemListRC.fetchedObjects;
    [self.arrSelectedItem removeAllObjects];

    if (isAllSelected) {
        [arrAllObject setValue:@(1) forKeyPath:@"is_Selected"];
        [self.arrSelectedItem addObjectsFromArray:arrAllObject];
    }
    else {
        [arrAllObject setValue:@(0) forKeyPath:@"is_Selected"];
        NSArray * arrAddedObject = [[NSArray alloc]initWithArray:self.arrAddedItem];
        self.arrAddedItem = arrAddedObject;
    }
    [self checkAllItemSelected];
    [self.tblMMDiscountItemList reloadRowsAtIndexPaths:self.tblMMDiscountItemList.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
}
#pragma mark - Item Sort -
-(IBAction)btnSortItemNameTapped:(UIButton *)sender {
    if (![strSortKey isEqualToString:@"item_Desc"]) {
        isAscending = FALSE;
        strSortKey = @"item_Desc";
    }
    isAscending =! isAscending;
    [self resetSortButtonAndListWithNewButton:sender];
}
-(IBAction)btnSortItemPriceTapped:(UIButton *)sender {
    if (![strSortKey isEqualToString:@"salesPrice"]) {
        isAscending = FALSE;
        strSortKey = @"salesPrice";
    }
    isAscending =! isAscending;
    [self resetSortButtonAndListWithNewButton:sender];
}
-(void)resetSortButtonAndListWithNewButton:(UIButton *)sender {
    self.MMDiscountItemListRC = nil;
    [self.tblMMDiscountItemList reloadData];
    [self checkAllItemSelected];

    UIImage * image = [UIImage imageNamed:@"ascending_descending_white.png"];
    [self.btnSortName setImage:image forState:UIControlStateNormal];
    [self.btnSortPrice setImage:image forState:UIControlStateNormal];
    NSString * strImageName = @"descending_white.png";
    if (isAscending) {
        strImageName = @"ascending_white.png";
    }
    [sender setImage:[UIImage imageNamed:strImageName] forState:UIControlStateNormal];
}
#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    NSArray *sections = self.MMDiscountItemListRC.sections;
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *sections = self.MMDiscountItemListRC.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MMDItemSelectionCell *cell = (MMDItemSelectionCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemListCell" forIndexPath:indexPath];
    Item *anItem = [self.MMDiscountItemListRC objectAtIndexPath:indexPath];
    cell.lblName.text = anItem.item_Desc;
    cell.lblUPC.text = anItem.barcode;
    cell.lblPrice.text = [NSString stringWithFormat:@"$ %.2f",anItem.salesPrice.floatValue];
    
    UIView * selBG = [[UIView alloc]init];
    selBG.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = selBG;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];

    cell.imgSelected.image = nil;
    if ([self.arrAddedItem containsObject:anItem.itemCode]) {
        cell.imgSelected.image = imgSelectedItem;
    }
    else {
        if ([self.arrSelectedItem containsObject:anItem]) {
            cell.backgroundColor = selectedColor;
            cell.contentView.backgroundColor = selectedColor;
        }
        else {
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
    }
    
    return cell;
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Item *anItem = [self.MMDiscountItemListRC objectAtIndexPath:indexPath];
    if (![self.arrAddedItem containsObject:anItem.itemCode]) {
        if ([self.arrSelectedItem containsObject:anItem]) {
            anItem.is_Selected = @(0);
            [self.arrSelectedItem removeObject:anItem];
        }
        else {
            [self.arrSelectedItem addObject:anItem];
            anItem.is_Selected = @(1);
        }
        [self checkAllItemSelected];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
-(void)checkAllItemSelected {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL isAllSelected = FALSE;
        
        NSArray * arrAllObject = self.MMDiscountItemListRC.fetchedObjects;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"is_Selected==%d",1];
        NSInteger count =[arrAllObject filteredArrayUsingPredicate:predicate].count;

        if (self.MMDiscountItemListRC.fetchedObjects.count == count && self.arrSelectedItem.count > 0) {
            isAllSelected = TRUE;
        }
        if ([self.Delegate respondsToSelector:@selector(didAllItemSelected:)]) {
            [self.Delegate didAllItemSelected:isAllSelected];
        }
    });
}

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([configuration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

#pragma mark - CoreData Methods -
- (NSFetchedResultsController *)MMDiscountItemListRC {
    
    if (_MMDiscountItemListRC != nil) {
        return _MMDiscountItemListRC;
    }
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor;
    NSString * strSection = nil;
    if ([strSortKey isEqualToString:@"item_Desc"]) {
        aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:strSortKey ascending:isAscending selector:@selector(caseInsensitiveCompare:)];
       // strSection = @"sectionLabel";
    }
    else{
        aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:strSortKey ascending:isAscending];
    }
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;

    
    NSMutableArray *subPredicates = [[NSMutableArray alloc]init];
    
    if ([self isSubDepartmentEnableInBackOffice]) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"itm_Type != %@ AND active == %d AND isNotDisplayInventory == %@",@(-1),TRUE,@(0)]];
    }
    else {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"itm_Type != %@ AND itm_Type != %@ AND active == %d AND isNotDisplayInventory == %@",@(-1),@(2),TRUE,@(0)]];
    }

    
    if (_filterMasterPredicate) {
        [subPredicates addObject:_filterMasterPredicate];
    }
    if (_filterTextSearchPredicate) {
        [subPredicates addObject:_filterTextSearchPredicate];
    }
    if (subPredicates.count > 0) {
        NSPredicate * andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        fetchRequest.predicate = andPredicate;
    }
    fetchRequest.fetchBatchSize = 20;
    
    _MMDiscountItemListRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:strSection cacheName:nil];
    
    [_MMDiscountItemListRC performFetch:nil];
    _MMDiscountItemListRC.delegate = self;
    if ([self.Delegate respondsToSelector:@selector(didItemTitleListReloaded:)]) {
        NSMutableArray * arrTitleList = [[NSMutableArray alloc] initWithArray:_MMDiscountItemListRC.sectionIndexTitles];
        if (arrTitleList.count > 0) {
            [arrTitleList addObject:@"ALL"];
        }
        [self.Delegate didItemTitleListReloaded:arrTitleList];
    }
    [self reSetIndexPath];
    return _MMDiscountItemListRC;
}
-(void)reSetIndexPath {

    NSArray *sections = _MMDiscountItemListRC.sections;

    NSMutableArray * arrIndex = [[NSMutableArray alloc]init];
    for (int i=0; i<sections.count; i++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[i];
        NSInteger intAllIndexCount = sectionInfo.numberOfObjects;
        
        for (int j=0; j<intAllIndexCount; j++) {
            [arrIndex addObject:[NSIndexPath indexPathForRow:j inSection:i]];
        }
    }
    arrAllIndexPath = [[NSArray alloc]initWithArray:arrIndex];
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.MMDiscountItemListRC]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblMMDiscountItemList beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.MMDiscountItemListRC]) {
        return;
    }
    
    UITableView *tableView = self.tblMMDiscountItemList;
    
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
    if (![controller isEqual:self.MMDiscountItemListRC]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblMMDiscountItemList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblMMDiscountItemList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.MMDiscountItemListRC]) {
        return;
    }
    [self.tblMMDiscountItemList endUpdates];
}
@end
