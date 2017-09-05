//
//  RcrController.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

/**
 This class is meant to replace AppDelegate of the stand alone application.
 */

#import <Foundation/Foundation.h>
#import "UpdateManager.h"
#import "CustomerDisplayClient.h"

@class UtilityManager, SettingView, ReportViewController;

@interface RcrController : NSObject <UpdateDelegate>
{
}

@property (nonatomic, strong) CustomerDisplayClient *customerDisplayClient;
@property (nonatomic, strong) ReportViewController *pReportView ;
@property (nonatomic, strong) SettingView *setting;

@property (nonatomic, strong) NSMutableDictionary *globalScanDict;
@property (nonatomic, strong) NSMutableDictionary *savePrintSetting;
@property (nonatomic, strong) NSMutableDictionary *tenderView;

@property (nonatomic, strong) NSMutableArray *globalArrTenderConfig;
@property (nonatomic, strong) NSMutableArray *globalAdvertisearray;
@property (nonatomic, strong) NSMutableArray *reciptItemLogDataAry;

@property (nonatomic, strong) NSString *recallInvoiceId;
@property (nonatomic, strong) NSString *manualPriceValue;
@property (nonatomic, strong) NSString *manualQtyValue;

@property (readwrite, assign) NSInteger TimeAdvetise;
@property (nonatomic, assign) NSInteger Globalseconds;
@property (nonatomic, assign) NSInteger recallCount;

@property (nonatomic, assign) int Globalminutes;
@property (readwrite, assign) int taxtagvalue;

@property (nonatomic, assign) BOOL isPrintReq;
@property (nonatomic, assign) BOOL bZexit;
@property (nonatomic, assign) BOOL isbillOrderFromRecall;
@property (nonatomic, assign) BOOL isbillOrderFromRecallOffline;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap1;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (RcrController*)sharedCrmController;
+ (NSString *)getKURLValue;
+ (NSString *)getImagePathValue;
+ (NSString*)getPortName;
+ (void)setPortName:(NSString *)m_portName;
+ (NSString*)getPortSettings;
+ (void)setPortSettings:(NSString *)m_portSettings;

- (void)UserTouchEnable;
- (void)setURLValues:(NSString *)kURLValue andImagePath:(NSString *)imagePathValue;
- (void)tenderInvoiceNotificat:(NSMutableDictionary *)ItemNotificationDict;
- (void)writeDictionaryToCustomerDisplay:(NSDictionary*)dictionary;
@property (NS_NONATOMIC_IOSONLY, getter=isDisplayConnected, readonly) BOOL displayConnected;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *displayName;
- (void)didInsertInvoiceDataToServerWithDetail:(NSMutableDictionary *)invoiceDetail withInvoiceObject:(NSManagedObjectID*)invoiceDataId;
- (BOOL)isSpecOptionApplicableCreditCardForCommon:(int)specOption;


@end
