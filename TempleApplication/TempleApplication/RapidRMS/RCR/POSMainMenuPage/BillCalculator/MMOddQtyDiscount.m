//
//  MMOddQtyDiscount.m
//  RapidRMS
//
//  Created by Siya-ios5 on 9/30/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMOddQtyDiscount.h"
#import "LineItem.h"

@implementation MMOddQtyDiscount

- (NSArray *)lineItemsForDiscount:(NSArray *)lineItems {
    // Get line items for this discount
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode In %@ AND  isQtyEdited = %@ AND isRefundFromInvoice = %@ ", [[self.discount_M.primaryItems allObjects] valueForKey:@"itemId"],@(TRUE),@(0)];
    NSArray *lineItemsForDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
    return lineItemsForDiscount;
}


- (NSArray *)lineItemsForItemWithOutRefund:(NSArray *)lineItems withRefund:(BOOL)isDiscountBunchForRefund {
    // Get line items for this discount
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"isRefundItem = %@ AND isRefundFromInvoice = %@", @(isDiscountBunchForRefund),@(0)];
    NSArray *lineItemsForDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
    return lineItemsForDiscount;
}



- (NSArray *)lineItemsForWithoutPrimary:(NSArray *)lineItems {
    NSPredicate *lineItemsForWithoutSecondaryAndPrimaryPredicate = [NSPredicate predicateWithFormat:@"NOT (itemCode IN %@)", [[self.discount_M.primaryItems allObjects] valueForKey:@"itemId"]];
    NSArray *lineItemsForWithoutSecondaryAndPrimaryArray = [lineItems filteredArrayUsingPredicate:lineItemsForWithoutSecondaryAndPrimaryPredicate];
    return lineItemsForWithoutSecondaryAndPrimaryArray;
}


-(DiscountAppliedOn)discountAppliedOnForThisDiscountScheme
{
    
    DiscountAppliedOn discountAppliedOn;
    
    if (self.discount_M.isCase.boolValue == TRUE && self.discount_M.isPack.boolValue == TRUE && self.discount_M.isUnit.boolValue == TRUE) {
        discountAppliedOn = All;
    }
    else if (self.discount_M.isUnit.boolValue == TRUE)
    {
        discountAppliedOn = Single;
    }
    else if (self.discount_M.isCase.boolValue == TRUE)
    {
        discountAppliedOn = Case;
    }
    else if (self.discount_M.isPack.boolValue == TRUE)
    {
        discountAppliedOn = Pack;
    }
    else
    {
        discountAppliedOn = Single;
    }
    return discountAppliedOn;
}



-(NSMutableArray *)uniqueArrayWithItemCode:(NSArray *)sortedPackageLineItemArray
{
    NSMutableArray *itemCodesPackageLineItemArray = [[NSMutableArray alloc] init];
    
    for (LineItem *lineItem in sortedPackageLineItemArray) {
        if (![itemCodesPackageLineItemArray containsObject:lineItem.itemCode]) {
            [itemCodesPackageLineItemArray addObject:lineItem.itemCode];
        }
    }
    return itemCodesPackageLineItemArray;
}


-(CGFloat)primaryItemQty
{
    return self.discount_M.primaryItemQty.floatValue;
}

-(BOOL)isPriceSortingAscendingwithRefund:(BOOL)isDiscountBunchForRefund
{
    BOOL isAscending = NO;
    
    if (self.discount_M == nil) {
        if (isDiscountBunchForRefund == TRUE) {
            isAscending = YES;
        }
    }
    else
    {
        if (self.discount_M.freeType.integerValue == Amount) {
            isAscending = NO;
        }
        
        if (isDiscountBunchForRefund == TRUE) {
            isAscending = YES;
            if (self.discount_M.freeType.integerValue == Amount) {
                isAscending = YES;
            }
        }
    }
    return isAscending;
}


-(NSMutableArray *)applyDiscountForTotalLineItems:(NSMutableArray *)totalLineItems withApplicableLineItem:(NSArray *)lineItems withRefund:(BOOL)isDiscountBunchForRefund withPackageType:(NSString *)packageType withPackageQty:(NSString *)packageQty withDiscountArray:(NSMutableArray *)discountArray
{
    
    //    NSInteger applicablePackageQty = self.discount_M.primaryItemQty.floatValue;
    //NSLog(@"Calculation bunch");
    
    CGFloat applicablePackageQty = [self primaryItemQty];
//    CGFloat appliedPackageQty = 0;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DiscountCode = %@",self.discount_M.code];
    NSArray *discountCodeFilterDictionary = [discountArray filteredArrayUsingPredicate:predicate];
    NSMutableDictionary *discountDictionary = [[discountCodeFilterDictionary firstObject] mutableCopy];
    CGFloat numberOfTimeDiscountApplied = [discountDictionary[@"DiscountApplied"] floatValue] ;
  
    CGFloat appliedPackageQty = numberOfTimeDiscountApplied;

    
    
    NSMutableArray *totalLineItemMutableCopy = [totalLineItems mutableCopy];
    
    lineItems = [self lineItemsForItemWithOutRefund:lineItems withRefund:isDiscountBunchForRefund];
    if (lineItems.count == 0) {
        //    NSLog(@"Falied");
        return totalLineItems;
    }
    
    if (self.discount_M == nil) {
        NSInteger totalLineItemPrimaryQty = [[lineItems valueForKeyPath:@"@sum.itemQty"] integerValue];
        if (totalLineItemPrimaryQty < applicablePackageQty) {
            return totalLineItems;
        }
    }
    
  
    BOOL isAscending = [self isPriceSortingAscendingwithRefund:isDiscountBunchForRefund];
    
    NSSortDescriptor *lineItemMaximumPriceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:packageType ascending:isAscending selector:nil];
    NSSortDescriptor *lineItemItemCodeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemCode" ascending:NO selector:nil];
    NSSortDescriptor *lineItemItemQtySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemQty" ascending:NO selector:nil];
    
    NSArray *lineItemMaximumPriceSortDescriptors = @[lineItemMaximumPriceSortDescriptor,lineItemItemCodeSortDescriptor,lineItemItemQtySortDescriptor];
    
    NSArray *sortedPackageLineItemArray = [lineItems sortedArrayUsingDescriptors:lineItemMaximumPriceSortDescriptors];

    
    
    if ([packageType isEqualToString:@"singlePrice"]) {
        
        NSInteger totalLineItemPrimaryQty = [[lineItems valueForKeyPath:@"@sum.itemQty"] integerValue];
        if (totalLineItemPrimaryQty >= applicablePackageQty)
        {
            NSMutableArray *applicablePrimaryItemsArray = [[NSMutableArray alloc] init];
            for (LineItem *lineItem in sortedPackageLineItemArray) {
                if (self.discount_M.qtyLimit.floatValue != 0 && appliedPackageQty >= (self.discount_M.qtyLimit.floatValue * self.discount_M.primaryItemQty.floatValue)) {
                    continue;
                }
             
                if (self.discount_M.qtyLimit.floatValue == 0) {
                    [applicablePrimaryItemsArray addObject:lineItem];
                    [totalLineItemMutableCopy removeObject:lineItem];
                    continue;
                }
                CGFloat qty = self.discount_M.qtyLimit.floatValue * self.discount_M.primaryItemQty.floatValue - appliedPackageQty;
                qty = qty - lineItem.itemQty.floatValue;
                if (qty >= 0) {
                    [applicablePrimaryItemsArray addObject:lineItem];
                    [totalLineItemMutableCopy removeObject:lineItem];
                }
                else
                {
                    LineItem *li = [[LineItem alloc] initWithLineItem:lineItem.anItem withBillDetail:lineItem.receiptDictionary withLineItemIndex:lineItem.lineItemIndex];
                    li.itemQty = @(lineItem.itemQty.floatValue + qty);
                    li.totalPackageQty = @([[li valueForKey:@"itemQty"] integerValue] / [[li valueForKey:@"packageQty"] integerValue]);

                    [applicablePrimaryItemsArray addObject:li];
                    
                    LineItem  *remainingPrimaryLineItem = [[LineItem alloc] initWithLineItem:lineItem.anItem withBillDetail:lineItem.receiptDictionary withLineItemIndex:lineItem.lineItemIndex];
                    remainingPrimaryLineItem.itemQty = @(-qty);
                    remainingPrimaryLineItem.totalPackageQty = @([[remainingPrimaryLineItem valueForKey:@"itemQty"] integerValue] / [[remainingPrimaryLineItem valueForKey:@"packageQty"] integerValue]);

                    [totalLineItemMutableCopy addObject:remainingPrimaryLineItem];
                    [totalLineItemMutableCopy removeObject:lineItem];
                }
               appliedPackageQty = appliedPackageQty + lineItem.itemQty.floatValue;
            }
            
            if (isDiscountBunchForRefund == FALSE) {
                self.applicableLineItems = applicablePrimaryItemsArray;
            }
            else
            {
                self.applicableRefundLineItems = applicablePrimaryItemsArray;
            }

            [discountArray removeObject:[discountCodeFilterDictionary firstObject]];
            [discountDictionary setObject:@(appliedPackageQty) forKey:@"DiscountApplied"];
            [discountArray addObject:discountDictionary];
            self.updatedDiscountDictionaryArray = discountArray;

            totalLineItems = totalLineItemMutableCopy;
        }
        return totalLineItems;
    }

    
    NSMutableArray *itemCodesPackageLineItemArray = [self uniqueArrayWithItemCode:sortedPackageLineItemArray];
    NSMutableArray *applicableLineItemsForDiscount = [[NSMutableArray alloc] init];
    
    
    for (NSNumber *itemCode in itemCodesPackageLineItemArray) {
        if (self.discount_M.qtyLimit.floatValue != 0 &&  appliedPackageQty  >= self.discount_M.qtyLimit.floatValue) {
            continue;
        }
        NSPredicate *lineItemWithItemCode = [NSPredicate predicateWithFormat:@"itemCode = %@", itemCode];
        NSMutableArray *lineItemWithItemCodeArray = [[sortedPackageLineItemArray filteredArrayUsingPredicate:lineItemWithItemCode] mutableCopy];
        
        NSInteger totalItemQty = 0;
        
        NSMutableArray *applicableLineItems = [[NSMutableArray alloc] init];
        
        for (LineItem *lineItem in lineItemWithItemCodeArray) {
            
            if (self.discount_M.qtyLimit.floatValue != 0 && appliedPackageQty >= self.discount_M.qtyLimit.floatValue) {
                continue;
            }
            
            totalItemQty += lineItem.itemQty.floatValue;
            NSInteger totalPackageQtyForItem = totalItemQty / [[lineItem valueForKey:packageQty] floatValue];
            NSInteger remainingItemQty  ;
            
            if (totalPackageQtyForItem != 0) {
                
                NSInteger appliedPackageQty = totalPackageQtyForItem;
                if (totalPackageQtyForItem > applicablePackageQty) {
                    appliedPackageQty = applicablePackageQty;
                }
                remainingItemQty =  [[lineItem valueForKey:packageQty] floatValue]  * appliedPackageQty - totalItemQty ;
            }
            else
            {
                remainingItemQty =  [[lineItem valueForKey:packageQty] floatValue] - totalItemQty ;
            }
            
            
            if (remainingItemQty < 0) {
                
                [applicableLineItems addObject:lineItem];
                
                appliedPackageQty = appliedPackageQty + totalPackageQtyForItem;
                totalItemQty = -remainingItemQty;
                
                
                NSInteger applicableLineItemQty = lineItem.itemQty.floatValue + remainingItemQty;
                
                LineItem *li = [[LineItem alloc] initWithLineItem:lineItem.anItem withBillDetail:lineItem.receiptDictionary withLineItemIndex:lineItem.lineItemIndex];
                li.itemQty = @([[li valueForKey:@"packageQty"] floatValue] * applicableLineItemQty);
                li.totalPackageQty = @([[li valueForKey:@"itemQty"] integerValue] / [[li valueForKey:@"packageQty"] integerValue]);

                [applicableLineItemsForDiscount addObject:li];
                
                LineItem  *remainingPrimaryLineItem = [[LineItem alloc] initWithLineItem:lineItem.anItem withBillDetail:lineItem.receiptDictionary withLineItemIndex:lineItem.lineItemIndex];
                remainingPrimaryLineItem.itemQty = @(-remainingItemQty);
                remainingPrimaryLineItem.totalPackageQty = @([[remainingPrimaryLineItem valueForKey:@"itemQty"] integerValue] / [[remainingPrimaryLineItem valueForKey:@"packageQty"] integerValue]);

                [totalLineItemMutableCopy addObject:remainingPrimaryLineItem];
                
                for (LineItem *applicableLineItem in applicableLineItems) {
                    for (LineItem *lineItemForRemove in totalLineItemMutableCopy) {
                        if ([lineItemForRemove isEqual:applicableLineItem])
                        {
                            [totalLineItemMutableCopy removeObject:lineItemForRemove];
                            break;
                        }
                    }
                    
                    if (applicableLineItem != lineItem  ) {
                        [applicableLineItemsForDiscount addObject:applicableLineItem];
                    }
                }
                [applicableLineItems removeAllObjects];
                [applicableLineItems addObject:remainingPrimaryLineItem];
            }
            else if (remainingItemQty == 0)
            {
                [applicableLineItems addObject:lineItem];
                appliedPackageQty = appliedPackageQty + totalPackageQtyForItem;
                
                for (LineItem *applicableLineItem in applicableLineItems) {
                    
                    for (LineItem *lineItem in totalLineItemMutableCopy) {
                        if ([lineItem isEqual:applicableLineItem])
                        {
                            [totalLineItemMutableCopy removeObject:lineItem];
                            break;
                        }
                    }
                    [applicableLineItemsForDiscount addObject:applicableLineItem];
                }
                [applicableLineItems removeAllObjects];
                totalItemQty = 0;
            }
            else
            {
                [applicableLineItems addObject:lineItem];
            }
        }
        
    }
    
    if (appliedPackageQty >= applicablePackageQty ) {
        //  NSLog(@"applicable bunch");
        
        [discountArray removeObject:[discountCodeFilterDictionary firstObject]];
        [discountDictionary setObject:@(appliedPackageQty) forKey:@"DiscountApplied"];
        [discountArray addObject:discountDictionary];
        self.updatedDiscountDictionaryArray = discountArray;
        if (isDiscountBunchForRefund == FALSE) {
            self.applicableLineItems = applicableLineItemsForDiscount;
        }
        else
        {
            self.applicableRefundLineItems = applicableLineItemsForDiscount;
        }
        totalLineItems = totalLineItemMutableCopy;
    }
    else
    {
        //  NSLog(@"need to address this");
    }
    
    return totalLineItems;
}





- (BOOL)isApplicableToLineItems:(NSArray*)lineItems withDiscountArray:(NSMutableArray *)discountArray  {
    // Check if it qualifies
    BOOL isDiscountSchemeApplicable = NO;
    
    self.applicableLineItems = [[NSMutableArray alloc] init];
    self.remainingLineItems = [[NSMutableArray alloc]init];
    self.applicableSecondaryItems = [[NSMutableArray alloc]init];
    self.applicableRefundLineItems = [[NSMutableArray alloc] init];
    self.updatedDiscountDictionaryArray = [[NSMutableArray alloc] init];

    
    // This condition is for check whether this bill contain enough primary items to apply qty discount........Here we do not have include the item with swipe or edited price.....
    
    NSArray *lineItemsForDiscount = [self lineItemsForDiscount:lineItems];
    if (lineItemsForDiscount.count == 0) {
        // There are no items remaining for this discount
        return isDiscountSchemeApplicable;
    }
    
    /// This condition is for to check the discount type. We have predifine enum for this discount type which are mention in this file.......
    DiscountAppliedOn discountAppliedOn = [self discountAppliedOnForThisDiscountScheme];
    
    NSString *packageType = @"";
    NSString *packageQty = @"";
    
    if (discountAppliedOn == All) {
        packageType = @"singlePrice";
        packageQty = @"singleQty";
        
    }
    else if (discountAppliedOn == Case)
    {
        packageType = @"casePrice";
        packageQty = @"caseQty";
        
    }
    else if (discountAppliedOn == Pack)
    {
        discountAppliedOn = Pack;
        packageType = @"packPrice";
        packageQty = @"packQty";
    }
    else
    {
        discountAppliedOn = Single;
        packageType = @"singlePrice";
        packageQty = @"singleQty";
        
    }
    
    
    /// Here we have two parts for discount apply.... We have two seprate methods for create discount bunch...One is for case and pack and the other one is one for single...
    
    //    if (![packageType isEqualToString:@"singlePrice"]) {
    NSArray *performDiscountStepArray = [NSArray arrayWithObjects:@(FALSE),@(TRUE), nil];
    NSMutableArray *totalLineItems = [lineItems mutableCopy];
    
    for (NSNumber *discountCheckCondition in performDiscountStepArray) {
        totalLineItems = [self applyDiscountForTotalLineItems:totalLineItems withApplicableLineItem:lineItemsForDiscount withRefund:discountCheckCondition.boolValue withPackageType:packageType withPackageQty:packageQty withDiscountArray:discountArray];
    }
    
    if (self.applicableLineItems.count > 0 || self.applicableRefundLineItems.count > 0) {
        self.remainingLineItems = totalLineItems;
        isDiscountSchemeApplicable = TRUE;
    }
    return isDiscountSchemeApplicable;

    
}


-(float)totalPriceForLineItem:(NSArray *)primaryItems
{
    float totalPrice = 0.0;
    
    for (LineItem *lineItem in primaryItems) {
        CGFloat lineItemTotalPrice =  (lineItem.itemBasicPrice.floatValue * lineItem.itemQty.integerValue);
        totalPrice += lineItemTotalPrice;
    }
    
    return totalPrice;
}
-(float)calculateAmountForDiscount:(NSArray *)primaryItems
{
    float totalDiscountAmountFor = 0.0;
    float totalPriceAmountFor = 0.0;
    
    for (LineItem *lineItem in primaryItems) {
        CGFloat lineItemTotalPrice =  (lineItem.itemBasicPrice.floatValue * lineItem.itemQty.floatValue);
        CGFloat lineItemPriceLevelDiscountPrice =  ((self.discount_M.free.floatValue / self.discount_M.primaryItemQty.floatValue) * lineItem.itemQty.floatValue);
        
        if (lineItemTotalPrice < 0) {
            lineItemPriceLevelDiscountPrice = -lineItemPriceLevelDiscountPrice;
        }
        
        CGFloat lineItemDiscount = lineItemTotalPrice - lineItemPriceLevelDiscountPrice;
        lineItem.subTotal.lineItemTotalDiscount = @(lineItemDiscount);
        totalPriceAmountFor += lineItem.itemBasicPrice.floatValue * lineItem.itemQty.integerValue;
        totalDiscountAmountFor = totalDiscountAmountFor + lineItemDiscount;
    }
    return totalDiscountAmountFor;
}


- (float)totalDiscount:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItem {
    
    if (self.discount_M.freeType.integerValue == Percentage || self.discount_M.freeType.integerValue == Free)
    {
        return [super totalDiscount:primaryItems secondaryItems:secondaryItem];
    }
    
    if (self.discount_M.discountType.integerValue == AmountFor) {
        return [self calculateAmountForDiscount:primaryItems];
    }
    
    
    CGFloat totalNumberOfTimeDiscountApplied = 0.0;
    NSSet *itemSet = [NSSet setWithArray:[primaryItems valueForKey:@"itemCode"]];
    for (NSNumber *itemCode in itemSet.allObjects) {
        NSPredicate *lineItemWithItemCode = [NSPredicate predicateWithFormat:@"itemCode = %@", itemCode];
        NSArray *lineItemWithItemCodeArray = [primaryItems filteredArrayUsingPredicate:lineItemWithItemCode];
        NSInteger totalLineItemSecondaryQty = [[lineItemWithItemCodeArray valueForKeyPath:@"@sum.itemQty"] integerValue];
        
        DiscountAppliedOn discountAppliedOn = [self discountAppliedOnForThisDiscountScheme];
        
        NSString *packageQty = @"";
        
        if (discountAppliedOn == All) {
            packageQty = @"singleQty";
        }
        else if (discountAppliedOn == Case)
        {
            packageQty = @"caseQty";
        }
        else if (discountAppliedOn == Pack)
        {
            packageQty = @"packQty";
        }
        else
        {
            packageQty = @"singleQty";
        }
        totalNumberOfTimeDiscountApplied += (totalLineItemSecondaryQty / [[[lineItemWithItemCodeArray firstObject] valueForKey:packageQty] integerValue])/ self.discount_M.primaryItemQty.floatValue ;
    }
    
    
//    NSInteger totalLineItemSecondaryQty = [[primaryItems valueForKeyPath:@"@sum.itemQty"] integerValue];
//    NSLog(@"total discount qty %ld ",(long)totalLineItemSecondaryQty);
//    NSLog(@"total number of time discount applied is %ld ",(long)totalNumberOfTimeDiscountApplied);
//    NSLog(@"total discount applied is %f ",(totalNumberOfTimeDiscountApplied * self.discount_M.free.floatValue));

    CGFloat totalDiscount = 0.0;
    float totalPrice = [self totalPriceForLineItem:primaryItems];

    if (self.discount_M.freeType.integerValue == Amount || self.discount_M.freeType.integerValue == AmountFor) {
        
        if (self.discount_M.freeType.integerValue == AmountFor)
        {
            if (totalPrice >= self.discount_M.free.floatValue)
            {
                totalDiscount = totalPrice - self.discount_M.free.floatValue * totalNumberOfTimeDiscountApplied;
            }
        }
        else
        {
            totalDiscount =  self.discount_M.free.floatValue * totalNumberOfTimeDiscountApplied;
        }
        
        
        if (totalPrice > 0 && totalPrice < totalDiscount) {
            totalDiscount = totalPrice;
        }
        else if (totalPrice < 0)
        {
            CGFloat  totalPriceTemp = -totalPrice;
            if (self.discount_M.freeType.integerValue == AmountFor) {
                if (totalPriceTemp >= self.discount_M.free.floatValue) {
                    totalDiscount = totalPriceTemp - self.discount_M.free.floatValue * totalNumberOfTimeDiscountApplied;
                }
            }
            else
            {
                totalDiscount =  self.discount_M.free.floatValue * totalNumberOfTimeDiscountApplied;
            }
            
            if (totalPriceTemp < totalDiscount) {
                totalDiscount = totalPrice;
            }
            else
            {
                totalDiscount = -totalDiscount;
            }
        }
    }
    
    for (LineItem *lineItem in primaryItems) {
        CGFloat lineItemTotalPrice =  (lineItem.itemBasicPrice.floatValue * lineItem.itemQty.integerValue);
        if (totalPrice == 0)
        {
            lineItem.subTotal.lineItemTotalDiscount = @(0) ;
        }
        else
        {
            lineItem.subTotal.lineItemTotalDiscount = @(( lineItemTotalPrice / totalPrice)  * totalDiscount);
        }
    }
    
    return totalDiscount;
}
//
//
- (float)discountedPrice:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItems {
    float discountedPrice = 0.00;
    if (self.discount_M.freeType.integerValue == Percentage || self.discount_M.freeType.integerValue == Free)
    {
        discountedPrice = [super totalPrice:primaryItems secondaryItems:secondaryItems] - [super totalDiscount:primaryItems secondaryItems:secondaryItems];
    }
    else if (self.discount_M.freeType.integerValue == AmountFor)
    {
        discountedPrice = [super totalPrice:primaryItems secondaryItems:secondaryItems] - [self calculateAmountForDiscount:primaryItems];
    }
    else
    {
        discountedPrice = [super totalPrice:primaryItems secondaryItems:secondaryItems] - [self totalDiscount:primaryItems secondaryItems:secondaryItems];
    }
    return discountedPrice;
}

@end
