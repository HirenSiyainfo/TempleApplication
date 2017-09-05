//
//  BasicCCbatchReceipt.m
//  RapidRMS
//
//  Created by Siya7 on 6/7/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "BasicCCbatchReceipt.h"

@implementation BasicCCbatchReceipt

- (instancetype)init {
    self = [super init];
    if (self) {
        _sections = @[];
        _fields = @[];
        _rmsDbController = [RmsDbController sharedRmsDbController];
        currencyFormatter = [[NSNumberFormatter alloc] init];
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        currencyFormatter.maximumFractionDigits = 2;
        _printerWidth = 48;
        
        receiptBatchDetailArray = [[NSArray alloc]init];
        
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
    NSDictionary *dictBranchInfo = [_rmsDbController.globalDict valueForKey:@"BranchInfo"];
    return dictBranchInfo;
}
- (NSDictionary *)userInfo
{
    NSDictionary *dictUserInfo = [_rmsDbController.globalDict valueForKey:@"UserInfo"];
    return dictUserInfo;
}



#pragma mark - Bluetooth Printing
//// print receipt start ////

- (NSInteger)sectionAtSectionIndex:(NSInteger)sectionIndex {
    return [_sections[sectionIndex] integerValue];
}
- (void)printccBatchReceiptWithDelegate:(id)delegate
{
//    if(receiptDataArray.count>0)
    {
        [self configureInvoiceReceiptSection];
        [self configurePrint:portSettingsForPrinter portName:portNameForPrinter withDelegate:delegate];
        _printerWidth = 48;
        
        NSInteger sectionCount = _sections.count;
        for (int i = 0; i < sectionCount; i++) {
            ReceiptSection section = [self sectionAtSectionIndex:i];
            [self printHeaderForSection:section];
            [self printCommandForSectionAtIndex:i];
        }
        [self concludePrint];
    }
}
//HeaderForSection
-(void)printHeaderForSection:(NSInteger)section
{
    {
        switch (section) {
            case ReceiptSectionReceiptHeader:
                break;
                
            case ReceiptSectionReceiptInfo:
                break;
                
            case ReceiptSectionItemDetail:
                [_printJob enableBold:YES];
                [_printJob printLine:[NSString stringWithFormat:@"PaymentGateway : %@",self.paymentGateway]];
                [_printJob printSeparator];
                [_printJob enableBold:NO];
                break;
                
            default:
                //      [_printJob printLine:[NSString stringWithFormat:@"Section Header - %@", @(section)]];
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
            
        case ReceiptFieldCashierAndRegisterName:
            [self printCashierAndRegister];
            break;
            
        case ReceiptFieldReceiptCurrentDate:
            [self printDateAndTime];
            break;
            
        case ReceiptFieldBatchNo:
            [self printBatchNo];
            break;
            
            case ReceiptFieldTitle:
            [self printTitle];
            break;
            
        case ReceiptFieldTotalCreditCardDetail:
            [self printCreditCardDetail];
            break;
            
            
        case ReceiptFieldTotalDebitCardDetail:
            [self printDebitCardDetail];
            break;
            
        case ReceiptFieldTotalAmountCount:
            [self printTotalAmountCount];
            break;
            
        case ReceiptFieldBridgePayCCBatchData:
            [self printBridgePayDetail];
            break;

        default:
            NSLog(@"Implement Field - %@", @(fieldId));
            break;
    }
    
}

- (void)printStoreName {
    [_printJob setTextAlignment:TA_CENTER];
    if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        [_printJob printLine:(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"StoreName"]];
    }
    else
    {
        [_printJob printLine:[self branchInfoValueForKeyIndex:ReceiptDataKeyBranchName]];
    }
}

- (void)printAddressLine1 {
    [_printJob setTextAlignment:TA_CENTER];
    NSString *addressLine1;
    if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        addressLine1 = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]];
        
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

- (void)printAddressLine2 {
    [_printJob setTextAlignment:TA_CENTER];
    if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [_printJob printLine:email];
            [_printJob printLine:phoneNo];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [_printJob printLine:phoneNo];
        }
    }
    else {
        NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [self branchInfoValueForKeyIndex:ReceiptDataKeyCity],[self branchInfoValueForKeyIndex:ReceiptDataKeyState],[self branchInfoValueForKeyIndex:ReceiptDataKeyZipCode]];
        [_printJob printLine:addressLine2];
    }
}

-(void)printCashierAndRegister
{
    NSString *salesPersonName=[NSString stringWithFormat:@"%@",[self userInfoValueForKeyIndex:ReceiptDataKeyUserName]];
    NSString *strCashier = [NSString stringWithFormat:@"Cashier #: %@",salesPersonName];
    NSString *strRegister = [NSString stringWithFormat:@"Register #: %@",(_rmsDbController.globalDict)[@"RegisterName"]];
    [self defaultFormatForReceptInfo];
    [_printJob printText1:strCashier text2:strRegister];
    
}

-(void)printDateAndTime
{
    [_printJob setTextAlignment:TA_LEFT];
    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    NSString *printDate = [dateFormatter stringFromDate:date];
    NSString *printTime = [timeFormatter stringFromDate:date];
    [_printJob printLine:[NSString stringWithFormat:@"Current Date:%@ %@",printDate,printTime]];
}

-(void)printBatchNo
{
    [_printJob setTextAlignment:TA_LEFT];
    [_printJob printLine:[NSString stringWithFormat:@"Batch No : %@",self.batchNo]];
    [_printJob printLine:@""];
}

- (void)printReceiptName {
    [_printJob setTextAlignment:TA_CENTER];
    [_printJob enableInvertColor:YES];
    [_printJob printLine:@" CC Batch Receipt "];
    [_printJob enableInvertColor:NO];
}

-(void)printTitle{
    [_printJob enableBold:YES];
    [self defaultFormatForFourColumn];
    [_printJob printText1:@"TenderType" text2:@"Amount" text3:@"Count" text4:@"Avg Ticket"];
    [_printJob printSeparator];
    [_printJob enableBold:NO];


}
- (void)printCreditCardDetail {
    [self defaultFormatForFourColumn];
    
    float amount = [_paxCreditDebitDetailDict[@"TotalCreditAmountValue"] floatValue];
    int count = [_paxCreditDebitDetailDict[@"TotalCreditCount"] intValue];
    if (count != 0) {
        creditAvgTicket = amount / count ;
    }
    else{
        creditAvgTicket = 0;
    }
    [_printJob printText1:@"Credit" text2:[NSString stringWithFormat:@"$%.2f",[_paxCreditDebitDetailDict[@"TotalCreditAmountValue"] floatValue]] text3:[NSString stringWithFormat:@"%d",[_paxCreditDebitDetailDict[@"TotalCreditCount"] intValue]] text4:[NSString stringWithFormat:@"$%.2f", creditAvgTicket]];
}
//- (void)printTotalCreditAmount {
//    [_printJob setTextAlignment:TA_LEFT];
//    [_printJob printLine:[NSString stringWithFormat:@"Total Count : %ld",(long)self.totalCount]];
//}
//- (void)printTotalDebitCount {
//    [_printJob setTextAlignment:TA_LEFT];
//    [_printJob printLine:[NSString stringWithFormat:@"Total Count : %ld",(long)self.totalCount]];
//}
- (void)printDebitCardDetail {
    [self defaultFormatForFourColumn];
    float amount = [_paxCreditDebitDetailDict[@"TotalDebitAmountValue"] floatValue];
    int count = [_paxCreditDebitDetailDict[@"TotalDebitCount"] intValue];

    if (count != 0) {
        debitAvgTicket = amount / count ;
    }
    else{
        debitAvgTicket = 0;
    }

    [_printJob printText1:@"Debit" text2:[NSString stringWithFormat:@"$%.2f",[_paxCreditDebitDetailDict[@"TotalDebitAmountValue"] floatValue]] text3:[NSString stringWithFormat:@"%d",[_paxCreditDebitDetailDict[@"TotalDebitCount"] intValue]] text4:[NSString stringWithFormat:@"$%.2f", debitAvgTicket]];

}

- (void)printTotalAmountCount {
    [_printJob enableBold:YES];
    [self defaultFormatForFourColumn];
    
    float toalAvgTicket = creditAvgTicket + debitAvgTicket;

   // [_printJob printText1:@"Total" text2:self.totalAmount text3:[NSString stringWithFormat:@"%ld",(long)self.totalCount]];
    [_printJob printText1:@"Total" text2:self.totalAmount text3:[NSString stringWithFormat:@"%ld",(long)self.totalCount] text4:[NSString stringWithFormat:@"$%.2f", toalAvgTicket]];
    [_printJob printLine:@""];
    [_printJob enableBold:NO];

}

//- (void)printTotalamount {
//    [_printJob setTextAlignment:TA_LEFT];
//    [_printJob printLine:[NSString stringWithFormat:@"Total Amount : %@",self.totalAmount]];
//}


- (void)printBridgePayDetail {
    [_printJob setTextAlignment:TA_LEFT];
    
    for (NSString *bridgePayDetail in bridgePayCCBatchData) {
        [_printJob printLine:[NSString stringWithFormat:@"%@",bridgePayDetail]];
    }
}

- (void)defaultFormatForReceptInfo
{
    columnWidths[0] = 18;
    columnWidths[1] = 29;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForItemDetail
{
    columnWidths[0] = 15;
    columnWidths[1] = 17;
    columnWidths[2] = 14;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentCenter;
    columnAlignments[2] = RPAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForFourColumn
{
    columnWidths[0] = 14;
    columnWidths[1] = 11;
    columnWidths[2] = 9;
    columnWidths[3] = 11;
    columnAlignments[0] = RCAlignmentLeft;
    columnAlignments[1] = RCAlignmentRight;
    columnAlignments[2] = RCAlignmentRight;
    columnAlignments[3] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

@end


