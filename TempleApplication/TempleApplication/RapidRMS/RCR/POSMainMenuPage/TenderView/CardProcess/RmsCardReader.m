//
//  RmsCardReader.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/3/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "RmsCardReader.h"
@interface RmsCardReader ()

@property (strong, nonatomic) id<RmsCardReaderDelegate> rmsCardReaderDelegate;

@end

@implementation RmsCardReader

- (instancetype)initWithDelegate:(id<RmsCardReaderDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.rmsCardReaderDelegate = delegate;
    }
    return self;
}
- (void)closeDevice
{
    
}

@end
