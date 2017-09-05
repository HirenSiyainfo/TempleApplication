//
//  Local DetailReportRequest.m
//  PaxControllerApp
//
//  Created by siya-IOS5 on 1/11/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "Local DetailReportRequest.h"
#import "PaxRequest+Internal.h"

@interface Local_DetailReportRequest ()
{
    NSInteger currentRecordNumber;
    NSString * strReferenceNumber;
}

@end


@implementation Local_DetailReportRequest



- (instancetype)initWithRecordNumber:(NSInteger)recordNumber {
    self = [super init];
    if (self) {
        currentRecordNumber = recordNumber;
        _commandType = kPaxCommandLocalDetailReport;
    }
    return self;
}

- (instancetype)initWithReferenceNumber:(NSString *)referenceNumber
{
    self = [super init];
    if (self) {
        strReferenceNumber = referenceNumber;
        _commandType = kPaxCommandLocalDetailReport;
    }
    return self;

}

- (NSMutableData *)commandSpecificBody {
    NSMutableData *commandSpecificData = [NSMutableData data];
    
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // EDC Type : O : n2 // Not sending this data
    [self appendToData:commandSpecificData string:@"00"];
   
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    
//    NSString *transactionString = [NSString stringWithFormat:@"%02d", EdcTransactionTypeSaleRedeem];
//    [self appendToData:commandSpecificData string:transactionString];

    //// Transaction Type
    // Transaction Type : O : n2
    [self appendToData:commandSpecificData byte:PaxControlCharFS];

    //// Card Type Type
    // Card Type : O : n2
    [self appendToData:commandSpecificData byte:PaxControlCharFS];

    //// Record number
    // Record number : O : n...4
    if (currentRecordNumber) {
        NSString *currentRecordNumberString = [NSString stringWithFormat:@"%ld", (long)currentRecordNumber];
        [self appendToData:commandSpecificData string:currentRecordNumberString];
    }
    
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    
    
    //// Transaction Number
    // Transaction Number : O : n...4
    [self appendToData:commandSpecificData byte:PaxControlCharFS];

    //// Auth Code
    // Auth Code : O : ans...10
    [self appendToData:commandSpecificData byte:PaxControlCharFS];

    /// Reference Number
    // Reference Number : O : ans...16
    if (strReferenceNumber != nil) {
        NSString *referenceNumber = [NSString stringWithFormat:@"%@", strReferenceNumber];
        [self appendToData:commandSpecificData string:referenceNumber];
        [self appendToData:commandSpecificData byte:PaxControlCharFS];

    }

    return commandSpecificData;
}

@end
