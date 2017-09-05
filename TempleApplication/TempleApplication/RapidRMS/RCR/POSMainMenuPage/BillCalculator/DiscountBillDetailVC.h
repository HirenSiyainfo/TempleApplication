//
//  DiscountBillDetailVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/9/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscountGraphNode.h"

@protocol DiscountBillDetailDelegate<NSObject>
-(void)didCancelDiscountView;
@end


@interface DiscountBillDetailVC : UIViewController

@property (nonatomic, weak) id<DiscountBillDetailDelegate > discountBillDetailDelegate;


- (void)plotGraph:(DiscountGraphNode*)graphNode withPath:(NSArray *)path;

@end
