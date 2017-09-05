//
//  DoCreditResponse.m
//  PaxControllerApp
//
//  Created by siya info on 17/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DoCreditResponse.h"
#import "PaxResponse+Internal.h"

#pragma mark - DoCreditResponse
@interface DoCreditResponse () {
    
}
//@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *transactionResponseCode;
@property (nonatomic, strong) NSString *transactionResponseMessage;
@property (nonatomic, strong) NSString *authCode;
@property (nonatomic, strong) NSString *hostReferenceNumber;
@property (nonatomic, strong) NSString *traceNumber;
@property (nonatomic, strong) NSString *batchNumber;
@property (nonatomic, strong) NSString *transactionType;
@property (nonatomic, strong) NSString *approvedAmount;
@property (nonatomic, strong) NSString *amountDue;
@property (nonatomic, strong) NSString *tipAmount;
@property (nonatomic, strong) NSString *cashBackAmount;
@property (nonatomic, strong) NSString *merchantSurchargeFee;
@property (nonatomic, strong) NSString *taxAmount;
@property (nonatomic, strong) NSString *balance1;
@property (nonatomic, strong) NSString *balance2;
@property (nonatomic, strong) NSString *accountNumber;
@property (nonatomic, strong) NSString *entryMode;

@end

@implementation DoCreditResponse


+ (NSInteger)minSize {
    NSMutableData *minCommand = [NSMutableData data];
    
    // TODO: Need to correct this as per the spec
    // Data : Required : Length
    
    // STX : M : 1
    [self appendByte:PaxControlCharSTX toData:minCommand];
    // Status : M : a1
    [self appendByte:0 toData:minCommand];
    // FS : M : a1
    [self appendByte:PaxControlCharFS toData:minCommand];
    // Command : M : ans3
    [minCommand appendBytes:"A01" length:3];
    
    // FS : M : a1
    [self appendByte:PaxControlCharFS toData:minCommand];
    // Version : M : ans...4
    char *version = "";
    [self appendBytes:version length:strlen(version) toData:minCommand];
    
    // FS : M : a1
    [self appendByte:PaxControlCharFS toData:minCommand];
    // ResponseCode : M : ans6
    char *responseCode = "000000";
    [self appendBytes:responseCode length:strlen(responseCode) toData:minCommand];
    
    // FS : M : a1
    [self appendByte:PaxControlCharFS toData:minCommand];
    // ResponseMessage : O : ans...32
    char *responseMessage = "";
    [self appendBytes:responseMessage length:strlen(responseMessage) toData:minCommand];
    
    // FS : M : a1
    [self appendByte:PaxControlCharFS toData:minCommand];
    // SerialNumber : O : ans...32
    char *serialNumber = "";
    [self appendBytes:serialNumber length:strlen(serialNumber) toData:minCommand];
    // ETX : M : a1
    [self appendByte:PaxControlCharETX toData:minCommand];
    // LRC : M : a1
    [self appendByte:0 toData:minCommand];
    
    
    return minCommand.length;
}

+ (NSInteger)maxSize {
    // TODO: Need to correct this as per the spec
    NSMutableData *maxCommand = [NSMutableData data];
    
    // Data : Required : Length
    
    // STX : M : 1
    [self appendByte:PaxControlCharSTX toData:maxCommand];
    // Status : M : a1
    [self appendByte:0 toData:maxCommand];
    // FS : M : a1
    [self appendByte:PaxControlCharFS toData:maxCommand];
    // Command : M : ans3
    [maxCommand appendBytes:"A01" length:3];
    
    // FS : M : a1
    [self appendByte:PaxControlCharFS toData:maxCommand];
    // Version : M : ans...4
    char *version = "1.32";
    [self appendBytes:version length:strlen(version) toData:maxCommand];
    
    // FS : M : a1
    [self appendByte:PaxControlCharFS toData:maxCommand];
    // ResponseCode : M : ans6
    char *responseCode = "000000";
    [self appendBytes:responseCode length:strlen(responseCode) toData:maxCommand];
    
    // FS : M : a1
    [self appendByte:PaxControlCharFS toData:maxCommand];
    // ResponseMessage : O : ans...32
    char *responseMessage = "12345678901234567890123456789012";
    [self appendBytes:responseMessage length:strlen(responseMessage) toData:maxCommand];
    
    // FS : M : a1
    [self appendByte:PaxControlCharFS toData:maxCommand];
    // SerialNumber : O : ans...32
    char *serialNumber = "12345678901234567890123456789012";
    [self appendBytes:serialNumber length:strlen(serialNumber) toData:maxCommand];
    // ETX : M : a1
    [self appendByte:PaxControlCharETX toData:maxCommand];
    // LRC : M : a1
    [self appendByte:0 toData:maxCommand];
    
    return maxCommand.length;
}


+ (BOOL)hasEnoughData:(NSData *)data {
//    BOOL hasEnoughData = NO;
    NSUInteger dataLength = data.length;
    NSUInteger minSize = [self minSize];
    NSUInteger maxSize = [self maxSize];
    
    if ((dataLength <= maxSize) && (dataLength >= minSize)) {
//        hasEnoughData = YES;
    }
    
    // TODO: Need to correct this as per the spec
    //    return hasEnoughData;
    return YES;
}

+ (DoCreditResponse*)responseFromData:(NSData*)data {
    DoCreditResponse *response;
    
    if (![self hasEnoughData:data]) {
        return response;
    }
    
    return response;
}

- (void)setupMessageFormat {
    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              @(FieldIndexHostInformation),
                              @(FieldIndexTransactionType),
                              @(FieldIndexAmountInformation),
                              @(FieldIndexAccountInformation),
                              @(FieldIndexTraceInformation),
                              @(FieldIndexAvsInformation),
                              @(FieldIndexCommercialInformation),
                              @(FieldIndexMotoECommerceInformation),
                              @(FieldIndexAdditionalInformation),
                              ];
}

- (instancetype)initWithData:(NSData*)data {
    self = [super initWithData:data];
    if (self) {

    }
    return self;
}

- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    NSInteger length;
    switch (fieldId) {
        case FieldIndexHostInformation:
            //////////
            // Host information
            // Host information : M
            _hostInformation = [[ResponseHostInformation alloc] init];
            [_hostInformation hostInformation:fieldData];
            break;
            
        case FieldIndexTransactionType:
            //////////
            // Transaction Type
            // Transaction Type : C : n2
            length = 2;
            _transactionType = [PaxResponse ansStringFrom:0 maxLength:length data:fieldData];
            break;
            
        case FieldIndexAmountInformation:
            //////////
            // Amount Information
            // Amount Information : M
            [self amountInformation:fieldData];
            break;
            
        case FieldIndexAccountInformation:
            //////////
            // Account Information
            // Account Information : M
            [self accountInformation:fieldData];
            break;
            
        case FieldIndexTraceInformation:
            //////////
            // Trace Information
            // Trace Information : M
            [self traceInformation:fieldData];
            break;
            
        case FieldIndexAvsInformation:
            //////////
            // AVS Information
            // AVS Information : C
            // If host returns the AVS information, this field is mandatory.
            [self avsInformation:fieldData];
            break;
            
        case FieldIndexCommercialInformation:
            //////////
            // Commercial Information
            // Commercial Information : C
            // If terminal supports commercial card, and the card type is commercial card, this is mandatory.
            [self commercialInformation:fieldData];
            break;
            
        case FieldIndexMotoECommerceInformation:
            //////////
            // Motot/Commerce Information
            // Motot/Commerce Information : C
            [self motoECommerceInformation:fieldData];
            break;
            
        case FieldIndexAdditionalInformation:
            //////////
            // Additional Information
            // Additional Information : C
            [self additionalInformation:fieldData];
            break;
            
        default:
            [super parseFieldData:fieldData forFieldId:fieldId];
            break;
    }
}

//- (void)parseFieldDataAtIndex:(NSInteger)currentIndex {
//    NSData *fieldData = responseFields[currentIndex];
//    FieldIndex currentFieldId = [responseMessageFields[currentIndex] integerValue];
//    
//    [self parseFieldData:fieldData forFieldId:currentFieldId];
//}
//
//- (void)parseCommandSpecificData:(NSData *)data {
//    for (NSInteger currentIndex = 0; currentIndex < responseMessageFields.count; currentIndex++) {
//        if (currentIndex >= responseFields.count) {
//            break;
//        }
//        [self parseFieldDataAtIndex:currentIndex];
//        
//    }
//    
//    return;
//}
//



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

- (void)avsInformation:(NSData *)data {
    NSInteger length;
    NSArray *fieldUnits = [self fieldUnitsFromData:data];
    NSData *fieldUnitData;
    
    NSInteger currentIndex = 0;

    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // AVS approval Code
    // AVS approval Code : C : ans...8
    length = 8;
    _avsApprovalCode = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _avsApprovalCode.length + 1;
    
    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // AVS message
    // AVS message : C : ans...32
    length = 32;
    _avsMessage = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    _currentIndex = _currentIndex + _avsMessage.length;
    
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


-(NSString *)stringFromData:(NSData *)data
{
    return  [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

-(NSArray *)isFoundString:(NSString *)stringToCheck inAddtionalInformation:(NSMutableArray *)addtionalInformationDetail
{
    NSArray *isFoundDetail;
    for (NSString *stringInDetail in addtionalInformationDetail) {
        NSArray *fieldDetail = [stringInDetail componentsSeparatedByString:@"="];
        if ([fieldDetail containsObject:stringToCheck] && fieldDetail.count > 1) {
            isFoundDetail = fieldDetail;
            break;
        }
    }
    return isFoundDetail;
}

-(void)configureAdditionalInformation:(NSMutableArray *)addtionalInformation ForKey:(NSString *)key
{
   NSArray *isFoundDetail = [self isFoundString:key inAddtionalInformation:addtionalInformation];
    if (isFoundDetail.count == 0) {
        return;
    }
    (self.additionalInformation)[key] = isFoundDetail[1];
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

@end
