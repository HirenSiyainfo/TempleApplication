//
//  MMDiscount.m
//  RapidRMS
//
//  Created by siya-IOS5 on 2/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDiscount.h"
#import "LineItem.h"
#import "Item_Price_MD+Dictionary.h"


@implementation MMDiscount


- (instancetype)initWithDiscountM:(Discount_M*)discount_M
{
    self = [super init];
    if (self) {
        self.discount_M = discount_M;
        self.discountName = discount_M.code;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        self.discountName = dictionary[@"Name"];

        }
    return self;
}

- (NSArray *)lineItemsForPackageType:(NSArray *)lineItems forPackageType:(NSString *)packageType {
    // Get line items for this discount
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"packageType = %@ AND isQtyEdited = %@", packageType,@(TRUE)];
    NSArray *lineItemsForDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
    return lineItemsForDiscount;
}


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


-(NSMutableArray *)applyDiscountForTotalLineItems:(NSMutableArray *)totalLineItems withApplicableLineItem:(NSArray *)lineItems withRefund:(BOOL)isDiscountBunchForRefund withPackageType:(NSString *)packageType withPackageQty:(NSString *)packageQty
{
    
//    NSInteger applicablePackageQty = self.discount_M.primaryItemQty.floatValue;
    //NSLog(@"Calculation bunch");
    
    CGFloat applicablePackageQty = [self primaryItemQty];

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
  
    /* if (self.discount_M.freeType.integerValue == Amount) {
        isAscending = YES;
    }
    
    if (isDiscountBunchForRefund == TRUE) {
          isAscending = YES;
        if (self.discount_M.freeType.integerValue == Amount) {
            isAscending = NO;
        }
    }*/
    
    DiscountAppliedOn discountAppliedOn = [self discountAppliedOnForThisDiscountScheme];
    
    NSString *packageTypeForDiscount = @"";
    
    if (discountAppliedOn == All) {
        packageTypeForDiscount = @"Single Item";
    }
    else if (discountAppliedOn == Case)
    {
        packageTypeForDiscount = @"Case";

    }
    else if (discountAppliedOn == Pack)
    {
        packageTypeForDiscount = @"Pack";
    }
    else
    {
        packageTypeForDiscount = @"Single Item";
    }
    
    NSMutableArray *applicableLineItemsForDiscount = [[NSMutableArray alloc] init];

    NSMutableArray *applicableLineItems = [[NSMutableArray alloc] init];

    if ([packageTypeForDiscount isEqualToString:@"Case"] || [packageTypeForDiscount isEqualToString:@"Pack"]) {
        NSArray *lineItemsForDiscountPackageQty = [self lineItemsForPackageType:lineItems forPackageType:packageTypeForDiscount];
        
        NSSortDescriptor *lineItemMaximumPriceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:packageType ascending:isAscending selector:nil];
        NSSortDescriptor *lineItemItemCodeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemCode" ascending:NO selector:nil];
        NSSortDescriptor *lineItemItemQtySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemQty" ascending:NO selector:nil];
        
        NSArray *lineItemMaximumPriceSortDescriptors = @[lineItemMaximumPriceSortDescriptor,lineItemItemCodeSortDescriptor,lineItemItemQtySortDescriptor];
        
        NSArray *sortedPackageLineItemArray = [lineItemsForDiscountPackageQty sortedArrayUsingDescriptors:lineItemMaximumPriceSortDescriptors];
        
        NSInteger remainingPackageQty = 0;
        
        if (sortedPackageLineItemArray.count > 0) {
            for (LineItem *primaryLineItem in sortedPackageLineItemArray) {
                if (applicablePackageQty <= 0) {
                    continue;
                }
                remainingPackageQty = applicablePackageQty - ([[primaryLineItem valueForKey:@"itemQty"] floatValue] / [[primaryLineItem valueForKey:@"packageQty"] floatValue]);
                
                if (remainingPackageQty < 0) {
                    
                    [applicableLineItems addObject:primaryLineItem];
                    
                    applicablePackageQty = applicablePackageQty - ([[primaryLineItem valueForKey:@"itemQty"] floatValue] / [[primaryLineItem valueForKey:@"packageQty"] floatValue]);
                    
                    
                    NSInteger applicableLineItemQty = ([[primaryLineItem valueForKey:@"itemQty"] floatValue] / [[primaryLineItem valueForKey:@"packageQty"] floatValue]) + remainingPackageQty;
                    
                    LineItem *li = [[LineItem alloc] initWithLineItem:primaryLineItem.anItem withBillDetail:primaryLineItem.receiptDictionary withLineItemIndex:primaryLineItem.lineItemIndex];
                    li.itemQty = @([[li valueForKey:@"packageQty"] floatValue] * applicableLineItemQty);
                    li.totalPackageQty = @([[li valueForKey:@"itemQty"] integerValue] / [[li valueForKey:@"packageQty"] integerValue]);

                    [applicableLineItemsForDiscount addObject:li];
                    
                    
                    LineItem  *remainingPrimaryLineItem = [[LineItem alloc] initWithLineItem:primaryLineItem.anItem withBillDetail:primaryLineItem.receiptDictionary withLineItemIndex:primaryLineItem.lineItemIndex];
                    remainingPrimaryLineItem.itemQty = @([[primaryLineItem valueForKey:@"packageQty"] floatValue] * -remainingPackageQty);
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
                        if (applicableLineItem != primaryLineItem  ) {
                            [applicableLineItemsForDiscount addObject:applicableLineItem];
                        }
                    }
                    [applicableLineItems removeAllObjects];
                    [applicableLineItems addObject:remainingPrimaryLineItem];
                    
                }
                else if (remainingPackageQty == 0)
                {
                    [applicableLineItems addObject:primaryLineItem];
                    applicablePackageQty = applicablePackageQty - ([[primaryLineItem valueForKey:@"itemQty"] floatValue] / [[primaryLineItem valueForKey:@"packageQty"] floatValue]);
                    
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
                }
                else
                {
                    applicablePackageQty = applicablePackageQty - ([[primaryLineItem valueForKey:@"itemQty"] floatValue] / [[primaryLineItem valueForKey:@"packageQty"] floatValue]);
                    [applicableLineItems addObject:primaryLineItem];
                }
            }
        }
        
        if (applicablePackageQty <= 0 )
        {
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
              NSLog(@"need to address this");
        }
        return totalLineItems;
    }
    



    NSArray *remaininglineItemsForDiscountSingleQty = [self lineItemsForPackageType:lineItems forPackageType:packageTypeForDiscount];
    
    NSSortDescriptor *lineItemMaximumPriceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:packageType ascending:isAscending selector:nil];
    NSSortDescriptor *lineItemItemCodeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemCode" ascending:NO selector:nil];
    NSSortDescriptor *lineItemItemQtySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemQty" ascending:NO selector:nil];
    
    NSArray *lineItemMaximumPriceSortDescriptors = @[lineItemMaximumPriceSortDescriptor,lineItemItemCodeSortDescriptor,lineItemItemQtySortDescriptor];
    
    NSArray *sortedPackageLineItemArray = [remaininglineItemsForDiscountSingleQty sortedArrayUsingDescriptors:lineItemMaximumPriceSortDescriptors];
    NSMutableArray *itemCodesPackageLineItemArray = [self uniqueArrayWithItemCode:sortedPackageLineItemArray];
    
    
    
    for (NSNumber *itemCode in itemCodesPackageLineItemArray) {
        
        if (applicablePackageQty <= 0) {
            continue;
        }
        
        NSPredicate *lineItemWithItemCode = [NSPredicate predicateWithFormat:@"itemCode = %@", itemCode];
        NSArray *lineItemWithItemCodeArray = [sortedPackageLineItemArray filteredArrayUsingPredicate:lineItemWithItemCode];
        
        NSInteger totalItemQty = 0;
        
        NSMutableArray *applicableLineItems = [[NSMutableArray alloc] init];
        
        for (LineItem *lineItem in lineItemWithItemCodeArray) {
            
            if (applicablePackageQty <= 0) {
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
                
                applicablePackageQty = applicablePackageQty - totalPackageQtyForItem;
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
                applicablePackageQty = applicablePackageQty - totalPackageQtyForItem;

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
    
    if (applicablePackageQty <= 0 ) {
      //  NSLog(@"applicable bunch");
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

- (BOOL)isApplicableToLineItems:(NSArray*)lineItems  {
    // Check if it qualifies
    BOOL isDiscountSchemeApplicable = NO;
    
    self.applicableLineItems = [[NSMutableArray alloc] init];
    self.remainingLineItems = [[NSMutableArray alloc]init];
    self.applicableSecondaryItems = [[NSMutableArray alloc]init];
    self.applicableRefundLineItems = [[NSMutableArray alloc] init];
    
    
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
            totalLineItems = [self applyDiscountForTotalLineItems:totalLineItems withApplicableLineItem:lineItemsForDiscount withRefund:discountCheckCondition.boolValue withPackageType:packageType withPackageQty:packageQty];
        }
        
        if (self.applicableLineItems.count > 0 || self.applicableRefundLineItems.count > 0) {
            self.remainingLineItems = totalLineItems;
            isDiscountSchemeApplicable = TRUE;
        }
        return isDiscountSchemeApplicable;
    
}

-(NSInteger )addPrimaryLineItemToBunch:(LineItem *)lineItem forApplicablePrimaryItem:(NSInteger)applicablePrimaryItem
{
    return applicablePrimaryItem - lineItem.itemQty.integerValue;
    
}


-(float)totalPrice:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItems {
    float totalPrice = 0.0;
    for (LineItem *lineItem in primaryItems) {
     
        CGFloat lineItemTotalPrice = (lineItem.itemBasicPrice.floatValue * lineItem.itemQty.integerValue);
        lineItem.subTotal.lineItemTotalPrice = @(lineItemTotalPrice);
        totalPrice += lineItem.itemBasicPrice.floatValue * lineItem.itemQty.integerValue;
    }
    for (LineItem *lineItem in secondaryItems) {
        
        CGFloat lineItemTotalPrice =  (lineItem.itemBasicPrice.floatValue * lineItem.itemQty.integerValue);
        lineItem.subTotal.lineItemTotalPrice = @(lineItemTotalPrice);
        totalPrice += lineItem.itemBasicPrice.floatValue * lineItem.itemQty.integerValue;
    }
   //  NSLog(@"discount total price %f for discount code %@ ",totalPrice,self.discount_M.discountId);
    return totalPrice;
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

- (float)totalDiscount:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItem {
    
    
    float totalPrice = [self totalPriceForLineItem:primaryItems];
    float totalDiscount = 0.00;
    
    
    if (self.discount_M.freeType.integerValue == AmountAt) {
        for (LineItem *lineItem in primaryItems) {
            float itemBasicPrice = lineItem.itemBasicPrice.floatValue;
            if (itemBasicPrice < 0 ) {
                itemBasicPrice = -itemBasicPrice;
            }
            if (itemBasicPrice >= self.discount_M.free.floatValue ) {
                totalDiscount = (itemBasicPrice - self.discount_M.free.floatValue) * lineItem.itemQty.integerValue;
                lineItem.subTotal.lineItemTotalDiscount = @(totalDiscount) ;
                if (lineItem.itemBasicPrice.floatValue < 0) {
                    lineItem.subTotal.lineItemTotalDiscount = @(-totalDiscount );
                    
                }
            }
            else
            {
                lineItem.subTotal.lineItemTotalDiscount = @(0) ;
            }
            
        }
    }
    else
    {
        if (self.discount_M.freeType.integerValue == Amount || self.discount_M.freeType.integerValue == AmountFor) {
            if (self.discount_M.freeType.integerValue == AmountFor) {
                if (totalPrice >= self.discount_M.free.floatValue) {
                    totalDiscount = totalPrice - self.discount_M.free.floatValue;
                }
            }
            else{
                totalDiscount =  self.discount_M.free.floatValue;
            }
            
            
            if (totalPrice > 0 && totalPrice < totalDiscount) {
                totalDiscount = totalPrice;
            }
            else if (totalPrice < 0)
            {
                CGFloat  totalPriceTemp = -totalPrice;
                if (self.discount_M.freeType.integerValue == AmountFor) {
                    if (totalPriceTemp >= self.discount_M.free.floatValue) {
                        totalDiscount = totalPriceTemp - self.discount_M.free.floatValue;
                    }
                }
                else{
                    totalDiscount =  self.discount_M.free.floatValue;
                }
                
                if (totalPriceTemp < totalDiscount) {
                    totalDiscount = totalPrice;
                }
                else{
                    totalDiscount = -totalDiscount;
                }
            }
        }
        
        if (self.discount_M.freeType.integerValue == Percentage || self.discount_M.freeType.integerValue == Free) {
            totalDiscount = totalPrice * self.discount_M.free.floatValue / 100.0;
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
    }
    
    
    return totalDiscount;
}
//
//
- (float)discountedPrice:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItems {
    float discountedPrice = [self totalPrice:primaryItems secondaryItems:secondaryItems] - [self totalDiscount:primaryItems secondaryItems:secondaryItems];
//    NSLog(@"MMDiscount discountedPrice %f",discountedPrice);
    return discountedPrice;
}


//- (NSString*)description {
//    return [NSString stringWithFormat:@"[Name:%@, Value:%@, primaryCode = %@ ,primaryQty = %@ , secondaryItemCode = %@ , secondaryItemQty = %@,primaryItems = %@ ,secondaryItems = %@  ]", self.name, self.value , self.primaryItemCode , self.primaryQty,self.secondaryItemCode,self.secondaryQty,self.primaryItemCodes,self.secondaryItemCodes];
//}
//


@end
