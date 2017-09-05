//
//  ItemTicket_MD+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/24/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemTicket_MD+Dictionary.h"

@implementation ItemTicket_MD (Dictionary)


-(void)updateItemTicketlDictionary :(NSDictionary *)itemTicketDictionary
{

    self.createddate = [NSDate date];
    self.expirationDays = @([[itemTicketDictionary valueForKey:@"ExpirationDays"] integerValue]);
    self.friday = @([[itemTicketDictionary valueForKey:@"Friday"] boolValue]);
    self.isExpiration = @([[itemTicketDictionary valueForKey:@"IsExpiration"] boolValue]);
    self.isTicket = @([[itemTicketDictionary valueForKey:@"IsTicket"] boolValue]);
    self.itemCode = @([[itemTicketDictionary valueForKey:@"ItemCode"] integerValue]);
    self.monday = @([[itemTicketDictionary valueForKey:@"Monday"] boolValue]);
    self.noOfdays = @([[itemTicketDictionary valueForKey:@"NoOfdays"] integerValue]);
    self.saturday = @([[itemTicketDictionary valueForKey:@"Saturday"] boolValue]);
    self.selectedOption = @([[itemTicketDictionary valueForKey:@"SelectedOption"] integerValue]);
    self.sunday = @([[itemTicketDictionary valueForKey:@"Sunday"] boolValue]);
    self.thursday = @([[itemTicketDictionary valueForKey:@"Thursday"] boolValue]);
    self.ticketId = @([[itemTicketDictionary valueForKey:@"Id"] integerValue]);
    self.tuesday = @([[itemTicketDictionary valueForKey:@"Tuesday"] boolValue]);
    self.userId = @([[itemTicketDictionary valueForKey:@"UserId"] integerValue]);
    self.wednesday = @([[itemTicketDictionary valueForKey:@"Wednesday"] boolValue]);
    self.noOfPerson = @([[itemTicketDictionary valueForKey:@"NoOfPerson"] integerValue]);
}
-(NSMutableDictionary *)itemTicketDictionary
{
    NSMutableDictionary *itemTicketDictionary = [[NSMutableDictionary alloc]init];
    itemTicketDictionary[@"Pass"] = [NSString stringWithFormat:@"%@",self.isTicket];
    itemTicketDictionary[@"Expiry"] = [NSString stringWithFormat:@"%@",self.isExpiration];
    itemTicketDictionary[@"DaysofExpiry"] = [NSString stringWithFormat:@"%@",self.expirationDays];
    itemTicketDictionary[@"ValidDays"] = [NSString stringWithFormat:@"%@",self.noOfdays];
    itemTicketDictionary[@"AllDays"] = [NSString stringWithFormat:@"%@",self.selectedOption];
    itemTicketDictionary[@"Sunday"] = [NSString stringWithFormat:@"%@",self.sunday];
    itemTicketDictionary[@"Monday"] = [NSString stringWithFormat:@"%@",self.monday];
    itemTicketDictionary[@"Tuesday"] = [NSString stringWithFormat:@"%@",self.tuesday];
    itemTicketDictionary[@"Wednesday"] = [NSString stringWithFormat:@"%@",self.wednesday];
    itemTicketDictionary[@"Thursday"] = [NSString stringWithFormat:@"%@",self.thursday];
    itemTicketDictionary[@"Friday"] = [NSString stringWithFormat:@"%@",self.friday];
    itemTicketDictionary[@"Saturday"] = [NSString stringWithFormat:@"%@",self.saturday];

    
    return itemTicketDictionary;
}

@end
