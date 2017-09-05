//
//  GroupMaster+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 14/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "GroupMaster+Dictionary.h"

@implementation GroupMaster (Dictionary)

-(NSDictionary *)groupMasterDictionary
{
    return nil;
}

-(NSDictionary *)groupMasterLoadDictionary
{
    NSMutableDictionary *groupMasterDictionary=[[NSMutableDictionary alloc]init];
    groupMasterDictionary[@"GroupId"] = self.groupId;
    groupMasterDictionary[@"GroupName"] = self.groupName;
    groupMasterDictionary[@"CostPrice"] = self.costPrice;
    groupMasterDictionary[@"SellingPrice"] = self.sellingPrice;
    groupMasterDictionary[@"Disc_Id"] = self.disc_Id;

    return  groupMasterDictionary;
}

-(void)updateGroupMasterFromDictionary :(NSDictionary *)groupMasterDictionary
{
    self.groupId =  @([[groupMasterDictionary valueForKey:@"GroupId"] integerValue]);
    self.groupName = [groupMasterDictionary valueForKey:@"GroupName"];
    self.costPrice = [groupMasterDictionary valueForKey:@"CostPrice"];
    self.sellingPrice = [groupMasterDictionary valueForKey:@"SellingPrice"];
    self.disc_Id = @([[groupMasterDictionary valueForKeyPath:@"Disc_Id"] integerValue]);
}

@end
