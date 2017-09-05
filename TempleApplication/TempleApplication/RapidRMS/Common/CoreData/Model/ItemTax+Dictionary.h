//
//  ItemTax+Dictionary.h
//  POSRetail
//
//  Created by Siya Infotech on 18/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "ItemTax.h"

@interface ItemTax (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemTaxDictionary;
-(void)updateitemTaxFromDictionary :(NSDictionary *)itemTaxDictionary;
-(void)updateitemTaxFromItemTable :(NSDictionary *)itemTaxDictionary :(NSString *)itemCode;

@end
