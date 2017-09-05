//
//  TenderConfigurationViewController.h
//  RapidRMS
//
//  Created by Siya on 28/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashBoardSettingVC.h"

@interface TenderConfigurationViewController : UIViewController<UpdateDelegate>

@property (nonatomic, strong) DashBoardSettingVC *dashBoard;

@end
