//
//  LocalDetailReportResponse.m
//  PaxControllerApp
//
//  Created by siya-IOS5 on 1/11/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "LocalDetailReportResponse.h"
#import "PaxResponse+Internal.h"

@implementation LocalDetailReportResponse


- (void)setupMessageFormat {
    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              @(FieldIndexLocalDetailReportTotalRecord),
                              @(FieldIndexLocalDetailRecordNumber),
                              @(FieldIndexHostInformation),
                              @(FieldIndexLocalTotalReportEDCType),
                              @(FieldIndexLocalDetailTransactionType),
                              @(FieldIndexLocalDetailOriginalTransactionType),
                              @(FieldIndexAmountInformation),
                              @(FieldIndexAccountInformation),
                              @(FieldIndexTraceInformation),
                              @(FieldIndexLocalDetailCashierInformation),
                              @(FieldIndexCommercialInformation),
                              @(FieldIndexLocalDetailCheckInformation),
                              @(FieldIndexAdditionalInformation),
                              ];
}

-(void)parseEDCType:(NSData *)data
{
    ///// n2
    NSInteger length = 2;
    self.edcType = [PaxResponse ansStringFrom:0 maxLength:length data:data];
}

-(void)parseTransactionType:(NSData *)data
{
    //// n2
    NSInteger length = 2;
    self.transactionType = [PaxResponse ansStringFrom:0 maxLength:length data:data];
}

-(void)parseOrignalTransactionType:(NSData *)data
{
    ///// n2
    NSInteger length = 2;
    self.orignalTransactionType = [PaxResponse ansStringFrom:0 maxLength:length data:data];
}
-(void)parseTotalRecord:(NSData *)data
{
    //// n...4.....
    NSInteger length = 4;
    _totalrecord = [NSString stringWithFormat:@"%@",[PaxResponse ansStringFrom:0 maxLength:length data:data]];
}

-(void)parseRecordNumber:(NSData *)data
{
    //// n...4.....
    NSInteger length = 4;
    _recordNumber = [NSString stringWithFormat:@"%@",[PaxResponse ansStringFrom:0 maxLength:length data:data]];
    
}


- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    switch (fieldId) {
        case FieldIndexLocalDetailReportTotalRecord:
            [self parseTotalRecord:fieldData];
            // Response Code : M : ans...8

            break;
        case FieldIndexLocalDetailRecordNumber:
            [self parseRecordNumber:fieldData];

            break;
        case FieldIndexHostInformation:
            _hostInformation = [[ResponseHostInformation alloc] init];
            [_hostInformation hostInformation:fieldData];
            break;
        case FieldIndexLocalTotalReportEDCType:
            [self parseEDCType:fieldData];
            break;
        case FieldIndexLocalDetailTransactionType:
            [self parseTransactionType:fieldData];
            break;
        case FieldIndexLocalDetailOriginalTransactionType:
            [self parseOrignalTransactionType:fieldData];
            break;
        case FieldIndexAmountInformation:
            [self amountInformation:fieldData];
            break;
        case FieldIndexAccountInformation:
            [self accountInformation:fieldData];

            break;
        case FieldIndexTraceInformation:
            [self traceInformation:fieldData];
            break;
        case FieldIndexLocalDetailCashierInformation:
            break;
        case FieldIndexCommercialInformation:
            [self commercialInformation:fieldData];

            break;
        case FieldIndexLocalDetailCheckInformation:
            break;
        case FieldIndexAdditionalInformation:
            [self additionalInformation:fieldData];
            break;

        default:
            [super parseFieldData:fieldData forFieldId:fieldId];
            break;
    }
}


- (void)amountInformation:(NSData *)data {
    // NOTE:
    // All amounts in $$$$$$CC format.
    // That is amount is returned in cents.
    NSInteger length;
    
    NSArray *fieldUnits = [self fieldUnitsFromData:data];
    NSData *fieldUnitData;
    
    NSInteger currentIndex = 0;
    
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Approved Amount
    // Approved Amount : C : n...8
    length = 8;
    _approvedAmount = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _approvedAmount.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Amount Due
    // Amount Due : C : n...8
    length = 8;
    _amountDue = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _amountDue.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Tip Amount
    // Tip Amount : C : n...8
    length = 8;
    _tipAmount = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _tipAmount.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Cash Back Amount
    // Cash Back Amount : C : n...8
    length = 8;
    _cashBackAmount = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _cashBackAmount.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Merchant Fee/ Surcharge Fee
    // Merchant Fee/ Surcharge Fee : C : n...8
    length = 8;
    _merchantSurchargeFee = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _merchantSurchargeFee.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Tax Amount
    // Tax Amount : C : n...8
    length = 8;
    _taxAmount = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _taxAmount.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Balance1
    // Balance1 : C : n...8
    length = 8;
    _balance1 = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _balance1.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Balance2
    // Balance2 : C : n...8
    length = 8;
    _balance2 = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _balance2.length;
    
}

- (void)accountInformation:(NSData *)data {
    NSInteger length;
    NSArray *fieldUnits = [self fieldUnitsFromData:data];
    NSData *fieldUnitData;
    
    NSInteger currentIndex = 0;
    
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Account Number
    // Account Number : M : n...19
    length = 19;
    _accountNumber = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _accountNumber.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Entry Mode
    // Entry Mode : M : n...1
    length = 1;
    _entryMode = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _entryMode.length;
    
    /*
     expireDate
     ebtType
     voucherNumber
     newAccountNo
     cardType
     cardHolder
     cvdApprovalCode
     cvdMessage
     cardPresentIndicator
     */
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Expiry Date
    // Expiry Date : C : n4 (FormatMM/YY)
    length = 4;
    _expiryDate = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // EBT type
    // EBT type : C : a1
    length = 1;
    _ebtType = [PaxResponse aStringFrom:0 maxLength:length data:fieldUnitData];
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Voucher number
    // Voucher number : C : ans..16
    length = 16;
    _voucherNumber = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // New Account No
    // New Account No : C : n..19
    length = 16;
    _neuAccountNo = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Card Type
    // Card Type : C : n2
    length = 2;
    _cardType = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Card Holder
    // Card Holder : C : ans...32
    length = 32;
    _cardHolder = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // CVD approval code
    // CVD approval code : C : ans...8
    length = 8;
    _cvdApprovalCode = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // CVD Message
    // CVD Message : C : ans...32
    length = 32;
    _cvdMessage = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Card Present Indicator
    // Card Present Indicator : C : N1
    length = 1;
    _cardPresentIndicator = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    
}

- (void)traceInformation:(NSData *)data {
    NSInteger length;
    NSArray *fieldUnits = [self fieldUnitsFromData:data];
    NSData *fieldUnitData;
    
    NSInteger currentIndex = 0;
    
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Transaction Number
    // Transaction Number : C : n...4
    length = 4;
    _transactionNumber = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _transactionNumber.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Reference Number
    // Reference Number : M : ans...16
    length = 16;
    _referenceNumber = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _referenceNumber.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Time Stamp
    // Time Stamp : M : n...14
    length = 14;
    _timeStamp = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _timeStamp.length;
    
}

- (void)commercialInformation:(NSData *)data {
    NSInteger length;
    NSArray *fieldUnits = [self fieldUnitsFromData:data];
    NSData *fieldUnitData;
    
    NSInteger currentIndex = 0;
    
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // PO Number
    // PO Number : C : ans...32
    length = 32;
    _poNumber = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _poNumber.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Customer Code
    // Customer Code : C : ans...32
    length = 32;
    _customerCode = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _customerCode.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Tax Exempt
    // Tax Exempt : C : n...1
    length = 1;
    _taxExempt = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _taxExempt.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Tax Exempt Id
    // Tax Exempt Id : C : ans...12
    length = 12;
    _taxExemptId = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _taxExemptId.length;
    
}

- (void)motoECommerceInformation:(NSData *)data {
    NSInteger length;
    NSArray *fieldUnits = [self fieldUnitsFromData:data];
    NSData *fieldUnitData;
    
    NSInteger currentIndex = 0;
    
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // MOTO/e-Commerc e mode
    // MOTO/e-Commerc e mode : O : a...1
    length = 1;
    _motoECommerceMode = [PaxResponse aStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _motoECommerceMode.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // transaction type
    // transaction type : O : a...1
    length = 1;
    _eCommerceTransactionType = [PaxResponse aStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _eCommerceTransactionType.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // secure type
    // secure type : O : a...1
    length = 1;
    _eCommerceSecureType = [PaxResponse aStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _eCommerceSecureType.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // order number
    // order number : O : ans...16
    length = 16;
    _eCommerceOrderNumber = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _eCommerceOrderNumber.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // installments
    // installments : O : n...3
    length = 3;
    _eCommerceInstallments = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _eCommerceInstallments.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // current installment
    // current installment : O : n...3
    length = 3;
    _eCommerceCurrentInstallment = [PaxResponse nStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _eCommerceCurrentInstallment.length;
    
}


- (void)additionalInformation:(NSData *)data {
    
    
    NSArray *fieldUnits = [self fieldUnitsFromData:data];
    self.additionalInformation = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *fieldUnitStringData = [[NSMutableArray alloc] init];
    for (NSData *fieldData in fieldUnits) {
        [fieldUnitStringData addObject:[self stringFromData:fieldData]];
    }
    for (NSString *fieldDataString in fieldUnitStringData) {
        NSArray *fieldDataArray = [fieldDataString componentsSeparatedByString:@"="];
        if (fieldDataArray.count == 2) {
            (self.additionalInformation)[fieldDataArray[0]] = fieldDataArray[1];
        }
    }
    
    /*  return;
     
     NSArray *addtionalFieldArray = [NSArray arrayWithObjects:@"TABLE",
     @"GUEST",
     @"TICKET",
     @"DISAMT",
     @"CHGAMT",
     @"SIGNSTATUS",
     @"FPS",
     @"FPSSIGN",
     @"FPSRECEIPT",
     @"ORIGTIP",
     @"EDCTYPE",
     @"TC",
     @"TVR",
     @"AID",
     @"TSI",
     @"ATC",
     @"APPLAB", nil];
     
     
     for (NSString *addtionalFieldString in addtionalFieldArray) {
     [self configureAdditionalInformation:fieldUnitStringData ForKey:addtionalFieldString];
     }*/
    
    // TODO:
    // Ignoring this block for now.
    //    TABLE
    //    GUEST
    //    TICKET
    //    DISAMT
    //    CHGAMT
    //    SIGNSTATUS
    //    FPS
    //    FPSSIGN
    //    FPSRECEIPT
    //    ORIGTIP
    //    EDCTYPE
    //    // Fields below applicable for Chip trans only.
    //    TC
    //    TVR
    //    AID
    //    TSI
    //    ATC
    //    APPLAB
}

-(NSString *)stringFromData:(NSData *)data
{
    return  [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}




@end
