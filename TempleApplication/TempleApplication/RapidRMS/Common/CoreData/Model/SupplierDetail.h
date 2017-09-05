//
//  SupplierDetail.h
//  POSRetail
//
//  Created by Siya Infotech on 12/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface SupplierDetail : NSManagedObject

@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSDecimalNumber * contactNo;
@property (nonatomic, retain) NSNumber * supplierId;
@property (nonatomic, retain) NSString * supplierName;
@property (nonatomic, retain) NSSet *supplierDetailItems;
@end

@interface SupplierDetail (CoreDataGeneratedAccessors)

- (void)addSupplierDetailItemsObject:(Item *)value;
- (void)removeSupplierDetailItemsObject:(Item *)value;
- (void)addSupplierDetailItems:(NSSet *)values;
- (void)removeSupplierDetailItems:(NSSet *)values;

@end
