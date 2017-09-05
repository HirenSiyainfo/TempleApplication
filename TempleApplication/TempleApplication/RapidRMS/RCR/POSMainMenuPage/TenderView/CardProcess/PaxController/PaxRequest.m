//
//  PaxRequest.m
//  PaxTestApp
//
//  Created by Siya Infotech on 05/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxRequest+Internal.h"

#define kVersion @"1.32"
//#define kVersion @"1.28"

#pragma mark - class PaxRequest
////////////////////////// PaxRequest //////////////////////////
@interface PaxRequest () {
}

@end

@implementation PaxRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        _commandData = [NSMutableData data];
        _version = kVersion;
    }
    return self;
}

#pragma mark - Public Methods
/**
    Base64 string for the command
 */
- (NSString*)base64String {
    NSString *base64String;
    [self prepareCommandData];
    self.requestCommandData = _commandData;
    base64String = [_commandData base64EncodedStringWithOptions:0];
    return base64String;
}

@end
////////////////////////// PaxRequest //////////////////////////
