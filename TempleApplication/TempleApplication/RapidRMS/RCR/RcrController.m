//
//  RcrController.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//
// Test 3 for Demo ...
#import "RcrController.h"

#import <AVFoundation/AVFoundation.h>

#import "POSFrontEndViewController.h"
#import "Keychain.h"
#import "SoundSettingPopover.h"

#import "Item+Dictionary.h"
#import "Configuration.h"
#import "ItemSupplier+Dictionary.h"
#import "ItemTax+Dictionary.h"
#import "RmsDbController.h"
#import "AppDelegate.h"
#import "ItemTag+Dictionary.h"
#import "UtilityManager.h"
#import "SizeMaster+Dictionary.h"
#import "InvoiceData_T+Dictionary.h"
#import "TenderPay+Dictionary.h"

static NSString * kURL;
static NSString * imagePath;
static NSString *portName = nil;
static NSString *portSettings = nil;


static RcrController *s_SharedCrmController = nil;

@interface RcrController () <DisplayDataReceiver> {
    
    NSTimer * statusCustomerDisplayTimer;

}

@property (nonatomic, strong) UtilityManager * util;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) RapidWebServiceConnection * invoicePushWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection * invoiceServerConnection;

@property (nonatomic, strong) UIView *inputAccessoryView;

@property (nonatomic, strong) NSMutableDictionary *globalDict;
@property (nonatomic, strong) NSMutableDictionary *invoiceDetailDict;

@property (nonatomic, strong) NSMutableArray *arrayMainTagListResponse;

@property (nonatomic, strong) NSString *strUpdateType;

@property (nonatomic, strong) NSManagedObjectID *invoiceDataObjectId;


@end

@implementation RcrController
+ (RcrController*)sharedCrmController {
    @synchronized(self) {
        if (!s_SharedCrmController) {
            s_SharedCrmController = [[RcrController alloc] init];
        }
    }
    return s_SharedCrmController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupRcrController];
        self.customerDisplayClient = [[CustomerDisplayClient alloc] initWithDelegate:self];
    }
    return self;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}


#pragma mark - Activity Indicator
// hide activity(Progress) indicator
-(void)hideActivityViewer:(UIView *) aView {
    [self.util hideActivityViewer:aView];
}

// show activity(Progress) indicator
-(void)showActivityViewer:(UIView *) aView {
	[self.util showActivityViewer:aView];
}

+ (NSString*)getPortName
{
    return portName;
}

+ (void)setPortName:(NSString *)m_portName
{
    if (portName != m_portName) {
//        [portName release];
        portName = [m_portName copy];
    }
}

+ (NSString *)getPortSettings
{
    return portSettings;
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    if (portSettings != m_portSettings) {
//        [portSettings release];
        portSettings = [m_portSettings copy];
    }
}

#pragma mark - App delegate methods
- (void)setupRcrController
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.managedObjectContext=self.rmsDbController.managedObjectContext;
//    self.objPOS.lblInvoiceNo.text = @"-";
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:@"AdvertiseTime"];
    if (str.length>0)
    {
        self.TimeAdvetise = 30;
    }
    else
    {
        self.TimeAdvetise = 30;
    }
    
    NSString *strScreen = [[NSUserDefaults standardUserDefaults]valueForKey:@"Display"];
    if (strScreen.length>0)
    {
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Fullscreen" forKey:@"Display"];
    }
    
    self.globalScanDict = [[NSMutableDictionary alloc]init];
    self.globalArrTenderConfig = [[NSMutableArray alloc]init];
    self.arrayMainTagListResponse = [[NSMutableArray alloc]init];
    self.globalAdvertisearray = [[NSMutableArray alloc]init];

    self.currencyFormatter = [[NSNumberFormatter alloc] init];
    self.currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    self.currencyFormatter.maximumFractionDigits = 2;
    
    NSString *strPurchasedTemp = [Keychain getStringForKey:@"DeviceId"];
    if (strPurchasedTemp)
    {
        (self.globalDict)[@"DeviceId"] = strPurchasedTemp;
    }
    else
    {
        NSString *udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
        (self.globalDict)[@"DeviceId"] = udid;
        [Keychain saveString:udid forKey:@"DeviceId"];
    }
    
    //set default values.
	self.manualPriceValue = @"";
	self.manualQtyValue = @"1";
    
    // menu page array for items.
//self.reciptDataAry = [[NSMutableArray alloc] init];
    self.reciptItemLogDataAry = [[NSMutableArray alloc] init];

   	// alloc the utility manager class.
	self.util = [[UtilityManager alloc]init];
    
    self.invoiceServerConnection = [[RapidWebServiceConnection alloc]init];
//    [statusCustomerDisplayTimer isValid];

  //  [self getTenderPaymentObjectWithCardIntTypeCredit];
    
 //   [self getTenderPaymentObjectWithCardIntTypeCredit];
    
    [self getTagList];
    
}

-(void)getTenderPaymentObjectWithCardIntTypeCredit
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *tenderFetchPredicate = [NSPredicate predicateWithFormat:@"cardIntType != %@ OR cardIntType != %@",@"Credit",@"Debit"];
    fetchRequest.predicate = tenderFetchPredicate;
    NSMutableArray *arrTemp = [[[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig"] mutableCopy];
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count >0)
    {
        for (int i =0; i<resultSet.count; i++)
        {
            TenderPay *tenderPay = resultSet[i];
            NSString *Spec3 = @"3";
            NSString *Spec4 = @"4";
            NSString *Spec8 = @"8";
            NSString *Spec9 = @"9";
            NSPredicate *tenderFetchPredicate = [NSPredicate predicateWithFormat:@"PayId == %@ AND (SpecOption==%@ OR SpecOption==%@ OR SpecOption==%@ OR SpecOption==%@) ",tenderPay.payId,Spec3,Spec4,Spec8,Spec9];
            NSArray *filterPayIdArray = [arrTemp filteredArrayUsingPredicate:tenderFetchPredicate];
            [arrTemp removeObjectsInArray:filterPayIdArray];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:arrTemp forKey:@"TendConfig"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}




-(void)getTagList
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SizeMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    [self.arrayMainTagListResponse removeAllObjects];
    if (resultSet.count > 0)
    {
        for (SizeMaster *size in resultSet)
        {
            NSMutableDictionary *supplierDict=[[NSMutableDictionary alloc]init];
            supplierDict[@"SizeName"] = size.sizeName;
            supplierDict[@"SizeId"] = size.sizeId;
            [self.arrayMainTagListResponse addObject:supplierDict];
        }
    }
   
}
#pragma mark - Remote notification
-(void)tenderInvoiceNotificat:(NSMutableDictionary *)ItemNotificationDict
{
    self.strUpdateType = [ItemNotificationDict valueForKey:@"Action"];
    
    NSMutableDictionary *DictPara = [[NSMutableDictionary alloc]init];
    DictPara[@"Code"] = ItemNotificationDict[@"Code"];
    DictPara[@"BranchId"] = ItemNotificationDict[@"EntityId"];
    DictPara[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self InvoicePushNotificationResponse:response error:error];
        });
    };
    self.invoicePushWebServiceConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_INVOICE_PUSH_NOTIFICATION_DATA params:DictPara asyncCompletionHandler:asyncCompletionHandler];
}

- (void)InvoicePushNotificationResponse:(id)response error:(NSError *)error
{
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {

            NSMutableArray *responseData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
            if([self.strUpdateType isEqualToString:@"Update"])
            {
                if (responseData.count>0)
                {
                    [self itemUpdateFromDatabaseTable:responseData];
                }
            }
        }
    }
}

- (void)sendInvoiceDataToServer
{
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self insertServerInvoiceResponse:response error:error];
        });
    };
    
    self.invoiceServerConnection = [self.invoiceServerConnection initWithRequest:KURL_INVOICE actionName:WSM_INVOICE_INSERT_LIST params:self.invoiceDetailDict completionHandler:completionHandler];

}

-(void)didInsertInvoiceDataToServerWithDetail:(NSMutableDictionary *)invoiceDetail withInvoiceObject:(NSManagedObjectID*)invoiceDataId
{
    self.invoiceDataObjectId = invoiceDataId;
    self.invoiceDetailDict = invoiceDetail;
    NSLog(@"invoiceDetail == %@",invoiceDetail);
    [self sendInvoiceDataToServer];
}



- (void)updateLocalDataBaseAfterTenderProcess:(NSMutableDictionary *)responseDict
{
    NSMutableDictionary *ItemNotificationDict=[[NSMutableDictionary alloc]init];
    if (responseDict != nil)
    {
        NSString *str= responseDict[@"ItemCodes"];
        if (![str isEqualToString:@""])
        {
            ItemNotificationDict[@"Code"] = str;
            NSString *strAction= responseDict[@"Action"];
            ItemNotificationDict[@"Action"] = strAction;
            ItemNotificationDict[@"EntityId"] = (self.rmsDbController.globalDict)[@"BranchID"];
            [self tenderInvoiceNotificat:ItemNotificationDict];
        }
    }
}

- (void)insertServerInvoiceResponse:(id)response error:(NSError *)error
{
    if (response != nil)
	{
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *responseDict = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSInteger recallCount = [[responseDict valueForKey:@"RecallCount"] integerValue];
                
//                self.serverInvoiceNo = [responseDict valueForKey:@"InvId"];
                if(self.recallCount != recallCount)
                {
                    self.recallCount = recallCount;
                    NSDictionary *recallCountDict = @{@"Code" : @(recallCount)};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LiveHoldUpdateCount" object:recallCountDict];
                }
                
                [self didRemoveDataFromLocalDataBaseWithInvoiceData];
                [self removeBillDataFromUserDefault];
                [self updateLocalDataBaseAfterTenderProcess:responseDict];
                
            }
            else if([[response  valueForKey:@"IsError"] intValue] == 1)
            {

                NSString *currentStep = [NSString stringWithFormat:@"Last Tender State = Transaction declined Error = 1 - %@",[Keychain getStringForKey:@"tenderInvoiceNo"]];
                [[NSUserDefaults standardUserDefaults] setObject:currentStep forKey:@"TenderStateBeforeTermination"];
            }
            else  if ([[response  valueForKey:@"IsError"] intValue] == -2)
            {
                NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
                NSInteger number = keyChainInvoiceNo.integerValue;
                number++;
                NSString *updatedTenderInvoiceNo = [NSString stringWithFormat: @"%d", (int)number];
                [Keychain saveString:updatedTenderInvoiceNo forKey:@"tenderInvoiceNo"];
                
                NSMutableArray *invoiceMstData = [[self.invoiceDetailDict valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceMst"];
                NSMutableDictionary *invoiceMasterDictionary = [invoiceMstData.firstObject firstObject];
                
                Configuration *configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
                NSString *registerInvNo = [NSString stringWithFormat:@"%@%@",configuration.regPrefixNo,updatedTenderInvoiceNo ];
                
                invoiceMasterDictionary[@"RegisterInvNo"] = registerInvNo;
                
                [self updateDataToDatabseTableForAlreadyExits];
                [self sendInvoiceDataToServer];
                return;
                
            }
            else // Unknown service error
            {
                
                NSString *currentStep = [NSString stringWithFormat:@"Last Tender State = Transaction declined, Error = declined from the server - %@",[Keychain getStringForKey:@"tenderInvoiceNo"]];
                [[NSUserDefaults standardUserDefaults] setObject:currentStep forKey:@"TenderStateBeforeTermination"];
            }
        }
        else
        {
            NSString *currentStep = [NSString stringWithFormat:@"Last Tender State = Invoice Transaction Error - %@",[Keychain getStringForKey:@"tenderInvoiceNo"]];
            [[NSUserDefaults standardUserDefaults] setObject:currentStep forKey:@"TenderStateBeforeTermination"];
        }
	}
    else
    {
        NSString *currentStep = [NSString stringWithFormat:@"Last Tender State = Internet Connection Problem. Try Again. - %@",[Keychain getStringForKey:@"tenderInvoiceNo"]];
        [[NSUserDefaults standardUserDefaults] setObject:currentStep forKey:@"TenderStateBeforeTermination"];
        
      //  [self updateRemarksWithErrorMessage:@"Internert Connection Error"];
    }
}

-(void)updateDataToDatabseTableForAlreadyExits
{
    NSMutableDictionary *databaseInsertDictionary = self.invoiceDetailDict;
    databaseInsertDictionary[@"branchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    databaseInsertDictionary[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    databaseInsertDictionary[@"zId"] = [self.rmsDbController.globalDict valueForKey:@"ZId"];
    databaseInsertDictionary[@"msgCode"] = @"-1";
    databaseInsertDictionary[@"message"] = @"Web services Connection Error. Try Again";
    if (self.invoiceDataObjectId != nil) {
        InvoiceData_T *invoiceData = [self.updateManager updateDataToDataTableWithObject:self.invoiceDataObjectId withInvoiceDetail:databaseInsertDictionary];
        self.invoiceDataObjectId = invoiceData.objectID;
    }
}

- (void)removeBillDataFromUserDefault
{
//    [emailButton setEnabled:YES];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BillData"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BillDataDateTime"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"StoreInvoiceNo"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TenderStateBeforeTermination"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BillMasterBlock"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PaymentLocalDetailArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)didRemoveDataFromLocalDataBaseWithInvoiceData
{
    if (self.invoiceDataObjectId != nil) {
        // fetch data to delete the transaction.....
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        
        InvoiceData_T * invoiceData = (InvoiceData_T *)[privateContextObject objectWithID:self.invoiceDataObjectId];
        //[UpdateManager deleteFromContext:self.managedObjectContext objectId:invoiceData.objectID];
        invoiceData.isUpload = @(TRUE);
        [UpdateManager saveContext:privateContextObject];
        self.invoiceDataObjectId = nil;
    } else
    {
    }
}

-(void)itemUpdateFromDatabaseTable:(NSMutableArray *)ItemUpdateArray
{
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    for (int idata = 0; idata<ItemUpdateArray.count; idata++)
    {
        NSMutableDictionary *itemDictionary = ItemUpdateArray[idata];
        Item *item = [self.updateManager fetchItemFromDBWithItemId:itemDictionary[@"ItemId"] shouldCreate:NO moc:privateManagedObjectContext];
        item.barcode = [itemDictionary valueForKey:@"Barcode"];
        item.deptId = @([[itemDictionary valueForKey:@"DepartId"] integerValue]);
        item.itemCode = @([[itemDictionary valueForKey:@"ItemId"] integerValue]);
        item.item_ImagePath = [itemDictionary valueForKey:@"ItemImage"];
        item.item_Desc = [itemDictionary valueForKey:@"ItemName"];
        item.item_MaxStockLevel = @([[itemDictionary valueForKey:@"MaxStockLevel"] integerValue]);
        item.item_MinStockLevel = @([[itemDictionary valueForKey:@"MinStockLevel"] integerValue]);
        item.profit_Amt = @([[itemDictionary valueForKey:@"ProfitAmt"] integerValue]);
        item.profit_Type = [itemDictionary valueForKey:@"ProfitType"];
        item.item_Remarks = [itemDictionary valueForKey:@"Remark"];
        item.salesPrice = @([[itemDictionary valueForKey:@"Price"] floatValue]);
        item.item_InStock = @([[itemDictionary valueForKey:@"availableQty"] integerValue]);
        item.taxApply = @([[itemDictionary valueForKey:@"isTax"] integerValue]);
        item.taxType = [itemDictionary valueForKey:@"TaxType"];
        item.item_No = [itemDictionary valueForKey:@"ItemNo"];
        item.itm_Type = [itemDictionary valueForKey:@"ITMType"];
        item.costPrice = @([[itemDictionary valueForKey:@"CostPrice"] floatValue]);
        
        if([[itemDictionary valueForKey:@"LastInvoice"] isKindOfClass:[NSString class]]) {
            item.lastInvoice=[itemDictionary valueForKey:@"LastInvoice"];
        }
        else{
            item.lastInvoice=@"";
        }
        if ([itemDictionary objectForKey:@"LastnvoiceDate"]) {
            item.lastSoldDate = [self.rmsDbController getDateFromJSONDate:[itemDictionary valueForKey:@"LastnvoiceDate"]];
        }
    }

    [UpdateManager saveContext:privateManagedObjectContext];
}

- (void)TouchoneTap:(UIGestureRecognizer *)gesture
{
    self.Globalseconds = self.TimeAdvetise;
    self.Globalminutes = 0;
    UIView *view = [[UIApplication sharedApplication].keyWindow viewWithTag:1200];
    [view removeFromSuperview];
}

-(void)UserTouchEnable
{
    self.Globalseconds = self.TimeAdvetise;
    self.Globalminutes = 0;
}


-(void) textFieldBegan:(NSNotification *) theNotification
{
    UITextField *theTextField = theNotification.object;
    if (!self.inputAccessoryView) {
        // inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, navigationController.view.frame.size.width, 1)];
        self.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    
    theTextField.inputAccessoryView = self.inputAccessoryView;
    [self forceKeyboard];
}

//Change the inputAccessoryView frame - this is correct for portrait, use a different
// frame for landscape

-(void) forceKeyboard
{
    self.inputAccessoryView.superview.frame = CGRectMake(0, 850, 768, 265);
}

#pragma mark -
// Check for the network Connection.
- (BOOL)isDataSourceAvailable {
	return self.util.dataSourceAvailable;
}
+ (NSString *) getKURLValue {
	return kURL;
}

+ (NSString *) getImagePathValue {
	return imagePath;
}

- (void) setURLValues:(NSString *)kURLValue andImagePath:(NSString *)imagePathValue {
	kURL = kURLValue;
	imagePath = imagePathValue;
}

- (void)responseDelegate :(NSMutableDictionary*)dict {
//    [self updateItemFromDict:dict];
}


- (void)didConnectToPos:(NSString*)posName {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectedToDisplay" object:nil userInfo:@{@"DisplayName": posName}];
    
    [statusCustomerDisplayTimer invalidate];
    statusCustomerDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sendStatusToCustomerDisplay:) userInfo:nil repeats:TRUE];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *posDeviceName = [UIDevice currentDevice].name;
        NSDictionary *displayNameDictionary = @{@"POSName": posDeviceName};
        [self writeDictionaryToCustomerDisplay:displayNameDictionary];
    });
    
    
}
- (void)didDisconnectToPos:(NSString*)posName {
    [self.customerDisplayClient reconnectToPreviousPos];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisconnectedToDisplay" object:nil userInfo:@{@"DisplayName": posName}];
}

- (BOOL)isDisplayConnected {
    return self.customerDisplayClient.isConnected;
}

- (NSString*)displayName {
    return self.customerDisplayClient.displayName;
}

- (void)writeDictionaryToCustomerDisplay:(NSDictionary*)dictionary {
    [self writeObjectToCustomerDisplay:dictionary];
}
-(void)sendStatusToCustomerDisplay :(NSTimer *)timer
{
    NSDictionary *dictionary = @{@"Status": @"1"};
    [self writeDictionaryToCustomerDisplay:dictionary ];
}


- (void)writeObjectToCustomerDisplay:(id)object {
    if (!self.customerDisplayClient.isConnected) {
        return;
    }

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    uint64_t dataLength = data.length;
    NSMutableData *dataPacket = [NSMutableData dataWithBytes:&dataLength length:sizeof(uint64_t)];
    [dataPacket appendData:data];
    [self.customerDisplayClient writeData:dataPacket];
}


-(NSArray *)getAllTenderPaymentObject
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
   
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return resultSet;
}

-(BOOL)isSpecOptionApplicableCreditCardForCommon:(int)specOption
{
    NSArray * totalPaymentArray = [self getAllTenderPaymentObject];
    
    BOOL isApplicable = FALSE;
    for(TenderPay *tenderpay in totalPaymentArray)
    {
        if (tenderpay == nil) {
            continue;
        }
        NSInteger ipay = tenderpay.payId.integerValue;
        
        for(int tenderConfig = 0; tenderConfig<self.globalArrTenderConfig.count; tenderConfig++)
        {
            int itender=[[(self.globalArrTenderConfig)[tenderConfig] valueForKey:@"PayId" ] intValue ];
            if(ipay==itender)
            {
                if([[(self.globalArrTenderConfig)[tenderConfig] valueForKey:@"SpecOption"] intValue ] == specOption)
                {
                    isApplicable = TRUE;
                    break;
                }
            }
        }
    }
    return isApplicable;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
