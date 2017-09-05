//
//  CCBatchVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 18/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyReportVC.h"
@interface CCBatchTrnxDetailStruct : NSObject

@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSString *tipAmount;
@property (nonatomic, strong) NSString *grandTotal;
@property (nonatomic, strong) NSString *totalTransaction;
@property (nonatomic, strong) NSString *totalAvgTicket;

@end

typedef NS_ENUM(NSInteger, TRANSACTIONTYPE) {
    TRANSACTIONTYPEMENU,
    TRANSACTIONTYPESALEREDEEM,
    TRANSACTIONTYPERETURN,
    TRANSACTIONTYPEAUTH,
    TRANSACTIONTYPEPOSTAUTH,
    TRANSACTIONTYPEFORCED,
    TRANSACTIONTYPEADJUST,
    TRANSACTIONTYPEWITHDRAWAL,
    TRANSACTIONTYPEACTIVATE,
    TRANSACTIONTYPEISSUE,
    TRANSACTIONTYPEADD,
    TRANSACTIONTYPECASHOUT,
    TRANSACTIONTYPEDEACTIVATE,
    TRANSACTIONTYPEREPLACE,
    TRANSACTIONTYPEMERGE,
    TRANSACTIONTYPEREPORTLOST,
    TRANSACTIONTYPEVOID,
    TRANSACTIONTYPEVSALE,
    TRANSACTIONTYPEVRTRN,
    TRANSACTIONTYPEVAUTH,
    TRANSACTIONTYPEVPOST,
    TRANSACTIONTYPEVFRCD,
    TRANSACTIONTYPEVWITHDRAW,
    TRANSACTIONTYPEBALANCE,
    TRANSACTIONTYPEVERIFY,
    TRANSACTIONTYPEREACTIVATE,
    TRANSACTIONTYPEFORCEDISSUE,
    TRANSACTIONTYPEFORCEDADD,
    TRANSACTIONTYPEUNLOAD,
    TRANSACTIONTYPERENEW,
    TRANSACTIONTYPEGETCONVERTDETAIL,
    TRANSACTIONTYPECONVERT,
    TRANSACTIONTYPETOKENIZE,
    TRANSACTIONTYPEREVERSAL,
};

typedef NS_ENUM(NSInteger, PaxLocalTotalReportDetails) {
    PaxLocalTotalReportCredit,
    PaxLocalTotalReportDebit,
    PaxLocalTotalReportEBT,
    PaxLocalTotalReportGift,
    PaxLocalTotalReportLOYALTY,
    PaxLocalTotalReportCASH,
    PaxLocalTotalReportCHECK,
};

@protocol CCBatchVCDelegate <NSObject>
- (void)startActivityIndicatorForCCBatch;
- (void)stopActivityIndicatorForCCBatch;
- (void)updateProgressStatusForCCBatch:(CGFloat)intPercentage;
- (void)updateLoadingMessageForCCBatch:(NSString *)message;
- (void)addTipsView:(UIView *)tipsView;
- (void)removeTipsView:(UIView *)tipsView;
- (void)presentViewAsModalForCCBatch:(UIView *)view;
- (void)removePresentedViewForCCBatch;
- (void)configurePaxDeviceFromSetting;
- (void)setSelectedPrintOptionForCCBatch:(ReportPrint)cCBatchReportPrint;
- (void)setPrintingData:(NSArray *)cCbatchPrintingArray paymentGateWay:(PaymentGateWay)paymentGateWay transactionDetails:(CCBatchTrnxDetailStruct *)transactionDetails filterDictionary:(NSDictionary *)filterDictionary;
@end

@interface CCBatchVC : UIViewController
- (void)displayCCBatchUI;
- (void)settleBatchProcess;

@property (nonatomic, strong) NSNumber *isTipsApplicable;
@property (nonatomic, strong) NSMutableDictionary *dictPaxData;

@property (nonatomic, weak) id <CCBatchVCDelegate> cCBatchVCDelegate;
@end
