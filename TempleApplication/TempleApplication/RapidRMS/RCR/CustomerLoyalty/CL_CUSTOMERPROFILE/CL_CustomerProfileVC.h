//
//  CL_CustomerProfileVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 27/11/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidCustomerLoyalty.h"
@protocol CustomerProfileVCDelegate <NSObject>
//- (void)didUpdateCustomerProfileInformation:(RapidCustomerLoyalty *)rapidCustomerLoyalty;

@end

@interface CL_CustomerProfileVC : UIViewController

@property (nonatomic ,weak) id<CustomerProfileVCDelegate> customerProfileVCDelegate;

@property (nonatomic, strong) RapidCustomerLoyalty *rapidCustomerLoyaltyProfileObject;

-(void)setCustomerInfoDetail;

@end
