//
//  CL_HouseChargeVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 18/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CL_HouseCharge.h"
#import "RapidCustomerLoyalty.h"


@protocol CL_HouseChageVCDelegate <NSObject>

-(void)didShowHouseChargePopOverView:(NSString*)selectedView withBalanceAmount:(NSNumber *)balanceAmount;


@end

@interface CL_HouseChargeVC : UIViewController

@property (nonatomic ,weak) id<CL_HouseChageVCDelegate> cl_HouseChageVCDelegate;
@property (nonatomic, strong) CL_HouseCharge *cl_HouseCharge;
@property (nonatomic ,strong) NSMutableArray *houseChargeListArray;


-(void)setCustomerHouseChargeInformation:(NSMutableArray *)arrHouseCharge withCustomerInfo:(RapidCustomerLoyalty *)customerInfo strdateTimeSet:(NSString *)strMonthlyDate withIsFromDashBoard:(BOOL)isFromDashBoard;



@end
