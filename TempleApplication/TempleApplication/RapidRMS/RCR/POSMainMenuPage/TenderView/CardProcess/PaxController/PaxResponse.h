//
//  PaxResponse.h
//  PaxTestApp
//
//  Created by Siya Infotech on 05/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaxConstants.h"

#pragma mark - PaxResponse
@interface PaxResponse : NSObject {
    NSUInteger _currentIndex;
    NSString *_responseCode;
    NSArray *responseFields;
    NSArray *responseMessageFields;
}

@property (nonatomic, readonly, getter=isMultiplePacketResponse) BOOL multiplePacketResponse;
@property (nonatomic, readonly) NSString *commandType;
@property (nonatomic, readonly) NSString *protocolVersion;
@property (nonatomic, readonly) NSString *responseCode;
@property (nonatomic, readonly) NSString *responseMessage;


- (instancetype)initWithData:(NSData*)data NS_DESIGNATED_INITIALIZER;

#pragma mark - Get Response object from Data
+ (PaxResponse*)responseFromData:(NSData*)data;
+ (NSString*)commandTypeFromData:(NSData*)data;

@property (NS_NONATOMIC_IOSONLY, readonly) PaxRespCode responseCodeValue;


@end

