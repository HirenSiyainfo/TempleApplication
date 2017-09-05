//
//  ItemSupplier+Dictionary.m
//  POSRetail
//
//  Created by Siya Infotech on 13/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "ItemSupplier+Dictionary.h"

@implementation ItemSupplier (Dictionary)
-(NSDictionary *)itemSupplierDictionary
{
    return nil;
}
-(void)updateItemSupplierFromDictionary :(NSDictionary *)itemSupplierDictionary
{
    self.supId= @([[itemSupplierDictionary valueForKey:@"SUPId"] integerValue]);
    self.itemCode = @([[itemSupplierDictionary valueForKey:@"ITEMCODE"] integerValue]);
    self.vendorId = @([[itemSupplierDictionary valueForKey:@"VendorId"] integerValue]);
}

-(void)updateItemSupplierFromItemTable :(NSDictionary *)itemSupplierDictionary withItemCode:(NSString *)itemCode
{
    self.supId= @([[itemSupplierDictionary valueForKey:@"Id"] integerValue]);
    self.itemCode = @(itemCode.integerValue);
}

@end
