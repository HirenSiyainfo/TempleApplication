//
//  ManagerReportPopUpVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 17/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

typedef NS_ENUM (NSUInteger, ManagerReportOption) {
    ManagerReportOptionZReport,
    ManagerReportOptionZZReport,
    ManagerReportOptionShiftReport,
};

#import <UIKit/UIKit.h>
@protocol ManagerReportPopUpVCDelegate
- (void)didSelectMangerReportOption:(ManagerReportOption)managerReportOption;
- (void)didCloseMangerReport;
@end

@interface ManagerReportPopUpVC : UIViewController

@property (nonatomic, weak) id <ManagerReportPopUpVCDelegate> managerReportPopUpVCDelegate;

@end
