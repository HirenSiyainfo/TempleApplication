//
//  CL_HouseChargeRefundCreditVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/07/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CL_HouseChargeRefundCreditVCDelegate <NSObject>

-(void)didRefundCreditAmount:(CGFloat)balanceAmount;
-(void)didCancelHouseChargeRefundCreditVC;

@end

@interface CL_HouseChargeRefundCreditVC : UIViewController
@property (nonatomic ,weak) id<CL_HouseChargeRefundCreditVCDelegate> cl_HouseChargeRefundCreditVCDelegate;
@property (nonatomic ,weak) NSNumber *balance;
@property (nonatomic ,weak) NSNumber *creditLimit;

@end
