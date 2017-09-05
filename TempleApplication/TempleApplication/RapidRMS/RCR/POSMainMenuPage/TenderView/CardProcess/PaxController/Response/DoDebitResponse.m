//
//  DoDebitResponse.m
//  PaxControllerApp
//
//  Created by siya info on 21/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DoDebitResponse.h"

@implementation DoDebitResponse
- (instancetype)initWithData:(NSData*)data {
    self = [super initWithData:data];
    if (self) {
        responseMessageFields = @[
                                  @(FieldIndexMultiPacket),
                                  @(FieldIndexCommandType),
                                  @(FieldIndexVersion),
                                  @(FieldIndexResponseCode),
                                  @(FieldIndexResponseMessage),
                                  @(FieldIndexHostInformation),
                                  @(FieldIndexTransactionType),
                                  @(FieldIndexAmountInformation),
                                  @(FieldIndexAccountInformation),
                                  @(FieldIndexTraceInformation),
                                  @(FieldIndexAdditionalInformation),
                                  ];
    }
    return self;
}
@end
