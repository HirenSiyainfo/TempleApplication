//
//  AddSubDepartmentModel.m
//  RapidRMS
//
//  Created by Siya9 on 21/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "AddSubDepartmentModel.h"

@implementation AddSubDepartmentModel

-(void)updateViewWithsubDepartmentDetail:(NSMutableDictionary *)subDepartmentDictionary
{
    if(subDepartmentDictionary != nil)
    {
        self.strSubDeptName = [subDepartmentDictionary valueForKey:@"SubDeptName"];
        self.strSubDeptCode = [subDepartmentDictionary valueForKey:@"SubDepCode"];
        self.strSubRemarks = [subDepartmentDictionary valueForKey:@"Remarks"];
        self.isNotDisplayInventory = [[subDepartmentDictionary valueForKey:@"IsNotDisplayInventory"] boolValue];
        self.strDepartmentID = [subDepartmentDictionary valueForKey:@"DeptId"];
    }
    else {
        self.strSubDeptName = @"";
        self.strSubDeptCode = @"";
        self.strSubRemarks = @"";
        self.isNotDisplayInventory = false;
    }
}

@end
