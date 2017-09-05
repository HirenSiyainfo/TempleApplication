//
//  VPurchaseOrderItem+Dictionary.h
//  RapidRMS
//
//  Created by Siya on 09/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "VPurchaseOrderItem.h"

@interface VPurchaseOrderItem (Dictionary)


-(void)updateVendorPoItemDictionary :(NSDictionary *)poItemDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getVendorPoItemDictionary, readonly, copy) NSDictionary *vendorPoItemDictionary;
@end
