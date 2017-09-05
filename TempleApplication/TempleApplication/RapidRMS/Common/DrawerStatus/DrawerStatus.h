//
//  UserRights.h
//  RapidRMS
//
//  Created by Siya-mac5 on 25/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintJob.h"
#import "PrintJobBase.h"
#import "PrinterFunctions.h"


@protocol DrawerStatusDelegate <NSObject>

-(void)errorOccuredWhileGettingDrawerStatusWithTitle:(NSString *)title message:(NSString *)message;
-(void)getDrawerStatusProcessCompleted;

@end

@interface DrawerStatus : NSObject 

- (instancetype)init;
- (BOOL)isDrawerConfigured;
- (void)detectDrawerType;
- (void)checkDrawerStatusWithDelegate:(id)delegate needToSwitchDrawerType:(BOOL)needToSwitchDrawerType;

@property (nonatomic, weak) id<DrawerStatusDelegate> drawerStatusDelegate;

@end
