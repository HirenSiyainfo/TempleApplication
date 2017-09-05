//
//  iPhoneModuleSettingViewController.h
//  RapidRMS
//
//  Created by Siya on 16/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPhoneModuleSettingViewController : UIViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UpdateDelegate>

@property (nonatomic, strong) NSMutableArray *arrDeviceAuthentication;

@end
