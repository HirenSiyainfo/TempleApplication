//
//  RmsDbController.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "XMPPFramework.h"
#import "UpdateManager.h"

#define LiveUpdateConnectedNotification @"LiveUpdateConnectedNotification"
#define LiveUpdateDisconnectedNotification @"LiveUpdateDisconnectedNotification"

@protocol SynchronizeVcDelegate <NSObject>

-(void)didSynchronizeComplete;
-(void)didSynchronizeFailed;

@end
typedef void (^ UIAlertActionHandler)(UIAlertAction *action);

typedef NS_ENUM(NSInteger, TAX_Setting) {
    TAX_APPLY_FOR_DISCOUNT_PRICE = 1,
    TAX_APPLY_FOR_ORIGNAL_PRICE,
};
typedef NS_ENUM(NSInteger, DepartmentType)
{
    DepartmentTypeNone = 0,
    DepartmentTypeMerchandise,
    DepartmentTypeLottery,
    DepartmentTypeGas,
    DepartmentTypeMoneyOrder,
    DepartmentTypeGiftCard,
    DepartmentTypeCheckCash,
    DepartmentTypeVendorPayout,
    DepartmentTypeHouseCharge,
    DepartmentTypeOther
};

@interface RmsDbController : NSObject <UpdateDelegate, XMPPRosterDelegate>
{
   volatile BOOL _isInternetRechable;
}

@property (nonatomic, weak) id<SynchronizeVcDelegate> synchronizeVcDelegate;

@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) NSMutableArray *pumpMasterArray;
@property (nonatomic, strong) NSMutableArray *tankMasterArray;

@property (nonatomic, strong) NSMutableDictionary *globalDict;
@property (nonatomic, strong) NSMutableDictionary *globalScanDevice;

@property (nonatomic, strong) NSMutableArray *appsActvDeactvSettingarray;
@property (nonatomic, strong) NSMutableArray *appsActvDeactvSettingarrayWithStore;
@property (nonatomic, strong) NSMutableArray *paymentCardTypearray;
@property (nonatomic, strong) NSMutableArray *outSideCardTypearray;


@property (nonatomic, assign) BOOL isRegisterFirstTime;
@property (nonatomic, assign) BOOL isInternetRechable;

@property (nonatomic) BOOL isSynchronizing;
@property (nonatomic) BOOL isFirstDashboardIcon;
@property (nonatomic) BOOL isVoidTrasnaction;
@property (nonatomic) BOOL isFirstShortCutIcon;
@property (nonatomic) BOOL isFirstTimeDataLoad;
@property (nonatomic) BOOL isFirstTimeActivate;

@property (nonatomic, strong) NSString *selectedModule;
@property (nonatomic, strong) NSString *rimSelectedFilterType;
@property (nonatomic, strong) NSString *rcrSelectedFilterType;
@property (nonatomic, strong) NSString *customerSelectedFilterType;
@property (nonatomic, strong) NSString *globalSoundString;
@property (nonatomic, strong) NSString *globalSoundSetting;

@property (assign) NSTimeInterval serviceTimeOut;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic , strong) NSURLSession *paxURLSession;

@property (nonatomic, assign) int intFrame;

@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;

+ (RmsDbController*)sharedRmsDbController;
+ (NSString *)removeNameSpaceFromXml:(NSString *)xml rootTag:(NSString *)rootTag;

- (void)playButtonSound;
- (void)startItemUpdate:(NSTimeInterval)timeInterVal;
- (void)doSynchronizeOperation;
- (void)startSynchronizeUpdate:(NSTimeInterval)timeInterVal;
- (void)getItemDataFirstTime;
- (void)getRegistrationDetail;
- (void)removeDatabaseInfoAndConfigureWithNewBarnch;
- (void)saveContext;

- (void)launchLoginScreenWithSelectedModule:(NSString *)strSelectedModule callModule:(NSString *)strCallModule;

- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;

- (void)cancelOfflineUploadProcess;
- (void)setInvoiceNoFromDict:(NSMutableDictionary *)responseData privateContextObject:(NSManagedObjectContext *)privateContextObject;

- (void)addItemListToLiveUpdateQueue:(NSMutableDictionary *)dictItem;

- (void)popupAlertFromVC:(UIViewController*)viewController title:(NSString *)title  message:(NSString *)message buttonTitles:(NSArray*)buttonTitles buttonHandlers:(NSArray*)buttonHandlers;

- (void)disconnect;
- (void)resumeConfiguration;
- (void)dbVersionUpdate;
- (void)dbVersionUpdateGas;
- (void)setupAudio;
- (void)removeAudio;

- (void)setAppSetting:(NSDictionary *)rapidConfigSetting;
- (void)removeAppSettings;

- (CGFloat)roundTo2Decimals:(CGFloat)number;
- (float)removeCurrencyFomatter:(NSString *)string;

- (NSString *)trimmedBarcode:(NSString *)searchData;
- (NSString *)ludForTimeInterval:(NSTimeInterval)timeInterVal;
- (NSString *)applyCurrencyFomatter:(NSString *)string;
- (NSString *)jsonStringFromObject:(id)object;
- (NSString *)GetHMACFromUserID:(NSString *)userId;
- (NSString *)userNameOfApp;

@property (NS_NONATOMIC_IOSONLY, getter=isXmppConnected, readonly) BOOL xmppConnected;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL wasDateModified;
- (BOOL)checkRightsForRightId :(NSString *)rightId;
- (BOOL)isSignUpForTrial:(NSMutableArray *)array;

- (id)objectFromJsonString:(NSString *)jsonString;
- (NSDate *)getDateFromJSONDate:(NSString *)jsonDate;
- (BOOL)isPreAuthEnabled;
-(NSString *)getStringPriceFromFloat:(float)input;
-(PumpCartInvoiceData *)getInvoiceDetailForRegInvNo :(NSMutableDictionary *)param withMethodName:(NSString *)methodName;
-(BOOL)checkGasPumpisActive;
-(BOOL)isRapidOnSite;
-(BOOL)getGasPumpUrlEnabled;
-(NSString *)getGasPumpUrl;
-(NSPredicate *)predicateForKey:(NSString *)key floatValue:(float)floatValue;
-(NSMutableDictionary *)createLogDictionaryWithLastPumpState:(NSInteger)pumpIndex withStatus:(NSString *)status;
-(void)addEventForMasterUpdateWithKey:(NSString *)appSeeKey;

@end
