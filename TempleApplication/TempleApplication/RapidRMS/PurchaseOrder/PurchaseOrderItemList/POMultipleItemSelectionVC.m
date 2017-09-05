//  InventoryManagement.m
//  I-RMS
//
//  Created by Siya Infotech on 09/08/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "POMultipleItemSelectionVC.h"
#import "UITableViewCell+NIB.h"
#import "InventoryCell.h"
#import "NewOrderScannerView.h"
#import "InventoryOutScannerView.h"
//#import "ItemInfoViewController.h"
#import "RmsDbController.h"
#import "POmenuListVC.h"
//#import "POmenuListVC_iPhone.h"

// CoreData Import
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "ItemTag+Dictionary.h"
#import "SizeMaster+Dictionary.h"
#import "GroupMaster+Dictionary.h"
#import "Mix_MatchDetail+Dictionary.h"
#import "Discount_Primary_MD.h"


//#import "InventoryAddNewSplitterVC.h"
#import "ItemInfoEditVC.h"
#import "ItemSupplier.h"
#import "CameraScanVC.h"
#import "Item_Price_MD+Dictionary.h"


#import "ItemInfoDataObject.h"
#import "RapidItemFilterVC.h"

@interface POMultipleItemSelectionVC ()<CameraScanVCDelegate,RapidItemFilterVCDeledate,UIGestureRecognizerDelegate>
{
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif

    BOOL flgViewControl;
    BOOL flgItemOperation;
    BOOL flgDonebutton;
    BOOL isScannerUsed;
    
    NSInteger deleteRecordId;
    
    NSString *strSwipeDire;
    NSMutableString *status;
    
    IntercomHandler *intercomHandler;
    Configuration *configuration;

    RapidItemFilterVC * objRapidItemFilterVC;
    NSPredicate * preCoustomeFilter;
}

@property (nonatomic, weak) IBOutlet UITextField *txtUniversalSearch;


@property (nonatomic, weak) IBOutlet UITableView *filterTypeTable;
@property (nonatomic, weak) IBOutlet UITableView *tblSuppFilter;
@property (nonatomic, weak) IBOutlet UITableView *tblviewInventory;

@property (nonatomic, weak) IBOutlet UIImageView *img1filter;
@property (nonatomic, weak) IBOutlet UIImageView *filterBorder;

@property (nonatomic, weak) IBOutlet UIButton *filterSuppButton;
@property (nonatomic, weak) IBOutlet UIButton *btn_Done;
@property (nonatomic, weak) IBOutlet UIButton *btnAddItem;
@property (nonatomic, weak) IBOutlet UIButton *filterButton;
@property (nonatomic, weak) IBOutlet UIButton *btn_ItemInfo;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnRapidFilterView;
@property (nonatomic, weak) IBOutlet UIView *viewFilterBG;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController *rimsController;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, strong) UpdateManager *itemMgmtUpdateManager;

@property (nonatomic, strong) RapidWebServiceConnection *poItemActiveWSC;
@property (nonatomic, strong) RapidWebServiceConnection *itemDeletedWC;
@property (nonatomic, strong) RapidWebServiceConnection *pOmgmtItemInsertWC;

@property (nonatomic, strong) NSMutableArray *arrTempSelected;
@property (nonatomic, strong) NSMutableArray *filterTypeArray;
@property (nonatomic, strong) NSMutableArray *suppliteFilter;

@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSString *strMainScanBarcode;
@property (nonatomic, strong) NSString *sortColumn;
@property (nonatomic, strong) NSString *sectionName;

@property (nonatomic, assign) BOOL checkCalledFunction;
@property (nonatomic, assign) BOOL redirectToCalledFun;

@property (nonatomic) BOOL isKeywordFilter;
@property (nonatomic) BOOL isSupplierFilter;
@property (nonatomic) BOOL isContinuousFiltering;
@property (nonatomic) BOOL isAscending;

@property (nonatomic, strong) NSIndexPath *indPath;
@property (nonatomic, strong) NSIndexPath *deleteIndexPath;
@property (nonatomic, strong) NSIndexPath *filterIndxPath;

@property (nonatomic, strong, readonly) NSFetchedResultsController *itemResultsController;
@property (nonatomic, strong) NSFetchedResultsController *allItemResultsController;
@property (nonatomic, strong) NSFetchedResultsController *previousItemResultsController;

@property (nonatomic, strong) NSRecursiveLock *poMultipleItemLock;

@end

@implementation POMultipleItemSelectionVC

@synthesize itemResultsController = _itemResultsController;
@synthesize allItemResultsController = _allItemResultsController;

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
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.itemDeletedWC = [[RapidWebServiceConnection alloc]init];
    self.pOmgmtItemInsertWC = [[RapidWebServiceConnection alloc]init];
    self.poItemActiveWSC = [[RapidWebServiceConnection alloc]init];
    // NAVIGATIONBAR_MACRO
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
    {
        self.navigationItem.title = @"Item Management";
        self.navigationItem.hidesBackButton=YES;
    }
    else
    {
        //self.navigationItem.hidesBackButton=YES;
    }
    // Do any additional setup after loading the view from its nib.
//    objMenubar=[[menuViewController alloc]initWithNibName:@"menuViewController" bundle:nil];
    self.rimsController.scannerButtonCalled = @"";
    
    self.itemMgmtUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    //self.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    //[self.managedObjectContext reset];
    self.filterTypeArray = [[NSMutableArray alloc] initWithObjects:@"ABC Shorting",@"Keyword",nil];
    //self.filterTypeTable.hidden = YES;
    self.filterTypeTable.layer.cornerRadius = 8.0;
    self.tblSuppFilter.layer.cornerRadius = 8.0;

    self.tblSuppFilter.backgroundColor = [UIColor colorWithRed:22.0/255.0 green:19.0/255.0 blue:36.0/255.0 alpha:1.0];
    self.filterTypeTable.backgroundColor = [UIColor redColor];

    if(self.objeNewSuppInfo)
    {
        NSString *strsupName = [self.objeNewSuppInfo valueForKey:@"SuppName"];
        if(strsupName.length>0){
             self.suppliteFilter = [[NSMutableArray alloc] initWithObjects:strsupName ,@"All",nil];
        }
        else{
            self.suppliteFilter = [[NSMutableArray alloc] initWithObjects:@"All",nil];
        }
        //self.filterTypeTable.hidden = YES;
        self.tblSuppFilter.layer.borderWidth = 1;
        self.tblSuppFilter.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.tblSuppFilter.hidden=YES;
        if(strsupName.length>0){
            self.isSupplierFilter=NO;
        }
        else{
            self.isSupplierFilter=NO;

        }
       
        
        self.filterTypeTable.hidden=YES;
        self.filterSuppButton.frame=self.filterButton.frame;
        self.filterBorder.frame=self.img1filter.frame;
        [self.filterButton setHidden:YES];
        [self.img1filter setHidden:YES];

    }
    else
    {
        [self.tblSuppFilter setHidden:YES];
        [self.filterBorder setHidden:YES];
        [self.filterSuppButton setHidden:YES];
        self.isSupplierFilter=NO;
    }
    self.sortColumn = @"item_Desc";
    self.sectionName = @"sectionLabel";
    self.isAscending = YES;
    
    // From loadItemDataInTable
    self.checkCalledFunction=TRUE;
    flgViewControl=TRUE;
    flgItemOperation=TRUE;
#ifdef LINEAPRO_SUPPORTED
    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [dtdev connect];
    
#endif

    status=[[NSMutableString alloc] init];
    
    if([self.rimsController.scannerButtonCalled isEqualToString:@""])
    {
        self.rimsController.scannerButtonCalled=@"poMultipleItemSelection";
    }
    
    flgDonebutton=FALSE;
    
    self.deleteIndexPath = [[NSIndexPath alloc] init];
    self.arrTempSelected = [[NSMutableArray alloc] init];
    
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
    
    //[self loadItemDataInTable];
    
    self.btnAddItem.enabled=NO;
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    self.tblviewInventory.separatorColor = [UIColor clearColor];
}

- (void)contextHasChanged:(NSNotification*)notification
{
    NSManagedObjectContext *changedContext = notification.object;
    NSManagedObjectContext *parentContext = nil;
    
    // Get parent context
    for (NSManagedObjectContext *aContext = self.managedObjectContext; aContext != nil; aContext = aContext.parentContext) {
        if (aContext.parentContext == nil) {
            break;
        }
        parentContext = aContext.parentContext;
    }
    
    // Ignore it.
    if (![changedContext isEqual:parentContext]) return;
    
    // This is not main thread
    if (![NSThread isMainThread]) {
        // Merge should be performed on main thread
        [self performSelectorOnMainThread:@selector(contextHasChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    // Merge changes
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    
    // Save changes
    [self saveContext];
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
        self.isContinuousFiltering = TRUE;
        self.txtUniversalSearch.placeholder = @"ABC Shorting";
        self.filterTypeTable.hidden = YES;
        self.filterIndxPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else
    {
        self.rmsDbController.rimSelectedFilterType = @"Keyword";
        self.isKeywordFilter = TRUE;
        self.isContinuousFiltering = FALSE;
        self.txtUniversalSearch.placeholder = @"UPC, ITEM #, DESCRIPTION, DEPARTMENT, etc..";
        self.filterTypeTable.hidden = YES;
        self.filterIndxPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    [self.tblSuppFilter reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    //NAVIGATIONBAR_MACRO
    [super viewWillAppear:animated];
    
    self.checkSearchRecord = TRUE;
    isScannerUsed = FALSE;
    
    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    self.rimsController.scannerButtonCalled = @"poMultipleItemSelection";
    
    [self checkItemFilterType];
    
    //    self.itemResultsController = nil;
    //    [self.tblviewInventory reloadData];
    
    [self checkConnectedScannerType];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.navigationItem.title = @"Item Management";
        
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
        
        self.navigationItem.hidesBackButton=YES;
    }
    else{
        [self.navigationController.navigationBar setHidden:YES];
    }
    //    NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    //    [tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    
    [self addFilterView];
}

-(void)resetTableViewData
{
    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    self.rimsController.scannerButtonCalled = @"poMultipleItemSelection";
}

-(IBAction)btn_back:(id)sender
{
    //hiten
    [self cancelClick:nil];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        NSArray *viewcon = self.navigationController.viewControllers;
        for(UIViewController *tempcon in viewcon){
            if([tempcon isKindOfClass:[POmenuListVC class]])
            {
                [self.navigationController popToViewController:tempcon animated:YES];
                return;
            }
        }
    }
    [self.rmsDbController playButtonSound];
    [self.navigationController popViewControllerAnimated:NO];
}

-(IBAction)btn_New:(id)sender
{
    [self.rmsDbController playButtonSound];
//    NSArray *arryView = [self._rimController.objInvHome.navigationController viewControllers];
//    
//    for(int i=0;i<[arryView count];i++){
//        
//        UIViewController *viewCon = [arryView objectAtIndex:i];
//        if([viewCon isKindOfClass:[InventoryManagement class]]){
//            [self._rimController.objInvHome.navigationController popToViewController:viewCon animated:YES];
//        }
//    }
//    
    self.rimsController.scannerButtonCalled = @"poMultipleItemSelection";
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        ItemInfoEditVC *objAddNew = [[ItemInfoEditVC alloc] initWithNibName:@"ItemInfoEditVC" bundle:nil];
        [self.navigationController pushViewController:objAddNew animated:YES];
    }
    else
    {
//        [self._rimController.objSideMenuiPad showInventoryAddNew:nil];
    }
}

#pragma mark - UniversalItemSearch

-(NSPredicate *)searchPredicateForText:(NSString *)searchData
{
    
    BOOL isNumeric;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:searchData];
    isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) // numeric
    {
        searchData = [self.rmsDbController trimmedBarcode:searchData];
    }

    NSMutableArray *textArray=[[searchData componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;
    if(self.isKeywordFilter)
    {
        // For - Filter the when I click "return" or "search button" - Keyword
        dbFields = @[ @"item_Desc contains[cd] %@",@"item_No == %@", @"barcode BEGINSWITH[cd] %@", @"item_Remarks BEGINSWITH[cd] %@",@"itemDepartment.deptName BEGINSWITH[cd] %@",@"ANY itemTags.tagToSizeMaster.sizeName contains[cd] %@"];
    }
    else
    {
        // For - Filter the item list as I type the keywords - ABC Shorting
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
        
        NSPredicate *predicate;
        if ([self isSubDepartmentEnableInBackOffice]) {
            predicate = [NSPredicate predicateWithFormat:@"active == %d AND isNotDisplayInventory == %@",TRUE,@(0)];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"active == %d AND isNotDisplayInventory == %@ AND itm_Type != %@",TRUE,@(0),@(2)];
        }

        [fieldWisePredicates addObject:predicate];
    }
    if (preCoustomeFilter) {
        [fieldWisePredicates addObject:preCoustomeFilter];
    }
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
    return finalPredicate;
}

/*-(IBAction)btn_UniversalItemSearch:(id)sender
 {
 if(self.isKeywordFilter)
 {
 if(self.txtUniversalSearch.text.length > 0)
 {
 NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
 [self.rmsDbController playButtonSound];
 [txtUniversalSearch resignFirstResponder];
 [tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
 self.searchText = txtUniversalSearch.text;
 _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 [self reloadInventoryMgmtTable];
 });
 }
 }
 }*/

-(IBAction)btn_UniversalItemSearch:(id)sender
{
    NSDictionary *searchDict = @{kPOMultipleItemSelectionSearchKey : self.txtUniversalSearch.text};
    [Appsee addEvent:kPOMultipleItemSelectionSearch withProperties:searchDict];
    if(self.isKeywordFilter)
    {
        if(self.txtUniversalSearch.text.length > 0)
        {
            NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.rmsDbController playButtonSound];
            [self.txtUniversalSearch resignFirstResponder];
            
            if (self.itemResultsController.sections.count > 0) {
                [self.tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
            }
            
            self.searchText = self.txtUniversalSearch.text;
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

-(IBAction)synchronize24HoursClickedFromME:(id)sender
{
    [self.rmsDbController playButtonSound];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseCompleteSyncDataFromME:) name:@"CompleteSyncData" object:nil];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [self.rmsDbController startSynchronizeUpdate:3600*24];
}

-(void)responseCompleteSyncDataFromME:(NSNotification *)notification
{
    [_activityIndicator hideActivityIndicator];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteSyncData" object:nil];
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
    [objRapidItemFilterVC filterViewSlideIn:FALSE];
    self.btnRapidFilterView.selected = FALSE;
    self.filterTypeTable.hidden = YES;
}

/*-(BOOL) textFieldShouldReturn:(UITextField *)textField
 {
 if(self.isKeywordFilter)
 {
 if(textField == txtUniversalSearch)
 {
 if(txtUniversalSearch.text.length > 0)
 {
 NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
 [tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
 
 _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 self.searchText = txtUniversalSearch.text;
 self.itemResultsController = nil;
 //hiten
 NSArray *sections = [self.itemResultsController sections];
 if(sections.count > 0)
 {
 [self.tblviewInventory reloadData];
 }
 [_activityIndicator hideActivityIndicator];
 });
 //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 //[self reloadInventoryMgmtTable];
 //});
 }
 }
 }
 [textField resignFirstResponder];
 return YES;
 }*/

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSDictionary *searchDict = @{kPOMultipleItemSelectionSearchKey : self.txtUniversalSearch.text};
    [Appsee addEvent:kPOMultipleItemSelectionSearch withProperties:searchDict];
    if(self.isKeywordFilter)
    {
        if(textField == self.txtUniversalSearch)
        {
            if(self.txtUniversalSearch.text.length > 0)
            {
                
                if (self.itemResultsController.sections.count > 0) {
                
                NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                }
                
//                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.searchText = self.txtUniversalSearch.text;
                    self.itemResultsController = nil;
                    //hiten
                    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
                    
                    NSArray *sections = self.itemResultsController.sections;
                    if(sections.count > 0)
                    {
                        [self.tblviewInventory reloadData];
                    }
                    else
                    {
                        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                        {};
                        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"No item found for %@",self.txtUniversalSearch.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                        self.itemResultsController = self.previousItemResultsController;
                    }
                    
//                    [_activityIndicator hideActivityIndicator];
                });
            }
        }
    }
    [textField resignFirstResponder];
    return YES;
}

// Clear text field and Load all data (when click to x button of textfield)

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    [Appsee addEvent:kPOMultipleItemSelectionSearchClear];
    textField.text = @"";
    self.searchText = @"";
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
    [self.tblviewInventory scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self checkItemFilterType];
    [self checkConnectedScannerType];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self reloadInventoryMgmtTable];
        
        [self reloadAllItems];
    });
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(!self.isKeywordFilter)
    {
        if(self.isContinuousFiltering)
        {
            if(textField == self.txtUniversalSearch)
            {
                NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
                if (textField.text.length == 1 && [string isEqualToString:@""]) {
                    self.searchText = @"";
                }
                else if(searchString.length > 0)
                {
                     if (self.itemResultsController.sections.count > 0) {
                        NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
                        [self.tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                    }
                    self.searchText = searchString;
                }
                else
                {
                    self.searchText = @"";
                }
                //                [self reloadInventoryMgmtTable];
                self.itemResultsController = nil;
                //hiten
                NSArray *sections = self.itemResultsController.sections;
                if(sections.count > 0)
                {
                    [self.tblviewInventory reloadData];
                }
                [_activityIndicator hideActivityIndicator];
            }
            return YES;
        }
        return YES;
    }
    else
    {
        return YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.filterTypeTable.hidden = YES;
}

-(IBAction)SupplierFilterButtonClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self.txtUniversalSearch resignFirstResponder];
    self.tblSuppFilter.hidden = NO;
    self.filterTypeTable.hidden = YES;
}


-(IBAction)filterButtonClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self.txtUniversalSearch resignFirstResponder];
    self.filterTypeTable.hidden = NO;
    self.tblSuppFilter.hidden = YES;
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tblviewInventory)
    {
        NSArray *sections = self.itemResultsController.sections;
        return sections.count;
    }
    else if (tableView == self.filterTypeTable)
    {
        return 1;
    }
    else if (tableView == self.tblSuppFilter)
    {
        return 1;
    }
    else
    {
        return 1;
    }
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
    if (tableView == self.tblviewInventory)
    {
        return 0;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView == self.tblviewInventory)
    {
        return 0;
    }
    else
    {
        return 0;
    }
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
    else if (tableView == self.filterTypeTable)
    {
        return self.filterTypeArray.count;
    }
    else if (tableView == self.tblSuppFilter)
    {
        return self.suppliteFilter.count;
    }
    else
    {
        return 1;
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblviewInventory)
    {
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            return 125;
        }
        else
        {
            return 73;
        }
    }
    else
    {
        return 44;
    }
}

- (void)itemSwipeMethod:(InventoryCell *)cell_p indexPath:(NSIndexPath *)indexPath
{
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [cell_p addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell_p addGestureRecognizer:gestureLeft];
    
    if(indexPath.section == self.indPath.section && indexPath.row == self.indPath.row)
    {
        cell_p.viewOperation.frame = CGRectMake(0, cell_p.viewOperation.frame.origin.y, cell_p.viewOperation.frame.size.width, cell_p.viewOperation.frame.size.height);
        cell_p.viewOperation.hidden = NO;
    }
    else
    {
        cell_p.viewOperation.frame = CGRectMake(320.0, cell_p.viewOperation.frame.origin.y, cell_p.viewOperation.frame.size.width, cell_p.viewOperation.frame.size.height);
        cell_p.viewOperation.hidden = YES;
    }
}

- (void)setCellDefaultBackGroundImage:(InventoryCell *)cellItem
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        cellItem.imgBackGround.image = [UIImage imageNamed:@"ListBg_iphone.png"];
    }
    else
    {
        cellItem.imgBackGround.image = [UIImage imageNamed:@"ListBg_ipad.png"];
    }
}

- (UITableViewCell *)configureItemCell:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InventoryItemCustomCell";
    InventoryCell *cellItem = [self.tblviewInventory dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    NSDictionary *itemDictionary = anItem.itemRMSDictionary;
    
    // check cell value
    if (cellItem == nil)
    {
        NSArray *nib;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            nib = [[NSBundle mainBundle] loadNibNamed:@"InventoryCell" owner:self options:nil];
        }
        else
        {
            nib = [[NSBundle mainBundle] loadNibNamed:@"POInventoryCell_iPad" owner:self options:nil];
        }
        cellItem = nib.firstObject;
    }
    else // to delete existing AsyncImageView image while tableview scrolling and reloading
    {
    }
    cellItem.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSMutableArray * itemMixMatchDiscArray = [[NSMutableArray alloc]init];
    for (Discount_Primary_MD *idiscMd1 in anItem.primaryItemDetail )
    {
        [itemMixMatchDiscArray addObject:idiscMd1];
    }
    if (itemMixMatchDiscArray.count > 0 && itemMixMatchDiscArray != nil) {
        cellItem.imgIsDiscount.image = [UIImage imageNamed:@"RIM_Item_Discount_cell"];

    }
    else{
        cellItem.imgIsDiscount.image = nil;

    }
    [self setCellDefaultBackGroundImage:cellItem];
   
    // show Image for each item in cell
    NSString *itemImageURL = itemDictionary[@"ItemImage"];
    
    if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        NSString *imgString = @"noimage.png";
        cellItem.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    }
    else if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<null>"])
    {
        NSString *imgString = @"noimage.png";
        cellItem.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    }
    else
    {
        [cellItem.itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",itemImageURL]]];
    }
    cellItem.itemImage.layer.cornerRadius = 10.0;
    cellItem.itemImage.layer.masksToBounds = YES;
    cellItem.lblInventoryName.text = itemDictionary[@"ItemName"];
  
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",[itemDictionary[@"DepartId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *departmentList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (departmentList.count>0)
    {
        Department *department=departmentList.firstObject;
        cellItem.lblDepartment.text = department.deptName;
    }
    else
    {
        cellItem.lblDepartment.text = @"";
    }

    
    cellItem.lblBarcode.text = itemDictionary[@"Barcode"];
    cellItem.lblBarcode.textColor = [UIColor blackColor];
    
    cellItem.lblItemNumber.text = itemDictionary[@"ItemNo"];
    
    cellItem.txtPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:[itemDictionary[@"SalesPrice"] floatValue]]];
    
    cellItem.txtCost.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:[itemDictionary[@"CostPrice"]floatValue]]];

    
    NSMutableArray * itemDiscArray = [[NSMutableArray alloc]init];
    for (Item_Discount_MD *idiscMd in anItem.itemToDisMd )
    {
        [itemDiscArray addObjectsFromArray:idiscMd.mdTomd2.allObjects];
    }
    Item_Discount_MD2 *idiscMd2=nil;
    
    if(itemDiscArray.count>0)
    {
        for (int idisc=0; idisc<itemDiscArray.count; idisc++)
        {
            idiscMd2 = itemDiscArray[idisc];
            NSInteger iDiscqty = idiscMd2.md2Tomd.dis_Qty.integerValue;
            if(idiscMd2.dayId.integerValue == -1 && iDiscqty == 1)
            {
                cellItem.txtPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:idiscMd2.md2Tomd.dis_UnitPrice.floatValue]];
                cellItem.txtPrice.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
                cellItem.imgIsDiscount.image = [UIImage imageNamed:@"RIM_Item_Discount_cell"];
            }
            else if(idiscMd2.dayId.integerValue >= -1 && idiscMd2.dayId.integerValue <= 7)
            {
                cellItem.txtPrice.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
                cellItem.imgIsDiscount.image = [UIImage imageNamed:@"RIM_Item_Discount_cell"];
            }
        }
    }
    else
    {
        NSString *iCostPrice = [NSString stringWithFormat:@"%.2f",[itemDictionary[@"CostPrice"] floatValue]];
        NSString *isalesPrice = [NSString stringWithFormat:@"%.2f",[itemDictionary[@"SalesPrice"] floatValue]];
        float CostPrice = iCostPrice.floatValue;
        float SPrice = isalesPrice.floatValue;
        if (CostPrice > SPrice)
        {
            cellItem.txtPrice.textColor = [UIColor redColor];
        }
    }
    
    cellItem.qtyBackgroundImage.layer.borderWidth = 1.0 ;
    cellItem.qtyBackgroundImage.layer.borderColor = [UIColor blackColor].CGColor ;


    cellItem.txtQty.text = [NSString stringWithFormat:@"%@",itemDictionary[@"avaibleQty"]];
    cellItem.txtQty.textColor = [UIColor blackColor];

    
    NSInteger minLevel = [itemDictionary[@"MinStockLevel"] integerValue];
    NSInteger availableQty = [itemDictionary[@"avaibleQty"] integerValue];
    if (minLevel >= 0)
    {
        if (availableQty <= minLevel)
        {
            cellItem.txtQty.textColor = [UIColor redColor];
        }
    }
    NSString *itemCode = itemDictionary[@"ItemId"];

    
    if(availableQty != 0)
    {
        Item *anItem = [self fetchAllItems:itemCode];
        NSMutableArray *itemPricingArray = [[NSMutableArray alloc]init];
        for (Item_Price_MD *pricing1 in anItem.itemToPriceMd)
        {
            NSMutableDictionary *pricingDict = [[NSMutableDictionary alloc]init];
            pricingDict[@"PriceQtyType"] = pricing1.priceqtytype;
            pricingDict[@"Qty"] = pricing1.qty;
            [itemPricingArray addObject:pricingDict];
        }
        
        NSPredicate *casePredicate = [NSPredicate predicateWithFormat:@"PriceQtyType = %@ AND Qty != 0" , @"Case"];
        NSArray *isCaseResult = [itemPricingArray filteredArrayUsingPredicate:casePredicate];
        NSString *caseValue;
        if(isCaseResult.count > 0)
        {
            NSString *caseQty  = [NSString stringWithFormat:@"%ld",(long)[[isCaseResult[0] valueForKey:@"Qty"] integerValue ]];
            float result = cellItem.txtQty.text.floatValue/caseQty.floatValue;
            NSString *cq = [self getValueBeforeDecimal:result];
            NSInteger y = cellItem.txtQty.text.integerValue % caseQty.integerValue;
            y = labs(y);
            caseValue = [NSString stringWithFormat:@"%@.%ld",cq,(long)y];
        }
        else
        {
            caseValue = @"-";
        }
        
        NSPredicate *packPredicate = [NSPredicate predicateWithFormat:@"PriceQtyType = %@ AND Qty != 0" , @"Pack"];
        NSArray *ispackResult = [itemPricingArray filteredArrayUsingPredicate:packPredicate];
        NSString *packValue;
        if(ispackResult.count > 0)
        {
            NSString *caseQty  = [NSString stringWithFormat:@"%ld",(long)[[ispackResult[0] valueForKey:@"Qty"] integerValue ]];
            float result = cellItem.txtQty.text.floatValue/caseQty.floatValue;
            NSString *pq = [self getValueBeforeDecimal:result];
            NSInteger x = cellItem.txtQty.text.integerValue % caseQty.integerValue;
            x = labs(x);
            packValue = [NSString stringWithFormat:@"%@.%ld",pq,(long)x];
        }
        else
        {
            packValue = @"-";
        }
        
        if(([caseValue isEqualToString:@"-"]) && ([packValue isEqualToString:@"-"]))
        {
            cellItem.txtCasePackValue.text = @"";
        }
        else if ([packValue isEqualToString:@"-"]) // Pack value not available
        {
            cellItem.txtCasePackValue.text = [NSString stringWithFormat:@"%@ / -",caseValue];
        }
        else if ([caseValue isEqualToString:@"-"]) // Case value not available
        {
            cellItem.txtCasePackValue.text = [NSString stringWithFormat:@"- / %@",packValue];
        }
        else
        {
            cellItem.txtCasePackValue.text = [NSString stringWithFormat:@"%@ / %@",caseValue , packValue];
        }
    }

    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        cellItem.txtQty.layer.cornerRadius = 5;
        CGRect frameRect = cellItem.txtQty.frame;
        frameRect.size.height = 25;
        cellItem.txtQty.frame = frameRect;
    }
    // Add Right arrow to selected Record.
    if([self.arrTempSelected containsObject:itemDictionary])
    {
        (cellItem.imgBackGround).image = [UIImage imageNamed:@"ListHoverAndActive_ipad.png"];
        cellItem.imgSelected.image = [UIImage imageNamed:@"radioMulti_selected.png"];
    }
    else
    {
        [self setCellDefaultBackGroundImage:cellItem];
        cellItem.imgSelected.image = [UIImage imageNamed:@"radiobtn.png"];
    }
//    if([[itemDictionary objectForKey:@"selected"] isEqualToString:@"1"])
//    {
//        [cellItem.imgBackGround setImage:[UIImage imageNamed:@"ListHoverAndActive_ipad.png"]];
//        cellItem.imgSelected.image = [UIImage imageNamed:@"img_add.png"];
//    }
//    else
//    {
//        [self setCellDefaultBackGroundImage:cellItem];
//        cellItem.imgSelected.image = nil;
//    }
    
    cellItem.btnCopy.tag = indexPath.section;
    [cellItem.btnCopy addTarget:self action:@selector(copyItem:) forControlEvents:UIControlEventTouchUpInside];
    
    cellItem.btnDelete.tag = indexPath.section;
    [cellItem.btnDelete addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    
    if(!self.checkSearchRecord)
    {
        [self itemSwipeMethod:cellItem indexPath:indexPath];
    }
    return cellItem;
}

- (NSString *)getValueBeforeDecimal:(float)result
{
    NSNumber *numberValue = @(result);
    NSString *floatString = numberValue.stringValue;
    NSArray *floatStringComps = [floatString componentsSeparatedByString:@"."];
    NSString *cq = [NSString stringWithFormat:@"%@",floatStringComps.firstObject];
    return cq;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell.backgroundColor = [UIColor clearColor];
    if(tableView == self.tblviewInventory)
    {
        cell = [self configureItemCell:indexPath];
    }
    
    if(tableView == self.filterTypeTable && self.filterTypeTable.hidden == YES)
    {
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        UITableViewCell *filterCell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"filterCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        filterCell.textLabel.font = [UIFont fontWithName:@"Lato" size:14];
        filterCell.textLabel.text = (self.filterTypeArray)[indexPath.row];
        [[self.view viewWithTag:232323] removeFromSuperview];
        if ([indexPath isEqual:self.filterIndxPath])
        {
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(150, 14, 22, 16)];
            imgView.tag = 232323;
            imgView.image = [UIImage imageNamed:@"soundCheckMark.png"];
            [filterCell.contentView addSubview:imgView];
        }
        else
        {
            [filterCell.imageView setImage:nil];
        }
        cell = filterCell;
    }
    else if(tableView == self.tblSuppFilter)
    {
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        UITableViewCell *filterCell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"filterCell"];
        filterCell.selectionStyle = UITableViewCellSelectionStyleNone;
        filterCell.backgroundColor = [UIColor clearColor];

        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(20.0, 0.00, 120.0, 45.0)];
        lable.font = [UIFont fontWithName:@"Lato" size:13];
        lable.text = (self.suppliteFilter)[indexPath.row];
        lable.textColor = [UIColor whiteColor];
        [filterCell addSubview:lable];
        
        [[filterCell viewWithTag:2121] removeFromSuperview];
        if (self.isSupplierFilter && indexPath.row == 0) {
        lable.textColor = [UIColor colorWithRed:253.0/255.0 green:143.0/255.0 blue:17.0/255.0 alpha:1.0];
        }
        else if([(self.suppliteFilter)[indexPath.row] isEqualToString:@"All"] && !self.isSupplierFilter) {
        lable.textColor = [UIColor colorWithRed:253.0/255.0 green:143.0/255.0 blue:17.0/255.0 alpha:1.0];
        }
        cell = filterCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblviewInventory) {
        if(!(self.checkSearchRecord))
        {
            if(self.checkCalledFunction)
            {
                if ((flgViewControl))
                {
                    InventoryCell *cell = (InventoryCell *)[tableView cellForRowAtIndexPath:indexPath];
                    cell.imgBackGround.image = [UIImage imageNamed:@"ListHoverAndActive_ipad.png"];
                    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self getClickedItemData:indexPath];
                        [self setCellDefaultBackGroundImage:cell];
                    });
                }
            }
        }
        else
        {
            Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
//            if (anItem.is_Selected.boolValue) {
//                anItem.is_Selected = @(NO);
//            } else {
//                anItem.is_Selected = @(YES);
//            }
            
            NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
            
            if([self.arrTempSelected containsObject:dictItemClicked])
            {
                [self.arrTempSelected removeObject:dictItemClicked];
                if(self.arrTempSelected.count > 0) {
                    flgDonebutton=TRUE;
                }
                else {
                    flgDonebutton = FALSE;
                }
            }
            else
            {
                [self.arrTempSelected addObject:dictItemClicked];
                flgDonebutton=TRUE;
            }
            
            
            NSArray *indexpaths = @[indexPath];
            if(tableView.indexPathsForVisibleRows.count>0){

                [self.tblviewInventory reloadRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            if(flgDonebutton)
            {
                self.btn_Done.hidden=NO;
                self.btnAddItem.enabled=YES;
            }
            else
            {
                self.btn_Done.hidden=YES;
                self.btnAddItem.enabled=NO;
            }
        }
    }
    else if (tableView == self.filterTypeTable)
    {
        self.filterIndxPath = indexPath;
        [self.rmsDbController playButtonSound];
        if(indexPath.row == 0)
        {
            self.rmsDbController.rimSelectedFilterType = @"ABC Shorting";
            self.isKeywordFilter = FALSE;
            self.isContinuousFiltering = TRUE;
            self.txtUniversalSearch.placeholder = @"ABC Shorting";
            self.filterTypeTable.hidden = YES;
        }
        else if (indexPath.row == 1)
        {
            self.rmsDbController.rimSelectedFilterType = @"Keyword";
            self.isKeywordFilter = TRUE;
            self.isContinuousFiltering = FALSE;
            self.txtUniversalSearch.placeholder = @"UPC, ITEM #, DESCRIPTION, DEPARTMENT, etc..";
            self.filterTypeTable.hidden = YES;
        }
        NSDictionary *searchTypeDict = @{kPOMultipleItemSelectionSearchTypeKey : self.rmsDbController.rimSelectedFilterType};
        [Appsee addEvent:kPOMultipleItemSelectionSearchType withProperties:searchTypeDict];
        if((self.txtUniversalSearch.text.length > 0) || (self.searchText.length > 0))
        {
            self.txtUniversalSearch.text = @"";
            self.searchText = @"";
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
              if (self.itemResultsController.sections.count > 0) {
                NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
             }
            [self reloadInventoryMgmtTable];
        }
        [self checkConnectedScannerType];
    }
    else if (tableView == self.tblSuppFilter)
    {
        if(indexPath.row == 0)
        {
            if([(self.suppliteFilter)[indexPath.row] isEqualToString:@"All"]){
                
                self.isSupplierFilter=NO;
                self.txtUniversalSearch.text = @"";
                self.searchText = @"";
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                [self reloadAllItems];
                 if (self.itemResultsController.sections.count > 0) {
                    NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                }
                [self.tblSuppFilter setHidden:YES];
            }
            else{
                
                self.isSupplierFilter=YES;
                self.txtUniversalSearch.text = @"";
                self.searchText = @"";
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                [self reloadInventoryMgmtTable];
                
                 if (self.itemResultsController.sections.count > 0) {
                    NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                }
               
                [self.tblSuppFilter setHidden:YES];
            }
            
        }
        else{
            
            self.isSupplierFilter=NO;
            self.txtUniversalSearch.text = @"";
            self.searchText = @"";
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            [self reloadAllItems];
             if (self.itemResultsController.sections.count > 0) {
                NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
            }
            [self.tblSuppFilter setHidden:YES];
            
        }
        [self.tblSuppFilter reloadData];
    }
    
}

- (void)getClickedItemData:(NSIndexPath *)indexPath
{
    [self.rmsDbController playButtonSound];
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
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
    if(flgItemOperation)
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            ItemInfoEditVC *objAddNew = [[ItemInfoEditVC alloc] initWithNibName:@"ItemInfoEditVC" bundle:nil];
            objAddNew.managedObjectContext = self.rmsDbController.managedObjectContext;
            objAddNew.isCopy=TRUE;
            objAddNew.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
//            objAddNew.itemInfoDataObject.dictGetItemData = dictItemClicked;
            [objAddNew.itemInfoDataObject setItemMainDataFrom:dictItemClicked];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.navigationController pushViewController:objAddNew animated:YES];
        }
        else
        {
        }
    }
    else
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            ItemInfoEditVC *objAddNew = [[ItemInfoEditVC alloc] initWithNibName:@"ItemInfoEditVC" bundle:nil];
            objAddNew.managedObjectContext = self.rmsDbController.managedObjectContext;
            objAddNew.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
//            objAddNew.itemInfoDataObject.dictGetItemData = dictItemClicked;
            [objAddNew.itemInfoDataObject setItemMainDataFrom:dictItemClicked];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.navigationController pushViewController:objAddNew animated:YES];
        }
        else
        {
//            [self._rimController.objSideMenuiPad showInventoryAddNew:(NSMutableDictionary *)anItem];
        }
    }
}

- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
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
    NSDictionary *selectedDict = @{kPOMultipleItemSelectionDoneKey : @(self.arrTempSelected.count)};
    [Appsee addEvent:kPOMultipleItemSelectionDone withProperties:selectedDict];
    [self.rmsDbController playButtonSound];
//    for(int isfnd = 0 ; isfnd < [self.arrTempSelected count] ; isfnd++)
//    {
//        NSMutableDictionary *dictSelected = [[self.arrTempSelected objectAtIndex:isfnd] mutableCopy];
//        Item *anItem = [self fetchAllItems:[dictSelected valueForKey:@"ItemId"]];
//        anItem.is_Selected = @(NO);
//    }
    
    self.btn_Done.hidden=YES;
    flgDonebutton = NO;
    self.checkSearchRecord = FALSE;
    int recordCount = 0 ;
    if (self.pOMultipleItemSelectionVCDelegate) {
        if (self.objNewItemReceiveList) {
            [self.navigationController popViewControllerAnimated:FALSE];
        }
        else if (self.navigationController) {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                [self.navigationController popViewControllerAnimated:TRUE];
            }
            else {
                [self.navigationController popViewControllerAnimated:FALSE];
            }
        }
        else{
            [self.pOMultipleItemSelectionVCDelegate didSelectionChangeInPOMultipleItemSelectionVC:self.arrTempSelected];
            [self dismissViewControllerAnimated:false completion:nil];

//            [self.view removeFromSuperview];
            return;
        }
        [self.pOMultipleItemSelectionVCDelegate didSelectionChangeInPOMultipleItemSelectionVC:self.arrTempSelected];
        return;
    }
    if(self.flgRedirectToGenerateOdr) // redirect to Generate Order
    {

    }
    else if(self.flgRedirectToOpenList) // redirect to OpenListView Order
    {
//        for(int i=0;i<[self.arrTempSelected count];i++)
//        {
//            NSMutableDictionary *dictSelected = [[self.arrTempSelected objectAtIndex:i]mutableCopy];
//            if([dictSelected  valueForKey:@"selected"])
//            {
//                //recordCount +=1;
//                
//                // removed unnecessery object from array
//                [dictSelected removeObjectForKey:@"AddedQty"];
//                [dictSelected removeObjectForKey:@"DepartId"];
//                [dictSelected removeObjectForKey:@"DepartmentName"];
//                [dictSelected removeObjectForKey:@"ItemDiscount"];
//                [dictSelected removeObjectForKey:@"ItemImage"];
//                [dictSelected removeObjectForKey:@"ItemSupplierData"];
//                [dictSelected removeObjectForKey:@"ItemTag"];
//                [dictSelected removeObjectForKey:@"MaxStockLevel"];
//                [dictSelected removeObjectForKey:@"MinStockLevel"];
//                [dictSelected removeObjectForKey:@"selected"];
//                [dictSelected removeObjectForKey:@"ItemNo"];
//                
//                [dictSelected removeObjectForKey:@"EBT"];
//                [dictSelected removeObjectForKey:@"NoDiscountFlg"];
//                [dictSelected removeObjectForKey:@"POSDISCOUNT"];
//                [dictSelected removeObjectForKey:@"TaxType"];
//                [dictSelected removeObjectForKey:@"isTax"];
//                [dictSelected removeObjectForKey:@"Remark"];
//                
//                [dictSelected setValue:@"0" forKey:@"FreeGoodsQty"];
//                [dictSelected setValue:@"0" forKey:@"ReOrder"];
//                
//                [objOpenList.arrPendingDeliveryData insertObject:dictSelected atIndex:0];
//            }
//        }
        // int tmprow = objInventoryCount.indPath.row;
        // if(tmprow > -1)
        // {
        //      objGenerateOdr.indPath=[NSIndexPath indexPathForRow:tmprow + recordCount inSection:0];
        // }
//        [self.arrTempSelected removeAllObjects];
//        self.checkSearchRecord=FALSE;
//        flgRedirectToOpenList = FALSE;
//        [objOpenList.tblPendingDeliveryData reloadData];
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else
//        {
////            [self._rimController.objPOMenuList showViewFromViewController:objOpenList];
//        }
//    }
//    else if(objDeliveryScane){
//        
//        for(int i=0;i<[self.arrTempSelected count];i++)
//        {
//            NSMutableDictionary *dictSelected = [[self.arrTempSelected objectAtIndex:i]mutableCopy];
//            if([dictSelected  valueForKey:@"selected"])
//            {
//                //recordCount +=1;
//                
//                // removed unnecessery object from array
//                [dictSelected removeObjectForKey:@"AddedQty"];
//                [dictSelected removeObjectForKey:@"DepartId"];
//                [dictSelected removeObjectForKey:@"DepartmentName"];
//                [dictSelected removeObjectForKey:@"ItemDiscount"];
//                [dictSelected removeObjectForKey:@"ItemImage"];
//                [dictSelected removeObjectForKey:@"ItemSupplierData"];
//                [dictSelected removeObjectForKey:@"ItemTag"];
//                [dictSelected removeObjectForKey:@"MaxStockLevel"];
//                [dictSelected removeObjectForKey:@"MinStockLevel"];
//                [dictSelected removeObjectForKey:@"selected"];
//                [dictSelected removeObjectForKey:@"ItemNo"];
//                
//                [dictSelected removeObjectForKey:@"EBT"];
//                [dictSelected removeObjectForKey:@"NoDiscountFlg"];
//                [dictSelected removeObjectForKey:@"POSDISCOUNT"];
//                [dictSelected removeObjectForKey:@"TaxType"];
//                [dictSelected removeObjectForKey:@"isTax"];
//                [dictSelected removeObjectForKey:@"Remark"];
//                
//                [dictSelected setValue:@"0" forKey:@"FreeGoodsQty"];
//                [dictSelected setValue:@"0" forKey:@"ReOrder"];
//                
//                NSPredicate *isselection = [NSPredicate predicateWithFormat:@"Barcode == %@",[dictSelected valueForKey:@"Barcode"]];
////                NSArray *arrayTemp = [[objDeliveryScane.objOpenList.arrPendingDeliveryData filteredArrayUsingPredicate:isselection]mutableCopy];
////                if(arrayTemp.count==0)
////                {
////                    [dictSelected setObject:@"0" forKey:@"NewAdded"];
////                    [dictSelected setObject:@"Green" forKey:@"Gvalue"];;
////                }
////                [objDeliveryScane.arrayScanData insertObject:dictSelected atIndex:0];
//            }
//        }
////        objDeliveryScane.btnback.hidden=NO;
//        [self.arrTempSelected removeAllObjects];
//        self.checkSearchRecord=FALSE;
//        flgRedirectToOpenList = FALSE;
////        [objDeliveryScane.tblPendingScanData reloadData];
//        
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else{
//            [self.view removeFromSuperview];
//        }
//    }
//    else if(objNewItemReceiveList){
//        BOOL morethenOne=NO;
//        
//        for(int i=0;i<[self.arrTempSelected count];i++)
//        {
//            NSMutableDictionary *dictSelected = [[self.arrTempSelected objectAtIndex:i]mutableCopy];
//            if([dictSelected  valueForKey:@"selected"])
//            {
//                //recordCount +=1;
//                
//                // removed unnecessery object from array
//                /*  [dictSelected removeObjectForKey:@"AddedQty"];
//                 [dictSelected removeObjectForKey:@"DepartId"];
//                 [dictSelected removeObjectForKey:@"DepartmentName"];
//                 [dictSelected removeObjectForKey:@"ItemDiscount"];
//                 [dictSelected removeObjectForKey:@"ItemImage"];
//                 [dictSelected removeObjectForKey:@"ItemSupplierData"];
//                 [dictSelected removeObjectForKey:@"ItemTag"];
//                 [dictSelected removeObjectForKey:@"MaxStockLevel"];
//                 [dictSelected removeObjectForKey:@"MinStockLevel"];
//                 [dictSelected removeObjectForKey:@"selected"];
//                 [dictSelected removeObjectForKey:@"ItemNo"];
//                 
//                 [dictSelected removeObjectForKey:@"EBT"];
//                 [dictSelected removeObjectForKey:@"NoDiscountFlg"];
//                 [dictSelected removeObjectForKey:@"POSDISCOUNT"];
//                 [dictSelected removeObjectForKey:@"TaxType"];
//                 [dictSelected removeObjectForKey:@"isTax"];
//                 [dictSelected removeObjectForKey:@"Remark"];
//                 
//                 [dictSelected setValue:@"0" forKey:@"FreeGoodsQty"];
//                 [dictSelected setValue:@"0" forKey:@"ReOrder"];*/
//                
//                [objNewItemReceiveList.arrayReceiveItem insertObject:dictSelected atIndex:0];
//            }
//        }
////        objDeliveryScane.btnback.hidden=NO;
//        if([self.arrTempSelected count]>1)
//        {
//            morethenOne=YES;
//        }
//        [self.arrTempSelected removeAllObjects];
//        self.checkSearchRecord=FALSE;
//        flgRedirectToOpenList = FALSE;
//        
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else{
//            [self.view removeFromSuperview];
//            [objNewItemReceiveList didSelectItems:(NSArray *) objNewItemReceiveList.arrayReceiveItem];
//            [objNewItemReceiveList.arrayReceiveItem removeAllObjects];
//        }
    }
    else
    {
        if(self.redirectToCalledFun) // redirect to Item Out
        {
            for(int i=0;i<self.arrTempSelected.count;i++)
            {
                NSMutableDictionary *dictSelected = [(self.arrTempSelected)[i]mutableCopy];
                if([dictSelected  valueForKey:@"selected"])
                {
                    dictSelected[@"AddedQty"] = @"1";
//                    [objInvenOut.arrScanBarDetails insertObject:dictSelected atIndex:0];
                }
            }
            [self.arrTempSelected removeAllObjects];
            self.redirectToCalledFun=FALSE;
            self.checkSearchRecord=FALSE;
//            objInvenOut.tblScannedItemList.hidden=NO;
//            [objInvenOut.tblScannedItemList reloadData];
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                [self.navigationController popViewControllerAnimated:YES];
                //                [self.navigationController popViewControllerAnimated:YES];
//                NSArray *arryView = [self._rimController.objInvHome.navigationController viewControllers];
//                for(int i=0;i<[arryView count];i++)
//                {
//                    UIViewController *viewCon = [arryView objectAtIndex:i];
//                    if([viewCon isKindOfClass:[InventoryOutScannerView class]])
//                    {
//                        [self.navigationController popViewControllerAnimated:YES];
//                        return;
//                    }
//                }
//                self._rimController.objAppInvenOut.managedObjectContext = self.rmsDbController.managedObjectContext;
//                [self._rimController.objInvHome.navigationController pushViewController:self._rimController.objAppInvenOut animated:YES];
            }
            else
            {
                // FOR IPAD ITEM SELECTION CHECK ItemMultipleSelectionVC.m (DONE BUTTON CLICKED)
                //[self._rimController.objSideMenuiPad showViewFromViewController:objInvenOut];
            }
        }
        else // redirect to Item In
        {
            for(int i=0;i<self.arrTempSelected.count;i++)
            {
                NSMutableDictionary *dictSelected = [(self.arrTempSelected)[i]mutableCopy];
                if([dictSelected  valueForKey:@"selected"])
                {
                    recordCount +=1;
                    dictSelected[@"AddedQty"] = @"1";
//                    [objNewOrder.arrScanBarDetails insertObject:dictSelected atIndex:0];
                }
            }
//            NSInteger tmprow = objNewOrder.indPath.row;
//            if(tmprow > -1)
//            {
//                objNewOrder.indPath=[NSIndexPath indexPathForRow:tmprow + recordCount inSection:0];
//            }
            [self.arrTempSelected removeAllObjects];
            self.checkSearchRecord=FALSE;
//            objNewOrder.tblScannedItemList.hidden=NO;
//            [objNewOrder.tblScannedItemList reloadData];
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
//                NSArray *arryView = [self._rimController.objInvHome.navigationController viewControllers];
//                for(int i=0;i<[arryView count];i++)
//                {
//                    UIViewController *viewCon = [arryView objectAtIndex:i];
//                    if([viewCon isKindOfClass:[NewOrderScannerView class]])
//                    {
                        [self.navigationController popViewControllerAnimated:YES];
//                        return;
//                    }
//                }
//                self._rimController.objAppInvenIn.managedObjectContext = self.rmsDbController.managedObjectContext;
//                [self._rimController.objInvHome.navigationController pushViewController:self._rimController.objAppInvenIn animated:YES];
            }
            else
            {
                // FOR IPAD ITEM SELECTION CHECK ItemMultipleSelectionVC.m (DONE BUTTON CLICKED)
                // [self._rimController.objSideMenuiPad showViewFromViewController:objNewOrder];
            }
        }
    }
    [self.arrTempSelected removeAllObjects];
    [self.tblviewInventory reloadData];
}

-(IBAction)cancelClick:(id)sender
{
    [Appsee addEvent:kPOMultipleItemSelectionCancel];
    [self.rmsDbController playButtonSound];
//    for(int isfnd = 0 ; isfnd < [self.arrTempSelected count] ; isfnd++)
//    {
//        NSMutableDictionary *dictSelected = [[self.arrTempSelected objectAtIndex:isfnd] mutableCopy];
//        Item *anItem = [self fetchAllItems:[dictSelected valueForKey:@"ItemId"]];
//        anItem.is_Selected = @(NO);
//    }
    //    [self.managedObjectContext reset];
    [self.arrTempSelected removeAllObjects];
    [self.tblviewInventory reloadData];
    
    [self.arrTempSelected removeAllObjects];
    self.btn_Done.hidden=YES;
    flgDonebutton = NO;
    self.checkSearchRecord = FALSE;
    if (self.objNewItemReceiveList) {
        [self.navigationController popViewControllerAnimated:FALSE];
    }
    else if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else{
//        [self.view removeFromSuperview];
        [self dismissViewControllerAnimated:false completion:nil];
        [self.pOMultipleItemSelectionVCDelegate didSelectionChangeInPOMultipleItemSelectionVC:[[NSMutableArray alloc]init]];
    }
}

#pragma mark - Left / Right / Copy / Delete swipe Method

-(void)didSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tblviewInventory];
    NSIndexPath *swipedIndexPath = [self.tblviewInventory indexPathForRowAtPoint:location];
    self.indPath = swipedIndexPath;
    strSwipeDire=@"Right";
    [self.tblviewInventory reloadData];
}

-(void)didSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tblviewInventory];
    NSIndexPath *swipedIndexPath = [self.tblviewInventory indexPathForRowAtPoint:location];
    if(self.indPath.row == swipedIndexPath.row)
    {
        self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        strSwipeDire = @"Left";
        [self.tblviewInventory reloadData];
    }
}

-(void)copyItem:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblviewInventory];
    NSIndexPath *indexPath = [self.tblviewInventory indexPathForRowAtPoint:buttonPosition];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getClickedItemData:indexPath];
        // hide swiped image
        self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        [self.tblviewInventory reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

-(void)deleteItem:(id)sender
{
    [self.rmsDbController playButtonSound];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblviewInventory];
    NSIndexPath *indexPath = [self.tblviewInventory indexPathForRowAtPoint:buttonPosition];
    self.deleteIndexPath = [indexPath copy ];
    Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
    deleteRecordId = anItem.itemCode.integerValue ;
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        strSwipeDire = @"Left";
        [self.tblviewInventory reloadData];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
    
        [self deleteRecord:deleteRecordId];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"Are you sure you want to delete %@ ?",anItem.item_Desc] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
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
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self deleteItemDataResponse:response error:error];
    };
    self.itemDeletedWC = [self.itemDeletedWC initWithRequest:KURL actionName:WSM_ITEM_DELETED params:deleteparam completionHandler:completionHandler];
    
}

- (void)deleteItemDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                // deleteRecordId
                
                [self.itemMgmtUpdateManager deleteItemWithItemCode:@(deleteRecordId)];
                self.searchText = @"";
                self.txtUniversalSearch.text = @"";
                self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
                self.itemResultsController = nil;
                [self.tblviewInventory reloadData];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Item has been deleted successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Item not deleted" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
    }
}

-(void)reloadInventoryMgmtTable
{
    self.itemResultsController = nil;
    [self.tblviewInventory reloadData];
    [_activityIndicator hideActivityIndicator];
}

-(void)reloadAllItems
{
    self.itemResultsController = self.allItemResultsController;
    [self.tblviewInventory reloadData];
    [_activityIndicator hideActivityIndicator];
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
    
    NSPredicate *predicate;
    if ([self isSubDepartmentEnableInBackOffice]) {
        predicate = [NSPredicate predicateWithFormat:@"active == %d AND isNotDisplayInventory == %@",TRUE,@(0)];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"active == %d AND isNotDisplayInventory == %@ AND itm_Type != %@",TRUE,@(0),@(2)];
    }

    fetchRequest.predicate = predicate;
    
    // Create and initialize the fetch results controller.
    _allItemResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionName cacheName:nil];
    
    [_allItemResultsController performFetch:nil];
    _allItemResultsController.delegate = self;
    return _allItemResultsController;
}

#pragma mark - Scanner Device Methods

-(void)deviceButtonPressed:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"poMultipleItemSelection"])
        {
            isScannerUsed = TRUE;
            [status setString:@""];
        }
    }
}

-(void)deviceButtonReleased:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"poMultipleItemSelection"])
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
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Please set scanner type as scanner" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

#pragma mark Item Info Button

-(IBAction)btn_ItemInfoClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
//        objItemInfo = [[ItemInfoViewController alloc] initWithNibName:@"ItemInfoViewController" bundle:nil];
//        objItemInfo.managedObjectContext = self.rmsDbController.managedObjectContext;
//        [self.navigationController pushViewController:objItemInfo animated:YES];
    }
    else
    {
//        objItemInfo = [[ItemInfoViewController alloc] initWithNibName:@"ItemInfoViewController_iPad" bundle:nil];
//        objItemInfo.managedObjectContext = self.rmsDbController.managedObjectContext;
//        [self.navigationController pushViewController:objItemInfo animated:YES];
    }
}

#pragma mark - RapidFilters -
-(void)addFilterView {
    if (!objRapidItemFilterVC) {
        objRapidItemFilterVC = [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"RapidItemFilterVC_sid"];
        [objRapidItemFilterVC.view setFrame:CGRectMake(355, 0, 355, self.viewFilterBG.bounds.size.height)];
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:objRapidItemFilterVC.view]){
        return NO;
    }
    else if (self.viewFilterBG.hidden) {
        self.btnRapidFilterView.selected = FALSE;
        [self.view removeGestureRecognizer:gestureRecognizer];
        return NO;
    }
    return YES;
}

#pragma mark - Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */

- (NSFetchedResultsController *)itemResultsController {
    RapidAutoLock *lock  = [[RapidAutoLock alloc]initWithLock:self.poMultipleItemLock];
    if (_itemResultsController != nil) {
        return _itemResultsController;
    }

    // Create and configure a fetch request with the Item entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    //[fetchRequest setFetchBatchSize:20];
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
        if(self.isKeywordFilter) {
            if(isRecordFound == 0) {
                BOOL valid;
                NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
                NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:self.txtUniversalSearch.text];
                valid = [alphaNums isSupersetOfSet:inStringSet];
                if (valid) // numeric
                {

                    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                    
                    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
                    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                    [itemparam setValue:self.txtUniversalSearch.text forKey:@"Code"];
                    [itemparam setValue:@"Barcode" forKey:@"Type"];
                    
                    CompletionHandler completionHandler = ^(id response, NSError *error) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self responsePurchaesOrderMgmtResponse:response error:error];
                        });
                    };
                    
                    self.pOmgmtItemInsertWC = [self.pOmgmtItemInsertWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
                    
                }
                else // non numeric
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        [self checkConnectedScannerType];
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"No item found for %@",self.searchText] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    self.searchText = @"";
                    self.txtUniversalSearch.text = @"";
                    [self.txtUniversalSearch resignFirstResponder];
                }
                _itemResultsController = self.previousItemResultsController;
                return _itemResultsController;
            }
        }
        else // for Alphabatic sorting
        {
            if(isRecordFound == 0)
            {
                _itemResultsController = self.previousItemResultsController;
                return _itemResultsController;
                
            }
        }
    }
    else {
        
        NSMutableArray *fieldWisePredicates = [NSMutableArray array];
        NSPredicate *predicate;
        if ([self isSubDepartmentEnableInBackOffice]) {
            predicate = [NSPredicate predicateWithFormat:@"active == %d AND isNotDisplayInventory == %@",TRUE,@(0)];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"active == %d AND isNotDisplayInventory == %@ AND itm_Type != %@",TRUE,@(0),@(2)];
        }
        
        [fieldWisePredicates addObject:predicate];
        
        if (preCoustomeFilter) {
            [fieldWisePredicates addObject:preCoustomeFilter];
        }
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
        
        [fetchRequest setPredicate:finalPredicate];
    }
  // NSString *sectionLabel = nil;
    // Create the sort descriptors array.
    [self applySupplierPredicateToFetchRequest:fetchRequest];
    
//    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending];
//    NSArray *sortDescriptors = @[aSortDescriptor];
//    fetchRequest.sortDescriptors = sortDescriptors;
//   // sectionLabel = self.sectionName;
//    // Create and initialize the fetch results controller.
//    _itemResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionName cacheName:nil];
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending selector:@selector(caseInsensitiveCompare:)];
    
    NSSortDescriptor *aSortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:self.sectionName ascending:self.isAscending selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor2,aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _itemResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionName cacheName:nil];
    
    [_itemResultsController performFetch:nil];
    _itemResultsController.delegate = self;
    
    if(self.objeNewSuppInfo && self.isSupplierFilter)
    {
        if (_itemResultsController.sections.count > 0) {
            self.previousItemResultsController = _itemResultsController;
        }
    }
    else
    {
        self.previousItemResultsController = _itemResultsController;
    }
    [lock unlock];
    return _itemResultsController;
}

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([configuration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

-(void)responsePurchaesOrderMgmtResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if(response!=nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            
            NSPredicate *inActiveItemPredicate = [NSPredicate predicateWithFormat:@"isDeleted == %d",FALSE];
            
            NSArray *itemResponseArray = [[responseDictionary valueForKey:@"ItemArray"] filteredArrayUsingPredicate:inActiveItemPredicate];
            if(itemResponseArray.count > 0)
            {
                NSDictionary *itemDict = itemResponseArray.firstObject;
                if ([[[itemDict valueForKey:@"Active"] stringValue] isEqualToString:@"0"]) // if not active item
                {
                    POMultipleItemSelectionVC * __weak myWeakReference = self;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        NSString *strItemId = [NSString stringWithFormat:@"%@",[itemDict valueForKey:@"ITEMCode"]];
                        Item *currentItem = [self fetchAllItems:strItemId];
                        [myWeakReference moveInActiveItemToActiveList:currentItem];
                    };
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"This item is inactive would you like to activate it?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                    
                }
                else{
                    [self.itemMgmtUpdateManager updateObjectsFromResponseDictionary:responseDictionary];
                    [self.itemMgmtUpdateManager linkItemToDepartmentFromResponseDictionary:responseDictionary];
                    self.searchText = self.txtUniversalSearch.text;
                    [self.tblviewInventory reloadData];
                }
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [self checkConnectedScannerType];
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        self.rimsController.scannerButtonCalled = @"InvAdd";
                        ItemInfoEditVC *objInventoryAdd = [[ItemInfoEditVC alloc] initWithNibName:@"ItemInfoEditVC" bundle:nil];
                        objInventoryAdd.isInvenManageCalled = TRUE;
                        objInventoryAdd.strScanBarcode = self.searchText;
                        [self.navigationController pushViewController:objInventoryAdd animated:YES];
                    }
                    else
                    {
                        //                    self._rimController.scannerButtonCalled = @"InvAdd";
                        //                    [self._rimController.objSideMenuiPad showInventoryAddNewWithBarcode:self.txtUniversalSearch.text];
                    }
                    self.itemResultsController = nil;
                };
                
                if(self.objNewItemReceiveList)
                {
                    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"No item found for %@",self.searchText] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    self.searchText = @"";
                    self.txtUniversalSearch.text = @"";
                }
                else{
                    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"No item found for %@, are you sure you want to add item with %@ UPC?",self.searchText,self.searchText] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                    self.searchText = @"";
                    self.txtUniversalSearch.text = @"";
                }
                
                [self.txtUniversalSearch resignFirstResponder];
            }
        }
        
    }
}

- (void)applySupplierPredicateToFetchRequest:(NSFetchRequest *)fetchRequest {
    NSPredicate *searchPredicateItemCode;
    if(self.objeNewSuppInfo && self.isSupplierFilter){
        
        NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemSupplier" inManagedObjectContext:self.managedObjectContext];
        fetchRequest2.entity = entity;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vendorId==%d",[[self.objeNewSuppInfo valueForKey:@"Suppid"] integerValue]];
        fetchRequest2.predicate = predicate;
        NSArray *itemItemSupplier = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest2];
        NSArray *itemIdList = [itemItemSupplier valueForKey:@"itemCode"];
        searchPredicateItemCode = [NSPredicate predicateWithFormat:@"itemCode IN %@",itemIdList];
        if(self.objeNewSuppInfo)
        {
            NSPredicate *oldPredicate = fetchRequest.predicate;
            if (oldPredicate != nil)
            {
                NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[oldPredicate, searchPredicateItemCode]];
                fetchRequest.predicate = predicate;
            }
            else
            {
                fetchRequest.predicate = searchPredicateItemCode;
            }
        }
    }
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if(controller != _itemResultsController)
    {
        [self unlockResultController];
        return;
    }
    else if (_itemResultsController == nil){
        [self unlockResultController];
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblviewInventory beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != _itemResultsController)
    {
        return;
    }
    else if (_itemResultsController == nil){
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
            [self.tblviewInventory reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(controller != _itemResultsController)
    {
        return;
    }
    else if (_itemResultsController == nil){
        return;
    }

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblviewInventory insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblviewInventory deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    if(controller != _itemResultsController)
    {
        return;
    }
    else if (_itemResultsController == nil){
        return;
    }
    [self.tblviewInventory endUpdates];
    [self unlockResultController];
}


- (void)moveInActiveItemToActiveList:(Item *)anItem
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * dictItemInfo;
    dictItemInfo = [self getParamToActiveItem:anItem isItemActive:@"1"];
   
    CompletionHandler completionHandler = ^(id response, NSError *error) {
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self responseForMovePOItemToActiveListResponse:response error:error];
              });
    };
    
    self.poItemActiveWSC = [self.poItemActiveWSC initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:dictItemInfo completionHandler:completionHandler];

}

-(void)responseForMovePOItemToActiveListResponse:(id)response error:(NSError *)error {
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {   //  InvItemUpdateNewBarcodeResult
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                 NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                NSString * strItemId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
                Item * currentItem = [self fetchAllItems:strItemId];
                currentItem.active = @1;
                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.itemResultsController = nil;
                    [self.tblviewInventory reloadData];
                    [self textFieldShouldReturn:self.txtUniversalSearch];
                });
            }
            else{
                NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n Item not updated, try again."};
                [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Item not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    
    [_activityIndicator hideActivityIndicator];
    // [self updateDataInDataBase_RIM];
}


- (NSMutableDictionary *)getParamToActiveItem:(Item *)anItem isItemActive:(NSString *)strIsAcite {
    NSMutableDictionary * addItemDataDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * itemDetails = [[NSMutableArray alloc] init];
    NSMutableDictionary * itemDataDict = [[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    
    NSString * strItemCode = [dictItemClicked valueForKey:@"ItemId"];
    BOOL isDuplicateUPC = [[dictItemClicked valueForKey:@"IsduplicateUPC"] boolValue];
    
    itemDataDict[@"ItemId"] = strItemCode;
    
    itemDataDict[@"ItemName"] = [NSString stringWithFormat:@"%@",[dictItemClicked valueForKey:@"ItemName"]];
    
    itemDataDict[@"Active"] = strIsAcite;
    
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


-(void)updateDataInDataBase_RIM {
    NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
    [itemLiveUpdate setValue:@"Update" forKeyPath:@"Action"];
    [itemLiveUpdate setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"EntityId"];
    [itemLiveUpdate setValue:@"Item" forKey:@"Type"];
    [self.rmsDbController addItemListToLiveUpdateQueue:itemLiveUpdate];
}


- (void)insertDidFinish {
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [self.managedObjectContext reset];
    [self.tblviewInventory reloadData];
    
    [self.arrTempSelected removeAllObjects];
    self.checkSearchRecord = FALSE;
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)poMultipleItemLock {
    if (_poMultipleItemLock == nil) {
        _poMultipleItemLock = [[NSRecursiveLock alloc] init];
    }
    return _poMultipleItemLock;
}

-(void)lockResultController
{
    [self.poMultipleItemLock lock];
}

-(void)unlockResultController
{
    [self.poMultipleItemLock unlock];
}

-(void)setItemResultsController:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.poMultipleItemLock];
    _itemResultsController = resultController;
    [lock unlock];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
