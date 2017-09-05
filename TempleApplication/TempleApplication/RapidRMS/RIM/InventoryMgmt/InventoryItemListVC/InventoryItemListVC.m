//
//  InventoryItemListVC.m
//  RapidRMS
//
//  Created by Siya9 on 13/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "InventoryItemListVC.h"
#import "RmsDbController.h"
#import "SelectUserOptionVC.h"
#import "ItemInfoEditVC.h"
#import "MultipleBarcodePopUpVC.h"
#import "ItemDetailEditVC.h"
#import "CameraScanVC.h"
#import "RapidItemFilterVC.h"
#import "DashBoardSettingVC.h"
#import "RmsDashboardVC.h"
#import "RcrPosRestaurantVC.h"
#import "CKOCalendarViewController.h"
#import "ItemTotalAverageInfoVC.h"
#import "ItemHistoryVC.h"

#import "InventoryCell.h"

//CoreData
#import "GroupMaster.h"
#import "Mix_MatchDetail.h"
#import "BarCodeSearch+Dictionary.h"
#import "ItemBarCode_Md.h"
#import "HoldInvoice.h"
#import "RimIphonePresentMenu.h"

@interface InventoryItemListVC ()<NSFetchedResultsControllerDelegate,RapidItemFilterVCDeledate,UIGestureRecognizerDelegate,CameraScanVCDelegate,MultipleBarcodePopUpVCDelegate
#ifdef LINEAPRO_SUPPORTED
,DTDeviceDelegate
#endif
>{
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
    BarCodeSearch *barcodeSearch;
    NSPredicate * preCoustomeFilter;
    ItemInfoDataObject * barcodeDataObject;
    RapidItemFilterVC * objRapidItemFilterVC;
    IntercomHandler *intercomHandler;
    RimIphonePresentMenu * objMenubar;
    Configuration *configuration;

    NSString * strSortKey;
    BOOL isAscending;
    BOOL isSortItemDesc;
    BOOL isSortItemQTY;
    BOOL isSortItemPrice;
}
@property (nonatomic) BOOL isKeywordFilter;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *barcodeSearchObjectContext;

@property (nonatomic, strong) NSFetchedResultsController *previousItemListRC;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) UpdateManager *itemMgmtUpdateManager;

@property (nonatomic, strong) NSIndexPath *indForSwipe;
@property (nonatomic, strong) NSIndexPath *indDeleteItem;
@property (nonatomic, strong) NSIndexPath *indLastSelectedItem;

@property (nonatomic, strong) CameraScanVC *cameraScanVC;

@property (nonatomic, weak) IBOutlet UITableView *tblInventoryItemList;

@property (nonatomic, weak) IBOutlet UIButton *btnShowCalendar;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnRapidFilterView;
@property (nonatomic, weak) IBOutlet UIButton *keyBoardButton;
@property (nonatomic, weak) IBOutlet UIButton *btnSortDesc;
@property (nonatomic, weak) IBOutlet UIButton *btnSortQTH;
@property (nonatomic, weak) IBOutlet UIButton *btnSortPeice;
@property (nonatomic, weak) IBOutlet UIButton *btnSelectMode;
@property (nonatomic, weak) IBOutlet UIButton *btnLabelPrint;

@property (nonatomic, weak) IBOutlet UIView * viewFilterBG;

@property (nonatomic, weak) IBOutlet UISwipeGestureRecognizer *gestureRight;
@property (nonatomic, weak) IBOutlet UISwipeGestureRecognizer *gestureLeft;

@property (nonatomic, weak) IBOutlet UITextField *txtUniversalSearch;

@property (nonatomic, strong) RapidWebServiceConnection * mgmtItemInsertWC;
@property (nonatomic, strong) RapidWebServiceConnection * activeItemInvMgtWSC;
@property (nonatomic, strong) RapidWebServiceConnection * itemSelectedLabelWebservice;
@property (nonatomic, strong) RapidWebServiceConnection * searchedBarcode;
@property (nonatomic, strong) RapidWebServiceConnection * itemActiveInactiveWSC;
@property (nonatomic, strong) RapidWebServiceConnection * updateBarcodesToItemWSC;
@property (nonatomic, strong) RapidWebServiceConnection * itemDeletedWSC;
@end

@implementation InventoryItemListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.rimsController = [RimsController sharedrimController];
    self.itemMgmtUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.barcodeSearchObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];

    if (IsPhone()) {
        objMenubar = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimIphonePresentMenu_sid"];
        objMenubar.sideMenuVCDelegate = self.sideMenuVCDelegate;
    }
#ifdef LINEAPRO_SUPPORTED
    // Linea Barcode device connection
    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [dtdev connect];
#endif
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    if (!self.strSearchText) {
        self.strSearchText = @"";
    }
    if (self.strSearchText != nil && self.strSearchText.length > 0) {
        self.txtUniversalSearch.text=self.strSearchText;
        self.isKeywordFilter = TRUE;
    }
    strSortKey = @"item_Desc";
    isSortItemDesc = FALSE;
    isSortItemQTY = TRUE;
    isSortItemPrice = TRUE;
    isAscending = TRUE;
    self.tblInventoryItemList.tableFooterView = [[UIView alloc]init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.rimsController.scannerButtonCalled=@"InvenMgmt";
    
    [self setFilterType:self.rmsDbController.rimSelectedFilterType];
    [self checkConnectedScannerType];
    NSDate* date = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_btnShowCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
    [self enableGestureForTableView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addFilterView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction -

-(IBAction)synchronize24HoursClickedFromRim:(id)sender {
    [self.rmsDbController playButtonSound];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseCompleteSyncDataFromRim:) name:@"CompleteSyncData" object:nil];
    [self showActivityIndicator];
    [self.rmsDbController startSynchronizeUpdate:3600*24];
}
-(void)responseCompleteSyncDataFromRim:(NSNotification *)notification {
    [_activityIndicator hideActivityIndicator];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteSyncData" object:nil];
}

-(IBAction)showCalendar:(id)sender {
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}
- (IBAction)btn_itemKeyboard:(id)sender {
    _keyBoardButton.selected = !_keyBoardButton.selected;
    [self.view endEditing:YES];
    [self.txtUniversalSearch becomeFirstResponder];
}

-(IBAction)btn_UniversalItemSearch:(id)sender {
    if(self.isKeywordFilter && self.txtUniversalSearch.text.length > 0) {
        [self.rmsDbController playButtonSound];
        [self.txtUniversalSearch resignFirstResponder];
        self.strSearchText = self.txtUniversalSearch.text;
        [self reloadInventeryItemList];
    }
}

-(IBAction)btnCameraScanSearch:(id)sender {
    if (!self.cameraScanVC) {
        self.cameraScanVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
        self.cameraScanVC.delegate = self;
    }
    [self presentViewController:self.cameraScanVC animated:YES completion:nil];
}

-(IBAction)btnMenuIphone:(id)sender {
    [self.rmsDbController playButtonSound];
    self.rimsController.scannerButtonCalled=@"";
    [self presentViewController:objMenubar animated:YES completion:nil];
}
#pragma mark - Sorting Types

- (IBAction)btnSortbyItemDescription:(UIButton *)sender
{
    [Appsee addEvent:kRIMItemDescriptionSorting];
    [self.rmsDbController playButtonSound];
    strSortKey = @"item_Desc";
    isAscending = isSortItemDesc;
    [self setUpDownImageToSortingType:sender isSorting:isAscending];
    isSortItemDesc = ! isAscending;
    [self reloadInventeryItemList];
}

- (IBAction)btnSortbyItemQTY:(id)sender
{
    [Appsee addEvent:kRIMItemQtySorting];
    [self.rmsDbController playButtonSound];
    strSortKey = @"item_InStock";
    isAscending = isSortItemQTY;
    [self setUpDownImageToSortingType:sender isSorting:isAscending];
    isSortItemQTY = ! isAscending;
    [self reloadInventeryItemList];
}

- (IBAction)btnSortbyItemPrice:(id)sender
{
    [Appsee addEvent:kRIMItemSalesPriceSorting];
    [self.rmsDbController playButtonSound];
    strSortKey = @"salesPrice";
    isAscending = isSortItemPrice;
    [self setUpDownImageToSortingType:sender isSorting:isAscending];
    isSortItemPrice = ! isAscending;
    [self reloadInventeryItemList];
}

-(void)setUpDownImageToSortingType:(UIButton *)sortingButton isSorting:(BOOL)isSorting
{
    isSortItemDesc = FALSE;
    isSortItemQTY = FALSE;
    isSortItemPrice = FALSE;
    
    UIImage * imgDefault = [UIImage imageNamed:@"RIM_List_Order_None"];
    [self.btnSortDesc setImage:imgDefault forState:UIControlStateNormal];
    [self.btnSortQTH setImage:imgDefault forState:UIControlStateNormal];
    [self.btnSortPeice setImage:imgDefault forState:UIControlStateNormal];
    
    NSString * strSortImage = @"RIM_List_Order_Descending";
    if(isSorting)
    {
        strSortImage = @"RIM_List_Order_Ascending";
    }
    
    [sortingButton setImage:[UIImage imageNamed:strSortImage] forState:UIControlStateNormal];
}
-(void)barcodeScanned:(NSString *)strBarcode {
    [self.txtUniversalSearch resignFirstResponder];
    self.strSearchText = strBarcode;
    self.txtUniversalSearch.text = strBarcode;
    [self reloadInventeryItemList];
}

-(IBAction)btn_ItemInfoClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    ItemTotalAverageInfoVC * objItemTotalAverageInfoVC =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemTotalAverageInfoVC_sid"];
    if (IsPhone()) {
        [self.navigationController pushViewController:objItemTotalAverageInfoVC animated:YES];
    }
    else {
        [self.sideMenuVCDelegate willPushViewController:objItemTotalAverageInfoVC animated:YES];
    }
}

-(IBAction)selectModeOnoff:(UIButton *)sender {
    self.indLastSelectedItem = nil;
    self.indForSwipe = nil;
    self.isItemInSelectMode = !self.isItemInSelectMode;
    self.previousItemListRC = nil;
    [self enableGestureForTableView];
    sender.selected = self.isItemInSelectMode;
    [self.arrItemSelected removeAllObjects];
    self.btnLabelPrint.enabled=NO;
    self.itemListRC = nil;
    [self.tblInventoryItemList reloadData];
}
-(void)enableGestureForTableView {
    if(self.isItemInSelectMode) {
        self.gestureRight.enabled = FALSE;
        self.gestureLeft.enabled = FALSE;
    }
    else {
        self.gestureRight.enabled = TRUE;
        self.gestureLeft.enabled = TRUE;
    }
}
-(IBAction)lablePrintForSelectedItemsTapped:(UIButton *)sender {
    [Appsee addEvent:kRIMFooterLablePrint];
    NSString *itemIdes = [[self.arrItemSelected valueForKey:@"itemCode"] componentsJoinedByString:@","];
    [self showActivityIndicator];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    param[@"ItemCodes"] = itemIdes;
    param[@"BranchId"] = self.rmsDbController.globalDict[@"BranchID"];
    param[@"RegisterId"] = self.rmsDbController.globalDict[@"RegisterId"];
    param[@"ProcessType"] = @"LabelPrint";
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    param[@"SelectedDate"] = strDateTime;
    param[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseLabelPrintItemsResponse:response error:error];
        });
    };
    self.itemSelectedLabelWebservice = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_INSERT_IOS_ITEMS params:param completionHandler:completionHandler];
}

- (void)responseLabelPrintItemsResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self.arrItemSelected removeAllObjects];
                
                self.btnLabelPrint.enabled=NO;
                [self reloadItemRowsAtIndexPaths:[self.tblInventoryItemList indexPathsForVisibleRows]];
                [self showMessage:@"Print Successfull."];
            }
        }
    }
}
-(void)showActivityIndicator{
    if (!_activityIndicator) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].delegate.window];
    }
}
#pragma mark - logout and upload barcode list -
-(IBAction)logoutClicked:(id)sender {
    [self uploadMissingBarcodeSearch];
    NSArray *viewControllerArray = self.sideMenuVCDelegate.currentNavigationController.viewControllers;
    for (UIViewController *vc in viewControllerArray) {
        if ([vc isKindOfClass:[RcrPosRestaurantVC class]] || [vc isKindOfClass:[RcrPosVC class]]) {
            [self.sideMenuVCDelegate.currentNavigationController popToViewController:vc animated:TRUE];
            return;
        }
    }
    for (UIViewController *vc in viewControllerArray) {
        if ([vc isKindOfClass:[DashBoardSettingVC class]] || [vc isKindOfClass:[RmsDashboardVC class]]) {
            [self.sideMenuVCDelegate.currentNavigationController popToViewController:vc animated:TRUE];
            break;
        }
    }
}
-(void)uploadMissingBarcodeSearch {
    NSArray *arrBarcode = [self fetchAllBarcodeDetails:self.barcodeSearchObjectContext];
    if (arrBarcode.count > 0) {
        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
        param[@"BranchId"] = self.rmsDbController.globalDict[@"BranchID"];
        param[@"RegisterId"] = self.rmsDbController.globalDict[@"RegisterId"];
        param[@"UserId"] = [self.rmsDbController.globalDict[@"UserInfo"] valueForKey:@"UserId"];
        
        NSDate *currentDate = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *currentDateValue = [formatter stringFromDate:currentDate];
        param[@"LocalDate"] = currentDateValue;
        param[@"ModuleName"] = @"RIM";
        param[@"Client"] = @"iOS";
        
        NSMutableArray *arrBarcodeDetail = [[NSMutableArray alloc]init];

        for (BarCodeSearch *barcodesearch in arrBarcode)
        {
            NSMutableDictionary *dictBarcode = barcodesearch.barcodeSearchDictionary;
            [dictBarcode removeObjectForKey:@"moduleName"];
            [arrBarcodeDetail addObject:dictBarcode];
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrBarcodeDetail options:NSJSONWritingPrettyPrinted error:nil];
        NSString *strSearchtext = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        param[@"SearchText"] = strSearchtext;
        
        AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
            [self missingBarcodeManualEntryResponse:response error:error];
        };
        
        self.searchedBarcode = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_BARCODE_SEARCH_LOG params:param asyncCompletionHandler:asyncCompletionHandler];
    }
}

- (void)missingBarcodeManualEntryResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSArray *barcodeSearchList=[self fetchAllBarcodeDetails:self.barcodeSearchObjectContext];
                for (NSManagedObject *barcodeContext in barcodeSearchList)
                {
                    [UpdateManager deleteFromContext:self.barcodeSearchObjectContext object:barcodeContext];
                }
                [UpdateManager saveContext:self.barcodeSearchObjectContext];
                NSLog(@"UploadMissingBarcodeResult Success ");
            }
            else {
                NSLog(@"UploadMissingBarcodeResult failed");
            }
        }
    }
}
- (NSArray*)fetchAllBarcodeDetails:(NsmoContext *)moc {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BarCodeSearch" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSPredicate *predict = [NSPredicate predicateWithFormat:@"barcode!=nil"];
    fetchRequest.predicate = predict;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

-(IBAction)btnAddNewItem:(id)sender {
    [self itemDetailViewShow:nil isItemCopy:FALSE];
}
- (void)launchItemDetailViewForIndexPath:(Item *)anItem isItemCopy:(BOOL)isItemCopy {
    
    [self.rmsDbController playButtonSound];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    if(anItem.itemSubDepartment.subDeptName) {
        dictItemClicked[@"SubDepartmentName"] = anItem.itemSubDepartment.subDeptName;
    }
    else {
        dictItemClicked[@"SubDepartmentName"] = @"";
    }
    //GET DEPARTMENT NAME
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",[dictItemClicked[@"DepartId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *departmentList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (departmentList.count>0) {
        Department *department=departmentList.firstObject;
        dictItemClicked[@"DepartmentName"] = department.deptName;
    }
    else {
        dictItemClicked[@"DepartmentName"] = @"";
    }
    // GET GROUPNAME
    if([dictItemClicked[@"CateId"] integerValue] != 0)
    {
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription entityForName:@"GroupMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        predicate = [NSPredicate predicateWithFormat:@"groupId==%d",[dictItemClicked[@"CateId"] integerValue]];
        fetchRequest.predicate = predicate;
        NSArray *groupList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (groupList.count > 0) {
            GroupMaster *groupMst=groupList.firstObject;
            dictItemClicked[@"GroupName"] = groupMst.groupName;
        }
        else {
            dictItemClicked[@"GroupName"] = @"";
        }
    }
    else {
        dictItemClicked[@"GroupName"] = @"";
    }
    // GET MixMatchName From ID
    if([dictItemClicked[@"mixMatchId"] integerValue] != 0)
    {
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription entityForName:@"Mix_MatchDetail" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        predicate = [NSPredicate predicateWithFormat:@"mixMatchId==%d",[dictItemClicked[@"mixMatchId"] integerValue]];
        fetchRequest.predicate = predicate;
        NSArray *groupList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (groupList.count > 0) {
            Mix_MatchDetail *groupMst = groupList.firstObject;
            dictItemClicked[@"mixMatchDiscription"] = groupMst.item_Description;
        }
        else {
            dictItemClicked[@"mixMatchDiscription"] = @"";
        }
    }
    else {
        dictItemClicked[@"mixMatchDiscription"] = @"";
    }
    // GET MixMatchName From GroupID
    if([dictItemClicked[@"cate_MixMatchId"] integerValue] != 0) {
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription entityForName:@"Mix_MatchDetail" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        predicate = [NSPredicate predicateWithFormat:@"mixMatchId==%d",[dictItemClicked[@"cate_MixMatchId"] integerValue]];
        fetchRequest.predicate = predicate;
        NSArray *groupList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (groupList.count > 0) {
            Mix_MatchDetail *groupMst = groupList.firstObject;
            dictItemClicked[@"cate_MixMatchDiscription"] = groupMst.item_Description;
        }
        else {
            dictItemClicked[@"cate_MixMatchDiscription"] = @"";
        }
    }
    else
    {
        dictItemClicked[@"cate_MixMatchDiscription"] = @"";
    }
    [self itemDetailViewShow:dictItemClicked isItemCopy:isItemCopy];
}
-(void)itemDetailViewShow:(NSMutableDictionary *)ItemInfo isItemCopy:(BOOL)isItemCopy {
    if (isItemCopy) {
        if (![[ItemInfo valueForKey:@"ITM_Type"] isEqualToString:@"0"]) {
            [self showMessage:@"You can't copy this item."];
            return;
        }
        ItemInfo[@"Barcode"] = @"";
        ItemInfo[@"avaibleQty"] = @"";
        ItemInfo[@"ItemNo"] = @"";
    }
    if (IsPhone()) {
        ItemInfoEditVC * itemInfoEditVC = (ItemInfoEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];

        if (itemInfoEditVC.itemInfoDataObject==nil) {
            itemInfoEditVC.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
        }
        [itemInfoEditVC.itemInfoDataObject setItemMainDataFrom:[ItemInfo mutableCopy]];
        itemInfoEditVC.isCopy = isItemCopy;
        [self.navigationController pushViewController:itemInfoEditVC animated:YES];
        [_activityIndicator hideActivityIndicator];
    }
    else {
        ItemDetailEditVC * itemDetailEditVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
        itemDetailEditVC.selectedItemInfoDict = ItemInfo;
        itemDetailEditVC.isItemCopy = isItemCopy;
        itemDetailEditVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:itemDetailEditVC animated:YES completion:^{
            [_activityIndicator hideActivityIndicator];
        }];
    }
}
#pragma mark - RapidFilters and Filter -

-(IBAction)filterButtonClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    [self.txtUniversalSearch resignFirstResponder];
    
    SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:@[@"ABC Shorting",@"Keyword"] SelectedObject:self.rmsDbController.rimSelectedFilterType SelectionComplete:^(NSArray *arrSelection) {
        [self setFilterType:arrSelection[0]];
        self.txtUniversalSearch.text = @"";
        self.strSearchText = @"";
        [self reloadInventeryItemList];
    } SelectionColse:^(UIViewController *popUpVC) {
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}
-(void)setFilterType:(NSString *)selectedoption {
    [self.rmsDbController playButtonSound];
    if ([selectedoption isEqualToString:@"ABC Shorting"]) {
        self.rmsDbController.rimSelectedFilterType = @"ABC Shorting";
        self.isKeywordFilter = FALSE;
        self.txtUniversalSearch.placeholder = @"ABC Shorting".uppercaseString;
    }
    else {
        self.rmsDbController.rimSelectedFilterType = @"Keyword";
        self.isKeywordFilter = TRUE;
        self.txtUniversalSearch.placeholder = @"UPC, Item Number, Description, Department, etc..".uppercaseString;
    }
}

-(void)addFilterView {
    if (!objRapidItemFilterVC) {
        objRapidItemFilterVC = [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"RapidItemFilterVC_sid"];
        objRapidItemFilterVC.view.frame = CGRectMake(self.viewFilterBG.bounds.size.width, 0, self.viewFilterBG.bounds.size.width, self.viewFilterBG.bounds.size.height);
        [self addChildViewController:objRapidItemFilterVC];
        [self.viewFilterBG addSubview:objRapidItemFilterVC.view];
        [objRapidItemFilterVC didMoveToParentViewController:self];
        objRapidItemFilterVC.deledate = self;
    }
}
- (void)highlightLetter:(UITapGestureRecognizer*)sender {
    [objRapidItemFilterVC filterViewSlideIn:FALSE];
    self.btnRapidFilterView.selected = FALSE;
    [self.view removeGestureRecognizer:sender];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:objRapidItemFilterVC.view]){
        return NO;
    }
    return YES;
}

-(IBAction)rapidFilterViewSlideInOutButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.view bringSubviewToFront:self.viewFilterBG];
    [objRapidItemFilterVC filterViewSlideIn:sender.selected];
    [self.view endEditing:YES];
    if (sender.selected) {
        UITapGestureRecognizer *letterTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(highlightLetter:)];
        letterTapRecognizer.numberOfTapsRequired = 1;
        letterTapRecognizer.delegate = self;
        [self.view addGestureRecognizer:letterTapRecognizer];
    }
}

-(void)willSetRapidItemFilterPredicate:(NSPredicate *) predicate withFilterDictionary:(NSDictionary *)dictFilterInfo {
#ifndef IS_CLICK_TO_SEARCH
    [objRapidItemFilterVC filterViewSlideIn:FALSE];
    self.btnRapidFilterView.selected = FALSE;
#endif
    preCoustomeFilter = predicate;
    [self reloadInventeryItemList];
}
-(void)willChangeRapidFilterIsSlidein:(BOOL)isSlidein {
#ifdef IS_CLICK_TO_SEARCH
    self.btnRapidFilterView.selected = isSlidein;
    [objRapidItemFilterVC filterViewSlideIn:isSlidein];
#endif
}

#pragma mark - UITextFieldDelegate -
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (IsPad()) {
        if (textField == self.txtUniversalSearch && _keyBoardButton.selected) {
            self.txtUniversalSearch.inputView = nil;
            [self.txtUniversalSearch becomeFirstResponder];
            
        }
        else {
            self.txtUniversalSearch.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [textField becomeFirstResponder];
        }
    }
    [objRapidItemFilterVC filterViewSlideIn:FALSE];
    self.btnRapidFilterView.selected = FALSE;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {   // return NO to not change text
    if (self.itemListRC.fetchedObjects.count > 0) {
        NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tblInventoryItemList scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
    self.strSearchText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (!self.isKeywordFilter) {
        [self reloadInventeryItemList];
    }
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.strSearchText = @"";
    [self reloadInventeryItemList];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (self.isKeywordFilter) {
        barcodeSearch = [self.itemMgmtUpdateManager updateBarcodeSearchInfo:self.barcodeSearchObjectContext];
        [self reloadInventeryItemList];
    }
    return YES;
}

#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSArray *sections = self.itemListRC.sections;
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *sections = self.itemListRC.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *sections = self.itemListRC.sectionIndexTitles;
    NSString *tempStr = @"";
    if (sections.count>0) {
        tempStr = sections[0];
    }
    return tempStr;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.itemListRC sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.itemListRC.sectionIndexTitles;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(IsPhone()) {
        return 100;
    }
    else {
        return 76;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self configureItemCell:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isItemInSelectMode) {
        self.indLastSelectedItem = nil;
        [self selectItemData:indexPath];
    }
    else {
        InventoryCell *cell = (InventoryCell *)[tableView cellForRowAtIndexPath:indexPath];
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        cell.imgBackGround.image = [UIImage imageNamed:@"ListHoverAndActive_ipad.png"];
        [self showActivityIndicator];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableArray<NSIndexPath *> * arrReloadIndexPath = [NSMutableArray array];
            
            NSIndexPath *previousIndexPath = [self.indLastSelectedItem copy];
            self.indLastSelectedItem = [indexPath copy];
            
            if (self.indForSwipe) {
                [arrReloadIndexPath addObject:[self.indForSwipe copy]];
            }
            self.indForSwipe = nil;
            if (previousIndexPath) {
                [arrReloadIndexPath addObject:previousIndexPath];
            }
            Item *anItem = [self.itemListRC objectAtIndexPath:indexPath];
            [self launchItemDetailViewForIndexPath:anItem isItemCopy:FALSE];
            [self reloadItemRowsAtIndexPaths:arrReloadIndexPath];
        });
    }
}

- (UITableViewCell *)configureItemCell:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InventoryItemCustomCell";
    InventoryCell *itemCell = [self.tblInventoryItemList dequeueReusableCellWithIdentifier:CellIdentifier];
    Item *anItem = [self.itemListRC objectAtIndexPath:indexPath];
    
//   withIsBarcodeExist:[self.itemMgmtUpdateManager doesBarcodeExist:itemBarCode forItemCode:itemCode]
    [itemCell configureCellWithItem:anItem withBarCode:@"" withCurrentIndexPath:indexPath withIsBarcodeExist:FALSE isLablePrintSelectOr:self.isItemInSelectMode isSelectedIndex:[indexPath isEqual:self.indLastSelectedItem]];
    
    itemCell.imgSelected.image = [UIImage imageNamed:@"RIM_Com_Arrow_Detail"];
    itemCell.imgSelected.highlightedImage = [UIImage imageNamed:@"rim_inventory_arrow_selected"];
    if (self.isItemInSelectMode) {
        itemCell.imgSelected.image = [UIImage imageNamed:@"radiobtn.png"];
        itemCell.imgSelected.highlightedImage = nil;
        if( [self.arrItemSelected containsObject:anItem]) {
            itemCell.imgSelected.image = [UIImage imageNamed:@"radioMulti_selected.png"];
        }
    }
    UIView * viewItemOpretions;
    if (self.isItemActive) {
        viewItemOpretions = itemCell.viewOperation;
    }
    else {
        viewItemOpretions = itemCell.viewOperationInactive;
    }
    if(self.indForSwipe != nil && [indexPath isEqual:self.indForSwipe]) {
        viewItemOpretions.hidden = NO;
    }
    else {
        viewItemOpretions.hidden = YES;
    }
    return itemCell;
}

- (void)selectItemData:(NSIndexPath *)indexPath {
    Item *anItem = [self.itemListRC objectAtIndexPath:indexPath];
    if (!self.arrItemSelected) {
        self.arrItemSelected = [NSMutableArray array];
    }
    if([self.arrItemSelected containsObject:anItem]) {
        [self.arrItemSelected removeObject:anItem];
        if(self.arrItemSelected.count > 0) {
            self.btnLabelPrint.enabled=YES;
        }
        else {
            self.btnLabelPrint.enabled=NO;
        }
    }
    else {
        [self.arrItemSelected addObject:anItem];
        self.btnLabelPrint.enabled=YES;
    }
    [self reloadItemRowsAtIndexPaths:@[indexPath]];
}
#pragma mark - Swipe -

-(IBAction)didSwipeGestureRecognizerRim:(UISwipeGestureRecognizer *)gesture {
    NSIndexPath *previousSelection = [self.indForSwipe copy];
    CGPoint location = [gesture locationInView:self.tblInventoryItemList];
    NSIndexPath *swipedIndexPath = [self.tblInventoryItemList indexPathForRowAtPoint:location];
    NSMutableArray *indexPaths = [NSMutableArray array];
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        
        Item * anItem = [self.itemListRC objectAtIndexPath:swipedIndexPath];
        if (anItem.itm_Type.intValue == 0) {
            self.indForSwipe = swipedIndexPath;
            if (swipedIndexPath) {
                [indexPaths addObject:swipedIndexPath];
            }
            if (previousSelection) {
                [indexPaths addObject:previousSelection];
            }
        }
    }
    else {
        if(self.indForSwipe.row == swipedIndexPath.row) {
            self.indForSwipe = nil;
            if (previousSelection) {
                [indexPaths addObject:previousSelection];
            }
        }
    }
    [self reloadItemRowsAtIndexPaths:indexPaths];
}
-(NSIndexPath *)getIndexPathFromInventoryTable:(UIView *)view {
    CGPoint center= view.center;
    CGPoint rootViewPoint = [view.superview convertPoint:center toView:self.tblInventoryItemList];
    return [self.tblInventoryItemList indexPathForRowAtPoint:rootViewPoint];
}
#pragma mark - Item Active & Inactive
-(IBAction)ActiveInactiveItemAtSender:(UIButton *)sender {
    
    [self showActivityIndicator];
    NSIndexPath *indexPath = [self getIndexPathFromInventoryTable:sender];
    Item *anItem = [self.itemListRC objectAtIndexPath:indexPath];
    NSMutableDictionary * dictItemInfo;
    if (self.isItemActive) {
        dictItemInfo = [self changeItemActiveToInactive:anItem isItemActive:@"0"];
    }
    else {
        dictItemInfo = [self changeItemActiveToInactive:anItem isItemActive:@"1"];
    }
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responceOfItemInactiveResponse:response error:error];
        });
    };
    self.itemActiveInactiveWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:dictItemInfo completionHandler:completionHandler];
}

-(void)responceOfItemInactiveResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                NSString * strItemId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
                Item *currentItem = [self.itemMgmtUpdateManager fetchAllEntityWithName:@"Item" key:@"itemCode" value:@[strItemId] moc:self.managedObjectContext].firstObject;
                currentItem.active = [NSNumber numberWithBool:!self.isItemActive];
                [self addLiveUpdateForDataBase];
                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                }
            }
            else {
                [self showMessage:@"Item not updated, try again."];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
}
-(void)addLiveUpdateForDataBase {
    
    NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
    itemLiveUpdate[@"Action"] = @"Update";
    itemLiveUpdate[@"EntityId"] = self.rmsDbController.globalDict[@"BranchID"];
    itemLiveUpdate[@"Type"] = @"Item";
    [self.rmsDbController addItemListToLiveUpdateQueue:itemLiveUpdate];
    
}
-(IBAction)historyItemAtSender:(UIButton *)sender {

    NSIndexPath *indexPath = [self getIndexPathFromInventoryTable:sender];
    Item *anItem = [self.itemListRC objectAtIndexPath:indexPath];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
    ItemHistoryVC * itemHistoryVC  = [storyboard instantiateViewControllerWithIdentifier:@"ItemHistoryVC"];
    ItemInfoDataObject * itemInfoDataObject = [[ItemInfoDataObject alloc]init];
    [itemInfoDataObject setItemMainDataFrom:dictItemClicked];
    itemHistoryVC.itemInfoDataObject = itemInfoDataObject;
    itemHistoryVC.managedObjectContext = self.managedObjectContext;
    if (IsPhone()) {
        CGRect frame = CGRectMake(0, 68, itemHistoryVC.view.frame.size.width, itemHistoryVC.view.frame.size.height-127);
        itemHistoryVC.view.frame = frame;
    }
    itemHistoryVC.view.backgroundColor = [UIColor colorWithRed:0.894 green:0.898 blue:0.918 alpha:1.000];
    itemHistoryVC.view.clipsToBounds = TRUE;
    
    [itemHistoryVC presentViewControllerForviewConteroller:self sourceView:nil ArrowDirection:(UIPopoverArrowDirection)nil];
    
    NSIndexPath * indSwiped = [self.indForSwipe copy];
    self.indForSwipe = nil;
    [self reloadItemRowsAtIndexPaths:@[indSwiped]];
}
#pragma mark - Update Item Barcode

-(IBAction)updateItemBarcodeAtSender:(UIButton *)sender {
    
    NSIndexPath *indexPath = [self getIndexPathFromInventoryTable:sender];
    Item *anItem = [self.itemListRC objectAtIndexPath:indexPath];
    
    barcodeDataObject = [[ItemInfoDataObject alloc]init];
    barcodeDataObject.arrItemAllBarcode = [NSMutableArray array];
    [barcodeDataObject setItemMainDataFrom:anItem.itemRMSDictionary];
    
    for (ItemBarCode_Md *barcode in anItem.itemBarcodes) {
        if([barcode.isBarcodeDeleted  isEqual: @(0)]) {
            NSMutableDictionary *barcodeDict = [[NSMutableDictionary alloc]init];
            barcodeDict[@"Barcode"] = barcode.barCode;
            barcodeDict[@"PackageType"] = barcode.packageType;
            barcodeDict[@"IsDefault"] = barcode.isDefault.stringValue;
            barcodeDict[@"isExist"] = @"";
            barcodeDict[@"notAllowItemCode"] = @"";
            if([barcode.isDefault  isEqual: @(1)]) {
                barcodeDataObject.Barcode = barcode.barCode;
            }
            [barcodeDataObject.arrItemAllBarcode addObject:barcodeDict];
        }
    }
    [barcodeDataObject createDuplicateItemBarcodeArray];
    if (IsPad()) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
        MultipleBarcodePopUpVC *barcodePopUpVC = [storyBoard instantiateViewControllerWithIdentifier:@"MultipleBarcodePopUpVC_sid"];
        barcodePopUpVC.editingPackageType = (ItemBarcodeType)sender.tag;
        barcodePopUpVC.multipleBarcodePopUpVCDelegate = self;
        barcodePopUpVC.arrItemBarcodeList = [barcodeDataObject.arrItemAllBarcode mutableCopy];
        
        barcodePopUpVC.itemCode = anItem.itemCode.stringValue;
        barcodePopUpVC.isDuplicateBarcodeAllowed = TRUE;
        [barcodePopUpVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionRight];
    }
    else {
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//        MultipleBarcodePopUpVCViewController *barcodePopUpVC = [storyBoard instantiateViewControllerWithIdentifier:@"MultipleBarcodePopUp"];
//        barcodePopUpVC.editingPackageType = packageNumber;
//        barcodePopUpVC.barcodeDisplayListArray = itemBarcodesList;
//        barcodePopUpVC.multipleBarcodePopUpVCDelegate = self;
//        barcodePopUpVC.barcodeDisplayListArray = itemBarcodesList;
//        NSString *item_Code = [NSString stringWithFormat:@"%ld",(long)updateBarcodeItemCode];
//        barcodePopUpVC.itemCode = item_Code;
//        if (anItem.isDuplicateBarcodeAllowed == FALSE)
//        {
//            barcodePopUpVC.isDuplicateBarcodeAllowed = NO;
//        }
//        else
//        {
//            barcodePopUpVC.isDuplicateBarcodeAllowed = YES;
//        }
//        [self.navigationController pushViewController:barcodePopUpVC animated:YES];
    }
}
- (void)didUpdateMultipleBarcode:(NSMutableArray *)itemBarcodes allowToItems:(NSString *)allowToItems {
    [self showActivityIndicator];
    NSIndexPath * indexPath = [self.indForSwipe copy];
    self.indForSwipe = nil;
    [self reloadItemRowsAtIndexPaths:@[indexPath]];
    barcodeDataObject.arrItemAllBarcode = [itemBarcodes copy];
    NSPredicate *duplicateBarcodePredicate = [NSPredicate predicateWithFormat:@"isExist == %@",@"YES"];
    NSArray *alreadyExistBarcodes = [itemBarcodes filteredArrayUsingPredicate:duplicateBarcodePredicate];
    BOOL isDuplicateUPC = FALSE;
    if (alreadyExistBarcodes != nil && alreadyExistBarcodes.count > 0) {
        isDuplicateUPC = TRUE;
    }
    else {
        isDuplicateUPC = barcodeDataObject.IsduplicateUPC;
    }
    NSMutableDictionary *updateBarcodeParam = [[NSMutableDictionary alloc]init];
    // New Added Barcode Array  Delete isExist, notAllowItemCode
    updateBarcodeParam[@"AddedBarcodes"] = barcodeDataObject.arrAddedBarcodeList;
    updateBarcodeParam[@"DeletedBarcodes"] = barcodeDataObject.arrDeletedBarcodeList;
    updateBarcodeParam[@"ItemCode"] = barcodeDataObject.ItemId.stringValue;
    updateBarcodeParam[@"DefaultBarcode"] = @"";
    NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"IsDefault == %@", @"1"];
    NSArray *isDefault = [barcodeDataObject.arrItemAllBarcode filteredArrayUsingPredicate:barcodePredicate];
    if(isDefault.count > 0) {
        NSDictionary *tempDict = isDefault.firstObject;
        updateBarcodeParam[@"DefaultBarcode"] = [tempDict valueForKey:@"Barcode"];
    }
    // pass system date and time while deleting record.
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString* currentDateTime = [formatter stringFromDate:date];
    updateBarcodeParam[@"UpdatedDate"] = currentDateTime;
    
    updateBarcodeParam[@"RegisterId"] = self.rmsDbController.globalDict[@"RegisterId"];
    updateBarcodeParam[@"BranchId"] = self.rmsDbController.globalDict[@"BranchID"];
    NSString *userID = self.rmsDbController.globalDict[@"UserInfo"][@"UserId"];
    updateBarcodeParam[@"UserId"] = userID;
    updateBarcodeParam[@"IsduplicateUPC"] = @(isDuplicateUPC);
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateBarcodeToSwipedItemResponse:response error:error];
        });
    };
    self.updateBarcodesToItemWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_INSERT_BARCODE_TO_ITEM_CODES params:updateBarcodeParam completionHandler:completionHandler];
}
- (void)updateBarcodeToSwipedItemResponse:(id)response error:(NSError *)error {
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {

                NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
                itemparam[@"BranchId"] = self.rmsDbController.globalDict[@"BranchID"];
                itemparam[@"Code"] = barcodeDataObject.ItemId.stringValue;
                itemparam[@"Type"] = @"";
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self responseUpdateBarcodeItemRimResponse:response error:error];
                    });
                };
                self.updateBarcodesToItemWSC = [self.updateBarcodesToItemWSC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
                return;
            }
            else {
                [self showMessage:@"Item barcode(s) has not been updated."];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
}

-(void)responseUpdateBarcodeItemRimResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            NSMutableArray *itemResponseArray = [responseDictionary valueForKey:@"ItemArray"];
            if(itemResponseArray.count > 0){
                NSDictionary *itemDict = itemResponseArray.firstObject;
                if (![[[itemDict valueForKey:@"isDeleted"] stringValue] isEqualToString:@"1"]) // if deleted
                {
                    [self.itemMgmtUpdateManager updateObjectsFromResponseDictionary:responseDictionary];
                    [self.itemMgmtUpdateManager linkItemToDepartmentFromResponseDictionary:responseDictionary];
                    [self showMessage:@"Item barcode(s) been updated successfully."];
                }
            }
            else
            {
                [self showMessage:@"Error Occurs while updating barcode in item list."];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
}

-(IBAction)copyItemAtSender:(UIButton *)sender {
    NSIndexPath *indexPath = [self getIndexPathFromInventoryTable:sender];
    Item *anItem = [self.itemListRC objectAtIndexPath:indexPath];
    [self showActivityIndicator];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self launchItemDetailViewForIndexPath:anItem isItemCopy:TRUE];
        self.indForSwipe = nil;
        self.indLastSelectedItem = nil;
        [self reloadItemRowsAtIndexPaths:@[indexPath]];
    });
}
#pragma mark - Delete Item
-(IBAction)deleteItemAtSender:(UIButton *)sender {
    [self.rmsDbController playButtonSound];
    NSIndexPath *indexPath = [self getIndexPathFromInventoryTable:sender];
    self.indDeleteItem = [indexPath copy ];
    Item *anItem = [self.itemListRC objectAtIndexPath:indexPath];
    
    if([self isAvailableInOffLineHolds:anItem.itemCode.integerValue]) {
        [self showMessage:@"You can not delete this item,It is in offline Hold Invoice."];
    }
    else {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
            self.indLastSelectedItem = nil;
            self.indForSwipe = nil;
            if (self.indDeleteItem) {
                [self reloadItemRowsAtIndexPaths:@[self.indDeleteItem]];
            }
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
            [self deleteRecord:anItem.itemCode.stringValue];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:[NSString stringWithFormat:@"Are you sure you want to delete %@ ?",anItem.item_Desc] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}
-(BOOL)isAvailableInOffLineHolds:(NSInteger) itemCode {
    BOOL isInHold = FALSE;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext * privateMOC = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSString * strItemId = [NSString stringWithFormat:@"%ld",(long)itemCode];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"HoldInvoice" inManagedObjectContext:privateMOC];
    fetchRequest.entity = entity;
    
    NSArray *resultSet = [UpdateManager executeForContext:privateMOC FetchRequest:fetchRequest];
    
    for (HoldInvoice * objHoldInvoice in resultSet) {
        isInHold = [self checkitemInOfflineData:objHoldInvoice.holdData withItemID:strItemId];
        if (isInHold) {
            return isInHold;
        }
    }
    return isInHold;
}
-(BOOL)checkitemInOfflineData:(NSData *)recallOfflineData withItemID:(NSString *)strItemID {
    NSDictionary * dictrecallData = [NSKeyedUnarchiver unarchiveObjectWithData:recallOfflineData];
    NSArray * arrInvoiceDetail = dictrecallData[@"InvoiceDetail"];
    NSDictionary * dictItemInfo = arrInvoiceDetail.firstObject;
    NSArray * arrItems = dictItemInfo[@"InvoiceItemDetail"];
    NSArray * arrItemsId = [arrItems valueForKey:@"ItemCode"];
    if ([arrItemsId containsObject:strItemID]) {
        return YES;
    }
    else {
        return FALSE;
    }
}

-(void) deleteRecord:(NSString *)deleteID {
    [self showActivityIndicator];
    NSMutableDictionary *deleteparam=[[NSMutableDictionary alloc]init];
    deleteparam[@"BranchId"] = self.rmsDbController.globalDict[@"BranchID"];
    deleteparam[@"ItemCode"] = deleteID;
    // pass system date and time while deleting record.
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString* currentDateTime = [formatter stringFromDate:date];
    deleteparam[@"Updatedate"] = currentDateTime;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deleteItemData:deleteID Response:response error:error];
        });
    };
    self.itemDeletedWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_ITEM_DELETED params:deleteparam completionHandler:completionHandler];
}

- (void)deleteItemData:(NSString *)deleteID Response:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                if (self.isItemActive) {
                    Item *currentItem = [self.itemMgmtUpdateManager fetchAllEntityWithName:@"Item" key:@"itemCode" value:@[deleteID] moc:self.managedObjectContext].firstObject;
                    currentItem.active = @(0);
                    NSError *error = nil;
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                    }
                }
                else {
                    [self.itemMgmtUpdateManager deleteItemWithItemCode:@(deleteID.intValue)];
                }
                self.strSearchText = self.txtUniversalSearch.text;
                self.indForSwipe=nil;
                self.indLastSelectedItem = nil;
                [self showMessage:@"Item has been deleted successfully."];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -2) {
                [self showMessage:[response valueForKey:@"Data"]];
            }
            else {
                [self showMessage:@"Item not deleted."];
            }
        }
    }
}

- (void)reloadItemRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSMutableArray * arrListIndexPath = [NSMutableArray array];
    NSArray * arrIndexPaths = [self.tblInventoryItemList indexPathsForVisibleRows];
    for (NSIndexPath * indexPath in indexPaths) {
        if ([arrIndexPaths containsObject:indexPath] && ![arrListIndexPath containsObject:indexPath]) {
            [arrListIndexPath addObject:indexPath];
        }
    }
    if (arrListIndexPath.count > 0) {
        [self.tblInventoryItemList reloadRowsAtIndexPaths:arrListIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)showMessage:(NSString *)strMessage {
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {};
    [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}
#pragma mark - Missing Item -
- (void)callWSForMissingItem {
    [self showActivityIndicator];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        itemparam[@"BranchId"] = self.rmsDbController.globalDict[@"BranchID"];
        itemparam[@"Code"] = [self.rmsDbController trimmedBarcode:self.txtUniversalSearch.text];
        itemparam[@"Type"] = @"Barcode";

        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self responseInvnetoryMgmtDataRimResponse:response error:error];
            });
        };
        self.mgmtItemInsertWC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];

    });
}

-(void)responseInvnetoryMgmtDataRimResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            NSMutableArray *itemResponseArray = [responseDictionary valueForKey:@"ItemArray"];
            if(itemResponseArray.count > 0)
            {
                NSDictionary *itemDict = itemResponseArray.firstObject;
                if ([[[itemDict valueForKey:@"isDeleted"] stringValue] isEqualToString:@"1"]) // if deleted
                {
                    [self getUserConformationToAddItem];
                    barcodeSearch.searchResult = @"";
                    barcodeSearch.foundOnServer =@(FALSE);
                    [UpdateManager saveContext:self.barcodeSearchObjectContext];
                    barcodeSearch = nil;
                }
                else if ([[[itemDict valueForKey:@"Active"] stringValue] isEqualToString:@"0"] && self.isItemActive) // if not active item
                {
                    InventoryItemListVC * __weak myWeakReference = self;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        self.txtUniversalSearch.text = @"";
                        self.strSearchText = self.txtUniversalSearch.text;
                        [self reloadInventeryItemList];
                    };
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        NSString *strItemId = [NSString stringWithFormat:@"%@",[itemDict valueForKey:@"ITEMCode"]];
                        Item *currentItem = [self.itemMgmtUpdateManager fetchAllEntityWithName:@"Item" key:@"itemCode" value:@[strItemId] moc:self.managedObjectContext].firstObject;
                        if (currentItem) {
                            [myWeakReference moveInvMgtInActiveItemToActiveItemList:currentItem];
                        }
                    };
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:@"This item is inactive would you like to activate it?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                }
                else if ([[[itemDict valueForKey:@"Active"] stringValue] isEqualToString:@"1"] && !self.isItemActive) // if active item
                {
                    [self showMessage:@"This Item is currently Activated."];
                    self.txtUniversalSearch.text = @"";
                    self.strSearchText = @"";
                    [self.txtUniversalSearch becomeFirstResponder];
                    [self reloadInventeryItemList];
                    
                }
                else // if not deleted than add to coredata
                {
                    [self.itemMgmtUpdateManager updateObjectsFromResponseDictionary:responseDictionary];
                    [self.itemMgmtUpdateManager linkItemToDepartmentFromResponseDictionary:responseDictionary];
                    
                    NSMutableString *strItem = [[NSMutableString alloc]init];
                    for (NSMutableDictionary *itemDictionary in itemResponseArray)
                    {
                        [strItem appendFormat:@"%@,",[itemDictionary valueForKey:@"ITEMCode"]];
                    }
                    NSString *strSearchResult = [strItem substringToIndex:strItem.length-1];
                    barcodeSearch.searchResult = strSearchResult;
                    barcodeSearch.foundOnServer = @(TRUE);
                    barcodeSearch.resultCount = @(itemResponseArray.count);
                    [UpdateManager saveContext:self.barcodeSearchObjectContext];
                    barcodeSearch = nil;
                    preCoustomeFilter = nil;
                    self.strSearchText = self.txtUniversalSearch.text;
                    [self reloadInventeryItemList];
                }
            }
            else
            {
                if (self.isItemInSelectMode) {
                    [self showMessage:[NSString stringWithFormat:@"No Record Found for %@",self.txtUniversalSearch.text]];
                    self.txtUniversalSearch.text = @"";
                    self.strSearchText = @"";
                    [self.txtUniversalSearch becomeFirstResponder];
                    [self reloadInventeryItemList];
                }
                else{
                    [self getUserConformationToAddItem];
                }
                barcodeSearch.searchResult = @"";
                barcodeSearch.foundOnServer =@(FALSE);
                [UpdateManager saveContext:self.barcodeSearchObjectContext];
                barcodeSearch = nil;
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
}

- (void)moveInvMgtInActiveItemToActiveItemList:(Item *)anItem {
    [self showActivityIndicator];
    NSMutableDictionary * dictItemInfo;
    dictItemInfo = [self changeItemActiveToInactive:anItem isItemActive:@"1"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseInvMgtForMoveItemToActiveListResponse:response error:error];
        });
    };
    self.activeItemInvMgtWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:dictItemInfo completionHandler:completionHandler];
}

-(void)responseInvMgtForMoveItemToActiveListResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSString * strItemId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
                
                NSManagedObjectContext *privateManageObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                
                Item *currentItem = [self.itemMgmtUpdateManager fetchAllEntityWithName:@"Item" key:@"itemCode" value:@[strItemId] moc:self.managedObjectContext].firstObject;
                
                currentItem.active = @1;
                NSError *error = nil;
                
                if (![privateManageObjectContext save:&error]) {
                    NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                }
                [self textFieldShouldReturn:self.txtUniversalSearch];
                [self reloadInventeryItemList];
            }
            else {
                [self showMessage:@"Item not updated, try again."];
            }
        }
    }
}

- (NSMutableDictionary *)changeItemActiveToInactive:(Item *)anItem isItemActive:(NSString *)strIsActive {
    NSMutableDictionary * addItemDataDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * itemDetails = [[NSMutableArray alloc] init];
    NSMutableDictionary * itemDataDict = [[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    
    NSString * strItemCode = [dictItemClicked valueForKey:@"ItemId"];
    BOOL isDuplicateUPC = [[dictItemClicked valueForKey:@"IsduplicateUPC"] boolValue];
    
    itemDataDict[@"ItemId"] = strItemCode;
    itemDataDict[@"ItemName"] = [NSString stringWithFormat:@"%@",[dictItemClicked valueForKey:@"ItemName"]];
    itemDataDict[@"Active"] = strIsActive;
    
    if (isDuplicateUPC) {
        itemDataDict[@"IsduplicateUPC"] = @"1";
    }
    else {
        itemDataDict[@"IsduplicateUPC"] = @"0";
    }
    
    itemDataDict[@"BranchId"] = self.rmsDbController.globalDict[@"BranchID"];
    
    NSString *userID = self.rmsDbController.globalDict[@"UserInfo"][@"UserId"];
    itemDataDict[@"UserId"] = userID;
    NSArray * arrKeys = itemDataDict.allKeys;
    NSMutableArray *itemMain = [[NSMutableArray alloc] init];
    for (NSString * strKey in arrKeys) {
        [itemMain addObject:@{@"Key":strKey,@"Value":[itemDataDict valueForKey:strKey]}];
    }
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    //    NSMutableArray * arrItemMain = [self ItemMain];
    itemDetailDict[@"ItemMain"] = itemMain;
    
    [self addBlanckArrayIn:itemDetailDict withKeys:@[@"ItemPriceSingle",@"ItemPriceCase",@"ItemPricePack",@"AddedBarcodesArray",@"DeletedBarcodesArray",@"VariationArray",@"VariationItemArray",@"addedItemTaxData",@"addedItemSupplierData",@"DeletedItemSupplierData",@"addedItemTag",@"addedItemDiscount",@"ItemTicketArray"]];
    
    itemDetailDict[@"DeletedItemTaxIds"] = @"";
    itemDetailDict[@"DeletedItemTagIds"] = @"";
    itemDetailDict[@"DeletedItemDiscountIds"] = @"";

    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    itemDetailDict[@"Updatedate"] = [formatter stringFromDate:date];
    
    [itemDetails addObject:itemDetailDict];
    addItemDataDic[@"ItemData"] = itemDetails;
    
    return addItemDataDic;
}
-(void)addBlanckArrayIn:(NSMutableDictionary *)itemDetailDict withKeys:(NSArray *)arrkeys{
    for (NSString * strkey in arrkeys) {
        itemDetailDict[strkey] = [[NSArray alloc]init];
    }
}
- (void)getUserConformationToAddItem {
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        self.strSearchText = @"";
        self.txtUniversalSearch.text = @"";
        [self reloadInventeryItemList];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        if(IsPhone())
        {
            self.rimsController.scannerButtonCalled = @"InvAdd";
            
            ItemInfoEditVC * itemInfoEditVC = [[UIStoryboard storyboardWithName:@"RimStoryboard_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];
            
            if (itemInfoEditVC.itemInfoDataObject==nil) {
                itemInfoEditVC.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
            }
            [itemInfoEditVC.itemInfoDataObject setItemMainDataFrom:nil];
            itemInfoEditVC.isCopy = FALSE;
            itemInfoEditVC.isInvenManageCalled = TRUE;
            itemInfoEditVC.strScanBarcode = self.txtUniversalSearch.text;
            [self.navigationController pushViewController:itemInfoEditVC animated:YES];
            
        }
        else
        {
            self.rimsController.scannerButtonCalled = @"InvAdd";
            ItemDetailEditVC *addNewSplitterVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
            addNewSplitterVC.selectedItemInfoDict = nil;
            addNewSplitterVC.isItemCopy = FALSE;
            addNewSplitterVC.searchedBarcode = self.txtUniversalSearch.text;
            addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self.sideMenuVCDelegate willPresentViewController:addNewSplitterVC animated:YES completion:nil];
        }
        self.strSearchText = @"";
        self.txtUniversalSearch.text = @"";
        [self reloadInventeryItemList];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:[NSString stringWithFormat:@"No item found for %@ UPC Number, are you sure you want to add item with %@ UPC?",self.strSearchText,self.strSearchText] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    [self.txtUniversalSearch resignFirstResponder];
}

#pragma mark - Scanner Types -
- (void)checkConnectedScannerType {
    
    if ([self.rmsDbController.globalScanDevice[@"Type"] isEqualToString:@"Bluetooth"])
        [self.txtUniversalSearch becomeFirstResponder];
    else
        [self.txtUniversalSearch resignFirstResponder];
}
#pragma mark - Scanner Device Methods

-(void)deviceButtonPressed:(int)which {
    if ([self.rmsDbController.globalScanDevice[@"Type"]isEqualToString:@"Scanner"]) {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"InvenMgmt"]) {
            self.strSearchText = @"";
        }
    }
}

-(void)deviceButtonReleased:(int)which {
    if ([self.rmsDbController.globalScanDevice[@"Type"]isEqualToString:@"Scanner"]) {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"InvenMgmt"]) {
            if(![self.strSearchText isEqualToString:@""]) {
                [self reloadInventeryItemList];
            }
        }
    }
}

-(void)barcodeData:(NSString *)barcode type:(int)type {
    if ([self.rmsDbController.globalScanDevice[@"Type"]isEqualToString:@"Scanner"]) {
        self.strSearchText = barcode;
        self.txtUniversalSearch.text = barcode;
    }
    else {
        [self showMessage:@"Please set scanner type as scanner."];
    }
}

#pragma mark - CoreData Methods -

-(void)reloadInventeryItemList {
    if(self.isItemInSelectMode) {
        self.gestureRight.enabled = FALSE;
        self.gestureLeft.enabled = FALSE;
    }
    else {
        self.gestureRight.enabled = TRUE;
        self.gestureLeft.enabled = TRUE;
    }
    self.indForSwipe = nil;
    self.indLastSelectedItem = nil;
    self.itemListRC = nil;

    ///// barcode search code
    NSDate *date =[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy/MM/dd hh:mm:ss";
    NSString *strDate = [formatter stringFromDate:date];
    
    barcodeSearch.moduleName = @"RIM";
    // barcodeSearch.barcode = self.searchText;
    //  barcodeSearch.modifiedBarCode = self.searchText;
    barcodeSearch.date = strDate;
    barcodeSearch.serverLookup = @(FALSE);
    barcodeSearch.foundOnServer = @(FALSE);

    
    [self showActivityIndicator];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tblInventoryItemList reloadData];
    });
}

- (NSFetchedResultsController *)itemListRC {
    if (_itemListRC) {
        return _itemListRC;
    }
    NSFetchRequest *fetchRequest = [self getFetchrequest:self.strSearchText];
    [self setSortDescriptorsFor:fetchRequest];
    NSInteger count = [UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest];
    barcodeSearch.resultCount = @(count);
    if (count > 0 || self.strSearchText.length == 0) {
        NSString * strSortSection = nil;
        if ([strSortKey isEqualToString:@"item_Desc"])
        {
            strSortSection = @"sectionLabel";
        }
        _itemListRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:strSortSection cacheName:nil];
        fetchRequest.fetchBatchSize = 20;
        [_itemListRC performFetch:nil];
        _itemListRC.delegate = self;
        
        self.previousItemListRC = _itemListRC;
        [self.activityIndicator hideActivityIndicator];
        if (self.isKeywordFilter) {
            barcodeSearch.searchResult = [[_itemListRC.fetchedObjects valueForKey:@"itemCode"] componentsJoinedByString:@","];
        }
        if (self.barcodeSearchObjectContext.hasChanges && barcodeSearch.moduleName != nil) {
            [UpdateManager saveContext:self.barcodeSearchObjectContext];
            barcodeSearch = nil;
        }
        return self.itemListRC;
    }
    else {
        if (self.isKeywordFilter) {
            BOOL valid;
            NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:self.txtUniversalSearch.text];
            valid = [alphaNums isSupersetOfSet:inStringSet];
            if (valid) { // numeric
                barcodeSearch.serverLookup = @(TRUE);
                [self callWSForMissingItem];
                NSString * strSortSection = nil;
                if ([strSortKey isEqualToString:@"item_Desc"])
                {
                    strSortSection = @"sectionLabel";
                }
                _itemListRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:strSortSection cacheName:nil];
                fetchRequest.fetchBatchSize = 20;
                [_itemListRC performFetch:nil];
                _itemListRC.delegate = self;
                self.previousItemListRC = _itemListRC;
            }
            else { // non numeric
                [self showMessage:[NSString stringWithFormat:@"No Record Found for %@",self.txtUniversalSearch.text]];
                self.txtUniversalSearch.text = @"";
                self.strSearchText = @"";
                [self.txtUniversalSearch becomeFirstResponder];
                barcodeSearch.searchResult = @"";
                [self.activityIndicator hideActivityIndicator];
            }
            return self.itemListRC;
        }
        else {
            [self.activityIndicator hideActivityIndicator];
            if (!self.previousItemListRC) {
                [self showMessage:[NSString stringWithFormat:@"No Record Found for %@",self.txtUniversalSearch.text]];
                self.txtUniversalSearch.text = @"";
                self.strSearchText = @"";
                [self.txtUniversalSearch becomeFirstResponder];
                barcodeSearch.searchResult = @"";
            }
            _itemListRC = self.previousItemListRC;
            return self.itemListRC;
        }
    }
}

#pragma mark - Create FetchRequest

-(NSFetchRequest *)getFetchrequest:(NSString *)strSearchWord {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    if (strSearchWord != nil && strSearchWord.length > 0) {
        fetchRequest.predicate = [self searchPredicateForText:strSearchWord];
    }
    else {
        fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[self defaultFilterForItem]];
    }
    return fetchRequest;
}

-(NSPredicate *)searchPredicateForText:(NSString *)searchData {
    barcodeSearch.searchText = searchData;
    BOOL isNumeric;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:searchData];
    isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) { // numeric
        barcodeSearch.barcode = searchData;
        searchData = [self.rmsDbController trimmedBarcode:searchData];
        barcodeSearch.modifiedBarCode = searchData;
    }
    else {
        barcodeSearch.barcode = @"";
        barcodeSearch.modifiedBarCode = @"";
    }
    NSMutableCharacterSet *separators = [[NSMutableCharacterSet alloc] init];
    [separators addCharactersInString:@","];
    
    NSMutableArray *textArray = [[searchData componentsSeparatedByCharactersInSet:separators] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;
    if(self.isKeywordFilter) {
        // For - Filter the when I click "return" or "search button" - Keyword
        dbFields = @[ @"item_Desc contains[cd] %@",@"item_No == %@", @"barcode == [cd] %@", @"item_Remarks BEGINSWITH[cd] %@",@"itemDepartment.deptName BEGINSWITH[cd] %@", @"ANY itemBarcodes.barCode == %@",@"ANY itemTags.tagToSizeMaster.sizeName contains[cd] %@"];
    }
    else {
        // For - Filter the item list as I press the keys - ABC Shorting
        dbFields = @[ @"item_Desc BEGINSWITH[cd] %@"];
    }
    
    for (int i=0; i<textArray.count; i++) {
        NSString *str=textArray[i];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *searchTextPredicates = [NSMutableArray array];
        for (NSString *dbField in dbFields) {
            if (![str isEqualToString:@""]) {
                [searchTextPredicates addObject:[NSPredicate predicateWithFormat:dbField, str]];
            }
        }
        NSPredicate *compoundpred = [NSCompoundPredicate orPredicateWithSubpredicates:searchTextPredicates];
        [fieldWisePredicates addObject:compoundpred];
    }
    [fieldWisePredicates addObjectsFromArray:[self defaultFilterForItem]];
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
    return finalPredicate;
}

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([configuration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

-(NSArray *)defaultFilterForItem {
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSPredicate *predicate;
    if ([self isSubDepartmentEnableInBackOffice]) {
        predicate = [NSPredicate predicateWithFormat:@"itm_Type != %@ AND active == %d AND isNotDisplayInventory == %@",@(-1),self.isItemActive,@(0)];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"itm_Type != %@ AND itm_Type != %@ AND active == %d AND isNotDisplayInventory == %@",@(-1),@(2),self.isItemActive,@(0)];
    }
    [fieldWisePredicates addObject:predicate];
    
    if (self.isItemInSelectMode) {
        
        NSPredicate *predicateDept = [NSCompoundPredicate notPredicateWithSubpredicate:[NSPredicate predicateWithFormat:@"itm_Type == 1 AND deptId == 0"]];
        
        NSPredicate *predicateSubDept = [NSCompoundPredicate notPredicateWithSubpredicate:[NSPredicate predicateWithFormat:@"itm_Type == 2 AND subDeptId == 0"]];
        [fieldWisePredicates addObject:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicateDept,predicateSubDept]]];
    }
    
    if (preCoustomeFilter) {
        [fieldWisePredicates addObject:preCoustomeFilter];
    }
    return fieldWisePredicates;
}

-(void)setSortDescriptorsFor:(NSFetchRequest *)fetchRequest {

    if ([strSortKey isEqualToString:@"item_InStock"]  || [strSortKey isEqualToString:@"salesPrice"])
    {
        NSSortDescriptor * aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:strSortKey ascending:isAscending];
        NSArray *sortDescriptors = @[aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    else if ([strSortKey isEqualToString:@"item_Desc"])
    {
        NSSortDescriptor * aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:strSortKey ascending:isAscending selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor * aSortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"sectionLabel" ascending:isAscending selector:@selector(caseInsensitiveCompare:)];
        NSArray * sortDescriptors = @[aSortDescriptor2,aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    else
    {
        NSSortDescriptor * aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:strSortKey ascending:isAscending selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = @[aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
    }
}

#pragma mark - ResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if ([controller isEqual:self.itemListRC]) {
        [self.tblInventoryItemList beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if ([controller isEqual:self.itemListRC]) {
        UITableView *tableView = self.tblInventoryItemList;
        
        self.indForSwipe = [self needToChangeIndexPathRowForSelectedItem:self.indForSwipe itemOldIndexPath:indexPath itemNewIndexPath:newIndexPath forChangeType:type];
        self.indLastSelectedItem = [self needToChangeIndexPathRowForSelectedItem:self.indLastSelectedItem itemOldIndexPath:indexPath itemNewIndexPath:newIndexPath forChangeType:type];
        
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeUpdate:
                if ([[tableView indexPathsForVisibleRows] indexOfObject:indexPath] != NSNotFound) {
                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                break;
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if ([controller isEqual:self.itemListRC]) {
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.tblInventoryItemList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tblInventoryItemList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            default:
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([controller isEqual:self.itemListRC]) {
        [self.tblInventoryItemList endUpdates];
    }
}
-(NSIndexPath *)needToChangeIndexPathRowForSelectedItem:(NSIndexPath *)selectedIndexPath itemOldIndexPath:(NSIndexPath *)oldIndexPath itemNewIndexPath:(NSIndexPath *)newIndexPath forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:{
            if ((oldIndexPath != nil && selectedIndexPath.section == oldIndexPath.section && oldIndexPath.row <=selectedIndexPath.row) || (newIndexPath != nil && selectedIndexPath.section == newIndexPath.section && newIndexPath.row <=selectedIndexPath.row)) {
                return [NSIndexPath indexPathForRow:selectedIndexPath.row +1 inSection:selectedIndexPath.section];
            }
            break;
        }
        case NSFetchedResultsChangeDelete:{
            if ((oldIndexPath != nil && selectedIndexPath.section == oldIndexPath.section && oldIndexPath.row <selectedIndexPath.row) || (newIndexPath != nil && selectedIndexPath.section == newIndexPath.section && newIndexPath.row <selectedIndexPath.row)) {
                return [NSIndexPath indexPathForRow:selectedIndexPath.row -1 inSection:selectedIndexPath.section];
            }
            else if ((oldIndexPath != nil && [oldIndexPath isEqual:selectedIndexPath]) || (newIndexPath != nil && [newIndexPath isEqual:selectedIndexPath])) {
                return nil;
            }
            break;
        }
        case NSFetchedResultsChangeMove:{
            if ([selectedIndexPath isEqual:oldIndexPath]) {
                return newIndexPath;
            }
            else if ([selectedIndexPath isEqual:newIndexPath]) {
                return [NSIndexPath indexPathForRow:selectedIndexPath.row +1 inSection:selectedIndexPath.section];
            }
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            break;
        }
    }
    return selectedIndexPath;
}
@end
