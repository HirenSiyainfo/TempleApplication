//
//  MMDiscountGroup.m
//  RapidRMS
//
//  Created by siya-IOS5 on 2/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDiscountGroup.h"
#import "LineItem.h"

@interface MMDiscountGroup ()
{
    NSString *packageTypeForDiscount;
}

@end

@implementation MMDiscountGroup


//- (NSArray*)lineItemsForCondition:(NSArray *)lineItems {
//    // Get line items for this discount
//    NSPredicate *conditionPredicate = [NSPredicate predicateWithFormat:@"itemCode In %@", [[self.discount_M.secondaryItems allObjects] valueForKey:@"itemId"]];
//    NSArray *lineItemsForCondition = [lineItems filteredArrayUsingPredicate:conditionPredicate];
//    
//    return lineItemsForCondition;
//}


- (NSArray*)lineItemsForCondition:(NSArray *)lineItems withRefund:(BOOL)isDiscountBunchForRefund {
    // Get line items for this discount
    NSPredicate *conditionPredicate = [NSPredicate predicateWithFormat:@"itemCode In %@ AND isRefundItem = %@ AND isQtyEdited = %@ AND isRefundFromInvoice = %@ AND packageType = %@", [[self.discount_M.secondaryItems allObjects] valueForKey:@"itemId"],@(isDiscountBunchForRefund),@(TRUE),@(0),packageTypeForDiscount];
    NSArray *lineItemsForCondition = [lineItems filteredArrayUsingPredicate:conditionPredicate];
    
    return lineItemsForCondition;
}


//- (NSArray *)lineItemsForDiscount:(NSArray *)lineItems {
//    // Get line items for this  discount
//    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode In %@ AND isQtyEdited = %@", [[self.discount_M.primaryItems allObjects] valueForKey:@"itemId"],@(TRUE)];
//    NSArray *lineItemsForDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
//    return lineItemsForDiscount;
//}


- (NSArray *)lineItemsForDiscount:(NSArray *)lineItems withRefund:(BOOL)isDiscountBunchForRefund {
    // Get line items for this  discount
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode In %@ AND isQtyEdited = %@ AND isRefundItem = %@ AND isRefundFromInvoice = %@ AND packageType = %@", [[self.discount_M.primaryItems allObjects] valueForKey:@"itemId"],@(TRUE),@(isDiscountBunchForRefund),@(0),packageTypeForDiscount];
    NSArray *lineItemsForDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
    return lineItemsForDiscount;
}



//- (NSArray *)lineItemsForWithoutSecondaryAndPrimary:(NSArray *)lineItems {
//    NSPredicate *lineItemsForWithoutSecondaryAndPrimaryPredicate = [NSPredicate predicateWithFormat:@"NOT (itemCode IN %@) AND NOT (itemCode IN %@)",[[self.discount_M.primaryItems allObjects] valueForKey:@"itemId"],[[self.discount_M.secondaryItems allObjects] valueForKey:@"itemId"]];
//    NSArray *lineItemsForWithoutSecondaryAndPrimaryArray = [lineItems filteredArrayUsingPredicate:lineItemsForWithoutSecondaryAndPrimaryPredicate];
//    return lineItemsForWithoutSecondaryAndPrimaryArray;
//}

-(NSArray *)isCaseForSameItemsForTotalItem:(NSMutableArray *)totalLineItems withRefund:(BOOL)isDiscountBunchForRefund
{
    
    NSPredicate *lineItemsArrayPredicate = [NSPredicate predicateWithFormat:@"itemCode In %@ AND itemCode In %@ AND isRefundItem = %@ AND isRefundFromInvoice = %@ AND packageType = %@" ,[[self.discount_M.primaryItems allObjects] valueForKey:@"itemId"],[[self.discount_M.secondaryItems allObjects] valueForKey:@"itemId"] , @(isDiscountBunchForRefund),@(0),packageTypeForDiscount];
    
    NSArray *lineItemsWhichInPrimaryAndSecondary = [totalLineItems filteredArrayUsingPredicate:lineItemsArrayPredicate];
    
    return lineItemsWhichInPrimaryAndSecondary;
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

-(NSInteger)totalPackageQtyForItem:(LineItem *)lineItem
{
    return lineItem.itemQty.integerValue / lineItem.packageQty.floatValue;
}

-(NSMutableArray *)configureLineItemForSameItems:(NSMutableArray *)totalLineItems withRefund:(BOOL)isDiscountBunchForRefund
{
    DiscountAppliedOn discountAppliedOn = [self discountAppliedOnForThisDiscountScheme];

    
     packageTypeForDiscount = @"";
    
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

  //  packageTypeForDiscount = @"Case";

    
    NSMutableArray *lineItemMutableCopy = [totalLineItems mutableCopy];
    
    NSArray *lineItemsForSecondary = [self lineItemsForCondition:totalLineItems withRefund:isDiscountBunchForRefund];
    NSInteger totalLineItemSecondaryQty = [[lineItemsForSecondary valueForKeyPath:@"@sum.totalPackageQty"] integerValue];
    if (totalLineItemSecondaryQty < self.discount_M.secondaryItemQty.integerValue) {
        return totalLineItems;
    }
    
    BOOL isAssendingForSecondary = YES;
    if (isDiscountBunchForRefund == TRUE) {
        isAssendingForSecondary = NO;
//        if (self.discount_M.freeType.integerValue == Amount) {
//            isAssendingForSecondary = YES;
//        }
    }

    
    NSArray *lineItemsWhichInPrimaryAndSecondary = [self isCaseForSameItemsForTotalItem:totalLineItems withRefund:isDiscountBunchForRefund];
    
    NSMutableArray *lineItemsForSecondaryMutableCopy = [lineItemsForSecondary mutableCopy];
    [lineItemsForSecondaryMutableCopy removeObjectsInArray:lineItemsWhichInPrimaryAndSecondary];
    
    NSSortDescriptor *abSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemBasicPrice" ascending:isAssendingForSecondary selector:nil];
    NSArray *abSortDescriptors = @[abSortDescriptor];
    lineItemsWhichInPrimaryAndSecondary = [lineItemsWhichInPrimaryAndSecondary sortedArrayUsingDescriptors:abSortDescriptors];
    
    for (LineItem *lineItemWhichInPrimaryAndSecondary in lineItemsWhichInPrimaryAndSecondary) {
        [lineItemsForSecondaryMutableCopy addObject:lineItemWhichInPrimaryAndSecondary];
    }
    
    
    //    NSMutableArray *applicableSecondaryLineItems = [lineItemsForSecondary mutableCopy];
    //    NSInteger remaningSeconaryItemQty = [[lineItemsForSecondaryMutableCopy valueForKeyPath:@"@sum.itemQty"] integerValue];
    //    if (remaningSeconaryItemQty >= self.discount_M.secondaryItemQty.floatValue) {
    ////        self.applicableSecondaryItems = lineItemsForSecondaryMutableCopy;
    //        [lineItemMutableCopy removeObjectsInArray:lineItemsForSecondaryMutableCopy];
    //    }
    //    else
    //    {
    //        [applicableSecondaryLineItems removeObjectsInArray:lineItemsWhichInPrimaryAndSecondary];
    //        [lineItemMutableCopy removeObjectsInArray:applicableSecondaryLineItems];
    //        NSInteger totalSumOfSecondaryLineItemWithOutSameItemQty = [[applicableSecondaryLineItems valueForKeyPath:@"@sum.itemQty"] integerValue];
    //        NSInteger applicableSecondaryItemQty = self.discount_M.secondaryItemQty.floatValue - totalSumOfSecondaryLineItemWithOutSameItemQty;
    //
    //        NSSortDescriptor *abSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemBasicPrice" ascending:YES selector:nil];
    //        NSArray *abSortDescriptors = @[abSortDescriptor];
    //        lineItemsWhichInPrimaryAndSecondary = [lineItemsWhichInPrimaryAndSecondary sortedArrayUsingDescriptors:abSortDescriptors];
    
    NSMutableArray *applicableSecondaryLineItems = [[NSMutableArray alloc] init];
    
    NSInteger applicableSecondaryItemQty = self.discount_M.secondaryItemQty.floatValue ;
    
    for (LineItem *secondaryLineItem in lineItemsForSecondaryMutableCopy) {
        if (applicableSecondaryItemQty == 0) {
            continue;
        }
        
        applicableSecondaryItemQty = applicableSecondaryItemQty - secondaryLineItem.totalPackageQty.integerValue;//secondaryLineItem.itemQty.floatValue;
        
        if (applicableSecondaryItemQty < 0) {
            
            NSInteger applicableLineItemQty = 0;
            applicableLineItemQty = secondaryLineItem.totalPackageQty.integerValue + applicableSecondaryItemQty;
            //secondaryLineItem.itemQty.floatValue
            
            LineItem *li = [[LineItem alloc] initWithLineItem:secondaryLineItem.anItem withBillDetail:secondaryLineItem.receiptDictionary withLineItemIndex:secondaryLineItem.lineItemIndex];
            li.itemQty = @([[li valueForKey:@"packageQty"] floatValue] * applicableLineItemQty);
            li.totalPackageQty = @([[li valueForKey:@"itemQty"] integerValue] / [[li valueForKey:@"packageQty"] integerValue]);
            
            [applicableSecondaryLineItems addObject:li];
            
            
            LineItem *remainingPrimaryLineItem = [[LineItem alloc] initWithLineItem:secondaryLineItem.anItem withBillDetail:secondaryLineItem.receiptDictionary withLineItemIndex:secondaryLineItem.lineItemIndex];
            remainingPrimaryLineItem.itemQty = @([[remainingPrimaryLineItem valueForKey:@"packageQty"] floatValue] * -applicableSecondaryItemQty);
            remainingPrimaryLineItem.totalPackageQty = @([[remainingPrimaryLineItem valueForKey:@"itemQty"] integerValue] / [[remainingPrimaryLineItem valueForKey:@"packageQty"] integerValue]);

            
            
            for (LineItem *lineItem in lineItemMutableCopy) {
                if ([lineItem isEqual:secondaryLineItem]) {
                    [lineItemMutableCopy removeObject:lineItem];
                    break;
                }
            }
            [lineItemMutableCopy addObject:remainingPrimaryLineItem];
            applicableSecondaryItemQty = 0;
        }
        else
        {
            for (LineItem *lineItem in lineItemMutableCopy) {
                if ([lineItem isEqual:secondaryLineItem]) {
                    [lineItemMutableCopy removeObject:lineItem];
                    break;
                }
            }
            [applicableSecondaryLineItems addObject:secondaryLineItem];
        }
    }
    //    }
    
    NSArray *lineItemsForDiscount = [self lineItemsForDiscount:lineItemMutableCopy withRefund:isDiscountBunchForRefund];
    if ([lineItemsForDiscount count] == 0) {
        return totalLineItems ;
    }
    
    NSInteger totalLineItemPrimaryQty = [[lineItemsForDiscount valueForKeyPath:@"@sum.totalPackageQty"] integerValue];
    if (totalLineItemPrimaryQty < self.discount_M.primaryItemQty.integerValue) {
        return totalLineItems;
    }
    
    
    NSSortDescriptor *primaryItemQtySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"totalPackageQty" ascending:NO selector:nil];
    NSArray *sortDescriptors = @[primaryItemQtySortDescriptor];
    NSArray  *applicablePrimaryLineItemDiscountArray = [lineItemsForDiscount sortedArrayUsingDescriptors:sortDescriptors];
    
    BOOL isAscending = NO;
    if (isDiscountBunchForRefund == TRUE) {
        isAscending = YES;
//       if (self.discount_M.freeType.integerValue == Amount) {
//            isAssending = NO;
//        }
    }
    NSSortDescriptor *primaryItemPriceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemBasicPrice" ascending:isAscending selector:nil];
    NSArray *primaryItemPriceSortDescriptors = @[primaryItemPriceSortDescriptor];
    applicablePrimaryLineItemDiscountArray = [applicablePrimaryLineItemDiscountArray sortedArrayUsingDescriptors:primaryItemPriceSortDescriptors];
    
    
    
    BOOL isNeedToAddInRemainingBunch = FALSE;
    NSMutableArray *remainingLineItemsArray = [[NSMutableArray alloc] init];
    NSMutableArray *applicablePrimaryItemsArray = [[NSMutableArray alloc] init];
    
    NSInteger applicablePrimaryItem =  self.discount_M.primaryItemQty.floatValue;
    
    
    for (LineItem *primaryLineItem in applicablePrimaryLineItemDiscountArray) {
        if (applicablePrimaryItem == 0) {
            [remainingLineItemsArray addObject:primaryLineItem];
            continue;
        }
        applicablePrimaryItem = [self addPrimaryLineItemToBunch:primaryLineItem forApplicablePrimaryItem:applicablePrimaryItem];
        
        
        LineItem *remainingPrimaryLineItem;
        if (applicablePrimaryItem < 0 ) {
            
            NSInteger applicableLineItemQty = 0;
            applicableLineItemQty = primaryLineItem.totalPackageQty.floatValue + applicablePrimaryItem;
            
            LineItem *li = [[LineItem alloc] initWithLineItem:primaryLineItem.anItem withBillDetail:primaryLineItem.receiptDictionary withLineItemIndex:primaryLineItem.lineItemIndex];
            li.itemQty = @([[li valueForKey:@"packageQty"] floatValue] * applicableLineItemQty);
            li.totalPackageQty = @([[li valueForKey:@"itemQty"] integerValue] / [[li valueForKey:@"packageQty"] integerValue]);

            
            [applicablePrimaryItemsArray addObject:li];
            
            isNeedToAddInRemainingBunch = TRUE;
            
            remainingPrimaryLineItem = [[LineItem alloc] initWithLineItem:primaryLineItem.anItem withBillDetail:primaryLineItem.receiptDictionary withLineItemIndex:primaryLineItem.lineItemIndex];
            remainingPrimaryLineItem.itemQty = @([[remainingPrimaryLineItem valueForKey:@"packageQty"] floatValue] * -applicablePrimaryItem);
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
                [remainingLineItemsArray addObject:remainingPrimaryLineItem];
                continue;
            }
            [remainingLineItemsArray addObject:primaryLineItem];
        }
        else
        {
            [applicablePrimaryItemsArray addObject:primaryLineItem];
            
            for (LineItem *lineItem in lineItemMutableCopy) {
                if ([lineItem isEqual:primaryLineItem]) {
                    [lineItemMutableCopy removeObject:lineItem];
                    break;
                }
            }
        }
    }
    
    if (isDiscountBunchForRefund == TRUE) {
        self.applicableRefundLineItems = applicablePrimaryItemsArray;
        self.applicableSecondaryRefundLineItems = applicableSecondaryLineItems;
        totalLineItems = lineItemMutableCopy;
    }
    else
    {
        self.applicableLineItems = applicablePrimaryItemsArray;
        self.applicableSecondaryItems = applicableSecondaryLineItems;
        totalLineItems = lineItemMutableCopy;
    }
    return totalLineItems;
}

-(NSMutableArray *)applyDiscountToLineItems:(NSArray *)lineItems withTotalLineItems:(NSMutableArray *)totalLineItems withRefund:(BOOL)isDiscountBunchForRefund
{
    
    NSMutableArray *lineItemMutableCopy = [totalLineItems mutableCopy];

    return  [self configureLineItemForSameItems:totalLineItems withRefund:isDiscountBunchForRefund];
    
    NSArray *lineItemsForDiscount = [self lineItemsForDiscount:lineItems withRefund:isDiscountBunchForRefund];
    if ([lineItemsForDiscount count] == 0) {
        return totalLineItems ;
    }

    if ( [[self isCaseForSameItemsForTotalItem:totalLineItems withRefund:isDiscountBunchForRefund] count] > 0) {
        return [self configureLineItemForSameItems:totalLineItems withRefund:isDiscountBunchForRefund];
    }
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemQty" ascending:NO selector:nil];
    NSArray *sortDescriptors = @[aSortDescriptor];
    NSArray  *applicableDiscountLineItemArray = [lineItemsForDiscount sortedArrayUsingDescriptors:sortDescriptors];
    
    
    NSSortDescriptor *abSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemBasicPrice" ascending:NO selector:nil];
    NSArray *abSortDescriptors = @[abSortDescriptor];
    applicableDiscountLineItemArray = [applicableDiscountLineItemArray sortedArrayUsingDescriptors:abSortDescriptors];
    
//    NSMutableArray *applicableDiscountLineItemMutableArray = [self sortLineItemWhichAreInSecondaryAsWellAsInPrimaryArray:[applicableDiscountLineItemArray mutableCopy] conditionForPrimary:YES withTotalLineItem:lineItemMutableCopy];
    
    
    
    BOOL isNeedToAddInRemainingBunch = FALSE;
    NSMutableArray *remainingLineItemsArray = [[NSMutableArray alloc] init];
    NSMutableArray *applicablePrimaryItemsArray = [[NSMutableArray alloc] init];
    
    NSInteger applicablePrimaryItem =  self.discount_M.primaryItemQty.floatValue;
    
    
    for (LineItem *primaryLineItem in applicableDiscountLineItemArray) {
        if (applicablePrimaryItem == 0) {
            [remainingLineItemsArray addObject:primaryLineItem];
            continue;
        }
        applicablePrimaryItem = [self addPrimaryLineItemToBunch:primaryLineItem forApplicablePrimaryItem:applicablePrimaryItem];
        
        
        LineItem *remainingPrimaryLineItem;
        if (applicablePrimaryItem < 0 ) {
            
            NSInteger applicableLineItemQty = 0;
            applicableLineItemQty = primaryLineItem.itemQty.floatValue + applicablePrimaryItem;
            
            
            LineItem *li = [[LineItem alloc] initWithLineItem:primaryLineItem.anItem withBillDetail:primaryLineItem.receiptDictionary withLineItemIndex:primaryLineItem.lineItemIndex];
            li.itemQty = @([[li valueForKey:@"packageQty"] floatValue] * applicableLineItemQty);
            
            [applicablePrimaryItemsArray addObject:li];
            
            isNeedToAddInRemainingBunch = TRUE;
            
            remainingPrimaryLineItem = [[LineItem alloc] initWithLineItem:primaryLineItem.anItem withBillDetail:primaryLineItem.receiptDictionary withLineItemIndex:primaryLineItem.lineItemIndex];
            remainingPrimaryLineItem.itemQty = @(-applicablePrimaryItem);
            
            
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
                [remainingLineItemsArray addObject:remainingPrimaryLineItem];
                continue;
            }
            [remainingLineItemsArray addObject:primaryLineItem];
        }
        else
        {
            [applicablePrimaryItemsArray addObject:primaryLineItem];
            
            for (LineItem *lineItem in lineItemMutableCopy) {
                if ([lineItem isEqual:primaryLineItem]) {
                    [lineItemMutableCopy removeObject:lineItem];
                    break;
                }
            }
        }
    }
    
    
    NSArray *lineItemsForCondition = [self lineItemsForCondition:lineItemMutableCopy withRefund:isDiscountBunchForRefund];
    
    if (lineItemsForCondition.count == 0) {
        return totalLineItems ;
    }
    
    NSInteger totalLineItemSecondaryQty = [[lineItemsForCondition valueForKeyPath:@"@sum.itemQty"] integerValue];
    if (totalLineItemSecondaryQty < self.discount_M.secondaryItemQty.integerValue) {
        return totalLineItems;
    }
    
    
    
    
    NSSortDescriptor *bSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemQty" ascending:NO selector:nil];
    NSArray *bSortDescriptors = @[bSortDescriptor];
    NSArray  *applicableDiscountSecondaryItemArray = [lineItemsForCondition sortedArrayUsingDescriptors:bSortDescriptors];
    
//    NSSortDescriptor *abcSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemBasicPrice" ascending:NO selector:nil];
//    NSArray *abcSortDescriptors = @[abcSortDescriptor];
//    applicableDiscountSecondaryItemArray = [applicableDiscountSecondaryItemArray sortedArrayUsingDescriptors:abcSortDescriptors];
//
    
    
//    NSMutableArray *applicableDiscountSecondaryItemMutableArray = [self sortLineItemWhichAreInSecondaryAsWellAsInPrimaryArray:applicableDiscountSecondaryItemArray conditionForPrimary:NO] ;
    
    
    NSInteger applicableSecondaryItem = self.discount_M.secondaryItemQty.floatValue;
    
    BOOL isNeedToAddInRemainingBunchForSecondary = FALSE;
    NSMutableArray *applicableSecondaryItems = [[NSMutableArray alloc] init];
    
    for (LineItem *secondaryLineItem in applicableDiscountSecondaryItemArray) {
        if (applicableSecondaryItem == 0) {
            [remainingLineItemsArray addObject:secondaryLineItem];
            continue;
        }
        applicableSecondaryItem = [self addSecondaryLineItemToBunch:secondaryLineItem forApplicableSecondaryItem:applicableSecondaryItem];
        
        LineItem *remainingSecondaryLineItem;
        
        if (applicableSecondaryItem < 0 ) {
            
            
            
            NSInteger applicableLineItemQty = 0;
            applicableLineItemQty = secondaryLineItem.itemQty.floatValue + applicableSecondaryItem;
            
            
            LineItem *li = [[LineItem alloc] initWithLineItem:secondaryLineItem.anItem withBillDetail:secondaryLineItem.receiptDictionary withLineItemIndex:secondaryLineItem.lineItemIndex];
            li.itemQty = @([[li valueForKey:@"packageQty"] floatValue] * applicableLineItemQty);
            
            
            [applicableSecondaryItems addObject:li];
            
            isNeedToAddInRemainingBunchForSecondary = TRUE;
            
            
            
            remainingSecondaryLineItem = [[LineItem alloc] initWithLineItem:secondaryLineItem.anItem withBillDetail:secondaryLineItem.receiptDictionary withLineItemIndex:secondaryLineItem.lineItemIndex];
            remainingSecondaryLineItem.itemQty = @(-applicableSecondaryItem);
            
            
            for (LineItem *lineItem in lineItemMutableCopy) {
                if ([lineItem isEqual:secondaryLineItem]) {
                    [lineItemMutableCopy removeObject:lineItem];
                    break;
                }
            }
            [lineItemMutableCopy addObject:remainingSecondaryLineItem];
            
            applicableSecondaryItem = 0;
        }
        
        if (isNeedToAddInRemainingBunchForSecondary == TRUE) {
            if (remainingSecondaryLineItem != nil) {
                [remainingLineItemsArray addObject:remainingSecondaryLineItem];
                continue;
            }
        }
        else
        {
            [applicableSecondaryItems addObject:secondaryLineItem];
            
            for (LineItem *lineItem in lineItemMutableCopy) {
                if ([lineItem isEqual:secondaryLineItem]) {
                    [lineItemMutableCopy removeObject:lineItem];
                    break;
                }
            }
        }
    }
    
    
    if (isDiscountBunchForRefund == TRUE) {
        self.applicableRefundLineItems = applicablePrimaryItemsArray;
        self.applicableSecondaryRefundLineItems = applicableSecondaryItems;
        totalLineItems = lineItemMutableCopy;
    }
    else
    {
        self.applicableLineItems = applicablePrimaryItemsArray;
        self.applicableSecondaryItems = applicableSecondaryItems;
        totalLineItems = lineItemMutableCopy;
    }
    return totalLineItems;

}

- (BOOL)isApplicableToLineItems:(NSArray*)lineItems
{
    BOOL isDiscountSchemeApplicable = FALSE;
    
    NSArray *lineItemsForDiscount = [self lineItemsForDiscount:lineItems];
    
    if (lineItemsForDiscount.count == 0) {
        return isDiscountSchemeApplicable;
    }
    
    NSInteger totalLineItemPrimaryQty = [[lineItemsForDiscount valueForKeyPath:@"@sum.itemQty"] integerValue];
    if (totalLineItemPrimaryQty < self.discount_M.primaryItemQty.floatValue) {
        return isDiscountSchemeApplicable;
    }
    
    self.applicableLineItems = [[NSMutableArray alloc] init];
    self.applicableSecondaryItems = [[NSMutableArray alloc]init];
    
    self.applicableRefundLineItems = [[NSMutableArray alloc]init];
    self.applicableSecondaryRefundLineItems = [[NSMutableArray alloc]init];

    self.remainingLineItems = [[NSMutableArray alloc]init];
    
    NSArray *performDiscountStepArray = [NSArray arrayWithObjects:@(FALSE),@(TRUE), nil];
    
    NSMutableArray *lineItemMutableCopy = [lineItems mutableCopy];

    for (NSNumber *discountCheckCondition in performDiscountStepArray) {
        lineItemMutableCopy = [self applyDiscountToLineItems:lineItemsForDiscount withTotalLineItems:lineItemMutableCopy withRefund:discountCheckCondition.boolValue];
    }
    

    if (self.applicableLineItems.count > 0 || self.applicableRefundLineItems.count > 0) {
        self.remainingLineItems = lineItemMutableCopy;
        isDiscountSchemeApplicable = TRUE;
        return isDiscountSchemeApplicable;
    }
    
    return isDiscountSchemeApplicable;
}


-(NSInteger )addPrimaryLineItemToBunch:(LineItem *)lineItem forApplicablePrimaryItem:(NSInteger)applicablePrimaryItem
{
    return applicablePrimaryItem - lineItem.totalPackageQty.floatValue;
    
}
-(NSInteger )addSecondaryLineItemToBunch:(LineItem *)lineItem forApplicableSecondaryItem:(NSInteger)applicableSecondaryItem
{
    return  applicableSecondaryItem - lineItem.itemQty.floatValue;
}




@end
