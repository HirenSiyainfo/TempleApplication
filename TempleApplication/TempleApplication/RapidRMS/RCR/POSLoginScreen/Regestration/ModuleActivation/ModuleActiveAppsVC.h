//
//  ActiveAppsVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/9/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleActivationVC.h"

@interface ModuleActiveAppsVC : UIViewController<UpdateDelegate>

@property (nonatomic, strong) ModuleActivationVC *moduleActiveApps;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
