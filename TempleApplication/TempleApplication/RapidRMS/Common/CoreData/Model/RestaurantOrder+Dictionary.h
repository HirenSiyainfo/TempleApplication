//
//  RestaurantOrder+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RestaurantOrder.h"
typedef NS_ENUM(NSInteger, RESTAURANT_ORDER_STATE) {
    OPEN_ORDER ,
    COMPLETED_ORDER,
    CANCEL_ORDER,
};

@interface RestaurantOrder (Dictionary)
-(void)updateRestaurantOrderDictionary :(NSDictionary *)restaurantOrderDictionary;

@end
