//
//  rapidRMSSettingController.m
//  RapidRMS
//
//  Created by Keyur Patel on 05/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "rapidRMSSettingController.h"
#import "AppDelegate.h"

@interface AppDelegate ()

@end

static rapidRMSSettingController *s_SharedsettingController = nil;
@interface rapidRMSSettingController () {
}
@property (nonatomic, weak) AppDelegate *appDelegate;


@end

@implementation rapidRMSSettingController


+ (rapidRMSSettingController *)sharedSettingController{
    if (!s_SharedsettingController) {
        @synchronized(self) {
            s_SharedsettingController = [[rapidRMSSettingController alloc] init];
        }
    }
    
    return s_SharedsettingController;
}

- (id)init {
    self = [super init];
    if (self) {
        self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    }
    return self;
}



@end
