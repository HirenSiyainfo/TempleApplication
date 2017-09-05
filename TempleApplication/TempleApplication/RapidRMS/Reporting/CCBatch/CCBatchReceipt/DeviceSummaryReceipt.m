//
//  DeviceSummaryReceipt.m
//  RapidRMS
//
//  Created by Siya-mac5 on 05/08/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "DeviceSummaryReceipt.h"
#import "RmsDbController.h"
#import "NSString+Methods.h"

@interface DeviceSummaryReceipt ()
{
    NSArray *cCBatchDetailsArray;
    NSArray *arrPaxReportEnum;

    RmsDbController *rmsDbController;
    PaymentGateWay paymentGateWay;
}

@end

@implementation DeviceSummaryReceipt

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings receiptData:(NSArray *)receiptDataArray paymentGateWay:(PaymentGateWay)selectedPaymentGateWay receiptTitle:(NSString *)title filterDetails:(NSDictionary *)filterDetailsDictionary {
    self = [super initWithPortName:portName portSetting:portSettings receiptData:receiptDataArray receiptTitle:title filterDetails:filterDetailsDictionary];
    if (self) {
        rmsDbController = [RmsDbController sharedRmsDbController];
        cCBatchDetailsArray = [receiptDataArray copy];
        arrPaxReportEnum = @[@(PaxLocalTotalReportCredit),@(PaxLocalTotalReportDebit),@(PaxLocalTotalReportEBT)];
        paymentGateWay = selectedPaymentGateWay;
    }
    return self;
}

- (void)configureRecieptSections {
    //// section detail
    _sections = @[
                  @(ReceiptSectionHeader),
                  @(ReceiptSectionCCBatchInfo),
                  @(ReceiptSectionCCBatchDetails),
                  @(ReceiptSectionFooter),
                  ];
    
    NSArray *receiptSectionHeaderFields = @[
                                            @(ReceiptFieldStoreName),
                                            @(ReceiptFieldStoreAddress),
                                            @(ReceiptFieldStoreEmailAndPhoneNumber),
                                            @(ReceiptFieldTitle),
                                            @(ReceiptFieldUserNameAndRegister),
                                            @(ReceiptFieldCurrentDate),
                                            ];
    
    NSArray *receiptSectionCCBatchInfoFields = @[
                                                 @(ReceiptFieldPaymentGateWay),
                                                 @(ReceiptFieldTotalAmount),
                                                 @(ReceiptFieldTotalTransactions),
                                                 ];
    
    NSArray *receiptSectionCCBatchDetailsFields = @[
                                                    @(ReceiptFieldCardPaymentDetails),
                                                    ];
    
    NSArray *receiptSectionFooterFields = @[
                                            ];
    /// field detail
    _fields = @[
                receiptSectionHeaderFields,
                receiptSectionCCBatchInfoFields,
                receiptSectionCCBatchDetailsFields,
                receiptSectionFooterFields,
                ];
}

- (void)printTotalAmount {
    [self defaultFormatForReceipt];
    NSString *totalAmount = [self totalAmountForDeviceSummary];
    [_printJob printText1:@"Total Amount:" text2:totalAmount];
}

- (NSString *)totalAmountForDeviceSummary {
    NSString *totalAmount;
    switch (paymentGateWay) {
        case BridgePay: {
            totalAmount = [NSString stringWithFormat:@"%@",[self totalAmountForBridgePay]];
            break;
        }
        case Pax: {
            totalAmount = [NSString stringWithFormat:@"%@",[self totalAmountForPax]];
            break;
        }
    }
    return totalAmount;
}

- (NSString *)totalAmountForBridgePay {
    float totalAmount = 0.00;
    NSArray *salesTransactions = [self salesTransactionsForBridgePayFromArray:cCBatchDetailsArray];
    NSArray *authTransactions = [self authTransactionsForBridgePayFromArray:cCBatchDetailsArray];
    NSArray *forceTransactions = [self forceTransactionsForBridgePayFromArray:cCBatchDetailsArray];
    NSArray *refundTransactions = [self refundTransactionsForBridgePayFromArray:cCBatchDetailsArray];
    if (refundTransactions && refundTransactions.count > 0) {
        totalAmount =  [[salesTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue] + [[authTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue] + [[forceTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue] - [[refundTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
    }
    NSString *strTotalAmount = [NSString stringWithFormat:@"%.2f", totalAmount];
    return [strTotalAmount applyCurrencyFormatter:strTotalAmount.floatValue];
}

- (NSArray *)salesTransactionsForBridgePayFromArray:(NSArray *)array {
    NSPredicate *salesPredicate = [self predicateTransactionwith:@"Sale"];
    return [array filteredArrayUsingPredicate:salesPredicate];
}
- (NSArray *)authTransactionsForBridgePayFromArray:(NSArray *)array {
    NSPredicate *authPredicate = [self predicateTransactionwith:@"Authorization"];
    return [array filteredArrayUsingPredicate:authPredicate];
}

- (NSArray *)forceTransactionsForBridgePayFromArray:(NSArray *)array {
    NSPredicate *forcePredicate = [self predicateTransactionwith:@"ForceCapture"];
    return [array filteredArrayUsingPredicate:forcePredicate];
}

- (NSArray *)refundTransactionsForBridgePayFromArray:(NSArray *)array {
    NSPredicate *refundPredicate = [self predicateForRefundTransaction];
    return [array filteredArrayUsingPredicate:refundPredicate];
}

- (NSPredicate *)predicateTransactionwith:(NSString *)strTransType{
    return [NSPredicate predicateWithFormat:@"VoidSaleTrans  ==  %@ AND TransType == %@", @"0" ,strTransType ];
}

- (NSPredicate *)predicateForRefundTransaction {
    return [NSPredicate predicateWithFormat:@"TransType IN %@",@"Credit"];
}

- (NSString *)totalAmountForPax {
    float totalAmount = 0.00;
    for (int index = 0; index < arrPaxReportEnum.count; index++) {
        totalAmount = totalAmount + [self calculateTotalAmount:index];
    }
    NSString *strTotalAmount = [NSString stringWithFormat:@"%.2f", totalAmount];
    return [strTotalAmount applyCurrencyFormatter:strTotalAmount.floatValue];
}

- (float)calculateTotalAmount:(NSInteger)index {
    float salesAmount = [[cCBatchDetailsArray[index] valueForKey:@"SaleAmount"] floatValue];
    float authAmount = [[cCBatchDetailsArray[index] valueForKey:@"authAmount"] floatValue] ;
    float forceAmount = [[cCBatchDetailsArray[index] valueForKey:@"forcedAmount"] floatValue] ;
    float postAuthAmount = [[cCBatchDetailsArray[index] valueForKey:@"postauthAmount"] floatValue];
    float returnAmount = [[cCBatchDetailsArray[index] valueForKey:@"returnAmount"] floatValue];
    
    float totalAmount = salesAmount + authAmount + forceAmount + postAuthAmount - returnAmount;
    return totalAmount;
}

- (void)printTotalTransactions {
    [self defaultFormatForReceipt];
    NSString *totalCount= [self totalCountForDeviceSummary];
    [_printJob printText1:@"Total Count:" text2:totalCount];
}

- (NSString *)totalCountForDeviceSummary {
    NSString *totalCount;
    switch (paymentGateWay) {
        case BridgePay: {
            NSArray *salesTransactions = [self salesTransactionsForBridgePayFromArray:cCBatchDetailsArray];
            NSArray *authTransactions = [self authTransactionsForBridgePayFromArray:cCBatchDetailsArray];
            NSArray *forceTransactions = [self forceTransactionsForBridgePayFromArray:cCBatchDetailsArray];
            NSArray *refundTransactions = [self refundTransactionsForBridgePayFromArray:cCBatchDetailsArray];
            totalCount = [NSString stringWithFormat:@"%ld",(long)(salesTransactions.count+ authTransactions.count + forceTransactions.count + refundTransactions.count)];
            break;
        }
        case Pax: {
            totalCount = [NSString stringWithFormat:@"%ld",(long)[self totalCountForPax]];
            break;
        }
    }
    return totalCount;
}

- (NSInteger)totalCountForPax {
    NSInteger totalCount = 0;
    for (int index = 0; index < arrPaxReportEnum.count; index++) {
        totalCount = totalCount + [self calculateTotalCount:index];
    }
    return totalCount;
}

- (NSInteger)calculateTotalCount:(NSInteger)index {
    NSInteger totalCountInt = [[cCBatchDetailsArray[index] valueForKey:@"saleCount"] integerValue] + [[cCBatchDetailsArray[index] valueForKey:@"authCount"] integerValue] + [[cCBatchDetailsArray[index] valueForKey:@"forcedCount"] integerValue] + [[cCBatchDetailsArray[index] valueForKey:@"postauthCount"] integerValue] + [[cCBatchDetailsArray[index] valueForKey:@"returnCount"] integerValue];
    return totalCountInt;
}

- (void)printCardPaymentDetails {
    [self printCardPaymentTitle];
    switch (paymentGateWay) {
        case BridgePay: {
            [self printCardTypeDetailsForBridgePay];
            break;
        }
        case Pax: {
            [self printPaymentTypeDetailsForPax];
            break;
        }
    }
}

- (void)printCardPaymentTitle {
    NSString *title = [self cardPaymentTitle];
    [_printJob enableBold:YES];
    [self printCardType:title];
    [self printTotal:@"" totalTransactions:@"Amount" avgTicket:@"Count"];
    [_printJob enableBold:NO];
}

- (NSString *)cardPaymentTitle {
    NSString *title = @"";
    switch (paymentGateWay) {
        case BridgePay: {
            title = @"CardType";
            break;
        }
        case Pax: {
            title = @"PaymentType";
            break;
        }
    }
    return title;
}

- (void)printCardTypeDetailsForBridgePay {
    NSArray *arrCardType = [cCBatchDetailsArray valueForKeyPath:@"@distinctUnionOfObjects.CardType"];
    for (NSString *cardType in arrCardType)
    {
        [_printJob enableBold:YES];
        [self printCardType:cardType];
        [_printJob enableBold:NO];
        NSPredicate *cardTypePredicate = [NSPredicate predicateWithFormat:@"CardType == %@",cardType];
        NSArray *filteredTransactionArray = [cCBatchDetailsArray filteredArrayUsingPredicate:cardTypePredicate];
        NSArray *salesTransactions = [self salesTransactionsForBridgePayFromArray:filteredTransactionArray];
        NSArray *authTransactions = [self authTransactionsForBridgePayFromArray:filteredTransactionArray];
        NSArray *forceTransactions = [self forceTransactionsForBridgePayFromArray:filteredTransactionArray];
        NSArray *refundTransactions = [self refundTransactionsForBridgePayFromArray:filteredTransactionArray];
      
        CGFloat salesAmount = [[salesTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
        NSString *totalSalesAmount = [NSString stringWithFormat:@"%.2f",salesAmount];
        NSString *totalSalesCount = [NSString stringWithFormat:@"%lu",(unsigned long)salesTransactions.count];
       
        CGFloat authsAmount = [[authTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
        NSString *totalAuthAmount = [NSString stringWithFormat:@"%.2f",authsAmount];
        NSString *totalAuthCount = [NSString stringWithFormat:@"%lu",(unsigned long)authTransactions.count];
        
        CGFloat forceAmount = [[forceTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
        NSString *totalForceAmount = [NSString stringWithFormat:@"%.2f",forceAmount];
        NSString *totalForceCount = [NSString stringWithFormat:@"%lu",(unsigned long)forceTransactions.count];
       
        NSString *totalPostAuthAmount = @"$0.00";
        NSString *totalPostAuthCount = @"0";
        
        NSString *totalRefundAmount = [NSString stringWithFormat:@"%@",[[refundTransactions valueForKeyPath:@"@sum.BillAmount"] stringValue]];
        NSString *totalRefundCount = [NSString stringWithFormat:@"%lu",(unsigned long)refundTransactions.count];


        NSString *strTotalAmount = [NSString stringWithFormat:@"%.2f", (totalSalesAmount.floatValue + totalAuthAmount.floatValue + totalForceAmount.floatValue - totalRefundAmount.floatValue)];

        NSString *totalReturnAmount;
        if (totalRefundAmount.floatValue > 0) {
            totalReturnAmount = [NSString stringWithFormat:@"-%@", [totalRefundAmount applyCurrencyFormatter:totalRefundAmount.floatValue]];
        }
        else {
            totalReturnAmount = @"$0.00";
        }
        
        
        NSString *totalAmount = [strTotalAmount applyCurrencyFormatter:strTotalAmount.floatValue];
        NSString *totalCount = [NSString stringWithFormat:@"%lu",(unsigned long)(salesTransactions.count + authTransactions.count + forceTransactions.count + refundTransactions.count)];
     
        totalSalesAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:totalSalesAmount]];
        totalAuthAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:totalAuthAmount]];
        totalForceAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:totalForceAmount]];
        totalRefundAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:totalRefundAmount]];

        [self printType:@"Sales" amount:totalSalesAmount count:totalSalesCount];
        [self printType:@"Auth" amount:totalAuthAmount count:totalAuthCount];
        [self printType:@"Force" amount:totalForceAmount count:totalForceCount];
        [self printType:@"PostAuth" amount:totalPostAuthAmount count:totalPostAuthCount];
        [self printType:@"Return" amount:totalReturnAmount count:totalRefundCount];
        [_printJob enableBold:YES];
        [self printType:@"Total" amount:totalAmount count:totalCount];
        [_printJob printLine:@""];
        [_printJob enableBold:NO];
    }
}

- (void)printType:(NSString *)type amount:(NSString *)amount count:(NSString *)count {
    [self defaultFormatForThreeColumn];
    [_printJob printText1:type text2:amount text3:count];
}

- (void)printPaymentTypeDetailsForPax {
    for (int index = 0; index < arrPaxReportEnum.count; index++) {
        NSString *paymentType = [[self paymentType:[arrPaxReportEnum[index] integerValue]] uppercaseString];
        [_printJob enableBold:YES];
        [self printCardType:paymentType];
        [_printJob enableBold:NO];
       
        NSString *salesAmount = [NSString stringWithFormat:@"%.2f",[[cCBatchDetailsArray[index] valueForKey:@"SaleAmount"] floatValue]];
        salesAmount = [salesAmount applyCurrencyFormatter:salesAmount.floatValue];
        NSString *salesCount = [[cCBatchDetailsArray[index] valueForKey:@"saleCount"] stringValue];
       
        NSString *authAmount = [NSString stringWithFormat:@"%.2f",[[cCBatchDetailsArray[index] valueForKey:@"authAmount"] floatValue]];
        authAmount = [authAmount applyCurrencyFormatter:authAmount.floatValue];
        NSString *authCount = [[cCBatchDetailsArray[index] valueForKey:@"authCount"] stringValue];
        if ([cCBatchDetailsArray[index] valueForKey:@"authCount"] == nil) {
            authCount = @"0";
        }

        NSString *forceAmount = [NSString stringWithFormat:@"%.2f",[[cCBatchDetailsArray[index] valueForKey:@"forcedAmount"] floatValue]];
        forceAmount = [forceAmount applyCurrencyFormatter:forceAmount.floatValue];
        NSString *forceCount = [[cCBatchDetailsArray[index] valueForKey:@"forcedCount"] stringValue];
        if ([cCBatchDetailsArray[index] valueForKey:@"forcedCount"] == nil) {
            forceCount = @"0";
        }

        NSString *postAuthAmount = [NSString stringWithFormat:@"%.2f",[[cCBatchDetailsArray[index] valueForKey:@"postauthAmount"] floatValue]];
        postAuthAmount = [postAuthAmount applyCurrencyFormatter:postAuthAmount.floatValue];
        NSString *postAuthCount = [[cCBatchDetailsArray[index] valueForKey:@"postauthCount"] stringValue];
        if ([cCBatchDetailsArray[index] valueForKey:@"postauthCount"] == nil) {
            postAuthCount = @"0";
        }

        NSString *returnAmount = @"";
        if ([[cCBatchDetailsArray[index] valueForKey:@"returnAmount"] floatValue] == 0) {
            returnAmount = @"$0.00";
        }
        else {
            returnAmount = [NSString stringWithFormat:@"-%.2f",[[cCBatchDetailsArray[index] valueForKey:@"returnAmount"] floatValue]];
            returnAmount = [returnAmount applyCurrencyFormatter:returnAmount.floatValue];
        }
        NSString *returnCount = [[cCBatchDetailsArray[index] valueForKey:@"returnCount"] stringValue];
    
        NSString *totalAmount = [self totalAmountFor:index];
        NSString *totalCount = [self totalCountFor:index];
        
        [self printType:@"Sales" amount:salesAmount count:salesCount];
        [self printType:@"Auth" amount:authAmount count:authCount];
        [self printType:@"Force" amount:forceAmount count:forceCount];
        [self printType:@"postAuth" amount:postAuthAmount count:postAuthCount];
        [self printType:@"Return" amount:returnAmount count:returnCount];
        
        [_printJob enableBold:YES];
        [self printType:@"Total" amount:totalAmount count:totalCount];
        [_printJob printLine:@""];
        [_printJob enableBold:NO];
    }
}

- (NSString *)paymentType:(PaxLocalTotalReportDetails)paymentTypeField {
    PaxLocalTotalReportDetails paxLocalTotalReportDetails = paymentTypeField;
    NSString *paymentType = @"";
    
    switch (paxLocalTotalReportDetails) {
        case PaxLocalTotalReportCredit:
            paymentType = @"Credit";
            break;
        case PaxLocalTotalReportDebit:
            paymentType = @"Debit";
            
            break;
        case PaxLocalTotalReportEBT:
            paymentType = @"EBT";
            
            break;
        case PaxLocalTotalReportGift:
            paymentType = @"Gift";
            
            break;
        case PaxLocalTotalReportLOYALTY:
            paymentType = @"Loyalty";
            
            break;
        case PaxLocalTotalReportCASH:
            paymentType = @"Cash";
            
            break;
        case PaxLocalTotalReportCHECK:
            paymentType = @"Check";
            
            break;
        default:
            break;
    }
    
    return paymentType;
}

- (NSString *)totalAmountFor:(NSInteger)paymentTypeIndex {
    NSString *totalAmount = @"";
    totalAmount = [NSString stringWithFormat:@"%.2f", [self calculateTotalAmount:paymentTypeIndex]];
    totalAmount = [totalAmount applyCurrencyFormatter:totalAmount.floatValue];
    return totalAmount;
}

- (NSString *)totalCountFor:(NSInteger)paymentTypeIndex {
    NSString *totalCount = @"";
    NSInteger totalCountInt = [self calculateTotalCount:paymentTypeIndex];
    totalCount = [NSString stringWithFormat:@"%ld", (long)totalCountInt];
    return totalCount;
}

#pragma mark - Html For Fields

- (NSString *)htmlForTotalAmount {
    NSString *htmlForTotalAmount = @"";
    NSString *totalAmount = [self totalAmountForDeviceSummary];
    htmlForTotalAmount = [htmlForTotalAmount stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForTotalAmount = [htmlForTotalAmount stringByAppendingFormat:@"<div style=\"float:left;\">%@</div>",@"Total Amount:"];
    htmlForTotalAmount = [htmlForTotalAmount stringByAppendingFormat:@"<div style=\"float:right; text-align:right;\">%@</div></div>",totalAmount];
    return htmlForTotalAmount;
}

- (NSString *)htmlForTotalTransactions {
    NSString *htmlForTotalTransactions = @"";
    NSString *totalCount = [self totalCountForDeviceSummary];
    htmlForTotalTransactions = [htmlForTotalTransactions stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForTotalTransactions = [htmlForTotalTransactions stringByAppendingFormat:@"<div style=\"float:left;\">%@</div>",@"Total Count:"];
    htmlForTotalTransactions = [htmlForTotalTransactions stringByAppendingFormat:@"<div style=\"float:right; text-align:right;\">%@</div></div></div></div>",totalCount];
    return htmlForTotalTransactions;
}

- (NSString *)htmlForCardPaymentDetails {
    NSString *htmlForCardPaymentDetails = @"";
    NSString *title = [self cardPaymentTitle];
    NSString *titleHtml = [self htmlCardPaymentDetailsWithText1:title text2:@"" text3:@"" enableBold:YES];
    NSString *headerHtml = [self htmlCardPaymentDetailsWithText1:@"" text2:@"Amount" text3:@"Count" enableBold:YES];
    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:titleHtml];
    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:headerHtml];
    NSString *cardPaymentHtml = @"";
    switch (paymentGateWay) {
        case BridgePay: {
           cardPaymentHtml = [self htmlForCardTypeDetailsForBridgePay];
            break;
        }
        case Pax: {
          cardPaymentHtml = [self htmlForPaymentTypeDetailsForPax];
            break;
        }
    }
    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardPaymentHtml];
    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:@"</tbody></table></div>"];
    return htmlForCardPaymentDetails;
}

- (NSString *)htmlForCardTypeDetailsForBridgePay {
    NSString *htmlForCardPaymentDetails = @"";
    NSArray *arrCardType = [cCBatchDetailsArray valueForKeyPath:@"@distinctUnionOfObjects.CardType"];
    for (NSString *cardType in arrCardType)
    {
        NSString *cardTypeHtml = [self htmlCardPaymentDetailsWithText1:cardType text2:@"" text3:@"" enableBold:YES];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardTypeHtml];
        NSPredicate *cardTypePredicate = [NSPredicate predicateWithFormat:@"CardType == %@",cardType];
        NSArray *filteredTransactionArray = [cCBatchDetailsArray filteredArrayUsingPredicate:cardTypePredicate];
      
        NSArray *salesTransactions = [self salesTransactionsForBridgePayFromArray:filteredTransactionArray];
        NSArray *authTransactions = [self authTransactionsForBridgePayFromArray:filteredTransactionArray];
        NSArray *forceTransactions = [self forceTransactionsForBridgePayFromArray:filteredTransactionArray];
        NSArray *refundTransactions = [self refundTransactionsForBridgePayFromArray:filteredTransactionArray];
        
        CGFloat salesAmount = [[salesTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
        NSString *totalSalesAmount = [NSString stringWithFormat:@"%.2f",salesAmount];
        NSString *totalSalesCount = [NSString stringWithFormat:@"%lu",(unsigned long)salesTransactions.count];
        
        CGFloat authsAmount = [[authTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
        NSString *totalAuthAmount = [NSString stringWithFormat:@"%.2f",authsAmount];
        NSString *totalAuthCount = [NSString stringWithFormat:@"%lu",(unsigned long)authTransactions.count];
        
        CGFloat forceAmount = [[forceTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
        NSString *totalForceAmount = [NSString stringWithFormat:@"%.2f",forceAmount];
        NSString *totalForceCount = [NSString stringWithFormat:@"%lu",(unsigned long)forceTransactions.count];
        
        NSString *totalPostAuthAmount = @"$0.00";
        NSString *totalPostAuthCount = @"0";
        
        NSString *totalRefundAmount = [NSString stringWithFormat:@"%@",[[refundTransactions valueForKeyPath:@"@sum.BillAmount"] stringValue]];
        NSString *totalRefundCount = [NSString stringWithFormat:@"%lu",(unsigned long)refundTransactions.count];
        
        NSString *totalReturnAmount;
        if (totalRefundAmount.floatValue > 0) {
            totalReturnAmount = [NSString stringWithFormat:@"-%@", [totalRefundAmount applyCurrencyFormatter:totalRefundAmount.floatValue]];
        }
        else {
            totalReturnAmount = @"$0.00";
        }

        float totalTransAmount = totalSalesAmount.floatValue + totalAuthAmount.floatValue + totalForceAmount.floatValue - totalRefundAmount.floatValue;
        NSString *strTotalAmount = [NSString stringWithFormat:@"%.2f", totalTransAmount];
        
        NSString *totalAmount = [strTotalAmount applyCurrencyFormatter:strTotalAmount.floatValue];
        NSString *totalCount = [NSString stringWithFormat:@"%lu",(unsigned long)(salesTransactions.count + authTransactions.count + forceTransactions.count + refundTransactions.count)];
        
        totalSalesAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:totalSalesAmount]];
        totalAuthAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:totalAuthAmount]];
        totalForceAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:totalForceAmount]];
        totalRefundAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:totalRefundAmount]];

        NSString *cardPaymentSalesHtml = [self htmlCardPaymentDetailsWithText1:@"Sales" text2:totalSalesAmount text3:totalSalesCount enableBold:NO];
        NSString *cardPaymentAuthsHtml = [self htmlCardPaymentDetailsWithText1:@"Auth" text2:totalAuthAmount text3:totalAuthCount enableBold:NO];
        NSString *cardPaymentForceHtml = [self htmlCardPaymentDetailsWithText1:@"Force" text2:totalForceAmount text3:totalForceCount enableBold:NO];
        NSString *cardPaymentPostAuthHtml = [self htmlCardPaymentDetailsWithText1:@"PostAuth" text2:totalPostAuthAmount text3:totalPostAuthCount enableBold:NO];
        NSString *cardPaymentReturnHtml = [self htmlCardPaymentDetailsWithText1:@"Return" text2:totalReturnAmount text3:totalRefundCount enableBold:NO];
        NSString *cardPaymentTotalHtml = [self htmlCardPaymentDetailsWithText1:@"Total" text2:totalAmount text3:totalCount enableBold:YES];
        
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardPaymentSalesHtml];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardPaymentAuthsHtml];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardPaymentForceHtml];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardPaymentPostAuthHtml];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardPaymentReturnHtml];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardPaymentTotalHtml];
    }
    return htmlForCardPaymentDetails;
}

- (NSString *)htmlForPaymentTypeDetailsForPax {
    NSString *htmlForCardPaymentDetails = @"";
    for (int index = 0; index < arrPaxReportEnum.count; index++) {
        NSString *paymentType = [[self paymentType:[arrPaxReportEnum[index] integerValue]] uppercaseString];
        NSString *paymentTypeHtml = [self htmlCardPaymentDetailsWithText1:paymentType text2:@"" text3:@"" enableBold:YES];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:paymentTypeHtml];
        
        NSString *salesAmount = [NSString stringWithFormat:@"%.2f",[[cCBatchDetailsArray[index] valueForKey:@"SaleAmount"] floatValue]];
        salesAmount = [salesAmount applyCurrencyFormatter:salesAmount.floatValue];
        NSString *salesCount = [[cCBatchDetailsArray[index] valueForKey:@"saleCount"] stringValue];
        
        NSString *authAmount = [NSString stringWithFormat:@"%.2f",[[cCBatchDetailsArray[index] valueForKey:@"authAmount"] floatValue]];
        authAmount = [authAmount applyCurrencyFormatter:authAmount.floatValue];
        NSString *authCount = [[cCBatchDetailsArray[index] valueForKey:@"authCount"] stringValue];
        if ([cCBatchDetailsArray[index] valueForKey:@"authCount"] == nil) {
            authCount = @"0";
        }

        NSString *forceAmount = [NSString stringWithFormat:@"%.2f",[[cCBatchDetailsArray[index] valueForKey:@"forcedAmount"] floatValue]];
        forceAmount = [forceAmount applyCurrencyFormatter:forceAmount.floatValue];
        NSString *forceCount = [[cCBatchDetailsArray[index] valueForKey:@"forcedCount"] stringValue];
        if ([cCBatchDetailsArray[index] valueForKey:@"forcedCount"] == nil) {
            forceCount = @"0";
        }

        NSString *postAuthAmount = [NSString stringWithFormat:@"%.2f",[[cCBatchDetailsArray[index] valueForKey:@"postauthAmount"] floatValue]];
        postAuthAmount = [postAuthAmount applyCurrencyFormatter:postAuthAmount.floatValue];
        NSString *postAuthCount = [[cCBatchDetailsArray[index] valueForKey:@"postauthCount"] stringValue];
        if ([cCBatchDetailsArray[index] valueForKey:@"postauthCount"] == nil) {
            postAuthCount = @"0";
        }

        NSString *returnAmount = @"";
        if ([[cCBatchDetailsArray[index] valueForKey:@"returnAmount"] floatValue] == 0) {
            returnAmount = @"$0.00";
        }
        else {
            returnAmount = [NSString stringWithFormat:@"-%.2f",[[cCBatchDetailsArray[index] valueForKey:@"returnAmount"] floatValue]];
            returnAmount = [returnAmount applyCurrencyFormatter:returnAmount.floatValue];
        }
        NSString *returnCount = [[cCBatchDetailsArray[index] valueForKey:@"returnCount"] stringValue];
       
        NSString *totalAmount = [self totalAmountFor:index];
        NSString *totalCount = [self totalCountFor:index];
        
        NSString *paymentTypeSalesHtml = [self htmlCardPaymentDetailsWithText1:@"Sales" text2:salesAmount text3:salesCount enableBold:NO];
        NSString *paymentTypeAuthHtml = [self htmlCardPaymentDetailsWithText1:@"Auth" text2:authAmount text3:authCount enableBold:NO];
        NSString *paymentTypeForceHtml = [self htmlCardPaymentDetailsWithText1:@"Force" text2:forceAmount text3:forceCount enableBold:NO];
        NSString *paymentTypePostAuthHtml = [self htmlCardPaymentDetailsWithText1:@"PostAuth" text2:postAuthAmount text3:postAuthCount enableBold:NO];
        NSString *paymentTypeReturnHtml = [self htmlCardPaymentDetailsWithText1:@"Return" text2:returnAmount text3:returnCount enableBold:NO];
        
        NSString *paymentTypeTotalHtml = [self htmlCardPaymentDetailsWithText1:@"Total" text2:totalAmount text3:totalCount enableBold:YES];
        
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:paymentTypeSalesHtml];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:paymentTypeAuthHtml];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:paymentTypeForceHtml];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:paymentTypePostAuthHtml];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:paymentTypeReturnHtml];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:paymentTypeTotalHtml];
    }
    return htmlForCardPaymentDetails;
}

@end
