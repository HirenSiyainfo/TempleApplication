//
//  DiscountMasterListVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 5/29/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DiscountMasterListDelegate <NSObject>

-(void)didSelectSalesDiscount :(NSDictionary *)discountInfo;

@end
@interface DiscountMasterListVC : UIViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id<DiscountMasterListDelegate> discountMasterListDelegate;

@end
