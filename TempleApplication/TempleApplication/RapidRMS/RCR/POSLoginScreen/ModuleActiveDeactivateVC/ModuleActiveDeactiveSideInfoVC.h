//
//  ModuleActiveUserInfoVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 05/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModuleActiveDeactiveDelegate <NSObject>
-(void)loadActiveApp;
-(void)loadAvailableApp;
-(void)loadReleaseModules;
-(void)loadActiveRegisterModule:(NSNumber *)registerNumber;
-(void)loadReleaseUserModule:(NSString *)regUser;
-(void)loadRegisterUserModuleall;
@end

@interface ModuleActiveDeactiveSideInfoVC : UIViewController

@property (nonatomic, weak) id <ModuleActiveDeactiveDelegate> moduleSelectionChangeDelegate;

@property (nonatomic, weak) IBOutlet UILabel *lblAvailableApp;

@property (nonatomic, strong) NSString *storeName;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *storeAddress;

@property (nonatomic, strong) NSMutableArray *activeDevices;
@property (nonatomic, strong) NSMutableArray *releaseDevices;
@property (nonatomic, strong) NSMutableArray *arrDeviceAuthentication;

@property (nonatomic, assign) BOOL isfromDashBoard;

@end
