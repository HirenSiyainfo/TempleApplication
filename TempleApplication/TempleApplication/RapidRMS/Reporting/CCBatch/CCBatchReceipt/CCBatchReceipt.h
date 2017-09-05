//
//  CCBatchReceipt.h
//  RapidRMS
//
//  Created by Siya-mac5 on 04/08/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "BasicPrint.h"
#import "CCBatchVC.h"

typedef NS_ENUM(NSInteger, ReceiptSection) {
    ReceiptSectionHeader = 500,
    ReceiptSectionCCBatchFilterInfo,
    ReceiptSectionCCBatchInfo,
    ReceiptSectionCCBatchDetails,
    ReceiptSectionFooter,
};

typedef NS_ENUM(NSInteger, ReceiptField) {
    ReceiptFieldStoreName = 200,
    ReceiptFieldStoreAddress,
    ReceiptFieldStoreEmailAndPhoneNumber,
    ReceiptFieldTitle,
    ReceiptFieldUserNameAndRegister,
    ReceiptFieldCurrentDate,
    ReceiptFieldPaymentGateWay,
    ReceiptFieldRegisterWiseFilter,
    ReceiptFieldCradTypeWiseFilter,
    ReceiptFieldSearchText,
    ReceiptFieldTotalAmount,
    ReceiptFieldTotalTransactions,
    ReceiptFieldAvgTicket,
    ReceiptFieldCommonHeader,
    ReceiptFieldCardPaymentDetails,
};

typedef NS_ENUM(NSUInteger, ReceiptDataKey) {
    ReceiptDataKeyBranchName,
    ReceiptDataKeyAddress1,
    ReceiptDataKeyAddress2,
    ReceiptDataKeyCity,
    ReceiptDataKeyState,
    ReceiptDataKeyZipCode,
    ReceiptDataKeyUserName,
};

typedef NS_ENUM(NSUInteger, RPAlignment) {
    RPAlignmentLeft,
    RPAlignmentCenter,
    RPAlignmentRight,
};

@interface CCBatchReceipt : BasicPrint


- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings receiptData:(NSArray *)receiptDataArray receiptTitle:(NSString *)title filterDetails:(NSDictionary *)filterDetailsDictionary;

- (void)printCCBatchReceiptWithDelegate:(id)delegate;
- (void)configureRecieptSections;
- (void)configurePrint:(NSString *)portSettings portName:(NSString *)portName withDelegate:(id)delegate;

- (void)printTotalAmount;
- (void)printTotalTransactions;
- (void)printCardType:(NSString *)cardType;
- (void)printTotal:(NSString *)total totalTransactions:(NSString *)totalTransactions avgTicket:(NSString *)avgTicket;

- (void)defaultFormatForReceipt;
- (void)defaultFormatForThreeColumn;

- (NSString *)generateHtml;

- (NSString *)htmlCardPaymentDetailsWithText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 enableBold:(BOOL)enableBold;

- (NSString *)currentDateTime;

- (id)userInfoValueForKeyIndex:(ReceiptDataKey)index;

@end
