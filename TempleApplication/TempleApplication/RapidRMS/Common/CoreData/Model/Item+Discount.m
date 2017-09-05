//
//  Item+Discount.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/26/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Item+Discount.h"
#import "Mix_MatchDetail+Dictionary.h"

@implementation Item (Discount)

-(CGFloat)taxValue
{
   //  NSManagedObjectContext *context = self.managedObjectContext;
    return 0.0;
   
}

-(CGFloat)discountedTotalPriceForQuantity :(NSInteger)quantity
{
    return (quantity * self.salesPrice.floatValue) - [self totalDiscountForQuantity:quantity];
}
-(CGFloat)totalTaxForQuantity :(NSInteger)quantity
{
    return [self taxValue] * quantity / 100.;
}
-(CGFloat)totalDiscountForQuantity :(NSInteger)quantity
{
    CGFloat totalDiscountForQuantity = 0.00;
    if (self.itemMixMatchDisc) {
        
        switch (self.itemMixMatchDisc.discCode.integerValue)
        {
            case MIX_MATCH_DISCOUNT_SALES_PRICE:
                totalDiscountForQuantity = [self mixmatchDiscountSalesPriceForQuantity :quantity];
                break;
            case MIX_MATCH_DISCOUNT_PERCENTAGE_OFF:
                totalDiscountForQuantity = [self mixmatchDiscountSPercentageOffForQuantity :quantity];

                break;
            case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE:
                totalDiscountForQuantity = [self mixmatchBuy_X_getY_for_X_discountSalesPriceForQuantity :quantity];

                break;
            case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF:
                totalDiscountForQuantity = [self mixmatchBuy_X_getY_for_X_discountSPercentageOffForQuantity :quantity];

                break;
            default:
                break;
        }
        
    }
    
    return totalDiscountForQuantity;
}
-(CGFloat)mixmatchDiscountSalesPriceForQuantity :(NSInteger)quantity
{
    CGFloat discountValue = 0.0;
    NSInteger applicationFactor =  quantity / self.itemMixMatchDisc.mix_Match_Qty.integerValue;
    discountValue = self.itemMixMatchDisc.mix_Match_Amt.floatValue * applicationFactor ;
    return discountValue;
}

-(CGFloat)mixmatchDiscountSPercentageOffForQuantity :(NSInteger)quantity
{
    CGFloat discountValue = 0.0;
    NSInteger applicationFactor =  quantity / self.itemMixMatchDisc.mix_Match_Qty.integerValue;
    discountValue = self.salesPrice.floatValue * applicationFactor * self.itemMixMatchDisc.mix_Match_Qty.integerValue*self.itemMixMatchDisc.mix_Match_Amt.floatValue  * 0.01;
    return discountValue;
}

-(CGFloat)mixmatchBuy_X_getY_for_X_discountSalesPriceForQuantity :(NSInteger)quantity
{
    return 0.00;
}

-(CGFloat)mixmatchBuy_X_getY_for_X_discountSPercentageOffForQuantity :(NSInteger)quantity
{
    return 0.00;
}
@end
