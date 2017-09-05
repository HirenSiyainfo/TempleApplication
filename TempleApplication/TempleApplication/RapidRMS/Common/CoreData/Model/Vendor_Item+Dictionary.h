//
//  Vendor_Item+Dictionary.h
//  RapidRMS
//
//  Created by Siya on 14/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Vendor_Item.h"

@interface Vendor_Item (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *vendorItemDictionary;
-(void)updatevendorItemDictionary :(NSDictionary *)venderItemDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getVendorItemDictionary, readonly, copy) NSDictionary *getVendorItemDictionary;
@end
