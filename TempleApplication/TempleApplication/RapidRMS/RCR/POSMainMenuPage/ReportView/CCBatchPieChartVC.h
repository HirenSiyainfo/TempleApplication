//
//  CCBatchPieChartVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 7/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCBatchPieChartVC : UIViewController<CPTPlotDataSource,CPTLegendDelegate>
@property (nonatomic , strong) NSMutableArray *cardDetails;
@end
