//
//  DoDebitRequest.m
//  PaxControllerApp
//
//  Created by siya info on 21/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DoDebitRequest.h"

@implementation DoDebitRequest
- (instancetype)initWithTransaction:(EdcTransactionType)transaction amount:(float)amount tipAmount:(float)tipAmount cashBackAmount:(float)cashBackAmount merchantFee:(float)merchantFee taxAmount:(float)taxAmount invoiceNumber:(NSString *)invoiceNumber referenceNumber:(NSString *)referenceNumber{
    self = [super initWithTransaction:transaction amount:amount tipAmount:tipAmount cashBackAmount:cashBackAmount merchantFee:merchantFee taxAmount:taxAmount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    if (self) {
        _commandType = kPaxCommandDoDebit;
    }
    return self;
}
@end
