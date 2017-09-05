//
//  BasicCCbatchReceipt.h
//  RapidRMS
//
//  Created by Siya7 on 6/7/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
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
    ReceiptFieldCashierAndRegisterName,
    ReceiptFieldReceiptCurrentDate,
    ReceiptFieldBatchNo,
   
    ReceiptFieldTitle,
    ReceiptFieldTotalCreditCardDetail,
    ReceiptFieldTotalDebitCardDetail,

    ReceiptFieldTotalAmountCount,
    ReceiptFieldBridgePayCCBatchData
    
};

typedef NS_ENUM(NSInteger, ReceiptSection) {
    ReceiptSectionReceiptHeader = 500,
    ReceiptSectionReceiptInfo,
    ReceiptSectionItemDetail,
};


typedef NS_ENUM(NSUInteger, RPAlignment) {
    RPAlignmentLeft,
    RPAlignmentCenter,
    RPAlignmentRight,
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

@interface BasicCCbatchReceipt : BasicPrint
{
    NSArray *receiptDataArray;
    NSArray *receiptBatchDetailArray;
   
    
    NSString *portNameForPrinter;
    NSString *portSettingsForPrinter;
    
    NSArray *receiptDataKeys;
    NSArray *bridgePayCCBatchData;
    float creditAvgTicket;
    float debitAvgTicket;
}
@property (nonatomic , strong) NSString *totalAmount;
@property (assign) NSInteger totalCount;
@property (nonatomic , strong) NSString *batchNo;
@property (nonatomic , strong) NSString *paymentGateway;
@property (nonatomic , strong) NSMutableDictionary *paxCreditDebitDetailDict;

- (void)printccBatchReceiptWithDelegate:(id)delegate;
- (void)configureInvoiceReceiptSection;

@property (nonatomic, strong) RcrController *crmController;

@end
