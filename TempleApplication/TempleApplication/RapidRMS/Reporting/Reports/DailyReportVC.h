//
//  DailyReportVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 11/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FooterButton)
{
    FooterButtonShiftReport = 5001,
    FooterButtonXReport,
    FooterButtonZReport,
    FooterButtonZZReport,
    FooterButtonManagerReport,
    FooterButtonCCBatch,
};

typedef NS_ENUM(NSInteger, ReportPrint)
{
    ShiftReportPrint,
    XReportPrint,
    ZReportPrint,
    ZZReportPrint,
    ManagerZReportPrint,
    ManagerZZReportPrint,
    CentralizeZReportPrint,
    CCOverViewPrint,
    CurrentTransactionPrint,
    DeviceSummaryPrint,
    DeviceBatchPrint,
};

typedef NS_ENUM(NSInteger, ReportName)
{
    ReportNameX = 6001,
    ReportNameZ,
    ReportNameZZ,
    ReportNameManagerZ,
    ReportNameManagerZZ,
    ReportNameShift,
    ReportNameCentralizedZ,
};

typedef NS_ENUM(NSInteger, PaymentGateWay) {
    BridgePay,
    Pax,
};

typedef NS_ENUM (NSUInteger, ManagerTabOption) {
    ManagerTabOptionShiftHistory = 7001,
    ManagerTabOptionZHistory,
    ManagerTabOptionZZHistory,
    ManagerTabOptionCentralizedZHistory,
    ManagerTabOptionCentralizedZZHistory,
    ManagerTabOptionNone,
};

@interface DailyReportVC : UIViewController

@end
