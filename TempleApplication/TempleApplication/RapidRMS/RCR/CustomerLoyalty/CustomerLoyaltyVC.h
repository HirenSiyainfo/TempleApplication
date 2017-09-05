//
//  CustomerLoyaltyVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 01/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidCustomerLoyalty.h"

typedef NS_ENUM(NSInteger, CL_HouseChargeType) {
    Cl_HouseCharge_CollectPayment,
    Cl_HouseCharge_AddCredit,
    Cl_HouseCharge_SetCreditLimit,
    };

@protocol CustomerLoyaltyVCDelegate <NSObject>

-(void)didCustomerWithHouseChargeDetail:(NSMutableDictionary*)customerDictionary withAmount :(CGFloat)balanceAmount withIsCollectPay:(BOOL)isCollectPay;

@end

@interface CustomerLoyaltyVC : UIViewController

@property (nonatomic ,weak) id<CustomerLoyaltyVCDelegate> customerLoyaltyVCDelegate;

@property(nonatomic,strong) NSMutableDictionary *dictCustomerDetail;
@property(nonatomic,strong) RapidCustomerLoyalty *rapidCustomerLoyaltyVCObject;
@property(nonatomic,strong) NSMutableArray *customerLoyaltyDetail;
@property (nonatomic) BOOL isFromDashBoard;


@property(nonatomic,strong) IBOutlet UIView *popOverView;



@end
