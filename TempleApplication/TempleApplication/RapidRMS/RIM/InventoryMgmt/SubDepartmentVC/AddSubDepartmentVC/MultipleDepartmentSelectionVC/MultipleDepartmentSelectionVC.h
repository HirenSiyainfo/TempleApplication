//
//  MultipleDepartmentSelectionVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DepartmentPopover.h"
#import "AddSubDepartmentVC.h"

@interface MultipleDepartmentSelectionVC : DepartmentPopover
@property (nonatomic, strong) AddSubDepartmentVC *objAddSubDepartment;
@property (nonatomic, strong) NSMutableArray *arrDeptSelected;



@end
