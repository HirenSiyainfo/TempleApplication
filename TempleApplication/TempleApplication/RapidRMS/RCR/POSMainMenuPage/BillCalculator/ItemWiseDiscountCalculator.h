//
//  ItemWiseDiscountCalculator.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/5/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemWiseDiscountCalculator : NSObject
- (instancetype)initWithRecieptArray:(NSMutableArray *)receiptArray;
-(void)calCulateItemWiseDiscount;

@end
