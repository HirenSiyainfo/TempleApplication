//
//  ItemSwipeDiscountCalculator.m
//  RapidRMS
//
//  Created by siya-IOS5 on 3/5/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ItemSwipeDiscountCalculator.h"

@interface ItemSwipeDiscountCalculator ()
{
    NSMutableArray *billDetail;
}

@end


@implementation ItemSwipeDiscountCalculator
- (instancetype)initWithRecieptArray:(NSMutableArray *)receiptArray{
    self = [super init];
    
    if (self) {
        billDetail = [[NSMutableArray alloc] init];
        billDetail = receiptArray;
    }
    
    return self;
}

-(void)calculateItemSwipeDiscount
{
    for (NSMutableDictionary *itemSwipeDiscountDictionary in billDetail) {
        
        
        if ([[itemSwipeDiscountDictionary objectForKey:@"IsRefundFromInvoice"] boolValue] == TRUE) {
            continue;
        }
        
        if ([itemSwipeDiscountDictionary objectForKey:@"PriceAtPos"])
        {
            if ([[itemSwipeDiscountDictionary objectForKey:@"PriceAtPos"] floatValue] > 0)
            {
                float itemSwipeDiscount = 0.0;
                
                CGFloat totalBasicPrice = [[itemSwipeDiscountDictionary objectForKey:@"ItemBasicPrice"] floatValue] * [[itemSwipeDiscountDictionary objectForKey:@"itemQty"] integerValue];
                
                CGFloat basicPriceForPackageType = totalBasicPrice / ([[itemSwipeDiscountDictionary objectForKey:@"itemQty"] integerValue] / [[itemSwipeDiscountDictionary objectForKey:@"PackageQty"] integerValue]);
                
                
                if (basicPriceForPackageType > [[itemSwipeDiscountDictionary objectForKey:@"PriceAtPos"] floatValue]) {
                    itemSwipeDiscount = basicPriceForPackageType - [[itemSwipeDiscountDictionary objectForKey:@"PriceAtPos"] floatValue];
                    itemSwipeDiscount = itemSwipeDiscount * ([[itemSwipeDiscountDictionary objectForKey:@"itemQty"] integerValue] / [[itemSwipeDiscountDictionary objectForKey:@"PackageQty"] integerValue]);
                }
                itemSwipeDiscountDictionary[@"IsQtyEdited"] = @"0";
                itemSwipeDiscountDictionary[@"itemPrice"] = @([[itemSwipeDiscountDictionary objectForKey:@"PriceAtPos"] floatValue] / [[itemSwipeDiscountDictionary objectForKey:@"PackageQty"] integerValue]);
                [itemSwipeDiscountDictionary setObject:@([[itemSwipeDiscountDictionary objectForKey:@"itemPrice"] floatValue] * [[itemSwipeDiscountDictionary objectForKey:@"itemQty"] floatValue]) forKey:@"TotalItemPrice"];
                [itemSwipeDiscountDictionary setObject:[NSString stringWithFormat:@"%.2f",itemSwipeDiscount] forKey:@"ItemDiscount"];
                
                NSMutableArray *discountArray = [itemSwipeDiscountDictionary valueForKey:@"Discount"];
                
                NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                            @"Swipe", @"DiscountType",
                                                                            @(itemSwipeDiscount),@"Amount",
                                                                            @"Swipe",@"AppliedOn",
                                                                            @(0),@"DiscountId"
                                                                            ,nil];
                [discountArray addObject:itemwisePecentageDiscountDictionary];
                
                
            }
            else
            {
                itemSwipeDiscountDictionary[@"itemPrice"] = @([[itemSwipeDiscountDictionary objectForKey:@"PriceAtPos"] floatValue] / [[itemSwipeDiscountDictionary objectForKey:@"PackageQty"] integerValue]);
                [itemSwipeDiscountDictionary setObject:@"0" forKey:@"ItemDiscount"];
            }
        }
    }
}

@end
