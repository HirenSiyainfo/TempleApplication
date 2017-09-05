
//
//  RDiscountCalculator.m
//  RapidDiscountDemo
//
//  Created by siya info on 20/01/16.
//  Copyright © 2016 siya info. All rights reserved.
//

#import "RDiscountCalculator.h"


#import "LineItem.h"
#import "Bill.h"
#import <GameplayKit/GameplayKit.h>

#import "DiscountGraphNode.h"
#import "Discount_Primary_MD.h"
#import "Discount_Secondary_MD.h"
#import "Discount_M.h"
#import "MMDiscount.h"
#import "MMDiscountGroup.h"
#import "RmsDbController.h"
#import "ItemSwipeDiscountCalculator.h"
#import "ItemWiseDiscountCalculator.h"
#import "BillAmountCalculator.h"
#import "BillWiseDiscountCalculator.h"
#import "Item_Price_MD+Dictionary.h"
#import "PriceLevelDiscount.h"
#import "MMDDayTimeSelectionVC.h"
#import "MMOddDiscountGroup.h"
#import "MMOddQtyDiscount.h"
typedef struct BillAmount {
    float totalBillAmount;
    float totalDiscount;
} BillAmount;



typedef struct TotalRemainingItemQty {
    float totalRemainingQtyForAveragePrice;
    float totalRemainingQtyForDiscountedPrice;
} TotalRemainingItemQty;


@implementation DiscountBlock
- (NSString*)description {
    // NOTE: Use \r for new line
    
    NSString *description = [[NSString alloc] initWithFormat:@"<%@ = 0x%0x, "
                             "Buy %d quantity for $%0.2f, "
                             "AveragePrice = $%0.2f, MaximumAllowed = %d, "
                             "DiscountApplied = $%0.2f, AppliedFactor = %d>", [self class], self,
                             _discountQuantity, _discountedPrice,
                             _averagePrice, _maximumFactor,
                             _discountAmount, _appliedFactor];
    return description;
}

- (NSString*)debugDescription {
    return [self description];
}
@end

@implementation DiscountGroup

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end


@interface RDiscountCalculator () {
    GKGraph *discountGraph;
    DiscountGraphNode *headNode;
    DiscountGraphNode *tailNode;
    BillAmountCalculator *discopuntBillAmountCalculator;
    NSArray *path ;
    NSInteger numberOfNode;
    
    NSInteger numberOfTimeExcuted;

    NSInteger loopCount;
    NSMutableArray *discountArrayForCalulation;
    NSInteger currentExcucatingDiscount;
    NSArray *localLineItemArray;
    NSMutableArray *discountGroupArray;
    GKGraphNode *dicountGraphHeadNode;
    GKGraphNode *dicountGraphTailNode;

}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RmsDbController *rmsDbController;


@end

@implementation RDiscountCalculator


- (instancetype)init{
    self = [super init];
    
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        self.managedObjectContext = self.rmsDbController.managedObjectContext;
    }
    
    return self;
}

-(void)printLineItems:(NSArray *)lineItems
{
    for (LineItem *lineItem in lineItems) {
        NSLog(@"lineItem = %@",lineItem);
        NSLog(@"lineItem qty = %@",lineItem.itemQty);
        NSLog(@"lineItem price = %@",lineItem.itemCode);
        NSLog(@"lineItem itemBasic Price = %@",lineItem.itemBasicPrice);
        NSLog(@"lineItem lineItemTotal Price = %@",lineItem.subTotal.lineItemTotalPrice);
        NSLog(@"lineItem lineItemTotal Discount = %@",lineItem.subTotal.lineItemTotalDiscount);
    }
}


-(void)configurePriceLevelDiscountForLineItem:(NSArray*)lineItems withApplicableDiscountArray:(NSMutableArray *)discountArray
{
    NSSet *lineItemSet = [NSSet setWithArray:[lineItems valueForKey:@"itemCode"]];
    
    for (NSNumber *itemCode in lineItemSet.allObjects) {
        
        Item *anItem = [self fetchItem:itemCode withMangedObjectContext:self.managedObjectContext];
        if (anItem.isPriceAtPOS.boolValue == TRUE) {
            continue;
        }
        [self setItemPriceFromItem_Price_MdforItem:anItem withQtyDiscountArray:discountArray forLineItems:lineItems];
    }
}


- (Item*)fetchItem:(NSNumber *)itemId withMangedObjectContext:(NSManagedObjectContext *)mangedObjectContext
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:mangedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%@ AND active == %d", itemId ,TRUE];
    [fetchRequest setPredicate:predicate];
    
    NSArray *resultSet = [UpdateManager executeForContext:mangedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=[resultSet firstObject];
    }
    return item;
}


-(void)setItemPriceFromItem_Price_MdforItem :(Item *)item withQtyDiscountArray:(NSMutableArray *)discountArray forLineItems:(NSArray *)lineItems

{
    
    if ([item.pricescale isEqualToString:@"APPPRICE"]) {
        for (Item_Price_MD *price_md in item.itemToPriceMd){
            NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@ AND packageType = %@", price_md.itemcode , price_md.priceqtytype];
            NSArray *lineItemsOfDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
            if (lineItemsOfDiscount.count == 0) {
                continue;
            }

            NSString *priceType = [NSString stringWithFormat:@"%@",price_md.applyPrice];
            NSNumber *priceValue = 0;

            if ([priceType isEqualToString:@"PriceA"])
            {
                priceValue = price_md.priceA;
            }
            else if ([priceType isEqualToString:@"PriceB"])
            {
                priceValue = price_md.priceB;
            }
            else if ([priceType isEqualToString:@"PriceC"])
            {
                priceValue = price_md.priceC;
            }
            else
            {
                priceValue = price_md.unitPrice;
            }

            CGFloat discount = price_md.unitPrice.floatValue - priceValue.floatValue;
            if (discount > 0) {
            MMDiscount *priceLevelDiscount = [[PriceLevelDiscount alloc] initWithPrimaryQty:price_md.qty.floatValue withItemCode:item.itemCode withApplicablePrice:priceValue.floatValue ithApplicablePackageType:price_md.priceqtytype];
            [discountArray addObject:priceLevelDiscount];
            }
        }
    }
//    return;
    
    
//    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@", item.itemCode];
//    NSArray *lineItemsOfDiscount = [lineItems filteredArrayUsingPredicate:discountPredicate];
//    LineItem *lineItem = nil;
//
//    if (lineItemsOfDiscount.count != 0) {
//        lineItem =  (LineItem *) [lineItemsOfDiscount firstObject];
//    }
//    
////    NSInteger totalLineItemPrimaryQty = [[lineItemsOfDiscount valueForKeyPath:@"@sum.itemQty"] integerValue];
////    
////    
////    NSMutableArray *priceLevelDiscountArray = [[NSMutableArray alloc]init];
////    CGFloat discountTotalWillBeAppliedOnItem = 0.00;
////
//    if ([item.pricescale isEqualToString:@"APPPRICE"])
//    {
//        for (Item_Price_MD *price_md in item.itemToPriceMd)
//        {
////        if (lineItem != nil && ![lineItem.packageType isEqualToString:price_md.priceqtytype]
////                ) {
////            continue;
////            }
//            
//            
//            NSMutableDictionary *price_Md_dictionary = [[NSMutableDictionary alloc]init];
//            [price_Md_dictionary setObject:[NSString stringWithFormat:@"%ld",(long)price_md.qty.integerValue] forKey:@"Qty"];
//            [price_Md_dictionary setObject:price_md.applyPrice forKey:@"applyPrice"];
//            
//            NSString *priceType = [NSString stringWithFormat:@"%@",price_md.applyPrice];
//            NSNumber *priceValue = 0;
//            
//            if ([priceType isEqualToString:@"PriceA"])
//            {
//                priceValue = price_md.priceA;
//            }
//            else if ([priceType isEqualToString:@"PriceB"])
//            {
//                priceValue = price_md.priceB;
//                
//            }
//            else if ([priceType isEqualToString:@"PriceC"])
//            {
//                priceValue = price_md.priceC;
//            }
//            else
//            {
//                priceValue = price_md.unitPrice;
//            }
//            
//            
//            
//            
//            if(!(priceValue.floatValue == 0) && price_md.qty.floatValue > 0)
//            {
////                CGFloat discount = price_md.unitPrice.floatValue - priceValue.floatValue;
////                if (discount > 0) {
////                    
////                    NSInteger possibilityOfAppliedThisDiscount = totalLineItemPrimaryQty / price_md.qty.floatValue;
////                    CGFloat tempDiscountValue = discountTotalWillBeAppliedOnItem;
////                    discountTotalWillBeAppliedOnItem = possibilityOfAppliedThisDiscount * discount;
////                    if (discountTotalWillBeAppliedOnItem > tempDiscountValue ) {
////                        [priceLevelDiscountArray removeAllObjects];
//                    MMDiscount *priceLevelDiscount = [[PriceLevelDiscount alloc] initWithPrimaryQty:price_md.qty.floatValue withItemCode:item.itemCode withApplicablePrice:priceValue.floatValue ithApplicablePackageType:price_md.priceqtytype];
//                    [discountArray addObject:priceLevelDiscount];
////                    }
////                }
//            }
//        }
//    }
//    if (priceLevelDiscountArray.count > 0) {
//        [discountArray addObject:[priceLevelDiscountArray firstObject]];
//    }
}

-(NSMutableArray *)calculateMixMatchAndQtyDiscountWithReceiptArray:(NSMutableArray *)receiptArray
{
    Bill *aBill = [[Bill alloc] initWithRecieptArray:receiptArray withManageObjectContext:self.managedObjectContext];
    return  [self configureDiscountWithBill:aBill withReciptArray:receiptArray];
}
-(void)calculateSwipeDiscountForReceiptArray:(NSMutableArray *)receiptArray
{
    ItemSwipeDiscountCalculator *itemSwipeDiscountCalculator = [[ItemSwipeDiscountCalculator alloc] initWithRecieptArray:receiptArray];
    [itemSwipeDiscountCalculator calculateItemSwipeDiscount];
}

-(void)calculateItemWiseDiscountForReceiptArray:(NSMutableArray *)receiptArray
{
    ItemWiseDiscountCalculator *itemWiseDiscountCalculator = [[ItemWiseDiscountCalculator alloc] initWithRecieptArray:receiptArray];
    [itemWiseDiscountCalculator calCulateItemWiseDiscount];
}


-(void)calculateBillWiseDiscountForReceiptArray:(NSMutableArray *)receiptArray
{
    BillWiseDiscountCalculator *billWiseDiscountCalculator = [[BillWiseDiscountCalculator alloc] initWithReceiptArray:receiptArray WithBillAmountCalculator:discopuntBillAmountCalculator];
    [billWiseDiscountCalculator calculateBillWiseDiscount];
}


-(void)resetItemPriceForReceiptArray:(NSMutableArray *)_billReceiptArray
{
    for(int i=0;i<[_billReceiptArray count];i++)
    {
        NSMutableDictionary *_billReceiptDisctionary = [_billReceiptArray objectAtIndex:i];
        
        [self resetVariationForDictionary:_billReceiptDisctionary];
        
        float totalVarionCost = 0.0;
        if ([_billReceiptDisctionary objectForKey:@"InvoiceVariationdetail"])
        {
            totalVarionCost = [[(NSArray *)[_billReceiptDisctionary objectForKey:@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.VariationBasicPrice"] floatValue] * [[_billReceiptDisctionary valueForKey:@"itemQty"] floatValue];
        }
        _billReceiptDisctionary[@"TotalVarionCost"] = @(totalVarionCost);
        
    }
}

-(void)resetVariationForDictionary :(NSMutableDictionary *)variationDictionary
{
    if ([variationDictionary objectForKey:@"InvoiceVariationdetail"])
    {
        NSMutableArray *variation = [variationDictionary objectForKey:@"InvoiceVariationdetail"];
        for (NSMutableDictionary *variationDictionary in variation)
        {
            [variationDictionary setValue:[variationDictionary objectForKey:@"VariationBasicPrice"] forKey:@"Price"];
        }
    }
}

-(NSMutableArray * )calculateDiscountForReceiptArray:(NSMutableArray *)receiptArray withBillAmountCalculator:(BillAmountCalculator *)billAmountCalculator
{
    discopuntBillAmountCalculator = billAmountCalculator;
    [self resetItemPriceForReceiptArray:receiptArray];
    
    NSLog(@"Discount calculation start time %@",[NSDate date]);
    NSMutableArray *billReceiptArray =   [self calculateMixMatchAndQtyDiscountWithReceiptArray:receiptArray];
    NSLog(@"Discount calculation end time %@",[NSDate date]);

    [self resetPriceAtPosDictionaryForRecieptArray:billReceiptArray];
    [self calculateSwipeDiscountForReceiptArray:billReceiptArray];
    [self calculateItemWiseDiscountForReceiptArray:billReceiptArray];
    [self calculateBillWiseDiscountForReceiptArray:billReceiptArray];
    [self calculateTotalItemCostForReceiptArray:billReceiptArray];
    self.totalDiscount =  [[billReceiptArray valueForKeyPath:@"@sum.ItemDiscount"] floatValue];

    return billReceiptArray;
}
-(void)resetPriceAtPosDictionaryForRecieptArray:(NSMutableArray *)receiptArray
{
    for(int i=0;i<[receiptArray count];i++)
    {
        NSMutableDictionary *billEntryDict = [receiptArray objectAtIndex:i];
        if (([[billEntryDict valueForKey:@"IsQtyEdited"] boolValue] == TRUE  && [[billEntryDict valueForKey:@"ItemDiscount"] floatValue] > 0) || ([[billEntryDict valueForKey:@"IsQtyEdited"] boolValue] == TRUE  && [[billEntryDict valueForKey:@"ItemDiscount"] floatValue] < 0)) {
            [billEntryDict removeObjectForKey:@"PriceAtPos"];
        }
    }
}
-(void)calculateTotalItemCostForReceiptArray:(NSMutableArray *)receiptArray
{
    
    for(int i=0;i<[receiptArray count];i++)
    {
        NSMutableDictionary *billEntryDict = [receiptArray objectAtIndex:i];
        
        float itemCost = [billEntryDict[@"itemPrice"] floatValue];
        float variationCost = [billEntryDict[@"TotalVarionCost"] floatValue];
        float totalItemCostValue = (itemCost*[[billEntryDict valueForKey:@"itemQty"] intValue]);
        totalItemCostValue += variationCost;
        [billEntryDict setObject:@(totalItemCostValue) forKey:@"TotalItemPrice"];
    }
}

//-(NSArray *)lineItemForDiscount:(MMDiscount *)discount
//{
//    
//}

//- (float)averageDiscoutePriceForDiscount:(MMDiscount*)discount {
//    
//    
//    MMItem *mmItem = [self.demoData itemForItemCode:discount.primaryItemCode];
//    MMItem *mmItem2 = [self.demoData itemForItemCode:discount.secondaryItemCode];
//    return [discount averageDiscountedPrice:mmItem secondaryItem:mmItem2];
//}

//- (NSArray*)sortedDiscountsArrayOnAveragePrice:(NSArray*)discountsForBill ascending:(BOOL)ascending {
//    NSArray *sortedDiscounts = [discountsForBill sortedArrayUsingComparator:^NSComparisonResult(MMDiscount *obj1, MMDiscount *obj2) {
//        
//        float avg1 = [self averageDiscoutePriceForDiscount:obj1];
//        float avg2 = [self averageDiscoutePriceForDiscount:obj2];
//        
//        if (!ascending) {
//            avg1 = -avg1;
//            avg2 = -avg2;
//        }
//        
//        if (avg1 > avg2) {
//            return NSOrderedDescending;
//        }
//        if (avg2 > avg1) {
//            return NSOrderedAscending;
//        }
//        
//        return NSOrderedSame;
//    }];
//    
//    return sortedDiscounts;
//}

- (NSArray*)sortedDiscountsBlocksOnAveragePrice:(NSArray*)discountBlocks ascending:(BOOL)ascending {
    NSArray *sortedDiscountBlocks = [discountBlocks sortedArrayUsingComparator:^NSComparisonResult(DiscountBlock *obj1, DiscountBlock *obj2) {
        
        float avg1 = obj1.averagePrice;
        float avg2 = obj2.averagePrice;
        
        if (!ascending) {
            avg1 = -avg1;
            avg2 = -avg2;
        }
        
        if (avg1 > avg2) {
            return NSOrderedDescending;
        }
        if (avg2 > avg1) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
    
    return sortedDiscountBlocks;
}

- (NSArray*)sortedDiscountsBlocksOnMaxApplicableFactor:(NSArray*)discountBlocks ascending:(BOOL)ascending {
    NSArray *sortedDiscountBlocks = [discountBlocks sortedArrayUsingComparator:^NSComparisonResult(DiscountBlock *obj1, DiscountBlock *obj2) {
        
        float mf1 = obj1.discountQuantity;
        float mf2 = obj2.discountQuantity;
        
        if (!ascending) {
            mf1 = -mf1;
            mf2 = -mf2;
        }
        
        if (mf1 > mf2) {
            return NSOrderedDescending;
        }
        if (mf2 > mf1) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
    
    return sortedDiscountBlocks;
}

- (NSArray*)sortedDiscountsBlocksOnMaxUsedQuantity:(NSArray*)discountBlocks ascending:(BOOL)ascending {
    NSArray *sortedDiscountBlocks = [discountBlocks sortedArrayUsingComparator:^NSComparisonResult(DiscountBlock *obj1, DiscountBlock *obj2) {
        
        float muq1 = obj1.maximumFactor * obj1.discountQuantity;
        float muq2 = obj2.maximumFactor * obj2.discountQuantity;
        
        if (!ascending) {
            muq1 = -muq1;
            muq2 = -muq2;
        }
        
        if (muq1 > muq2) {
            return NSOrderedDescending;
        }
        if (muq2 > muq1) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
    
    return sortedDiscountBlocks;
}





- (BillAmount)calculateBillAmount:(NSMutableArray *)aBill discountsForBill:(NSArray*)discountsForBill discountForPriceLevel:(NSMutableArray *)priceLevelDiscount withTotalBill:(NSArray *)totalBill withCalculationType:(NSNumber *)calculationType withItemCode:(NSNumber *)itemCode{
    
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@ AND isRefundItem = %@ AND  isRefundFromInvoice = %@", itemCode , calculationType , @(0)];
    NSArray *lineItemsForDiscount = [totalBill filteredArrayUsingPredicate:discountPredicate];
    
    
    // calculation for item from invoice....
    
    if (lineItemsForDiscount.count == 0) {
        NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@ AND  isRefundFromInvoice = %@", itemCode , @(1)];
        NSArray *lineItemsForDiscount = [totalBill filteredArrayUsingPredicate:discountPredicate];
        if (lineItemsForDiscount.count > 0) {
        
            for (LineItem *lineItem in lineItemsForDiscount) {
                lineItem.subTotal.lineItemTotalDiscount = [lineItem.receiptDictionary valueForKey:@"ItemDiscount"];
            }
        }

    }
    
    
    LineItem *lineItem = nil;
    for (LineItem *lineItemDiscount in lineItemsForDiscount) {
        if (lineItem == nil) {
            lineItem = [lineItemDiscount mutableCopyOfLineItem];
        }
        else{
            lineItem.itemQty = @(lineItem.itemQty.integerValue + lineItemDiscount.itemQty.integerValue);
        }
    }
    BillAmount ba = {0.0, 0.0};

    if (lineItem == nil) {
        return ba;
    }
    
    
    aBill = [[NSMutableArray alloc]init];
    [aBill addObject:lineItem];

    
    // Calculate for each line item
    for (LineItem *aLineItem in aBill) {
        
        NSMutableArray *discountForItem = [[NSMutableArray alloc]init];
        
        for (MMDiscount *discount in discountsForBill) {
            NSArray *discountItemCodes = [discount.discount_M.primaryItems.allObjects valueForKey:@"itemId"];
            if ([discountItemCodes containsObject:aLineItem.itemCode]) {
                [discountForItem addObject:discount];
            }
        }
        
        NSPredicate *discountForPriceLevelPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@",aLineItem.itemCode];
        NSMutableArray  *discountForPriceLevelItem = [[priceLevelDiscount filteredArrayUsingPredicate:discountForPriceLevelPredicate] mutableCopy];

        discountForItem = [[discountForItem arrayByAddingObjectsFromArray:discountForPriceLevelItem] mutableCopy];
        
        BillAmount itemTotal = [self calculateBillAmountForLineItem:aLineItem discountsForBill:discountForItem forTotalBill:totalBill withCalculationType:calculationType];
        
        ba.totalBillAmount += itemTotal.totalBillAmount;
        ba.totalDiscount += itemTotal.totalDiscount;
        
    }
    
    return ba;
}




- (BillAmount)calculateBillAmountForLineItem:(LineItem *)aLineItem discountsForBill:(NSArray*)discountsForBill forTotalBill:(NSArray *)totalBill withCalculationType:(NSNumber *)calculationType{
    //    MMItem *anItem = [self.demoData itemForItemCode:aLineItem.itemCode];
    
    TotalRemainingItemQty totalRemainingItemQty = {0, 0};
    // Get discounts
  //  NSArray *itemCodes = @[aLineItem.itemCode];
    //NSArray *discForItem = [[self fetchDiscountArrayForItems:itemCodes] mutableCopy];

    
    // Generate two lists
    NSMutableArray *averagePriceList = [NSMutableArray arrayWithCapacity:discountsForBill.count];
    NSMutableArray *discountBunchList = [NSMutableArray arrayWithCapacity:discountsForBill.count];
    
    
      NSMutableArray *averagePriceList_2 = [NSMutableArray arrayWithCapacity:discountsForBill.count];
      NSMutableArray *discountBunchList_2 = [NSMutableArray arrayWithCapacity:discountsForBill.count];

    
    for (MMDiscount *discount in discountsForBill) {
        DiscountBlock *db = nil;
        
        db = [self discountBlockForDiscount:discount forLineItem:aLineItem withCalculationType:calculationType];
        db.maximumFactor = aLineItem.itemQty.integerValue / db.discountQuantity;
        [averagePriceList addObject:db];
        
        db = [self discountBlockForDiscount:discount forLineItem:aLineItem withCalculationType:calculationType];
        db.maximumFactor = aLineItem.itemQty.integerValue / db.discountQuantity;
        [discountBunchList addObject:db];
        
        
        db = [self discountBlockForDiscount:discount forLineItem:aLineItem withCalculationType:calculationType];
        db.maximumFactor = aLineItem.itemQty.integerValue / db.discountQuantity;
        [averagePriceList_2 addObject:db];

        db = [self discountBlockForDiscount:discount forLineItem:aLineItem withCalculationType:calculationType];
        db.maximumFactor = aLineItem.itemQty.integerValue / db.discountQuantity;
        [discountBunchList_2 addObject:db];

    }
    
    
    
    //    NSLog(@"Before sorting = %@", averagePriceList);
    // Sort on average price
    
    BOOL isAscending = TRUE;
    if (calculationType.boolValue == TRUE) {
        isAscending = FALSE;
    }
    
    
    NSArray *temp1 = [self sortedDiscountsBlocksOnAveragePrice:averagePriceList ascending:isAscending];
    [averagePriceList removeAllObjects];
    [averagePriceList addObjectsFromArray:temp1];
    //    NSLog(@"After sorting = %@", averagePriceList);
    
    
    
    NSArray *temp3 = [self sortedDiscountsBlocksOnAveragePrice:averagePriceList_2 ascending:isAscending];
    [averagePriceList_2 removeAllObjects];
    [averagePriceList_2 addObjectsFromArray:temp3];

    
    //    NSLog(@"Before sorting = %@", discountBunchList);
    // Sort on Maximum factor
    
    
    isAscending = FALSE;
    if (calculationType.boolValue == TRUE) {
        isAscending = TRUE;
    }

    
    NSArray *temp2 = [self sortedDiscountsBlocksOnMaxUsedQuantity:discountBunchList ascending:isAscending];
    [discountBunchList removeAllObjects];
    [discountBunchList addObjectsFromArray:temp2];
    //    NSLog(@"After sorting = %@", discountBunchList);
    
    
    NSArray *temp4 = [self sortedDiscountsBlocksOnMaxApplicableFactor:discountBunchList_2 ascending:isAscending];
    [discountBunchList_2 removeAllObjects];
    [discountBunchList_2 addObjectsFromArray:temp4];

    
    // 1 //////////////////////////////////////////
    // Calculation based on average price
    NSInteger remainingQuatity = aLineItem.itemQty.integerValue;
    BillAmount averagePriceBill = {0, 0};
    
    for (DiscountBlock *discountBlock in averagePriceList) {
        // Check if discount can be applied
        if (remainingQuatity >= discountBlock.discountQuantity) {
            // Can apply discount
            remainingQuatity = [self updateDiscountBlock:discountBlock andBillAmount:&averagePriceBill forQuantity:remainingQuatity];
        }
        
    }
    totalRemainingItemQty.totalRemainingQtyForAveragePrice = remainingQuatity;
    
    //    NSLog(@"discount 1 = %0.2f", averagePriceBill.totalDiscount);
    
    // 2 //////////////////////////////////////////
    // Calculation based on average price
    remainingQuatity = aLineItem.itemQty.integerValue;
    BillAmount maximumFactorBill = {0, 0};
    
    for (DiscountBlock *discountBlock in discountBunchList) {
        // Check if discount can be applied
        // Excluding single quantity in this calculation
        if ((remainingQuatity >= discountBlock.discountQuantity) && (discountBlock.discountQuantity > 1)) {
            // Can apply discount
            remainingQuatity = [self updateDiscountBlockForDiscountListQty:discountBlock andBillAmount:&maximumFactorBill forQuantity:remainingQuatity];
        }
        
    }
    
    if (remainingQuatity > 0 && discountBunchList.count > 0 ) {
        
        DiscountBlock *discountBlock = discountBunchList[0];
        [self updateDiscountBlock:discountBlock andBillAmount:&maximumFactorBill forQuantity:remainingQuatity];
    }
    totalRemainingItemQty.totalRemainingQtyForDiscountedPrice = remainingQuatity;
    
    
    
    
    
    remainingQuatity = aLineItem.itemQty.integerValue;
    BillAmount maximumFactorBillDiscountQty = {0, 0};
    
    for (DiscountBlock *discountBlock in averagePriceList_2) {
        // Check if discount can be applied
        // Excluding single quantity in this calculation
        if ((remainingQuatity >= discountBlock.discountQuantity)) {
            // Can apply discount
            remainingQuatity = [self updateDiscountBlock:discountBlock andBillAmount:&maximumFactorBillDiscountQty forQuantity:remainingQuatity];
        }
        
    }
    
    
    remainingQuatity = aLineItem.itemQty.integerValue;
    BillAmount discountBunchList_2QtyDiscount = {0, 0};
    
    for (DiscountBlock *discountBlock in discountBunchList_2) {
        // Check if discount can be applied
        // Excluding single quantity in this calculation
        if (remainingQuatity >= discountBlock.discountQuantity) {
            // Can apply discount
            remainingQuatity = [self updateDiscountBlockForDiscountListQty:discountBlock andBillAmount:&discountBunchList_2QtyDiscount forQuantity:remainingQuatity];
        }
        
    }



    if (discountBunchList_2QtyDiscount.totalDiscount > maximumFactorBill.totalDiscount) {
        maximumFactorBill = discountBunchList_2QtyDiscount;
        discountBunchList = discountBunchList_2;
    }
    
    

    // Check Max value
    BillAmount maxDisc;
    NSArray *maxDiscList;
    
    
    if (calculationType.boolValue == TRUE) {
        if (averagePriceBill.totalDiscount < maximumFactorBill.totalDiscount) {
            if (averagePriceBill.totalDiscount < maximumFactorBillDiscountQty.totalDiscount) {
                maxDisc = averagePriceBill;
                maxDiscList = averagePriceList;
            }
            else
            {
                maxDisc = maximumFactorBillDiscountQty;
                maxDiscList = averagePriceList_2;
            }
        } else {
            
            if (maximumFactorBill.totalDiscount < maximumFactorBillDiscountQty.totalDiscount) {
                maxDisc = maximumFactorBill;
                maxDiscList = discountBunchList;
            }
            else
            {
                maxDisc = maximumFactorBillDiscountQty;
                maxDiscList = averagePriceList_2;
            }
        }
    }
    else
    {
        if (averagePriceBill.totalDiscount > maximumFactorBill.totalDiscount) {
            if (averagePriceBill.totalDiscount > maximumFactorBillDiscountQty.totalDiscount) {
                maxDisc = averagePriceBill;
                maxDiscList = averagePriceList;
            }
            else
            {
                maxDisc = maximumFactorBillDiscountQty;
                maxDiscList = averagePriceList_2;
            }
        } else {
            
            if (maximumFactorBill.totalDiscount > maximumFactorBillDiscountQty.totalDiscount) {
                maxDisc = maximumFactorBill;
                maxDiscList = discountBunchList;
            }
            else
            {
                maxDisc = maximumFactorBillDiscountQty;
                maxDiscList = averagePriceList_2;
            }
        }
    }
    
   
    
    NSLog(@"Bill amount = $%0.2f, Discount = $%0.2f", maxDisc.totalBillAmount, maxDisc.totalDiscount);
    NSLog(@"Discounts applied:\n%@", maxDiscList);
    
    if (maxDisc.totalDiscount!= 0) {
        [self updateDiscountBlock:maxDiscList forLineItem:aLineItem inBill:totalBill withCalculationType:calculationType];
    }
    else
    {
        NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@ AND isRefundItem = %@ AND  isRefundFromInvoice = %@", aLineItem.itemCode , calculationType , @(0)];
        NSArray *itemToRemainingDiscount = [totalBill filteredArrayUsingPredicate:itemPredicate];
        for (LineItem *lineItem in itemToRemainingDiscount) {
            CGFloat totalLineItemPrice = lineItem.itemQty.floatValue * lineItem.itemBasicPrice.floatValue;
            lineItem.subTotal.lineItemTotalPrice = @(totalLineItemPrice);
            lineItem.subTotal.lineItemTotalDiscount = @(0);
        }
    }
    return maxDisc;
}

-(void)updateDiscountBlock:(NSArray *)discountBlock forLineItem:(LineItem *)lineItem inBill:(NSArray *)totalBill withCalculationType:(NSNumber *)calculationType
{
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"itemCode = %@ AND isRefundItem = %@ AND  isRefundFromInvoice = %@", lineItem.itemCode , calculationType , @(0)];
    NSArray *itemToApplyDiscount = [totalBill filteredArrayUsingPredicate:itemPredicate];
    
    NSPredicate *itemPredicateForBlock = [NSPredicate predicateWithFormat:@"appliedFactor > %d",0];
    NSArray *itemToApplyDiscountBlockDetail = [discountBlock filteredArrayUsingPredicate:itemPredicateForBlock];
    
    

    NSSortDescriptor *lineItemItemQtySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemQty" ascending:NO selector:nil];
    itemToApplyDiscount = [itemToApplyDiscount sortedArrayUsingDescriptors:@[lineItemItemQtySortDescriptor]];

    for (DiscountBlock *discountBlock in itemToApplyDiscountBlockDetail) {
        
        NSInteger totalItemQtyForDiscount = discountBlock.appliedFactor * discountBlock.discountQuantity;

        
        for (LineItem *lineItem in itemToApplyDiscount) {
            NSInteger remainingItemQty = lineItem.itemQty.floatValue - lineItem.discountAppliedQty.floatValue;
            if (totalItemQtyForDiscount <= 0) {
                continue;
            }
            
            if (remainingItemQty <= 0) {
                continue;
            }
            totalItemQtyForDiscount = totalItemQtyForDiscount - remainingItemQty;
            
            if (totalItemQtyForDiscount < 0) {
                
                lineItem.discountAppliedQty = @(lineItem.discountAppliedQty.floatValue + (remainingItemQty + totalItemQtyForDiscount));
                
                CGFloat totalLineItemPrice = lineItem.itemQty.floatValue * lineItem.itemBasicPrice.floatValue;
                
                CGFloat totalAppliedQtyForDiscount = remainingItemQty + totalItemQtyForDiscount;
                if ([discountBlock.discount isKindOfClass:[PriceLevelDiscount class]]) {
                    CGFloat discountedPricePerItem = discountBlock.discountAmount / (discountBlock.discountQuantity) ;

                    lineItem.subTotal.lineItemTotalDiscount = @(lineItem.subTotal.lineItemTotalDiscount.floatValue + (discountedPricePerItem * totalAppliedQtyForDiscount));
                    
                    [self addDiscountToLineItems:lineItem withTotalDiscountNode:discountBlock withDiscount:(discountedPricePerItem *totalAppliedQtyForDiscount)];

                }
                else
                {
                    CGFloat discountedPricePerItem = discountBlock.discountAmount/discountBlock.discountQuantity;
                    lineItem.subTotal.lineItemTotalDiscount = @(lineItem.subTotal.lineItemTotalDiscount.floatValue + (discountedPricePerItem *totalAppliedQtyForDiscount));
                    
                    [self addDiscountToLineItems:lineItem withTotalDiscountNode:discountBlock withDiscount:(discountedPricePerItem *totalAppliedQtyForDiscount)];

                }
                lineItem.subTotal.lineItemTotalPrice = @(totalLineItemPrice);
            }
            else if (totalItemQtyForDiscount > 0)
            {
                lineItem.discountAppliedQty = @(lineItem.discountAppliedQty.floatValue + remainingItemQty );
                CGFloat totalLineItemPrice = lineItem.itemQty.floatValue * lineItem.itemBasicPrice.floatValue;
                
                CGFloat totalAppliedQtyForDiscount = remainingItemQty;
                
                if ([discountBlock.discount isKindOfClass:[PriceLevelDiscount class]]) {
                    CGFloat discountedPricePerItem = discountBlock.discountAmount / (discountBlock.discountQuantity) ;

                    lineItem.subTotal.lineItemTotalDiscount = @(lineItem.subTotal.lineItemTotalDiscount.floatValue + (discountedPricePerItem * totalAppliedQtyForDiscount));
                    [self addDiscountToLineItems:lineItem withTotalDiscountNode:discountBlock withDiscount:(discountedPricePerItem *totalAppliedQtyForDiscount)];

                }
                else
                {
                    CGFloat discountedPricePerItem =  discountBlock.discountAmount/discountBlock.discountQuantity;
                    lineItem.subTotal.lineItemTotalDiscount = @(lineItem.subTotal.lineItemTotalDiscount.floatValue + (discountedPricePerItem *totalAppliedQtyForDiscount));
                    [self addDiscountToLineItems:lineItem withTotalDiscountNode:discountBlock withDiscount:(discountedPricePerItem *totalAppliedQtyForDiscount)];

                }
                lineItem.subTotal.lineItemTotalPrice = @(totalLineItemPrice);
            }
            else
            {
                CGFloat totalLineItemPrice = lineItem.itemQty.floatValue * lineItem.itemBasicPrice.floatValue;

                CGFloat totalAppliedQtyForDiscount = remainingItemQty;
                
                lineItem.discountAppliedQty = @(lineItem.discountAppliedQty.floatValue + totalAppliedQtyForDiscount );

                
                
                lineItem.subTotal.lineItemTotalPrice = @(totalLineItemPrice);
                
                if ([discountBlock.discount isKindOfClass:[PriceLevelDiscount class]]) {
                    CGFloat discountedPricePerItem = discountBlock.discountAmount / (discountBlock.discountQuantity) ;

                    lineItem.subTotal.lineItemTotalDiscount = @(lineItem.subTotal.lineItemTotalDiscount.floatValue + (discountedPricePerItem * totalAppliedQtyForDiscount));
                    [self addDiscountToLineItems:lineItem withTotalDiscountNode:discountBlock withDiscount:(discountedPricePerItem *totalAppliedQtyForDiscount)];
                }
                else
                {
                    CGFloat discountedPricePerItem = discountBlock.discountAmount/discountBlock.discountQuantity;
                    lineItem.subTotal.lineItemTotalDiscount = @(lineItem.subTotal.lineItemTotalDiscount.floatValue + (discountedPricePerItem *totalAppliedQtyForDiscount));
                    [self addDiscountToLineItems:lineItem withTotalDiscountNode:discountBlock withDiscount:(discountedPricePerItem *totalAppliedQtyForDiscount)];
                }
            }
            
        }
    }
    
    for (LineItem *lineItem in itemToApplyDiscount) {
        CGFloat totalLineItemPrice = lineItem.itemQty.floatValue * lineItem.itemBasicPrice.floatValue;
        lineItem.subTotal.lineItemTotalPrice = @(totalLineItemPrice);
    }

}


-(void)addDiscountToLineItems:(LineItem *)toLineItems withTotalDiscountNode:(DiscountBlock*)discountNode withDiscount:(CGFloat)discount
{
     if ([discountNode.discount isKindOfClass:[PriceLevelDiscount class]])
    {
        NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                    @"Percentage", @"DiscountType",
                                                                    @(discount),@"Amount",
                                                                    @"Price_Md",@"AppliedOn",
                                                                    @(discountNode.discount.discount_M.discountId.floatValue),@"DiscountId",nil];
        
        NSMutableArray *discountArray = [toLineItems valueForKey:@"discountArray"];
        [discountArray addObject:itemwisePecentageDiscountDictionary];
    }
    
    else
    {
        NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                    @"Percentage", @"DiscountType",
                                                                    @(discount),@"Amount",
                                                                    @"Quantity",@"AppliedOn",
                                                                    @(discountNode.discount.discount_M.discountId.floatValue),@"DiscountId",nil];
        
        NSMutableArray *discountArray = [toLineItems valueForKey:@"discountArray"];
        [discountArray addObject:itemwisePecentageDiscountDictionary];
    }
}


-(NSMutableArray *)applyDiscountForDiscountBlock:(DiscountBlock *)discountBlock inBill:(NSMutableArray *)totalBill forTotalDiscountQty:(NSInteger )totalItemQtyForDiscount
{
    
    if (totalItemQtyForDiscount <= 0) {
        return totalBill;
    }
    LineItem *firstLineItem = [totalBill firstObject];
    NSInteger remainingItemQty = firstLineItem.itemQty.floatValue - firstLineItem.discountAppliedQty.floatValue;
    remainingItemQty = remainingItemQty - totalItemQtyForDiscount;
    if (remainingItemQty <= 0) {
        [totalBill removeObject:firstLineItem];
    }
    else
    {
        firstLineItem.discountAppliedQty = @(totalItemQtyForDiscount);
    }
    
    totalItemQtyForDiscount = totalItemQtyForDiscount - firstLineItem.itemQty.floatValue;
   return [self applyDiscountForDiscountBlock:discountBlock inBill:totalBill forTotalDiscountQty:totalItemQtyForDiscount];
}


- (NSInteger)updateDiscountBlock:(DiscountBlock*)discountBlock andBillAmount:(BillAmount*)pBillamount forQuantity:(NSInteger)quantity {
    NSInteger applicableFactor = quantity / discountBlock.discountQuantity;
    pBillamount->totalBillAmount += (applicableFactor * discountBlock.discountedPrice);
    pBillamount->totalDiscount += (applicableFactor * (discountBlock.discountAmount));
    
    discountBlock.appliedFactor = applicableFactor;
    quantity -= (applicableFactor * discountBlock.discountQuantity);
    
    return quantity;
}


- (NSInteger)updateDiscountBlockForDiscountListQty:(DiscountBlock*)discountBlock andBillAmount:(BillAmount*)pBillamount forQuantity:(NSInteger)quantity {
    NSInteger applicableFactor = quantity / discountBlock.discountQuantity;
    pBillamount->totalBillAmount += (applicableFactor * discountBlock.discountedPrice);
    pBillamount->totalDiscount += (discountBlock.discountAmount);
    
    discountBlock.appliedFactor = applicableFactor;
    quantity -= (applicableFactor * discountBlock.discountQuantity);
    
    return quantity;
}


-(DiscountBlock*)discountBlockForDiscount:(MMDiscount*)discount forLineItem:(LineItem *)lineItem withCalculationType:(NSNumber *)calculationType{
    DiscountBlock *db = [[DiscountBlock alloc] init];
    
    if ([discount isKindOfClass:[PriceLevelDiscount class]]) {
        db.discountQuantity = discount.primaryItemQty;
    }
    else
    {
        db.discountQuantity = discount.discount_M.primaryItemQty.integerValue;
    }
    
    
    CGFloat discountedPriceForAvgPrice = 0.00;
    
    if ([discount isKindOfClass:[PriceLevelDiscount class]]) {
        
        CGFloat lineItemTotalPrice =  (lineItem.itemBasicPrice.floatValue * lineItem.itemQty.floatValue);
    //    NSInteger appliedFactor = lineItem.itemQty.integerValue / db.discountQuantity;
        
        CGFloat lineItemPriceLevelDiscountPrice =  ((discount.applicablePrice / discount.primaryQty) * db.discountQuantity);
        
        if (calculationType.boolValue == TRUE) {
            lineItemPriceLevelDiscountPrice = -lineItemPriceLevelDiscountPrice;
        }
        CGFloat totalDiscount = ((lineItem.itemBasicPrice.floatValue * db.discountQuantity) -  lineItemPriceLevelDiscountPrice) ;
        
        
        db.discountAmount = totalDiscount;
//        if (totalDiscount < 0) {
//            totalDiscount = -totalDiscount;
//        }
        db.discountedPrice = lineItemTotalPrice - totalDiscount;
        discountedPriceForAvgPrice = lineItemPriceLevelDiscountPrice;
    }
    else
    {
        CGFloat discountedPriceForDiscount = discount.discount_M.free.floatValue;
        if (calculationType.boolValue == TRUE) {
            discountedPriceForDiscount = -discountedPriceForDiscount;
        }
        
        CGFloat itemPrice = db.discountQuantity * lineItem.itemBasicPrice.floatValue;
        CGFloat discount = discountedPriceForDiscount;
   //     NSInteger appliedFactor = lineItem.itemQty.integerValue / db.discountQuantity;
        discount = (itemPrice - discount) ;
        db.discountAmount = discount;
        
//        if (calculationType.boolValue == TRUE) {
//            discount = -discount;
//        }
        db.discountedPrice = (lineItem.itemBasicPrice.floatValue * lineItem.itemQty.floatValue) - discount;
        discountedPriceForAvgPrice = discountedPriceForDiscount;
    }
    
    db.averagePrice = discountedPriceForAvgPrice / db.discountQuantity;
    db.discount = discount;
    return db;
}


-(NSMutableArray *)configureDiscountWithBill:(Bill *)aBill withReciptArray:(NSMutableArray *)receiptArray
{
    NSArray *lineItems = aBill.lineItems;
    NSArray *itemCodes = [lineItems valueForKey:@"itemCode"];
    NSMutableArray *discountsForBill = [[self fetchDiscountArrayForItems:itemCodes] mutableCopy];
    NSMutableArray *applicableDiscountArray = [[NSMutableArray alloc] init];
//    NSLog(@"Before Calculation");
//    [self printLineItems:lineItems] ;
    
    
    BOOL isDiscountForMixAndMatchApplicable = FALSE;
    
    for (Discount_M *discountM in discountsForBill) {
        
        if (discountM.discountType.integerValue == 4) {
            MMDiscount *mmDiscount = [[MMDiscount alloc] initWithDiscountM:discountM];
            [applicableDiscountArray addObject:mmDiscount];
            // Qty discount
        }
        else if ([self isValidDate:discountM] == FALSE || [self isValidDay:discountM] == FALSE || [self isValidTime:discountM] == FALSE) {
            continue;
        }
        else if (discountM.discountType.integerValue == 1) {
            isDiscountForMixAndMatchApplicable = TRUE;
            if (discountM.quantityType.integerValue == MMDQuantityTypeODD) {
                MMDiscount *mmDiscount = [[MMOddQtyDiscount alloc] initWithDiscountM:discountM];
                [applicableDiscountArray addObject:mmDiscount];
            }
            else{
                MMDiscount *mmDiscount = [[MMDiscount alloc] initWithDiscountM:discountM];
                [applicableDiscountArray addObject:mmDiscount];

            }
            
            // Qty discount
        }
        else if (discountM.discountType.integerValue == 2)
        {
            isDiscountForMixAndMatchApplicable = TRUE;
            if (discountM.quantityType.integerValue == MMDQuantityTypeODD) {
                MMDiscount *mmGroupDiscount = [[MMOddDiscountGroup alloc] initWithDiscountM:discountM];
                [applicableDiscountArray addObject:mmGroupDiscount];
            }
            else
            {
                MMDiscount *mmGroupDiscount = [[MMDiscountGroup alloc] initWithDiscountM:discountM];
                [applicableDiscountArray addObject:mmGroupDiscount];
            }
            // Mix match discount
        }
    }
    numberOfNode = 0;
    numberOfTimeExcuted = 0;
//    if (isDiscountForMixAndMatchApplicable == FALSE) {
//        
//        NSMutableArray *priceLevelDiscount = [[NSMutableArray alloc] init];
//        [self configurePriceLevelDiscountForLineItem:lineItems withApplicableDiscountArray:priceLevelDiscount];
//        NSMutableArray *totalLineItemArray = [[NSMutableArray alloc]init];
//        NSSet *lineItemSet = [NSSet setWithArray:[lineItems valueForKey:@"itemCode"]];
//        
//        for (NSNumber *itemCode  in lineItemSet.allObjects) {
//            NSArray *calcluationArray = @[@(0),@(1)];
//            for (NSNumber *type in calcluationArray) {
//                [self calculateBillAmount:totalLineItemArray discountsForBill:applicableDiscountArray discountForPriceLevel:priceLevelDiscount withTotalBill:aBill.totalLineItems withCalculationType:type withItemCode:itemCode];
//            }
//        }
//        return [self configureReceiptArrayAfterCalculation:aBill];
//        
//    }
//    
    
    
    
   [self configurePriceLevelDiscountForLineItem:lineItems withApplicableDiscountArray:applicableDiscountArray];
    
   
//    if (applicableDiscountArray.count == 0) {
//        return receiptArray;
//    }
       [self generateGraphForLineItems:lineItems discountsForBill:applicableDiscountArray];
    
    NSLog(@"numberOfNode %ld",(long)numberOfNode);
    NSLog(@"numberOfTimeExcuted %ld",(long)numberOfTimeExcuted);

    
        path = [discountGraph findPathFromNode:headNode toNode:tailNode];

    
       BillAmount ba = {0.0, 0.0};
        for (DiscountGraphNode *discNode in path) {
            if (![discNode isKindOfClass:[DiscountGraphNode class]]) {
                continue;
            }
            ba.totalBillAmount += [discNode totalPrice];
            ba.totalDiscount += [discNode totalDiscount];
            
            
//            NSLog(@"printLineItems Discount %@",discNode.discount.description);
//            [self printLineItems:discNode.primaryItems] ;
//            
//            NSLog(@"secondaryItems Discount %@",discNode.discount.description);
//            [self printLineItems:discNode.secondaryItems] ;


//            NSLog(@"Applicable Discount %@",discNode.discount.description);
//            NSLog(@"DiscountGraphNode primary Item %@",[discNode.primaryItems valueForKey:@"itemCode"]);
//            NSLog(@"DiscountGraphNode secondary Item %@",[discNode.secondaryItems valueForKey:@"itemCode"]);
//            NSLog(@"DiscountGraphNode primary Item lineItemIndex %@",[discNode.primaryItems valueForKey:@"lineItemIndex"]);
//            NSLog(@"DiscountGraphNode secondary Item lineItemIndex %@",[discNode.secondaryItems valueForKey:@"lineItemIndex"]);
//
//            NSLog(@"DiscountGraphNode primart Item lineItemIndex %@",[discNode.secondaryItems valueForKey:@"lineItemIndex"]);
//
//            NSLog(@"DiscountGraphNode secondary Item lineItemIndex %@",[discNode.secondaryItems valueForKey:@"lineItemIndex"]);
//
//            NSLog(@"DiscountGraphNode secondary Item lineItemIndex %@",[discNode.secondaryItems valueForKey:@"lineItemIndex"]);
//
//            NSLog(@"DiscountGraphNode discount %@",discNode.discount.discount_M.discountId);
//            
//            NSLog(@"DiscountGraphNode total discount %f",[discNode totalDiscount]);
//            NSLog(@"DiscountGraphNode total totalBillAmount %f",[discNode totalPrice]);
            
            [self configureDiscountsWithLineItems:aBill.totalLineItems withTotalDiscountNode:discNode];
        }
//    NSLog(@"After Calculation");
//    [self printLineItems:aBill.totalLineItems] ;
    self.billAmount = ba.totalBillAmount;

    return [self configureReceiptArrayAfterCalculation:aBill];
    
}

-(NSMutableArray *)configureReceiptArrayAfterCalculation:(Bill *)aBill
{
    NSMutableArray *recieptArray = [[NSMutableArray alloc] init];
    for (LineItem *lineItem in aBill.totalLineItems) {
        
        NSMutableDictionary *recieptDictionary = [lineItem.receiptDictionary mutableCopy];
        
        if (lineItem.isRefundFromInvoice == TRUE) {
            [recieptArray addObject:recieptDictionary];
            continue;
        }
            
        CGFloat itemPrice = lineItem.subTotal.lineItemTotalPrice.floatValue - lineItem.subTotal.lineItemTotalDiscount.floatValue;
        [recieptDictionary setObject:@(itemPrice/lineItem.itemQty.floatValue) forKey:@"itemPrice"];
            [recieptDictionary setObject:@(lineItem.subTotal.lineItemTotalDiscount.floatValue) forKey:@"ItemDiscount"];
        [recieptDictionary setObject:@(itemPrice) forKey:@"TotalItemPrice"];
        [recieptDictionary setObject:lineItem.discountArray forKey:@"Discount"];

//        recieptDictionary[@"itemTax"] = @(lineItem.subTotal.lineItemTotalTax.floatValue);
        [recieptArray addObject:recieptDictionary];
    }
    return recieptArray;
}

-(void)addDiscountToLineItems:(LineItem *)toLineItems FromLineItem:(LineItem *)FromLineItems withTotalDiscountNode:(DiscountGraphNode*)discountNode
{
    if ([discountNode.discount isKindOfClass:[MMDiscountGroup class]])
    {
        NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                    @"Percentage", @"DiscountType",
                                                                    @(FromLineItems.subTotal.lineItemTotalDiscount.floatValue),@"Amount",
                                                                    @"MixAndMatch",@"AppliedOn",
                                                                    @(discountNode.discount.discount_M.discountId.floatValue),@"DiscountId",nil];
        
        NSMutableArray *discountArray = [toLineItems valueForKey:@"discountArray"];
        [discountArray addObject:itemwisePecentageDiscountDictionary];
    }

   else if ([discountNode.discount isKindOfClass:[PriceLevelDiscount class]])
    {
        NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                    @"Percentage", @"DiscountType",
                                                                    @(FromLineItems.subTotal.lineItemTotalDiscount.floatValue),@"Amount",
                                                                    @"Price_Md",@"AppliedOn",
                                                                    @(discountNode.discount.discount_M.discountId.floatValue),@"DiscountId",nil];
        
        NSMutableArray *discountArray = [toLineItems valueForKey:@"discountArray"];
        [discountArray addObject:itemwisePecentageDiscountDictionary];
    }
    
   else
   {
       NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                   @"Percentage", @"DiscountType",
                                                                   @(FromLineItems.subTotal.lineItemTotalDiscount.floatValue),@"Amount",
                                                                   @"Quantity",@"AppliedOn",
                                                                   @(discountNode.discount.discount_M.discountId.floatValue),@"DiscountId",nil];
       
       NSMutableArray *discountArray = [toLineItems valueForKey:@"discountArray"];
       [discountArray addObject:itemwisePecentageDiscountDictionary];
   }
}

-(void)configureDiscountsWithLineItems:(NSArray *)lineItem withTotalDiscountNode:(DiscountGraphNode *)discountGraphNode
{
    if ([discountGraphNode.primaryItems count] > 0) {
        NSPredicate *predicateWithLineItemIndex = [NSPredicate predicateWithFormat:@"lineItemIndex IN %@",[discountGraphNode.primaryItems valueForKey:@"lineItemIndex"]];
        NSArray *arrayOfPrimaryItemsInLineItems = [lineItem filteredArrayUsingPredicate:predicateWithLineItemIndex];
        for (LineItem *discountNodePrimaryLineItem in discountGraphNode.primaryItems) {
            
            for (LineItem *applicablePrimaryLineItem in arrayOfPrimaryItemsInLineItems) {
                if (applicablePrimaryLineItem.lineItemIndex.integerValue != discountNodePrimaryLineItem.lineItemIndex.integerValue) {
                    continue;
                }
                applicablePrimaryLineItem.subTotal.lineItemTotalPrice = @(applicablePrimaryLineItem.subTotal.lineItemTotalPrice.floatValue + discountNodePrimaryLineItem.subTotal.lineItemTotalPrice.floatValue);
                applicablePrimaryLineItem.subTotal.lineItemTotalDiscount = @(applicablePrimaryLineItem.subTotal.lineItemTotalDiscount.floatValue + discountNodePrimaryLineItem.subTotal.lineItemTotalDiscount.floatValue);
                
                if ( discountNodePrimaryLineItem.subTotal.lineItemTotalDiscount.floatValue != 0) {
                    [self addDiscountToLineItems:applicablePrimaryLineItem FromLineItem:discountNodePrimaryLineItem withTotalDiscountNode:discountGraphNode];
                }
                
                
                
                
//                NSNumber *taxType ;
//                if (discountGraphNode.discount.discount_M == nil) {
//                    taxType = @(1);
//                }
//                else
//                {
//                    taxType = discountGraphNode.discount.discount_M.discountType;
//                }
//                
//                CGFloat totalTax = [discountNodePrimaryLineItem calculateTaxForLineItem:taxType];
//                applicablePrimaryLineItem.subTotal.lineItemTotalTax = @(applicablePrimaryLineItem.subTotal.lineItemTotalTax.floatValue + totalTax);
                
            }
        }
    }
    
    if ([discountGraphNode.secondaryItems count] > 0) {
        {
            NSPredicate *predicateWithLineItemIndex = [NSPredicate predicateWithFormat:@"lineItemIndex IN %@",[discountGraphNode.secondaryItems valueForKey:@"lineItemIndex"]];
            NSArray *arrayOfSecondaryInLineItems = [lineItem filteredArrayUsingPredicate:predicateWithLineItemIndex];
            for (LineItem *discountNodeSecondaryLineItem in discountGraphNode.secondaryItems) {
                
                for (LineItem *applicableSecondaryLineItem in arrayOfSecondaryInLineItems) {
                    if (applicableSecondaryLineItem.lineItemIndex.integerValue != discountNodeSecondaryLineItem.lineItemIndex.integerValue) {
                        continue;
                    }
                    applicableSecondaryLineItem.subTotal.lineItemTotalPrice = @(applicableSecondaryLineItem.subTotal.lineItemTotalPrice.floatValue + discountNodeSecondaryLineItem.subTotal.lineItemTotalPrice.floatValue);
                 //   applicableSecondaryLineItem.subTotal.lineItemTotalDiscount = @(applicableSecondaryLineItem.subTotal.lineItemTotalDiscount.floatValue + discountNodeSecondaryLineItem.subTotal.lineItemTotalDiscount.floatValue);

                    
                    
//                    NSNumber *taxType ;
//                    if (discountGraphNode.discount.discount_M == nil) {
//                        taxType = @(1);
//                    }
//                    else
//                    {
//                        taxType = discountGraphNode.discount.discount_M.discountType;
//                    }
//                    
//                    CGFloat totalTax = [discountNodeSecondaryLineItem calculateTaxForLineItem:taxType];
//                    applicableSecondaryLineItem.subTotal.lineItemTotalTax = @(applicableSecondaryLineItem.subTotal.lineItemTotalTax.floatValue + totalTax);
                }
            }
        }
    }

}


-(NSArray *)fetchDiscountArrayForItems:(NSArray*)itemCodes
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Discount_M" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY primaryItems.itemId IN %@ AND isStatus = %@",itemCodes , @(TRUE)];
    [fetchRequest setPredicate:predicate];
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];

    return resultSet;

}
//- (BillAmount)calculateBillAmount:(Bill *)aBill {
//
//    NSArray *lineItems = aBill.lineItems;
//    NSMutableArray *discountsForBill = [NSMutableArray array];
//    NSArray *lineItemItemCodes = [lineItems valueForKey:@"anItem"];
//
////    for (LineItem *aLineItem in lineItems) {
////        
////        MMItem *anItem = [_demoData itemForItemCode:aLineItem.itemCode];
////        NSArray *discForItem = [_demoData discountsForItemCode:anItem.code];
////        [discountsForBill addObjectsFromArray:discForItem];
////
////    }
////    NSSet *setForDiscountApplicable = [NSSet setWithArray:discountsForBill];
////    
////
////    [self generateGraphForLineItems:lineItems discountsForBill:[setForDiscountApplicable allObjects]];
////    NSArray *path = [discountGraph findPathFromNode:headNode toNode:tailNode];
////
////    _appliedDiscounts = path;
////
////    
////    NSMutableArray *applicableDiscountArray = [[NSMutableArray alloc] init];
////    
//    BillAmount ba = {0.0, 0.0};
////    for (DiscountGraphNode *discNode in path) {
////        if (![discNode isKindOfClass:[DiscountGraphNode class]]) {
////            continue;
////        }
////        ba.totalBillAmount += [discNode totalPrice];
////        ba.totalDiscount += [discNode totalDiscount];
////   //     NSLog(@"Applicable Discount %@",discNode.discount.description);
////        NSLog(@"DiscountGraphNode %@",discNode);
////
////        if (discNode.discount.name.length > 0 && discNode.discount.value > 0) {
////            [applicableDiscountArray addObject:discNode.discount];
////        }
////    }
////    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"primaryQty" ascending:NO selector:nil];
////    NSArray *sortDescriptors = @[aSortDescriptor];
////    applicableDiscountArray = [[applicableDiscountArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
////    
////    
////    for (MMDiscount *discount in applicableDiscountArray) {
////        [self applyDiscountToApplicableBillItem:discount forBill:aBill forDiscountQty:discount.primaryQty.floatValue forDiscountAmount:discount.value.floatValue];
////    }
////
//  return ba;
//}

//-(void)applyDiscountToApplicableBillItem:(MMDiscount *)discount forBill:(MMBill *)mmBill forDiscountQty:(NSInteger )discountQty forDiscountAmount:(float)discountAmount
//{
//    
//    NSInteger remainingAppliedDiscountQty = discountQty;
//    
//    NSArray *applicablePrimaryItemForDiscount = [mmBill.dc_BillItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"itemCode = %@",discount.primaryItemCode]];
//    
//    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"remainingDiscountQty" ascending:NO selector:nil];
//    NSArray *sortDescriptors = @[aSortDescriptor];
//    applicablePrimaryItemForDiscount = [[applicablePrimaryItemForDiscount sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
//    
//    for (DC_BillItem *dcBillItem in applicablePrimaryItemForDiscount) {
//        
//        if (dcBillItem.remainingDiscountQty <= 0) {
//            continue;
//        }
//        if (remainingAppliedDiscountQty <= 0) {
//            continue;
//        }
//       
//        
//        
////        float remainingDiscountApplicableQty =  discountQty - dcBillItem.remainingDiscountQty.integerValue ;
//        
//        
//        dcBillItem.remainingDiscountQty = @(dcBillItem.itemQty.integerValue - discountQty);
//        
//        float appliedDiscountOnQty = discountQty ;
//
//        if (dcBillItem.remainingDiscountQty.floatValue < 0) {
//            appliedDiscountOnQty  += dcBillItem.remainingDiscountQty.floatValue;
//        }
//
//        
//        remainingAppliedDiscountQty = remainingAppliedDiscountQty - dcBillItem.itemQty.floatValue;
//        
//        float totalCalculatedItemPrice =  dcBillItem.itemPrice.floatValue;
//        float totalCalculatedDiscount =  dcBillItem.totalDiscount.floatValue;
//        
//        float calculatedTotalPriceForScheme = dcBillItem.singlePrice.floatValue * appliedDiscountOnQty;
//        float calculatedDiscountForScheme = ((calculatedTotalPriceForScheme * discountAmount) / 100);
//        
//        dcBillItem.totalDiscount = @(totalCalculatedDiscount + calculatedDiscountForScheme);
//        calculatedTotalPriceForScheme = calculatedTotalPriceForScheme - calculatedDiscountForScheme;
//        dcBillItem.itemPrice = @(totalCalculatedItemPrice + calculatedTotalPriceForScheme);
//
//        
//        
////        if (remainingDiscountApplicableQty == 0) {
////            dcBillItem.remainingDiscountQty = @(dcBillItem.itemQty.integerValue - discountQty);
////            
////            remainingAppliedDiscountQty = remainingAppliedDiscountQty - dcBillItem.itemQty.floatValue;
////            
////            float totalCalculatedItemPrice =  dcBillItem.itemPrice.floatValue;
////            float totalCalculatedDiscount =  dcBillItem.totalDiscount.floatValue;
////
////            float totalPrice = dcBillItem.singlePrice.floatValue * discountQty;
////            dcBillItem.totalDiscount = @(((totalPrice * discountAmount) / 100) + totalCalculatedDiscount);
////            totalPrice = totalPrice - dcBillItem.totalDiscount.floatValue;
////            dcBillItem.itemPrice = @(totalCalculatedItemPrice + totalPrice);
////        }
////        else if (remainingDiscountApplicableQty < 0)
////        {
////            dcBillItem.remainingDiscountQty = @(dcBillItem.itemQty.integerValue - discountQty);
////            remainingDiscountApplicableQty = -remainingDiscountApplicableQty;
////            
////            remainingAppliedDiscountQty = 0;
////            
////            
////            float totalCalculatedItemPrice =  dcBillItem.itemPrice.floatValue;
////            float totalCalculatedDiscount =  dcBillItem.totalDiscount.floatValue;
////
////
////            float discountedItemPrice = dcBillItem.singlePrice.floatValue * discountQty;
////            dcBillItem.totalDiscount = @((discountedItemPrice * discountAmount) / 100);
////            discountedItemPrice = discountedItemPrice - dcBillItem.totalDiscount.floatValue;
////            
//////            float totalPrice = discountedItemPrice + (dcBillItem.singlePrice.floatValue * remainingDiscountApplicableQty);
//////            dcBillItem.itemPrice = @(totalPrice);
////        }
////        else if (remainingDiscountApplicableQty > 0 )
////        {
////            dcBillItem.remainingDiscountQty = @(dcBillItem.itemQty.integerValue - discountQty);
////            
////            remainingAppliedDiscountQty = remainingAppliedDiscountQty - dcBillItem.itemQty.floatValue;
////
////            float totalPrice = dcBillItem.singlePrice.floatValue * dcBillItem.itemQty.floatValue;
////            dcBillItem.totalDiscount = @((totalPrice * discountAmount) / 100);
////            totalPrice = totalPrice - dcBillItem.totalDiscount.floatValue;
////            dcBillItem.itemPrice = @(totalPrice);
////        }
//    }
//}



- (void)generateGraphForLineItems:(NSArray*)lineItems discountsForBill:(NSArray*)discountsForBill {
    discountGraph = [[GKGraph alloc] init];
    
//    MMDiscount *tailNodeDiscount = [[MMDiscount alloc] initWithDictionary:@{
//                                                                            @"Value": @(0),
//                                                                            @"Name": @"Tail"
//                                                                            } ];
//    
//    
//    MMDiscount *headNodeDiscount = [[MMDiscount alloc] initWithDictionary:@{
//                                                                            @"Value": @(0),
//                                                                            @"Name": @"Head"
//                                                                            } ];
//    
//
//    
//
//    headNode = [[DiscountGraphNode alloc] initWithDiscount:headNodeDiscount primaryItem:nil secondaryItem:nil];
//    tailNode = [[DiscountGraphNode alloc] initWithDiscount:tailNodeDiscount primaryItem:nil secondaryItem:nil];
//    
//    
//    [discountGraph addNodes:@[headNode, tailNode]];
//    
//    GKGraphNode *currentNode = headNode;
    
    discountGroupArray = [[NSMutableArray alloc]init];
    
    for (MMDiscount *discount in discountsForBill) {
        
        NSMutableArray *itemForDiscounts = [[NSMutableArray alloc]init];
 
        NSArray *itemIdArrayPrimaryForDiscount;
        
        if([discount isKindOfClass:[PriceLevelDiscount class]])
        {
            itemIdArrayPrimaryForDiscount = @[discount.itemCode];
        }
        else
        {
            NSArray *primaryItems = [discount.discount_M.primaryItems allObjects];
            itemIdArrayPrimaryForDiscount = [primaryItems valueForKey:@"itemId"];
        }

        
        if (itemIdArrayPrimaryForDiscount.count > 0) {
            [itemForDiscounts addObjectsFromArray:itemIdArrayPrimaryForDiscount];
        }
        
        NSArray *secondaryItems = [discount.discount_M.secondaryItems allObjects];
        NSArray *itemIdArrayForSecondaryDiscount = [secondaryItems valueForKey:@"itemId"];

        if (itemIdArrayForSecondaryDiscount.count > 0) {
            [itemForDiscounts addObjectsFromArray:itemIdArrayForSecondaryDiscount];
        }

        DiscountGroup *discountGroup = nil;
        
        if (discountGroupArray.count > 0) {
            for (DiscountGroup *discountGroupAlreadyExist in discountGroupArray) {
                if (discountGroup != nil) {
                    break;
                }
                NSSet *set = [NSSet setWithArray:itemForDiscounts];
                BOOL isContain = [set intersectsSet:discountGroupAlreadyExist.discountGrouplineItems];
                if (isContain) {
                    discountGroup = discountGroupAlreadyExist;
                }
            }
        }
        
        if (discountGroup) {
            NSSet *set = [NSSet setWithArray:itemForDiscounts];
            NSMutableArray *itemWhichAreInList = [[discountGroup.discountGrouplineItems allObjects] mutableCopy];
            [itemWhichAreInList addObjectsFromArray:set.allObjects];
            discountGroup.discountGrouplineItems = [NSMutableSet setWithArray:itemWhichAreInList];
            [discountGroup.discounts addObject:discount];
        }
        else
        {
            DiscountGroup *discountGroup = [[DiscountGroup alloc]init];
            discountGroup.discounts = [[NSMutableArray alloc]initWithObjects:discount, nil];
            discountGroup.discountGrouplineItems = [NSMutableSet setWithArray:itemForDiscounts];
            [discountGroupArray addObject:discountGroup];
        }

    }
    
    NSMutableArray *totalDiscountedLineItems = [[NSMutableArray alloc]init];
    for (DiscountGroup *discountGroup in discountGroupArray) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode IN %@",discountGroup.discountGrouplineItems.allObjects];
        NSArray *filterdlineItems = [lineItems filteredArrayUsingPredicate:predicate];
        if (filterdlineItems.count > 0) {
            [totalDiscountedLineItems addObjectsFromArray:discountGroup.discountGrouplineItems.allObjects];
        }
        discountGroup.lineItemForDiscount = [filterdlineItems mutableCopy];
    }
    
    NSMutableArray *totalLineItems = [[lineItems valueForKey:@"itemCode"] mutableCopy];
    if (totalLineItems.count > 0) {
        [totalLineItems removeObjectsInArray:totalDiscountedLineItems];
        if (totalLineItems.count > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode IN %@",totalLineItems];
            NSArray *filterdlineItems = [lineItems filteredArrayUsingPredicate:predicate];
            
            DiscountGroup *discountGroup = [[DiscountGroup alloc]init];
            discountGroup.discounts = [[NSMutableArray alloc]init];
            discountGroup.discountGrouplineItems = [NSMutableSet setWithArray:[filterdlineItems valueForKey:@"itemCode"]];
            discountGroup.lineItemForDiscount = [filterdlineItems mutableCopy];
            [discountGroupArray addObject:discountGroup];
        }
    }
    
    [self performDiscountGroupProcess];
    return;
    
    //    NSLog(@"Head = %@, Tail = %@", headNode, tailNode);
    
    //#define USE_HANDWIRED_GRAPH
    
#ifdef USE_HANDWIRED_GRAPH
    [self handWiredGraphForBill:20];
#else
//    loopCount = 0;
//    
//    NSMutableArray *discountDictionaryArray = [[NSMutableArray alloc] init];
//    
//    NSInteger recursionIndex = 1;
//    for (MMDiscount *discount in discountsForBill) {
//        NSMutableDictionary *discountDictionary = [[NSMutableDictionary alloc] init];
//        if (discount.discount_M) {
//            [discountDictionary setObject:discount.discount_M.qtyLimit forKey:@"DiscountLimits"];
//            [discountDictionary setObject:discount.discount_M.name forKey:@"DiscountName"];
//            [discountDictionary setObject:discount.discount_M.code forKey:@"DiscountCode"];
//
//        }
//        else{
//            [discountDictionary setObject:@(0) forKey:@"DiscountLimits"];
//            [discountDictionary setObject:@"PriceLevel Discount" forKey:@"DiscountName"];
//            [discountDictionary setObject:@"PriceLevel Discount" forKey:@"DiscountCode"];
//        }
//        [discountDictionary setObject:@(0) forKey:@"DiscountApplied"];
//        
//        [discountDictionary setObject:@(recursionIndex) forKey:@"RecursionIndex"];
//        [discountDictionaryArray addObject:discountDictionary];
//        recursionIndex++;
//    }
//    
//    localLineItemArray = lineItems;
//
//    [self addDiscountNodesToCurrentNode:currentNode lineItems:lineItems discountsForBill:discountsForBill discountDictionary:discountDictionaryArray recursionIndex:0];
    currentExcucatingDiscount = 0;
//    [self configureDiscountArray:discountsForBill currentNode:currentNode applyDiscountToLineItems:localLineItemArray discountDictionary:discountDictionaryArray withBaseNode:currentNode];

    NSLog(@"loopCount = %ld", (long)loopCount);
#endif
    
    
    //#define DEBUG_GRAPH_STRUCTURE
    
#ifdef DEBUG_GRAPH_STRUCTURE
    NSArray *nodes = @[headNode];
    int level = 0;
    [self printGraph:level nodes:nodes];
    
#endif
    
}

-(void)performNextDiscountProcessWithLineItems:(NSArray *)lineItems withDiscount:(NSArray *)discounts
{
    NSMutableArray *discountDictionaryArray = [[NSMutableArray alloc] init];
    
    NSInteger recursionIndex = 1;
    for (MMDiscount *discount in discounts) {
        NSMutableDictionary *discountDictionary = [[NSMutableDictionary alloc] init];
        if (discount.discount_M) {
            [discountDictionary setObject:discount.discount_M.qtyLimit forKey:@"DiscountLimits"];
            [discountDictionary setObject:discount.discount_M.name forKey:@"DiscountName"];
            [discountDictionary setObject:discount.discount_M.code forKey:@"DiscountCode"];
            
        }
        else{
            [discountDictionary setObject:@(0) forKey:@"DiscountLimits"];
            [discountDictionary setObject:@"PriceLevel Discount" forKey:@"DiscountName"];
            [discountDictionary setObject:@"PriceLevel Discount" forKey:@"DiscountCode"];
        }
        [discountDictionary setObject:@(0) forKey:@"DiscountApplied"];
        
        [discountDictionary setObject:@(recursionIndex) forKey:@"RecursionIndex"];
        [discountDictionaryArray addObject:discountDictionary];
        recursionIndex++;
    }
    
}

-(void)performDiscountGroupProcess
{
    discountGraph = [[GKGraph alloc] init];
    
    
    
    MMDiscount *tailNodeDiscount = [[MMDiscount alloc] initWithDictionary:@{
                                                                            @"Value": @(0),
                                                                            @"Name": @"T0"
                                                                            } ];
    
    
    MMDiscount *headNodeDiscount = [[MMDiscount alloc] initWithDictionary:@{
                                                                            @"Value": @(0),
                                                                            @"Name": @"Head"
                                                                            }];
    
    headNode = [[DiscountGraphNode alloc] initWithDiscount:headNodeDiscount primaryItem:nil secondaryItem:nil];
    tailNode = [[DiscountGraphNode alloc] initWithDiscount:tailNodeDiscount primaryItem:nil secondaryItem:nil];
    
    [discountGraph addNodes:@[headNode, tailNode]];
    
    
    dicountGraphHeadNode = headNode;
    NSOperationQueue *nsoperationQueue = [[NSOperationQueue alloc]init];
    nsoperationQueue.maxConcurrentOperationCount = 1;
    nsoperationQueue.qualityOfService = NSQualityOfServiceUserInteractive;
    
    NSOperation *previousOperation = nil;
    
    NSInteger currentExecutingGroup = 1;
    
    NSMutableArray *operations = [[NSMutableArray alloc]init];
    
    dicountGraphHeadNode = headNode;

    
    for (DiscountGroup *discountGroup in discountGroupArray) {
        
        GKGraphNode *dicountGraphHeadNode1 = dicountGraphHeadNode;
        GKGraphNode *dicountGraphTailNode1 = tailNode;

        
        NSMutableArray *discountDictionaryArray = [[NSMutableArray alloc] init];
        
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self addDiscountNodesToCurrentNode:dicountGraphHeadNode1 lineItems:discountGroup.lineItemForDiscount discountsForBill:discountGroup.discounts discountDictionary:discountDictionaryArray recursionIndex:0 discountGraphTailNode:dicountGraphTailNode1];
            
        } ];
        
        
        if (currentExecutingGroup < discountGroupArray.count) {
            
//            NSInteger nextGroup = currentExecutingGroup + 1;
            NSString *tailName = [NSString stringWithFormat:@"T%ld",(long)currentExecutingGroup];
//            if (nextGroup == discountGroupArray.count) {
//                tailName = @"Tail";
//            }
            dicountGraphHeadNode = tailNode;
            MMDiscount *tailNodeDiscount = [[MMDiscount alloc] initWithDictionary:@{
                                                                                    @"Value": @(0),
                                                                                    @"Name": tailName
                                                                                    } ];
            tailNode = [[DiscountGraphNode alloc] initWithDiscount:tailNodeDiscount primaryItem:nil secondaryItem:nil];
        }
        
        if (previousOperation == nil) {
            previousOperation = blockOperation;
        }
        else
        {
            [blockOperation addDependency:previousOperation];
        }
        [operations addObject:blockOperation];
        currentExecutingGroup++;
        
    }
    [nsoperationQueue addOperations:operations waitUntilFinished:YES];
}

/*-(void)performNextDiscountGroupProcessWithCurrentNode:(GKGraphNode *)currentNode withLastRemainingItems:(NSArray *)lastRemainingItems
{
    if (discountGroupArray.count == 0) {
        
        return;
    }
    
    DiscountGroup *discountGroup = [discountGroupArray firstObject];
    
    NSMutableArray *discountDictionaryArray = [[NSMutableArray alloc] init];
    
//    NSInteger recursionIndex = 1;
//    for (MMDiscount *discount in discountGroup.discounts) {
//        NSMutableDictionary *discountDictionary = [[NSMutableDictionary alloc] init];
//        if (discount.discount_M) {
//            [discountDictionary setObject:discount.discount_M.qtyLimit forKey:@"DiscountLimits"];
//            [discountDictionary setObject:discount.discount_M.name forKey:@"DiscountName"];
//            [discountDictionary setObject:discount.discount_M.code forKey:@"DiscountCode"];
//            
//        }
//        else{
//            [discountDictionary setObject:@(0) forKey:@"DiscountLimits"];
//            [discountDictionary setObject:@"PriceLevel Discount" forKey:@"DiscountName"];
//            [discountDictionary setObject:@"PriceLevel Discount" forKey:@"DiscountCode"];
//        }
//        [discountDictionary setObject:@(0) forKey:@"DiscountApplied"];
//        
//        [discountDictionary setObject:@(recursionIndex) forKey:@"RecursionIndex"];
//        [discountDictionaryArray addObject:discountDictionary];
//        recursionIndex++;
//    }

    NSMutableArray *discountedItems = discountGroup.lineItemForDiscount;
    
    if (lastRemainingItems != nil) {
        [discountedItems addObjectsFromArray:lastRemainingItems];
    }
    
    [self addDiscountNodesToCurrentNode:currentNode lineItems:discountedItems discountsForBill:discountGroup.discounts discountDictionary:discountDictionaryArray recursionIndex:0];

}*/

//
//- (void)addDiscountNodesToCurrentNode:(GKGraphNode *)currentNode lineItems:(NSArray *)lineItems discountsForBill:(NSArray *)discountsForBill  {
//
//    // Manage this flag to check if at least one discount scheme applied
//    BOOL discountApplied = NO;
//
//    NSArray *lineItemsForNextDiscount = lineItems;
//    NSMutableArray *remainingLineItems = [[NSMutableArray alloc] init];
//    remainingLineItems = [lineItems mutableCopy];
//
//
//    for (MMDiscount *discount in discountsForBill) {
//        loopCount++;
//        numberOfTimeExcuted++;
//        BOOL isDiscountSchemeApplicable;
//        isDiscountSchemeApplicable = [discount isApplicableToLineItems:remainingLineItems];//[self isDiscountApplicable:discount lineItems:lineItems];
//
//        if (isDiscountSchemeApplicable == NO) {
//            // There are line items for this discount, but criteria for discount is not fulfilled
//            continue;
//        }
//
//        // Discount scheme applies
//        discountApplied = YES;
//
//
//        numberOfNode++;
//        DiscountGraphNode *discountNode = [[DiscountGraphNode alloc] initWithDiscount:discount primaryItems:discount.applicableLineItems secondaryItems:discount.applicableSecondaryItems];
//        [currentNode addConnectionsToNodes:@[discountNode] bidirectional:NO];
//
//
//        if (discount.applicableRefundLineItems.count > 0) {
//            DiscountGraphNode *discountRefundNode = [[DiscountGraphNode alloc] initWithDiscount:discount primaryItems:discount.applicableRefundLineItems secondaryItems:discount.applicableSecondaryRefundLineItems];
//            [discountNode addConnectionsToNodes:@[discountRefundNode] bidirectional:NO];
//
//            discountNode = discountRefundNode;
//        }
//
//
//
//
//        //      NSMutableArray *remaningLineItems;
//        //        remaningLineItems = [discount remaningLineItems:lineItems];
//        //        NSLog(@"applicableLineItems %@",discount.applicableLineItems);
//        //        NSLog(@"remainingLineItems %@",discount.remainingLineItems);
//
//        // Recurrsive call
//
//    }
//
//    // Check if any scheme was applied
//    if (!discountApplied) {
//        // No scheme applied
//
//        GKGraphNode *x = currentNode;
//
//        for (LineItem *aLineItem in lineItems) {
//
//            if (aLineItem.itemQty.integerValue == 0) {
//                continue;
//            }
//
//            NSString *name = @"Zero";
//
//            if (aLineItem.isRefundItem.boolValue == TRUE) {
//                name = @"Refund";
//
//            }
//
//            MMDiscount *zeroDiscount = [[MMDiscount alloc] initWithDictionary:@{
//                                                                                @"Value": @(0),
//                                                                                @"Name": name
//                                                                                } ];
//
//
//            DiscountGraphNode *discountNode = [[DiscountGraphNode alloc] initWithDiscount:zeroDiscount primaryItems:@[aLineItem] secondaryItems:nil];
//
//            [x addConnectionsToNodes:@[discountNode] bidirectional:NO];
//            x = discountNode;
//        }
//
//        [x addConnectionsToNodes:@[tailNode] bidirectional:NO];
//    }
//    [self addDiscountNodesToCurrentNode:currentNode lineItems:lineItemsForNextDiscount discountsForBill:discountsForBill ];
//
//}

-(void)configureDiscountArray:(NSArray *)discountArray currentNode:(GKGraphNode *)currentNode applyDiscountToLineItems:(NSArray *)lineItems discountDictionary:(NSMutableArray *)discountDictionaryArray withBaseNode:(GKGraphNode *)baseNode
{
    if (discountArray.count == 0) {
        GKGraphNode *x = currentNode;
        for (LineItem *aLineItem in lineItems) {
            if (aLineItem.itemQty.integerValue == 0) {
                continue;
            }
            
            NSString *name = @"Zero";
            if (aLineItem.isRefundItem.boolValue == TRUE) {
                name = @"Refund";
            }
            MMDiscount *zeroDiscount = [[MMDiscount alloc] initWithDictionary:@{
                                                                                @"Value": @(0),
                                                                                @"Name": name
                                                                                } ];
            DiscountGraphNode *discountNode = [[DiscountGraphNode alloc] initWithDiscount:zeroDiscount primaryItems:@[aLineItem] secondaryItems:nil];
            
            [x addConnectionsToNodes:@[discountNode] bidirectional:NO];
            x = discountNode;
        }
        [x addConnectionsToNodes:@[tailNode] bidirectional:NO];
    }
    
    if (currentExcucatingDiscount >= discountArray.count ) {
        NSLog(@"all calculation is finish");
        return;
    }
    MMDiscount *discount =   [discountArray objectAtIndex:currentExcucatingDiscount];
    discountArrayForCalulation = [discountArray mutableCopy];
    [discountArrayForCalulation removeObject:discount];
    [discountArrayForCalulation insertObject:discount atIndex:0];
    [self performNextDiscountWithCurrentNode:baseNode applyDiscountToLineItems:lineItems discountDictionary:discountDictionaryArray discountArray:discountArray withBaseNode:baseNode];
}

-(void)performNextDiscountWithCurrentNode:(GKGraphNode *)currentNode applyDiscountToLineItems:(NSArray *)lineItems discountDictionary:(NSMutableArray *)discountDictionaryArray discountArray:(NSArray *)discountArray withBaseNode:(GKGraphNode *)baseNode
{
    
    if (discountArrayForCalulation.count == 0) {
            GKGraphNode *x = currentNode;
            for (LineItem *aLineItem in lineItems) {
                if (aLineItem.itemQty.integerValue == 0) {
                    continue;
                }
                
                NSString *name = @"Zero";
                if (aLineItem.isRefundItem.boolValue == TRUE) {
                    name = @"Refund";
                }
                MMDiscount *zeroDiscount = [[MMDiscount alloc] initWithDictionary:@{
                                                                                    @"Value": @(0),
                                                                                    @"Name": name
                                                                                    } ];
                DiscountGraphNode *discountNode = [[DiscountGraphNode alloc] initWithDiscount:zeroDiscount primaryItems:@[aLineItem] secondaryItems:nil];
                
                [x addConnectionsToNodes:@[discountNode] bidirectional:NO];
                x = discountNode;
            }
            [x addConnectionsToNodes:@[tailNode] bidirectional:NO];
        currentExcucatingDiscount++;
        [self configureDiscountArray:discountArray currentNode:currentNode applyDiscountToLineItems:localLineItemArray discountDictionary:discountDictionaryArray withBaseNode:baseNode];
        return;
    }
    
    [self addDiscountNodesToModifiedCurrentNode:currentNode applyDiscountToLineItems:lineItems discountDictionary:discountDictionaryArray discountArray:discountArray withBaseNode:baseNode];
}
-(void)addDiscountNodesToModifiedCurrentNode:(GKGraphNode *)currentNode applyDiscountToLineItems:(NSArray *)lineItems discountDictionary:(NSMutableArray *)discountDictionaryArray discountArray:(NSArray *)discountArray withBaseNode:(GKGraphNode *)baseNode
{
    MMDiscount *discount = [discountArrayForCalulation firstObject];
    loopCount++;
    numberOfTimeExcuted++;
 
    BOOL discountApplied = NO;

    if ([self isDiscountLimitValidForDiscount:discountDictionaryArray withDiscount:discount.discount_M] == FALSE) {
        [discountArrayForCalulation removeObject:discount];
        [self performNextDiscountWithCurrentNode:currentNode applyDiscountToLineItems:lineItems discountDictionary:discountDictionaryArray discountArray:discountArray withBaseNode:baseNode];
        return;
    }
    
    BOOL isDiscountSchemeApplicable;
    
    if ([discount isKindOfClass:[MMOddQtyDiscount class]]) {
        isDiscountSchemeApplicable = [discount isApplicableToLineItems:lineItems withDiscountArray:discountDictionaryArray];//[self isDiscountApplicable:discount lineItems:lineItems];
        if (isDiscountSchemeApplicable == TRUE) {
            discountDictionaryArray = discount.updatedDiscountDictionaryArray;
        }
    }
    else
    {
        isDiscountSchemeApplicable = [discount isApplicableToLineItems:lineItems];//[self
    }
    
    
    if (isDiscountSchemeApplicable == NO) {
        [discountArrayForCalulation removeObject:discount];
        [self performNextDiscountWithCurrentNode:currentNode applyDiscountToLineItems:lineItems discountDictionary:discountDictionaryArray discountArray:discountArray withBaseNode:baseNode];
        return;

    }
    discountApplied = YES;
    numberOfNode++;
    DiscountGraphNode *discountNode = [[DiscountGraphNode alloc] initWithDiscount:discount primaryItems:discount.applicableLineItems secondaryItems:discount.applicableSecondaryItems];
    [currentNode addConnectionsToNodes:@[discountNode] bidirectional:NO];
    
    
    if (discount.applicableRefundLineItems.count > 0) {
        DiscountGraphNode *discountRefundNode = [[DiscountGraphNode alloc] initWithDiscount:discount primaryItems:discount.applicableRefundLineItems secondaryItems:discount.applicableSecondaryRefundLineItems];
        [discountNode addConnectionsToNodes:@[discountRefundNode] bidirectional:NO];
        
        discountNode = discountRefundNode;
    }
    
    [self addDiscountNodesToModifiedCurrentNode:discountNode applyDiscountToLineItems:discount.remainingLineItems discountDictionary:[self updateDiscountDictionary:[[discountDictionaryArray mutableCopy] mutableCopy] withDiscount:discount.discount_M withRecursionIndex:0] discountArray:discountArray withBaseNode:baseNode];
}

- (void)addDiscountNodesToCurrentNode:(GKGraphNode *)currentNode lineItems:(NSArray *)lineItems discountsForBill:(NSArray *)discountsForBill discountDictionary:(NSMutableArray *)discountDictionaryArray recursionIndex:(NSInteger )index discountGraphTailNode:(GKGraphNode *)graphTailNode  {

    // Manage this flag to check if at least one discount scheme applied
    BOOL discountApplied = NO;
    
   // NSLog(@"Rescursion Index = %ld",(long)index);
    
    
    NSMutableArray *discountsForBillMutableCopy = [discountsForBill mutableCopy];
    
    for (MMDiscount *discount in discountsForBill) {
        loopCount++;
        numberOfTimeExcuted++;
      //  NSLog(@"discount = %@",discount);
        
    if ([self isDiscountLimitValidForDiscount:discountDictionaryArray withDiscount:discount.discount_M] == FALSE) {
            continue;
        }
        
        BOOL isDiscountSchemeApplicable;
        
        if ([discount isKindOfClass:[MMOddQtyDiscount class]]) {
            isDiscountSchemeApplicable = [discount isApplicableToLineItems:lineItems withDiscountArray:discountDictionaryArray];//[self isDiscountApplicable:discount lineItems:lineItems];
            if (isDiscountSchemeApplicable == TRUE) {
                discountDictionaryArray = discount.updatedDiscountDictionaryArray;
            }
        }
        else
        {
            isDiscountSchemeApplicable = [discount isApplicableToLineItems:lineItems];//[self isDiscountApplicable:discount lineItems:lineItems];
        }
        

        if (isDiscountSchemeApplicable == NO) {
            // There are line items for this discount, but criteria for discount is not fulfilled
            continue;
        }

        // Discount scheme applies
        discountApplied = YES;


        numberOfNode++;
        DiscountGraphNode *discountNode = [[DiscountGraphNode alloc] initWithDiscount:discount primaryItems:discount.applicableLineItems secondaryItems:discount.applicableSecondaryItems];
        [currentNode addConnectionsToNodes:@[discountNode] bidirectional:NO];
        
        
        if (discount.applicableRefundLineItems.count > 0) {
            DiscountGraphNode *discountRefundNode = [[DiscountGraphNode alloc] initWithDiscount:discount primaryItems:discount.applicableRefundLineItems secondaryItems:discount.applicableSecondaryRefundLineItems];
            [discountNode addConnectionsToNodes:@[discountRefundNode] bidirectional:NO];
            discountNode = discountRefundNode;
        }

        


//      NSMutableArray *remaningLineItems;
//        remaningLineItems = [discount remaningLineItems:lineItems];
//        NSLog(@"applicableLineItems %@",discount.applicableLineItems);
//        NSLog(@"remainingLineItems %@",discount.remainingLineItems);

        // Recurrsive call
        
//        [self updateDiscountDictionary:[discountDictionaryArray mutableCopy] withDiscount:discount.discount_M];
//        NSLog(@"index = %ld",(long)index);
        NSInteger currentRecursionIndex = index;

        [self addDiscountNodesToCurrentNode:discountNode lineItems:discount.remainingLineItems discountsForBill:discountsForBill discountDictionary:[self updateDiscountDictionary:[[discountDictionaryArray mutableCopy] mutableCopy] withDiscount:discount.discount_M withRecursionIndex:currentRecursionIndex] recursionIndex:index++ discountGraphTailNode:graphTailNode];
        [discountsForBillMutableCopy removeObject:discount];



    }

    
    
    if (!discountApplied) {
        GKGraphNode *x = currentNode;

        for (LineItem *aLineItem in lineItems) {
            
            if (aLineItem.itemQty.integerValue == 0) {
                continue;
            }
            NSString *name = @"Zero";
            if (aLineItem.isRefundItem.boolValue == TRUE) {
                name = @"Refund";
            }
            
            MMDiscount *zeroDiscount = [[MMDiscount alloc] initWithDictionary:@{
                                                                                @"Value": @(0),
                                                                                @"Name": name
                                                                                } ];
            DiscountGraphNode *discountNode = [[DiscountGraphNode alloc] initWithDiscount:zeroDiscount primaryItems:@[aLineItem] secondaryItems:nil];
            [x addConnectionsToNodes:@[discountNode] bidirectional:NO];
            x = discountNode;
        }
        [x addConnectionsToNodes:@[graphTailNode] bidirectional:NO];
    }
    
}

-(BOOL)isDiscountLimitValidForDiscount:(NSMutableArray *)discountDictionaryArray withDiscount:(Discount_M *)discount
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DiscountCode = %@",discount.code];
    NSArray *discountCodeFilterDictionary = [discountDictionaryArray filteredArrayUsingPredicate:predicate];
    
    NSMutableDictionary *discountDictionary = [[discountCodeFilterDictionary firstObject] mutableCopy];
    NSInteger numberOfTimeDiscountApplied = [discountDictionary[@"DiscountApplied"] integerValue] ;

    BOOL isDiscountApplicable = FALSE;
    
    
    if (discount == nil) {
      return  isDiscountApplicable = TRUE;
    }
    
    if (discount.qtyLimit.integerValue > numberOfTimeDiscountApplied || discount.qtyLimit.integerValue == 0) {
        isDiscountApplicable = TRUE;
    }
    return isDiscountApplicable;
}


-(NSMutableArray *)updateDiscountDictionary:(NSMutableArray *)discountDictionaryArray withDiscount:(Discount_M *)discount withRecursionIndex:(NSInteger)recursionIndex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DiscountCode = %@",discount.code];
    NSArray *discountCodeFilterDictionary = [discountDictionaryArray filteredArrayUsingPredicate:predicate];
    
    if (discountCodeFilterDictionary.count > 0) {
        
        NSMutableDictionary *discountDictionary = [[discountCodeFilterDictionary firstObject] mutableCopy];
        NSInteger numberOfTimeDiscountApplied = [discountDictionary[@"DiscountApplied"] integerValue] + 1;
        [discountDictionary setObject:discount.qtyLimit forKey:@"DiscountLimits"];
        [discountDictionary setObject:@(numberOfTimeDiscountApplied) forKey:@"DiscountApplied"];
        [discountDictionary setObject:discount.name forKey:@"DiscountName"];
        [discountDictionary setObject:discount.code forKey:@"DiscountCode"];
        [discountDictionary setObject:@(recursionIndex) forKey:@"RecursionIndex"];

        [discountDictionaryArray removeObject:[discountCodeFilterDictionary firstObject]];
        [discountDictionaryArray addObject:discountDictionary];

    }
  //  NSLog(@"discountDictionary after = %@",discountDictionaryArray);
    return discountDictionaryArray;
}

- (GKGraph*)discountGraph {
    return discountGraph;
}

- (DiscountGraphNode*)headNode {
    return (DiscountGraphNode*)headNode;
}
- (DiscountGraphNode*)tailNode {
    return (DiscountGraphNode*)tailNode;
}
-(NSArray *)pathForDiscount
{
    return path;
}

-(NSDate *)getCurrentDate:(NSString *)dateFormatter withDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateFormatter];
    NSString *stringConverted = [formatter stringFromDate:date];
    NSLog(@"stringConverted = %@",stringConverted);
    
    
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *dateConverted = [formatter dateFromString:stringConverted];
    NSLog(@"dateConverted2 = %@",dateConverted);
    
    return dateConverted;
}



-(NSDate *)getCurrentTime:(NSString *)dateFormatter withDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateFormatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *stringConverted = [formatter stringFromDate:date];
    NSLog(@"stringConverted = %@",stringConverted);
    
    
    NSDate *dateConverted = [formatter dateFromString:stringConverted];
    NSLog(@"dateConverted2 = %@",dateConverted);
    
    return dateConverted;
}

-(BOOL)isValidDate:(Discount_M *)discount_M
{
    
    NSDate *today = [self getCurrentDate:@"MM/dd/yyyy" withDate:[NSDate date]]; // it will give you current date

    return [self isValidDateAndTime:discount_M.startDate withEndDate:discount_M.endDate withTodayDate:today];
}
-(BOOL)isValidDateAndTime:(NSDate *)startDate withEndDate:(NSDate *)endDate withTodayDate:(NSDate *)todayDate {
    BOOL isDateValid = FALSE;
    
    NSComparisonResult result;
    //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
    result = [todayDate compare:startDate]; // comparing two dates
    
    if(result==NSOrderedAscending)
    {
        NSLog(@"isDateInValid");
        return  isDateValid;
    }
    else if(result==NSOrderedDescending)
    {
        NSLog(@"isDateValid");
        isDateValid = TRUE;
    }
    else
    {
        isDateValid = TRUE;
        NSLog(@"Both dates are same");
    }
    
    
    if (endDate != nil) {
        NSComparisonResult result;
        //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
        result = [todayDate compare:endDate]; // comparing two dates
        
        if(result==NSOrderedAscending)
        {
            NSLog(@"isDateInValid");
            isDateValid = TRUE;
        }
        else if(result==NSOrderedDescending)
        {
            NSLog(@"isDateValid");
            isDateValid = FALSE;
        }
        else
        {
            isDateValid = TRUE;
            NSLog(@"Both dates are same");
        }
    }
    else
    {
        isDateValid = TRUE;
    }
    return isDateValid;

}
-(BOOL)isValidTime:(Discount_M *)discount_M
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *stringConverted = [formatter stringFromDate:[NSDate date]];
    NSLog(@"stringConverted = %@",stringConverted);
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *dateConverted = [formatter dateFromString:stringConverted];
    NSLog(@"dateConverted2 = %@",dateConverted);

    NSDate *todayCurrentTime = dateConverted; // it will give you current date
    NSDate * discountStartTime = [self getCurrentTime:@"HH:mm" withDate:discount_M.startTime];
    NSDate * discountEndTime = [self getCurrentTime:@"HH:mm" withDate:discount_M.endTime];
    
    BOOL isValidTime = FALSE;
    
    if([discountStartTime compare: todayCurrentTime] == NSOrderedAscending || [discountStartTime compare: todayCurrentTime] == NSOrderedSame ){
        isValidTime = TRUE;
    }
    else {
        return FALSE;
    }
    if([todayCurrentTime compare: discountEndTime] == NSOrderedAscending || [todayCurrentTime compare: discountEndTime] == NSOrderedSame ) {
        isValidTime = TRUE;
    }
    else{
        isValidTime = FALSE;
    }
    return isValidTime;
}

-(BOOL)isValidDay:(Discount_M *)discount_M
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    return [self isValidDaySelectedDay:discount_M.validDays withCurrentDay:[components weekday]];
}

-(BOOL)isValidDaySelectedDay:(NSNumber *)selectedDay withCurrentDay:(NSInteger)currentDay {
    WeekDay todayEnum = [self weekDayEnumFromWeekDayInt:currentDay];
    if (isDaySelected(selectedDay.integerValue, todayEnum)) {
        NSLog(@"Day is valid");
        return TRUE;
    }
    else {
        NSLog(@"Day is Invalid");

        return FALSE;
    }
}
-(WeekDay)weekDayEnumFromWeekDayInt:(NSInteger)currentDay {
    WeekDay todayEnum;
    switch (currentDay) {
        case 1: {
            todayEnum = WeekDaySun;
            break;
        }
        case 2: {
            todayEnum = WeekDayMon;
            break;
        }
        case 3: {
            todayEnum = WeekDayTue;
            break;
        }
        case 4: {
            todayEnum = WeekDayWed;
            break;
        }
        case 5: {
            todayEnum = WeekDayThu;
            break;
        }
        case 6: {
            todayEnum = WeekDayFri;
            break;
        }
        case 7: {
            todayEnum = WeekDaySat;
            break;
        }
    }
    return todayEnum;
}
@end
