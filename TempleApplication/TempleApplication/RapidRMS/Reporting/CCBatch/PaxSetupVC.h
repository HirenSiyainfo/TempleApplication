//
//  PaxSetupVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 07/07/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PaxSetupVCDelegate <NSObject>
- (void)didCancelPaxSetUp;
- (void)didSavePaxData:(NSDictionary *)paxDictionary;
- (void)didRequestedForConnectOtherPaxDevice;
- (void)didFetchDataForOtherConnectedPaxDevice;
- (void)startActivityIndicatorForPax;
- (void)stopActivityIndicatorForPax;
@end

@interface PaxSetupVC : UIViewController

@property (nonatomic, weak) id <PaxSetupVCDelegate> paxSetupVCDelegate;

- (void)displayPaxConnectionDetail:(NSDictionary *)paxDictionary;
- (void)statusForOtherPaxDeviceConnection:(NSString *)status;
@end
