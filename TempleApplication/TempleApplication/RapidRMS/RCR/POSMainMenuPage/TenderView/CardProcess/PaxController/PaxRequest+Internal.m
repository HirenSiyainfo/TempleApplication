//
//  PaxRequest+Internal.m
//  PaxControllerApp
//
//  Created by Siya Infotech on 15/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxRequest+Internal.h"

@implementation PaxRequest (Internal)
#pragma mark - Prepare Command Data
/**
 This method generate command specific body.
 Each sub-class must implement this.
 */
- (NSMutableData *)commandSpecificBody {
    NSMutableData *commandSpecificData = [NSMutableData data];
    return commandSpecificData;
}

/**
 This method generates command body of the commands.
 */
- (NSMutableData *)commandBody {
    NSMutableData *commandBodyData = [NSMutableData data];
    // Data
    // Command type : M : ans3
    [self appendToData:commandBodyData string:_commandType];
    // FS : M : 1
    [self appendToData:commandBodyData byte:PaxControlCharFS];
    // Version : M : ans...4
    [self appendToData:commandBodyData string:_version];

    // Command specific
    NSMutableData *commandSpecificData = self.commandSpecificBody;
    [commandBodyData appendData:commandSpecificData];

    return commandBodyData;
}

/**
 This method generates complete Request Message including:
    - PaxControlCharSTX
    - Command Data
    - PaxControlCharETX
    - LRC
 */
- (void)prepareCommandData {
    // Header
    // STX - Start of Transaction
    [self appendByte:PaxControlCharSTX];

    NSMutableData *commandBody = [self.commandBody mutableCopy];

    // ETX - End of Transaction
    [self appendToData:commandBody byte:PaxControlCharETX];
//    [self appendByte:PaxControlCharETX];
    [_commandData appendData:commandBody];

    // Checksum
    // LRC - Longitudinal Redundancy Check
    UInt8 checkSum = [self checksumForData:commandBody];
    [self appendByte:checkSum];


}

#pragma mark - Append data to command
// Append Byte
- (void)appendByte:(UInt8)cc {
    [_commandData appendBytes:(const void *)&cc length:1];
}

// Append String
- (void)appendString:(NSString*)string {
    NSData *datax = [string dataUsingEncoding:NSUTF8StringEncoding];
    [_commandData appendData:datax];
}

// Append Byte
- (void)appendToData:(NSMutableData*)data byte:(UInt8)cc {
    [data appendBytes:(const void *)&cc length:1];
}

// Append String
- (void)appendToData:(NSMutableData*)data string:(NSString*)string {
    NSData *datax = [string dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:datax];
}

// String from amount

- (NSInteger)centsFromDollar:(float)dollars {
    NSInteger cents;
    NSInteger sign = (dollars < 0 ? -1 : 1);
    cents = (dollars + 0.001 * sign) * 100;
    return cents;
}

// Amount is converted to cents before formatting
- (NSString*)stringForAmount:(float)amount {
    
    NSNumber * amountInCents = @((amount * 100));
    
    NSString *stringForAmount = amountInCents.stringValue; // [NSString stringWithFormat:@"%0.2f", _amount]; //
    if (amountInCents.floatValue < 100) {
        stringForAmount = [NSString stringWithFormat:@"%03ld", (long)amountInCents.floatValue];
    }
    return stringForAmount;
}

// Append amount
- (void)appendAmount:(float)amount toData:(NSMutableData *)data {
    NSString *stringForAmount = [NSString stringWithFormat:@"%ld",(long)[self centsFromDollar:amount]];
    [self appendToData:data string:stringForAmount];
}

#pragma mark - Checksum
// LRC - Longitudinal Redundancy Check
/**
 Calculation:
 Set LRC = 0
 For each character c in the string Do
 Set LRC = LRC XOR c
 End Do
 */
- (UInt8)checksumForData:(NSData*)data {
    UInt8 checkSum = 0;

    UInt8 nextChar;
    NSRange range;
    range.length = 1;
    for (int i = 0; i < data.length; i++) {
        range.location = i;
        [data getBytes:&nextChar range:range];
        checkSum ^= nextChar;
    }
    return checkSum;
}


@end
