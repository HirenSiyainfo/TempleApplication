//
//  PaxDeviceViewController.h
//  RapidRMS
//
//  Created by Siya Infotech on 04/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PaxDeviceSettingVCDelegate <NSObject>
- (void)didUpdatePaxDeviceSetting;
@end

@interface PaxDeviceViewController : UIViewController
@property (nonatomic,weak) id<PaxDeviceSettingVCDelegate>paxDeviceSettingVCDelegate;

@end
