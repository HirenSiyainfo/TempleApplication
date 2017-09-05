//
//  ReportsGraphVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 12/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportsGraphVC : UIViewController
@property (nonatomic, strong) NSMutableArray *reportsArray;
@property (nonatomic, strong) NSString *typeOfChart;

- (void)loadGraph;
@end
