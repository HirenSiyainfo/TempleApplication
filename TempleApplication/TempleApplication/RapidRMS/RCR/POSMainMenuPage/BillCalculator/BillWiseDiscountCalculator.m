//
//  BillWiseDiscountCalculator.m
//  RapidRMS
//
//  Created by siya-IOS5 on 3/5/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "BillWiseDiscountCalculator.h"
#import "RmsDbController.h"
#import "BillAmountCalculator.h"
#import "Item+Dictionary.h"

@interface BillWiseDiscountCalculator ()
{
    NSMutableArray *billDetail;
    BillAmountCalculator *billAmountCalculator;
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) UpdateManager *updateManager;

@end
@implementation BillWiseDiscountCalculator
- (instancetype)initWithReceiptArray:(NSMutableArray *)receiptArray WithBillAmountCalculator:(BillAmountCalculator *)billAmountCalc{
    self = [super init];
    
    if (self) {
        billDetail = [[NSMutableArray alloc] init];
        billDetail = receiptArray;
        billAmountCalculator = billAmountCalc;
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        self.crmController = [RcrController sharedCrmController];
        self.managedObjectContext = self.rmsDbController.managedObjectContext;
        _updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:nil];
    }
    return self;
}

-(void)calculateBillWiseDiscount
{
    switch (billAmountCalculator.billWiseDiscountType) {
        case BillWiseDiscountTypeNone:
            
            break;
        case BillWiseDiscountTypeAmount:
          [self calCulateBillWiseDiscountWithPercentageWithAmount:[self calculateBillParcentageForBill]];
            break;
            
        case BillWiseDiscountTypePercentage:
            [self calCulateBillWiseDiscountWithPercentage:billAmountCalculator.billWiseDiscount.floatValue];
            
            break;
        default:
            break;
    }

}


-(CGFloat )calculateBillParcentageForBill
{
    CGFloat billDiscountPercentage = 0.00;
    CGFloat totalSalesAmountForBill = 0.00;
    CGFloat totalRefundAmountForBill = 0.00;

    for(int i=0;i<[billDetail count];i++)
    {
        NSMutableDictionary *billEntryDict = [billDetail objectAtIndex:i];
        
        if (billEntryDict[@"ItemWiseDiscountType"])
        {
            if ([billEntryDict[@"ItemWiseDiscountType"] isEqualToString:@"Amount"]) {
                NSString *discountValue=[[billEntryDict objectForKey:@"ItemWiseDiscountValue"] stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
                float discPrice=[[NSString stringWithFormat:@"%f",[self.crmController.currencyFormatter numberFromString:discountValue].floatValue] floatValue];
                if (discPrice == 0) {
                    continue;
                }
            }
            else
            {
                if ([billEntryDict[@"ItemWiseDiscountType"] floatValue] == 0) {
                    continue;
                }
            }
        }
        
        CGFloat itemPrice = [billEntryDict[@"itemPrice"] floatValue];
        
         Item *item = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%@",[billEntryDict  valueForKey:@"itemId"]] shouldCreate:NO moc:self.managedObjectContext];
        if ([item.pos_DISCOUNT integerValue] == 1) {
            continue;
        }
        CGFloat variationCost = [billEntryDict[@"TotalVarionCost"] floatValue];
        CGFloat totalItemCostValue = (itemPrice * [[billEntryDict valueForKey:@"itemQty"] integerValue]);
        if (totalItemCostValue > 0) {
            totalSalesAmountForBill += totalItemCostValue + variationCost;
        }
        else
        {
            totalRefundAmountForBill += totalItemCostValue + variationCost;
        }

    }
    
    CGFloat diffrence = totalSalesAmountForBill + totalRefundAmountForBill;
    if (diffrence > 0 && totalSalesAmountForBill > billAmountCalculator.billWiseDiscount.floatValue) {
        billDiscountPercentage = (billAmountCalculator.billWiseDiscount.floatValue * 100) / totalSalesAmountForBill;
        if (billDiscountPercentage > 100) {
            billDiscountPercentage = 100;
        }
    }
    else
    {
        billDiscountPercentage = (billAmountCalculator.billWiseDiscount.floatValue * 100) / totalRefundAmountForBill;
        if (billDiscountPercentage > 100) {
            billDiscountPercentage = 100;
        }
    }
    return billDiscountPercentage;
}
-(void)calCulateBillWiseDiscountWithPercentageWithAmount :(CGFloat )percentage
{
    for(int i=0;i<[billDetail count];i++)
    {
        NSMutableDictionary *dict = [billDetail objectAtIndex:i];
        
        if ([[dict objectForKey:@"IsRefundFromInvoice"] boolValue] == TRUE) {
            continue;
        }
        
        
        if (!([dict[@"item"][@"isCheckCash"] boolValue]==YES))
        {
            if (!dict[@"ItemWiseDiscountType"])
            {
                Item *item = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%@",[dict  valueForKey:@"itemId"]] shouldCreate:NO moc:self.managedObjectContext];
                
                if ([item.pos_DISCOUNT integerValue] == 0)
                {
                    NSNumber *itemPrice = nil;
                    
                    
                    if (dict[@"PriceAtPos"])
                    {
                        itemPrice = @([dict[@"PriceAtPos"] floatValue]/[dict[@"PackageQty"] integerValue]);
                    }
                    else
                    {
                        itemPrice = dict[@"itemPrice"];
                    }
                    itemPrice = @(itemPrice.floatValue * [dict[@"itemQty"] floatValue]);
                    
                    CGFloat percentageForAmountCalcuation = percentage;
                    if (percentage > 0) {
                        if (itemPrice.floatValue < 0) {
                            continue;
                        }
                    }
                    else
                    {
                        if (itemPrice.floatValue > 0) {
                            continue;
                        }
                        percentageForAmountCalcuation = -percentageForAmountCalcuation;
                    }
                    
                        CGFloat totalVariationForItem = [self calculateTotalForVariationDictionary:dict];
                        
                        CGFloat totalVariationDiscountForItem = [self calculateBillDiscountForVariationDictionary:dict withPercentage:percentageForAmountCalcuation];
                     
                        CGFloat discountForItem = ([itemPrice floatValue]* percentageForAmountCalcuation * 0.01) + totalVariationDiscountForItem;
                        
                        dict[@"ItemExternalDiscount"] = @(discountForItem);
                        
                        
                        NSNumber *discountId = @(0);
                        
                        if (dict[@"SalesManualDiscountId"]) {
                            discountId = dict[@"SalesManualDiscountId"];
                        }
                        
                        if ([[self discountTypeForBill] length] > 0) {
                            NSMutableDictionary *billDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                           [self discountTypeForBill], @"DiscountType",
                                                           @(discountForItem),@"Amount",
                                                                           @"Bill",@"AppliedOn",
                                                                           discountId,@"DiscountId",nil];
                            NSMutableArray *discountArray = [dict valueForKey:@"Discount"];
                            [discountArray addObject:billDiscountDictionary];
                        }
                        
                        dict[@"itemPrice"] = @(([itemPrice floatValue] - discountForItem)/[dict[@"itemQty"] floatValue]);
                        
                        float itemOrignalDiscount = [[dict objectForKey:@"ItemDiscount"] floatValue] + discountForItem;
                        
                        [dict setValue:[NSString stringWithFormat:@"%f",itemOrignalDiscount] forKey:@"ItemDiscount"];
                        
                        
                        CGFloat totalDiscountedVariationForItem = totalVariationForItem - totalVariationDiscountForItem;
                        
                        dict[@"TotalVarionCost"] = @(totalDiscountedVariationForItem * [[dict valueForKey:@"itemQty"] floatValue]) ;
                        
                }
            }
        }
    }
}



-(void)calCulateBillWiseDiscountWithPercentage :(CGFloat )percentage
{
    for(int i=0;i<[billDetail count];i++)
    {
        NSMutableDictionary *dict = [billDetail objectAtIndex:i];
        
        if ([[dict objectForKey:@"IsRefundFromInvoice"] boolValue] == TRUE) {
            continue;
        }

        
        if (!([dict[@"item"][@"isCheckCash"] boolValue]==YES))
        {
            if (!dict[@"ItemWiseDiscountType"])
            {
                Item *item = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%@",[dict  valueForKey:@"itemId"]] shouldCreate:NO moc:self.managedObjectContext];
                
                if ([item.pos_DISCOUNT integerValue] == 0)
                {
                    NSNumber *itemPrice = nil;
                    
                    
                    if (dict[@"PriceAtPos"])
                    {
                        itemPrice = @([dict[@"PriceAtPos"] floatValue]/[dict[@"PackageQty"] integerValue]);
                    }
                    else
                    {
                        itemPrice = dict[@"itemPrice"];
                    }
                    
                        itemPrice = @(itemPrice.floatValue * [dict[@"itemQty"] floatValue]);
                    
                        CGFloat totalVariationForItem = [self calculateTotalForVariationDictionary:dict];
                        
                        CGFloat totalVariationDiscountForItem = [self calculateBillDiscountForVariationDictionary:dict withPercentage:percentage];
                        if (percentage < 0 ) {
                            percentage = -percentage;
                        }
                        CGFloat discountForItem = ([itemPrice floatValue]* percentage * 0.01) + totalVariationDiscountForItem;
                        
                        dict[@"ItemExternalDiscount"] = @(discountForItem);
                        
                        
                        NSNumber *discountId = @(0);
                        
                        if (dict[@"SalesManualDiscountId"]) {
                            discountId = dict[@"SalesManualDiscountId"];
                        }
                        
                        if ([[self discountTypeForBill] length] > 0) {
                            NSMutableDictionary *billDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                           [self discountTypeForBill], @"DiscountType",
                                                                           @(discountForItem),@"Amount",
                                                                           @"Bill",@"AppliedOn",
                                                                           discountId,@"DiscountId",nil];
                            NSMutableArray *discountArray = [dict valueForKey:@"Discount"];
                            [discountArray addObject:billDiscountDictionary];
                        }
                        
                        dict[@"itemPrice"] = @(([itemPrice floatValue] - discountForItem) / [dict[@"itemQty"] floatValue]);
                        
                        float itemOrignalDiscount = [[dict objectForKey:@"ItemDiscount"] floatValue] + discountForItem;
                        
                        [dict setValue:[NSString stringWithFormat:@"%f",itemOrignalDiscount] forKey:@"ItemDiscount"];
                        
                        
                        CGFloat totalDiscountedVariationForItem = totalVariationForItem - totalVariationDiscountForItem;
                        
                        dict[@"TotalVarionCost"] = @(totalDiscountedVariationForItem * [[dict valueForKey:@"itemQty"] floatValue]) ;
                        
                }
            }
        }
    }
}

-(CGFloat )calculateTotalForVariationDictionary :(NSDictionary *)dictionary
{
    CGFloat totalVarionCost = 0.0;
    
    if ([dictionary objectForKey:@"InvoiceVariationdetail"])
    {
        totalVarionCost = [[(NSArray *)[dictionary objectForKey:@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.VariationBasicPrice"] floatValue] ;
    }
    return totalVarionCost;
}

-(CGFloat )calculateBillDiscountForVariationDictionary :(NSDictionary *)dictionary withPercentage:(CGFloat )percentage
{
    CGFloat totalVarionDiscount = 0.0;
    
    if ([dictionary objectForKey:@"InvoiceVariationdetail"])
    {
        NSMutableArray *variationDetailForItem = [dictionary objectForKey:@"InvoiceVariationdetail"];
        for (NSMutableDictionary *variationDictionary in variationDetailForItem)
        {
            CGFloat variationPrice = [variationDictionary[@"VariationBasicPrice"] floatValue];
            
            float despriceForVariation = (variationPrice * percentage * 0.01);
            
            totalVarionDiscount += despriceForVariation;
            
            variationPrice = variationPrice - despriceForVariation;
            
            [variationDictionary setValue:[NSString stringWithFormat:@"%f",variationPrice] forKey:@"Price"];
        }
    }
    return totalVarionDiscount;
}

-(NSString *)discountTypeForBill
{
    NSString *discountType = @"";
    switch (billAmountCalculator.billWiseDiscountType) {
        case BillWiseDiscountTypeNone:
            discountType = @"";
            break;
        case BillWiseDiscountTypeAmount:
            discountType = @"Amount";
            
            break;
            
        case BillWiseDiscountTypePercentage:
            discountType = @"Percentage";
            
            break;
        default:
            break;
    }
    return discountType;
    
}

@end
