//
//  CurrentTransactionReceipt.m
//  RapidRMS
//
//  Created by Siya-mac5 on 29/08/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CurrentTransactionReceipt.h"

@interface CurrentTransactionReceipt ()
{
    RmsDbController *rmsDbController;
    CCBatchTrnxDetailStruct *cCBatchTrnxDetails;
    PaymentGateWay paymentGateWay;
    
    NSArray *ccTransactionsArray;
}

@property (strong, nonatomic) NSNumber *isTipsApplicable;

@end

@implementation CurrentTransactionReceipt

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings receiptData:(NSArray *)receiptDataArray paymentGateWay:(PaymentGateWay)selectedPaymentGateWay receiptTitle:(NSString *)title cCBatchTrnxDetail:(CCBatchTrnxDetailStruct*)cCBatchTrnxDetail isTipsApplicable:(NSNumber *)isTipsApplicable filterDetails:(NSDictionary *)filterDetailsDictionary {
    self = [super initWithPortName:portName portSetting:portSettings receiptData:receiptDataArray receiptTitle:title filterDetails:filterDetailsDictionary];
    if (self) {
        ccTransactionsArray = [receiptDataArray copy];
        paymentGateWay = selectedPaymentGateWay;
        cCBatchTrnxDetails = cCBatchTrnxDetail;
        self.isTipsApplicable = isTipsApplicable;
        rmsDbController = [RmsDbController sharedRmsDbController];
    }
    return self;
}

- (void)configureRecieptSections {
    //// section detail
    _sections = @[
                  @(ReceiptSectionHeader),
                  @(ReceiptSectionCCBatchFilterInfo),
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
                                            @(ReceiptFieldPaymentGateWay),
                                            ];
    NSArray *receiptSectionCCBatchFilterInfo = @[
                                                 @(ReceiptFieldRegisterWiseFilter),
                                                 @(ReceiptFieldCradTypeWiseFilter),
                                                 ];

    NSArray *receiptSectionCCBatchInfoFields = @[
                                                 @(ReceiptFieldCommonHeader),
                                                 ];
    
    NSArray *receiptSectionCCBatchDetailsFields = @[
                                                    @(ReceiptFieldCardPaymentDetails),
                                                    ];
    
    NSArray *receiptSectionFooterFields = @[
                                            ];
    /// field detail
    _fields = @[
                receiptSectionHeaderFields,
                receiptSectionCCBatchFilterInfo,
                receiptSectionCCBatchInfoFields,
                receiptSectionCCBatchDetailsFields,
                receiptSectionFooterFields,
                ];
}

#pragma mark - Html For Section Header

- (NSString *)htmlHeaderForReceiptSectionHeader {
    NSString *htmlHeaderForReceiptSectionHeader = [[NSString alloc] initWithFormat:@"<!doctype html> <html> $$STYLE$$ <body>"];
    htmlHeaderForReceiptSectionHeader = [htmlHeaderForReceiptSectionHeader stringByAppendingFormat:@"<div style=\"width:1000px; font-family:Helvetica Neue; font-size:14px; margin:auto;\">"];
    htmlHeaderForReceiptSectionHeader = [htmlHeaderForReceiptSectionHeader stringByAppendingFormat:@"<div style=\"width:100%%;  float:left;  padding-bottom:10px; \">"];
    htmlHeaderForReceiptSectionHeader = [htmlHeaderForReceiptSectionHeader stringByAppendingFormat:@"<table style=\"font-family:Helvetica Neue;width:1000px;font-size:16px;padding-top:8px;padding-bottom:8px;padding-right:12px;padding-left:12px;\"><tbody>"];
    return htmlHeaderForReceiptSectionHeader;
}

- (NSString *)htmlHeaderForReceiptSectionCCBatchInfo {
    NSString *htmlHeaderForReceiptSectionCCBatchInfo = @"";
    htmlHeaderForReceiptSectionCCBatchInfo = [htmlHeaderForReceiptSectionCCBatchInfo stringByAppendingString:@"<table width=\"1000\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"> <tbody>"];
    return htmlHeaderForReceiptSectionCCBatchInfo;
}

- (NSString *)htmlHeaderForReceiptSectionCCBatchDetails {
    NSString *htmlHeaderForReceiptSectionCCBatchDetails = @"";
    return htmlHeaderForReceiptSectionCCBatchDetails;
}

#pragma mark - Html For Fields

- (NSString *)htmlForUserNameAndRegister {
    NSString *htmlForUserNameAndRegister = @"";
    htmlForUserNameAndRegister = [htmlForUserNameAndRegister stringByAppendingFormat:@"<div style=\"width:100%%; float:left; border-bottom:dashed 1px #000; padding-bottom:10px; font-size:16px; \">"];
    htmlForUserNameAndRegister = [htmlForUserNameAndRegister stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForUserNameAndRegister = [htmlForUserNameAndRegister stringByAppendingFormat:@"<div style=\"float:left;\">%@</div>",@"User #:"];
    NSString *strUserName = [NSString stringWithFormat:@"%@",[self userInfoValueForKeyIndex:ReceiptDataKeyUserName]];
    NSString *strRegister = [NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"RegisterName"]];
    htmlForUserNameAndRegister = [htmlForUserNameAndRegister stringByAppendingFormat:@"<div style=\"float:left; text-align:left;\">%@</div>",strUserName];
    htmlForUserNameAndRegister = [htmlForUserNameAndRegister stringByAppendingFormat:@"<div style=\"float:right\">"];
    htmlForUserNameAndRegister = [htmlForUserNameAndRegister stringByAppendingFormat:@"<div style=\"float:right; text-align:left;\">%@</div>",strRegister];
    htmlForUserNameAndRegister = [htmlForUserNameAndRegister stringByAppendingFormat:@"<div style=\"float:right; \">%@</div></div></div>",@"Register #:"];
    return htmlForUserNameAndRegister;
}

- (NSString *)htmlForCurrentDate {
    NSString *htmlForCurrentDate = @"";
    htmlForCurrentDate = [htmlForCurrentDate stringByAppendingFormat:@"<div style=\"float:left;\">"];
    NSString *currentDate = [self currentDateTime];
    htmlForCurrentDate = [htmlForCurrentDate stringByAppendingFormat:@"<div style=\"float:right; text-align:left;\">%@</div>",currentDate];
    htmlForCurrentDate = [htmlForCurrentDate stringByAppendingFormat:@"<div style=\"float:right;\">%@</div></div>",@"Current Date:"];
    return htmlForCurrentDate;
}

- (NSString *)htmlForPaymentGateWay {
    NSString *htmlForPaymentGateWay = @"";
    htmlForPaymentGateWay = [htmlForPaymentGateWay stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForPaymentGateWay = [htmlForPaymentGateWay stringByAppendingFormat:@"<div style=\"float:left; font-size:16px;\">%@</div>",@"Payment GateWay:"];
    htmlForPaymentGateWay = [htmlForPaymentGateWay stringByAppendingFormat:@"<div style=\"float:right; font-size:16px; text-align:right;\">%@</div></div></div>",[rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"]];
    return htmlForPaymentGateWay;
}

- (NSString *)htmlForCommonHeader {
    NSString *htmlForCommonHeader = @"";
    NSString *headerHtml = [NSString stringWithFormat:@"%@%@%@%@%@",[self htmlForTotal],[self htmlForTipAmount],[self htmlForGrandTotal],[self htmlForTotalTransactions],[self htmlForAvgTicket]];
    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr> %@ </tr></table>",headerHtml];
    return htmlForCommonHeader;
}

- (NSString *)htmlForTotal {
    NSString *total = [NSString stringWithFormat:@"%@",cCBatchTrnxDetails.total];
    NSString *currencyFomattedTotal = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:total]];
    NSString *htmlForTotal = [self htmlForColumnTitle:@"TOTAL" value:currencyFomattedTotal className:@"CHTotal"];
    return htmlForTotal;
}

- (NSString *)htmlForTipAmount {
    NSString *tipAmount = [NSString stringWithFormat:@"%@",cCBatchTrnxDetails.tipAmount];
    NSString *currencyFomattedTipAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:tipAmount]];
    NSString *htmlForTipAmount = [self htmlForColumnTitle:@"TIP AMOUNT" value:currencyFomattedTipAmount className:@"CHTipAmount"];
    return htmlForTipAmount;
}

- (NSString *)htmlForGrandTotal {
    NSString *grandTotal = [NSString stringWithFormat:@"%@",cCBatchTrnxDetails.grandTotal];
    NSString *currencyFomattedGrandTotal = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:grandTotal]];
    NSString *htmlForGrandTotal = [self htmlForColumnTitle:@"GRAND TOTAL" value:currencyFomattedGrandTotal className:@"CHGrandTotal"];
    return htmlForGrandTotal;
}

- (NSString *)htmlForTotalTransactions {
    NSString *totalTransactions = [NSString stringWithFormat:@"%@",cCBatchTrnxDetails.totalTransaction];
    NSString *htmlForTotalTransactions = [self htmlForColumnTitle:@"TOTAL TRANSACTIONS" value:totalTransactions className:@"CHTotalTransactions"];
    return htmlForTotalTransactions;
}

- (NSString *)htmlForAvgTicket {
    NSString *totalAvgTicket = [NSString stringWithFormat:@"%@",cCBatchTrnxDetails.totalAvgTicket];
    NSString *currencyFomattedAvgTicket = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:totalAvgTicket]];
    NSString *htmlForAvgTicket = [self htmlForColumnTitle:@"AVG.TICKET" value:currencyFomattedAvgTicket className:@"CHAvgTicket"];
    return htmlForAvgTicket;
}

- (NSString *)htmlForColumnTitle:(NSString *)title value:(NSString *)value className:(NSString *)className{
    NSString *htmlForColumn = @"";
    htmlForColumn = [htmlForColumn stringByAppendingFormat:@"<td class = \"%@\" align=\"center\"><strong>%@</strong><br>%@<br></td>",className,value,title];
    return htmlForColumn;
}

- (NSString *)htmlForCardPaymentDetails {
    NSString *htmlForCardPaymentDetails = @"";
    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:@"<table width=\"1000\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"> <tbody>"];
    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingFormat:@"<tr style=\" background:#fd8c08; color:#fff; height:28px;\">"];
    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingFormat:@"%@",[self htmlTransactionDetailsHeader]];
    for (NSDictionary *transactionDictionary in ccTransactionsArray) {
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingFormat:@"<tr>"];
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingFormat:@"%@",[self htmlTransactionDetailsFields:transactionDictionary]];
    }
    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingFormat:@"</table>"];
    return htmlForCardPaymentDetails;
}

- (NSString *)htmlTransactionDetailsHeader {
    NSString *htmlTransactionDetailsHeader = @"";
    NSString *htmlForDateAndTime = [self htmlForHeaderColumn:@"DATE &amp; TIME" className:@"HDateAndTime" align:@"left"];
    NSString *htmlForCardNumber = [self htmlForHeaderColumn:@"CARD NUMBER" className:@"HCardNumber" align:@"center"];
    NSString *htmlForCardType = [self htmlForHeaderColumn:@"CARD TYPE" className:@"HCardType" align:@"center"];
    NSString *htmlForAmount = [self htmlForHeaderColumn:@"AMOUNT" className:@"HAmount" align:@"center"];
    NSString *htmlForTips = [self htmlForHeaderColumn:@"TIPS" className:@"HTips" align:@"center"];
    NSString *htmlForTotalAmount = [self htmlForHeaderColumn:@"TOTAL AMOUNT" className:@"HTotalAmount" align:@"center"];
    NSString *htmlForAuth = [self htmlForHeaderColumn:@"AUTH" className:@"HAuth" align:@"center"];
    NSString *htmlForInvoice = [self htmlForHeaderColumn:@"INVOICE#" className:@"HInvoice" align:@"center"];
    htmlTransactionDetailsHeader = [htmlTransactionDetailsHeader stringByAppendingFormat:@"%@%@%@%@%@%@%@%@</tr>",htmlForDateAndTime,htmlForCardNumber,htmlForCardType,htmlForAmount,htmlForTips,htmlForTotalAmount,htmlForAuth,htmlForInvoice];
    return htmlTransactionDetailsHeader;
}

- (NSString *)htmlForHeaderColumn:(NSString *)columnName className:(NSString *)className align:(NSString *)align{
    NSString *htmlForColumn = @"";
    htmlForColumn = [htmlForColumn stringByAppendingFormat:@"<td class = \"%@\" align = \"%@\">%@</td>",className,align,columnName];
    return htmlForColumn;
}

- (NSString *)htmlTransactionDetailsFields:(NSDictionary *)transactionDetailsDictionary {
    NSString *htmlTransactionDetailsFields = @"";
    NSString *htmlForDateAndTime = [self htmlForTransactionDateAndTime:transactionDetailsDictionary];
    NSString *htmlForCardNumber = [self htmlForCardNumber:transactionDetailsDictionary];
    NSString *htmlForCardType = [self htmlForCardType:transactionDetailsDictionary];
    NSString *htmlForAmount = [self htmlForAmount:transactionDetailsDictionary];
    NSString *htmlForTips = [self htmlForTips:transactionDetailsDictionary];
    NSString *htmlForTotalAmount = [self htmlForTotalAmount:transactionDetailsDictionary];
    NSString *htmlForAuth = [self htmlForAuth:transactionDetailsDictionary];
    NSString *htmlForInvoice = [self htmlForInvoice:transactionDetailsDictionary];
    htmlTransactionDetailsFields = [htmlTransactionDetailsFields stringByAppendingFormat:@"%@%@%@%@%@%@%@%@</tr>",htmlForDateAndTime,htmlForCardNumber,htmlForCardType,htmlForAmount,htmlForTips,htmlForTotalAmount,htmlForAuth,htmlForInvoice];
    return htmlTransactionDetailsFields;
}

- (NSString *)htmlForTransactionDateAndTime:(NSDictionary *)transactionDetailsDictionary {
    NSString *strDate = [self getStringFormat:transactionDetailsDictionary [@"BillDate"] fromFormat:@"MM-dd-yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy"];
    NSString *strTime = [self getStringFormat:transactionDetailsDictionary [@"BillDate"] fromFormat:@"MM-dd-yyyy HH:mm:ss" toFormate:@"hh:mm a"];
    NSString *dateAndTime = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
    NSString *htmlForDateAndTime = [self htmlForTransactionDetailsField:dateAndTime className:@"HDateAndTime" status:@"" align:@"left"];
    return htmlForDateAndTime;
}

- (NSString *)htmlForCardNumber:(NSDictionary *)transactionDetailsDictionary {
    NSString *cardNumber = [NSString stringWithFormat:@"%@",transactionDetailsDictionary [@"AccNo"]];
    if ([cardNumber length] == 4) {
        cardNumber = [NSString stringWithFormat:@"**** **** **** %@",cardNumber];
    }
    else {
        cardNumber = [NSString stringWithFormat:@"**** **** **** %@",[cardNumber substringFromIndex:cardNumber.length-4]];
    }
    
    NSString *htmlForCardNumber = [self htmlForTransactionDetailsField:cardNumber className:@"HCardNumber" status:@"" align:@"Center"];
    return htmlForCardNumber;
}

- (NSString *)htmlForCardType:(NSDictionary *)transactionDetailsDictionary {
    NSString *cardType = [NSString stringWithFormat:@"%@",transactionDetailsDictionary [@"CardType"]];
    NSString *htmlForCardType = [self htmlForTransactionDetailsField:cardType className:@"HCardType" status:@"" align:@"Center"];
    return htmlForCardType;
}

- (NSString *)htmlForAmount:(NSDictionary *)transactionDetailsDictionary {
    NSString *billAmount = [NSString stringWithFormat:@"%@",transactionDetailsDictionary [@"BillAmount"]];
    NSString *currencyFomattedTotal = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:billAmount]];
    NSString *htmlForAmount = [self htmlForTransactionDetailsField:currencyFomattedTotal className:@"HAmount" status:@"" align:@"Center"];
    return htmlForAmount;
}

- (NSString *)htmlForTips:(NSDictionary *)transactionDetailsDictionary {
    NSString *tipsAmount = [NSString stringWithFormat:@"%@",transactionDetailsDictionary [@"TipsAmount"]];
    NSString *currencyFomattedTipsAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:tipsAmount]];
    NSString *htmlForTips = [self htmlForTransactionDetailsField:currencyFomattedTipsAmount className:@"HTips" status:@"" align:@"Center"];
    return htmlForTips;
}

- (NSString *)htmlForTotalAmount:(NSDictionary *)transactionDetailsDictionary {
    CGFloat totalAmount = [transactionDetailsDictionary [@"BillAmount"] floatValue] +
    [transactionDetailsDictionary[@"TipsAmount"] floatValue];
    NSString *totalAmountString = [NSString stringWithFormat:@"%.2f",totalAmount];
    NSString *currencyFomattedTotalAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:totalAmountString]];
    NSString *htmlForTotalAmount = [self htmlForTransactionDetailsField:currencyFomattedTotalAmount className:@"HTotalAmount" status:@"" align:@"Center"];
    return htmlForTotalAmount;
}

- (NSString *)htmlForAuth:(NSDictionary *)transactionDetailsDictionary {
    NSString *auth = [NSString stringWithFormat:@"%@",transactionDetailsDictionary [@"AuthCode"]];
    if (auth == nil || !auth.length > 0) {
        auth = @"-";
    }
    NSString *htmlForAuth = [self htmlForTransactionDetailsField:auth className:@"HAuth" status:@"" align:@"Center"];
    return htmlForAuth;
}

- (NSString *)htmlForInvoice:(NSDictionary *)transactionDetailsDictionary {
    NSString *invoiceNo = [NSString stringWithFormat:@"%@",transactionDetailsDictionary [@"RegisterInvNo"]];
    NSString *htmlForInvoice = [self htmlForTransactionDetailsField:invoiceNo className:@"HInvoice" status:@"" align:@"Center"];
    return htmlForInvoice;
}


-(NSString *)getStringFormat:(NSString *)pstrDate fromFormat:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    return result;
}

- (NSString *)htmlForTransactionDetailsField:(NSString *)field className:(NSString *)className status:(NSString *)status align:(NSString *)align {
    NSString *htmlForTransactionsField = @"";
    htmlForTransactionsField = [htmlForTransactionsField stringByAppendingFormat:@"<td class = \"%@\" height=\"48\" align=\"%@\" style=\"border-bottom:1px solid #e0e0e0\">%@<br>%@<br></td>",className,align,field,status];
    return htmlForTransactionsField;
}

#pragma mark - Get Transation Type

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
            strTransationType = @"AUTH";
            break;
            
        case TRANSACTIONTYPEPOSTAUTH:
            strTransationType = @"POSTAUTH";
            break;
            
        case TRANSACTIONTYPEFORCED:
            strTransationType = @"FORCED";
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
            strTransationType = @"VOID";
            break;
            
        case TRANSACTIONTYPEVSALE:
            strTransationType = @"V/SALE";
            break;
            
        case TRANSACTIONTYPEVRTRN:
            strTransationType = @"V/RTRN";
            break;
            
        case TRANSACTIONTYPEVAUTH:
            strTransationType = @"V/AUTH";
            break;
            
        case TRANSACTIONTYPEVPOST:
            strTransationType = @"V/POST";
            break;
            
        case TRANSACTIONTYPEVFRCD:
            strTransationType = @"V/FRCD";
            break;
            
        case TRANSACTIONTYPEVWITHDRAW:
            strTransationType = @"V/WITHDRAW";
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

@end
