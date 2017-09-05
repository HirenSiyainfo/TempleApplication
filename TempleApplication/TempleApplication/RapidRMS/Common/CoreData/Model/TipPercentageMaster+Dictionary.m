//
//  TipPercentageMaster+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 11/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TipPercentageMaster+Dictionary.h"

@implementation TipPercentageMaster (Dictionary)

-(NSDictionary *)tipPercentageMasterDictionary
{
    NSMutableDictionary *tipPercentageMasterDictionary=[[NSMutableDictionary alloc]init];
    tipPercentageMasterDictionary[@"BrnTipPercentageId"] = self.brnTipPercentageId;
    tipPercentageMasterDictionary[@"TipPercentage"] = self.tipPercentage;
//    [tipPercentageMasterDictionary setObject:self.branchId forKey:@"BranchId"];
    tipPercentageMasterDictionary[@"IsDeleted"] = self.isDelete;
//    [tipPercentageMasterDictionary setObject:self.createdBy forKey:@"CreatedBy"];
    return tipPercentageMasterDictionary;
}

-(void)updateTipPercentageMasterDictionary :(NSDictionary *)tipPercentageMasterDictionary
{
    self.brnTipPercentageId =  @([[tipPercentageMasterDictionary valueForKey:@"BrnTipPercentageId"] integerValue]);
    self.tipPercentage =  @([[tipPercentageMasterDictionary valueForKey:@"TipPercentage"] floatValue]);
//    self.branchId =  @([[tipPercentageMasterDictionary valueForKey:@"BranchId"] integerValue]);
    self.isDelete =  @([[tipPercentageMasterDictionary valueForKey:@"IsDeleted"] integerValue]);
//    self.createdBy =  @([[tipPercentageMasterDictionary valueForKey:@"CreatedBy"] integerValue]);
}

@end
