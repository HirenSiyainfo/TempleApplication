//
//  Item_Price_MD+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Item_Price_MD+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"

@implementation Item_Price_MD (Dictionary)
-(NSDictionary *)item_Price_Md_Dictionary
{
    return nil;
}
-(void)updateItem_Price_Md_Dictionary :(NSDictionary *)item_Price_Md_Dictionary
{
    self.itemcode = @([[item_Price_Md_Dictionary valueForKey:@"ItemCode"] integerValue]);
    self.priceqtytype = [item_Price_Md_Dictionary valueForKey:@"PriceQtyType"];
    self.qty = @([[item_Price_Md_Dictionary valueForKey:@"Qty"] floatValue]);
    self.cost = @([[item_Price_Md_Dictionary valueForKey:@"Cost"] floatValue]);
    self.profit = @([[item_Price_Md_Dictionary valueForKey:@"Profit"] floatValue]);
    self.unitPrice = @([[item_Price_Md_Dictionary valueForKey:@"UnitPrice"] floatValue]);
    self.priceA = @([[item_Price_Md_Dictionary valueForKey:@"PriceA"] floatValue]);
    self.priceB = @([[item_Price_Md_Dictionary valueForKey:@"PriceB"] floatValue]);
    self.priceC = @([[item_Price_Md_Dictionary valueForKey:@"PriceC"] floatValue]);
    self.applyPrice = [item_Price_Md_Dictionary valueForKey:@"ApplyPrice"];
    self.isPackCaseAllow = @([[item_Price_Md_Dictionary valueForKey:@"IsPackCaseAllow"] integerValue]);
    self.unitQty = @([[item_Price_Md_Dictionary valueForKey:@"UnitQty"] integerValue]);
    self.unitType = [item_Price_Md_Dictionary valueForKey:@"UnitType"];
}

-(void)linkToBarcodePrice :(NSArray *)itemBarcode_Mds
{
   /* NSSet *priceBarcodes = self.priceBarcodes;
    [self removePriceBarcodes:priceBarcodes];*/
    
    
    [self addPriceBarcodes:[NSSet setWithArray:itemBarcode_Mds]];
    for (ItemBarCode_Md *itemBarcode_md in itemBarcode_Mds)
    {
        
        itemBarcode_md.barcodePrice_MD = self;
//        if ([itemBarcode_md.barCode isEqualToString:@"822720"] )
//        {
//        }
    }
}

@end
