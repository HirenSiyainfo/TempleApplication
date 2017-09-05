//
//  ManagerReportVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 13/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyReportVC.h"

@protocol ManagerReportVCDelegate <NSObject>
- (void)didSelectedMangerReportOption:(ManagerTabOption)managerTabOption;
- (void)accessMangerReport:(ReportName)reportName usingDictionary:(NSMutableDictionary *)mangerDetailsDict;
@end

@interface ManagerReportVC : UIViewController

@property (nonatomic, weak) id <ManagerReportVCDelegate> managerReportVCDelegate;

- (void)needToShowAllTabOptions:(BOOL)needToShowAllTab;
- (void)accessManagerReportsDetailsFor:(NSDate *)reportDate formatter:(NSString *)formatter reportName:(ReportName)reportName;

@end
