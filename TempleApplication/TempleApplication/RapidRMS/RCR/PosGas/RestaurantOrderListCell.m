//
//  RestaurantOrderListCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/13/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RestaurantOrderListCell.h"
#import "RestaurantItem+Dictionary.h"
#import "RestaurantOrder+Dictionary.h"

@implementation RestaurantOrderListCell


-(NSString * )durationForOrderStartDate:(NSDate *)startDate
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDate *d1 = startDate;
    NSDate *d2 = [NSDate date];//2012-06-22
    NSDateComponents *components = [c components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:d2 toDate:d1 options:0];
    NSInteger diffInMinutes = -components.minute;
    NSInteger diffInHours = -components.hour;
    return  [NSString stringWithFormat:@"%ld hours %ld min",(long)diffInHours,(long)diffInMinutes];
}


-(UIColor *)restaurantItemForRestaurantOrder:(RestaurantOrder *)restaurantOrder
{
    UIColor *cellColor = [UIColor clearColor];
    if (restaurantOrder.restaurantOrderItem.allObjects.count > 0) {
        NSPredicate *restaurantOrderPredicate = [NSPredicate predicateWithFormat:@"isNoPrint = %@ AND isPrinted = %@",@(0),@(0)];
        NSArray *resultSet = [restaurantOrder.restaurantOrderItem.allObjects filteredArrayUsingPredicate:restaurantOrderPredicate];
        if (resultSet.count > 0) {
            cellColor = [UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:0.8];
        }
    }
    return cellColor;
}

@end
