//
//  ItemMixMatchDiscountCalculator.m
//  RapidRMS
//
//  Created by Siya Infotech on 11/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemMixMatchDiscountCalculator.h"

#import "Item+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Mix_MatchDetail+Dictionary.h"
#import "Item+Discount.h"

#import "RmsDbController.h"

#define BED_KEY_IS_QUANTITY_EDITED      @"IsQtyEdited"
#define BED_KEY_PRICE_AT_POS            @"PriceAtPos"
#define BED_KEY_ITEMID                  @"itemId"
#define BED_KEY_ITEM_DISCOUNT           @"ItemDiscount"
#define BED_KEY_IS_BASIC_DISCOUNTED     @"isBasicDiscounted"

#define BED_KEY_ITEM_BAISC_PRICE        @"ItemBasicPrice"
#define BED_KEY_ITEM_DISCOUNT_PERCENTAGE  @"ItemDiscountPercentage"
#define BED_KEY_UNPROCESSED_QUANTITY    @"UnProcessedQuantity"

#define BED_KEY_ITEM_QUANTITY           @"itemQty"



@interface ItemMixMatchDiscountCalculator () {
    NSInteger maxQuantityToProcess;
}
@property (nonatomic, strong) NSMutableArray *billReceiptArray;

@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) NSManagedObjectContext *moc;

/////////////////////
// SHOULD BE REMOVED
@property (nonatomic, strong) NSMutableDictionary *carryForwardBillEntry;
@property (nonatomic) int carryForwardQuantity;
// SHOULD BE REMOVED
/////////////////////

@end

@implementation ItemMixMatchDiscountCalculator

#pragma mark - Generic
- (instancetype)init //WithManageObjectcontext:(NSManagedObjectContext*)moc
{
    self = [super init];

    if (self) {
        RmsDbController *rmsDbController = [RmsDbController sharedRmsDbController];
        _moc = rmsDbController.managedObjectContext;
        _updateManager = [[UpdateManager alloc] initWithManagedObjectContext:_moc delegate:nil];
    }

    return self;
}


#pragma mark - Discount Calculation
- (void)calculateDiscountForBillEntries:(NSArray*)billItemEntries {
    NSArray *uniqueValues;
    uniqueValues = [self lsitOfUniqueValuesForDiscountSchemeFromArray:billItemEntries];
    // for-loop to process each key
    for (NSString *aValue in uniqueValues) {
        [self calculateDiscountForUniqueValue:aValue billEntries:billItemEntries];
    }
}

- (NSArray *)lsitOfUniqueValuesForDiscountSchemeFromArray:(NSArray *)billItemEntries {
    // Get list of unique Keys
    NSArray *uniqueValues = [self uniqueValuesFromArray:billItemEntries forKey:[self keyForDiscountScheme]];
    return uniqueValues;
}

- (NSArray *)uniqueValuesFromArray:(NSArray*)anArray forKey:(NSString *)keyName
{
    NSArray *listOfValues = [anArray valueForKey:keyName];
    NSSet *uniqueList = [NSSet setWithArray:listOfValues];
    return uniqueList.allObjects;
}

- (void)calculateDiscountForUniqueValue:(NSString *)aValue billEntries:(NSArray*)billItemEntries {
    // Prepare bunch
    NSArray *bunchToProcess = [self bunchForUniqueValue:aValue billEntries:billItemEntries];

    if (bunchToProcess.count == 0) {
        return;
    }

    NSArray *tempList = [self filterArray:billItemEntries forkey:[self keyForDiscountScheme] withValue:aValue];

    NSString *itemCode = tempList.firstObject[BED_KEY_ITEMID];

    Item *item = [_updateManager fetchItemFromDBWithItemId:itemCode shouldCreate:NO moc:_moc];

    [self willProcessBunch:bunchToProcess forItem:item billEntries:billItemEntries];
    [self calculateDiscountForBunch:bunchToProcess forItem:item];
}

- (void)willProcessBunch:(NSArray*)bunchToProcess forItem:(Item*)item billEntries:(NSArray*)billItemEntries {
    NSArray *xBunch = [self filterArray:billItemEntries forkey:BED_KEY_ITEMID withValue:item.itemCode.stringValue];
    NSInteger xQuantity = 0;
    for (NSDictionary *billEntry in xBunch) {
        xQuantity += [billEntry[BED_KEY_ITEM_QUANTITY] integerValue];
    }
    NSInteger yQuantity = 0;
    for (NSDictionary *billEntry in bunchToProcess) {
        yQuantity += [billEntry[BED_KEY_ITEM_QUANTITY] integerValue];
    }
    NSInteger xApplicationFactor;
    NSInteger yApplicationFactor;

    switch (item.itemMixMatchDisc.discCode.integerValue)
    {
        case MIX_MATCH_DISCOUNT_SALES_PRICE:
        case MIX_MATCH_DISCOUNT_PERCENTAGE_OFF:
        {
            xApplicationFactor = xQuantity / item.itemMixMatchDisc.mix_Match_Qty.integerValue;
            yApplicationFactor = xApplicationFactor;
        }
            break;
        case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE:
        case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF:
        {
            xApplicationFactor = xQuantity / item.itemMixMatchDisc.quantityX.integerValue;
            yApplicationFactor = yQuantity / item.itemMixMatchDisc.quantityY.integerValue;
        }
            break;
        default:
        {
            xApplicationFactor = 0;
            yApplicationFactor = 0;
        }
            break;
    }


    maxQuantityToProcess = MIN(xApplicationFactor, yApplicationFactor) * item.itemMixMatchDisc.quantityY.integerValue;
}

- (void)didProcessQuantity:(NSInteger)quantityProcessed {
    maxQuantityToProcess -= quantityProcessed;
}


- (void)calculateDiscountForBunch:(NSArray*)bunchToProcess forItem:(Item*)item {

    if (maxQuantityToProcess == 0) {
        return;
    } else if (maxQuantityToProcess < 0) {
        return;
    }

    NSMutableArray *tempArray = [self sortBillReceiptArrayOnItemQuantity:bunchToProcess key:BED_KEY_UNPROCESSED_QUANTITY];
    bunchToProcess = [NSArray arrayWithArray:tempArray];

    // Get QD Entries for this item
    NSArray *qdDiscountEntries = [self applicableDiscountData:item];
    qdDiscountEntries = [self sortDiscountArrayOnDiscountQuantity:qdDiscountEntries];

    if (qdDiscountEntries.count == 0) {
        // There are no discount entries
        return;
    }

    // Total quantity of this bunch
    NSInteger totalBunchQuantity = [self quantityFromBunch:bunchToProcess];
    NSDictionary *applicableDiscountDictionary;

    for (NSDictionary *qdDiscountDictionary in qdDiscountEntries) {
        NSInteger groupingQuantity = [qdDiscountDictionary[@"DIS_Qty"] integerValue];

        // Need to consider _carryForwardQuantity
        if ((totalBunchQuantity) >= groupingQuantity) {
            // This is QD entry that is applicable
            applicableDiscountDictionary = qdDiscountDictionary;
            break;
        }
    }

    if (applicableDiscountDictionary == nil) {
        // There is QD applicable on this bunch
        return;
    }

    [self clearQuantityEditingFlagForBunch:bunchToProcess];

    // Get the quantity for grouping
    NSInteger groupingQuantity = [applicableDiscountDictionary[@"DIS_Qty"] integerValue];

    NSArray *selectionArray = @[];
    NSDictionary *unusedVariable;
    for (unusedVariable in bunchToProcess) {
        selectionArray = [selectionArray arrayByAddingObject:@(0)];
    }

    selectionArray = [self groupBunch:bunchToProcess selectionArray:selectionArray groupingQuantity:groupingQuantity index:0];

    NSArray *selectedBunch = [self bunchFromArray:bunchToProcess selectionArray:selectionArray selected:YES];

    if (selectedBunch.count > 0) {
        [self calculateDiscountForBunch:selectedBunch forItem:item forDiscountDictionary:applicableDiscountDictionary];

        [self calculateDiscountForBunch:bunchToProcess forItem:item];
        return;
    }


    NSArray *remainingBunch = [self bunchFromArray:bunchToProcess selectionArray:selectionArray selected:NO];

    if (remainingBunch.count <= 0) {
        return;
    }

    NSInteger remainingQuantity = [self quantityFromBunch:remainingBunch];
    NSInteger groupingQuantityx = [applicableDiscountDictionary[@"DIS_Qty"] integerValue];

    if (remainingQuantity + _carryForwardQuantity >= groupingQuantityx) {
        // Now what ???

        // Need to break down remaining bunch in parts

        NSInteger applicationFactor = (remainingQuantity + _carryForwardQuantity) / groupingQuantityx;

        NSInteger nextBunchQuantity = applicationFactor * groupingQuantityx;

        int quantitySum = 0;

        NSMutableArray *nextBunch = [NSMutableArray array];
        NSMutableArray *leftOverBunch = [NSMutableArray array];

        for (NSMutableDictionary *billEntryDictionary in remainingBunch) {
            if (quantitySum < nextBunchQuantity) {
                [nextBunch addObject:billEntryDictionary];
            } else {
                [leftOverBunch addObject:billEntryDictionary];
            }

            quantitySum += [billEntryDictionary[BED_KEY_UNPROCESSED_QUANTITY] integerValue];
        }

        // Next bunch for same QD scheme
        [self calculateDiscountForBunch:nextBunch forItem:item forDiscountDictionary:applicableDiscountDictionary];
        
    }
    
    [self calculateDiscountForBunch:bunchToProcess forItem:item];
}

- (void)calculateDiscountForBunch:(NSArray*)bunchToProcess forItem:(Item*)item forDiscountDictionary:(NSDictionary*)qdDiscountDictionary {

    NSInteger billEntryIndex = 0;
    NSInteger billEntryCount = bunchToProcess.count;


    NSInteger groupingQuantity = [qdDiscountDictionary[@"DIS_Qty"] integerValue];
    NSInteger pendingBunchQuantity = [self quantityFromBunch:bunchToProcess];


    NSInteger leftOverQuantity = 0;

    if (_carryForwardBillEntry) {
        leftOverQuantity = _carryForwardQuantity;
    }
    pendingBunchQuantity += leftOverQuantity;

    // Start the loop now
    for (NSMutableDictionary *billEntryDictionary in bunchToProcess) {
        if (maxQuantityToProcess == 0) {
            return;
        } else if (maxQuantityToProcess < 0) {
            return;
        }

        billEntryIndex++;

        NSInteger unProcessedQuantity = [billEntryDictionary[BED_KEY_UNPROCESSED_QUANTITY] integerValue];

        unProcessedQuantity = MIN(unProcessedQuantity, maxQuantityToProcess);

        CGFloat unitSalesPrice = [billEntryDictionary[BED_KEY_ITEM_BAISC_PRICE] floatValue];
        NSInteger billEntryQuantity = [billEntryDictionary[BED_KEY_ITEM_QUANTITY] integerValue];
        NSInteger totalQuantity = unProcessedQuantity + leftOverQuantity;

        if (pendingBunchQuantity >= groupingQuantity) {
            // Process full discount on billEntryQuantity

            // adjust values now
            pendingBunchQuantity -= ((totalQuantity / groupingQuantity) * groupingQuantity);
            leftOverQuantity = totalQuantity % groupingQuantity;

            NSInteger excludeQuantity = 0;

            if (billEntryIndex == billEntryCount) {
                excludeQuantity = totalQuantity % groupingQuantity;
            }

            // Discount calculation is here
            CGFloat qdOnSingleQuantity = unitSalesPrice - [self singleQuantityDiscountedPriceForDiscountDictionary:qdDiscountDictionary];
            CGFloat qdOnThisEntry = qdOnSingleQuantity * (unProcessedQuantity - excludeQuantity);

            [self didProcessQuantity:(unProcessedQuantity - excludeQuantity)];

            if (billEntryDictionary[BED_KEY_PRICE_AT_POS]) {
                qdOnThisEntry = 0;
            }


            qdOnThisEntry += [billEntryDictionary[@"TotalDiscount"] floatValue];

            CGFloat totalSalesPrice = unitSalesPrice * billEntryQuantity;

            CGFloat averageSalesPrice = (totalSalesPrice - qdOnThisEntry) / billEntryQuantity;

            billEntryDictionary[@"TotalPrice"] = @(totalSalesPrice - qdOnThisEntry);

            billEntryDictionary[@"TotalDiscount"] = @(qdOnThisEntry);
            billEntryDictionary[@"itemPrice"] = @(averageSalesPrice);
            billEntryDictionary[BED_KEY_ITEM_DISCOUNT] = @(qdOnThisEntry / [billEntryDictionary[BED_KEY_ITEM_QUANTITY] integerValue]);


            billEntryDictionary[BED_KEY_UNPROCESSED_QUANTITY] = @(excludeQuantity);


            NSString *itemDiscountPercentage = [NSString stringWithFormat:@"%f", qdOnThisEntry / unitSalesPrice*100];
            float Percentage = itemDiscountPercentage.floatValue  / [billEntryDictionary[BED_KEY_ITEM_QUANTITY] integerValue];
            billEntryDictionary[@"ItemDiscountPercentage"] = @(Percentage);
        } else {
            // Leave remaining entries
            // Can't process further
            // NEED TO ADDRESS THIS
            return;
        }


    }
}

- (CGFloat)singleQuantityDiscountedPriceForDiscountDictionary:(NSDictionary*)qdDiscountDictionary {
    CGFloat discountedPrice = [qdDiscountDictionary[@"DIS_UnitPrice"] floatValue] / [qdDiscountDictionary[@"DIS_Qty"] floatValue];
    return discountedPrice;
}

- (NSArray *)applicableDiscountData:(Item*)item {

    NSNumber *discountQuantity = @(0);
    CGFloat discountedPrice=0.00;
    CGFloat mixmatchAmount=0.00;
    CGFloat salesPrice=0.00;

    switch (item.itemMixMatchDisc.discCode.integerValue)
    {
        case MIX_MATCH_DISCOUNT_SALES_PRICE:
        case MIX_MATCH_DISCOUNT_PERCENTAGE_OFF:
        {
            mixmatchAmount = item.itemMixMatchDisc.mix_Match_Amt.floatValue;
            discountQuantity = item.itemMixMatchDisc.mix_Match_Qty;
            salesPrice = item.salesPrice.floatValue;
        }
            break;
        case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE:
        case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF:
        {
            mixmatchAmount = item.itemMixMatchDisc.amount.floatValue;
            discountQuantity = item.itemMixMatchDisc.quantityY;

            Item *itemY = [_updateManager fetchItemFromDBWithItemId:item.itemMixMatchDisc.code.stringValue shouldCreate:NO moc:_moc];
            salesPrice = itemY.salesPrice.floatValue;
        }

            break;
    }

    switch (item.itemMixMatchDisc.discCode.integerValue)
    {
        case MIX_MATCH_DISCOUNT_SALES_PRICE:
        case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE:
            discountedPrice = (salesPrice * discountQuantity.integerValue) - mixmatchAmount;
            break;
        case MIX_MATCH_DISCOUNT_PERCENTAGE_OFF:
        case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF:
            discountedPrice = salesPrice * discountQuantity.integerValue * (1.0 - mixmatchAmount / 100.0);
            break;
    }

    NSMutableArray *discountDataArray = [NSMutableArray array];

    [discountDataArray addObject:@{@"DIS_Qty": discountQuantity.stringValue, @"DIS_UnitPrice": @(discountedPrice)}];
    
    return discountDataArray;
}

- (NSMutableArray*)sortDiscountArrayOnDiscountQuantity:(NSArray*)itmDiscountArray
{
    // first array order by discount array in desc (max Qty wise)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"DIS_Qty"
                                                                   ascending:NO ];
    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
    NSArray *sortedArray = [itmDiscountArray sortedArrayUsingDescriptors:sortDescriptors];

    return [sortedArray mutableCopy];
}

#pragma mark - Grouping
- (NSArray *)bunchForUniqueValue:(NSString *)aValue billEntries:(NSArray*)billItemEntries {
    NSArray *bunchToProcess = [self filterArray:billItemEntries forkey:[self keyForDiscountScheme] withValue:aValue];
    NSString *itemCode = bunchToProcess.firstObject[BED_KEY_ITEMID];

    Item *item = [_updateManager fetchItemFromDBWithItemId:itemCode shouldCreate:NO moc:_moc];
    if (item.itemMixMatchDisc)
    {
        switch (item.itemMixMatchDisc.discCode.integerValue)
        {
            case MIX_MATCH_DISCOUNT_SALES_PRICE:
            case MIX_MATCH_DISCOUNT_PERCENTAGE_OFF:
                break;
            case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE:
            case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF:
                bunchToProcess = [self filterArray:billItemEntries forkey:BED_KEY_ITEMID withValue:item.itemMixMatchDisc.code.stringValue];
                break;
        }
    } else {
        bunchToProcess = nil;
    }
    return bunchToProcess;
}

- (NSArray*)filterArray:(NSArray*)array forkey:(NSString *)key withValue:(id)value {
    NSPredicate *itemCodePredicate = [NSPredicate predicateWithFormat:@"%K = %@", key, value];
    NSArray *filteredArray = [array filteredArrayUsingPredicate:itemCodePredicate];

    return filteredArray;
}

- (NSInteger)quantityFromBunch:(NSArray*)anArray forSelectionArray:(NSArray*)selectionArray {
    NSInteger quantity = 0;

    for (int index = 0; index < anArray.count; index++) {
        NSDictionary *billEntryDictionary = anArray[index];
        NSInteger currentQuantity = [billEntryDictionary[BED_KEY_UNPROCESSED_QUANTITY] integerValue];
        NSInteger currentSelection = [selectionArray[index] integerValue];
        quantity += (currentQuantity * currentSelection);
    }
    return quantity;
}

- (NSInteger)quantityFromBunch:(NSArray*)anArray {
    NSInteger quantity = 0;

    for (int index = 0; index < anArray.count; index++) {
        NSDictionary *billEntryDictionary = anArray[index];
        NSInteger currentQuantity = [billEntryDictionary[BED_KEY_UNPROCESSED_QUANTITY] integerValue];
        quantity += currentQuantity;
    }
    return quantity;
}

- (NSArray*)groupBunch:(NSArray*)anArray selectionArray:(NSArray*)selectionArray groupingQuantity:(NSInteger)groupingQuantity index:(int)index {

    if (index >= anArray.count) {
        return selectionArray;
    }
    NSArray *selectionArray_0 = [self groupBunch:anArray selectionArray:selectionArray groupingQuantity:groupingQuantity index:(index + 1)];
    NSMutableArray *selectionArray_1 = [selectionArray mutableCopy];
    selectionArray_1[index] = @(1);

    selectionArray_1 = [[self groupBunch:anArray selectionArray:selectionArray_1 groupingQuantity:groupingQuantity index:(index + 1)] mutableCopy];

    //    NSInteger quantity1 = [self quantityFromBunch:anArray forSelectionArray:selectionArray_0];
    NSInteger quantity2 = [self quantityFromBunch:anArray forSelectionArray:selectionArray_1];

    NSArray *updatedSelectionArray;
    if ((quantity2 != 0) && ((quantity2 % groupingQuantity) == 0)) {
        updatedSelectionArray = selectionArray_1;
    } else {
        updatedSelectionArray = selectionArray_0;
    }

    return updatedSelectionArray;
}

- (NSArray*)bunchFromArray:(NSArray*)anArray selectionArray:(NSArray*)selectionArray selected:(BOOL)selected {
    NSMutableArray *requestedBunch = [NSMutableArray array];

    for (int index = 0; index < anArray.count; index++) {
        if (selected && ([selectionArray[index] integerValue] == 1)) {
            [requestedBunch addObject:anArray[index]];
        } else if (!selected && ([selectionArray[index] integerValue] == 0)) {
            [requestedBunch addObject:anArray[index]];
        }
    }

    return requestedBunch;
}

#pragma mark - Utility
- (void)clearQuantityEditingFlagForBunch:(NSArray *)bunchToProcess {
    // Need to check if quantity was edited
    for (NSMutableDictionary *billEntry in bunchToProcess) {
        // if there is Price At POS
        if (billEntry[BED_KEY_PRICE_AT_POS]) {
            // This entry has Price Set at POS
            // Now check if quantity was edited
            if ([billEntry[BED_KEY_IS_QUANTITY_EDITED] boolValue] == YES) {
                // Quantity was edited
                // Remove PriceAtPOS Key
                [billEntry removeObjectForKey:BED_KEY_PRICE_AT_POS];
                [billEntry removeObjectForKey:BED_KEY_IS_QUANTITY_EDITED];
            }
        }
    }
}

- (NSMutableArray*)sortBillReceiptArrayOnItemQuantity:(NSArray*)billReceiptArray key:(NSString*)key
{
    // reminder process

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                                   ascending:NO ];
    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
    NSArray *sortedArray = [billReceiptArray sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedArray mutableCopy];
}

#pragma mark - Discount Scheme Specific
- (NSString*)keyForDiscountScheme {
    return @"mixMatchId";
}



/*
///////////////////////

- (NSArray *)bunchForUniqueValue:(NSString *)aValue billEntries:(NSArray*)billItemEntries {
    NSArray *bunchToProcess = [self filterArray:billItemEntries forkey:[self keyForDiscountScheme] withValue:aValue];
    NSString *itemCode = [bunchToProcess firstObject][BED_KEY_ITEMID];

    Item *item = [_updateManager fetchItemFromDBWithItemId:itemCode shouldCreate:NO moc:_moc];
    if (item.itemMixMatchDisc)
    {
        switch ([item.itemMixMatchDisc.discCode integerValue])
        {
            case MIX_MATCH_DISCOUNT_SALES_PRICE:
            case MIX_MATCH_DISCOUNT_PERCENTAGE_OFF:
                break;
            case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE:
            case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF:
                bunchToProcess = [self filterArray:billItemEntries forkey:BED_KEY_ITEMID withValue:[item.itemMixMatchDisc.code stringValue]];
                break;
        }
    } else {
        bunchToProcess = nil;
    }
    return bunchToProcess;
}

- (void)calculateDiscountForUniqueValue:(NSString *)aValue billEntries:(NSArray*)billItemEntries {
    // Prepare bunch
    NSArray *bunchToProcess = [self bunchForUniqueValue:aValue billEntries:billItemEntries];

    if ([bunchToProcess count] == 0) {
        return;
    }

    NSArray *tempList = [self filterArray:billItemEntries forkey:[self keyForDiscountScheme] withValue:aValue];

    NSString *itemCode = [tempList firstObject][BED_KEY_ITEMID];

    Item *item = [_updateManager fetchItemFromDBWithItemId:itemCode shouldCreate:NO moc:_moc];

    [self calculateDiscountForBunch:bunchToProcess forItem:item];
}

- (void)calculateDiscountForBunch:(NSArray*)bunchToProcess {
}


- (NSArray *)uniqueValuesFromArray:(NSArray*)anArray forKey:(NSString *)keyName
{
    NSArray *listOfValues = [anArray valueForKey:keyName];
    NSSet *uniqueList = [NSSet setWithArray:listOfValues];
    return [uniqueList allObjects];
}





///////////////////////////////


-(NSDate*)getDate :(NSString *)dateString
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDate *currentDate = [dateFormater dateFromString:dateString];
    return currentDate;
}

- (BOOL)isDiscountMD2Applicable:(Item_Discount_MD2 *)idiscMd2 onDate:(NSDate *)date {
    NSComparisonResult result,result2;

    NSDate *strStartDate=[self getDate:[[idiscMd2 itemDiscount_MD2Dictionary]objectForKey:@"StartDate"]];
    NSDate *strEndDate=[self getDate:[[idiscMd2 itemDiscount_MD2Dictionary]objectForKey:@"EndDate"]];

    result = [date compare:strStartDate]; // comparing two dates
    result2 = [date compare:strEndDate]; // comparing two dates

    return (result==NSOrderedDescending && result2==NSOrderedAscending);
}

-(NSDate *)setFormatter :(NSDate *)date
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDate *currentDate = [dateFormatter dateFromString:dateString];
    return currentDate;
}

- (int)totalQuantityForItemCode:(int)itemCode
{
    int totalQuantity=0;
    if([_billReceiptArray count]>0)
    {
        for (NSDictionary *billEntryDictionary in _billReceiptArray) {
            int ircptItemId = [billEntryDictionary[BED_KEY_ITEMID] intValue];

            if(ircptItemId == itemCode)
            {
                totalQuantity += [billEntryDictionary[BED_KEY_ITEM_QUANTITY] intValue];
            }
        }
    }
    return totalQuantity;
}

- (void)resetDiscountAndPrice:(NSMutableDictionary *)billEntryDictionary
{
    [billEntryDictionary setObject:@"0" forKey:BED_KEY_ITEM_DISCOUNT];
    [billEntryDictionary setObject:@"0" forKey:BED_KEY_IS_BASIC_DISCOUNTED];
    billEntryDictionary[@"itemPrice"] = @([[billEntryDictionary objectForKey:BED_KEY_ITEM_BAISC_PRICE] floatValue]);
    billEntryDictionary[@"ItemDiscountPercentage"] = @(0);

    billEntryDictionary[BED_KEY_UNPROCESSED_QUANTITY] = @([billEntryDictionary[BED_KEY_ITEM_QUANTITY] integerValue]);
    billEntryDictionary[@"TotalDiscount"] = @(0);
}

#pragma mark - Grouping and Other restructuring
- (NSInteger)quantityFromBunch:(NSArray*)anArray forSelectionArray:(NSArray*)selectionArray {
    NSInteger quantity = 0;

    for (int index = 0; index < [anArray count]; index++) {
        NSDictionary *billEntryDictionary = anArray[index];
        NSInteger currentQuantity = [billEntryDictionary[BED_KEY_UNPROCESSED_QUANTITY] integerValue];
        NSInteger currentSelection = [selectionArray[index] integerValue];
        quantity += (currentQuantity * currentSelection);
    }
    return quantity;
}

- (NSInteger)quantityFromBunch:(NSArray*)anArray {
    NSInteger quantity = 0;

    for (int index = 0; index < [anArray count]; index++) {
        NSDictionary *billEntryDictionary = anArray[index];
        NSInteger currentQuantity = [billEntryDictionary[BED_KEY_UNPROCESSED_QUANTITY] integerValue];
        quantity += currentQuantity;
    }
    return quantity;
}

- (NSArray*)groupBunch:(NSArray*)anArray selectionArray:(NSArray*)selectionArray groupingQuantity:(int)groupingQuantity index:(int)index {

    if (index >= [anArray count]) {
        return selectionArray;
    }
    NSArray *selectionArray_0 = [self groupBunch:anArray selectionArray:selectionArray groupingQuantity:groupingQuantity index:(index + 1)];
    NSMutableArray *selectionArray_1 = [selectionArray mutableCopy];
    selectionArray_1[index] = @(1);

    selectionArray_1 = [[self groupBunch:anArray selectionArray:selectionArray_1 groupingQuantity:groupingQuantity index:(index + 1)] mutableCopy];

    //    NSInteger quantity1 = [self quantityFromBunch:anArray forSelectionArray:selectionArray_0];
    NSInteger quantity2 = [self quantityFromBunch:anArray forSelectionArray:selectionArray_1];

    NSArray *updatedSelectionArray;
    if ((quantity2 != 0) && ((quantity2 % groupingQuantity) == 0)) {
        updatedSelectionArray = selectionArray_1;
    } else {
        updatedSelectionArray = selectionArray_0;
    }

    return updatedSelectionArray;
}

- (NSArray*)bunchFromArray:(NSArray*)anArray selectionArray:(NSArray*)selectionArray selected:(BOOL)selected {
    NSMutableArray *requestedBunch = [NSMutableArray array];

    for (int index = 0; index < [anArray count]; index++) {
        if (selected && ([selectionArray[index] integerValue] == 1)) {
            [requestedBunch addObject:anArray[index]];
        } else if (!selected && ([selectionArray[index] integerValue] == 0)) {
            [requestedBunch addObject:anArray[index]];
        }
    }

    return requestedBunch;
}

- (void)calculateQDForBunch:(NSArray*)bunchToProcess forItem:(Item*)item {

    NSMutableArray *tempArray = [self sortBillReceiptArrayOnItemQuantity:bunchToProcess key:BED_KEY_UNPROCESSED_QUANTITY];
    bunchToProcess = [NSArray arrayWithArray:tempArray];
    // Get QD Entries for this item
    NSArray *qdDiscountEntries = [self applicableDiscountData:item];
    qdDiscountEntries = [self sortDiscountArrayOnDiscountQuantity:qdDiscountEntries];

    if ([qdDiscountEntries count] == 0) {
        // There are no discount entries
        return;
    }

    // Total quantity of this bunch
    int totalBunchQuantity = [self quantityFromBunch:bunchToProcess];
    NSDictionary *applicableDiscountDictionary;

    for (NSDictionary *qdDiscountDictionary in qdDiscountEntries) {
        int groupingQuantity = [qdDiscountDictionary[@"DIS_Qty"] integerValue];

        // Need to consider _carryForwardQuantity
        if ((totalBunchQuantity + _carryForwardQuantity) >= groupingQuantity) {
            // This is QD entry that is applicable
            applicableDiscountDictionary = qdDiscountDictionary;
            break;
        }
    }

    if (applicableDiscountDictionary == nil) {
        // There is QD applicable on this bunch
        return;
    }

    [self clearQuantityEditingFlagForBunch:bunchToProcess];

    // Get the quantity for grouping
    int groupingQuantity = [applicableDiscountDictionary[@"DIS_Qty"] integerValue];

    NSArray *selectionArray = [NSArray array];
    for (NSDictionary *unusedVariable in bunchToProcess) {
        selectionArray = [selectionArray arrayByAddingObject:@(0)];
    }

    selectionArray = [self groupBunch:bunchToProcess selectionArray:selectionArray groupingQuantity:groupingQuantity index:0];

    NSArray *selectedBunch = [self bunchFromArray:bunchToProcess selectionArray:selectionArray selected:YES];

    if ([selectedBunch count] > 0) {
        [self calculateQDForBunch:selectedBunch forItem:item forDiscountDictionary:applicableDiscountDictionary];

        [self calculateQDForBunch:bunchToProcess forItem:item];
        return;
    }


    NSArray *remainingBunch = [self bunchFromArray:bunchToProcess selectionArray:selectionArray selected:NO];

    if ([remainingBunch count] <= 0) {
        return;
    }

    int remainingQuantity = [self quantityFromBunch:remainingBunch];
    int groupingQuantityx = [applicableDiscountDictionary[@"DIS_Qty"] integerValue];

    if (remainingQuantity + _carryForwardQuantity >= groupingQuantityx) {
        // Now what ???

        // Need to break down remaining bunch in parts

        int applicationFactor = (remainingQuantity + _carryForwardQuantity) / groupingQuantityx;

        int nextBunchQuantity = applicationFactor * groupingQuantityx;

        int quantitySum = 0;

        NSMutableArray *nextBunch = [NSMutableArray array];
        NSMutableArray *leftOverBunch = [NSMutableArray array];

        for (NSMutableDictionary *billEntryDictionary in remainingBunch) {
            if (quantitySum < nextBunchQuantity) {
                [nextBunch addObject:billEntryDictionary];
            } else {
                [leftOverBunch addObject:billEntryDictionary];
            }

            quantitySum += [billEntryDictionary[BED_KEY_UNPROCESSED_QUANTITY] integerValue];
        }

        // Next bunch for same QD scheme
        [self calculateQDForBunch:nextBunch forItem:item forDiscountDictionary:applicableDiscountDictionary];

    }

    [self calculateQDForBunch:bunchToProcess forItem:item];
}

*/
@end
