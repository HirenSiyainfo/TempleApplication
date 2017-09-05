//
//  MMDSelectedItemListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 25/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDSelectedItemListVC.h"
#import "MMDItemSelectionCell.h"
#import "Item+Dictionary.h"
#import "Discount_Secondary_MD.h"
#import "Discount_Primary_MD.h"
#import "RmsDbController.h"
#import "MultipleBarcodeRingUpForItemMovement.h"
#import "MMDSlideItemListVC.h"

@interface MMDSelectedItemListVC ()<MMDItemSelectionCellDelegate,UITextFieldDelegate,MultipleBarcodePopUpForIMVCDelegate> {
    NSMutableDictionary * dictItemList;
    NSArray * arrItemTypeList;
}
@property (nonatomic, weak) IBOutlet UIView * viewEditingView;
@property (nonatomic, weak) IBOutlet UILabel * lblTitle;
@property (nonatomic, weak) IBOutlet UILabel * lblisXTitle;

@property (nonatomic, weak) IBOutlet UITextField *txtSerachBarcode;

@property (nonatomic, strong) NSString * strSearchText;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) MultipleBarcodeRingUpForItemMovement *multipleBarcodeRingUpForItemMovement;
@end

@implementation MMDSelectedItemListVC
@synthesize managedObjectContext = __managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.tblSelectedItemList.tableFooterView = [[UIView alloc]init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.view.bounds.size.height < 400) {
        _viewEditingView.hidden = FALSE;
    }
    else {
        _viewEditingView.hidden = TRUE;
    }
    if ([self isXContainer]) {
        _lblisXTitle.text = @"X";
    }
    else {
        _lblisXTitle.text = @"Y";
    }
    if (self.view.tag == 100) {
        _lblisXTitle.text = @"X";
    }
}
-(BOOL)isXContainer {
    return  (self.view.tag == 500 )? TRUE : FALSE;
}
#pragma mark - setter -
-(void)setStrTitleOfContainer:(NSString *)strTitleOfContainer {
    _strTitleOfContainer = strTitleOfContainer;
    _lblTitle.text = _strTitleOfContainer;
}
-(void)setArrSelectedItem:(NSMutableArray *)arrSelectedItem{
    if (dictItemList) {
        [dictItemList removeAllObjects];
    }
    else {
        dictItemList = [[NSMutableDictionary alloc]init];
    }
    NSMutableArray * arrAddedType = [[NSMutableArray alloc]init];
    NSArray * arrFilterType = @[@(MMDItemSelectTypeItem),@(MMDItemSelectTypeDepartment),@(MMDItemSelectTypeGroup),@(MMDItemSelectTypeTag)];
    for (NSNumber * itemType in arrFilterType) {
        NSPredicate * filterItem = [NSPredicate predicateWithFormat:@"itemType == %@",itemType];
        NSMutableArray * arrFilteredList = [[NSMutableArray alloc] initWithArray:[arrSelectedItem filteredArrayUsingPredicate:filterItem]];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self.itemDetail.item_Desc" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];

        if (arrFilteredList.count > 0) {
            [arrFilteredList sortUsingDescriptors:sortDescriptors];
            dictItemList[itemType.stringValue] = arrFilteredList;
            [arrAddedType addObject:itemType.stringValue];
        }
    }
    
    arrItemTypeList = [[NSArray alloc]initWithArray:arrAddedType];
    _arrSelectedItem = arrSelectedItem;
    [self.tblSelectedItemList reloadData];
}

#pragma mark - IBAction -
-(IBAction)fullScreenSelectedItemView:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.Delegate respondsToSelector:@selector(isFullScreenView:isXitemContainer:)]) {
        [self.Delegate isFullScreenView:sender.selected isXitemContainer:[self isXContainer]];
    }
}
-(IBAction)deleteSelectedItem:(UIButton *)sender {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return arrItemTypeList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 23;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 23)];
    
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, view.frame.size.width-20, view.frame.size.height)];
    [label setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0]];
    label.backgroundColor = [UIColor clearColor];
    MMDItemSelectType itemType = (MMDItemSelectType)[arrItemTypeList[section] intValue];

    NSString *sectionTitle = [self getItemTypeStringFromType:itemType];
    [label setText:sectionTitle];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithWhite:0.933 alpha:1.000]]; //your background color...
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSString * strKey = arrItemTypeList[section];
    NSArray * arrItemList = dictItemList[strKey];
    return arrItemList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MMDItemSelectionCell *cell = (MMDItemSelectionCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    NSString * strKey = arrItemTypeList[indexPath.section];
    NSArray * arrItemList = dictItemList[strKey];
    if ([self isXContainer]) {
        Discount_Secondary_MD * MMDItem = arrItemList[indexPath.row];
        cell.lblName.text = MMDItem.itemDetail.item_Desc;
        cell.lblUPC.text = MMDItem.itemDetail.barcode;
        cell.lblPrice.text = [NSString stringWithFormat:@"$ %.2f",MMDItem.itemDetail.salesPrice.floatValue];
        cell.btnDelete.tag = indexPath.row;

    }
    else {
        Discount_Primary_MD * MMDItem = arrItemList[indexPath.row];
        cell.lblName.text = MMDItem.itemDetail.item_Desc;
        cell.lblUPC.text = MMDItem.itemDetail.barcode;
        cell.lblPrice.text = [NSString stringWithFormat:@"$ %.2f",MMDItem.itemDetail.salesPrice.floatValue];
        NSInteger tag = (indexPath.row*10)+indexPath.section;
        cell.btnDelete.tag = tag;
    }
    cell.tableView = tableView;
    cell.Delegate = self;
    return cell;
}
-(void)didDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        [self.tblSelectedItemList beginUpdates];
        NSString * strKey = arrItemTypeList[indexPath.section];
        NSMutableArray * arrSectionItems = [[NSMutableArray alloc]initWithArray:dictItemList[strKey]];
        id MMDitem = arrSectionItems[indexPath.row];
        [arrSectionItems removeObject:MMDitem];
        [_arrSelectedItem removeObject:MMDitem];
        NSMutableArray * arrSectionList = [[NSMutableArray alloc]init];
        BOOL isSeccionDelete = FALSE;
        if (arrSectionItems.count == 0) {
            [dictItemList removeObjectForKey:strKey];
            NSMutableArray * arrAddedType = [[NSMutableArray alloc]initWithArray:arrItemTypeList];
            [arrAddedType removeObject:strKey];
            arrItemTypeList = [[NSArray alloc]initWithArray:arrAddedType];
            [arrSectionList addObject:@(indexPath.section)];
            isSeccionDelete = TRUE;
        }
        else {
            dictItemList[strKey] = arrSectionItems;
        }
        
        [self.tblSelectedItemList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if (isSeccionDelete) {
            [self.tblSelectedItemList deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tblSelectedItemList endUpdates];
        [self.Delegate didDeleteItemInContainer];
    }
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(NSString *)getItemTypeStringFromType:(MMDItemSelectType) itemType{
    NSString * strType = @"";
    switch (itemType) {
        case MMDItemSelectTypeItem: {
            strType = @"ITEM";
            break;
        }
        case MMDItemSelectTypeDepartment: {
            strType = @"DEPARTMENT";
            break;
        }
        case MMDItemSelectTypeGroup: {
            strType = @"GROUP";
            break;
        }
        case MMDItemSelectTypeTag: {
            strType = @"TAG";
            break;
        }
    }
    return strType;
}

#pragma mark - Textfield Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self searchBarcodeItem];
    return YES;
}

- (void)searchBarcodeItem
{
    BOOL isNumeric;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:_txtSerachBarcode.text];
    isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    NSString * itemBarcode = _txtSerachBarcode.text;
    self.strSearchText = itemBarcode;
    if (isNumeric) // numeric
    {
        itemBarcode = [self.rmsDbController trimmedBarcode:itemBarcode];
    }
    Item *item=nil;
    NSArray *itemsForBarcode = [self fetchItemWithItemBarcode:_txtSerachBarcode.text];
    if(itemsForBarcode.count == 0)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"No Item with UPC #%@ found.", itemBarcode ] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        _txtSerachBarcode.text = @"";
        return;
    }
    else
    {
        if (itemsForBarcode.count == 1)
        {
            item = itemsForBarcode.firstObject;
            if ([self isAlreadyAvailableInList:item]) {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Item already available in list with UPC #%@.", itemBarcode ] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                _txtSerachBarcode.text = @"";
                return;
            }
            else {
                //Add scanned items to list
                [self addScannedItemsToSelectedDiscountedItems:@[item]];
            }
        }
        else if (itemsForBarcode.count > 1)
        {
            NSMutableArray *remainingItemsArray = [[self removeAlreadyAvailableItemsInList:itemsForBarcode] copy];
            if (remainingItemsArray && remainingItemsArray.count > 0) {
                if (remainingItemsArray.count == 1) {
                    //Add scanned items to list
                    [self addScannedItemsToSelectedDiscountedItems:remainingItemsArray];
                }
                else {
                    //Show multiple scanned items in PopUp
                    [self showMultipleItemForBarcodeWithDetail:remainingItemsArray withItemBarcode:_txtSerachBarcode.text];
                }
            }
            else {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"All items already available in list with UPC #%@.",_txtSerachBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                _txtSerachBarcode.text = @"";
                return;
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"No Record Found for %@",_txtSerachBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            _txtSerachBarcode.text = @"";
            return;
        }
        _txtSerachBarcode.text = @"";
    }
}

- (void)addScannedItemsToSelectedDiscountedItems:(NSArray *)scannedItems {
    NSMutableArray *arrNewAddedItem = [NSMutableArray array];
    [arrNewAddedItem addObjectsFromArray:[self MMDItemListFromItemArray:scannedItems withItemType:@(ItemListViewTypesItem)]];
    NSSet * uniqeuObject = [NSSet setWithArray:arrNewAddedItem];
    NSMutableArray *selectedItemsObjects = [[NSMutableArray alloc] initWithArray:self.arrSelectedItem];
    [selectedItemsObjects addObjectsFromArray:uniqeuObject.allObjects];
    self.arrSelectedItem = [[NSMutableArray alloc] initWithArray:selectedItemsObjects];
}

- (BOOL)isAlreadyAvailableInList:(Item *)serachItem {
    BOOL isAlreadyAvailable = false;
    NSArray *filterArray = [self filterScanItemsFromDiscountedItems:serachItem];
    if (filterArray && filterArray.count>0) {
        isAlreadyAvailable = true;
    }
    return isAlreadyAvailable;
}

- (NSArray *)filterScanItemsFromDiscountedItems:(Item *)serachItem {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %d",[serachItem.itemCode integerValue]];
    NSArray *filterArray = [self.arrSelectedItem filteredArrayUsingPredicate:predicate];
    return filterArray;
}

- (NSMutableArray *)removeAlreadyAvailableItemsInList:(NSArray *)itemsArray {
    NSMutableArray *allScannedItems = [[NSMutableArray alloc] initWithArray:itemsArray];
    for (Item *scannedItem in itemsArray) {
        if ([self isAlreadyAvailableInList:scannedItem]) {
            [allScannedItems removeObject:scannedItem];
        }
    }
    return allScannedItems;
}

-(NSArray *)MMDItemListFromItemArray:(NSArray *)arrItem withItemType:(NSNumber *)numItemType{
    NSMutableArray * arrMMDItems = [[NSMutableArray alloc]init];
    for (Item * anItem in arrItem) {
        if (self.isXitemList && self.isMandMDiscount) {
            Discount_Secondary_MD * mMDItem = [NSEntityDescription insertNewObjectForEntityForName:@"Discount_Secondary_MD" inManagedObjectContext:self.moc];
            mMDItem.createdDate = [NSDate date];
            mMDItem.secondaryId = @(0);
            mMDItem.itemId = anItem.itemCode;
            mMDItem.itemType = numItemType;
            mMDItem.discountId = @(0);
            mMDItem.itemDetail = [self.moc objectWithID:anItem.objectID];
            
            [arrMMDItems addObject:mMDItem];
        }
        else {
            Discount_Primary_MD * mMDItem = [NSEntityDescription insertNewObjectForEntityForName:@"Discount_Primary_MD" inManagedObjectContext:self.moc];
            mMDItem.createdDate = [NSDate date];
            mMDItem.primaryId = @(0);
            mMDItem.itemId = anItem.itemCode;
            mMDItem.itemType = numItemType;
            mMDItem.discountId = @(0);
            mMDItem.itemDetail = [self.moc objectWithID:anItem.objectID];
            
            [arrMMDItems addObject:mMDItem];
        }
    }
    return arrMMDItems;
}

- (NSArray *)fetchItemWithItemBarcode :(NSString *)itemData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY itemBarcodes.barCode == %@ ",itemData];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return resultSet;
}

#pragma mark - MultipleItemBarcodeRingUp

-(void)showMultipleItemForBarcodeWithDetail :(NSArray *)itemArray withItemBarcode:(NSString *)barcode
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MMDiscount" bundle:nil];
    _multipleBarcodeRingUpForItemMovement = [storyBoard instantiateViewControllerWithIdentifier:@"MultipleBarcodeRingUpForItemMovement"];
    _multipleBarcodeRingUpForItemMovement.modalPresentationStyle = UIModalPresentationFullScreen;
    _multipleBarcodeRingUpForItemMovement.multipleBarcodePopUpForIMVCDelegate = self;
    _multipleBarcodeRingUpForItemMovement.itemBarcode = barcode;
    _multipleBarcodeRingUpForItemMovement.multipleItemArray = [itemArray mutableCopy];
    _multipleBarcodeRingUpForItemMovement.view.frame =self.view.bounds;
    _multipleBarcodeRingUpForItemMovement.view.frame = CGRectMake(0, 0, 1024, 768);
    if (self.isXitemList & !self.isMandMDiscount) {
        [self.view.superview.superview addSubview:_multipleBarcodeRingUpForItemMovement.view];
    }
    else {
        [self.view.superview.superview.superview addSubview:_multipleBarcodeRingUpForItemMovement.view];
    }
}


-(void)didSelectItemsForScanningItemForDuplicateBarcode:(NSArray *)selectedItems {
    [_multipleBarcodeRingUpForItemMovement.view removeFromSuperview];
    //Add scanned items to list
    [self addScannedItemsToSelectedDiscountedItems:selectedItems];
}

-(void)didCanceItemsSelection {
    [_multipleBarcodeRingUpForItemMovement.view removeFromSuperview];
    _txtSerachBarcode.text = @"";
}

@end
