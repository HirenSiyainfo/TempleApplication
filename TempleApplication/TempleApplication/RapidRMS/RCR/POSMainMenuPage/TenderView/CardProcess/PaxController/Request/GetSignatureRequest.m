//
//  GetSignatureRequest.m
//  PaxControllerApp
//
//  Created by siya info on 28/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GetSignatureRequest.h"
#import "PaxRequest+Internal.h"

@interface GetSignatureRequest () {
    NSInteger _offset;
    NSInteger _requestLength;
}

@end

@implementation GetSignatureRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        _commandType = kPaxCommandGetSignature;
        _offset = 0;
    }
    return self;
}

- (instancetype)initWithOffset:(NSInteger)offset requestLength:(NSInteger)requestLength {
    self = [self init];
    if (self) {
        _offset = offset;
        _requestLength = requestLength;
    }
    return self;
}

- (NSMutableData *)commandSpecificBody {
    NSMutableData *commandSpecificData = [NSMutableData data];

    [self appendToData:commandSpecificData byte:PaxControlCharFS];

    // Offset : M : n...6
    [self appendToData:commandSpecificData string:@(_offset).stringValue];

    // Request Length : O : n...6
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // Do not send as it is optional
//    [self appendToData:commandSpecificData string:[@(_requestLength) stringValue]];

    return commandSpecificData;
}

@end
