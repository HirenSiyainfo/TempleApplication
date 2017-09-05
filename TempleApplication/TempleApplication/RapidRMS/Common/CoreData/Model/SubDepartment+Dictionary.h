//
//  SubDepartment+Dictionary.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "SubDepartment.h"

@interface SubDepartment (Dictionary)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *subDepartmentDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getSubDepartmentDictionary, readonly, copy) NSDictionary *getSubDepartmentDictionary;
-(void)updateSubDepartmentDictionary :(NSDictionary *)subDepartmentDictionary;

@end
