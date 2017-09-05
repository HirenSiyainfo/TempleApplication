//
//  CCBatchVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 18/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CCBatchVC.h"
#import "CCOverViewVC.h"
#import "CurrentTransactionVC.h"
#import "DeviceSummaryVC.h"
#import "DeviceBatchVC.h"
#import "RmsDbController.h"
#import "TenderPay+Dictionary.h"
#import "PaxDevice.h"
#import "LocalTotalReportResponse.h"
#import "BatchCloseResponse.h"
#import "LocalDetailReportResponse.h"
#import "NSString+Methods.h"
#import "PaxCCBatchReceipt.h"
#import "BridgePayCCBatchReceipt.h"
#import "SelectUserOptionVC.h"
#import "TipsVC.h"
#import "PaxSetupVC.h"
#import "InitializeResponse.h"
#import "CCBatchForBridgePay.h"
#import "CCBatchForPax.h"
#import "PaxDeviceViewController.h"

@implementation CCBatchTrnxDetailStruct
-(NSString *)description{
    return [NSString stringWithFormat:@"total: %@\n tipAmount: %@\n grandTotal: %@\n totalTransaction: %@\n totalAvgTicket: %@\n",self.total,self.tipAmount,self.grandTotal,self.totalTransaction,self.totalAvgTicket];
}
@end

typedef NS_ENUM(NSInteger, TabOption)
{
    TabOptionCCOverView = 3501,
    TabOptionCurrentTrnxs,
    TabOptionDeviceSummary,
    TabOptionDeviceBatch,
};

typedef enum __SPEC_OPTIONS_ {
    SPEC_PRINT_RECIPT,
    SPEC_PRINT_PROMT,
    SPEC_OPEN_DRAWER,
    SPEC_CARD_PROCESS,
    SPEC_MULTIPLE_CARD_PROCESS,
    SPEC_POS_SIGN_RECEIPT = 6,
    SPEC_CUSTOMER_DISPLAY_SIGN_RECEIPT = 7,
    SPEC_TENDER_DISABLE = 11,
    SPEC_BRIDGEPAY_SERVER = 12,
    SPEC_RAPID_SERVER = 13,
    
} __SPEC_OPTIONS_;


#define LIVE_GET_BATCH_SETTLE_DATA_URL @"https://gateway.itstgate.com/admin/ws/trxdetail.asmx"
#define TEST_GET_BATCH_SETTLE_DATA_URL @"https://gatewaystage.itstgate.com/admin/ws/trxdetail.asmx"


#define LIVE_BATCH_SETTLE_DATA_URL @"https://gateway.itstgate.com/SmartPayments/transact.asmx"
#define TEST_BATCH_SETTLE_DATA_URL @"https://gatewaystage.itstgate.com/SmartPayments/transact.asmx"

@interface CCBatchVC () <PrinterFunctionsDelegate,DeviceBatchVCDelegate,tipsSelectionDeletage,CurrentTransactionVCDelegate,PaxSetupVCDelegate,CCBatchForBridgePayDelegate,CCBatchForPaxDelegate,PaxDeviceSettingVCDelegate> {
    NSMutableArray *chartArray;
    NSMutableArray *totalCardDetailsArrayForDeviceBatch;
    NSMutableArray *totalCardDetailsArrayForCurrentTrnx;

    NSArray *paxReportArray;
    NSArray *array_port;
    NSArray *bridgePayBatchSummryArray;
    NSArray *deviceSummaryPrintingArray;
    
    NSDictionary *selectedTipsDictionary;

    NSString *transctionServer;
    NSString *batchNo;
    NSString *totalAmountString;
    NSString *selectedCardTypeForCurrentTrnxs;
    NSString *selectedCardTypeForDeviceBatch;
    NSString *selectedRegisterNameForCCOverView;
    NSString *selectedRegisterNameForCurrentTrnxs;
    
    NSString *searchTextForDeviceBatch;

    NSString *paxSerialNo;

    NSInteger totalCount;

    NSNumber *selectedRegisterIdForCCOverView;
    NSNumber *selectedRegisterIdForCurrentTransaction;

    BOOL needToReloadCurrentTrnx;
    BOOL needToReloadDeviceBatch;
    BOOL needToReloadDeviceSummary;

    PaymentGateWay paymentGateWay;
    TabOption selectedTabOption;
    TipsVC *tipsVC;
    PaxSetupVC *paxSetupVC;
}

@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIView *cCOverViewContainer;
@property (nonatomic, weak) IBOutlet UIView *currentTrnxsContainer;
@property (nonatomic, weak) IBOutlet UIView *deviceSummaryContainer;
@property (nonatomic, weak) IBOutlet UIView *deviceBatchContainer;
@property (nonatomic, weak) IBOutlet UIView *ccBatchOtherOptionsView;

@property (nonatomic, weak) IBOutlet UIButton *btnPaxSetup;
@property (nonatomic, weak) IBOutlet UIButton *btnRegisterSelection;
@property (nonatomic, weak) IBOutlet UIButton *btnCardTypeSelection;

@property (nonatomic, strong) NSMutableArray *totalCardArrayForDeviceBatch;
@property (nonatomic, strong) NSMutableArray *totalCardArrayForCurrentTrnxs;
@property (nonatomic, strong) NSMutableArray *cardDetailForDeviceBatch;
@property (nonatomic, strong) NSMutableArray *cardDetailForCurrentTrnx;

@property (nonatomic, strong) NSMutableArray *registerDetailArray;

@property (nonatomic, strong) CCOverViewVC *cCOverViewVC;
@property (nonatomic, strong) CurrentTransactionVC *currentTransactionVC;
@property (nonatomic, strong) DeviceSummaryVC *deviceSummaryVC;
@property (nonatomic, strong) DeviceBatchVC *deviceBatchVC;
@property (nonatomic, strong) CCBatchForBridgePay *cCBatchForBridgePay;
@property (nonatomic, strong) CCBatchForPax *cCBatchForPax;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RcrController *crmController;

@property (nonatomic, strong) RapidWebServiceConnection *paymentCCWSC;
@property (nonatomic, strong) RapidWebServiceConnection *insertCardSettlementWC;
@property (nonatomic, strong) RapidWebServiceConnection *captureWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *getCaptureAmtWebServiceConnection;


@end

@implementation CCBatchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    [self defaultSetupForCCBatch];
    [self.btnPaxSetup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnPaxSetup setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.btnPaxSetup setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];

    // Do any additional setup after loading the view.
}

- (void)initialConfigurationProcessForCCBatch {
    if (self.rmsDbController.paymentCardTypearray.count == 0) {
        //Get CC Type Details
        [self getCardTypeDetailForCC];
    }
    else
    {
        //Initialization
        [self initializationProcessAccordingToPaymentGateWay];
    }
}

- (void)defaultSetupForCCBatch {
    needToReloadCurrentTrnx = true;
    needToReloadDeviceBatch = true;
    needToReloadDeviceSummary = true;
    selectedCardTypeForCurrentTrnxs = @"SELECT CARD TYPE";
    selectedCardTypeForDeviceBatch = @"SELECT CARD TYPE";
    selectedRegisterIdForCCOverView = (self.rmsDbController.globalDict)[@"RegisterId"];
    selectedRegisterIdForCurrentTransaction = @(-1);
    selectedRegisterNameForCCOverView = (self.rmsDbController.globalDict)[@"RegisterName"];
    selectedRegisterNameForCurrentTrnxs = @"All Registers";
    searchTextForDeviceBatch = @"";
}

#pragma mark - Initialization

-(void)getCardTypeDetailForCC
{
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self responseGetCardTypeDetailForCCResponse:response error:error];
    };
    
    self.paymentCCWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_GET_CARD_TYPE_DETAIL params:itemparam completionHandler:completionHandler];
}

-(void)responseGetCardTypeDetailForCCResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.rmsDbController.paymentCardTypearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                //Initialization
                [self initializationProcessAccordingToPaymentGateWay];
            }
        }
    }
}

- (void)initializationProcessAccordingToPaymentGateWay {
    transctionServer = [self getTransctionServerForSpecOption];
    if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Bridgepay"])
    {
        //BridgePay Initialization
        paymentGateWay = BridgePay;
        self.cCBatchForBridgePay = [[CCBatchForBridgePay alloc] init];
        self.cCBatchForBridgePay.cCBatchForBridgePayDelegate = self;
        self.cCBatchForBridgePay.transctionServer = transctionServer;
    }
    else if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Pax"])
    {
        //Pax Initialization
        NSDictionary *dictDevice = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceConfig"];
        if (dictDevice != nil)
        {
            paymentGateWay = Pax;
            self.cCBatchForPax = [[CCBatchForPax alloc] init];
            self.cCBatchForPax.cCBatchForPaxDelegate = self;
        }
        else {
            [self.cCBatchVCDelegate configurePaxDeviceFromSetting];
        }
    }
}

- (void)didUpdatePaxDeviceSetting
{
    [self displayCCBatchUI];
}

#pragma mark - Current Transction Server

-(NSString *)getTransctionServerForSpecOption {
    TenderPay *tenderPay = [self getPaymentDetailForEntity:@"TenderPay" withThePredicate:[NSPredicate predicateWithFormat:@"cardIntType == %@",@"Credit"]];
    NSString *transctionServerForSpecOption = [NSString stringWithFormat:@"%@",[self transctionServerForSpecOptionforPaymentId:tenderPay.payId.integerValue]];
    return transctionServerForSpecOption;
}

-(TenderPay *)getPaymentDetailForEntity:(NSString *)entityName withThePredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.rmsDbController.managedObjectContext];
    fetchRequest.entity = entity;
    
    if (predicate!=nil) {
        fetchRequest.predicate = predicate;
    }
    
    NSArray *arrayPay = [UpdateManager executeForContext:self.rmsDbController.managedObjectContext FetchRequest:fetchRequest];
    
    TenderPay *tenderPay = arrayPay.firstObject;
    
    return tenderPay;
}

-(NSString *)transctionServerForSpecOptionforPaymentId:(NSInteger)paymentId
{
    NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig" ];
    if(arrTemp.count > 0)
    {
        self.crmController.globalArrTenderConfig = [arrTemp mutableCopy];
    }
    NSString *applicableTransctionServer = @"";
    for(int i = 0; i<self.crmController.globalArrTenderConfig.count; i++)
    {
        int itender = [[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"PayId" ] intValue ];
        if(paymentId == itender)
        {
            NSInteger paymentServerSpecOption = [[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"] intValue ];
            switch (paymentServerSpecOption)
            {
                case SPEC_RAPID_SERVER:
                    applicableTransctionServer = @"RAPID CONNECT";
                    break;
                case SPEC_BRIDGEPAY_SERVER:
                    applicableTransctionServer = @"BRIDGEPAY";
                    break;
                default:
                    
                    break;
            }
        }
    }
    return applicableTransctionServer;
}

#pragma mark - UIConfiguration

- (void)displayCCBatchUI {
    //Display default screen as per payment gateway
    [self initialConfigurationProcessForCCBatch];
    [self defaultSetupForCCBatch];
    [self configureDefaultCCBatchUI];
    switch (paymentGateWay) {
        case BridgePay:
            //Current Trnxs For BridgePay
            [self setSelected:TabOptionCCOverView];
            [self configureCCBatchOtherOptionsViewForTab:TabOptionCCOverView];
            [self loadCurrentTransaction];
            [self configureContainerView:self.cCOverViewContainer];
            break;
            
        case Pax:
            //Device Batch For Pax
            [self setSelected:TabOptionDeviceSummary];
            [self configureCCBatchOtherOptionsViewForTab:TabOptionDeviceSummary];
            [self loadDeviceSummary];
            [self configureContainerView:self.deviceSummaryContainer];
            break;
            
        default:
            break;
    }
}

- (void)configureContainerView:(UIView *)containerView {
    self.cCOverViewContainer.hidden = YES;
    self.currentTrnxsContainer.hidden = YES;
    self.deviceSummaryContainer.hidden = YES;
    self.deviceBatchContainer.hidden = YES;
    containerView.hidden = NO;
}

- (void)configureCCBatchOtherOptionsViewForTab:(TabOption)tabOption {
    //Display Other Options after Tab Options in Right Side
    [self hideOtherOptionView];
    switch (tabOption) {
        case TabOptionCCOverView:
            [self showOption:self.btnRegisterSelection];
            self.btnCardTypeSelection.hidden = YES;
            break;
        case TabOptionCurrentTrnxs:
            [self showOption:self.btnRegisterSelection];
            break;
        case TabOptionDeviceSummary:
            break;
        case TabOptionDeviceBatch:
            [self showOption:self.btnPaxSetup];
            if (paymentGateWay == BridgePay) {
                self.btnPaxSetup.hidden = YES;
            }
            break;
            
        default:
            break;
    }
}

- (void)hideOtherOptionView {
    self.ccBatchOtherOptionsView.hidden = YES;
}

- (void)showOtherOptionView {
    self.ccBatchOtherOptionsView.hidden = NO;
}

- (void)showOption:(UIButton *)button {
    [self showOtherOptionView];
    self.btnRegisterSelection.hidden = YES;
    self.btnPaxSetup.hidden = YES;
    self.btnCardTypeSelection.hidden = NO;
    button.hidden = NO;
}

#pragma mark - SettleBatch

- (void)settleBatchProcess {
    CCBatchVC * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        switch (paymentGateWay) {
            case BridgePay:
                //Batch Settlement For BridgePay
                [myWeakReference batchSettlementProcessForBridgePay];
                break;
                
            case Pax:
                //Batch Settlement For Pax
                [myWeakReference batchSettlementProcessForPax];
                break;
                
            default:
                break;
        }
    };
    
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to do batch settlement?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)batchSettlementProcessForBridgePay
{
    [self startActivityIndicator];
    [self.cCBatchForBridgePay batchSettlementProcessForBridgePay];
}

- (void)batchSettlementProcessForPax {
    [self startActivityIndicator];
    [self.cCBatchVCDelegate updateLoadingMessageForCCBatch:@"Please enter password in the device, if required"];
    [self.cCBatchForPax batchSettlementProcessForPax];
}

#pragma mark - Insert Card Settlement

- (NSString *)getCurrentDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *currentDate = [dateFormatter stringFromDate:date];
    return currentDate;
}

- (NSMutableDictionary *)getInsertCardSettlementParameterWithResponseString:(NSString *)responseString isXML:(BOOL)isXMLResponse {
    NSMutableDictionary *parameterDictionary = [[NSMutableDictionary alloc] init];
    parameterDictionary[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    parameterDictionary[@"BatchNo"] = @"";
    parameterDictionary[@"SettlementDate"] = [self getCurrentDate];
    parameterDictionary[@"UserId"] = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    parameterDictionary[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    parameterDictionary[@"GatewayType"] = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
    parameterDictionary[@"IsManual"] = @"1";
    parameterDictionary[@"Responsemsg"] = responseString;
    parameterDictionary[@"BatchSettlementAmount"] = @"0";
    parameterDictionary[@"IsXMLResponse"] = @(isXMLResponse);
    return parameterDictionary;
}

- (void)insertCardSettlementProcessWithResponseString:(NSString *)responseString isXML:(BOOL)isXMLResponse
{
    [self startActivityIndicator];
    NSMutableDictionary *parameterDictionary = [self getInsertCardSettlementParameterWithResponseString:responseString isXML:isXMLResponse];
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseInsertCardSettlementResponse:response error:error];
        });
    };
    self.insertCardSettlementWC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_INSERT_CARD_SETTLEMENT_JSON params:parameterDictionary completionHandler:completionHandler];
}

- (void)responseInsertCardSettlementResponse:(id)response error:(NSError *)error
{
    [self stopActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
               // [self showAlertWithMessage:@"Batch settlement sucess" withTitle:@"Info"];
                [self resetCCBatchAfterBatchSettlement:YES];
            }
            else {
               // [self showAlertWithMessage:@"Batch settlement failed" withTitle:@"Info"];
            }
        }
    }
}

#pragma mark - PaxSetupVCDelegate 

- (void)didCancelPaxSetUp {
    [self.cCBatchVCDelegate removePresentedViewForCCBatch];
    self.btnPaxSetup.selected = NO;
    [self.cCBatchForPax configureIPAndPortOfPaxDeviceAsPerSetting];
}

- (void)didSavePaxData:(NSDictionary *)paxDictionary {
    [self.cCBatchForPax configureIPAndPortOfOtherPaxDevice:paxDictionary];
}

- (void)didRequestedForConnectOtherPaxDevice {
    [self.cCBatchForPax requestForConnectOtherPaxDevice];
}

- (void)didFetchDataForOtherConnectedPaxDevice {
    self.btnPaxSetup.selected = NO;
    needToReloadDeviceBatch = YES;
    needToReloadDeviceSummary = YES;
    [self loadDeviceBatch];
}

- (void)startActivityIndicatorForPax {
    [self startActivityIndicator];
}

- (void)stopActivityIndicatorForPax {
    [self stopActivityIndicator];
}

#pragma mark - Other Option Events

- (IBAction)registerSelectionClicked:(id)sender {
    if (self.registerDetailArray != nil && self.registerDetailArray.count > 0) {
        switch (selectedTabOption) {
            case TabOptionCCOverView:
                [self openRegisterSelectionPopUp:sender isCCOverViewSelected:YES];
                break;
                
            case TabOptionCurrentTrnxs:
                [self openRegisterSelectionPopUp:sender isCCOverViewSelected:NO];
                break;
                
            default:
                break;
        }
    }
}

- (void)openRegisterSelectionPopUp:(id)sender isCCOverViewSelected:(bool)isCCOverViewSelected {
    SelectUserOptionVC *selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:self.registerDetailArray OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        [self.btnRegisterSelection setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        if (isCCOverViewSelected) {
            selectedRegisterIdForCCOverView = arrSelection.firstObject [@"RegisterId"];
            selectedRegisterNameForCCOverView = arrSelection.firstObject [@"RegisterName"];
            [self.btnRegisterSelection setTitle:selectedRegisterNameForCCOverView forState:UIControlStateNormal];
            [self updateCCOverViewUIAsPerFilter];
        }
        else {
            selectedRegisterIdForCurrentTransaction = arrSelection.firstObject [@"RegisterId"];
            selectedRegisterNameForCurrentTrnxs = arrSelection.firstObject [@"RegisterName"];
            [self.btnRegisterSelection setTitle:selectedRegisterNameForCurrentTrnxs forState:UIControlStateNormal];
            [self updateCurrentTrnxsUIAsPerFilter];
        }
    } SelectionColse:^(UIViewController *popUpVC) {
        [[popUpVC presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    }];
    selectUserOptionVC.strkey = @"RegisterName";
    if (isCCOverViewSelected) {
        selectUserOptionVC.selectedObject = @{ @"RegisterId" : selectedRegisterIdForCCOverView,
                                               @"RegisterName" : self.btnRegisterSelection.titleLabel.text};
    }
    else {
        selectUserOptionVC.selectedObject = @{ @"RegisterId" : selectedRegisterIdForCurrentTransaction,
                                               @"RegisterName" : self.btnRegisterSelection.titleLabel.text};
    }
    selectUserOptionVC.isHideArrow = true;
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

- (IBAction)paxSetupClicked:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Reporting" bundle:nil];
    paxSetupVC = [storyBoard instantiateViewControllerWithIdentifier:@"PaxSetupVC"];
    paxSetupVC.paxSetupVCDelegate = self;
    paxSetupVC.view.frame = CGRectMake(301, 214, 421, 340);
    self.btnPaxSetup.selected = YES;
    [self.cCBatchVCDelegate presentViewAsModalForCCBatch:paxSetupVC.view];
    [paxSetupVC statusForOtherPaxDeviceConnection:@"CONNECTED"];
    NSDictionary *paxDictionary = [self.cCBatchForPax paxInfoDictionary];
    [paxSetupVC displayPaxConnectionDetail:@{
                                            @"PaxIpAddress":paxDictionary [@"PaxIpAddress"],
                                            @"Port":paxDictionary [@"Port"],
                                             }];
}

- (IBAction)cardTypeSelectionClicked:(id)sender {
    switch (selectedTabOption) {
        case TabOptionCurrentTrnxs:
            if (self.totalCardArrayForCurrentTrnxs != nil && self.totalCardArrayForCurrentTrnxs.count > 0) {
                [self openCardTypePopUpForCurrentTrnxs:sender];
            }
            break;
            
        case TabOptionDeviceBatch:
            if (self.totalCardArrayForDeviceBatch != nil && self.totalCardArrayForDeviceBatch.count > 0) {
                [self openCardTypePopUpForDeviceBatch:sender];
            }
            break;

        default:
            break;
    }
}

- (void)openCardTypePopUpForCurrentTrnxs:(id)sender {
    [self openCardTypePopUp:sender withTotalOption:self.totalCardArrayForCurrentTrnxs forCurrentTransaction:YES];
}

- (void)openCardTypePopUpForDeviceBatch:(id)sender {
    [self openCardTypePopUp:sender withTotalOption:self.totalCardArrayForDeviceBatch forCurrentTransaction:NO];
}

- (void)openCardTypePopUp:(id)sender withTotalOption:(NSMutableArray *)totalOptionArray forCurrentTransaction:(BOOL)isCurrentTransaction {
    SelectUserOptionVC *selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:totalOptionArray OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        [self.btnCardTypeSelection setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        if (isCurrentTransaction) {
            selectedCardTypeForCurrentTrnxs = arrSelection.firstObject;
            [self.btnCardTypeSelection setTitle:selectedCardTypeForCurrentTrnxs forState:UIControlStateNormal];
            [self updateCurrentTrnxsUIAsPerFilter];
        }
        else {
            selectedCardTypeForDeviceBatch = arrSelection.firstObject;
            [self.btnCardTypeSelection setTitle:selectedCardTypeForDeviceBatch forState:UIControlStateNormal];
            [self.deviceBatchVC clearSearchTextFieldOfCommonHeader];
            [self updateDeviceBatchUIAsPerFilterUsingCardType:arrSelection.firstObject];
        }
    } SelectionColse:^(UIViewController *popUpVC) {
        [[popUpVC presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    }];
    selectUserOptionVC.selectedObject = self.btnCardTypeSelection.titleLabel.text;
    selectUserOptionVC.isHideArrow = true;
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

- (void)updateCCOverViewUIAsPerFilter {
    NSMutableArray *filterArray;
    NSMutableArray *predicateArray = [[NSMutableArray alloc] init];
    if (![selectedRegisterIdForCCOverView isEqual:@(-1)]) {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"RegisterId = %@",selectedRegisterIdForCCOverView]];
    }
    if (predicateArray.count > 0) {
        NSPredicate *cardPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
        NSArray *creditCardDetail = [totalCardDetailsArrayForCurrentTrnx filteredArrayUsingPredicate:cardPredicate];
        filterArray = [creditCardDetail mutableCopy];
    }
    else
    {
        filterArray = [totalCardDetailsArrayForCurrentTrnx mutableCopy];
    }
    [self setupCardArrayWithCardDetailForOverView:filterArray];
    [self configureChartArray:filterArray];
    [self loadCCOverView];
}

- (void)updateCurrentTrnxsUIAsPerFilter {
    NSMutableArray *predicateArray = [[NSMutableArray alloc] init];
    if (![selectedCardTypeForCurrentTrnxs isEqualToString:@"All"] && ![selectedCardTypeForCurrentTrnxs isEqualToString:@"SELECT CARD TYPE"])
    {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"CardType = %@",selectedCardTypeForCurrentTrnxs]];
    }
    if (![selectedRegisterIdForCurrentTransaction isEqual:@(-1)]) {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"RegisterId = %@",selectedRegisterIdForCurrentTransaction]];
    }
    if (predicateArray.count > 0) {
        NSPredicate *cardPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
        NSArray *creditCardDetail = [totalCardDetailsArrayForCurrentTrnx filteredArrayUsingPredicate:cardPredicate];
        self.cardDetailForCurrentTrnx = [creditCardDetail mutableCopy];
    }
    else
    {
        self.cardDetailForCurrentTrnx = [totalCardDetailsArrayForCurrentTrnx mutableCopy];
    }
    [self.currentTransactionVC updateCurrentTrnxUIWithCardDetail:self.cardDetailForCurrentTrnx];
    [self setupCardArrayWithCardDetailForCurrentTrnx:self.cardDetailForCurrentTrnx];
    [self setCurrentTransactionPrintingData];
}

- (void)updateDeviceBatchUIAsPerFilterUsingCardType:(NSString *)selectedCardType {
    NSPredicate *cardPredicate;
    if (![selectedCardType isEqualToString:@"All"] && ![selectedCardType isEqualToString:@"SELECT CARD TYPE"])
    {
        cardPredicate = [NSPredicate predicateWithFormat:@"CardType = %@",selectedCardTypeForDeviceBatch];
    }
    if (cardPredicate) {
        NSArray *creditCardDetail = [totalCardDetailsArrayForDeviceBatch filteredArrayUsingPredicate:cardPredicate];
        self.cardDetailForDeviceBatch = [creditCardDetail mutableCopy];
    }
    else
    {
        self.cardDetailForDeviceBatch = [totalCardDetailsArrayForDeviceBatch mutableCopy];
    }
    [self.deviceBatchVC updateDeviceBatchUIWithCardDetail:self.cardDetailForDeviceBatch];
    [self setupCardArrayWithCardDetailForDeviceBatch:self.cardDetailForDeviceBatch];
    [self setDeviceBatchPrintingData];
}

#pragma mark - Tab Option Events

- (void)setSelected:(TabOption)tabOption {
    selectedTabOption = tabOption;
    for (UIButton *button in self.headerView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            if (button.tag == tabOption) {
                button.selected = YES;
            }
            else
            {
                button.selected = NO;
            }
        }
    }
}

- (IBAction)tabOptionSelected:(UIButton *)sender {
    TabOption tabOption = sender.tag;
    [self setSelected:tabOption];
    [self configureCCBatchOtherOptionsViewForTab:tabOption];
    switch (tabOption) {
        case TabOptionCCOverView:
            //Display CCOverView
            [self.cCBatchVCDelegate setSelectedPrintOptionForCCBatch:CCOverViewPrint];
            if (totalCardDetailsArrayForCurrentTrnx == nil || totalCardDetailsArrayForCurrentTrnx.count == 0) {
                //Load Current Trnxs
                [self loadCurrentTransaction];
                return;
            }
            [self loadCCOverView];
            [self configureContainerView:self.cCOverViewContainer];
            break;
        case TabOptionCurrentTrnxs:
            //Display Current Trnxs
            [self loadCurrentTransaction];
            [self configureContainerView:self.currentTrnxsContainer];
            break;
        case TabOptionDeviceSummary:
            //Display Device Summary
            [self.cCBatchVCDelegate setSelectedPrintOptionForCCBatch:DeviceSummaryPrint];
            [self loadDeviceSummary];
            [self configureContainerView:self.deviceSummaryContainer];
            break;
        case TabOptionDeviceBatch:
            //Display Device Batch
            [self loadDeviceBatch];
            [self configureContainerView:self.deviceBatchContainer];
            break;
            
        default:
            break;
    }
}

#pragma mark - Load CCOverView

- (void)loadCCOverView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.btnRegisterSelection setTitle:selectedRegisterNameForCCOverView forState:UIControlStateNormal];
    });
    if (selectedTabOption == TabOptionCCOverView) {
        [self.cCBatchVCDelegate setSelectedPrintOptionForCCBatch:CCOverViewPrint];
        [self setCCOverViewPrintingData];
    }
    [self.cCOverViewVC loadCCBatchPieChart:chartArray];
}

#pragma mark - Load Current Transaction

- (void)loadCurrentTransaction {
    [self.cCBatchVCDelegate setSelectedPrintOptionForCCBatch:CurrentTransactionPrint];
    [self setCurrentTransactionPrintingData];
    if (selectedTabOption == TabOptionCCOverView) {
        [self.btnRegisterSelection setTitle:selectedRegisterNameForCCOverView forState:UIControlStateNormal];
    }
    else {
        [self.btnRegisterSelection setTitle:selectedRegisterNameForCurrentTrnxs forState:UIControlStateNormal];
    }
    [self.btnCardTypeSelection setTitle:selectedCardTypeForCurrentTrnxs forState:UIControlStateNormal];
    if (!needToReloadCurrentTrnx) {
        if (selectedTabOption == TabOptionCCOverView) {
            [self loadOverViewAfterLoadingCurrentTrnxIfRequire];
        }
        return;
    }
    [self configureCurrentTransaction];
    switch (paymentGateWay) {
        case BridgePay:
            //Current Transaction For BridgePay
            [self loadCurrentTransactionForBridgePay];
            break;
            
        case Pax:
            //Current Transaction For Pax
            [self loadCurrentTransactionForPax];
            break;

        default:
            break;
    }
}

- (void)loadCurrentTransactionForBridgePay {
    [self startActivityIndicator];
    [self.cCBatchForBridgePay getCurrentTransactionDataThroughBridgePayForDate:[self currentDateForCurrentTrnx]];
}

- (void)loadCurrentTransactionForPax {
    [self startActivityIndicator];
    [self.cCBatchForPax getCurrentTransactionDataThroughPaxForDate:[self currentDateForCurrentTrnx] withPaxSerialNo:paxSerialNo];
}

- (void)configureCurrentTransaction {
    self.currentTransactionVC.isTipsApplicable = self.isTipsApplicable;
    [self.currentTransactionVC configureCurrentTransactionHeader];
}

- (NSString *)currentDateForCurrentTrnx {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDate = [dateFormatter stringFromDate:date];
    return currentDate;
}

#pragma mark - Load Device Summary

- (void)loadDeviceSummary {
    [self setDeviceSummaryPrintingData];
    if (!needToReloadDeviceSummary) {
        return;
    }
    //Get Device Summary
    [self getDeviceSummaryDetailsAccordingToPaymentGateWay];
}

- (void)getDeviceSummaryDetailsAccordingToPaymentGateWay
{
    switch (paymentGateWay) {
        case BridgePay:
            //Device Summary For BridgePay
            [self configureDeviceBatch];
            [self loadDeviceBatchDataForBridgePay];
            break;
            
        case Pax:
            //Device Summary For Pax
            [self loadDeviceSummaryForPax];
            break;
            
        default:
            break;
    }
}

- (void)loadDeviceSummaryForPax {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startActivityIndicator];
    });
    
    paxReportArray = @[@(PaxLocalTotalReportCredit),@(PaxLocalTotalReportDebit),@(PaxLocalTotalReportEBT)];
    [self.cCBatchForPax deviceSummaryDataForPax];
}

#pragma mark - Load Device Batch

- (void)loadDeviceBatch {
    [self.cCBatchVCDelegate setSelectedPrintOptionForCCBatch:DeviceBatchPrint];
    [self setDeviceBatchPrintingData];
    [self.btnCardTypeSelection setTitle:selectedCardTypeForDeviceBatch forState:UIControlStateNormal];
    if (!needToReloadDeviceBatch) {
        return;
    }
    [self configureDeviceBatch];
    switch (paymentGateWay) {
        case BridgePay:
            //Device Batch For BridgePay
            [self loadDeviceBatchDataForBridgePay];
            break;
            
        case Pax:
            //Device Batch For Pax
            [self loadDeviceBatchDataForPax];
            break;
            
        default:
            break;
    }
}

- (void)configureDeviceBatch {
    self.deviceBatchVC.isTipsApplicable = self.isTipsApplicable;
    [self.deviceBatchVC configureDeviceBatchHeader];
}

-(void)loadDeviceBatchDataForBridgePay
{
    [self startActivityIndicator];
    [self.cCBatchForBridgePay deviceBatchDataForBridgePay];
}

-(void)loadDeviceBatchDataForPax
{
    [self startActivityIndicator];
    [self.cCBatchForPax deviceBatchDataForPax];
}

#pragma mark - ActivityIndicator

- (void)startActivityIndicator {
    [self.cCBatchVCDelegate startActivityIndicatorForCCBatch];
}

- (void)stopActivityIndicator {
    [self.cCBatchVCDelegate stopActivityIndicatorForCCBatch];
}

#pragma mark - CCBatchForBridgePayDelegate

- (void)currentTransactionResponse:(id)response error:(NSError *)error
{
    [self stopActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responeArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                self.cardDetailForCurrentTrnx = [responeArray mutableCopy];
                [self configureRegisterDetail];
                [self getTotalCardArrayForCurrentTrnxs:responeArray];
                [self configureChartArray:responeArray];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self loadOverViewAfterLoadingCurrentTrnxIfRequire];
                });
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"BillDate" ascending:FALSE];
                [self.cardDetailForCurrentTrnx sortUsingDescriptors:@[sortDescriptor]];
                totalCardDetailsArrayForCurrentTrnx = [self.cardDetailForCurrentTrnx mutableCopy];
                dispatch_async(dispatch_get_main_queue(),  ^{
                    needToReloadCurrentTrnx = false;
                    [self.currentTransactionVC updateCurrentTrnxUIWithCardDetail:self.cardDetailForCurrentTrnx];
                });
                [self setCurrentTransactionPrintingData];
                [self setupCardArrayWithCardDetailForCurrentTrnx:self.cardDetailForCurrentTrnx];
                [self updateCCOverViewUIAsPerFilter];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (selectedTabOption == TabOptionCCOverView) {
                        [self loadOverViewAfterLoadingCurrentTrnxIfRequire];
                    }
                });
                switch (paymentGateWay) {
                    case BridgePay:
                        [self showAlertWithMessage:@"No Record found for Bridge Pay." withTitle:@"Info"];
                        break;
                        
                    case Pax:
                        [self showAlertWithMessage:@"No Record found for Pax." withTitle:@"Info"];
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
}

- (void)deviceBatchDataForBridgePay:(NSMutableArray *)deviceBatchDataArray {
    needToReloadDeviceSummary = false;
    deviceSummaryPrintingArray = [deviceBatchDataArray copy];
    [self setDeviceSummaryPrintingData];
    [self.deviceSummaryVC displayDeviceSummaryUI:deviceBatchDataArray paxReportEnum:nil withPaymentGateWay:paymentGateWay];
    [self deviceBatchSetupUsingData:deviceBatchDataArray];
}

- (void)deviceBatchSetupUsingData:(NSMutableArray *)deviceBatchDataArray {
    [self stopActivityIndicator];
    totalCardDetailsArrayForDeviceBatch = [deviceBatchDataArray mutableCopy];
    self.cardDetailForDeviceBatch = [deviceBatchDataArray mutableCopy];
    [self getTotalCardArrayForDeviceBatch:totalCardDetailsArrayForDeviceBatch];
    needToReloadDeviceBatch = false;
    [self.deviceBatchVC updateDeviceBatchUIWithCardDetail:self.cardDetailForDeviceBatch];
    [self setupCardArrayWithCardDetailForDeviceBatch:self.cardDetailForDeviceBatch];
    [self setDeviceBatchPrintingData];
}

- (void)didErrorOccurredWhileGettingDeviceBatchDataThroughBridgePay {
    [self stopActivityIndicator];
    if([transctionServer isEqualToString:@"RAPID CONNECT"]) {
        [self showAlertWithMessage:@"No Record found in Rapid Server." withTitle:@"Info"];
    }
    else {
        [self showAlertWithMessage:@"No Record found in Bridge Pay." withTitle:@"Info"];
    }
}

- (void)didConnectionDroppedWhileGettingDeviceBatchDataThroughBridgePay {
    [self stopActivityIndicatorAndShowAlertWithMessage:@"Connection Dropped. Try again." withTitle:@"Info"];
}

- (void)didBatchSettledWithBatchSummry:(NSArray *)batchSummryArray batchInfo:(NSString *)batchInfo result:(NSInteger)result response:(NSString *)responseString
{
    [self stopActivityIndicator];
    bridgePayBatchSummryArray = batchSummryArray;
    NSDictionary *printccBatchReceiptDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrintCCBatchReceiptSetting"];
    if (printccBatchReceiptDictionary != nil) {
        if([[printccBatchReceiptDictionary valueForKey:@"PrintCCBatchReceipt"] isEqual: @(1)])
        {
            [self bridgePayCCBatchPrintReceipt:bridgePayBatchSummryArray];
        }
        else
        {
            [self displayBatchSettlementAlertWithBatchInfo:batchInfo andResult:result];
        }
    }
    else
    {
        [self displayBatchSettlementAlertWithBatchInfo:batchInfo andResult:result];
    }
    if(![transctionServer isEqualToString:@"RAPID CONNECT"]){
        [self insertCardSettlementProcessWithResponseString:responseString isXML:TRUE];
    }
}

- (void)didErrorOccurredInBatchSettlementProcessWithMessage:(NSString *)responseMessage withTitle:(NSString *)title {
    [self stopActivityIndicatorAndShowAlertWithMessage:responseMessage withTitle:title];
}

- (void)errorOccurredInTipAdjustmentThroughRapidConnectServerWithMessage:(NSString *)message withTitle:(NSString *)title {
    [self stopActivityIndicatorAndShowAlertWithMessage:message withTitle:title];
}

- (void)didTipsAdjustedSuccessfullyWithMessage:(NSString *)message withTitle:(NSString *)title {
    [self showAlertWithMessage:message withTitle:title];
    [self loadAppropriateUIAfterTipsAdjustment];
}

- (void)startActivityIndicatorForBridgePay {
    [self startActivityIndicator];
}

- (void)stopActivityIndicatorForBridgePay {
    [self stopActivityIndicator];
}

#pragma mark - Current Transaction Process

- (void)configureRegisterDetail {
    NSArray *uniqueRegisterArray = [self.cardDetailForCurrentTrnx valueForKeyPath:@"@distinctUnionOfObjects.RegisterId"];
    self.registerDetailArray = [[NSMutableArray alloc] init];
    for (NSNumber *registerId in uniqueRegisterArray) {
        NSPredicate *registerPredicate = [NSPredicate predicateWithFormat:@"RegisterId == %@",registerId];
        NSString *registerName = [[[self.cardDetailForCurrentTrnx filteredArrayUsingPredicate:registerPredicate] firstObject] valueForKey:@"RegisterName"];
        NSDictionary *registerDictionary = @{
                                             @"RegisterId" : registerId,
                                             @"RegisterName" : registerName,
                                             };
        [self.registerDetailArray addObject:registerDictionary];
    }
    if (self.registerDetailArray != nil && self.registerDetailArray.count > 0) {
        NSDictionary *registerDictionary;
        if (selectedTabOption == TabOptionCCOverView) {
            registerDictionary = @{
                                   @"RegisterId" : @(-1),
                                   @"RegisterName" : @"All Registers",
                                   };
        }
        else {
            registerDictionary = @{
                                   @"RegisterId" : @(-1),
                                   @"RegisterName" : @"All Registers",
                                   };
        }
        [self.registerDetailArray insertObject:registerDictionary atIndex:0];
    }
}

- (void)loadOverViewAfterLoadingCurrentTrnxIfRequire {
    if (selectedTabOption == TabOptionCCOverView) {
        if (chartArray == nil || chartArray.count == 0) {
            chartArray = [[NSMutableArray alloc] init];
            [chartArray addObject:[self deafultOverViewDict]];
        }
        [self loadCCOverView];
        [self configureContainerView:self.cCOverViewContainer];
    }
}

- (NSDictionary *)deafultOverViewDict {
    NSDictionary *dictionary = @{
                                 @"Card" : @"-",
                                 @"Amount" : @(0),
                                 @"TrnxCount" : @"0",
                                 @"AvgTicket" : @(0),
                                 };
    return dictionary;
}


#pragma mark - Batch Settlement Process

- (void)displayBatchSettlementAlertWithBatchInfo:(NSString *)batchInfo andResult:(NSInteger)result{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self resetCCBatchAfterBatchSettlement:YES];
    };
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self bridgePayCCBatchPrintReceipt:bridgePayBatchSummryArray];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Batch Info" message:[NSString stringWithFormat:batchInfo,result] buttonTitles:@[@"OK",@"Print"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)resetCCBatchAfterBatchSettlement:(BOOL)isCCBatchSettled {
    if (isCCBatchSettled) {
        if (needToReloadCurrentTrnx) {
            needToReloadCurrentTrnx = false;
        }
        if (needToReloadDeviceSummary) {
            needToReloadDeviceSummary = false;
        }
        if (needToReloadDeviceBatch) {
            needToReloadDeviceBatch = false;
        }
    }
    else {
        needToReloadCurrentTrnx = true;
        needToReloadDeviceSummary = true;
        needToReloadDeviceBatch = true;
    }
    [self configureDefaultCCBatchUI];
}

- (void)configureDefaultCCBatchUI {
    [chartArray removeAllObjects];
    [self.cCOverViewVC loadCCBatchPieChart:chartArray];
    [self loadOverViewAfterLoadingCurrentTrnxIfRequire];
    [self.cardDetailForCurrentTrnx removeAllObjects];
    [self.totalCardArrayForCurrentTrnxs removeAllObjects];
    [totalCardDetailsArrayForCurrentTrnx removeAllObjects];
    [self.currentTransactionVC updateCurrentTrnxUIWithCardDetail:self.cardDetailForCurrentTrnx];
    [self setupCardArrayWithCardDetailForCurrentTrnx:self.cardDetailForCurrentTrnx];
    [self setupCardArrayWithCardDetailForOverView:self.cardDetailForCurrentTrnx];
    [self.registerDetailArray removeAllObjects];
    [self.cardDetailForDeviceBatch removeAllObjects];
    [self.totalCardArrayForDeviceBatch removeAllObjects];
    [totalCardDetailsArrayForDeviceBatch removeAllObjects];
    [self.deviceBatchVC updateDeviceBatchUIWithCardDetail:self.cardDetailForDeviceBatch];
    [self setupCardArrayWithCardDetailForDeviceBatch:self.cardDetailForDeviceBatch];
    [self.cCBatchVCDelegate setPrintingData:nil paymentGateWay:paymentGateWay transactionDetails:nil filterDictionary:nil];
    [self.deviceSummaryVC displayDeviceSummaryUI:nil paxReportEnum:nil withPaymentGateWay:paymentGateWay];
}

#pragma mark - ChartConfiguration

-(void)configureChartArray:(NSMutableArray *)responseArray
{
    chartArray = [[NSMutableArray alloc] init];
    
    NSArray *cardArray = [responseArray valueForKey:@"CardType"];
    NSSet *cardSet = [NSSet setWithArray:cardArray];
    
    for (NSString *card in cardSet) {
        NSMutableDictionary *cardDictionary = [[NSMutableDictionary alloc] init];
        NSPredicate *cardPreDicate = [NSPredicate predicateWithFormat:@"CardType = %@",card];
        NSArray *cardArray = [responseArray filteredArrayUsingPredicate:cardPreDicate];
        NSNumber *totalCardAmount = [cardArray valueForKeyPath:@"@sum.BillAmount"];
        NSNumber *totalTipAmount = [cardArray valueForKeyPath:@"@sum.TipAmount"];
        cardDictionary[@"Amount"] = totalCardAmount;
        cardDictionary[@"TipAmount"] = totalTipAmount;
        cardDictionary[@"Card"] = card;
        cardDictionary[@"TrnxCount"] = [NSString stringWithFormat:@"%ld",(long)cardArray.count];
        float avgTicket = [totalCardAmount floatValue]/cardArray.count;
        cardDictionary[@"AvgTicket"] = @(avgTicket);
        [chartArray addObject:cardDictionary];
    }
}

#pragma mark - Configure Card Array

- (void)getTotalCardArrayForCurrentTrnxs:(NSMutableArray *)responseArray {
    NSArray *cardArray = [responseArray valueForKey:@"CardType"];
    NSSet *cardSet = [NSSet setWithArray:cardArray];
    self.totalCardArrayForCurrentTrnxs = [cardSet.allObjects mutableCopy];
    [self.totalCardArrayForCurrentTrnxs insertObject:@"All" atIndex:0];
}

- (void)getTotalCardArrayForDeviceBatch:(NSMutableArray *)responseArray {
    NSArray *cardArray = [responseArray valueForKey:@"CardType"];
    NSSet *cardSet = [NSSet setWithArray:cardArray];
    self.totalCardArrayForDeviceBatch = [cardSet.allObjects mutableCopy];
    [self.totalCardArrayForDeviceBatch insertObject:@"All" atIndex:0];
}

#pragma mark - Setup Card Details

- (void)setupCardArrayWithCardDetailForDeviceBatch:(NSMutableArray *)cardDetailArray
{
    //Update Device Batch Deatil
    dispatch_async(dispatch_get_main_queue(),  ^{
        CCBatchTrnxDetailStruct *cCBatchTrnxDetail = [self ccbatchStructForCardDetail:cardDetailArray];
        [self.deviceBatchVC updateCommonHeaderWith:cCBatchTrnxDetail];
    });
}

- (void)setupCardArrayWithCardDetailForOverView:(NSMutableArray *)cardDetailArray {
    //Update Over View Deatil
    dispatch_async(dispatch_get_main_queue(),  ^{
        CCBatchTrnxDetailStruct *cCBatchTrnxDetail = [self ccbatchStructForCardDetail:cardDetailArray];
        [self.cCOverViewVC updateCommonHeaderWith:cCBatchTrnxDetail];
    });
}

- (void)setupCardArrayWithCardDetailForCurrentTrnx:(NSMutableArray *)cardDetailArray {
    //Update Current Trnx Deatil
    dispatch_async(dispatch_get_main_queue(),  ^{
        CCBatchTrnxDetailStruct *cCBatchTrnxDetail = [self ccbatchStructForCardDetail:cardDetailArray];
        [self.currentTransactionVC updateCommonHeaderWith:cCBatchTrnxDetail];
    });
}

-(CCBatchTrnxDetailStruct *)ccbatchStructForCardDetail:(NSMutableArray *)cardDetailArray
{
    CCBatchTrnxDetailStruct *ccbatchFooter = [[CCBatchTrnxDetailStruct alloc] init];
    if (cardDetailArray != nil && cardDetailArray.count > 0)
    {
        NSArray *cardDetailsArray;
        BOOL needToCheckForVoid = [self needToCheckForVoidTransaction];
        if (needToCheckForVoid) {
            NSPredicate *predicate = [self predicateByExcludingVoidTransaction];
            cardDetailsArray = [cardDetailArray filteredArrayUsingPredicate:predicate];
            //            cardDetailsArray = [self cardDeatilsArrayIfHavingVoidTransactions:cardDetailArray];
        }
        else
        {
            cardDetailsArray = [cardDetailArray copy];
        }
        
        ccbatchFooter.total = [self totalAmount:cardDetailsArray];
        ccbatchFooter.tipAmount = [self totalTipsAll:cardDetailsArray];
        ccbatchFooter.grandTotal = [self totalTransactionForAll:cardDetailsArray];
        ccbatchFooter.totalTransaction = [NSString stringWithFormat:@"%lu",(unsigned long)cardDetailsArray.count];
        ccbatchFooter.totalAvgTicket = [self averageTransactionForAll:cardDetailsArray];
    }
    else {
        ccbatchFooter.total = @"$0.00";
        ccbatchFooter.tipAmount = @"$0.00";
        ccbatchFooter.grandTotal = @"$0.00";
        ccbatchFooter.totalTransaction = @"0";
        ccbatchFooter.totalAvgTicket = @"$0.00";
    }
    return ccbatchFooter;
}

- (BOOL)needToCheckForVoidTransaction {
    BOOL needToCheck = false;
    switch (selectedTabOption) {
        case TabOptionDeviceBatch:
        case TabOptionDeviceSummary:
            needToCheck = true;
            break;
            
        default:
            break;
    }
    return needToCheck;
}

- (NSArray *)cardDeatilsArrayIfHavingVoidTransactions:(NSMutableArray *)cardDetailArray {
    NSArray *voidTrnxsTypeArray = @[@"16",@"17",@"18",@"19",@"20",@"21",@"22"];
    NSPredicate *voidTrnxsPredicate = [NSPredicate predicateWithFormat:@"TransType IN %@",voidTrnxsTypeArray];
    NSArray *filterArray = [cardDetailArray filteredArrayUsingPredicate:voidTrnxsPredicate];
    NSPredicate *cardDetailTrnxsPredicate = [NSPredicate predicateWithFormat:@"not (RegisterInvNo IN %@)",[filterArray valueForKey:@"RegisterInvNo"]];
    NSArray *creditCardCellArray = [cardDetailArray filteredArrayUsingPredicate:cardDetailTrnxsPredicate];
    return creditCardCellArray;
}

- (NSString *)totalAmount:(NSArray *)cardDetailArray
{
    float billAmount = [self billAmountFromArray:cardDetailArray];
    return [NSString stringWithFormat:@"%.2f",billAmount];
}

- (NSString *)totalTipsAll:(NSArray *)cardDetailArray
{
    float tipsAmount = [[cardDetailArray valueForKeyPath:@"@sum.TipsAmount"] floatValue];
    return [NSString stringWithFormat:@"%.2f",tipsAmount];
}

- (NSString *)totalTransactionForAll:(NSArray *)cardDetailArray
{
    float total = [self billAmountFromArray:cardDetailArray] + [[cardDetailArray valueForKeyPath:@"@sum.TipsAmount"] floatValue];
    return [NSString stringWithFormat:@"%.2f",total];
}

- (NSString *)averageTransactionForAll:(NSArray *)cardDetailArray
{
    float billAmount = [self billAmountFromArray:cardDetailArray];
    NSInteger count = cardDetailArray.count;
    float averageTotal;
    if(count > 0)
    {
        averageTotal = billAmount / count;
    }
    else
    {
        averageTotal = 0.00;
    }
    return [NSString stringWithFormat:@"%.2f",averageTotal];
}

- (float)billAmountFromArray:(NSArray *)array
{
    float billAmount = 0.00;
    if (selectedTabOption == TabOptionDeviceBatch || selectedTabOption == TabOptionDeviceSummary) {
        billAmount = [[array valueForKeyPath:@"@sum.BillAmount"] floatValue];
        if (paymentGateWay == BridgePay) {
            NSArray *refundTransactions = [self refundTransactionsForBridgePayFromArray:array];
            if (refundTransactions && refundTransactions.count > 0) {
                float refundAmount = [[refundTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
                billAmount = billAmount - (refundAmount * 2);
            }
        }
        return billAmount;
    }
    billAmount = [[array valueForKeyPath:@"@sum.BillAmount"] floatValue];
    return billAmount;
}

- (NSArray *)refundTransactionsForBridgePayFromArray:(NSArray *)array {
    NSPredicate *refundPredicate = [self predicateForRefundTransaction];
    return [array filteredArrayUsingPredicate:refundPredicate];
}

- (NSPredicate *)predicateByExcludingVoidTransaction {
    return [NSPredicate predicateWithFormat:@"VoidSaleTrans  ==  %@ AND TransType != %@", @"0" ,@"Void" ];
}

- (NSPredicate *)predicateForWithoutRefundTransaction {
    return [NSPredicate predicateWithFormat:@"not (TransType IN %@)",@"Credit              "];
}

- (NSPredicate *)predicateForRefundTransaction {
    return [NSPredicate predicateWithFormat:@"TransType IN %@",@"Credit              "];
}

#pragma mark - CCBatchForPaxDelegate

- (void)statusForOtherPaxDeviceConnection:(NSString *)paxDeviceStatus withPaxSerialNo:(NSString *)serialNo {
    paxSerialNo = serialNo;
    [paxSetupVC statusForOtherPaxDeviceConnection:paxDeviceStatus];
}

- (void)deviceSummaryDataThroughPax:(NSMutableArray *)deviceSummaryArray {
    [self stopActivityIndicator];
    needToReloadDeviceSummary = false;
    deviceSummaryPrintingArray = [deviceSummaryArray copy];
    [self.cCBatchVCDelegate setSelectedPrintOptionForCCBatch:DeviceSummaryPrint];
    [self setDeviceSummaryPrintingData];
    [self.deviceSummaryVC displayDeviceSummaryUI:deviceSummaryArray paxReportEnum:paxReportArray withPaymentGateWay:paymentGateWay];
}

- (void)updateProgressStatusForFetchingPaxData:(CGFloat)percentage {
    [self.cCBatchVCDelegate removePresentedViewForCCBatch];
    [self.cCBatchVCDelegate updateProgressStatusForCCBatch:percentage];
}

- (void)deviceBatchDataForPax:(NSMutableArray *)deviceBatchDataArray {
    [self deviceBatchSetupUsingData:deviceBatchDataArray];
}

- (void)didBatchSettledWithDetails:(NSString *)batchJsonString totalTransactionCount:(NSInteger)totalTransactionCount totalAmount:(NSString *)totalAmount cCBatchNo:(NSString *)cCBatchNo batchMessage:(NSString *)batchMessage batchDictionary:(NSMutableDictionary *)batchDict{
    [self stopActivityIndicator];
    totalAmountString = totalAmount;
    totalCount = totalTransactionCount;
    batchNo = cCBatchNo;
    _dictPaxData = [batchDict mutableCopy];
    [self insertCardSettlementProcessWithResponseString:batchJsonString isXML:FALSE];
  
    NSDictionary *printccBatchReceiptDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrintCCBatchReceiptSetting"];
    if (printccBatchReceiptDictionary != nil) {
        if([[printccBatchReceiptDictionary valueForKey:@"PrintCCBatchReceipt"] isEqual: @(1)])
        {
            [self paxCCBatchPrintReceipt:totalTransactionCount totalAmount:totalAmount cCBatchNo:cCBatchNo paxCCbatchDict:batchDict];
        }
        else
        {
            [self displayBatchCloseAlert:batchMessage];
        }
    }
    else
    {
        [self displayBatchCloseAlert:batchMessage];
    }
}

- (void)didErrorOccurredInBatchSettlementProcessWithMessage:(NSString *)responseMessage {
    [self showAlertWithMessage:[NSString stringWithFormat:@"%@" ,responseMessage] withTitle:@"Info"];
}

- (void)paxDeviceFailedWhileBatchSettlementWithMessage:(NSString *)responseMessage {
    [self displayAlertForBatchCloseErrorUsing:responseMessage];
}

- (void)paxDeviceFailedWhileGettingDeviceBatchDataWithMessage:(NSString *)responseMessage {
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self resetCCBatchAfterBatchSettlement:NO];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:responseMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (void)paxDeviceFailedDueToErrorWithMessage:(NSString *)responseMessage {
    [self displayAlertForBatchCloseErrorUsing:responseMessage];
}

- (void)displayBatchCloseAlert:(NSString *)batchMessage {
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self startActivityIndicator];
        [self.cCBatchForPax paxTotalReport];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        
        [self paxCCBatchPrintReceipt:totalCount totalAmount:totalAmountString cCBatchNo:batchNo paxCCbatchDict:_dictPaxData];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Batch close successfully" message:batchMessage buttonTitles:@[@"OK",@"Print"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)displayAlertForBatchCloseErrorUsing:(NSString *)responseMessage {
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self startActivityIndicator];
        [self.cCBatchForPax paxTotalReport];
    };
    
    [self.rmsDbController popupAlertFromVC:self title:@"Batch close Error" message:responseMessage buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)processAfterVoidThroughPax {
    [self stopActivityIndicator];
    [self displayCCBatchUI];
}

#pragma mark - DeviceBatchVCDelegate

- (void)didSearch:(NSString *)text {
    searchTextForDeviceBatch = text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterInvNo == [c] %@ OR AuthCode == [c] %@ OR AccNo contains[cd] %@",text,text,text];
    NSMutableArray *filterArray = [[self.cardDetailForDeviceBatch filteredArrayUsingPredicate:predicate] mutableCopy];
    self.cardDetailForDeviceBatch = [filterArray mutableCopy];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"BillDate" ascending:FALSE];
    [self.cardDetailForDeviceBatch sortUsingDescriptors:@[sortDescriptor]];
    [self.deviceBatchVC updateDeviceBatchUIWithCardDetail:self.cardDetailForDeviceBatch];
    [self setupCardArrayWithCardDetailForDeviceBatch:self.cardDetailForDeviceBatch];
    [self setDeviceBatchPrintingData];
    if (filterArray == nil || filterArray.count == 0) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No record found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

- (void)didClearSearch {
    searchTextForDeviceBatch = @"";
    [self updateDeviceBatchUIAsPerFilterUsingCardType:selectedCardTypeForDeviceBatch];
}

- (void)didSelectRecordForTipAdjustmentAtIndexPath:(NSIndexPath *)indexpath {
    NSDictionary *dictionaryAtIndexpath;
    switch (selectedTabOption) {
        case TabOptionCurrentTrnxs:
            dictionaryAtIndexpath = (self.cardDetailForCurrentTrnx)[indexpath.row];
            break;
            
        case TabOptionDeviceBatch:
            dictionaryAtIndexpath = (self.cardDetailForDeviceBatch)[indexpath.row];
            break;

        default:
            break;
    }
    [self displayTipsUIWithTipDetail:dictionaryAtIndexpath];
}

-(void)displayTipsUIWithTipDetail:(NSDictionary *)tipsDictionary
{
    selectedTipsDictionary = tipsDictionary;
    NSString *identiFier = @"TipsView";
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    tipsVC = [storyBoard instantiateViewControllerWithIdentifier:identiFier];
    tipsVC.billAmountForTipCalculation = [[tipsDictionary valueForKey:@"BillAmount"] floatValue];
    tipsVC.tipsSelectionDeletage = self;
    tipsVC.tipAmount = [[tipsDictionary valueForKey:@"TipsAmount"] floatValue];
    [self.cCBatchVCDelegate addTipsView:tipsVC.view];
}

#pragma mark - TipsSelectionDeletage

-(void)didRemoveTip {
    [self removeAndResetTipUI];
}

-(void)didSelectTip:(CGFloat)tipAmount {
    switch (paymentGateWay) {
        case BridgePay:
            [self removeTipsView];
            [self startActivityIndicator];
            [self.cCBatchForBridgePay tipsAdjustmentForBridgePayWithTipAmount:tipAmount withTipsDictionary:selectedTipsDictionary];
            break;
            
        case Pax:
            break;
            
        default:
            break;
    }
}

-(void)didCancelTip {
    [self removeAndResetTipUI];
}

- (void)removeAndResetTipUI {
    [self removeTipsView];
    [self resetSelectedTipsDictionary];
}

- (void)removeTipsView {
    [self.cCBatchVCDelegate removeTipsView:tipsVC.view];
}

- (void)resetSelectedTipsDictionary {
    selectedTipsDictionary = nil;
}

#pragma mark - Update UI After Tips Adjustment

- (void)loadAppropriateUIAfterTipsAdjustment {
    needToReloadCurrentTrnx = true;
    needToReloadDeviceBatch = true;
    switch (selectedTabOption) {
        case TabOptionCurrentTrnxs:
            [self loadCurrentTransaction];
            break;
            
        case TabOptionDeviceBatch:
            [self loadDeviceBatchDataForBridgePay];
            break;
            
        default:
            break;
    }
}

#pragma mark - PaxCCBatchReceipt

-(void)paxCCBatchPrintReceipt:(NSInteger)totalTrxCount totalAmount:(NSString *)totalTrxAmountString cCBatchNo:(NSString *)trxCCBatchNo paxCCbatchDict:(NSMutableDictionary *)paxCCbatchDict
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self setPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    PaxCCBatchReceipt *paxCCBatchReceipt = [[PaxCCBatchReceipt alloc] initWithPortName:portName portSetting:portSettings withTotalCount:totalTrxCount withTotalAmount:totalTrxAmountString withBatchNo:trxCCBatchNo batchDictionary:paxCCbatchDict];
    
    [paxCCBatchReceipt printccBatchReceiptWithDelegate:self];
}

#pragma mark - BridgePayCCBatchReceipt

-(void)bridgePayCCBatchPrintReceipt:(NSArray *)ccBatchPrintReceiptArray
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self setPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    BridgePayCCBatchReceipt *bridgePayCCBatchReceipt = [[BridgePayCCBatchReceipt alloc] initWithPortName:portName portSetting:portSettings withBridgePayCCBatchData:ccBatchPrintReceiptArray];
    
    [bridgePayCCBatchReceipt printccBatchReceiptWithDelegate:self];
}

#pragma mark - Port Setting

+ (void)setPortName:(NSString *)m_portName
{
    [RcrController setPortName:m_portName];
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    [RcrController setPortSettings:m_portSettings];
}

- (void)setPortInfo
{
    NSString *localPortName;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"] length] > 0)
    {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"] isEqualToString:@"Bluetooth"]) {
            localPortName = @"BT:Star Micronics";
        }
        else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"] isEqualToString:@"TCP"]) {
            NSString *tcp = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedTCPPrinter"];
            localPortName = tcp;
        }
    }
    else{
        localPortName=@"BT:Star Micronics";
    }
    [CCBatchVC setPortName:localPortName];
    [CCBatchVC setPortSettings:array_port[0]];
}

#pragma mark - PrinterDelegate

-(void)printerTaskDidSuccessWithDevice:(NSString *)device
{
    [self resetCCBatchAfterBatchSettlement:YES];
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self resetCCBatchAfterBatchSettlement:YES];
    };

    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        if ([[(self.rmsDbController.paymentCardTypearray).firstObject valueForKey:@"Gateway"] isEqualToString:@"Bridgepay"])
        {
            [self bridgePayCCBatchPrintReceipt:bridgePayBatchSummryArray];
        }
        else if ([[(self.rmsDbController.paymentCardTypearray).firstObject valueForKey:@"Gateway"] isEqualToString:@"Pax"])
        {
            [self paxCCBatchPrintReceipt:totalCount totalAmount:totalAmountString cCBatchNo:batchNo paxCCbatchDict:_dictPaxData];
        }
    };
    
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Failed to Batch print receipt. Would you like to retry.?" buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

#pragma mark - CCBatch Printing

- (void)setCurrentTransactionPrintingData {
    CCBatchTrnxDetailStruct *cCBatchTrnxDetail = [self ccbatchStructForCardDetail:self.cardDetailForCurrentTrnx];
    [self.cCBatchVCDelegate setPrintingData:self.cardDetailForCurrentTrnx paymentGateWay:paymentGateWay transactionDetails:cCBatchTrnxDetail filterDictionary:[self filterDictionaryForCCBatch]];
}

- (void)setCCOverViewPrintingData {
    [self.cCBatchVCDelegate setPrintingData:chartArray paymentGateWay:paymentGateWay transactionDetails:nil filterDictionary:[self filterDictionaryForCCBatch]];
}

- (void)setDeviceSummaryPrintingData {
    [self.cCBatchVCDelegate setPrintingData:deviceSummaryPrintingArray paymentGateWay:paymentGateWay transactionDetails:nil filterDictionary:[self filterDictionaryForCCBatch]];
}

- (void)setDeviceBatchPrintingData {
    CCBatchTrnxDetailStruct *cCBatchTrnxDetail = [self ccbatchStructForCardDetail:self.cardDetailForDeviceBatch];
    [self.cCBatchVCDelegate setPrintingData:self.cardDetailForDeviceBatch paymentGateWay:paymentGateWay transactionDetails:cCBatchTrnxDetail filterDictionary:[self filterDictionaryForCCBatch]];
}

#pragma mark - CCBatch Filter Details

-(NSDictionary *)filterDictionaryForCCBatch {
    NSString *selectedRegister = @"";
    NSString *selectedCradType = @"";
    NSString *searchText = @"";

    switch (selectedTabOption) {
        case TabOptionCCOverView: {
            selectedRegister = selectedRegisterNameForCCOverView;
            break;
        }
        case TabOptionCurrentTrnxs: {
            selectedRegister = selectedRegisterNameForCurrentTrnxs;
            if ([selectedCardTypeForCurrentTrnxs isEqualToString:@"SELECT CARD TYPE"]) {
                selectedCradType = @"All Cards";
            }
            else {
                selectedCradType = selectedCardTypeForCurrentTrnxs;
            }
            break;
        }
        case TabOptionDeviceSummary: {

            break;
        }
        case TabOptionDeviceBatch: {
            if ([selectedCardTypeForDeviceBatch isEqualToString:@"SELECT CARD TYPE"]) {
                selectedCradType = @"All Cards";
            }
            else {
                selectedCradType = selectedCardTypeForDeviceBatch;
            }
            if (searchTextForDeviceBatch && searchTextForDeviceBatch.length > 0) {
                searchText = searchTextForDeviceBatch;
            }
            else {
                searchText = @"-";
            }
            break;
        }
    }
    
    return @{
             @"SelectedRegister":selectedRegister,
             @"SelectedCradType":selectedCradType,
             @"SearchText":searchText,
             };
}

#pragma mark - Void Transaction Process

-(void)setVoidTransactionProcess:(NSIndexPath *)indexpath
{
    [self startActivityIndicator];
    NSDictionary *dictionaryAtIndexpath;
    dictionaryAtIndexpath = (self.cardDetailForDeviceBatch)[indexpath.row];
    switch (paymentGateWay) {
        case BridgePay: {
            [self processVoidForBridgepayWithDetail:dictionaryAtIndexpath];
            break;
        }
        case Pax: {
            [self.cCBatchForPax paxVoidTransactionProcessWithDictionary:dictionaryAtIndexpath];
            break;
        }
    }
}

-(void)processVoidForBridgepayWithDetail:(NSDictionary *)creditDetailDictionary
{
    NSString *strInvId = [creditDetailDictionary valueForKey:@"TransactionNo"];
    NSString *strVoidAmount = [creditDetailDictionary valueForKey:@"BillAmount"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self processVoidForCurrenTransctionId:strInvId withAmount:strVoidAmount];
    });
    self.rmsDbController.isVoidTrasnaction = FALSE;
}

-(void)processVoidForCurrenTransctionId:(NSString *)currentTransctionId withAmount:(NSString *)amount
{
    NSLog(@"processVoidForCurrenTransctionId");
    NSString *extData = [NSString stringWithFormat:@"<TransactionID><Target>%@</Target></TransactionID>",currentTransctionId];
    NSString *strTranType = @"Void";
    NSString *transDetails;
    transDetails  = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=%@&InvNum=&PNRef=%@&Zip=&Street=&CVNum=&ExtData=%@",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],strTranType,amount,currentTransctionId,extData];
    NSLog(@"transDetails = %@",transDetails);
    [self processVoidTransaction:[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"URL"] details:transDetails];
}

- (void)processVoidTransaction:(NSString *)url details:(NSString *)details
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",@"ProcessCreditCard"]];
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseCreditCardVoidTransctionInvoiceResponse:response error:error];
        });
    };
    
    self.insertCardSettlementWC = [[RapidWebServiceConnection alloc] initWithAsyncRequestURL:url withDetailValues:details asyncCompletionHandler:asyncCompletionHandler];
    NSLog(@"url = %@",url);
}

-(NSString *)jsonStringForBridgePayVoidRespone:(NSString *)response
{
    NSMutableString *stringResult = [NSMutableString stringWithString:response];
    [self removeNameSpace: @" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://TPISoft.com/SmartPayments/\"" result:stringResult];
    NSString *authCode = [self bridgePayResponseValueForPath:@"/Response/AuthCode" forResponseString:stringResult];
    NSString *transaction = [self bridgePayResponseValueForPath:@"/Response/PNRef" forResponseString:stringResult];
    NSMutableDictionary *bridgePayVoidDictionary = [[NSMutableDictionary alloc] init];
    bridgePayVoidDictionary[@"AuthCode"] = authCode;
    bridgePayVoidDictionary[@"PNRef"] = transaction;
    return [self.rmsDbController jsonStringFromObject:bridgePayVoidDictionary];
}

-(NSString *)bridgePayResponseValueForPath:(NSString *)path forResponseString:(NSString *)responseString
{
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
    DDXMLNode *rootNode = [document rootElement];
    NSArray *resultNode = [rootNode nodesForXPath:path error:nil];
    DDXMLElement *pumpElement;
    if (resultNode != nil && resultNode.count > 0) {
        pumpElement = resultNode[0];
    }
    NSString *strResult = [NSString stringWithFormat:@"%@",[pumpElement stringValue]];
    return strResult;
}

-(void)responseCreditCardVoidTransctionInvoiceResponse:(id)response error:(NSError *)error
{
    [self stopActivityIndicator];
    NSLog(@"responseCreditCardVoidTransctionInvoiceResponse = %@",response);
    if (response != nil) {
        if ([response isKindOfClass:[NSString class]]) {
            NSLog(@"responseString : %@",response);
            if ([self getResultOfCreditCard:response] == 0 || [self getResultOfCreditCard:response] == 108)
            {
                [self startActivityIndicator];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self displayCCBatchUI];
                });
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [self stopActivityIndicator];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please try again later." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(NSInteger)getResultOfCreditCard:(NSString *)result
{
    NSMutableString *stringResult = [NSMutableString stringWithString:result];
    [self removeNameSpace: @" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://TPISoft.com/SmartPayments/\"" result:stringResult];
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:stringResult options:0 error:nil];
    DDXMLNode *rootNode = [document rootElement];
    NSArray *resultNode = [rootNode nodesForXPath:@"/Response/Result" error:nil];
    if (resultNode.count == 0) {
        // Pump not available
        return 0;
    }
    DDXMLElement *pumpElement = resultNode[0];
    NSString *strResult = [pumpElement stringValue];
    NSLog(@"Result=   %@",strResult);
    return strResult.integerValue ;
    
}
- (void)removeNameSpace:(NSString*)nameSpaceString result:(NSMutableString *)result {
    NSRange stringRange;
    stringRange.location = 0;
    stringRange.length = result.length;
    [result replaceOccurrencesOfString:nameSpaceString withString:@"" options:NSCaseInsensitiveSearch range:stringRange];
}

#pragma mark - Force Transaction Process

-(void)setForceTransactionProcess:(NSIndexPath*)indexpath
{
    [self startActivityIndicator];
    NSDictionary *dictionaryAtIndexpath;
    dictionaryAtIndexpath = (self.cardDetailForDeviceBatch)[indexpath.row];
    
    NSMutableDictionary *getAmountDictionary = [[NSMutableDictionary alloc]init];
    getAmountDictionary[@"InvNo"] = [dictionaryAtIndexpath valueForKey:@"RegisterInvNo"];
    getAmountDictionary[@"AuthCode"] = [dictionaryAtIndexpath valueForKey:@"AuthCode"];
    NSString *accNo = [dictionaryAtIndexpath valueForKey:@"AccNo"] ;
    NSString *cardNo = [accNo substringFromIndex:[accNo length] - 4];
    getAmountDictionary[@"CardNo"] = cardNo;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseGetCaptureAmountResponse:response withDict:dictionaryAtIndexpath error:error];
        });
    };
    self.getCaptureAmtWebServiceConnection = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_GET_CAPTURE_AMOUNT params:getAmountDictionary completionHandler:completionHandler];
    

}

- (void)responseGetCaptureAmountResponse:(id)response withDict:(NSDictionary*)dictData error:(NSError *)error
{
    [self stopActivityIndicator];
    if (response != nil) {
        if ([[response valueForKey:@"IsError"] intValue] == 0)
        {
            NSString *strCaptureAmt = [NSString stringWithFormat:@"%@" ,[response valueForKey:@"Data"]];
           
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
            };
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
                switch (paymentGateWay) {
                    case BridgePay: {
                        if ([strCaptureAmt floatValue] > 0)
                        {
                            [self processAmountAdjustBridgePay:[strCaptureAmt floatValue] withTransactionNo:dictData[@"TransactionNo"] withTransactionId:dictData[@"RegisterInvNo"] withType:@"Force"];
                        }
                        break;
                    }
                    case Pax: {
                        if ([strCaptureAmt floatValue] > 0)
                        {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self startActivityIndicator];
                                [self.cCBatchForPax paxForceTransactionProcessWithDictionary:dictData withCaptureAmt:strCaptureAmt];
                            });
                        }
                        break;
                    }
                }
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Post Auth Amount :  %@",strCaptureAmt] buttonTitles:@[@"Cancel",@"OK"] buttonHandlers:@[leftHandler,rightHandler]];
        }
        else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    }
}

-(void)processAmountAdjustBridgePay:(float)totalAmount withTransactionNo:(NSString *)transctionNo withTransactionId:(NSString *)regInvNo withType:(NSString *)type
{
    [self startActivityIndicator];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *paymentDictionary = self.rmsDbController.paymentCardTypearray.firstObject;
        NSString *transDetails = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=%.2f&InvNum=%@&PNRef=%@&Zip=&Street=&CVNum=&ExtData=",[paymentDictionary valueForKey:@"Username"],[paymentDictionary valueForKey:@"password"],type,totalAmount,regInvNo,transctionNo];
        [self processAmountAdjustment:[paymentDictionary valueForKey:@"URL"] details:transDetails withTotalAmount:totalAmount];
    });
}

- (void)processAmountAdjustment:(NSString *)url details:(NSString *)details withTotalAmount:(float)totalAmount
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",@"ProcessCreditCard"]];
    [self processTotalAmountAdjustmentWithURl:url transctionDetail:details withTipAmount:totalAmount];
}

-(void)processTotalAmountAdjustmentWithURl:(NSString *)url transctionDetail:(NSString *)transDetail withTipAmount:(float)tipAmount
{
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseTenderCreditCardTotalAmountAdjustmentResponse:response error:error];
        });
    };
    
    self.captureWebServiceConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequestURL:url withDetailValues:transDetail asyncCompletionHandler:asyncCompletionHandler];
}

-(void)responseTenderCreditCardTotalAmountAdjustmentResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        [self stopActivityIndicator];
        if (response != nil) {
            if ([response isKindOfClass:[NSString class]]) {
                DDXMLElement *RespMSGElement = [self getValueFromXmlResponse:response string:@"RespMSG"];
                if ([RespMSGElement.stringValue isEqualToString:@"Approved"])
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self displayCCBatchUI];
                    });
                }
                else
                {
                    [self stopActivityIndicator];
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:RespMSGElement.stringValue buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
        }
        else
        {
            [self stopActivityIndicator];
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Connection Dropped. Try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    });
}

- (DDXMLElement *)getValueFromXmlResponse:(NSString *)responseString string:(NSString *)string
{
    responseString = [RmsDbController removeNameSpaceFromXml:responseString rootTag:@"Response"];
    DDXMLDocument *fuelTypeDocument = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
    DDXMLNode *rootNode = fuelTypeDocument.rootElement;
    NSString *responseStr = [NSString stringWithFormat:@"/Response/%@",string];
    NSArray *FuelNodes = [rootNode nodesForXPath:responseStr error:nil];
    DDXMLElement *fuelElement = FuelNodes.firstObject;
    return fuelElement;
}


#pragma mark - Utility

- (void)stopActivityIndicatorAndShowAlertWithMessage:(NSString *)message withTitle:(NSString *)title {
    [self stopActivityIndicator];
    [self showAlertWithMessage:message withTitle:title];
}

- (void)showAlertWithMessage:(NSString *)message withTitle:(NSString *)title {
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:title message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"CCOverViewVCSegue"]) {
        self.cCOverViewVC = (CCOverViewVC*) segue.destinationViewController;
    }
    if ([segueIdentifier isEqualToString:@"CurrentTransactionVCegue"]) {
        self.currentTransactionVC = (CurrentTransactionVC*) segue.destinationViewController;
        self.currentTransactionVC.currentTransactionVCDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"DeviceSummaryVCSegue"]) {
        self.deviceSummaryVC = (DeviceSummaryVC*) segue.destinationViewController;
    }
    if ([segueIdentifier isEqualToString:@"DeviceBatchVCSegue"]) {
        self.deviceBatchVC = (DeviceBatchVC*) segue.destinationViewController;
        self.deviceBatchVC.deviceBatchVCDelegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
