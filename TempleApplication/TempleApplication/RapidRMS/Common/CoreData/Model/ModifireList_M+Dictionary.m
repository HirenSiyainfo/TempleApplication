//
//  ModifireList_M+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 10/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ModifireList_M+Dictionary.h"

@implementation ModifireList_M (Dictionary)

-(NSDictionary *)itemModifireItemMDictionary
{
    NSMutableDictionary *itemModifireItemMDictionary=[[NSMutableDictionary alloc]init];
    itemModifireItemMDictionary[@"BrnModifierItemId"] = self.brnModifierItemId;
    itemModifireItemMDictionary[@"BranchId"] = self.branchId;
    itemModifireItemMDictionary[@"ModifierId"] = self.modifierId;
    itemModifireItemMDictionary[@"ModifireItem"] = self.modifireItem;
    itemModifireItemMDictionary[@"Price"] = self.price;
    itemModifireItemMDictionary[@"CalcInPOS"] = self.calcInPOS;
    itemModifireItemMDictionary[@"CreatedBy"] = self.createdBy;
    //    [itemModifireItemMDictionary setObject:self.createdDate forKey:@"CreatedDate"];
    itemModifireItemMDictionary[@"IsDeleted"] = self.isDelete;
    return itemModifireItemMDictionary;
}

-(void)updateitemModifireItemMDictionary :(NSDictionary *)itemModifireItemMDictionary
{
    self.brnModifierItemId =  @([[itemModifireItemMDictionary valueForKey:@"BrnModifierItemId"] integerValue]);
    self.branchId =  @([[itemModifireItemMDictionary valueForKey:@"BranchId"] integerValue]);
    self.modifierId =  @([[itemModifireItemMDictionary valueForKey:@"ModifierId"] integerValue]);
    self.modifireItem = [itemModifireItemMDictionary valueForKey:@"ModifireItem"];
    self.price =  @([[itemModifireItemMDictionary valueForKey:@"Price"] floatValue]);
    self.calcInPOS =  @([[itemModifireItemMDictionary valueForKey:@"CalcInPOS"] integerValue]);
    self.createdBy =  @([[itemModifireItemMDictionary valueForKey:@"CreatedBy"] integerValue]);
    //    self.createdDate = [itemModifireItemMDictionary valueForKey:@"CreatedDate"];
    self.isDelete =  @([[itemModifireItemMDictionary valueForKey:@"IsDeleted"] integerValue]);
}

@end
