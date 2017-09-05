//
//  CCBatchReceipt.m
//  RapidRMS
//
//  Created by Siya-mac5 on 04/08/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CCBatchReceipt.h"
#import "RasterPrintJob.h"
#import "RmsDbController.h"
#import "RasterPrintJobBase.h"

@interface CCBatchReceipt ()
{
    NSString *portNameForPrinter;
    NSString *portSettingsForPrinter;
    NSString *receiptTitle;
    
    NSArray *cCBatchDetailsArray;
    NSArray *receiptDataKeys;
    
    NSDictionary *cCBatchFilterDetailsDictionary;

    RmsDbController *rmsDbController;
    PaymentGateWay paymentGateWay;
}

@end

@implementation CCBatchReceipt

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings receiptData:(NSArray *)receiptDataArray receiptTitle:(NSString *)title filterDetails:(NSDictionary *)filterDetailsDictionary
{
    self = [super init];
    if (self) {
        portNameForPrinter = portName;
        portSettingsForPrinter = portSettings;
        cCBatchDetailsArray = [receiptDataArray copy];
        cCBatchFilterDetailsDictionary = [filterDetailsDictionary copy];
        rmsDbController = [RmsDbController sharedRmsDbController];
        receiptTitle = title;
        receiptDataKeys = @[
                            @"BranchName",
                            @"Address1",
                            @"Address2",
                            @"City",
                            @"State",
                            @"ZipCode",
                            @"UserName"];
    }
    return self;
}

#pragma mark - Printing
- (void)configureRecieptSections {

}

- (NSInteger)sectionAtSectionIndex:(NSInteger)sectionIndex {
    return [_sections[sectionIndex] integerValue];
}

- (void)printCCBatchReceiptWithDelegate:(id)delegate
{
    if(cCBatchDetailsArray.count>0)
    {
        [self configureRecieptSections];
        [self configurePrint:portSettingsForPrinter portName:portNameForPrinter withDelegate:delegate];
        _printerWidth = 48;
        
        NSInteger sectionCount = _sections.count;
        for (int i = 0; i < sectionCount; i++) {
            ReceiptSection section = [self sectionAtSectionIndex:i];
            [self printHeaderForSection:section];
            [self printCommandForSectionAtIndex:i];
            [self printFooterForSection:section];
        }
        
        [self concludePrint];
    }
}

- (void)configurePrint:(NSString *)portSettings portName:(NSString *)portName withDelegate:(id)delegate
{
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    
    if (isBlueToothPrinter) {
        _printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
        [_printJob enableSlashedZero:YES];
    }
    else
    {
        _printJob = [[RasterPrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
    }
}

- (void)concludePrint
{
    [_printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [_printJob firePrint];
    _printJob = nil;
}

#pragma mark - Header Printing

- (void)printHeaderForSection:(NSInteger)section
{
    switch (section) {
        case ReceiptSectionHeader:
            
            break;
            
        case ReceiptSectionCCBatchFilterInfo:
            [_printJob enableBold:YES];
            [_printJob setTextAlignment:TA_LEFT];
            [_printJob printLine:@"Filter Info"];
            [_printJob enableBold:NO];
            break;

        case ReceiptSectionCCBatchInfo:
            
            break;
            
        case ReceiptSectionCCBatchDetails:
            
            break;
            
        case ReceiptSectionFooter:
            
            break;

        default:
            break;
    }
}

#pragma mark - Footer Printing

- (void)printFooterForSection:(NSInteger)section
{
    switch (section) {
        case ReceiptSectionHeader:
            [_printJob printSeparator];
            break;
            
        case ReceiptSectionCCBatchFilterInfo:
            [_printJob printSeparator];
            break;

        case ReceiptSectionCCBatchInfo:
            [_printJob printSeparator];
            break;
            
        case ReceiptSectionCCBatchDetails:
            [_printJob printSeparator];
            break;
            
        case ReceiptSectionFooter:
            
            break;
            
        default:
            break;
    }
}

#pragma mark - Field Printing

- (void)printFieldWithId:(NSInteger)fieldId
{
    switch (fieldId) {
        case ReceiptFieldStoreName:
            [self printStoreName];
            break;

        case ReceiptFieldStoreAddress:
            [self printStoreAddress];
            break;
            
        case ReceiptFieldStoreEmailAndPhoneNumber:
            [self printStoreEmailAndPhoneNumber];
            break;
            
        case ReceiptFieldTitle:
            [self printReceiptTitle];
            break;
            
        case ReceiptFieldUserNameAndRegister:
            [self printUserNameAndRegister];
            break;
            
        case ReceiptFieldCurrentDate:
            [self printCurrentDate];
            break;
            
        case ReceiptFieldPaymentGateWay:
            [self printPaymentGateWay];
            break;
            
        case ReceiptFieldRegisterWiseFilter:
            [self printRegisterWiseFilter];
            break;

        case ReceiptFieldCradTypeWiseFilter:
            [self printCradTypeWiseFilter];
            break;

        case ReceiptFieldSearchText:
            [self printSearchText];
            break;

        case ReceiptFieldTotalAmount:
            [self printTotalAmount];
            break;
            
        case ReceiptFieldTotalTransactions:
            [self printTotalTransactions];
            break;
            
        case ReceiptFieldAvgTicket:
            [self printAvgTicket];
            break;
            
        case ReceiptFieldCardPaymentDetails:
            [self printCardPaymentDetails];
            break;

        default:
            break;
    }
}

#pragma mark - Field Wise Printing

- (void)printStoreName {
    [_printJob setTextAlignment:TA_CENTER];
    NSString *storeName = [self storeNameForReceipt];
    [_printJob printLine:storeName];
}

- (NSString *)storeNameForReceipt {
    NSString *storeName = @"";
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        storeName = [NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"StoreName"]];
    }
    else
    {
        storeName = [NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyBranchName]];
    }
    return storeName;
}

- (void)printStoreAddress {
    [_printJob setTextAlignment:TA_CENTER];
    NSString *addressLine1;
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        addressLine1 = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]];
        
        NSArray *arrAddress = [addressLine1 componentsSeparatedByString:@"\r\n"];
        if(arrAddress.count == 1)
        {
            arrAddress = [addressLine1 componentsSeparatedByString:@","];
        }
        for (uint i=0; i < arrAddress.count ;i++)
        {
            NSString *address = [arrAddress objectAtIndex:i];
            [_printJob printLine:address];
        }
    }
    else {
        addressLine1 = [NSString stringWithFormat:@"%@  , %@", [self branchInfoValueForKeyIndex:ReceiptDataKeyAddress1],[self branchInfoValueForKeyIndex:ReceiptDataKeyAddress2]];
        [_printJob printLine:addressLine1];
    }
}

- (void)printStoreEmailAndPhoneNumber {
    [_printJob setTextAlignment:TA_CENTER];
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [_printJob printLine:email];
            [_printJob printLine:phoneNo];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [_printJob printLine:phoneNo];
        }
    }
    else {
        NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [self branchInfoValueForKeyIndex:ReceiptDataKeyCity],[self branchInfoValueForKeyIndex:ReceiptDataKeyState],[self branchInfoValueForKeyIndex:ReceiptDataKeyZipCode]];
        [_printJob printLine:addressLine2];
    }
}

- (void)printReceiptTitle {
    [_printJob setTextAlignment:TA_CENTER];
    [_printJob enableInvertColor:YES];
    [_printJob printLine:receiptTitle];
    [_printJob enableInvertColor:NO];
}

-(void)printUserNameAndRegister {
    NSString *strUserName = [NSString stringWithFormat:@"User #: %@",[self userInfoValueForKeyIndex:ReceiptDataKeyUserName]];
    NSString *strRegister = [NSString stringWithFormat:@"Register #: %@",(rmsDbController.globalDict)[@"RegisterName"]];
    [self defaultFormatForReceipt];
    [_printJob printText1:strUserName text2:strRegister];
}

- (void)printCurrentDate {
    [_printJob setTextAlignment:TA_LEFT];
    NSString *currentDate = [self currentDateTime];
    [_printJob printLine:[NSString stringWithFormat:@"Current Date:%@",currentDate]];
}

- (NSString *)currentDateTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    NSString *currentDateTime = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:date],[timeFormatter stringFromDate:date]];
    return currentDateTime;
}

- (void)printPaymentGateWay {
//    [_printJob setTextAlignment:TA_LEFT];
    [self defaultFormatForReceipt];
    [_printJob printText1:@"Payment GateWay:" text2:[rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"]];
}

- (void)printRegisterWiseFilter {
    [self defaultFormatForReceipt];
    [_printJob printText1:@"Selected Register:" text2:[self filterValueForKey:@"SelectedRegister"]];
}

- (void)printCradTypeWiseFilter {
    [self defaultFormatForReceipt];
    [_printJob printText1:@"Selected Crad Type:" text2:[self filterValueForKey:@"SelectedCradType"]];
}

- (void)printSearchText {
    [self defaultFormatForReceipt];
    [_printJob printText1:@"Search Text:" text2:[self filterValueForKey:@"SearchText"]];
}

- (NSString *)filterValueForKey:(NSString *)filterKey {
    return cCBatchFilterDetailsDictionary [filterKey];
}

- (void)printTotalAmount {
    [self defaultFormatForReceipt];
    NSString *totalAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:[[cCBatchDetailsArray valueForKeyPath:@"@sum.Amount"] stringValue]]];
    [_printJob printText1:@"Total:" text2:totalAmount];
}

- (void)printTotalTransactions {
    [self defaultFormatForReceipt];
    NSString *totalTrnxCount = [NSString stringWithFormat:@"%@",[cCBatchDetailsArray valueForKeyPath:@"@sum.TrnxCount"]];
    [_printJob printText1:@"Total Transactions:" text2:totalTrnxCount];
}

- (void)printAvgTicket {
    [self defaultFormatForReceipt];
    NSString *totalAvgTicket = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:[[cCBatchDetailsArray valueForKeyPath:@"@sum.AvgTicket"] stringValue]]];
    [_printJob printText1:@"Avg. Ticket:" text2:totalAvgTicket];
}

- (void)printCardPaymentDetails {
    [self printCardPaymentTitle];
    for (NSDictionary *cardPaymentDictionary in cCBatchDetailsArray) {
        NSString *cardType = [NSString stringWithFormat:@"%@",cardPaymentDictionary [@"Card"]];
        [_printJob enableBold:YES];
//        [self printCardType:cardType];
        [_printJob enableBold:NO];
        NSString *total = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:[cardPaymentDictionary [@"Amount"] stringValue]]];
        NSString *totalTransactions = [NSString stringWithFormat:@"%ld",(long)[cardPaymentDictionary [@"TrnxCount"] integerValue]];
        NSString *avgTicket = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:[cardPaymentDictionary [@"AvgTicket"] stringValue]]];
//        [self printTotal:total totalTransactions:totalTransactions avgTicket:avgTicket];
        [self printTotal:cardType total:total totalTransactions:totalTransactions avgTicket:avgTicket];

    }
}

- (void)printCardPaymentTitle {
    [_printJob enableBold:YES];
//    [self printCardType:@"CardType"];
//    [self printTotal:@"Total" totalTransactions:@"Count" avgTicket:@"Avg. Ticket"];
    [self printTotal:@"CardType" total:@"Amount" totalTransactions:@"Count" avgTicket:@"Avg. Ticket"];
    [_printJob enableBold:NO];
}

- (void)printCardType:(NSString *)cardType {
    [_printJob setTextAlignment:TA_LEFT];
    [_printJob printLine:cardType];
}

- (void)printTotal:(NSString *)total totalTransactions:(NSString *)totalTransactions avgTicket:(NSString *)avgTicket {
    [self defaultFormatForThreeColumn];
    [_printJob printText1:total text2:totalTransactions text3:avgTicket];
}

- (void)printTotal:(NSString *)cardType total:(NSString *)total totalTransactions:(NSString *)totalTransactions avgTicket:(NSString *)avgTicket {
    [self defaultFormatForFourColumn];
    [_printJob printText1:cardType text2:total text3:totalTransactions text4:avgTicket];

}

#pragma mark - HTML 

- (NSString *)generateHtml
{
    [self configureRecieptSections];
    NSMutableString *html = [[NSMutableString alloc] init];
    for (int i = 0 ; i < _sections.count; i++) {
        NSString *htmlForSection = [self htmlForSectionAtIndex:i];
        [html appendString:htmlForSection];
    }
    return html;
}

- (NSString *)htmlForSectionAtIndex:(NSInteger)sectionIndex {
    NSMutableString *html = [[NSMutableString alloc] init];
    [html appendString: [self headerHtmlForSectionAtIndex:sectionIndex]];
    NSArray *sectionFields = _fields[sectionIndex];
    for (int j = 0; j < sectionFields.count; j++) {
        [html appendString:[self htmlForFieldAtIndex:j sectionIndex:sectionIndex]];
    }
    [html appendString:[self footerHtmlForSectionAtIndex:sectionIndex]];
    return html;
}

- (NSString *)htmlForFieldAtIndex:(NSInteger)fieldIndex sectionIndex:(NSInteger)sectionIndex {
    NSString *html;
    NSNumber *fieldNumber = _fields[sectionIndex][fieldIndex];
    ReceiptField fieldId = fieldNumber.integerValue;
    html = [self htmlForFieldId:fieldId];
    if(html == nil)
    {
        html = @"";
    }
    return html;
}

- (NSString *)headerHtmlForSectionAtIndex:(NSInteger)sectionId
{
    NSString *html;
    NSNumber *sectionNumber = _sections[sectionId];
    ReceiptSection section = sectionNumber.integerValue;
    html = [self htmlForSectionHeader:section];
    if(html == nil)
    {
        html = @"";
    }
    return html;
}

- (NSString *)footerHtmlForSectionAtIndex:(NSInteger)sectionId
{
    NSString *html;
    NSNumber *sectionNumber = _sections[sectionId];
    ReceiptSection section = sectionNumber.integerValue;
    html = [self htmlForSectionFooter:section];
    if(html == nil)
    {
        html = @"";
    }
    return html;
}

- (NSString *)htmlForSectionHeader:(ReceiptSection)sectionId
{
    NSString *htmlForSection;
    switch (sectionId) {
        case ReceiptSectionHeader:
            htmlForSection = [self htmlHeaderForReceiptSectionHeader];
            break;
            
        case ReceiptSectionCCBatchFilterInfo:
            htmlForSection = [self htmlHeaderForReceiptSectionCCBatchFilterInfo];
            break;

        case ReceiptSectionCCBatchInfo:
            htmlForSection = [self htmlHeaderForReceiptSectionCCBatchInfo];
            break;
            
        case ReceiptSectionCCBatchDetails:
            htmlForSection = [self htmlHeaderForReceiptSectionCCBatchDetails];
            break;
            
        case ReceiptSectionFooter:
            htmlForSection = [self htmlHeaderForReceiptSectionFooter];
            break;
            
        default:
            break;
    }
    return htmlForSection;
}

- (NSString *)htmlForSectionFooter:(ReceiptSection)sectionId
{
    NSString *htmlForSection;
    switch (sectionId) {
        case ReceiptSectionHeader:
            htmlForSection = [self htmlFooterForReceiptSectionHeader];
            break;
            
        case ReceiptSectionCCBatchFilterInfo:
            htmlForSection = [self htmlFooterForReceiptSectionCCBatchFilterInfo];
            break;
            
        case ReceiptSectionCCBatchInfo:
            htmlForSection = [self htmlFooterForReceiptSectionCCBatchInfo];
            break;
            
        case ReceiptSectionCCBatchDetails:
            htmlForSection = [self htmlFooterForReceiptSectionCCBatchDetails];
            break;
            
        case ReceiptSectionFooter:
            htmlForSection = [self htmlFooterForReceiptSectionFooter];
            break;
            
        default:
            break;
    }
    return htmlForSection;
}

- (NSString *)htmlForFieldId:(ReceiptField)fieldId
{
    NSString *htmlForFieldId;
    switch (fieldId) {
        case ReceiptFieldStoreName:
            htmlForFieldId = [self htmlForStoreName];
            break;
            
        case ReceiptFieldStoreAddress:
            htmlForFieldId = [self htmlForStoreAddress];
            break;
            
        case ReceiptFieldStoreEmailAndPhoneNumber:
            htmlForFieldId = [self htmlForStoreEmailAndPhoneNumber];
            break;
            
        case ReceiptFieldTitle:
            htmlForFieldId = [self htmlForTitle];
            break;
            
        case ReceiptFieldUserNameAndRegister:
            htmlForFieldId = [self htmlForUserNameAndRegister];
            break;
            
        case ReceiptFieldCurrentDate:
            htmlForFieldId = [self htmlForCurrentDate];
            break;
            
        case ReceiptFieldPaymentGateWay:
            htmlForFieldId = [self htmlForPaymentGateWay];
            break;
            
        case ReceiptFieldRegisterWiseFilter:
            htmlForFieldId = [self htmlForRegisterWiseFilter];
            break;
            
        case ReceiptFieldCradTypeWiseFilter:
            htmlForFieldId = [self htmlForCradTypeWiseFilter];
            break;

        case ReceiptFieldSearchText:
            htmlForFieldId = [self htmlForSearchText];
            break;

        case ReceiptFieldTotalAmount:
            htmlForFieldId = [self htmlForTotalAmount];
            break;
            
        case ReceiptFieldTotalTransactions:
            htmlForFieldId = [self htmlForTotalTransactions];
            break;
            
        case ReceiptFieldAvgTicket:
            htmlForFieldId = [self htmlForAvgTicket];
            break;
            
        case ReceiptFieldCommonHeader:
            htmlForFieldId = [self htmlForCommonHeader];
            break;
            
        case ReceiptFieldCardPaymentDetails:
            htmlForFieldId = [self htmlForCardPaymentDetails];
            break;
            
        default:
            break;
    }
    return htmlForFieldId;
}

#pragma mark - Html For Section Header

- (NSString *)htmlHeaderForReceiptSectionHeader {
    NSString *htmlHeaderForReceiptSectionHeader = [[NSString alloc] initWithFormat:@"<!doctype html> <html> <meta name=\"format-detection\" content=\"telephone=no\"> <body>"];
    htmlHeaderForReceiptSectionHeader = [htmlHeaderForReceiptSectionHeader stringByAppendingFormat:@"<div style=\"width:336px; font-family:Helvetica Neue; font-size:14px; margin:auto;\">"];
    htmlHeaderForReceiptSectionHeader = [htmlHeaderForReceiptSectionHeader stringByAppendingFormat:@"<div style=\"width:100%%;  float:left;  padding-bottom:10px; \">"];
    htmlHeaderForReceiptSectionHeader = [htmlHeaderForReceiptSectionHeader stringByAppendingFormat:@"<table style=\"font-family:Helvetica Neue;width:336px;font-size:16px;padding-top:8px;padding-bottom:8px;padding-right:12px;padding-left:12px;\"><tbody>"];
    return htmlHeaderForReceiptSectionHeader;
}

- (NSString *)htmlHeaderForReceiptSectionCCBatchFilterInfo {
    NSString *htmlHeaderForReceiptSectionCCBatchFilterInfo = @"";
    htmlHeaderForReceiptSectionCCBatchFilterInfo = [htmlHeaderForReceiptSectionCCBatchFilterInfo stringByAppendingFormat:@"<div style=\"width:100%%; border-bottom:dashed 1px #000; float:left; padding-bottom:10px; font-size:16px; \">"];
    htmlHeaderForReceiptSectionCCBatchFilterInfo = [htmlHeaderForReceiptSectionCCBatchFilterInfo stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlHeaderForReceiptSectionCCBatchFilterInfo = [htmlHeaderForReceiptSectionCCBatchFilterInfo stringByAppendingFormat:@"<div style=\"float:left; margin-top:3px;\"><strong>%@</strong></div>",@"Filter Info:"];
    htmlHeaderForReceiptSectionCCBatchFilterInfo = [htmlHeaderForReceiptSectionCCBatchFilterInfo stringByAppendingFormat:@"<div style=\"float:right; text-align:right; margin-top:3px;\">%@</div></div>",@""];
    return htmlHeaderForReceiptSectionCCBatchFilterInfo;
}

- (NSString *)htmlHeaderForReceiptSectionCCBatchInfo {
    NSString *htmlHeaderForReceiptSectionCCBatchInfo = @"";
    htmlHeaderForReceiptSectionCCBatchInfo = [htmlHeaderForReceiptSectionCCBatchInfo stringByAppendingFormat:@"<div style=\"width:100%%; border-bottom:dashed 1px #000; float:left; padding-bottom:10px; font-size:16px; \">"];
    htmlHeaderForReceiptSectionCCBatchInfo = [htmlHeaderForReceiptSectionCCBatchInfo stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    return htmlHeaderForReceiptSectionCCBatchInfo;
}

- (NSString *)htmlHeaderForReceiptSectionCCBatchDetails {
    NSString *htmlHeaderForReceiptSectionCCBatchDetails = @"";
    htmlHeaderForReceiptSectionCCBatchDetails = [htmlHeaderForReceiptSectionCCBatchDetails stringByAppendingString:@"<div style=\"width:100%%; border-bottom:dashed 1px #000; float:left;  padding-bottom:10px;\">"];
    htmlHeaderForReceiptSectionCCBatchDetails = [htmlHeaderForReceiptSectionCCBatchDetails stringByAppendingString:@"<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"width:336px;margin:Auto\"><tbody>"];
    return htmlHeaderForReceiptSectionCCBatchDetails;
}

- (NSString *)htmlHeaderForReceiptSectionFooter {
    NSString *htmlHeaderForReceiptSectionFooter = @"";
    return htmlHeaderForReceiptSectionFooter;
}

#pragma mark - Html For Section Footer

- (NSString *)htmlFooterForReceiptSectionHeader {
    NSString *htmlFooterForReceiptSectionHeader = @"";
    return htmlFooterForReceiptSectionHeader;
}

- (NSString *)htmlFooterForReceiptSectionCCBatchFilterInfo {
    NSString *htmlFooterForReceiptSectionCCBatchFilterInfo = @"";
    htmlFooterForReceiptSectionCCBatchFilterInfo = [htmlFooterForReceiptSectionCCBatchFilterInfo stringByAppendingString:@"</div>"];
    return htmlFooterForReceiptSectionCCBatchFilterInfo;
}

- (NSString *)htmlFooterForReceiptSectionCCBatchInfo {
    NSString *htmlFooterForReceiptSectionCCBatchInfo = @"";
    return htmlFooterForReceiptSectionCCBatchInfo;
}

- (NSString *)htmlFooterForReceiptSectionCCBatchDetails {
    NSString *htmlFooterForReceiptSectionCCBatchDetails = @"";
    return htmlFooterForReceiptSectionCCBatchDetails;
}

- (NSString *)htmlFooterForReceiptSectionFooter {
    NSString *htmlFooterForReceiptSectionFooter = @"";
    htmlFooterForReceiptSectionFooter = [htmlFooterForReceiptSectionFooter stringByAppendingFormat:@"</div> </body> </html>"];
    return htmlFooterForReceiptSectionFooter;
}

#pragma mark - Html For Fields

- (NSString *)htmlForStoreName {
    NSString *htmlForStoreName = @"";
    NSString *storeName = [self storeNameForReceipt];
    htmlForStoreName = [self htmlRowFor:storeName];
    return htmlForStoreName;
}

- (NSString *)htmlRowFor:(NSString *)string {
    NSString *htmlRowFor = @"";
    htmlRowFor = [htmlRowFor stringByAppendingFormat:@"<tr><td align=\"center\">%@</td></tr>",string];
    return htmlRowFor;
}

- (NSString *)htmlForStoreAddress {
    NSString *htmlForStoreAddress = @"";
    NSString *storeAddress = @"";
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        storeAddress = [NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]];
    }
    else {
        storeAddress = [NSString stringWithFormat:@"%@%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyAddress1],[self branchInfoValueForKeyIndex:ReceiptDataKeyAddress2]];
    }
    htmlForStoreAddress = [self htmlRowFor:storeAddress];
    return htmlForStoreAddress;
}

- (NSString *)htmlForStoreEmailAndPhoneNumber {
    NSString *htmlForStoreEmailAndPhoneNumber = @"";
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            NSString *emailAndPhoneNumber = [NSString stringWithFormat:@"%@ - %@",email,phoneNo];
            htmlForStoreEmailAndPhoneNumber = [htmlForStoreEmailAndPhoneNumber stringByAppendingFormat:@"%@",[self htmlRowFor:emailAndPhoneNumber]];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            htmlForStoreEmailAndPhoneNumber = [self htmlRowFor:phoneNo];
        }
    }
    else {
        NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [self branchInfoValueForKeyIndex:ReceiptDataKeyCity],[self branchInfoValueForKeyIndex:ReceiptDataKeyState],[self branchInfoValueForKeyIndex:ReceiptDataKeyZipCode]];
        htmlForStoreEmailAndPhoneNumber = [self htmlRowFor:addressLine2];
    }
    htmlForStoreEmailAndPhoneNumber = [htmlForStoreEmailAndPhoneNumber stringByAppendingFormat:@"</tbody></table>"];
    return htmlForStoreEmailAndPhoneNumber;
}

- (NSString *)htmlForTitle {
    NSString *htmlForTitle = @"";
    htmlForTitle = [htmlForTitle stringByAppendingFormat:@"<table style=\" width:100%%; font-size:16px; margin-top:5px;\">"];
    htmlForTitle = [htmlForTitle stringByAppendingFormat:@"<tr><td style=\"width:25%%;\"></td>"];
    htmlForTitle = [htmlForTitle stringByAppendingFormat:@"<td style=\"width:50%%; color:#fff; background:#000; text-align:center;\">%@</td>",receiptTitle];
    htmlForTitle = [htmlForTitle stringByAppendingFormat:@"<td style=\"width:25%%;\"></td> </tr> </table> </div>"];
    return htmlForTitle;
}

- (NSString *)htmlForUserNameAndRegister {
    NSString *htmlForUserNameAndRegister = @"";
    htmlForUserNameAndRegister = [htmlForUserNameAndRegister stringByAppendingFormat:@"<div style=\"width:100%%; border-bottom:dashed 1px #000; float:left; padding-bottom:10px; font-size:16px; \">"];
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
    htmlForCurrentDate = [htmlForCurrentDate stringByAppendingFormat:@"<div style=\"float:left\">"];
    NSString *currentDate = [self currentDateTime];
    htmlForCurrentDate = [htmlForCurrentDate stringByAppendingFormat:@"<div style=\"float:right; text-align:left; margin-top:3px;\">%@</div>",currentDate];
    htmlForCurrentDate = [htmlForCurrentDate stringByAppendingFormat:@"<div style=\"float:right; margin-top:3px;\">%@</div></div></div>",@"Current Date:"];
    return htmlForCurrentDate;
}

- (NSString *)htmlForPaymentGateWay {
    NSString *htmlForPaymentGateWay = @"";
    htmlForPaymentGateWay = [htmlForPaymentGateWay stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForPaymentGateWay = [htmlForPaymentGateWay stringByAppendingFormat:@"<div style=\"float:left; margin-top:3px;\">%@</div>",@"Payment GateWay:"];
    htmlForPaymentGateWay = [htmlForPaymentGateWay stringByAppendingFormat:@"<div style=\"float:right; text-align:right; margin-top:3px;\">%@</div></div>",[rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"]];
    return htmlForPaymentGateWay;
}

- (NSString *)htmlForRegisterWiseFilter {
    NSString *htmlForRegisterWiseFilter = @"";
    htmlForRegisterWiseFilter = [htmlForRegisterWiseFilter stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForRegisterWiseFilter = [htmlForRegisterWiseFilter stringByAppendingFormat:@"<div style=\"float:left; margin-top:3px;\">%@</div>",@"Selected Register:"];
    htmlForRegisterWiseFilter = [htmlForRegisterWiseFilter stringByAppendingFormat:@"<div style=\"float:right; text-align:right; margin-top:3px;\">%@</div></div>",[self filterValueForKey:@"SelectedRegister"]];
    return htmlForRegisterWiseFilter;
}

- (NSString *)htmlForCradTypeWiseFilter {
    NSString *htmlForCradTypeWiseFilter = @"";
    htmlForCradTypeWiseFilter = [htmlForCradTypeWiseFilter stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForCradTypeWiseFilter = [htmlForCradTypeWiseFilter stringByAppendingFormat:@"<div style=\"float:left; margin-top:3px;\">%@</div>",@"Selected Crad Type:"];
    htmlForCradTypeWiseFilter = [htmlForCradTypeWiseFilter stringByAppendingFormat:@"<div style=\"float:right; text-align:right; margin-top:3px;\">%@</div></div>",[self filterValueForKey:@"SelectedCradType"]];
    return htmlForCradTypeWiseFilter;
}

- (NSString *)htmlForSearchText {
    NSString *htmlForSearchText = @"";
    htmlForSearchText = [htmlForSearchText stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForSearchText = [htmlForSearchText stringByAppendingFormat:@"<div style=\"float:left; margin-top:3px;\">%@</div>",@"Search Text:"];
    htmlForSearchText = [htmlForSearchText stringByAppendingFormat:@"<div style=\"float:right; text-align:right; margin-top:3px;\">%@</div></div>",[self filterValueForKey:@"SearchText"]];
    return htmlForSearchText;
}

- (NSString *)htmlForTotalAmount {
    NSString *htmlForTotalAmount = @"";
    NSString *totalAmount = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:[[cCBatchDetailsArray valueForKeyPath:@"@sum.Amount"] stringValue]]];
    htmlForTotalAmount = [htmlForTotalAmount stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForTotalAmount = [htmlForTotalAmount stringByAppendingFormat:@"<div style=\"float:left;\">%@</div>",@"Total:"];
    htmlForTotalAmount = [htmlForTotalAmount stringByAppendingFormat:@"<div style=\"float:right; text-align:right;\">%@</div></div>",totalAmount];
    return htmlForTotalAmount;
}

- (NSString *)htmlForTotalTransactions {
    NSString *htmlForTotalTransactions = @"";
    NSString *totalTrnxCount = [NSString stringWithFormat:@"%@",[cCBatchDetailsArray valueForKeyPath:@"@sum.TrnxCount"]];
    htmlForTotalTransactions = [htmlForTotalTransactions stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForTotalTransactions = [htmlForTotalTransactions stringByAppendingFormat:@"<div style=\"float:left;\">%@</div>",@"Total Transactions:"];
    htmlForTotalTransactions = [htmlForTotalTransactions stringByAppendingFormat:@"<div style=\"float:right; text-align:right;\">%@</div></div>",totalTrnxCount];
    return htmlForTotalTransactions;
}

- (NSString *)htmlForAvgTicket {
    NSString *htmlForAvgTicket = @"";
    NSString *totalAvgTicket = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:[[cCBatchDetailsArray valueForKeyPath:@"@sum.AvgTicket"] stringValue]]];
    htmlForAvgTicket = [htmlForAvgTicket stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\">"];
    htmlForAvgTicket = [htmlForAvgTicket stringByAppendingFormat:@"<div style=\"float:left;\">%@</div>",@"Avg. Ticket:"];
    htmlForAvgTicket = [htmlForAvgTicket stringByAppendingFormat:@"<div style=\"float:right; text-align:right;\">%@</div></div></div></div>",totalAvgTicket];
    return htmlForAvgTicket;
}

- (NSString *)htmlForCommonHeader {
    NSString *htmlForCommonHeader = @"";
    return htmlForCommonHeader;
}

- (NSString *)htmlForCardPaymentDetails {
    NSString *htmlForCardPaymentDetails = @"";
//    NSString *titleHtml = [self htmlCardPaymentDetailsWithText1:@"CardType" text2:@"" text3:@"" enableBold:YES];
//    NSString *headerHtml = [self htmlCardPaymentDetailsWithText1:@"Total" text2:@"Count" text3:@"Avg. Ticket" enableBold:YES];
//    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:titleHtml];
//    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:headerHtml];
    
    NSString *headerHtml = [self htmlCardPaymentDataWithText1:@"CardType" text2:@"Amount" text3:@"Count" text4:@"Avg. Ticket" enableBold:YES];

    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:headerHtml];

    for (NSDictionary *cardPaymentDictionary in cCBatchDetailsArray) {
//        NSString *cardTypeHtml = [self htmlCardPaymentDetailsWithText1:cardType text2:@"" text3:@"" enableBold:YES];
//        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardTypeHtml];
        NSString *cardType = [NSString stringWithFormat:@"%@",cardPaymentDictionary [@"Card"]];

        NSString *total = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:[cardPaymentDictionary [@"Amount"] stringValue]]];
        NSString *totalTransactions = [NSString stringWithFormat:@"%ld",(long)[cardPaymentDictionary [@"TrnxCount"] integerValue]];
        NSString *avgTicket = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:[cardPaymentDictionary [@"AvgTicket"] stringValue]]];
//        NSString *cardPaymentHtml = [self htmlCardPaymentDetailsWithText1:total text2:totalTransactions text3:avgTicket enableBold:NO];
        NSString *cardPaymentHtml = [self htmlCardPaymentDataWithText1:cardType text2:total text3:totalTransactions text4:avgTicket enableBold:NO];
        
        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardPaymentHtml];

//        htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:cardPaymentHtml];


    }
    htmlForCardPaymentDetails = [htmlForCardPaymentDetails stringByAppendingString:@"</tbody></table></div>"];
    return htmlForCardPaymentDetails;
}

- (NSString *)htmlCardPaymentDetailsWithText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 enableBold:(BOOL)enableBold {
    NSString *htmlForCardPaymentTitle = @"";
    if (enableBold) {
        htmlForCardPaymentTitle = [htmlForCardPaymentTitle stringByAppendingString:[NSString stringWithFormat:@"<tr><td align=\"left\" style=\"width:38%%;\"><strong><font size=\"3\">%@</font></strong></td><td align=\"center\" style=\"width:42%%; word-break:break-all;\"><strong><font size=\"3\">%@</font></strong></td><td style=\"width:30%%;\" align=\"right\"><strong><font size=\"3\">%@</font> </strong></td></tr>",text1,text2,text3]];
    }
    else {
        htmlForCardPaymentTitle = [htmlForCardPaymentTitle stringByAppendingString:[NSString stringWithFormat:@"<tr><td align=\"left\" style=\"width:38%%;\"><font size=\"3\">%@</font></td><td align=\"center\" style=\"width:42%%; word-break:break-all;\"><font size=\"3\">%@</font></td><td style=\"width:30%%;\" align=\"right\"><font size=\"3\">%@</font></td></tr>",text1,text2,text3]];
    }
    return htmlForCardPaymentTitle;
}

- (NSString *)htmlCardPaymentDataWithText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 text4:(NSString *)text4 enableBold:(BOOL)enableBold {
    NSString *htmlForCardPaymentTitle = @"";
    if (enableBold) {
        
        htmlForCardPaymentTitle = [htmlForCardPaymentTitle stringByAppendingString:[NSString stringWithFormat:@"<tr><td align=\"left\" style=\"width:30%%; word-break:break-all;\"><strong><font size=\"3\">%@</font></strong></td><td align=\"left\" style=\"width:30%%; word-break:break-all;\"><strong><font size=\"3\">%@</font></strong></td><td align=\"center\" style=\"width:15%%; word-break:break-all;\"><strong><font size=\"3\">%@</font></strong></td><td style=\"width:35%%;\" align=\"right\"><strong><font size=\"3\">%@</font> </strong></td></tr>",text1,text2,text3,text4]];
    }
    else {
        htmlForCardPaymentTitle = [htmlForCardPaymentTitle stringByAppendingString:[NSString stringWithFormat:@"<tr><td align=\"left\" style=\"width:30%%;\"><font size=\"3\">%@</font></td><td align=\"left\" style=\"width:30%%; word-break:break-all;\"><font size=\"3\">%@</font></td><td align=\"center\" style=\"width:20%%; word-break:break-all;\"><font size=\"3\">%@</font></td><td style=\"width:30%%;\" align=\"right\"><font size=\"3\">%@</font></td></tr>",text1,text2,text3,text4]];
    }
    return htmlForCardPaymentTitle;
}


#pragma mark -  Utility

- (id)branchInfoValueForKeyIndex:(ReceiptDataKey)index
{
    return [self valueFromDictionary:[self branchInfo] forKeyIndex:index];
}

- (id)userInfoValueForKeyIndex:(ReceiptDataKey)index
{
    return [self valueFromDictionary:[self userInfo] forKeyIndex:index];
}

- (NSDictionary *)branchInfo
{
    NSDictionary *dictBranchInfo = [rmsDbController.globalDict valueForKey:@"BranchInfo"];
    return dictBranchInfo;
}

- (NSDictionary *)userInfo
{
    NSDictionary *dictUserInfo = [rmsDbController.globalDict valueForKey:@"UserInfo"];
    return dictUserInfo;
}

- (id)valueFromDictionary:(NSDictionary *)dictionary forKeyIndex:(ReceiptDataKey)index
{
    return dictionary[[self keyForIndex:index]];
}

- (NSString *)keyForIndex:(ReceiptDataKey)index
{
    return receiptDataKeys[index];
}

#pragma mark - Formating For Receipt Printing

- (void)defaultFormatForReceipt
{
    columnWidths[0] = 18;
    columnWidths[1] = 29;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForThreeColumn
{
    columnWidths[0] = 15;
    columnWidths[1] = 16;
    columnWidths[2] = 15;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentRight;
    columnAlignments[2] = RPAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForFourColumn
{
    columnWidths[0] = 12;
    columnWidths[1] = 13;
    columnWidths[2] = 7;
    columnWidths[3] = 13;
    columnAlignments[0] = RCAlignmentLeft;
    columnAlignments[1] = RCAlignmentLeft;
    columnAlignments[2] = RCAlignmentRight;
    columnAlignments[3] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

@end
