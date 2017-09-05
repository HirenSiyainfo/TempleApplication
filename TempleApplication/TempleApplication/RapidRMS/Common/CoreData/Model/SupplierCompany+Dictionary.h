//
//  SupplierCompany+Dictionary.h
//  RapidRMS
//
//  Created by Siya Infotech on 29/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "SupplierCompany.h"

@interface SupplierCompany (Dictionary)

-(void)updateSupplierCompanyDictionary :(NSDictionary *)csupplierDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getSupplierCompanyDictionary, readonly, copy) NSDictionary *supplierCompanyDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getSupplierCompanyDetailsDictionary, readonly, copy) NSDictionary *supplierCompanyDetailsDictionary;
@end
