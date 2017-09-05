//
//  ForceBatchCloseRequest.m
//  PaxControllerApp
//
//  Created by siya info on 30/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ForceBatchCloseRequest.h"

@implementation ForceBatchCloseRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        _commandType = kPaxCommandForceBtachClose;
    }
    return self;
}

@end
