//
//  ItemSupplier+Dictionary.h
//  POSRetail
//
//  Created by Siya Infotech on 13/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "ItemSupplier.h"

@interface ItemSupplier (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemSupplierDictionary;
-(void)updateItemSupplierFromDictionary :(NSDictionary *)itemSupplierDictionary;
-(void)updateItemSupplierFromItemTable :(NSDictionary *)itemSupplierDictionary withItemCode:(NSString *)itemCode;

@end
