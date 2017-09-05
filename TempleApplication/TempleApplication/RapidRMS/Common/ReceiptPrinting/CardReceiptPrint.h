//
//  CardReceiptPrint.h
//  RapidRMS
//
//  Created by Siya Infotech on 09/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaymentData.h"
#import "PrintJob.h"
#import "BasicPrint.h"

typedef NS_ENUM(NSInteger, CardReceiptFeild) {
    CardReceiptFieldStoreName = 200,
    CardReceiptFieldAddressline1,
    CardReceiptFieldAddressline2,
    
    CardReceiptFieldReceiptName,
    CardReceiptFieldInvoiceNo,
    CardReceiptFieldCashierAndRegisterName,
    CardReceiptFieldTransactionDate,
    CardReceiptFieldPrintDate,
    
    CardReceiptFieldCardDetails,

    CardReceiptFieldCardHolderSignature,
    CardReceiptFieldThanksMessage,
};

typedef NS_ENUM(NSInteger, CardReceiptSection) {
    CardReceiptSectionReceiptHeader = 500,
    CardReceiptSectionReceiptInfo,
    CardReceiptSectionCardDetail,
    CardReceiptSectionSignature,
    CardReceiptSectionThanksMessage,
};

typedef NS_ENUM(NSUInteger, CRAlignment) {
    CRAlignmentLeft,
    CRAlignmentCenter,
    CRAlignmentRight,
};

@interface CardReceiptPrint : BasicPrint
{
    
    NSString *strInvoice;
    PrintJob *printJob;
    
    NSString *portNameForPrinter;
    NSString *portSettingsForPrinter;
    NSString *strReceiptDate;
    
    
    NSArray *arrTipsPercent;
    NSArray *paymentDatailsArray;
    
    NSMutableDictionary *invoiceDetailDict;
    
    NSNumber *tipSettings;

}
@property (nonatomic, strong) RcrController *crmController;

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings withPaymentDatail:(NSArray *)paymentDatail tipSetting:(NSNumber *)tipSetting tipsPercentArray:(NSArray *)tipsPercentArray receiptDate:(NSString *)reciptDate NS_DESIGNATED_INITIALIZER;
@property (assign) BOOL isVoidCardReceipt;
-(NSString *)generateHtmlForCardRecieptForInvoiceNo:(NSString *)strInvoiceNo;

- (void)printCardReceiptForInvoiceNo:(NSString *)strInvoiceNo withDelegate:(id)delegate;

- (void)printCardReceiptFromHtml:(NSString *)path withPort:portName portSettings:portSettings;

@end
