//
//  GiftCardReceiptPrint.h
//  RapidRMS
//
//  Created by Siya-mac5 on 14/11/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StarBitmap.h"
#import "RasterDocument.h"
#import "RmsDbController.h"
#import "PrintJob.h"
#import "BasicPrint.h"

typedef NS_ENUM(NSInteger, GiftCardReceiptField) {
    GiftCardReceiptFieldStoreName = 200,
    GiftCardReceiptFieldAddressline1,
    GiftCardReceiptFieldAddressline2,
    
    GiftCardReceiptFieldReceiptName,
    GiftCardReceiptFieldCashierName,
    GiftCardReceiptFieldRegisterName,
    GiftCardReceiptFieldCurrentDate,
    GiftCardReceiptFieldTranscationDate,
    
    GiftCardReceiptFieldNameOfGiftCard,
    GiftCardReceiptFieldCardNumber,
    GiftCardReceiptFieldBalance,
    
    GiftCardReceiptFieldThanksMessage,
    
    GiftCardReceiptFieldBarcode,
};

typedef NS_ENUM(NSInteger, GiftCardReceiptSection) {
    GiftCardReceiptSectionReceiptHeader = 500,
    GiftCardReceiptSectionReceiptInfo,
    GiftCardReceiptSectionGiftCardDetail,
    GiftCardReceiptSectionThanksMessage,
    GiftCardReceiptSectionBarcode,
    GiftCardReceiptSectionReceiptFooter,
};

typedef NS_ENUM(NSInteger, GiftCardReceiptDataKey) {
    GiftCardReceiptDataKeyBranchName,
    GiftCardReceiptDataKeyAddress1,
    GiftCardReceiptDataKeyAddress2,
    GiftCardReceiptDataKeyCity,
    GiftCardReceiptDataKeyState,
    GiftCardReceiptDataKeyZipCode,
    GiftCardReceiptDataKeyUserName,
    GiftCardReceiptDataKeyHelpMessage1,
    GiftCardReceiptDataKeyHelpMessage2,
    GiftCardReceiptDataKeyHelpMessage3,
};

@interface GiftCardReceiptPrint : BasicPrint
{
    NSString *portNameForPrinter;
    NSString *portSettingsForPrinter;

    PrintJob *printJob;
    RmsDbController *rmsDbController;
    NSString *strReceiptDate;
    
    NSMutableDictionary *receiptDataDictionary;
    NSArray *giftCardReceiptDataKeys;
}

typedef NS_ENUM(NSUInteger, GiftCardRPAlignment) {
    GiftCardRPAlignmentLeft,
    GiftCardRPAlignmentCenter,
    GiftCardRPAlignmentRight,
};

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSMutableDictionary *)giftCardDataDictionary withReceiptDate:(NSString*)receiptDate;
- (void)printGiftCardReceiptWithDelegate:(id)delegate;

@end
