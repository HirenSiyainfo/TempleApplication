
//
//  RmsDbController.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "RmsDbController.h"
#import "Keychain.h"
#import "RimLoginVC.h"
#import "LoadingViewController.h"
#import "UserActivationViewController.h"
#import "ModuleActivationVC.h"
#import "DashBoardSettingVC.h"
#import "HConfigurationVC.h"

#import "Item+Dictionary.h"
#import "Configuration.h"
#import "ItemSupplier+Dictionary.h"
#import "ItemTax+Dictionary.h"
#import "RimsController.h"
#import "Reachability.h"
#import "InvoiceData_T+Dictionary.h"
#import "POSLoginView.h"
#import <AVFoundation/AVFoundation.h>

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "UpdateManager.h"
#import "ModuleInfo+Dictionary.h"
#import "RegisterInfo+Dictionary.h"
#import "BranchInfo+Dictionary.h"
#import "CreditcardCredetnial+Dictionary.h"
#import "CredentialInfo+Dictionary.h"

#import <CFNetwork/CFNetwork.h>
#import <CommonCrypto/CommonHMAC.h>
#import "PaxDevice.h"
#import "InitializeResponse.h"
#import "NSString+Methods.h"

// Please note down core data details so it will helpful to others
// Last Change done by : Himanshu (Add ItemInventoryCount table)
#define CURRENT_DB_VERSION 70.0 // change when required from 24.0
#define CURRENT_DB_VERSION_GAS 13.0
#define INTERCOM_SECUREMODE_KEY @"p7Nr8NpldxIKOm6l4-pgY61QZDY2YSJFuxpujZrc"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

#define LIVEUPDATE_SERVER_NAME @"ongocloud.com"
//#define LIVEUPDATE_SERVER_NAME @"rmsinvupdate1.cloudapp.net"

#import "UserAuthenticationVC.h"
static RmsDbController *s_sharedRmsDbController = nil;


@interface RmsDbController () <UpdateDelegate ,PaxDeviceDelegate>
{
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    
    NSString *password;
    
    BOOL isXmppConnected;
    BOOL customCertEvaluation;
    BOOL isT0;
    
    NSDate *startDate;
    NSCondition *_myCondition;
    PaxDevice *paxDevice;
}

@property (nonatomic, strong) RimsController *_rimController;
@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic) Reachability *hostReachability;


@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, strong) RapidWebServiceConnection *wsPhase1;
@property (nonatomic, strong) RapidWebServiceConnection *wsPhase2;
@property (nonatomic, strong) RapidWebServiceConnection *wsPhase3;
@property (nonatomic, strong) RapidWebServiceConnection *wsPhase4;
@property (nonatomic, strong) RapidWebServiceConnection *regConfiguration;
@property (nonatomic, strong) RapidWebServiceConnection *pumpCartWC;

@property (nonatomic, strong) RapidWebServiceConnection *synchronizeWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *paymentCardTypeWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *itemUpdateConnection;
@property (nonatomic, strong) RapidWebServiceConnection *userInfoWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *getMasterDetailConnection;
@property (nonatomic, strong) RapidWebServiceConnection *getMasterUpdateDetailConnection;
@property (nonatomic, strong) RapidWebServiceConnection *webServiceConnectionOffline;
@property (nonatomic, strong) RapidWebServiceConnection *liveUpdateConnection;
@property (nonatomic, strong) RapidWebServiceConnection *petroLiveUpdateConnection;
@property (nonatomic, strong) RapidWebServiceConnection *receiptMasterConnection;

@property (nonatomic, strong) NSArray *offlineInvoiceList;
@property (nonatomic, strong) NSMutableArray *arrayItemLiveUpdate;
@property (nonatomic, strong) NSMutableArray *arrayPetroLiveUpdate;

@property (nonatomic, strong) NSString *strUpdateType;
@property (nonatomic, strong) NSString *strPetroUpdateType;

@property (nonatomic, assign) BOOL isOffline;
@property (nonatomic, assign) BOOL isMasterUpdate;

@property (nonatomic) NSInteger nextIndex;
@property (nonatomic) NSInteger steps;
@property (nonatomic) NSInteger currentStep;

@property (nonatomic, strong) NSManagedObjectContext *offlineManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *privateWriterContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) NSLock *liveUpdateLock;
@property (nonatomic, strong) NSLock *petroliveUpdateLock;



@end

@implementation RmsDbController
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize pumpMasterArray,tankMasterArray;

+ (RmsDbController*)sharedRmsDbController {
    @synchronized(self) {
        if (!s_sharedRmsDbController) {
            s_sharedRmsDbController = [[RmsDbController alloc] init];
        }
    }
    return s_sharedRmsDbController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpDbController];
    }
    return self;
}

- (void)removeDB
{
    // if value is not CURRENT_DB_VERSION call updateDbForVersion
    float dbVersion = [[[NSUserDefaults standardUserDefaults] valueForKey:@"RmsDbVersion"] floatValue ];
    
    float dbCheck = CURRENT_DB_VERSION - dbVersion;
    
    // if value is not CURRENT_DB_VERSION call updateDbForVersion
    if(fabsl(dbCheck) > 0.01)
    {

        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RapidRms.sqlite"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ConfigurationStep"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        if (![fileManager removeItemAtURL:storeURL error:&error])
        {
            
            NSLog(@"[Error] %@ (%@)", error, storeURL);
        }
    }
}

- (void)removeDBForGas
{
    float dbVersion = [[[NSUserDefaults standardUserDefaults] valueForKey:@"RmsDbVersionGas"] floatValue ];
    
    float dbCheck = CURRENT_DB_VERSION_GAS - dbVersion;
    
    // if value is not CURRENT_DB_VERSION call updateDbForVersion
    if(fabsl(dbCheck) > 0.01)
    {
        
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GasPump.sqlite"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        
        if ([fileManager fileExistsAtPath:storeURL.path]){
            
            if (![fileManager removeItemAtURL:storeURL error:&error])
            {
                
                NSLog(@"[Error] %@ (%@)", error, storeURL);
            }
        }
    
    }
}
-(void)removeDatabaseInfoAndConfigureWithNewBarnch{
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"RmsDbVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self launchUpdateProgressVC];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self getItemDataFirstTime];
    });
}
-(void)setUpDbController
{
    [self removeDB];
    
    [self removeDBForGas];
    
    self.liveUpdateLock = [[NSLock alloc] init];
    self.petroliveUpdateLock = [[NSLock alloc] init];

    
    self.appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.paymentCardTypearray = [[NSMutableArray alloc]init];
    self.arrayItemLiveUpdate = [[NSMutableArray alloc]init];
    self.arrayPetroLiveUpdate = [[NSMutableArray alloc]init];
   //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextHasChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    self.regConfiguration = [[RapidWebServiceConnection alloc] init];
    
//    self.pumpManager = [[PumpManager alloc] initWithDelegate:self];
//    
//    [self dbVersionUpdateGas];
    
    self.offlineManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    self.isSynchronizing = FALSE;

    self.currencyFormatter = [[NSNumberFormatter alloc] init];
    self.currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

    self.globalDict = [[NSMutableDictionary alloc] init];
	(self.globalDict)[@"UserInfo"] = @"";
    (self.globalDict)[@"BranchID"] = @"";
    (self.globalDict)[@"RegisterId"] = @"";
    (self.globalDict)[@"ZId"] = @"";
    (self.globalDict)[@"ZRequired"] = @"";
	(self.globalDict)[@"ItemSelectionMode"] = autoMode;
	(self.globalDict)[@"AddModifireAtIndex"] = @"0";
	(self.globalDict)[@"DiscountMode"] = billDis;
	(self.globalDict)[@"BillDiscount"] = @"0.0";
	(self.globalDict)[@"InvoiceNo"] = @"-";
    (self.globalDict)[@"BranchInfo"] = @"";
    (self.globalDict)[@"DBName"] = @"";
    (self.globalDict)[@"TokenId"] = @"";
    self.globalSoundSetting = [[NSString alloc] init];
    self.globalScanDevice = [[NSMutableDictionary alloc]init];
    
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"Sound"] isEqualToString:@""])
    {
        self.globalSoundString = [[NSUserDefaults standardUserDefaults]valueForKey:@"Sound"];
        
        if([self.globalSoundString isKindOfClass:[NSString class]])
        {
            if ([self.globalSoundString isEqualToString:@"<null>"]) {
                
            }
            else
            {
                self.globalSoundSetting = self.globalSoundString;
                [self setupAudio];
            }
        }
        else
        {
            
        }
	}
    // Scanner
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"ScannerType"] isEqualToString:@""])
    {
        NSString *strScanar = [[NSUserDefaults standardUserDefaults]valueForKey:@"ScannerType"];
        if([strScanar isKindOfClass:[NSString class]])
        {
            if ([strScanar isEqualToString:@"<null>"])
            {
                (self.globalScanDevice)[@"Type"] = @"Bluetooth";
            }
            else
            {
                (self.globalScanDevice)[@"Type"] = strScanar;
            }
        }
        else
        {
            (self.globalScanDevice)[@"Type"] = @"Bluetooth";
        }
	}
    else
    {
        (self.globalScanDevice)[@"Type"] = @"Scanner";
    }
    
    NSString *strPurchasedTemp = [Keychain getStringForKey:@"DeviceId"];
    if (strPurchasedTemp)
    {
        NSLog(@"MacAddress From Keychain : %@",strPurchasedTemp);
        (self.globalDict)[@"DeviceId"] = strPurchasedTemp;
    }
    else
    {
        NSString *udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
        (self.globalDict)[@"DeviceId"] = udid;
        NSLog(@"MacAddress identifierForVendor : %@",udid);
        [Keychain saveString:udid forKey:@"DeviceId"];
    }
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getbranchinfolist:) name:@"BranchInfoResult" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseSyncMasterUpdate:) name:@"UpdatedSyncMasterlistResult" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseLiveUpdateAcknowledgementResult:) name:@"LiveUpdateAcknowledgementResult" object:nil];

    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = RAPID_SERVER_NAME;
    
    _myCondition = [[NSCondition alloc] init];
    
	self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
	[self.hostReachability startNotifier];
    #if RAPID_URL_SCHEME == RAPID_URL_SCHEME_LOCAL
           self.isInternetRechable = !([self.hostReachability currentReachabilityStatus] == NotReachable);
    
    #endif
    //self.isInternetRechable = YES;
    self.isOffline = NO;
    //Hiten
    //[DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    
    // Setup the XMPP stream
    
	[self setupStream];
    
    self.isOffline = NO;
    
}


-(void)offlineInvoiceData:(NSTimer *)timer
{
    dispatch_async(dispatch_queue_create("responseOfflineDataUpdate", NULL), ^{
        [self sendOfflineTenderPaymentDataToServer];
    });
}



#pragma mark - Rechability
- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = note.object;
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
	{
		[self statusDidChanged:reachability];
//        NetworkStatus netStatus = [reachability currentReachabilityStatus];
//        BOOL connectionRequired = [reachability connectionRequired];
    }
}

- (void)statusDidChanged:(Reachability *)reachability
{
    NetworkStatus netStatus = reachability.currentReachabilityStatus;
    //  BOOL connectionRequired = [reachability connectionRequired];
    
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    switch (netStatus)
    {
        case NotReachable:
        {
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            [self popupAlertFromVC:rootController title:@"Info" message:@"Please check Internet Connection or Server not Accessible." buttonTitles:@[@"OK"] buttonHandlers:nil];
            self.isInternetRechable = NO;
            self.isOffline = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            if(self.isOffline){
                [self popupAlertFromVC:rootController title:@"Info" message:@"Now you are connected with Internet" buttonTitles:@[@"OK"] buttonHandlers:nil];
                
            }
            self.isInternetRechable = TRUE;
            self.isOffline = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            if(self.isOffline){
                [self popupAlertFromVC:rootController title:@"Info" message:@"Now you are connected with Internet" buttonTitles:@[@"OK"] buttonHandlers:nil];
                
            }
            self.isInternetRechable = TRUE;
            self.isOffline = NO;
            break;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetBreakDown" object:nil];
}

-(UIAlertView *)getAlertMessage:(UIViewController *)rootController{
    
    UIAlertView *alert = nil;
        NSArray* subviews = rootController.view.subviews;
        if (subviews.count > 0) {
            for (id cc in subviews) {
                if ([cc isKindOfClass:[UIAlertView class]]) {
                    alert = cc;
                }
            }
    }
    return alert;
}
#pragma mark - Device Activation
-(void)getRegistrationDetail
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict[@"MacAddress"] = (self.globalDict)[@"DeviceId"];
    dict[@"dType"] = @"IOS-RCRIpad";
    dict[@"dVersion"] = [UIDevice currentDevice].systemVersion;
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    if ([appVersion isKindOfClass:[NSString class]])
    {
        dict[@"appVersion"] = appVersion;
    }
    else
    {
        dict[@"appVersion"] = @"";
    }
    NSString *buildVersion = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey];
    if ([buildVersion isKindOfClass:[NSString class]])
    {
        dict[@"buildVersion"] = buildVersion;
    }
    else
    {
        dict[@"buildVersion"] = @"";
    }
    // Pass system date and time while configuration
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    dict[@"LocalDate"] = currentDateTime;
    NSLog(@"DeviceConfigration03192015 Param = %@",dict);
    // DeviceConfigration05012015
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{

                [self regConfigrationResponse:response error:error];
            });
    };
    self.regConfiguration = [self.regConfiguration initWithRequest:KURL actionName:WSM_DEVICE_CONFIGRATION params:dict completionHandler:completionHandler];
 
}

#pragma mark - RemoveAppSettings

-(void)removeAppSettings
{
    [self removeSoundSettingForRapidRMS];
    [self removeScannerSettingForRapidRMS];
    [self removeCahngeDueTimerAndTipsSettingForRapidRMS];
    [self removeRcrAndRIMSettingForRapidRMS];
    [self removeTenderSettingForRapidRMS];
    [self removeFlowerSettingForRapidRMS];
    [self removeDashBoardIconSelectionSettingForRapidRMS];
    [self removeUpcSettingForRapidRMS];
    [self removeKitchenPrinterSettingRapidRMS];
    [self removePaxDeviceSettingRapidRMS];
    [self removeTaxSettingRapidRMS];
    [self removePrinterSettingRapidRMS];

}

-(void)removeSoundSettingForRapidRMS {
    self.globalSoundSetting = nil;
    [self removeAudio];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Sound"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SelectedSound"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeScannerSettingForRapidRMS {
    [self.globalScanDevice removeObjectForKey:@"Type"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ScannerType"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Type"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeCahngeDueTimerAndTipsSettingForRapidRMS {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChangeDue_Setting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeRcrAndRIMSettingForRapidRMS {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Selection"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PrintRecieptStatus"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"WeightScaleStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeTenderSettingForRapidRMS {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TendConfig"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeFlowerSettingForRapidRMS {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ModuleSelectionShortCut"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeDashBoardIconSelectionSettingForRapidRMS {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DashBoardIconSelection"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeUpcSettingForRapidRMS {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UPC_Setting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeKitchenPrinterSettingRapidRMS {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"KitchenPrinter_Setting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removePaxDeviceSettingRapidRMS {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PaxDeviceConfig"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PaxDeviceStatus"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)removeTaxSettingRapidRMS {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Tax_Setting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removePrinterSettingRapidRMS {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PrinterSelection"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DrawerDeviceStatus"];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BluetoothDrawerDeviceType"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BluetoothDrawerDeviceType"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"TCPDrawerDeviceType"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TCPDrawerDeviceType"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - SetAppSettings

-(void)soundSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
 
    if (settingDictionary[@"RapidSoundSetting"])
    {
        NSDictionary *dictForSound = [settingDictionary[@"RapidSoundSetting"] firstObject];
        [[NSUserDefaults standardUserDefaults] setObject:dictForSound[@"Sound"] forKey:@"Sound"];
        [[NSUserDefaults standardUserDefaults] setObject:dictForSound[@"SelectedSound"] forKey:@"SelectedSound"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.globalSoundSetting = [[NSString alloc] init];
        self.globalSoundSetting = dictForSound[@"Sound"];
        [self setupAudio];
    }
}
-(void)scannerSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    if (settingDictionary[@"RapidScannerSetting"])
    {
         NSDictionary *dictForScannerSetting = [settingDictionary[@"RapidScannerSetting"] firstObject];
        [[NSUserDefaults standardUserDefaults] setObject:dictForScannerSetting[@"Type"] forKey:@"ScannerType"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        (self.globalScanDevice)[@"Type"] = dictForScannerSetting[@"Type"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Bluetooth" forKey:@"Type"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

-(void)cahngeDueTimerAndTipsSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"ChangeDue_Setting"] == nil) {
        if (settingDictionary[@"RapidChangeDueTimeAndTipsSetting"] != nil)
        {
            NSDictionary *dictCahngeDueAndTips = settingDictionary[@"RapidChangeDueTimeAndTipsSetting"];
            NSManagedObjectContext *privateContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
            Configuration *configuration = [UpdateManager getConfigurationMoc:privateContext];
            if(dictCahngeDueAndTips[@"TipsSwitch"])
            {
                if ([dictCahngeDueAndTips[@"TipsSwitch"] isKindOfClass:[NSNumber class]]) {
                    configuration.localTipsSetting = dictCahngeDueAndTips[@"TipsSwitch"];
                }
                else if ([dictCahngeDueAndTips[@"TipsSwitch"] isKindOfClass:[NSString class]]){
                    NSString * strTip = dictCahngeDueAndTips[@"TipsSwitch"];
                    configuration.localTipsSetting = [NSNumber numberWithBool:strTip.boolValue];
                }
            }
            else
            {
                configuration.localTipsSetting = @(0);
            }
            [UpdateManager saveContext:privateContext];
            [[NSUserDefaults standardUserDefaults] setObject:dictCahngeDueAndTips forKey:@"ChangeDue_Setting"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        else
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            dict[@"TipsSwitch"] = @(0);
            dict[@"changeDueTimerSwitch"] = @(0);
            dict[@"changeDueTimerValue"] = @"";
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"ChangeDue_Setting"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
}

-(void)rcrAndRIMSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    if (settingDictionary[@"RapidRCRAndRIMSetting"])
    {
        NSDictionary *dictCahngeDueAndTips = settingDictionary[@"RapidRCRAndRIMSetting"];
       
        if (dictCahngeDueAndTips[@"Selection"]) {
            [[NSUserDefaults standardUserDefaults] setObject:dictCahngeDueAndTips[@"Selection"] forKey:@"Selection"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"Department" forKey:@"Selection"];
        }
        
        if (dictCahngeDueAndTips[@"PrintRecieptStatus"]) {
            [[NSUserDefaults standardUserDefaults] setObject:dictCahngeDueAndTips[@"PrintRecieptStatus"] forKey:@"PrintRecieptStatus"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"PrintRecieptStatus"];
        }
        
        if (dictCahngeDueAndTips[@"WeightScaleStatus"]) {
            [[NSUserDefaults standardUserDefaults] setObject:dictCahngeDueAndTips[@"WeightScaleStatus"] forKey:@"WeightScaleStatus"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"WeightScaleStatus"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Department" forKey:@"Selection"];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"PrintRecieptStatus"];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"WeightScaleStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)tenderSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *arryForTendConfig = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig"];
    if(arryForTendConfig.count == 0)
    {
        if (settingDictionary[@"RapidTenderSetting"])
        {
            NSArray *arrayForTenderConfig = settingDictionary[@"RapidTenderSetting"];
            [[NSUserDefaults standardUserDefaults] setObject:arrayForTenderConfig forKey:@"TendConfig"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
}
-(void)flowerSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *arryForModuleSelectionShortCut = [[NSUserDefaults standardUserDefaults] valueForKey:@"ModuleSelectionShortCut"];
    if(arryForModuleSelectionShortCut.count == 0)
    {
        if (settingDictionary[@"RapidModuleSelectionShortCut"])
        {
            NSArray *arrayForModulShortCut = [settingDictionary valueForKey:@"RapidModuleSelectionShortCut"];
            [[NSUserDefaults standardUserDefaults] setObject:arrayForModulShortCut forKey:@"ModuleSelectionShortCut"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
}
-(void)dashBoardIconSelectionSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *arrDashBoardIconSelection = [[NSUserDefaults standardUserDefaults] valueForKey:@"DashBoardIconSelection"];
    if(arrDashBoardIconSelection.count == 0)
    {
        if (settingDictionary[@"RapidDashBoardIconSelection"])
        {
            NSArray *arrayForDashBoardIconSelection = [settingDictionary valueForKey:@"RapidDashBoardIconSelection"];
            [[NSUserDefaults standardUserDefaults] setObject:arrayForDashBoardIconSelection forKey:@"DashBoardIconSelection"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
}
-(void)upcSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *arrUPC_Setting = [[NSUserDefaults standardUserDefaults] valueForKey:@"UPC_Setting"];
    if(arrUPC_Setting.count == 0)
    {
        if (settingDictionary[@"RapidUPC_Setting"])
        {
            NSArray *arrayForUPC_Setting = settingDictionary[@"RapidUPC_Setting"];
            [[NSUserDefaults standardUserDefaults] setObject:arrayForUPC_Setting forKey:@"UPC_Setting"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
}

-(void)kitchenPrinterSettingRapidRMS:(NSMutableDictionary *)settingDictionary
{
    if (settingDictionary[@"KitchenPrinter_Setting"])
    {
        NSArray *arrayForUPC_Setting = settingDictionary[@"KitchenPrinter_Setting"];
        [[NSUserDefaults standardUserDefaults] setObject:arrayForUPC_Setting forKey:@"KitchenPrinter_Setting"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

-(void)paxDeviceSettingRapidRMS:(NSMutableDictionary *)settingDictionary
{
    if (settingDictionary[@"PaxDeviceConfig"])
    {
        NSDictionary *dictPaxDevice = [settingDictionary[@"PaxDeviceConfig"] firstObject];
        [[NSUserDefaults standardUserDefaults] setObject:dictPaxDevice forKey:@"PaxDeviceConfig"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self paxConnectedStatus:dictPaxDevice];
    }
}

-(void)paxConnectedStatus:(NSDictionary *)dictPaxConfig
{
    paxDevice = [[PaxDevice alloc] initWithIp:dictPaxConfig[@"PaxDeviceIp"] port:dictPaxConfig[@"PaxDevicePort"]];
    paxDevice.paxDeviceDelegate = self;
    paxDevice.pdResonse = PDRequestInitialize;
    [paxDevice initializeDevice];
}

- (void)paxDevice:(PaxDevice*)paxDevice willSendRequest:(NSString*)request
{
    
}
- (void)paxDevice:(PaxDevice*)paxDevice response:(PaxResponse*)response
{
    InitializeResponse *initializeResponse = (InitializeResponse *)response;
    if (initializeResponse.responseCode.integerValue == 0) {
        dispatch_async(dispatch_get_main_queue(),  ^{
            NSDictionary *dictPaxDevice = @{
                            @"PaxConnectionStatus" : @(1),
                            @"PaxSerialNumber" : [NSString stringWithFormat:@"%@",initializeResponse.serialNumber],
                        };
            
            [[NSUserDefaults standardUserDefaults] setObject:dictPaxDevice forKey:@"PaxDeviceStatus"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),  ^{

            NSDictionary *dictPaxDevice = @{
                                            @"PaxConnectionStatus" : @(0),
                                            @"PaxSerialNumber" : [NSString stringWithFormat:@"%@",initializeResponse.serialNumber],
                                            };
            
            [[NSUserDefaults standardUserDefaults] setObject:dictPaxDevice forKey:@"PaxDeviceStatus"];
            [[NSUserDefaults standardUserDefaults]synchronize];
});
    }

}
- (void)paxDevice:(PaxDevice*)paxDevice failed:(NSError*)error response:(PaxResponse *)response
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        ///////
        NSDictionary *dictPaxDevice = @{
                                        @"PaxConnectionStatus" : @(0),
                                        @"PaxSerialNumber" : @"",
                                        };
        
        [[NSUserDefaults standardUserDefaults] setObject:dictPaxDevice forKey:@"PaxDeviceStatus"];
        [[NSUserDefaults standardUserDefaults]synchronize];

    });
}

- (void)paxDevice:(PaxDevice*)paxDevice isConncted:(BOOL)isConncted
{
    
}
- (void)paxDeviceDidTimeout:(PaxDevice*)paxDevice
{
    
}



-(void)taxSettingRapidRMS:(NSMutableDictionary *)settingDictionary
{
    if (settingDictionary[@"Tax_Setting"])
    {
        NSDictionary *dictTaxSetting = [settingDictionary[@"Tax_Setting"] firstObject];
        [[NSUserDefaults standardUserDefaults] setObject:dictTaxSetting forKey:@"Tax_Setting"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}
-(void)printerSettingRapidRMS:(NSMutableDictionary *)settingDictionary
{
    if (settingDictionary[@"PrinterSelection"])
    {
        NSDictionary *dictPrinterSetting = [settingDictionary[@"PrinterSelection"] firstObject];
        [[NSUserDefaults standardUserDefaults] setObject:dictPrinterSetting forKey:@"PrinterSelection"];
    }
    if(settingDictionary[@"PrinterWithIP"]){
        NSDictionary *dictPrinterSetting = settingDictionary[@"PrinterWithIP"];
        NSString *strPrinterType;
        
        strPrinterType = dictPrinterSetting[@"PrinterType"];
        
        if([strPrinterType isEqualToString:@"TCP"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:dictPrinterSetting[@"PrinterIP"] forKey:@"SelectedTCPPrinter"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:strPrinterType forKey:@"PrinterSelection"];
    }
    
    NSMutableDictionary *dictPrinterUnfo = settingDictionary[@"DeviceStatus"];
    if (dictPrinterUnfo) {
        [[NSUserDefaults standardUserDefaults] setObject:dictPrinterUnfo[@"DrawerDeviceStatus"] forKey:@"DrawerDeviceStatus"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"DrawerDeviceStatus"];
    }
    
    NSMutableDictionary *dictDrawerType = settingDictionary[@"DrawerType"];
    if (dictDrawerType) {
        if (dictDrawerType[@"BluetoothDrawerDeviceType"]) {
            [[NSUserDefaults standardUserDefaults] setObject:dictDrawerType[@"BluetoothDrawerDeviceType"] forKey:@"BluetoothDrawerDeviceType"];
        }
        if (dictDrawerType[@"TCPDrawerDeviceType"]) {
            [[NSUserDefaults standardUserDefaults] setObject:dictDrawerType[@"TCPDrawerDeviceType"] forKey:@"TCPDrawerDeviceType"];
        }
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)gasPumpSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{

    NSDictionary *gasPetroSetting = [settingDictionary valueForKey:@"RapidPetroSetting"];
    if([gasPetroSetting valueForKey:@"selectedPetroServer"]){
        
        [[NSUserDefaults standardUserDefaults] setObject:[settingDictionary valueForKey:@"RapidPetroSetting"] forKey:@"RapidPetroSetting"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
    else{
     
        NSMutableDictionary *dictRapidPetroSetting = [NSMutableDictionary dictionary];
        dictRapidPetroSetting[@"selectedPetroServer"] = @(1);
        
        NSString * GasPumpUrl = [gasPetroSetting objectForKey:@"GasPumpUrl"];
        if (!GasPumpUrl) {
            GasPumpUrl = @"";
        }
        NSNumber * urlEnabled = [gasPetroSetting objectForKey:@"GasPumpUrlEnabled"];
        if (!urlEnabled) {
            urlEnabled = @(0);
        }
        dictRapidPetroSetting[@"RapidOnsite"] = [@{@"GasPumpUrl":GasPumpUrl,@"GasPumpUrlEnabled":urlEnabled} mutableCopy];
        
        NSNumber * beepSelection = [gasPetroSetting objectForKey:@"BeepSelectionEnabled"];
        if (!beepSelection) {
            beepSelection = @(0);
        }
        NSNumber * gradeSelection = [gasPetroSetting objectForKey:@"GradeSelectionEnabled"];
        if (!gradeSelection) {
            gradeSelection = @(0);
        }
        NSNumber * serviceMode = [gasPetroSetting objectForKey:@"ServiceMode"];
        if (!serviceMode) {
            serviceMode = @(0);
        }
        NSNumber * simulation = [gasPetroSetting objectForKey:@"Simulation"];
        if (!simulation) {
            simulation = @(0);
        }
        
        NSNumber * usePreAuth = [gasPetroSetting objectForKey:@"UsePreAuth"];
        if (!usePreAuth) {
            usePreAuth = @(0);
        }
        
        dictRapidPetroSetting[@"PetroSetting"] = [@{@"BeepSelectionEnabled":beepSelection,@"GradeSelectionEnabled":gradeSelection,@"PaymentMode":@[@"Cash",@"Credit"],@"ServiceMode":serviceMode,@"Simulation":simulation,@"UsePreAuth":usePreAuth} mutableCopy];
        
        dictRapidPetroSetting[@"RapidFusion"] = [@{@"fusionIP":@"", @"fusionPort":@"", @"PaymentData":[@[] mutableCopy]} mutableCopy];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:dictRapidPetroSetting forKey:@"RapidPetroSetting"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
//        NSMutableDictionary *gasSetting = [settingDictionary valueForKey:@"RapidPetroSetting"];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[gasSetting valueForKey:@"GasPumpUrlEnabled"] forKey:@"GasPumpUrlEnabled"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[gasSetting valueForKey:@"GasPumpUrl"] forKey:@"GasPumpUrl"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[gasSetting valueForKey:@"ServiceMode"] forKey:@"ServiceMode"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        
//        NSMutableArray *arrayServiceMode = [[gasSetting valueForKey:@"PaymentMode"]mutableCopy];
//        [[NSUserDefaults standardUserDefaults] setObject:arrayServiceMode forKey:@"PaymentMode"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[gasSetting valueForKey:@"GradeSelectionEnabled"] forKey:@"GradeSelectionEnabled"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[gasSetting valueForKey:@"BeepSelectionEnabled"] forKey:@"BeepSelectionEnabled"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[gasSetting valueForKey:@"Simulation"] forKey:@"Simulation"];
//        [[NSUserDefaults standardUserDefaults]synchronize];

    }
}

- (BOOL)isPreAuthEnabled {
    
    NSDictionary *petroSetting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RapidPetroSetting"] mutableCopy];
    return [petroSetting[@"RapidOnsite"][@"UsePreAuth"] boolValue];
}
-(void)configureRapidSettingWith:(NSMutableDictionary *)settingDictionary
{
    [self soundSettingForRapidRMS:settingDictionary];
    [self scannerSettingForRapidRMS:settingDictionary];
    [self cahngeDueTimerAndTipsSettingForRapidRMS:settingDictionary];
    [self tenderSettingForRapidRMS:settingDictionary];
    [self rcrAndRIMSettingForRapidRMS:settingDictionary];
    [self flowerSettingForRapidRMS:settingDictionary];
    [self dashBoardIconSelectionSettingForRapidRMS:settingDictionary];
    [self upcSettingForRapidRMS:settingDictionary];
    [self kitchenPrinterSettingRapidRMS:settingDictionary];
    [self paxDeviceSettingRapidRMS:settingDictionary];
    [self taxSettingRapidRMS:settingDictionary];
    [self printerSettingRapidRMS:settingDictionary];
    [self gasPumpSettingForRapidRMS:settingDictionary];
}

- (void)configureDatabaseWithDeviceConfiguration:(NSManagedObjectContext *)privateContextObject responseData:(NSMutableDictionary *)responseData responseArray:(NSMutableArray *)responseArray
{
    NSPredicate *filterRcrPredicate = [NSPredicate predicateWithFormat:@"MacAdd = %@",(self.globalDict)[@"DeviceId"]];
    NSArray * array = [self.appsActvDeactvSettingarray filteredArrayUsingPredicate:filterRcrPredicate];
    if (array.count > 0)
    {
        [self.updateManager deleteModuleInfoFromDatabaseWithContext:privateContextObject];
        
        for (NSDictionary *dictionary in array)
        {
            ModuleInfo *moduleInfo = [self.updateManager updateModuleInfoMoc:privateContextObject];
            [moduleInfo updateModuleInfoDictionary:dictionary];
        }
    }
    
    RegisterInfo *registerInfo = [self.updateManager updateRegisterInfoMoc:privateContextObject];
    [registerInfo updateRegisterInfoDictionary:responseData];
    
    BranchInfo *branchInfo = [self.updateManager updateBranchInfoMoc:privateContextObject];
    [branchInfo updateBranchInfoDictionary:[self.globalDict valueForKey:@"BranchInfo"]];
    
    [self.updateManager deleteDetailOfUserInfo:privateContextObject];
    NSDictionary *userInfo = [[responseData valueForKey:@"UserInfo"] firstObject];
    [self.updateManager updateDetailWithUserInfo:userInfo withmoc:privateContextObject];
    [UpdateManager saveContext:privateContextObject];
    
}

- (void)loginOffline
{
    // Get
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;

    // Commented because duplicate
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSArray * registerArray = [self.updateManager fetchEntityFromDatabase:privateContextObject withEntityName:@"RegisterInfo"];
    if (registerArray.count == 0) {
        [self popupAlertFromVC:rootController title:@"Info - 1" message:@"Register information is missing. Please check the internet connection and restart the application." buttonTitles:@[@"OK"] buttonHandlers:nil];
        return;
    }
    
    // Check Registration Data
    RegisterInfo *registerInfo = [self.updateManager updateRegisterInfoMoc:privateContextObject];
    NSDictionary * registerInfoDictionary = registerInfo.registerDictionary;
    if (registerInfoDictionary == nil)
    {
        [self popupAlertFromVC:rootController title:@"Info - 2" message:@"Register information is missing. Please check the internet connection and restart the application." buttonTitles:@[@"OK"] buttonHandlers:nil];
        return;
    }
    
    (self.globalDict)[@"BranchID"] = @([[registerInfoDictionary valueForKey:@"BranchId"] integerValue]);
    (self.globalDict)[@"RegisterId"] = [NSString stringWithFormat:@"%@",[registerInfoDictionary valueForKey:@"RegisterId"]];
    (self.globalDict)[@"ZRequired"] = [registerInfoDictionary valueForKey:@"ZRequired"];
    (self.globalDict)[@"ZId"] = [NSString stringWithFormat:@"%@",[registerInfoDictionary valueForKey:@"ZId"]];
    (self.globalDict)[@"RegisterName"] = [registerInfoDictionary valueForKey:@"RegisterName"];
    (self.globalDict)[@"DBName"] = [registerInfoDictionary valueForKey:@"DBName"];
    (self.globalDict)[@"TokenId"] = [registerInfoDictionary valueForKey:@"TokenId"];
    
    // Check Branch Info
    NSArray * branchArray = [self.updateManager fetchEntityFromDatabase:privateContextObject withEntityName:@"BranchInfo"];
    if (branchArray.count == 0) {
        [self popupAlertFromVC:rootController title:@"Info" message:@"Branch information is missing. Please check the internet connection and restart the application." buttonTitles:@[@"OK"] buttonHandlers:nil];
        return;
    }
    BranchInfo *branchInfo = [self.updateManager updateBranchInfoMoc:privateContextObject];
    (self.globalDict)[@"BranchInfo"] = branchInfo.branchInfoDictionary;
    
    // Check Module Info
    ModuleInfo *moduleInfo = [self.updateManager fetchModuleInfoMoc:privateContextObject withDiviceId:(self.globalDict)[@"DeviceId"]];
    if (moduleInfo == nil)
    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Offline Process is not applicable for this device setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
        [self popupAlertFromVC:rootController title:@"Info" message:@"Module information is missing. Please check the internet connection and restart the application." buttonTitles:@[@"OK"] buttonHandlers:nil];
        return;
    }
    
    self.appsActvDeactvSettingarray = [[NSMutableArray alloc]init];
    NSArray * arrayActivation = [self.updateManager moduleInfoMoc:privateContextObject];
    for (ModuleInfo *moduleInfo in arrayActivation)
    {
        [self.appsActvDeactvSettingarray addObject:moduleInfo.moduleInfoDictionary];
    }
    BOOL isRcrGasactive = [self isRcrGasActiveLog];
    if (isRcrGasactive)
    {
        
        DebugLogManager * objLogManager = [DebugLogManager sharedDebugLogManager];
        NSFetchedResultsController * objects = objLogManager.logPetroRC;
        if (!objects) {
            objects = objLogManager.logPetroRC;
        }
        NSArray * petroLogs = objects.fetchedObjects;
        for (PetroLog * petroLog in petroLogs) {
            [objLogManager addOperationInQueue:petroLog];
        }
    }
    [self launchRmsDashBoard];
}

- (void)setInvoiceNoFromDict:(NSMutableDictionary *)responseData privateContextObject:(NSManagedObjectContext *)privateContextObject
{
    NSString *strInvNo = [[responseData valueForKey:@"RegisterInvNo"] stringValue];
    if (strInvNo) {
        [Keychain saveString:strInvNo forKey:@"tenderInvoiceNo"];
        Configuration *configuration = [self.updateManager insertConfigurationMoc:privateContextObject];
        configuration.invoiceNo = [responseData valueForKey:@"RegisterInvNo"];
    }
}

- (void)setAppSetting:(NSDictionary *)rapidConfigSetting
{
    NSData *objectData = [[rapidConfigSetting valueForKey:@"KeyValue"] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *rapidSettingDictionary = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                  options:NSJSONReadingMutableContainers error:nil];
    [self configureRapidSettingWith:rapidSettingDictionary];
}

- (void)regConfigrationResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSMutableArray *responseArray = [self objectFromJsonString:response[@"Data"]];
            //NSLog(@"responseArray regConfigration %@",responseArray);
            
            NSMutableDictionary *responseData = [self checkforActiveDeviceInfoForStore:responseArray];
            
            BOOL isSignUpForTrial = [self isSignUpForTrial:responseArray];
            if (isSignUpForTrial) {
                if ([responseData valueForKey:@"ISDEMO"]) {
                    (self.globalDict)[@"IsSignUpForTrial"] = [responseData valueForKey:@"ISDEMO"];
                }
            }
            self.appsActvDeactvSettingarrayWithStore=[responseArray mutableCopy];
            
            self.appsActvDeactvSettingarrayWithStore = [self replacekeyValuepairDetials:self.appsActvDeactvSettingarrayWithStore];
            
            if([[response valueForKey:@"IsError"] intValue] == 1)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isFirstTimeActivate = true;
                    [self regScreen];
                });
            }
            else if([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.isFirstTimeActivate = false;
                if ([responseData valueForKey:@"BranchId"]) {
                    (self.globalDict)[@"BranchID"] = [responseData valueForKey:@"BranchId"];
                }
                if ([responseData valueForKey:@"RegisterId"]) {
                    (self.globalDict)[@"RegisterId"] = [responseData valueForKey:@"RegisterId"];
                }
                if ([responseData valueForKey:@"ZRequired"]) {
                    (self.globalDict)[@"ZRequired"] = [responseData valueForKey:@"ZRequired"];
                }
                if ([responseData valueForKey:@"ZId"]) {
                    (self.globalDict)[@"ZId"] = [responseData valueForKey:@"ZId"];
                }
                if ([responseData valueForKey:@"RegisterName"]) {
                    (self.globalDict)[@"RegisterName"] = [responseData valueForKey:@"RegisterName"];
                }
                if ([responseData valueForKey:@"DBName"]) {
                    (self.globalDict)[@"DBName"] = [responseData valueForKey:@"DBName"];
                }
                if ([responseData valueForKey:@"TokenId"]) {
                    (self.globalDict)[@"TokenId"] = [responseData valueForKey:@"TokenId"];
                }
                NSMutableArray *arryBranch=[responseData valueForKey:@"Branch_MArray"];
                if(arryBranch.count>0)
                {
                    NSMutableArray *responseBranchArray=[arryBranch mutableCopy];
                    NSMutableDictionary *dictBranchInfo = responseBranchArray.firstObject;
                    dictBranchInfo[@"HelpMessage1"] = [responseData valueForKey:@"HelpMessage1"];
                    dictBranchInfo[@"HelpMessage2"] = [responseData valueForKey:@"HelpMessage2"];
                    dictBranchInfo[@"HelpMessage3"] = [responseData valueForKey:@"HelpMessage3"];
                    dictBranchInfo[@"SupportEmail"] = [responseData valueForKey:@"SupportEmail"];
                    
                    (self.globalDict)[@"BranchInfo"] = dictBranchInfo;
                }
                
                self.appsActvDeactvSettingarray = [responseData valueForKey:@"objDeviceInfo"];
                
                BOOL isRcrGasactive = [self isRcrGasActiveLog];
                if (isRcrGasactive)
                {
                
                    DebugLogManager * objLogManager = [DebugLogManager sharedDebugLogManager];
                    NSFetchedResultsController * objects = objLogManager.logPetroRC;
                    if (!objects) {
                        objects = objLogManager.logPetroRC;
                    }
                    NSArray * petroLogs = objects.fetchedObjects;
                    for (PetroLog * petroLog in petroLogs) {
                        [objLogManager addOperationInQueue:petroLog];
                    }
                }
                
                if (self.appsActvDeactvSettingarray.count > 0) {
                    NSString *userEmailId = [NSString stringWithFormat:@"%@",(self.globalDict)[@"BranchInfo"][@"Email"]];
                    NSString *userId = [NSString stringWithFormat:@"%@",self.appsActvDeactvSettingarray.firstObject[@"ConfigurationId"]];
                    
                    if (userEmailId != nil && userEmailId.length > 0 && userId != nil && userId.length > 0) {
                        [Intercom reset];
                        [Intercom setHMAC:[self GetHMACFromUserID:userEmailId] data:userEmailId];
                        dispatch_after(1.0, dispatch_get_main_queue(), ^ {
                            [Intercom registerUserWithUserId:userId email:userEmailId];
                            NSDictionary *userInfo=@{
                                                     @"name":[self.appsActvDeactvSettingarray.firstObject valueForKey:@"STORENAME"],
                                                     @"id":self.appsActvDeactvSettingarray.firstObject[@"ConfigurationId"]
                                                     };
                            [Intercom updateUserWithAttributes:@{
                                                                 @"name" : [[self.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"],
                                                                 @"company" : userInfo
                                                                 }];
                        });
                    }
                }
                
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                
                //   [self setInvoiceNoFromDict:responseData privateContextObject:privateContextObject];
                
                NSString *storeInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
                if (storeInvoiceNo)
                {
                    NSString *strInvpr = [responseData valueForKey:@"InvPrefix"];
                    if(strInvpr==nil)
                    {
                        dispatch_after(1.0, dispatch_get_main_queue(), ^ {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Invoice prefix for this register is not received from the server. Please contact manager." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alert show];
                            
                        });
                        return;
                    }
                    Configuration *configuration = [self.updateManager insertConfigurationMoc:privateContextObject ];
                    configuration.regPrefixNo = [responseData valueForKey:@"InvPrefix"];
                }
                else
                {
                    Configuration *configuration = [self.updateManager insertConfigurationMoc:privateContextObject];
                    if(configuration.invoiceNo != 0)
                    {
                        [Keychain saveString:configuration.invoiceNo.stringValue forKey:@"tenderInvoiceNo"];
                        configuration.regPrefixNo = [responseData valueForKey:@"InvPrefix"];
                    }
                    else
                    {
                        [Keychain saveString:@"0" forKey:@"tenderInvoiceNo"];
                        configuration.regPrefixNo = [responseData valueForKey:@"InvPrefix"];
                    }
                }
                
                [self configureDatabaseWithDeviceConfiguration:privateContextObject responseData:responseData responseArray:responseArray];
                
                if (![[responseData valueForKey:@"BranchConfigurationSetting"] isKindOfClass:[NSNull class]])
                {
                    NSDictionary *rapidConfigSetting = [[responseData valueForKey:@"BranchConfigurationSetting"] firstObject];
                    [self setAppSetting:rapidConfigSetting];
                }
                // for VMS Vendor
                
                if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    
                    NSEntityDescription *entity = [NSEntityDescription
                                                   entityForName:@"Vendor_Item" inManagedObjectContext:self.managedObjectContext];
                    fetchRequest.entity = entity;
                    NSArray *arryTemp = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
                    if (arryTemp.count == 0)
                    {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ModuleCode==%@ && IsActive ==%@ && MacAdd==%@",@"VMS",@(1),(self.globalDict)[@"DeviceId"]];
                        NSArray *arrayCount = [self.appsActvDeactvSettingarray filteredArrayUsingPredicate:predicate];
                        if(arrayCount.count>0)
                        {
                            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                            HConfigurationVC *objStoreVC = [storyBoard instantiateViewControllerWithIdentifier:@"HConfigurationVC"];
                            objStoreVC.dictBranchInfo=[arryBranch.firstObject mutableCopy]
                            ;
                            [objStoreVC.dictBranchInfo removeObjectForKey:@"objmodule"];
                            [[NSUserDefaults standardUserDefaults]setObject:objStoreVC.dictBranchInfo forKey:@"HStoreInfo"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [self.appDelegate.navigationController pushViewController:objStoreVC animated:YES];
                        }
                        else{
                            [self getItemDataFirstTime];
                        }
                    }
                    else{
                        [self getItemDataFirstTime];
                    }
                    
                }
                else{
                    [self getItemDataFirstTime];
                }
                
                //[self getItemDataFirstTime];
                [self sendOfflineTenderPaymentDataToServer];
                //[self uploadLastTenderState];
            }
            else
            {
                self.isFirstTimeActivate = false;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self loginOffline];
                });

            }
        }
    }
    else
    {
        self.isFirstTimeActivate = false;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loginOffline];
        });
    }
    //[self bridgepayGasCreditCardProcess];
}

-(BOOL)isRcrGasActiveLog
{
    BOOL isRcrActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@",@"RCRGAS"];
    NSArray *rcrArray = [self.appsActvDeactvSettingarray filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}

-(void)bridgepayGasCreditCardProcess{
    
    RapidWebServiceConnection *bridgepayGasCreditCardProcess = [[RapidWebServiceConnection alloc]init];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict[@"CardNumber"] = @"4012000033330026";
    dict[@"ExpDate"] = @"1220";
    dict[@"NameOnCard"] = @"";
    dict[@"Amount"] = @"0.10";
    dict[@"ZipCode"] = @"205219000";
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            
            [self bridgepayGasCreditCardProcessResponse:response error:error];
        });
    };
    bridgepayGasCreditCardProcess = [bridgepayGasCreditCardProcess initWithRequest:KURL_PAYMENT actionName:WSM_BRIDGEPAY_GAS_CREDIT_CARD_PROCESS params:dict completionHandler:completionHandler];
    
}

- (void)bridgepayGasCreditCardProcessResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSMutableArray *responseArray = [self objectFromJsonString:response[@"Data"]];
            NSLog(@"responseArray regConfigration %@",responseArray);
        }
    }
}



- (BOOL)isSignUpForTrial:(NSMutableArray *)array
{
    BOOL isSignUpForTrial = FALSE;
    if (array != nil && array.count > 0 && [[array.firstObject valueForKey:@"ISDEMO"]integerValue] == 1) {
        isSignUpForTrial = TRUE;
    }
    return isSignUpForTrial;
}

-(BOOL)isVendorActive{
    
    BOOL vItem=NO;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Vendor_Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (arryTemp.count == 0)
    {
        vItem=NO;
    }
    else
    {
        vItem=YES;
    }
    return  vItem;
    
}

-(NSMutableDictionary *)checkforActiveDeviceInfoForStore:(NSMutableArray *)aStore{
    
    NSMutableDictionary *dictActiveStore;
    
    for(int i=0;i<aStore.count;i++){
        
        NSMutableDictionary *dictStore = [aStore[i]mutableCopy];
        
        NSMutableArray *arrayDeviceInfo = [dictStore valueForKey:@"objDeviceInfo"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"MacAdd = %@",[self.globalDict valueForKey:@"DeviceId"]];
        
        NSArray *arrayTemp = [arrayDeviceInfo filteredArrayUsingPredicate:predicate];
        if(arrayTemp.count>0)
        {
            dictActiveStore = dictStore;

        }
        else{
            dictStore[@"DisableActivation"] = @"";
            aStore[i] = dictStore;
        }
    }

    return dictActiveStore;
}

-(NSMutableArray *)replacekeyValuepairDetials:(NSMutableArray *)pArray{
    
    for(int i=0;i<pArray.count;i++){
        
        NSMutableDictionary *dictStore = [pArray[i]mutableCopy];
        
        dictStore[@"objBranchInfo"] = [dictStore valueForKey:@"Branch_MArray"];
        [dictStore removeObjectForKey:@"Branch_MArray"];
        pArray[i] = dictStore;
    }
    return pArray;
    
}

//-(void)uploadLastTenderState {
//   // [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"TenderStateBeforeTermination"];
//    //[[NSUserDefaults standardUserDefaults] synchronize];
//
//    if([[NSUserDefaults standardUserDefaults]valueForKey:@"TenderStateBeforeTermination"])
//    {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resonseSendBillData:) name:@"UploadLastTenderState" object:nil];
//        
//        NSString *strBillInfo = [[NSUserDefaults standardUserDefaults]valueForKey:@"TenderStateBeforeTermination"];
//        
//        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
//        [param setObject:strBillInfo forKey:@"receiptarray"];
//        
//        [param setObject:[self.globalDict objectForKey:@"RegisterId"] forKey:@"registerid"];
//        
//        
//        [param setObject:[self.globalDict objectForKey:@"BranchID"] forKey:@"BranchId"];
//        
//        
//        [param setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"BillDataDateTime"] forKey:@"currentDatetime"];
//        
//        
//        self.missedTenderConnnecation = [self.missedTenderConnnecation initWithJSONKey:nil JSONValues:param actionName:@"InsertMissedInvoiceDetail" URL:KURL NotificationName:@"UploadLastTenderState"];
//    }
//
//}
//
//- (void)resonseSendBillData:(NSNotification *)notification {
//    
//    if(notification.object!=nil){
//        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"TenderStateBeforeTermination"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    
// 
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadLastTenderState" object:nil];
//    
//}

//- (NSMutableArray *) getDeviceInfo (NSMutableDictionary *) dictDeviceInfo
//{
//    NSMutableArray *deviceInfoData = [[NSMutableArray alloc] init];
//
//
//            [tmpSup removeObjectForKey:@"Checked"];
//            [tmpSup removeObjectForKey:@"CompanyName"];
//            [tmpSup removeObjectForKey:@"ContactNo"];
//            [tmpSup removeObjectForKey:@"ItemCode"];
//            [tmpSup removeObjectForKey:@"SupplierName"];
//            [itemSupplierData addObject:tmpSup];
//
//	return deviceInfoData;
//}

-(void)regScreen
{
    UserActivationViewController *objUser;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        objUser = [[UserActivationViewController alloc] initWithNibName:@"UserActivationViewController" bundle:nil];
        objUser.bFromDashborad=NO;
    }
    else
    {
        objUser = [[UserActivationViewController alloc] initWithNibName:@"UserActivationVC_iPhone" bundle:nil];
    }
    [self.appDelegate.navigationController pushViewController:objUser animated:YES];
}

- (void)postConfigurationStatus:(int)statusCode message:(NSString *)errorMsg
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kConfigurationMessageNotification object:nil userInfo:@{kConfigurationMessageKey:errorMsg, kConfigurationStatusCodeKey:@(statusCode)}];
}

- (void)postConfigurationDownloadStatus:(int)statusCode message:(NSString *)errorMsg
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kConfigurationDownloadStatusMessageNotification object:nil userInfo:@{kConfigurationMessageKey:errorMsg, kConfigurationStatusCodeKey:@(statusCode)}];
}



//hiten
- (void)stepWisePostConfigurationStatus:(int)statusCode message:(NSString *)errorMsg duration:(NSDate *)pdate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStepWiseConfigurationMessageNotification object:nil userInfo:@{kStepWiseConfigurationMessageKey:errorMsg, kStepWiseConfigurationStatusCodeKey:@(statusCode),kStepWiseConfigurationDuration:pdate}];
    
}

- (NSString *)ludTextFromDate:(NSDate *)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//    [formatter setTimeZone:sourceTimeZone];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString* strDate = [formatter stringFromDate:date];
    return strDate;
}

- (NSString *)ludForTimeInterval:(NSTimeInterval)timeInterVal
{
    NSString *strDate;
    NSManagedObjectContext *moc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    Configuration *configuration = [UpdateManager getConfigurationMoc:moc];
    NSDate *configDate = configuration.lastUpdateDate;
    if (configDate == nil) {
        configDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDate *minusOneHr = [configDate dateByAddingTimeInterval:-timeInterVal];

    strDate = [self ludTextFromDate:minusOneHr];
    return strDate;
}
- (NSString *)ludForPetroTimeInterval:(NSTimeInterval)timeInterVal
{
    NSString *strDate;
    NSManagedObjectContext *moc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    Configuration *configuration = [UpdateManager getConfigurationMoc:moc];
    NSDate *configDate = configuration.lastPetroUpdateDate;
    if (configDate == nil) {
        strDate = @"";
    }
    else{
        NSDate *minusOneHr = [configDate dateByAddingTimeInterval:-timeInterVal];
        
        strDate = [self ludTextFromDate:minusOneHr];
    }
    
    return strDate;
}

- (NSString *)ludForTimeIntervalForMasterSync:(NSTimeInterval)timeInterVal
{
    NSString *strDate;
    NSManagedObjectContext *moc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    Configuration *configuration = [UpdateManager getConfigurationMoc:moc];
    NSDate *configDate = configuration.masterUpdateDate;
    if (configDate == nil) {
        configDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDate *minusOneHr = [configDate dateByAddingTimeInterval:-timeInterVal];

    strDate = [self ludTextFromDate:minusOneHr];
    return strDate;
}

- (NSString *)ludForTimeIntervalForMasterUpdate:(NSTimeInterval)timeInterVal
{
    NSString *strDate;
    NSManagedObjectContext *moc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    Configuration *configuration = [UpdateManager getConfigurationMoc:moc];
    NSDate *configDate = configuration.masterUpdateDate;
    [moc reset];
    if (configDate == nil) {
        configDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDate *minusOneHr = [configDate dateByAddingTimeInterval:-timeInterVal];

    strDate = [self ludTextFromDate:minusOneHr];
    return strDate;
}


- (void)startItemUpdate:(NSTimeInterval)timeInterVal
{
    [self launchUpdateProgressVC];

    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:[self.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];
    self.isFirstTimeDataLoad = NO;
    NSString *strDate;

    strDate = [self ludForTimeInterval:timeInterVal];
    [itemparam setValue:strDate forKey:@"datetime"];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseItemUpdateResponse:response error:error];
        });
    };
    self.itemUpdateConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_ITEM_UPDATE_LIST params:itemparam asyncCompletionHandler:asyncCompletionHandler];

}


-(void)responseItemUpdateResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_queue_create("responseItemUpdate", NULL), ^{
        [self _responseItemUpdateResponse:response];
    });
}

-(void)_responseItemUpdateResponse:(id)response
{
    if(response!= nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            
            if (responseDictionary!= nil)
            {
                [self.updateManager updateObjectsFromResponseDictionary:responseDictionary];
                [self dbVersionUpdate];
            }
        }
    }
    
    [self masterTableCall];
    // [self getMasterDetail];
}

- (void)launchUpdateProgressVC
{
    if(!self.isSynchronizing)
    {
        UIViewController *loadingView = self.appDelegate.navigationController.viewControllers.firstObject;
        
        if([loadingView isKindOfClass:[LoadingViewController class]]){
            
            return;
        }
        loadingView = self.appDelegate.navigationController.viewControllers.lastObject;
        
        if([loadingView isKindOfClass:[LoadingViewController class]]){
            
            return;
        }
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                LoadingViewController *objLoadingScreen = [[LoadingViewController alloc] initWithNibName:@"LoadingVC_iPhone" bundle:nil];
                objLoadingScreen.startingTime=[NSDate date];
                [self.appDelegate.navigationController pushViewController:objLoadingScreen animated:TRUE];
            });
        }
        else
        {
            LoadingViewController *objLoadingScreen = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
            objLoadingScreen.startingTime=[NSDate date];
            [self.appDelegate.navigationController pushViewController:objLoadingScreen animated:TRUE];
        }
    }
}

- (void)configureReceiptMasterData
{
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    
    [itemparam setValue:[self.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];

    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self receiptMasterResponse:response error:error];
    };
    
    self.receiptMasterConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_GET_RECEIPT_MASTER params:itemparam asyncCompletionHandler:asyncCompletionHandler];
}

-(void)receiptMasterResponse:(id)response error:(NSError *)error
{
    if(response!= nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]){
            if([[response valueForKey:@"IsError"] integerValue] == 0) {
                NSMutableArray *responseArray = [self objectFromJsonString:[response valueForKey:@"Data"]];
                for (NSDictionary *responseDictionary in responseArray)
                {
                    if (![[responseDictionary valueForKey:@"ReceiptType"] isKindOfClass:[NSNull class]] && [[responseDictionary valueForKey:@"ReceiptType"] isEqualToString:@"Invoice"])
                    {
                        NSMutableDictionary *receiptMasterDictionary = [[NSMutableDictionary alloc] init];
                        
                        receiptMasterDictionary[@"StoreName"] = [responseDictionary valueForKey:@"StoreName"];
                        receiptMasterDictionary[@"Address"] = [responseDictionary valueForKey:@"Address"];
                        receiptMasterDictionary[@"Email"] = [responseDictionary valueForKey:@"Email"];
                        receiptMasterDictionary[@"PhoneNo"] = [responseDictionary valueForKey:@"PhoneNo"];
                        receiptMasterDictionary[@"ThanksNote"] = [responseDictionary valueForKey:@"ThanksNote"];
                        (self.globalDict)[@"ReceiptMasterInfo"] = receiptMasterDictionary;
                        
                    }
                    else if(![[responseDictionary valueForKey:@"ReceiptType"] isKindOfClass:[NSNull class]] && [[responseDictionary valueForKey:@"ReceiptType"] isEqualToString:@"GiftInvoice"])
                    {
                        NSMutableDictionary *receiptMasterDictionary = [[NSMutableDictionary alloc] init];
                        
                        receiptMasterDictionary[@"StoreName"] = [responseDictionary valueForKey:@"StoreName"];
                        receiptMasterDictionary[@"Address"] = [responseDictionary valueForKey:@"Address"];
                        receiptMasterDictionary[@"Email"] = [responseDictionary valueForKey:@"Email"];
                        receiptMasterDictionary[@"PhoneNo"] = [responseDictionary valueForKey:@"PhoneNo"];
                        receiptMasterDictionary[@"ThanksNote"] = [responseDictionary valueForKey:@"ThanksNote"];
                        (self.globalDict)[@"GiftCardMasterInfo"] = receiptMasterDictionary;
                        
                    }
                }
            }
        }
        else{
            if ((self.globalDict)[@"ReceiptMasterInfo"]) {
                [self.globalDict removeObjectForKey:@"ReceiptMasterInfo"];
            }
        }
    }
}


- (void)defaultItemMethod
{
    [self configureReceiptMasterData];
//     self.isFirstTimeActivate = true;
    
    if([self checkVendorModuleIsActive]){
        self.steps=8;
    }
    else{
        self.steps=6;
    }
    
    // REVISIT
    // [self showActivityViewer:self.appDelegate.navigationController.topViewController.view];
    
    //    LoadingViewController *objLoadingScreen = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    //    [self.appDelegate.navigationController pushViewController:objLoadingScreen animated:TRUE];
    
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    
#ifdef USE_LOCAL_SERVICE
    [itemparam setValue:@"1" forKey:@"BranchId"];
    [itemparam setValue:@"" forKey:@"Code"];
    [itemparam setValue:@"" forKey:@"Type"];
#else
    [itemparam setValue:[self.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:@"" forKey:@"Code"];
    [itemparam setValue:@"" forKey:@"Type"];
#endif
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (arryTemp.count == 0)
    {
        self.isFirstTimeDataLoad = YES;
        self.isFirstDashboardIcon = YES;
        self.isFirstShortCutIcon = YES;
        [self launchUpdateProgressVC];
        
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ConfigurationStep"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //        self.isFirstDashboardIcon = YES;
        //        self.isFirstShortCutIcon = YES;
        NSString *strCurrentStep = [[NSUserDefaults standardUserDefaults] valueForKey:@"ConfigurationStep"];
        
        
        self.currentStep = strCurrentStep.integerValue;
        switch (strCurrentStep.integerValue) {
            case 0:
            {
                [self phase1Webservice];
                
            }
                break;
            case 2:
                [self phase2Webservice];
                break;
            case 4:
                [self phase3Webservice];
                break;
            case 6:
            {
                if([self checkVendorModuleIsActive]){
                    [self phase4Webservice];
                }
            }
                break;
                
            default:
            {
                [self phase1Webservice];
            }
                break;
        }
    }
    else
    {
        BOOL dbUpdateRequired = [self dbUpdateRequired];
        if(dbUpdateRequired)
        {
            [self updateDbForVersion];
            [self getItemDataFirstTime];
        }
        else
        {
            //[self launchRmsDashBoard];
            [self startItemUpdate:0];
        }
    }
}

-(void) getItemDataFirstTime
{
    [self defaultItemMethod];
}


-(void)phase1Response:(id)response error:(NSError *)error
{
    // [self stepWisePostConfigurationStatus:0 message:@"1" duration:[NSDate date]];
    self.currentStep=2;
    
    if(response!= nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]){
            if([[response valueForKey:@"IsError"]integerValue]==0){
                
                NSString *progressMessage2 = [NSString stringWithFormat:@"Configuration in progress: Step 2 of %ld ...",(long)self.steps];
                [self postConfigurationStatus:0 message:progressMessage2];
                // NSString *errorMsg = @"Item(s) data configuration in progress...";
                //[self postConfigurationStatus:0 message:errorMsg];
                NSDictionary *responseDictionary = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                
                [self.updateManager insertPhase1:responseDictionary];
                
                [self phase2Webservice];
            
            }
            else{
                [self errorMessage:1];
            }
            
        }
    }
    else{
        
        [self errorMessage:1];
    }
}

-(void)phase2Response:(id)response error:(NSError *)error
{
    //[self stepWisePostConfigurationStatus:0 message:@"1" duration:[NSDate date]];
    self.currentStep=4;
    if(response!= nil)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if([[response valueForKey:@"IsError"]integerValue]==0){
                
                NSString *progressMessage4 = [NSString stringWithFormat:@"Configuration in progress: Step 4 of %ld ...",(long)self.steps];
                [self postConfigurationStatus:0 message:progressMessage4];
                
                NSDictionary *responseDictionary = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                
                [self.updateManager insertPhase2:responseDictionary];
                
                
                [self phase3Webservice];
                
            }
            else{
                [self errorMessage:3];
            }
            
        }
        else{
            
            [self errorMessage:3];
        }
    }
}

-(void)phase3Response:(id)response error:(NSError *)error
{
   // [self stepWisePostConfigurationStatus:0 message:@"1" duration:[NSDate date]];
    self.currentStep=6;
    if(response!= nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {

         if([[response valueForKey:@"IsError"]integerValue]==0){
        
            NSString *progressMessage6  = [NSString stringWithFormat:@"Configuration in progress: Step 6 of %ld ...",(long)self.steps];
            [self postConfigurationStatus:0 message:progressMessage6];
            
            //NSString *errorMsg = @"Item(s) data configuration in progress...";
            //[self postConfigurationStatus:0 message:errorMsg];
            NSDictionary *responseDictionary = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            [self.updateManager insertPhase3:responseDictionary];
            
            if([self checkVendorModuleIsActive]){
            
                
                [self phase4Webservice];

            }
            else{
            
                [self insertDidFinish];
            
                if(!self.isSynchronizing) {
                    [self dbVersionUpdate];
                }
            }
         }
         else{
             [self errorMessage:5];
         }
    }
    else{
        
        [self errorMessage:5];
    }
    }
}

-(void)phase4Response:(id)response error:(NSError *)error
{
    // [self stepWisePostConfigurationStatus:0 message:@"1" duration:[NSDate date]];
    self.currentStep=8;
    if(response!= nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if([[response valueForKey:@"IsError"]integerValue]==0){
                
                //NSString *errorMsg = @"Item(s) data configuration in progress...";
                // [self postConfigurationStatus:0 message:errorMsg];
                
                NSString *progressMessage8 = [NSString stringWithFormat:@"Configuration in progress: Step 8 of %ld ...",(long)self.steps];
                [self postConfigurationStatus:0 message:progressMessage8];
                
                NSMutableArray *vendorItem = [self objectFromJsonString:[response valueForKey:@"Data"]];
                [self.updateManager insertPhase4:vendorItem];
                
                [self insertDidFinish];
                
                if(!self.isSynchronizing) {
                    [self dbVersionUpdate];
                }
            }
            else{
                [self errorMessage:7];
            }
            
        }
    }
    else{
        
        [self errorMessage:7];
    }

}


-(void)phase1Webservice{
    
    self.currentStep=1;
    
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    
#ifdef USE_LOCAL_SERVICE
    [itemparam setValue:@"1" forKey:@"BranchId"];
    [itemparam setValue:@"" forKey:@"Code"];
    [itemparam setValue:@"" forKey:@"Type"];
#else
    [itemparam setValue:[self.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:@"" forKey:@"Code"];
    [itemparam setValue:@"" forKey:@"Type"];
#endif
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *progressMessage1 = [NSString stringWithFormat:@"Configuration in progress: Step 1 of %ld ...",(long)self.steps];
        [self postConfigurationStatus:0 message:progressMessage1];
    });
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self phase1Response:response error:error];
    };
    startDate = nil;
    isT0 = false;
    ProgressHandler progressHandler = [self phaseProgressHandler];
    self.wsPhase1 = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_PHASE_1 params:itemparam asyncCompletionHandler:asyncCompletionHandler progressHandler:progressHandler];
}
-(void)phase2Webservice{
    
    self.currentStep=3;
    
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:[self.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:@"" forKey:@"Code"];
    [itemparam setValue:@"" forKey:@"Type"];
    
    NSString *progressMessage3 = [NSString stringWithFormat:@"Configuration in progress: Step 3 of %ld ...",(long)self.steps];
    [self postConfigurationStatus:0 message:progressMessage3];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self phase2Response:response error:error];
    };
    startDate = nil;
    isT0 = false;

    ProgressHandler progressHandler = [self phaseProgressHandler];
    
    self.wsPhase2 = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_PHASE_2 params:itemparam asyncCompletionHandler:asyncCompletionHandler progressHandler:progressHandler];

}

-(void)phase3Webservice{
    
     self.currentStep=3;

    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:[self.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:@"" forKey:@"Code"];
    [itemparam setValue:@"" forKey:@"Type"];
    
    NSString *progressMessage5 = [NSString stringWithFormat:@"Configuration in progress: Step 5 of %ld ...",(long)self.steps];
    [self postConfigurationStatus:0 message:progressMessage5];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self phase3Response:response error:error];
    };
    startDate = nil;
    isT0 = false;

    ProgressHandler progressHandler = [self phaseProgressHandler];
    
    self.wsPhase3 = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_PHASE_3 params:itemparam asyncCompletionHandler:asyncCompletionHandler progressHandler:progressHandler];

}

-(void)phase4Webservice{

    self.currentStep=4;

    NSString *progressMessage7 = [NSString stringWithFormat:@"Configuration in progress: Step 7 of %ld ...",(long)self.steps];
    [self postConfigurationStatus:0 message:progressMessage7];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:@"Hackney" forKey:@"SupplierDbName"];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self phase4Response:response error:error];
    };
    startDate = nil;
    isT0 = false;

    ProgressHandler progressHandler = [self phaseProgressHandler];
    
    self.wsPhase4 = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_PHASE_4 params:param asyncCompletionHandler:asyncCompletionHandler progressHandler:progressHandler];
  
}

-(ProgressHandler)phaseProgressHandler{
    ProgressHandler progressHandler = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            
            double progress;
            progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            
            NSString * strDownloadMessage ;
            if (totalBytesExpectedToWrite == -1) {
                if (totalBytesWritten >= 1073741824) {
                    int64_t gbWritten = totalBytesWritten/1073741824;
                    strDownloadMessage = [NSString stringWithFormat:@"%lld GB downloaded",gbWritten];
                }
                else if (totalBytesWritten >= 1048576) {
                    int64_t kbWritten = totalBytesWritten/1048576;
                    strDownloadMessage = [NSString stringWithFormat:@"%lld MB downloaded",kbWritten];
                }
                else if (totalBytesWritten >= 1024) {
                    int64_t kbWritten = totalBytesWritten/1024;
                    strDownloadMessage = [NSString stringWithFormat:@"%lld KB downloaded",kbWritten];
                }
                else {
                    strDownloadMessage = [NSString stringWithFormat:@"%lld Bytes downloaded",totalBytesWritten];
                }
            }
            else
            {
                if (!isT0) {
                    startDate = [NSDate date];
                    isT0 = YES;
                }
                NSTimeInterval t1 = [[NSDate date] timeIntervalSinceDate:startDate];
                NSTimeInterval t2 = (t1 * (totalBytesExpectedToWrite - totalBytesWritten))/totalBytesWritten;
                
                if (t2 >= 36000) {
                    t2  = t2/36000;
                    strDownloadMessage = @"It take a long Time..";
                }
                else if (t2 >= 3600) {
                    t2  = t2/3600;
                    strDownloadMessage = [NSString stringWithFormat:@"%d Hour Remaining",(int)t2];
                }
                else if (t2 >= 60) {
                    t2  = t2/60;
                    strDownloadMessage = [NSString stringWithFormat:@"%d Min Remaining",(int)t2];
                }
                else
                {
                    strDownloadMessage = [NSString stringWithFormat:@"%d Sec Remaining",(int)t2];
                }
            }
            [self postConfigurationDownloadStatus:0 message:strDownloadMessage];

        });
    };
    return progressHandler;
}

-(void)resumeConfiguration{
    
    switch (self.currentStep) {
        case 1:
        case 2:
            [self phase1Webservice];
            break;
        case 3:
        case 4:
            [self phase2Webservice];
            break;
        case 5:
        case 6:
            [self phase3Webservice];
            break;
        case 7:
        case 8:
            [self phase4Webservice];
            break;
        default:
            break;
    }
}

-(void)errorMessage:(NSInteger)intStep{
    
    if(self.isSynchronizing)
    {
        [self.synchronizeVcDelegate didSynchronizeFailed];
        self.isSynchronizing = FALSE;
    }
    else
    {
        NSString *errorMsg = [NSString stringWithFormat:@"Database configuration process failed in step %ld \n please restart the application & try again or please contact RapidRMS.",(long)intStep];
    
        [self postConfigurationStatus:1 message:errorMsg];
        //[self stepWisePostConfigurationStatus:1 message:@"-1" duration:[NSDate date]];
    }
}

-(BOOL )checkVendorModuleIsActive{
    
    BOOL isActive = NO;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Vendor_Item" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        NSArray *arryTemp = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (arryTemp.count == 0)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ModuleCode == %@ && IsActive == %@ && MacAdd == %@",@"VMS",@(1),(self.globalDict)[@"DeviceId"]];
            NSArray *arrayCount = [self.appsActvDeactvSettingarray filteredArrayUsingPredicate:predicate];
            if(arrayCount.count>0)
            {
                isActive=YES;
            }
        }
    }
    return  isActive;
}


-(void)responseItem:(NSNotification *)notification
{
    [self stepWisePostConfigurationStatus:0 message:@"1" duration:[NSDate date]];
    
    NSMutableArray *responseItemArray = notification.object;
    responseItemArray = [responseItemArray valueForKey:WSM_ITEM_LIST_RESPONSEKEY];
    if(responseItemArray!= nil)
    {
        NSString *errorMsg = @"Item(s) data configuration in progress...";
        [self postConfigurationStatus:0 message:errorMsg];
        NSDictionary *responseDictionary = [[self objectFromJsonString:[responseItemArray valueForKey:@"Data"]] firstObject];
        [self.updateManager insertObjectsFromResponseDictionary:responseDictionary];
        if(!self.isSynchronizing) {
            [self dbVersionUpdate];
        }
        [self stepWisePostConfigurationStatus:0 message:@"2" duration:[NSDate date]];
    }
    else
    {
        if(self.isSynchronizing)
        {
            [self.synchronizeVcDelegate didSynchronizeFailed];
            self.isSynchronizing = FALSE;
        }
        else
        {
            NSString *errorMsg = @"Database configuration process failed \n please restart the application & try again \n or please contact RapidRMS.";
            [self postConfigurationStatus:1 message:errorMsg];
            [self stepWisePostConfigurationStatus:1 message:@"-1" duration:[NSDate date]];
        }
    }
}




-(void)masterTableCall
{
    BOOL isContZero=FALSE;
    NSUInteger cnt=0;

    BOOL masterDbUpdateRequired = [self masterDbUpdateRequired];
    if (masterDbUpdateRequired) {
        [self updateMasterDbForVersion];
        [self getMasterDetail];
        return;
    }
    
 NSArray *masterArray = @[@"Department",@"SubDepartment",@"DepartmentTax",@"TenderPay",@"GroupMaster",@"TipPercentageMaster",@"Variation_Master",@"SizeMaster",@"SupplierMaster",@"TaxMaster"
                          ];
                          
    for (int i = 0; i<masterArray.count; i++)
    {
        cnt=[self fetchMasterObjectsCounts:masterArray[i]];
        if (cnt==0)
        {
            isContZero=TRUE;
           // [self getMasterDetail];
            break;
        }
    }

    if (isContZero==FALSE)
    {
        //[self getMasterUpdate:0];
        self.isMasterUpdate = NO;
    }
    else{
        //[self getMasterDetail];
        self.isMasterUpdate = NO;

    }
    [self getMasterDetail];
    
}

-(NSUInteger )fetchMasterObjectsCounts :(NSString *)tableName
{
    NSUInteger count=0;
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:tableName inManagedObjectContext:privateManagedObjectContext];
    fetchRequest.entity = entity;
    count = [UpdateManager countForContext:privateManagedObjectContext FetchRequest:fetchRequest];
    return count;
}
-(void)updateSupplierListFromItemTable :(NSArray *)supplierlist with:(NSString *)itemCode
{
    for(int i = 0;i<supplierlist.count;i++)
    {
        ItemSupplier *itemSupplier = nil;
        NSMutableDictionary *dictTemp = supplierlist[i];
        itemSupplier = (ItemSupplier *)[self.updateManager insertEntityWithName:@"ItemSupplier" moc:self.managedObjectContext];
        [itemSupplier updateItemSupplierFromItemTable:dictTemp withItemCode:itemCode];
    }
}

-(void)updateTaxListFromItemTable :(NSArray *)taxArray with:(NSString *)itemCode
{
    for(int k = 0;k<taxArray.count;k++)
    {
        NSMutableDictionary *dictTemp = taxArray[k];
        ItemTax *tax = nil;
        tax = (ItemTax *)[self.updateManager insertEntityWithName:@"ItemTax" moc:self.managedObjectContext];
        [tax updateitemTaxFromItemTable:dictTemp :itemCode];
    }
}

#pragma mark - Master data
-(void)getMasterDetail
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(!self.isMasterUpdate)
        {
            NSString *progressMaster = [NSString stringWithFormat:@"Master Update..."];
            [self postConfigurationStatus:0 message:progressMaster];
        }
        
    });
    
    [self connect:(self.globalDict)[@"DeviceId"]];
    
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
     [self addEventForMasterUpdateWithKey:kMasterUpdateService];
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseMasterResponse:response error:error];
        });
    };
    self.getMasterDetailConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_MASTER_LIST params:itemparam asyncCompletionHandler:asyncCompletionHandler];
    [self addPumpCartToLiveUpdateQueue:@{@"Action":@"Update"}];
}

-(void)responseMasterResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_queue_create("MasterUpdate", NULL), ^{
        [self _responseMasterResponse:response];
    });
}

-(void)_responseMasterResponse:(id)response
{
    [self stepWisePostConfigurationStatus:0 message:@"3" duration:[NSDate date]];
    
    if(response!= nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            [self deleteMaster];
            if(!self.isMasterUpdate)
            {
                NSString *errorMsg = @"Master(s) data configuration in progress...";
                [self postConfigurationStatus:0 message:errorMsg];
            }
            
            NSDictionary *masterResponseDictionary = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];

            [self.updateManager insertObjectsFromMasterResponseDictionary:masterResponseDictionary];
            if(!self.isSynchronizing)
            {
                [self masterDbVersionUpdate];
            }
            [self stepWisePostConfigurationStatus:0 message:@"4" duration:[NSDate date]];
        }}
    else
    {
        if(self.isSynchronizing)
        {
            [self.synchronizeVcDelegate didSynchronizeFailed];
            self.isSynchronizing = FALSE;
            return;
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MasterDetailResult" object:nil];
    NSDictionary *masterResponseDict = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
    
    [self.updateManager insertMasterDate:[masterResponseDict valueForKey:@"UTCTime"]];
    
    [self GetCardTypeDetail];
    
    if(!self.isSynchronizing)
    {
        //if(self.isFirstTimeDataLoad) {
        [self launchRmsDashBoard];
        //}
    }
    else
    {
        if(self.isSynchronizing)
        {
            [self.synchronizeVcDelegate didSynchronizeComplete];
            self.isSynchronizing = FALSE;
        }
    }
}

-(void)getMasterUpdate:(NSTimeInterval)timeInterVal
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
 //       NSString *progressMaster = [NSString stringWithFormat:@"Master Update..."];
       // [self postConfigurationStatus:0 message:progressMaster];
    });
    
    
    [self connect:(self.globalDict)[@"DeviceId"]];
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.globalDict)[@"BranchID"] forKey:@"BranchId"];

    NSString *strDate ;
    strDate = [self ludForTimeIntervalForMasterUpdate:timeInterVal];
    [itemparam setValue:strDate forKey:@"DateTime"];

    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseMasterUpdateResponse:response error:error];
        });
    };
    self.getMasterUpdateDetailConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_MASTER_UPDATE_LIST params:itemparam asyncCompletionHandler:asyncCompletionHandler];

}

-(void)responseMasterUpdateResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_queue_create("UpdateMasterList", NULL), ^{
        [self _responseMasterUpdateResponse:response];
    });
}

-(void)_responseMasterUpdateResponse:(id)response
{
    if(response!= nil)
    {
    if ([response isKindOfClass:[NSDictionary class]]) {

        NSDictionary *masterResponseDictionary = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
        [self.updateManager UpdateObjectsFromMasterResponseDictionary:masterResponseDictionary];
    }
    }
    NSDictionary *masterResponseDict = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
    [self.updateManager insertMasterDate:[masterResponseDict valueForKey:@"UTCTime"]];
    [self GetCardTypeDetail];
    [self launchRmsDashBoard];
    
}

#pragma mark - Syncronize Item Update Method

- (void)startSynchronizeUpdate:(NSTimeInterval) timeInterVal
{
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:[self.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];
    self.isFirstTimeDataLoad = NO;
    NSString *strDate;
    strDate = [self ludForTimeInterval:timeInterVal];
    [itemparam setValue:strDate forKey:@"datetime"];
    
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self syncUpdateResponse:response error:error];
              });
    };
    self.synchronizeWebServiceConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_ITEM_UPDATE_LIST params:itemparam asyncCompletionHandler:asyncCompletionHandler];
}

-(void)syncUpdateResponse:(id)response error:(NSError *)error
{
    if(response!= nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *responseDictionary = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            
            if (responseDictionary!= nil)
            {
                [self.updateManager updateObjectsFromResponseDictionary:responseDictionary];
                [self dbVersionUpdate];
            }
        }
    }
    [[NSNotificationCenter defaultCenter ] postNotificationName:@"CompleteSyncData" object:nil];
}

// Syncronize Updation Methods execution Over

-(void)GetCardTypeDetail
{
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseGetCardTypeDetailResponse:response error:error];
        });
    };
    self.paymentCardTypeWebserviceConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_GET_CARD_TYPE_DETAIL params:itemparam asyncCompletionHandler:asyncCompletionHandler];
}

-(void)responseGetCardTypeDetailResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_queue_create("UpdateCardTypeList", NULL), ^{
       [self _responseGetCardTypeDetailResponse:response];
    });
}

-(void)_responseGetCardTypeDetailResponse:(id)response
{
    NSLog(@"GetCardTypeDetail Response");
    if(response!= nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
               self.paymentCardTypearray = [self objectFromJsonString:[response valueForKey:@"Data"]];
                
                self.outSideCardTypearray = [self.paymentCardTypearray mutableCopy];
                
                NSPredicate *inSidePredicate = [NSPredicate predicateWithFormat:@"ServiceType like 'In-Side'"];
                self.paymentCardTypearray = [[self.paymentCardTypearray filteredArrayUsingPredicate:inSidePredicate] mutableCopy];
                
                [self.updateManager updateCreditcardCredentialWithDetail:self.paymentCardTypearray withContext:self.managedObjectContext];
            }
        }
    }
    else
    {
        CreditcardCredetnial *creditcardCredetnial = [self.updateManager fetchCreditcardCredetnialMoc:self.managedObjectContext];
        if (creditcardCredetnial != nil)
        {
            if (creditcardCredetnial.creditcardCredetnialDictionary!=nil) {
                [self.paymentCardTypearray addObject:creditcardCredetnial.creditcardCredetnialDictionary];
            }
        }
    }
}

-(void)deleteDepartment
{
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:privateManagedObjectContext];
    fetchRequest.entity = entity;
   // NSError *error;
    NSArray *arryTemp = [UpdateManager executeForContext:privateManagedObjectContext FetchRequest:fetchRequest];
    for (NSManagedObject *product in arryTemp)
    {
        [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
    }
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)deleteMaster
{
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];

    NSArray *masterArray = @[@"SizeMaster",@"SupplierMaster",@"TaxMaster",@"Department",@"DepartmentTax",@"GroupMaster",@"Mix_MatchDetail",@"SubDepartment",@"Variation_Master",@"TipPercentageMaster",@"SupplierCompany",@"SupplierRepresentative",@"DiscountMaster"];
    for (int i = 0; i<masterArray.count; i++)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:masterArray[i] inManagedObjectContext:privateManagedObjectContext];
        fetchRequest.entity = entity;
    //    NSError *error;
        NSArray *arryTemp = [UpdateManager executeForContext:privateManagedObjectContext FetchRequest:fetchRequest];
        for (NSManagedObject *product in arryTemp)
        {
            [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
        }
    }
    [UpdateManager saveContext:privateManagedObjectContext];

}

#pragma mark - LaunchViewControllers

-(void)launchRmsDashBoard {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _launchRmsDashBoard];
    });
}

-(void)_launchRmsDashBoard
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self._rimController = [RimsController sharedrimController];
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UIViewController *dashBoard = [storyBoard instantiateViewControllerWithIdentifier:@"RmsDashBoard_iPhone"];
        [self.appDelegate.navigationController pushViewController:dashBoard animated:TRUE];
    }
    else{
        DashBoardSettingVC *objSetting = [[DashBoardSettingVC alloc] initWithNibName:@"DashBoardSettingVC" bundle:nil];
        [self.appDelegate.navigationController pushViewController:objSetting animated:YES];
    }
}

- (void)launchLoginScreenWithSelectedModule:(NSString *)strSelectedModule callModule:(NSString *)strCallModule
{
    self.selectedModule = strSelectedModule;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self._rimController = [RimsController sharedrimController];
        if([strCallModule isEqualToString:@"SETTING"])
        {
            self._rimController = [RimsController sharedrimController];
            RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
            [self.appDelegate.navigationController pushViewController:loginView animated:YES];
        }
        else{

        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UIViewController *dashBoard = [storyBoard instantiateViewControllerWithIdentifier:@"RmsDashBoard_iPhone"];
        [self.appDelegate.navigationController pushViewController:dashBoard animated:TRUE];
        }
//        ViewController * loginView = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
//        [self.appDelegate.navigationController pushViewController:loginView animated:YES];
    }
    else
    {
        if([strCallModule isEqualToString:@"RCR"])
        {
            if([self.selectedModule isEqualToString:@"RCR"])
            {
                POSLoginView * loginView = [[POSLoginView alloc] initWithNibName:@"POSLoginView" bundle:nil];
                [self.appDelegate.navigationController pushViewController:loginView animated:YES];
            }
            else
            {
                UserAuthenticationVC * userAuthentication = [[UserAuthenticationVC alloc] initWithNibName:@"UserAuthenticationVC" bundle:nil];
                [self.appDelegate.navigationController pushViewController:userAuthentication animated:YES];
            }
        }
        else if([strCallModule isEqualToString:@"RIM"])
        {
            self._rimController = [RimsController sharedrimController];
            RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
            [self.appDelegate.navigationController pushViewController:loginView animated:YES];
        }
        else if([strCallModule isEqualToString:@"TVM"])
        {
            self._rimController = [RimsController sharedrimController];
            RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
            [self.appDelegate.navigationController pushViewController:loginView animated:YES];
        }
        
        else if([strCallModule isEqualToString:@"CLM"])
        {
            self._rimController = [RimsController sharedrimController];
            RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
            [self.appDelegate.navigationController pushViewController:loginView animated:YES];
        }
        else
        {
            NSLog(@"Wrong condition launch login screen");
        }
    }
}




#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.

- (NSManagedObjectContext *)privateWriterContext
{
    if (_privateWriterContext != nil) {
        return _privateWriterContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _privateWriterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateWriterContext.persistentStoreCoordinator = coordinator;
    }
    _privateWriterContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    return _privateWriterContext;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    __managedObjectContext.parentContext = self.privateWriterContext;
    
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RapidRms" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RapidRms.sqlite"];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    return __persistentStoreCoordinator;
}

- (void)saveContext
{

    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        BOOL hasChanges = managedObjectContext.hasChanges;
        @try {
            if (hasChanges && ![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
            
        }
    }
}

- (void)contextHasChanged:(NSNotification*)notification
{
    NSManagedObjectContext *changedContext = notification.object;
    // Ignore notification from other Managed Contexts
    BOOL isRmsContext = NO;
    for (NSManagedObjectContext *aContext = changedContext.parentContext; aContext != nil; aContext = aContext.parentContext) {
        if ([aContext isEqual:self.managedObjectContext]) {
            // It matched
            isRmsContext = YES;
            break;
        }
    }

    if (!isRmsContext) {
        // We are not interested in these changes
        return;
    }

    // Notification from main context itself.
    // Ignore it.
    if ([changedContext isEqual:self.managedObjectContext]) return;
    
    // This is not main thread
    if (![NSThread isMainThread]) {
        // Merge should be performed on main thread
        [self performSelectorOnMainThread:@selector(contextHasChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    // Merge changes
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    // Save changes
    [self saveContext];
}

#pragma mark - Appdelegate Methods
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
    if (self.wasDateModified == FALSE)
    {
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        Configuration *configuration = [self.updateManager insertConfigurationMoc:privateContextObject];
        configuration.lastAccessDate = [NSDate date];
        [UpdateManager saveContext:privateContextObject];
    }
    
  
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

-(BOOL)wasDateModified
{
    BOOL dateModified = FALSE;
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    Configuration *configuration = [self.updateManager insertConfigurationMoc:privateContextObject];
    if (configuration.lastAccessDate == nil) {
        return dateModified;
    }
    if ([configuration.lastAccessDate compare:[NSDate date]] == NSOrderedDescending) {
        dateModified = TRUE;
    }
    return dateModified;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

#pragma mark - Remote notification
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandle
{
    
}

//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
//{
//    NSCharacterSet *set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
//    NSString *strToken = [[[deviceToken description] componentsSeparatedByCharactersInSet:set] componentsJoinedByString: @""];
//    NSArray *arrToken = [strToken componentsSeparatedByString:@":"];
//    self.regToken = [arrToken firstObject];
//    [self.globalDict setObject:self.regToken forKey:@"TokenId"];
//    [self getRegistrationDetail];
//}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    NSMutableArray *responseData = [[userInfo objectForKey:@"ItemObject"]JSONValue];
//    NSString *str=[responseData valueForKey:@"ITEMCode"];
//    NSString *str1=[responseData valueForKey:@"ITEM_Remarks"];
//    NSString *str2=[responseData valueForKey:@"SalesPrice"];
//    NSString *message = nil;
//    id alert =[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]; //[userInfo objectForKey:@"alert"];
//    if ([alert isKindOfClass:[NSString class]])
//    {
//        message = alert;
//        
//    } else if ([alert isKindOfClass:[NSDictionary class]])
//    {
//        message =[[userInfo objectForKey:@"aps"] objectForKey:@"url"]; //[alert objectForKey:@"body"];
//    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
//    NSMutableArray *responseData = [[userInfo objectForKey:@"ItemObject"]JSONValue];
//    if(responseData.count > 0)
//    {
//        NSMutableDictionary *ItemNotificationDict = [responseData firstObject];
//        [self tenderInvoiceNotificat:ItemNotificationDict];
//    }
//    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)processForOfflineDataUpload
{
    
}


-(NSUInteger )fetchOfflineDataCountFromInvoiceTable :(NSString *)tableName
{
    NSUInteger count=0;
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:tableName inManagedObjectContext:privateManagedObjectContext];
    fetchRequest.entity = entity;
    count = [UpdateManager countForContext:privateManagedObjectContext FetchRequest:fetchRequest];
    
    return count;
}

// round decimal

- (CGFloat)roundTo2Decimals:(CGFloat)number {
    CGFloat roundedValue = number;
    roundedValue *= 100.0;
    roundedValue = round(roundedValue);
    roundedValue /= 100.0;
    return roundedValue;
}
// send Tender Payment data to server

-(void)sendOfflineTenderPaymentDataToServer
{
    self.nextIndex = 0;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.offlineManagedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *offlineDataDisplayPredicate = [NSPredicate predicateWithFormat:@"isUpload == %@",@(FALSE)];
    fetchRequest.predicate = offlineDataDisplayPredicate;
    
    self.offlineInvoiceList = [UpdateManager executeForContext:self.offlineManagedObjectContext FetchRequest:fetchRequest];
    
    if(self.offlineInvoiceList.count > 0)
    {
        [self uploadNextInvoiceData];
    }
}

- (void)uploadNextInvoiceData
{
    if(self.nextIndex >= self.offlineInvoiceList.count)
    {
        return;
    }
    
    InvoiceData_T *invoiceDataT = (self.offlineInvoiceList)[self.nextIndex];
    
    NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceMstData] firstObject];
    invoiceDetailDict[@"InvoiceItemDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceItemData] firstObject];
    invoiceDetailDict[@"InvoicePaymentDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoicePaymentData] firstObject];
    [invoiceDetail addObject:invoiceDetailDict];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init ];
    param[@"InvoiceDetail"] = invoiceDetail;
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doOfflinePaymentProcessResponse:response error:error];
        });
    };
    self.webServiceConnectionOffline = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL_INVOICE actionName:WSM_INVOICE_INSERT_LIST params:param asyncCompletionHandler:asyncCompletionHandler];

}

- (void) doOfflinePaymentProcessResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_queue_create("doAsynchOfflinePaymentProcess", NULL), ^{
        [self doAsynchOfflinePaymentProcessResponse:response];
    });
}

- (void) doAsynchOfflinePaymentProcessResponse:(id)response
{
    if (response != nil)
	{
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                InvoiceData_T *invoiceDataT = (self.offlineInvoiceList)[self.nextIndex];
                
                NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                invoiceDataT.isUpload = @(TRUE);
            //    [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                [UpdateManager saveContext:privateManagedObjectContext];
                
            }
            else  if ([[response  valueForKey:@"IsError"] intValue] == -2)
            {
                InvoiceData_T *invoiceDataT = (self.offlineInvoiceList)[self.nextIndex];
                
                NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
              //  [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                invoiceDataT.isUpload = @(TRUE);
                [UpdateManager saveContext:privateManagedObjectContext];
            }
            else
            {
                
            }
        }
    }
    self.nextIndex++;
    [self uploadNextInvoiceData];
}

-(void)cancelOfflineUploadProcess
{
    self.webServiceConnectionOffline = nil;
}

- (void)setupAudio
{
    if (self.globalSoundSetting != nil && self.globalSoundSetting.length > 0)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:self.globalSoundSetting ofType:@"wav"];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    }
}

- (void)removeAudio {
    self.audioPlayer = nil;
}

-(void)playButtonSound
{
    if (self.audioPlayer)
    {
        [self.audioPlayer play];
    }
}

#pragma mark - UpdateDataBase

-(BOOL)dbUpdateRequired
{
    // read key - RmsDbVersion from user default
    
    float dbVersion = [[[NSUserDefaults standardUserDefaults] valueForKey:@"RmsDbVersion"] floatValue ];
    
    float dbCheck = CURRENT_DB_VERSION - dbVersion;
   
    // if value is not CURRENT_DB_VERSION call updateDbForVersion
    if(fabsl(dbCheck) > 0.01)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)deleteDatabaseForBuildUpdate:(NSString *)entityName
{
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        NSError *deleteError = nil;
        [self.persistentStoreCoordinator executeRequest:delete withContext:privateManagedObjectContext error:&deleteError];
    }
    else{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:entityName inManagedObjectContext:privateManagedObjectContext];
        fetchRequest.entity = entity;
        
        NSArray *arryTemp = [UpdateManager executeForContext:privateManagedObjectContext FetchRequest:fetchRequest];
        for (NSManagedObject *product in arryTemp)
        {
            [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
        }
    }
    [UpdateManager saveContext:privateManagedObjectContext];
}
- (void)deletePetroDatabaseForBuildUpdate:(NSString *)entityName
{
//    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.rapidPetroPos.petroMOC];
//    
//    if ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0) {
//        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
//        NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
//        NSError *deleteError = nil;
//        [self.persistentStoreCoordinator executeRequest:delete withContext:privateManagedObjectContext error:&deleteError];
//    }
//    else{
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription
//                                       entityForName:entityName inManagedObjectContext:privateManagedObjectContext];
//        fetchRequest.entity = entity;
//        
//        NSArray *arryTemp = [UpdateManager executeForContext:privateManagedObjectContext FetchRequest:fetchRequest];
//        for (NSManagedObject *product in arryTemp)
//        {
//            [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
//        }
//    }
//    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)updateDbForVersion // DELETE ALL ITEM FROM THE DATABASE
{
    NSArray *ItemsDataArray = @[@"Item",@"BarCodeSearch",@"Configuration",@"CredentialInfo",@"CreditcardCredetnial",@"Department",@"DepartmentTax",@"Discount_M",@"Discount_Primary_MD",@"Discount_Secondary_MD",@"DiscountMaster",@"FuelPump",@"GroupMaster",@"HoldInvoice",@"InvoiceData_T",@"Item_Discount_MD",@"Item_Discount_MD2",@"Item_Price_MD",@"ItemBarCode_Md",@"ItemInventoryCount",@"ItemInventoryCountSession",@"ItemInventoryReconcileCount",@"ItemSupplier",@"ItemTag",@"ItemTax",@"ItemTicket_MD",@"ItemVariation_M",@"ItemVariation_Md",@"KitchenPrinter",@"LastInvoiceData",@"ManualPOSession",@"ManualReceivedItem",@"Mix_MatchDetail",@"ModifierPrice",@"Modifire_M",@"ModifireList_M",@"ModuleInfo",@"NoSale",@"RestaurantItem",@"RestaurantOrder",@"RoleInfo",@"ShiftDetail",@"SizeMaster",@"SubDepartment",@"SupplierCompany",@"SupplierMaster",@"SupplierRepresentative",@"TaxMaster",@"TenderPay",@"TipPercentageMaster",@"UnitConversion",@"Variation_Master",@"Vendor_Item",@"VPurchaseOrder",@"VPurchaseOrderItem",@"WeightScaleUnit"];
//    ,@"RegisterInfo",@"BranchInfo",@"UserInfo",@"RightInfo" it configure in active deactive modual
    
    for (int i = 0; i<ItemsDataArray.count; i++)
    {
        NSString *entityName = ItemsDataArray[i];
        [self deleteDatabaseForBuildUpdate:entityName];
    }
    
    NSArray *PetroDataArray = @[@"FuelPump",@"FuelTank",@"FuelType",@"GasStation",@"PayMode",@"PumpCart",@"PumpCartInvoiceData",@"ServiceType"];
//    if (!self.rapidPetroPos) {
//        self.rapidPetroPos = [RapidPetroPOS createInstance];
//    }
    for (int i = 0; i<PetroDataArray.count; i++)
    {
        NSString *entityName = PetroDataArray[i];
        [self deletePetroDatabaseForBuildUpdate:entityName];
    }
}

-(void)dbVersionUpdate
{
    // set key - RmsDbVersion in user default to CURRENT_DB_VERSION
    [[NSUserDefaults standardUserDefaults] setObject:@(CURRENT_DB_VERSION) forKey:@"RmsDbVersion"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)dbVersionUpdateGas
{
    // set key - RmsDbVersion in user default to CURRENT_DB_VERSION_GAS
    [[NSUserDefaults standardUserDefaults] setObject:@(CURRENT_DB_VERSION_GAS) forKey:@"RmsDbVersionGas"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

// For Master DB
-(BOOL)masterDbUpdateRequired
{
    float dbVersion = [[[NSUserDefaults standardUserDefaults] valueForKey:@"masterRmsDbVersion"] floatValue ];
    // if value is not CURRENT_DB_VERSION call updateDbForVersion
    float dbCheck = CURRENT_DB_VERSION - dbVersion;
    
    if(fabsl(dbCheck) > 0.01)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)updateMasterDbForVersion
{
    [self deleteMaster];
    [self masterDbVersionUpdate];
}

-(void)masterDbVersionUpdate
{
    // set key - RmsMasterDbVersion in user default to CURRENT_DB_VERSION
    [[NSUserDefaults standardUserDefaults] setObject:@(CURRENT_DB_VERSION) forKey:@"masterRmsDbVersion"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - UpdateDelegate methods
- (void)insertDidFinish {
    [self getMasterDetail];
}


#pragma mark - Update UserInfo methods
-(void)updateUserInfoWithDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init ];
    [param setValue:[self.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];
    [param setValue:[dictionary valueForKey:@"Code"] forKey:@"UserId"];
    
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseForUpdateUserInfoResponse:response error:error];
        });
    };
    self.userInfoWebserviceConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_USER_DETAILS params:param asyncCompletionHandler:asyncCompletionHandler];
}

-(void)responseForUpdateUserInfoResponse:(id)response error:(NSError *)error
{
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            response = [response valueForKey:@"UserDetailsResult"];
            
            NSMutableArray *responseArray = [self objectFromJsonString:response[@"Data"]];
            NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
            NSArray *userInfoArray = [[responseArray.firstObject valueForKey:@"UserInfo"] valueForKey:@"UserInfo"];
            for (NSDictionary *userInfoDictionary in userInfoArray.firstObject) {
                NSNumber *userId = [userInfoDictionary valueForKey:@"UserId"];
                [self.updateManager deleteDetailOfUserInfoWithUserId:userId withContext:privateContextObject];
            }
            NSDictionary *userInfo = [responseArray.firstObject valueForKey:@"UserInfo"];
            [self.updateManager updateDetailWithUserInfo:userInfo withmoc:privateContextObject];
            [UpdateManager saveContext:privateContextObject];
        }
    }
}



//Hiten


#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return _xmppRosterStorage.mainThreadManagedObjectContext;
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return _xmppCapabilitiesStorage.mainThreadManagedObjectContext;
}
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
	NSAssert(_xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the _xmppStream, such as modules/extensions and delegates.
    
	_xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		//_xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	_xmppReconnect = [[XMPPReconnect alloc] init];
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	_xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	_xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	_xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];
	
	_xmppRoster.autoFetchRoster = YES;
	_xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	_xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	_xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	_xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:_xmppCapabilitiesStorage];
    
    _xmppCapabilities.autoFetchHashedCapabilities = YES;
    _xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[_xmppReconnect         activate:_xmppStream];
	[_xmppRoster            activate:_xmppStream];
	[_xmppvCardTempModule   activate:_xmppStream];
	[_xmppvCardAvatarModule activate:_xmppStream];
	[_xmppCapabilities      activate:_xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    //	[_xmppStream setHostName:@"talk.google.com"];
    //	[_xmppStream setHostPort:5222];
	
    
	// You may need to alter these settings depending on the server you're connecting to
	customCertEvaluation = YES;
    
}

- (void)teardownStream
{
	[_xmppStream removeDelegate:self];
	[_xmppRoster removeDelegate:self];
	
	[_xmppReconnect         deactivate];
	[_xmppRoster            deactivate];
	[_xmppvCardTempModule   deactivate];
	[_xmppvCardAvatarModule deactivate];
	[_xmppCapabilities      deactivate];
	
	[_xmppStream disconnect];
	
	_xmppStream = nil;
	_xmppReconnect = nil;
    _xmppRoster = nil;
	_xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    _xmppvCardTempModule = nil;
	_xmppvCardAvatarModule = nil;
	_xmppCapabilities = nil;
	_xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = _xmppStream.myJID.domain;
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:LIVEUPDATE_SERVER_NAME]
       || [domain isEqualToString:LIVEUPDATE_SERVER_NAME]
       || [domain isEqualToString:LIVEUPDATE_SERVER_NAME])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
	
	[self.xmppStream sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[self.xmppStream sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)connect:(NSString *)strName;
{
	if (!_xmppStream.disconnected) {
	
	}
    
    NSString *strJID = [NSString stringWithFormat:@"%@ %@",strName,LIVEUPDATE_SERVER_NAME];
    strJID = [strJID stringByReplacingOccurrencesOfString:@" " withString:@"@"];
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:strName];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:strName];
    
	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
	
	if (myJID == nil || myPassword == nil) {
	
	}
    
	_xmppStream.myJID = [XMPPJID jidWithString:strJID];
	password = strName;
    
	NSError *error = nil;
	if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		DDLogError(@"Error connecting: %@", error);
	}
}

#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	NSString *expectedCertName = _xmppStream.myJID.domain;
	if (expectedCertName)
	{
		settings[(NSString *)kCFStreamSSLPeerName] = expectedCertName;
	}
	
	if (customCertEvaluation)
	{
		settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
	}
}
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	// The delegate method should likely have code similar to this,
	// but will presumably perform some extra security code stuff.
	// For example, allowing a specific self-signed certificate that is known to the app.
	
	dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(bgQueue, ^{
		
		SecTrustResultType result = kSecTrustResultDeny;
		OSStatus status = SecTrustEvaluate(trust, &result);
		
		if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
			completionHandler(YES);
		}
		else {
			completionHandler(NO);
		}
	});
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
   [[NSNotificationCenter defaultCenter] postNotificationName:LiveUpdateConnectedNotification object:nil];
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![self.xmppStream authenticateWithPassword:password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

-(BOOL)isXmppConnected
{
    return isXmppConnected;
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LiveUpdateConnectedNotification object:nil];
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // A simple example of inbound message handling.
    
    if (message.chatMessageWithBody)
    {
        //		XMPPUserCoreDataStorageObject *user = [_xmppRosterStorage userForJID:[message from]
        //		                                                         _xmppStream:_xmppStream
        //		                                               managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *body = [message elementForName:@"body"].stringValue;
        //NSString *displayName = [user displayName];
        
        NSMutableArray *arrayItems = [self objectFromJsonString:body];
        
        if(arrayItems.count>0)
        {
            NSMutableDictionary *dictItem = arrayItems[0];
            if ([[dictItem valueForKey:@"Action"] isEqualToString:@"HoldInvoice"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LiveHoldUpdateCount" object:dictItem];
            }
            else if ([[dictItem valueForKey:@"Action"] isEqualToString:@"PetroLiveUpdate"])
            {
                [self addPumpCartToLiveUpdateQueue:dictItem];
            }
            else if ([[dictItem valueForKey:@"Action"] isEqualToString:@"UserLiveUpdate"])
            {
                [self updateUserInfoWithDictionary:dictItem];
            }
            else
            {
                [self addItemListToLiveUpdateQueue:dictItem];
            }
        }
    }
}

-(void)addItemListToLiveUpdateQueue:(NSMutableDictionary *)dictItem
{
    [self lockLiveUpdate:2];
//    NSLog(@"Need To LiveUpdate call");
    if (self.arrayItemLiveUpdate.count < 2) {
        [self.arrayItemLiveUpdate addObject:dictItem];
    }
    [self unlockLiveUpdate:2];
    [self processNextLiveUpdate];
}

-(void)processNextLiveUpdate
{
    NSLog(@"Need to call LiveUpdate");
    [self lockLiveUpdate:3];
    if(self.arrayItemLiveUpdate.count > 0 && (self.liveUpdateConnection == nil))
    {
        NSMutableDictionary *dictItem = self.arrayItemLiveUpdate[0];
        self.strUpdateType = [dictItem valueForKey:@"Action"];
        NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
        [itemparam setValue:[self.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];
        NSString *strDate = [self ludForTimeInterval:0];
        [itemparam setValue:strDate forKey:@"datetime"];
        NSLog(@"Date sent to LiveUpdate WS = %@", strDate);

        AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self liveUpdateResponse:response error:error];
            });
        };
        self.liveUpdateConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_ITEM_UPDATE_LIST params:itemparam asyncCompletionHandler:asyncCompletionHandler];
    }
    [self unlockLiveUpdate:3];
}

- (void)liveUpdateResponse:(id)response error:(NSError *)error
{
    //    NSLog(@"liveUpdateResponse");
    NSLog(@"self.strUpdateType is %@",self.strUpdateType);
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]){
            
            NSMutableArray *responseData = [self objectFromJsonString:response[@"Data"]];
            if(responseData.count > 0)
            {
                NSDictionary *responseDictionary = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                
                [self setGasPumpAmountLimit:responseDictionary];
                
                if([self.strUpdateType isEqualToString:@"Update"] || [self.strUpdateType isEqualToString:@"FuelType"] || [self.strUpdateType isEqualToString:@"Sync"])
                {
                    [self.updateManager liveUpdateFromResponseDictionary:responseDictionary];
                }
                else if([self.strUpdateType isEqualToString:@"Delete SubDepartment"])
                {
                    [self.updateManager liveUpdateFromResponseDictionary:responseDictionary];
                }
                else if([self.strUpdateType isEqualToString:@"Delete Department"])
                {
                    [self.updateManager liveUpdateFromResponseDictionary:responseDictionary];
                }
                else if([self.strUpdateType isEqualToString:@"Deleted"])
                {
                    [self.updateManager deleteObjectsFromTable:responseDictionary];
                }
                else  if([self.strUpdateType isEqualToString:@"Insert"])
                {
                    [self.updateManager liveUpdateFromResponseDictionary:responseDictionary];
                }
                else if([self.strUpdateType isEqualToString:@"Insert Vendor"])
                {
                    [self.updateManager liveUpdateFromResponseDictionary:responseDictionary];
                }
                else if([self.strUpdateType isEqualToString:@"Insert Supplier"])
                {
                    [self.updateManager liveUpdateFromResponseDictionary:responseDictionary];
                }
                else if([self.strUpdateType isEqualToString:@"Delete"])
                {
                    [self.updateManager liveUpdateFromResponseDictionary:responseDictionary];
                }
                else
                {
                    
                }
            }
            self.liveUpdateConnection = nil;
            
            [self lockLiveUpdate:1];
            if(self.arrayItemLiveUpdate.count > 0)
            {
                [self.arrayItemLiveUpdate removeObjectAtIndex:0];
            }
            [self unlockLiveUpdate:1];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LiveUpdateResponseNotification" object:nil];
            [self processNextLiveUpdate];
        }
        else
        {
            NSLog(@"liveUpdateResponse is nil");
            self.liveUpdateConnection = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LiveUpdateResponseNotification" object:nil];
            [self processNextLiveUpdate];
        }
    }
    else {
        self.liveUpdateConnection = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self processNextLiveUpdate];
        });
        NSLog(@"Nil Responce");
    }
}

#pragma mark Petro Live Update

-(void)addPumpCartToLiveUpdateQueue:(NSDictionary *)dictPumpCart
{
    [self.petroliveUpdateLock lock];
    if (self.arrayPetroLiveUpdate.count < 2) {
        [self.arrayPetroLiveUpdate addObject:dictPumpCart];
    }
    [self.petroliveUpdateLock unlock];
    [self processPetroNextLiveUpdate];
}

-(void)processPetroNextLiveUpdate
{
    NSLog(@"Need to call PetroLiveUpdate");
    [self.petroliveUpdateLock lock];
    if(self.arrayPetroLiveUpdate.count > 0 && (self.petroLiveUpdateConnection == nil))
    {
        NSMutableDictionary *dictItem = self.arrayPetroLiveUpdate[0];
        self.strPetroUpdateType = [dictItem valueForKey:@"Action"];
        NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
        [itemparam setValue:[self.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];
        NSString *strDate = [self ludForPetroTimeInterval:0];
        [itemparam setValue:strDate forKey:@"datetime"];
        NSLog(@"Date sent to PetroLiveUpdate WS = %@", strDate);
        
        AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self petroliveUpdateResponse:response error:error];
            });
        };
        self.petroLiveUpdateConnection = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_ITEM_PETRO_UPDATE_LIST params:itemparam asyncCompletionHandler:asyncCompletionHandler];
    }
    [self.petroliveUpdateLock unlock];
}

- (void)petroliveUpdateResponse:(id)response error:(NSError *)error
{
    NSLog(@"self.strPetroUpdateType is %@",self.strPetroUpdateType);
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]){
            
            NSMutableArray *responseData = [self objectFromJsonString:response[@"Data"]];
            if(responseData.count > 0)
            {
                NSDictionary *responseDictionary = [[self objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                
                if([self.strPetroUpdateType isEqualToString:@"Update"] || [self.strPetroUpdateType isEqualToString:@"FuelType"] || [self.strPetroUpdateType isEqualToString:@"Sync"])
                {
//                    [self.updateManager liveUpdateFromResponseDictionary:responseDictionary];
                    [self.updateManager insertOrUpdatePumpCartChangedData:responseDictionary];
                }
            }
            self.petroLiveUpdateConnection = nil;
            [self.petroliveUpdateLock lock];
            if(self.arrayPetroLiveUpdate.count > 0)
            {
                [self.arrayPetroLiveUpdate removeObjectAtIndex:0];
            }
            [self.petroliveUpdateLock unlock];
            [self processPetroNextLiveUpdate];
        }
        else
        {
            NSLog(@"petroLiveUpdateConnection is nil");
            self.petroLiveUpdateConnection = nil;
            [self processPetroNextLiveUpdate];
        }
    }
    else {
        self.petroLiveUpdateConnection = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self processPetroNextLiveUpdate];
        });
        NSLog(@"Petro Nil Responce");
    }
}
#pragma mark

-(void)setGasPumpAmountLimit:(NSDictionary*)updateResponseDictionary{
    
    if([[updateResponseDictionary valueForKey:@"GasSetting"] isKindOfClass:[NSDictionary class]]){
        
        NSDictionary *gasSetting = [updateResponseDictionary valueForKey:@"GasSetting"];
        
        NSUserDefaults *amountLimit = [NSUserDefaults standardUserDefaults];
        [amountLimit setValue:gasSetting[@"InsidePay"] forKey:@"InsidePaymentLimit"];
        [amountLimit setValue:gasSetting[@"OutsidePay"] forKey:@"OutsidePaymentLimit"];
        [amountLimit synchronize];

    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GasSettingUpdate" object:nil];
    
}

- (void)lockLiveUpdate:(int)index {
//    NSLog(@"Locking for Live update %d", index);
    [self.liveUpdateLock lock];
//    NSLog(@"Locked for Live update = %@\n", [NSThread currentThread]);
}

- (void)unlockLiveUpdate:(int)index  {
//    NSLog(@"Unlocking Live update %d", index);
    [self.liveUpdateLock unlock];
//    NSLog(@"Unlocked Live update = %@\n", [NSThread currentThread]);
}

- (void)responseLiveUpdateAcknowledgementResult:(NSNotification *)notification
{
    
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    if ([presence.type isEqualToString:@"available"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LiveUpdateConnectedNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:LiveUpdateDisconnectedNotification object:nil];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LiveUpdateDisconnectedNotification object:nil];

	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
   [[NSNotificationCenter defaultCenter] postNotificationName:LiveUpdateDisconnectedNotification object:nil];

	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check _xmppStream.hostName");
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [_xmppRosterStorage userForJID:presence.from
	                                                         xmppStream:_xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = user.displayName;
	NSString *jidStrBare = presence.fromStr;
	NSString *body = nil;
	
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
	
	
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
	}
	else
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}

#pragma mark - Synchronize Method

-(void)doSynchronizeOperation
{
    self.isSynchronizing = TRUE;
    [self deleteAll];
    [self getItemDataFirstTime];
}

-(void)deleteAll
{
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSArray *masterArray = @[@"Department",@"DepartmentTax",@"GroupMaster",@"Item",@"Item_Discount_MD",@"Item_Discount_MD2",@"ItemSupplier",@"ItemTag",@"ItemTax",@"Mix_MatchDetail",@"SizeMaster",@"SupplierMaster",@"TaxMaster",@"TenderPay",@"DiscountMaster"];
    for (int i = 0; i<masterArray.count; i++)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:masterArray[i] inManagedObjectContext:privateManagedObjectContext];
        fetchRequest.entity = entity;
        //    NSError *error;
        NSArray *arryTemp = [UpdateManager executeForContext:privateManagedObjectContext FetchRequest:fetchRequest];
        for (NSManagedObject *product in arryTemp)
        {
            [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
        }
    }
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(BOOL)doesUserHaveRightsToEditItem
{
    BOOL haveRights = FALSE;
    NSArray *roleInfoArray = (self.globalDict)[@"RoleInfo"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"MenuName == Item"];
    NSArray *isroleInfoFound = [roleInfoArray filteredArrayUsingPredicate:predicate];
    if(isroleInfoFound.count > 0)
    {
        for (NSDictionary *roleDict in isroleInfoFound) {
            if([[roleDict valueForKey:@"CanEdit"] isEqualToString:@"1"])
            {
                haveRights = TRUE;
            }
            else
            {
                haveRights = FALSE;
            }
        }
    }
    else
    {
        haveRights = FALSE;
    }
    return haveRights;
}

#pragma mark - trimmedBarcode as per UPC scanner setting

- (NSString *)trimmedBarcode:(NSString *)searchData
{
    NSArray *upcSettingArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"UPC_Setting"];
    if ([upcSettingArray isKindOfClass:[NSArray class]] && upcSettingArray.count > 0)
    {
        NSString *strLength = [NSString stringWithFormat:@"%lu",(unsigned long)searchData.length];
        NSPredicate *upcPredicate = [NSPredicate predicateWithFormat:@"UpcLimit == %@", strLength];
        NSArray *isResultFound = [upcSettingArray filteredArrayUsingPredicate:upcPredicate];
        if(isResultFound.count > 0)
        {
            NSString *barcode = searchData;
            for (int i = 0; i< isResultFound.count; i++)
            {
                NSDictionary * upcSettingDictionary = isResultFound[i];
                if ([upcSettingDictionary[@"LeadingDigit"] boolValue] == YES)
                {
                    // Remove First Digit.....
                    barcode = [barcode substringFromIndex:1];
                }
                if ([upcSettingDictionary[@"CheckDigit"] boolValue] == YES)
                {
                    // Remove Last Digit......
                    barcode = [barcode substringToIndex:barcode.length-1];
                }
                searchData = barcode;
            }
        }
    }
    return searchData;
}

- (void)disconnect
{
	[self goOffline];
	[_xmppStream disconnect];
}

-(BOOL)checkRightsForRightId :(NSString *)rightId
{
    BOOL isRightApplicable = FALSE;
    NSArray *rightArray = [self.globalDict valueForKey:@"RightInfo"];
    
    NSPredicate *rightPredicate = [NSPredicate predicateWithFormat:@"(RightId == %d OR  RightId == %@) AND FlgRight == %d",rightId.integerValue,rightId,1];
    NSArray *resultRightArray = [rightArray filteredArrayUsingPredicate:rightPredicate];
    if (resultRightArray.count > 0)
    {
        isRightApplicable = TRUE;
    }
    return isRightApplicable;
}

- (void)popupAlertFromVC:(UIViewController*)viewController title:(NSString *)title  message:(NSString *)message buttonTitles:(NSArray*)buttonTitles buttonHandlers:(NSArray*)buttonHandlers
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    for (int i = 0; i< buttonTitles.count; i++)
    {
        UIAlertAction* action = [UIAlertAction actionWithTitle:buttonTitles[i] style:UIAlertActionStyleDefault
                                                       handler: buttonHandlers[i]];
        [alert addAction:action];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [viewController presentViewController:alert animated:TRUE completion:nil];

    });
}

#pragma  mark - Currency Fomatter

-(NSString *)getStringPriceFromFloat:(float)input {
    
    NSString * strInput = [NSString stringWithFormat:@"%.3f",input];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    return [self.currencyFormatter stringFromNumber:[f numberFromString:strInput]];
}


- (NSString *)applyCurrencyFomatter:(NSString *)string
{
    if(string != nil)
    {
        NSNumber *number = @(string.floatValue);
        string = [self.currencyFormatter stringFromNumber:number];
        string = [string stringByReplacingOccurrencesOfString:@"," withString:@""];
        return string;
    }
    else
    {
        return nil;
    }
}

- (float)removeCurrencyFomatter:(NSString *)string
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    nf.numberStyle = NSNumberFormatterCurrencyStyle;
    NSNumber *number = [nf numberFromString:string];
    float fltValue = number.floatValue;
    return fltValue;
}

-(NSString *)jsonStringFromObject:(id)object {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
    if (! jsonData) {
        NSLog(@"error: %@", error.localizedDescription);
        return @"";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

-(id)objectFromJsonString:(NSString *)jsonString {
    NSError *error;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (! jsonData) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
}

- (NSDate *)getDateFromJSONDate:(NSString *)jsonDate {
    NSString *header = @"/Date(";
    NSUInteger headerLength = header.length;
    
    NSString *timestampString;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:jsonDate];
    scanner.scanLocation = headerLength;
    [scanner scanUpToString:@")" intoString:&timestampString];
    
    NSCharacterSet* timezoneDelimiter = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
    NSRange rangeOfTimezoneSymbol = [timestampString rangeOfCharacterFromSet:timezoneDelimiter];
    if (rangeOfTimezoneSymbol.length!= 0) {
        NSRange rangeOfFirstNumber;
        rangeOfFirstNumber.location = 0;
        rangeOfFirstNumber.length = rangeOfTimezoneSymbol.location;
        
        NSRange rangeOfSecondNumber;
        rangeOfSecondNumber.location = rangeOfTimezoneSymbol.location + 1;
        rangeOfSecondNumber.length = timestampString.length - rangeOfSecondNumber.location;
        
        NSString* firstNumberString = [timestampString substringWithRange:rangeOfFirstNumber];
        
        unsigned long long firstNumber = firstNumberString.longLongValue;
        NSTimeInterval interval = firstNumber/1000;
        
        return [NSDate dateWithTimeIntervalSince1970:interval];
    }
    
    unsigned long long firstNumber = timestampString.longLongValue;
    NSTimeInterval interval = firstNumber/1000;
    
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

+ (NSString *)removeNameSpaceFromXml:(NSString *)xml rootTag:(NSString *)rootTag
{
    NSMutableArray *xmlArray = [[xml componentsSeparatedByString:@"<"] mutableCopy];
    for (int i = 0; i < xmlArray.count; i++)
    {
        NSString *stringAtIndex = xmlArray[i];
        NSRange responseRange = [stringAtIndex rangeOfString:rootTag];
        
        if (responseRange.location != NSNotFound)
        {
            NSInteger rootTagLength = responseRange.location + rootTag.length;
            stringAtIndex = [stringAtIndex substringToIndex:rootTagLength];
            stringAtIndex = [stringAtIndex stringByAppendingString:@">"];
            xmlArray[i] = stringAtIndex;
            break;
        }
    }
    NSString *xmlString = [xmlArray componentsJoinedByString:@"<"];
    return xmlString;
}

#pragma mark - Create HMAC for INTERCOM -

-(NSString *)GetHMACFromUserID:(NSString *)userId{
    
    const char *cKey  = [INTERCOM_SECUREMODE_KEY cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [userId cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    return [self hexRepresentationWithSpaces_AS:false datavalue:HMAC];
}
-(NSString*)hexRepresentationWithSpaces_AS:(BOOL)spaces datavalue:(NSData *)data{
    const unsigned char* bytes = (const unsigned char*)data.bytes;
    NSUInteger nbBytes = data.length;
    //If spaces is true, insert a space every this many input bytes (twice this many output characters).
    static const NSUInteger spaceEveryThisManyBytes = 4UL;
    //If spaces is true, insert a line-break instead of a space every this many spaces.
    static const NSUInteger lineBreakEveryThisManySpaces = 4UL;
    const NSUInteger lineBreakEveryThisManyBytes = spaceEveryThisManyBytes * lineBreakEveryThisManySpaces;
    NSUInteger strLen = 2*nbBytes + (spaces ? nbBytes/spaceEveryThisManyBytes : 0);
    
    NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:strLen];
    for(NSUInteger i=0; i<nbBytes; ) {
        [hex appendFormat:@"%02X", bytes[i]];
        //We need to increment here so that the every-n-bytes computations are right.
        ++i;
        
        if (spaces) {
            if (i % lineBreakEveryThisManyBytes == 0) [hex appendString:@"\n"];
            else if (i % spaceEveryThisManyBytes == 0) [hex appendString:@" "];
        }
    }
    return hex.lowercaseString;
}

- (NSString *)userNameOfApp
{
    NSString *userNameOfApp = @"";
    NSString *userName = [NSString stringWithFormat:@"%@",[[self.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserName"]];
    NSString *email = [NSString stringWithFormat:@"%@",[[self.globalDict valueForKey:@"UserInfo"] valueForKey:@"Email"]];
    if ([userName isEqualToString:email]) {
        NSString *firstName = [NSString stringWithFormat:@"%@",[[self.globalDict valueForKey:@"UserInfo"] valueForKey:@"FirstName"]];
        if (firstName == nil || firstName.length == 0) {
            return @"";
        }
        NSString *lastName = [NSString stringWithFormat:@"%@",[[self.globalDict valueForKey:@"UserInfo"] valueForKey:@"LastName"]];
        if (lastName == nil || lastName.length == 0) {
            userNameOfApp = [NSString stringWithFormat:@"%@",firstName];
        }
        else
        {
            userNameOfApp = [NSString stringWithFormat:@"%@ %@",firstName,[lastName substringToIndex:1]];
        }
    }
    else {
        userNameOfApp = [NSString stringWithFormat:@"%@",userName];
    }
    return userNameOfApp;
}

#pragma mark Get Invoice From RegInvNo

//-(PumpCartInvoiceData *)getInvoiceDetailForRegInvNo :(NSMutableDictionary *)param withMethodName:(NSString *)methodName{
//    
//    
//    NSData *requestData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
//    
//    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",KURL,methodName]];
//    NSMutableURLRequest *invoiceRequest = [[NSMutableURLRequest alloc] initWithURL:requestUrl];
//    
//    invoiceRequest.HTTPMethod = @"POST";
//    [invoiceRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [invoiceRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [invoiceRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)requestData.length] forHTTPHeaderField:@"Content-Length"];
//    if (![(self.globalDict)[@"DBName"] isEqualToString:@""])
//    {
//        [invoiceRequest addValue:(self.globalDict)[@"DBName"] forHTTPHeaderField:@"DBName-Header"];
//    }
//    invoiceRequest.HTTPBody = requestData;
//    
////    get response
////    NSURLResponse *urlResponse_p = nil;
////    NSError *error = nil;
//    
//    __block NSData *result;
//    __block BOOL responceReceived = NO;
//    
//    result = nil;
//    
//    [_myCondition lock];
//    [[[NSURLSession sharedSession] dataTaskWithRequest:invoiceRequest
//                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                         [_myCondition lock];
//
//                                         if (error == nil) {
//                                             result = data;
//
//                                         }
//                                         responceReceived = YES;
//                                         [_myCondition signal];
//                                         [_myCondition unlock];
//
//                                     }] resume];
//    while (!responceReceived) {
//        [_myCondition wait];
//    }
//    [_myCondition unlock];
//    
//    NSDictionary *dicResponse = [self responseDictionaryFromData:result withMethodName:methodName];
//
//    NSMutableDictionary *pumpInvoiceDictionary = [self objectFromJsonString:[dicResponse valueForKey:@"Data"]];
//    
//    if([self checkGasPumpisActive]){
//        
//        [self updateBillAmountforCC:pumpInvoiceDictionary];
//    }
//
//    
////    PumpCartInvoiceData *pumpCartInvoice = [self.updateManager insertPumpCartInvoiceDetailInFromLive:pumpInvoiceDictionary moc:self.rapidPetroPos.petroMOC];
//
////    return pumpCartInvoice;
//}


-(void)updateBillAmountforCC:(NSMutableDictionary *)invoiceDetail{
    
    BOOL isPaxTransaction = NO;
    NSMutableArray *paymentArray = [[invoiceDetail valueForKey:@"InvoicePaymentDetail"]firstObject];
    
    for (NSMutableDictionary *dictPaymentDetail in paymentArray) {
        if([dictPaymentDetail[@"GatewayType"] isEqualToString:@"Pax"]){
            isPaxTransaction = YES;
        }
        
        float billAmount = [dictPaymentDetail[@"BillAmount"] floatValue] - [dictPaymentDetail[@"ReturnAmount"] floatValue];
        dictPaymentDetail[@"BillAmount"] = @(billAmount);
    }
    
    NSMutableArray *invoiceItemDetail = [[invoiceDetail valueForKey:@"InvoiceItemDetail"] firstObject];
    
    for (NSMutableDictionary *dictItemDetail in invoiceItemDetail) {
        if([dictItemDetail[@"Barcode"] isEqualToString:@"GAS"]){
            //   self.btnCapture.hidden = NO;
            dictItemDetail[@"ItemBasicAmount"] = dictItemDetail[@"ItemAmount"];
        }
    }
    
    
}
- (NSDictionary *)responseDictionaryFromData:(NSData *)data withMethodName:(NSString *)methodName
{
    NSMutableDictionary *dicResponse;
    if (data) {
        dicResponse = [self convertResponsetoDictionaryFromData:data withMethodName:methodName];
    }
    NSString *actionNameResult = [NSString stringWithFormat:@"%@Result",methodName];
    NSDictionary *responseDictionary = [dicResponse valueForKey:actionNameResult];
    data = nil;
    return responseDictionary;
}


-(NSMutableDictionary *)convertResponsetoDictionaryFromData:(NSData *)data withMethodName:(NSString *)methodName
{
    NSMutableDictionary *dicResponse;
    NSString *actionNameResult = [NSString stringWithFormat:@"%@Result",methodName];
    dicResponse = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves) error:nil];
    if (dicResponse && [[dicResponse[actionNameResult] valueForKey:@"IsError"] integerValue] == -786) {
        dicResponse = nil;
    }
    return dicResponse;
}

/*-(void)InsertPumpCartDataWebServiceCall:(PumpCart *)pumpCart{
    
    if ((pumpCart.registerNumber.integerValue == [(self.globalDict)[@"RegisterId"] integerValue] || [pumpCart.transactionType isEqualToString:@"OUTSIDE-PAY"])) {
        
        NSManagedObjectContext *moc = [UpdateManager privateConextFromParentContext:self.rapidPetroPos.petroMOC];
        
        FuelPump *fuelPump = (FuelPump *)[self.updateManager __fetchEntityWithName:@"FuelPump" key:@"pumpIndex" value:pumpCart.pumpIndex shouldCreate:NO moc:moc];
        
        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
        dictParam[@"PumpId"] = pumpCart.pumpIndex.stringValue;
        dictParam[@"FuelId"] = fuelPump.fuelIndex;
        dictParam[@"isPaid"] = pumpCart.isPaid;
        dictParam[@"UserId"] = pumpCart.userId.stringValue;
        dictParam[@"CartId"] = [NSString stringWithFormat:@"%@",pumpCart.cartId];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        dictParam[@"TimeStampVal"] = @"";
        if(pumpCart.regInvNum != nil){
            dictParam[@"RegInvNum"] = pumpCart.regInvNum;
        }
        else{
            dictParam[@"RegInvNum"] = @"0";
        }
        dictParam[@"RegisterNumber"] = pumpCart.registerNumber.stringValue;
        dictParam[@"PayId"] = @"0";
        dictParam[@"PricePerGallon"] = pumpCart.pricePerGallon;
        dictParam[@"AmountLimit"] = pumpCart.amountLimit;
        dictParam[@"BranchId"] = (self.globalDict)[@"BranchID"];
        dictParam[@"VolumeLimit"] = pumpCart.volumeLimit;
        dictParam[@"Amount"] = pumpCart.amount;
        dictParam[@"Volume"] = pumpCart.volume;
        dictParam[@"PayType"] = @"0";
        dictParam[@"CreatedBy"] = @"0";
        dictParam[@"TransactionType"] = pumpCart.transactionType;
        
        NSMutableDictionary *dictMain = [[NSMutableDictionary alloc]init];
        dictMain[@"PumpCartData"] = dictParam;
        
        AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error){
            
            [self pumpCartInsertResponse:response error:error];
        };
        
        self.pumpCartWC = [self.pumpCartWC initWithAsyncRequest:KURL actionName:@"InsertPumpCart" params:dictMain asyncCompletionHandler:asyncCompletionHandler];
    }
}
- (void)pumpCartInsertResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            //    [_activityIndicator hideActivityIndicator];
        }
    }
}
*/


-(NSPredicate *)predicateForKey:(NSString *)key floatValue:(float)floatValue {
    
    const float epsilon = 0.001;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K > %f AND %K < %f", key, floatValue - epsilon,  key, floatValue + epsilon];
    return predicate;
}

-(BOOL)checkGasPumpisActive{
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (self.globalDict)[@"DeviceId"]];
    
    NSArray *activeModulesArray = [[self.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    
    return [self isRcrGasActive:activeModulesArray];
}
-(BOOL)isRcrGasActive:(NSArray *)array
{
    BOOL isRcrActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@",@"RCRGAS"];
    NSArray *rcrArray = [array filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}
-(BOOL)isRapidOnSite{
    BOOL isRapidOnSite = NO;
    NSDictionary *petroSetting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RapidPetroSetting"] mutableCopy];
//    if([petroSetting[@"selectedPetroServer"] integerValue] == GASPUMP_SERVER_RAPIDONSITE){
//        isRapidOnSite = YES;
//    }
    return isRapidOnSite;
}

-(BOOL)getGasPumpUrlEnabled{
    NSDictionary *petroSetting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RapidPetroSetting"] mutableCopy];
    return [petroSetting[@"RapidOnsite"][@"GasPumpUrlEnabled"] boolValue];
}
-(NSString *)getGasPumpUrl{
    NSDictionary *petroSetting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RapidPetroSetting"] mutableCopy];
    return petroSetting[@"RapidOnsite"][@"GasPumpUrl"];
}
-(void)addEventForMasterUpdateWithKey:(NSString *)appSeeKey{
    
    RegisterInfo *registerInfo = [self.updateManager updateRegisterInfoMoc:self.managedObjectContext];
    NSDictionary * registerInfoDictionary = registerInfo.registerDictionary;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict[@"DeviceType"] = [UIDevice currentDevice].model;
    if (registerInfoDictionary == nil)
    {
        dict[@"DBName"] = @"Register information is missing";
        dict[@"RegisterId"] = @"Register information is missing";
    }
    else{
        if([registerInfoDictionary valueForKey:@"DBName"] && [registerInfoDictionary valueForKey:@"RegisterId"]){
            dict[@"DBName"] = [registerInfoDictionary valueForKey:@"DBName"];
            dict[@"RegisterId"] = [NSString stringWithFormat:@"%@",[registerInfoDictionary valueForKey:@"RegisterId"]];
        }
        else{
            dict[@"DBName"] = @"First time information is missing";
            dict[@"RegisterId"] = @"First time information is missing";
        }
    }
    
    dict[@"OSVersion"] = [UIDevice currentDevice].systemVersion;
    dict[@"Appversion"] =  [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    dict[@"Buildversion"] = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey];;
    
    [Appsee addEvent:appSeeKey withProperties:dict];
}
//-(NSMutableDictionary *)createLogDictionaryWithLastPumpState:(NSInteger)pumpIndex withStatus:(NSString *)status{
//    
///*    FuelPump *fuelPump = (FuelPump *)[self.updateManager __fetchEntityWithName:@"FuelPump" key:@"pumpIndex" value:@(pumpIndex) shouldCreate:NO moc:self.rapidPetroPos.petroMOC];
//    
//    NSMutableDictionary *logDict = [[NSMutableDictionary alloc] init];
//    [logDict setObject:fuelPump.cart forKey:@"CartId"];
//    [logDict setObject:fuelPump.amountLimit forKey:@"BroadcastAuthAmount"];
//    [logDict setObject:fuelPump.volume forKey:@"GallonsQty"];
//    [logDict setObject:fuelPump.amount forKey:@"Amount"];
//    [logDict setObject:fuelPump.fuelIndex forKey:@"FuelType"];
//    [logDict setObject:fuelPump.price forKey:@"BroadcastFuelPrice"];
//    [logDict setObject:status forKey:@"Status"];
//    if([status isEqualToString:@"Transfer"]){
//        [logDict setObject:[NSString stringWithFormat:@"%ld",(long)pumpIndex] forKey:@"FromPump"];
//    }
//    else{
//        [logDict setObject:@"" forKey:@"FromPump"];
//    }
//    [logDict setObject:(self.globalDict)[@"BranchID"] forKey:@"BranchId"];
//    [logDict setObject:[[self.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
//    [logDict setObject:(self.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
//    
//    NSDate* date = [NSDate date];
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
//    NSString *currentDateTime = [formatter stringFromDate:date];
//    [logDict setObject:currentDateTime forKey:@"LocalDate"];
//    
//    return logDict;
//    */
//}

#pragma mark

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
