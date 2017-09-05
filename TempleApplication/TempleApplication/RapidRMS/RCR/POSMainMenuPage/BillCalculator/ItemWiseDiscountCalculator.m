//
//  ItemWiseDiscountCalculator.m
//  RapidRMS
//
//  Created by siya-IOS5 on 3/5/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ItemWiseDiscountCalculator.h"
#import "RmsDbController.h"
#import "Item+Dictionary.h"
@interface ItemWiseDiscountCalculator ()
{
    NSMutableArray *billDetail;
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;

@property (nonatomic, strong) UpdateManager *updateManager;

@end
@implementation ItemWiseDiscountCalculator
- (instancetype)initWithRecieptArray:(NSMutableArray *)receiptArray{
    self = [super init];
    
    if (self) {
        billDetail = [[NSMutableArray alloc] init];
        billDetail = receiptArray;
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        self.crmController = [RcrController sharedCrmController];

        self.managedObjectContext = self.rmsDbController.managedObjectContext;
        _updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:nil];
    }
    
    return self;
}


-(void)calCulateItemWiseDiscount
{
    for(int i=0;i<[billDetail count];i++)
    {
        NSMutableDictionary *_billReceiptDict = [billDetail objectAtIndex:i];
        
        if ([[_billReceiptDict objectForKey:@"IsRefundFromInvoice"] boolValue] == TRUE) {
            continue;
        }
        
        if (!([[[_billReceiptDict  valueForKey:@"item"]objectForKey:@"isCheckCash"] boolValue]==YES))
        {
            if ([_billReceiptDict objectForKey:@"ItemWiseDiscountType"])
            {
                Item *item = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%@",[_billReceiptDict  valueForKey:@"itemId"]] shouldCreate:NO moc:self.managedObjectContext];
                
                if ([item.pos_DISCOUNT integerValue] == 0)
                {
                    if ([[_billReceiptDict objectForKey:@"ItemWiseDiscountType"] isEqualToString:@"Percentage"])
                    {
                        [self itemPercentageWiseDiscountCalculation:_billReceiptDict];
                    }
                    else if ([[_billReceiptDict objectForKey:@"ItemWiseDiscountType"] isEqualToString:@"Amount"])
                    {
                        [self itemAmountWiseDiscountCalculation:_billReceiptDict];
                    }
                }
            }
            
        }
    }
    
}

-(void)itemPercentageWiseDiscountCalculation :(NSMutableDictionary *)percentageDiscountDict
{
    if ([percentageDiscountDict objectForKey:@"PriceAtPos"])
    {
        NSNumber *itemPrice = @([[percentageDiscountDict objectForKey:@"PriceAtPos"] floatValue] * ([percentageDiscountDict[@"itemQty"] integerValue] / [percentageDiscountDict[@"PackageQty"] integerValue]));
        
        CGFloat totalVariationForItem = [self calculateTotalForVariationDictionary:percentageDiscountDict];
        CGFloat totalVariationDiscountForItem = [self calculateItemWisePercentageDiscountForVariationDictionary:percentageDiscountDict] ;
        
        //   if ([itemPrice floatValue] > 0)
        {
            float desprice = ([itemPrice floatValue] * [[percentageDiscountDict valueForKey:@"ItemWiseDiscountValue"] floatValue] * 0.01);
            
            //            CGFloat totalDiscountForItem = desprice + totalVariationDiscountForItem;
            
            CGFloat totalPercentageDiscountForItem = desprice + totalVariationDiscountForItem;
            
            percentageDiscountDict[@"ItemExternalDiscount"] = @(totalPercentageDiscountForItem);
            percentageDiscountDict[@"itemPrice"] = @(([itemPrice floatValue] - desprice)/ [percentageDiscountDict[@"itemQty"] integerValue]);
            
            CGFloat totalDiscountForItem = [[percentageDiscountDict objectForKey:@"ItemDiscount"] floatValue] + totalPercentageDiscountForItem;
            
            
            NSNumber *discountId = @(0);
            if (percentageDiscountDict[@"SalesManualDiscountId"]) {
                discountId = percentageDiscountDict[@"SalesManualDiscountId"];
            }
          
            NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                        @"Percentage", @"DiscountType",
                                                                        @(totalPercentageDiscountForItem),@"Amount",
                                                                        @"Item",@"AppliedOn",
                                                                        discountId,@"DiscountId",nil];
            
            NSMutableArray *discountArray = [percentageDiscountDict valueForKey:@"Discount"];
            [discountArray addObject:itemwisePecentageDiscountDictionary];
            
           
            [percentageDiscountDict setValue:[NSString stringWithFormat:@"%f",totalDiscountForItem] forKey:@"ItemDiscount"];
            
            CGFloat totalDiscountedVariationForItem = totalVariationForItem - totalVariationDiscountForItem;
            percentageDiscountDict[@"TotalVarionCost"] = @(totalDiscountedVariationForItem * [[percentageDiscountDict valueForKey:@"itemQty"] floatValue]) ;
            
        }
    }
    else
    {
        NSNumber *itemPrice = @([percentageDiscountDict[@"itemPrice"] floatValue] * ([percentageDiscountDict[@"itemQty"] floatValue]));
        
         //  if ([itemPrice floatValue] > 0)
        {
            CGFloat totalVariationForItem = [self calculateTotalForVariationDictionary:percentageDiscountDict];
            
            CGFloat totalVariationDiscountForItem = [self calculateItemWisePercentageDiscountForVariationDictionary:percentageDiscountDict] ;
            
            float desprice = ([itemPrice floatValue] * [[percentageDiscountDict valueForKey:@"ItemWiseDiscountValue"] floatValue] * 0.01);
            
            if (itemPrice < 0)
            {
                desprice = -desprice;
            }
            
            percentageDiscountDict[@"itemPrice"] = @(([itemPrice floatValue] - desprice)/ [percentageDiscountDict[@"itemQty"] integerValue]);
            
            
            CGFloat totalApplicableDiscount = desprice + totalVariationDiscountForItem;
            
            percentageDiscountDict[@"ItemExternalDiscount"] = @(totalApplicableDiscount);
            
            
            NSNumber *discountId = @(0);
            
            if (percentageDiscountDict[@"SalesManualDiscountId"]) {
                discountId = percentageDiscountDict[@"SalesManualDiscountId"];
            }
            
            NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                        @"Percentage", @"DiscountType",
                                                                        @(totalApplicableDiscount)
                                                                        ,@"Amount",
                                                                        @"Item",@"AppliedOn",
                                                                        discountId,@"DiscountId",nil];
            
            NSMutableArray *discountArray = [percentageDiscountDict valueForKey:@"Discount"];
            [discountArray addObject:itemwisePecentageDiscountDictionary];
            
            
           float totalDiscountForItem = [[percentageDiscountDict objectForKey:@"ItemDiscount"] floatValue] + totalApplicableDiscount;
            
            [percentageDiscountDict setValue:[NSString stringWithFormat:@"%f",totalDiscountForItem] forKey:@"ItemDiscount"];
            
            CGFloat totalDiscountedVariationForItem = totalVariationForItem - totalVariationDiscountForItem;
            percentageDiscountDict[@"TotalVarionCost"] = @(totalDiscountedVariationForItem * ([percentageDiscountDict[@"itemQty"] integerValue] / [percentageDiscountDict[@"PackageQty"] integerValue])) ;
        }
    }
}

-(void)itemAmountWiseDiscountCalculation :(NSMutableDictionary *)amountDiscountDict
{
    if ([amountDiscountDict objectForKey:@"PriceAtPos"])
    {
        NSNumber *itemPrice = @([[amountDiscountDict objectForKey:@"PriceAtPos"] floatValue]);
        //  if ([itemPrice floatValue] > 0)
        {
            NSString *discountValue=[[amountDiscountDict objectForKey:@"ItemWiseDiscountValue"] stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
            
            float mainPrice = [itemPrice floatValue];
            float discPrice = [[NSString stringWithFormat:@"%f",[self.crmController.currencyFormatter numberFromString:discountValue].floatValue] floatValue];
            float discountToCompare = discPrice * ([amountDiscountDict[@"itemQty"] integerValue] / [amountDiscountDict[@"PackageQty"] integerValue]);
                if (mainPrice < 0)
                {
                    discPrice = -discPrice;
                }
                
                float itemPrice = mainPrice - discPrice ;
                amountDiscountDict[@"ItemExternalDiscount"] = @(discountToCompare);

                NSNumber *discountId = @(0);
                
                if (amountDiscountDict[@"SalesManualDiscountId"]) {
                    discountId = amountDiscountDict[@"SalesManualDiscountId"];
                }
                
                if (discountToCompare != 0.00) {
                    NSMutableDictionary *amountPecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                              @"Amount", @"DiscountType",
                                                                        @(discountToCompare),@"Amount",
                                                                              @"Item",@"AppliedOn",
                                                                              discountId,@"DiscountId",nil];
                    
                    NSMutableArray *discountArray = [amountDiscountDict valueForKey:@"Discount"];
                    [discountArray addObject:amountPecentageDiscountDictionary];
                }
                
                amountDiscountDict[@"itemPrice"] = @(itemPrice / [amountDiscountDict[@"PackageQty"] integerValue]);
                
                CGFloat totalItemDiscount = [[amountDiscountDict objectForKey:@"ItemDiscount"] floatValue] + discountToCompare;
                
                [amountDiscountDict setObject:[NSString stringWithFormat:@"%f",totalItemDiscount] forKey:@"ItemDiscount"];
        }
    }
    else
    {
        NSNumber *itemPrice = @([amountDiscountDict[@"itemPrice"] floatValue] * [amountDiscountDict[@"itemQty"] integerValue]) ;
        //   if ([itemPrice floatValue] > 0)
        {
            NSString *discountValue = [[amountDiscountDict objectForKey:@"ItemWiseDiscountValue"] stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
            
            float mainPrice = [itemPrice floatValue];
            float discPrice = [[NSString stringWithFormat:@"%f",[self.crmController.currencyFormatter numberFromString:discountValue].floatValue] floatValue] * ([amountDiscountDict[@"itemQty"] integerValue] / [amountDiscountDict[@"PackageQty"] integerValue]);

                if (mainPrice < 0)
                {
                    discPrice = -discPrice;
                }
            
                NSNumber *discountId = @(0);
                if (amountDiscountDict[@"SalesManualDiscountId"]) {
                    discountId = amountDiscountDict[@"SalesManualDiscountId"];
                }
            if (discPrice != 0.00) {

                NSMutableDictionary *amountPecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                          @"Amount", @"DiscountType",
                                                                          @(discPrice)
                                                                          ,@"Amount",
                                                                          @"Item",@"AppliedOn",
                                                                          discountId,@"DiscountId",nil];
                
                NSMutableArray *discountArray = [amountDiscountDict valueForKey:@"Discount"];
                [discountArray addObject:amountPecentageDiscountDictionary];
            }
                float itemPrice = mainPrice - discPrice ;
                amountDiscountDict[@"itemPrice"] = @(itemPrice / [amountDiscountDict[@"itemQty"] integerValue]);
                
                float totalItemDiscount = [[amountDiscountDict objectForKey:@"ItemDiscount"] floatValue] + discPrice;
                
                amountDiscountDict[@"ItemExternalDiscount"] = @(discPrice);
                [amountDiscountDict setObject:[NSString stringWithFormat:@"%f",totalItemDiscount] forKey:@"ItemDiscount"];
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
-(CGFloat )calculateItemWisePercentageDiscountForVariationDictionary :(NSDictionary *)dictionary
{
    CGFloat totalVarionDiscount = 0.0;
    
    if ([dictionary objectForKey:@"InvoiceVariationdetail"])
    {
        NSMutableArray *variationDetailForItem = [dictionary objectForKey:@"InvoiceVariationdetail"];
        for (NSMutableDictionary *variationDictionary in variationDetailForItem)
        {
            CGFloat variationPrice = [variationDictionary[@"VariationBasicPrice"] floatValue];
            
            float despriceForVariation = (variationPrice * [[dictionary valueForKey:@"ItemWiseDiscountValue"] floatValue] * 0.01);
            
            totalVarionDiscount += despriceForVariation;
            
            variationPrice = variationPrice - despriceForVariation;
            
            [variationDictionary setValue:[NSString stringWithFormat:@"%f",variationPrice] forKey:@"Price"];
        }
    }
    return totalVarionDiscount;
}


@end
