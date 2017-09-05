//
//  ICHomeVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 31/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemCountListVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "ItemInfoEditVC.h"
#import "ICQtyEditVC.h"
#import "InventoryItemSelectionListVC.h"
#import "RapidMultipleBarcodeRingUpHelper.h"
//#import "InventoryCountItemSelectionVC.h"
#import "ICHomeVC.h"
#import "ItemReconcileListVC.h"
#import "ICSearchItemSelectionVC.h"
#import "CameraScanVC.h"
#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif

// custom cell import
#import "ItemCountListCustomCell.h"

// Core data table import
#import "Item+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "ItemInventoryCount+Dictionary.h"
#import "ItemInventoryCountSession+Dictionary.h"
#import "ItemInventoryReconcileCount+Dictionary.h"
#import "ItemDetailEditVC.h"
#import "MultipleItemBarcodeRingUpVC.h"
#import "InventoryCountItemSelectionVC.h"
#import "ICRecallSessionListVC.h"
#import "IntercomHandler.h"

@class SettingsViewController;

@interface ItemCountListVC () <UITableViewDelegate,UITableViewDataSource,UpdateDelegate,ICQtyEditDelegate,NSFetchedResultsControllerDelegate,ICSearchItemSelectionVCDelegate,CameraScanVCDelegate,InventoryItemSelectionListVCDelegate,ICSearchItemSelectionVCDelegate , ItemInfoEditVCDelegate , ItemInfoEditRedirectionVCDelegate,MultipleItemBarcodeRingUpDelegate,InventoryCountItemSelectionVCDelegate
#ifdef LINEAPRO_SUPPORTED
,DTDeviceDelegate
#endif
>
{
    IntercomHandler *intercomHandler;
    Item *currentScanItem;
    InventoryCountItemSelectionVC *inventoryCountItemSelectionDelegate;
    NSMutableArray *priceMdForBarcodes;
    Configuration *configuration;
    ICQtyEditVC *iCQtyEditVC;
    ItemInventoryCount *currentScanitemInventoryCount;
    CGFloat totalCostForReconcileItem;
    NSManagedObjectID *objectIdOfUpdatingItem;
    NSNumber *countSessionId;
    MultipleItemBarcodeRingUpVC * multipleItemBarcodeRingUpVC;
    UIVisualEffectView *effectView;
    NSMutableString *status;
	NSMutableString *debug;
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
}

@property (nonatomic, weak) IBOutlet UILabel *inventoryCount;
@property (nonatomic, weak) IBOutlet UITextField *searchBarcode;
@property (nonatomic, weak) IBOutlet UIButton *itemInfoBtn;
@property (nonatomic, weak) IBOutlet UIView *itemInfoView;
@property (nonatomic, weak) IBOutlet UILabel *mismatchItem;
@property (nonatomic, weak) IBOutlet UILabel *totalProduct;
@property (nonatomic, weak) IBOutlet UILabel *totalCost;
@property (nonatomic, weak) IBOutlet UIView *moreOperationView;
@property (nonatomic, weak) IBOutlet UIButton *moreBtn;
@property (nonatomic, weak) IBOutlet UITableView *scanItemListTableView;
//@property (nonatomic, weak) IBOutlet UILabel *scannerStatus;
@property (nonatomic, weak) IBOutlet UIView *roundedView;
@property (nonatomic, weak) IBOutlet UIImageView *scannerStatus;

@property (nonatomic, weak) IBOutlet UIButton *btnNew;
@property (nonatomic, weak) IBOutlet UIButton *btnSearch;
@property (nonatomic, weak) IBOutlet UIButton *btnHold;
@property (nonatomic, weak) IBOutlet UIButton *btnView;
@property (nonatomic, weak) IBOutlet UIButton *btnReconcile;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController *_rimController;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, strong) UpdateManager *iCountUpdateManager;

@property (nonatomic, strong) RapidWebServiceConnection *additemCountWebservice;
@property (nonatomic, strong) RapidWebServiceConnection *holdUserSessionWC;
@property (nonatomic, strong) RapidWebServiceConnection *closeInventoryUserSessionWC;
@property (nonatomic, strong) RapidWebServiceConnection *deleteItemCountWebservice;
@property (nonatomic, strong) RapidWebServiceConnection *updateItemCountWebservice;
@property (nonatomic, strong) NSMutableArray <UIViewController *> *presentedViewControllers;

@property (nonatomic, strong) NSFetchedResultsController *itemInventoryCountResultController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (assign) bool suspendDisplayInfo;
@property (assign) BOOL isUploading;

@end

@implementation ItemCountListVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize iCountUpdateManager;

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
    self._rimController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.additemCountWebservice = [[RapidWebServiceConnection alloc]init];
    self.holdUserSessionWC = [[RapidWebServiceConnection alloc] init];
    self.closeInventoryUserSessionWC = [[RapidWebServiceConnection alloc] init];
    self.deleteItemCountWebservice = [[RapidWebServiceConnection alloc] init];
    self.updateItemCountWebservice = [[RapidWebServiceConnection alloc] init];

    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    self.iCountUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    countSessionId = self.currentItemInventoryCountSession.sessionId;
    _inventoryCount.text = [NSString stringWithFormat:@"INC #%@", countSessionId];
    
    self.suspendDisplayInfo = false;
#ifdef LINEAPRO_SUPPORTED
    dtdev = [DTDevices sharedDevice];
	[dtdev addDelegate:self];
    [dtdev connect];

    if(!self.suspendDisplayInfo)
        [self connectionState:dtdev.connstate];
#endif
    self.suspendDisplayInfo = false;
    
    if([self._rimController.scannerButtonCalled isEqualToString:@""])
    {
        self._rimController.scannerButtonCalled = @"ItemCountListVC";
    }
    
    // Do any additional setup after loading the view from its nib.
//    _itemInventoryCountResultController = nil;
    //[self itemInventoryCountResultController];
    /// Get The Cuurent itemInventoryCountSession here....
    [_roundedView.layer setCornerRadius:18.0f];
    _roundedView.clipsToBounds = YES;
    self.presentedViewControllers = [[NSMutableArray alloc] init];
    
    if (IsPhone()) {
        
        self.scanItemListTableView.estimatedRowHeight = 95;
        self.scanItemListTableView.rowHeight = UITableViewAutomaticDimension;
    }
    self.isUploading = TRUE;
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"helpbtn.png" selectedImage:@"helpbtnselected.png" withViewController:self];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self._rimController.scannerButtonCalled = @"ItemCountListVC";
    self.itemInventoryCountResultController = nil;
    self.scanItemListTableView.hidden = NO;

    [self.scanItemListTableView reloadData];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear = %@" ,[NSDate date]);

    self.currentItemInventoryCountSession = [self.iCountUpdateManager fetchItemInventoryCountSession:countSessionId.stringValue moc:self.managedObjectContext];
}

-(IBAction)backToRootView:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    if(_isRecallList)
    {
        [self backToRecallSessionListVC];
    }
    else
    {
        [self backToHomeVC];
    }
}

-(IBAction)itemCountListInfo:(id)sender
{
    _itemInfoBtn.selected = !_itemInfoBtn.selected;
    if(_itemInfoBtn.selected)
    {
        // hide more option view
        _moreBtn.selected = NO;
        _moreOperationView.hidden = YES;
        // show item info view
        _itemInfoView.hidden = NO;
        _totalProduct.text = [NSString stringWithFormat:@"%ld",(long)[self filterInventoryCount]];
        
        NSArray *resultSet = [self filterReconcileInventoryCountWithPredicate:[NSPredicate predicateWithFormat:@"isMatching == %@ AND sessionId == %d",@(NO), countSessionId.integerValue]];
        _mismatchItem.text = [NSString stringWithFormat:@"%lu",(unsigned long)resultSet.count];
        [self reconcileInventoryCountObjectSum];
        _totalCost.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",totalCostForReconcileItem]];
    }
    else
    {
        _itemInfoView.hidden = YES;
    }
}

- (NSFetchedResultsController *)itemInventoryCountResultController
{
    if (_itemInventoryCountResultController != nil) {
        return _itemInventoryCountResultController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryCount" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionId == %@ AND isDelete == %@ AND userSessionId == %@", countSessionId,@(0),self.userSessionId];
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
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
    if((textField == _searchBarcode) && _searchBarcode.text.length > 0)
    {
        [self searchBarcodeItem];
        return YES;
    }
    else
    {
        [textField resignFirstResponder];
        return YES;
    }
}

-(IBAction)btnSearchBarClick:(id)sender
{
    if( _searchBarcode.text.length > 0)
    {
        [self searchBarcodeItem];
    }
}

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([configuration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

- (NSArray *)fetchItemWithItemBarcode :(NSString *)itemData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    //   ANY itemBarcodes.barCode == %@ OR barcode == %@
    
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barCode like[cd] %@ AND((packageType == %@ OR barcodePrice_MD.isPackCaseAllow == %@))",itemData,@"Single Item",@1];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barcode == %@ OR ANY itemBarcodes.barCode == %@",itemData,itemData];
    //////// Change It ///////
    
    NSPredicate *predicate;
    if ([self isSubDepartmentEnableInBackOffice]) {
        predicate = [NSPredicate predicateWithFormat:@"ANY itemBarcodes.barCode == %@ ",itemData];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"ANY itemBarcodes.barCode == %@ AND itm_Type != %@",itemData,@(2)];
    }

    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    /*   if (resultSet.count>0)
     {
     item=[resultSet firstObject];
     }*/
    return resultSet;
}

- (void)searchBarcodeItem
{
    BOOL isNumeric;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:_searchBarcode.text];
    isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    NSString * itemBarcode = _searchBarcode.text;

    if (isNumeric) // numeric
    {
        itemBarcode = [self.rmsDbController trimmedBarcode:itemBarcode];
    }
    
//    BOOL isScanItemfound = FALSE;
    
    Item *item=nil;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
//    fetchRequest.entity = entity;
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barcode==%@ OR ANY itemBarcodes.barCode == %@", _searchBarcode.text,_searchBarcode.text];
//    fetchRequest.predicate = predicate;
//    
//    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    NSArray *itemsForBarcode = [self fetchItemWithItemBarcode:_searchBarcode.text];
    if(itemsForBarcode.count == 0)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"No Item with UPC #%@ found.", itemBarcode ] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        _searchBarcode.text = @"";
        return;
    }

    else
    {

        RapidMultipleBarcodeRingUpHelper *rapidMultipleBarcodeRingUpHelper = [[RapidMultipleBarcodeRingUpHelper alloc]init];
        
        priceMdForBarcodes = [rapidMultipleBarcodeRingUpHelper rigupProcessForItemBarcode:itemsForBarcode withItemBarcode:itemBarcode];
        
        NSPredicate *itemInActivePredicate = [NSPredicate predicateWithFormat:@"priceToItem.active == %@",@(1)];
        
        priceMdForBarcodes = (NSMutableArray *)[priceMdForBarcodes filteredArrayUsingPredicate:itemInActivePredicate];
        

        if (priceMdForBarcodes.count == 1)
        {
            Item_Price_MD *md = priceMdForBarcodes.firstObject;
            item = md.priceToItem;

//            item = priceMdForBarcodes.firstObject;
            self.scannerStatus.hidden = YES;
            self.scanItemListTableView.hidden = NO;
        }
        else if (priceMdForBarcodes.count > 1)
        {
            [self showMultipleItemForBarcodeWithDetail:priceMdForBarcodes withItemBarcode:_searchBarcode.text];
            self.scannerStatus.hidden = YES;
            self.scanItemListTableView.hidden = NO;
            return;
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:[NSString stringWithFormat:@"No Record Found for %@",_searchBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            _searchBarcode.text = @"";
            return;
        }
        currentScanItem = item;
        currentScanitemInventoryCount = nil;
        _searchBarcode.text = @"";
        
        [self launchICQty_VCWithItem:currentScanItem withItemInventoryCount:currentScanitemInventoryCount];


    }
    
}

#pragma mark - Check scanner type
- (void)checkConnectedScanner_Count
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
    {
        [_searchBarcode becomeFirstResponder];
    }
    else
    {
        [_searchBarcode resignFirstResponder];
    }
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES; // Return YES, if enable delete on swipe.
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.scanItemListTableView)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
            ItemInventoryCount *iteminventoryCount = [self.itemInventoryCountResultController objectAtIndexPath:indexPath];
            iteminventoryCount = (ItemInventoryCount *)[privateContextObject objectWithID:iteminventoryCount.objectID];
            iteminventoryCount.isUploadedToServer = @(0);
            iteminventoryCount.isDelete = @(1);
            [UpdateManager saveContext:privateContextObject];
            [self.scanItemListTableView reloadData];
            [self sendEachItemToServer];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.itemInventoryCountResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    if(sectionInfo.numberOfObjects == 0)
    {
        self.scannerStatus.hidden = NO;
        self.scanItemListTableView.hidden = YES;
        self.itemInfoView.hidden = YES;
    }
    else
    {
        self.scannerStatus.hidden = YES;
        self.scanItemListTableView.hidden = NO;
    }
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
//    ItemInventoryCount *iteminventoryCount = [self.itemInventoryCountResultController objectAtIndexPath:indexPath];
//    NSDictionary *itemDictionary = iteminventoryCount.itemCountItem.itemRMSDictionary;
//    NSString *itemName = itemDictionary[@"ItemName"];
//    
//    UIFont *nameFont = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
//    CGRect textRect = [itemName boundingRectWithSize:constraintSize
//                                               options:NSStringDrawingUsesLineFragmentOrigin
//                                            attributes:@{NSFontAttributeName:nameFont}
//                                               context:nil];
//    CGSize size = textRect.size;
//    rowHeight += size.height;
//    return rowHeight;
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
    ItemCountListCustomCell *itemCell = (ItemCountListCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIView *viewBG = [[UIView alloc] initWithFrame:itemCell.bounds];
    viewBG.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    itemCell.selectedBackgroundView = viewBG;

//    itemCell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    if(IsPad())
    {
        itemCell.imgSelected.image = [UIImage imageNamed:@"RIM_Com_Arrow_Detail"];
        itemCell.imgSelected.highlightedImage = [UIImage imageNamed:@"rim_inventory_arrow_selected"];
    }
    else{
        
        itemCell.imgSelected.image = [UIImage imageNamed:@"ic_arrow.png"];
        itemCell.imgSelected.highlightedImage = [UIImage imageNamed:@"ic_arrowselected.png"];

    }
    ItemInventoryCount *iteminventoryCount = [self.itemInventoryCountResultController objectAtIndexPath:indexPath];
    NSDictionary *itemDictionary = iteminventoryCount.itemCountItem.itemRMSDictionary;
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
    
    itemCell.itemQtyOH.text = [NSString stringWithFormat:@"%@",itemDictionary[@"avaibleQty"]];
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
    
    NSString *manSingle = [NSString stringWithFormat:@"%@",iteminventoryCount.singleCount.stringValue];
    NSString *manCase = [NSString stringWithFormat:@"%@",iteminventoryCount.caseCount.stringValue];
    NSString *manPack = [NSString stringWithFormat:@"%@",iteminventoryCount.packCount.stringValue];
    
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
    
    if (iteminventoryCount.itemInventoryReconcileCount.isMatching.boolValue)
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
    ItemInventoryCount *itemInventoryCount = [self.itemInventoryCountResultController objectAtIndexPath:indexPath];
    currentScanItem = itemInventoryCount.itemCountItem;
    currentScanitemInventoryCount = [self.itemInventoryCountResultController objectAtIndexPath:indexPath];
    // ItemEditQty
    [self launchICQty_VCWithItem:itemInventoryCount.itemCountItem withItemInventoryCount:[self.itemInventoryCountResultController objectAtIndexPath:indexPath]];
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark - Footer Button Method
-(IBAction)addNewItem:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"You don't have rights to add new item. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    [self hideMoreOptionView];
    [self.rmsDbController playButtonSound];
    if(IsPhone())
    {
        ItemInfoEditVC  *itemInfoEditVC = (ItemInfoEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];
        itemInfoEditVC.itemInfoEditVCDelegate = self;
        if (itemInfoEditVC.itemInfoDataObject==nil) {
            itemInfoEditVC.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
        }
        [itemInfoEditVC.itemInfoDataObject setItemMainDataFrom:nil];
        itemInfoEditVC.isCopy = false;
  
        NSMutableDictionary *navigationInfo = [[NSMutableDictionary alloc] init ];
        navigationInfo[@"isWaitForLiveUpdate"] = @(TRUE);
        itemInfoEditVC.dictNewOrderData=navigationInfo;

        [self.navigationController pushViewController:itemInfoEditVC animated:YES];
    }
    else
    {
        ItemDetailEditVC * objItemDetailEditVC=
        [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
        objItemDetailEditVC.selectedItemInfoDict = nil;
        objItemDetailEditVC.isItemCopy = FALSE;
        objItemDetailEditVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        objItemDetailEditVC.itemInfoEditRedirectionVCDelegate = self;
        
        NSMutableDictionary *navigationInfo = [[NSMutableDictionary alloc] init ];
        navigationInfo[@"isWaitForLiveUpdate"] = @(TRUE);
        objItemDetailEditVC.navigationInfo=navigationInfo;

        [self presentViewController:objItemDetailEditVC animated:YES completion:nil];
    }
}

-(IBAction)searchItem:(id)sender
{
    [self hideMoreOptionView];
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
    _searchBarcode.text = strBarcode;
    [self textFieldShouldReturn:_searchBarcode];
}

- (void)ItemInfornationChangeAt:(NSInteger )indexRow WithNewData:(id)newItemInfo {
    if ([newItemInfo isKindOfClass:[NSDictionary class]]) {
        [self didSelectedItems:@[newItemInfo]];
    }
    else{
        [self didSelectedItems:newItemInfo];
    }
}

-(void)didSelectedItems:(NSArray *)selectedItems // Delegate method of ICSearchItemSelectionVC to display selected item.
{
    self.scannerStatus.hidden = YES;
    self.scanItemListTableView.hidden = NO;
    
    for (int i = 0 ; i < selectedItems.count; i++)
    {
        currentScanitemInventoryCount = nil;
        
        NSString *itemCode = @"";
        Item *anItem = nil;
        
        id selectedItemAtIndex = selectedItems[i];
        
        if ([selectedItemAtIndex isKindOfClass:[NSDictionary class]]) {
            itemCode = [NSString stringWithFormat:@"%@",[selectedItems[i] valueForKey:@"ItemId"]];
            anItem = [self fetchAllItems:itemCode];
        }
        else
        {
            anItem = (Item*)selectedItems[i];
            itemCode = anItem.itemCode.stringValue;
        }
        
        if (selectedItems.count == 1)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self launchICQty_VCWithItem:anItem withItemInventoryCount:currentScanitemInventoryCount];
            });
        }
        else
        {
            NSMutableDictionary *qtyCountInformationDictionary = [[NSMutableDictionary alloc]init];
            qtyCountInformationDictionary[@"addedSingleQty"] = @"0";
            qtyCountInformationDictionary[@"addedCaseQty"] = @"0";
            qtyCountInformationDictionary[@"addedPackQty"] = @"0";
            qtyCountInformationDictionary[@"createDate"] = [NSDate date];
            
            qtyCountInformationDictionary[@"isUploadedToServer"] = @(0);
            qtyCountInformationDictionary[@"userSessionId"] = self.userSessionId;
            qtyCountInformationDictionary[@"isDelete"] = @(0);
            
            qtyCountInformationDictionary[@"itemCode"] = itemCode;
            qtyCountInformationDictionary[@"userId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
            qtyCountInformationDictionary[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
            qtyCountInformationDictionary[@"sessionId"] = countSessionId;
            qtyCountInformationDictionary[@"Id"] = @(0);
            
            NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
            
            [self.iCountUpdateManager modifidedUpdateItemForInventoryCountListwithDetail:qtyCountInformationDictionary withItem:(Item *)OBJECT_COPY(anItem, privateContextObject) withitemInventoryCount:(ItemInventoryCount *)OBJECT_COPY(currentScanitemInventoryCount, privateContextObject) withItemInventorySession:(ItemInventoryCountSession *)OBJECT_COPY(self.currentItemInventoryCountSession, privateContextObject) withInventoryCountSessionDetail:self.inventoryCountSessionDictionary withManageObjectContext:privateContextObject];
            
            currentScanitemInventoryCount = (ItemInventoryCount *)OBJECT_COPY(currentScanitemInventoryCount, self.managedObjectContext);
            self.currentItemInventoryCountSession = (ItemInventoryCountSession *)OBJECT_COPY(self.currentItemInventoryCountSession, self.managedObjectContext);
            
        }
    }
    [self dismissViewControllerAnimated:TRUE completion:^{
        
    }];
    [self sendEachItemToServer];
    //    self.itemInventoryCountResultController = nil;
    //    [self.scanItemListTableView reloadData];
}
-(IBAction)holdItemCount:(id)sender
{
    [self hideMoreOptionView];
    [self.rmsDbController playButtonSound];
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:self.userSessionId forKey:@"UserSessionId"];
        
        NSDate *currentDate = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *currentDateValue = [formatter stringFromDate:currentDate];
        [param setValue:currentDateValue forKey:@"LocalDate"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self responseHoldUserSessionResponse:response error:error];
            });
        };
        
        self.holdUserSessionWC = [self.holdUserSessionWC initWithRequest:KURL actionName:WSM_HOLD_USER_SESSION params:param completionHandler:completionHandler];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Are you sure you want to hold inventory count?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

//-(IBAction)moreOption:(id)sender
//{
//    [self.rmsDbController playButtonSound];
//    _moreBtn.selected = !_moreBtn.selected;
//    if(_moreBtn.selected)
//    {
//        // hide item info view
//        _itemInfoBtn.selected = NO;
//        _itemInfoView.hidden = YES;
//        // show more option view
//        _moreOperationView.hidden = NO;
//    }
//    else
//    {
//        _moreOperationView.hidden = YES;
//    }
//}

-(IBAction)viewReconcile:(id)sender
{
    [self hideMoreOptionView];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
    ItemReconcileListVC *objItemReconcileList = [storyBoard instantiateViewControllerWithIdentifier:@"ItemReconcileListVC_sid"];
    objItemReconcileList.reConcileItemInvCountSession = self.currentItemInventoryCountSession;
    objItemReconcileList.reconcileSessionDictionary = [self.inventoryCountSessionDictionary mutableCopy];
    objItemReconcileList.isViewOnly = YES;
    objItemReconcileList.isReconcileHistory = NO;
    [self.navigationController pushViewController:objItemReconcileList animated:YES];
}

-(IBAction)reConcileItemCount:(id)sender
{
    [self.rmsDbController playButtonSound];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self hideMoreOptionView];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self sendDataToServerForUpdate];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Are you sure you want to reconcile inventory count?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)hideMoreOptionView
{
    _moreBtn.selected = NO;
    _moreOperationView.hidden = YES;
}

- (void)backToHomeVC
{
    NSArray *arryView = self.navigationController.viewControllers;
    for(int i=0; i< arryView.count; i++)
    {
        UIViewController *viewCon = arryView[i];
        if([viewCon isKindOfClass:[ICHomeVC class]] )
        {
            [self.navigationController popToViewController:viewCon animated:YES];
            break;
        }
    }
}
- (void)backToRecallSessionListVC
{
    NSArray *arryView = self.navigationController.viewControllers;
    for(int i=0; i< arryView.count; i++)
    {
        UIViewController *viewCon = arryView[i];
        if([viewCon isKindOfClass:[ICRecallSessionListVC class]] )
        {
            [self.navigationController popToViewController:viewCon animated:YES];
            break;
        }
    }
}


-(void)responseHoldUserSessionResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self backToHomeVC];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error occur while hold inventory count, please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

#pragma mark Coredata table function

- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
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

#pragma mark-
#pragma mark - MultipleItemBarcodeRingUp

-(void)showMultipleItemForBarcodeWithDetail :(NSArray *)itemArray withItemBarcode:(NSString *)barcode
{
    [_searchBarcode resignFirstResponder];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
    inventoryCountItemSelectionDelegate = [storyBoard instantiateViewControllerWithIdentifier:@"InventoryCountItemSelectionVC"];
    inventoryCountItemSelectionDelegate.modalPresentationStyle = UIModalPresentationFullScreen;
    inventoryCountItemSelectionDelegate.inventoryCountItemSelectionVCDelegate = self;
    inventoryCountItemSelectionDelegate.itemBarcode = barcode;
    inventoryCountItemSelectionDelegate.multipleItemArray = [itemArray mutableCopy];
    inventoryCountItemSelectionDelegate.view.frame =self.view.bounds;
    [self.view addSubview:inventoryCountItemSelectionDelegate.view];
    

}

-(void)didSelectItemFromMultipleDuplicateBarcode :(Item *)item
{
    currentScanItem = item;
    currentScanitemInventoryCount = nil;
    [self launchICQty_VCWithItem:item withItemInventoryCount:currentScanitemInventoryCount];
    [inventoryCountItemSelectionDelegate.view removeFromSuperview ];
    _searchBarcode.text = @"";
}


-(void)didCanceMultipleItemBarcodeCustomerVC
{
    [inventoryCountItemSelectionDelegate.view removeFromSuperview ];
    _searchBarcode.text = @"";
}

- (void)launchICQty_VCWithItem:(Item *)item withItemInventoryCount:(ItemInventoryCount *)iteminventoryCount
{
    // ItemEditQty
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
    iCQtyEditVC = [storyBoard instantiateViewControllerWithIdentifier:@"ICQtyEditVC_sid"];
//    ICQtyEditVC *objEditItem = [[ICQtyEditVC alloc]initWithNibName:@"QtyEditVC_ipad" bundle:Nil];
    iCQtyEditVC.selectedItem = item;
    iCQtyEditVC.selectedItemInventoryCount = iteminventoryCount;
    iCQtyEditVC.iCQtyEditDelegate = self;
    if(IsPad())
    {
        iCQtyEditVC.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:iCQtyEditVC animated:YES completion:Nil];

    }
    else
    {
        [self.navigationController pushViewController:iCQtyEditVC animated:YES];

    }
}



#pragma mark Insert Item In Local Data Base
-(void)didAddItemToInventoryCountListWith:(ItemInventoryCount *)itemInventoryCount withItem:(Item *)item withCountDetail:(NSMutableDictionary *)countDictionary
{
    countDictionary[@"sessionId"] = countSessionId;
    
    countDictionary[@"isUploadedToServer"] = @(0);
    countDictionary[@"userSessionId"] = self.userSessionId;
    countDictionary[@"isDelete"] = @(0);
    if(itemInventoryCount == nil)
    {
        countDictionary[@"Id"] = @(0);
    }
    else
    {
        countDictionary[@"Id"] = itemInventoryCount.itemCountId;
    }
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    [self.iCountUpdateManager modifidedUpdateItemForInventoryCountListwithDetail:countDictionary withItem:(Item *)OBJECT_COPY(item, privateContextObject) withitemInventoryCount:(ItemInventoryCount *)OBJECT_COPY(currentScanitemInventoryCount, privateContextObject) withItemInventorySession:(ItemInventoryCountSession *)OBJECT_COPY(self.currentItemInventoryCountSession, privateContextObject) withInventoryCountSessionDetail:self.inventoryCountSessionDictionary withManageObjectContext:privateContextObject];

    currentScanitemInventoryCount = (ItemInventoryCount *)OBJECT_COPY(currentScanitemInventoryCount, self.managedObjectContext);
    self.currentItemInventoryCountSession = (ItemInventoryCountSession *)OBJECT_COPY(self.currentItemInventoryCountSession, self.managedObjectContext);
    
//    self.itemInventoryCountResultController = nil;
//    [self.scanItemListTableView reloadData];
    
    [self sendEachItemToServer];
}

- (NSMutableDictionary *)configureItemDictionaryForUpload:(ItemInventoryCount *)itemInvCount
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[NSString stringWithFormat:@"%@",countSessionId.stringValue] forKey:@"StockSessionId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    param[@"SingleCount"] = itemInvCount.singleCount;
    param[@"CaseCount"] = itemInvCount.caseCount;
    param[@"PackCount"] = itemInvCount.packCount;
    param[@"ItemCode"] = itemInvCount.itemCode;
    [param setValue:[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateValue = [formatter stringFromDate:currentDate];
    [param setValue:currentDateValue forKey:@"LocalDate"];
    [param setValue:self.userSessionId forKey:@"UserSessionId"];
    return param;
}

- (NSMutableDictionary *)sendInsertedItemToServerForUpload:(ItemInventoryCount *)itemInvCount
{
    NSMutableDictionary *param = [self configureItemDictionaryForUpload:itemInvCount];
    
    NSMutableDictionary *itemInvCountData = [[NSMutableDictionary alloc] init];
    [itemInvCountData setValue:param forKey:@"objItemInvCount"];
    return itemInvCountData;
}

- (NSMutableDictionary *)sendUpdatedItemToServerForUpload:(ItemInventoryCount *)itemInvCount
{
    
    NSMutableDictionary *param = [self configureItemDictionaryForUpload:itemInvCount];
    [param setValue:itemInvCount.itemCountId forKey:@"Id"];
    
    NSMutableDictionary *itemInvCountData = [[NSMutableDictionary alloc] init];
    [itemInvCountData setValue:param forKey:@"objItemInvCount"];
    return itemInvCountData;
}

- (NSArray *)itemCountsToUpload
{
//    NSManagedObjectContext *moc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
//    NSManagedObjectContext *moc = self.managedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryCount" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isUploadedToServer == %@ AND userSessionId == %@ AND sessionId == %@", @(0), self.userSessionId, countSessionId];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return resultSet;
}

-(void)sendEachItemToServer
{
    NSArray *resultSet;
    
    resultSet = [self itemCountsToUpload];
    NSLog(@"Upload Count %lu",(unsigned long)resultSet.count);
    if(resultSet.count > 0 )
    {
    //    self.isUploading = TRUE;
        ItemInventoryCount *itemInvCount = resultSet.firstObject;
        objectIdOfUpdatingItem = itemInvCount.objectID;
        if ([itemInvCount.isDelete isEqualToNumber:@(1)]) // If deleting item
        {
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setValue:[NSString stringWithFormat:@"%@",countSessionId.stringValue] forKey:@"StockSessionId"];
            [param setValue:itemInvCount.itemCountId forKey:@"ItemInvId"];
            [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];

            CompletionHandler completionHandler = ^(id response, NSError *error) {
                [self resDeleteIemInventoryCountDataResponse:response error:error];
            };
            
            self.deleteItemCountWebservice = [self.deleteItemCountWebservice initWithRequest:KURL actionName:WSM_DELETE_ITEM_INVENTORY_COUNT_DATA params:param completionHandler:completionHandler];
        }
        else if([itemInvCount.itemCountId isEqualToNumber:@(0)]) // If inserting item
        {
            NSMutableDictionary *itemInvCountData = [self sendInsertedItemToServerForUpload:itemInvCount];
       //     itemInvCount.isUploadedToServer = @(1);
            [UpdateManager saveContext:itemInvCount.managedObjectContext];
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                [self resAddItemInventoryCountDataResponse:response error:error];
            };
            
            self.additemCountWebservice = [self.additemCountWebservice initWithRequest:KURL actionName:WSM_ADD_ITEM_INVENTORY_COUNT_DATA params:itemInvCountData completionHandler:completionHandler];

        }
        else if (itemInvCount.itemCountId) // If updating item
        {
            NSMutableDictionary *itemInvCountData;
            itemInvCountData = [self sendUpdatedItemToServerForUpload:itemInvCount];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                [self resUpdateItemInventoryCountDataResponse:response error:error];
            };
            
            self.updateItemCountWebservice = [self.updateItemCountWebservice initWithRequest:KURL actionName:WSM_UPDATE_ITEM_INVENTORY_COUNT_DATA params:itemInvCountData completionHandler:completionHandler];
        }
    }
}

// Response of Inserted Item
- (void)resAddItemInventoryCountDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {

            ItemInventoryCount *itemInvCount;
            itemInvCount = (ItemInventoryCount *)[self.managedObjectContext objectWithID:objectIdOfUpdatingItem];

            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSString *itmCountId = [response valueForKey:@"Data"];
                NSNumber *itemCountId = @(itmCountId.integerValue);
                
                itemInvCount.isUploadedToServer = @(1);
                itemInvCount.itemCountId = itemCountId;
            }
//            else{
//                itemInvCount.isUploadedToServer = @(0);
//            }
            [UpdateManager saveContext:self.managedObjectContext];

        }
    }
    [self sendEachItemToServer];
}

// Response of Updated Item
- (void)resUpdateItemInventoryCountDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSString *itmCountId = [response valueForKey:@"Data"];
                NSNumber *itemCountId = @(itmCountId.integerValue);
                
                ItemInventoryCount *itemInvCount;
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                itemInvCount = (ItemInventoryCount *)[privateContextObject objectWithID:objectIdOfUpdatingItem];
                
                itemInvCount.isUploadedToServer = @(1);
                itemInvCount.itemCountId = itemCountId;
                [UpdateManager saveContext:privateContextObject];
            }
        }
    }
    [self sendEachItemToServer];
}

// Response of Deleted Item
- (void)resDeleteIemInventoryCountDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                ItemInventoryCount *itemInvCount;
                NSManagedObjectContext *moc2 = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                itemInvCount = (ItemInventoryCount *)[moc2 objectWithID:objectIdOfUpdatingItem];
                [self.iCountUpdateManager removeItemInventoryCount:itemInvCount withManageObjectContext:moc2];
            }
        }
    }
    [self sendEachItemToServer];
}

-(void)didCancelItemInventoryCountProcess
{
    
}


-(NSArray *)fetchInventoryCountRecordFromLocalDatabase
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryCount" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionId == %@", countSessionId];
    fetchRequest.predicate = predicate;
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    NSArray *itemInventoryCountRecords = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return itemInventoryCountRecords;
}

-(void)sendDataToServerForUpdate
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[NSString stringWithFormat:@"%@",self.userSessionId] forKey:@"userSessionId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateValue = [formatter stringFromDate:currentDate];
    [param setValue:currentDateValue forKey:@"CurrentDate"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self resCloseInventoryUserSessionResponse:response error:error];
    };
    
    self.closeInventoryUserSessionWC = [self.closeInventoryUserSessionWC initWithRequest:KURL actionName:WSM_CLOSE_INVENTORY_USER_SESSION params:param completionHandler:completionHandler];
}

- (void)resCloseInventoryUserSessionResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self.rmsDbController playButtonSound];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [self backToHomeVC];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Reconcile process is successfully completed." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(NSArray *)filterReconcileInventoryCountWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryReconcileCount" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return resultSet;
}

-(NSInteger)filterInventoryCount
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryCount" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionId == %@ AND isDelete == %@", countSessionId,@(0)];
    fetchRequest.predicate = predicate;
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];

    return resultSet.count;
}

-(NSInteger )reconcileInventoryCountObjectSum
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionId == %d", countSessionId.integerValue];
    NSArray *resultSet = [self filterReconcileInventoryCountWithPredicate:predicate];
    
    NSInteger singleCount = 0;
    NSInteger caseCount = 0;
    NSInteger packCount = 0;
    totalCostForReconcileItem = 0.00;
    
    NSInteger productCount = 0;
    
    for (ItemInventoryReconcileCount *itemInventoryReconcileCount in resultSet)
    {
        NSInteger singleQuntity = itemInventoryReconcileCount.singleQuantity.integerValue;
        NSInteger caseQuntity = itemInventoryReconcileCount.caseQuantity.integerValue;
        NSInteger packQuntity = itemInventoryReconcileCount.packQuantity.integerValue;
        
        if (singleQuntity !=0 || caseQuntity != 0 || packQuntity != 0)
        {
            productCount ++;

        }

        for (ItemInventoryCount *itemInventoryCount in itemInventoryReconcileCount.itemInventoryCounts)
        {
            singleCount +=itemInventoryCount.singleCount.integerValue * singleQuntity;
            caseCount +=itemInventoryCount.caseCount.integerValue * caseQuntity;
            packCount +=itemInventoryCount.packCount.integerValue * packQuntity;
            totalCostForReconcileItem += itemInventoryCount.itemCountItem.costPrice.floatValue * (itemInventoryCount.singleCount.integerValue * singleQuntity + itemInventoryCount.caseCount.integerValue * caseQuntity + itemInventoryCount.packCount.integerValue * packQuntity ) ;
        }
    }
    return productCount;
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != self.itemInventoryCountResultController)
    {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.scanItemListTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != self.itemInventoryCountResultController)
    {
        return;
    }
    
    UITableView *tableView = self.scanItemListTableView;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.scanItemListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(controller != self.itemInventoryCountResultController)
    {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.scanItemListTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.scanItemListTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != self.itemInventoryCountResultController)
    {
        return;
    }
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.scanItemListTableView endUpdates];
}

#pragma mark - Device scanner methods

bool icCountScanActive = false;

#ifdef LINEAPRO_SUPPORTED

-(void)connectionState:(int)state
{
	switch (state) {
		case CONN_DISCONNECTED:
		case CONN_CONNECTING:
			[self.scannerStatus setImage:[UIImage imageNamed:@"img_ScannerNotConnected.png"]];
//            self.scannerStatus.text = @"Scanner Not Connected";
			break;
		case CONN_CONNECTED:
            icCountScanActive=false;
			[self.scannerStatus setImage:[UIImage imageNamed:@"img_scannerConnected.png"]];
//            self.scannerStatus.text = @"Scan Item";
			break;
	}
}

-(void)deviceButtonPressed:(int)which
{
    [status setString:@""];
    if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Scanner"])
    {
        if([self._rimController.scannerButtonCalled isEqualToString:@"ItemCountListVC"])
        {
            [debug setString:@""];
            [self.scannerStatus setImage:[UIImage imageNamed:@"scanning.png"]];
//            self.scannerStatus.text = @"Scanning";
//            if (![self.scannerStatus isFirstResponder]) {
//                [self.scannerStatus becomeFirstResponder];
//            }
        }
    }
}

-(void)deviceButtonReleased:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Scanner"])
    {
        if([self._rimController.scannerButtonCalled isEqualToString:@"ItemCountListVC"])
        {
            if(![status isEqualToString:@""])
            {
//                [self.scannerStatus endEditing:YES];
                [self searchBarcodeItem];
            }
            else
            {
                
            }
            [self.scannerStatus setImage:[UIImage imageNamed:@"img_scannerConnected.png"]];
//            self.scannerStatus.text = @"Scanning";
        }
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Please set scanner type as scanner." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }

}

// Barcode Result display via this function
-(void)barcodeData:(NSString *)barcode type:(int)type
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        [status appendFormat:@"%@",barcode];
        _searchBarcode.text = barcode;
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Please set scanner type as scanner." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}
#endif
@end
