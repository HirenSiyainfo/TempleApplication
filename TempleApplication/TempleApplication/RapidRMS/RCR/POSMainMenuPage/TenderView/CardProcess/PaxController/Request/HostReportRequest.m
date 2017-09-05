//
//  HostReportRequest.m
//  PaxControllerApp
//
//  Created by siya-IOS5 on 8/13/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HostReportRequest.h"

@implementation HostReportRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        _commandType = kPaxCommandHostReport;
    }
    return self;
}

@end
