//
//  RestaurantOrder+CoreDataProperties.m
//  RapidRMS
//
//  Created by Siya Infotech on 5/19/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "RestaurantOrder+CoreDataProperties.h"

@implementation RestaurantOrder (CoreDataProperties)

+ (NSFetchRequest<RestaurantOrder *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RestaurantOrder"];
}

@dynamic branch_id;
@dynamic endTime;
@dynamic isDineIn;
@dynamic isPaid;
@dynamic noOfGuest;
@dynamic order_id;
@dynamic register_Id;
@dynamic startTime;
@dynamic state;
@dynamic tabelName;
@dynamic table_id;
@dynamic totalAmount;
@dynamic totalDiscount;
@dynamic totalTax;
@dynamic waiter_id;
@dynamic waiterName;
@dynamic paymentData;
@dynamic invoiceNo;
@dynamic orderStatus;
@dynamic restaurantOrderItem;

@end
