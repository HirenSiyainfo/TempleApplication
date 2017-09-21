//
//  LastInvoiceReceiptPrint.m
//  RapidRMS
//
//  Created by Siya Infotech on 10/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "LastInvoiceReceiptPrint.h"

@implementation LastInvoiceReceiptPrint

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSArray *)printData withPaymentDatail:(NSArray *)paymentDatail tipSetting:(NSNumber *)tipSetting tipsPercentArray:(NSArray *)tipsPercentArray receiptDate:(NSString *)reciptDate withMasterDetail:(NSArray *)masterDetail
{
    self = [super initWithPortName:portName portSetting:portSettings printData:printData withPaymentDatail:paymentDatail tipSetting:tipSetting tipsPercentArray:tipsPercentArray receiptDate:reciptDate withMasterDetail:masterDetail];
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
