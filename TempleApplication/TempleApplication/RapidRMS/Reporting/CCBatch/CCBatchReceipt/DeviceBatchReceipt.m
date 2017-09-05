//
//  DeviceBatchReceipt.m
//  RapidRMS
//
//  Created by Siya-mac5 on 29/08/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "DeviceBatchReceipt.h"


@interface DeviceBatchReceipt()
{
    PaymentGateWay paymentGateWay;
}

@end
@implementation DeviceBatchReceipt

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings receiptData:(NSArray *)receiptDataArray paymentGateWay:(PaymentGateWay)selectedPaymentGateWay receiptTitle:(NSString *)title cCBatchTrnxDetail:(CCBatchTrnxDetailStruct*)cCBatchTrnxDetail isTipsApplicable:(NSNumber *)isTipsApplicable filterDetails:(NSDictionary *)filterDetailsDictionary {
    self = [super initWithPortName:portName portSetting:portSettings receiptData:receiptDataArray paymentGateWay:selectedPaymentGateWay receiptTitle:title cCBatchTrnxDetail:cCBatchTrnxDetail isTipsApplicable:isTipsApplicable filterDetails:filterDetailsDictionary];
    if (self) {
        paymentGateWay = selectedPaymentGateWay;
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
                                            @(ReceiptFieldPaymentGateWay),
                                            ];
    
    NSArray *receiptSectionCCBatchFilterInfo = @[
                                                 @(ReceiptFieldCradTypeWiseFilter),
                                                 @(ReceiptFieldSearchText),
                                                 ];

    NSArray *receiptSectionCCBatchInfoFields = @[
                                                 @(ReceiptFieldCommonHeader),
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

- (NSString *)htmlForCardType:(NSDictionary *)transactionDetailsDictionary {
    NSString *cardType = [NSString stringWithFormat:@"%@",transactionDetailsDictionary [@"CardType"]];
    NSString *transactionStatus = [self transactionStatus:transactionDetailsDictionary];
    NSString *htmlForCardType = [self htmlForTransactionDetailsField:cardType className:@"HCardType" status:transactionStatus align:@"Center"];
    return htmlForCardType;
}

- (NSString *)transactionStatus:(NSDictionary *)transactionDetailsDictionary {
    NSString *transactionStatus = @"";
    switch (paymentGateWay) {
        case BridgePay: {
            transactionStatus = [NSString stringWithFormat:@"%@",[[transactionDetailsDictionary [@"TransType"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString]];
            break;
        }
        case Pax: {
            NSInteger transationType = [transactionDetailsDictionary [@"TransType"] integerValue];
            transactionStatus = [NSString stringWithFormat:@"%@",[self getTransationType:transationType]];
            break;
        }
    }
    return transactionStatus;
}

@end
