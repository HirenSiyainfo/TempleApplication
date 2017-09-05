//
//  ItemDiscountCalculator.m
//  RapidRMS
//
//  Created by Siya Infotech on 11/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemDiscountCalculator.h"

#import "Item+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Mix_MatchDetail+Dictionary.h"
#import "Item+Discount.h"

#import "RmsDbController.h"

#define IS_QUANTITY_EDITED_KEY @"IsQtyEdited"

@interface ItemDiscountCalculator ()
@property (nonatomic, strong) NSMutableArray *billReceiptArray;

@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) NSManagedObjectContext *moc;

@property (nonatomic, strong) NSMutableDictionary *carryForwardBillEntry;
@property (nonatomic) int carryForwardQuantity;
@end

@implementation ItemDiscountCalculator
///////////////////////
- (NSArray *)bunchForUniqueValue:(NSString *)aValue billEntries:(NSArray*)billItemEntries {
    NSArray *bunchToProcess = [self filterArray:billItemEntries forkey:@"mixMatchId" withValue:aValue];
    NSString *itemCode = [bunchToProcess.firstObject valueForKey:@"itemId"];

    Item *item = [_updateManager fetchItemFromDBWithItemId:itemCode shouldCreate:NO moc:_moc];
    if (item.itemMixMatchDisc)
    {
        switch (item.itemMixMatchDisc.discCode.integerValue)
        {
            case MIX_MATCH_DISCOUNT_SALES_PRICE:
            case MIX_MATCH_DISCOUNT_PERCENTAGE_OFF:
                [self calculateDiscountForBunch:bunchToProcess forItem:item];
                break;
            default:
                bunchToProcess = nil;
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

    if (bunchToProcess.count == 0) {
        return;
    }

    NSString *itemCode = [bunchToProcess.firstObject valueForKey:@"itemId"];

    Item *item = [_updateManager fetchItemFromDBWithItemId:itemCode shouldCreate:NO moc:_moc];

    [self calculateDiscountForBunch:bunchToProcess forItem:item];
}

- (void)calculateDiscountForBunch:(NSArray*)bunchToProcess {
}

- (NSArray *)lsitOfUniqueValuesForDiscountSchemeFromArray:(NSArray *)billItemEntries {
    // Get list of unique Keys
    NSArray *uniqueValues = [self uniqueValuesFromArray:billItemEntries forKey:@"mixMatchId"];
    return uniqueValues;
}

- (void)calculateDiscountForBillEntries:(NSArray*)billItemEntries {
    NSArray *uniqueValues;
    uniqueValues = [self lsitOfUniqueValuesForDiscountSchemeFromArray:billItemEntries];
    // for-loop to process each key
    for (NSString *aValue in uniqueValues) {
        [self calculateDiscountForUniqueValue:aValue billEntries:billItemEntries];
    }
}

- (NSArray *)uniqueValuesFromArray:(NSArray*)anArray forKey:(NSString *)keyName
{
    NSArray *listOfValues = [anArray valueForKey:keyName];
    NSSet *uniqueList = [NSSet setWithArray:listOfValues];
    return uniqueList.allObjects;
}


- (NSArray*)filterArray:(NSArray*)array forkey:(NSString *)key withValue:(id)value {
    NSPredicate *itemCodePredicate = [NSPredicate predicateWithFormat:@"%K = %@", key, value];
    NSArray *filteredArray = [array filteredArrayUsingPredicate:itemCodePredicate];

    return filteredArray;
}



- (void)calculateDiscountForBunch:(NSArray*)bunchToProcess forItem:(Item*)item {

    NSMutableArray *tempArray = [self sortBillReceiptArrayOnItemQuantity:bunchToProcess key:@"UnProcessedQuantity"];
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
    NSInteger groupingQuantity = [applicableDiscountDictionary[@"DIS_Qty"] integerValue];

    NSArray *selectionArray = @[];
    NSDictionary *unusedVariable;
    for (unusedVariable in bunchToProcess) {
        selectionArray = [selectionArray arrayByAddingObject:@(0)];
    }

    selectionArray = [self groupBunch:bunchToProcess selectionArray:selectionArray groupingQuantity:groupingQuantity index:0];

    NSArray *selectedBunch = [self bunchFromArray:bunchToProcess selectionArray:selectionArray selected:YES];

    if (selectedBunch.count > 0) {
        [self calculateQDForBunch:selectedBunch forItem:item forDiscountDictionary:applicableDiscountDictionary];

        [self calculateQDForBunch:bunchToProcess forItem:item];
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

        NSInteger quantitySum = 0;

        NSMutableArray *nextBunch = [NSMutableArray array];
        NSMutableArray *leftOverBunch = [NSMutableArray array];

        for (NSMutableDictionary *billEntryDictionary in remainingBunch) {
            if (quantitySum < nextBunchQuantity) {
                [nextBunch addObject:billEntryDictionary];
            } else {
                [leftOverBunch addObject:billEntryDictionary];
            }

            quantitySum += [billEntryDictionary[@"UnProcessedQuantity"] integerValue];
        }

        // Next bunch for same QD scheme
        [self calculateQDForBunch:nextBunch forItem:item forDiscountDictionary:applicableDiscountDictionary];

    }

    [self calculateQDForBunch:bunchToProcess forItem:item];
}


///////////////////////////////

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


-(NSDate*)getDate :(NSString *)dateString
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    dateFormater.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *currentDate = [dateFormater dateFromString:dateString];
    return currentDate;
}

- (BOOL)isDiscountMD2Applicable:(Item_Discount_MD2 *)idiscMd2 onDate:(NSDate *)date {
    NSComparisonResult result,result2;

    NSDate *strStartDate=[self getDate:idiscMd2.itemDiscount_MD2Dictionary[@"StartDate"]];
    NSDate *strEndDate=[self getDate:idiscMd2.itemDiscount_MD2Dictionary[@"EndDate"]];

    result = [date compare:strStartDate]; // comparing two dates
    result2 = [date compare:strEndDate]; // comparing two dates

    return (result==NSOrderedDescending && result2==NSOrderedAscending);
}

-(NSDate *)setFormatter :(NSDate *)date
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *currentDate = [dateFormatter dateFromString:dateString];
    return currentDate;
}

- (int)totalQuantityForItemCode:(NSInteger)itemCode
{
    int totalQuantity=0;
    if(_billReceiptArray.count>0)
    {
        for (NSDictionary *billEntryDictionary in _billReceiptArray) {
            int ircptItemId=[[billEntryDictionary valueForKey:@"itemId"]intValue];

            if(ircptItemId==itemCode)
            {
                totalQuantity+=[[billEntryDictionary valueForKey:@"itemQty"]intValue];
            }
        }
    }
    return totalQuantity;
}

- (NSArray *)applicableDiscountData:(Item*)item {
//    NSString *strItemId=[NSString stringWithFormat:@"%d", itemCode];
//    Item *item = [_updateManager fetchItemFromDBWithItemId:strItemId shouldCreate:NO moc:_moc];
//
    NSInteger iqty = [self totalQuantityForItemCode:item.itemCode.integerValue];

    Item_Discount_MD2 *idiscMd2;
    NSMutableArray * itemDiscArray = [[NSMutableArray alloc]init];
    for (Item_Discount_MD *idiscMd in item.itemToDisMd )
    {
        [itemDiscArray addObjectsFromArray:idiscMd.mdTomd2.allObjects];
    }
    NSMutableArray *itmDiscountData=[[NSMutableArray alloc]init];

    for (int idisc=0; idisc<itemDiscArray.count; idisc++) {

        //  NSMutableDictionary *dict=[itemDiscArray objectAtIndex:idisc];
        idiscMd2=itemDiscArray[idisc];

        //  int iDiscqty=[[dict valueForKey:@"DIS_Qty"]integerValue];
        NSInteger iDiscqty = idiscMd2.md2Tomd.dis_Qty.integerValue;

        if(iqty>=iDiscqty)
        {
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
            NSInteger weekday = comps.weekday;

            if(idiscMd2.dayId.integerValue==0)
            {
                if ([self isDiscountMD2Applicable:idiscMd2 onDate:[self setFormatter:[NSDate date]]])
                {
                    [itmDiscountData addObject:idiscMd2.itemDiscount_MD2Dictionary];
                }
            }
            else if (idiscMd2.dayId.integerValue==weekday||idiscMd2.dayId.integerValue==-1)
            {
                if (idiscMd2.dayId.integerValue==weekday)
                {
                    if ([self isDiscountMD2Applicable:idiscMd2 onDate:[self setFormatter:[NSDate date]]])
                    {
                        [itmDiscountData addObject:idiscMd2.itemDiscount_MD2Dictionary];
                    }
                }
                else
                {
                    [itmDiscountData addObject:idiscMd2.itemDiscount_MD2Dictionary];
                }
            }
            else
            {

            }

        }
    }
    return itmDiscountData;
}

- (void)resetDiscountAndPrice:(NSMutableDictionary *)billEntryDictionary
{
    billEntryDictionary[@"ItemDiscount"] = @"0";
    billEntryDictionary[@"isBasicDiscounted"] = @"0";
    billEntryDictionary[@"itemPrice"] = @([billEntryDictionary[@"ItemBasicPrice"] floatValue]);
    billEntryDictionary[@"ItemDiscountPercentage"] = @(0);

    billEntryDictionary[@"UnProcessedQuantity"] = @([billEntryDictionary[@"itemQty"] integerValue]);
    billEntryDictionary[@"TotalDiscount"] = @(0);
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

- (NSMutableArray*)sortBillReceiptArrayOnItemQuantity:(NSArray*)billReceiptArray key:(NSString*)key
{
    // reminder process

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                                   ascending:NO ];
    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
    NSArray *sortedArray = [billReceiptArray sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedArray mutableCopy];
}

#pragma mark - Grouping and Other restructuring
- (NSInteger)quantityFromBunch:(NSArray*)anArray forSelectionArray:(NSArray*)selectionArray {
    NSInteger quantity = 0;

    for (int index = 0; index < anArray.count; index++) {
        NSDictionary *billEntryDictionary = anArray[index];
        NSInteger currentQuantity = [billEntryDictionary[@"UnProcessedQuantity"] integerValue];
        NSInteger currentSelection = [selectionArray[index] integerValue];
        quantity += (currentQuantity * currentSelection);
    }
    return quantity;
}

- (NSInteger)quantityFromBunch:(NSArray*)anArray {
    NSInteger quantity = 0;

    for (int index = 0; index < anArray.count; index++) {
        NSDictionary *billEntryDictionary = anArray[index];
        NSInteger currentQuantity = [billEntryDictionary[@"UnProcessedQuantity"] integerValue];
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

- (void)calculateQDForItem:(Item*)item {
    // Clear the carry forward if any
    _carryForwardBillEntry = nil;
    _carryForwardQuantity = 0;

    // Get bunch with Item Code
    NSString *key = @"itemId";
    NSString *value = [NSString stringWithFormat:@"%@", item.itemCode];

    // Get Bunch for this item
    NSArray *bunchToProcess = [self filterArray:_billReceiptArray forkey:key withValue:value];

    for (NSMutableDictionary *billEntryDictionary in bunchToProcess) {
        [self resetDiscountAndPrice:billEntryDictionary];
    }
    // Calculate QD on entire bunch
    [self calculateQDForBunch:bunchToProcess forItem:item];
}

- (void)clearQuantityEditingFlagForBunch:(NSArray *)bunchToProcess {
    // Need to check if quantity was edited
    for (NSMutableDictionary *billEntry in bunchToProcess) {
        // if there is Price At POS
        if (billEntry[@"PriceAtPos"]) {
            // This entry has Price Set at POS
            // Now check if quantity was edited
            if ([billEntry[IS_QUANTITY_EDITED_KEY] boolValue] == YES) {
                // Quantity was edited
                // Remove PriceAtPOS Key
                [billEntry removeObjectForKey:@"PriceAtPos"];
                [billEntry removeObjectForKey:IS_QUANTITY_EDITED_KEY];
            }
        }
    }
}

- (void)calculateQDForBunch:(NSArray*)bunchToProcess forItem:(Item*)item {

    NSMutableArray *tempArray = [self sortBillReceiptArrayOnItemQuantity:bunchToProcess key:@"UnProcessedQuantity"];
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
    NSInteger groupingQuantity = [applicableDiscountDictionary[@"DIS_Qty"] integerValue];

    NSArray *selectionArray = @[];
    NSDictionary *unusedVariable;
    for (unusedVariable in bunchToProcess) {
        selectionArray = [selectionArray arrayByAddingObject:@(0)];
    }

    selectionArray = [self groupBunch:bunchToProcess selectionArray:selectionArray groupingQuantity:groupingQuantity index:0];

    NSArray *selectedBunch = [self bunchFromArray:bunchToProcess selectionArray:selectionArray selected:YES];

    if (selectedBunch.count > 0) {
        [self calculateQDForBunch:selectedBunch forItem:item forDiscountDictionary:applicableDiscountDictionary];

        [self calculateQDForBunch:bunchToProcess forItem:item];
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

        NSInteger quantitySum = 0;

        NSMutableArray *nextBunch = [NSMutableArray array];
        NSMutableArray *leftOverBunch = [NSMutableArray array];

        for (NSMutableDictionary *billEntryDictionary in remainingBunch) {
            if (quantitySum < nextBunchQuantity) {
                [nextBunch addObject:billEntryDictionary];
            } else {
                [leftOverBunch addObject:billEntryDictionary];
            }

            quantitySum += [billEntryDictionary[@"UnProcessedQuantity"] integerValue];
        }

        // Next bunch for same QD scheme
        [self calculateQDForBunch:nextBunch forItem:item forDiscountDictionary:applicableDiscountDictionary];

    }

    [self calculateQDForBunch:bunchToProcess forItem:item];
}

- (void)calculateQDForBunch:(NSArray*)bunchToProcess forItem:(Item*)item forDiscountDictionary:(NSDictionary*)qdDiscountDictionary {

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

        billEntryIndex++;

        NSInteger unProcessedQuantity = [billEntryDictionary[@"UnProcessedQuantity"] integerValue];

        CGFloat unitSalesPrice = [billEntryDictionary[@"ItemBasicPrice"] floatValue];
        NSInteger billEntryQuantity = [billEntryDictionary[@"itemQty"] integerValue];
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
            CGFloat qdOnSingleQuantity = unitSalesPrice - [self singleQuantityQDPriceForDiscountDictionary:qdDiscountDictionary];
            CGFloat qdOnThisEntry = qdOnSingleQuantity * (unProcessedQuantity - excludeQuantity);

            if (billEntryDictionary[@"PriceAtPos"]) {
                qdOnThisEntry = 0;
            }


            qdOnThisEntry += [billEntryDictionary[@"TotalDiscount"] floatValue];

            CGFloat totalSalesPrice = unitSalesPrice * billEntryQuantity;

            CGFloat averageSalesPrice = (totalSalesPrice - qdOnThisEntry) / billEntryQuantity;

            billEntryDictionary[@"TotalPrice"] = @(totalSalesPrice - qdOnThisEntry);

            billEntryDictionary[@"TotalDiscount"] = @(qdOnThisEntry);
            billEntryDictionary[@"itemPrice"] = @(averageSalesPrice);
            billEntryDictionary[@"ItemDiscount"] = @(qdOnThisEntry / [billEntryDictionary[@"itemQty"] integerValue]);


            billEntryDictionary[@"UnProcessedQuantity"] = @(excludeQuantity);


            NSString *itemDiscountPercentage = [NSString stringWithFormat:@"%f", qdOnThisEntry / unitSalesPrice*100];
            float Percentage = itemDiscountPercentage.floatValue  / [billEntryDictionary[@"itemQty"] integerValue];
            billEntryDictionary[@"ItemDiscountPercentage"] = @(Percentage);
        } else {
            // Leave remaining entries
            // Can't process further
            // NEED TO ADDRESS THIS
            return;
        }
        
        
    }
}

- (CGFloat)singleQuantityQDPriceForDiscountDictionary:(NSDictionary*)qdDiscountDictionary {
    CGFloat discountedPrice = [qdDiscountDictionary[@"DIS_UnitPrice"] floatValue] / [qdDiscountDictionary[@"DIS_Qty"] floatValue];
    return discountedPrice;
}
@end
