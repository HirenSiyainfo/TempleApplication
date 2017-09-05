//
//  CL_HouseChargeAddCreditVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CL_HouseChargeAddCreditVCDelegate <NSObject>

-(void)didAddCreditAmount:(CGFloat)balanceAmount;
-(void)didCancelHouseChargeAddCreditVC;

@end


@interface CL_HouseChargeAddCreditVC : UIViewController
@property (nonatomic ,weak) id<CL_HouseChargeAddCreditVCDelegate> cl_HouseChargeAddCreditVCDelegate;
@property (nonatomic ,weak) NSNumber *balance;
@property (nonatomic ,weak) NSNumber *creditLimit;




@end
