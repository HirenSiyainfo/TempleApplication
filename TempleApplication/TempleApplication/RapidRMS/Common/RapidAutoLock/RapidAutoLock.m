//
//  RcdAutoLock.m
//  DataReceiveApp
//
//  Created by Siya Infotech on 23/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RapidAutoLock.h"

@interface RapidAutoLock()
@property (nonatomic, strong) id<NSLocking> rapidLock;
@end

@implementation RapidAutoLock

-(instancetype)initWithLock:(id<NSLocking>)lock;
{
    self = [super init];
    if (self) {
        _rapidLock = lock;
        [_rapidLock lock];
    }
    return self;
}

-(void)unlock
{
    if (_rapidLock) {
        [_rapidLock unlock];
        _rapidLock = nil;
    }
}

-(void)dealloc
{
    [self unlock];
}

@end
