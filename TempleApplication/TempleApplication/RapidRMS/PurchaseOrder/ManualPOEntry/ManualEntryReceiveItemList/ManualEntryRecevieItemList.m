//
//  ManualEntryRecevieItemList.m
//  RapidRMS
//
//  Created by Siya on 16/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ManualEntryRecevieItemList.h"
#import "POMultipleItemSelectionVC.h"
#import "ManualEntryCustomCell.h"
#import "RmsDbController.h"
#import "Item+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "ManualItemReceiveVC.h"
#import "SubDepartment+Dictionary.h"
#import "ReceivedItemListCell.h"
#import "MESearchItemSelectionVC.h"
#import "ManualReceivedItem+Dictionary.h"
#import "ManualPOSession+Dictionary.h"
#import "UpdateManager.h"
#import "ManualPOEntryHomeVC.h"
#import  "SlidingManuVC.h"
#import  "ItemInfoEditVC.h"
#import "ItemDetailEditVC.h"
#import "CameraScanVC.h"

#import "ItemInfoDataObject.h"
#import "SupplierCompany.h"

typedef NS_ENUM(NSUInteger, ItemSort) // itemInfoSectionArray
{
    Item_Sort_None,
    Item_Sort_ATOZ,
    Item_Sort_ZTOA,
};

@interface ManualEntryRecevieItemList ()<CameraScanVCDelegate,ItemInfoEditRedirectionVCDelegate,POMultipleItemSelectionVCDelegate>
{
    NSString *strSwipeDire;
    NSString *strmanualItemId;
    ManualReceivedItem *manualItem;
    ManualItemReceiveVC *manualItemReceiveVC;
    ItemSort sortingPreference;
    POMultipleItemSelectionVC *itemMultipleVC;
    IntercomHandler *intercomHandler;
    Configuration *configuration;

    NSString *barcodeString;
}

@property (nonatomic, weak) IBOutlet UITextField *txtUniversalSearch;

@property (nonatomic, weak) IBOutlet UIView *viewBottom;
@property (nonatomic, weak) IBOutlet UIView *viewHeader;

@property (nonatomic, weak) IBOutlet UILabel *lblinvoiceNo;
@property (nonatomic, weak) IBOutlet UILabel *lblSupplierName;
@property (nonatomic, weak) IBOutlet UILabel *lblDateReceived;
@property (nonatomic, weak) IBOutlet UILabel *lblProducts;
@property (nonatomic, weak) IBOutlet UILabel *lblCosts;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;


@property (nonatomic, weak) IBOutlet UITextField *txtBarcodeSearch;

@property (nonatomic, weak) IBOutlet UITableView *tblManulReceiveList;

@property (nonatomic, weak) IBOutlet UIButton *btnHold;
@property (nonatomic, weak) IBOutlet UIButton *btnUpdate;
@property (nonatomic, weak) IBOutlet UIButton *btnSearch;
@property (nonatomic, weak) IBOutlet UIButton *btnAddNew;
@property (nonatomic, weak) IBOutlet UIButton *btnReconcile;
@property (nonatomic, weak) IBOutlet UIButton *btnShort;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnInfo;


@property (nonatomic, weak) IBOutlet UIView *viewSearcHidden;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) NewManualItemVC *manualItemReceive;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;

@property (nonatomic, strong) RapidWebServiceConnection *manualEntryServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *manualEntryReconcile;
@property (nonatomic, strong) RapidWebServiceConnection *deleteManualEntryItemServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *missingItemWSC;
@property (nonatomic, strong) RapidWebServiceConnection *itemActiveWSC;


@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (nonatomic, strong) NSFetchedResultsController *meItemResultSetController;

@property (nonatomic, assign) BOOL boolHoldClick;

@property (nonatomic, assign) int totAvaialbeQty;
@property (nonatomic, assign) int totReceivingQty;
@property (nonatomic, assign) int totReceivingCase;
@property (nonatomic, assign) int totReceivingPack;
@property (nonatomic, assign) int totNumberOfProduct;

@property (nonatomic, assign) float TotalCost;
@property (nonatomic, assign) float TotalPrice;
@property (nonatomic, assign) float TotalExtendedPrice;
@property (nonatomic, assign) float totalCost;

@property (nonatomic, strong) NSRecursiveLock *manualEntryLock;

@property (nonatomic, strong) NSMutableArray *arrayReceiveItem;
@property (nonatomic, strong) NSMutableArray *previewItemArray;
@property (nonatomic, strong) NSMutableArray * arrItemCode;

@property (nonatomic, strong) NSString *emaiItemHtml;

@property (nonatomic, strong) NSIndexPath *indPath;
@property (nonatomic, strong) NSIndexPath *selectedItemPath;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation ManualEntryRecevieItemList
@synthesize managedObjectContext = __managedObjectContext;
@synthesize dictSupplier;
@synthesize PDFCreator,strInvoiceNo;
@synthesize showView;
@synthesize manualItemReceive;
@synthesize meItemResultSetController = _meItemResultSetController;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self calculatetotalItemCost];
    self.lblinvoiceNo.text=[NSString stringWithFormat:@"%@", self.strInvoiceNo];
    self.lblDateReceived.text = [self.dictSupplier valueForKey:@"ReceiveDate"];
    self.lblSupplierName.text = [self.dictSupplier valueForKey:@"SuppName"];
    self.lblTitle.text = [NSString stringWithFormat:@"%@", self.strTitle];
    [self diableManuButtonsFromHistroy];
    _meItemResultSetController=nil;
    [self.tblManulReceiveList reloadData];

//    if(!_showView)
//    {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.meItemResultSetController=nil;
//            [self.tblManulReceiveList reloadData];
//        });
//    }
//    else{
//        _meItemResultSetController=nil;
//        [self.tblManulReceiveList reloadData];
//    }
}

-(IBAction)itemSort:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    switch (sortingPreference) {
        case Item_Sort_None:
            sortingPreference=Item_Sort_ATOZ;
            [btn setImage:[UIImage imageNamed:@"RIM_List_Order_Ascending"] forState:UIControlStateNormal];
            break;
        case Item_Sort_ATOZ:
            sortingPreference=Item_Sort_ZTOA;
            [btn setImage:[UIImage imageNamed:@"RIM_List_Order_Descending"] forState:UIControlStateNormal];
            break;
        case Item_Sort_ZTOA:
            sortingPreference=Item_Sort_None;
            [btn setImage:[UIImage imageNamed:@"RIM_List_Order_None"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    self.meItemResultSetController=nil;
    [self.tblManulReceiveList reloadData];
}

-(void)diableManuButtonsFromHistroy
{
    if(!self.showView)
    {
        [self.txtUniversalSearch becomeFirstResponder];
        self.viewSearcHidden.hidden=YES;
        self.btnAddNew.enabled=YES;
        self.btnSearch.enabled=YES;
        self.btnUpdate.enabled=YES;
        self.btnReconcile.enabled=YES;
        self.btnHold.enabled=YES;
    }
    else{
        
        [self.txtBarcodeSearch resignFirstResponder];
        [self.txtUniversalSearch resignFirstResponder];
        [[self.txtBarcodeSearch valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
        [self.view endEditing:YES];
        self.viewSearcHidden.hidden=NO;
        self.btnAddNew.enabled=NO;
        self.btnSearch.enabled=NO;
        self.btnUpdate.enabled=NO;
        self.btnReconcile.enabled=NO;
        self.btnHold.enabled=NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sortingPreference =Item_Sort_None;
    self.arrayReceiveItem = [[NSMutableArray alloc]init];
    _previewItemArray = [[NSMutableArray alloc]init];
    
    _viewHeader.layer.cornerRadius = 8.0;
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    self.manualEntryServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.deleteManualEntryItemServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.missingItemWSC = [[RapidWebServiceConnection alloc]init];
    self.itemActiveWSC = [[RapidWebServiceConnection alloc]init];
    self.manualEntryReconcile = [[RapidWebServiceConnection alloc]init];
    
    if(_posession!=nil)
    {
        NSManagedObjectID *posessionid = _posession.objectID;
        _posession = (ManualPOSession *)[self.managedObjectContext objectWithID:posessionid];
    }


    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
    _viewHeader.frame=CGRectMake(_viewHeader.frame.origin.x, 768, _viewHeader.frame.size.width, _viewHeader.frame.size.height);
   // self.showView=NO;
    
    [self.view bringSubviewToFront:self.viewBottom];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextHasChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
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


//- (void)contextHasChanged:(NSNotification*)notification
//{
//    NSLog(@"contextHasChanged notification : %@", notification);
//    NSManagedObjectContext *changedContext = [notification object];
//    NSManagedObjectContext *parentContext = self.rmsDbController.managedObjectContext;
//    
//    // Ignore it.
//    if (![changedContext isEqual:parentContext]){
//
//        return;
//    }
//    
//    // This is not main thread
//    if (![NSThread isMainThread]) {
//        // Merge should be performed on main thread
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self contextHasChanged:notification];
//        });
//        return;
//    }
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // Merge changes
//        [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            // Save changes
//            [self saveContext];
//        });
//    });
//}
//
//- (void)saveContext
//{
//    //NSLog(@"saveContext");
//    NSError *error = nil;
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        BOOL hasChanges = [managedObjectContext hasChanges];
//        hasChanges = YES;
//        @try {
//            if (hasChanges) {
//                if (![managedObjectContext save:&error]) {
//                    // Replace this implementation with code to handle the error appropriately.
//                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                }
//            }
//        }
//        @catch (NSException *exception) {
//        }
//        @finally {
//            
//        }
//    }
//}

- (NSArray *)fetchAllReceivingItems
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"ManualReceivedItem" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"supplierIDitems.manualPoId = %d",self.strManualPoID.integerValue];
    fetchRequest.predicate = predicatePO;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    return resultSet;
}

- (BOOL)checkItemisAlreadyIntheList:(NSString *)strItemCode
{
    BOOL alreadyExit = NO;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"ManualReceivedItem" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"supplierIDitems.manualPoId = %d",self.strManualPoID.integerValue];
    
    fetchRequest.predicate = predicatePO;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    for(int i=0;i<resultSet.count;i++)
    {
        NSIndexPath *indPath = [NSIndexPath indexPathForRow:i inSection:0];
        ManualReceivedItem *mrItem = [self.meItemResultSetController objectAtIndexPath:indPath];
        NSDictionary *itemDictionary = mrItem.item.itemDictionary;
        if([[itemDictionary valueForKey:@"ItemId"] isEqualToString:strItemCode])
        {
            alreadyExit=YES;
            break ;
        }
    }
    return alreadyExit;
}

-(CGFloat)qtyForPriceMdForpackageType :(NSString *)packagetype withItem:(Item *)item
{
    CGFloat qty = 0.0;
    NSArray *priceToItemArray = item.itemToPriceMd.allObjects;
    
    for (Item_Price_MD *price_md in priceToItemArray)
    {
        if ([price_md.priceqtytype isEqualToString:packagetype])
        {
            qty= price_md.qty.floatValue;
        }
    }
    return qty;
}


- (void)calculatetotalItemCost {
    NSArray *arrayItems = [self fetchAllReceivingItems];

    int itemcount = 0;
    _totalCost=0.0;
    if (arrayItems.count > 0) {
        for(int i=0;i<arrayItems.count;i++){
            ManualReceivedItem *mrItem = arrayItems[i];
            
             if(mrItem.isReturn.boolValue){
                 float cost=0.0;
                 
                 NSDictionary *itemDictionary = mrItem.item.itemDictionary;
                 if(itemDictionary != nil) {
                     
                     CGFloat singleCost = mrItem.unitCost.floatValue * mrItem.unitQuantityReceived.integerValue;
                     CGFloat caseCost = mrItem.caseCost.floatValue * mrItem.caseQuantityReceived.integerValue;
                     CGFloat packCost = mrItem.packCost.floatValue * mrItem.packQuantityReceived.integerValue;
                     
                     CGFloat freeSingleCost = mrItem.freeGoodCost.floatValue * mrItem.singleReceivedFreeGoodQty.integerValue;
                     CGFloat freeCaseCost = mrItem.freeGoodCaseCost.floatValue * mrItem.caseReceivedFreeGoodQty.integerValue;
                     CGFloat freePackCost = mrItem.freeGoodPackCost.floatValue * mrItem.packReceivedFreeGoodQty.integerValue;
                     
                     cost = singleCost + caseCost + packCost + freeSingleCost + freeCaseCost + freePackCost ;
                     
                     _totalCost = _totalCost - fabsf(cost);
                     itemcount++;
                 }
             }
             else {
                 float cost=0.0;
                 
                 NSDictionary *itemDictionary = mrItem.item.itemDictionary;
                 if(itemDictionary != nil) {
                     
                     CGFloat singleCost = mrItem.unitCost.floatValue * mrItem.unitQuantityReceived.integerValue;
                     CGFloat caseCost = mrItem.caseCost.floatValue * mrItem.caseQuantityReceived.integerValue;
                     CGFloat packCost = mrItem.packCost.floatValue * mrItem.packQuantityReceived.integerValue;
                     
                     CGFloat freeSingleCost = mrItem.freeGoodCost.floatValue * mrItem.singleReceivedFreeGoodQty.integerValue;
                     CGFloat freeCaseCost = mrItem.freeGoodCaseCost.floatValue * mrItem.caseReceivedFreeGoodQty.integerValue;
                     CGFloat freePackCost = mrItem.freeGoodPackCost.floatValue * mrItem.packReceivedFreeGoodQty.integerValue;
                     
                     cost = singleCost + caseCost + packCost + freeSingleCost + freeCaseCost + freePackCost ;
                     
                     _totalCost = _totalCost + fabsf(cost);
                     itemcount++;
                 }
             }
        }
        self.lblCosts.text=[NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:_totalCost]];
    }
    else
    {
        self.lblCosts.text = @"0.0";
    }
    self.lblProducts.text = [NSString stringWithFormat:@"%d",itemcount];
}

-(IBAction)btnCameraScanSearch:(id)sender
{
    self.cameraScanVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    [self presentViewController:self.cameraScanVC animated:YES completion:^{
        self.cameraScanVC.delegate = self;
    }];
}

#pragma mark - Camera Scan Delegate Methods

-(void)barcodeScanned:(NSString *)strBarcode
{
    self.txtUniversalSearch.text = strBarcode;
    [self textFieldShouldReturn:self.txtUniversalSearch];
}


-(IBAction)infoClicked:(id)sender{
    
    [self calculatetotalItemCost];
    
    if(_viewHeader.frame.origin.y==768)
    {
        [UIView setAnimationDuration:.25];
        _viewHeader.frame=CGRectMake(_viewHeader.frame.origin.x, 540, _viewHeader.frame.size.width, _viewHeader.frame.size.height);
        _btnInfo.selected = YES;
    }
    else{
        [UIView setAnimationDuration:.25];
        _viewHeader.frame=CGRectMake(_viewHeader.frame.origin.x, 768, _viewHeader.frame.size.width, _viewHeader.frame.size.height);
        _btnInfo.selected = NO;
    }
}

-(IBAction)cancelInfoClicked:(id)sender
{
    [UIView setAnimationDuration:.25];
    _viewHeader.frame=CGRectMake(_viewHeader.frame.origin.x, 768, _viewHeader.frame.size.width, _viewHeader.frame.size.height);
    _btnInfo.selected = NO;

}

- (IBAction)btnHoldClicked:(id)sender
{
    if(!self.showView)
    {
        self.boolHoldClick=YES;
        
        NSArray *sections = self.meItemResultSetController.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
        if(sectionInfo.numberOfObjects>0)
        {
            [self callHoldwebService];
        }
    }
}
- (IBAction)btnUpdateClicked:(id)sender
{

    if(!self.showView)
    {
    
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            self.boolHoldClick=NO;
            NSArray *sections = self.meItemResultSetController.sections;
            id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
            if(sectionInfo.numberOfObjects>0)
            {
                [self callHoldwebService];
            }
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Are you sure want to update any changes in order?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        
    }
    
}


-(void)callHoldwebService{

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    [param setValue:self.strManualPoID forKey:@"ManualEntryId"];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateValue = [formatter stringFromDate:currentDate];
    [param setValue:currentDateValue forKey:@"LocalDate"];
    
    if(self.boolHoldClick)
    {
        [param setValue:@"Hold" forKey:@"Status"];
    }
    else{
        
        [param setValue:@"Update" forKey:@"Status"];
    }
    
    param[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self holdManualEntryResponse:response error:error];
             });
    };
    
    self.manualEntryServiceConnection = [self.manualEntryServiceConnection initWithRequest:KURL actionName:WSM_HOLD_MANUAL_ENTRY params:param completionHandler:completionHandler];

}

- (void)holdManualEntryResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
        
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                manualItem=nil;
                if(self.boolHoldClick){
                    
                    NSArray *arrayView = self.navigationController.viewControllers;
                    for(UIViewController *viewcon in arrayView){
                        if([viewcon isKindOfClass:[ManualPOEntryHomeVC class]]){
                            ManualPOEntryHomeVC *pohome = (ManualPOEntryHomeVC *)viewcon;
                            [self.navigationController popToViewController:pohome animated:YES];
                        }
                    }
                }
                else{
                    
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Stock Updated Successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Error occured in hold Manual Entry" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


- (IBAction)btnReconcileClicked:(id)sender
{
    NSArray * arrItems = [self.meItemResultSetController fetchedObjects];
    BOOL isQtyChange = FALSE;
    for (ManualReceivedItem * mrItem in arrItems) {
        
        if (mrItem.unitQuantityReceived.intValue != 0  || mrItem.singleReceivedFreeGoodQty.intValue != 0){
            isQtyChange = true;
            break;
        }
        else if (mrItem.caseQuantityReceived.intValue != 0  || mrItem.caseReceivedFreeGoodQty.intValue != 0) {
            isQtyChange = true;
            break;
        }
        else if (mrItem.packQuantityReceived.intValue != 0  || mrItem.packReceivedFreeGoodQty.intValue != 0){
            isQtyChange = true;
            break;
        }
    }
    if (!isQtyChange) {
        UIAlertActionHandler okHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Add Received QTY to reconcile this order." buttonTitles:@[@"Yes"] buttonHandlers:@[okHandler]];
    }
    else if(!self.showView)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            NSArray *sections = self.meItemResultSetController.sections;
            id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
            if(sectionInfo.numberOfObjects>0)
            {
            
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                
                NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
                [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                
                [param setValue:self.strManualPoID forKey:@"ManualEntryId"];
                
                NSDate *currentDate = [NSDate date];
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
                NSString *currentDateValue = [formatter stringFromDate:currentDate];
                [param setValue:currentDateValue forKey:@"LocalDate"];
                
                param[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    [self reconcileManualEntryResponse:response error:error];
                };
                
                self.manualEntryReconcile = [self.manualEntryReconcile initWithRequest:KURL actionName:WSM_RECONCILE_MANUAL_ENTRY params:param completionHandler:completionHandler];
            }
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Are you sure want to reconcile this order?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

- (void)reconcileManualEntryResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    NSArray *arrayView = self.navigationController.viewControllers;
                    for(UIViewController *viewcon in arrayView){
                        if([viewcon isKindOfClass:[ManualPOEntryHomeVC class]]){
                            ManualPOEntryHomeVC *pohome = (ManualPOEntryHomeVC *)viewcon;
                            [self.navigationController popToViewController:pohome animated:YES];
                        }
                    }
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
                
            }
            else
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Error occurred in Reconcile Manual Entry" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
        
    }
}

#pragma mark - Fetch All Vendor Item

- (NSArray *)sortForPreference:(ItemSort)itemSortingPreference {
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor;
    NSArray *sortDescriptors;

    
    switch (itemSortingPreference) {
        case Item_Sort_None:
        {
            aSortDescriptor  = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            sortDescriptors = @[aSortDescriptor];
        }
            break;
        case Item_Sort_ATOZ:
        {
            aSortDescriptor  = [[NSSortDescriptor alloc] initWithKey:@"item.item_Desc" ascending:YES];
            sortDescriptors = @[aSortDescriptor];
            
        }
            break;
        case Item_Sort_ZTOA:
        {
            aSortDescriptor  = [[NSSortDescriptor alloc] initWithKey:@"item.item_Desc" ascending:NO];
            sortDescriptors = @[aSortDescriptor];
            
        }
            break;
        default:
            break;
    }
    return sortDescriptors;
}

- (NSFetchedResultsController *)meItemResultSetController {
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.manualEntryLock];
    if (_meItemResultSetController != nil) {
        return _meItemResultSetController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualReceivedItem" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [self manualPredicate];
    fetchRequest.predicate = predicatePO;
    
    fetchRequest.sortDescriptors = [self sortForPreference:sortingPreference];

    // Create and initialize the fetch results controller.
    _meItemResultSetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_meItemResultSetController performFetch:nil];
    _meItemResultSetController.delegate = self;
    [lock unlock];
    return _meItemResultSetController;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *sections = self.meItemResultSetController.sections;
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.meItemResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];

    return sectionInfo.numberOfObjects;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReceivedItemListCell";
    ReceivedItemListCell *cellmanualItem = [self.tblManulReceiveList dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cellmanualItem.selectionStyle = UITableViewCellSelectionStyleNone;
    ManualReceivedItem *mrItem = [self.meItemResultSetController objectAtIndexPath:indexPath];
    if(mrItem.isReturn.integerValue == 1)
    {
        CGFloat singleCost = -(mrItem.unitCost.floatValue * mrItem.unitQuantityReceived.integerValue);
        CGFloat caseCost = -(mrItem.caseCost.floatValue * mrItem.caseQuantityReceived.integerValue);
        CGFloat packCost = -(mrItem.packCost.floatValue * mrItem.packQuantityReceived.integerValue);
        
        CGFloat freeSingleCost = -(mrItem.freeGoodCost.floatValue * mrItem.singleReceivedFreeGoodQty.integerValue);
        CGFloat freeCaseCost = -(mrItem.freeGoodCaseCost.floatValue * mrItem.caseReceivedFreeGoodQty.integerValue);
        CGFloat freePackCost = -(mrItem.freeGoodPackCost.floatValue * mrItem.packReceivedFreeGoodQty.integerValue);
        
        float extendedCost = singleCost + caseCost + packCost + freeSingleCost + freeCaseCost + freePackCost;

        
        NSInteger receivedgreeGoodsSingle = -(mrItem.unitQuantityReceived.integerValue + mrItem.singleReceivedFreeGoodQty.integerValue);
        NSInteger receivedgreeGoodsCase = -(mrItem.caseQuantityReceived.integerValue + mrItem.caseReceivedFreeGoodQty.integerValue);
        NSInteger receivedgreeGoodsPack = -(mrItem.packQuantityReceived.integerValue + mrItem.packReceivedFreeGoodQty.integerValue);
        
        cellmanualItem.txtReceivedSingelQty.text = [NSString stringWithFormat:@"%ld",(long)receivedgreeGoodsSingle];

        cellmanualItem.txtExtendedCost.text=[NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:extendedCost]];
        
          cellmanualItem.txtReceivedCasePackValue.text = [NSString stringWithFormat:@"%ld / %ld",(long)receivedgreeGoodsCase ,(long)receivedgreeGoodsPack];
    }
    else
    {

        CGFloat singleCost = mrItem.unitCost.floatValue * mrItem.unitQuantityReceived.integerValue;
        CGFloat caseCost = mrItem.caseCost.floatValue * mrItem.caseQuantityReceived.integerValue;
        CGFloat packCost = mrItem.packCost.floatValue * mrItem.packQuantityReceived.integerValue;
        
        CGFloat freeSingleCost = mrItem.freeGoodCost.floatValue * mrItem.singleReceivedFreeGoodQty.integerValue;
        CGFloat freeCaseCost = mrItem.freeGoodCaseCost.floatValue * mrItem.caseReceivedFreeGoodQty.integerValue;
        CGFloat freePackCost = mrItem.freeGoodPackCost.floatValue * mrItem.packReceivedFreeGoodQty.integerValue;
        
        float extendedCost = singleCost + caseCost + packCost + freeSingleCost + freeCaseCost + freePackCost;
        
        NSInteger receivedgreeGoodsSingle = mrItem.unitQuantityReceived.integerValue + mrItem.singleReceivedFreeGoodQty.integerValue;
        NSInteger receivedgreeGoodsCase = mrItem.caseQuantityReceived.integerValue + mrItem.caseReceivedFreeGoodQty.integerValue;
        NSInteger receivedgreeGoodsPack = mrItem.packQuantityReceived.integerValue + mrItem.packReceivedFreeGoodQty.integerValue;
        
        cellmanualItem.txtReceivedSingelQty.text = [NSString stringWithFormat:@"%ld",(long)receivedgreeGoodsSingle];

        cellmanualItem.txtExtendedCost.text=[NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:extendedCost]];
        
        cellmanualItem.txtReceivedCasePackValue.text = [NSString stringWithFormat:@"%ld / %ld",(long)receivedgreeGoodsCase ,(long)receivedgreeGoodsPack];
    }
    
    NSDictionary *itemDictionary = mrItem.item.itemDictionary;
    
    // show Image for each item in cell
    NSString *itemImageURL = itemDictionary[@"ItemImage"];
    
    if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        NSString *imgString = @"noimage.png";
        cellmanualItem.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    }
    else if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<null>"])
    {
        NSString *imgString = @"noimage.png";
        cellmanualItem.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    }
    else
    {
        [cellmanualItem.itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",itemImageURL]]];
    }
    cellmanualItem.itemImage.layer.cornerRadius = 10.0;
    cellmanualItem.itemImage.clipsToBounds = YES;
    
    cellmanualItem.lblInventoryName.text = itemDictionary[@"ItemName"];
    cellmanualItem.txtQty.text = [NSString stringWithFormat:@"%@",itemDictionary[@"availableQty"]];
    
    NSString *barCode = self.txtUniversalSearch.text;
    NSString *itemCode = itemDictionary[@"ItemId"];
    
    BOOL isBarcodeExist = [self.updateManager doesBarcodeExist:barCode forItemCode:itemCode];
    if(isBarcodeExist)
    {
        cellmanualItem.lblBarcode.text = self.txtUniversalSearch.text;
    }
    else
    {
        cellmanualItem.lblBarcode.text = itemDictionary[@"Barcode"];
    }
    //cellItem.lblBarcode.textColor = [UIColor blackColor];
    cellmanualItem.lblItemNumber.text = itemDictionary[@"ItemNo"];
    
    
    cellmanualItem.txtCost.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:mrItem.unitCost.floatValue]];
    
    
    cellmanualItem.txtPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:mrItem.unitPrice.floatValue]];
    cellmanualItem.txtDiscount.text = @"";

    cellmanualItem.imgArrow.image = [UIImage imageNamed:@"RIM_Com_Arrow_Detail"];
    
    NSInteger minLevel = [itemDictionary[@"MinStockLevel"] integerValue];
    NSInteger availableQty = [itemDictionary[@"availableQty"] integerValue];
    if (minLevel >= 0)
    {
        if (availableQty <= minLevel)
        {
            cellmanualItem.qtyBackgroundImage.image=[UIImage imageNamed:@"globalred.png"];
        }
    }
    
    if(availableQty != 0)
    {
        Item *anItem = [self fetchAllItems:itemCode];
        NSMutableArray *itemPricingArray = [[NSMutableArray alloc]init];
        for (Item_Price_MD *pricing in anItem.itemToPriceMd)
        {
            NSMutableDictionary *pricingDict = [[NSMutableDictionary alloc]init];
            pricingDict[@"PriceQtyType"] = pricing.priceqtytype;
            pricingDict[@"Qty"] = pricing.qty;
            [itemPricingArray addObject:pricingDict];
        }
        
        NSPredicate *casePredicate = [NSPredicate predicateWithFormat:@"PriceQtyType = %@ AND Qty != 0" , @"Case"];
        NSArray *isCaseResult = [itemPricingArray filteredArrayUsingPredicate:casePredicate];
        NSString *caseValue;
        if(isCaseResult.count > 0)
        {
            NSString *caseQty  = [NSString stringWithFormat:@"%ld",(long)[[isCaseResult[0] valueForKey:@"Qty"] integerValue ]];
            float result = cellmanualItem.txtQty.text.floatValue/caseQty.floatValue;
            NSString *cq = [self getValueBeforeDecimal:result];
            NSInteger y = cellmanualItem.txtQty.text.integerValue % caseQty.integerValue;
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
            float result = cellmanualItem.txtQty.text.floatValue/caseQty.floatValue;
            NSString *pq = [self getValueBeforeDecimal:result];
            NSInteger x = cellmanualItem.txtQty.text.integerValue % caseQty.integerValue;
            x = labs(x);
            packValue = [NSString stringWithFormat:@"%@.%ld",pq,(long)x];
        }
        else
        {
            packValue = @"-";
        }
        
        if(([caseValue isEqualToString:@"-"]) && ([packValue isEqualToString:@"-"]))
        {
            cellmanualItem.txtCasePackValue.text = @"";
        }
        else if ([packValue isEqualToString:@"-"]) // Pack value not available
        {
            cellmanualItem.txtCasePackValue.text = [NSString stringWithFormat:@"%@ / -",caseValue];
        }
        else if ([caseValue isEqualToString:@"-"]) // Case value not available
        {
            cellmanualItem.txtCasePackValue.text = [NSString stringWithFormat:@"- / %@",packValue];
        }
        else
        {
            cellmanualItem.txtCasePackValue.text = [NSString stringWithFormat:@"%@ / %@",caseValue , packValue];
        }
    }
    else
    {
        cellmanualItem.txtCasePackValue.text = @"";
    }

    cellmanualItem.btnDelete.tag = indexPath.row;
    [cellmanualItem.btnDelete addTarget:self action:@selector(deleteManualEntryItemSwipe:) forControlEvents:UIControlEventTouchUpInside];
    
    [self recallManualEntryItemSwipe:cellmanualItem indexPath:indexPath];
    
    
    return cellmanualItem;
}


- (void)recallManualEntryItemSwipe:(ReceivedItemListCell *)cell_p indexPath:(NSIndexPath *)indexPath
{
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [cell_p addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell_p addGestureRecognizer:gestureLeft];
    
    if(!self.showView)
    {
        if(indexPath.section == self.indPath.section && indexPath.row == self.indPath.row)
        {
            cell_p.viewOperation.frame = CGRectMake(0, cell_p.viewOperation.frame.origin.y, cell_p.viewOperation.frame.size.width, cell_p.viewOperation.frame.size.height);
            cell_p.viewOperation.hidden = NO;
        }
        else
        {
            cell_p.viewOperation.frame = CGRectMake(913.0, cell_p.viewOperation.frame.origin.y, cell_p.viewOperation.frame.size.width, cell_p.viewOperation.frame.size.height);
            cell_p.viewOperation.hidden = YES;
        }
    }
}

#pragma mark - Left / Right / Edit / Delete swipe Method

-(void)didSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tblManulReceiveList];
    NSIndexPath *swipedIndexPath = [self.tblManulReceiveList indexPathForRowAtPoint:location];
    self.indPath = swipedIndexPath;
    strSwipeDire = @"Right";
    [self.tblManulReceiveList reloadData];
}

-(void)didSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tblManulReceiveList];
    NSIndexPath *swipedIndexPath = [self.tblManulReceiveList indexPathForRowAtPoint:location];
    if(self.indPath.row == swipedIndexPath.row)
    {
        self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        strSwipeDire = @"Left";
        [self.tblManulReceiveList reloadData];
    }
}



-(void)deleteManualEntryItemSwipe:(id)sender{
    
    NSIndexPath *indpath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    _selectedItemPath = indpath;
     manualItem = [self.meItemResultSetController objectAtIndexPath:_selectedItemPath];
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        strSwipeDire = @"Left";
        [self.tblManulReceiveList reloadData];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
       
        if(manualItem.receivedItemId.intValue==0)
        {
            [self deleteSingleManualEntryItemFromTable:manualItem];
            [self calculatetotalItemCost];
            manualItem=nil;
        }
        else{
            
            NSDictionary *dict = manualItem.manualPoItemSessionDictionary;
            
            strmanualItemId=[dict valueForKey:@"receivedItemId"];
            [self deleteManualEntryItems:strmanualItemId];
        }
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[NSString stringWithFormat:@"Are you sure you want to delete %@ item",manualItem.item.item_Desc] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

- (void)deleteManualEntryItems:(NSString *)strId
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    [param setValue:strId forKey:@"Id"];
    
    [param setValue:self.strManualPoID forKey:@"ManualEntryId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deleteManualEntryItemResponse:response error:error];
        });
    };
    
    self.deleteManualEntryItemServiceConnection = [self.deleteManualEntryItemServiceConnection initWithRequest:KURL actionName:WSM_DELETE_MANUAL_ENTRY_ITEM params:param completionHandler:completionHandler];

}

- (void)deleteManualEntryItemResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
                [self deleteManualEntryItemfromTable];
                [self calculatetotalItemCost];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -1)
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
                self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
                [self.tblManulReceiveList reloadData];
            }
            
            else
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Error occurred in delete Manual Entry Item" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

-(void)deleteManualEntryItemfromTable{
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSArray *manulPOsessionitem=[self.updateManager fetchAllPoitemDetailsFromID:privateContextObject withItemID:strmanualItemId];
    
    for (NSManagedObject *posessionItem in manulPOsessionitem)
    {
        [UpdateManager deleteFromContext:privateContextObject object:posessionItem];
    }
    [UpdateManager saveContext:privateContextObject];
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
   // _meItemResultSetController=nil;
   // [self.tblManulReceiveList reloadData];
}

-(void)deleteSingleManualEntryItemFromTable:(ManualReceivedItem *)reitem{
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    [UpdateManager deleteFromContext:privateContextObject objectId:[privateContextObject objectWithID:reitem.objectID].objectID];
    
    [UpdateManager saveContext:privateContextObject];
    
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
   // _meItemResultSetController=nil;
//[self.tblManulReceiveList reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(!self.showView)
    {
        
        _selectedItemPath = indexPath;
        manualItem = [self.meItemResultSetController objectAtIndexPath:indexPath];
        
        NSDictionary *itemDictionary = manualItem.item.itemDictionary;
        
        NSString *strItemcode = [itemDictionary valueForKey:@"ItemId"];
        
        Item *anItem = [self fetchAllItems:strItemcode];
        
        if(anItem == nil)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                NSDictionary *dict = manualItem.manualPoItemSessionDictionary;
                strmanualItemId = [dict valueForKey:@"receivedItemId"];
                [self deleteManualEntryItems:strmanualItemId];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[NSString stringWithFormat:@"Item was removed"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
        
        NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
       
        if(anItem.itemDepartment.deptName)
        {
            dictItemClicked[@"DepartmentName"] = anItem.itemDepartment.deptName;
        }
        else {
            dictItemClicked[@"DepartmentName"] = @"";
        }

        if(anItem.itemSubDepartment.subDeptName)
        {
            dictItemClicked[@"SubDepartmentName"] = anItem.itemSubDepartment.subDeptName;
        }
        else
        {
            dictItemClicked[@"SubDepartmentName"] = @"";
        }
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        ManualItemReceiveVC *manualItemReceiveTemp = [storyBoard instantiateViewControllerWithIdentifier:@"ManualItemReceiveVC"];
        
        manualItemReceiveTemp.manualPoID=self.strManualPoID;
        ItemInfoDataObject * itemData =[[ItemInfoDataObject alloc]init];
        [itemData setItemMainDataFrom:dictItemClicked];
        manualItemReceiveTemp.itemInfoDataObject = itemData;
        manualItemReceiveTemp.manualItemReceive = manualItem;
        [self.navigationController pushViewController:manualItemReceiveTemp animated:YES];
    
    }
}

-(void)loadManualItemReceiveItemList
{
    NSIndexPath *indPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self tableView:self.tblManulReceiveList didSelectRowAtIndexPath:indPath];
}

- (Item *)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
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

- (NSArray *)fetchManualReceivedItems :(NSInteger)itemId
{

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"ManualReceivedItem" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"supplierIDitems.manualPoId = %d AND item.itemCode = %d AND receivedItemId > 0",self.strManualPoID.integerValue,itemId];
    fetchRequest.predicate = predicatePO;
    
    return [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
}

- (NSString *)getValueBeforeDecimal:(float)result
{
    NSNumber *numberValue = @(result);
    NSString *floatString = numberValue.stringValue;
    NSArray *floatStringComps = [floatString componentsSeparatedByString:@"."];
    NSString *cq = [NSString stringWithFormat:@"%@",floatStringComps.firstObject];
    return cq;
}

- (void)setCellDefaultBackGroundImage:(ManualEntryCustomCell *)cellmanualItem
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        cellmanualItem.imgBackGround.image = [UIImage imageNamed:@"ListBg_iphone.png"];
    }
    else
    {
        cellmanualItem.imgBackGround.image = [UIImage imageNamed:@"ListBg_ipad.png"];
    }
}

-(IBAction)searchButtonClick:(id)sender
{
    if(!self.showView)
    {
        itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionHeaderVC" bundle:nil];
        
//        itemMultipleVC.managedObjectContext=[UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
        itemMultipleVC.managedObjectContext = self.rmsDbController.managedObjectContext;
        
        itemMultipleVC.objeNewSuppInfo=[dictSupplier mutableCopy];
        itemMultipleVC.checkSearchRecord = TRUE;
        itemMultipleVC.objNewItemReceiveList = self;
        itemMultipleVC.flgRedirectToOpenList = false;
        itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
        [self.navigationController pushViewController:itemMultipleVC animated:NO];
    }
    
}
-(void)didSelectionChangeInPOMultipleItemSelectionVC:(NSMutableArray *) selectedObject {
    for(int i=0;i<selectedObject.count;i++) {
        
        NSMutableDictionary *dictSelected = [selectedObject[i]mutableCopy];
        if([dictSelected  valueForKey:@"selected"]) {
    
            [self.arrayReceiveItem insertObject:dictSelected atIndex:0];
        }
    }
    [self didSelectItems:(NSArray *) self.arrayReceiveItem];
    [self.arrayReceiveItem removeAllObjects];

}
- (void)selectItemsFromResultSet:(NSArray *)resultSet {
    Item *item;
    for(int i=0;i<resultSet.count;i++)
    {
        item=resultSet[i];
        NSMutableDictionary *dictTempGlobal = [item.itemRMSDictionary mutableCopy];
        [self.arrayReceiveItem insertObject:dictTempGlobal atIndex:0];
    }
    if (resultSet.count>0)
    {
        [self didSelectItems:self.arrayReceiveItem];
        [self.arrayReceiveItem removeAllObjects];
    }
}

-(void)searchItemWithSearchString:(NSString *)strSearch{
    
      if(strSearch.length>0){
    
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
        fetchRequest.entity = entity;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(barcode == %@ OR ANY itemBarcodes.barCode == %@) AND active == %d", strSearch,strSearch,TRUE];
        fetchRequest.predicate = predicate;
        
        NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (resultSet.count==0)
        {
            BOOL valid;
            NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:strSearch];
            valid = [alphaNums isSupersetOfSet:inStringSet];
            if (valid) // numeric
            {
                [self callWebServiceForMissingItem:strSearch];
                return;
            }
            else // non numeric
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[NSString stringWithFormat:@"No Record Found for %@",strSearch] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
        
          [self selectItemsFromResultSet:resultSet];
      }
}

- (void)callWebServiceForMissingItem:(NSString *)code
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    });
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[self.rmsDbController trimmedBarcode:code] forKey:@"Code"];
    [itemparam setValue:@"Barcode" forKey:@"Type"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self responseForMissingItemResponse:response error:error];
    };
    
    self.missingItemWSC = [self.missingItemWSC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
    
}

-(void)responseForMissingItemResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if(response!=nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
        
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            
            NSPredicate *inActiveItemPredicate = [NSPredicate predicateWithFormat:@"Active == %@ AND isDeleted == %d", @(0),FALSE];
            
            NSArray *itemResponseArray = [[responseDictionary valueForKey:@"ItemArray"] filteredArrayUsingPredicate:inActiveItemPredicate];
            if(itemResponseArray.count > 0)
            {
                NSDictionary *itemDict = itemResponseArray.firstObject;
                if ([[[itemDict valueForKey:@"Active"] stringValue] isEqualToString:@"0"]) // if not active item
                {
                    ManualEntryRecevieItemList * __weak myWeakReference = self;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        NSString *strItemId = [NSString stringWithFormat:@"%@",[itemDict valueForKey:@"ITEMCode"]];
                        Item *currentItem = [self fetchAllItems:strItemId];
                        [myWeakReference moveItemToActiveList:currentItem];
                    };
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"This item is inactive would you like to activate it?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                }
                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[NSString stringWithFormat:@"No Record Found for %@",barcodeString] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            
        }
    }
}

- (void)moveItemToActiveList:(Item *)anItem
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * dictItemInfo;
    dictItemInfo = [self getParamToActiveItem:anItem isItemActive:@"1"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self responseForMoveItemToActiveResponse:response error:error];
            });
    };
    
    self.itemActiveWSC = [self.itemActiveWSC initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:dictItemInfo completionHandler:completionHandler];
}

-(void)responseForMoveItemToActiveResponse:(id)response error:(NSError *)error {

    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            
            if ([response count] > 0) {   //  InvItemUpdateNewBarcodeResult
                if ([[response valueForKey:@"IsError"] intValue] == 0) {
                    NSString * strItemId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
                    Item * currentItem = [self fetchAllItems:strItemId];
                    currentItem.active = @1;
                    NSError *error = nil;
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                    }
                    [self selectItemsFromResultSet:@[currentItem]];
                }
                else{
                    NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n Item not updated, try again."};
                    [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                    
                    [_activityIndicator hideActivityIndicator];
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Item not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
            }
        }

    }

    [_activityIndicator hideActivityIndicator];
    [self updateDataInDataBase_RIM];
    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
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

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([configuration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

-(void)searchItemWithSearchItemNumberString:(NSString *)intItemNo
{
    if(intItemNo.length>0){
        
        Item *item=nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
        fetchRequest.entity = entity;
        NSPredicate *predicate;
        if ([self isSubDepartmentEnableInBackOffice]) {
            predicate = [NSPredicate predicateWithFormat:@"barcode == %@ OR ANY itemBarcodes.barCode == %@ OR item_No == %@ AND active == %d",intItemNo,intItemNo , intItemNo,TRUE];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"(barcode == %@ OR ANY itemBarcodes.barCode == %@ OR item_No == %@ AND active == %d) AND itm_Type != %@",intItemNo,intItemNo , intItemNo,TRUE,@(2)];
        }
        fetchRequest.predicate = predicate;
        
        NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (resultSet.count==0)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[NSString stringWithFormat:@"No Record Found for %@",intItemNo] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        for(int i=0;i<resultSet.count;i++)
        {
            item=resultSet[i];
            NSMutableDictionary *dictTempGlobal = [item.itemRMSDictionary mutableCopy];
            [self.arrayReceiveItem insertObject:dictTempGlobal atIndex:0];
        }
        
        if (resultSet.count>0)
        {
            [self didSelectItems:self.arrayReceiveItem];
            [self.arrayReceiveItem removeAllObjects];
        }

    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.txtBarcodeSearch){
        barcodeString = self.txtBarcodeSearch.text;
        [self searchItemWithSearchString:self.txtBarcodeSearch.text];
        [textField resignFirstResponder];
        textField.text=@"";
    }
    else if(textField == self.txtUniversalSearch){
        if(_isHistory){
            [self searchBarcodeItem];

        }
        else{
            barcodeString = self.txtUniversalSearch.text;
            [self searchItemWithSearchItemNumberString:self.txtUniversalSearch.text];
            [textField resignFirstResponder];
            textField.text=@"";

        }
    }
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    [_arrItemCode removeAllObjects];
    _txtUniversalSearch.text = @"";
    
    self.meItemResultSetController = nil;
    [self.tblManulReceiveList reloadData];
    return YES;
}

- (void)searchBarcodeItem
{
    
    BOOL isNumeric;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:_txtUniversalSearch.text];
    isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) // numeric
    {
        _txtUniversalSearch.text = [self.rmsDbController trimmedBarcode:_txtUniversalSearch.text];
    }
    
    //    BOOL isScanItemfound = FALSE;
    
    //  Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barcode == %@ OR ANY itemBarcodes.barCode == %@ OR item_No == %@ AND active == %d",_txtUniversalSearch.text,_txtUniversalSearch.text , _txtUniversalSearch.text,TRUE];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0)
    {
        _arrItemCode = [[NSMutableArray alloc]init];
        self.meItemResultSetController = nil;
        for (Item * item in resultSet) {
            [_arrItemCode addObject:[NSString stringWithFormat:@"%@",item.itemCode]];
            
        }
        NSFetchRequest *fetchRequestReconcileCount = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityReconcileCount = [NSEntityDescription entityForName:@"ManualReceivedItem" inManagedObjectContext:self.managedObjectContext];
        fetchRequestReconcileCount.entity = entityReconcileCount;
        NSPredicate *itemSearchPredicate = [self itemSearchPredicate];
        fetchRequestReconcileCount.predicate = itemSearchPredicate;
        
        
        NSArray *tempResultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequestReconcileCount];
        
        if (tempResultSet.count > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tblManulReceiveList reloadData];
            });
            
        }
        else{
            [self noRecordFound];
            return;
        }
    }
    else
    {
        [self noRecordFound];
        return;
    }
}
-(NSPredicate *)itemSearchPredicate{
    NSMutableArray *arrPredicate = [[NSMutableArray alloc]init];
    for (NSString *strItemCode in _arrItemCode) {
        NSPredicate *itemSearchPredicate = [NSPredicate predicateWithFormat:@"item.itemCode = %@",strItemCode];
        [arrPredicate addObject:itemSearchPredicate];
    }
    NSPredicate *finalPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:arrPredicate];
    return finalPredicate;
    
}

- (NSPredicate *)manualPredicate
{
    NSPredicate *predicate;
    if (_txtUniversalSearch.text.length > 0 && _arrItemCode && _arrItemCode.count > 0) {
        
        NSPredicate *finalPredicate = [self itemSearchPredicate];
        return finalPredicate;
    }
    
    predicate = [NSPredicate predicateWithFormat:@"supplierIDitems.manualPoId = %d",self.strManualPoID.integerValue];
    return predicate;
}


-(void)noRecordFound{
    [_arrItemCode removeAllObjects];
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {};
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:[NSString stringWithFormat:@"No Record Found for %@",_txtUniversalSearch.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    _txtUniversalSearch.text = @"";
    
}

-(void)didSelectItems:(NSArray *) selectedItems{
    
    //selectedItems = [self removeAlreadyExitsItemFromArray:selectedItems];
    for (int i = 0 ; i < selectedItems.count; i++)
    {
        NSString *itemCode = [NSString stringWithFormat:@"%@",[selectedItems[i] valueForKey:@"ItemId"]];
        Item *anItem = [self fetchAllItems:itemCode];
 
        NSMutableDictionary *dict =  [self createPricisingDictionary:anItem];
        if (selectedItems.count == 1)
        {
            manualItem = nil;
            NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];

            manualItem = [self.updateManager updateItemReceiveListwithDetailReturn:dict withItem:(Item *)OBJECT_COPY(anItem, privateContextObject) withitemReceive:(ManualReceivedItem *)OBJECT_COPY(manualItem, privateContextObject) withManualPoSession:
                         (ManualPOSession *)OBJECT_COPY(_posession, privateContextObject) withManageObjectContext:privateContextObject];
            
            manualItem = (ManualReceivedItem *)OBJECT_COPY(manualItem, self.managedObjectContext);
            _posession = (ManualPOSession *)OBJECT_COPY(_posession, self.managedObjectContext);
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
            manualItemReceiveVC = [storyBoard instantiateViewControllerWithIdentifier:@"ManualItemReceiveVC"];
            
            manualItemReceiveVC.manualPoID=self.strManualPoID;
            ItemInfoDataObject * itemData =[[ItemInfoDataObject alloc]init];
            [itemData setItemMainDataFrom:selectedItems[i]];
            manualItemReceiveVC.itemInfoDataObject = itemData;
            manualItemReceiveVC.manualItemReceive = manualItem;
            
            [self.navigationController pushViewController:manualItemReceiveVC animated:YES];
            manualItem = nil;
        }
        else
        {
            NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
            [self.updateManager updateItemReceiveListwithDetail:dict withItem:(Item *)OBJECT_COPY(anItem, privateContextObject) withitemReceive:nil withManualPoSession:(ManualPOSession *)OBJECT_COPY(_posession, privateContextObject) withManageObjectContext:privateContextObject];
            _posession = (ManualPOSession *)OBJECT_COPY(_posession, self.managedObjectContext);
        }
    }
//    _meItemResultSetController = nil;
//    [self.tblManulReceiveList reloadData];
}

-(NSArray *)removeAlreadyExitsItemFromArray:(NSArray *) selectedItems
{
    NSMutableArray *listArray = [[NSMutableArray alloc] init];
    NSMutableArray *arrayTemp = (NSMutableArray *)selectedItems;
    for(int i=0; i<arrayTemp.count; i++)
    {
        NSMutableDictionary *dict = selectedItems[i];
        BOOL checkisExits = [self checkItemisAlreadyIntheList:[dict valueForKey:@"ItemId"]];
        if(!checkisExits)
        {
            [listArray addObject:dict];
        }
    }
    return (NSArray *)listArray;
}

-(NSMutableDictionary *)createPricisingDictionary:(Item *)pitem
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualReceivedItem" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"supplierIDitems.manualPoId = %d AND item.itemCode = %d",self.strManualPoID.integerValue,pitem.itemCode.intValue];
    
    fetchRequest.predicate = predicatePO;
    
    // Create the sort descriptors array.

    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];

    if (resultSet.count>0) {
        ManualReceivedItem * objMPO = (ManualReceivedItem *)resultSet.firstObject;
        dict = [[NSMutableDictionary alloc] initWithDictionary:objMPO.manualPoItemSessionDictionary];
        [dict removeObjectForKey:@"isReturn"];
        [dict removeObjectForKey:@"receivedItemId"];
    }
    else {
        for (Item_Price_MD *pricing in pitem.itemToPriceMd)
        {
            if([pricing.priceqtytype isEqualToString:@"Single item"] || [pricing.priceqtytype isEqualToString:@"Single Item"])
            {
                dict[@"unitCost"] = pricing.cost;
                dict[@"unitMarkup"] = pricing.profit;
                dict[@"unitPrice"] = pricing.unitPrice;
                dict[@"unitQtyonHand"] = pricing.qty;
            }
            else if([pricing.priceqtytype isEqualToString:@"Pack"])
            {
                dict[@"packCost"] = pricing.cost;
                dict[@"packMarkup"] = pricing.profit;
                dict[@"packPrice"] = pricing.unitPrice;
                dict[@"packQtyonHand"] = pricing.qty;
                
            }
            else if([pricing.priceqtytype isEqualToString:@"Case"])
            {
                dict[@"caseCost"] = pricing.cost;
                dict[@"caseMarkup"] = pricing.profit;
                dict[@"casePrice"] = pricing.unitPrice;
                dict[@"cashQtyonHand"] = pricing.qty;
            }
            
        }
    }
    
    dict[@"unitQuantityReceived"] = @"0";
    dict[@"packQuantityReceived"] = @"0";
    dict[@"caseQuantityReceived"] = @"0";
    
    dict[@"createDate"] = [NSDate date];
    dict[@"singleReceivedFreeGoodQty"] = @"0";
    dict[@"caseReceivedFreeGoodQty"] = @"0";
    dict[@"packReceivedFreeGoodQty"] = @"0";
    dict[@"freeGoodCost"] = @"0.00";
    dict[@"freeGoodCaseCost"] = @"0.00";
    dict[@"freeGoodPackCost"] = @"0.00";
    
    return  dict;
}

-(IBAction)addNewItem:(id)sender{
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"You don't have rights to add new item. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    if(!self.showView)
    {
//        InventoryAddNewSplitterVC *addNewSplitterVC = [[InventoryAddNewSplitterVC alloc] initWithNibName:@"InventoryAddNewSplitterVC-ipad" bundle:nil];
//        addNewSplitterVC.searchedBarcode = @"";
//        
//        NSMutableDictionary *navigationInfo = [[NSMutableDictionary alloc] init ];
//        [navigationInfo setObject:@(TRUE) forKey:@"NewOrderCalled"];
//        [navigationInfo setObject:self forKey:@"manualEntryReceiveItem"];
//        addNewSplitterVC.navigationInfo=navigationInfo;
//        addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        [self presentViewController:addNewSplitterVC animated:YES completion:nil];
        ItemDetailEditVC *addNewSplitterVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
        addNewSplitterVC.selectedItemInfoDict = nil;
        if (dictSupplier && [dictSupplier objectForKey:@"Suppid"]) {
            
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
            fetchRequest.entity = entity;
            
            NSPredicate *salesRep = [NSPredicate predicateWithFormat:@"companyId == %@",[dictSupplier objectForKey:@"Suppid"]];
            fetchRequest.predicate = salesRep;
            NSArray * arrSup = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
            if (arrSup && arrSup.count > 0) {
                SupplierCompany * objSelectedSup = arrSup.firstObject;
                
                
                NSMutableDictionary * dictSupInfo = [NSMutableDictionary dictionary];
                dictSupInfo[@"CompanyName"] = objSelectedSup.companyName;
                dictSupInfo[@"ContactNo"] = objSelectedSup.phoneNo;
                dictSupInfo[@"Email"] = objSelectedSup.email;
                dictSupInfo[@"ItemCode"] = @(0);
                dictSupInfo[@"SalesRepresentatives"] = [NSMutableArray array];
                dictSupInfo[@"VendorId"] = objSelectedSup.companyId;
                
                addNewSplitterVC.predefineInfoItemInfoDict = [NSMutableDictionary dictionary];
                addNewSplitterVC.predefineInfoItemInfoDict[@"ItemSupplierData"] = @[dictSupInfo];
            }
        }
        
        NSMutableDictionary *navigationInfo = [[NSMutableDictionary alloc] init ];
        navigationInfo[@"isWaitForLiveUpdate"] = @(TRUE);
        addNewSplitterVC.navigationInfo=navigationInfo;

        
        addNewSplitterVC.isItemCopy = FALSE;
        addNewSplitterVC.itemInfoEditRedirectionVCDelegate = self;
        addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:addNewSplitterVC animated:YES completion:nil];
    }
}
- (void)ItemInfornationChangeAt:(NSInteger )indexRow WithNewData:(id)newItemInfo {
    [self didSelectItems:newItemInfo];
}
-(IBAction)back:(id)sender
{
      [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)didSelectManu:(NSString *) strManuName{
    
    [self hideMenu];
}

-(NSString *)htmlBillHeader:(NSString *)html invoiceArray:(NSMutableArray *)arrayInvoice
{
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:@"ManualEntry"];
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS1$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"]]];
     html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS2$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$EMAIL$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Email"]]];

    html = [html stringByReplacingOccurrencesOfString:@"$$PHONE$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"PhoneNo1"]]];

    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$INVOICE_NO$$" withString:[NSString stringWithFormat:@"%@",self.strInvoiceNo]];
    
    if(dictSupplier && [dictSupplier valueForKey:@"SuppName"]){
        
         html = [html stringByReplacingOccurrencesOfString:@"$$SUPPLIER_NAME$$" withString:[NSString stringWithFormat:@"%@",dictSupplier[@"SuppName"]]];
    }
    else{
         html = [html stringByReplacingOccurrencesOfString:@"$$SUPPLIER_NAME$$" withString:[NSString stringWithFormat:@"%@",@"N/A"]];
    }
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *currentDateValue = [formatter stringFromDate:currentDate];
    
    NSString *strDate = [self getStringFormate:currentDateValue fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MM/dd/yyyy"];
    NSString *strTime = [self getStringFormate:currentDateValue fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:strDate];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    
    return html;
}

-(NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    return result;
}

// Modified by Hitendra
-(NSString *)htmlBillTextForItem:(NSMutableArray *)arrayInvoice1
{
    NSString *itemHtml = @"";
    
//    NSMutableArray *arrTemp = [[arrayInvoice1 valueForKeyPath:@"self.item"]mutableCopy];
//
//    NSMutableArray * arrUniqeItemIds = [[arrTemp valueForKey:@"itemCode"] mutableCopy];
//    
//    [arrUniqeItemIds removeObject:[[NSNull alloc]init]];
    
//    NSSet * itemCode = [[NSSet alloc]initWithArray:arrUniqeItemIds];
//    arrUniqeItemIds = [itemCode.allObjects mutableCopy];
    
    for (ManualReceivedItem *mrItem in arrayInvoice1) {
//        NSArray *arrItems = [self fetchManualReceivedItems:mrItem.itemCode.integerValue];
//        if (arrItems.count > 0) {
//            ManualReceivedItem *mrItem = arrItems.firstObject;
            //            if((mrItem.isReturn).integerValue != 1){
            
            NSMutableDictionary *dictTemp  = [mrItem.manualPoItemSessionDictionary mutableCopy];
            NSDictionary *itemDictionary = mrItem.item.itemDictionary;
            if(itemDictionary != nil) {
                
                dictTemp[@"Barcode"] = [itemDictionary valueForKey:@"Barcode"];
                dictTemp[@"ItemNo"] = [itemDictionary valueForKey:@"ItemNo"];
                dictTemp[@"ItemName"] = [itemDictionary valueForKey:@"ItemName"];
                dictTemp[@"unitQtyonHand"] = [itemDictionary valueForKey:@"availableQty"];
            
                NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:dictTemp withManualItem:mrItem];
                itemHtml = [itemHtml stringByAppendingFormat:@"%@",strHTML];
            }
    }
    return itemHtml;
}

-(NSString *)htmlBillTextGenericForItemwithDictionary:(NSDictionary *)itemDictionary withManualItem:(ManualReceivedItem *)mrItem
{
    
    //    NSInteger receivedTotalSingleQty  = 0;
    //    NSInteger receivedTotalCaseQty  = 0;
    //    NSInteger receivedTotalPackQty  = 0;
    
    CGFloat singleAllCost = 0;
    CGFloat caseAllCost = 0;
    CGFloat packAllCost = 0;
    
    //    for (ManualReceivedItem *mrItem in arrmrItem) {
    
    NSInteger currentSingleQty  = 0;
    NSInteger currentCaseQty  = 0;
    NSInteger currentPackQty  = 0;
    
    NSInteger currentFGSingleQty  = 0;
    NSInteger currentFGCaseQty  = 0;
    NSInteger currentFGPackQty  = 0;
    
    currentSingleQty = labs(mrItem.unitQuantityReceived.integerValue);
    currentFGSingleQty = labs(mrItem.singleReceivedFreeGoodQty.integerValue);
    
    currentCaseQty = labs(mrItem.caseQuantityReceived.integerValue);
    currentFGCaseQty = labs(mrItem.caseReceivedFreeGoodQty.integerValue);
    
    currentPackQty = labs(mrItem.packQuantityReceived.integerValue);
    currentFGPackQty = labs(mrItem.packReceivedFreeGoodQty.integerValue);
    
    if (mrItem.isReturn.boolValue) {
        
        singleAllCost -= mrItem.unitCost.floatValue * currentSingleQty + mrItem.freeGoodCost.floatValue * currentFGSingleQty;
        caseAllCost -= mrItem.caseCost.floatValue * currentCaseQty + mrItem.freeGoodCaseCost.floatValue * currentFGCaseQty;
        packAllCost -= mrItem.packCost.floatValue * currentPackQty + mrItem.freeGoodPackCost.floatValue * currentFGPackQty;
        currentSingleQty = currentSingleQty * (-1);
        currentFGSingleQty = currentFGSingleQty * (-1);
        currentCaseQty = currentCaseQty * (-1);
        currentFGCaseQty = currentFGCaseQty * (-1);
        currentPackQty = currentPackQty * (-1);
        currentFGPackQty = currentFGPackQty * (-1);
    }
    else{
        singleAllCost += mrItem.unitCost.floatValue * currentSingleQty + mrItem.freeGoodCost.floatValue * currentFGSingleQty;
        caseAllCost += mrItem.caseCost.floatValue * currentCaseQty + mrItem.freeGoodCaseCost.floatValue * currentFGCaseQty;
        packAllCost += mrItem.packCost.floatValue * currentPackQty + mrItem.freeGoodPackCost.floatValue * currentFGPackQty;
    }
    float extendedCost = singleAllCost + caseAllCost + packAllCost;
    
    NSNumber *extendedCostnum = @(extendedCost);
    NSString *htmldata = @"";
    
    int totalUnitQty = (int)currentSingleQty ;
    int totalCaseQty = (int)currentCaseQty;
    int totalPackQty = (int)currentPackQty;
    
    int qtyonHand = 0;
    if(!self.showView)
    {
        qtyonHand = [itemDictionary[@"unitQtyonHand"]intValue];
        
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font></td><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font></td><td align=\"left\" valign=\"top\" style=\"width:25%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%d</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%d</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%d</font></td><td align=\"right\" font size=\"2\">%.2f</font></td><td font size=\"2\" align=\"right\">%.2f</font></td><td font size=\"2\" align=\"right\">%.2f</font></td></tr>",itemDictionary[@"Barcode"],itemDictionary[@"ItemNo"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"unitQtyonHand"],totalUnitQty,totalCaseQty,totalPackQty,[itemDictionary[@"unitCost"] floatValue],[itemDictionary[@"unitPrice"] floatValue],extendedCostnum.floatValue];
    }
    else{
        
        float totalReceiveQty = totalUnitQty + totalCaseQty + totalPackQty;
        
        qtyonHand = [itemDictionary[@"unitQtyonHand"] intValue] - totalReceiveQty;
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font></td><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font></td><td align=\"left\" valign=\"top\" style=\"width:25%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%d</font></td></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%d</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%d</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%d</font></td><td align=\"right\" font size=\"2\">%.2f</font></td><td font size=\"2\" align=\"right\">%.2f</font></td><td font size=\"2\" align=\"right\">%.2f</font></td></tr>",itemDictionary[@"Barcode"],itemDictionary[@"Barcode"],@"%",itemDictionary[@"ItemName"],qtyonHand,totalUnitQty,totalCaseQty,totalPackQty,[itemDictionary[@"unitCost"] floatValue],[itemDictionary[@"unitPrice"] floatValue],extendedCostnum.floatValue];
        
    }
    _totAvaialbeQty += qtyonHand;
    _totReceivingQty += totalUnitQty;
    _totReceivingCase += totalCaseQty;
    _totReceivingPack += totalPackQty;
    _TotalCost += [itemDictionary[@"unitCost"]floatValue];
    _TotalPrice += [itemDictionary[@"unitPrice"]floatValue];
    _TotalExtendedPrice += extendedCostnum.floatValue;
    _totNumberOfProduct++;
    return htmldata;
    
}
-(NSMutableArray *)getAllReceivingItems{
    
    NSArray *arrayItems = [self fetchAllReceivingItems];
    [_previewItemArray removeAllObjects];
    for(int i=0;i<arrayItems.count;i++)
    {
        ManualReceivedItem *ritem  = (ManualReceivedItem *)arrayItems[i];
        [_previewItemArray addObject:ritem];
    }
    return _previewItemArray;
}

//hiten
-(IBAction)previewandPrint:(id)sender{
    
    _previewItemArray = [self getAllReceivingItems];
    NSArray *sortDescriptorArray = [self sortForPreference:sortingPreference];
    [_previewItemArray sortUsingDescriptors:sortDescriptorArray];
    if(_previewItemArray.count>0)
    {
        [self htmlBillTextForPreview:_previewItemArray];
    }
}
-(void)htmlBillTextForPreview:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ManualEntryItems" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];

    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:nil];
    // set Html itemDetail
    
    _TotalExtendedPrice = 0.00;
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
  
//    NSMutableArray *arrTemp = [[arryInvoice valueForKeyPath:@"self.item"]mutableCopy];
//    
//    NSMutableArray * arrUniqeItemIds = [[arrTemp valueForKey:@"itemCode"] mutableCopy];
//    
//    
    
    if (![itemHtml isEqualToString:@""]) {
        self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
        self.emaiItemHtml = [self htmlTotalQtyCostAndPrice:self.emaiItemHtml];
        /// Write Data On Document Directory.......
        NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
        [self writeDataOnCacheDirectory:data];
        
        self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                             pathForPDF:@"~/Documents/ManualEntryItems.pdf".stringByExpandingTildeInPath
                                               delegate:self
                                               pageSize:kPaperSizeA4
                                                margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    }
}

-(NSString *)htmlTotalQtyCostAndPrice:(NSString *)html
{   
    NSString *strAQy =[NSString stringWithFormat:@""];
    NSString *strRecsing =[NSString stringWithFormat:@"%d",_totReceivingQty];
    NSString *strRecCase =[NSString stringWithFormat:@"%d",_totReceivingCase];
    NSString *strRecpack =[NSString stringWithFormat:@"%d",_totReceivingPack];
    
    NSArray *fetchedData = [self.meItemResultSetController fetchedObjects];
    NSArray *arrBarcode = [fetchedData valueForKeyPath:@"@distinctUnionOfObjects.item.barcode"];
    
    NSString *strItemCount =[NSString stringWithFormat:@"%lu Products",(unsigned long)arrBarcode.count];
    
 //   NSString *strCost =[NSString stringWithFormat:@"%.2f",_TotalCost];
  //  NSString *strPrice =[NSString stringWithFormat:@"%.2f",_TotalPrice];
    NSString *strExtPrice =[NSString stringWithFormat:@"%.2f",_TotalExtendedPrice];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOT_ITEM_COUNT$$" withString:strItemCount];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOT_AVA_QTY$$" withString:strAQy];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOT_REC_SING$$" withString:strRecsing];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOT_REC_CASE$$" withString:strRecCase];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOT_REC_PACK$$" withString:strRecpack];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOT_COST$$" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOT_SPRICE$$" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOT_EXTPRICE$$" withString:strExtPrice];
    _totAvaialbeQty = 0;
    _totReceivingQty = 0;
    _totReceivingPack = 0;
    _totReceivingCase = 0;
    _TotalCost = 0.00;
    _TotalPrice = 0.00;
    _TotalExtendedPrice = 0.00;
    _totNumberOfProduct = 0;
    return html;
}

-(void)writeDataOnCacheDirectory :(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.emaiItemHtml])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.emaiItemHtml error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.emaiItemHtml = [documentsDirectory stringByAppendingPathComponent:@"ItemInfo.html"];
    [data writeToFile:self.emaiItemHtml atomically:YES];
}

#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
}

-(void)openDocumentwithSharOption:(NSString *)strpdfUrl{
    // here's a URL from our bundle
    NSURL *documentURL = [[NSURL alloc]initFileURLWithPath:strpdfUrl];
    
    // pass it to our document interaction controller
    self.controller.URL = documentURL;
    // present the preview
    [self.controller presentPreviewAnimated:YES];
    
}


- (UIDocumentInteractionController *)controller {
    
    if (!_controller) {
        _controller = [[UIDocumentInteractionController alloc]init];
        _controller.delegate = self;
    }
    return _controller;
}

#pragma mark - Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if(controller != _meItemResultSetController)
    {
        [self unlockResultController];
        return;
    }
    else if (_meItemResultSetController == nil){
        [self unlockResultController];
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblManulReceiveList beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != _meItemResultSetController)
    {
        return;
    }
    else if (_meItemResultSetController == nil){
        return;
    }

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblManulReceiveList insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblManulReceiveList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tblManulReceiveList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tblManulReceiveList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tblManulReceiveList insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(controller != _meItemResultSetController)
    {
        return;
    }
    else if (_meItemResultSetController == nil){
        return;
    }

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblManulReceiveList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblManulReceiveList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != _meItemResultSetController)
    {
        return;
    }
    else if (_meItemResultSetController == nil){
        return;
    }

    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tblManulReceiveList endUpdates];
    [self unlockResultController];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [itemMultipleVC cancelClick:nil];
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)manualEntryLock {
    if (_manualEntryLock == nil) {
        _manualEntryLock = [[NSRecursiveLock alloc] init];
    }
    return _manualEntryLock;
}

-(void)lockResultController
{
    [self.manualEntryLock lock];
}

-(void)unlockResultController
{
    [self.manualEntryLock unlock];
}

-(void)setMeItemResultSetController:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.manualEntryLock];
    _meItemResultSetController = resultController;
    [lock unlock];
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
