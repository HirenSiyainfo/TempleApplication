//
//  ItemInventoryCountSession+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 1/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemInventoryCountSession+Dictionary.h"

@implementation ItemInventoryCountSession (Dictionary)

-(NSDictionary *)getItemInventoryCountDictionary
{
    NSMutableDictionary *itemInventoryCountDictionary = [[NSMutableDictionary alloc]init];
    if(self.branchId != nil)
    {
        itemInventoryCountDictionary[@"BranchId"] = self.branchId;
    }
    if (self.sessionId != nil) {
        itemInventoryCountDictionary[@"StockSessionId"] = self.sessionId;
    }
    if(self.startDate != nil)
    {
        itemInventoryCountDictionary[@"StartDate"] = self.startDate;
    }
    if(self.endDate != nil)
    {
        itemInventoryCountDictionary[@"EndDate"] = self.endDate;
    }
    itemInventoryCountDictionary[@"Remarks"] = self.remarks;
    if(self.status != nil)
    {
        itemInventoryCountDictionary[@"Status"] = self.status;
    }
    
    return itemInventoryCountDictionary;
}

-(void)updateItemInventoryCountDictionary :(NSDictionary *)itemInventoryCountDictionary
{
    self.branchId =[itemInventoryCountDictionary valueForKey:@"BranchId"];
    self.sessionId =[itemInventoryCountDictionary valueForKey:@"StockSessionId"];
    // START DATE
    if([[itemInventoryCountDictionary valueForKey:@"StartDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        NSDate *currentDate = [dateFormatter dateFromString:[itemInventoryCountDictionary valueForKey:@"StartDate"]];
        self.startDate = currentDate;
    }
    else  if([[itemInventoryCountDictionary valueForKey:@"StartDate"] isKindOfClass:[NSDate class]])
    {
        self.startDate = [itemInventoryCountDictionary valueForKey:@"StartDate"];
    }
    // END DATE
    if([[itemInventoryCountDictionary valueForKey:@"EndDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        NSDate *currentDate = [dateFormatter dateFromString:[itemInventoryCountDictionary valueForKey:@"EndDate"]];
        self.startDate = currentDate;
    }
    else  if([[itemInventoryCountDictionary valueForKey:@"EndDate"] isKindOfClass:[NSDate class]])
    {
        self.startDate = [itemInventoryCountDictionary valueForKey:@"EndDate"];
    }
    self.remarks = [itemInventoryCountDictionary valueForKey:@"Remarks"];
    self.status = [itemInventoryCountDictionary valueForKey:@"Status"];
}

@end
