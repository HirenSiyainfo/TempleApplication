//
//  SubDepartment+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "SubDepartment+Dictionary.h"

@implementation SubDepartment (Dictionary)

-(NSDictionary *)subDepartmentDictionary
{
    return nil;
}

-(void)updateSubDepartmentDictionary :(NSDictionary *)subDepartmentDictionary
{
    self.brnSubDeptID =  @([[subDepartmentDictionary valueForKey:@"BrnSubDeptID"] integerValue]);
    self.branchId =  @([[subDepartmentDictionary valueForKey:@"BranchId"] integerValue]);
    self.deptId = @([[subDepartmentDictionary valueForKey:@"DeptId"] integerValue]);
    self.subDeptName = [subDepartmentDictionary valueForKey:@"SubDeptName"];
    self.remarks = [subDepartmentDictionary valueForKey:@"Remarks"];
    self.subDeptImagePath = [subDepartmentDictionary valueForKey:@"SubDeptImagePath"];
    //self.createdDate = [subDepartmentDictionary valueForKey:@"CreatedDate"];
    self.createdBy = @([[subDepartmentDictionary valueForKey:@"CreatedBy"] integerValue]);
    self.isDelete = @([[subDepartmentDictionary valueForKey:@"IsDeleted"] integerValue]);
    self.subDepCode = [subDepartmentDictionary valueForKey:@"SubDepCode"];
    self.itemCode = @([[subDepartmentDictionary valueForKey:@"ItemCode"] integerValue]);
    self.isNotDisplayInventory = @([[subDepartmentDictionary valueForKey:@"IsNotDisplayInventory"] integerValue]);
}

-(NSDictionary *)getSubDepartmentDictionary
{
    NSMutableDictionary *subDepartmentDictionary=[[NSMutableDictionary alloc]init];
    subDepartmentDictionary[@"BrnSubDeptID"] = self.brnSubDeptID;
    subDepartmentDictionary[@"BranchId"] = self.branchId;
    subDepartmentDictionary[@"DeptId"] = self.deptId;
    subDepartmentDictionary[@"SubDeptName"] = self.subDeptName;
    subDepartmentDictionary[@"Remarks"] = self.remarks;
    //[subDepartmentDictionary setObject:self.createdDate forKey:@"CreatedDate"];
    if (self.subDeptImagePath == nil){
        subDepartmentDictionary[@"SubDeptImagePath"] = @"";
    } else {
        subDepartmentDictionary[@"SubDeptImagePath"] = self.subDeptImagePath;
    }
    subDepartmentDictionary[@"CreatedBy"] = self.createdBy;
    subDepartmentDictionary[@"IsDeleted"] = self.isDelete;
    subDepartmentDictionary[@"SubDepCode"] = self.subDepCode;
    subDepartmentDictionary[@"itemCode"] = self.itemCode;
    subDepartmentDictionary[@"IsNotDisplayInventory"] = self.isNotDisplayInventory;
    return  subDepartmentDictionary;
}

@end