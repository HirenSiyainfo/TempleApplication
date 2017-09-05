//
//  BridgePayCCBatchReceipt.m
//  RapidRMS
//
//  Created by Siya7 on 6/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "BridgePayCCBatchReceipt.h"

@implementation BridgePayCCBatchReceipt

-(instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings withBridgePayCCBatchData:(NSArray *)bridgePayCCBatchDetail
{
    self = [super init];
    if (self) {
        portNameForPrinter = portName;
        portSettingsForPrinter = portSettings;
        _rmsDbController = [RmsDbController sharedRmsDbController];
        self.crmController = [RcrController sharedCrmController];
        bridgePayCCBatchData = bridgePayCCBatchDetail;
        self.paymentGateway = @" BridgePay ";

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
                                          ];
    
    NSArray *receiptDataSectionFields = @[
                                          @(ReceiptFieldBridgePayCCBatchData),
                                          ];
    
    
    /// field detail
    _fields = @[
                receiptHeaderSectionFields,
                receiptInfoSectionFields,
                receiptDataSectionFields,
                ];
}


@end
