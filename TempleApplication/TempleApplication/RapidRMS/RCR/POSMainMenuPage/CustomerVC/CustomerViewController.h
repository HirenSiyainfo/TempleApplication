//
//  CustomerViewController.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidCustomerLoyalty.h"

@protocol CustomerSelectionDelegate <NSObject>
-(void)didSelectCustomerWithDetail:(RapidCustomerLoyalty *)rapidCustomerLoyalty customerDictionary:(NSDictionary *)customerDictionary withIsCustomerFromHouseCharge:(BOOL)isCustomerFromHouseCharge withIscollectPay:(BOOL)isCollectPay;


-(void)didCancelCustomerSelection;
@end



@interface CustomerViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
}

@property (nonatomic, weak) id<CustomerSelectionDelegate> customerSelectionDelegate;

@property (nonatomic) BOOL isFromDashBoard;
@property (nonatomic) BOOL isCustomerDeleted;

@end
