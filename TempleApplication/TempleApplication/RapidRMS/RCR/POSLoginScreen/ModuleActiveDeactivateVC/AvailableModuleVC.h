//
//  DisplayModuleViewController.h
//  RapidRMS
//
//  Created by Siya on 17/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleActiveDeactiveVC.h"

@interface AvailableModuleVC : UIViewController

@property (nonatomic, strong) ModuleActiveDeactiveVC *objModActi;

@property (nonatomic, strong) NSMutableArray *deactiveDeviceArray;
@property (nonatomic, strong) NSMutableArray *displayModuleData;
@property (nonatomic, strong) NSMutableArray *rcrModuleData;
@property (nonatomic, strong) NSMutableArray *otherModulData;
@property (nonatomic, strong) NSMutableArray *activeModules;

@property (nonatomic, assign) BOOL activationDisable;
@property (nonatomic, assign) BOOL isRcrActive;

-(void)reloadAvailableModuleData;
@end
