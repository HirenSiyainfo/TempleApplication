//
//  AppDelegate.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "AppDelegate.h"
#import "RmsDbController.h"
#import "Reachability.h"

//#define INTERCOM_INTEGRATION_KEY @"37b4b97acee7d4aaf3918c921460cc3653a2b4b5"
#define INTERCOM_INTEGRATION_KEY @"ios_sdk-525a2293b8367d3105652b85e4c1091a152f5a22"
#define INTERCOM_INTEGRATION_APP_ID @"zms4kbl3"

#ifdef DEBUG
#define APPSEE_INTEGRATION_KEY @"b4a74e22ab674871be5b360b092046b5"
#else
#define APPSEE_INTEGRATION_KEY @"d47e513a78004eceab5eaa05029a90a2"
#endif

#ifndef __IPHONE_8_0
#define __IPHONE_8_0 80000
#endif


@interface AppDelegate ()

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation AppDelegate




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UIBarButtonItem appearance].tintColor = [UIColor colorWithRed:0.0/255.0 green:129.0/255.0 blue:254.0/255.0 alpha:1.0];
        
    }
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CardTransactionRequest"];
//    [[NSUserDefaults standardUserDefaults]synchronize];
    
    application.statusBarHidden = NO;
[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [Appsee start:APPSEE_INTEGRATION_KEY];
    [Intercom setApiKey:INTERCOM_INTEGRATION_KEY forAppId:INTERCOM_INTEGRATION_APP_ID];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
   
//    #if TARGET_IPHONE_SIMULATOR
//    [self.rmsDbController getRegistrationDetail];
//    //    [self.crmController application:application didFinishLaunchingWithOptions:launchOptions];
//#elif TARGET_OS_IPHONE
//#endif
//
//    UIApplication *thisApp = [UIApplication sharedApplication];
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
//    if ([thisApp respondsToSelector:@selector(registerForRemoteNotifications)]) // FOR IOS 8
//    {
//        [thisApp registerForRemoteNotifications];
//    }
//    else // FOR IOS 7
//#endif
//    {
//        [thisApp registerForRemoteNotificationTypes:
//         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//    }
    (self.rmsDbController.globalDict)[@"TokenId"] = @"";
    [self.rmsDbController getRegistrationDetail];
    
    
    [self.rmsDbController addEventForMasterUpdateWithKey:kMasterUpdateEvent];

    [_window makeKeyAndVisible];
    return YES;
}

//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
//{
//    NSCharacterSet *set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
//    NSString *strToken = [[[deviceToken description] componentsSeparatedByCharactersInSet:set] componentsJoinedByString: @""];
//    NSArray *arrToken = [strToken componentsSeparatedByString:@":"];
//    NSString *regToken = [arrToken firstObject];
//    [self.rmsDbController.globalDict setObject:regToken forKey:@"TokenId"];
//    [self.rmsDbController getRegistrationDetail];
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.rmsDbController applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.rmsDbController applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.rmsDbController applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.rmsDbController applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [FBSession.activeSession close];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.rmsDbController applicationWillTerminate:application];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication];
}

#pragma mark - Remote notification
//-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    [self.rmsDbController application:application performFetchWithCompletionHandler:completionHandler];
//}

//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
//{
//    [self.rmsDbController application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
//}

//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    [self.rmsDbController application:application didFailToRegisterForRemoteNotificationsWithError:error];
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    [self.rmsDbController application:application didReceiveRemoteNotification:userInfo];
//    
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
//{
//    [self.rmsDbController application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
//}

@end
