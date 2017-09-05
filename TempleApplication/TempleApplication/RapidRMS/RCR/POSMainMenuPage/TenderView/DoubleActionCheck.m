//
//  DoubleActionCheck.m
//  AnimatingApp
//
//  Created by siya info on 03/11/15.
//  Copyright © 2015 siya info. All rights reserved.
//

#import "DoubleActionCheck.h"

@interface DoubleActionCheck ()
@property (nonatomic, strong) NSDate *previousDate;
@property (nonatomic, strong) NSLock *buttonLock;
@property (nonatomic) NSTimeInterval interval;
@end

@implementation DoubleActionCheck

- (instancetype)init {
    self = [super init];
    if (self) {
        _interval = 1.0;
        _buttonLock = [[NSLock alloc] init];
        _previousDate = [NSDate dateWithTimeIntervalSinceNow:(-2 * _interval)];
    }
    return self;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval {
    self = [self init];
    if (self) {
        _interval = timeInterval;
        _previousDate = [NSDate dateWithTimeIntervalSinceNow:(-2 * _interval)];
    }
    return self;
}

- (BOOL)isQuickTap {
    BOOL isQuickTap = NO;
    [_buttonLock lock];

    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeLapsed = [currentDate timeIntervalSinceDate:_previousDate];

    if (timeLapsed < _interval) {
        isQuickTap = YES;
    } else {
        _previousDate = currentDate;
    }


    [_buttonLock unlock];

    return isQuickTap;
}

@end
