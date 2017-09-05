//
//  RestaurantItem+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RestaurantItem+Dictionary.h"

@implementation RestaurantItem (Dictionary)
-(void)updateRestaurantItemDictionary :(NSDictionary * )restaurantItemDictionary
{
    self.isCanceled = @([[restaurantItemDictionary valueForKey:@"isCanceled"] integerValue]);
    self.isNoPrint = @([[restaurantItemDictionary valueForKey:@"isNoPrint"] integerValue]);
    self.isPrinted = @([[restaurantItemDictionary valueForKey:@"isPrinted"] integerValue]);
    self.itemId = @([[restaurantItemDictionary valueForKey:@"itemId"] integerValue]);
    self.itemIndex = @([[restaurantItemDictionary valueForKey:@"itemIndex"] integerValue]);
    self.noteToChef = [restaurantItemDictionary valueForKey:@"noteToChef"];
    self.orderId = @([[restaurantItemDictionary valueForKey:@"orderId"] integerValue]);
    self.orderItemId = @([[restaurantItemDictionary valueForKey:@"orderItemId"] integerValue]);
    self.previousQuantity = @([[restaurantItemDictionary valueForKey:@"previousQuantity"] integerValue]);
    self. quantity = @([[restaurantItemDictionary valueForKey:@"quantity"] integerValue]);
    self.itemDetail = [self archivedDataWithRestaurantItemObject:[restaurantItemDictionary valueForKey:@"itemDetail"]];
    self. guestId = @([[restaurantItemDictionary valueForKey:@"guestId"] integerValue]);
    self.itemName = [restaurantItemDictionary valueForKey:@"itemName"];
    self.isDineIn = @([[restaurantItemDictionary valueForKey:@"isDineIn"] integerValue]);
}
-(NSData *)archivedDataWithRestaurantItemObject:(NSMutableArray *)itemDetail
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:itemDetail];
    return data;
}

@end
