//
//  ModuleActiveDeactiveVC.h
//  RapidRMS
//
//  Created by Siya on 17/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateManager.h"

@interface ModuleActiveDeactiveVC : UIViewController<UpdateDelegate>

@property (nonatomic, strong) NSMutableArray *arrDeviceAuthentication;

@property (nonatomic, assign) BOOL bFromDashborad;

@end
