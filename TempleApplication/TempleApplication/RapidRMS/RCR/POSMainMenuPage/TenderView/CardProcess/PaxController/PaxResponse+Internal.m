//
//  PaxResponse+Internal.m
//  PaxControllerApp
//
//  Created by siya info on 17/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxResponse+Internal.h"

@implementation PaxResponse (Internal)
#pragma mark - Data type check
+ (BOOL)isChar:(char)aChar between:(char)start and:(char)end {
    BOOL isBetween = NO;
    if ((aChar >= start) && (aChar <= end)) {
        isBetween = YES;
    }
    return isBetween;
}

+ (BOOL)isA:(char)aChar {
    BOOL isA;
    
    isA  = [self isChar:aChar between:'A' and:'Z'];
    isA |= [self isChar:aChar between:'a' and:'z'];
    
    return isA;
}

+ (BOOL)isN:(char)aChar {
    BOOL isN;
    
    isN  = [self isChar:aChar between:'0' and:'9'];
    
    return isN;
}

+ (BOOL)isS:(char)aChar {
    //    BOOL isS = YES;
    
    NSString *searchString = [NSString stringWithFormat:@"%c", aChar];
    static NSString *specialChars = @".,!?+-_:;<>\\/\"\'#%% \t\n^~";
    
    NSRange range = [specialChars rangeOfString:searchString];
    
    return (range.location != NSNotFound);
}

+ (BOOL)isAN:(char)aChar {
    BOOL isAN;
    
    isAN  = [self isA:aChar];
    isAN  |= [self isN:aChar];
    
    return isAN;
}

+ (BOOL)isANS:(char)aChar {
    BOOL isANS;
    
    isANS  = [self isA:aChar];
    isANS  |= [self isN:aChar];
    isANS  |= [self isS:aChar];
    
    return isANS;
}

#pragma mark - Chuck of Data
+ (NSData*)subDataFrom:(NSUInteger)startIndex length:(NSUInteger)length data:(NSData*)data {
    if (startIndex + length > data.length) {
        return nil;
    }
    
    NSRange range;
    range.location = startIndex;
    range.length = length;
    NSData *segment = [data subdataWithRange:range];
    return segment;
}

+ (UInt8)byteFromStartIndex:(NSUInteger)startIndex data:(NSData *)data {
    UInt8 byte;
    NSData *segment = [self subDataFrom:startIndex length:1 data:data];
    
    [segment getBytes:&byte length:1];
    return byte;
}

+ (NSString*)stringFrom:(NSUInteger)startIndex length:(NSUInteger)length data:(NSData*)data {
    NSData *segment = [self subDataFrom:startIndex length:length data:data];
    NSString *string = [[NSString alloc] initWithData:segment encoding:NSASCIIStringEncoding];
    return string;
}

#pragma mark - Parse Fields
+ (NSString*)aStringFrom:(NSUInteger)startIndex maxLength:(NSUInteger)maxLength data:(NSData*)data {
    NSMutableString *string = [NSMutableString string];
    NSUInteger count = data.length;
    
    maxLength = MIN(maxLength, count - startIndex);
    
    if (maxLength <= 0) {
        return string;
    }
    
    for (NSUInteger index = startIndex; index < count; index++) {
        char byte = [self byteFromStartIndex:index data:data];
        
        if (![self isA:byte]) {
            break;
        }
        NSString *charString = [[NSString alloc] initWithBytes:&byte length:1 encoding:NSASCIIStringEncoding];
        [string appendString:charString];
    }
    return string;
}

+ (NSString*)nStringFrom:(NSUInteger)startIndex maxLength:(NSUInteger)maxLength data:(NSData*)data {
    NSMutableString *string = [NSMutableString string];
    NSUInteger count = data.length;
    
    maxLength = MIN(maxLength, count - startIndex);
    
    if (maxLength <= 0) {
        return string;
    }
    
    for (NSUInteger index = startIndex; index < count; index++) {
        char byte = [self byteFromStartIndex:index data:data];
        
        if (![self isN:byte]) {
            break;
        }
        NSString *charString = [[NSString alloc] initWithBytes:&byte length:1 encoding:NSASCIIStringEncoding];
        [string appendString:charString];
    }
    return string;
}

+ (NSString*)anStringFrom:(NSUInteger)startIndex maxLength:(NSUInteger)maxLength data:(NSData*)data {
    NSMutableString *string = [NSMutableString string];
    NSUInteger count = data.length;
    
    maxLength = MIN(maxLength, count - startIndex);
    
    if (maxLength <= 0) {
        return string;
    }
    
    for (NSUInteger index = startIndex; index < count; index++) {
        char byte = [self byteFromStartIndex:index data:data];
        
        if (![self isAN:byte]) {
            break;
        }
        NSString *charString = [[NSString alloc] initWithBytes:&byte length:1 encoding:NSASCIIStringEncoding];
        [string appendString:charString];
    }
    return string;
}

+ (NSString*)ansStringFrom:(NSUInteger)startIndex maxLength:(NSUInteger)maxLength data:(NSData*)data {
    NSMutableString *string = [NSMutableString string];
    NSUInteger count = data.length;
    
    maxLength = MIN(maxLength, count - startIndex);
    
    if (maxLength <= 0) {
        return string;
    }
    
    for (NSUInteger index = startIndex; index < (startIndex + maxLength); index++) {
        char byte = [self byteFromStartIndex:index data:data];
        
        if (![self isANS:byte]) {
            break;
        }
        NSString *charString = [[NSString alloc] initWithBytes:&byte length:1 encoding:NSASCIIStringEncoding];
        [string appendString:charString];
    }
    return string;
}

+ (BOOL)hasResponseCode:(NSData *)data {
    BOOL hasResponseCode = YES;
    
    if (data.length < 6) {
        hasResponseCode = NO;
    }
    return hasResponseCode;
}

+ (void)appendByte:(unsigned char)byte toData:(NSMutableData*)data {
    [data appendBytes:&byte length:1];
}

+ (void)appendBytes:(char*)bytes length:(NSUInteger)length toData:(NSMutableData*)data {
    if (length == 0) {
        return;
    }
    [data appendBytes:bytes length:length];
}

+ (BOOL)isStx:(unsigned char)byte {
    return (byte == PaxControlCharSTX);
}

+ (BOOL)isEtx:(unsigned char)byte {
    return (byte == PaxControlCharETX);
}

+ (BOOL)isUs:(unsigned char)byte {
    return (byte == PaxControlCharUS);
}

+ (BOOL)isFs:(unsigned char)byte {
    return (byte == PaxControlCharFS);
}

/**
 Field Units are the components of a field separetd by PaxControlCharUS,
 and gets a list of all fields present in the response message.
 */
- (NSArray*)fieldUnitsFromData:(NSData *)data {
    return [PaxResponse fieldUnitsFromData:data];
}

+ (NSArray*)fieldUnitsFromData:(NSData *)data {
    NSMutableArray *fieldUnits = nil;
    unsigned char *dataBytes = (unsigned char*)data.bytes;
    NSInteger count = data.length;
    
    // There is no data
    if (count == 0) {
        return fieldUnits;
    }
    
    fieldUnits = [NSMutableArray array];
    
    NSInteger previousIndex = 0;
    NSRange fieldUnitRange;
    
    unsigned char byte;
    
    for (NSInteger currentIndex = 0; currentIndex < count; currentIndex++) {
        byte = (unsigned char)dataBytes[currentIndex];
        if ([self isUs:byte]) {
            // Separator found
            fieldUnitRange.location = previousIndex;
            fieldUnitRange.length = currentIndex - previousIndex;
            previousIndex = currentIndex + 1;
            
            NSData *fieldUnitData = [data subdataWithRange:fieldUnitRange];
            [fieldUnits addObject:fieldUnitData];
        }
    }
    
    // Last field
    fieldUnitRange.location = previousIndex;
    fieldUnitRange.length = count - previousIndex;
    
    NSData *fieldUnitData = [data subdataWithRange:fieldUnitRange];
    [fieldUnits addObject:fieldUnitData];
    
    return fieldUnits;
}

//- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
//    
//}

@end
