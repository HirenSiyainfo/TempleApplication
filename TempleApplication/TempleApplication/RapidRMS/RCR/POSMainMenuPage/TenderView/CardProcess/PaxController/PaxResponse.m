//
//  PaxResponse.m
//  PaxTestApp
//
//  Created by Siya Infotech on 05/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxResponse.h"
#import "PaxResponse+Internal.h"
#import "PaxConstants.h"

// Responses
#import "InitializeResponse.h"
#import "SetVariableResponse.h"
#import "GetVariableResponse.h"
#import "DoSignatureResponse.h"
#import "GetSignatureResponse.h"

#import "DoCreditResponse.h"
#import "DoDebitResponse.h"
#import "DoEbtResponse.h"

#import "BatchCloseResponse.h"
#import "ForceBatchCloseResponse.h"
#import "BatchClearResponse.h"
#import "HostReportResponse.h"
#import "HistoryReportResponse.h"
#import "LocalTotalReportResponse.h"
#import "LocalDetailReportResponse.h"
#define ElementPositionStatus 1
#define ElementPositionCommandType 3
#define ElementPositionVersion 7

#define ElementLengthStatus 1
#define ElementLengthCommandType 3
#define ElementLengthVersion 4
#define ElementLengthResponseCode 6
#define ElementLengthResponseMessage 32


@interface PaxResponse ()

@property (nonatomic) BOOL multiplePacketResponse;
@property (nonatomic, strong) NSString *commandType;
@property (nonatomic, strong) NSString *protocolVersion;
@property (nonatomic, strong) NSString *responseCode;
@property (nonatomic, strong) NSString *responseMessage;
@property (nonatomic) NSUInteger currentIndex;


@end

#pragma mark - PaxResponse
@implementation PaxResponse
- (instancetype)initWithData:(NSData*)data {
    self = [super init];
    if (self) {
        // Parse the response
        _currentIndex = 0;
        
        [self setupMessageFormat];

        // Parse Data
        [self parseFieldsFromData:data];

        // Checksum
        if (![self checksumMatches:data]) {
            // TODO: At present we are assigning nil to self.
            // We may have to rather set some error code
            self = nil;
        } else {
            // Checksum matches. Now check validity of the packet
            // We must do this while parsing.
            // parseFieldsFromData must return TRUE/FALSE to specify validity of the message.
//            [self checkPacketValidity];
        }
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
                              ];
}

- (BOOL)checksumMatches:(NSData *)data {
    BOOL checksumMatches = YES;
    // TODO:
    // Calculate Checksum and verify
    return checksumMatches;
}


/**
 Fields are the components of a Request/Response separetd by PaxControlCharFS.
 All the fields are enclosed between PaxControlCharSTX and PaxControlCharETX.
 This method checks the separators PaxControlCharFS, PaxControlCharSTX and PaxControlCharETX
 and gets a list of all fields present in the response message.
 */
- (NSArray*)fieldsFromData:(NSData *)data {
    NSMutableArray *fields = nil;
    unsigned char *dataBytes = (unsigned char*)data.bytes;
    NSInteger count = data.length;
    
    // There is no data
    if (count == 0) {
        return fields;
    }

    // Check STX
    unsigned char byte = (unsigned char)dataBytes[0];
    if (![PaxResponse isStx:byte]) {
        // The start of the transaction message response not found
        return fields;
    }
    
    fields = [NSMutableArray array];
    
    NSInteger previousIndex = 1;
    
    
    for (NSInteger currentIndex = 1; currentIndex < count; currentIndex++) {
        byte = (unsigned char)dataBytes[currentIndex];
        if ([PaxResponse isFs:byte] || [PaxResponse isEtx:byte]) {
            // Separator found
            NSRange fieldRange;
            fieldRange.location = previousIndex;
            fieldRange.length = currentIndex - previousIndex;
            previousIndex = currentIndex + 1;
            
            NSData *fieldData = [data subdataWithRange:fieldRange];
            [fields addObject:fieldData];
        }
    }
    
    return fields;
}

//- (void)parseCommandSpecificData:(NSData *)data {
//    NSLog(@"Each derived class must implement this");
//}

- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    switch (fieldId) {
        case FieldIndexMultiPacket:
            [self parseMultiPacket:fieldData];
            break;

        case FieldIndexCommandType:
            [self parseCommandType:fieldData];
            break;
            
        case FieldIndexVersion:
            [self parseProtocolVersion:fieldData];
            break;
            
        case FieldIndexResponseCode:
            [self parseResponseCode:fieldData];
            break;
            
        case FieldIndexResponseMessage:
            [self parseResponseMessage:fieldData];
            break;
            
        default:
            break;
            
    }
}

- (void)parseFieldDataAtIndex:(NSInteger)currentIndex {
    NSData *fieldData = responseFields[currentIndex];
    FieldIndex currentFieldId = [responseMessageFields[currentIndex] integerValue];
    
    [self parseFieldData:fieldData forFieldId:currentFieldId];
}

- (void)parseFieldsFromData:(NSData *)data {
    // Parse data with separator PaxControlCharFS to get data for each field
    responseFields = [self fieldsFromData:data];
    for (NSInteger currentIndex = 0; currentIndex < responseMessageFields.count; currentIndex++) {
        if (currentIndex >= responseFields.count) {
            break;
        }
        [self parseFieldDataAtIndex:currentIndex];
        
    }
    
    return;
}

- (void)parseMultiPacket:(NSData *)fieldData {
    //////////
    // Multiple Packet
    // Status : M : a1
    //    _currentIndex = ElementPositionStatus;
    unsigned char byte = [PaxResponse byteFromStartIndex:0 data:fieldData];
    BOOL boolValue = (byte == '0' ? NO : YES);
    _multiplePacketResponse = boolValue;
}

- (void)parseCommandType:(NSData *)fieldData {
    //////////
    // CommandType
    // Command : M : ans3
    _commandType = [PaxResponse anStringFrom:0 maxLength:ElementLengthCommandType data:fieldData];
}

- (void)parseProtocolVersion:(NSData *)fieldData {
    //////////
    // Version
    // Version : M : ans...4
    _protocolVersion = [PaxResponse ansStringFrom:0 maxLength:ElementLengthVersion data:fieldData];
}

- (void)parseResponseCode:(NSData *)fieldData {
    //////////
    // ResponseCode
    // ResponseCode : M : ans6
    _responseCode = [PaxResponse anStringFrom:0 maxLength:ElementLengthResponseCode data:fieldData];
}

- (void)parseResponseMessage:(NSData *)fieldData {
    //////////
    // ResponseMessage
    // ResponseMessage : O : ans...32
    _responseMessage = [PaxResponse ansStringFrom:0 maxLength:ElementLengthResponseMessage data:fieldData];
}

+ (PaxResponse*)responseFromData:(NSData*)data {
    PaxResponse *response;
    
    BOOL hasResponseCode;
    hasResponseCode = [self hasResponseCode:data];
    
    if (!hasResponseCode) {
        return response;
    }
    
    // Basic Response
    response = [[PaxResponse alloc] initWithData:data];
    
    // Command Type
    NSString *commandType = response.commandType;
    
    // Specific Response
    if ([commandType isEqualToString:@"A01"]) {
        response = [[InitializeResponse alloc] initWithData:data];
    } else if ([commandType isEqualToString:@"T01"]) {
        response = [[DoCreditResponse alloc] initWithData:data];
    } else if ([commandType isEqualToString:@"T03"]) {
        response = [[DoDebitResponse alloc] initWithData:data];
    } else if ([commandType isEqualToString:@"T05"]) {
        response = [[DoEbtResponse alloc] initWithData:data];
    } else if ([commandType isEqualToString:@"A03"]) {
        response = [[GetVariableResponse alloc] initWithData:data];
    } else if ([commandType isEqualToString:@"A09"]) {
        response = [[GetSignatureResponse alloc] initWithData:data];
    } else if ([commandType isEqualToString:@"A21"]) {
        response = [[DoSignatureResponse alloc] initWithData:data];
    } else if ([commandType isEqualToString:@"B01"]) {
        response = [[BatchCloseResponse alloc] initWithData:data];
    } else if ([commandType isEqualToString:@"B03"]) {
        response = [[ForceBatchCloseResponse alloc] initWithData:data];
    } else if ([commandType isEqualToString:@"B05"]) {
        response = [[BatchClearResponse alloc] initWithData:data];
    }
    else if ([commandType isEqualToString:@"R07"])
    {
        response = [[HostReportResponse alloc] initWithData:data];
    }
    else if ([commandType isEqualToString:@"R09"])
    {
        response = [[HistoryReportResponse alloc] initWithData:data];
    }
    else if ([commandType isEqualToString:@"R01"])
    {
        response = [[LocalTotalReportResponse alloc] initWithData:data];
    }
    else if ([commandType isEqualToString:@"R03"])
    {
        response = [[LocalDetailReportResponse alloc] initWithData:data];
    }
    else if ([commandType isEqualToString:@"A05"])
    {
        response = [[SetVariableResponse alloc] initWithData:data];
    }

    
    return response;
}

+ (NSString*)commandTypeFromData:(NSData*)data {
    return nil;
}

- (PaxRespCode)responseCodeValue {
    return (PaxRespCode)_responseCode.integerValue;
}

@end

