//
//  InitializeResponse.m
//  PaxControllerApp
//
//  Created by siya info on 17/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "InitializeResponse.h"
#import "PaxResponse+Internal.h"

#pragma mark - InitializeResponse
@interface InitializeResponse () {
    
}
@property (nonatomic, strong) NSString *serialNumber;

@end

@implementation InitializeResponse


+ (NSInteger)minSize {
    NSMutableData *minCommand = [NSMutableData data];
    
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
    BOOL hasEnoughData = NO;
    NSUInteger dataLength = data.length;
    NSUInteger minSize = [self minSize];
    NSUInteger maxSize = [self maxSize];
    
    if ((dataLength <= maxSize) && (dataLength >= minSize)) {
        hasEnoughData = YES;
    }
    return hasEnoughData;
}

+ (InitializeResponse*)responseFromData:(NSData*)data {
    InitializeResponse *response;
    
    if (![self hasEnoughData:data]) {
        return response;
    }
    
    return response;
}

- (instancetype)initWithData:(NSData*)data {
    self = [super initWithData:data];
    if (self) {
        // Parse the response
    }
    return self;
}


- (void)setupMessageFormat {
    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              @(FieldIndexSerialNumber),
                              ];
}

- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    switch (fieldId) {
        case FieldIndexSerialNumber:
            [self parseSerialNumber:fieldData];
            
            break;
        default:
            [super parseFieldData:fieldData forFieldId:fieldId];
            break;
    }
}

- (void)parseSerialNumber:(NSData *)data {
    //////////
    // Serial Number
    // Serial Number : M : ans32
    NSUInteger length = 32;
    _serialNumber = [PaxResponse anStringFrom:0 maxLength:length data:data];
}
@end

