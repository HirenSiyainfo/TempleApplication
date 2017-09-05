//
//  RestaurantItem.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, RestaurantOrder;

@interface RestaurantItem : NSManagedObject

@property (nonatomic, retain) NSNumber * guestId;
@property (nonatomic, retain) NSNumber * isCanceled;
@property (nonatomic, retain) NSNumber * isNoPrint;
@property (nonatomic, retain) NSNumber * isPrinted;
@property (nonatomic, retain) NSData * itemDetail;
@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSNumber * itemIndex;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSString * noteToChef;
@property (nonatomic, retain) NSNumber * orderId;
@property (nonatomic, retain) NSNumber * orderItemId;
@property (nonatomic, retain) NSNumber * previousQuantity;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * isDineIn;
@property (nonatomic, retain) RestaurantOrder *itemToOrderRestaurant;
@property (nonatomic, retain) Item *restaurantItemToItem;

@end
