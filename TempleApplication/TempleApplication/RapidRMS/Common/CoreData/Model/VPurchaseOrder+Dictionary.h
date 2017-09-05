//
//  VPurchaseOrder+Dictionary.h
//  RapidRMS
//
//  Created by Siya on 09/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "VPurchaseOrder.h"

@interface VPurchaseOrder (Dictionary)

-(void)updateVendorPoDictionary :(NSDictionary *)poDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getVendorPoDictionary, readonly, copy) NSDictionary *vendorPoDictionary;
@end
