//
//  Item+Discount.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/26/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Item.h"

typedef NS_ENUM(NSInteger, MIX_MATCH_DISCOUNT)
{
    MIX_MATCH_DISCOUNT_SALES_PRICE = 1,
    MIX_MATCH_DISCOUNT_PERCENTAGE_OFF,
    MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE,
    MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF,
};

@interface Item (Discount)
-(CGFloat)discountedTotalPriceForQuantity :(NSInteger)quantity;
-(CGFloat)totalTaxForQuantity :(NSInteger)quantity;
-(CGFloat)totalDiscountForQuantity :(NSInteger)quantity;
@end
