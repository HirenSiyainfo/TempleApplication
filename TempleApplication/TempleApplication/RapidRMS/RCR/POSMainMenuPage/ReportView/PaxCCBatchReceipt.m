//
//  PaxCCBatchReceipt.m
//  RapidRMS
//
//  Created by Siya7 on 6/8/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PaxCCBatchReceipt.h"

@implementation PaxCCBatchReceipt


-(instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings withTotalCount:(NSInteger)totalCount withTotalAmount:(NSString *)totalAmount withBatchNo:(NSString *)batchNo batchDictionary:(NSMutableDictionary *)batchDict
{
    self = [super init];
    if (self) {
        portNameForPrinter = portName;
        portSettingsForPrinter = portSettings;
        self.totalAmount = totalAmount;
        self.totalCount = totalCount;
        self.batchNo = batchNo;
        self.paxCreditDebitDetailDict = batchDict;
        _rmsDbController = [RmsDbController sharedRmsDbController];
        self.crmController = [RcrController sharedCrmController];
        self.paymentGateway = @" Pax ";
    }
    return self;
}

- (void)configureInvoiceReceiptSection {
    //// section detail
    _sections = @[
                  @(ReceiptSectionReceiptHeader),
                  @(ReceiptSectionReceiptInfo),
                  @(ReceiptSectionItemDetail),
                  ];
    
    NSArray *receiptHeaderSectionFields = @[
                                            @(ReceiptFieldStoreName),
                                            @(ReceiptFieldAddressline1),
                                            @(ReceiptFieldAddressline2),
                                            ];
    
    NSArray *receiptInfoSectionFields = @[
                                          @(ReceiptFieldReceiptName),
                                          @(ReceiptFieldCashierAndRegisterName),
                                          @(ReceiptFieldReceiptCurrentDate),
                                          @(ReceiptFieldBatchNo),
                                          ];
    
    NSArray *receiptDataSectionFields = @[
                                          @(ReceiptFieldTitle),
                                          @(ReceiptFieldTotalCreditCardDetail),
                                          @(ReceiptFieldTotalDebitCardDetail),
                                          @(ReceiptFieldTotalAmountCount)
                                          ];
    
    
    /// field detail
    _fields = @[
                receiptHeaderSectionFields,
                receiptInfoSectionFields,
                receiptDataSectionFields,
                ];
}

@end
