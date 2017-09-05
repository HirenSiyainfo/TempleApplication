//
//  ResponseHostInformation.m
//  PaxControllerApp
//
//  Created by siya info on 31/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ResponseHostInformation.h"
#import "PaxConstants.h"
#import "PaxResponse+Internal.h"

@implementation ResponseHostInformation
- (instancetype)initWithData:(NSData*)data {
    self = [super init];
    if (self) {
        [self parseHostInformation:data];
    }
    return self;
}

- (void)parseHostInformation:(NSData *)data {
    NSArray *fieldUnits = [PaxResponse fieldUnitsFromData:data];

    for (NSInteger currentIndex = FieldUnitIndexHostResponseCode; fieldUnits.count <= currentIndex; currentIndex++) {
        NSData *fieldUnitData = fieldUnits[currentIndex];
        NSString *value = [[NSString alloc] initWithData:fieldUnitData encoding:NSASCIIStringEncoding];

        switch ((FieldUnitIndex)currentIndex) {
            case FieldUnitIndexHostResponseCode:
                //////////
                // Response Code (we call it Transaction Response Code)
                // Response Code : M : ans...8
                _transactionResponseCode = value;
                break;

            case FieldUnitIndexHostResponseMessage:
                //////////
                // Response Message (we call it Transaction Response Message)
                // Response Message : C : ans...32
                _transactionResponseMessage = value;
                break;

            case FieldUnitIndexAuthCode:
                //////////
                // Authcode
                // Authcode : C : ans...10
                _authCode = value;
                break;

            case FieldUnitIndexHostReferenceNumber:
                //////////
                // Host Reference Number
                // Host Reference Number : C : ans...32
                _hostReferenceNumber = value;
                break;

            case FieldUnitIndexTraceNumber:
                //////////
                // Trace Number
                // Trace Number : C : ans...10
                _traceNumber = value;
                break;

            case FieldUnitIndexBatchNumber:
                //////////
                // Batch Number
                // Batch Number : C : ans...6
                _batchNumber = value;
                break;

            default:
                break;
        }
    }
}

- (void)hostInformation:(NSData *)data {
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
//    _currentIndex = _currentIndex + _transactionResponseCode.length;
    
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
//        _currentIndex++;
        length = 32;
        _transactionResponseMessage = [PaxResponse ansStringFrom:0 maxLength:length data:fieldUnitData];
//        _currentIndex = _currentIndex + _transactionResponseMessage.length + 1;
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
//    _currentIndex = _currentIndex + _authCode.length + 1;
    
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
//    _currentIndex = _;currentIndex + _hostReferenceNumber.length + 1;
    
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
//    _currentIndex = _currentIndex + _traceNumber.length + 1;
    
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
//    _currentIndex = _currentIndex + _batchNumber.length;
    
}

@end
