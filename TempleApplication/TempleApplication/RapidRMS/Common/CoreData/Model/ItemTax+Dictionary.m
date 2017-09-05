//
//  ItemTax+Dictionary.m
//  POSRetail
//
//  Created by Siya Infotech on 18/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "ItemTax+Dictionary.h"

@implementation ItemTax (Dictionary)
-(NSDictionary *)itemTaxDictionary
{
    return nil;
}
-(void)updateitemTaxFromDictionary :(NSDictionary *)itemTaxDictionary
{
    self.amount =  @([[itemTaxDictionary valueForKey:@"Amount"] integerValue]);;
    self.itemId =  @([[itemTaxDictionary valueForKey:@"ITEMCode"] integerValue]);;
    self.taxId =  @([[itemTaxDictionary valueForKey:@"TAXId"] integerValue]);;
}
-(void)updateitemTaxFromItemTable :(NSDictionary *)itemTaxDictionary :(NSString *)itemCode
{
    self.amount =  @([[itemTaxDictionary valueForKey:@"Amount"] integerValue]);;
    self.itemId =  @(itemCode.integerValue);;
    self.taxId =  @([[itemTaxDictionary valueForKey:@"TaxId"] integerValue]);;
}

@end
