//
//  MMOddDiscountGroup.m
//  RapidRMS
//
//  Created by Siya-ios5 on 9/30/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMOddDiscountGroup.h"
#import "LineItem.h"
@implementation MMOddDiscountGroup


- (NSArray*)lineItemsForCondition:(NSArray *)lineItems withRefund:(BOOL)isDiscountBunchForRefund {
    // Get line items for this discount
    NSPredicate *conditionPredicate = [NSPredicate predicateWithFormat:@"itemCode In %@ AND isRefundItem = %@ AND isQtyEdited = %@ AND isRefundFromInvoice = %@", [[self.discount_M.secondaryItems allObjects] valueForKey:@"itemId"],@(isDiscountBunchForRefund),@(TRUE),@(0)];
    NSArray *lineItemsForCondition = [lineItems filteredArrayUsingPredicate:conditionPredicate];
    
    return lineItemsForCondition;
}



- (NSArray *)lineItemsForDiscount:(NSArray *)lineItems withRefund:(BOOL)isDiscountBunchForRefund {
    // Get line items for this  discount
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode In %@ AND isQtyEdited = %@ AND isRefundItem = %@ AND isRefundFromInvoice = %@", [[self.discount_M.primaryItems allObjects] valueForKey:@"itemId"],@(TRUE),@(isDiscountBunchForRefund),@(0)];
    NSArray *lineItemsForDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
    return lineItemsForDiscount;
}



-(NSArray *)isCaseForSameItemsForTotalItem:(NSMutableArray *)totalLineItems withRefund:(BOOL)isDiscountBunchForRefund
{
    NSPredicate *lineItemsArrayPredicate = [NSPredicate predicateWithFormat:@"itemCode In %@ AND itemCode In %@ AND isRefundItem = %@ AND isRefundFromInvoice = %@" ,[[self.discount_M.primaryItems allObjects] valueForKey:@"itemId"],[[self.discount_M.secondaryItems allObjects] valueForKey:@"itemId"] , @(isDiscountBunchForRefund),@(0)];
    
    NSArray *lineItemsWhichInPrimaryAndSecondary = [totalLineItems filteredArrayUsingPredicate:lineItemsArrayPredicate];
    
    return lineItemsWhichInPrimaryAndSecondary;
}


-(NSMutableArray *)configureLineItemForSameItems:(NSMutableArray *)totalLineItems withRefund:(BOOL)isDiscountBunchForRefund
{
    
    NSMutableArray *lineItemMutableCopy = [totalLineItems mutableCopy];
    
    
    NSArray *lineItemsForSecondary = [self lineItemsForCondition:totalLineItems withRefund:isDiscountBunchForRefund];
    
    NSInteger totalLineItemSecondaryQty = [[lineItemsForSecondary valueForKeyPath:@"@sum.itemQty"] integerValue];
    if (totalLineItemSecondaryQty < self.discount_M.secondaryItemQty.integerValue) {
        return totalLineItems;
    }
    
    BOOL isAssendingForSecondary = YES;
    if (isDiscountBunchForRefund == TRUE) {
        isAssendingForSecondary = NO;
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
    
    
    
    NSMutableArray *applicableSecondaryLineItems = [[NSMutableArray alloc] init];
    
    NSInteger applicableSecondaryItemQty = self.discount_M.secondaryItemQty.floatValue ;
    
    for (LineItem *secondaryLineItem in lineItemsForSecondaryMutableCopy) {
        if (applicableSecondaryItemQty == 0) {
            continue;
        }
        
        applicableSecondaryItemQty = applicableSecondaryItemQty - secondaryLineItem.itemQty.floatValue;
        
        if (applicableSecondaryItemQty < 0) {
            
            NSInteger applicableLineItemQty = 0;
            applicableLineItemQty = secondaryLineItem.itemQty.floatValue + applicableSecondaryItemQty;
            
            
            LineItem *li = [[LineItem alloc] initWithLineItem:secondaryLineItem.anItem withBillDetail:secondaryLineItem.receiptDictionary withLineItemIndex:secondaryLineItem.lineItemIndex];
            li.itemQty = @(applicableLineItemQty);
            
            [applicableSecondaryLineItems addObject:li];
            
            
            LineItem *remainingPrimaryLineItem = [[LineItem alloc] initWithLineItem:secondaryLineItem.anItem withBillDetail:secondaryLineItem.receiptDictionary withLineItemIndex:secondaryLineItem.lineItemIndex];
            remainingPrimaryLineItem.itemQty = @(-applicableSecondaryItemQty);
            
            
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
    
    
    
    NSArray *lineItemsForDiscount = [self lineItemsForDiscount:lineItemMutableCopy withRefund:isDiscountBunchForRefund];
    if ([lineItemsForDiscount count] == 0) {
        return totalLineItems ;
    }
    
    NSInteger totalLineItemPrimaryQty = [[lineItemsForDiscount valueForKeyPath:@"@sum.itemQty"] integerValue];
    if (totalLineItemPrimaryQty < self.discount_M.primaryItemQty.integerValue) {
        return totalLineItems;
    }

    NSMutableArray *applicablePrimaryItemsArray = [[NSMutableArray alloc] init];
    for (LineItem *lineItem in lineItemsForDiscount) {
        [applicablePrimaryItemsArray addObject:lineItem];
        [lineItemMutableCopy removeObject:lineItem];
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
 return  [self configureLineItemForSameItems:totalLineItems withRefund:isDiscountBunchForRefund];
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

@end
