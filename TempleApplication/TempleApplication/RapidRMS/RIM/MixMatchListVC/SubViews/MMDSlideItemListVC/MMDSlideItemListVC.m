//
//  MMDSlideItemListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 25/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDSlideItemListVC.h"
#import "MMDItemSectionVC.h"
#import "MMDMasterItemListVC.h"
#import "RmsDbController.h"
#import "Discount_Secondary_MD.h"
#import "Discount_Primary_MD.h"
#import "Item+Dictionary.h"
#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif

@interface MMDSlideItemListVC ()<DidSelectItemSectionTitleDelegate,DidChangeItemListDelegate
#ifdef LINEAPRO_SUPPORTED
,DTDeviceDelegate
#endif
>
{
    
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
    
    UIViewController * currentPresentedVC;
    
    MMDItemSectionVC * itemSectionTitleVC;
    MMDItemListVC * mMDItemListVC;
    MMDMasterItemListVC * mMDMasterDepartmentListVC;
    MMDMasterItemListVC * mMDMasterGroupListVC;
    MMDMasterItemListVC * mMDMasterTagListVC;
    
    NSArray * addedItems;
    NSMutableString *status;
}
@property (nonatomic, weak) IBOutlet UIView * viewSlideSubView;
@property (nonatomic, weak) IBOutlet UIView * viewSlideItemTitleDetail;
@property (nonatomic, weak) IBOutlet UILabel * lblDiscountQTY;
@property (nonatomic, weak) IBOutlet UILabel * lblDiscountAmount;
@property (nonatomic, weak) IBOutlet UITextField * txtSearchText;
@property (nonatomic, weak) IBOutlet UIButton * btnSelectDeselectItem;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@end

@implementation MMDSlideItemListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    status=[[NSMutableString alloc] init];
    [self addItemSectionTitleVC];
    [self addItemVC];
    [self addGroupVC];
    [self addTagVC];
    [self addDepartmentVC];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#ifdef LINEAPRO_SUPPORTED
    // Linea Barcode device connection
    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [dtdev connect];
    
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#ifdef LINEAPRO_SUPPORTED
    // Linea Barcode device connection
    [dtdev disconnect];
#endif

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addItemSectionTitleVC {
    if (!itemSectionTitleVC) {
        itemSectionTitleVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDItemSectionVC_sid"];
        
        itemSectionTitleVC.view.frame = _viewSlideItemTitleDetail.bounds;
        itemSectionTitleVC.Delegate = self;
        [self addChildViewController:itemSectionTitleVC];
        [_viewSlideItemTitleDetail addSubview:itemSectionTitleVC.view];
    }
}
-(void)addItemVC {
    if (!mMDItemListVC) {
        mMDItemListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDItemListVC_sid"];
        
        mMDItemListVC.view.frame = _viewSlideSubView.bounds;
        mMDItemListVC.filterMasterPredicate = nil;
        mMDItemListVC.Delegate = self;
    }
}
-(void)addDepartmentVC {
    if (!mMDMasterDepartmentListVC) {
        mMDMasterDepartmentListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDMasterItemListVC_sid"];
        mMDMasterDepartmentListVC.view.frame = _viewSlideSubView.bounds;
        mMDMasterDepartmentListVC.selectedMaster = MasterTypesDepartment;
        mMDMasterDepartmentListVC.Delegate = self;
        //  [self addChildViewController:mMDMasterGroupListVC];
    }
}
-(void)addGroupVC {
    if (!mMDMasterGroupListVC) {
        mMDMasterGroupListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDMasterItemListVC_sid"];
        mMDMasterGroupListVC.view.frame = _viewSlideSubView.bounds;
        mMDMasterGroupListVC.selectedMaster = MasterTypesGroup;
        mMDMasterGroupListVC.Delegate = self;
        //  [self addChildViewController:mMDMasterGroupListVC];
    }
}
-(void)addTagVC {
    if (!mMDMasterTagListVC) {
        mMDMasterTagListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDMasterItemListVC_sid"];
        mMDMasterTagListVC.view.frame = _viewSlideSubView.bounds;
        mMDMasterTagListVC.selectedMaster = MasterTypesTAG;
        mMDMasterTagListVC.Delegate = self;
        //  [self addChildViewController:mMDMasterTagListVC];
    }
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self createSearchTextFilter];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self createSearchTextFilter];
    return YES;
}
#pragma mark - setter -

-(void)setResetNewInfo:(NSDictionary *)resetNewInfo {
    _lblDiscountQTY.text = [resetNewInfo valueForKey:@"qty"];
    _lblDiscountAmount.text = [resetNewInfo valueForKey:@"amount"];
}

-(void)setSelectedView:(ItemListViewTypes)selectedView {
    NSMutableArray * arrAddedItems = [[[self.delegate getSelectedItems] valueForKey:@"itemId"] mutableCopy];
    [currentPresentedVC.view removeFromSuperview];
    switch (selectedView) {
        case ItemListViewTypesItem: {

            currentPresentedVC = mMDItemListVC;
            itemSectionTitleVC.defaultSelectedTitle = mMDItemListVC.strItemSectionTitle;
            mMDItemListVC.filterTextSearchPredicate = nil;
            [arrAddedItems addObjectsFromArray:[mMDMasterTagListVC.arrSelectedItem valueForKey:@"itemCode"]];
            [arrAddedItems addObjectsFromArray:[mMDMasterGroupListVC.arrSelectedItem valueForKey:@"itemCode"]];
            [arrAddedItems addObjectsFromArray:[mMDMasterDepartmentListVC.arrSelectedItem valueForKey:@"itemCode"]];
            mMDItemListVC.arrAddedItem = [arrAddedItems copy];
            [mMDItemListVC.tblMMDiscountItemList reloadData];
            _txtSearchText.text = @"";
            break;
        }
        case ItemListViewTypesDepartment: {
            currentPresentedVC = mMDMasterDepartmentListVC;
            itemSectionTitleVC.defaultSelectedTitle = mMDMasterDepartmentListVC.strItemSectionTitle;
            [arrAddedItems addObjectsFromArray:[mMDItemListVC.arrSelectedItem valueForKey:@"itemCode"]];
            [arrAddedItems addObjectsFromArray:[mMDMasterGroupListVC.arrSelectedItem valueForKey:@"itemCode"]];
            [arrAddedItems addObjectsFromArray:[mMDMasterTagListVC.arrSelectedItem valueForKey:@"itemCode"]];

            mMDMasterDepartmentListVC.arrAddedItem = arrAddedItems;
            [mMDMasterDepartmentListVC.tblMMMasterItemList reloadData];
            
            break;
        }
        case ItemListViewTypesTag: {
            currentPresentedVC = mMDMasterTagListVC;
            itemSectionTitleVC.defaultSelectedTitle = mMDMasterTagListVC.strItemSectionTitle;
            [arrAddedItems addObjectsFromArray:[mMDItemListVC.arrSelectedItem valueForKey:@"itemCode"]];
            [arrAddedItems addObjectsFromArray:[mMDMasterGroupListVC.arrSelectedItem valueForKey:@"itemCode"]];
            [arrAddedItems addObjectsFromArray:[mMDMasterDepartmentListVC.arrSelectedItem valueForKey:@"itemCode"]];
            mMDMasterTagListVC.arrAddedItem = arrAddedItems;
            [mMDMasterTagListVC.tblMMMasterItemList reloadData];
            
            break;
        }
        case ItemListViewTypesGroup: {
            currentPresentedVC = mMDMasterGroupListVC;
            itemSectionTitleVC.defaultSelectedTitle = mMDMasterGroupListVC.strItemSectionTitle;
            [arrAddedItems addObjectsFromArray:[mMDItemListVC.arrSelectedItem valueForKey:@"itemCode"]];
            [arrAddedItems addObjectsFromArray:[mMDMasterTagListVC.arrSelectedItem valueForKey:@"itemCode"]];
            [arrAddedItems addObjectsFromArray:[mMDMasterDepartmentListVC.arrSelectedItem valueForKey:@"itemCode"]];
            mMDMasterGroupListVC.arrAddedItem = arrAddedItems;
            [mMDMasterGroupListVC.tblMMMasterItemList reloadData];
            break;
        }
    }
    _selectedView = selectedView;
    [self addChildViewController:currentPresentedVC];
    currentPresentedVC.view.frame = _viewSlideSubView.bounds;
    [_viewSlideSubView addSubview:currentPresentedVC.view];
    [currentPresentedVC viewWillAppear:YES];
    [currentPresentedVC didMoveToParentViewController:self];
}
-(void)didItemSectionTitleSelect:(NSString *) strTitleName {
    if ([strTitleName isEqualToString:@"ALL"]) {
        _txtSearchText.text  = @"";
    }
    switch (_selectedView) {
        case ItemListViewTypesItem: {
            mMDItemListVC.strItemSectionTitle = strTitleName;
            break;
        }
        case ItemListViewTypesDepartment: {
            mMDMasterDepartmentListVC.strItemSectionTitle = strTitleName;
            break;
        }
        case ItemListViewTypesTag: {
            mMDMasterTagListVC.strItemSectionTitle = strTitleName;
            break;
        }
        case ItemListViewTypesGroup: {
            mMDMasterGroupListVC.strItemSectionTitle = strTitleName;
            break;
        }
    }
}

-(void)didItemTitleListReloaded:(NSArray *)arrTitleList {
    itemSectionTitleVC.arrSectionTitle = arrTitleList;
}

-(void)didAllItemSelected:(BOOL)isAllSelected {
    _btnSelectDeselectItem.selected = isAllSelected;
}

-(void)searchTextChangeToNewString:(NSString *)strtext withReloadList:(BOOL)isReload {
    _txtSearchText.text = strtext;
    if (isReload) {
        [self searchItemInList:nil];
    }
}

#pragma mark - IBAction -
-(IBAction)selectAllDeselectAll:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.view endEditing:YES];
    switch (self.selectedView) {
        case ItemListViewTypesItem: {
            mMDItemListVC.isAllSelected = sender.selected;;
            break;
        }
        case ItemListViewTypesDepartment: {
            mMDMasterDepartmentListVC.isAllSelected = sender.selected;
            break;
        }
        case ItemListViewTypesTag: {
            mMDMasterTagListVC.isAllSelected = sender.selected;
            break;
        }
        case ItemListViewTypesGroup: {
            mMDMasterGroupListVC.isAllSelected = sender.selected;
            break;
        }
    }
   
}
-(IBAction)searchItemInList:(id)sender {
    if (_txtSearchText.text.length > 0) {
        [_txtSearchText resignFirstResponder];
        [self createSearchTextFilter];
    }
    else {
        [_txtSearchText becomeFirstResponder];
    }
}
-(IBAction)btnCloseSlideView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(willCloseItemSelectionView)]) {
        [self.delegate willCloseItemSelectionView];
    }
}
-(void)createSearchTextFilter{
    NSPredicate * textFilterPredicate;
    if (_txtSearchText.text.length > 0) {
        textFilterPredicate = [self getPredicateFor:_txtSearchText.text];
    }
    switch (_selectedView) {
        case ItemListViewTypesItem: {
            mMDItemListVC.filterTextSearchPredicate = textFilterPredicate;
            break;
        }
        case ItemListViewTypesDepartment: {
            mMDMasterDepartmentListVC.filterTextSearchPredicate = textFilterPredicate;
            break;
        }
        case ItemListViewTypesTag: {
            mMDMasterTagListVC.filterTextSearchPredicate = textFilterPredicate;
            break;
        }
        case ItemListViewTypesGroup: {
            mMDMasterGroupListVC.filterTextSearchPredicate = textFilterPredicate;
            break;
        }
    }
}
-(NSPredicate *)getPredicateFor:(NSString *)strSearch{
    NSArray *dbFields = @[ @"item_Desc contains[cd] %@",@"item_No == %@", @"barcode == %@", @"item_Remarks BEGINSWITH[cd] %@",@"itemDepartment.deptName BEGINSWITH[cd] %@", @"ANY itemBarcodes.barCode == %@",@"ANY itemTags.tagToSizeMaster.sizeName contains[cd] %@"];
    
    NSMutableArray *searchTextPredicates = [NSMutableArray array];
    for (NSString *dbField in dbFields)
    {
        [searchTextPredicates addObject:[NSPredicate predicateWithFormat:dbField, strSearch]];
    }
    return [NSCompoundPredicate orPredicateWithSubpredicates:searchTextPredicates];
}
-(IBAction)addNewSelectedItem:(id)sender {
    NSMutableArray * arrItemList = [self.delegate getSelectedItems];
    NSMutableArray * arrNewAddedItem = [NSMutableArray array];
    
    NSPredicate *predicate;// = [NSPredicate predicateWithFormat:@"NOT (self.itemCode IN %@)",[arrItemList valueForKey:@"itemId"]];
//    NSArray * arrList = [mMDItemListVC.arrSelectedItem filteredArrayUsingPredicate:predicate];
    [arrNewAddedItem addObjectsFromArray:[self MMDItemListFromItemArray:mMDItemListVC.arrSelectedItem withItemType:@(ItemListViewTypesItem)]];
    
    predicate = [NSPredicate predicateWithFormat:@"NOT (self.itemCode IN %@)",[arrItemList valueForKey:@"itemId"]];
    NSArray * arrList = [mMDMasterDepartmentListVC.arrSelectedItem filteredArrayUsingPredicate:predicate];
    [arrNewAddedItem addObjectsFromArray:[self MMDItemListFromItemArray:arrList withItemType:@(ItemListViewTypesDepartment)]];
    
    predicate = [NSPredicate predicateWithFormat:@"NOT (self.itemCode IN %@)",[arrItemList valueForKey:@"itemId"]];
    arrList = [mMDMasterGroupListVC.arrSelectedItem filteredArrayUsingPredicate:predicate];
    [arrNewAddedItem addObjectsFromArray:[self MMDItemListFromItemArray:arrList withItemType:@(ItemListViewTypesGroup)]];
    
    predicate = [NSPredicate predicateWithFormat:@"NOT (self.itemCode IN %@)",[arrItemList valueForKey:@"itemId"]];
    arrList = [mMDMasterTagListVC.arrSelectedItem filteredArrayUsingPredicate:predicate];
    [arrNewAddedItem addObjectsFromArray:[self MMDItemListFromItemArray:arrList withItemType:@(ItemListViewTypesTag)]];
    if (arrNewAddedItem.count == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please select at least one item."];
    }
    else{
        [arrItemList addObjectsFromArray:arrNewAddedItem];
        [self.delegate didSelectItemList:arrItemList];
        
        [mMDItemListVC.arrSelectedItem removeAllObjects];
        [mMDMasterTagListVC.arrSelectedItem removeAllObjects];
        [mMDMasterGroupListVC.arrSelectedItem removeAllObjects];
        
        self.selectedView = _selectedView;
        [self didAllItemSelected:NO];

    }
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

-(void)showMessageWithTitle:(NSString *)strTitle withMessage:(NSString *) strMessage{
    if (!strTitle) {
        strTitle = @"Discount";
    }
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
    };
    [[RmsDbController sharedRmsDbController] popupAlertFromVC:self title:strTitle message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    
}

#pragma mark - Scanner Device Methods

-(void)deviceButtonPressed:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        [status setString:@""];
    }
}

-(void)deviceButtonReleased:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if(![status isEqualToString:@""])
        {
            [self searchItemInList:nil];
        }
    }
}

-(void)barcodeData:(NSString *)barcode type:(int)type
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        [status setString:@""];
        [status appendFormat:@"%@", barcode];
        _txtSearchText.text = barcode;
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Discount" message:@"Please set scanner type as scanner." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

@end
