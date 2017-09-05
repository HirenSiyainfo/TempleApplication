//
//  DashBoardSettingVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 05/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DashBoardSettingDelegate<NSObject>


@end

@interface DashBoardSettingVC : UIViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>



-(IBAction)secondMenuTapped:(id)sender;

@property (nonatomic, weak) id<DashBoardSettingDelegate> dashBoardSettingDelegate;


-(void)tenderConfigurationSub:(NSString *)strTitle Index:(NSString *)strIndex arrPaymentType:(NSMutableArray *)arryPaymentType;
-(void)goToDisplayConnection;
-(void)goToAvailableAppsMenu;
-(void)goToActiveAppsMenu;
-(void)goTODeviceActivation;


@end
