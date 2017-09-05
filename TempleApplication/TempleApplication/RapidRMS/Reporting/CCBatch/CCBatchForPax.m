//
//  CCBatchForPax.m
//  RapidRMS
//
//  Created by Siya-mac5 on 22/07/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CCBatchForPax.h"
#import "RmsDbController.h"
#import "PaxDevice.h"
#import "CCBatchVC.h"
#import "NSString+Methods.h"

@interface CCBatchForPax () <PaxDeviceDelegate> {
    NSString *paxDeviceIP;
    NSString *paxDevicePort;
    NSString *totalAmountString;
    NSString *batchNo;

    NSMutableArray *localReportDetailsArray;

    CGFloat currentRecordIndex;
    CGFloat reportTotalRecord;
    CGFloat totalCreditAmountValue;
    CGFloat totalDebitAmountValue;
    NSMutableDictionary *dictTotalAmountCount;
    NSInteger totalCount;
    NSInteger totalCreditCount;
    NSInteger totalDebitCount;

    PaxDevice *paxReportDetailDevice;
}

@property (nonatomic, strong) NSMutableArray *cardDetailForDeviceBatch;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *currentTransactionThroughPaxWSC;
@property (nonatomic ,strong) RapidWebServiceConnection *insertPaxWSC;

@end

@implementation CCBatchForPax

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        [self initializationProcessForPax];
    }
    return self;
}

- (void)initializationProcessForPax {
    [self configureIPAndPortOfPaxDeviceAsPerSetting];
    [self initializePax];
}

- (void)configureIPAndPortOfPaxDeviceAsPerSetting {
    NSDictionary *dictDevice = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceConfig"];
    if (dictDevice != nil)
    {
        paxDeviceIP = dictDevice [@"PaxDeviceIp"];
        paxDevicePort = dictDevice [@"PaxDevicePort"];
    }
}

- (void)configureIPAndPortOfOtherPaxDevice:(NSDictionary *)paxDictionary {
    paxDeviceIP = paxDictionary [@"PaxIpAddress"];
    paxDevicePort = paxDictionary [@"Port"];
}

- (NSDictionary *)paxInfoDictionary {
    return @{
             @"PaxIpAddress" : paxDeviceIP,
             @"Port" : paxDevicePort
             };
}

- (void)initializePax {
    if (paxReportDetailDevice == nil) {
        [self configurePaxDevice];
    }
    [paxReportDetailDevice initializeDevice];
}

- (void)configurePaxDevice
{
    localReportDetailsArray = [[NSMutableArray alloc] init];
    paxReportDetailDevice = [[PaxDevice alloc] initWithIp:paxDeviceIP port:paxDevicePort];
    paxReportDetailDevice.paxDeviceDelegate = self;
}

#pragma mark - Current Transaction

- (void)getCurrentTransactionDataThroughPaxForDate:(NSString *)date withPaxSerialNo:(NSString *)paxSerialNo {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[self.rmsDbController.globalDict objectForKey:@"BranchID"] forKey:@"BranchId"];
    [param setValue:date forKey:@"BillDate"];
    [param setValue:paxSerialNo forKey:@"PaxSerialNo"];
    [param setValue:@"" forKey:@"BatchNo"];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self.cCBatchForPaxDelegate currentTransactionResponse:response error:error];
    };
    
    self.currentTransactionThroughPaxWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_CC_BATCH_UN_SETTLEMENT_PAX_DATA params:param completionHandler:completionHandler];
}

#pragma mark - Device Summary

- (void)deviceSummaryDataForPax
{
    if (paxReportDetailDevice == nil) {
        [self configurePaxDevice];
    }
    [self paxTotalReport];
}

#pragma mark - Device Batch

- (void)deviceBatchDataForPax {
    localReportDetailsArray = [[NSMutableArray alloc] init];
    currentRecordIndex = 0;
    if (paxReportDetailDevice == nil) {
        [self configurePaxDevice];
    }
    [self getLocalDetailReportWithRecordIndex:currentRecordIndex ];
}

- (void)batchSettlementProcessForPax {
    [paxReportDetailDevice closeBatch];
}

#pragma mark - Other

- (void)requestForConnectOtherPaxDevice {
    paxReportDetailDevice = nil;
    [self configurePaxDevice];
    paxReportDetailDevice.pdResonse = PDRequestInitialize;
    [paxReportDetailDevice initializeDevice];
}

- (void)paxTotalReport {
    [paxReportDetailDevice localTotalReport];
}

- (void)getLocalDetailReportWithRecordIndex:(CGFloat)currentIndex  {
    [paxReportDetailDevice getLocalDetailReportForRecordNumber:currentIndex];
}

#pragma mark - Device Batch Response

- (void)paxInitializationResponse:(InitializeResponse *)initializeResponse {
    if (initializeResponse.responseCode.integerValue == 0) {
        dispatch_async(dispatch_get_main_queue(),  ^{
            [self.cCBatchForPaxDelegate statusForOtherPaxDeviceConnection:@"CONNECTED" withPaxSerialNo:initializeResponse.serialNumber];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),  ^{
            [self.cCBatchForPaxDelegate statusForOtherPaxDeviceConnection:@"CONNECTED" withPaxSerialNo:initializeResponse.serialNumber];
        });
    }
}

- (void)deviceSummaryDataThroughPaxResponse:(LocalTotalReportResponse *)localTotalResponse {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.cCBatchForPaxDelegate deviceSummaryDataThroughPax:localTotalResponse.totalLocalReportDetailArray];
    });
}

- (void)deviceBatchDataThroughPaxResponse:(LocalDetailReportResponse *)localTotalResponse {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ResponseHostInformation *responseHostInformation = (ResponseHostInformation *)localTotalResponse.hostInformation;
        reportTotalRecord = localTotalResponse.totalrecord.integerValue;
        NSMutableDictionary *deviceBatchDictionary = [self getDeviceBatchDictionaryWithResponse:localTotalResponse withHostInformation:responseHostInformation];
        [localReportDetailsArray addObject:deviceBatchDictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            currentRecordIndex++;
            CGFloat percentage = currentRecordIndex / reportTotalRecord ;
            [self.cCBatchForPaxDelegate updateProgressStatusForFetchingPaxData:percentage];
            [self fetchNextRecord];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self insertPaxDataToServer:deviceBatchDictionary withResponse:localTotalResponse];
        });
    });
}

- (void)deviceBatchVoidProcessThroughPaxResponse:(DoCreditResponse *)doCreditResponse {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.cCBatchForPaxDelegate processAfterVoidThroughPax];
    });
}

- (NSString *)getDateFromResponseDateForDeviceBatch:(NSString *)dateString{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyyMMddHHmmss";
    df.timeZone = [NSTimeZone localTimeZone];
    NSString *str = dateString;
    NSDate *date = [df dateFromString:str];// NOTE -0700 is the only change
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MM-dd-yyyy HH:mm:ss";
    NSString *finalDate = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return finalDate;
}

- (NSMutableDictionary *)getDeviceBatchDictionaryWithResponse:(LocalDetailReportResponse *)localTotalResponse withHostInformation:(ResponseHostInformation *)responseHostInformation {
    NSMutableDictionary *deviceBatchDictionary = [[NSMutableDictionary alloc] init];
    if (localTotalResponse.referenceNumber.length > 6) {
        deviceBatchDictionary[@"RegisterInvNo"] = [localTotalResponse.referenceNumber substringToIndex:localTotalResponse.referenceNumber.length - 6];
    }
    else {
        deviceBatchDictionary[@"RegisterInvNo"] = localTotalResponse.referenceNumber;
    }
    deviceBatchDictionary[@"AccNo"] = localTotalResponse.accountNumber;
    deviceBatchDictionary[@"CardType"] = [self cardTypeOf:localTotalResponse.cardType.integerValue];
    CGFloat approvedAmount = localTotalResponse.approvedAmount.floatValue/100;
    if (localTotalResponse.transactionType.integerValue == EdcTransactionTypeReturn) {
        approvedAmount = -approvedAmount;
    }
    deviceBatchDictionary[@"BillAmount"] = [NSString stringWithFormat:@"%f",approvedAmount];
    deviceBatchDictionary[@"BillDate"] = [self getDateFromResponseDateForDeviceBatch:localTotalResponse.timeStamp];
    deviceBatchDictionary[@"AuthCode"] = responseHostInformation.authCode;
    deviceBatchDictionary[@"TransType"] = [self getTransationType:localTotalResponse.transactionType.integerValue];
    deviceBatchDictionary[@"TipsAmount"] = @"0.00";
    deviceBatchDictionary[@"TransactionNo"] = localTotalResponse.transactionNumber;
    deviceBatchDictionary[@"VoidSaleTrans"] = @"0";
    return deviceBatchDictionary;
}

- (NSMutableDictionary *)getBatchDictionary {
    NSDictionary *printDateAndTimeDict = [self getPrintDateAndTime];
    NSMutableDictionary *batchDictionary = [[NSMutableDictionary alloc]init];
    [batchDictionary setObject:[NSString stringWithFormat:@"%ld",(long)totalCount] forKey:@"TotalCount"];
    [batchDictionary setObject:[NSString stringWithFormat:@"%@",totalAmountString] forKey:@"TotalAmount"];
    [batchDictionary setObject:[NSString stringWithFormat:@"%@",batchNo] forKey:@"BatchNo"];
    [batchDictionary setObject:[NSString stringWithFormat:@"%@",printDateAndTimeDict[@"PrintDate"]] forKey:@"PrintDate"];
    [batchDictionary setObject:[NSString stringWithFormat:@"%@",printDateAndTimeDict[@"PrintTime"]] forKey:@"PrintTime"];
    return batchDictionary;
}

- (NSDictionary *)getPrintDateAndTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    NSString *printDate = [dateFormatter stringFromDate:date];
    NSString *printTime = [timeFormatter stringFromDate:date];
    return @{@"PrintDate" : printDate,
             @"PrintTime" : printTime
             };
}

-(void)fetchNextRecord
{
    if (currentRecordIndex >= reportTotalRecord) {
        
        NSPredicate *voidPredicate = [NSPredicate predicateWithFormat:@"TransType = %@",@"Void"];
        NSArray *voidInvoiceArray = [localReportDetailsArray filteredArrayUsingPredicate:voidPredicate];
        NSArray *voidFilterArray = [voidInvoiceArray valueForKey:@"RegisterInvNo"];
        for (NSMutableDictionary *voidFilterDictionary in localReportDetailsArray) {
            if ([[voidFilterDictionary valueForKey:@"TransType"] isEqualToString:@"SALE/REDEEM"] && [voidFilterArray containsObject:[voidFilterDictionary valueForKey:@"RegisterInvNo"]]) {
                voidFilterDictionary[@"VoidSaleTrans"] = @"1";
            }
        }
        self.cardDetailForDeviceBatch = [localReportDetailsArray mutableCopy];
        
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"BillDate" ascending:FALSE];
        [self.cardDetailForDeviceBatch sortUsingDescriptors:@[sortDescriptor]];
        dispatch_async(dispatch_get_main_queue(),  ^{
            [self.cCBatchForPaxDelegate deviceBatchDataForPax:self.cardDetailForDeviceBatch];
        });
        return;
    }
    [self getLocalDetailReportWithRecordIndex:currentRecordIndex];
}

#pragma mark - Insert Pax Data

- (void)insertPaxDataToServer:(NSMutableDictionary *)deviceBatchDictionary withResponse:(LocalDetailReportResponse *)localTotalResponse  {
    deviceBatchDictionary[@"TimeStamp"] = [NSString stringWithFormat:@"%@",localTotalResponse.timeStamp];
    NSMutableDictionary *paxDataDictionary = [[NSMutableDictionary alloc] init];
    NSError *err;
    NSData *jsonData = [NSJSONSerialization  dataWithJSONObject:deviceBatchDictionary options:0 error:&err];
    NSString *myString = [[NSString alloc] initWithData:jsonData  encoding:NSUTF8StringEncoding];
    paxDataDictionary[@"PaxData"] = myString;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
    };
    self.insertPaxWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_INSERT_PAX params:paxDataDictionary completionHandler:completionHandler];
}

#pragma mark - Batch Settlement Response

- (void)batchSettlementProcessThroughPaxResponse:(BatchCloseResponse *)batchCloseResponse {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (batchCloseResponse.responseCode.integerValue == 0) {
            ResponseHostInformation *responseHostInformation = (ResponseHostInformation *)batchCloseResponse.hostInformation;
            batchNo = responseHostInformation.batchNumber;
            
            dictTotalAmountCount = [[NSMutableDictionary alloc]init];
            
            [dictTotalAmountCount setValue:[NSString stringWithFormat:@"%ld",(long)batchCloseResponse.totalCreditCount ]forKey:@"TotalCreditCount"];
            
            [dictTotalAmountCount setValue:[NSString stringWithFormat:@"%ld",(long)batchCloseResponse.totalDebitCount ]forKey:@"TotalDebitCount"];
            
            [dictTotalAmountCount setValue:[NSString stringWithFormat:@"%f",batchCloseResponse.totalCreditAmount] forKey:@"TotalCreditAmountValue"];
            
            [dictTotalAmountCount setValue:[NSString stringWithFormat:@"%f",batchCloseResponse.totalDebitAmount]forKey:@"TotalDebitAmountValue"];

            
            CGFloat totalAmount = batchCloseResponse.totalCreditAmount + batchCloseResponse.totalDebitAmount + batchCloseResponse.totalEBTAmount;
            totalAmountString = [[NSString stringWithFormat:@"%f",totalAmount] applyCurrencyFormatter:totalAmount];
            totalCount = batchCloseResponse.totalCreditCount + batchCloseResponse.totalDebitCount + batchCloseResponse.totalEBTCount;
            NSString *batchMessage = [NSString stringWithFormat:@"TotalCount = %ld \n  TotalAmount = %@",(long)totalCount,totalAmountString];
            NSMutableDictionary *batchDictionary = [self getBatchDictionary];
            NSString *batchJsonString = [self.rmsDbController jsonStringFromObject:batchDictionary];
            [self.cCBatchForPaxDelegate didBatchSettledWithDetails:batchJsonString totalTransactionCount:totalCount totalAmount:totalAmountString cCBatchNo:batchNo batchMessage:batchMessage batchDictionary:dictTotalAmountCount];
        }
        else
        {
            [self.cCBatchForPaxDelegate didErrorOccurredInBatchSettlementProcessWithMessage:batchCloseResponse.responseMessage];
        }
    });
}

#pragma mark - GetCardType

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

#pragma mark - PaxDeviceDelegate

- (void)paxDevice:(PaxDevice*)paxDevice willSendRequest:(NSString*)request
{
    
}

- (void)paxDevice:(PaxDevice*)paxDevice response:(PaxResponse*)response
{
    if ([response isKindOfClass:[InitializeResponse class]]) {
        InitializeResponse *initializeResponse = (InitializeResponse *)response;
        [self paxInitializationResponse:initializeResponse];
    }
    else if ([response isKindOfClass:[LocalTotalReportResponse class]]) {
        LocalTotalReportResponse *localTotalResponse = (LocalTotalReportResponse *)response;
        [self deviceSummaryDataThroughPaxResponse:localTotalResponse];
    }
    else if ([response isKindOfClass:[BatchCloseResponse class]])
    {
        BatchCloseResponse *batchCloseResponse = (BatchCloseResponse *)response;
        [self batchSettlementProcessThroughPaxResponse:batchCloseResponse];
    }
    else if ([response isKindOfClass:[LocalDetailReportResponse class]])
    {
        LocalDetailReportResponse *localTotalResponse = (LocalDetailReportResponse *)response;
        [self deviceBatchDataThroughPaxResponse:localTotalResponse];
    }
    else if ([response isKindOfClass:[DoCreditResponse class]])
    {
        DoCreditResponse *doCreditResponse = (DoCreditResponse *)response;
        [self deviceBatchVoidProcessThroughPaxResponse:doCreditResponse];
    }
}

- (void)paxDevice:(PaxDevice*)paxDevice failed:(NSError*)error response:(PaxResponse *)response
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.cCBatchForPaxDelegate stopActivityIndicatorForPax];
        if ([response isKindOfClass:[BatchCloseResponse class]])
        {
            [self.cCBatchForPaxDelegate paxDeviceFailedWhileBatchSettlementWithMessage:response.responseMessage];
        }
        else if ([response isKindOfClass:[LocalDetailReportResponse class]])
        {
            [self.cCBatchForPaxDelegate paxDeviceFailedWhileGettingDeviceBatchDataWithMessage:response.responseMessage];
        }
        else
        {
            [self.cCBatchForPaxDelegate paxDeviceFailedDueToErrorWithMessage:response.responseMessage];
        }
    });
}

- (void)paxDevice:(PaxDevice*)paxDevice isConncted:(BOOL)isConncted
{
    
}

- (void)paxDeviceDidTimeout:(PaxDevice*)paxDevice
{
    
}

#pragma mark - Transation Type

- (NSString *)getTransationType:(TRANSACTIONTYPE)transationType {
    NSString *strTransationType = @"";
    switch (transationType) {
        case TRANSACTIONTYPEMENU:
            strTransationType = @"MENU";
            break;
            
        case TRANSACTIONTYPESALEREDEEM:
            strTransationType = @"SALE/REDEEM";
            break;
            
        case TRANSACTIONTYPERETURN:
            strTransationType = @"RETURN";
            break;
            
        case TRANSACTIONTYPEAUTH:
            strTransationType = @"Authorization";
            break;
            
        case TRANSACTIONTYPEPOSTAUTH:
            strTransationType = @"POSTAUTH";
            break;
            
        case TRANSACTIONTYPEFORCED:
            strTransationType = @"ForceCapture";
            break;
            
        case TRANSACTIONTYPEADJUST:
            strTransationType = @"ADJUST";
            break;
            
        case TRANSACTIONTYPEWITHDRAWAL:
            strTransationType = @"WITHDRAWAL";
            break;
            
        case TRANSACTIONTYPEACTIVATE:
            strTransationType = @"ACTIVATE";
            break;
            
        case TRANSACTIONTYPEISSUE:
            strTransationType = @"ISSUE";
            break;
            
        case TRANSACTIONTYPEADD:
            strTransationType = @"ADD";
            break;
            
        case TRANSACTIONTYPECASHOUT:
            strTransationType = @"CASHOUT";
            break;
            
        case TRANSACTIONTYPEDEACTIVATE:
            strTransationType = @"DEACTIVATE";
            break;
            
        case TRANSACTIONTYPEREPLACE:
            strTransationType = @"REPLACE";
            break;
            
        case TRANSACTIONTYPEMERGE:
            strTransationType = @"MERGE";
            break;
            
        case TRANSACTIONTYPEREPORTLOST:
            strTransationType = @"REPORTLOST";
            break;
            
        case TRANSACTIONTYPEVOID:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVSALE:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVRTRN:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVAUTH:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVPOST:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVFRCD:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVWITHDRAW:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEBALANCE:
            strTransationType = @"BALANCE";
            break;
            
        case TRANSACTIONTYPEVERIFY:
            strTransationType = @"VERIFY";
            break;
            
        case TRANSACTIONTYPEREACTIVATE:
            strTransationType = @"REACTIVATE";
            break;
            
        case TRANSACTIONTYPEFORCEDISSUE:
            strTransationType = @"FORCED ISSUE";
            break;
            
        case TRANSACTIONTYPEFORCEDADD:
            strTransationType = @"FORCED ADD";
            break;
            
        case TRANSACTIONTYPEUNLOAD:
            strTransationType = @"UNLOAD";
            break;
            
        case TRANSACTIONTYPERENEW:
            strTransationType = @"RENEW";
            break;
            
        case TRANSACTIONTYPEGETCONVERTDETAIL:
            strTransationType = @"GET CONVERT DETAIL";
            break;
            
        case TRANSACTIONTYPECONVERT:
            strTransationType = @"CONVERT";
            break;
            
        case TRANSACTIONTYPETOKENIZE:
            strTransationType = @"TOKENIZE";
            break;
            
        case TRANSACTIONTYPEREVERSAL:
            strTransationType = @"REVERSAL";
            break;
            
        default:
            break;
    }
    return strTransationType;
}

#pragma mark - Void Transation For Pax

-(void)paxVoidTransactionProcessWithDictionary:(NSDictionary *)creditDictionary
{
    NSString *registerInvoiceNo = [NSString stringWithFormat:@"%@",[creditDictionary valueForKey:@"RegisterInvNo"]];
    NSDate *date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HHmmss";
    NSString *strDate = [formatter stringFromDate:date];
    NSString *currentCreditTransactionId = [NSString stringWithFormat:@"%@%@",registerInvoiceNo,strDate];
    if (creditDictionary) {
        if (creditDictionary[@"TransactionNo"]) {
            [paxReportDetailDevice voidCreditTransactionNumber:creditDictionary[@"TransactionNo"] invoiceNumber:registerInvoiceNo referenceNumber:currentCreditTransactionId];
        }
    }
}

#pragma mark - Force Transation For Pax

- (void)paxForceTransactionProcessWithDictionary:(NSDictionary *)creditDictionary withCaptureAmt:(NSString *)strCaptureAmt{
    [paxReportDetailDevice doCreditCaptureWithAmount:[strCaptureAmt floatValue] withInvoiceNumber:creditDictionary[@"RegisterInvNo"] referenceNumber:creditDictionary[@"RegisterInvNo"] transactionNumber:creditDictionary[@"TransactionNo"] withAuthCode:creditDictionary[@"AuthCode"]];
}

@end
