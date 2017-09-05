//
//  PaxRequest+Internal.h
//  PaxControllerApp
//
//  Created by Siya Infotech on 15/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxRequest.h"

@interface PaxRequest (Internal)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableData *commandSpecificBody;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableData *commandBody;
- (void)prepareCommandData;
- (void)appendByte:(UInt8)cc;
- (void)appendString:(NSString*)string;
- (void)appendToData:(NSMutableData*)data byte:(UInt8)cc;
- (void)appendToData:(NSMutableData*)data string:(NSString*)string;
- (NSString*)stringForAmount:(float)_amount;
- (void)appendAmount:(float)_amount toData:(NSMutableData *)data;
- (UInt8)checksumForData:(NSData*)data;

@end
