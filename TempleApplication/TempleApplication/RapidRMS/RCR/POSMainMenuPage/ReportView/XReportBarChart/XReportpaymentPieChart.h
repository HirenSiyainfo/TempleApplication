//
//  XReportpaymentPieChart.h
//  POSRetail
//
//  Created by Siya Infotech on 24/12/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportViewController.h"

@interface XReportpaymentPieChart : UIViewController<CPTPlotDataSource>

@property(nonatomic,strong) NSMutableArray *arrXRepDepartment;
@property(nonatomic,strong) NSString *StrLableName;
@property (nonatomic,strong) ReportViewController *objPayReportView;


@end
