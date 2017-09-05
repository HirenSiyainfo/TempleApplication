//
//  DepartmentTax+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DepartmentTax+Dictionary.h"

@implementation DepartmentTax (Dictionary)
-(NSDictionary *)departmentTaxDictionary
{
    return nil;
}
-(void)updatedepartmentTaxFromDictionary :(NSDictionary *)departmentTaxDictionary
{
    self.amount =  @([[departmentTaxDictionary valueForKey:@"Amount"] integerValue]);;
    self.deptId =  @([[departmentTaxDictionary valueForKey:@"DeptId"] integerValue]);;
    self.taxId =  @([[departmentTaxDictionary valueForKey:@"TaxId"] integerValue]);;
}
@end
