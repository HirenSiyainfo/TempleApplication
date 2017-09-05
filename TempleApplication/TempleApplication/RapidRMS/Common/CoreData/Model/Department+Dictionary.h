//
//  Department+Dictionary.h
//  POSRetail
//
//  Created by Siya Infotech on 14/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "Department.h"

@interface Department (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *departmentDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *departmentLoadDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getdepartmentLoadDictionary, readonly, copy) NSDictionary *getdepartmentLoadDictionary;

-(void)updateDepartmentFromDictionary :(NSDictionary *)departmentDictionary;
@end
