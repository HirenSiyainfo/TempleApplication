//
//  InvoiceReceiptPrint.h
//  RapidRMS
//
//  Created by Siya Infotech on 09/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StarBitmap.h"
#import "RasterDocument.h"
#import "RmsDbController.h"
#import "PrintJob.h"
#import "BasicPrint.h"

typedef NS_ENUM(NSInteger, ReceiptFeild) {
   ReceiptFieldStoreName = 200,
    ReceiptFieldAddressline1,
    ReceiptFieldAddressline2,
    
    ReceiptFieldReceiptName,
    ReceiptFieldInvoiceNo,
    ReceiptFieldCashierAndRegisterName,
    ReceiptFieldTransactionDate,
    ReceiptFieldPrintDate,
    
    ReceiptFieldItemDetail,
    
    ReceiptFieldTotalQTY,
    ReceiptFieldSubTotal,
    ReceiptFieldTax,
    ReceiptFieldAmount,
    ReceiptFieldTip,
    ReceiptFieldTotal,
    
 //   ReceiptFieldTipArray,
    
    ReceiptFieldCashDetail,
//    ReceiptFieldChangeDue,
//    ReceiptFieldCheckTendered,
//    ReceiptFieldCraditTendered,
//    ReceiptFieldCardHolderName,
//    ReceiptFieldCardNumber,
//    ReceiptFieldAuthCode,
    ReceiptFieldSignuture,
    ReceiptFieldAgreementText,
    ReceiptFieldDiscount,

    
    ReceiptFieldThanksMessage,
    
    ReceiptFieldBarcode,

   };

typedef NS_ENUM(NSInteger, ReceiptSection) {
    ReceiptSectionReceiptHeader = 500,
    ReceiptSectionReceiptInfo,
    ReceiptSectionItemDetail,
    ReceiptSectionTotalSaleDetail,
 //   ReceiptSectionTipDetail,
    ReceiptSectionCardDetail,
    ReceiptSectionReceiptFooter,
    ReceiptSectionBarcode,
};

typedef NS_ENUM(NSUInteger, RPAlignment) {
    RPAlignmentLeft,
    RPAlignmentCenter,
    RPAlignmentRight,
};


typedef NS_ENUM(NSInteger, ReceiptDataKey) {
    ReceiptDataKeyBranchName,
    ReceiptDataKeyAddress1,
    ReceiptDataKeyAddress2,
    ReceiptDataKeyCity,
    ReceiptDataKeyState,
    ReceiptDataKeyZipCode,
    ReceiptDataKeyUserName,
    ReceiptDataKeyItem,
    ReceiptDataKeyItemName,
    ReceiptDataKeyItemQty,
    ReceiptDataKeyItemDiscount,
    ReceiptDataKeyExtraCharge,
    ReceiptDataKeyItemBasicPrice,
    ReceiptDataKeyItemTax,
    ReceiptDataKeyTipsPercentage,
    ReceiptDataKeyTipsAmount,
    ReceiptDataKeyInvoiceVariationdetail,
    ReceiptDataKeyVariationItemName,
    ReceiptDataKeyVariationPrice,
    ReceiptDataKeyVariationQty,
    ReceiptDataKeyCardHolderName,
    ReceiptDataKeyCardAccNo,
    ReceiptDataKeyAuthCode,
    ReceiptDataKeyHelpMessage1,
    ReceiptDataKeyHelpMessage2,
    ReceiptDataKeyHelpMessage3,
    ReceiptDataKeySupportEmail,
};

@interface InvoiceReceiptPrint : BasicPrint
{
    
    NSString *portNameForPrinter;
    NSString *portSettingsForPrinter;
    NSString *strReceiptDate;

    PrintJob *printJob;
    NSArray *paymentDatailsArray;
    RmsDbController *rmsDbController;
    
    NSArray *receiptDataArray;
    NSArray *arrTipsPercent;
    NSArray *receiptDataKeys;
    NSMutableDictionary *invoiceDetailDict;
    NSArray *masterArray;

    NSNumber *tipSettings;
    
    UIImage *customerSignatureImage;
    
    NSString *strInvoice;
    NSString *strChangeDue;
    NSString *imageURL;
    float subtotal;
    int qty;
    float tax;
    float totalDiscount;
    int iqty;
    
    NSString *gasDetail;
    BOOL gasDetailAvailable;
    BOOL isSorting;

}

@property (nonatomic, strong) RcrController *crmController;
@property(assign) BOOL isVoidInvoicePrint;
@property(nonatomic , strong) NSString *cashierName;

@property(nonatomic , strong) NSString *registerName;
@property(assign) BOOL isInvoiceReceipt;


- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSArray *)printData withPaymentDatail:(NSArray *)paymentDatail tipSetting:(NSNumber *)tipSetting tipsPercentArray:(NSArray *)tipsPercentArray receiptDate:(NSString *)reciptDate withMasterDetail:(NSArray *)masterDetail
 NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDemoPortName:(NSString *)portName printData:(NSArray *)printData withDelegate:(id)delegate;

-(NSString *)generateHtmlForInvoiceNo:(NSString *)strInvoiceNo withChangeDue:(NSString *)changeDue;

- (void)printInvoiceReceiptFromHtml:(NSString *)path withPort:portName portSettings:portSettings;

- (void)printInvoiceReceiptForInvoiceNo:(NSString *)strInvoiceNo withChangeDue:(NSString *)changeDue withDelegate:(id)delegate;
- (void)printItemDetailWithDictionary:(NSDictionary *)receiptDictionary;
- (NSString *)currencyFormattedStringForAmount:(float)amount;
- (void)defaultFormatForItemDetail;
- (NSString *)htmlForItemDictionary:(NSDictionary *)billEntry;
@end
