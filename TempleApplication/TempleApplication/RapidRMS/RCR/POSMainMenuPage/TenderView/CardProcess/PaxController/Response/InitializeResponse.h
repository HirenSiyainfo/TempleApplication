//
//  InitializeResponse.h
//  PaxControllerApp
//
//  Created by siya info on 17/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxResponse.h"

#pragma mark - InitializeResponse
@interface InitializeResponse : PaxResponse
@property (nonatomic, readonly) NSString *serialNumber;

+ (InitializeResponse*)responseFromData:(NSData*)data;

- (instancetype)initWithData:(NSData*)data NS_DESIGNATED_INITIALIZER;
@end

