//
//  Department+CoreDataProperties.h
//  RapidRMS
//
//  Created by Siya9 on 26/09/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Department.h"

NS_ASSUME_NONNULL_BEGIN

@interface Department (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *applyAgeDesc;
@property (nullable, nonatomic, retain) NSNumber *chargeAmt;
@property (nullable, nonatomic, retain) NSString *chargeTyp;
@property (nullable, nonatomic, retain) NSNumber *checkCashAmt;
@property (nullable, nonatomic, retain) NSString *checkCashType;
@property (nullable, nonatomic, retain) NSNumber *chkCheckCash;
@property (nullable, nonatomic, retain) NSNumber *chkExtra;
@property (nullable, nonatomic, retain) NSNumber *deductChk;
@property (nullable, nonatomic, retain) NSString *deptCode;
@property (nullable, nonatomic, retain) NSNumber *deptId;
@property (nullable, nonatomic, retain) NSString *deptName;
@property (nullable, nonatomic, retain) NSNumber *deptTypeId;
@property (nullable, nonatomic, retain) NSString *imagePath;
@property (nullable, nonatomic, retain) NSNumber *is_asItem;
@property (nullable, nonatomic, retain) NSNumber *isAgeApply;
@property (nullable, nonatomic, retain) NSNumber *isNotApplyInItem;
@property (nullable, nonatomic, retain) NSNumber *isNotDisplay;
@property (nullable, nonatomic, retain) NSNumber *isNotDisplayInventory;
@property (nullable, nonatomic, retain) NSNumber *isPOS;
@property (nullable, nonatomic, retain) NSNumber *itemcode;
@property (nullable, nonatomic, retain) NSNumber *profitMargin;
@property (nullable, nonatomic, retain) NSNumber *salesPrice;
@property (nullable, nonatomic, retain) NSString *taxApplyIn;
@property (nullable, nonatomic, retain) NSNumber *taxFlg;
@property (nullable, nonatomic, retain) NSSet<Item *> *departmentItems;
@property (nullable, nonatomic, retain) KitchenPrinter *departmentPrinter;
@property (nullable, nonatomic, retain) NSSet<SubDepartment *> *departmentSubDepartments;

@end

@interface Department (CoreDataGeneratedAccessors)

- (void)addDepartmentItemsObject:(Item *)value;
- (void)removeDepartmentItemsObject:(Item *)value;
- (void)addDepartmentItems:(NSSet<Item *> *)values;
- (void)removeDepartmentItems:(NSSet<Item *> *)values;

- (void)addDepartmentSubDepartmentsObject:(SubDepartment *)value;
- (void)removeDepartmentSubDepartmentsObject:(SubDepartment *)value;
- (void)addDepartmentSubDepartments:(NSSet<SubDepartment *> *)values;
- (void)removeDepartmentSubDepartments:(NSSet<SubDepartment *> *)values;

@end

NS_ASSUME_NONNULL_END
