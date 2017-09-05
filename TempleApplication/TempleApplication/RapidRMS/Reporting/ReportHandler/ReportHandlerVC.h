//
//  ReportHandlerVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 12/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyReportVC.h"

@protocol ReportHandlerVCDelegate <NSObject>

-(void)didCompleteReport:(ReportName)reportType responseArray:(NSArray *)responseArray;

@end

@interface ReportHandlerVC : UIViewController
@property (nonatomic, weak) id <ReportHandlerVCDelegate> reportHandlerVCDelegate;

@property (nonatomic, weak) IBOutlet UIView *graphContainer;
@property (nonatomic, weak) IBOutlet UIView *creditBatchContainer;

@property (nonatomic, strong) NSString *zIdForZZ;

- (void)configureView:(UIView *)view;
- (void)access:(ReportName)report usingDictionary:(NSMutableDictionary *)mangerDetailsDict;
@end
