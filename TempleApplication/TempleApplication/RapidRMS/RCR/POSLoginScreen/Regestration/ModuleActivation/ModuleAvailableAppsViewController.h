//
//  AvailableAppsViewController.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/7/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleActivationVC.h"
#import "UpdateManager.h"

@interface ModuleAvailableAppsViewController : UIViewController<UpdateDelegate>

@property (nonatomic,strong) NSMutableArray *arrDeviceAuthentication;

@property (nonatomic, strong) ModuleActivationVC *moduelAvailableApps;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) UpdateManager *departmentUpdateManager;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
