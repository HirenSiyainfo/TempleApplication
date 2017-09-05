//
//  GiftCardReceiptPrint.m
//  RapidRMS
//
//  Created by Siya-mac5 on 14/11/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "GiftCardReceiptPrint.h"
#import "RasterPrintJob.h"
#import "RasterPrintJobBase.h"

@implementation GiftCardReceiptPrint

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSMutableDictionary *)giftCardDataDictionary withReceiptDate:(NSString*)receiptDate {
    self = [super init];
    if (self) {
        portNameForPrinter = portName;
        portSettingsForPrinter = portSettings;
        receiptDataDictionary = giftCardDataDictionary;
        rmsDbController = [RmsDbController sharedRmsDbController];
        strReceiptDate = receiptDate;
        giftCardReceiptDataKeys = @[
                            @"BranchName",
                            @"Address1",
                            @"Address2",
                            @"City",
                            @"State",
                            @"ZipCode",
                            @"UserName",
                            @"HelpMessage1",
                            @"HelpMessage2",
                            @"HelpMessage3",
                            ];
    }
    return self;
}

//// Receipt Section and Feild

- (void)configureGiftCardReceiptSection {
    
    //// section detail
    _sections = @[
                  @(GiftCardReceiptSectionReceiptHeader),
                  @(GiftCardReceiptSectionReceiptInfo),
                  @(GiftCardReceiptSectionGiftCardDetail),
                  @(GiftCardReceiptSectionThanksMessage),
                  @(GiftCardReceiptSectionBarcode),
                  @(GiftCardReceiptSectionReceiptFooter),
                  ];
    
    NSArray *receiptHeaderSectionFields = @[
                                            @(GiftCardReceiptFieldStoreName),
                                            @(GiftCardReceiptFieldAddressline1),
                                            @(GiftCardReceiptFieldAddressline2),
                                            ];
    
    NSArray *receiptInfoSectionFields = @[
                                          @(GiftCardReceiptFieldReceiptName),
                                          @(GiftCardReceiptFieldCashierName),
                                          @(GiftCardReceiptFieldRegisterName),
                                          @(GiftCardReceiptFieldTranscationDate),
                                          @(GiftCardReceiptFieldCurrentDate),
                                          ];
    
    NSArray *receiptGiftCardDetailSectionFields = @[
                                                    @(GiftCardReceiptFieldNameOfGiftCard),
                                                    @(GiftCardReceiptFieldCardNumber),
                                                    @(GiftCardReceiptFieldBalance),
                                                    ];
    NSArray *receiptThanksMessageSectionFields = @[
                                                   @(GiftCardReceiptFieldThanksMessage),
                                                   ];
    
    NSArray *receiptBarcodeSectionFields = @[
                                             @(GiftCardReceiptFieldBarcode),
                                             ];
    
    
    NSArray *receiptFooterSectionFields = @[
                                                ];
    
    /// field detail
    _fields = @[
                receiptHeaderSectionFields,
                receiptInfoSectionFields,
                receiptGiftCardDetailSectionFields,
                receiptThanksMessageSectionFields,
                receiptBarcodeSectionFields,
                receiptFooterSectionFields,
                ];
}


#pragma mark - Printing
//// print receipt start ////

- (NSInteger)sectionAtSectionIndex:(NSInteger)sectionIndex {
    return [_sections[sectionIndex] integerValue];
}

- (void)printGiftCardReceiptWithDelegate:(id)delegate
{
        [self configureGiftCardReceiptSection];
        [self configurePrint:portSettingsForPrinter portName:portNameForPrinter withDelegate:delegate];
        _printerWidth = 48;
        
        NSInteger sectionCount = _sections.count;
        for (int i = 0; i < sectionCount; i++) {
            GiftCardReceiptSection section = [self sectionAtSectionIndex:i];
            [self printHeaderForSection:section];
            [self printCommandForSectionAtIndex:i];
            [self printFooterForSection:section];
        }
        [self concludePrint];
}

- (void)configurePrint:(NSString *)portSettings portName:(NSString *)portName withDelegate:(id)delegate
{
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    
    if (isBlueToothPrinter) {
        printJob = [[PrintJob alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
        [printJob enableSlashedZero:YES];
    }
    else
    {
        printJob = [[RasterPrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
    }
}

- (void)concludePrint
{
    [printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [printJob firePrint];
    printJob = nil;
}

#pragma mark - Header Printing

-(void)printHeaderForSection:(NSInteger)section
{
    switch (section) {
        case GiftCardReceiptSectionReceiptHeader:
            
            break;
            
        case GiftCardReceiptSectionReceiptInfo:
            break;
            
        case GiftCardReceiptSectionGiftCardDetail:

            break;
            
        case GiftCardReceiptSectionThanksMessage:

            break;
            
        case GiftCardReceiptSectionBarcode:
            
            break;
            
        case GiftCardReceiptSectionReceiptFooter:
            
            break;

        default:
            break;
    }
}

#pragma mark - Command For Section & Field

-(void)printCommandForSectionAtIndex:(NSInteger)sectionIndex
{
    NSArray *sectionFields = _fields[sectionIndex];
    NSInteger fieldCount = sectionFields.count;
    for (int i = 0; i < fieldCount; i++) {
        [self printCommandForFieldAtIndex:i sectionIndex:sectionIndex];
    }
}

- (void)printCommandForFieldAtIndex:(NSInteger)fieldIndex sectionIndex:(NSInteger)sectionIndex
{
    NSNumber *fieldNumber = _fields[sectionIndex][fieldIndex];
    GiftCardReceiptField fieldId = fieldNumber.integerValue;
    [self printFieldWithId:fieldId];
}

#pragma mark - Field Printing

- (void)printFieldWithId:(NSInteger)fieldId
{
    switch (fieldId) {
        case GiftCardReceiptFieldStoreName:
            [self printStoreName];
            break;
            
        case GiftCardReceiptFieldAddressline1:
            [self printAddressLine1];
            break;

        case GiftCardReceiptFieldAddressline2:
            [self printAddressLine2];
            break;

        case GiftCardReceiptFieldReceiptName:
            [self printReceiptName];
            break;
            
        case GiftCardReceiptFieldCashierName:
            [self printCashierName];
            break;
            
        case GiftCardReceiptFieldRegisterName:
            [self printRegisterName];
            break;
            
        case GiftCardReceiptFieldTranscationDate:
            [self printTranscationDate];
            break;
            
        case GiftCardReceiptFieldCurrentDate:
            [self printCurrentDate];
            break;

        case GiftCardReceiptFieldNameOfGiftCard:
            [self printNameOfGiftCard];
            break;

        case GiftCardReceiptFieldCardNumber:
            [self printGiftCardNumber];
            break;

        case GiftCardReceiptFieldBalance:
            [self printGiftCardBalance];
            break;
            
        case GiftCardReceiptFieldThanksMessage:
            [self printThanksMessage];
            break;
            
        case GiftCardReceiptFieldBarcode:
            [self printBarcode];
            break;

        default:
            break;
    }
}

- (void)printStoreName {
    [printJob setTextAlignment:TA_CENTER];
    if ((rmsDbController.globalDict)[@"GiftCardMasterInfo"] && [(rmsDbController.globalDict)[@"GiftCardMasterInfo"] count] > 0) {
        [printJob printLine:(rmsDbController.globalDict)[@"GiftCardMasterInfo"] [@"StoreName"]];
    }
    else
    {
        [printJob printLine:[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyBranchName]];
    }
}

- (void)printAddressLine1 {
    [printJob setTextAlignment:TA_CENTER];
    NSString *addressLine1;
    if ((rmsDbController.globalDict)[@"GiftCardMasterInfo"] && [(rmsDbController.globalDict)[@"GiftCardMasterInfo"] count] > 0) {
        addressLine1 = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"GiftCardMasterInfo"] [@"Address"]];
        
        NSArray *arrAddress = [addressLine1 componentsSeparatedByString:@"\r\n"];
        
        for (uint i=0; i < arrAddress.count ;i++)
        {
            NSString *address = [arrAddress objectAtIndex:i];
            [printJob printLine:address];
        }
    }
    else {
        addressLine1 = [NSString stringWithFormat:@"%@  , %@", [self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyAddress1],[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyAddress2]];
        [printJob printLine:addressLine1];
    }
}

- (void)printAddressLine2 {
    [printJob setTextAlignment:TA_CENTER];
    if ((rmsDbController.globalDict)[@"GiftCardMasterInfo"] && [(rmsDbController.globalDict)[@"GiftCardMasterInfo"] count] > 0) {
        if ((rmsDbController.globalDict)[@"GiftCardMasterInfo"] [@"Email"] && [(rmsDbController.globalDict)[@"GiftCardMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"GiftCardMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"GiftCardMasterInfo"] [@"PhoneNo"]];
            [printJob printLine:email];
            [printJob printLine:phoneNo];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"GiftCardMasterInfo"] [@"PhoneNo"]];
            [printJob printLine:phoneNo];
        }
    }
    else {
        NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyCity],[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyState],[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyZipCode]];
        [printJob printLine:addressLine2];
    }
}

- (void)printReceiptName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob enableInvertColor:YES];
    [printJob printLine:@" Gift Card Receipt "];
    [printJob enableInvertColor:NO];
}

- (void)printCashierName {
    [printJob setTextAlignment:TA_LEFT];
    NSString *cashierName = [NSString stringWithFormat:@"Cashier #: %@",[self userInfoValueForKeyIndex:GiftCardReceiptDataKeyUserName]];
    [printJob printLine:cashierName];
}

- (void)printRegisterName {
    [printJob setTextAlignment:TA_LEFT];
    NSString *strRegister =[NSString stringWithFormat:@"Register #: %@",(rmsDbController.globalDict)[@"RegisterName"]];
    [printJob printLine:strRegister];
}

-(void)printCurrentDate
{
    [printJob setTextAlignment:TA_LEFT];
    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    NSString *printDate = [dateFormatter stringFromDate:date];
    NSString *printTime = [timeFormatter stringFromDate:date];
    [printJob printLine:[NSString stringWithFormat:@"Current Date:%@ %@\r\n",printDate,printTime]];
}
-(void)printTranscationDate
{
    [printJob setTextAlignment:TA_LEFT];
    NSString *strTansDate =[NSString stringWithFormat:@"Trans Date:%@ ", strReceiptDate];
    [printJob printLine:strTansDate];
}

-(void)printNameOfGiftCard
{
    [printJob setTextAlignment:TA_LEFT];
    NSString *giftCardName = @"Rapid GiftCard";
    [printJob printLine:giftCardName];
}

-(void)printGiftCardNumber
{
    [self defaultFormatForTwoColumn];
    NSString *giftCardNumber = [receiptDataDictionary valueForKey:@"GiftCardNumber"];
    [printJob printText1:@"Card Number" text2:giftCardNumber];
}

-(void)printGiftCardBalance
{
    [self defaultFormatForTwoColumn];
    NSString *balance = [NSString stringWithFormat:@"%@",[rmsDbController applyCurrencyFomatter:[receiptDataDictionary valueForKey:@"GiftCardTotalBalance"]]];
    [printJob printText1:@"Available Balance" text2:balance];
}

-(void)printThanksMessage
{
    [printJob setTextAlignment:TA_CENTER];
    
    if ((rmsDbController.globalDict)[@"GiftCardMasterInfo"] && [(rmsDbController.globalDict)[@"GiftCardMasterInfo"] count] > 0 && (rmsDbController.globalDict)[@"GiftCardMasterInfo"] [@"ThanksNote"] && [(rmsDbController.globalDict)[@"GiftCardMasterInfo"] [@"ThanksNote"] length] > 0) {
        NSString *thanksMessage = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"GiftCardMasterInfo"] [@"ThanksNote"]];
        
        NSArray *arrThanks = [thanksMessage componentsSeparatedByString:@"\r\n"];
        
        for (uint i=0; i < arrThanks.count ;i++)
        {
            NSString *strThanks = [arrThanks objectAtIndex:i];
            [printJob printLine:strThanks];
        }
    }
    else
    {
        if ([[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyHelpMessage1] length]>0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyHelpMessage1]]];
        }
        [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyBranchName]]];
        if ([[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyHelpMessage2] length]>0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyHelpMessage2]]];
        }
        if ([[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyHelpMessage3] length]>0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:GiftCardReceiptDataKeyHelpMessage3]]];
        }
    }
}

-(void)printBarcode
{
    [printJob setTextAlignment:TA_CENTER];
    NSString *giftCardNumber = [receiptDataDictionary valueForKey:@"GiftCardNumber"];
    [printJob printBarCode:giftCardNumber];
}

#pragma mark - Footer Printing

-(void)printFooterForSection:(NSInteger)section
{
    switch (section) {
        case GiftCardReceiptSectionReceiptHeader:
            [printJob printLine:@""];
            break;
            
        case GiftCardReceiptSectionReceiptInfo:
            [printJob printSeparator];
            break;
            
        case GiftCardReceiptSectionGiftCardDetail:
            [printJob printSeparator];
            [printJob printLine:@""];
            break;
            
        case GiftCardReceiptSectionThanksMessage:
            [printJob printLine:@""];
            break;
            
        case GiftCardReceiptSectionBarcode:
            [printJob printLine:@""];
            break;
            
        case GiftCardReceiptSectionReceiptFooter:
            
            break;
            
        default:
            break;
    }
}

#pragma mark - Common Utility

- (id)branchInfoValueForKeyIndex:(GiftCardReceiptDataKey)index
{
    return [self valueFromDictionary:[self branchInfo] forKeyIndex:index];
}

- (id)userInfoValueForKeyIndex:(GiftCardReceiptDataKey)index
{
    return [self valueFromDictionary:[self userInfo] forKeyIndex:index];
}

- (id)valueFromDictionary:(NSDictionary *)dictionary forKeyIndex:(GiftCardReceiptDataKey)index
{
    return dictionary[[self keyForIndex:index]];
}

- (NSString *)keyForIndex:(GiftCardReceiptDataKey)index
{
    return giftCardReceiptDataKeys[index];
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

- (void)defaultFormatForTwoColumn
{
    columnWidths[0] = 23;
    columnWidths[1] = 23;
    columnAlignments[0] = GiftCardRPAlignmentLeft;
    columnAlignments[1] = GiftCardRPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

@end
