//
//  DoubleActionCheck.h
//  AnimatingApp
//
//  Created by siya info on 03/11/15.
//  Copyright © 2015 siya info. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoubleActionCheck : NSObject

@property (nonatomic, readonly) NSTimeInterval interval;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval;

@property (NS_NONATOMIC_IOSONLY, getter=isQuickTap, readonly) BOOL quickTap;
@end
