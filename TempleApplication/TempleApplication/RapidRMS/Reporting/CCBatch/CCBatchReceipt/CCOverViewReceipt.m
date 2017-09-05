//
//  CCOverViewReceipt.m
//  RapidRMS
//
//  Created by Siya-mac5 on 05/08/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CCOverViewReceipt.h"

@implementation CCOverViewReceipt

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings receiptData:(NSArray *)receiptDataArray receiptTitle:(NSString *)title filterDetails:(NSDictionary *)filterDetailsDictionary {
    self = [super initWithPortName:portName portSetting:portSettings receiptData:receiptDataArray receiptTitle:title filterDetails:filterDetailsDictionary];
    if (self) {
    }
    return self;
}

- (void)configureRecieptSections {
    //// section detail
    _sections = @[
                  @(ReceiptSectionHeader),
                  @(ReceiptSectionCCBatchFilterInfo),
                  @(ReceiptSectionCCBatchInfo),
                  @(ReceiptSectionCCBatchDetails),
                  @(ReceiptSectionFooter),
                  ];
    
    NSArray *receiptSectionHeaderFields = @[
                                            @(ReceiptFieldStoreName),
                                            @(ReceiptFieldStoreAddress),
                                            @(ReceiptFieldStoreEmailAndPhoneNumber),
                                            @(ReceiptFieldTitle),
                                            @(ReceiptFieldUserNameAndRegister),
                                            @(ReceiptFieldCurrentDate),
                                            ];
    
    NSArray *receiptSectionCCBatchFilterInfo = @[
                                            @(ReceiptFieldRegisterWiseFilter),
                                            ];
    
    NSArray *receiptSectionCCBatchInfoFields = @[
                                                 @(ReceiptFieldPaymentGateWay),
                                                 @(ReceiptFieldTotalAmount),
                                                 @(ReceiptFieldTotalTransactions),
                                                 @(ReceiptFieldAvgTicket),
                                                 ];
    
    NSArray *receiptSectionCCBatchDetailsFields = @[
                                                @(ReceiptFieldCardPaymentDetails),
                                                ];
    
    NSArray *receiptSectionFooterFields = @[
                                               ];
    /// field detail
    _fields = @[
                receiptSectionHeaderFields,
                receiptSectionCCBatchFilterInfo,
                receiptSectionCCBatchInfoFields,
                receiptSectionCCBatchDetailsFields,
                receiptSectionFooterFields,
                ];
}

@end
