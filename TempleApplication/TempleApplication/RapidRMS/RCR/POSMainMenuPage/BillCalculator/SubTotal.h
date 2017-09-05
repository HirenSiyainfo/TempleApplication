//
//  SubTotal.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/19/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubTotal : NSObject

@property (nonatomic,strong) NSNumber *lineItemTotalPrice;
@property (nonatomic,strong) NSNumber *lineItemTotalDiscount;
@property (nonatomic,strong) NSNumber *lineItemTotalTax;
@property (nonatomic,strong) NSNumber *lineItemTotalFee;
@property (nonatomic,strong) NSNumber *lineItemDiscountedPrice;
@property (nonatomic,strong) NSMutableArray *lineItemTaxArray;


@end
