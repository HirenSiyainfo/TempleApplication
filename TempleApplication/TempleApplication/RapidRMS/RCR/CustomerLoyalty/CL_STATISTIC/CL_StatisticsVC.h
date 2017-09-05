//
//  CL_StatisticsVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 27/11/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidCustomerLoyalty.h"
#import "CS_Statistics.h"
@protocol StatisticsVCDelegate <NSObject>


@end


@interface CL_StatisticsVC : UIViewController
{
       
}
@property (nonatomic ,weak) id<StatisticsVCDelegate> statisticsVCDelegate;
@property (nonatomic, strong) RapidCustomerLoyalty *rapidCustomerLoyaltyStatisticObject;
@property (nonatomic, strong) CS_Statistics *cs_Statistics;

-(void)setCustomerStatisticInformation:(CS_Statistics *)statisticdetail strdateTimeSet:(NSString *)strMonthlyDate;



@end
