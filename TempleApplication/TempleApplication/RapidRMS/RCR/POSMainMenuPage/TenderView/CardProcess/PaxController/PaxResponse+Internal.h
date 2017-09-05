//
//  PaxResponse+Internal.h
//  PaxControllerApp
//
//  Created by siya info on 17/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxResponse.h"

@interface PaxResponse (Internal)

// Data type validation
+ (BOOL)isChar:(char)aChar between:(char)start and:(char)end;
+ (BOOL)isA:(char)aChar;
+ (BOOL)isN:(char)aChar;
+ (BOOL)isS:(char)aChar;
+ (BOOL)isAN:(char)aChar;
+ (BOOL)isANS:(char)aChar;
+ (BOOL)isStx:(unsigned char)byte;
+ (BOOL)isEtx:(unsigned char)byte;
+ (BOOL)isUs:(unsigned char)byte;
+ (BOOL)isFs:(unsigned char)byte;

// Sub data
+ (NSData*)subDataFrom:(NSUInteger)startIndex length:(NSUInteger)length data:(NSData*)data;

// Parsing
+ (UInt8)byteFromStartIndex:(NSUInteger)startIndex data:(NSData *)data;
+ (NSString*)stringFrom:(NSUInteger)startIndex length:(NSUInteger)length data:(NSData*)data;
+ (NSString*)aStringFrom:(NSUInteger)startIndex maxLength:(NSUInteger)maxLength data:(NSData*)data;
+ (NSString*)nStringFrom:(NSUInteger)startIndex maxLength:(NSUInteger)maxLength data:(NSData*)data;
+ (NSString*)anStringFrom:(NSUInteger)startIndex maxLength:(NSUInteger)maxLength data:(NSData*)data;
+ (NSString*)ansStringFrom:(NSUInteger)startIndex maxLength:(NSUInteger)maxLength data:(NSData*)data;

// Parse Subfields/Field-Units
- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId;
- (NSArray*)fieldUnitsFromData:(NSData *)data;
+ (NSArray*)fieldUnitsFromData:(NSData *)data;

+ (BOOL)hasResponseCode:(NSData *)data;
+ (void)appendByte:(unsigned char)byte toData:(NSMutableData*)data;
+ (void)appendBytes:(char*)bytes length:(NSUInteger)length toData:(NSMutableData*)data;

@end
