//
//  HouseChargeReceiptPrint.m
//  RapidRMS
//
//  Created by siya8 on 23/01/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "HouseChargeReceiptPrint.h"
#import "RasterPrintJob.h"
#import "RasterPrintJobBase.h"

@implementation HouseChargeReceiptPrint

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSMutableArray *)houseChargeDataArray withReceiptDate:(NSString*)receiptDate withIsSignature:(BOOL)isSign{
    self = [super init];
    if (self) {
        portNameForPrinter = portName;
        portSettingsForPrinter = portSettings;
        receiptDataArray = houseChargeDataArray;
        rmsDbController = [RmsDbController sharedRmsDbController];
        strReceiptDate = receiptDate;
        isSignature = isSign;
        houseChargeReceiptDataKeys = @[
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
- (void)configureHouseChargeReceiptSection {

    //// section detail
    _sections = @[
                  @(HouseChargeReceiptSectionReceiptHeader),
                  @(HouseChargeReceiptSectionReceiptInfo),
                  @(HouseChargeReceiptSectionHouseChargeDetail),
                  @(HouseChargeReceiptSectionThanksMessage),
                  @(HouseChargeReceiptSectionBarcode),
                  @(HouseChargeReceiptSectionReceiptFooter),
                  ];

    NSArray *receiptHeaderSectionFields = @[
                                            @(HouseChargeReceiptFieldStoreName),
                                            @(HouseChargeReceiptFieldAddressline1),
                                            @(HouseChargeReceiptFieldAddressline2),
                                            ];
    
    NSArray *receiptInfoSectionFields = @[
                                          @(HouseChargeReceiptFieldReceiptName),
                                          @(HouseChargeReceiptFieldReceiptType),
                                          @(HouseChargeReceiptFieldCashierName),
                                          @(HouseChargeReceiptFieldRegisterName),
                                          @(HouseChargeReceiptFieldTranscationDate),
                                          @(HouseChargeReceiptFieldCurrentDate),
                                          ];

    NSArray *receiptGiftCardDetailSectionFields = @[
                                                    @(HouseChargeReceiptFieldNameOfHouseChargeUser),
                                                    @(HouseChargeReceiptFieldCardNumber),
                                                    @(HouseChargeReceiptFieldBalance),
                                                    ];
    
    NSArray *receiptBarcodeSectionFields = @[
                                             @(HouseChargeReceiptFieldBarcode),
                                             ];
    
    NSArray *receiptThanksMessageSectionFields = @[
                                                   @(HouseChargeReceiptFieldSignature),
                                                   @(HouseChargeReceiptFieldThanksMessage),
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

- (void)printHouseChargeReceiptWithDelegate:(id)delegate
{
    [self configureHouseChargeReceiptSection];
    [self configurePrint:portSettingsForPrinter portName:portNameForPrinter withDelegate:delegate];
    _printerWidth = 48;
    
    NSInteger sectionCount = _sections.count;
    for (int i = 0; i < sectionCount; i++) {
        HouseChargeReceiptSection section = [self sectionAtSectionIndex:i];
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
        case HouseChargeReceiptSectionReceiptHeader:
            
            break;
            
        case HouseChargeReceiptSectionReceiptInfo:
            break;
            
        case HouseChargeReceiptSectionHouseChargeDetail:
            
            break;
            
        case HouseChargeReceiptSectionThanksMessage:
            
            break;
            
        case HouseChargeReceiptSectionBarcode:
            
            break;
            
        case HouseChargeReceiptSectionReceiptFooter:
            
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
    HouseChargeReceiptField fieldId = fieldNumber.integerValue;
    [self printFieldWithId:fieldId];
}

#pragma mark - Field Printing

- (void)printFieldWithId:(NSInteger)fieldId
{
    switch (fieldId) {
        case HouseChargeReceiptFieldStoreName:
            [self printStoreName];
            break;
            
        case HouseChargeReceiptFieldAddressline1:
            [self printAddressLine1];
            break;
            
        case HouseChargeReceiptFieldAddressline2:
            [self printAddressLine2];
            break;
            
        case HouseChargeReceiptFieldReceiptName:
            [self printReceiptName];
            break;
            
        case HouseChargeReceiptFieldReceiptType:
            [self printReceiptType];
            break;
   
        case HouseChargeReceiptFieldCashierName:
            [self printCashierName];
            break;
            
        case HouseChargeReceiptFieldRegisterName:
            [self printRegisterName];
            break;
            
        case HouseChargeReceiptFieldTranscationDate:
            [self printTranscationDate];
            break;
            
        case HouseChargeReceiptFieldCurrentDate:
            [self printCurrentDate];
            break;
            
        case HouseChargeReceiptFieldNameOfHouseChargeUser:
            [self printNameOfHouseChargeUSer];
            break;
            
        case HouseChargeReceiptFieldCardNumber:
            [self printHouseChargeId];
            break;
            
        case HouseChargeReceiptFieldBalance:
            [self printHouseChargeBalance];
            break;
            
        case HouseChargeReceiptFieldSignature:
                [self printSignature];
            break;

        case HouseChargeReceiptFieldThanksMessage:
            [self printThanksMessage];
            break;
            
        case HouseChargeReceiptFieldBarcode:
            [self printBarcode];
            break;
            
        default:
            break;
    }
}

- (void)printStoreName {
    [printJob setTextAlignment:TA_CENTER];
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        [printJob printLine:(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"StoreName"]];
    }
    else
    {
        [printJob printLine:[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyBranchName]];
    }
}

- (void)printAddressLine1 {
    [printJob setTextAlignment:TA_CENTER];
    NSString *addressLine1;
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        addressLine1 = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]];
        
        NSArray *arrAddress = [addressLine1 componentsSeparatedByString:@"\r\n"];
        
        for (uint i=0; i < arrAddress.count ;i++)
        {
            NSString *address = [arrAddress objectAtIndex:i];
            [printJob printLine:address];
        }
    }
    else {
        addressLine1 = [NSString stringWithFormat:@"%@  , %@", [self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyAddress1],[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyAddress2]];
        [printJob printLine:addressLine1];
    }
}

- (void)printAddressLine2 {
    [printJob setTextAlignment:TA_CENTER];
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [printJob printLine:email];
            [printJob printLine:phoneNo];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [printJob printLine:phoneNo];
        }
    }
    
    else {
        NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyCity],[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyState],[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyZipCode]];
        [printJob printLine:addressLine2];
    }
}

- (void)printReceiptName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob enableInvertColor:YES];
    [printJob printLine:@" House Charge Receipt "];
    [printJob enableInvertColor:NO];
}

- (void)printCashierName {
    [printJob setTextAlignment:TA_LEFT];
    NSString *cashierName = [NSString stringWithFormat:@"Cashier #: %@",[self userInfoValueForKeyIndex:HouseChargeReceiptDataKeyUserName]];
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
-(void)printReceiptType{
    if(isSignature){
        [printJob printLine:@""];
        [printJob setTextAlignment:TA_LEFT];
        [printJob printLine:@"Store Copy"];
        [printJob printLine:@""];

    }
    else{
        [printJob printLine:@""];
        [printJob setTextAlignment:TA_LEFT];
        [printJob printLine:@"Customer Copy"];
        [printJob printLine:@""];
    }
}

-(void)printNameOfHouseChargeUSer
{
    [self defaultFormatForTwoColumn];
    NSString *custName = [NSString stringWithFormat:@"%@",[receiptDataArray.firstObject valueForKey:@"CustName"]];
    if ([custName isEqualToString:@""]) {
        [printJob printText1:@"Customer Name:" text2:[receiptDataArray.firstObject valueForKey:@"CustEmail"]];
    }
    else{
        [printJob printText1:@"Customer Name:" text2:custName];
    }
}

-(void)printHouseChargeId
{
    [self defaultFormatForTwoColumn];
    NSString *custId = [NSString stringWithFormat:@"%@",[receiptDataArray.firstObject valueForKey:@"CustContactNo"]];
    if ([custId isEqualToString:@""]) {
        [printJob printText1:@"Customer Contact no:" text2:@"-"];
    }
    else{
        [printJob printText1:@"Customer Contact no:" text2:custId];
    }
}

-(void)printHouseChargeBalance
{
    [self defaultFormatForTwoColumn];
    NSString *balance = [NSString stringWithFormat:@"%@",[receiptDataArray.firstObject valueForKey:@"AvailableBalance"]];
    [printJob printText1:@"Available Balance: " text2:balance];
}
-(void)printSignature
{
    if (isSignature){
        
    [printJob setTextAlignment:TA_RIGHT];
    [printJob printLine:@"Signature:"];
    [printJob printLine:@""];
    [printJob printLine:@""];
    [printJob printLine:@""];
    [printJob printLine:@""];

    [printJob setTextAlignment:TA_RIGHT];
    NSString *line = [[NSString string] stringByPaddingToLength:30 withString:@"-" startingAtIndex:0];
    NSString *strLine = [NSString stringWithFormat:@"X %@",line];
    [printJob printLine:strLine];
    
    [printJob printLine:@""];
    }
    
}

-(void)printThanksMessage
{
    [printJob setTextAlignment:TA_CENTER];
    
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0 && (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"] length] > 0) {
        NSString *thanksMessage = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"]];
        
        NSArray *arrThanks = [thanksMessage componentsSeparatedByString:@"\r\n"];
        
        for (uint i=0; i < arrThanks.count ;i++)
        {
            NSString *strThanks = [arrThanks objectAtIndex:i];
            [printJob printLine:strThanks];
        }
    }
    else
    {
        if ([[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyHelpMessage1] length]>0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyHelpMessage1]]];
        }
        [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyBranchName]]];
        if ([[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyHelpMessage2] length]>0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyHelpMessage2]]];
        }
        if ([[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyHelpMessage3] length]>0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:HouseChargeReceiptDataKeyHelpMessage3]]];
        }
    }
}

-(void)printBarcode
{
//    [printJob setTextAlignment:TA_CENTER];
//    NSString *giftCardNumber = [receiptDataDictionary valueForKey:@"GiftCardNumber"];
//    [printJob printBarCode:giftCardNumber];
    
}

#pragma mark - Footer Printing

-(void)printFooterForSection:(NSInteger)section
{
    switch (section) {
        case HouseChargeReceiptSectionReceiptHeader:
            [printJob printLine:@""];
            break;
            
        case HouseChargeReceiptSectionReceiptInfo:
            [printJob printSeparator];
            break;
            
        case HouseChargeReceiptSectionHouseChargeDetail:
            [printJob printSeparator];
            [printJob printLine:@""];
            break;
            
        case HouseChargeReceiptSectionThanksMessage:
            [printJob printLine:@""];
            break;
            
        case HouseChargeReceiptSectionBarcode:
            [printJob printLine:@""];
            break;
            
        case HouseChargeReceiptSectionReceiptFooter:
            
            break;
            
        default:
            break;
    }
}

#pragma mark - Common Utility

- (id)branchInfoValueForKeyIndex:(HouseChargeReceiptDataKey)index
{
    return [self valueFromDictionary:[self branchInfo] forKeyIndex:index];
}

- (id)userInfoValueForKeyIndex:(HouseChargeReceiptDataKey)index
{
    return [self valueFromDictionary:[self userInfo] forKeyIndex:index];
}

- (id)valueFromDictionary:(NSDictionary *)dictionary forKeyIndex:(HouseChargeReceiptDataKey)index
{
    return dictionary[[self keyForIndex:index]];
}

- (NSString *)keyForIndex:(HouseChargeReceiptDataKey)index
{
    return houseChargeReceiptDataKeys[index];
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
    columnAlignments[0] = HouseChargeRPAlignmentLeft;
    columnAlignments[1] = HouseChargeRPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

@end
