//
//  Discount_M+CoreDataProperties.h
//  RapidRMS
//
//  Created by Siya9 on 26/09/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Discount_M.h"

NS_ASSUME_NONNULL_BEGIN

@interface Discount_M (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSString *descriptionText;
@property (nullable, nonatomic, retain) NSNumber *discountId;
@property (nullable, nonatomic, retain) NSNumber *discountType;
@property (nullable, nonatomic, retain) NSDate *endDate;
@property (nullable, nonatomic, retain) NSDate *endTime;
@property (nullable, nonatomic, retain) NSNumber *free;
@property (nullable, nonatomic, retain) NSNumber *freeType;
@property (nullable, nonatomic, retain) NSNumber *isCase;
@property (nullable, nonatomic, retain) NSNumber *isDelete;
@property (nullable, nonatomic, retain) NSNumber *isPack;
@property (nullable, nonatomic, retain) NSNumber *isStatus;
@property (nullable, nonatomic, retain) NSNumber *isUnit;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *primaryItemQty;
@property (nullable, nonatomic, retain) NSNumber *qtyLimit;
@property (nullable, nonatomic, retain) NSNumber *quantityType;
@property (nullable, nonatomic, retain) NSNumber *secondaryItemQty;
@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSDate *startTime;
@property (nullable, nonatomic, retain) NSNumber *taxType;
@property (nullable, nonatomic, retain) NSNumber *validDays;
@property (nullable, nonatomic, retain) NSSet<Discount_Primary_MD *> *primaryItems;
@property (nullable, nonatomic, retain) NSSet<Discount_Secondary_MD *> *secondaryItems;

@end

@interface Discount_M (CoreDataGeneratedAccessors)

- (void)addPrimaryItemsObject:(Discount_Primary_MD *)value;
- (void)removePrimaryItemsObject:(Discount_Primary_MD *)value;
- (void)addPrimaryItems:(NSSet<Discount_Primary_MD *> *)values;
- (void)removePrimaryItems:(NSSet<Discount_Primary_MD *> *)values;

- (void)addSecondaryItemsObject:(Discount_Secondary_MD *)value;
- (void)removeSecondaryItemsObject:(Discount_Secondary_MD *)value;
- (void)addSecondaryItems:(NSSet<Discount_Secondary_MD *> *)values;
- (void)removeSecondaryItems:(NSSet<Discount_Secondary_MD *> *)values;

@end

NS_ASSUME_NONNULL_END
