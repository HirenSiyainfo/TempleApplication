//
//  LoadingViewController.h
//  POSRetail
//
//  Created by siya-IOS5 on 3/26/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDownLoadProgressNotification @"DownLoadProgress"

#define kConfigurationMessageNotification @"ConfigurationMessage"
#define kConfigurationDownloadStatusMessageNotification @"ConfigurationDownloadMessage"
#define kConfigurationMessageKey @"Configuration Message"
#define kConfigurationStatusCodeKey @"Configuration Status"

#define kStepWiseConfigurationMessageNotification @"SetpWiseConfigurationMessage"
#define kStepWiseConfigurationMessageKey @"SetpWiseConfiguration Message"
#define kStepWiseConfigurationStatusCodeKey @"SetpWiseConfiguration Status"
#define kStepWiseConfigurationDuration @"SetpWiseConfiguration Duration"

#define kStepWiseProgressNotification @"SetpWiseConfigurationProgress"
#define kStepItemUpdateProgress @"SetpWiseItemUpdate Progress"

@interface LoadingViewController : UIViewController
{
    
}

@property(nonatomic,strong)NSDate *startingTime;

@end