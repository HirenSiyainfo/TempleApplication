//
//  SupplierCompany.h
//  RapidRMS
//
//  Created by Siya on 23/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, SupplierRepresentative;

@interface SupplierCompany : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * companyId;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * companyZone;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSString * phoneNo;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * supplierDatabase;
@property (nonatomic, retain) NSString * supplierZone;
@property (nonatomic, retain) NSNumber * venderId;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) NSSet *representatives;
@end

@interface SupplierCompany (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

- (void)addRepresentativesObject:(SupplierRepresentative *)value;
- (void)removeRepresentativesObject:(SupplierRepresentative *)value;
- (void)addRepresentatives:(NSSet *)values;
- (void)removeRepresentatives:(NSSet *)values;

@end
