//
//  CCBatchForBridgePay.m
//  RapidRMS
//
//  Created by Siya-mac5 on 22/07/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CCBatchForBridgePay.h"
#import "RmsDbController.h"
#import "NSString+Methods.h"

#define LIVE_GET_BATCH_SETTLE_DATA_URL @"https://gateway.itstgate.com/admin/ws/trxdetail.asmx"
#define TEST_GET_BATCH_SETTLE_DATA_URL @"https://gatewaystage.itstgate.com/admin/ws/trxdetail.asmx"

#define LIVE_BATCH_SETTLE_DATA_URL @"https://gateway.itstgate.com/SmartPayments/transact.asmx"
#define TEST_BATCH_SETTLE_DATA_URL @"https://gatewaystage.itstgate.com/SmartPayments/transact.asmx"

@interface CCBatchForBridgePay() {
    NSString *processBatchUnsettleUrl;
    NSString *processBatchSettleUrl;
    
    CGFloat adjustedTipAmount;

    NSDictionary *selectedTipsDictionary;
}

@property (nonatomic, strong) NSMutableArray *cardDetailForDeviceBatch;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *currentTransactionThroughBridgePayWSC;
@property (nonatomic, strong) RapidWebServiceConnection *deviceBatchWSCThroughRapidConnectServer;
@property (nonatomic, strong) RapidWebServiceConnection *deviceBatchWSCThroughBridgePayServer;
@property (nonatomic, strong) RapidWebServiceConnection *cardSettlementDateWSC;
@property (nonatomic, strong) RapidWebServiceConnection *batchSettlementWSCThroughRapidConnectServer;
@property (nonatomic, strong) RapidWebServiceConnection *batchSettlementWSCThroughBridgePayServer;
@property (nonatomic, strong) RapidWebServiceConnection *tipAdjustmentWSCThroughRapidConnectServer;
@property (nonatomic, strong) RapidWebServiceConnection *tipsAdjustmentWSC;
@property (nonatomic, strong) RapidWebServiceConnection *tipAdjustmentWSCThroughBridgePayServer;
@property (nonatomic, strong) RapidWebServiceConnection *creditCardDeclineWSC;

@end

@implementation CCBatchForBridgePay

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        [self initializationProcessForBridgePay];
    }
    return self;
}

- (void)initializationProcessForBridgePay {
    if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"PaymentMode"] isEqualToString:@"Test"])
    {
        processBatchUnsettleUrl = TEST_GET_BATCH_SETTLE_DATA_URL;
        processBatchSettleUrl = TEST_BATCH_SETTLE_DATA_URL;
    }
    else
    {
        processBatchUnsettleUrl = LIVE_GET_BATCH_SETTLE_DATA_URL;
        processBatchSettleUrl = LIVE_BATCH_SETTLE_DATA_URL;
    }
}

#pragma mark - Current Transaction

- (void)getCurrentTransactionDataThroughBridgePayForDate:(NSString *)date {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[self.rmsDbController.globalDict objectForKey:@"BranchID"] forKey:@"BranchId"];
    [param setValue:date forKey:@"BillDate"];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self.cCBatchForBridgePayDelegate currentTransactionResponse:response error:error];
    };
    
    self.currentTransactionThroughBridgePayWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_CC_BATCH_UN_SETTLEMENT_DATA params:param completionHandler:completionHandler];
}

#pragma mark - Device Batch

- (void)deviceBatchDataForBridgePay
{
    if([self.transctionServer isEqualToString:@"RAPID CONNECT"]) {
        [self deviceBatchDataThroughRapidConnectServer];
    }
    else {
        [self deviceBatchDataThroughBridgePayServer];
    }
}

- (void)deviceBatchDataThroughRapidConnectServer {
    NSMutableDictionary *parameterDictionary = [self deviceBatchParameterForRapidConnectRapidConnect];
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deviceBatchDataThroughRapidConnectServerResponse:response error:error];
        });
    };
    
    self.deviceBatchWSCThroughRapidConnectServer = [[RapidWebServiceConnection alloc] initWithRequest:KURL_PAYMENT actionName:WSM_BRIDGEPAY_GET_CARD_TRNX_PROCESS params:parameterDictionary completionHandler:completionHandler];
}

- (NSMutableDictionary *)deviceBatchParameterForRapidConnectRapidConnect {
    NSMutableDictionary *parameterDictionary = [[NSMutableDictionary alloc]init];
    parameterDictionary[@"BranchId"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    parameterDictionary[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    parameterDictionary[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    parameterDictionary[@"SettlementEndDate"] = [self settlementEndDateForDeviceBatch];
    return parameterDictionary;
}

- (NSString *)settlementEndDateForDeviceBatch {
    NSDate *date = [NSDate date];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    date = [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
    NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
    dateFormatter1.dateFormat = @"yyyy-MM-dd";
    NSString *nowDate = [dateFormatter1 stringFromDate:date];
    NSString *nowdatetime = [NSString stringWithFormat:@"%@T00:00:00",nowDate];
    return nowdatetime;
}

- (void)deviceBatchDataThroughRapidConnectServerResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSString *responseString = response[@"Data"];
            [self handleCardTrxProcessResponse:responseString];
        }
    }
    else
    {
        [self.cCBatchForBridgePayDelegate didConnectionDroppedWhileGettingDeviceBatchDataThroughBridgePay];
    }
}

- (void)handleCardTrxProcessResponse:(NSString *)responseString {
    responseString = [responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    responseString = [RmsDbController removeNameSpaceFromXml:responseString rootTag:@"string"];
    NSMutableArray *responseArray = [self getValueFromBatchXmlResponse:responseString];
    if (responseArray.count>0)
    {
        responseArray = [self removeInProperValuefromCartType:responseArray];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TransType  ==  %@", @"ForceCapture" ];
        NSArray *filteredArray = [responseArray filteredArrayUsingPredicate:predicate];
        NSArray *arrAuthCode = [filteredArray valueForKey:@"OrigTrnHostReferenceKey"];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"HostRefNum IN %@ AND TransType == %@", arrAuthCode , @"Authorization" ];
        NSArray *filterArray1 = [responseArray filteredArrayUsingPredicate:predicate1];
        [responseArray removeObjectsInArray:filterArray1];
        self.cardDetailForDeviceBatch = [responseArray mutableCopy];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"BillDate" ascending:FALSE];
        [self.cardDetailForDeviceBatch sortUsingDescriptors:@[sortDescriptor]];
        dispatch_async(dispatch_get_main_queue(),  ^{
            [self.cCBatchForBridgePayDelegate deviceBatchDataForBridgePay:self.cardDetailForDeviceBatch];
        });
    }
    else
    {
        [self.cCBatchForBridgePayDelegate didErrorOccurredWhileGettingDeviceBatchDataThroughBridgePay];
    }
}

-(NSMutableArray *)removeInProperValuefromCartType:(NSMutableArray *)pArray {
    for(int i=0; i<pArray.count; i++){
        NSMutableDictionary *dict = [pArray[i] mutableCopy];
        NSRange rang = [[dict valueForKey:@"CardType"] rangeOfString:@","];
        if(rang.location != NSNotFound){
            NSArray *arryExtData = [[dict valueForKey:@"CardType"] componentsSeparatedByString:@","];
            for (NSString *strTem in arryExtData) {
                NSRange rang = [strTem rangeOfString:@"CardType"];
                if(rang.location!=NSNotFound)
                {
                    NSArray  *arryExtData2 = [strTem componentsSeparatedByString:@"="];
                    if(arryExtData2.count >= 2)
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

- (NSMutableArray *)getValueFromBatchXmlResponse:(NSString *)responseString
{
    NSMutableArray *totalCreditCardData = [[NSMutableArray alloc]init];
    DDXMLDocument *fuelTypeDocument = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
    DDXMLNode *rootNode = fuelTypeDocument.rootElement;
    NSString *responseStr = [NSString stringWithFormat:@"/string/RichDBDS/TrxDetailCard"];
    NSArray *FuelNodes = [rootNode nodesForXPath:responseStr error:nil];
    for (DDXMLElement *fuelElement in FuelNodes)
    {
        NSMutableDictionary *individualCreditCardData = [[NSMutableDictionary alloc] init];
        individualCreditCardData[@"TransactionNo"] = [self valueforAttibute:@"TRX_HD_Key" creditDataElement:fuelElement];
        individualCreditCardData[@"RegisterInvNo"] = [self valueforAttibute:@"Invoice_ID" creditDataElement:fuelElement];
        NSString *dateFibnal = [self getFinalBillDateFrom:[self valueforAttibute:@"Date_DT" creditDataElement:fuelElement]];
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
        individualCreditCardData[@"HostRefNum"] = [self valueforAttibute:@"Host_Ref_Num_CH" creditDataElement:fuelElement];
        individualCreditCardData[@"OrigTrnHostReferenceKey"] = [self valueforAttibute:@"Orig_TRX_HD_Key" creditDataElement:fuelElement];
        [totalCreditCardData addObject:individualCreditCardData];
    }
    return totalCreditCardData;
}

- (NSString *)getFinalBillDateFrom:(NSString *)dateString {
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    df.timeZone = [NSTimeZone localTimeZone];
    NSString *str = dateString;
    NSDate *date = [df dateFromString:str];
    if(date == nil)
    {
        df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    }
    date = [df dateFromString:str];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MM-dd-yyyy HH:mm:ss";
    NSString *finalDate = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return finalDate;
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

- (void)deviceBatchDataThroughBridgePayServer {
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] forKey:@"GateWayType"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self getCardSettlementForBridgePayResponse:response error:error];
    };
    
    self.cardSettlementDateWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_GET_CARD_SETTLEMENT_DETAIL params:param completionHandler:completionHandler];
}

- (void)getCardSettlementForBridgePayResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *ccBatchDate = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSString *lastCcBatchDate = [self getLastCcBatchDate:ccBatchDate];
                NSString *nowDateTime = [self getNowDateTime];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSString *detail = [NSString stringWithFormat:@"UserName=%@&Password=%@&RPNum=%@&BeginDt=%@&EndDt=%@&ExcludeVoid=%@&SettleFlag=%@&PNRef=&PaymentType=&ExcludePaymentType=&TransType=%@&ExcludeTransType=&ApprovalCode=&Result=%@&ExcludeResult=&NameOnCard=&CardNum=&CardType=&ExcludeCardType=&User=&invoiceId=&SettleMsg=&SettleDt=&TransformType=&Xsl=&ColDelim=&RowDelim=&IncludeHeader=&ExtData=",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"MerchantKey"],lastCcBatchDate,nowDateTime,@"false",@"0",@"'Sale','Authorization','Void','ForceCapture','Credit'",@"0"];
                    [self getUnsettleBatchDetailwithProcess:@"GetCardTrx" withDetail:detail withProcessUrl:processBatchUnsettleUrl];
                });
            }
            else if([[response valueForKey:@"IsError"] intValue] == 1)
            {
                NSString *nowDateTimeUsingTimeZone = [self getNowDateTimeUsingTimeZone];
                NSString *currentDateTime = [self getCurrentDateTime];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSString *detail = [NSString stringWithFormat:@"UserName=%@&Password=%@&RPNum=%@&BeginDt=%@&EndDt=%@&ExcludeVoid=%@&SettleFlag=%@&PNRef=&PaymentType=&ExcludePaymentType=&TransType=&ExcludeTransType=&ApprovalCode=&Result=&ExcludeResult=&NameOnCard=&CardNum=&CardType=&ExcludeCardType=&User=&invoiceId=&SettleMsg=&SettleDt=&TransformType=&Xsl=&ColDelim=&RowDelim=&IncludeHeader=&ExtData=",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"MerchantKey"],nowDateTimeUsingTimeZone,currentDateTime,@"true",@"0"];
                    [self getUnsettleBatchDetailwithProcess:@"GetCardTrx" withDetail:detail withProcessUrl:processBatchUnsettleUrl];
                });
            }
            else
            {
                [self.cCBatchForBridgePayDelegate stopActivityIndicatorForBridgePay];
            }
        }
    }
    else
    {
        [self.cCBatchForBridgePayDelegate stopActivityIndicatorForBridgePay];
    }
}

- (NSString *)getLastCcBatchDate:(NSMutableArray *)ccBatchDate {
    NSString *lastCcBatchDate = [ccBatchDate.firstObject valueForKey:@"SettlementDate"];
    NSDate *passDate = [self jsonStringToNSDate:lastCcBatchDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *currentDate = [dateFormatter stringFromDate:passDate];
    dateFormatter.dateFormat = @"hh:mm:ss";
    NSString *currentTime = [dateFormatter stringFromDate:passDate];
    lastCcBatchDate = [NSString stringWithFormat:@"%@T%@",currentDate,currentTime];
    return lastCcBatchDate;
}

- (NSString *)getNowDateTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    dateFormatter1.timeZone = [NSTimeZone timeZoneWithName:@"US/Eastern"];
    dateFormatter1.dateFormat = @"yyyy-MM-dd";
    NSString *nowDate = [dateFormatter1 stringFromDate:date];
    dateFormatter1.dateFormat = @"hh:mm:ss";
    NSString *nowTime = [dateFormatter1 stringFromDate:date];
    NSString *nowDateTime = [NSString stringWithFormat:@"%@T%@",nowDate,nowTime];
    return nowDateTime;
}

- (NSString *)getNowDateTimeUsingTimeZone {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    formatter.timeZone = sourceTimeZone;
    formatter.dateFormat = @"yyyy-MM-ddTHH:mm:ss";
    NSDate *minusOneHr = [[NSDate date] dateByAddingTimeInterval:-3600 * 72];
    NSString *strDate = [formatter stringFromDate:minusOneHr];
    NSString *nowDateTimeUsingTimeZone = [NSString stringWithFormat:@"%@T00:00:00",strDate];
    return nowDateTimeUsingTimeZone;
}

- (NSString *)getCurrentDateTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *currentDate = [dateFormatter stringFromDate:date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm:ss";
    NSString *currentTime = [timeFormatter stringFromDate:date];
    NSString *currentDateTime = [NSString stringWithFormat:@"%@T%@",currentDate,currentTime];
    return currentDateTime;
}

- (void)getUnsettleBatchDetailwithProcess:(NSString *)processName withDetail:(NSString *)detail withProcessUrl:(NSString *)url
{
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deviceBatchDataThroughBridgePayServerResponse:response error:error];
        });
    };
    self.deviceBatchWSCThroughBridgePayServer = [[RapidWebServiceConnection alloc] initWithAsyncRequestURL:[NSString stringWithFormat:@"%@/%@",url,processName] withDetailValues:detail asyncCompletionHandler:asyncCompletionHandler];
}

- (void)deviceBatchDataThroughBridgePayServerResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        [self.cCBatchForBridgePayDelegate stopActivityIndicatorForBridgePay];
    });
    if (response != nil) {
        if ([response isKindOfClass:[NSString class]]) {
            [self handleCardTrxProcessResponse:response];
        }
    }
}

#pragma mark - Batch Settlement

- (void)batchSettlementProcessForBridgePay
{
    if([self.transctionServer isEqualToString:@"RAPID CONNECT"]) {
        [self batchSettlementProcessThroughRapidConnectServer];
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self batchSettlementProcessThroughBridgePayServer];
        });
    }
}

- (void)batchSettlementProcessThroughRapidConnectServer {
    NSMutableDictionary *batchSettlementParameter = [self getBatchSettlementParameterForRapidConnect];
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self batchSettlementProcessResponse:response error:error];
    };
    
    self.batchSettlementWSCThroughRapidConnectServer = [[RapidWebServiceConnection alloc] initWithRequest:KURL_PAYMENT actionName:WSM_BRIDGEPAY_SETTLEMENT_PROCESS params:batchSettlementParameter completionHandler:completionHandler];
}

- (NSMutableDictionary *)getBatchSettlementParameterForRapidConnect {
    NSMutableDictionary *batchSettlementParameter = [[NSMutableDictionary alloc]init];
    batchSettlementParameter[@"BranchId"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    batchSettlementParameter[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    batchSettlementParameter[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    batchSettlementParameter[@"TransType"] = @"CaptureAll";
    batchSettlementParameter[@"ExtData"] = @"<CardType>ALL</CardType>";
    batchSettlementParameter[@"localDate"] = [self getLocaleDate];
    return batchSettlementParameter;
}

- (NSString *)getLocaleDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *localDate = [formatter stringFromDate:date];
    return localDate;
}

- (void)batchSettlementProcessThroughBridgePayServer {
    NSString *detail = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=&InvNum=&PNRef=&Zip=&Street=&CVNum=&ExtData=%@",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],@"CaptureAll",@"<CardType>ALL</CardType>"];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self batchSettlementProcessResponse:response error:error];
        });
    };
    
    self.batchSettlementWSCThroughBridgePayServer = [[RapidWebServiceConnection alloc] initWithAsyncRequestURL:[NSString stringWithFormat:@"%@/%@",processBatchSettleUrl,@"ProcessCreditCard"] withDetailValues:detail asyncCompletionHandler:asyncCompletionHandler];
}

- (void)batchSettlementProcessResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        if (response != nil) {
            Class class = [self identifyClassToHandleResponse];
            if ([response isKindOfClass:class]) {
                NSString *responseString = [self getResponseStringToHandleResponse:response];
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
                    NSArray *bridgePayBatchSummryArray = [batchSummry componentsSeparatedByString:@","];
                    batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                    batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@",Result=0" withString:@""];
                    batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"=" withString:@" = "];
                    batchSummry = [batchSummry stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
                    NSString *batchInfo = [NSString stringWithFormat:@"Confirmation = %@ \n %@",authCode,batchSummry];
                    [self.cCBatchForBridgePayDelegate didBatchSettledWithBatchSummry:bridgePayBatchSummryArray batchInfo:batchInfo result:result response:response];
                }
                else
                {
                    [self.cCBatchForBridgePayDelegate didErrorOccurredInBatchSettlementProcessWithMessage:[NSString stringWithFormat:@"Code %ld(%@), Error occured while processing.",(long)result,respMSG] withTitle:@"Info"];
                }
            }
        }
        else
        {
            [self.cCBatchForBridgePayDelegate didErrorOccurredInBatchSettlementProcessWithMessage:@"TGate connection error" withTitle:@"Failed"];
        }
    });
    [self callDeclineWebservicewithErrorMessage:response];
}

- (Class)identifyClassToHandleResponse {
    Class class;
    if([self.transctionServer isEqualToString:@"RAPID CONNECT"]){
        class = [NSDictionary class];
    }
    else {
        class = [NSString class];
    }
    return class;
}

- (NSString *)getResponseStringToHandleResponse:(id)response {
    NSString *responseString;
    if([self.transctionServer isEqualToString:@"RAPID CONNECT"]){
        responseString = response[@"Data"];
    }
    else {
        responseString = response;
    }
    return responseString;
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

- (NSString *)getTransactionDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    return currentDateTime;
}

- (NSMutableDictionary *)declineWSParameterWithErrorMessage:(NSString *)errorMessage {
    NSMutableDictionary *errorResponse = [[NSMutableDictionary alloc]init];
    errorResponse[@"errorMassege"] = [NSString stringWithFormat:@"%@",errorMessage];
    errorResponse[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    errorResponse[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    errorResponse[@"errorCode"] = @"2";
    errorResponse[@"transDate"] = [self getTransactionDate];
    errorResponse[@"invoiceDetail"] = @"";
    NSMutableDictionary *dictMain = [[NSMutableDictionary alloc]init];
    dictMain[@"objCardDeclineProcessDetail"] = errorResponse;
    return dictMain;
}

- (void)callDeclineWebservicewithErrorMessage:(NSString *)errorMessage
{
    NSMutableDictionary *declineParameterDictionary = [self declineWSParameterWithErrorMessage:errorMessage];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self callDeclineWebservicewithErrorMessageResponse:response error:error];
    };
    
    self.creditCardDeclineWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_CREDIT_CARD_DECLINE_PROCESS params:declineParameterDictionary completionHandler:completionHandler];
}

- (void)callDeclineWebservicewithErrorMessageResponse:(id)response error:(NSError *)error
{
}

#pragma mark - Tips Adjustment

- (void)tipsAdjustmentForBridgePayWithTipAmount:(CGFloat)tipAmount withTipsDictionary:(NSDictionary *)tipsDictionary  {
    adjustedTipAmount = tipAmount;
    selectedTipsDictionary = tipsDictionary;
    if([self.transctionServer isEqualToString:@"RAPID CONNECT"]) {
        [self tipsAdjustmentThroughRapidConnectServer];
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self tipsAdjustmentThroughBridgePayServer];
        });
    }
}

- (void)tipsAdjustmentThroughRapidConnectServer {
    NSMutableDictionary *parameterDictionary = [self parameterForTipsAdjustmentThroughRapidConnectServer];
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self tipAdjustmentThroughRapidConnectServerResponse:response error:error];
    };
    
    self.tipAdjustmentWSCThroughRapidConnectServer = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL_PAYMENT actionName:WSM_RAPID_SERVER_TIP_ADJUSTMENT_PROCESS params:parameterDictionary asyncCompletionHandler:asyncCompletionHandler];
}

- (NSMutableDictionary *)parameterForTipsAdjustmentThroughRapidConnectServer {
    NSString *extData = [NSString stringWithFormat:@"<TipAmt>%.2f</TipAmt>",adjustedTipAmount];
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
    return dictParam;
}

-(void)tipAdjustmentThroughRapidConnectServerResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        if (response != nil) {
            if ([response isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *dictResponse = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if ([dictResponse[@"RespMSG"] isEqualToString:@"Approved"])
                {
                    [self tipAdjustment];
                }
                else
                {
                    [self.cCBatchForBridgePayDelegate errorOccurredInTipAdjustmentThroughRapidConnectServerWithMessage:dictResponse[@"RespMSG"] withTitle:@"Info"];
                }
            }
        }
        else
        {
            [self.cCBatchForBridgePayDelegate errorOccurredInTipAdjustmentThroughRapidConnectServerWithMessage:@"Connection Dropped. Try again." withTitle:@"Info"];
        }
    });
}

- (NSString *)getBillDateTime {
    NSDate *date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    return currentDateTime;
}

- (NSMutableDictionary *)tipsAdjustmentParameterDictionary {
    NSMutableDictionary *parameterDictionary = [[NSMutableDictionary alloc]init];
    parameterDictionary[@"RegInvoiceNo"] = [selectedTipsDictionary valueForKey:@"RegisterInvNo"];
    parameterDictionary[@"TransactionNo"] = [selectedTipsDictionary valueForKey:@"TransactionNo"];
    parameterDictionary[@"AuthCode"] = @"-";
    parameterDictionary[@"CardType"] = [selectedTipsDictionary valueForKey:@"CardType"];
    parameterDictionary[@"TipAmount"] = [NSString stringWithFormat:@"%.2f",adjustedTipAmount];
    parameterDictionary[@"AccNo"] = [selectedTipsDictionary valueForKey:@"AccNo"];
    parameterDictionary[@"PayId"] = @"0";
    parameterDictionary[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    parameterDictionary[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    parameterDictionary[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    parameterDictionary[@"BillDate"] = [self getBillDateTime];
    return parameterDictionary;
}

- (void)tipAdjustment
{
    NSMutableDictionary *parameterDictionary = [self tipsAdjustmentParameterDictionary];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseTipsAdjustmentResponse:response error:error];
        });
    };
    
    self.tipsAdjustmentWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_CC_TIPS_ADJUSTMENT params:parameterDictionary completionHandler:completionHandler];
}

-(void)responseTipsAdjustmentResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self.cCBatchForBridgePayDelegate didTipsAdjustedSuccessfullyWithMessage:@"Tip Adjusted SuccessFully" withTitle:@"Info"];
            }
            else
            {
                NSString *strError = [NSString stringWithFormat:@"Error occured while applying tip.\n Error code = %@ Message = %@ \nPlease try again.",[response valueForKey:@"IsError"],[response valueForKey:@"Data"]];
                [self.cCBatchForBridgePayDelegate errorOccurredInTipAdjustmentThroughRapidConnectServerWithMessage:strError withTitle:@"Info"];
            }
        }
    }
    else
    {
        [self.cCBatchForBridgePayDelegate errorOccurredInTipAdjustmentThroughRapidConnectServerWithMessage:@"Error occured while applying tip. Please try again." withTitle:@"Info"];
    }
}

- (void)tipsAdjustmentThroughBridgePayServer {
    NSDictionary *paymentDictionary = self.rmsDbController.paymentCardTypearray.firstObject;
    NSString *extData = [NSString stringWithFormat:@"<TipAmt>%.2f</TipAmt>",adjustedTipAmount];
    NSString *transDetails = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=&InvNum=&PNRef=%@&Zip=&Street=&CVNum=&ExtData=%@",[paymentDictionary valueForKey:@"Username"],[paymentDictionary valueForKey:@"password"],@"Adjustment",[selectedTipsDictionary valueForKey:@"TransactionNo"],extData];
    [self processTipAdjustment:[paymentDictionary valueForKey:@"URL"] details:transDetails];
}

- (void)processTipAdjustment:(NSString *)url details:(NSString *)details
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",@"ProcessCreditCard"]];
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self tipAdjustmentThroughBridgePayServerResponse:response error:error];
        });
    };

    self.tipAdjustmentWSCThroughBridgePayServer = [[RapidWebServiceConnection alloc] initWithAsyncRequestURL:url withDetailValues:details asyncCompletionHandler:asyncCompletionHandler];
}

-(void)tipAdjustmentThroughBridgePayServerResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        if (response != nil) {
            if ([response isKindOfClass:[NSString class]]) {
                NSString *responseString = response;
                DDXMLElement *RespMSGElement = [self getValueFromXmlResponse:responseString string:@"RespMSG"];
                if ([RespMSGElement.stringValue isEqualToString:@"Approved"])
                {
                    [self tipAdjustment];
                }
                else
                {
                    [self.cCBatchForBridgePayDelegate errorOccurredInTipAdjustmentThroughRapidConnectServerWithMessage:RespMSGElement.stringValue withTitle:@"Info"];
                }
            }
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

@end
