//
//  LastPostpayGasInvoiceReceiptPrint.m
//  RapidRMS
//
//  Created by Siya10 on 30/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "LastPostpayGasInvoiceReceiptPrint.h"

@implementation LastPostpayGasInvoiceReceiptPrint
- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSArray *)printData withPaymentDatail:(NSArray *)paymentDatail tipSetting:(NSNumber *)tipSetting tipsPercentArray:(NSArray *)tipsPercentArray receiptDate:(NSString *)reciptDate
{
    self = [super initWithPortName:portName portSetting:portSettings printData:printData withPaymentDatail:paymentDatail tipSetting:tipSetting tipsPercentArray:tipsPercentArray receiptDate:reciptDate withMasterDetail:nil];
    if (self) {
        portNameForPrinter = portName;
        portSettingsForPrinter = portSettings;
        strReceiptDate = reciptDate;
        receiptDataArray = printData;
        paymentDatailsArray = paymentDatail;
        tipSettings = tipSetting;
        arrTipsPercent = [tipsPercentArray mutableCopy];
        rmsDbController = [RmsDbController sharedRmsDbController];
        self.crmController = [RcrController sharedCrmController ];
        
        receiptDataKeys = @[
                            @"BranchName",
                            @"Address1",
                            @"Address2",
                            @"City",
                            @"State",
                            @"ZipCode",
                            @"UserName",
                            @"Item",
                            @"ItemName",
                            @"ItemQty",
                            @"ItemDiscountAmount",
                            @"ExtraCharge",
                            @"ItemBasicAmount",
                            @"ItemTaxAmount",
                            @"TipsPercentage",
                            @"TipsAmount",
                            @"InvoiceVariationdetail",
                            @"VariationItemName",
                            @"Price",
                            @"ItemQty",
                            @"CardHolderName",
                            @"AccNo",
                            @"AuthCode",
                            @"HelpMessage1",
                            @"HelpMessage2",
                            @"HelpMessage3",
                            @"SupportEmail",
                            ];
    }
    return self;
}


@end
