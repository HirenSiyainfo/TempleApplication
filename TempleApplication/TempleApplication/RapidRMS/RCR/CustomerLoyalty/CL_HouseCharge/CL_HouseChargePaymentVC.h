//
//  CL_HouseChargePaymentVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CL_HouseChargePaymentVCDelegate <NSObject>

-(void)didAddBalanceAmount:(CGFloat)balanceAmount;
-(void)didCancelHouseChargePaymentVC;

@end


@interface CL_HouseChargePaymentVC : UIViewController
@property (nonatomic ,weak) id<CL_HouseChargePaymentVCDelegate> cl_HouseChargePaymentVCDelegate;
@property (nonatomic ,weak) NSNumber *balance;
@property (nonatomic ,weak) NSString *customerNo;





@end
