//
//  CL_CustomerSearchVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 12/9/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CL_CustomerSearchData.h"

@protocol CL_CustomerSearchVCDelegate<NSObject>

-(void)didUpdateCustomerWithStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate withSearchCustomType:(NSString *)customType;

@end

@interface CL_CustomerSearchVC : UIViewController

@property (nonatomic, weak) id<CL_CustomerSearchVCDelegate> cl_CustomerSearchVCDelegate;

@property (nonatomic , strong) CL_CustomerSearchData *cl_CustomerSearchData;


@end
