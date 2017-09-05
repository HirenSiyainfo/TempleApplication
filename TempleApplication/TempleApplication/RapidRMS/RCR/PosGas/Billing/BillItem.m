//
//  BillItem.m
//  RapidRMS
//
//  Created by Siya Infotech on 02/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "BillItem.h"
#import "Item+Discount.h"
#import "BillAmountComponents.h"

@interface BillItem ()

@property (nonatomic, strong) Item *anItem;

@end

@implementation BillItem

- (instancetype)initWithItem:(Item *)ringupItem
{
    self = [super init];
    
    if (self) {
        self.anItem = ringupItem;
        self.itemQuantity = 1;
    }
    return self;
}

-(NSString *)name
{
    return self.anItem.item_Desc;
}

-(NSString *)barcode
{
    return self.anItem.barcode;
}

-(NSString *)imagePath
{
    return self.anItem.item_ImagePath;
}

-(float)salesPrice
{
    return self.anItem.salesPrice.floatValue;
}

-(BillAmountComponents *)billAmountComponents
{
    BillAmountComponents *billAmountComponent = [[BillAmountComponents alloc] init];
    
    billAmountComponent.totalTax = [self.anItem totalTaxForQuantity:self.itemQuantity];
    billAmountComponent.totalDiscount = [self.anItem totalDiscountForQuantity:self.itemQuantity];
    billAmountComponent.subTotal = [self.anItem discountedTotalPriceForQuantity:self.itemQuantity];
    billAmountComponent.billAmount = billAmountComponent.totalTax + billAmountComponent.subTotal;
    
    return billAmountComponent;
}

@end
