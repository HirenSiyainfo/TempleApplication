//
//  RCRBillSummary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 7/28/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RCRBillSummary.h"
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "RmsDbController.h"
@interface RCRBillSummary ()<NSCoding>
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end


@implementation RCRBillSummary


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.totalBillAmount forKey:@"totalBillAmount"];
    [aCoder encodeObject:self.totalSubTotalAmount forKey:@"totalSubTotalAmount"];
    [aCoder encodeObject:self.totalCheckCashAmount forKey:@"totalCheckCashAmount"];
    [aCoder encodeObject:self.totalExtraChargeAmount forKey:@"totalExtraChargeAmount"];
    [aCoder encodeObject:self.totalTaxAmount forKey:@"totalTaxAmount"];
    [aCoder encodeObject:self.totalDiscountAmount forKey:@"totalDiscountAmount"];
    [aCoder encodeObject:self.totalVariationAmount forKey:@"totalVariationAmount"];
    [aCoder encodeObject:self.totalVariationDiscount forKey:@"totalVariationDiscount"];
    [aCoder encodeObject:self.totalEBTAmount forKey:@"totalEBTAmount"];
    [aCoder encodeObject:self.totalHouseChargeAmount forKey:@"totalHouseChargeAmount"];
    
    [aCoder encodeBool:self.isEbtApplied forKey:@"isEbtApplied"];
    [aCoder encodeBool:self.isEbtAppliedForDisplay forKey:@"isEbtAppliedForDisplay"];

}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.totalBillAmount = [aDecoder decodeObjectForKey:@"totalBillAmount"];
        self.totalSubTotalAmount = [aDecoder decodeObjectForKey:@"totalSubTotalAmount"];
        self.totalCheckCashAmount = [aDecoder decodeObjectForKey:@"totalCheckCashAmount"];
        self.totalExtraChargeAmount = [aDecoder decodeObjectForKey:@"totalExtraChargeAmount"];
        self.totalTaxAmount = [aDecoder decodeObjectForKey:@"totalTaxAmount"];
        self.totalDiscountAmount = [aDecoder decodeObjectForKey:@"totalDiscountAmount"];
        self.totalVariationAmount = [aDecoder decodeObjectForKey:@"totalVariationAmount"];
        self.totalVariationDiscount = [aDecoder decodeObjectForKey:@"totalVariationDiscount"];
        self.totalEBTAmount = [aDecoder decodeObjectForKey:@"totalEBTAmount"];
        self.totalHouseChargeAmount = [aDecoder decodeObjectForKey:@"totalHouseChargeAmount"];

        self.isEbtApplied = [aDecoder decodeBoolForKey:@"isEbtApplied"];
        self.isEbtAppliedForDisplay = [aDecoder decodeBoolForKey:@"isEbtAppliedForDisplay"];
    }
    
    return self;
    
}

- (void) updateBillSummrayWithDetail:(NSMutableArray *)reciptArray
{
    float totalPrice = 0.0f;
    float taxValue = 0.0f;
    float totalDiscount = 0.0f;

   
   /// Update Variation Property for bill.....
    self.totalVariationAmount  = 0;
    self.totalVariationDiscount  = 0;

    if (reciptArray.count > 0)
    {
        for (int i=0; i<reciptArray.count; i++)
        {
            NSMutableDictionary *ringupEntry = reciptArray[i];
            NSMutableArray *reciptDataArray = [ringupEntry valueForKey:@"item"];
            BOOL  checkcash=[[reciptDataArray valueForKey:@"isCheckCash"] boolValue];
            BOOL  extracharge=[[reciptDataArray valueForKey:@"isExtraCharge"] boolValue];
            CGFloat itemTax = [ringupEntry[@"itemTax"] floatValue];
            if(checkcash)
            {
                totalPrice -= ([ringupEntry[@"itemPrice"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]);//-([[ringupEntry valueForKey:@"ItemDiscount"] floatValue]));
                
                
                totalPrice +=[[reciptDataArray valueForKey:@"CheckCashCharge"] floatValue];
                
                if ([ringupEntry[@"EBTApplicableForDisplay"] floatValue] == TRUE)
                {
                    itemTax = 0.0;
                }

                taxValue += itemTax;
                
                //                totalDiscount += [ringupEntry[@"ItemDiscountPercentage"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]*[[ringupEntry valueForKey:@"ItemBasicPrice"] floatValue]*0.01;
                
                totalDiscount += [ringupEntry[@"ItemDiscount"] floatValue];
                
              //  totalDiscount += [ringupEntry[@"ItemDiscountPercentage"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]*[[ringupEntry valueForKey:@"ItemBasicPrice"] floatValue]*0.01;
                // checkcash=1;
            }
            else if(extracharge)
            {
                
                NSArray * variation = ringupEntry[@"InvoiceVariationdetail"];
                float variationprice =0.0;
                for (NSDictionary *dictVariation in variation) {
                    variationprice += [dictVariation[@"VariationBasicPrice"] floatValue];
                }
                
                totalPrice += ([ringupEntry[@"itemPrice"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]);//-([[ringupEntry valueForKey:@"ItemDiscount"] floatValue]));
                
                
                totalPrice+=[[reciptDataArray valueForKey:@"ExtraCharge"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] intValue];
                
                if ([ringupEntry[@"EBTApplicableForDisplay"] floatValue] == TRUE)
                {
                    itemTax = 0.0;
                }
                taxValue += itemTax;
                totalPrice +=  variationprice * [[ringupEntry valueForKey:@"itemQty"] floatValue];
                totalDiscount += [ringupEntry[@"ItemDiscount"] floatValue];
            }
            else
            {
                //#define ADDRESS_FLOATING_POINT
#ifdef ADDRESS_FLOATING_POINT
                totalPrice += [ringupEntry[@"TotalPrice"] floatValue];
                taxValue += [ringupEntry[@"itemTax"] floatValue];
                totalDiscount += [ringupEntry[@"TotalDiscount"] floatValue];
#else
                
                NSNumber *itemVariationCost = [self itemVariationCost:ringupEntry];
                self.totalVariationAmount =  @(self.totalVariationAmount.floatValue + itemVariationCost.floatValue);
                
                NSNumber *itemvariationWithDiscount = [self itemVariationCostForDiscountedPrice:ringupEntry];
                self.totalVariationDiscount =  @(self.totalVariationDiscount.floatValue + itemvariationWithDiscount.floatValue);

                totalPrice += ([ringupEntry[@"itemPrice"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]) + itemvariationWithDiscount.floatValue;
               
                if ([ringupEntry[@"EBTApplicableForDisplay"] floatValue] == TRUE)
                {
                    itemTax = 0.0;
                }
                taxValue += itemTax;
                
//                float totalItemPrice = [[ringupEntry valueForKey:@"ItemBasicPrice"] floatValue] + itemVariationCost.floatValue;
//                totalDiscount += [ringupEntry[@"ItemDiscountPercentage"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]* totalItemPrice *0.01;
                totalDiscount += [ringupEntry[@"ItemDiscount"] floatValue];

#endif
            }
        }
    }
    [self updateSubtotal:totalPrice taxValue:taxValue totalDiscount:totalDiscount];
    self.totalCheckCashAmount = @([self totalCheckCashForBillOrderArray:reciptArray]);
    self.totalEBTAmount = @([self totalEBTForBillEntry:reciptArray]);
    self.totalHouseChargeAmount = @([self totalHouseChargeBillEntry:reciptArray]);
}

- (void)updateSubtotal:(float)totalPrice taxValue:(float)taxValue totalDiscount:(float)totalDiscount
{
    NSNumber *sTotal = @(totalPrice);
    self.totalSubTotalAmount = sTotal;
    
    NSString *stingToFloatTax=[NSString stringWithFormat:@"%.2f", taxValue];
    
    NSNumber *sTotalTax = @(stingToFloatTax.floatValue );
    self.totalTaxAmount = sTotalTax;
    
    NSString *stingToFloatDiscount=[NSString stringWithFormat:@"%.2f",totalDiscount];
    NSNumber *sTotalDiscount = @(stingToFloatDiscount.floatValue);
    self.totalDiscountAmount = sTotalDiscount;
    
    float total=totalPrice + taxValue;
    NSNumber *totalBill= @(total);
    self.totalBillAmount = totalBill;
}



- (NSNumber *)itemVariationCost:(NSMutableDictionary *)ringupEntry
{
    NSNumber *itemVariationCost = 0;
    if([ringupEntry valueForKey:@"InvoiceVariationdetail"])
    {
        itemVariationCost = [(NSArray *)ringupEntry[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.VariationBasicPrice"];
    }
    return itemVariationCost;
}

- (NSNumber *)itemVariationCostForDiscountedPrice:(NSMutableDictionary *)ringupEntry
{
    NSNumber *itemVariationCost = 0;
    if([ringupEntry valueForKey:@"InvoiceVariationdetail"])
    {
       CGFloat itemVariation = [[(NSArray *)ringupEntry[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.Price"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue];
        itemVariationCost = @(itemVariation);
    }
    return itemVariationCost;
}

-(CGFloat)totalCheckCashForBillOrderArray:(NSMutableArray *)receiptArray
{
    CGFloat totalCheckCashAmount = 0.00;
    for (int i = 0; i < receiptArray.count; i++)
    {
        NSDictionary *itemDictionary = [receiptArray[i] valueForKey:@"item"];
        
        BOOL isChargeCashvalue=[itemDictionary[@"isCheckCash"] boolValue];
        
        if (isChargeCashvalue == TRUE)
        {
            totalCheckCashAmount += [[receiptArray[i] valueForKey:@"itemPrice"] floatValue];
        }
    }
    return totalCheckCashAmount;
}
-(CGFloat)totalEBTForBillEntry:(NSMutableArray *)reciptArray
{
    CGFloat totalEBT = 0.00;
    
    for (NSDictionary *receiptDictionary in reciptArray) {
        
        BOOL isEBTApplicable = [receiptDictionary[@"EBTApplicable"] boolValue];
        if (isEBTApplicable) {
            BOOL isEBTApplied = [receiptDictionary[@"EBTApplied"] boolValue];
            if (isEBTApplicable == TRUE && isEBTApplied == TRUE) {
               
                NSNumber *itemVariationCost = 0;
                if([receiptDictionary valueForKey:@"InvoiceVariationdetail"])
                {
                    CGFloat itemVariation = [[(NSArray *)receiptDictionary[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.Price"] floatValue]*[[receiptDictionary valueForKey:@"itemQty"] floatValue];
                    itemVariationCost = @(itemVariation);
                }
                totalEBT += [[receiptDictionary valueForKey:@"itemPrice"] floatValue] * [[receiptDictionary valueForKey:@"itemQty"] floatValue] ;
                totalEBT +=  itemVariationCost.floatValue;


            }
        }

    }
    return totalEBT;
}

-(CGFloat)totalHouseChargeBillEntry:(NSMutableArray *)reciptArray
{
    CGFloat totalHouseCharge = 0.00;
    
    for (NSDictionary *receiptDictionary in reciptArray)
    {
        if ([receiptDictionary valueForKey:@"HouseChargeAmount"]) {
            NSNumber *houseCharge = [receiptDictionary valueForKey:@"HouseChargeAmount"];
            totalHouseCharge = self.totalSubTotalAmount.floatValue - houseCharge.floatValue ;
        }
    }
    return totalHouseCharge;
}



- (float)departmentTaxcalculation:(NSString *)salesPrice department:(Department *)department
{
    float checkCashPrice = 0.00;
    
    if (department.chkExtra.boolValue || department.chkCheckCash.boolValue)
    {
        if ([department.taxApplyIn isEqualToString:@"Fee"])
        {
           
            if(department.chkExtra.boolValue)
            {
                checkCashPrice = [self getDepartmentExtraChargeAmount:department withSalesPrice:salesPrice];            }
            else if (department.chkCheckCash.boolValue)
            {
                checkCashPrice = [self getDepartmentCheckCashAmount:department withSalesPrice:salesPrice];            }
            
            }
        else if ([department.taxApplyIn isEqualToString:@"Both"])
        {
            float departmentCheckExtraAmt = 0.00;
            
            if(department.chkExtra.boolValue)
            {
                departmentCheckExtraAmt = [self getDepartmentExtraChargeAmount:department withSalesPrice:salesPrice];

            }
            else if (department.chkCheckCash.boolValue)
            {
                departmentCheckExtraAmt = [self getDepartmentCheckCashAmount:department withSalesPrice:salesPrice];
            }
            
            checkCashPrice = salesPrice.floatValue + departmentCheckExtraAmt;
        }
        else
        {
            checkCashPrice = salesPrice.floatValue;
        }
    }
    else
        
    {
        checkCashPrice = salesPrice.floatValue;
        
    }
    return checkCashPrice;
}
- (CGFloat)getDepartmentExtraChargeAmount:(Department *)department withSalesPrice:(NSString *)salesPrice
{
    float extraChargeAmount = 0.00;
    NSString *sChargetype=department.chargeTyp;
    float fChargeAmt=department.chargeAmt.floatValue;
    
    if([sChargetype isEqualToString:@"Fix Charge"])
    {
        extraChargeAmount = fChargeAmt;
    }
    else if([sChargetype isEqualToString:@"Percentage(%)"])
    {
        NSString *sAmount = salesPrice;
        float fenterprice=sAmount.floatValue;
        extraChargeAmount = fenterprice * fChargeAmt * 0.01;
    }
    else
    {
        
    }
    return extraChargeAmount;
}

- (CGFloat)getDepartmentCheckCashAmount:(Department *)department withSalesPrice:(NSString *)salesPrice
{
    float checkCashPrice = 0.00;
    
    NSString *sCheckCashtype = department.checkCashType;
    float fCheckCashAmt = department.checkCashAmt.floatValue;
    
    if([sCheckCashtype isEqualToString:@"Fix Charge"])
    {
        checkCashPrice = fCheckCashAmt;
    }
    else if([sCheckCashtype isEqualToString:@"Percentage(%)"])
    {
        NSString *sAmount = salesPrice;
        
        float fenterprice=sAmount.floatValue;
        checkCashPrice = fenterprice * fCheckCashAmt * 0.01;
    }
    else
    {
        
    }
    return checkCashPrice;
}



-(void)taxCalculateForReciptDataArray:(NSMutableArray *)reciptArray withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    for (int i=0; i<reciptArray.count; i++)
    {
        NSMutableDictionary *itemRcptDisc = reciptArray[i];
        NSMutableArray *taxArray = [itemRcptDisc valueForKey:@"ItemTaxDetail"];
        if([taxArray isKindOfClass:[NSMutableArray class]])
        {
            BOOL isEBTApplicable = [itemRcptDisc[@"EBTApplicable"] boolValue];
            if (isEBTApplicable) {
                BOOL isEBTApplied = [itemRcptDisc[@"EBTApplied"] boolValue];
                if (isEBTApplicable == TRUE && isEBTApplied == TRUE) {
                    continue;
                }
            }
            
            float TaxAmount = 0;
            for (int i=0; i<taxArray.count; i++)
            {
                NSMutableDictionary *Dict = taxArray[i];
                float price = 0.00;
                
                if ([[itemRcptDisc valueForKey:@"itemType"] isEqualToString:@"Item"])
                {
                    Item *anItem = [self fetchItem:[itemRcptDisc valueForKey:@"itemId"] withMangedObjectContext:managedObjectContext];
                    
                    if([anItem.taxType isEqualToString:@"Tax wise"])
                    {
                        float variationAmount = [itemRcptDisc[@"TotalVarionCost"] floatValue] / [[itemRcptDisc valueForKey:@"itemQty"] floatValue] ;
                        
                        price = [itemRcptDisc[@"itemPrice"] floatValue] + variationAmount;
                    }
                    else if([anItem.taxType isEqualToString:@"Department wise"])
                    {
                        Department *department=[self fetchDepartment:[NSString stringWithFormat:@"%ld",(long)[itemRcptDisc[@"departId"]integerValue ]] withMangedObjectContext:managedObjectContext];
                        
                        float variationAmount = [itemRcptDisc[@"TotalVarionCost"] floatValue] / [[itemRcptDisc valueForKey:@"itemQty"] floatValue] ;
                        float itemPrice = [itemRcptDisc[@"itemPrice"] floatValue];
                        
                        NSString *totalPrice = [NSString stringWithFormat:@"%.2f", variationAmount + itemPrice];
                        
                        price = [self departmentTaxcalculation:totalPrice department:department];
                    }
                    else
                    {
                        float variationAmount = [itemRcptDisc[@"TotalVarionCost"] floatValue] / [[itemRcptDisc valueForKey:@"itemQty"] floatValue] ;
                        
                        price = [itemRcptDisc[@"itemPrice"] floatValue] + variationAmount;
                    }
                }
                else if ([[itemRcptDisc valueForKey:@"itemType"] isEqualToString:@"Department"])
                {
                    Department *department = [self fetchDepartment:[NSString stringWithFormat:@"%ld",(long)[itemRcptDisc[@"departId"]integerValue ]]withMangedObjectContext:managedObjectContext];
                    price = [self departmentTaxcalculation:[NSString stringWithFormat:@"%@", itemRcptDisc[@"itemPrice"]] department:department];
                }
                
                float despriceTaxAmount = (price * [Dict[@"TaxPercentage"] floatValue]*0.01);
                float itmDiscout=[[itemRcptDisc valueForKey:@"itemQty"] floatValue]*despriceTaxAmount;
                
                NSString *priceValuetax1 = [NSString stringWithFormat:@"%f",itmDiscout];
                TaxAmount+=itmDiscout;
                Dict[@"ItemTaxAmount"] = priceValuetax1;
                taxArray[i] = Dict;
            }
            itemRcptDisc[@"ItemTaxDetail"] = taxArray;
            itemRcptDisc[@"itemTax"] = @(TaxAmount);
        }
    }
}

- (Item*)fetchItem:(NSString *)itemId withMangedObjectContext:(NSManagedObjectContext *)mangedObjectContext
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:mangedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d AND active == %d", itemId.integerValue,TRUE];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:mangedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}


- (Department*)fetchDepartment:(NSString *)deptId withMangedObjectContext:(NSManagedObjectContext *)mangedObjectContext
{
    Department *department=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Department" inManagedObjectContext:mangedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d", deptId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:mangedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        department=resultSet.firstObject;
    }
    return department;
}


@end
