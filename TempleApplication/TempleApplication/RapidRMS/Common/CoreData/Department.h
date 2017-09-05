//
//  Department.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/7/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Department : NSManagedObject

@property (nonatomic, retain) NSString * applyAgeDesc;
@property (nonatomic, retain) NSNumber * chargeAmt;
@property (nonatomic, retain) NSString * chargeTyp;
@property (nonatomic, retain) NSNumber * checkCashAmt;
@property (nonatomic, retain) NSString * checkCashType;
@property (nonatomic, retain) NSString * deptName;
@property (nonatomic, retain) NSNumber * deptId;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSNumber * is_asItem;
@property (nonatomic, retain) NSNumber * isAgeApply;
@property (nonatomic, retain) NSNumber * chkCheckCash;
@property (nonatomic, retain) NSNumber * deductChk;
@property (nonatomic, retain) NSNumber * chkExtra;
@property (nonatomic, retain) NSNumber * taxFlg;
@property (nonatomic, retain) NSNumber * itemcode;
@property (nonatomic, retain) NSNumber * salesPrice;
@property (nonatomic, retain) NSSet *departmentItems;
@end

@interface Department (CoreDataGeneratedAccessors)

- (void)addDepartmentItemsObject:(Item *)value;
- (void)removeDepartmentItemsObject:(Item *)value;
- (void)addDepartmentItems:(NSSet *)values;
- (void)removeDepartmentItems:(NSSet *)values;

@end
