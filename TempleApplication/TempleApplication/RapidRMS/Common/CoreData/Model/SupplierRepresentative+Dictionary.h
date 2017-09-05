//
//  SupplierRepresentative+Dictionary.h
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "SupplierRepresentative.h"

@interface SupplierRepresentative (Dictionary)

-(void)updateSupplierRepresentativeDictionary :(NSDictionary *)csupplierDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getSupplierRepresentativeDictionary, readonly, copy) NSDictionary *supplierRepresentativeDictionary;
@end
