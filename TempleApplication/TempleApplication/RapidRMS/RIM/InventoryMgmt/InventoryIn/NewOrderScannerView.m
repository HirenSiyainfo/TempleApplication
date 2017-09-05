//
//  NewOrderScannerView.m
//  I-RMS
//
//  Created by Siya Infotech on 16/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "EmailFromViewController.h"
#import "ExportPopupVC.h"
#import "InventoryItemSelectionListVC.h"
#import "InvnetoryInCustomCell.h"
#import "ItemDetailEditVC.h"
#import "ItemInfoEditVC.h"
#import "ItemInfoPopupVC.h"
#import "NewOrderScannerView.h"
#import "RimIphonePresentMenu.h"
#import "RIMNumberPadPopupVC.h"
#import "RimsController.h"
#import "RmsDbController.h"
#import "UserInputTextVC.h"


// CoreData Import
#import "Item+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "Department+Dictionary.h"
#import "CameraScanVC.h"

//#define LOG_FILE
@interface NewOrderScannerView ()<CameraScanVCDelegate,ItemInfoEditRedirectionVCDelegate ,EmailFromViewControllerDelegate, ExportPopupVCDelegate,InventoryItemSelectionListVCDelegate>
{
    EmailFromViewController *emailFromViewController;
    IntercomHandler *intercomHandler;
    
    NSMutableString *status;
    NSMutableString *debug;
    
    NSInteger deleteRecordId;
    
    BOOL flgCopyButtonClicked;
    BOOL flgCopyScanITem;
    
    NSInteger swipedRecordID;
    
    RimIphonePresentMenu * objMenubar;
    Configuration *configuration;

    UITextField *activeField;
    
    NSString *currentDateTime;
    NSString * strUserInputMsg;
    NSString * strDate,* strTime;
}
@property (nonatomic, strong) RmsDbController * rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;
@property (nonatomic, strong) UpdateManager * updateManager;
@property (nonatomic, strong) UpdateManager * iteminUpdateManager;

@property (nonatomic, weak) RmsActivityIndicator * activityIndicator;
@property (nonatomic, strong) UIDocumentInteractionController *controller;
@property (nonatomic, strong) NSString *emaiItemHtml;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;

@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) NSMutableDictionary *emailTempDictionary;
@property (nonatomic, strong) NSMutableArray *arrItemInOpenData;

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnTotalItemInfo;
@property (nonatomic, weak) IBOutlet UIButton *pdfEmailBtn;

@property (nonatomic, weak) IBOutlet UITextField *txtMainBarcode;

@property (nonatomic, weak) IBOutlet UIImageView *statusImage;
@property (nonatomic, weak) IBOutlet UITableView *tblScannedItemList;

@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblTime;

@property (nonatomic, strong) NSMutableArray *arrItemInOpenOrder;
@property (nonatomic, strong) NSString *strTypeOfOperation;
@property (nonatomic, strong) NSIndexPath *indPath;

@property (nonatomic, strong) NSMutableArray *arrScanBarDetails;
@property (nonatomic, strong) NSIndexPath *clickedTextIndPath;

@property (nonatomic, strong) NSMutableDictionary *dictInventoryMain;
@property (assign) bool suspendDisplayInfo;
@property (nonatomic, strong) NSMutableArray *arrFilterSupplier;
@property (nonatomic, strong) NSMutableArray *arrFilterDepartment;

@property (nonatomic, strong) RapidWebServiceConnection * activeItemInWSC;
@property (nonatomic, strong) RapidWebServiceConnection * mgmtItemInsertWC;
@property (nonatomic, strong) RapidWebServiceConnection * addInventoryInWC;
@property (nonatomic, strong) RapidWebServiceConnection * updateInventoryInWC;

@end

@implementation NewOrderScannerView


- (void)viewDidLoad
{
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.addInventoryInWC = [[RapidWebServiceConnection alloc]init];
    self.mgmtItemInsertWC = [[RapidWebServiceConnection alloc]init];
    self.updateInventoryInWC = [[RapidWebServiceConnection alloc]init];
    self.activeItemInWSC = [[RapidWebServiceConnection alloc]init];
    
    self.managedObjectContext=self.rmsDbController.managedObjectContext;
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    self.iteminUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    if (IsPhone()) {
        objMenubar = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimIphonePresentMenu_sid"];
        objMenubar.sideMenuVCDelegate = self.sideMenuVCDelegate;
    }
    
    self.suspendDisplayInfo = false;
	status = [[NSMutableString alloc] init];
	debug = [[NSMutableString alloc] init];
    self.arrScanBarDetails = [[NSMutableArray alloc] init];
    
    #ifdef LOG_FILE
	NSFileManager *fileManger = [NSFileManager defaultManager];
	if ([fileManger fileExistsAtPath:[self getLogFile]])
	{
		[debug appendString:[[NSString alloc] initWithContentsOfFile:[self getLogFile]]];
		[debugText setText:debug];
	}
    #endif

    if([self.rimsController.scannerButtonCalled isEqualToString:@""]) {
        
        self.rimsController.scannerButtonCalled=@"InvnetoryIn";
    }
    
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
    
    flgCopyButtonClicked=FALSE;
    
    [_txtMainBarcode becomeFirstResponder];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    [super viewDidLoad];
}

-(void)viewInventoryItem:(NSArray *) dictArrItemMain
{
    self.arrScanBarDetails = [dictArrItemMain mutableCopy];
}

-(void)viewInventoryMain:(NSArray *) arrInventoryMain
{
    self.dictInventoryMain = arrInventoryMain.firstObject;
    NSString  *Datetime = [NSString stringWithFormat:@"%@",[self.dictInventoryMain valueForKey:@"CreatedDate"]];
    strDate = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy"];
    strTime = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];

    if (IsPad()) {
        _lblDate.text = strDate;
        _lblTime.text = strTime;
    }
    else{
        _lblDate.text = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
    }
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    currentDateTime=[NSString stringWithFormat:@"%@",destinationDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM dd, yyyy";
    dateFormatter.timeZone = sourceTimeZone;
    NSString *date = [dateFormatter stringFromDate:destinationDate];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    timeFormatter.timeZone = sourceTimeZone;
    NSString *time = [timeFormatter stringFromDate:destinationDate];
    
    if(_lblDate.text.length == 0)
    {
        strDate = date;
        strTime = time;
        if (IsPad()) {
            _lblDate.text = strDate;
            _lblTime.text = strTime;
        }
        else{
            _lblDate.text = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
        }
    }

    if(self.arrInOpenData.count > 0)
    {
        NSMutableDictionary *dict = self.arrInOpenData.firstObject;
        [self viewInventoryItem:dict[@"InventoryItem"]];
        [self viewInventoryMain:dict[@"InventoryMain"]];
        [self.tblScannedItemList reloadData];
        [self.arrInOpenData removeAllObjects];
    }
    
    [self.tblScannedItemList reloadData];
	//update display according to current dtdev state
    self.suspendDisplayInfo=false;

    self.rimsController.scannerButtonCalled = @"InvnetoryIn";
    
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
    [self checkConnectedScanner];
}

#pragma mark - Check scanner type
- (void)checkConnectedScanner
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
    {
        _txtMainBarcode.hidden = FALSE;
        _txtMainBarcode.userInteractionEnabled = TRUE;
        [_txtMainBarcode becomeFirstResponder];
    }
    else
    {
        _txtMainBarcode.hidden = TRUE;
        _txtMainBarcode.userInteractionEnabled = FALSE;
    }
}

-(IBAction)btn_back:(id)sender {
    
    [self.rmsDbController playButtonSound];
    self.rimsController.scannerButtonCalled=@"";
    [self presentViewController:objMenubar animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/* add new item function */

-(IBAction)btnAddNewItem:(id)sender
{
    [Appsee addEvent:kRIMItemInFooterAddNew];
    [self.rmsDbController playButtonSound];
    if(IsPhone())
    {
        ItemInfoEditVC *objInventoryAdd = [[UIStoryboard storyboardWithName:@"RimStoryboard_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];
        objInventoryAdd.NewOrderCalled=TRUE;
        if (objInventoryAdd.itemInfoDataObject==nil) {
            objInventoryAdd.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
        }
        [objInventoryAdd.itemInfoDataObject setItemMainDataFrom:nil];
        [self.sideMenuVCDelegate willPushViewController:objInventoryAdd animated:YES];
    }
    else
    {
        NSMutableDictionary *navigationInfo = [[NSMutableDictionary alloc] init ];
        navigationInfo[@"NewOrderCalled"] = @(TRUE);
        navigationInfo[@"objNewOrderAdd"] = self;
        [self showInventoryAddNew:nil navigationInfo:navigationInfo];
    }
}

-(IBAction)btnSearchItem:(id)sender
{
    [Appsee addEvent:kRIMItemInFooterSearch];
    [self.rmsDbController playButtonSound];
    
    if(IsPhone())
    {
        NSArray *arryView = self.navigationController.viewControllers;
        for(int i=0;i<arryView.count;i++)
        {
            UIViewController *viewCon = arryView[i];
            if([viewCon isKindOfClass:[InventoryItemSelectionListVC class]]){
                [self.navigationController popToViewController:viewCon animated:YES];
                return;
            }
        }
    }
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

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([configuration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

- (void)barcodeSearchItem
{
    BOOL isNumeric;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:_txtMainBarcode.text];
    isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) // numeric
    {
        _txtMainBarcode.text = [self.rmsDbController trimmedBarcode:_txtMainBarcode.text];
    }
    
    BOOL isScanItemfound = FALSE;
    
    Item *getitem=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate;
    if ([self isSubDepartmentEnableInBackOffice]) {
        predicate = [NSPredicate predicateWithFormat:@"(barcode == %@ OR ANY itemBarcodes.barCode == %@) AND active == %d", _txtMainBarcode.text,_txtMainBarcode.text,TRUE];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"(barcode == %@ OR ANY itemBarcodes.barCode == %@) AND active == %d AND itm_Type != %@", _txtMainBarcode.text,_txtMainBarcode.text,TRUE,@(2)];
    }

    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        getitem=resultSet.firstObject;
    }
    
    NSMutableDictionary *dictItemClicked = [getitem.itemRMSDictionary mutableCopy];
    
    if(dictItemClicked != nil)
    {
        dictItemClicked[@"AddedQty"] = @"1";
        
        NSString * strItemCode=[NSString stringWithFormat:@"%d",[[dictItemClicked valueForKey:@"ItemId"]intValue]];
        
        BOOL isExtisData=FALSE;
        
        if(self.arrScanBarDetails.count>0)
        {
            for (int idata=0; idata < self.arrScanBarDetails.count; idata++) {
                NSString *sItemId=[NSString stringWithFormat:@"%d",[[(self.arrScanBarDetails)[idata]valueForKey:@"ItemId"]intValue]];
                if([sItemId isEqualToString:strItemCode])
                {
                    isExtisData=TRUE;
                    break;
                }
            }
        }
        
        if(isExtisData)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"%@ item already existed.",_txtMainBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        else
        {
            NSString *barCode = _txtMainBarcode.text;
            NSString *itemCode = dictItemClicked[@"ItemId"];
            
            BOOL isBarcodeExist = [self.iteminUpdateManager doesBarcodeExist:barCode forItemCode:itemCode];
            if(isBarcodeExist)
            {
                dictItemClicked[@"Barcode"] = barCode;
            }
            else
            {
                
            }
            [self.arrScanBarDetails insertObject:dictItemClicked atIndex:0];
            [self.tblScannedItemList reloadData];
        }
        isScanItemfound = TRUE;
        [_txtMainBarcode becomeFirstResponder];
    }
    if(!isScanItemfound)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [itemparam setValue:_txtMainBarcode.text forKey:@"Code"];
        [itemparam setValue:@"Barcode" forKey:@"Type"];
        NSDictionary *barcodeDict = @{kRIMItemInBarcodeSearchWebServiceCallKey : _txtMainBarcode.text};
        [Appsee addEvent:kRIMItemInBarcodeSearchWebServiceCall withProperties:barcodeDict];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self responseInvnetoryInDataResponse:response error:error];
            });
        };
        
        self.mgmtItemInsertWC = [self.mgmtItemInsertWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
    }
    else
    {
        [_txtMainBarcode resignFirstResponder];
        _txtMainBarcode.text = @"";
    }
    [self.tblScannedItemList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    NSInteger tmprow = self.indPath.row;
    if(tmprow > -1)
    {
        self.indPath=[NSIndexPath indexPathForRow:tmprow + 1 inSection:0];
    }
}

// barcode scan data, txtMainBarcode and device scanner

-(void)responseInvnetoryInDataResponse:(id)response error:(NSError *)error {

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
                    [Appsee addEvent:kRIMItemInBarcodeSearchWebServiceResponse withProperties:@{kRIMItemInBarcodeSearchWebServiceResponseKey : @"No Record Found"}];
                    
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        [_txtMainBarcode becomeFirstResponder];
                        _txtMainBarcode.text = @"";
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"No Record Found for %@",_txtMainBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    [self checkConnectedScanner];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"mgmtItemInsertResult" object:nil];
                    return;
                }
                else if ([[[itemDict valueForKey:@"Active"] stringValue] isEqualToString:@"0"]) // if not active
                {
                    [Appsee addEvent:kRIMItemInBarcodeSearchWebServiceResponse withProperties:@{kRIMItemInBarcodeSearchWebServiceResponseKey : @"This Item is currently not Activated."}];
                    
                    NewOrderScannerView * __weak myWeakReference = self;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        NSString *strItemId = [NSString stringWithFormat:@"%@",[itemDict valueForKey:@"ITEMCode"]];
                        Item *currentItem = [self fetchAllItems:strItemId];
                        [myWeakReference moveINVInActiveItemToActiveItemList:currentItem];
                    };
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"This item is inactive would you like to activate it?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                    [self checkConnectedScanner];
                }
                else // if not deleted than add to coredata
                {
                    [Appsee addEvent:kRIMItemInBarcodeSearchWebServiceResponse withProperties:@{kRIMItemInBarcodeSearchWebServiceResponseKey : @"Record Found"}];
                    
                    [self.iteminUpdateManager updateObjectsFromResponseDictionary:responseDictionary];
                    [self.iteminUpdateManager linkItemToDepartmentFromResponseDictionary:responseDictionary];
                    Item *anItem=[self fetchAllItems:[[[responseDictionary valueForKey:@"ItemArray"] firstObject ]valueForKey:@"ITEMCode"]];
                    if (anItem) {
                        NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
                        dictItemClicked[@"AddedQty"] = @"1";
                        [self.arrScanBarDetails insertObject:dictItemClicked atIndex:0];
                    }
                    [self.tblScannedItemList reloadData];
                }
            }
            else
            {
                [Appsee addEvent:kRIMItemInBarcodeSearchWebServiceResponse withProperties:@{kRIMItemInBarcodeSearchWebServiceResponseKey : @"No Record Found"}];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [_txtMainBarcode becomeFirstResponder];
                    _txtMainBarcode.text = @"";
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"No Record Found for %@",_txtMainBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self checkConnectedScanner];
            }

        }
    }
}

- (void)moveINVInActiveItemToActiveItemList:(Item *)anItem
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * dictItemInfo;
    dictItemInfo = [self getParamToActiveItem:anItem isItemActive:@"1"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseInForMoveItemToActiveListResponse:response error:error];
        });
    };
    
    self.activeItemInWSC = [self.activeItemInWSC initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:dictItemInfo completionHandler:completionHandler];
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

-(void)responseInForMoveItemToActiveListResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];

    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSString * strItemId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
                Item * currentItem = [self fetchAllItems:strItemId];
                currentItem.active = @1;
                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                }
                [self barcodeSearchItem];
                _txtMainBarcode.text = @"";
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
    _txtMainBarcode.text = strBarcode;
    [self textFieldShouldReturn:_txtMainBarcode];
}

#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if((textField == _txtMainBarcode) && _txtMainBarcode.text.length > 0)
    {
        NSDictionary *searchDict = @{kRIMItemInBarcodeSearchKey : textField.text};
        [Appsee addEvent:kRIMItemInBarcodeSearch withProperties:searchDict];
        [self barcodeSearchItem];
        return YES;
    }
    else
    {
        [textField resignFirstResponder];
        return YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(textField != _txtMainBarcode)
    {
        CGPoint textboxPosition = [textField convertPoint:CGPointZero toView:self.tblScannedItemList];
        NSIndexPath * cellIndexPath = [self.tblScannedItemList indexPathForRowAtPoint:textboxPosition];
        
        RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:NumberPadPickerTypesQTY NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
            if(numInput.floatValue == 0)
            {
                numInput = @(0);
            }
            NSMutableDictionary *dict = self.arrScanBarDetails[cellIndexPath.row];
            dict[@"AddedQty"] = numInput.stringValue;
            //                self.arrScanBarDetails[self.clickedTextIndPath.row] = dict;
            [self.tblScannedItemList reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        } NumberPadColseInput:^(UIViewController *popUpVC) {
            [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        }];
        objRIMNumberPadPopupVC.inputView = textField;
        [objRIMNumberPadPopupVC presentVCForRightSide:self WithInputView:textField];
//        [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:self sourceView:textField ArrowDirection:UIPopoverArrowDirectionRight];
        return FALSE;
    }
    return TRUE;
}

- (void)doneButton // Function for Iphone Numberpad
{
    if([activeField.text isEqual: @""])
    {
        NSMutableDictionary *dict = (self.arrScanBarDetails)[self.clickedTextIndPath.row];
        dict[@"AddedQty"] = @"1";
        (self.arrScanBarDetails)[self.clickedTextIndPath.row] = dict;
        activeField.text = @"1";
        [activeField resignFirstResponder];
    }
    else
    {
        NSMutableDictionary *dict = (self.arrScanBarDetails)[self.clickedTextIndPath.row];
        dict[@"AddedQty"] = activeField.text;
        (self.arrScanBarDetails)[self.clickedTextIndPath.row] = dict;
        [activeField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
{
    if (IsPad())
    {
        if(textField != _txtMainBarcode)
        {
            if([activeField.text isEqual: @""])
            {
                NSMutableDictionary *dict = (self.arrScanBarDetails)[self.clickedTextIndPath.row];
                dict[@"AddedQty"] = @"1";
                (self.arrScanBarDetails)[self.clickedTextIndPath.row] = dict;
                activeField.text = @"1";
                [activeField resignFirstResponder];
            }
            else
            {
                NSMutableDictionary *dict = (self.arrScanBarDetails)[self.clickedTextIndPath.row];
                dict[@"AddedQty"] = activeField.text;
                (self.arrScanBarDetails)[self.clickedTextIndPath.row] = dict;
                [activeField resignFirstResponder];
            }
        }
    }
    return YES;
}

/* save item */

-(IBAction)btnHoldItemClicked:(id)sender
{
    [Appsee addEvent:kRIMItemInFooterHold];
    [self.rmsDbController playButtonSound];
    self.strTypeOfOperation = @"OPEN";
    
    if((self.arrScanBarDetails).count > 0) {
        [self setUserInputViewWithMessage:[NSString stringWithFormat:@"%@",[self.dictInventoryMain valueForKey:@"Description"]]];
    }
    else {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Add some product." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

-(IBAction)btnSaveItemClicked:(id)sender
{
    [Appsee addEvent:kRIMItemInFooterSave];
    [self.rmsDbController playButtonSound];
    self.strTypeOfOperation = @"CLOSE";
    
    if((self.arrScanBarDetails).count > 0) {
        [self setUserInputViewWithMessage:[NSString stringWithFormat:@"%@",[self.dictInventoryMain valueForKey:@"Description"]]];
    }
    else {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Add some product." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

-(void)setUserInputViewWithMessage:(NSString *)strMessage {
    UserInputTextVC * objUserInputTextVC = [UserInputTextVC setInputTextViewViewitem:@"" InputTitle:@"Add Item Message" InputSaved:^(NSString *strInput) {
        strUserInputMsg = strInput;
    } InputClosed:^(UIViewController *popUpVC) {
        [((UserInputTextVC *)popUpVC) popoverPresentationControllerShouldDismissPopover];
        [self.rmsDbController playButtonSound];
        if(self.isItemOrderUpdate) {
            [self updateItemInRecord];
        }
        else {
            [self btnSaveRecord:nil];
        }
    }];
    objUserInputTextVC.isKeybordShow = TRUE;
    [objUserInputTextVC presentViewControllerForviewConteroller:self sourceView:nil ArrowDirection:(UIPopoverArrowDirection)nil];
    self.popoverPresentationController.delegate = objUserInputTextVC;
}
-(IBAction)btnSaveRecord:(id)sender
{
    if(self.arrScanBarDetails.count > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *addInvenIn = [self insertAddInventoryIn];
        NSDictionary *addInventoryDict = @{kRIMItemInAddInventoryWebServiceCallKey : @([[addInvenIn valueForKey:@"InventoryInDetail"] count])};
        [Appsee addEvent:kRIMItemInAddInventoryWebServiceCall withProperties:addInventoryDict];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getInsertAddInventoryResponse:response error:error];
            });
        };
        
        self.addInventoryInWC = [self.addInventoryInWC initWithRequest:KURL actionName:WSM_ADD_INVENTORY_IN params:addInvenIn completionHandler:completionHandler];
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Add some product to place order" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

- (void) getInsertAddInventoryResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [Appsee addEvent:kRIMItemInAddInventoryWebServiceResponse withProperties:@{kRIMItemInAddInventoryWebServiceResponseKey : @"Order added successfully"}];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Order added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self.arrScanBarDetails removeAllObjects];
                [self.tblScannedItemList reloadData];
            }
            else {
                [Appsee addEvent:kRIMItemInAddInventoryWebServiceResponse withProperties:@{kRIMItemInAddInventoryWebServiceResponseKey : @"Order not added."}];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Order not added." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

- (NSMutableDictionary *) insertAddInventoryIn
{
    NSMutableDictionary * addItemInventoryIn = [[NSMutableDictionary alloc] init];
    NSMutableArray * InventoryIn = [[NSMutableArray alloc] init];
	
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
	itemDetailDict[@"InventoryMst"] = [self InventoryMst];
    itemDetailDict[@"InventoryItemDetail"] = [self InventoryItemDetail];
	[InventoryIn addObject:itemDetailDict];
	addItemInventoryIn[@"InventoryInDetail"] = InventoryIn;
	return addItemInventoryIn;
}

- (NSMutableArray *) InventoryMst
{
    NSMutableArray *arrItemMst = [[NSMutableArray alloc] init];
	NSMutableDictionary *dictItemMstData = [[NSMutableDictionary alloc] init];
    
    dictItemMstData[@"OrderNo"] = @"";
    dictItemMstData[@"Date"] = currentDateTime;
    dictItemMstData[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictItemMstData[@"UserId"] = [NSString stringWithFormat:@"%@",userID ];
    
    dictItemMstData[@"Type"] = self.strTypeOfOperation;
    dictItemMstData[@"Description"] = strUserInputMsg;
    
    [arrItemMst addObject:dictItemMstData];
	return arrItemMst;
}

- (NSMutableArray *) InventoryItemDetail
{
    NSMutableArray *arrItemInventory = [[NSMutableArray alloc] init];
    
    if(self.arrScanBarDetails.count>0)
    {
        for (int isup=0; isup < self.arrScanBarDetails.count; isup++)
        {
            // AddedQty, Barcode, CostPrice, ItemId, SalesPrice, avaibleQty
            NSMutableDictionary *tmpSup = [(self.arrScanBarDetails)[isup] mutableCopy ];
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"AddedQty",@"Barcode",@"CostPrice",@"ItemId",@"SalesPrice",@"avaibleQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = speDict.allKeys;
            [tmpSup removeObjectsForKeys:speKeys];
            [arrItemInventory addObject:tmpSup];
        }
    }
	return arrItemInventory;
    
}

/* */

// Update open in record start //

-(void)updateItemInRecord
{
    if(self.arrScanBarDetails.count > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *updateInvenIn = [self UpdateInOpenData];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getUpdateInventoryInResponse:response error:error];
            });
        };
        
        self.updateInventoryInWC = [self.updateInventoryInWC initWithRequest:KURL actionName:WSM_UPDATE_INVENTORY_IN params:updateInvenIn completionHandler:completionHandler];
    }
}

- (void) getUpdateInventoryInResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Order added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self.arrScanBarDetails removeAllObjects];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Order not updated." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}

- (NSMutableDictionary *) UpdateInOpenData
{
    NSMutableDictionary * addItemInventoryIn = [[NSMutableDictionary alloc] init];
    NSMutableArray * InventoryIn = [[NSMutableArray alloc] init];
	
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
	itemDetailDict[@"InventoryMst"] = [self updateInventoryMst];
    itemDetailDict[@"InventoryItemDetail"] = [self updateInventoryItemDetail];
	[InventoryIn addObject:itemDetailDict];
	addItemInventoryIn[@"InventoryInDetail"] = InventoryIn;
	return addItemInventoryIn;
}

- (NSMutableArray *) updateInventoryMst
{
    NSMutableArray *arrItemMst = [[NSMutableArray alloc] init];
	NSMutableDictionary *dictItemMstData = [[NSMutableDictionary alloc] init];
    
    dictItemMstData[@"OrderNo"] = @"";
//    [dictItemMstData setObject:_txtEnterOrder.text forKey:@"Date"];
    // Passing created order data and time as per Keyursir's guidance.
    dictItemMstData[@"Date"] = [self.dictInventoryMain valueForKey:@"CreatedDate"];
    dictItemMstData[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictItemMstData[@"UserId"] = [NSString stringWithFormat:@"%@",userID ];
    
    dictItemMstData[@"Type"] = self.strTypeOfOperation;
    dictItemMstData[@"ItemInId"] = [self.dictInventoryMain valueForKey:@"ItemInOutId" ];
    dictItemMstData[@"Description"] = strUserInputMsg;
    
    [arrItemMst addObject:dictItemMstData];
	return arrItemMst;
}

- (NSMutableArray *) updateInventoryItemDetail
{
    NSMutableArray *arrItemInventory = [[NSMutableArray alloc] init];
    
//    [self.arrScanBarDetails removeAllObjects];
    
    if(self.arrScanBarDetails.count>0)
    {
        for (int isup=0; isup < self.arrScanBarDetails.count; isup++)
        {
            NSMutableDictionary *tmpSup = [(self.arrScanBarDetails)[isup] mutableCopy ];
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"AddedQty",@"Barcode",@"CostPrice",@"ItemId",@"SalesPrice",@"avaibleQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = speDict.allKeys;
            [tmpSup removeObjectsForKeys:speKeys];
            [arrItemInventory addObject:tmpSup];
        }
    }
	return arrItemInventory;
}

// Update open in record over //

bool newScanActive=false;

// Inventory In functionality (functions)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddItemCustomCell";
    InvnetoryInCustomCell *cell = (InvnetoryInCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didInSwipeRight:)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [cell.contentView addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didInSwipeLeft:)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell.contentView addGestureRecognizer:gestureLeft];

    if(indexPath.row==self.indPath.row)
    {
        cell.viewOperation.frame=CGRectMake(0, cell.viewOperation.frame.origin.y, cell.viewOperation.frame.size.width, cell.viewOperation.frame.size.height);
        cell.viewOperation.hidden=NO;
    }
    else
    {
        cell.viewOperation.frame=CGRectMake(cell.viewOperation.frame.size.width, cell.viewOperation.frame.origin.y, cell.viewOperation.frame.size.width, cell.viewOperation.frame.size.height);
        cell.viewOperation.hidden=YES;
    }
    
    NSMutableDictionary *dict = (self.arrScanBarDetails)[indexPath.row];
    
    // show Image for each item in cell
    NSString * imageImage = @"";
    imageImage = dict[@"ItemImage"];
    
    if(([imageImage isKindOfClass:[NSNull class]]) || ([imageImage isEqualToString:@"<null>"])  )
    {
        imageImage = @"";
    }
    
    if ([[imageImage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        cell.imgItem.image = [UIImage imageNamed:@"noimage.png"];
    }
    else
    {
        [cell.imgItem loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageImage]]];
    }
    cell.lblInventoryName.text = dict[@"ItemName"];
    cell.lblBarcode.text = dict[@"Barcode"];
    
    cell.txtCostPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:[dict[@"CostPrice"] floatValue]]];
    
    cell.txtSellingPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:[dict[@"SalesPrice"] floatValue]]];
    
    cell.txtAvaQTY.text = [NSString stringWithFormat:@"%@",dict[@"avaibleQty"] ];
    
    cell.txtAddQTY.text = [NSString stringWithFormat:@"%@",dict[@"AddedQty"] ];

    cell.txtAddQTY.delegate=self;
    
    cell.btnEdit.tag = indexPath.row;
    [cell.btnEdit addTarget:self action:@selector(invenIneditItem:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnCopy.tag = indexPath.row;
    [cell.btnCopy addTarget:self action:@selector(invenIncopyItem:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnDelete.tag = indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(invenIndeleteItem:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblScannedItemList)
    {
        if (self.arrScanBarDetails.count > 0) {
            _statusImage.hidden = TRUE;
        }
        else {
            _statusImage.hidden = FALSE;
        }
            
        return self.arrScanBarDetails.count;
    }
    else
    {
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IsPhone()) {
        return 95;
    }
    else{
        return 76;
    }
}

-(void)didInSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    [Appsee addEvent:kRIMItemInSwipe];
    CGPoint location = [gesture locationInView:self.tblScannedItemList];
    NSIndexPath *swipedIndexPath = [self.tblScannedItemList indexPathForRowAtPoint:location];
    self.indPath=swipedIndexPath;
    [self.tblScannedItemList reloadRowsAtIndexPaths:@[self.indPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)didInSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tblScannedItemList];
    NSIndexPath *swipedIndexPath = [self.tblScannedItemList indexPathForRowAtPoint:location];
    if(self.indPath.row == swipedIndexPath.row)
    {
        self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
        [self.tblScannedItemList reloadRowsAtIndexPaths:@[swipedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

-(void)invenIneditItem:(id)sender
{
   [self.rmsDbController playButtonSound];
    swipedRecordID = [sender tag];
    NSDictionary *itemInDict = @{kRIMItemInSwipeEditKey : @(swipedRecordID)};
    [Appsee addEvent:kRIMItemInSwipeEdit withProperties:itemInDict];
    flgCopyButtonClicked = FALSE;
    [self getClickedItemInData:(self.arrScanBarDetails)[[sender tag]]];
}

-(void)invenIncopyItem:(id)sender
{
   [self.rmsDbController playButtonSound];
    flgCopyButtonClicked = TRUE;
    NSDictionary *itemInDict = @{kRIMItemInSwipeCopyKey : @([sender tag])};
    [Appsee addEvent:kRIMItemInSwipeCopy withProperties:itemInDict];
    [self getClickedItemInData:(self.arrScanBarDetails)[[sender tag]]];
}

- (void)getClickedItemInData:(NSIndexPath *)indexPath
{
    Item *anItem=[self fetchAllItems:[indexPath valueForKey:@"ItemId"]];
    NSMutableDictionary *dictItemClickedx = [anItem.itemRMSDictionary mutableCopy];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",[dictItemClickedx[@"DepartId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *departmentList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (departmentList.count>0)
    {
        Department *department=departmentList.firstObject;
        dictItemClickedx[@"DepartmentName"] = department.deptName;
    }
    else
    {
        dictItemClickedx[@"DepartmentName"] = @"";
    }
    
    if(IsPhone())
    {
        ItemInfoEditVC *objAddNew = [[UIStoryboard storyboardWithName:@"RimStoryboard_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];
        objAddNew.managedObjectContext = self.rmsDbController.managedObjectContext;
        if (objAddNew.itemInfoDataObject==nil) {
            objAddNew.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
        }
        if(flgCopyButtonClicked)
        {
            dictItemClickedx[@"Barcode"] = @"";
//            flgCopyButtonClicked=FALSE;
        }
        
        [objAddNew.itemInfoDataObject setItemMainDataFrom:dictItemClickedx];
        objAddNew.NewOrderCalled=TRUE;
        objAddNew.dictNewOrderData = (self.arrScanBarDetails)[swipedRecordID];
        if(!(flgCopyScanITem))
        {
            (objAddNew.dictNewOrderData)[@"indexpath"] = [NSString stringWithFormat:@"%ld",(long)swipedRecordID];
        }
//        objAddNew.objNewOrderAdd=self;
        [self.navigationController pushViewController:objAddNew animated:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else
    {
        NSMutableDictionary *navigationInfo = [[NSMutableDictionary alloc] init ];
        navigationInfo[@"NewOrderCalled"] = @(TRUE);
        navigationInfo[@"objNewOrderAdd"] = self;
        navigationInfo[@"swipedRecordID"] = [NSString stringWithFormat:@"%ld",(long)swipedRecordID];
        
        if(flgCopyButtonClicked)
        {
            dictItemClickedx[@"Barcode"] = @"";
//            flgCopyButtonClicked = FALSE;
        }
        [self showInventoryAddNew:dictItemClickedx navigationInfo:navigationInfo];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
}

-(void)invenIndeleteItem:(id)sender
{
    [self.rmsDbController playButtonSound];
    deleteRecordId = [sender tag];
    NSDictionary *itemInDict = @{kRIMItemInSwipeDeleteKey : @(deleteRecordId)};
    [Appsee addEvent:kRIMItemInSwipeDelete withProperties:itemInDict];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [Appsee addEvent:kRIMItemInSwipeDeleteCancel];
        self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
        [self.tblScannedItemList reloadData];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [Appsee addEvent:kRIMItemInSwipeDeleteDone];
        [self deleteRecord:deleteRecordId];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this item?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)deleteRecord:(NSInteger)deleteID
{
    [self.arrScanBarDetails removeObjectAtIndex:self.indPath.row];
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
    [self.tblScannedItemList reloadData];
}

- (void)insertDidFinish {
}

#ifdef LINEAPRO_SUPPORTED

-(void)connectionState:(int)state
{
    switch (state) {
        case CONN_DISCONNECTED:
        case CONN_CONNECTING:
            _statusImage.image = [UIImage imageNamed:@"img_ScannerNotConnected.png"];
            break;
        case CONN_CONNECTED:
            newScanActive=false;
            _statusImage.image = [UIImage imageNamed:@"img_scannerConnected.png"];
            break;
    }
}

-(void)deviceButtonPressed:(int)which
{
    [status setString:@""];
    
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"InvnetoryIn"])
        {
            [debug setString:@""];
            _statusImage.image = [UIImage imageNamed:@"scanning.png"];
        }
    }
}

-(void)deviceButtonReleased:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"InvnetoryIn"])
        {
            if(![status isEqualToString:@""])
            {
                [self barcodeSearchItem];
            }
            else
            {
                
            }
            _statusImage.image = [UIImage imageNamed:@"img_scannerConnected.png"];
        }
    }
}

// Barcode Result display via this function
-(void)barcodeData:(NSString *)barcode type:(int)type
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        [status setString:@""];
        [status appendFormat:@"%@",barcode];
        _txtMainBarcode.text = barcode;
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please change type as scanner" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

#endif
// MULTIPLE ITEM SELECTION ITEMS

-(void)didSelectedItems:(NSArray *) arrListOfitems{

    int recordCount = 0 ;
    
    if (arrListOfitems.count > 0) {
        for (Item * anItem in arrListOfitems) {
            NSMutableDictionary *dictSelected = [anItem.itemRMSDictionary mutableCopy];
            if([dictSelected  valueForKey:@"selected"])
            {
                recordCount +=1;
                dictSelected[@"AddedQty"] = @"1";
                [self.arrScanBarDetails insertObject:dictSelected atIndex:0];
            }

        }
    }
    [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];    
    NSInteger tmprow = self.indPath.row;
    if(tmprow > -1)
    {
        self.indPath=[NSIndexPath indexPathForRow:tmprow + recordCount inSection:0];
    }
    
    [self.tblScannedItemList reloadData];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    InvnetoryInCustomCell *cell = (InvnetoryInCustomCell *) activeField.superview.superview;
    UITextField *addQtyTF = (UITextField *)[cell viewWithTag:111];
    [self textFieldShouldEndEditing:addQtyTF];
    [popoverController dismissPopoverAnimated:YES];
}


#pragma mark - Export List -

-(IBAction)btn_ExportClick:(id)sender{
    [Appsee addEvent:kRIMItemInFooterExport];
    ExportPopupVC * exportPopupVC =
    [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"ExportPopupVC_sid"];
    exportPopupVC.delegate = self;
    
    
    [exportPopupVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionDown];
}
-(void)didSelectExportType:(ExportType)exportType withTag:(NSInteger)tag {
    switch (exportType) {
        case  ExportTypeEmail :
            [self sendEmail];
            break;
        case ExportTypePrieview:
            [self previewandPrint];
            break;
        default:
            break;
    }
}
-(void)sendEmail{
    [Appsee addEvent:kRIMItemInEmail];
    if(self.arrScanBarDetails.count>0)
    {
        [self htmlBillText:self.arrScanBarDetails];
    }
}

//hiten

-(void)htmlBillText:(NSMutableArray *)arryInvoice
{
    
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ItemInfo" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];

    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
    
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
    
    [self.view addSubview:emailFromViewController.view];
    
}
-(void)didCancelEmail
{
    [emailFromViewController.view removeFromSuperview];
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

-(NSString *)htmlBillHeader:(NSString *)html invoiceArray:(NSMutableArray *)arrayInvoice
{
//    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"%@",self._rimController.objSideMenuiPad.currentViewController.text]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"Item In"]];

    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:strDate];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    
    return html;
}
// Modified by Hitendra
-(NSString *)htmlBillTextForItem:(NSMutableArray *)arrayInvoice
{
    NSString *itemHtml = @"";
    
    self.emailTempDictionary = [[NSMutableDictionary alloc]init];
    
    for (int i=0; i<arrayInvoice.count; i++)
    {

        // set Item Detail with only 1 qty....
        NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:arrayInvoice[i]];
        itemHtml = [itemHtml stringByAppendingFormat:@"%@",strHTML];
        
        
    }

    return itemHtml;
}
-(NSString *)htmlBillTextGenericForItemwithDictionary:(NSDictionary *)itemDictionary
{
    NSString *htmldata = @"";
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font> </td><td>&nbsp;</td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></td><td align=\"right\" valign=\"top\"><font size=\"2\">%.2f</font></td><td align=\"right\" valign=\"top\"><font size=\"2\">%.2f</font></td><td>&nbsp;</td><td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"Barcode"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"avaibleQty"],[itemDictionary[@"CostPrice"]floatValue],[itemDictionary[@"SalesPrice"]floatValue],itemDictionary[@"AddedQty"]];
    
    return htmldata;
    
}

// Add by Himanshu - Item info popup view

-(IBAction)btnItemInfoClick:(UIButton *)sender
{
    [Appsee addEvent:kRIMItemInFooterItemInfo];

    float totalQTYeach = 0.0;
    float totalCostPrice = 0.0;
    for( int iArr = 0 ; iArr < self.arrScanBarDetails.count; iArr++)
    {
        // Calculate Total CostPrice
        int iQty = [(self.arrScanBarDetails)[iArr][@"AddedQty"] intValue ];
        totalQTYeach = totalQTYeach + iQty;
        
        float iCost = [(self.arrScanBarDetails)[iArr][@"CostPrice"] floatValue ];
        totalCostPrice = totalCostPrice + (iQty * iCost);
    }
    ItemInfoPopupVC * objItemInfoPopupVC =
    [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoPopupVC_sid"];
    
    NSMutableDictionary * dictItemInfo = [NSMutableDictionary dictionary];
    [dictItemInfo setObject:[NSString stringWithFormat:@"%lu",(unsigned long)(self.arrScanBarDetails).count] forKey:ItemInfoPopupVCNumOfProduct];
    [dictItemInfo setObject:[NSString stringWithFormat:@"%.0f",totalQTYeach] forKey:ItemInfoPopupVCAddedQTY];
    [dictItemInfo setObject:[NSString stringWithFormat:@"%.2f",totalCostPrice] forKey:ItemInfoPopupVCTotalCost];
    objItemInfoPopupVC.dictItemInfo = dictItemInfo;
    
    [objItemInfoPopupVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionDown];
}

-(void)previewandPrint{
    [Appsee addEvent:kRIMItemInPreview];
    if(self.arrScanBarDetails.count>0)
    {
        [self htmlBillTextForPreview:self.arrScanBarDetails];
    }
}

-(void)htmlBillTextForPreview:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ItemInfo" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];

    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
   /* objPreviewandPrint = [[PreviewAndPrintViewController alloc]initWithNibName:@"PreviewAndPrintViewController" bundle:nil];
    
    NSData *myData = [NSData dataWithContentsOfFile:self.emaiItemHtml];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    objPreviewandPrint.dictParameter =[[NSMutableDictionary alloc]init];
    [objPreviewandPrint.dictParameter setObject:stringHtml forKey:@"HtmlString"];*/
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/previewreceipt.pdf".stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    
    //[self presentViewController:objPreviewandPrint animated:YES completion:nil];
    
}
#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    //NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
   // objPreviewandPrint.strPdfFilePath=htmlToPDF.PDFpath;
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    //NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
   // objPreviewandPrint.strPdfFilePath=result;
    
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

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}

- (void)showInventoryAddNew:(NSMutableDictionary *)selectedItem navigationInfo:(NSDictionary*)navigationInfo {
    // Present InventoryAddNewSplitterVC
    ItemDetailEditVC * itemDetailEditVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
    
    itemDetailEditVC.selectedItemInfoDict = selectedItem;
    itemDetailEditVC.navigationInfo = [navigationInfo mutableCopy];
    itemDetailEditVC.itemInfoEditRedirectionVCDelegate=self;
    itemDetailEditVC.isItemCopy = flgCopyButtonClicked;
    itemDetailEditVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:itemDetailEditVC animated:YES completion:nil];
}
- (void)ItemInfornationChangeAt:(NSInteger )indexRow WithNewData:(id)newItemInfo {
    if (indexRow == -1) {
        [self.arrScanBarDetails insertObject:newItemInfo atIndex:0];
    }
    else {
        (self.arrScanBarDetails)[indexRow] = newItemInfo;
    }
    [self.tblScannedItemList reloadData];
    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
}
@end
