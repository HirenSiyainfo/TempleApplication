//
//  Modifire_M+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 09/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Modifire_M+Dictionary.h"

@implementation Modifire_M (Dictionary)

-(NSDictionary *)itemModifireMDictionary
{
    NSMutableDictionary *itemModifireMDictionary=[[NSMutableDictionary alloc]init];
    itemModifireMDictionary[@"BrnModifierId"] = self.brnModifierId;
    itemModifireMDictionary[@"BranchId"] = self.branchId;
    itemModifireMDictionary[@"Name"] = self.modifireName;
    itemModifireMDictionary[@"CreatedBy"] = self.createdBy;
//    [itemModifireMDictionary setObject:self.createdDate forKey:@"CreatedDate"];
    itemModifireMDictionary[@"IsDeleted"] = self.isDelete;
    return itemModifireMDictionary;
}

-(void)updateitemModifireMDictionary :(NSDictionary *)itemModifireMDictionary
{
    self.brnModifierId =  @([[itemModifireMDictionary valueForKey:@"BrnModifierId"] integerValue]);
    self.branchId =  @([[itemModifireMDictionary valueForKey:@"BranchId"] integerValue]);
    self.modifireName = [itemModifireMDictionary valueForKey:@"Name"];
    self.createdBy =  @([[itemModifireMDictionary valueForKey:@"CreatedBy"] integerValue]);
//    self.createdDate = [itemModifireMDictionary valueForKey:@"CreatedDate"];
    self.isDelete =  @([[itemModifireMDictionary valueForKey:@"IsDeleted"] integerValue]);
}

@end
