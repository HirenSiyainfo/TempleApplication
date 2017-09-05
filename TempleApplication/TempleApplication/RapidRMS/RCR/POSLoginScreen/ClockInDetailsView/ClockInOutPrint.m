//
//  ClockInOutPrint.m
//  RapidRMS
//
//  Created by Siya Infotech on 09/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ClockInOutPrint.h"
#import "RasterPrintJob.h"
#import "PaxConstants.h"
#import "RasterPrintJobBase.h"

@implementation ClockInOutPrint


- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSArray *)printData startDate:(NSString *)startDate endDate:(NSString *)endDate clockInOutUser:(NSString *)clockInOutUser
{
    self = [super init];
    if (self) {
        portNameForPrinter = portName;
        portSettingsForPrinter = portSettings;
        receiptDataArray = printData;
        rmsDbController = [RmsDbController sharedRmsDbController];
        strStartDate = [startDate copy];
        strEndDate = [endDate copy];
        strClockInOutUser = [clockInOutUser copy];
        receiptDataKeys = @[
                            @"BranchName",
                            @"Address1",
                            @"Address2",
                            @"City",
                            @"State",
                            @"ZipCode",
                            @"UserName",
                            ];
    }
    return self;
}

//// Receipt Section and Feild

- (void)configureInvoiceReceiptSection {
    
    //// section detail
    _sections = @[
                  @(ReceiptSectionReceiptHeader),
                  @(ReceiptSectionReceiptInfo),
                  @(ReceiptSectionClockInOutDetails),
                  @(ReceiptSectionReceiptFooter),
                  ];
    
    NSArray *receiptHeaderSectionFields = @[
                                           @(ReceiptFieldStoreName),
                                           @(ReceiptFieldAddressline1),
                                           @(ReceiptFieldAddressline2),
                                           ];
    
    NSArray *receiptInfoSectionFields = @[
                                     @(ReceiptFieldReceiptName),
                                     @(ReceiptFieldRegisterName),
                                     @(ReceiptFieldCurrentUserName),
                                     @(ReceiptFieldClockInOutUserName),
                                     @(ReceiptFieldCurrentDate),
                                     @(ReceiptFieldDateRange),
                                     ];
    
    NSArray *receiptClockInOutDetailsSectionFields = @[
                                    @(ReceiptFieldClockInOutDetails),
                                    ];
    
    NSArray *receiptFooterSectionFields = @[
                                ];

    /// field detail
    _fields = @[
                receiptHeaderSectionFields,
                receiptInfoSectionFields,
                receiptClockInOutDetailsSectionFields,
                receiptFooterSectionFields,
                ];
}


- (id)branchInfoValueForKeyIndex:(ReceiptDataKey)index
{
    return [self valueFromDictionary:[self branchInfo] forKeyIndex:index];
}

- (id)userInfoValueForKeyIndex:(ReceiptDataKey)index
{
    return [self valueFromDictionary:[self userInfo] forKeyIndex:index];
}

- (id)valueFromDictionary:(NSDictionary *)dictionary forKeyIndex:(ReceiptDataKey)index
{
   return dictionary[[self keyForIndex:index]];
}

- (NSString *)keyForIndex:(ReceiptDataKey)index
{
    return receiptDataKeys[index];
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

#pragma mark - Html
- (NSString *)generateHtmlForClockInOutDetails:(NSString *)htmlString {
    htmlString = [self htmlAfterReplcementOfValues:htmlString];
    return htmlString;
}

-(NSString *)htmlAfterReplcementOfValues:(NSString *)html {
    //Replace Store Name
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        html = [self replaceHtmlString:html replaceString:@"$$STORE_NAME$$" withValue:[NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"StoreName"]]];
    }
    else
    {
        html = [self replaceHtmlString:html replaceString:@"$$STORE_NAME$$" withValue:[self branchInfoValueForKeyIndex:ReceiptDataKeyBranchName]];
    }

    //Replace Address1
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        html = [self replaceHtmlString:html replaceString:@"$$ADDRESS1$$" withValue:[NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]]];
    }
    else {
        html = [self replaceHtmlString:html replaceString:@"$$ADDRESS1$$" withValue:[NSString stringWithFormat:@"%@%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyAddress1],[self branchInfoValueForKeyIndex:ReceiptDataKeyAddress2]]];
    }

    //Replace Address2
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            html = [self replaceHtmlString:html replaceString:@"$$ADDRESS2$$" withValue:[NSString stringWithFormat:@"%@ - %@",email,phoneNo]];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            html = [self replaceHtmlString:html replaceString:@"$$ADDRESS2$$" withValue:[NSString stringWithFormat:@"%@",phoneNo]];
        }
    }
    else {
        html = [self replaceHtmlString:html replaceString:@"$$ADDRESS2$$" withValue:[NSString stringWithFormat:@"%@%@%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyCity],[self branchInfoValueForKeyIndex:ReceiptDataKeyState],[self branchInfoValueForKeyIndex:ReceiptDataKeyZipCode]]];
    }
    
    //Replace Receipt Name
    html = [self replaceHtmlString:html replaceString:@"$$RECEIPT_NAME$$" withValue:@"Clock-In/Out"];
    //Replace Register Name
    html = [self replaceHtmlString:html replaceString:@"$$REGISTER_NAME$$" withValue:[self getRegisterName]];
    //Replace Current User Name
    html = [self replaceHtmlString:html replaceString:@"$$CURRENT_USER_NAME$$" withValue:[self getCurrentUserName]];
    //Replace Clock-In/Out User Name
    html = [self replaceHtmlString:html replaceString:@"$$CLOCK_IN_OUT_USER_NAME$$" withValue:[self clockInOutUserName]];
    //Replace Current Date
    html = [self replaceHtmlString:html replaceString:@"$$CURRENT_DATE$$" withValue:[NSString stringWithFormat:@"%@ %@",[[self getCurrentDate] valueForKey:@"CurrentDate"],[[self getCurrentDate] valueForKey:@"CurrentTime"]]];
    //Replace Date Range
    html = [self replaceHtmlString:html replaceString:@"$$START_DATE$$" withValue:[self getStatDate]];
    html = [self replaceHtmlString:html replaceString:@"$$END_DATE$$" withValue:[self getEndDate]];
    //Replace Start And EndTime
    html = [self replaceHtmlString:html replaceString:@"$$ITEM_HTML$$" withValue:[self htmlStringForStartAndEndTime]];
    return html;
}

- (NSString *)htmlStringForStartAndEndTime {
    NSString *strHtml = @"";
    for (NSDictionary *dictionary in receiptDataArray) {
        NSString *clockInDate = [self getCovertedTime:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"Date"]]] currentFormate:@"MMMM dd, yyyy" convertInto:@"MM/dd/yyyy"];
        NSString *clockInDay = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"Day"]];
        NSString *clockInTime = [self getCovertedTime:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"ClockInTime"]]] currentFormate:@"hh:mm:ss a" convertInto:@"hh:mm a"];
        NSString *clockOutTime = [self getCovertedTime:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"ClockOutTime"]] currentFormate:@"hh:mm:ss a" convertInto:@"hh:mm a"];
        NSString *hours = [self stringFromTimeInterval:[[dictionary valueForKey:@"WorkingTime"] integerValue]];
        if (!clockOutTime || clockOutTime.length == 0) {
            clockOutTime = @"-";
        }
        if (!clockInTime || clockInTime.length == 0) {
            clockInTime = @"-";
        }
        strHtml = [strHtml stringByAppendingFormat:@"<tr><td style=\"width:20%@;float:left; text-align:left;\"><font size=\"2\">%@</font> </td><td style=\"width:20%@;float:left; text-align:left;\"><font size=\"2\">%@</font> </td><td style=\"width:20%@;float:left; text-align:left;\"><font size=\"2\">%@</font> </td><td style=\"width:20%@;float:left; text-align:right;\"><font size=\"2\">%@</font> </td><td style=\"width:20%@;float:right; text-align:right;\"><font size=\"2\">%@</font> </td></tr>",@"%",clockInDate,@"%",clockInDay,@"%",clockInTime,@"%",clockOutTime,@"%",hours];
    }
    strHtml = [strHtml stringByAppendingFormat:@"<tr style=\"width:100%%;  border-top:dashed 1px #000;  float:left;padding-top:2px; font-size:14px;\"><td style=\"width:20%@;float:left; text-align:left;\"><strong><font size=\"2\">%@</font> </strong></td><td style=\"width:20%@;float:left; text-align:left;\"><strong><font size=\"2\">%@</font> </strong></td><td style=\"width:20%@;float:left; text-align:left;\"><strong><font size=\"2\">%@</font> </strong></td><td style=\"width:20%@;float:left; text-align:right;\"><strong><font size=\"2\">%@</font> </strong></td><td style=\"width:20%@;float:right; text-align:right;\"><strong><font size=\"2\">%@</font> </strong></td></tr>",@"%",@"Total",@"%",@"",@"%",@"",@"%",@"",@"%",[self getTotalTime]];
    return strHtml;
}

- (NSString *)replaceHtmlString:(NSString *)htmlString replaceString:(NSString *)replaceString withValue:(NSString *)stringValue {
    htmlString = [htmlString stringByReplacingOccurrencesOfString:replaceString withString:stringValue];
    return htmlString;
}

#pragma mark - Bluetooth Printing
//// print receipt start ////

- (NSInteger)sectionAtSectionIndex:(NSInteger)sectionIndex {
    return [_sections[sectionIndex] integerValue];
}

- (void)printClockInOutDetailsWithDelegate:(id)delegate
{
    if(receiptDataArray.count>0)
    {
        [self configureInvoiceReceiptSection];
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

//// headerSection

-(void)printHeaderForSection:(NSInteger)section
{
    {
        switch (section) {
            case ReceiptSectionReceiptHeader:
                break;
                
            case ReceiptSectionReceiptInfo:
                break;
                
            case ReceiptSectionClockInOutDetails:
                [self defaultFormatForFourColumn];
                [printJob enableBold:YES];
                [printJob printSeparator];
                [printJob printText1:@"Date" text2:@"Start Time" text3:@"End Time" text4:@"Hours"];
                [printJob printSeparator];
                [printJob enableBold:NO];
                break;
                
            case ReceiptSectionReceiptFooter:
                break;

            default:
                //      [printJob printLine:[NSString stringWithFormat:@"Section Header - %@", @(section)]];
                break;
        }
    }
    
}

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
    ReceiptFeild fieldId = fieldNumber.integerValue;
    [self printFieldWithId:fieldId];
}

//// fields

- (void)printFieldWithId:(NSInteger)fieldId
{
    switch (fieldId) {
        case ReceiptFieldStoreName:
            [self printStoreName];
            break;
            
        case ReceiptFieldAddressline1:
            [self printAddressLine1];
            break;
            
        case ReceiptFieldAddressline2:
           [self printAddressLine2];
            break;
            
        case ReceiptFieldReceiptName:
           [self printReceiptName];
            break;
            
        case ReceiptFieldRegisterName:
            [self printRegisterName];
            break;
            
        case ReceiptFieldCurrentUserName:
            [self printCurrentUserName];
            break;
            
        case ReceiptFieldClockInOutUserName:
            [self printClockInOutUserName];
            break;

        case ReceiptFieldCurrentDate:
            [self printCurrentDate];
            break;
            
        case ReceiptFieldDateRange:
            [self printDateRange];
            break;
            
        case ReceiptFieldClockInOutDetails:
            [self printClockInOutDetails];
            break;

        default:
            NSLog(@"Implement Field - %@", @(fieldId));
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
        [printJob printLine:[self branchInfoValueForKeyIndex:ReceiptDataKeyBranchName]];
    }

}

- (void)printAddressLine1 {
    [printJob setTextAlignment:TA_CENTER];
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
            [printJob printLine:address];
        }
    }
    else {
      addressLine1 = [NSString stringWithFormat:@"%@  , %@", [self branchInfoValueForKeyIndex:ReceiptDataKeyAddress1],[self branchInfoValueForKeyIndex:ReceiptDataKeyAddress2]];
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
        NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [self branchInfoValueForKeyIndex:ReceiptDataKeyCity],[self branchInfoValueForKeyIndex:ReceiptDataKeyState],[self branchInfoValueForKeyIndex:ReceiptDataKeyZipCode]];
        [printJob printLine:addressLine2];
    }
}

- (void)printReceiptName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob enableInvertColor:YES];
    [printJob printLine:@" Clock-In/Out "];
    [printJob enableInvertColor:NO];
}

-(void)printRegisterName
{
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:[NSString stringWithFormat:@"Register: %@",[self getRegisterName]]];
}

- (NSString *)getRegisterName {
    return (rmsDbController.globalDict)[@"RegisterName"];
}

- (void)printCurrentUserName {
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:[NSString stringWithFormat:@"Current User: %@",[self getCurrentUserName]]];
}

- (NSString *)getCurrentUserName {
    NSString *strUserName = [NSString stringWithFormat:@"%@",[self userInfoValueForKeyIndex:ReceiptDataKeyUserName]];
    return strUserName;
}

- (NSString *)clockInOutUserName {
    NSString *strUserName = [NSString stringWithFormat:@"%@",strClockInOutUser];
    return strUserName;
}

- (void)printClockInOutUserName {
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:[NSString stringWithFormat:@"Clock-In/Out User: %@",[self clockInOutUserName]]];
}

-(void)printCurrentDate
{
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:[NSString stringWithFormat:@"Current Date:%@ %@",[[self getCurrentDate] valueForKey:@"CurrentDate"],[[self getCurrentDate] valueForKey:@"CurrentTime"]]];
}

- (NSDictionary *)getCurrentDate {
    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    NSString *printDate = [dateFormatter stringFromDate:date];
    NSString *printTime = [timeFormatter stringFromDate:date];
    return @{
             @"CurrentDate":printDate,
             @"CurrentTime":printTime
             };
}

- (void)printDateRange {
    [printJob setTextAlignment:TA_LEFT];
    [printJob enableBold:true];
    [printJob printLine:@"Date Range:"];
    [printJob enableBold:false];
    [printJob printLine:[NSString stringWithFormat:@"    Start Date: %@",[self getStatDate]]];
    [printJob printLine:[NSString stringWithFormat:@"    End Date: %@\r\n",[self getEndDate]]];
}

- (NSString *)getStatDate {
    NSString *startDate = [self getCovertedTime:strStartDate currentFormate:@"MMMM dd, yyyy" convertInto:@"MM/dd/yyyy"];
    return startDate;
}

- (NSString *)getEndDate {
    NSString *endDate = [self getCovertedTime:strEndDate currentFormate:@"MMMM dd, yyyy" convertInto:@"MM/dd/yyyy"];
    return endDate;
}

- (void)printClockInOutDetails {
    [self defaultFormatForFourColumn];
    for (NSDictionary *dictionary in receiptDataArray) {
        NSString *clockInDate = [self getCovertedTime:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"Date"]]] currentFormate:@"MMMM dd, yyyy" convertInto:@"MM/dd/yyyy"];
        NSString *clockInTime = [self getCovertedTime:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"ClockInTime"]]] currentFormate:@"hh:mm:ss a" convertInto:@"hh:mm a"];
        NSString *clockOutTime = [self getCovertedTime:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"ClockOutTime"]] currentFormate:@"hh:mm:ss a" convertInto:@"hh:mm a"];
        NSString *hours = [self stringFromTimeInterval:[[dictionary valueForKey:@"WorkingTime"] integerValue]];
        if (!clockOutTime || clockOutTime.length == 0) {
            clockOutTime = @"-";
        }
        if (!clockInTime || clockInTime.length == 0) {
            clockInTime = @"-";
        }
        [printJob printText1:clockInDate text2:clockInTime text3:clockOutTime text4:hours];
    }
}

- (NSString *)getCovertedTime:(NSString *)time currentFormate:(NSString *)currentFormate convertInto:(NSString *)convertedFormate {
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = currentFormate;
    NSDate *printDate = [timeFormatter dateFromString:time];
    timeFormatter.dateFormat = convertedFormate;
    NSString *printTime = [timeFormatter stringFromDate:printDate];
    return printTime;
}

//// footerSection
- (void)printFooterForSection:(NSInteger)section {
    switch (section) {
        case ReceiptSectionReceiptHeader:
            break;
            
        case ReceiptSectionReceiptInfo:
            break;
            
        case ReceiptSectionClockInOutDetails:
        {
            [self defaultFormatForFourColumn];
            [printJob enableBold:YES];
            [printJob printSeparator];
            [printJob printText1:@"Total" text2:@"" text3:@"" text4:[self getTotalTime]];
            [printJob enableBold:NO];
        }
            break;
            
        case ReceiptSectionReceiptFooter:
            break;
            
            default:
            break;
    }
}

- (NSString *)getTotalTime {
    NSInteger totalSeconds = [[receiptDataArray valueForKeyPath:@"@sum.WorkingTime"] integerValue];
    NSString *totalTime = [self stringFromTimeInterval:totalSeconds];
    return totalTime;
}
#pragma mark - Formating

- (void)defaultFormatForFourColumn
{
    columnWidths[0] = 12;
    columnWidths[1] = 11;
    columnWidths[2] = 11;
    columnWidths[3] = 11;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentRight;
    columnAlignments[2] = RPAlignmentRight;
    columnAlignments[3] = RPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

#pragma mark - Utility

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)hours, (long)minutes];
}

@end
