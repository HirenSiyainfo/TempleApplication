//
//  SubDepartment.h
//  RapidRMS
//
//  Created by Siya-mac5 on 26/10/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Department, Item;

@interface SubDepartment : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * brnSubDeptID;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * deptId;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * itemCode;
@property (nonatomic, retain) NSString * remarks;
@property (nonatomic, retain) NSString * subDepCode;
@property (nonatomic, retain) NSString * subDeptImagePath;
@property (nonatomic, retain) NSString * subDeptName;
@property (nonatomic, retain) NSNumber * isNotDisplayInventory;
@property (nonatomic, retain) NSSet *subDepartmentDepartments;
@property (nonatomic, retain) NSSet *subDepartmentItems;
@end

@interface SubDepartment (CoreDataGeneratedAccessors)

- (void)addSubDepartmentDepartmentsObject:(Department *)value;
- (void)removeSubDepartmentDepartmentsObject:(Department *)value;
- (void)addSubDepartmentDepartments:(NSSet *)values;
- (void)removeSubDepartmentDepartments:(NSSet *)values;

- (void)addSubDepartmentItemsObject:(Item *)value;
- (void)removeSubDepartmentItemsObject:(Item *)value;
- (void)addSubDepartmentItems:(NSSet *)values;
- (void)removeSubDepartmentItems:(NSSet *)values;

@end
