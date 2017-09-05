//
//  PriceLevelDiscount.m
//  RapidRMS
//
//  Created by siya-IOS5 on 3/8/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PriceLevelDiscount.h"
#import "LineItem.h"

@implementation PriceLevelDiscount

- (instancetype)initWithPrimaryQty:(CGFloat)primaryQtyValue withItemCode:(NSNumber *)itemCode withApplicablePrice:(CGFloat)applicablePrice ithApplicablePackageType:(NSString *)packageType
{
    self = [super init];
    if (self) {
        self.primaryQty = primaryQtyValue;
        self.itemCode = itemCode;
        self.applicablePrice = applicablePrice;
        self.discountName = @"Price Level Discount";
        self.packageType = packageType;
    }
    return self;
}

- (NSArray *)lineItemsForPackageType:(NSArray *)lineItems forPackageType:(NSString *)packageType {
    // Get line items for this discount
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@ AND packageType = %@ AND isQtyEdited = %@", self.itemCode ,packageType,@(TRUE)];
    NSArray *lineItemsForDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
    return lineItemsForDiscount;
}

- (NSArray *)lineItemsForDiscountForRemainingItems:(NSArray *)lineItems  {
    // Get line items for this discount
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@ AND isQtyEdited = %@ AND packageType != %@  AND packageType != %@", self.itemCode,@(TRUE),@"Case",@"Pack"];
    NSArray *lineItemsForDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
    return lineItemsForDiscount;
}


- (NSArray *)lineItemsForDiscount:(NSArray *)lineItems {
    // Get line items for this discount
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@ AND isQtyEdited = %@ AND packageType = %@", self.itemCode,@(TRUE),self.packageType];
    NSArray *lineItemsForDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
    return lineItemsForDiscount;
}

- (NSArray *)lineItemsForWithoutPrimary:(NSArray *)lineItems {
    NSPredicate *lineItemsForWithoutSecondaryAndPrimaryPredicate = [NSPredicate predicateWithFormat:@"NOT (itemCode = %@)", self.itemCode];
    NSArray *lineItemsForWithoutSecondaryAndPrimaryArray = [lineItems filteredArrayUsingPredicate:lineItemsForWithoutSecondaryAndPrimaryPredicate];
    return lineItemsForWithoutSecondaryAndPrimaryArray;
}


-(CGFloat)primaryItemQty
{
    return self.primaryQty;
}

- (BOOL)isApplicableToLineItems:(NSArray*)lineItems  {
    // Check if it qualifies
    
//    NSLog(@"CalculationPricelevelbunch");

    BOOL isDiscountSchemeApplicable = NO;
    
    NSArray *lineItemsForDiscount = [self lineItemsForDiscount:lineItems];
    
    if (lineItemsForDiscount.count == 0) {
//        NSLog(@"FailedPriceLevelBunch");
        // There are no items remaining for this dicount
        return isDiscountSchemeApplicable;
    }
 
    NSMutableArray *lineItemMutableCopy = [lineItems mutableCopy];
    NSMutableArray *remainingLineItems = [[NSMutableArray alloc] init];
    NSMutableArray *applicablePrimaryItems = [[NSMutableArray alloc] init];

    self.applicableLineItems = [[NSMutableArray alloc] init];
    self.remainingLineItems = [[NSMutableArray alloc]init];
    self.applicableSecondaryItems = [[NSMutableArray alloc]init];

    
    if ([self.packageType isEqualToString:@"Case"] || [self.packageType isEqualToString:@"Pack"]) {
        NSArray *lineItemsForDiscountPackageQty = [self lineItemsForPackageType:lineItems forPackageType:self.packageType];
        if (lineItemsForDiscountPackageQty.count > 0) {
            for (LineItem *primaryLineItem in lineItemsForDiscountPackageQty) {
                [applicablePrimaryItems addObject:primaryLineItem];
                [lineItemMutableCopy removeObject:primaryLineItem];
            }
            isDiscountSchemeApplicable = TRUE;
            self.applicableLineItems = applicablePrimaryItems;
            self.remainingLineItems = lineItemMutableCopy;
            return isDiscountSchemeApplicable;
        }
    }
    
    NSArray *remaininglineItemsForDiscountSingleQty = [self lineItemsForDiscountForRemainingItems:lineItemMutableCopy];
    if (remaininglineItemsForDiscountSingleQty.count == 0) {
        //        NSLog(@"FailedPriceLevelBunch");
        // There are no items remaining for this dicount
        return isDiscountSchemeApplicable;
    }

    NSInteger totalLineItemPrimaryQty = [[remaininglineItemsForDiscountSingleQty valueForKeyPath:@"@sum.itemQty"] integerValue];
    if (totalLineItemPrimaryQty < self.primaryQty) {
//        NSLog(@"FailedPriceLevelBunch");
        return isDiscountSchemeApplicable;
    }
    

//    NSLog(@"applicablePriceLevelBunch");

    isDiscountSchemeApplicable = TRUE;
//    NSMutableArray *lineItemsForWithoutPrimary = [[self lineItemsForWithoutPrimary:lineItems] mutableCopy];
    
    
    
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemQty" ascending:NO selector:nil];
    NSArray *sortDescriptors = @[aSortDescriptor];
    NSArray  *applicableDiscountLineItemArray = [remaininglineItemsForDiscountSingleQty sortedArrayUsingDescriptors:sortDescriptors];
    
    NSSortDescriptor *bSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemBasicPrice" ascending:NO selector:nil];
    NSArray *bSortDescriptors = @[bSortDescriptor];
    applicableDiscountLineItemArray = [remaininglineItemsForDiscountSingleQty sortedArrayUsingDescriptors:bSortDescriptors];
    
    NSInteger applicablePrimaryItem = self.primaryQty;
    
    BOOL isNeedToAddInRemainingBunch = FALSE;
    
    for (LineItem *primaryLineItem in applicableDiscountLineItemArray) {
        if (applicablePrimaryItem == 0) {
            [remainingLineItems addObject:primaryLineItem];
            continue;
        }
        if (self.primaryQty == 1) {
            applicablePrimaryItem = 0;
        }
        else
        {
            applicablePrimaryItem = [self addPrimaryLineItemToBunch:primaryLineItem forApplicablePrimaryItem:applicablePrimaryItem];
        }
        
        
        LineItem *remainingPrimaryLineItem;
        if (applicablePrimaryItem < 0 ) {
            
            NSInteger applicableLineItemQty = 0;
            applicableLineItemQty = primaryLineItem.itemQty.floatValue + applicablePrimaryItem;
            
            LineItem *li = [[LineItem alloc] initWithLineItem:primaryLineItem.anItem withBillDetail:primaryLineItem.receiptDictionary withLineItemIndex:primaryLineItem.lineItemIndex];
            li.itemQty = @([[li valueForKey:@"packageQty"] floatValue] * applicableLineItemQty);
            li.totalPackageQty = @([[li valueForKey:@"itemQty"] integerValue] / [[li valueForKey:@"packageQty"] integerValue]);
            [applicablePrimaryItems addObject:li];
            
            isNeedToAddInRemainingBunch = TRUE;
            
            remainingPrimaryLineItem = [[LineItem alloc] initWithLineItem:primaryLineItem.anItem withBillDetail:primaryLineItem.receiptDictionary withLineItemIndex:primaryLineItem.lineItemIndex];
            remainingPrimaryLineItem.itemQty = @(-applicablePrimaryItem);
            remainingPrimaryLineItem.totalPackageQty = @([[remainingPrimaryLineItem valueForKey:@"itemQty"] integerValue] / [[remainingPrimaryLineItem valueForKey:@"packageQty"] integerValue]);

            
            
            
            for (LineItem *lineItem in lineItemMutableCopy) {
                if ([lineItem isEqual:primaryLineItem]) {
                    [lineItemMutableCopy removeObject:lineItem];
                    break;
                }
            }
            [lineItemMutableCopy addObject:remainingPrimaryLineItem];
            
            applicablePrimaryItem = 0;
        }
        
        if (isNeedToAddInRemainingBunch == TRUE) {
            
            if (remainingPrimaryLineItem != nil) {
                [remainingLineItems addObject:remainingPrimaryLineItem];
                continue;
            }
            [remainingLineItems addObject:primaryLineItem];
        }
        else
        {
            for (LineItem *lineItem in lineItemMutableCopy) {
                if ([lineItem isEqual:primaryLineItem]) {
                    [lineItemMutableCopy removeObject:lineItem];
                    break;
                }
            }

            [applicablePrimaryItems addObject:primaryLineItem];
        }
    }
    
    self.applicableLineItems = applicablePrimaryItems;
    self.remainingLineItems = lineItemMutableCopy;
    return isDiscountSchemeApplicable;
    
}

-(NSInteger )addPrimaryLineItemToBunch:(LineItem *)lineItem forApplicablePrimaryItem:(NSInteger)applicablePrimaryItem
{
    return applicablePrimaryItem - lineItem.itemQty.integerValue;
    
}
//- (NSMutableArray *)remaningLineItems:(NSArray *)lineItems {
//    NSArray *lineItemsForDiscount = [self lineItemsForDiscount:lineItems];
//    LineItem *lineItem = [lineItemsForDiscount firstObject];
//
//    NSMutableArray *remaningLineItems = [lineItems mutableCopy];
//    [remaningLineItems removeObject:lineItem];
//
//    NSInteger remainingQty = lineItem.itemQty.integerValue - self.discount_M.primaryItemQty.integerValue;
//
//    LineItem *li = [[LineItem alloc] initWithDictionary:@{
//                                                          @"I": lineItem.itemCode,
//                                                          @"Q": @(remainingQty)
//                                                          }];
//
//    [remaningLineItems addObject:li];
//    return remaningLineItems;
//}

//- (float)totalPrice:(MMItem*)primaryItem secondaryItem:(MMItem*)secondaryItem {
//    float totalPrice = 0.0;
//
//    if (primaryItem) {
//        totalPrice += primaryItem.singlePrice.floatValue * _primaryQty.integerValue;
//    }
//
//    return totalPrice;
//}
//
//- (float)totalDiscount:(MMItem*)primaryItem secondaryItem:(MMItem*)secondaryItem {
//    float totalDiscount = [self totalPrice:primaryItem secondaryItem:secondaryItem] * _value.floatValue / 100.0;
//
//    return totalDiscount;
//}
//
//- (float)discountedPrice:(MMItem*)primaryItem secondaryItem:(MMItem*)secondaryItem {
//    float discountedPrice = [self totalPrice:primaryItem secondaryItem:secondaryItem] - [self totalDiscount:primaryItem secondaryItem:secondaryItem];
//
//    return discountedPrice;
//}


-(float)totalPrice:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItems {
    float totalPrice = 0.0;
    for (LineItem *lineItem in primaryItems) {
        
        CGFloat lineItemTotalPrice = (lineItem.itemBasicPrice.floatValue * lineItem.itemQty.floatValue);
        lineItem.subTotal.lineItemTotalPrice = @(lineItemTotalPrice);
        totalPrice += lineItem.itemBasicPrice.floatValue * lineItem.itemQty.integerValue;
    }
    for (LineItem *lineItem in secondaryItems) {
        
        CGFloat lineItemTotalPrice =  (lineItem.itemBasicPrice.floatValue * lineItem.itemQty.floatValue);
        lineItem.subTotal.lineItemTotalPrice = @(lineItemTotalPrice);
        totalPrice += lineItem.itemBasicPrice.floatValue * lineItem.itemQty.integerValue;
    }
    //  NSLog(@"discount total price %f for discount code %@ ",totalPrice,self.discount_M.discountId);
    return totalPrice;
}

- (float)totalDiscount:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItem {
    float totalDiscount = 0.0;
    float totalPrice = 0.0;
    
    for (LineItem *lineItem in primaryItems) {
        CGFloat lineItemTotalPrice =  (lineItem.itemBasicPrice.floatValue * lineItem.itemQty.floatValue);
        CGFloat lineItemPriceLevelDiscountPrice =  ((self.applicablePrice / self.primaryQty) * lineItem.itemQty.floatValue);
        
        if (lineItemTotalPrice < 0) {
            lineItemPriceLevelDiscountPrice = -lineItemPriceLevelDiscountPrice;
        }
        
        CGFloat lineItemDiscount = lineItemTotalPrice - lineItemPriceLevelDiscountPrice;
        lineItem.subTotal.lineItemTotalDiscount = @(lineItemDiscount);
        totalPrice += lineItem.itemBasicPrice.floatValue * lineItem.itemQty.integerValue;
        totalDiscount = totalDiscount + lineItemDiscount;
    }
//    totalDiscount = totalPrice * self.discount_M.free.floatValue / 100.0;
    //   NSLog(@"discount total discount %f for discount code %@",totalDiscount,self.discount_M.discountId);
    return totalDiscount;
}
//
//
- (float)discountedPrice:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItems {
    float discountedPrice = [self totalPrice:primaryItems secondaryItems:secondaryItems] - [self totalDiscount:primaryItems secondaryItems:secondaryItems];
//    NSLog(@"PriceLevel discountedPrice %f",discountedPrice);
    return discountedPrice;
}


//- (NSString*)description {
//    return [NSString stringWithFormat:@"[Name:%@, Value:%@, primaryCode = %@ ,primaryQty = %@ , secondaryItemCode = %@ , secondaryItemQty = %@,primaryItems = %@ ,secondaryItems = %@  ]", self.name, self.value , self.primaryItemCode , self.primaryQty,self.secondaryItemCode,self.secondaryQty,self.primaryItemCodes,self.secondaryItemCodes];
//}
//

@end
