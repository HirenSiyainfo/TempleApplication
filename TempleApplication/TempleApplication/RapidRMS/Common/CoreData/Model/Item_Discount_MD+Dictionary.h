//
//  Item_Discount_MD+Dictionary.h
//  POSRetail
//
//  Created by Siya Infotech on 13/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "Item_Discount_MD.h"

@interface Item_Discount_MD (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemDiscount_MD_Dictionary;
-(void)updateItemDiscount_MdFromDictionary :(NSDictionary *)itemDiscount_MD_Dictionary;
@end
