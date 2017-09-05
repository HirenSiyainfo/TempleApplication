//
//  HouseChargeReceiptPrint.h
//  RapidRMS
//
//  Created by siya8 on 23/01/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicPrint.h"
#import "StarBitmap.h"
#import "RasterDocument.h"
#import "RmsDbController.h"
#import "PrintJob.h"
#import "RapidCustomerLoyalty.h"


typedef NS_ENUM(NSInteger, HouseChargeReceiptField) {
    HouseChargeReceiptFieldStoreName = 200,
    HouseChargeReceiptFieldAddressline1,
    HouseChargeReceiptFieldAddressline2,
    
    HouseChargeReceiptFieldReceiptName,
    HouseChargeReceiptFieldReceiptType,
    HouseChargeReceiptFieldCashierName,
    HouseChargeReceiptFieldRegisterName,
    HouseChargeReceiptFieldCurrentDate,
    HouseChargeReceiptFieldTranscationDate,
    HouseChargeReceiptFieldNameOfHouseChargeUser,
    HouseChargeReceiptFieldCardNumber,
    HouseChargeReceiptFieldBalance,
    
    HouseChargeReceiptFieldSignature,
    HouseChargeReceiptFieldThanksMessage,
    
    HouseChargeReceiptFieldBarcode,
};

typedef NS_ENUM(NSInteger, HouseChargeReceiptSection) {
    HouseChargeReceiptSectionReceiptHeader = 500,
    HouseChargeReceiptSectionReceiptInfo,
    HouseChargeReceiptSectionHouseChargeDetail,
    HouseChargeReceiptSectionThanksMessage,
    HouseChargeReceiptSectionBarcode,
    HouseChargeReceiptSectionReceiptFooter,
};

typedef NS_ENUM(NSInteger, HouseChargeReceiptDataKey) {
    HouseChargeReceiptDataKeyBranchName,
    HouseChargeReceiptDataKeyAddress1,
    HouseChargeReceiptDataKeyAddress2,
    HouseChargeReceiptDataKeyCity,
    HouseChargeReceiptDataKeyState,
    HouseChargeReceiptDataKeyZipCode,
    HouseChargeReceiptDataKeyUserName,
    HouseChargeReceiptDataKeyHelpMessage1,
    HouseChargeReceiptDataKeyHelpMessage2,
    HouseChargeReceiptDataKeyHelpMessage3,
};


@interface HouseChargeReceiptPrint : BasicPrint{
    NSString *portNameForPrinter;
    NSString *portSettingsForPrinter;

    NSInteger signPrintStep;
    PrintJob *printJob;
    RmsDbController *rmsDbController;
    NSString *strReceiptDate;
    
    NSMutableArray *receiptDataArray;
    RapidCustomerLoyalty *receiptData;
    NSArray *houseChargeReceiptDataKeys;
    BOOL isSignature;
}
typedef NS_ENUM(NSUInteger, HouseChargeRPAlignment) {
    HouseChargeRPAlignmentLeft,
    HouseChargeRPAlignmentCenter,
    HouseChargeRPAlignmentRight,
};

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSMutableArray *)houseChargeDataArray withReceiptDate:(NSString*)receiptDate withIsSignature:(BOOL)isSign;
- (void)printHouseChargeReceiptWithDelegate:(id)delegate;


@end
