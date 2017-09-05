//
//  Item_Discount_MD2+Dictionary.h
//  POSRetail
//
//  Created by Siya Infotech on 13/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "Item_Discount_MD2.h"

@interface Item_Discount_MD2 (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemDiscount_MD2Dictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemDiscount_MD2DictionaryRim;
-(void)updateItemDiscount_Md2FromDictionary :(NSDictionary *)itemDiscount_MD2Dictionary;
@end
