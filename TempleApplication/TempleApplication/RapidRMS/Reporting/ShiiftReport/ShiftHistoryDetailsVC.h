//
//  ShiftHistoryDetailsVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 19/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagerReportVC.h"

@protocol ShiftHistoryDetailsVCDelegate

- (void)accessShiftReport:(ReportName)reportName usingDictionary:(NSMutableDictionary *)shiftDetailsDict;
- (void)didSelectedMangerReportOption:(ManagerTabOption)managerTabOption;

@end

@interface ShiftHistoryDetailsVC : UIViewController

@property (nonatomic, weak) id <ShiftHistoryDetailsVCDelegate> shiftHistoryDetailsVCDelegate;

- (void)loadShiftHistoryWithAllTabOptions:(BOOL)needToShowAllTab;
- (void)loadHtmlForShiftHistoryUsing:(NSString *)html;
@end
