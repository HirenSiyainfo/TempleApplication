//
//  OfflineReceiptPrint.m
//  RapidRMS
//
//  Created by Siya Infotech on 29/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "OfflineReceiptPrint.h"

@implementation OfflineReceiptPrint

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSArray *)printData withPaymentDatail:(NSArray *)paymentDatail tipSetting:(NSNumber *)tipSetting tipsPercentArray:(NSArray *)tipsPercentArray receiptDate:(NSString *)reciptDate;
{
    self = [super init];
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

//// Receipt Section and Feild

- (void)configureInvoiceReceiptSection {
    
    //// section detail
    _sections = @[
                  @(ReceiptSectionReceiptHeader),
                  @(ReceiptSectionReceiptInfo),
                  @(ReceiptSectionItemDetail),
                  @(ReceiptSectionTotalSaleDetail),
                  //  @(ReceiptSectionTipDetail),
                  @(ReceiptSectionCardDetail),
                  @(ReceiptSectionReceiptFooter),
                  @(ReceiptSectionBarcode),
                  
                  ];
    
    NSArray *receiptHeaderSectionFields = @[
                                            @(ReceiptFieldStoreName),
                                            @(ReceiptFieldAddressline1),
                                            @(ReceiptFieldAddressline2),
                                            ];
    
    NSArray *receiptInvoiceInfoSectionFields = @[
                                                 @(ReceiptFieldReceiptName),
                                                 @(ReceiptFieldInvoiceNo),
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
                                               @(ReceiptFieldTip),
                                               @(ReceiptFieldTotal),
                                               
                                               ];
    
    //   NSArray *receiptTipSectionFields = @[
    //   @(ReceiptFieldTipArray),
    //     ];
    
    
    NSArray *receiptCardDetailSectionFields = @[
                                                @(ReceiptFieldCashDetail),
                                                //                                  @(ReceiptFieldChangeDue),
                                                //                                  @(ReceiptFieldCheckTendered),
                                                //                                  @(ReceiptFieldCraditTendered),
                                                //                                  @(ReceiptFieldCardHolderName),
                                                //                                  @(ReceiptFieldCardNumber),
                                                //                                  @(ReceiptFieldAuthCode),
                                                @(ReceiptFieldSignuture),
                                                // @(ReceiptFieldAgreementText),
                                                @(ReceiptFieldDiscount),
                                                ];
    
    NSArray *receiptThanksMessageSectionFields = @[
                                                   @(ReceiptFieldThanksMessage),
                                                   ];
    
    NSArray *receiptBarcodeSectionFields = @[
                                             @(ReceiptFieldBarcode),
                                             ];
    /// field detail
    _fields = @[
                receiptHeaderSectionFields,
                receiptInvoiceInfoSectionFields,
                receiptItemDetailSectionFields,
                receiptTotalSaleSectionFields,
                //   receiptTipSectionFields,
                receiptCardDetailSectionFields,
                receiptThanksMessageSectionFields,
                receiptBarcodeSectionFields,
                ];
}

-(void)printTrasactionDateAndTime
{
    [printJob setTextAlignment:TA_LEFT];
//    if (strReceiptDate) {
//        [printJob printLine:[[NSString alloc]initWithFormat:@"Hold Date:%@", strReceiptDate]];
//    }
}

- (void)printReceiptName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob enableInvertColor:YES];
    [printJob printLine:@"Offline Receipt "];
    
//    if (self.isVoidInvoicePrint == TRUE) {
//        [printJob printLine:@" Void "];
//    }
    [printJob enableInvertColor:NO];
}

@end
