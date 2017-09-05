//
//  BatchClearRequest.m
//  PaxControllerApp
//
//  Created by siya info on 30/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "BatchClearRequest.h"
#import "PaxRequest+Internal.h"

@interface BatchClearRequest () {
    EdcType _edcType;
}

@end

@implementation BatchClearRequest
- (instancetype)initWithEdcType:(EdcType)edcType {
    self = [super init];
    if (self) {
        _commandType = kPaxCommandBatchClear;
        _edcType = edcType;
    }
    return self;
}

- (NSMutableData *)commandSpecificBody {
    NSMutableData *commandSpecificData = [NSMutableData data];

    [self appendToData:commandSpecificData byte:PaxControlCharFS];

    // EDC Type : O : n2
    NSString *edcString = [NSString stringWithFormat:@"%02d", _edcType];
    [self appendToData:commandSpecificData string:edcString];

    return commandSpecificData;
}
@end
