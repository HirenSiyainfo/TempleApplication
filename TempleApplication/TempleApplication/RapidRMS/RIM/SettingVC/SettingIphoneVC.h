//
//  SettingViewController.h
//  I-RMS
//
//  Created by Siya Infotech on 07/01/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RmsDashboardVC.h"

@interface SettingIphoneVC : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) RmsDashboardVC *objSettingHome;
@end
