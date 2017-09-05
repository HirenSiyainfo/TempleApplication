//
//  XCCbatchReportVC.m
//  RapidRMS
//
//  Created by Siya on 24/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "XCCbatchReportVC.h"
#import "RmsDbController.h"
#import "CCbatchReportCell.h"
#import "RcrController.h"
#import "CommonLabel.h"
#import "TipsVC.h"
#import "CCBatchOverViewVC.h"
#import "CCBatchFooterView.h"
#import "NSString+Methods.h"
#import "TenderPay+Dictionary.h"
#import "PaxDevice.h"
#import "PaxConstants.h"
#import "PaxResponse+Internal.h"
#import "LocalDetailReportResponse.h"
#import "ResponseHostInformation.h"
#import "PaxResponse.h"
#import "PaxDetailReportCell.h"
#import "LocalTotalReportResponse.h"
#import "BatchCloseResponse.h"
#import "BasicCCbatchReceipt.h"
#import "PaxCCBatchReceipt.h"
#import "BridgePayCCBatchReceipt.h"
#import "NSString+Methods.h"
#import "DoCreditResponse.h"
#import "PaxDevice.h"

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


typedef NS_ENUM(NSInteger, PaxLocalTotalReportDetails) {
    PaxLocalTotalReportCredit,
    PaxLocalTotalReportDebit,
    PaxLocalTotalReportEBT,
    PaxLocalTotalReportGift,
    PaxLocalTotalReportLOYALTY,
    PaxLocalTotalReportCASH,
    PaxLocalTotalReportCHECK,
};

typedef NS_ENUM(NSInteger, PaymentGateWay) {
    BridgePay,
    Pax,
};

#define LIVE_GET_BATCH_SETTLE_DATA_URL @"https://gateway.itstgate.com/admin/ws/trxdetail.asmx"
#define TEST_GET_BATCH_SETTLE_DATA_URL @"https://gatewaystage.itstgate.com/admin/ws/trxdetail.asmx"


#define LIVE_BATCH_SETTLE_DATA_URL @"https://gateway.itstgate.com/SmartPayments/transact.asmx"
#define TEST_BATCH_SETTLE_DATA_URL @"https://gatewaystage.itstgate.com/SmartPayments/transact.asmx"


@interface XCCbatchReportVC ()<CCbatchReportCellDelegate,tipsSelectionDeletage,PaxDeviceDelegate>
{
    IBOutlet UIView *datePickerView;
    NSXMLParser *revParser;
    NSMutableArray *XmlResponseArray;
    
    NSMutableDictionary *dictCardElement;
    NSMutableString *currentElement;
    
    NSString *unsettleBatchProcessUrl;
    
    NSString *processBatchSettleUrl;
    TipsVC *tipsVC;
    
    NSDictionary *selectedTipsDictionary;
    
    IBOutlet UILabel *tipAmountLabel;
    
    CGFloat adjustedTipAmount;
    IBOutlet UIView *ccBatchHeaderView;
    IBOutlet UIView *ccBatchFooterView;

    IBOutlet UIView *ccBatchTipHeaderView;
    IBOutlet UIView *ccBatchWithoutTipHeaderView;
    IBOutlet CCBatchFooterView *ccBatchTipFooterView;
    IBOutlet CCBatchFooterView *ccBatchWithOutTipFooterView;
    NSMutableArray *configureChartArray;
    

    
    
    NSMutableArray *totalCardDetailsArray;
    CCBatchOverViewVC *ccBatchOverViewVC;
    
    
    IBOutlet UIButton *overViewButton;
    IBOutlet UIButton *ccBatchButton;
    
    PaxDevice *paxReportDetailDevice;
    NSMutableArray *localReportDetailsArray;
    CGFloat reportTotalRecord;
    CGFloat currentRecordIndex;
    
    IBOutlet UITableView *paxReportDetailTableView;
    IBOutlet UIView *paxReportContainerView;
    NSArray *paxReportEnumArray;
    NSMutableArray *totalLocalReportDetailsArray;
    
    NSInteger paymentGateWay;
    IBOutlet UIButton *ccBatchSummary;
    
    NSArray *array_port;
    
    NSString *totalAmountString;
    NSInteger totalCount;
    NSString *batchNo;
    NSArray *bridgePayBatchSummryArray;

}
@property (nonatomic,strong) PaxDevice *paxDevice;


@property (nonatomic, strong) CCBatchFooterView *ccBatchFooterVC;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) NSMutableArray *totalCardDisplayArray;
@property (nonatomic, strong) NSMutableArray *totalCardArray;
@property (nonatomic, strong) NSMutableArray *cardDetail;
@property (nonatomic, strong) NSMutableArray *cardDetailDisplayList;
@property (nonatomic, strong) NSMutableArray *cardDetailList;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic ,strong) RapidWebServiceConnection *insertPaxWSC;


@property (nonatomic, weak) IBOutlet UIView *CardSettlementview;
@property (nonatomic, weak) IBOutlet UITableView *tblCardSettlement;
@property (nonatomic, weak) IBOutlet UITableView *tblCardSettlementPlain;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UILabel *lblDate;

@property (nonatomic, weak) IBOutlet UIView *cardSelectionView;
@property (nonatomic, weak) IBOutlet UIPickerView *cardSelectionPickerView;
@property (nonatomic, weak) IBOutlet UILabel *selectedCardName;
@property (nonatomic, weak) IBOutlet UIButton *cardSelectionButton;

@property (nonatomic, weak) IBOutlet UIView *viewSetting;
@property (nonatomic, weak) IBOutlet UISwitch *switchSetting;
@property (nonatomic, weak) IBOutlet UIDatePicker *settingTimePicker;

@property (nonatomic, weak) IBOutlet UIButton *btnbatchSettleBatch;
@property (nonatomic, weak) IBOutlet UIDatePicker *btnSettin;
@property (nonatomic, strong) RapidWebServiceConnection *paymentCCWebserviceConnection;

@property (nonatomic, strong) RapidWebServiceConnection *creditCardDeclineConnection;
@property (nonatomic, strong) RapidWebServiceConnection *creditcardWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *tipAdjustmentWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *batchSettlementWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *tipAdjustmentFromCCBatch;
@property (nonatomic, strong) RapidWebServiceConnection *bridgePaysattlementRapidServerConnection;
@property (nonatomic, strong) RapidWebServiceConnection *getCardSettlementDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *xCCbatchDataWC;
@property (nonatomic, strong) RapidWebServiceConnection *insertCardSettlementWC;
@property (nonatomic, strong) RapidWebServiceConnection *tipsAdjustmentWC;
@property (nonatomic, strong) RapidWebServiceConnection *captureWebServiceConnection;


@property (nonatomic, strong) NSDate *selectedDate;
@end

@implementation XCCbatchReportVC
@synthesize parseingFunCall;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)ConfigurePaymentGateWay
{
    if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Bridgepay"])
    {
        paymentGateWay = BridgePay;
        ccBatchButton.selected = YES;
        ccBatchSummary.hidden = YES;
        if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"PaymentMode"] isEqualToString:@"Test"])
        {
            unsettleBatchProcessUrl = TEST_GET_BATCH_SETTLE_DATA_URL;
            processBatchSettleUrl = TEST_BATCH_SETTLE_DATA_URL;
        }
        else
        {
            unsettleBatchProcessUrl = LIVE_GET_BATCH_SETTLE_DATA_URL;
            processBatchSettleUrl = LIVE_BATCH_SETTLE_DATA_URL;
        }
       [self getCardSettlementForBridgePay];
    }
    else if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Pax"])
    {
        paymentGateWay = Pax;
        ccBatchSummary.selected = YES;
        [self configurePaxReportDetail];
    }
}

-(void)GetCardTypeDetailForCC
{
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self responseGetCardTypeDetailForCCResponse:response error:error];
    };
    
    self.paymentCCWebserviceConnection = [self.paymentCCWebserviceConnection initWithRequest:KURL actionName:@"GetCardTypeDetail" params:itemparam completionHandler:completionHandler];
}


-(void)responseGetCardTypeDetailForCCResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.rmsDbController.paymentCardTypearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self ConfigurePaymentGateWay];
            }
        }
    }
}


- (void)viewDidLoad
{
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults]valueForKey:@"AutoSettingValue"];
    
    if([dict isKindOfClass:[NSMutableDictionary class]])
    {
        self.btnbatchSettleBatch.enabled=NO;
        NSString *dateString = [dict valueForKey:@"AutoSettingTime"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm:ss";
        NSDate *dateFromString ;//= [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:dateString];
        self.settingTimePicker.date=dateFromString;
    }
    else{
        self.btnbatchSettleBatch.enabled=YES;
    }
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    self.paymentCCWebserviceConnection = [[RapidWebServiceConnection alloc] init];
    self.creditCardDeclineConnection = [[RapidWebServiceConnection alloc] init];
    self.creditcardWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    self.tipAdjustmentWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    self.batchSettlementWebserviceConnection = [[RapidWebServiceConnection alloc]init
                                                ];
    self.tipAdjustmentFromCCBatch = [[RapidWebServiceConnection alloc] init
                                     ];
    
    self.bridgePaysattlementRapidServerConnection  = [[RapidWebServiceConnection alloc] init
                                                      ];
    self.getCardSettlementDetailWC = [[RapidWebServiceConnection alloc] init];
    self.insertCardSettlementWC = [[RapidWebServiceConnection alloc] init];
    self.tipsAdjustmentWC = [[RapidWebServiceConnection alloc] init];
    self.xCCbatchDataWC = [[RapidWebServiceConnection alloc] init];
    self.captureWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.CardSettlementview.layer.borderWidth = 0.3;
    self.CardSettlementview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewSetting.layer.borderWidth = 0.3;
    self.viewSetting.layer.borderColor = [UIColor lightGrayColor].CGColor;
    datePickerView.layer.borderWidth = 0.3;
    datePickerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.selectedDate = [NSDate date];
    [self configureDatelable:self.selectedDate];
    
    if (self.isTipsApplicable.boolValue == FALSE)
    {
        _ccBatchFooterVC = ccBatchWithOutTipFooterView;
        [ccBatchHeaderView addSubview:ccBatchWithoutTipHeaderView];
        [ccBatchFooterView addSubview:ccBatchWithOutTipFooterView];
    }
    else
    {
        _ccBatchFooterVC = ccBatchTipFooterView;
        [ccBatchHeaderView addSubview:ccBatchTipHeaderView];
        [ccBatchFooterView addSubview:ccBatchTipFooterView];
    }
    

    [self.tblCardSettlement registerNib:[UINib nibWithNibName:@"CCbatchReportCell" bundle:nil] forCellReuseIdentifier:@"CCBatchWithOutTip"];
    [self.tblCardSettlement registerNib:[UINib nibWithNibName:@"CCbatchReportCell_Tip" bundle:nil] forCellReuseIdentifier:@"CCBatchWithTip"];

    self.datePicker.hidden = YES;
    datePickerView.hidden = YES;
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    if (self.rmsDbController.paymentCardTypearray.count == 0) {
        [self GetCardTypeDetailForCC];
    }
    else
    {
        [self ConfigurePaymentGateWay];
    }
    paxReportDetailTableView.estimatedRowHeight = 90;
    paxReportDetailTableView.rowHeight = UITableViewAutomaticDimension;
    
     array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(void)configurePaxReportDetail
{
    paxReportContainerView.frame = CGRectMake(0, 114, paxReportContainerView.frame.size.width, paxReportContainerView.frame.size.height);
    [self.view addSubview:paxReportContainerView];
    [paxReportDetailTableView registerNib:[UINib nibWithNibName:@"PaxDetailReportCell" bundle:nil] forCellReuseIdentifier:@"PaxDetailReportCell"];
    paxReportEnumArray = @[@(PaxLocalTotalReportCredit),@(PaxLocalTotalReportDebit),@(PaxLocalTotalReportEBT)];
    [self localTotalReportRequest];
    
}

#define BRIDGEPAY_SERVICECALL
#ifdef BRIDGEPAY_SERVICECALL
-(void)getCardSettlementForBridgePay
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    });
    
    NSString *transctionServerForSpecOption = [self getTransctionServerForSpecOption];
    
    if([transctionServerForSpecOption isEqualToString:@"RAPID CONNECT"]){
        
        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
        dictParam[@"BranchId"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
        dictParam[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
       	dictParam[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
        NSDate* date = [NSDate date];
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 1;
        NSCalendar *theCalendar = [NSCalendar currentCalendar];
        date = [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
        NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
        dateFormatter1.dateFormat = @"yyyy-MM-dd";
        NSString *nowDate = [dateFormatter1 stringFromDate:date];
        NSString *nowdatetime=[NSString stringWithFormat:@"%@T00:00:00",nowDate];
        
        dictParam[@"SettlementEndDate"] = nowdatetime;
        [self getBridgePayTrxProcessData:dictParam];
        
    }
    else {

        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] forKey:@"GateWayType"];

        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self getCardSettlementForBridgePayResponse:response error:error];
        };
        
        self.getCardSettlementDetailWC = [self.getCardSettlementDetailWC initWithRequest:KURL actionName:@"GetCardSettlementDetail" params:param completionHandler:completionHandler];
    }

}

#else
-(void)GetCardData :(NSString*)date
{
    

    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:[self.rmsDbController.globalDict objectForKey:@"BranchID"] forKey:@"BranchId"];
    [param setValue:date forKey:@"BillDate"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self ccBatchResponse:response error:error];
    };
    
    self.xCCbatchDataWC = [self.xCCbatchDataWC initWithRequest:KURL actionName:@"CCbatchUnSettlementData" params:param completionHandler:completionHandler];
}
#endif

- (void)getCardSettlementForBridgePayResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                XmlResponseArray = [[NSMutableArray alloc] init];
                
                NSMutableArray *ccBatchDate = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                NSString *lastCcBatchDate = [ccBatchDate.firstObject valueForKey:@"SettlementDate" ];
                NSDate *passDate = [self jsonStringToNSDate:lastCcBatchDate];
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
                dateFormatter.dateFormat = @"yyyy-MM-dd";
                NSString *currentDate = [dateFormatter stringFromDate:passDate];
                lastCcBatchDate = [NSString stringWithFormat:@"%@T00:00:00",currentDate];
                // lastCcBatchDate = [NSString stringWithFormat:@"%@T00:00:00",@"2001-01-01"];
                
                
                NSDate* date = [NSDate date];
                NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                dayComponent.day = 1;
                NSCalendar *theCalendar = [NSCalendar currentCalendar];
                date = [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
                NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
                dateFormatter1.dateFormat = @"yyyy-MM-dd";
                NSString *nowDate = [dateFormatter1 stringFromDate:date];
                NSString *nowdatetime=[NSString stringWithFormat:@"%@T00:00:00",nowDate];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self getUnsettleBatchDetailwithProcess:@"GetCardTrx" withDetail:[NSString stringWithFormat:@"UserName=%@&Password=%@&RPNum=%@&BeginDt=%@&EndDt=%@&ExcludeVoid=%@&SettleFlag=%@&PNRef=&PaymentType=&ExcludePaymentType=&TransType=%@&ExcludeTransType=&ApprovalCode=&Result=%@&ExcludeResult=&NameOnCard=&CardNum=&CardType=&ExcludeCardType=&User=&invoiceId=&SettleMsg=&SettleDt=&TransformType=&Xsl=&ColDelim=&RowDelim=&IncludeHeader=&ExtData=",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"MerchantKey"],lastCcBatchDate,nowdatetime,@"false",@"0",@"'Sale','Credit','Authorization','Void','ForceCapture'",@"0"]withProcessUrl:unsettleBatchProcessUrl];

                });
            }
            else if([[response valueForKey:@"IsError"] intValue] == 1)
            {
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                formatter.timeZone = sourceTimeZone;
                formatter.dateFormat = @"yyyy-MM-ddTHH:mm:ss";
                NSDate *minusOneHr = [[NSDate date] dateByAddingTimeInterval:-3600 * 72];
                NSString* strDate = [formatter stringFromDate:minusOneHr];
                NSString *nowdatetime=[NSString stringWithFormat:@"%@T00:00:00",strDate];
                //  NSString *nowdatetime=[NSString stringWithFormat:@"%@T00:00:00",@"2001-01-01"];
                
                NSDate *date = [NSDate date];
                
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd";
                NSString *currentDate = [dateFormatter stringFromDate:date];
                
                NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
                timeFormatter.dateFormat = @"HH:mm:ss";
                NSString *currentTime = [timeFormatter stringFromDate:date];
                
                NSString *currentDatenTime = [NSString stringWithFormat:@"%@T%@",currentDate,currentTime];
                
                
                XmlResponseArray = [[NSMutableArray alloc] init];
                _CardSettlementview.hidden = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self getUnsettleBatchDetailwithProcess:@"GetCardTrx" withDetail:[NSString stringWithFormat:@"UserName=%@&Password=%@&RPNum=%@&BeginDt=%@&EndDt=%@&ExcludeVoid=%@&SettleFlag=%@&PNRef=&PaymentType=&ExcludePaymentType=&TransType=&ExcludeTransType=&ApprovalCode=&Result=&ExcludeResult=&NameOnCard=&CardNum=&CardType=&ExcludeCardType=&User=&invoiceId=&SettleMsg=&SettleDt=&TransformType=&Xsl=&ColDelim=&RowDelim=&IncludeHeader=&ExtData=",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"MerchantKey"],nowdatetime,currentDatenTime,@"true",@"0"] withProcessUrl:unsettleBatchProcessUrl];
                });
            }
            else
            {
                [_activityIndicator hideActivityIndicator];;
            }
        }
    }
    else
    {
        [_activityIndicator hideActivityIndicator];;
    }
}
- (void)getBridgePayTrxProcessData:(NSMutableDictionary *)paramValue
{
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self bridgepayGetCardTrxProcessResponse:response error:error];
        });
    };
    
    self.tipAdjustmentFromCCBatch = [self.tipAdjustmentFromCCBatch initWithRequest:KURL_PAYMENT actionName:WSM_BRIDGEPAY_GET_CARD_TRNX_PROCESS params:paramValue completionHandler:completionHandler];
}

-(void)bridgepayGetCardTrxProcessResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSString *responseString = response[@"Data"];
            
            responseString = [responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            responseString = [responseString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
            responseString = [responseString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            responseString = [RmsDbController removeNameSpaceFromXml:responseString rootTag:@"string"];
            //   responseString = [responseString stringByReplacingOccurrencesOfString:@" xmlns=\"http://www.namespaceuri.com/Admin/ws\"" withString:@""];
            NSMutableArray *responseArray = [self getValueFromBatchXmlResponse:responseString];
            if (responseArray.count>0)
            {
                responseArray = [self removeInProperValuefromCartType:responseArray];
                self.cardDetail = [[NSMutableArray alloc]init];
                totalCardDetailsArray = [responseArray mutableCopy];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TransType  ==  %@ AND TransType != %@", @"0" ,@"Void" ];
                
                NSArray *filteredArray = [totalCardDetailsArray filteredArrayUsingPredicate:predicate];
                
                self.cardDetail = [totalCardDetailsArray mutableCopy];
                [self configuerChartArray:responseArray];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"BillDate" ascending:FALSE];
                [self.cardDetail sortUsingDescriptors:@[sortDescriptor]];
                
                dispatch_async(dispatch_get_main_queue(),  ^{
                    [self.tblCardSettlement reloadData];
                    [self.cardSelectionPickerView reloadAllComponents];
                    self.selectedCardName.text = @"All";
                    
                });
                [self setupCardArrayWithCardDetail: self.cardDetail];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Record found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Connection Dropped. Try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

#pragma mark- CreditCard Settlement Process
-(void)batchSettlementProcess
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSString *transctionServerForSpecOption = [self getTransctionServerForSpecOption];
    
    if([transctionServerForSpecOption isEqualToString:@"RAPID CONNECT"]){
        
        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
        dictParam[@"BranchId"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
        dictParam[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
       	dictParam[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        dictParam[@"TransType"] = @"CaptureAll";
        dictParam[@"ExtData"] = @"<CardType>ALL</CardType>";
        [self getBridgePaySattlementProcess:dictParam];
        
    }
    else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self bridgePayBatchSettleWithDatail:@"ProcessCreditCard" withDetail:[NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=&InvNum=&PNRef=&Zip=&Street=&CVNum=&ExtData=%@",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],@"CaptureAll",@"<CardType>ALL</CardType>"]withProcessUrl:processBatchSettleUrl];
            });
    }
}

-(void)responseCreditCardSettlementResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        
        if (response != nil) {
            if ([response isKindOfClass:[NSString class]]) {
                    NSString *responseString = response;
                    responseString = [responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    responseString = [responseString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                    responseString = [responseString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                    responseString = [RmsDbController removeNameSpaceFromXml:responseString rootTag:@"Response"];
                    //    responseString = [responseString stringByReplacingOccurrencesOfString:@" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://TPISoft.com/SmartPayments/\"" withString:@""];
                    
                    NSInteger result = [self getValueFromSettleBatchResponse:responseString withTagName:@"Result"].integerValue;
                    NSString *respMSG = [self getValueFromSettleBatchResponse:responseString withTagName:@"RespMSG"];
                    
                    if ([respMSG isEqualToString:@"Approved"] )
                    {
                        NSString *authCode = [self getValueFromSettleBatchResponse:responseString withTagName:@"AuthCode"];
                        NSString *batchSummry = [self getValueFromSettleBatchResponse:responseString withTagName:@"ExtData/Batch/Summary"];
                        
                        batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"=" withString:@" : "];
                        bridgePayBatchSummryArray = [batchSummry componentsSeparatedByString:@","];

                        batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                        batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@",Result=0" withString:@""];
                        batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"=" withString:@" = "];
                        batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
                        NSLog(@"batchSummry %@",batchSummry);
                        NSString *batchInfo = [NSString stringWithFormat:@"Confirmation = %@ \n %@",authCode,batchSummry];
                        NSLog(@"batchInfo %@",batchInfo);
                        
                        NSDictionary *printccBatchReceiptDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrintCCBatchReceiptSetting"];
                        
                        if (printccBatchReceiptDictionary != nil) {
                            if([[printccBatchReceiptDictionary valueForKey:@"PrintCCBatchReceipt"] isEqual: @(1)])
                            {
                                [self bridgePayCCBatchPrintReceipt:bridgePayBatchSummryArray];
                            }
                            else
                            {
                                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                                {
                                    [self hideallDetails];
                                };
                                
                                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                                {
                                    [self bridgePayCCBatchPrintReceipt:bridgePayBatchSummryArray];
                                };
                                [self.rmsDbController popupAlertFromVC:self title:@"Batch Info" message:[NSString stringWithFormat:batchInfo,result] buttonTitles:@[@"OK",@"Print"] buttonHandlers:@[leftHandler,rightHandler]];
                            }
                        }
                        else
                        {
                            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                            {
                                [self hideallDetails];
                            };
                            
                            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                            {
                                [self bridgePayCCBatchPrintReceipt:bridgePayBatchSummryArray];
                            };
                            [self.rmsDbController popupAlertFromVC:self title:@"Batch Info" message:[NSString stringWithFormat:batchInfo,result] buttonTitles:@[@"OK",@"Print"] buttonHandlers:@[leftHandler,rightHandler]];
                            
                        }
                        [self insertCardSettlementProcessWithResponseString:response isXML:TRUE];
                    }
                    else
                    {
                        [_activityIndicator hideActivityIndicator];;
                        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                        {
                        };
                        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Code %ld(%@), Error occured while processing.",(long)result,respMSG] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    }
            }
        }
        
        else
        {
            [_activityIndicator hideActivityIndicator];;
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Failed" message:@"TGate connection error" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    });
    [self callDeclineWebservicewithErrorMessage:response];
}

- (void)getBridgePaySattlementProcess:(NSMutableDictionary *)paramValue
{
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self bridgepaySattlementProcessResponse:response error:error];
    };
    
    self.bridgePaysattlementRapidServerConnection = [self.bridgePaysattlementRapidServerConnection initWithRequest:KURL_PAYMENT actionName:WSM_BRIDGEPAY_SETTLEMENT_PROCESS params:paramValue completionHandler:completionHandler];
}

-(void)bridgepaySattlementProcessResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        if (response != nil) {
            if ([response isKindOfClass:[NSDictionary class]]) {
                [_activityIndicator hideActivityIndicator];
                NSString *responseString = response[@"Data"];
                
                responseString = [responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                responseString = [responseString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                responseString = [responseString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                responseString = [RmsDbController removeNameSpaceFromXml:responseString rootTag:@"Response"];
                
                NSInteger result = [self getValueFromSettleBatchResponse:responseString withTagName:@"Result"].integerValue;
                NSString *respMSG = [self getValueFromSettleBatchResponse:responseString withTagName:@"RespMSG"];
                
                if ([respMSG isEqualToString:@"Approved"])
                {
                    NSString *authCode = [self getValueFromSettleBatchResponse:responseString withTagName:@"AuthCode"];
                    NSString *batchSummry = [self getValueFromSettleBatchResponse:responseString withTagName:@"ExtData/Batch/Summary"];
                    batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"=" withString:@" : "];

                    bridgePayBatchSummryArray = [batchSummry componentsSeparatedByString:@","];

                    batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                    batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@",Result=0" withString:@""];
                    batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"=" withString:@" = "];
                    batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
                    NSLog(@"batchSummry %@",batchSummry);
                    NSString *batchInfo = [NSString stringWithFormat:@"Confirmation = %@ \n %@",authCode,batchSummry];
                    
                    NSLog(@"batchInfo %@",batchInfo);
                    
                    NSDictionary *printccBatchReceiptDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrintCCBatchReceiptSetting"];
                    
                    if (printccBatchReceiptDictionary != nil) {
                        if([[printccBatchReceiptDictionary valueForKey:@"PrintCCBatchReceipt"] isEqual: @(1)])
                        {
                            [self bridgePayCCBatchPrintReceipt:bridgePayBatchSummryArray];
                        }
                        else
                        {
                            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                            {
                                [self hideallDetails];
                            };
                            
                            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                            {
                                [self bridgePayCCBatchPrintReceipt:bridgePayBatchSummryArray];
                            };
                            [self.rmsDbController popupAlertFromVC:self title:@"Batch Info" message:[NSString stringWithFormat:batchInfo,result] buttonTitles:@[@"OK",@"Print"] buttonHandlers:@[leftHandler,rightHandler]];
                        }
                    }
                    else
                    {
                        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                        {
                            [self hideallDetails];
                        };
                        
                        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                        {
                            [self bridgePayCCBatchPrintReceipt:bridgePayBatchSummryArray];
                        };
                        [self.rmsDbController popupAlertFromVC:self title:@"Batch Info" message:[NSString stringWithFormat:batchInfo,result] buttonTitles:@[@"OK",@"Print"] buttonHandlers:@[leftHandler,rightHandler]];
                    }
                    
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Code %ld(%@), Error occured while processing.",(long)result,respMSG] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
        }
        else
        {
            [_activityIndicator hideActivityIndicator];;
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Failed" message:@"TGate connection error" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    });
    [self callDeclineWebservicewithErrorMessage:response];
}


-(void)bridgePayBatchSettleWithDatail:(NSString *)processName withDetail:(NSString *)detail withProcessUrl:(NSString *)Url
{
    self.parseingFunCall = @"BatchSettlementProcess";
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseCreditCardSettlementResponse:response error:error];
        });
    };
    
    self.batchSettlementWebserviceConnection = [self.batchSettlementWebserviceConnection initWithAsyncRequestURL:[NSString stringWithFormat:@"%@/%@",Url,processName] withDetailValues:detail asyncCompletionHandler:asyncCompletionHandler];
}

- (NSString *)getValueFromSettleBatchResponse:(NSString *)responseString withTagName:(NSString *)tagName
{
    NSString *valueForTag = @"";
    DDXMLDocument *fuelTypeDocument = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
    DDXMLNode *rootNode = fuelTypeDocument.rootElement;
    NSString *responseStr = [NSString stringWithFormat:@"/Response/%@",tagName];
    NSArray *FuelNodes = [rootNode nodesForXPath:responseStr error:nil];
    if (FuelNodes.count > 0)
    {
        DDXMLElement *fuelElement = FuelNodes.firstObject;
        valueForTag = fuelElement.stringValue;
    }
        return valueForTag;
}

-(void)callDeclineWebservicewithErrorMessage:(NSString *)errorMessage
{
    NSMutableDictionary *errorResponse = [[NSMutableDictionary alloc]init];
    errorResponse[@"errorMassege"] = [NSString stringWithFormat:@"%@",errorMessage];
    errorResponse[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    errorResponse[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    errorResponse[@"errorCode"] = @"2";
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    errorResponse[@"transDate"] = currentDateTime;
    
    errorResponse[@"invoiceDetail"] = @"";
    
    NSMutableDictionary *dictMain = [[NSMutableDictionary alloc]init];
    dictMain[@"objCardDeclineProcessDetail"] = errorResponse;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self callDeclineWebservicewithErrorMessageResponse:response error:error];
    };
    
    self.creditCardDeclineConnection = [self.creditCardDeclineConnection initWithRequest:KURL actionName:@"CreditCardDeclineProcess" params:dictMain completionHandler:completionHandler];
}

- (void)callDeclineWebservicewithErrorMessageResponse:(id)response error:(NSError *)error
{

}


#pragma mark - Webservice Call For CreditCardUnsettleData
-(void)getCreditCardUnsettleDataWithProcessURL:(NSString *)processURl withDetail:(NSString *)detail
{
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseCreditCardUnsettleDataResponse:response error:error];
        });
    };
    self.creditcardWebserviceConnection = [self.creditcardWebserviceConnection initWithAsyncRequestURL:processURl withDetailValues:detail asyncCompletionHandler:asyncCompletionHandler];
}


-(void)responseCreditCardUnsettleDataResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        [_activityIndicator hideActivityIndicator];;
    });
    
    if (response != nil) {
        if ([response isKindOfClass:[NSString class]]) {
            
                NSString *responseString = response;
                responseString = [responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                responseString = [responseString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                responseString = [responseString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                responseString = [RmsDbController removeNameSpaceFromXml:responseString rootTag:@"string"];
                //   responseString = [responseString stringByReplacingOccurrencesOfString:@" xmlns=\"http://www.namespaceuri.com/Admin/ws\"" withString:@""];
                NSMutableArray *responseArray = [self getValueFromBatchXmlResponse:responseString];
                
                if (responseArray.count>0)
                {
                    responseArray = [self removeInProperValuefromCartType:responseArray];
                    self.cardDetail = [[NSMutableArray alloc]init];
                    totalCardDetailsArray = [responseArray mutableCopy];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TransType  ==  %@", @"ForceCapture" ];
                    NSArray *filteredArray = [totalCardDetailsArray filteredArrayUsingPredicate:predicate];
                    NSArray *arrAuthCode = [filteredArray valueForKey:@"AuthCode"];
                    
                    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"AuthCode IN %@ AND TransType == %@", arrAuthCode , @"Authorization" ];
                    NSArray *filterArray1 = [totalCardDetailsArray filteredArrayUsingPredicate:predicate1];
                    [totalCardDetailsArray removeObjectsInArray:filterArray1];
                    
                    self.cardDetail = [totalCardDetailsArray mutableCopy];
                    [self configuerChartArray:responseArray];
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"BillDate" ascending:FALSE];
                    [self.cardDetail sortUsingDescriptors:@[sortDescriptor]];
                    
                    dispatch_async(dispatch_get_main_queue(),  ^{
                        [self.tblCardSettlement reloadData];
                        [self.cardSelectionPickerView reloadAllComponents];
                        self.selectedCardName.text = @"All";
                        
                    });
                    [self setupCardArrayWithCardDetail: self.cardDetail];
                }
                else
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Record found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
        }
    }
}

-(void)getUnsettleBatchDetailwithProcess:(NSString *)processName withDetail:(NSString *)detail withProcessUrl:(NSString *)Url
{
    self.parseingFunCall = @"ccBatch";
    [self getCreditCardUnsettleDataWithProcessURL:[NSString stringWithFormat:@"%@/%@",Url,processName] withDetail:detail];
 }

-(void)configuerChartArray:(NSMutableArray *)responseArray
{
    configureChartArray = [[NSMutableArray alloc]init];
    
    NSArray *cardArray = [responseArray valueForKey:@"CardType"];
    NSSet *cardSet = [NSSet setWithArray:cardArray];
    self.totalCardArray = [cardSet.allObjects mutableCopy];
    [self.totalCardArray insertObject:@"All" atIndex:0];

    for (NSString *card in cardSet) {
        NSMutableDictionary *cardDictionary = [[NSMutableDictionary alloc] init];
        
        NSPredicate *cardPreDicate = [NSPredicate predicateWithFormat:@"CardType = %@",card];
        NSArray *cardArray = [responseArray filteredArrayUsingPredicate:cardPreDicate];
        NSNumber *totalCardAmount = [cardArray valueForKeyPath:@"@sum.BillAmount"];
        NSNumber *totalTipAmount = [cardArray valueForKeyPath:@"@sum.TipAmount"];
        cardDictionary[@"Amount"] = totalCardAmount;
        cardDictionary[@"TipAmount"] = totalTipAmount;
        cardDictionary[@"Card"] = card;
        [configureChartArray addObject:cardDictionary];
        
    }
    
}

- (NSString *)valueforAttibute:(NSString *)attribute creditDataElement:(DDXMLElement *)creditElement
{
    NSArray *elementArray = [creditElement nodesForXPath:attribute error:nil];
    if (elementArray.count == 0) {
        return @"";
    }
    DDXMLElement *element = elementArray.firstObject;
    NSString *valueAsString = [NSString stringWithFormat:@"%@",element.stringValue];
    return valueAsString;
}

- (NSMutableArray *)getValueFromBatchXmlResponse:(NSString *)responseString
{
    NSMutableArray *totalCreditCardData = [[NSMutableArray alloc]init];
    DDXMLDocument *fuelTypeDocument = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
    DDXMLNode *rootNode = fuelTypeDocument.rootElement;
    NSString *responseStr = [NSString stringWithFormat:@"/string/RichDBDS/TrxDetailCard"];
    NSArray *FuelNodes = [rootNode nodesForXPath:responseStr error:nil];
    for (DDXMLElement *fuelElement in FuelNodes)
    {
        //NSArray *attributes = [fuelElement attributes];
        NSMutableDictionary *individualCreditCardData = [[NSMutableDictionary alloc] init];
        individualCreditCardData[@"TransactionNo"] = [self valueforAttibute:@"TRX_HD_Key" creditDataElement:fuelElement];
       individualCreditCardData[@"RegisterInvNo"] = [self valueforAttibute:@"Invoice_ID" creditDataElement:fuelElement];
      
        NSString* dateString = [self valueforAttibute:@"Date_DT" creditDataElement:fuelElement]
        ;
        NSDateFormatter* df = [[NSDateFormatter alloc]init];
        df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        df.timeZone = [NSTimeZone localTimeZone];
        NSString* str = dateString;
        NSDate* date = [df dateFromString:str];// NOTE -0700 is the only change
        if(date == nil)
        {
            df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        }
         date = [df dateFromString:str];

        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"MM-dd-yyyy HH:mm:ss";
        NSString *dateFibnal = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
        individualCreditCardData[@"BillDate"] = dateFibnal;
        individualCreditCardData[@"CardType"] = [self valueforAttibute:@"Payment_Type_ID" creditDataElement:fuelElement];
        individualCreditCardData[@"TransType"] = [[self valueforAttibute:@"Trans_Type_ID" creditDataElement:fuelElement] trimeString];
        individualCreditCardData[@"BillAmount"] = [self valueforAttibute:@"Auth_Amt_MN" creditDataElement:fuelElement];
        if ([[individualCreditCardData[@"TransType"] trimeString] isEqualToString:@"ForceCapture"])
        {
            individualCreditCardData[@"BillAmount"] = [self valueforAttibute:@"Total_Amt_MN" creditDataElement:fuelElement];
        }
        individualCreditCardData[@"AuthCode"] = [self valueforAttibute:@"Approval_Code_CH" creditDataElement:fuelElement];
        individualCreditCardData[@"AccNo"] = [self valueforAttibute:@"Acct_Num_CH" creditDataElement:fuelElement];
        individualCreditCardData[@"TipsAmount"] = [self valueforAttibute:@"Tip_Amt_MN" creditDataElement:fuelElement];
         individualCreditCardData[@"VoidSaleTrans"] = [self valueforAttibute:@"Void_Flag_CH" creditDataElement:fuelElement];

        [totalCreditCardData addObject:individualCreditCardData];
    }
    return totalCreditCardData;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.cardSelectionPickerView.hidden = YES;
    //call didSelectRow of tableView again, by passing the touch to the super class
    [super touchesBegan:touches withEvent:event];
}


-(CCBatchFooterStruct)ccbatchStructForCardDetail:(NSMutableArray *)cardDetailArray
{
    CCBatchFooterStruct ccbatchFooter;

    if (cardDetailArray != nil)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"VoidSaleTrans  ==  %@ AND TransType != %@", @"0" ,@"Void" ];
        
        NSArray *filteredArray = [self.cardDetail filteredArrayUsingPredicate:predicate];
        ccbatchFooter.totalTransction = (__bridge void *)([NSString stringWithFormat:@"%lu",(unsigned long)filteredArray.count]);
        ccbatchFooter.totalTipAmount = (__bridge void *)([self totalTipsAll]);
        ccbatchFooter.totalAvgTicket = (__bridge void *)([self averageTransactionForAll]);
        ccbatchFooter.totalTransctionAmount = (__bridge void *)([self totalTransactionForAll]);
        ccbatchFooter.totalAmount = (__bridge void *)([self totalAmount]);
    }
    return ccbatchFooter;
}

- (void)setupCardArrayWithCardDetail:(NSMutableArray *)cardDetailArray
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        CCBatchFooterStruct ccbatchFooter = [self ccbatchStructForCardDetail:cardDetailArray];
        [_ccBatchFooterVC updateCCBatchFooterViewWith:ccbatchFooter];
    });
}

-(void)ccBatchResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                //hiren
                responseArray = [self removeInProperValuefromCartType:responseArray];
                //
                self.cardDetail = [[NSMutableArray alloc]init];
                totalCardDetailsArray = [responseArray mutableCopy];
                self.cardDetail = [totalCardDetailsArray mutableCopy];
                [self configuerChartArray:responseArray];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"BillDate" ascending:FALSE];
                [self.cardDetail sortUsingDescriptors:@[sortDescriptor]];
                
                dispatch_async(dispatch_get_main_queue(),  ^{
                    [self.tblCardSettlement reloadData];
                    [self.cardSelectionPickerView reloadAllComponents];
                    self.selectedCardName.text = @"All";
                });
                [self setupCardArrayWithCardDetail: self.cardDetail];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Record found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(void)getNumberOfcards :(NSMutableArray*)responseArray
{
    self.totalCardDisplayArray = [[NSMutableArray alloc]init];
    for (int i=0; i<responseArray.count; i++)
    {
        NSString *strCardType = [responseArray[i] valueForKey:@"CardType"];
            if (![self.totalCardDisplayArray containsObject:strCardType])
            {
                [self.totalCardDisplayArray addObject:strCardType];
            }
    }
    
    [self setCardarray:responseArray];
    self.totalCardArray = [self.totalCardDisplayArray mutableCopy];
    [self.totalCardArray insertObject:@"Detail Breakdown" atIndex:0];

        dispatch_async(dispatch_get_main_queue(),  ^{
            [self.tblCardSettlement reloadData];
        });
}

-(NSMutableArray *)removeInProperValuefromCartType:(NSMutableArray *)pArray{
    
    for(int i=0;i<pArray.count;i++){
        
        NSMutableDictionary *dict = [pArray[i]mutableCopy];
        NSRange rang = [[dict valueForKey:@"CardType"] rangeOfString:@","];
        if(rang.location!=NSNotFound){
            
            NSArray  *arryExtData = [[dict valueForKey:@"CardType"] componentsSeparatedByString:@","];
            
            for (NSString *strTem in arryExtData) {
                NSRange rang = [strTem rangeOfString:@"CardType"];
                if(rang.location!=NSNotFound)
                {
                    NSArray  *arryExtData2 = [strTem componentsSeparatedByString:@"="];
                    if(arryExtData2.count>=2)
                    {
                        dict[@"CardType"] = arryExtData2[1];
                        pArray[i] = dict;
                    }
                }
            }
        }
    }
    return pArray;
}

-(void)setCardarray :(NSMutableArray*)arrayForCardDisplay
{
    self.cardDetailDisplayList = [[NSMutableArray alloc]init];
    for (int i=0; i < self.totalCardDisplayArray.count;i++)
    {
        [self setCardListAtindex:i withArrayForCardDisplay:arrayForCardDisplay];
    }
    self.cardDetailList = [self.cardDetailDisplayList mutableCopy];
}


-(void)setCardListAtindex:(int)index withArrayForCardDisplay:(NSMutableArray *)responseCardArray
{
    NSPredicate *cardType = [NSPredicate predicateWithFormat:@"CardType == %@", (self.totalCardDisplayArray)[index]];
    NSArray *cardArray = [[responseCardArray filteredArrayUsingPredicate:cardType] mutableCopy ];
    NSMutableDictionary *cardDict = [[NSMutableDictionary alloc]init];
    cardDict[(self.totalCardDisplayArray)[index]] = cardArray;
    [self.cardDetailDisplayList addObject:cardDict];
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == paxReportDetailTableView) {
        PaxLocalTotalReportDetails paxLocalTotalReportDetails = [paxReportEnumArray[section] integerValue];
        NSString *sectionName = @"";
        
        switch (paxLocalTotalReportDetails) {
            case PaxLocalTotalReportCredit:
                sectionName = @"Credit";
                break;
            case PaxLocalTotalReportDebit:
                sectionName = @"Debit";
                
                break;
            case PaxLocalTotalReportEBT:
                sectionName = @"EBT";
                
                break;
            case PaxLocalTotalReportGift:
                sectionName = @"Gift";
                
                break;
            case PaxLocalTotalReportLOYALTY:
                sectionName = @"Loyalty";
                
                break;
            case PaxLocalTotalReportCASH:
                sectionName = @"Cash";
                
                break;
            case PaxLocalTotalReportCHECK:
                sectionName = @"Check";
                
                break;
            default:
                break;
        }
        return sectionName;
    }
    return @"";
   
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == paxReportDetailTableView) {
        return paxReportEnumArray.count;
    }
    else
    {
        if([self.selectedCardName.text isEqualToString:@"All"])
        {
            return 1;
        }
        else
        {
            return 1;
        }
    }
}


//hiten

-(NSString *)averageTransactionForAll
{
//    NSMutableArray * cardCountDict = [self.cardDetail mutableCopy];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"VoidSaleTrans  ==  %@ AND TransType != %@", @"0" ,@"Void" ];
    
    NSArray *filteredArray = [self.cardDetail filteredArrayUsingPredicate:predicate];
    NSNumber *sum=[filteredArray valueForKeyPath:@"@sum.BillAmount"];
    NSString *str = [NSString stringWithFormat:@"%f",sum.floatValue];
    float averageTotal;
    if(filteredArray.count > 0)
    {
        averageTotal = str.floatValue / filteredArray.count;
    }
    else
    {
        averageTotal = 0.00;
    }
    return [NSString stringWithFormat:@"%.2f",averageTotal];
}

-(NSString *)totalTipsAll
{
   // NSMutableArray * cardCountDict = [self.cardDetail mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"VoidSaleTrans  ==  %@ AND TransType != %@", @"0" ,@"Void" ];
    
    NSArray *filteredArray = [self.cardDetail filteredArrayUsingPredicate:predicate];
    NSNumber *sum=[filteredArray valueForKeyPath:@"@sum.TipsAmount"];
    NSString *str = [NSString stringWithFormat:@"%.2f",sum.floatValue];
    return str;
}

-(NSString *)totalTransactionForAll
{
   // NSMutableArray * cardCountDict = [self.cardDetail mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"VoidSaleTrans ==  %@ AND TransType != %@", @"0" , @"Void"];
    
    NSArray *filteredArray = [self.cardDetail filteredArrayUsingPredicate:predicate];
    
    NSNumber *sum = [filteredArray valueForKeyPath:@"@sum.BillAmount"];
    NSNumber *sumTips = [filteredArray valueForKeyPath:@"@sum.TipsAmount"];

    NSString *str = [NSString stringWithFormat:@"%.2f",sum.floatValue + sumTips.floatValue ];
    return str;
}
-(NSString *)totalAmount
{
  //  NSMutableArray * cardCountDict = [self.cardDetail mutableCopy];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"VoidSaleTrans ==  %@ AND TransType != %@", @"0", @"Void"];
    
    NSArray *filteredArray = [self.cardDetail filteredArrayUsingPredicate:predicate];

    NSNumber *sum=[filteredArray valueForKeyPath:@"@sum.BillAmount"];
    NSString *str = [NSString stringWithFormat:@"%.2f",sum.floatValue];
    return str;
}
//


-(NSString *)totalTips :(NSInteger)index
{
    if([self.selectedCardName.text isEqualToString:@"Detail Breakdown"])
    {
        NSDictionary *cardTypeDictionary = (self.cardDetailDisplayList)[index];
        NSMutableArray *cardCountDict = [cardTypeDictionary valueForKey:(self.totalCardDisplayArray)[index+1]];
        NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.TipsAmount"];
        NSString *str = [NSString stringWithFormat:@"%.2f",sum.floatValue];
        return str;
    }
    
    else{
        NSMutableArray * cardCountDict = [(self.cardDetailDisplayList)[index] valueForKey:(self.totalCardDisplayArray)[index]];
        NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.TipsAmount"];
        NSString *str = [NSString stringWithFormat:@"%.2f",sum.floatValue];
        return str;
    }
    
}

-(NSString *)averageTransactionAtSection :(NSInteger)index
{
    if([self.selectedCardName.text isEqualToString:@"Detail Breakdown"])
    {
        NSDictionary *cardTypeDictionary = (self.cardDetailDisplayList)[index];
        NSMutableArray *cardCountDict = [cardTypeDictionary valueForKey:(self.totalCardDisplayArray)[index+1]];
        NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.BillAmount"];
        NSString *str = [NSString stringWithFormat:@"%f",sum.floatValue];
        float averageTotal = str.floatValue / cardCountDict.count;
        return [NSString stringWithFormat:@"%.2f",averageTotal];
    }
    
    else{
        NSMutableArray * cardCountDict = [(self.cardDetailDisplayList)[index] valueForKey:(self.totalCardDisplayArray)[index]];
        NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.BillAmount"];
        NSString *str = [NSString stringWithFormat:@"%f",sum.floatValue];
        float averageTotal = str.floatValue / cardCountDict.count;
        return [NSString stringWithFormat:@"%.2f",averageTotal];
    }
    
}

-(NSString *)totalTransactionAtSection :(NSInteger)index
{
    
    if([self.selectedCardName.text isEqualToString:@"Detail Breakdown"])
    {
        NSDictionary *cardTypeDictionary = (self.cardDetailDisplayList)[index];
        NSMutableArray *cardCountDict = [cardTypeDictionary valueForKey:(self.totalCardDisplayArray)[index+1]];
        NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.BillAmount"];
        NSString *str = [NSString stringWithFormat:@"%.2f",sum.floatValue];
        return str;
    }
    
    else{

        NSMutableArray * cardCountDict = [(self.cardDetailDisplayList)[index] valueForKey:(self.totalCardDisplayArray)[index]];
        NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.BillAmount"];
        NSString *str = [NSString stringWithFormat:@"%.2f",sum.floatValue];
        return str;
        
    }
}

-(NSInteger)numberofRowsAtSection :(NSInteger)index
{
    if([self.selectedCardName.text isEqualToString:@"Detail Breakdown"])
    {   NSDictionary *cardTypeDictionary = (self.cardDetailDisplayList)[index];
        NSMutableArray *cardCountDict = [cardTypeDictionary valueForKey:(self.totalCardDisplayArray)[index+1]];
        return cardCountDict.count;
    }
    else
    {
        NSDictionary *cardTypeDictionary = (self.cardDetailDisplayList)[index];
        NSMutableArray *cardCountDict = [cardTypeDictionary valueForKey:(self.totalCardDisplayArray)[index]];
        return cardCountDict.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == paxReportDetailTableView) {
        return 1;
    }
    else
    {
        return self.cardDetail.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView == paxReportDetailTableView)
    {
        return paxReportDetailTableView.rowHeight;
    }
    else
    {
    
        if (([[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Sale"] || [[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"SALE/REDEEM"] || [[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Authorization"]) && [[(self.cardDetail)[indexPath.row] valueForKey:@"VoidSaleTrans"] isEqualToString:@"0"]){
            return 80.0;
        }
        else
        {
            return 44.0;
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == paxReportDetailTableView) {
        return 44.0;
    }
    return 1.0;
}

-(NSString*)formatString :(NSString*)stringReplace
{
   stringReplace = [stringReplace stringByReplacingOccurrencesOfString:@"{" withString:@""];
    stringReplace = [stringReplace stringByReplacingOccurrencesOfString:@"}" withString:@""];
    stringReplace = [stringReplace stringByReplacingOccurrencesOfString:@";" withString:@""];
    return stringReplace;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == paxReportDetailTableView) {
        PaxDetailReportCell *paxDetailReportCell = (PaxDetailReportCell *)[tableView dequeueReusableCellWithIdentifier:@"PaxDetailReportCell"];
        
        NSString *saleAmount = [NSString stringWithFormat:@"%@",totalLocalReportDetailsArray[indexPath.section]];
        saleAmount = [self formatString:saleAmount];
       // saleAmount = [saleAmount applyCurrencyFormatter:saleAmount.floatValue];
        paxDetailReportCell.salesAmount.text = saleAmount;
//        paxDetailReportCell.salesCount.text = [totalLocalReportDetailsArray[indexPath.section] valueForKey:@"saleCount"];
//        
//        
//        NSString *returnAmount = [NSString stringWithFormat:@"%.2f",[[totalLocalReportDetailsArray[indexPath.section] valueForKey:@"returnAmount"] floatValue] / 100];
//        returnAmount = [returnAmount applyCurrencyFormatter:returnAmount.floatValue];
//        paxDetailReportCell.returnAmount.text = returnAmount;
//        paxDetailReportCell.returnCount.text = [totalLocalReportDetailsArray[indexPath.section] valueForKey:@"returnCount"];
        return paxDetailReportCell;
    }
    else
    {
        NSString *identiFier = @"";
        
        if (self.isTipsApplicable.boolValue == YES)
        {
            identiFier = @"CCBatchWithTip";
        }
        else
        {
            identiFier = @"CCBatchWithOutTip";
        }
        CCbatchReportCell *cell = (CCbatchReportCell *)[tableView dequeueReusableCellWithIdentifier:identiFier];
        cell.indexPathForCell = indexPath;
        cell.ccbatchReportCellDelegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        
        NSString *strDate = [self getStringFormat:[(self.cardDetail)[indexPath.row] valueForKey:@"BillDate"] fromFormat:@"MM-dd-yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy"];
        
        NSString *strTime = [self getStringFormat:[(self.cardDetail)[indexPath.row] valueForKey:@"BillDate"] fromFormat:@"MM-dd-yyyy HH:mm:ss" toFormate:@"hh:mm a"];
        
        cell.lblDate.text = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
        
        cell.accountNo.text = [(self.cardDetail)[indexPath.row] valueForKey:@"AccNo"];
        
        NSString *billAmount = [NSString stringWithFormat:@"%.2f",[[(self.cardDetail)[indexPath.row] valueForKey:@"BillAmount"] floatValue]];
        billAmount = [billAmount applyCurrencyFormatter:billAmount.floatValue];
        cell.amount.text = billAmount;
        
        cell.cardType.text = [NSString stringWithFormat:@"%@",[(self.cardDetail)[indexPath.row] valueForKey:@"CardType"]];
        
        if (self.isTipsApplicable.boolValue == YES)
        {
            cell.tipsAmount.hidden = NO;
            
            NSString *tipsAmount = [NSString stringWithFormat:@"%.2f",[[(self.cardDetail)[indexPath.row] valueForKey:@"TipsAmount"] floatValue]];
            tipsAmount = [tipsAmount applyCurrencyFormatter:tipsAmount.floatValue];
            cell.tipsAmount.text = tipsAmount;
        }
        else
        {
            cell.tipsAmount.hidden = YES;
            cell.totalTips.hidden = YES;
        }
        
        CGFloat totalAmount = [[(self.cardDetail)[indexPath.row] valueForKey:@"BillAmount"] floatValue] +
        [[(self.cardDetail)[indexPath.row] valueForKey:@"TipsAmount"] floatValue];
        
        NSString *totalAmountText = @"";
        totalAmountText = [totalAmountText applyCurrencyFormatter:totalAmount];
        cell.totalAmount.text = totalAmountText;
        cell.authCode.text = [NSString stringWithFormat:@"%@",[(self.cardDetail)[indexPath.row] valueForKey:@"AuthCode"]];
        cell.invoice.text = [NSString stringWithFormat:@"%@",[(self.cardDetail)[indexPath.row] valueForKey:@"RegisterInvNo"]];
        //        cell.lblTransType.text = [NSString stringWithFormat:@"%@",[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"]];
        [cell.buttonTransType setTitle:[NSString stringWithFormat:@"%@",[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"]] forState:UIControlStateNormal];
        
        [cell.buttonTransType setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
       
        if ([[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Authorization"] &&  [[(self.cardDetail)[indexPath.row] valueForKey:@"VoidSaleTrans"] isEqualToString:@"0"]){
            cell.forceButton.layer.cornerRadius = 3.0;
            cell.forceButton.layer.borderWidth = 0.5;
            cell.forceButton.userInteractionEnabled = YES;
            cell.forceButton.hidden = NO;
            }
        else
        {
            cell.forceButton.layer.cornerRadius = 0.0;
            cell.forceButton.layer.borderWidth = 0.0;
            cell.forceButton.userInteractionEnabled = NO;
            cell.forceButton.hidden = YES;
        }
        
        if (([[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Sale"] || [[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"SALE/REDEEM"] || [[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Authorization"]) && [[(self.cardDetail)[indexPath.row] valueForKey:@"VoidSaleTrans"] isEqualToString:@"0"]){
            cell.voidButton.hidden = NO;
            cell.voidButton.layer.cornerRadius = 3.0;
            cell.voidButton.layer.borderWidth = 0.5;
        }
        else
        {
            cell.voidButton.hidden = YES;
        }

        if (([[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Authorization"] && [[(self.cardDetail)[indexPath.row] valueForKey:@"VoidSaleTrans"] isEqualToString:@"0"]))
        {
            cell.forceButton.hidden = NO;
        }
        else
        {
            cell.forceButton.hidden = YES;
         }

        
        if ([[(self.cardDetail)[indexPath.row] valueForKey:@"VoidSaleTrans"] isEqualToString:@"1"] ) {
            [cell.buttonTransType setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        return cell;
        
    }
    
}

-(void)didSelectTransactionAtIndexPath :(NSIndexPath *)indexpath
{
    
    NSDictionary *dictionaryAtIndexpath;
    if([self.selectedCardName.text isEqualToString:@"All"])
    {
        dictionaryAtIndexpath = (self.cardDetail)[indexpath.row];
    }
    else if([self.selectedCardName.text isEqualToString:@"Detail Breakdown"])
    {
        NSMutableArray * cardCountArray = [(self.cardDetailDisplayList)[indexpath.section] valueForKey:(self.totalCardDisplayArray)[indexpath.section+1]];
        dictionaryAtIndexpath = cardCountArray[indexpath.row];

    }
    else
    {
        NSMutableArray * cardCountArray = [(self.cardDetailDisplayList)[indexpath.section] valueForKey:(self.totalCardDisplayArray)[indexpath.section]];
        dictionaryAtIndexpath = cardCountArray[indexpath.row];
    }
    [self selectTipsWithDict:dictionaryAtIndexpath];
}

-(NSString *)getStringFormat:(NSString *)pstrDate fromFormat:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
}


-(IBAction)dateChanged:(id)sender
{
    self.selectedDate = self.datePicker.date;
}

-(IBAction)datePickerDone:(id)sender
{
    [self.rmsDbController playButtonSound];
    //NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //NSString *currentDate = [dateFormatter stringFromDate:self.selectedDate];
    // [self configureDatelable:self.selectedDate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     /*   NSDate *date = [NSDate date];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDate = [dateFormatter stringFromDate:date];*/
        [self getCardSettlementForBridgePay];
        //[self GetCardData:currentDate];
    });
    self.datePicker.hidden = YES;
    datePickerView.hidden = YES;
}

-(IBAction)datePickerCancel:(id)sender
{
    [self.rmsDbController playButtonSound];
    self.datePicker.hidden = YES;
    datePickerView.hidden = YES;
}

-(IBAction)showDatePicker:(id)sender
{
    [self.rmsDbController playButtonSound];
    self.datePicker.hidden = NO;
    datePickerView.hidden = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cardSelectionPickerView.hidden = YES;
}

-(void)configureDatelable :(NSDate*)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.dateFormat = @"MMMM dd, yyyy";
    NSString *lableDate = [dateFormatter stringFromDate:date];
    self.lblDate.text = lableDate;
}

#pragma mark - Card Selection

-(IBAction)cardTypeSelectionClicked:(id)sender
{
    [self.cardSelectionPickerView setHidden:NO];
}

#pragma mark - UIPickerView Delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        tView.font = [UIFont fontWithName:@"Helvetica" size:14.00];
        tView.textAlignment = NSTextAlignmentCenter;
    }
    
    tView.text = (self.totalCardArray)[row];

  /*  if(row == 0)
    {
        tView.text = @"All";
    }
    else
    {
        tView.text = [self.totalCardArray objectAtIndex:row];
    }*/
    return tView;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.totalCardArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    NSString *title = (self.totalCardArray)[row];
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *selectedCardType = (self.totalCardArray)[row];
    NSPredicate *cardPredicate;
    if([selectedCardType isEqualToString:@"All"])
    {
    
    }
    else
    {
        cardPredicate = [NSPredicate predicateWithFormat:@"CardType = %@",selectedCardType];
    }
    
    
    if (cardPredicate) {
        NSArray *creditCardDetail = [totalCardDetailsArray filteredArrayUsingPredicate:cardPredicate];
        self.cardDetail = [creditCardDetail mutableCopy];
    }
    else
    {
        self.cardDetail = [totalCardDetailsArray mutableCopy];
    }
    [self setupCardArrayWithCardDetail: self.cardDetail];
    [self.tblCardSettlement reloadData];
    self.selectedCardName.text = selectedCardType;
     self.cardSelectionPickerView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)xCartSattlement:(id)sender
{
    XCCbatchReportVC * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Bridgepay"])
        {
            [myWeakReference batchSettlementProcess];
        }
        else
        {
            [myWeakReference paxBatchClose:nil];

        }
    };
    
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to do batch sattlement?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)insertCardSettlementProcessWithResponseString:(NSString *)responseString isXML:(BOOL)isXMLResponse
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:@"" forKey:@"BatchNo"];
    NSDate* date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *currentDate = [dateFormatter stringFromDate:date];
    
    [param setValue:currentDate forKey:@"SettlementDate"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    param[@"UserId"] = userID;
    param[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    
    param[@"GatewayType"] = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
    param[@"IsManual"] = @"1";
    param[@"Responsemsg"] = responseString;
    param[@"BatchSettlementAmount"] = @"0";
    param[@"IsXMLResponse"] = @(isXMLResponse);

    

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseInsertCardSettlementResponse:response error:error];
        });
    };
    
    self.insertCardSettlementWC = [self.insertCardSettlementWC initWithRequest:KURL actionName:@"InsertCardSettlementJson" params:param completionHandler:completionHandler];
}

- (void)responseInsertCardSettlementResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Batch sattlement sucess" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
                [self hideallDetails];
            }
            else{
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Batch sattlement failed" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(void)hideallDetails{
    
    [self.cardSelectionView setHidden:YES];
    [self.cardDetailDisplayList removeAllObjects];
    [self.totalCardDisplayArray removeAllObjects];

    [self.cardDetail removeAllObjects];
   // [self getCardSettlementForBridgePay];
    [self.tblCardSettlement reloadData];
}

-(IBAction)settingCancelClick:(id)sender{
    
    [self.viewSetting setHidden:YES];
}

-(IBAction)audoSttingOnOff:(id)sender{
    
    if(self.switchSetting.on){
        
        self.btnbatchSettleBatch.enabled=NO;
        self.settingTimePicker.hidden=NO;
        NSMutableDictionary *dict  =[[NSMutableDictionary alloc]init];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"HH:mm:ss";
        NSString *timeFromString = [formatter stringFromDate:self.settingTimePicker.date];
        dict[@"AutoSetting"] = @"1";
        dict[@"AutoSettingTime"] = timeFromString;
        
        [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"AutoSettingValue"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
    else{
         self.btnbatchSettleBatch.enabled=YES;
        self.settingTimePicker.hidden=YES;
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"AutoSettingValue"];
        [[NSUserDefaults standardUserDefaults]synchronize];

    }
}
-(IBAction)settingButtonClick:(id)sender{
    
    [self.viewSetting setHidden:NO];
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults]valueForKey:@"AutoSettingValue"];
    
    if([dict isKindOfClass:[NSMutableDictionary class]])
    {
        self.btnbatchSettleBatch.enabled=NO;
        self.switchSetting.on=YES;
        self.settingTimePicker.hidden=NO;
        
        NSString *dateString = [dict valueForKey:@"AutoSettingTime"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm:ss";
        NSDate *dateFromString; // = [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:dateString];
        self.settingTimePicker.date=dateFromString;
        
    }
    else{
        self.btnbatchSettleBatch.enabled=YES;
        self.switchSetting.on=NO;
        self.settingTimePicker.hidden=YES;
    }
    
   /* NSMutableDictionary *dict  =[[NSMutableDictionary alloc]init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *timeFromString = [formatter stringFromDate:self.settingTimePicker.date];
    [dict setObject:@"1" forKey:@"AutoSetting"];
    [dict setObject:timeFromString forKey:@"AutoSettingTime"];
    
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"AutoSettingValue"];
    [[NSUserDefaults standardUserDefaults]synchronize];*/
}

-(IBAction)settingDoneButtonClick:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *timeFromString = [formatter stringFromDate:self.settingTimePicker.date];
    
    NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults]valueForKey:@"AutoSettingValue"]mutableCopy];
    
    if([dict isKindOfClass:[NSMutableDictionary class]]){
        dict[@"AutoSetting"] = @"1";
        dict[@"AutoSettingTime"] = timeFromString;
        
        [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"AutoSettingValue"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }

    self.viewSetting.hidden=YES;
    
}

-(IBAction)timeValueOfTimePicker:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *timeFromString = [formatter stringFromDate:self.settingTimePicker.date];
    
    NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults]valueForKey:@"AutoSettingValue"]mutableCopy];

    dict[@"AutoSetting"] = @"1";
    dict[@"AutoSettingTime"] = timeFromString;
    
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"AutoSettingValue"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(IBAction)cancelXccBatchReport:(id)sender
{
    [self.xCCbatchReportDelegate cancelCCBatchReport];
}
-(NSDate*)jsonStringToNSDate :(NSString* ) string
{
    // Extract the numeric part of the date.  Dates should be in the format
    // "/Date(x)/", where x is a number.  This format is supplied automatically
    // by JSON serialisers in .NET.
    NSRange range = NSMakeRange(6, string.length - 8);
    NSString* substring = [string substringWithRange:range];
    
    // Have to use a number formatter to extract the value from the string into
    // a long long as the longLongValue method of the string doesn't seem to
    // return anything useful - it is always grossly incorrect.
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    NSNumber* milliseconds = [formatter numberFromString:substring];
    // NSTimeInterval is specified in seconds.  The value we get back from the
    // web service is specified in milliseconds.  Both values are since 1st Jan
    // 1970 (epoch).
    NSTimeInterval seconds = milliseconds.longLongValue / 1000;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *textfieldSearch = textField.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterInvNo == %@",textfieldSearch];
    NSMutableArray *filterArray = [[totalCardDetailsArray filteredArrayUsingPredicate:predicate] mutableCopy];
    self.cardDetail = [filterArray mutableCopy];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"BillDate" ascending:FALSE];
    [self.cardDetail sortUsingDescriptors:@[sortDescriptor]];
    self.selectedCardName.text = @"";
    
    [self.tblCardSettlement reloadData];
   // [self getNumberOfcards:filterArray];
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.selectedCardName.text = @"All";
    self.cardDetail = [totalCardDetailsArray mutableCopy];
    [self setupCardArrayWithCardDetail: self.cardDetail];
    [self.tblCardSettlement reloadData];
   // [self getNumberOfcards:self.cardDetail];
    return YES;
}


-(void)selectTipsWithDict :(NSDictionary *)tipsDictionary
{
    selectedTipsDictionary = tipsDictionary;
    NSString *identiFier = @"TipsView";
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    tipsVC = [storyBoard instantiateViewControllerWithIdentifier:identiFier];
    tipsVC.billAmountForTipCalculation = [[tipsDictionary valueForKey:@"BillAmount"] floatValue];
    // resign previous popover
    tipsVC.tipsSelectionDeletage = self;
    tipsVC.tipAmount = [[tipsDictionary valueForKey:@"TipsAmount"] floatValue];
    tipsVC.view.frame = self.view.superview.bounds;
    [self.view.superview addSubview: tipsVC.view];
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


-(NSString *)getTransctionServerForSpecOption{
    
    TenderPay *tenderPay = [self getPaymentDetailForEntity:@"TenderPay" withThePredicate:[NSPredicate predicateWithFormat:@"cardIntType == %@",@"Credit"]];
    
    NSString *transctionServerForSpecOption = [NSString stringWithFormat:@"%@",[self transctionServerForSpecOptionforPaymentId:tenderPay.payId.integerValue]];
    
    return transctionServerForSpecOption;
    
}
-(NSString *)transctionServerForSpecOptionforPaymentId:(NSInteger)paymentId
{
    NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig" ];
    if(arrTemp.count > 0)
    {
        self.crmController.globalArrTenderConfig = [arrTemp mutableCopy];
    }
    
    NSString *applicableTransctionServer = @"";
    for(int i = 0;i<self.crmController.globalArrTenderConfig.count;i++)
    {
        int itender=[[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"PayId" ] intValue ];
        if(paymentId==itender)
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

-(void)didSelectTip:(CGFloat)tipAmount
{
    
    [tipsVC.view removeFromSuperview];
    
    NSString *transctionServerForSpecOption = [self getTransctionServerForSpecOption];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    if([transctionServerForSpecOption isEqualToString:@"RAPID CONNECT"]){
        
        NSString *extData = [NSString stringWithFormat:@"<TipAmt>%.2f</TipAmt>",tipAmount];
        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
        dictParam[@"TransType"] = @"Adjustment";
        dictParam[@"Amount"] = @"";
        dictParam[@"InvNum"] = @"";
        dictParam[@"MagData"] = @"";
        dictParam[@"BranchId"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
        dictParam[@"ExtData"] = extData;
        dictParam[@"TransactionId"] = [selectedTipsDictionary valueForKey:@"TransactionNo"];
        dictParam[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
        dictParam[@"CardNo"] = @"";
        [self tipAdjustFromCCBatch:dictParam];
        
    }
    else{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSDictionary *paymentDictionary = self.rmsDbController.paymentCardTypearray.firstObject;
            NSString *extData = [NSString stringWithFormat:@"<TipAmt>%.2f</TipAmt>",tipAmount];
            NSString *transDetails = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=&InvNum=&PNRef=%@&Zip=&Street=&CVNum=&ExtData=%@",[paymentDictionary valueForKey:@"Username"],[paymentDictionary valueForKey:@"password"],@"Adjustment",[selectedTipsDictionary valueForKey:@"TransactionNo"],extData];
            [self processTipAdjustment:[paymentDictionary valueForKey:@"URL"] details:transDetails withTipAmount:tipAmount];
        });
        
    }

}
- (void)tipAdjustFromCCBatch:(NSMutableDictionary *)paramValue
{
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self tipAdjustmentFromCCBatchResponse:response error:error];
    };
    
    self.tipAdjustmentFromCCBatch = [self.tipAdjustmentFromCCBatch initWithAsyncRequest:KURL_PAYMENT actionName:WSM_RAPID_SERVER_TIP_ADJUSTMENT_PROCESS params:paramValue asyncCompletionHandler:asyncCompletionHandler];
}

// Tip Adjustment After Tender (From Rapid Server Response)

-(void)tipAdjustmentFromCCBatchResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        if (response != nil) {
            if ([response isKindOfClass:[NSDictionary class]]) {
                [_activityIndicator hideActivityIndicator];;
                NSMutableDictionary *dictResponse = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if ([dictResponse[@"RespMSG"]isEqualToString:@"Approved"])
                {
                    [self adjustTipInLocalDataBasewithTipAmount:adjustedTipAmount];
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];;
                    NSString *message = dictResponse[@"RespMSG"];
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
        }
        else
        {
            [_activityIndicator hideActivityIndicator];;
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Connection Dropped. Try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    });
}


-(void)didCancelTip
{
    [tipsVC.view removeFromSuperview];
    selectedTipsDictionary = nil;
}

-(void)didRemoveTip
{
    [tipsVC.view removeFromSuperview];
    selectedTipsDictionary = nil;

}



- (DDXMLElement *)getValueFromXmlResponse:(NSString *)responseString string:(NSString *)string
{
    /*if ([[[self.rmsDbController.paymentCardTypearray firstObject]valueForKey:@"PaymentMode"] isEqualToString:@"Test"])
    {
        responseString = [responseString stringByReplacingOccurrencesOfString:@" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://TPISoft.com/SmartPayments/\"" withString:@""];
    }
    else
    {
        responseString = [responseString stringByReplacingOccurrencesOfString:@" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://TPISoft.com/SmartPayments/\"" withString:@""];
    }*/
    
    responseString = [RmsDbController removeNameSpaceFromXml:responseString rootTag:@"Response"];
    DDXMLDocument *fuelTypeDocument = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
    DDXMLNode *rootNode = fuelTypeDocument.rootElement;
    NSString *responseStr = [NSString stringWithFormat:@"/Response/%@",string];
    NSArray *FuelNodes = [rootNode nodesForXPath:responseStr error:nil];
    DDXMLElement *fuelElement = FuelNodes.firstObject;
    return fuelElement;
}

-(void)responseCreditCardTipAdjustmentResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        if (response != nil) {
            if ([response isKindOfClass:[NSString class]]) {
                
                NSLog(@"Tips Respone = %@",response);
                
                NSString *responseString = response;
                DDXMLElement *RespMSGElement = [self getValueFromXmlResponse:responseString string:@"RespMSG"];
                if ([RespMSGElement.stringValue isEqualToString:@"Approved"])
                {
                    [self adjustTipInLocalDataBasewithTipAmount:adjustedTipAmount];
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];
                    
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:RespMSGElement.stringValue buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
        }
        else
        {
        }
    });
}

-(void)processTipAdjustmentWithURl:(NSString *)url transctionDetail:(NSString *)transDetail withTipAmount:(float)tipAmount
{
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseCreditCardTipAdjustmentResponse:response error:error];
        });
    };
    
    self.tipAdjustmentWebserviceConnection = [self.tipAdjustmentWebserviceConnection initWithAsyncRequestURL:url withDetailValues:transDetail asyncCompletionHandler:asyncCompletionHandler];
    
}

- (void)processTipAdjustment:(NSString *)url details:(NSString *)details withTipAmount:(float)tipAmount
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",@"ProcessCreditCard"]];
    adjustedTipAmount = tipAmount;
    [self processTipAdjustmentWithURl:url transctionDetail:details withTipAmount:tipAmount];
}

-(void)adjustTipInLocalDataBasewithTipAmount :(float)tipAmont
{
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:[selectedTipsDictionary valueForKey:@"RegisterInvNo"] forKey:@"RegInvoiceNo"];
    [itemparam setValue:[selectedTipsDictionary valueForKey:@"TransactionNo"] forKey:@"TransactionNo"];
    [itemparam setValue:@"-" forKey:@"AuthCode"];
    [itemparam setValue:[selectedTipsDictionary valueForKey:@"CardType"] forKey:@"CardType"];
    [itemparam setValue:[NSString stringWithFormat:@"%.2f",tipAmont] forKey:@"TipAmount"];
    [itemparam setValue:[selectedTipsDictionary valueForKey:@"AccNo"] forKey:@"AccNo"];
    [itemparam setValue:@"0" forKey:@"PayId"];
    itemparam[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    itemparam[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    itemparam[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    itemparam[@"BillDate"] = currentDateTime;
    NSLog(@"CCTipsAdjustment = %@",itemparam);
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseTipsAdjustmentResponse:response error:error];
        });
    };
    
    self.tipsAdjustmentWC = [self.tipsAdjustmentWC initWithRequest:KURL actionName:@"CCTipsAdjustment" params:itemparam completionHandler:completionHandler];
}

-(void)responseTipsAdjustmentResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Tip Adjusted SuccessFully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                [self getCardSettlementForBridgePay];
            }
            else
            {
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                NSString *strError = [NSString stringWithFormat:@"Error occured while applying tip.\n Error code = %@ Message = %@ \nPlease try again.",[response valueForKey:@"IsError"],[response valueForKey:@"Data"]];
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:strError buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    else
    {
        [_activityIndicator hideActivityIndicator];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error occured while applying tip. Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(IBAction)graphButton:(id)sender
{
    ccBatchButton.selected = NO;
    overViewButton.selected = YES;
    ccBatchSummary.selected = NO;
    paxReportContainerView.hidden = YES;
    
    
    if (ccBatchOverViewVC == nil) {
        ccBatchOverViewVC = [[CCBatchOverViewVC alloc] initWithNibName:@"CCBatchOverViewVC" bundle:nil];
    }
    ccBatchOverViewVC.view.frame = CGRectMake(0, 108, ccBatchOverViewVC.view.frame.size.width, ccBatchOverViewVC.view.frame.size.height);
    ccBatchOverViewVC.ccBatchFooterStruct = [self ccbatchStructForCardDetail:totalCardDetailsArray];
    ccBatchOverViewVC.creditCardDetail = configureChartArray;
    [self.view addSubview:ccBatchOverViewVC.view];
}

-(IBAction)ccBatchButton:(id)sender
{
    ccBatchButton.selected = YES;
    overViewButton.selected = NO;
    ccBatchSummary.selected = NO;
    paxReportContainerView.hidden = YES;

    if (paymentGateWay == Pax) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        localReportDetailsArray = [[NSMutableArray alloc] init];
        [self localDetailReportRequest];
    }
    if (ccBatchOverViewVC) {
        [ccBatchOverViewVC.view removeFromSuperview];
        ccBatchOverViewVC = nil;
    }
}
-(void)configurePaxDevice
{
    NSDictionary *dictDevice = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceConfig"];
    if (dictDevice != nil)
    {
        localReportDetailsArray = [[NSMutableArray alloc] init];
        NSString *paxDeviceIP = dictDevice [@"PaxDeviceIp"];
        NSString *paxDevicePort = dictDevice [@"PaxDevicePort"];
        paxReportDetailDevice = [[PaxDevice alloc] initWithIp:paxDeviceIP port:paxDevicePort];
        paxReportDetailDevice.paxDeviceDelegate = self;
    }
}

-(void)localTotalReportRequest
{
    if (paxReportDetailDevice == nil) {
        [self configurePaxDevice];
    }

    ccBatchSummary.selected = YES;
    ccBatchButton.selected = NO;
    overViewButton.selected = NO;
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [paxReportDetailDevice localTotalReport];
}

- (void)localDetailReportRequest
{
    currentRecordIndex = 0;
    localReportDetailsArray = [[NSMutableArray alloc] init];
    if (paxReportDetailDevice == nil) {
        [self configurePaxDevice];
    }
    
    [paxReportDetailDevice getLocalDetailReportForRecordNumber:currentRecordIndex ];
}

- (void)paxDevice:(PaxDevice*)paxDevice willSendRequest:(NSString*)request
{

}
- (void)paxDevice:(PaxDevice*)paxDevice response:(PaxResponse*)response
{
    
    if ([response isKindOfClass:[LocalTotalReportResponse class]]) {
        LocalTotalReportResponse *localTotalResponse = (LocalTotalReportResponse *)response;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_activityIndicator hideActivityIndicator];
            totalLocalReportDetailsArray = [[NSMutableArray alloc] init];
            totalLocalReportDetailsArray = localTotalResponse.totalLocalReportDetailArray;
            [paxReportDetailTableView reloadData];
        });
    }
    else if ([response isKindOfClass:[BatchCloseResponse class]])
    {
        BatchCloseResponse *batchCloseResponse = (BatchCloseResponse *)response;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (batchCloseResponse.responseCode.integerValue == 0) {
                
                NSLog(@"totalCountDetail = %@",batchCloseResponse.totalCountDetail);
                NSLog(@"totalAmountDetail = %@",batchCloseResponse.totalAmountDetail);
                ResponseHostInformation *responseHostInformation = (ResponseHostInformation *)batchCloseResponse.hostInformation;
                
                batchNo = responseHostInformation.batchNumber;
    
                [_activityIndicator hideActivityIndicator];
                
                CGFloat totalAmount = batchCloseResponse.totalCreditAmount + batchCloseResponse.totalDebitAmount + batchCloseResponse.totalEBTAmount;
                
                totalAmountString = [[NSString stringWithFormat:@"%f",totalAmount] applyCurrencyFormatter:totalAmount];
                
                totalCount = batchCloseResponse.totalCreditCount + batchCloseResponse.totalDebitCount + batchCloseResponse.totalEBTCount;
                
                NSString *batchMessage = [NSString stringWithFormat:@"TotalCount = %ld \n  TotalAmount = %@",(long)totalCount,totalAmountString];
                
                NSDate * date = [NSDate date];
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"MM/dd/yyyy";
                NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
                timeFormatter.dateFormat = @"hh:mm a";
                NSString *printDate = [dateFormatter stringFromDate:date];
                NSString *printTime = [timeFormatter stringFromDate:date];
                
                NSMutableDictionary *batchDictionary = [[NSMutableDictionary alloc]init];
                [batchDictionary setObject:[NSString stringWithFormat:@"%ld",(long)totalCount] forKey:@"TotalCount"];
                [batchDictionary setObject:[NSString stringWithFormat:@"%@",totalAmountString] forKey:@"TotalAmount"];
                [batchDictionary setObject:[NSString stringWithFormat:@"%@",batchNo] forKey:@"BatchNo"];
                [batchDictionary setObject:[NSString stringWithFormat:@"%@",printDate] forKey:@"PrintDate"];
                [batchDictionary setObject:[NSString stringWithFormat:@"%@",printTime] forKey:@"PrintTime"];

                NSString *batchJsonString = [self.rmsDbController jsonStringFromObject:batchDictionary];

                [self insertCardSettlementProcessWithResponseString:batchJsonString isXML:FALSE];
                
                NSDictionary *printccBatchReceiptDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrintCCBatchReceiptSetting"];
                
                if (printccBatchReceiptDictionary != nil) {
                    if([[printccBatchReceiptDictionary valueForKey:@"PrintCCBatchReceipt"] isEqual: @(1)])
                    {
                        [self paxCCBatchPrintReceipt:totalCount TotalAmount:totalAmountString CCBatchNo:batchNo];
                    }
                    else
                    {
                        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                        {
                            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                            [paxReportDetailDevice localTotalReport];
                        };
                        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                        {
                            [self paxCCBatchPrintReceipt:totalCount TotalAmount:totalAmountString CCBatchNo:batchNo];
                        };
                        [self.rmsDbController popupAlertFromVC:self title:@"Batch close successfully" message:batchMessage buttonTitles:@[@"OK",@"Print"] buttonHandlers:@[leftHandler,rightHandler]];
                    }
                }
                else
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                        [paxReportDetailDevice localTotalReport];
                    };
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        [self paxCCBatchPrintReceipt:totalCount TotalAmount:totalAmountString CCBatchNo:batchNo];
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Batch close successfully" message:batchMessage buttonTitles:@[@"OK",@"Print"] buttonHandlers:@[leftHandler,rightHandler]];
                }
                
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                NSString *strError = [NSString stringWithFormat:@"%@" ,response.responseMessage];
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:strError buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        });
    }
    
    else if ([response isKindOfClass:[LocalDetailReportResponse class]])
    {
        LocalDetailReportResponse *localTotalResponse = (LocalDetailReportResponse *)response;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ResponseHostInformation *responseHostInformation = (ResponseHostInformation *)localTotalResponse.hostInformation;
            
            NSString* dateString = localTotalResponse.timeStamp;
            NSDateFormatter* df = [[NSDateFormatter alloc]init];
            df.dateFormat = @"yyyyMMddHHmmss";
            df.timeZone = [NSTimeZone localTimeZone];
            NSString* str = dateString;
            NSDate* date = [df dateFromString:str];// NOTE -0700 is the only change
            // date = [df dateFromString:str];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"MM-dd-yyyy HH:mm:ss";
            NSString *dateFibnal = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
            
            reportTotalRecord = localTotalResponse.totalrecord.integerValue;
            
            NSMutableDictionary *reportDictionary = [[NSMutableDictionary alloc] init];
            if (localTotalResponse.referenceNumber.length >= 7) {
                reportDictionary[@"RegisterInvNo"] = [localTotalResponse.referenceNumber substringToIndex:localTotalResponse.referenceNumber.length - 6];
            }
            else
            {
                reportDictionary[@"RegisterInvNo"] = localTotalResponse.referenceNumber;
            }
            reportDictionary[@"AccNo"] = localTotalResponse.accountNumber;
            reportDictionary[@"CardType"] = [self cardTypeOf:localTotalResponse.cardType.integerValue];
            
            CGFloat approvedAmount = localTotalResponse.approvedAmount.floatValue/100;
            if (localTotalResponse.transactionType.integerValue == EdcTransactionTypeReturn) {
                approvedAmount = -approvedAmount;
            }
            
            reportDictionary[@"BillAmount"] = [NSString stringWithFormat:@"%f",approvedAmount];
            reportDictionary[@"BillDate"] = dateFibnal;
            reportDictionary[@"AuthCode"] = responseHostInformation.authCode;
          //  reportDictionary[@"TransType"] = [self getTransationType:localTotalResponse.transactionType.integerValue];
            reportDictionary[@"TipsAmount"] = @"0.00";
            reportDictionary[@"TransactionNo"] = localTotalResponse.transactionNumber;
       /*     if ([reportDictionary[@"TransType"] isEqualToString: @"Void"] &&[[self getTransationType:localTotalResponse.orignalTransactionType.integerValue] isEqualToString: @"SALE/REDEEM" ]) {
                reportDictionary[@"VoidSaleTrans"] = @"1";
            }
            else
            {
                reportDictionary[@"VoidSaleTrans"] = @"0";
            }*/
            
            reportDictionary[@"VoidSaleTrans"] = @"0";

            
            [localReportDetailsArray addObject:reportDictionary];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                currentRecordIndex++;
                CGFloat intPercentage = currentRecordIndex / reportTotalRecord ;
                [_activityIndicator updateProgressStatus:intPercentage];
                [self fetchNextRecord];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                reportDictionary[@"TimeStamp"] = [NSString stringWithFormat:@"%@",localTotalResponse.timeStamp];
                NSMutableDictionary *paxDataDictionary = [[NSMutableDictionary alloc] init];
                NSError * err;
                NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:reportDictionary options:0 error:&err];
                NSString * myString = [[NSString alloc] initWithData:jsonData  encoding:NSUTF8StringEncoding];
                paxDataDictionary[@"PaxData"] = myString;
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                };
                
                self.insertPaxWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_INSERT_PAX params:paxDataDictionary completionHandler:completionHandler];
            });
        });
    }
    
    else if ([response isKindOfClass:[DoCreditResponse class]])
    {
        [self localDetailReportRequest];
    }
}

-(void)paxCCBatchPrintReceipt:(NSInteger)totalTrxCount TotalAmount:(NSString *)totalTrxAmountString CCBatchNo:(NSString *)trxCCBatchNo
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    PaxCCBatchReceipt *paxCCBatchReceipt = [[PaxCCBatchReceipt alloc] initWithPortName:portName portSetting:portSettings withTotalCount:totalTrxCount withTotalAmount:totalTrxAmountString withBatchNo:trxCCBatchNo batchDictionary:nil];
    
    [paxCCBatchReceipt printccBatchReceiptWithDelegate:self];
}


-(void)bridgePayCCBatchPrintReceipt:(NSArray *)ccBatchPrintReceiptArray
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    BridgePayCCBatchReceipt *bridgePayCCBatchReceipt = [[BridgePayCCBatchReceipt alloc] initWithPortName:portName portSetting:portSettings withBridgePayCCBatchData:ccBatchPrintReceiptArray];
    
    [bridgePayCCBatchReceipt printccBatchReceiptWithDelegate:self];
}


+ (void)setPortName:(NSString *)m_portName
{
    [RcrController setPortName:m_portName];
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    [RcrController setPortSettings:m_portSettings];
}
- (void)SetPortInfo
{
    NSString *localPortName;
    
    NSString *Str = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"];
    
    if(Str.length > 0)
    {
        if ([Str isEqualToString:@"Bluetooth"])
        {
            localPortName=@"BT:Star Micronics";
        }
        else if([Str isEqualToString:@"TCP"]){
            
            NSString *tcp = [[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"];
            localPortName=tcp;
        }
    }
    else{
        localPortName=@"BT:Star Micronics";
    }
    
    [XCCbatchReportVC setPortName:localPortName];
    [XCCbatchReportVC setPortSettings:array_port[0]];
}

-(void)printerTaskDidSuccessWithDevice:(NSString *)device
{
    
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        
        if ([[(self.rmsDbController.paymentCardTypearray).firstObject valueForKey:@"Gateway"] isEqualToString:@"Bridgepay"])
        {
            [self bridgePayCCBatchPrintReceipt:bridgePayBatchSummryArray];
        }
        else if ([[(self.rmsDbController.paymentCardTypearray).firstObject valueForKey:@"Gateway"] isEqualToString:@"Pax"])
        {
            [self paxCCBatchPrintReceipt:totalCount TotalAmount:totalAmountString CCBatchNo:batchNo];
        }
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Failed to Batch print receipt. Would you like to retry.?" buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(void)fetchNextRecord
{
    if (currentRecordIndex >= reportTotalRecord) {
        
        self.cardDetail = [[NSMutableArray alloc]init];
        
        NSPredicate *voidPredicate = [NSPredicate predicateWithFormat:@"TransType = %@",@"Void"];
        NSArray *voidInvoiceArray = [localReportDetailsArray filteredArrayUsingPredicate:voidPredicate];
        NSArray *voidFilterArray = [voidInvoiceArray valueForKey:@"RegisterInvNo"];
        for (NSMutableDictionary *voidFilterDictionary in localReportDetailsArray) {
            if ([[voidFilterDictionary valueForKey:@"TransType"] isEqualToString:@"SALE/REDEEM"] && [voidFilterArray containsObject:[voidFilterDictionary valueForKey:@"RegisterInvNo"]]) {
                voidFilterDictionary[@"VoidSaleTrans"] = @"1";
            }
        }
        
        totalCardDetailsArray = [localReportDetailsArray mutableCopy];
        self.cardDetail = [totalCardDetailsArray mutableCopy];
        [self configuerChartArray:localReportDetailsArray];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"BillDate" ascending:FALSE];
        [self.cardDetail sortUsingDescriptors:@[sortDescriptor]];
        
        dispatch_async(dispatch_get_main_queue(),  ^{
            [_activityIndicator hideActivityIndicator];
            [self.tblCardSettlement reloadData];
            [self.cardSelectionPickerView reloadAllComponents];
            self.selectedCardName.text = @"All";
        });
        [self setupCardArrayWithCardDetail: self.cardDetail];
        return;
    }
    [paxReportDetailDevice getLocalDetailReportForRecordNumber:currentRecordIndex];
}

- (void)paxDevice:(PaxDevice*)paxDevice failed:(NSError*)error response:(PaxResponse *)response
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_activityIndicator hideActivityIndicator];
         if ([response isKindOfClass:[BatchCloseResponse class]])
         {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            [paxReportDetailDevice localTotalReport];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Batch close Error" message:response.responseMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
        
     else if ([response isKindOfClass:[LocalDetailReportResponse class]])
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [self hideallDetails];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:response.responseMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
        else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                [paxReportDetailDevice localTotalReport];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Batch close Error" message:response.responseMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    });
}

- (void)paxDevice:(PaxDevice*)paxDevice isConncted:(BOOL)isConncted
{
    
}
- (void)paxDeviceDidTimeout:(PaxDevice*)paxDevice
{
    
}

-(IBAction)paxBatchClose:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [_activityIndicator updateLoadingMessage:@"Please enter password in the device, if required"];

    [paxReportDetailDevice closeBatch];
}

-(IBAction)ccBatchSuummaryForPax:(id)sender
{
    paxReportContainerView.hidden = NO;
   
    if (ccBatchOverViewVC) {
        [ccBatchOverViewVC.view removeFromSuperview];
        ccBatchOverViewVC = nil;
    }
    
    [self localTotalReportRequest];
}


-(NSString *)cardTypeOf:(NSInteger)cardType
{
    NSString *creditCardType = @"";
    switch (cardType) {
        case VisaCard:
            creditCardType = @"VISA";
            break;
        case MasterCard:
            creditCardType = @"MASTER";
            break;
        case  AMEX:
            creditCardType = @"AMEX";
            break;
        case  Discover:
            creditCardType = @"Discover";
            break;
        case  DinerClub:
            creditCardType = @"DinerClub";
            break;
        case enRoute:
            creditCardType = @"enRoute";
            break;
        case  JCB :
            creditCardType = @"JCB";
            break;
        case RevolutionCard:
            creditCardType = @"RevolutionCard";
            break;
            
        default:
        case  OTHER:
            creditCardType = @"OTHER";
            
            break;
    }
    return creditCardType;
}

#pragma mark BridgePay Amount Capture Method

-(void)didSelectForceTransactionAtIndexPath :(NSIndexPath *)indexpath
{
    
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
        [self setForceTransactionProcess:indexpath];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Are you sure you want Force this Transaction ?"] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(void)setForceTransactionProcess:(NSIndexPath*)indexpath
{
    NSDictionary *dictionaryAtIndexpath;
    if([self.selectedCardName.text isEqualToString:@"All"])
    {
        dictionaryAtIndexpath = (self.cardDetail)[indexpath.row];
    }
    else if([self.selectedCardName.text isEqualToString:@"Detail Breakdown"])
    {
        NSMutableArray * cardCountArray = [(self.cardDetailDisplayList)[indexpath.section] valueForKey:(self.totalCardDisplayArray)[indexpath.section+1]];
        dictionaryAtIndexpath = cardCountArray[indexpath.row];
    }
    else
    {
        NSMutableArray * cardCountArray = [(self.cardDetailDisplayList)[indexpath.section] valueForKey:(self.totalCardDisplayArray)[indexpath.section]];
        dictionaryAtIndexpath = cardCountArray[indexpath.row];
    }
    
    
    
    if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Bridgepay"])
    {
        [self processAmountAdjustBridgePay:[dictionaryAtIndexpath[@"BillAmount"] floatValue] withTransactionNo:dictionaryAtIndexpath[@"TransactionNo"] withTransactionId:dictionaryAtIndexpath[@"RegisterInvNo"] withType:@"Force"];
    }
    else if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Pax"])
    {
        [self.paxDevice doCreditCaptureWithAmount:[dictionaryAtIndexpath[@"BillAmount"] floatValue] withInvoiceNumber:dictionaryAtIndexpath[@"RegisterInvNo"] referenceNumber:dictionaryAtIndexpath[@"RegisterInvNo"] transactionNumber:dictionaryAtIndexpath[@"TransactionNo"] withAuthCode:dictionaryAtIndexpath[@"AuthCode"]];
    }
}



-(void)processAmountAdjustBridgePay:(float)totalAmount withTransactionNo:(NSString *)transctionNo withTransactionId:(NSString *)regInvNo withType:(NSString *)type
{
    if (!_activityIndicator) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    }
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
    
    self.captureWebServiceConnection = [self.captureWebServiceConnection initWithAsyncRequestURL:url withDetailValues:transDetail asyncCompletionHandler:asyncCompletionHandler];
    
}

-(void)responseTenderCreditCardTotalAmountAdjustmentResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        [_activityIndicator hideActivityIndicator];
        _activityIndicator = nil;
        if (response != nil) {
            if ([response isKindOfClass:[NSString class]]) {
                DDXMLElement *RespMSGElement = [self getValueFromXmlResponse:response string:@"RespMSG"];
                if ([RespMSGElement.stringValue isEqualToString:@"Approved"])
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self getCardSettlementForBridgePay];
                    });
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:RespMSGElement.stringValue buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
        }
        else
        {
            [_activityIndicator hideActivityIndicator];
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Connection Dropped. Try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    });
}


-(void)didSelectVoidTransactionAtIndexPath :(NSIndexPath *)indexpath
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
        [self setVoidTransactionProcess:indexpath];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Are you sure you want Void this Transaction ?"] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(void)setVoidTransactionProcess :( NSIndexPath *)indexpath
{
    NSDictionary *dictionaryAtIndexpath;
    if([self.selectedCardName.text isEqualToString:@"All"])
    {
        dictionaryAtIndexpath = (self.cardDetail)[indexpath.row];
    }
    else if([self.selectedCardName.text isEqualToString:@"Detail Breakdown"])
    {
        NSMutableArray * cardCountArray = [(self.cardDetailDisplayList)[indexpath.section] valueForKey:(self.totalCardDisplayArray)[indexpath.section+1]];
        dictionaryAtIndexpath = cardCountArray[indexpath.row];
    }
    else
    {
        NSMutableArray * cardCountArray = [(self.cardDetailDisplayList)[indexpath.section] valueForKey:(self.totalCardDisplayArray)[indexpath.section]];
        dictionaryAtIndexpath = cardCountArray[indexpath.row];
        
    }
    
    
    if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Bridgepay"])
    {
        [self processVoidForBridgepayWithDetail:dictionaryAtIndexpath];
    }
    else if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Pax"])
    {
        [self paxVoidTransactionProcessWithDictionary:dictionaryAtIndexpath];
    }

}

-(void)processVoidForBridgepayWithDetail:(NSDictionary *)creditDetailDictionary
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
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
    
    self.captureWebServiceConnection = [self.captureWebServiceConnection initWithAsyncRequestURL:url withDetailValues:details asyncCompletionHandler:asyncCompletionHandler];
    
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
    [_activityIndicator hideActivityIndicator];
    NSLog(@"responseCreditCardVoidTransctionInvoiceResponse = %@",response);
    
    if (response != nil) {
        if ([response isKindOfClass:[NSString class]]) {
            NSLog(@"responseString : %@",response);
            if ([self getResultOfCreditCard:response] == 0 || [self getResultOfCreditCard:response] == 108)
            {
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self getCardSettlementForBridgePay];
                });

            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [_activityIndicator hideActivityIndicator];
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

-(void)paxVoidTransactionProcessWithDictionary:(NSDictionary *)creditDictionary
{
    NSDictionary *dictDevice = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceConfig"];
    if (dictDevice != nil)
    {
        NSString *paxDeviceIP = dictDevice [@"PaxDeviceIp"];
        NSString *paxDevicePort = dictDevice [@"PaxDevicePort"];
        paxReportDetailDevice = [[PaxDevice alloc] initWithIp:paxDeviceIP port:paxDevicePort];
        paxReportDetailDevice.paxDeviceDelegate = self;
        NSString *registerInvoiceNo = [NSString stringWithFormat:@"%@",[creditDictionary valueForKey:@"RegisterInvNo"]];
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HHmmss";
        NSString *strDate = [formatter stringFromDate:date];
        NSString *currentCreditTransactionId = [NSString stringWithFormat:@"%@%@",registerInvoiceNo,strDate];
        
        if (creditDictionary) {
            if (creditDictionary[@"TransactionNo"]) {
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                paxReportDetailDevice.pdResonse = PDResponseDoCash;
                [paxReportDetailDevice voidCreditTransactionNumber:creditDictionary[@"TransactionNo"] invoiceNumber:registerInvoiceNo referenceNumber:currentCreditTransactionId];
            }
        }
    }
}
@end
