//
//  RestaurantOrder+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RestaurantOrder+Dictionary.h"

@implementation RestaurantOrder (Dictionary)

-(void)updateRestaurantOrderDictionary :(NSDictionary *)restaurantOrderDictionary
{
    self.order_id = @([[restaurantOrderDictionary valueForKey:@"orderid"] integerValue]) ;
    self.noOfGuest= @([[restaurantOrderDictionary valueForKey:@"noOfGuest"] integerValue]);
    self.tabelName = [restaurantOrderDictionary valueForKey:@"tableName"];
    self.startTime= [NSDate date];
    self.totalAmount = @([[restaurantOrderDictionary valueForKey:@"InvoiceTotal"] floatValue]);
    self.totalDiscount = @([[restaurantOrderDictionary valueForKey:@"InvoiceDiscount"] floatValue]);
    self.totalTax = @([[restaurantOrderDictionary valueForKey:@"InvoiceTax"] floatValue]);
    self.state = @([[restaurantOrderDictionary valueForKey:@"orderState"] integerValue]) ;
    self.waiter_id = @([[restaurantOrderDictionary valueForKey:@"UserId"] integerValue]) ;
    self.isDineIn = @([[restaurantOrderDictionary valueForKey:@"isDineIn"] integerValue]) ;
    self.invoiceNo = [restaurantOrderDictionary valueForKey:@"InvoiceNo"] ;

}

@end
