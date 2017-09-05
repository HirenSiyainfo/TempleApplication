//
//  LocalTotalReportRequest.m
//  PaxControllerApp
//
//  Created by siya-IOS5 on 9/18/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "LocalTotalReportRequest.h"
#import "PaxRequest+Internal.h"

@implementation LocalTotalReportRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        _commandType = kPaxCommandLocalTotalReport;
    }
    return self;
}
- (NSMutableData *)commandSpecificBody {
    NSMutableData *commandSpecificData = [NSMutableData data];
    
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // EDC Type : O : n2 // Not sending this data
    [self appendToData:commandSpecificData string:@"00"];
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    
    //// Card Type
    // Card Type : C : n2
//    [self appendToData:commandSpecificData string:@"01"];    
    return commandSpecificData;
}
@end
