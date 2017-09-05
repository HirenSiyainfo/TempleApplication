//
//  RestaurantOrder+CoreDataProperties.h
//  RapidRMS
//
//  Created by Siya Infotech on 5/19/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "RestaurantOrder.h"


NS_ASSUME_NONNULL_BEGIN

@interface RestaurantOrder (CoreDataProperties)

+ (NSFetchRequest<RestaurantOrder *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *branch_id;
@property (nullable, nonatomic, copy) NSDate *endTime;
@property (nullable, nonatomic, copy) NSNumber *isDineIn;
@property (nullable, nonatomic, copy) NSNumber *isPaid;
@property (nullable, nonatomic, copy) NSNumber *noOfGuest;
@property (nullable, nonatomic, copy) NSNumber *order_id;
@property (nullable, nonatomic, copy) NSNumber *register_Id;
@property (nullable, nonatomic, copy) NSDate *startTime;
@property (nullable, nonatomic, copy) NSNumber *state;
@property (nullable, nonatomic, copy) NSString *tabelName;
@property (nullable, nonatomic, copy) NSNumber *table_id;
@property (nullable, nonatomic, copy) NSNumber *totalAmount;
@property (nullable, nonatomic, copy) NSNumber *totalDiscount;
@property (nullable, nonatomic, copy) NSNumber *totalTax;
@property (nullable, nonatomic, copy) NSNumber *waiter_id;
@property (nullable, nonatomic, copy) NSString *waiterName;
@property (nullable, nonatomic, retain) NSData *paymentData;
@property (nullable, nonatomic, copy) NSString *invoiceNo;
@property (nullable, nonatomic, copy) NSNumber *orderStatus;
@property (nullable, nonatomic, retain) NSSet<RestaurantItem *> *restaurantOrderItem;

@end

@interface RestaurantOrder (CoreDataGeneratedAccessors)

- (void)addRestaurantOrderItemObject:(RestaurantItem *)value;
- (void)removeRestaurantOrderItemObject:(RestaurantItem *)value;
- (void)addRestaurantOrderItem:(NSSet<RestaurantItem *> *)values;
- (void)removeRestaurantOrderItem:(NSSet<RestaurantItem *> *)values;

@end

NS_ASSUME_NONNULL_END
