//
//  BatchCloseRequest.m
//  PaxControllerApp
//
//  Created by siya info on 30/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "BatchCloseRequest.h"
#import "PaxRequest+Internal.h"

@implementation BatchCloseRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        _commandType = kPaxCommandBatchClose;
    }
    return self;
}

- (NSMutableData *)commandSpecificBody {
    NSMutableData *commandSpecificData = [NSMutableData data];

    [self appendToData:commandSpecificData byte:PaxControlCharFS];

    // Time Stamp: O : n14 => The date time, YYYYMMDDhhmmss
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYYMMDDhhmmss";
    NSString *dateString = [dateFormatter stringFromDate:date];
    [self appendToData:commandSpecificData string:dateString];

    return commandSpecificData;
}

@end
