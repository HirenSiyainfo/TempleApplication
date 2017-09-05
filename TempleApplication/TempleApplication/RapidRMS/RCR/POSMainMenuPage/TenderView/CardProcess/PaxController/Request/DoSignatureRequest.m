//
//  DoSignatureRequest.m
//  PaxControllerApp
//
//  Created by siya info on 28/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DoSignatureRequest.h"
#import "PaxRequest+Internal.h"


#define DEFAULT_SIGNATURE_TIMEOUT (600)
#define MIN_SIGNATURE_TIMEOUT (150)

@interface DoSignatureRequest () {
    BOOL _needUploadToHost;
    NSString *_transactionNumber;
    EdcType _edcType;
    NSInteger _signatureTimeout;
}

@end

@implementation DoSignatureRequest
- (instancetype)initWithEdcType:(EdcType)edcType {
    self = [super init];
    if (self) {
        _commandType = kPaxCommandDoSignature;
        _edcType = edcType;

        _needUploadToHost = NO;
        _signatureTimeout = DEFAULT_SIGNATURE_TIMEOUT;
    }
    return self;
}

- (instancetype)initWithEdcType:(EdcType)edcType transactionNumber:(NSString*)transactionNumber {
    self = [self initWithEdcType:edcType];
    if (self) {
        _transactionNumber = [transactionNumber copy];
        _needUploadToHost = YES;
    }
    return self;
}

- (NSMutableData *)commandSpecificBody {
    NSMutableData *commandSpecificData = [NSMutableData data];

    [self appendToData:commandSpecificData byte:PaxControlCharFS];

    // Upload Flag : M : n1
    [self appendToData:commandSpecificData byte:_needUploadToHost ? '1' : '0'];

    if (_needUploadToHost) {
        // Host reference number : O : ans...32
        [self appendToData:commandSpecificData byte:PaxControlCharFS];
        [self appendToData:commandSpecificData string:_transactionNumber];

        // EDC Type : O : n2 // Not sending this data
        [self appendToData:commandSpecificData byte:PaxControlCharFS];
        
        NSString *edcType = [NSString stringWithFormat:@"%02d", _edcType];
        [self appendToData:commandSpecificData string:edcType];

        // Timeout : M : n...3
        [self appendToData:commandSpecificData byte:PaxControlCharFS];
        _signatureTimeout = MIN(MIN_SIGNATURE_TIMEOUT, _signatureTimeout);
        [self appendToData:commandSpecificData string:@(_signatureTimeout).stringValue];

    } else {
        [self appendToData:commandSpecificData byte:PaxControlCharFS];
        [self appendToData:commandSpecificData byte:PaxControlCharFS];
        [self appendToData:commandSpecificData byte:PaxControlCharFS];
        _signatureTimeout = MIN(MIN_SIGNATURE_TIMEOUT, _signatureTimeout);
        [self appendToData:commandSpecificData string:@(_signatureTimeout).stringValue];
    }

    return commandSpecificData;
}

@end
