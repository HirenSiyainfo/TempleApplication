//
//  RestaurantOrderListCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/13/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantOrderListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *tableNo;
@property (nonatomic, weak) IBOutlet UILabel *noOfGuest;
@property (nonatomic, weak) IBOutlet UILabel *totalAmount;
@property (nonatomic, weak) IBOutlet UILabel *dateTime;
@property (nonatomic, weak) IBOutlet UILabel *duration;


-(UIColor *)restaurantItemForRestaurantOrder:(RestaurantOrder *)restaurantOrder;
-(NSString * )durationForOrderStartDate:(NSDate *)startDate;

@end
