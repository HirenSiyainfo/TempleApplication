//
//  BatchCloseResponse.m
//  PaxControllerApp
//
//  Created by siya info on 30/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "BatchCloseResponse.h"
#import "PaxResponse+Internal.h"

@implementation BatchCloseResponse
- (void)setupMessageFormat {
    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              @(FieldIndexBCHostInformation),
                              @(FieldIndexTotalCount),
                              @(FieldIndexTotalAmount),
                              @(FieldIndexTimeStamp),
                              ];
}

- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    switch (fieldId) {
        case FieldIndexBCHostInformation:
#ifdef USE_HOSTINFORMATION_CLASS
            _hostInformation = [[ResponseHostInformation alloc]init];
            [_hostInformation hostInformation:fieldData];

#else
#endif

            break;
        case FieldIndexTotalCount:
            [self parseTotalCount:fieldData];
            break;
        case FieldIndexTotalAmount:
            [self parseTotalAmount:fieldData];
            break;
        case FieldIndexTimeStamp:
            [self parseTimeStamp:fieldData];
            break;
        default:
            [super parseFieldData:fieldData forFieldId:fieldId];
            break;
    }
}

#ifndef USE_HOSTINFORMATION_CLASS
- (void)parseHostInformation:(NSData *)data {
    NSInteger length;
    NSArray *fieldUnits = [PaxResponse fieldUnitsFromData:data];
    NSData *fieldUnitData;

    NSInteger currentIndex = FieldUnitIndexHostResponseCode;

    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Response Code (we call it Transaction Response Code)
    // Response Code : M : ans...8
    length = 8;
    _transactionResponseCode = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];

    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Response Message (we call it Transaction Response Message)
    // Response Message : C : ans...32
    //    if ([_transactionResponseCode integerValue] != 0)
    {
        _currentIndex++;
        length = 32;
        _transactionResponseMessage = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
    }

    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Authcode
    // Authcode : C : ans...10
    length = 32;
    _authCode = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];

    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Host Reference Number
    // Host Reference Number : C : ans...32
    length = 32;
    _hostReferenceNumber = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];

    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Trace Number
    // Trace Number : C : ans...10
    length = 32;
    _traceNumber = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];

    currentIndex++;
    if (fieldUnits.count <= currentIndex) {
        return;
    }
    fieldUnitData = fieldUnits[currentIndex];
    //////////
    // Batch Number
    // Batch Number : C : ans...6
    length = 32;
    _batchNumber = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];

}
#endif

-(NSNumber *)valueAtIndex:(NSInteger )currentIndex forbatchDetail:(NSArray *)batchDetail
{
    NSNumber *batchValue = 0;
    if (batchDetail.count < currentIndex) {
        return batchValue;
    }
    batchValue = batchDetail[currentIndex];
    return batchValue;
}

- (void)parseTotalCount:(NSData *)data {
    
    // Order of data in total count...
    ///TotalCount:<creditCount>=<debitCount>=<ebtCount>=<giftCount>=<loyaltyCount>=<cashCount>= <CHECKCount>

    
    NSString *value = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *totalCountArray = [value componentsSeparatedByString:@"="];
    if (totalCountArray.count == 0) {
        return;
    }
    NSInteger currentIndexCount = 0;
    _totalCreditCount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].integerValue;
    
    currentIndexCount++;
    _totalDebitCount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].integerValue;

    currentIndexCount++;
    _totalEBTCount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].integerValue;

    currentIndexCount++;
    _totalGiftCount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].integerValue;

    currentIndexCount++;
    _totalLoyaltyCount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].integerValue;

    currentIndexCount++;
    _totalCashCount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].integerValue;

    currentIndexCount++;
    _totalCheckCount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].integerValue;
    
    [self setTotalCountDictionary:data];
    //_totalCount = [value integerValue];
}

-(void)setTotalCountDictionary:(NSData *)data
{
    NSString *totalCount = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *totalCountArray = [totalCount componentsSeparatedByString:@"="];
    NSArray *addtionalFieldArray = @[@"creditCount",
                                    @"debitCount",
                                    @"ebtCount",
                                    @"gfitCount",
                                    @"loyaltyCount",
                                    @"cashCount",
                                    @"CHECKCount"];
    
    self.totalCountDetail = [[NSMutableDictionary alloc] init];
    for (int i =0 ; i < totalCountArray.count; i++) {
        (self.totalCountDetail)[addtionalFieldArray[i]] = totalCountArray[i];
    }
}


-(void)parseTotalAmountDictionary:(NSData *)data
{
    NSString *totalAmount = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *totalAmountArray = [totalAmount componentsSeparatedByString:@"="];
    NSArray *addtionalFieldArray = @[@"creditAmount",
                                    @"debitAmount",
                                    @"ebtAmount",
                                    @"giftAmount",
                                    @"loyaltyAmount",
                                    @"cashAmount",
                                    @"CHECKAmount"];
    
    self.totalAmountDetail = [[NSMutableDictionary alloc] init];
    for (int i =0 ; i < totalAmountArray.count; i++) {
        (self.totalAmountDetail)[addtionalFieldArray[i]] = totalAmountArray[i];
    }
}



- (void)parseTotalAmount:(NSData *)data {
    
    
    // Order of data in total amount...
  //  TotalAmount:<creditAmount>=<debitAmount>=<ebtAmount>=<giftAmount>=<loyaltyAmount>=<c ashAmount>=<CHECKAmount>
    NSString *value = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    
    NSArray *totalCountArray = [value componentsSeparatedByString:@"="];
    if (totalCountArray.count == 0) {
        return;
    }
    NSInteger currentIndexCount = 0;
    _totalCreditAmount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].floatValue / 100;
    
    currentIndexCount++;
    _totalDebitAmount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].floatValue / 100;
    
    currentIndexCount++;
    _totalEBTAmount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].floatValue / 100;
    
    currentIndexCount++;
    _totalGiftAmount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].floatValue / 100;
    
    currentIndexCount++;
    _totalLoyaltyAmount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].floatValue / 100;
    
    currentIndexCount++;
    _totalCashAmount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].floatValue / 100;
    
    currentIndexCount++;
    _totalCheckAmount = [self valueAtIndex:currentIndexCount forbatchDetail:totalCountArray].floatValue / 100;
    
    [self parseTotalAmountDictionary:data];

//    _totalAmount = [value floatValue];
}

- (void)parseTimeStamp:(NSData *)data {
    NSString *value = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

    // Time Stamp : C : n14 => The date time, YYYYMMDDhhmmss

//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSString *inputDateFormat = @"";
//    NSString *outputDateFormat = @"";
//
//    [dateFormatter setDateFormat:inputDateFormat];
//    NSDate *date = [dateFormatter dateFromString:value];
//
//    [dateFormatter setDateFormat:outputDateFormat];
//    _timeStamp = [dateFormatter stringFromDate:date];

    _timeStamp = value;
}

@end
