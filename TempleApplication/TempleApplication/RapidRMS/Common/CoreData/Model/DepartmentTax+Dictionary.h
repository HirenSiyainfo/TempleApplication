//
//  DepartmentTax+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DepartmentTax.h"

@interface DepartmentTax (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *departmentTaxDictionary;
-(void)updatedepartmentTaxFromDictionary :(NSDictionary *)departmentTaxDictionary;
@end
