//
//  ICHomeVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 31/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemReconcileListVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
//#import "ItemInfoEditVC.h"
#import "ICQtyEditVC.h"
//#import "InventoryCountItemSelectionVC.h"
#import "ICHomeVC.h"

// custom cell import
#import "ItemCountListCustomCell.h"

// Core data table import
#import "Item+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "ItemInventoryCount+Dictionary.h"
#import "ItemInventoryCountSession+Dictionary.h"

#import "ItemInventoryReconcileCount.h"
#import "EmailFromViewController.h"
#import "NDHTMLtoPDF.h"
#import "ICReconcileCompletePopUp.h"
#import "InventoryItemSelectionListVC.h"
#import "CameraScanVC.h"
#import "BarCodeSearch+Dictionary.h"
#import "BarCodeSearch.h"
#import "ICReconcileStatusVC.h"
#import "IntercomHandler.h"

typedef NS_ENUM(NSUInteger, ItemReconcileList) // itemInfoSectionArray
{
    ItemReconcileListAll,
    ItemReconcileListUnMatched,
    ItemReconcileListMatched,
    ItemReconcileListUncounted,
};

@interface ItemReconcileListVC () <UITableViewDelegate,UITableViewDataSource,UpdateDelegate,NSFetchedResultsControllerDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate , EmailFromViewControllerDelegate , ReconcileCompletePopupVCDelegate,CameraScanVCDelegate,InventoryItemSelectionListVCDelegate
#ifdef LINEAPRO_SUPPORTED
,DTDeviceDelegate
#endif
>{
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
    
    BarCodeSearch *barcodeSearch;
    ItemReconcileList itemReconcileListType;
    EmailFromViewController *emailFromViewController;
    ICReconcileCompletePopUp *iCReconcileCompletePopUp;
    NSDictionary *itemIncDictionary;
    BOOL includeUncountedItem;
    BOOL isShareClicked;
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UITableView *reConcileItemListTableView;
@property (nonatomic, weak) IBOutlet UIButton *allBtn;
@property (nonatomic, weak) IBOutlet UIButton *unMatchedBtn;
@property (nonatomic, weak) IBOutlet UIButton *matchedBtn;
@property (nonatomic, weak) IBOutlet UIButton *unCountedBtn;
@property (nonatomic, weak) IBOutlet UIButton *moreBtn;
@property (nonatomic, weak) IBOutlet UIButton *completeBtn;
@property (nonatomic, weak) IBOutlet UITextField *searchDescription;
@property (nonatomic, weak) IBOutlet UIView *compConformView;
@property (nonatomic, weak) IBOutlet UIView *conformInnerView;
@property (nonatomic, weak) IBOutlet UIView *roundedView;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, weak) IBOutlet UITextField *searchBarcode;

@property (nonatomic, weak) IBOutlet UIButton *sendUncounted;
@property (nonatomic, weak) IBOutlet UIButton *ignoreUncounted;
@property (nonatomic, weak) IBOutlet UIButton *cancelComplete;
@property (nonatomic, weak) IBOutlet UIButton *continueComplete;
@property (nonatomic, weak) IBOutlet UILabel *invCountTitle;
@property (nonatomic, weak) IBOutlet UIButton *shareOrderClicked;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *iReconcileUpdateManager;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, weak) IBOutlet UITextField *txtUniversalSearch;

@property (nonatomic, strong) RapidWebServiceConnection *completedReconcileCountWC;
@property (nonatomic, strong) RapidWebServiceConnection *reconcileCountDataWC;
@property (nonatomic, strong) RapidWebServiceConnection *responseCloseInvCountWC;
@property (nonatomic, strong) RimsController *rimController;

@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSString *emaiItemHtml;
@property (nonatomic, strong) NSString * strSearchText;
@property (nonatomic, strong) NSMutableArray * arrItemCode;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *itemInventoryCountResultController;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation ItemReconcileListVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize iReconcileUpdateManager;

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
    self.completedReconcileCountWC = [[RapidWebServiceConnection alloc] init];
    self.responseCloseInvCountWC = [[RapidWebServiceConnection alloc] init];
    self.reconcileCountDataWC = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.iReconcileUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    includeUncountedItem = NO;
    
    _conformInnerView.layer.cornerRadius = 10.0;
    _continueComplete.layer.cornerRadius = 5.0;
    _continueComplete.layer.masksToBounds = YES;
    _cancelComplete.layer.cornerRadius = 5.0;
    _cancelComplete.layer.masksToBounds = YES;
    
    isShareClicked = FALSE;
    
#ifdef LINEAPRO_SUPPORTED
    // Linea Barcode device connection
    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [dtdev connect];
#endif

    [_roundedView.layer setCornerRadius:18.0f];
    _roundedView.clipsToBounds = YES;
    if (IsPhone()) {
        
        self.reConcileItemListTableView.estimatedRowHeight = 95;
        self.reConcileItemListTableView.rowHeight = UITableViewAutomaticDimension;

    }

    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"helpbtn.png" selectedImage:@"helpbtnselected.png" withViewController:self];

    // Do any additional setup after loading the view from its nib.
    //[self itemInventoryCountResultController];
    /// Get The Cuurent itemInventoryCountSession here....
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    self.navigationController.navigationBarHidden = YES;
    self.rimController.scannerButtonCalled=@"ItemReconcileList";
    if(self.isViewOnly)
    {
        _completeBtn.enabled = NO;
    }
    else
    {
        _completeBtn.enabled = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    itemIncDictionary = self.reConcileItemInvCountSession.itemInventoryCountDictionary;
    _invCountTitle.text = [NSString stringWithFormat:@"INC #%@",[itemIncDictionary valueForKey:@"StockSessionId"]];

    if(!isShareClicked)
    {
        [self getReconcileCountData];
        
    }
    else
    {
        [_activityIndicator hideActivityIndicator];
        isShareClicked = FALSE;
    }
}

-(void)getReconcileCountData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryCountSession" inManagedObjectContext:privateContextObject];
    fetchRequest.entity = entity;

//     NSArray *arryTemp = [UpdateManager executeForContext:privateContextObject FetchRequest:fetchRequest];
//    for (NSManagedObject *product in arryTemp)
//    {
//        [UpdateManager deleteFromContext:privateContextObject object:product];
//    }
//    [UpdateManager saveContext:privateContextObject];

    // DELETE EXISTING SESSION AND CALL ITEM OF THAT STOCK SESSION ID
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    [param setValue:[itemIncDictionary valueForKey:@"StockSessionId"] forKey:@"StockSessionId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    if(self.isReconcileHistory) // Get History Data
    {
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self responseCompletedReconcileCountDataResponse:response error:error];
        };
        
        self.completedReconcileCountWC = [self.completedReconcileCountWC initWithRequest:KURL actionName:WSM_COMPLETED_RECONCILE_COUNT_DATA params:param completionHandler:completionHandler];
    }
    else
    {
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self responseReconcileCountDataResponse:response error:error];
        };
        
        self.reconcileCountDataWC = [self.reconcileCountDataWC initWithRequest:KURL actionName:WSM_RECONCILE_COUNT_DATA params:param completionHandler:completionHandler];
    }
}

- (void)reconcileCountData:(NSDictionary *)response
{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    ItemInventoryCountSession *itemInventoryCountSession = [self.iReconcileUpdateManager insertInventoryCountSessionInLocalDataBaseWithDetail:itemIncDictionary withContext:privateContextObject];
    itemInventoryCountSession = (ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, self.managedObjectContext);
    
    NSMutableArray *sessionItemList  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
    // STORE EACH ITEM TO SESSION
    
    NSUInteger currentItemIndex = 0;
    for (NSDictionary *eachSession in sessionItemList)
    {
        @autoreleasepool {
            Item *anItem = [self fetchAllItems:[eachSession valueForKey:@"ItemCode"]];
            NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
            
            [self.iReconcileUpdateManager modifidedServerUpdateItemForInventoryCountListwithDetail:eachSession withItem:(Item *)OBJECT_COPY(anItem, privateContextObject) withitemInventoryCount:nil withItemInventorySession:(ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, privateContextObject) withInventoryCountSessionDetail:itemIncDictionary withManageObjectContext:privateContextObject];
            
            //                [self.iReconcileUpdateManager updateItemForInventoryCountListwithServerDetail:eachSession withItem:(Item *)OBJECT_COPY(anItem, privateContextObject) withitemInventoryCount:nil withItemInventorySession:(ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, privateContextObject) withManageObjectContext:privateContextObject];
            
            itemInventoryCountSession = (ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, self.managedObjectContext);
            currentItemIndex ++;
            CGFloat count = (float)sessionItemList.count;
            CGFloat intPercentage = currentItemIndex / count ;
            [_activityIndicator updateProgressStatus:intPercentage];
        }
    }
    self.reConcileItemInvCountSession = itemInventoryCountSession;
    _itemInventoryCountResultController = nil;
    
    [_activityIndicator hideActivityIndicator];
}

// ReconcileCountData - Response Method
- (void)responseReconcileCountDataResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                dispatch_async(dispatch_queue_create("responseReconcileCountData", NULL), ^{
                    [self reconcileCountData:response];
                });
            }
            else
            {
                [_activityIndicator hideActivityIndicator];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error occur while getting selected session data, please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

// CompletedReconcileCountData - Response Method -- Reconcile History service
- (void)responseCompletedReconcileCountDataResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                ItemInventoryCountSession *itemInventoryCountSession = [self.iReconcileUpdateManager insertInventoryCountSessionInLocalDataBaseWithDetail:itemIncDictionary withContext:privateContextObject];
                itemInventoryCountSession = (ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, self.managedObjectContext);
                
                NSMutableArray *sessionItemList = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                // STORE EACH ITEM TO SESSION
                NSNumber * currentItemCount = 0;
                for (NSDictionary *eachSession in sessionItemList)
                {
                    @autoreleasepool {
                        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                        Item *anItem = [self fetchAllItems:[eachSession valueForKey:@"ItemCode"]];
                        
                        [self.iReconcileUpdateManager modifidedServerUpdateItemForInventoryCountHistoryListwithDetail:eachSession withItem:(Item *)OBJECT_COPY(anItem, privateContextObject) withitemInventoryCount:nil withItemInventorySession:(ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, privateContextObject) withInventoryCountSessionDetail:itemIncDictionary withManageObjectContext:privateContextObject];
                        
                        //                [self.iReconcileUpdateManager updateItemForInventoryCountListwithServerDetail:eachSession withItem:(Item *)OBJECT_COPY(anItem, privateContextObject) withitemInventoryCount:nil withItemInventorySession:(ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, privateContextObject) withManageObjectContext:privateContextObject];
                        itemInventoryCountSession = (ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, self.managedObjectContext);
                        currentItemCount = @(currentItemCount.intValue + 1);

                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            float intPercentage = currentItemCount.floatValue / sessionItemList.count;
                            [_activityIndicator updateProgressStatus:intPercentage];
                        });
                    }
                }
                [UpdateManager saveContext:privateContextObject];
                self.reConcileItemInvCountSession = itemInventoryCountSession;
                _itemInventoryCountResultController = nil;
                [self.reConcileItemListTableView reloadData];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error occur while getting selected session data, please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];

}

-(IBAction)backToRootView:(id)sender
{
    if(self.isViewOnly)
    {
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else
    {
        NSArray *arryView = self.navigationController.viewControllers;
        for(int i=0; i< arryView.count; i++)
        {
            UIViewController *viewCon = arryView[i];
            if([viewCon isKindOfClass:[ICReconcileStatusVC class]])
            {
                [self.navigationController popToViewController:viewCon animated:YES];
                break;
            }
        }
    }
}
-(NSPredicate *)itemSearchPredicate{
    NSMutableArray *arrPredicate = [[NSMutableArray alloc]init];
    for (NSString *strItemCode in _arrItemCode) {
        NSPredicate *itemSearchPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@",strItemCode];
        [arrPredicate addObject:itemSearchPredicate];
    }
    NSPredicate *finalPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:arrPredicate];
    return finalPredicate;

}
- (NSPredicate *)reconcilePredicate
{
    _shareOrderClicked.hidden = NO;
    NSPredicate *predicate;
        if (_searchBarcode.text.length > 0 && _arrItemCode && _arrItemCode.count > 0) {
            
            NSPredicate *finalPredicate = [self itemSearchPredicate];
            return finalPredicate;
        }
    
    switch (itemReconcileListType)
    {
        case ItemReconcileListAll:
            predicate = [NSPredicate predicateWithFormat:@"sessionId == %@ AND (singleCount != %@ OR caseCount != %@ OR packCount != %@ ) ", self.reConcileItemInvCountSession.sessionId,@(0),@(0),@(0)];
            break;
            
        case ItemReconcileListUnMatched:
            predicate = [NSPredicate predicateWithFormat:@"sessionId == %@ AND isMatching == %@ AND (singleCount != %@ OR caseCount != %@ OR packCount != %@ ) ", self.reConcileItemInvCountSession.sessionId,@(NO),@(0),@(0),@(0)];
            break;
            
        case ItemReconcileListMatched:
            predicate = [NSPredicate predicateWithFormat:@"sessionId == %@ AND isMatching == %@ AND (singleCount != %@ OR caseCount != %@ OR packCount != %@ ) ", self.reConcileItemInvCountSession.sessionId,@(YES),@(0),@(0),@(0)];
            break;
            
        case ItemReconcileListUncounted:
            _shareOrderClicked.hidden = YES;
            predicate = [NSPredicate predicateWithFormat:@"sessionId == %@ AND (singleCount == %@ AND caseCount == %@ AND packCount == %@ ) ", self.reConcileItemInvCountSession.sessionId,@(0),@(0),@(0)];
            
            break;
            
        default:
            predicate = [NSPredicate predicateWithFormat:@"sessionId == %@", self.reConcileItemInvCountSession.sessionId];
            break;
    }
    
//    if (searchDescription.text.length > 0) {
//        NSPredicate *itemSearchPredicate = [NSPredicate predicateWithFormat:@"item_Desc = %@",searchDescription.text];
//        NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate,itemSearchPredicate]];
//        return compoundPredicate;
//    }
    
    return predicate;
}
-(NSInteger)countForEntity:(NSString *)entityName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    return [UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest];
}

-(BOOL)isReconcileItemCountMatchWithItemCount
{
    BOOL isReconcileItemCountMatchWithItemCount = FALSE;
    if ([self countForEntity:@"Item"] == self.reConcileItemInvCountSession.sessionReconcileCounts.allObjects.count) {
        isReconcileItemCountMatchWithItemCount = TRUE;
    }
    return isReconcileItemCountMatchWithItemCount;
}

-(void)insertRemainingReconcileItems
{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:privateContextObject];
    fetchRequest.entity = entity;
    NSSet *items = [self.reConcileItemInvCountSession.sessionReconcileCounts.allObjects valueForKey:@"itemCode"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (itemCode IN %@)",items];
    fetchRequest.predicate = predicate;
    NSArray *remainingItems = [UpdateManager executeForContext:privateContextObject FetchRequest:fetchRequest];
    NSUInteger currentItemIndex = 0;
    for (Item *item in remainingItems) {
        [self.iReconcileUpdateManager insertReconcileCountForItem:item withDetail:self.reconcileSessionDictionary withReconcileSession:(ItemInventoryCountSession *)OBJECT_COPY(self.reConcileItemInvCountSession, privateContextObject) withContext:privateContextObject];
        
        currentItemIndex ++;
        CGFloat count = (float)remainingItems.count;
        CGFloat intPercentage = currentItemIndex / count ;
        [_activityIndicator updateProgressStatus:intPercentage];
    }
    [UpdateManager saveContext:privateContextObject];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_activityIndicator hideActivityIndicator];
    });
}

- (NSFetchedResultsController *)itemInventoryCountResultController
{
    if (_itemInventoryCountResultController != nil) {
        return _itemInventoryCountResultController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryReconcileCount" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate;
    
    predicate = [self reconcilePredicate];
    
    fetchRequest.predicate = predicate; // @"(ANY itemInventoryCounts).itemCountItem.item_Desc"
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _itemInventoryCountResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_itemInventoryCountResultController performFetch:nil];
    _itemInventoryCountResultController.delegate = self;
    
    return _itemInventoryCountResultController;
}


#pragma mark - UITextField Delegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    if (searchDescription.text > 0) {
//        self.itemInventoryCountResultController = nil;
//    }
    if ([textField isEqual:_searchBarcode]) {
        [self searchItemFromList];
    }
    [textField resignFirstResponder];
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    [_arrItemCode removeAllObjects];
    _searchBarcode.text = @"";

    self.itemInventoryCountResultController = nil;
    [self.reConcileItemListTableView reloadData];
    return YES;
}
- (NSString *)getValueBeforeDecimal:(float)result
{
    NSNumber *numberValue = @(result);
    NSString *floatString = numberValue.stringValue;
    NSArray *floatStringComps = [floatString componentsSeparatedByString:@"."];
    NSString *cq = [NSString stringWithFormat:@"%@",floatStringComps.firstObject];
    return cq;
}

#pragma mark - UITableView Delegate Method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.itemInventoryCountResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat rowHeight = 63.69;
//
//    CGSize constraintSize;
//    constraintSize.width = 205;
//    constraintSize.height = 200;
//    
//    ItemInventoryReconcileCount *itemReconcileCount = [self.itemInventoryCountResultController objectAtIndexPath:indexPath];
//    
//    Item *anItem = [self fetchAllItems:itemReconcileCount.itemCode.stringValue ];
//    NSDictionary *itemDictionary = anItem.itemRMSDictionary;
//    NSString *itemName = itemDictionary[@"ItemName"];
//    
//    UIFont *nameFont = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
//    CGRect textRect = [itemName boundingRectWithSize:constraintSize
//                                             options:NSStringDrawingUsesLineFragmentOrigin
//                                          attributes:@{NSFontAttributeName:nameFont}
//                                             context:nil];
//    CGSize size = textRect.size;
//    rowHeight += size.height;
    if(IsPad())
    {
        return 75;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemCountListCustomCell";
    ItemCountListCustomCell *itemCell = (ItemCountListCustomCell *)[self.reConcileItemListTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIView *viewBG = [[UIView alloc] initWithFrame:itemCell.bounds];
    viewBG.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    itemCell.selectedBackgroundView = viewBG;

//    itemCell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    ItemInventoryReconcileCount *itemReconcileCount = [self.itemInventoryCountResultController objectAtIndexPath:indexPath];
    Item *anItem = [self fetchAllItems:itemReconcileCount.itemCode.stringValue ];
    NSDictionary *itemDictionary = anItem.itemRMSDictionary;
    
    NSString *itemCode = itemDictionary[@"ItemId"];
    itemCell.itemName.text = itemDictionary[@"ItemName"];
    itemCell.itemBarcode.text = itemDictionary[@"Barcode"];
    
    NSNumber *cPrice = @([itemDictionary[@"CostPrice"] floatValue]);
    itemCell.itemCostPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:cPrice]];
    
    NSNumber *sPrice = @([itemDictionary[@"SalesPrice"] floatValue]);
    itemCell.itemSalesPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:sPrice]];
    
    if(cPrice > sPrice)
    {
        itemCell.dividerView.image = [UIImage imageNamed:@"red1px.png"];
    }
    else{
        itemCell.dividerView.image = [UIImage imageNamed:@"numpad_selected.png"];
    }

    itemCell.itemDiscount.text = @"";
    NSMutableArray * itemDiscArray = [[NSMutableArray alloc]init];
    
    Item *aItem = [self fetchAllItems:itemCode];
    for (Item_Discount_MD *idiscMd in aItem.itemToDisMd )
    {
        [itemDiscArray addObjectsFromArray:idiscMd.mdTomd2.allObjects];
    }
    Item_Discount_MD2 *idiscMd2=nil;
    
    if(itemDiscArray.count>0)
    {
        for (int idisc=0; idisc<itemDiscArray.count; idisc++)
        {
            idiscMd2=itemDiscArray[idisc];
            NSInteger iDiscqty = idiscMd2.md2Tomd.dis_Qty.integerValue;
            if(idiscMd2.dayId.integerValue == -1 && iDiscqty == 1)
            {
                NSNumber *sPrice = @(idiscMd2.md2Tomd.dis_UnitPrice.floatValue);
                itemCell.itemSalesPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:sPrice]];
                itemCell.itemSalesPrice.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
                itemCell.itemDiscount.text = @"D";
            }
            else if(idiscMd2.dayId.integerValue >= -1 && idiscMd2.dayId.integerValue <= 7)
            {
                itemCell.itemSalesPrice.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
                itemCell.itemDiscount.text = @"D";
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
            itemCell.itemSalesPrice.textColor = [UIColor redColor];
        }
    }
    
    if(itemReconcileCount.expectedQuantity)
    {
        itemCell.itemQtyOH.text = [NSString stringWithFormat:@"%@",itemReconcileCount.expectedQuantity];
    }
    else
    {
        itemCell.itemQtyOH.text = [NSString stringWithFormat:@"%@",itemDictionary[@"avaibleQty"]];
    }
    
    NSInteger availableQty = [itemDictionary[@"avaibleQty"] integerValue];
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
            float result = itemCell.itemQtyOH.text.floatValue/caseQty.floatValue;
            NSString *cq = [self getValueBeforeDecimal:result];
            NSInteger y = itemCell.itemQtyOH.text.integerValue % caseQty.integerValue;
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
            float result = itemCell.itemQtyOH.text.floatValue/caseQty.floatValue;
            NSString *pq = [self getValueBeforeDecimal:result];
            NSInteger x = itemCell.itemQtyOH.text.integerValue % caseQty.integerValue;
            x = labs(x);
            packValue = [NSString stringWithFormat:@"%@.%ld",pq,(long)x];
        }
        else
        {
            packValue = @"-";
        }
        
        if(([caseValue isEqualToString:@"-"]) && ([packValue isEqualToString:@"-"]))
        {
            itemCell.itemCasePack.text = @"";
        }
        else if ([packValue isEqualToString:@"-"]) // Pack value not available
        {
            itemCell.itemCasePack.text = [NSString stringWithFormat:@"%@ / -",caseValue];
        }
        else if ([caseValue isEqualToString:@"-"]) // Case value not available
        {
            itemCell.itemCasePack.text = [NSString stringWithFormat:@"- / %@",packValue];
        }
        else
        {
            itemCell.itemCasePack.text = [NSString stringWithFormat:@"%@ / %@",caseValue , packValue];
        }
    }
    else
    {
        itemCell.itemCasePack.text = @"";
    }
    
    NSString *manSingle = [NSString stringWithFormat:@"%@",itemReconcileCount.singleCount.stringValue];
    NSString *manCase = [NSString stringWithFormat:@"%@",itemReconcileCount.caseCount.stringValue];
    NSString *manPack = [NSString stringWithFormat:@"%@",itemReconcileCount.packCount.stringValue];
    
    if ([manPack isEqualToString:@"-"]) // Pack value not available
    {
        itemCell.itemManualCasePack.text = @"";
    }
    else
    {
        itemCell.itemManualQtyOH.text = manSingle;
    }
    
    if(([manCase isEqualToString:@"-"]) && ([manPack isEqualToString:@"-"]))
    {
        itemCell.itemManualCasePack.text = @"";
    }
    else if ([manPack isEqualToString:@"-"]) // Pack value not available
    {
        itemCell.itemManualCasePack.text = [NSString stringWithFormat:@"%@ / -",manCase];
    }
    else if ([manCase isEqualToString:@"-"]) // Case value not available
    {
        itemCell.itemManualCasePack.text = [NSString stringWithFormat:@"- / %@",manPack];
    }
    else
    {
        itemCell.itemManualCasePack.text = [NSString stringWithFormat:@"%@ / %@",manCase,manPack];
    }
    
    if (itemReconcileCount.isMatching.boolValue)
    {
        itemCell.imageBackGround.image = [UIImage imageNamed:@"greenbg.png"];
    }
    else
    {
        itemCell.imageBackGround.image = [UIImage imageNamed:@"redbg.png"];
    }
    return itemCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Footer Button Method

-(IBAction)allItemClicked:(id)sender
{
    [self selectedItemTab:_allBtn];
    itemReconcileListType = ItemReconcileListAll;
    self.itemInventoryCountResultController = nil;
    [self.reConcileItemListTableView reloadData];
}

-(IBAction)unMatchedItemClicked:(id)sender
{
    [self selectedItemTab:_unMatchedBtn];
    itemReconcileListType = ItemReconcileListUnMatched;
    self.itemInventoryCountResultController = nil;
    [self.reConcileItemListTableView reloadData];
}

-(IBAction)matchedItemClicked:(id)sender
{
    [self selectedItemTab:_matchedBtn];
    itemReconcileListType = ItemReconcileListMatched;
    self.itemInventoryCountResultController = nil;
    [self.reConcileItemListTableView reloadData];
}


-(IBAction)uncountedItemClicked:(id)sender
{
    [self selectedItemTab:_unCountedBtn];
   
    if ([self isReconcileItemCountMatchWithItemCount] == FALSE) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        dispatch_async(dispatch_queue_create("insertRemainingReconcileItems", NULL), ^{
            NSLog(@"1.....");
            [self insertRemainingReconcileItems];
            NSLog(@"2.....");
        });
//        _itemInventoryCountResultController = nil;

    }

    itemReconcileListType = ItemReconcileListUncounted;
    self.itemInventoryCountResultController = nil;
    [self.reConcileItemListTableView reloadData];
}
-(void)showActivityIndicator{
    if (!_activityIndicator) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].delegate.window];
    }
}

-(IBAction)moreClicked:(id)sender
{
    [self selectedItemTab:_moreBtn];
}

-(IBAction)completeInvCountClicked:(id)sender
{
    [self selectedItemTab:_completeBtn];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
        iCReconcileCompletePopUp = [storyBoard instantiateViewControllerWithIdentifier:@"ICReconcileCompletePopUp"];
        iCReconcileCompletePopUp.reconcileCompletePopupVCDelegate = self;
        iCReconcileCompletePopUp.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:iCReconcileCompletePopUp animated:YES completion:Nil];


//    _compConformView.hidden = NO;
}

-(void)selectedItemTab:(UIButton *)selectedButton
{
    _allBtn.selected = NO;
    _unMatchedBtn.selected = NO;
    _matchedBtn.selected = NO;
    _moreBtn.selected = NO;
    _completeBtn.selected = NO;
    _unCountedBtn.selected = NO;
    
    selectedButton.selected = YES;
}

#pragma mark complete conformation view

//-(IBAction)sendUncounted:(id)sender
//{
//    includeUncountedItem = YES;
//    _sendUncounted.selected = YES;
//    _ignoreUncounted.selected = NO;
//}
//
//-(IBAction)ignoreUncounted:(id)sender
//{
//    includeUncountedItem = NO;
//    _ignoreUncounted.selected = YES;
//    _sendUncounted.selected = NO;
//}

//-(IBAction)continueComplete:(id)sender
//{
//    _compConformView.hidden = YES;
//    [self completeReconcileAndSendData];
//}
//
//-(IBAction)cancelComplete:(id)sender
//{
//    _compConformView.hidden = YES;
//}

-(void)didCancel
{
    [self selectedItemTab:nil];
    [iCReconcileCompletePopUp dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Coredata table function

- (Item*)fetchAllItems :(NSString *)itemId
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
-(void)completeReconcile :(BOOL)isSelected{
    
    NSArray *arrDeptId = [[NSArray alloc]init];
    arrDeptId = [iCReconcileCompletePopUp.arrSelectedDepartment valueForKey:@"deptId"];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:iCReconcileCompletePopUp.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    [param setValue:@(isSelected) forKey:@"includeUncountedItem"];
    
    [param setValue:[NSString stringWithFormat:@"%@",self.reConcileItemInvCountSession.sessionId.stringValue] forKey:@"StockSessionId"];
    
    if(isSelected){
        NSString *strDeptIds = [arrDeptId componentsJoinedByString:@","];
        NSLog(@"%@",strDeptIds);
        [param setValue:strDeptIds forKey:@"DepartmentIDs"];
    }
    NSDate *currentDate = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateValue = [formatter stringFromDate:currentDate];
    [param setValue:currentDateValue forKey:@"LocalDate"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseCloseInvCountSessionResponse:response error:error];
        });
    };
    
    self.responseCloseInvCountWC = [self.responseCloseInvCountWC initWithRequest:KURL actionName:WSM_CLOSE_INV_COUNT_SESSION params:param completionHandler:completionHandler];
}

- (void)responseCloseInvCountSessionResponse:(id)response error:(NSError *)error
{
    [iCReconcileCompletePopUp dismissViewControllerAnimated:YES completion:nil];
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSArray *arryView = self.navigationController.viewControllers;
                for(int i=0; i< arryView.count; i++)
                {
                    UIViewController *viewCon = arryView[i];
                    if([viewCon isKindOfClass:[ICHomeVC class]])
                    {
                        [self.navigationController popToViewController:viewCon animated:YES];
                        break;
                    }
                }
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 3)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}
#pragma mark - Scanner Device Methods

-(void)deviceButtonPressed:(int)which {
    if ([self.rmsDbController.globalScanDevice[@"Type"]isEqualToString:@"Scanner"]) {
        if([self.rimController.scannerButtonCalled isEqualToString:@"ItemReconcileList"]) {
            self.strSearchText = @"";
        }
    }
}

-(void)deviceButtonReleased:(int)which {
    if ([self.rmsDbController.globalScanDevice[@"Type"]isEqualToString:@"Scanner"]) {
        if([self.rimController.scannerButtonCalled isEqualToString:@"ItemReconcileList"]) {
            if(![self.strSearchText isEqualToString:@""]) {
                [self searchItemFromList];
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


-(void)showMessage:(NSString *)strMessage {
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {};
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

#pragma mark - Share Inventory CountList methods - Himanshu

- (void)createHTMLViewandLaunchSendEmailVC
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_queue_t dispatchQueue = dispatch_queue_create("CreateHtTMLData", NULL);
    
    dispatch_async(dispatchQueue, ^{
        NSArray *fetchedData = self.itemInventoryCountResultController.fetchedObjects;
        //  [arryInvoice addObjectsFromArray:fetchedData];
        NSMutableArray *arryInvoice = [self makeItemArray:fetchedData];
        NSMutableArray *inventoryMain = [[NSMutableArray alloc] init];
        
        self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ReconcileItemList" ofType:@"html"];
        self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
        
        NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
        self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
        
        self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:inventoryMain];
        
        // set Html itemDetail
        NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
        self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
        
        /// Write Data On Document Directory.......
        NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
        [self writeDataOnCacheDirectory:data];
        if(IsPad()){
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
            emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];

        }
        else{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController_iPhone"];

        }

        NSData *myData = [NSData dataWithContentsOfFile:self.emaiItemHtml];
        NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
        
        NSString *strsubjectLine = @"";
        emailFromViewController.emailFromViewControllerDelegate = self;

        emailFromViewController.dictParameter =[[NSMutableDictionary alloc]init];
        (emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
        (emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
        (emailFromViewController.dictParameter)[@"postfile"] = myData;
        (emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
        (emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_activityIndicator hideActivityIndicator];
            [self.view addSubview:emailFromViewController.view];
        });
    });
}

-(void)didCancelEmail
{
    [emailFromViewController.view removeFromSuperview];
}

-(NSMutableArray *)makeItemArray:(NSArray *)fetchedData{
   
    NSMutableArray *itemArray = [[NSMutableArray alloc]init];
    for (ItemInventoryReconcileCount *itemReconcileCount in fetchedData) {
        @autoreleasepool {
            Item *anItem = [self fetchAllItems:itemReconcileCount.itemCode.stringValue];
            if (anItem) {
                NSDictionary *itemDictionary = anItem.itemRMSDictionary;
                
                NSNumber *singleQty = itemReconcileCount.singleCount;
                NSNumber *caseQty = @(itemReconcileCount.caseCount.integerValue * itemReconcileCount.caseQuantity.integerValue);
                NSNumber *packQty = @(itemReconcileCount.packCount.integerValue * itemReconcileCount.packQuantity.integerValue);
                
                NSNumber *addedQty = @(singleQty.integerValue + caseQty.integerValue + packQty.integerValue);
                
                NSString *strAddedQty = [NSString stringWithFormat:@"%@",addedQty];
                [itemDictionary setValue:strAddedQty forKey:@"AddedQty"];
                [itemArray addObject:itemDictionary];
            }
        }
    }
    return itemArray;
}

- (void)printPreviewBeforePrint
{    
    NSMutableArray *arryInvoice ;

    NSArray *fetchedData = self.itemInventoryCountResultController.fetchedObjects;
    arryInvoice = [self makeItemArray:fetchedData];
    NSMutableArray *inventoryMain = [[NSMutableArray alloc] init];
    
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ReconcileItemList" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:inventoryMain];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
//    CGSize paperSize = CGSizeMake(320, 841.8);
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/Reconclie Item List.pdf".stringByExpandingTildeInPath delegate:self pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 5, 10, 5)];
}

-(IBAction)shareOrderClicked:(id)sender
{
    isShareClicked = TRUE;
    UIButton *button;
    button = sender;
    
    UIAlertController *popup = [UIAlertController alertControllerWithTitle:@"Export" message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *print = [UIAlertAction actionWithTitle:@"Print" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    [popup dismissViewControllerAnimated:YES completion:nil];
                                    [self printPreviewBeforePrint];
                                }];
    
    UIAlertAction *email = [UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    [popup dismissViewControllerAnimated:YES completion:nil];
                                    [self createHTMLViewandLaunchSendEmailVC];
                                }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                [popup dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    [popup addAction:print];
    [popup addAction:email];
    [popup addAction:cancel];
    
    UIPopoverPresentationController *popPresenter = popup.popoverPresentationController;
    popPresenter.sourceView = button;
    popPresenter.sourceRect = button.bounds;
    [self presentViewController:popup animated:YES completion:nil];
}
-(IBAction)searchItem:(id)sender
{
    [self.rmsDbController playButtonSound];
    //    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    //    {
    //        ICSearchItemSelectionVC *icSearchItemSelectionVC = [[ICSearchItemSelectionVC alloc] initWithNibName:@"InventoryManagement" bundle:nil];
    //        icSearchItemSelectionVC.icSearchItemSelectionVC = self;
    //        icSearchItemSelectionVC.isItemActive = TRUE;
    //        [self.navigationController pushViewController:icSearchItemSelectionVC animated:YES];
    //    }
    //    else
    //    {
    //        ICSearchItemSelectionVC *icSearchItemSelectionVC = [[ICSearchItemSelectionVC alloc] initWithNibName:@"InventoryManagement_iPad" bundle:nil];
    //        icSearchItemSelectionVC.icSearchItemSelectionVC = self;
    //        [self.navigationController pushViewController:icSearchItemSelectionVC animated:YES];
    //    }
    InventoryItemSelectionListVC * objInventoryItemSelectionListVC =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemSelectionListVC_sid"];
    objInventoryItemSelectionListVC.delegate = self;
    objInventoryItemSelectionListVC.arrNotSelectedItemCodes = @[@(0)];
    objInventoryItemSelectionListVC.isSingleSelection = FALSE;
    objInventoryItemSelectionListVC.isItemActive = TRUE;
    objInventoryItemSelectionListVC.isItemInSelectMode = TRUE;
    objInventoryItemSelectionListVC.strNotSelectionMsg = @"";
    [self presentViewController:objInventoryItemSelectionListVC animated:YES completion:nil];
    
    
}
-(IBAction)btnSearchBarClick:(id)sender
{
    [self searchItemFromList];
}

- (void)searchItemFromList {
    if( _searchBarcode.text.length > 0)
    {
        [self searchBarcodeItem];
    }
}

- (void)searchBarcodeItem
{
    NSPredicate *searchPredicate = [self searchPredicateForText:_searchBarcode.text];

    BOOL isNumeric;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:_searchBarcode.text];
    isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) // numeric
    {
        _searchBarcode.text = [self.rmsDbController trimmedBarcode:_searchBarcode.text];
    }
    
    //    BOOL isScanItemfound = FALSE;
    
  //  Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = searchPredicate;
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];

    if (resultSet.count > 0)
    {
        _arrItemCode = [[NSMutableArray alloc]init];
        self.itemInventoryCountResultController = nil;
        for (Item * item in resultSet) {
            [_arrItemCode addObject:[NSString stringWithFormat:@"%@",item.itemCode]];
            
        }
        NSFetchRequest *fetchRequestReconcileCount = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityReconcileCount = [NSEntityDescription entityForName:@"ItemInventoryReconcileCount" inManagedObjectContext:self.managedObjectContext];
        fetchRequestReconcileCount.entity = entityReconcileCount;
        NSPredicate *itemSearchPredicate = [self itemSearchPredicate];
        fetchRequestReconcileCount.predicate = itemSearchPredicate;
        
        
        NSArray *tempResultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequestReconcileCount];
        if (tempResultSet.count > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.reConcileItemListTableView reloadData];
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

-(NSPredicate *)searchPredicateForText:(NSString *)searchData
{
    BOOL isNumber;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:searchData];
    isNumber = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumber) // numeric
    {
        searchData = [self.rmsDbController trimmedBarcode:searchData];
    }
    
    NSMutableCharacterSet *separators = [[NSMutableCharacterSet alloc] init];
    [separators addCharactersInString:@","];
    NSMutableArray *textArray = [[searchData componentsSeparatedByCharactersInSet:separators] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = @[ @"item_Desc contains[cd] %@",@"item_No == %@",@"barcode==%@",@"ANY itemBarcodes.barCode == %@"];
    
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

-(void)noRecordFound{
    [_arrItemCode removeAllObjects];
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {};
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:[NSString stringWithFormat:@"No Record Found for %@",_searchBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    _searchBarcode.text = @"";

}

-(IBAction)btnCameraScanSearch:(id)sender
{
    self.cameraScanVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    [self presentViewController:self.cameraScanVC animated:YES completion:^{
        self.cameraScanVC.delegate = self;
    }];
}


-(NSString *)htmlBillHeader:(NSString *)html invoiceArray:(NSMutableArray *)arrayInvoice
{
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"Reconclie List"]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]
                                                                                     ]];
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
//    NSString  *Datetime = [NSString stringWithFormat:@"%@",[[arrayInvoice firstObject] valueForKey:@"CreatedDate"]];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString  *currentDateTime = [formatter stringFromDate:date];
    NSString *strTime = [self getStringFormate:currentDateTime fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"hh:mm a"];
    NSString *strDate = [self getStringFormate:currentDateTime fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"MMM dd, yyyy"];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:[NSString stringWithFormat:@"%@",strDate]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    
    return html;
}

-(NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
}

-(NSString *)htmlBillTextForItem:(NSMutableArray *)arrayInvoice
{
    NSMutableArray * arrTest = [NSMutableArray array];
    for (int i=0; i<arrayInvoice.count; i++)
    {
        // set Item Detail with only 1 qty....
        [arrTest addObject:[self htmlBillTextGenericForItemwithDictionary:arrayInvoice[i]]];
    }
    return [arrTest componentsJoinedByString:@""];
}
-(NSString *)htmlBillTextGenericForItemwithDictionary:(NSDictionary *)itemDictionary
{
    NSInteger diffqty = [itemDictionary[@"AddedQty"] floatValue] - [itemDictionary[@"avaibleQty"] floatValue];
    
    return [@"" stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font></td><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">&nbsp; %@</font></td><td>&nbsp;</td><td align=\"left\" valign=\"top\"style=\"width:40%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">&nbsp; %@</font></td><td>&nbsp;</td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td><td align=\"right\" valign=\"top\"><font size=\"2\">%ld</font></td></tr>",itemDictionary[@"AddedQty"],itemDictionary[@"Barcode"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"avaibleQty"],(long)diffqty];

}

-(void)writeDataOnCacheDirectory :(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.emaiItemHtml])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.emaiItemHtml error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.emaiItemHtml = [documentsDirectory stringByAppendingPathComponent:@"ReconcileItemList.html"];
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

-(void)openDocumentwithSharOption:(NSString *)strpdfUrl
{
    // here's a URL from our bundle
    NSURL *documentURL = [[NSURL alloc]initFileURLWithPath:strpdfUrl];
    // pass it to our document interaction controller
    self.controller.URL = documentURL;
    // present the preview
    [self.controller presentPreviewAnimated:YES];
}

- (UIDocumentInteractionController *)controller {
    
    if (!self.documentController)
    {
        self.documentController = [[UIDocumentInteractionController alloc]init];
        self.documentController.delegate = self;
    }
    return self.documentController;
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
//    NSLog(@"offline upload invoice beginUpdates");
    
    if (![controller isEqual:self.itemInventoryCountResultController] ) {
        return;
    }
    [self.reConcileItemListTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.itemInventoryCountResultController] ) {
        return;
    }
    
       UITableView *tableView = self.reConcileItemListTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic] ;
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.itemInventoryCountResultController] ) {
        return;
    }
    
  
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.reConcileItemListTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.reConcileItemListTableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.reConcileItemListTableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (![controller isEqual:self.itemInventoryCountResultController] ) {
        return;
    }
    
    [self.reConcileItemListTableView endUpdates];
//    NSLog(@"endUpdates");
}


@end
