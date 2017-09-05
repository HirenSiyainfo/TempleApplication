//
//  Discount_Secondary_MD+CoreDataProperties.h
//  RapidRMS
//
//  Created by Siya Infotech on 05/02/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Discount_Secondary_MD.h"

NS_ASSUME_NONNULL_BEGIN

@interface Discount_Secondary_MD (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSNumber *discountId;
@property (nullable, nonatomic, retain) NSNumber *secondaryId;
@property (nullable, nonatomic, retain) NSNumber *isDelete;
@property (nullable, nonatomic, retain) NSNumber *itemId;
@property (nullable, nonatomic, retain) NSNumber *itemType;
@property (nullable, nonatomic, retain) Item *itemDetail;
@property (nullable, nonatomic, retain) Discount_M *secondaryItem;

@end

NS_ASSUME_NONNULL_END
