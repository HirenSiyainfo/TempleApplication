//
//  ItemInventoryCount+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 1/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemInventoryCount+Dictionary.h"

@implementation ItemInventoryCount (Dictionary)

-(void)updateItemInventoryCountDictionary :(NSDictionary *)itemInventoryCountDictionary
{
    self.createDate = [itemInventoryCountDictionary valueForKey:@"createDate"];
    self.sessionId = [itemInventoryCountDictionary valueForKey:@"sessionId"];
    self.singleCount  =  @([[itemInventoryCountDictionary valueForKey:@"addedSingleQty"] integerValue]);
    self.caseCount  = @([[itemInventoryCountDictionary valueForKey:@"addedCaseQty"] integerValue]);
    self.packCount  =  @([[itemInventoryCountDictionary valueForKey:@"addedPackQty"]integerValue]);
    self.itemCode  = @([[itemInventoryCountDictionary valueForKey:@"itemCode"]integerValue]);
    self.userId  = [itemInventoryCountDictionary valueForKey:@"userId"];
    self.registerId = [itemInventoryCountDictionary valueForKey:@"registerId"];
    
    self.isUploadedToServer = [itemInventoryCountDictionary valueForKey:@"isUploadedToServer"];
    self.userSessionId = [itemInventoryCountDictionary valueForKey:@"userSessionId"];
    self.isDelete = [itemInventoryCountDictionary valueForKey:@"isDelete"];
   
}

-(void)updateItemInventoryCountDictionaryOfServer :(NSDictionary *)itemInventoryCountDictionary
{
    self.itemCountId = [itemInventoryCountDictionary valueForKey:@"Id"];
    self.sessionId = [itemInventoryCountDictionary valueForKey:@"StockSessionId"];
    self.singleCount  =  @([[itemInventoryCountDictionary valueForKey:@"SingleCount"] integerValue]);
    self.caseCount  = @([[itemInventoryCountDictionary valueForKey:@"CaseCount"] integerValue]);
    self.packCount  =  @([[itemInventoryCountDictionary valueForKey:@"PackCount"]integerValue]);
    self.itemCode  = @([[itemInventoryCountDictionary valueForKey:@"ItemCode"]integerValue]);
    self.userId  = [itemInventoryCountDictionary valueForKey:@"UserId"];
    self.registerId = [itemInventoryCountDictionary valueForKey:@"RegisterId"];
    
    if([[itemInventoryCountDictionary valueForKey:@"LocalDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        NSDate *currentDate = [dateFormatter dateFromString:[itemInventoryCountDictionary valueForKey:@"LocalDate"]];
        self.createDate = currentDate;
    }
    else
    {
        self.createDate = [itemInventoryCountDictionary valueForKey:@"LocalDate"];
    }
    
    self.userSessionId = [itemInventoryCountDictionary valueForKey:@"UserSessionId"];
    self.isUploadedToServer = @(1);
    self.isDelete = @(0);    
}

@end
