//
//  AddCustomerVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  "RapidCustomerLoyalty.h"
@protocol AddCustomerVCdelegate <NSObject>

- (void)didUpdateCustomerList;

@end

@interface AddCustomerVC : UIViewController

@property (nonatomic, weak) id<AddCustomerVCdelegate> addCustomerVCdelegate;

@property (nonatomic, strong) RapidCustomerLoyalty *rapidCustomerLoyalty;


@end
