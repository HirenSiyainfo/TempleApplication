//  InventoryManagement.m
//  I-RMS
//
//  Created by Siya Infotech on 09/08/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "InventoryManagement.h"
#import "UITableViewCell+NIB.h"
#import "InventoryCell.h"
#import "RimIphonePresentMenu.h"
#import "RmsDbController.h"
#import "ItemHistoryVC.h"
#import "RimIphonePresentMenu.h"
#import "ItemInfoEditVC.h"
#import "RmsDashboardVC.h"
// CoreData Import
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "HoldInvoice+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "ItemTag+Dictionary.h"
#import "SizeMaster+Dictionary.h"
#import "GroupMaster+Dictionary.h"
#import "Mix_MatchDetail+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "SubDepartment+Dictionary.h"
#import "BarCodeSearch+Dictionary.h"

#import "ItemDetailEditVC.h"
#import "ItemInfoEditVC.h"
#import "ItemTotalAverageInfoVC.h"

#import "ItemVariation_M+Dictionary.h"
#import "ItemVariation_Md+Dictionary.h"
#import "CKOCalendarViewController.h"
#import "CameraScanVC.h"
#import "ItemTotalAverageInfoVC.h"
#import "RcrPosRestaurantVC.h"
#import "RcrPosVC.h"
#import "RapidItemFilterVC.h"
#import "SelectUserOptionVC.h"

@interface InventoryManagement () <CameraScanVCDelegate,InventoryCellDelegate,UIGestureRecognizerDelegate,RapidItemFilterVCDeledate> {

    BOOL flgViewControl;
    BOOL isScannerUsed;
    BOOL isDiscripitionSort;
    BOOL isQtySort;
    BOOL isPriceSort;

    IntercomHandler *intercomHandler;
    ItemHistoryVC * itemHistoryVC;
    RimIphonePresentMenu * objMenubar;

    NSInteger deleteRecordId;
    NSInteger updateBarcodeItemCode;

    BarCodeSearch *barcodeSearch;

    
    NSString *strSwipeDire;
    NSMutableString *status;

    NSMutableArray *singleItemBarcodesList;
    NSMutableArray *caseBarcodesList;
    NSMutableArray *packBarcodesList;
    NSMutableArray *selectedItem;

    ItemInfoDataObject * barcodeDataObject;
    RapidItemFilterVC * objRapidItemFilterVC;
    NSPredicate * preCoustomeFilter;
}
@property (nonatomic, strong) UpdateManager *itemMgmtUpdateManager;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, strong) NSManagedObjectContext *barcodeSearchObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *itemResultsController;
@property (nonatomic, strong) NSFetchedResultsController *allItemResultsController;
@property (nonatomic, strong) NSFetchedResultsController *previousItemResultsController;

@property (nonatomic) BOOL isAscending;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;


@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, strong) NSRecursiveLock *inventoryLock;
@property (nonatomic, strong) RapidWebServiceConnection * webServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection * itemSelectedLabelWebservice;
@property (nonatomic, strong) RapidWebServiceConnection * itemDeletedWC;
@property (nonatomic, strong) RapidWebServiceConnection * mgmtItemInsertWC;
@property (nonatomic, strong) RapidWebServiceConnection * insertBarcodesToItemWC;
@property (nonatomic, strong) RapidWebServiceConnection * updateBarcodeItemInsertWC;
@property (nonatomic, strong) RapidWebServiceConnection * itemUpdateWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection * activeItemInvMgtWSC;


//@property (nonatomic, strong) NSMutableArray *filterTypeArray;

@property (nonatomic, strong) NSIndexPath *indPath;
@property (nonatomic, strong) NSIndexPath *deleteIndexPath;
@property (nonatomic, strong) NSIndexPath *indexPathforSelectedItem;

@property (nonatomic, strong) NSString *strMainScanBarcode;
@property (nonatomic, strong) NSString *sortColumn;
@property (nonatomic, strong) NSString *sectionName;


@property (nonatomic, weak) IBOutlet UIButton *filterButton;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIImageView *img_qty;
@property (nonatomic, weak) IBOutlet UIImageView *img_Price;
@property (nonatomic, weak) IBOutlet UIImageView *img_description;
@property (nonatomic, weak) IBOutlet UIButton *btnRapidFilterView;
@property (nonatomic, weak) IBOutlet UIButton *keyBoardButton;
@property (nonatomic, weak) IBOutlet UIView *viewFilterBG;
@end

@implementation InventoryManagement

@synthesize itemResultsController = __itemResultsController;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.itemSelectModeArray=[[NSMutableArray alloc]init];
    self.isLablePrintSelect=FALSE;
    
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.webServiceConnection = [[RapidWebServiceConnection alloc]init];
    self.itemUpdateWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.itemSelectedLabelWebservice = [[RapidWebServiceConnection alloc] init];
    self.itemDeletedWC = [[RapidWebServiceConnection alloc]init];
    self.mgmtItemInsertWC = [[RapidWebServiceConnection alloc]init];
    self.insertBarcodesToItemWC = [[RapidWebServiceConnection alloc]init];
    self.updateBarcodeItemInsertWC = [[RapidWebServiceConnection alloc]init];
    self.activeItemInvMgtWSC = [[RapidWebServiceConnection alloc]init];
    
    // Do any additional setup after loading the view from its nib.
    if (IsPhone()) {
        objMenubar = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimIphonePresentMenu_sid"];
        objMenubar.sideMenuVCDelegate = self.sideMenuVCDelegate;
    }
    self.rimsController.scannerButtonCalled = @"";
    
    self.itemMgmtUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.barcodeSearchObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.sortColumn = @"item_Desc";
    self.sectionName = @"sectionLabel";
    self.isAscending = YES;
    isDiscripitionSort = TRUE;
    [self setUpDownImageToSortingType:_img_description isSorting:isDiscripitionSort];
    
    // From loadItemDataInTable
    self.checkCalledFunction=TRUE;
    flgViewControl=TRUE;
#ifdef LINEAPRO_SUPPORTED
    // Linea Barcode device connection
    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [dtdev connect];
    
#endif
    status=[[NSMutableString alloc] init];
    
    if([self.rimsController.scannerButtonCalled isEqualToString:@""])
    {
        self.rimsController.scannerButtonCalled=@"InvenMgmt";
    }
    
    flgDonebutton=FALSE;
    
    selectedItem = [[NSMutableArray alloc] init];
    self.deleteIndexPath = [[NSIndexPath alloc] init];
    self.arrTempSelected = [[NSMutableArray alloc] init];
    
    self.indPath = nil;
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    if (self.searchText != nil && self.searchText.length > 0) {
        self.txtUniversalSearch.text=self.searchText;
    }
}
-(IBAction)synchronize24HoursClickedFromRim:(id)sender
{
    [self.rmsDbController playButtonSound];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseCompleteSyncDataFromRim:) name:@"CompleteSyncData" object:nil];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].delegate.window];
    [self.rmsDbController startSynchronizeUpdate:3600*24];
}

-(void)responseCompleteSyncDataFromRim:(NSNotification *)notification
{
    [_activityIndicator hideActivityIndicator];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteSyncData" object:nil];
}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

- (void)contextHasChanged:(NSNotification*)notification
{
    NSManagedObjectContext *changedContext = notification.object;
    NSManagedObjectContext *parentContext = self.rmsDbController.managedObjectContext;
    
    // Ignore it.
    if (![changedContext isEqual:parentContext]) return;
    
    // This is not main thread
    if (![NSThread isMainThread]) {
        // Merge should be performed on main thread
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self contextHasChanged:notification];
        });
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Merge changes
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // Save changes
            [self saveContext];
        });
    });
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        BOOL hasChanges = managedObjectContext.hasChanges;
        hasChanges = YES;
        @try {
            if (hasChanges) {
                if (![managedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
            
        }
    }
}

#pragma mark - Check scanner type
- (void)checkConnectedScannerType
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
    {
        [self.txtUniversalSearch becomeFirstResponder];
    }
    else
    {
        [self.txtUniversalSearch resignFirstResponder];
    }
}

- (void)checkItemFilterType
{
    if([self.rmsDbController.rimSelectedFilterType isEqualToString:@"ABC Shorting"])
    {
        self.rmsDbController.rimSelectedFilterType = @"ABC Shorting";
        self.isKeywordFilter = FALSE;
        self.isAbcShortingFilter = TRUE;
        self.txtUniversalSearch.placeholder = @"ABC Shorting";
    }
    else
    {
        self.rmsDbController.rimSelectedFilterType = @"Keyword";
        self.isKeywordFilter = TRUE;
        self.isAbcShortingFilter = FALSE;
        self.txtUniversalSearch.placeholder = @"UPC, Item Number, Description, Department, etc..";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    isScannerUsed = FALSE;
    NSIndexPath * tempRload = [self.indPath copy];
    self.indPath = nil;
    if (tempRload) {
        [self reloadItemRowsAtIndexPaths:@[tempRload]];
    }

    self.rimsController.scannerButtonCalled = @"InvenMgmt";
    
    [self checkItemFilterType];
    [self checkConnectedScannerType];
    
    NSDate* date = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [self.showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
    if (IsPad()) {
        [self addFilterView];
    }
}

-(void)resetTableViewData
{
    self.indPath = nil;
    self.indexPathforSelectedItem = nil;
    self.rimsController.scannerButtonCalled = @"InvenMgmt";
}

-(IBAction)btn_back:(id)sender {
    
    [self.rmsDbController playButtonSound];
    self.rimsController.scannerButtonCalled=@"";
    [self presentViewController:objMenubar animated:YES completion:nil];
}

-(IBAction)btn_New:(id)sender
{
    [Appsee addEvent:kRIMFooterNewItem];
    [self.rmsDbController playButtonSound];
//    NSArray *arryView = [self.rimsController.objInvHome.navigationController viewControllers];
//    
//    for(int i=0;i<[arryView count];i++){
//        
//        UIViewController *viewCon = [arryView objectAtIndex:i];
//        if([viewCon isKindOfClass:[InventoryManagement class]]){
//            [self.rimsController.objInvHome.navigationController popToViewController:viewCon animated:YES];
//        }
//    }
    
    self.rimsController.scannerButtonCalled = @"InvAdd";
    
    if (IsPhone())
    {
        ItemInfoEditVC * itemInfoEditVC = [[UIStoryboard storyboardWithName:@"RimStoryboard_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];
        if (itemInfoEditVC.itemInfoDataObject==nil) {
            itemInfoEditVC.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
        }
        //        itemInfoEditVC.itemInfoDataObject.dictGetItemData = [ItemInfo mutableCopy];
        [itemInfoEditVC.itemInfoDataObject setItemMainDataFrom:nil];
        itemInfoEditVC.isCopy = FALSE;
        [self.navigationController pushViewController:itemInfoEditVC animated:YES];
    }
    else
    {
        ItemDetailEditVC *addNewSplitterVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
        addNewSplitterVC.selectedItemInfoDict = nil;
        addNewSplitterVC.isItemCopy = FALSE;
        addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.sideMenuVCDelegate willPresentViewController:addNewSplitterVC animated:YES completion:nil];
//        [self._rimController.objSideMenuiPad showInventoryAddNew:nil];
    }
}

#pragma mark - UniversalItemSearch

-(NSPredicate *)searchPredicateForText:(NSString *)searchData
{
    barcodeSearch.searchText = searchData;
    BOOL isNumeric;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:searchData];
    isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) // numeric
    {
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
    if(self.isKeywordFilter)
    {
        // For - Filter the when I click "return" or "search button" - Keyword
        dbFields = @[ @"item_Desc contains[cd] %@",@"item_No == %@", @"barcode == %@", @"item_Remarks BEGINSWITH[cd] %@",@"itemDepartment.deptName BEGINSWITH[cd] %@", @"ANY itemBarcodes.barCode == %@",@"ANY itemTags.tagToSizeMaster.sizeName contains[cd] %@"];
    }
    else
    {
        // For - Filter the item list as I press the keys - ABC Shorting
        dbFields = @[ @"item_Desc BEGINSWITH[cd] %@"];
    }
    
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
    
    NSPredicate *isDisplayInPosPredicate = [NSPredicate predicateWithFormat:@"itm_Type != %@ AND active == %d AND isNotDisplayInventory == %@",@(-1),self.isItemActive,@(0)];
    
    [fieldWisePredicates addObject:isDisplayInPosPredicate];

    if (preCoustomeFilter) {
        [fieldWisePredicates addObject:preCoustomeFilter];
    }
    
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
    return finalPredicate;
}

-(IBAction)btn_UniversalItemSearch:(id)sender
{
    if(self.isKeywordFilter)
    {
        if(self.txtUniversalSearch.text.length > 0)
        {
            [self.rmsDbController playButtonSound];
            [self.txtUniversalSearch resignFirstResponder];
            self.searchText = self.txtUniversalSearch.text;
            NSDictionary *searchDict = @{kRIMUniversalItemSearchKey  : self.txtUniversalSearch.text};
            [Appsee addEvent:kRIMUniversalItemSearch withProperties:searchDict];
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reloadInventoryMgmtTable];
            });
        }
    }
    
}

-(IBAction)btnCameraScanSearch:(id)sender
{
    self.cameraScanVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    [self presentViewController:self.cameraScanVC animated:YES completion:^{
        self.cameraScanVC.delegate = self;
    }];
}
- (IBAction)btn_itemKeyboard:(id)sender
{
    _keyBoardButton.selected = !_keyBoardButton.selected;
    [self.view endEditing:YES];
    [self.txtUniversalSearch becomeFirstResponder];

}
#pragma mark - Camera Scan Delegate Methods

-(void)barcodeScanned:(NSString *)strBarcode
{
    [self.txtUniversalSearch resignFirstResponder];
    self.searchText = strBarcode;
    self.txtUniversalSearch.text = strBarcode;
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadInventoryMgmtTable];
    });
}

#pragma mark - UITextField Delegate Methods

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.txtUniversalSearch && _keyBoardButton.selected) {
        self.txtUniversalSearch.inputView = nil;
        [self.txtUniversalSearch becomeFirstResponder];

    }
    else {
        self.txtUniversalSearch.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        [textField becomeFirstResponder];
    }
    [objRapidItemFilterVC filterViewSlideIn:FALSE];
    self.btnRapidFilterView.selected = FALSE;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    barcodeSearch = [self.itemMgmtUpdateManager updateBarcodeSearchInfo:self.barcodeSearchObjectContext];
    if(self.isKeywordFilter)
    {
        if(textField == self.txtUniversalSearch)
        {
            if(self.txtUniversalSearch.text.length > 0)
            {
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.searchText = self.txtUniversalSearch.text;
                    self.itemResultsController = nil;
                    //hiten
//                    NSArray *sections = [self.itemResultsController sections];
//                    if(sections.count > 0)
//                    {
//                        self.indPath = nil;
//                        self.indexPathforSelectedItem = nil;
                        [self.tblviewInventory reloadData];
//                    }
                    [_activityIndicator hideActivityIndicator];
                });
            }
        }
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)clearTextAndReloadData
{
    self.searchText = @"";
    self.indPath=nil;
    [self.tblviewInventory scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self checkItemFilterType];
    [self checkConnectedScannerType];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadAllItems];
    });
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.txtUniversalSearch) {
        [Appsee addEvent:kRIMClearUniversalItemSearch];
    }
    textField.text = @"";
    [self clearTextAndReloadData];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(!self.isKeywordFilter)
    {
        if(self.isAbcShortingFilter)
        {
            if(textField == self.txtUniversalSearch)
            {
                if([string isEqualToString:@","])
                {
                    self.rmsDbController.rimSelectedFilterType = @"Keyword";
                    self.isKeywordFilter = TRUE;
                    self.isAbcShortingFilter = FALSE;
                    self.txtUniversalSearch.placeholder = @"UPC, Item Number, Description, Department, etc..";
                }
                else
                {
                    NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
                    if (textField.text.length == 1 && [string isEqualToString:@""]) {
                        self.searchText = @"";
                    }
                    else if(searchString.length > 0)
                    {
                        if (self.itemResultsController.fetchedObjects.count > 0)
                        {
                            NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
                            [self.tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                        }
                        self.searchText = searchString;
                    }
                    else
                    {
                        self.searchText = @"";
                    }
                    self.itemResultsController = nil;
                    //hiten
                    NSArray *sections = self.itemResultsController.sections;
                    if(sections.count > 0)
                    {
                        self.itemResultsController = nil;
                        self.indPath = nil;
                        self.indexPathforSelectedItem = nil;
                        [self.tblviewInventory reloadData];
                    }
                    [_activityIndicator hideActivityIndicator];
                }
            }
            return YES;
        }
        return YES;
    }
    else
    {
        if(range.location == 0 && ([string isEqualToString:@""]))
        {
            textField.text = @"";
            [self clearTextAndReloadData];
        }
        return YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    self.filterTypeTable.hidden = YES;
}

-(IBAction)filterButtonClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self.txtUniversalSearch resignFirstResponder];
    
    SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:@[@"ABC Shorting",@"Keyword"] SelectedObject:self.rmsDbController.rimSelectedFilterType SelectionComplete:^(NSArray *arrSelection) {
        [self setFilterType:arrSelection[0]];
    } SelectionColse:^(UIViewController *popUpVC) {
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}
-(void)setFilterType:(NSString *)selectedoption{
    [self.rmsDbController playButtonSound];
    if ([selectedoption isEqualToString:@"ABC Shorting"]) {
        self.rmsDbController.rimSelectedFilterType = @"ABC Shorting";
        self.isKeywordFilter = FALSE;
        self.isAbcShortingFilter = TRUE;
        self.txtUniversalSearch.placeholder = @"ABC Shorting";
    }
    else{
        self.rmsDbController.rimSelectedFilterType = @"Keyword";
        self.isKeywordFilter = TRUE;
        self.isAbcShortingFilter = FALSE;
        self.txtUniversalSearch.placeholder = @"UPC, Item Number, Description, Department, etc..";
    }
    self.indPath = nil;
    self.indexPathforSelectedItem = nil;

    NSDictionary *filterTypeDict = @{kRIMItemFilterTypeSelectionKey : self.rmsDbController.rimSelectedFilterType};
    [Appsee addEvent:kRIMItemFilterTypeSelection withProperties:filterTypeDict];
    if((self.txtUniversalSearch.text.length > 0) || (self.searchText.length > 0))
    {
        self.txtUniversalSearch.text = @"";
        self.searchText = @"";
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [self reloadAllItems];
    }
    [self checkConnectedScannerType];
    [self checkItemFilterType];
}
#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tblviewInventory)
    {
        NSArray *sections = self.itemResultsController.sections;
        return sections.count;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (tableView == self.tblviewInventory) {
        NSArray *sections = self.itemResultsController.sectionIndexTitles;
        
        for(int i=0 ; i< sections.count ; i++)
        {
            NSString *tempStr = sections[i];
            return tempStr;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.tblviewInventory)
    {
        return [self.itemResultsController sectionForSectionIndexTitle:title atIndex:index];
    }
    else
    {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblviewInventory)
    {
        NSArray *sections = self.itemResultsController.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
        return sectionInfo.numberOfObjects;
    }
    return 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tblviewInventory)
    {
        return self.itemResultsController.sectionIndexTitles;
    }
    else
    {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.tblviewInventory)
    {
        if(IsPhone())
        {
            return 85;

            CGFloat rowHeight = 68.69;
            
            CGSize constraintSize;
            constraintSize.width = 205;
            constraintSize.height = 200;
            
            Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
            NSDictionary *itemDictionary = anItem.itemRMSDictionary;
            NSString *itemName = itemDictionary[@"ItemName"];
            
            UIFont *nameFont = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
            CGRect textRect = [itemName boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin                                                 attributes:@{NSFontAttributeName:nameFont} context:nil];
            CGSize size = textRect.size;
            rowHeight += size.height;
            return rowHeight;
        }
        else
        {
            return 76;
        }
    }
    else
    {
        return 44;
    }
}

- (void)itemSwipeMethod:(InventoryCell *)cell_p indexPath:(NSIndexPath *)indexPath
{
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRightRim:)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [cell_p addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeftRim:)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell_p addGestureRecognizer:gestureLeft];
    
    UIView * viewItemOpretions;
    if (self.isItemActive) {
        viewItemOpretions = cell_p.viewOperation;
    }
    else{
        viewItemOpretions = cell_p.viewOperationInactive;
    }
    
    if(self.indPath != nil && indexPath.section == self.indPath.section && indexPath.row == self.indPath.row)
    {
        viewItemOpretions.hidden = NO;
    }
    else
    {
        viewItemOpretions.hidden = YES;
    }
}

- (UITableViewCell *)configureItemCell:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InventoryItemCustomCell";
    InventoryCell *itemCell = [self.tblviewInventory dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // check cell value
    if (itemCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InventoryCell" owner:self options:nil];
        itemCell = nib.firstObject;
    }
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    NSDictionary *itemDictionary = anItem.itemRMSDictionary;
    NSString *itemCode = itemDictionary[@"ItemId"];
    NSString * itemBarCode = self.txtUniversalSearch.text;

    [itemCell configureCellWithItem:anItem withBarCode:itemBarCode withCurrentIndexPath:indexPath withIsBarcodeExist:[self.itemMgmtUpdateManager doesBarcodeExist:itemBarCode forItemCode:itemCode] isLablePrintSelectOr:self.isLablePrintSelect isSelectedIndex:[indexPath isEqual:self.indexPathforSelectedItem]];
    
    if(!self.checkSearchRecord)
    {
        if([anItem.itm_Type isEqualToString:@"0"])
        {
            [self itemSwipeMethod:itemCell indexPath:indexPath];
        }
        else {
            itemCell.viewOperation.hidden = TRUE;
            itemCell.viewOperationInactive.hidden = TRUE;
        }
    }
    
    itemCell.imgSelected.image = [UIImage imageNamed:@"RIM_Com_Arrow_Detail"];
    itemCell.imgSelected.highlightedImage = [UIImage imageNamed:@"rim_inventory_arrow_selected"];
    if (self.isLablePrintSelect) {
        itemCell.imgSelected.image = [UIImage imageNamed:@"radiobtn.png"];
        itemCell.imgSelected.highlightedImage = nil;
        if( [self.itemSelectModeArray containsObject:itemDictionary]) {
            itemCell.imgSelected.image = [UIImage imageNamed:@"radioMulti_selected.png"];
        }
    }
    itemCell.inventoryCellDelegate=self;
    return itemCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    if(tableView == self.tblviewInventory)
    {
        cell = [self configureItemCell:indexPath];
    }
//    cell.backgroundColor = [UIColor clearColor];
//    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSIndexPath *previousIndexPath = self.indexPathforSelectedItem;
    if (tableView == self.tblviewInventory)
    {
        if(self.isLablePrintSelect)
        {
            self.indexPathforSelectedItem = nil;
            [self selectItemData:indexPath];
        }
        else{
            
            if(!(self.checkSearchRecord))
            {
                if(self.checkCalledFunction)
                {
                    if ((flgViewControl))
                    {
                        //if ([self.rmsDbController doesUserHaveRightsToEditItem]) {
                        InventoryCell *cell = (InventoryCell *)[tableView cellForRowAtIndexPath:indexPath];
                        cell.imgBackGround.image = [UIImage imageNamed:@"ListHoverAndActive_ipad.png"];
                        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.indexPathforSelectedItem = [indexPath copy];
                            NSMutableArray * arrReloadIndexPath = [NSMutableArray array];
                            if (previousIndexPath) {
                                [arrReloadIndexPath addObject:previousIndexPath];
                            }
                            if (self.indexPathforSelectedItem) {
                                [arrReloadIndexPath addObject:self.indexPathforSelectedItem];
                            }
                            [self reloadItemRowsAtIndexPaths:arrReloadIndexPath];
                            [self launchItemDetailViewForIndexPath:indexPath isItemCopy:FALSE];
                            //[self setCellDefaultBackGroundImage:cell];
                        });
                        //}
                        //else
                        //{
                        //UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                        //{
                        //};
                        //[self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You don't have rights to edit item. Please contact to admin." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                        //}
                    }
                }
            }
            else
            {
                Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
//                if (anItem.is_Selected.boolValue) {
//                    anItem.is_Selected = @(NO);
//                } else {
//                    anItem.is_Selected = @(YES);
//                }
                
                NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
                if([self.itemSelectModeArray containsObject:dictItemClicked])
                {
                    [self.itemSelectModeArray removeObject:dictItemClicked];
                    if(self.arrTempSelected.count > 0) {
                        flgDonebutton=TRUE;
                    } else {
                        flgDonebutton = FALSE;
                    }
                }
                else
                {
                    [self.itemSelectModeArray addObject:dictItemClicked];
                    flgDonebutton=TRUE;
                }
//                if([[dictItemClicked objectForKey:@"selected"] isEqualToString:@"0"])
//                {
//                    for(int isfnd = 0 ; isfnd < [self.arrTempSelected count] ; isfnd++)
//                    {
//                        NSMutableDictionary *dictSelected = [[self.arrTempSelected objectAtIndex:isfnd] mutableCopy ];
//                        if([[dictSelected valueForKey:@"ItemId"] isEqualToString:[dictItemClicked valueForKey:@"ItemId"]])
//                        {
//                            [self.arrTempSelected removeObjectAtIndex:isfnd];
//                            break;
//                        }
//                    }
//                    if(self.arrTempSelected.count > 0) {
//                        flgDonebutton=TRUE;
//                    } else {
//                        flgDonebutton = FALSE;
//                    }
//                } else {
//                    [self.arrTempSelected addObject:dictItemClicked];
//                    flgDonebutton=TRUE;
//                }
                
                if (self.indexPathforSelectedItem) {
                    [self reloadItemRowsAtIndexPaths:@[self.indexPathforSelectedItem]];
//                    [self.tblviewInventory reloadRowsAtIndexPaths:@[self.indexPathforSelectedItem] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                
                if(flgDonebutton)
                {
                    self.btn_Done.hidden=NO;
                }
                else
                {
                    self.btn_Done.hidden=YES;
                }
            }
        }
    }
    if (previousIndexPath) {
        [self reloadItemRowsAtIndexPaths:@[previousIndexPath]];
    }
}

- (void)reloadItemRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    NSMutableArray * arrListIndexPath = [NSMutableArray array];
    NSArray * arrIndexPaths = [self.tblviewInventory indexPathsForVisibleRows];
    for (NSIndexPath * indexPath in indexPaths) {
        if ([arrIndexPaths containsObject:indexPath] && ![arrListIndexPath containsObject:indexPath]) {
            [arrListIndexPath addObject:indexPath];
        }
//        @try {
//            id isDisp = [self.itemResultsController objectAtIndexPath:indexPath];
//            if (isDisp != nil && ![arrListIndexPath containsObject:indexPath]) {
//                [arrListIndexPath addObject:indexPath];
//            }
//        }
//        @catch (NSException *exception) {
//            
//        }
    }
    if (arrListIndexPath.count > 0) {
        [self.tblviewInventory reloadRowsAtIndexPaths:arrListIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)launchItemDetailViewForIndexPath:(NSIndexPath *)indexPath isItemCopy:(BOOL)isItemCopy {

    [self.rmsDbController playButtonSound];
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    
    if(anItem.itemSubDepartment.subDeptName)
    {
        dictItemClicked[@"SubDepartmentName"] = anItem.itemSubDepartment.subDeptName;
    }
    else
    {
        dictItemClicked[@"SubDepartmentName"] = @"";
    }
    
    //GET DEPARTMENT NAME
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",[dictItemClicked[@"DepartId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *departmentList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (departmentList.count>0)
    {
        Department *department=departmentList.firstObject;
        dictItemClicked[@"DepartmentName"] = department.deptName;
    }
    else
    {
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
        if (groupList.count > 0)
        {
            GroupMaster *groupMst=groupList.firstObject;
            dictItemClicked[@"GroupName"] = groupMst.groupName;
        }
        else
        {
            dictItemClicked[@"GroupName"] = @"";
        }
    }
    else
    {
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
        if (groupList.count > 0)
        {
            Mix_MatchDetail *groupMst = groupList.firstObject;
            dictItemClicked[@"mixMatchDiscription"] = groupMst.item_Description;
        }
        else
        {
            dictItemClicked[@"mixMatchDiscription"] = @"";
        }
    }
    else
    {
        dictItemClicked[@"mixMatchDiscription"] = @"";
    }
    
    // GET MixMatchName From GroupID
    if([dictItemClicked[@"cate_MixMatchId"] integerValue] != 0)
    {
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription entityForName:@"Mix_MatchDetail" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        predicate = [NSPredicate predicateWithFormat:@"mixMatchId==%d",[dictItemClicked[@"cate_MixMatchId"] integerValue]];
        fetchRequest.predicate = predicate;
        NSArray *groupList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (groupList.count > 0)
        {
            Mix_MatchDetail *groupMst = groupList.firstObject;
            dictItemClicked[@"cate_MixMatchDiscription"] = groupMst.item_Description;
        }
        else
        {
            dictItemClicked[@"cate_MixMatchDiscription"] = @"";
        }
    }
    else
    {
        dictItemClicked[@"cate_MixMatchDiscription"] = @"";
    }
    
    [_activityIndicator hideActivityIndicator];
    [self itemDetailViewShow:dictItemClicked isItemCopy:isItemCopy];
}
-(void)itemDetailViewShow:(NSMutableDictionary *)ItemInfo isItemCopy:(BOOL)isItemCopy {
    if (isItemCopy) {
        if (![[ItemInfo valueForKey:@"ITM_Type"] isEqualToString:@"0"]) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You can't copy this item." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        ItemInfo[@"Barcode"] = @"";
        ItemInfo[@"avaibleQty"] = @"";
        ItemInfo[@"ItemNo"] = @"";
    }
    if (IsPhone()) {
        ItemInfoEditVC * itemInfoEditVC = [[UIStoryboard storyboardWithName:@"RimStoryboard_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];
        if (itemInfoEditVC.itemInfoDataObject==nil) {
            itemInfoEditVC.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
        }
        [itemInfoEditVC.itemInfoDataObject setItemMainDataFrom:[ItemInfo mutableCopy]];
        itemInfoEditVC.isCopy = isItemCopy;
        [self.navigationController pushViewController:itemInfoEditVC animated:YES];
    }
    else {
        ItemDetailEditVC * itemDetailEditVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
        itemDetailEditVC.selectedItemInfoDict = ItemInfo;
        itemDetailEditVC.isItemCopy = isItemCopy;
        itemDetailEditVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:itemDetailEditVC animated:YES completion:nil];
    }
}
- (void)getSelectedPackageTypePopUp:(NSIndexPath *)indexPath packageType:(NSString *)editingPackageType sender:(UIButton *)sender
{
    NSMutableArray *itemBarcodesList = [[NSMutableArray alloc] init];
    [_activityIndicator hideActivityIndicator];
    [self.rmsDbController playButtonSound];
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    updateBarcodeItemCode = anItem.itemCode.integerValue ;
    for (ItemBarCode_Md *barcode in anItem.itemBarcodes)
    {
        if([barcode.isBarcodeDeleted  isEqual: @(0)])
        {
            if([editingPackageType isEqualToString:@"Single Item"])
            {
                if([barcode.packageType isEqualToString:@"Single Item"])
                {
                    NSMutableDictionary *barcodeDict = [[NSMutableDictionary alloc]init];
                    barcodeDict[@"Barcode"] = barcode.barCode;
                    barcodeDict[@"PackageType"] = barcode.packageType;
                    barcodeDict[@"IsDefault"] = barcode.isDefault;
                    barcodeDict[@"isExist"] = @"";
                    barcodeDict[@"notAllowItemCode"] = @"";
                    [itemBarcodesList addObject:barcodeDict];
                }
            }
            else if([editingPackageType isEqualToString:@"Case"])
            {
                if([barcode.packageType isEqualToString:@"Case"])
                {
                    NSMutableDictionary *barcodeDict = [[NSMutableDictionary alloc]init];
                    barcodeDict[@"Barcode"] = barcode.barCode;
                    barcodeDict[@"PackageType"] = barcode.packageType;
                    barcodeDict[@"IsDefault"] = barcode.isDefault;
                    barcodeDict[@"isExist"] = @"";
                    barcodeDict[@"notAllowItemCode"] = @"";
                    [itemBarcodesList addObject:barcodeDict];
                }
            }
            else if([editingPackageType isEqualToString:@"Pack"])
            {
                if([barcode.packageType isEqualToString:@"Pack"])
                {
                    NSMutableDictionary *barcodeDict = [[NSMutableDictionary alloc]init];
                    barcodeDict[@"Barcode"] = barcode.barCode;
                    barcodeDict[@"PackageType"] = barcode.packageType;
                    barcodeDict[@"IsDefault"] = barcode.isDefault;
                    barcodeDict[@"isExist"] = @"";
                    barcodeDict[@"notAllowItemCode"] = @"";
                    [itemBarcodesList addObject:barcodeDict];
                }
            }
        }
    }
    
    ItemBarcodeType packageNumber = ItemBarcodeTypeAll;
    if([editingPackageType isEqualToString:@"Single Item"])
    {
        packageNumber = ItemBarcodeTypeSingleItem;
    }
    else if([editingPackageType isEqualToString:@"Case"])
    {
        packageNumber = ItemBarcodeTypeCase;
    }
    else if([editingPackageType isEqualToString:@"Pack"])
    {
        packageNumber = ItemBarcodeTypePack;
    }
    if(IsPad())
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
        MultipleBarcodePopUpVC *barcodePopUpVC = [storyBoard instantiateViewControllerWithIdentifier:@"MultipleBarcodePopUpVC_sid"];
        barcodePopUpVC.editingPackageType = packageNumber;
        barcodePopUpVC.arrItemBarcodeList = itemBarcodesList;
        barcodePopUpVC.anItem = anItem;
        barcodeDataObject = [[ItemInfoDataObject alloc]init];
        [barcodeDataObject setItemMainDataFrom:anItem.itemRMSDictionary];
        barcodeDataObject.arrItemAllBarcode = [itemBarcodesList mutableCopy];
        [barcodeDataObject createDuplicateItemBarcodeArray];
        barcodePopUpVC.multipleBarcodePopUpVCDelegate = self;
        NSString *item_Code = [NSString stringWithFormat:@"%ld",(long)updateBarcodeItemCode];
        barcodePopUpVC.itemCode = item_Code;
        barcodePopUpVC.isDuplicateBarcodeAllowed = anItem.isDuplicateBarcodeAllowed.boolValue;
        
        [barcodePopUpVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionRight];
        
    }
    else
    {
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

//- (void)setBarcodeDetailsToMultipleBarcodePopUp:(MultipleBarcodePopUpVC *)barcodePopUpVC forItem:(Item *)anItem forPackageType:(NSInteger)packageType
//{
//    [self setBarcodeListForItem:anItem];
//    switch (packageType) {
//        case PackageTypeSingleItem:
//            barcodePopUpVC.caseBarcodes = [caseBarcodesList mutableCopy];
//            barcodePopUpVC.packBarcodes = [packBarcodesList mutableCopy];
//            break;
//        case PackageTypeCase:
//            barcodePopUpVC.singleItemBarcodes = [singleItemBarcodesList mutableCopy];
//            barcodePopUpVC.packBarcodes = [packBarcodesList mutableCopy];
//            break;
//        case PackageTypePack:
//            barcodePopUpVC.singleItemBarcodes = [singleItemBarcodesList mutableCopy];
//            barcodePopUpVC.caseBarcodes = [caseBarcodesList mutableCopy];
//            break;
//        default:
//            break;
//    }
//}

-(void)setBarcodeListForItem:(Item *)anItem {
    singleItemBarcodesList = [[NSMutableArray alloc]init];
    caseBarcodesList = [[NSMutableArray alloc]init];
    packBarcodesList = [[NSMutableArray alloc]init];
    for (ItemBarCode_Md *barcode in anItem.itemBarcodes) {
        if([barcode.isBarcodeDeleted  isEqual: @(0)]) {
            if([barcode.packageType isEqualToString:@"Single Item"]) {
                NSMutableDictionary *barcodeDict = [[NSMutableDictionary alloc]init];
                barcodeDict[@"Barcode"] = barcode.barCode;
                barcodeDict[@"PackageType"] = barcode.packageType;
                barcodeDict[@"IsDefault"] = barcode.isDefault;
                barcodeDict[@"isExist"] = @"";
                barcodeDict[@"notAllowItemCode"] = @"";
                [singleItemBarcodesList addObject:barcodeDict];
            }
            else if([barcode.packageType isEqualToString:@"Case"]) {
                NSMutableDictionary *barcodeDict = [[NSMutableDictionary alloc]init];
                barcodeDict[@"Barcode"] = barcode.barCode;
                barcodeDict[@"PackageType"] = barcode.packageType;
                barcodeDict[@"IsDefault"] = barcode.isDefault;
                barcodeDict[@"isExist"] = @"";
                barcodeDict[@"notAllowItemCode"] = @"";
                [caseBarcodesList addObject:barcodeDict];
            }
            else if([barcode.packageType isEqualToString:@"Pack"]) {
                NSMutableDictionary *barcodeDict = [[NSMutableDictionary alloc]init];
                barcodeDict[@"Barcode"] = barcode.barCode;
                barcodeDict[@"PackageType"] = barcode.packageType;
                barcodeDict[@"IsDefault"] = barcode.isDefault;
                barcodeDict[@"isExist"] = @"";
                barcodeDict[@"notAllowItemCode"] = @"";
                [packBarcodesList addObject:barcodeDict];
            }
        }
    }
}

- (Item*)fetchAllItemsFromDb:(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:_managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}


-(IBAction)btn_DoneClicked:(id)sender
{
    [Appsee addEvent:kRIMFooterDone];
//    for(int istmp = 0 ; istmp < [self.arrTempSelected count] ; istmp++ )
//    {
//        NSMutableDictionary *dictSelected = [[self.arrTempSelected objectAtIndex:istmp] mutableCopy ];
//        Item *anItem=[self fetchAllItems:[dictSelected valueForKey:@"ItemId"]];
//        anItem.is_Selected = @(NO);
//    }
    [self.rmsDbController playButtonSound];
    //    [self.managedObjectContext reset];
    [self.tblviewInventory reloadData];
    
    self.btn_Done.hidden=YES;
    flgDonebutton = NO;
    self.checkSearchRecord = FALSE;

}
#pragma mark - item active & inactive -
-(void)ActiveInactiveItemAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];

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
    
    self.itemUpdateWebServiceConnection = [self.itemUpdateWebServiceConnection initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:dictItemInfo completionHandler:completionHandler];

}

-(void)responceOfItemInactiveResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSString * strItemId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
                Item * currentItem = [self fetchAllItemsFromDb:strItemId];
                if (self.isItemActive) {
                    currentItem.active = @0;
                }
                else {
                    currentItem.active = @1;
                }
                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                }
            }
            else{
                NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n Item not updated, try again."};
                [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
    [self updateDataInDataBase_RIM];
    self.indexPathforSelectedItem = nil;
    self.indPath = nil;
}
-(void)updateDataInDataBase_RIM{
    
    NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
    [itemLiveUpdate setValue:@"Update" forKeyPath:@"Action"];
    [itemLiveUpdate setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"EntityId"];
    [itemLiveUpdate setValue:@"Item" forKey:@"Type"];
    [self.rmsDbController addItemListToLiveUpdateQueue:itemLiveUpdate];

}
- (NSMutableDictionary *)changeItemActiveToInactive:(Item *)anItem isItemActive:(NSString *)strIsActive{
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
    
    itemDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    itemDataDict[@"UserId"] = userID;
    NSArray * arrKeys = itemDataDict.allKeys;
    NSMutableArray *itemMain = [[NSMutableArray alloc] init];
    for (NSString * strKey in arrKeys) {
        [itemMain addObject:@{@"Key":strKey,@"Value":[itemDataDict valueForKey:strKey]}];
    }
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
//    NSMutableArray * arrItemMain = [self ItemMain];
    itemDetailDict[@"ItemMain"] = itemMain;
    
    itemDetailDict[@"ItemPriceSingle"] = [[NSArray alloc]init];
    itemDetailDict[@"ItemPriceCase"] = [[NSArray alloc]init];
    itemDetailDict[@"ItemPricePack"] = [[NSArray alloc]init];

    itemDetailDict[@"AddedBarcodesArray"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedBarcodesArray"] = [[NSArray alloc]init];
    
    itemDetailDict[@"VariationArray"] = [[NSArray alloc]init];
    itemDetailDict[@"VariationItemArray"] = [[NSArray alloc]init];
    
    itemDetailDict[@"addedItemTaxData"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemTaxIds"] = @"";
    
    itemDetailDict[@"addedItemSupplierData"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemSupplierData"] = [[NSArray alloc]init];

    itemDetailDict[@"addedItemTag"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemTagIds"] = @"";
    
    itemDetailDict[@"addedItemDiscount"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemDiscountIds"] = @"";
    
    itemDetailDict[@"ItemTicketArray"] = [[NSArray alloc]init];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    itemDetailDict[@"Updatedate"] = [formatter stringFromDate:date];
    
    [itemDetails addObject:itemDetailDict];
    addItemDataDic[@"ItemData"] = itemDetails;
    
    return addItemDataDic;
}
#pragma mark - Left / Right / Copy / Delete swipe Method
-(void)didSwipeRightRim:(UISwipeGestureRecognizer *)gesture
{
    [Appsee addEvent:kRIMItemSwipe];
    if(self.isLablePrintSelect){
        
    }
    else{
        //    if([self.rmsDbController doesUserHaveRightsToEditItem])
        //    {
        CGPoint location = [gesture locationInView:self.tblviewInventory];
        NSIndexPath *swipedIndexPath = [self.tblviewInventory indexPathForRowAtPoint:location];
        
        Item * anItem = [self.itemResultsController objectAtIndexPath:swipedIndexPath];
        if([anItem.itm_Type isEqualToString:@"0"])
        {
            NSIndexPath *previousSelection = self.indPath;
            self.indPath = swipedIndexPath;
            strSwipeDire=@"Right";
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            
            if (previousSelection.row >= 0) {
                if (previousSelection.section == swipedIndexPath.section && previousSelection.row == swipedIndexPath.row) {
                    if (swipedIndexPath) {
                        [indexPaths addObject:swipedIndexPath];
                    }
                }
                else
                {
                    if (swipedIndexPath) {
                        [indexPaths addObject:swipedIndexPath];
                    }
                    if (previousSelection) {
                        [indexPaths addObject:previousSelection];
                    }
                }
            } else {
                if (swipedIndexPath) {
                    [indexPaths addObject:swipedIndexPath];
                }
            }
            [self reloadItemRowsAtIndexPaths:indexPaths];
            //        [self.tblviewInventory reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            //    }
            //    else
            //    {
            //UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            //{
            //};
            //[self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:@"You don't have rights to edit item. Please contact to admin." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            //    }
        }
    }
}

-(void)didSwipeLeftRim:(UISwipeGestureRecognizer *)gesture
{
    if(self.isLablePrintSelect){
        
    }
    else{
        
        
        //    if([self.rmsDbController doesUserHaveRightsToEditItem])
        //    {
        CGPoint location = [gesture locationInView:self.tblviewInventory];
        NSIndexPath *swipedIndexPath = [self.tblviewInventory indexPathForRowAtPoint:location];
        if(self.indPath.row == swipedIndexPath.row)
        {
            self.indPath = nil;
            strSwipeDire = @"Left";
            //            [self.tblviewInventory reloadData];
            if (swipedIndexPath) {
                [self reloadItemRowsAtIndexPaths:@[swipedIndexPath]];
            }
//            [self.tblviewInventory reloadRowsAtIndexPaths:@[swipedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        //    }
        //    else
        //    {
        //UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        //{
        //};
        //[self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:@"You don't have rights to edit item. Please contact to admin." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        //    }
        
    }
}
-(void)historyItemAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender{
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
    itemHistoryVC  = [storyboard instantiateViewControllerWithIdentifier:@"ItemHistoryVC"];
    ItemInfoDataObject * itemInfoDataObject = [[ItemInfoDataObject alloc]init];
    [itemInfoDataObject setItemMainDataFrom:dictItemClicked];
    itemHistoryVC.itemInfoDataObject = itemInfoDataObject;
    itemHistoryVC.managedObjectContext = self.managedObjectContext;
    UIView * bgview = [[UIView alloc]initWithFrame:self.view.bounds];
    bgview.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.300];
    
    CGRect frameHistory = itemHistoryVC.view.bounds;
    frameHistory.origin.y = 50;
    frameHistory.origin.x = (bgview.frame.size.width-724)/2;
    frameHistory.size.height = 624;
    frameHistory.size.width = 724;
    
    //    UIView * bgColorView = [[UIView alloc]init];
    itemHistoryVC.view.backgroundColor = [UIColor colorWithRed:0.894 green:0.898 blue:0.918 alpha:1.000];
    itemHistoryVC.view.frame = frameHistory;
    itemHistoryVC.view.clipsToBounds = TRUE;
    itemHistoryVC.view.layer.cornerRadius = 15;
    
    itemHistoryVC.view.frame = frameHistory;
    
    //    [bgColorView addSubview:itemHistoryVC.view];
    [bgview addSubview:itemHistoryVC.view];
    
    UIButton * btnColse = [[UIButton alloc] init];
    [btnColse setTitle:@"Close" forState:UIControlStateNormal];
    [btnColse setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnColse.backgroundColor = [UIColor colorWithRed:0.286 green:0.416 blue:0.475 alpha:1.000];
    [btnColse addTarget:self action:@selector(closeHistoryPopupView:) forControlEvents:UIControlEventTouchUpInside];
    btnColse.clipsToBounds = TRUE;
    btnColse.layer.cornerRadius = 10;
    
    CGRect frameColse;
    frameColse.origin.y = itemHistoryVC.view.bounds.size.height+65;
    frameColse.origin.x = (bgview.frame.size.width-100)/2;
    frameColse.size.height = 50;
    frameColse.size.width = 100;
    btnColse.frame = frameColse;
    [bgview addSubview:btnColse];
    
    [self.view addSubview:bgview];
    
    UITapGestureRecognizer *letterTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeHistoryPopupViewFromTap:)];
    letterTapRecognizer.numberOfTapsRequired = 1;
    letterTapRecognizer.delegate = self;
    [bgview addGestureRecognizer:letterTapRecognizer];
    
    self.indexPathforSelectedItem = nil;
    self.indPath = nil;
    [self reloadItemRowsAtIndexPaths:@[indexPath]];
//    [self.tblviewInventory reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:itemHistoryVC.view]) {
        return NO;
    }
    else {
        if ([touch.view isDescendantOfView:objRapidItemFilterVC.view]){
            return NO;
        }
        else if (self.viewFilterBG.hidden) {
            self.btnRapidFilterView.selected = FALSE;
            [self.view removeGestureRecognizer:gestureRecognizer];
            return NO;
        }
    }
    return YES;
}
-(void)closeHistoryPopupViewFromTap:(UITapGestureRecognizer*)gestureRecognizer {
    UIView * viewbg = gestureRecognizer.view;
    itemHistoryVC = nil;
    [viewbg removeFromSuperview];
}
-(void)closeHistoryPopupView:(UIButton *)sender {
    UIView * bgView = sender.superview;
    itemHistoryVC = nil;
    [bgView removeFromSuperview];
}
-(void)copyItemAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender
{
//    self.rimsController.objSideMenuiPad.isCopyItem = YES;
//    //[self.rmsDbController playButtonSound];
//    self.rimsController.flgButtonClicked=YES;
    
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    NSDictionary *itemSwipeDict = @{kRIMItemSwipeCopyKey: [dictItemClicked valueForKey:@"ItemId"]};
    [Appsee addEvent:kRIMItemSwipeCopy withProperties:itemSwipeDict];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self launchItemDetailViewForIndexPath:indexPath isItemCopy:TRUE];
        // hide swiped image
        self.indPath = nil;
        self.indexPathforSelectedItem = nil;
        [self reloadItemRowsAtIndexPaths:@[indexPath]];
//        [self.tblviewInventory reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

-(void)deleteItemAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender
{
    [self.rmsDbController playButtonSound];
    
    self.deleteIndexPath = [indexPath copy ];
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    NSDictionary *itemSwipeDict = @{kRIMItemSwipeDeleteKey: [dictItemClicked valueForKey:@"ItemId"]};
    [Appsee addEvent:kRIMItemSwipeDelete withProperties:itemSwipeDict];
    
    // Check swiped item is deparment or not
    // It department then check department is assign in item or not.
    // If not assign the user can delete the deparment and if assign in item then can't delete the deparmtent.
    NSString *itemName = anItem.item_Desc;
    if([anItem.itm_Type isEqualToString:@"1"] || [anItem.itm_Type isEqualToString:@"2"])
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        // Create the predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId == %@ AND (itm_Type == %@ OR itm_Type == %@ )",anItem.deptId,@(1),@(2)];
        fetchRequest.predicate = predicate;
        
        NSArray *isItemFound = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (isItemFound.count > 0)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                self.indPath = nil;
                self.indexPathforSelectedItem = nil;
                strSwipeDire = @"Left";
                [self.tblviewInventory reloadData];
            };
            NSString *deptType = @"Department";
            
            if([anItem.itm_Type isEqualToString:@"1"])
            {
                deptType = @"Department";
            }
            else if ([anItem.itm_Type isEqualToString:@"2"])
            {
                deptType = @"SubDepartment";
            }
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"You can't delete this %@ from Item list, as %@ assign to some item.",itemName,deptType] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
    }
    deleteRecordId = anItem.itemCode.integerValue ;
    [_activityIndicator hideActivityIndicator];
    if([self isAvailableInOffLineHolds:deleteRecordId]){
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You can not delete this item,It is in offline Hold Invoice." buttonTitles:@[@"Yes"] buttonHandlers:@[rightHandler]];
    }
    else {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            self.indPath = nil;
            self.indexPathforSelectedItem = nil;
            strSwipeDire = @"Left";
            if (self.deleteIndexPath) {
                [self reloadItemRowsAtIndexPaths:@[self.deleteIndexPath]];
            }

//            [self.tblviewInventory reloadRowsAtIndexPaths:@[self.deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self deleteRecord:deleteRecordId];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"Are you sure you want to delete %@ ?",itemName] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}
-(BOOL)isAvailableInOffLineHolds:(NSInteger) itemCode{
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
-(void)singleItemClickedAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender {
    
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    NSDictionary *itemSwipeDict = @{kRIMItemSwipeSingleKey: [dictItemClicked valueForKey:@"ItemId"]};
    [Appsee addEvent:kRIMItemSwipeSingle withProperties:itemSwipeDict];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getSelectedPackageTypePopUp:indexPath packageType:@"Single Item" sender:sender];
    });
}
-(void)caseClickedAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender {

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    NSDictionary *itemSwipeDict = @{kRIMItemSwipeCaseKey: [dictItemClicked valueForKey:@"ItemId"]};
    [Appsee addEvent:kRIMItemSwipeCase withProperties:itemSwipeDict];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getSelectedPackageTypePopUp:indexPath packageType:@"Case" sender:sender];
    });
}
-(void)packClickedAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender {
    
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    NSDictionary *itemSwipeDict = @{kRIMItemSwipePackKey: [dictItemClicked valueForKey:@"ItemId"]};
    [Appsee addEvent:kRIMItemSwipePack withProperties:itemSwipeDict];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getSelectedPackageTypePopUp:indexPath packageType:@"Pack" sender:sender];
    });
}

-(void) deleteRecord:(NSInteger)deleteID
{
    NSString *deleteItemCode = [NSString stringWithFormat:@"%ld", (long)deleteID];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *deleteparam=[[NSMutableDictionary alloc]init];
    [deleteparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [deleteparam setValue:deleteItemCode forKey:@"ItemCode"];
    // pass system date and time while deleting record.
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString* currentDateTime = [formatter stringFromDate:date];
    deleteparam[@"Updatedate"] = currentDateTime;
    
    NSDictionary *itemDeleteDict = @{kRIMItemSwipeDeleteWebServiceCallKey: deleteItemCode};
    [Appsee addEvent:kRIMItemSwipeDeleteWebServiceCall withProperties:itemDeleteDict];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deleteItemDataResponse:response error:error];
        });
    };
    
    self.itemDeletedWC = [self.itemDeletedWC initWithRequest:KURL actionName:WSM_ITEM_DELETED params:deleteparam completionHandler:completionHandler];
}

- (void)deleteItemDataResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSDictionary *itemDeleteDict = @{kRIMItemSwipeDeleteWebServiceResponseKey: @"Item has been deleted successfully"};
                [Appsee addEvent:kRIMItemSwipeDeleteWebServiceResponse withProperties:itemDeleteDict];
                
                // deleteRecordId
                if (self.isItemActive) {
                    Item * currentItem = [self fetchAllItemsFromDb:[NSString stringWithFormat:@"%ld",(long)deleteRecordId]];
                    currentItem.active = @0;
                    NSError *error = nil;
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                    }
                }
                else {
                    [self.itemMgmtUpdateManager deleteItemWithItemCode:@(deleteRecordId)];
                }
                self.searchText = self.txtUniversalSearch.text;
                self.indPath=nil;
                self.indexPathforSelectedItem = nil;
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item has been deleted successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -2) {
                NSDictionary *deleteDict = @{kRIMItemDeleteWebServiceResponseKey : [response valueForKey:@"Data"]};
                [Appsee addEvent:kRIMItemDeleteWebServiceResponse withProperties:deleteDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                NSDictionary *itemDeleteDict = @{kRIMItemSwipeDeleteWebServiceResponseKey: @"Item not deleted."};
                [Appsee addEvent:kRIMItemSwipeDeleteWebServiceResponse withProperties:itemDeleteDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item not deleted." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}

-(void)reloadInventoryMgmtTable
{
    self.indPath = nil;
    self.indexPathforSelectedItem = nil;
    self.itemResultsController = nil;
    [self.tblviewInventory reloadData];
    [_activityIndicator hideActivityIndicator];
}

-(void)reloadAllItems
{
    self.indPath = nil;
    self.indexPathforSelectedItem = nil;
    self.itemResultsController = _allItemResultsController;
    self.previousItemResultsController = _allItemResultsController;
    [self.tblviewInventory reloadData];
    [_activityIndicator hideActivityIndicator];
}

#pragma mark - Scanner Device Methods

-(void)deviceButtonPressed:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"InvenMgmt"])
        {
            isScannerUsed = TRUE;
            [status setString:@""];
            self.searchText = @"";
        }
    }
}

-(void)deviceButtonReleased:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"InvenMgmt"])
        {
            if(![status isEqualToString:@""])
            {
                //txtUniversalSearch.text = status;
                [self reloadInventoryMgmtTable];
            }
        }
    }
}

-(void)barcodeData:(NSString *)barcode type:(int)type
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        [status setString:@""];
        self.strMainScanBarcode = barcode;
        [status appendFormat:@"%@", barcode];
        self.searchText = barcode;
        self.txtUniversalSearch.text = barcode;
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please set scanner type as scanner." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

#pragma mark Item Info Button

-(IBAction)btn_ItemInfoClicked:(id)sender
{
    [Appsee addEvent:kRIMFooterItemInfo];
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
#pragma mark - RapidFilters -
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
    self.allItemResultsController=nil;
    self.itemResultsController=nil;
    [self.tblviewInventory reloadData];
}
-(void)willChangeRapidFilterIsSlidein:(BOOL)isSlidein {
#ifdef IS_CLICK_TO_SEARCH
    self.btnRapidFilterView.selected = isSlidein;
    [objRapidItemFilterVC filterViewSlideIn:isSlidein];
#endif
}
#pragma mark - Fetched results controller

- (void)attachSortDescriptorsTorResultController:(NSFetchRequest *)fetchRequest
{
    // Create the sort descriptors array.
    NSString *sectionLabel = nil;
    NSSortDescriptor *aSortDescriptor;
    if ([self.sortColumn isEqualToString:@"item_InStock"]  || [self.sortColumn isEqualToString:@"salesPrice"])
    {
        aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending];
        NSArray *sortDescriptors = @[aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    else if ([self.sortColumn isEqualToString:@"item_Desc"])
    {
        NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *aSortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:self.sectionName ascending:self.isAscending selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = @[aSortDescriptor2,aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
        sectionLabel = self.sectionName;
    }
    else
    {
        aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = @[aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    
    // Create and initialize the fetch results controller.

    __itemResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:sectionLabel cacheName:nil];
    
    [__itemResultsController performFetch:nil];
    __itemResultsController.delegate = self;
    
    self.previousItemResultsController = __itemResultsController;
}

- (void)callWSForMissingItem
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    });
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[self.rmsDbController trimmedBarcode:self.txtUniversalSearch.text] forKey:@"Code"];
    [itemparam setValue:@"Barcode" forKey:@"Type"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseInvnetoryMgmtDataRimResponse:response error:error];
        });
    };
    
    self.mgmtItemInsertWC = [self.mgmtItemInsertWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
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
                    InventoryManagement * __weak myWeakReference = self;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        self.txtUniversalSearch.text = @"";
                        self.searchText = self.txtUniversalSearch.text;
                        self.itemResultsController = nil;
                        [self.tblviewInventory reloadData];
                    };
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        NSString *strItemId = [NSString stringWithFormat:@"%@",[itemDict valueForKey:@"ITEMCode"]];
                        Item *currentItem = [self fetchAllItemsFromDb:strItemId];
                        if (currentItem) {
                            [myWeakReference moveInvMgtInActiveItemToActiveItemList:currentItem];
                        }
                    };
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"This item is inactive would you like to activate it?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                }
                else if ([[[itemDict valueForKey:@"Active"] stringValue] isEqualToString:@"1"] && !self.isItemActive) // if active item
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"This Item is currently Activated." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    self.txtUniversalSearch.text = @"";
                    self.searchText = @"";
                    [self.txtUniversalSearch becomeFirstResponder];
                    __itemResultsController = nil;
                    self.previousItemResultsController = __itemResultsController;
                    [self.tblviewInventory reloadData];
                    
                }
                else // if not deleted than add to coredata
                {
                    self.itemResultsController = nil;
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
                    self.searchText = self.txtUniversalSearch.text;
                    [self.tblviewInventory reloadData];
                }
            }
            else
            {
                [self getUserConformationToAddItem];
                barcodeSearch.searchResult = @"";
                barcodeSearch.foundOnServer =@(FALSE);
                [UpdateManager saveContext:self.barcodeSearchObjectContext];
                barcodeSearch = nil;
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
}

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)itemResultsController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.inventoryLock];
    if (__itemResultsController != nil)
    {
        return __itemResultsController;
    }

    // Create and configure a fetch request with the Item entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    if (self.searchText != nil && ![self.searchText isEqualToString:@""]) {
        NSPredicate *searchPredicate = [self searchPredicateForText:self.searchText];
        
        BOOL isNumeric;
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:self.searchText];
        isNumeric = [alphaNums isSupersetOfSet:inStringSet];
        if (isNumeric) // numeric
        {
            self.searchText = [self.rmsDbController trimmedBarcode:self.searchText];
        }
        fetchRequest.predicate = searchPredicate;
        NSInteger isRecordFound = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
        NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        
        NSMutableString *strItemId = [[NSMutableString alloc]init];
        if (resultSet.count >0)
        {
            for (Item *item in resultSet)
            {
                NSMutableDictionary *dictTempGlobal = [item.itemRMSDictionary mutableCopy];
                [strItemId appendFormat:@"%@,",[dictTempGlobal valueForKey:@"ItemId"]];
            }
            NSString *strSearchResult = [strItemId substringToIndex:strItemId.length-1];
            barcodeSearch.searchResult = strSearchResult;
        }
        else
        {
            barcodeSearch.searchResult = @"";
            
        }
        
        
        ///// barcode search code
        NSDate *date =[NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy/MM/dd hh:mm:ss";
        NSString *strDate = [formatter stringFromDate:date];
        
        barcodeSearch.moduleName = @"RIM";
        // barcodeSearch.barcode = self.searchText;
        //  barcodeSearch.modifiedBarCode = self.searchText;
        barcodeSearch.resultCount = @(isRecordFound);
        barcodeSearch.date = strDate;
        barcodeSearch.serverLookup = @(FALSE);
        barcodeSearch.foundOnServer = @(FALSE);
        
        ///// barcode search code end
        if(self.isKeywordFilter)
        {
            if(isRecordFound == 0)
            {
                BOOL valid;
                NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
                NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:self.txtUniversalSearch.text];
                valid = [alphaNums isSupersetOfSet:inStringSet];
                if (valid) // numeric
                {
                    barcodeSearch.serverLookup = @(TRUE);
                    [self callWSForMissingItem];
                }
                else // non numeric
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"No Record Found for %@",self.txtUniversalSearch.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    self.txtUniversalSearch.text = @"";
                    self.searchText = @"";
                    [self.txtUniversalSearch becomeFirstResponder];
                    __itemResultsController = self.previousItemResultsController;
                    return __itemResultsController;
                }
                [self attachSortDescriptorsTorResultController:fetchRequest];
                return __itemResultsController;
            }
            else
            {
                
            }
        }
        else // for Alphabatic sorting
        {
            if(isRecordFound == 0)
            {
                __itemResultsController = self.previousItemResultsController;
                return __itemResultsController;
                
            }
        }
    }
    else{
        NSMutableArray *fieldWisePredicates = [NSMutableArray array];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itm_Type != %@ AND active == %d AND isNotDisplayInventory == %@",@(-1),self.isItemActive,@(0)];
        
        [fieldWisePredicates addObject:predicate];
        
        if (preCoustomeFilter) {
            [fieldWisePredicates addObject:preCoustomeFilter];
        }
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
        
        fetchRequest.predicate = finalPredicate;    }
    if (barcodeSearch.moduleName != nil) {
        [UpdateManager saveContext:self.barcodeSearchObjectContext];
        barcodeSearch = nil;
    }
    [self attachSortDescriptorsTorResultController:fetchRequest];
    [lock unlock];
    return __itemResultsController;
}

-(void)uploadMissingBarcodeSearch {
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    [param setValue:[(self.rmsDbController.globalDict)[@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateValue = [formatter stringFromDate:currentDate];
    [param setValue:currentDateValue forKey:@"LocalDate"];
    
    [param setValue:@"RIM" forKey:@"ModuleName"];
    [param setValue:@"iOS" forKey:@"Client"];
    
    NSMutableArray *arrBarcodeDetail = [[NSMutableArray alloc]init];
    NSArray *arrBarcode = [self fetchAllBarcodeDetails:self.barcodeSearchObjectContext];
    for (BarCodeSearch *barcodesearch in arrBarcode)
    {
        NSMutableDictionary *dictBarcode = barcodesearch.barcodeSearchDictionary;
        [dictBarcode removeObjectForKey:@"moduleName"];
        [arrBarcodeDetail addObject:dictBarcode];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrBarcodeDetail options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strSearchtext = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [param setValue:strSearchtext forKey:@"SearchText"];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
            [self missingBarcodeManualEntryResponse:response error:error];
    };
    
    self.webServiceConnection = [self.webServiceConnection initWithAsyncRequest:KURL actionName:WSM_BARCODE_SEARCH_LOG params:param asyncCompletionHandler:asyncCompletionHandler];
}

- (void)missingBarcodeManualEntryResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSArray *barcodeSearchList=[self fetchAllBarcodeDetails:self.barcodeSearchObjectContext];;
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

- (NSArray*)fetchAllBarcodeDetails:(NsmoContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BarCodeSearch" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSPredicate *predict = [NSPredicate predicateWithFormat:@"barcode!=nil"];
    fetchRequest.predicate = predict;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

- (NSFetchedResultsController *)allItemResultsController {
    
    if (_allItemResultsController != nil) {
        return _allItemResultsController;
    }

    // Create and configure a fetch request with the Item entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending selector:@selector(caseInsensitiveCompare:)];
    
    NSSortDescriptor *aSortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:self.sectionName ascending:self.isAscending selector:@selector(caseInsensitiveCompare:)];
    
    NSArray *sortDescriptors = @[aSortDescriptor2,aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    
    NSPredicate * fatchPredicate = [NSPredicate predicateWithFormat:@"active == %d AND isNotDisplayInventory == %@ ",self.isItemActive,@(0)];

    [fieldWisePredicates addObject:fatchPredicate];
    
    if (preCoustomeFilter) {
        [fieldWisePredicates addObject:preCoustomeFilter];
    }

    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
    
    fetchRequest.predicate = finalPredicate;

    _allItemResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:self.sectionName cacheName:nil];

    
    [_allItemResultsController performFetch:nil];
    _allItemResultsController.delegate = self;
    return _allItemResultsController;
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if(controller != __itemResultsController)
    {
        [self unlockResultController];
        return;
    }
    else if (__itemResultsController == nil){
        [self unlockResultController];
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblviewInventory beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != __itemResultsController)
    {
        return;
    }
    self.indPath = [self needToChangeIndexPathRowForSelectedItem:self.indPath itemOldIndexPath:indexPath itemNewIndexPath:newIndexPath forChangeType:type];
    
    self.indexPathforSelectedItem = [self needToChangeIndexPathRowForSelectedItem:self.indexPathforSelectedItem itemOldIndexPath:indexPath itemNewIndexPath:newIndexPath forChangeType:type];
    if (__itemResultsController == nil){
        return;
    }
    UITableView *tableView = self.tblviewInventory;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] != NSNotFound) {
                if (indexPath) {
                    [self reloadItemRowsAtIndexPaths:@[indexPath]];
                }
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
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
        case NSFetchedResultsChangeDelete: {
            if ((oldIndexPath != nil && selectedIndexPath.section == oldIndexPath.section && oldIndexPath.row <selectedIndexPath.row) || (newIndexPath != nil && selectedIndexPath.section == newIndexPath.section && newIndexPath.row <selectedIndexPath.row)) {
                return [NSIndexPath indexPathForRow:selectedIndexPath.row -1 inSection:selectedIndexPath.section];
            }
            else if ((oldIndexPath != nil && [oldIndexPath isEqual:selectedIndexPath]) || (newIndexPath != nil && [newIndexPath isEqual:selectedIndexPath])){
                return nil;
            }
            break;
        }
        case NSFetchedResultsChangeMove: {
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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(controller != __itemResultsController)
    {
        return;
    }

    self.indPath = [self needToChangeIndexPathSectionForSelectedItem:self.indPath newSectionIndexPath:sectionIndex forChangeType:type];
    
    self.indexPathforSelectedItem = [self needToChangeIndexPathSectionForSelectedItem:self.indexPathforSelectedItem newSectionIndexPath:sectionIndex forChangeType:type];

    if (__itemResultsController == nil){
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblviewInventory insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblviewInventory deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}

-(NSIndexPath *)needToChangeIndexPathSectionForSelectedItem:(NSIndexPath *)selectedIndexPath newSectionIndexPath:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:{
            if (sectionIndex < selectedIndexPath.section) {
                return [NSIndexPath indexPathForRow:selectedIndexPath.row inSection:selectedIndexPath.section+1];
            }
            break;
        }
        case NSFetchedResultsChangeDelete: {
            if (sectionIndex < selectedIndexPath.section) {
                return [NSIndexPath indexPathForRow:selectedIndexPath.row -1 inSection:selectedIndexPath.section];
            }
            break;
        }
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate: {
            return nil;
            break;
        }
    }
    return selectedIndexPath;
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != __itemResultsController)
    {
        return;
    }
    else if (__itemResultsController == nil){
        return;
    }
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tblviewInventory endUpdates];
    [self unlockResultController];
}

- (void)getUserConformationToAddItem
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [_activityIndicator hideActivityIndicator];
        [self checkConnectedScannerType];
        self.searchText = @"";
        self.txtUniversalSearch.text = @"";
        self.itemResultsController = nil;
        [self.tblviewInventory reloadData];
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
        self.searchText = @"";
        self.txtUniversalSearch.text = @"";
        self.itemResultsController = nil;
        [self.tblviewInventory reloadData];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"No item found for %@ UPC Number, are you sure you want to add item with %@ UPC?",self.searchText,self.searchText] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    //    [UpdateManager saveContext:self.barcodeSearchObjectContext];
    //    barcodeSearch = nil;
    [self.txtUniversalSearch resignFirstResponder];
}
- (void)moveInvMgtInActiveItemToActiveItemList:(Item *)anItem
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * dictItemInfo;
    dictItemInfo = [self changeItemActiveToInactive:anItem isItemActive:@"1"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseInvMgtForMoveItemToActiveListResponse:response error:error];
        });
    };
    
    self.activeItemInvMgtWSC = [self.activeItemInvMgtWSC initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:dictItemInfo completionHandler:completionHandler];
}

-(void)responseInvMgtForMoveItemToActiveListResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSString * strItemId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
                self.itemResultsController = nil;
                
                NSManagedObjectContext *privateManageObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                
                Item * currentItem = [self fetchAllItems:strItemId privateContext:privateManageObjectContext];
            
                currentItem.active = @1;
                NSError *error = nil;
                
                if (![privateManageObjectContext save:&error]) {
                    NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                }
                
                [self.tblviewInventory reloadData];
                [self textFieldShouldReturn:self.txtUniversalSearch];
            }
            else{
                NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n Item not updated, try again."};
                [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

- (Item*)fetchAllItems:(NSString *)itemId privateContext:(NSManagedObjectContext *)privateContext
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:privateContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:privateContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}


# pragma mark - Multiplebarcode Delegate
- (void)didUpdateMultipleBarcode:(NSMutableArray *)itemBarcodes allowToItems:(NSString *)allowToItems
{
    barcodeDataObject.arrItemAllBarcode = itemBarcodes;
    if (!barcodeDataObject.IsduplicateUPC) {
        [self removeExistingBarcodeBeforSendItToServerFromBarcodeArray:itemBarcodes];
    }
    
    NSPredicate *duplicateBarcodePredicate = [NSPredicate predicateWithFormat:@"isExist == %@",@"YES"];
    NSArray *alreadyExistBarcodes = [itemBarcodes filteredArrayUsingPredicate:duplicateBarcodePredicate];
    BOOL isDuplicateUPC = FALSE;
    if (alreadyExistBarcodes != nil && alreadyExistBarcodes.count > 0) {
        isDuplicateUPC = TRUE;
    }
    else
    {
        isDuplicateUPC = barcodeDataObject.IsduplicateUPC;
    }

    NSString *barcodeItemCode = [NSString stringWithFormat:@"%ld", (long)updateBarcodeItemCode];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *updateBarcodeParam = [[NSMutableDictionary alloc]init];
    // New Added Barcode Array  Delete isExist, notAllowItemCode
    [updateBarcodeParam setValue:barcodeDataObject.arrAddedBarcodeList forKey:@"AddedBarcodes"];
    [updateBarcodeParam setValue:barcodeDataObject.arrDeletedBarcodeList forKey:@"DeletedBarcodes"];
    [updateBarcodeParam setValue:barcodeItemCode forKey:@"ItemCode"];
    
    NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"PackageType == %@", @"Single Item"];
    NSArray *isBarcodeResult = [itemBarcodes filteredArrayUsingPredicate:barcodePredicate];
    if(isBarcodeResult.count > 0)
    {
        NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"IsDefault == %@", @"1"];
        NSArray *isDefault = [itemBarcodes filteredArrayUsingPredicate:barcodePredicate];
        if(isDefault.count > 0)
        {
            NSDictionary *tempDict = isDefault.firstObject;
            [updateBarcodeParam setValue:[tempDict valueForKey:@"Barcode"] forKey:@"DefaultBarcode"];
        }
        else
        {
            [updateBarcodeParam setValue:@"" forKey:@"DefaultBarcode"];
        }
    }
    else
    {
        Item *anItem = [self fetchAllItemsFromDb:barcodeItemCode];
        for (ItemBarCode_Md *barcode in anItem.itemBarcodes)
        {
            if([barcode.isBarcodeDeleted  isEqual: @(0)])
            {
                if([barcode.packageType isEqualToString:@"Single Item"])
                {
                    if([barcode.isDefault  isEqual: @(1)])
                    {
                        [updateBarcodeParam setValue:barcode.barCode forKey:@"DefaultBarcode"];
                    }
                }
            }
        }
    }
    if([[updateBarcodeParam valueForKey:@"DefaultBarcode"] isEqualToString:@""])
    {
        [updateBarcodeParam setValue:@"" forKey:@"DefaultBarcode"];
    }
    
    
    // pass system date and time while deleting record.
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString* currentDateTime = [formatter stringFromDate:date];
    [updateBarcodeParam setValue:currentDateTime forKey:@"UpdatedDate"];
    
    updateBarcodeParam[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    updateBarcodeParam[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    updateBarcodeParam[@"UserId"] = userID;
    updateBarcodeParam[@"IsduplicateUPC"] = @(isDuplicateUPC);
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateBarcodeToSwipedItemResponse:response error:error];
        });
    };
    
    self.insertBarcodesToItemWC = [self.insertBarcodesToItemWC initWithRequest:KURL actionName:WSM_INSERT_BARCODE_TO_ITEM_CODES params:updateBarcodeParam completionHandler:completionHandler];
    self.indPath = nil;
    self.indexPathforSelectedItem = nil;
    [self.tblviewInventory reloadData];
}

- (void)updateBarcodeToSwipedItemResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

                NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
                [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                NSString *barcodeItemCode = [NSString stringWithFormat:@"%ld", (long)updateBarcodeItemCode];
                [itemparam setValue:barcodeItemCode forKey:@"Code"];
                [itemparam setValue:@"" forKey:@"Type"];
                
                NSDictionary *barcodesDict = @{kRIMItemListWebServiceCallKey: barcodeItemCode};
                [Appsee addEvent:kRIMItemListWebServiceCall withProperties:barcodesDict];
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self responseUpdateBarcodeItemRimResponse:response error:error];
                    });
                };
                
                self.updateBarcodeItemInsertWC = [self.updateBarcodeItemInsertWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
            }
            else {
                
                NSDictionary *insertBarcodesDict = @{kRIMItemSwipeBarcodeWebServiceResponseKey: @"Item barcode(s) has not been updated."};
                [Appsee addEvent:kRIMItemSwipeBarcodeWebServiceResponse withProperties:insertBarcodesDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item barcode(s) has not been updated." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
    [self.tblviewInventory reloadData];
}

-(void)responseUpdateBarcodeItemRimResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            NSMutableArray *itemResponseArray = [responseDictionary valueForKey:@"ItemArray"];
            if(itemResponseArray.count > 0)
            {
                NSDictionary *itemDict = itemResponseArray.firstObject;
                if ([[[itemDict valueForKey:@"isDeleted"] stringValue] isEqualToString:@"1"]) // if deleted
                {
                }
                else // if not deleted than add to coredata
                {
                    [self.itemMgmtUpdateManager updateObjectsFromResponseDictionary:responseDictionary];
                    [self.itemMgmtUpdateManager linkItemToDepartmentFromResponseDictionary:responseDictionary];
                    [self.tblviewInventory reloadData];
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    
                    NSDictionary *barcodesDict = @{kRIMItemListWebServiceResponseKey: @"Item barcode(s) been updated successfully."};
                    [Appsee addEvent:kRIMItemListWebServiceResponse withProperties:barcodesDict];
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item barcode(s) been updated successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
            }
            else
            {
                NSDictionary *barcodesDict = @{kRIMItemListWebServiceResponseKey: @"Error occurs while updating barcode in item list."};
                [Appsee addEvent:kRIMItemListWebServiceResponse withProperties:barcodesDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Error occurs while updating barcode in item list." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}

- (void)removeExistingBarcodeBeforSendItToServerFromBarcodeArray:(NSMutableArray *)barcodeArray
{
    [self findAndRemoveExistingBarcode:singleItemBarcodesList newArray:barcodeArray];
    [self findAndRemoveExistingBarcode:caseBarcodesList newArray:barcodeArray];
    [self findAndRemoveExistingBarcode:packBarcodesList newArray:barcodeArray];
}

-(NSMutableArray *)findAndRemoveExistingBarcode:(NSMutableArray *)existingArray newArray:(NSMutableArray *)newArray
{
    for(int i = 0; i < existingArray.count ; i++)
    {
        for(int j = 0 ; j < newArray.count ; j++)
        {
            if([[existingArray[i] valueForKey:@"Barcode" ] isEqualToString:[newArray[j] valueForKey:@"Barcode" ] ])
            {
                [newArray removeObjectAtIndex:j];
                break;
            }
        }
    }
    return newArray;
}

- (void)selectItemData:(NSIndexPath *)indexPath
{
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    
    if([self.itemSelectModeArray containsObject:dictItemClicked])
    {
        [self.itemSelectModeArray removeObject:dictItemClicked];
        if(self.itemSelectModeArray.count > 0) {
            self.btnLabelPrint.enabled=YES;
        } else {
            self.btnLabelPrint.enabled=NO;
        }
    }
    else
    {
        [self.itemSelectModeArray addObject:dictItemClicked];
        self.btnLabelPrint.enabled=YES;
    }
    
    [self reloadItemRowsAtIndexPaths:@[indexPath]];
}

-(IBAction)selectModeOnoff:(id)sender
{
    [Appsee addEvent:kRIMFooterItemSelect];
    
    self.indexPathforSelectedItem = nil;
    self.indPath = nil;
    if(self.isLablePrintSelect)
    {
        [self removeSelectedItems];
        self.btnLabelPrint.enabled = NO;
        self.isLablePrintSelect = FALSE;
        [self.btnSelectMode setSelected:NO];
    }
    else
    {
        self.isLablePrintSelect=TRUE;
        [self.btnSelectMode setSelected:YES];
    }
    [self.tblviewInventory reloadData];
}

-(void)removeSelectedItems
{
    if(self.itemSelectModeArray.count == 0)
    {
        return;
    }
    [self.itemSelectModeArray removeAllObjects];
}

-(NSString *)getSelectedItemIDs
{
    NSMutableString *strResult = [NSMutableString string];
    for(int i=0;i<self.itemSelectModeArray.count;i++)
    {
        NSMutableDictionary *dict = (self.itemSelectModeArray)[i];
        NSString *ch = [dict valueForKey:@"ItemId"];
        [strResult appendFormat:@"%@,", ch];
    }
    NSString *strList = [strResult substringToIndex:strResult.length-1];
    return strList;
}

-(IBAction)lablePrintSelecteditems:(id)sender{
    [Appsee addEvent:kRIMFooterLablePrint];
    NSString *itemIdes = [self getSelectedItemIDs];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:itemIdes forKey:@"ItemCodes"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    [param setValue:@"LabelPrint" forKey:@"ProcessType"];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    [param setValue:strDateTime forKey:@"SelectedDate"];
    [param setValue:[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
    
    NSDictionary *dictItemSelected = @{kRIMFooterLablePrintWebServiceCallKey : @(self.itemSelectModeArray.count)};
    [Appsee addEvent:kRIMFooterLablePrintWebServiceCall withProperties:dictItemSelected];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseLabelPrintItemsResponse:response error:error];
        });
    };
    
    self.itemSelectedLabelWebservice = [self.itemSelectedLabelWebservice initWithRequest:KURL actionName:WSM_INSERT_IOS_ITEMS params:param completionHandler:completionHandler];

}

- (void)responseLabelPrintItemsResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self removeSelectedItems];
                
                self.btnLabelPrint.enabled=NO;
                [self.tblviewInventory reloadData];
                
                NSDictionary *dictLabelPrintResponse = @{kRIMFooterLablePrintWebServiceResponseKey : @"Print Successfull."};
                [Appsee addEvent:kRIMFooterLablePrintWebServiceResponse withProperties:dictLabelPrintResponse];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Print Successfull." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}


- (void)insertDidFinish {
}

- (void)callNotification
{
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)restoreItemSElectionForLabdelforIpad
{
    [self removeSelectedItems];
    [self.itemSelectModeArray removeAllObjects];
    [self.tblviewInventory reloadData];
    self.btnLabelPrint.enabled = NO;
    self.btnSelectMode.selected = NO;
    self.isLablePrintSelect = NO;
}

-(void)restoreItemSelectionforLabel{
    
    BOOL boolisfind=NO;
    
    NSArray *array  = self.navigationController.viewControllers;
    
    for(int i=0;i<array.count;i++)
    {
//        if([[array objectAtIndex:i]isKindOfClass:[InventoryManagement class]])
//        {
//            boolisfind=YES;
//        }
//        else if([[array objectAtIndex:i]isKindOfClass:[NewOrderScannerView class]])
//        {
//            boolisfind=NO;
//        }
//        else if([[array objectAtIndex:i]isKindOfClass:[InventoryOutScannerView class]])
//        {
//            boolisfind=NO;
//        }
    }
    
    if(!boolisfind)
    {
        [self.itemSelectModeArray removeAllObjects];
        [self.tblviewInventory reloadData];
        self.btnLabelPrint.enabled=NO;
        self.btnSelectMode.selected=NO;
        self.isLablePrintSelect=NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)logoutClicked:(id)sender
{
    [Appsee addEvent:kRIMFooterLogout];
    [self restoreItemSElectionForLabdelforIpad];
    [self uploadMissingBarcodeSearch];
//    [self.sideMenuVCDelegate willPopViewControllerAnimated:YES];
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

#pragma mark - Sorting Types

- (IBAction)descriptionSorting:(UIButton *)sender
{
    [Appsee addEvent:kRIMItemDescriptionSorting];
    [self.rmsDbController playButtonSound];
    self.sortColumn = @"item_Desc";
    self.isAscending = YES;
    if(isDiscripitionSort == TRUE)
    {
        [self setUpDownImageToSortingType:_img_description isSorting:isDiscripitionSort];
        self.isAscending = YES;
        isDiscripitionSort = FALSE;
    }
    else
    {
        [self setUpDownImageToSortingType:_img_description isSorting:isDiscripitionSort];
        self.isAscending = NO;
        isDiscripitionSort = TRUE;
    }
    self.itemResultsController = nil;
    [self.tblviewInventory reloadData];
}

- (IBAction)qtySorting:(id)sender
{
    [Appsee addEvent:kRIMItemQtySorting];
    [self.rmsDbController playButtonSound];
    self.sortColumn = @"item_InStock";
    if(isQtySort == TRUE)
    {
        [self setUpDownImageToSortingType:_img_qty isSorting:isQtySort];
        self.isAscending = YES;
        isQtySort = FALSE;
    }
    else
    {
        [self setUpDownImageToSortingType:_img_qty isSorting:isQtySort];
        self.isAscending = NO;
        isQtySort = TRUE;
    }
    self.itemResultsController = nil;
    [self.tblviewInventory reloadData];
}

- (IBAction)salesPriceSorting:(id)sender
{
    [Appsee addEvent:kRIMItemSalesPriceSorting];
    [self.rmsDbController playButtonSound];
    self.sortColumn = @"salesPrice";
    if(isPriceSort == TRUE)
    {
        [self setUpDownImageToSortingType:_img_Price isSorting:isPriceSort];
        self.isAscending = YES;
        isPriceSort = FALSE;
    }
    else
    {
        [self setUpDownImageToSortingType:_img_Price isSorting:isPriceSort];
        self.isAscending = NO;
        isPriceSort = TRUE;
    }
    self.itemResultsController = nil;
    [self.tblviewInventory reloadData];
}

-(void)setUpDownImageToSortingType:(UIImageView *)sortingType isSorting:(BOOL)isSorting
{
    _img_description.image = [UIImage imageNamed:@"RIM_List_Order_None"];
    _img_Price.image = [UIImage imageNamed:@"RIM_List_Order_None"];
    _img_qty.image = [UIImage imageNamed:@"RIM_List_Order_None"];
    
    if(isSorting)
    {
        sortingType.image = [UIImage imageNamed:@"RIM_List_Order_Ascending"];
    }
    else
    {
        sortingType.image = [UIImage imageNamed:@"RIM_List_Order_Descending"];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)inventoryLock {
    if (_inventoryLock == nil) {
        _inventoryLock = [[NSRecursiveLock alloc] init];
    }
    return _inventoryLock;
}

-(void)lockResultController
{
    [self.inventoryLock lock];
}

-(void)unlockResultController
{
    [self.inventoryLock unlock];
}

-(void)setItemResultsController:(NSFetchedResultsController *)resultController
{
    self.indexPathforSelectedItem = nil;
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.inventoryLock];
    __itemResultsController = resultController;
    [lock unlock];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
