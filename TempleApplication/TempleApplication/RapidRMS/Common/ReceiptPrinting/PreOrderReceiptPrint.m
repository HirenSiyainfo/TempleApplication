//
//  PreOrderReceiptPrint.m
//  RapidRMS
//
//  Created by Siya7 on 5/27/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PreOrderReceiptPrint.h"

@implementation PreOrderReceiptPrint


- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSArray *)printData receiptDate:(NSString *)reciptDate
{
    self = [super init];
    if (self) {
        portNameForPrinter = portName;
        portSettingsForPrinter = portSettings;
        strReceiptDate = reciptDate;
        receiptDataArray = printData;
        rmsDbController = [RmsDbController sharedRmsDbController];
        self.crmController = [RcrController sharedCrmController];
        
        
        
        receiptDataKeys = @[
                            @"BranchName",
                            @"Address1",
                            @"Address2",
                            @"City",
                            @"State",
                            @"ZipCode",
                            @"UserName",
                            @"item",
                            @"itemName",
                            @"itemQty",
                            @"ItemDiscount",
                            @"ExtraCharge",
                            @"ItemBasicPrice",
                            @"itemTax",
                            @"TipsPercentage",
                            @"TipsAmount",
                            @"InvoiceVariationdetail",
                            @"VariationItemName",
                            @"Price",
                            @"itemQty",
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

//// Receipt Section and Feild

- (void)configureInvoiceReceiptSection {
    
    //// section detail
    _sections = @[
                  @(ReceiptSectionReceiptHeader),
                  @(ReceiptSectionReceiptInfo),
                  @(ReceiptSectionItemDetail),
                  @(ReceiptSectionTotalSaleDetail),
                  @(ReceiptSectionReceiptFooter),
                  ];
    
    NSArray *receiptHeaderSectionFields = @[
                                            @(ReceiptFieldStoreName),
                                            @(ReceiptFieldAddressline1),
                                            @(ReceiptFieldAddressline2),
                                            ];
    
    NSArray *receiptInvoiceInfoSectionFields = @[
                                                 @(ReceiptFieldReceiptName),
                                                 @(ReceiptFieldCashierAndRegisterName),
                                                 @(ReceiptFieldTransactionDate),
                                                 @(ReceiptFieldPrintDate),
                                                 ];
    
    NSArray *receiptItemDetailSectionFields = @[
                                                @(ReceiptFieldItemDetail),
                                                ];
    
    NSArray *receiptTotalSaleSectionFields = @[
                                               @(ReceiptFieldTotalQTY),
                                               @(ReceiptFieldSubTotal),
                                               @(ReceiptFieldTax),
                                               @(ReceiptFieldAmount),
                                               ];
    
    NSArray *receiptFooterSectionFields = @[
                                            @(ReceiptFieldThanksMessage),
                                            ];
    
    
    _fields = @[
                receiptHeaderSectionFields,
                receiptInvoiceInfoSectionFields,
                receiptItemDetailSectionFields,
                receiptTotalSaleSectionFields,
                receiptFooterSectionFields,
                ];
}

-(void)printTrasactionDateAndTime
{
    [printJob setTextAlignment:TA_LEFT];
    if (strReceiptDate) {
        [printJob printLine:[[NSString alloc]initWithFormat:@"Hold Date:%@", strReceiptDate]];
    }
}

- (void)printReceiptName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob enableInvertColor:YES];
    [printJob printLine:@" Pre-Order Receipt "];
    
    if (self.isVoidInvoicePrint == TRUE) {
        [printJob printLine:@" Void "];
    }
    [printJob enableInvertColor:NO];
}

@end
