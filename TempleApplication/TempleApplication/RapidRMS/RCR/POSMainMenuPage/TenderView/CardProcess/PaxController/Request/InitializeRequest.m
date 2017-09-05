//
//  InitializeRequest.m
//  PaxControllerApp
//
//  Created by Siya Infotech on 15/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "InitializeRequest.h"
#import "PaxRequest+Internal.h"

#pragma mark - class InitializeRequest
////////////////////////// InitializeRequest //////////////////////////
@implementation InitializeRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        _commandType = kPaxCommandInitialize;
    }
    return self;
}

@end
////////////////////////// InitializeRequest //////////////////////////

