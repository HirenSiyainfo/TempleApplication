//
//  CL_HouseChargeCreditLimitVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CL_HouseChargeCreditLimitVCDelegate <NSObject>

-(void)setCreditLimit:(CGFloat)balanceAmount;
-(void)didCancelHouseChargeCreditLimitVC;

@end

@interface CL_HouseChargeCreditLimitVC : UIViewController

@property (nonatomic ,weak) id<CL_HouseChargeCreditLimitVCDelegate> cl_HouseChargeCreditLimitVCDelegate;
@property (nonatomic ,weak) NSNumber *currentCreditLimit;



@end
