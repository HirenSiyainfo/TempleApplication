//
//  Item_Discount_MD+Dictionary.m
//  POSRetail
//
//  Created by Siya Infotech on 13/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "Item_Discount_MD+Dictionary.h"

@implementation Item_Discount_MD (Dictionary)
-(NSDictionary *)itemDiscount_MD_Dictionary
{
    return nil;
}
-(void)updateItemDiscount_MdFromDictionary :(NSDictionary *)itemDiscount_MD_Dictionary
{
    self.iDisNo= @([[itemDiscount_MD_Dictionary valueForKey:@"IDisNo"] integerValue]);
    self.dis_Qty = @([[itemDiscount_MD_Dictionary valueForKey:@"DIS_Qty"] integerValue]);
    self.dis_UnitPrice=@([[itemDiscount_MD_Dictionary valueForKey:@"DIS_UnitPrice"] floatValue]);
    self.itemCode=@([[itemDiscount_MD_Dictionary valueForKey:@"ITEMCode"] integerValue]);
    self.isDiscounted=@([[itemDiscount_MD_Dictionary valueForKey:@"IsDiscounted"] integerValue]);
}
@end
