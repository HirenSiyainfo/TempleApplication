//
//  ClockInOutPrint.h
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
    ReceiptFieldRegisterName,
    ReceiptFieldCurrentUserName,
    ReceiptFieldClockInOutUserName,
    ReceiptFieldCurrentDate,
    ReceiptFieldDateRange,
    ReceiptFieldClockInOutDetails,
};

typedef NS_ENUM(NSInteger, ReceiptSection) {
    ReceiptSectionReceiptHeader = 500,
    ReceiptSectionReceiptInfo,
    ReceiptSectionClockInOutDetails,
    ReceiptSectionReceiptFooter,
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
};

@interface ClockInOutPrint : BasicPrint
{
    NSString *portNameForPrinter;
    NSString *portSettingsForPrinter;

    NSString *strStartDate;
    NSString *strEndDate;
    NSString *strClockInOutUser;

    PrintJob *printJob;
    RmsDbController *rmsDbController;
    
    NSArray *receiptDataArray;
    NSArray *receiptDataKeys;
}


- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSArray *)printData startDate:(NSString *)startDate endDate:(NSString *)endDate clockInOutUser:(NSString *)clockInOutUser NS_DESIGNATED_INITIALIZER;

- (NSString *)generateHtmlForClockInOutDetails:(NSString *)htmlString;

- (void)printClockInOutDetailsWithDelegate:(id)delegate;

@end
