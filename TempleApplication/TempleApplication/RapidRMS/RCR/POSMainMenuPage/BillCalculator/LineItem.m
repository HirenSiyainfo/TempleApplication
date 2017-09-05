//
//  LineItem.m
//  RapidRMS
//
//  Created by siya-IOS5 on 2/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "LineItem.h"
#import "SubTotal.h"
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"


typedef NS_ENUM(NSInteger, TaxType) {
    TaxOnOrignalPrice = 1,
    TaxOnDiscountedPrice = 2,
};


@implementation LineItem


- (instancetype)initWithLineItem:(Item *)item withBillDetail:(NSDictionary *)receiptDictionary withLineItemIndex:(NSNumber *)lineItemIndex
{
    self = [super init];
    
    if (self) {
        self.discountArray = [[NSMutableArray alloc]init];
        self.anItem = item;
        self.itemBasicPrice = @([[receiptDictionary valueForKey:@"ItemBasicPrice"] floatValue]);
        self.itemQty = @([[receiptDictionary valueForKey:@"itemQty"] integerValue]);
        self.packageQty = @([[receiptDictionary valueForKey:@"PackageQty"] integerValue]);
        self.totalPackageQty = @([[receiptDictionary valueForKey:@"itemQty"] integerValue] / [[receiptDictionary valueForKey:@"PackageQty"] integerValue]) ;
        self.packageType = [receiptDictionary valueForKey:@"PackageType"];
        self.itemCode = @([[receiptDictionary valueForKey:@"itemId"] integerValue]);
        self.isQtyEdited = [[receiptDictionary valueForKey:@"IsQtyEdited"] boolValue];
        self.receiptDictionary = receiptDictionary;
        self.lineItemIndex = lineItemIndex;
        self.barcode = [receiptDictionary valueForKey:@"Barcode"];
        SubTotal *subTotal = [[SubTotal alloc] init];
        if ([[receiptDictionary valueForKey:@"ItemTaxDetail"] isKindOfClass:[NSMutableArray class]]) {
            subTotal.lineItemTaxArray = [receiptDictionary valueForKey:@"ItemTaxDetail"];
        }
        self.subTotal = subTotal;
        self.isRefundFromInvoice = [[receiptDictionary valueForKey:@"IsRefundFromInvoice"] boolValue];
        
        
        self.isRefundItem = @(FALSE);

        if (self.itemBasicPrice.floatValue < 0 ){
            self.isRefundItem = @(TRUE);
        }
        
        
        for (Item_Price_MD *price_md in [self.anItem.itemToPriceMd allObjects]) {
            
            
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

            
            
            if ([price_md.priceqtytype isEqualToString:@"Case"])
            {
                self.caseQty = price_md.qty;
                self.casePrice = @(self.itemBasicPrice.floatValue * self.caseQty.floatValue) ;
            }
            else  if ([price_md.priceqtytype isEqualToString:@"Single item"] || [price_md.priceqtytype isEqualToString:@"Single Item"])
            {
                self.singleQty = price_md.qty;
                self.singlePrice = @(self.itemBasicPrice.floatValue * self.singleQty.floatValue);

            }
            else if ([price_md.priceqtytype isEqualToString:@"Pack"] )
            {
                self.packQty = price_md.qty;
                self.packPrice = @(self.itemBasicPrice.floatValue * self.packQty.floatValue);
            }
        }
        
    }
    return self;
}
-(LineItem *)mutableCopyOfLineItem
{
    LineItem *mutableLineItem = [[LineItem alloc] init];

    mutableLineItem.discountArray = [[NSMutableArray alloc]init];
    mutableLineItem.anItem = self.anItem;
    mutableLineItem.itemBasicPrice = @([[self.receiptDictionary valueForKey:@"ItemBasicPrice"] floatValue]);
    mutableLineItem.itemQty = @([[self.receiptDictionary valueForKey:@"itemQty"] integerValue]);
    mutableLineItem.packageQty = @([[self.receiptDictionary valueForKey:@"PackageQty"] integerValue]);
    mutableLineItem.packageType = [self.receiptDictionary valueForKey:@"PackageType"];
    mutableLineItem.itemCode = @([[self.receiptDictionary valueForKey:@"itemId"] integerValue]);
    mutableLineItem.receiptDictionary = self.receiptDictionary;
    mutableLineItem.lineItemIndex = self.lineItemIndex;
    mutableLineItem.isRefundFromInvoice = self.isRefundFromInvoice;
    SubTotal *subTotal = [[SubTotal alloc] init];
    subTotal.lineItemTaxArray = self.subTotal.lineItemTaxArray;
    mutableLineItem.subTotal = subTotal;
    
    mutableLineItem.isRefundItem = @(FALSE);

    if (self.itemBasicPrice.floatValue < 0 ){
        mutableLineItem.isRefundItem = @(TRUE);
    }
    
    
    for (Item_Price_MD *price_md in [self.anItem.itemToPriceMd allObjects]) {
        
        
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
        
        
        
        if ([price_md.priceqtytype isEqualToString:@"Case"])
        {
            mutableLineItem.caseQty = price_md.qty;
            mutableLineItem.casePrice = @(self.itemBasicPrice.floatValue * self.caseQty.floatValue) ;
        }
        else  if ([price_md.priceqtytype isEqualToString:@"Single item"] || [price_md.priceqtytype isEqualToString:@"Single Item"])
        {
            mutableLineItem.singleQty = price_md.qty;
            mutableLineItem.singlePrice = @(self.itemBasicPrice.floatValue * self.singleQty.floatValue);
            
        }
        else if ([price_md.priceqtytype isEqualToString:@"Pack"] )
        {
            mutableLineItem.packQty = price_md.qty;
            mutableLineItem.packPrice = @(self.itemBasicPrice.floatValue * self.packQty.floatValue);
        }
    }
    

    return mutableLineItem;

}

@end
