//
//  DiscountMaster+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 5/29/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DiscountMaster+Dictionary.h"

@implementation DiscountMaster (Dictionary)
-(NSDictionary *)discountMasterDictionary
{
    return nil;
}
-(void)updateDiscountMasterFromDictionary :(NSDictionary *)discountMasterDictionary
{
    self.amount =  @([[discountMasterDictionary valueForKey:@"Amount"] floatValue]);
    self.discountId =  @([[discountMasterDictionary valueForKey:@"DiscountId"] integerValue]);
    self.title =  [NSString stringWithFormat:@"%@",[discountMasterDictionary valueForKey:@"Title"]];
    self.type =  [NSString stringWithFormat:@"%@",[discountMasterDictionary valueForKey:@"Type"]];
    self.salesDiscount =  @([[discountMasterDictionary valueForKey:@"SalesDiscount"] boolValue]);
    self.isDelete =  @([[discountMasterDictionary valueForKey:@"IsDeleted"] boolValue]);
    self.branchId =  @([[discountMasterDictionary valueForKey:@"BranchId"] integerValue]);
}
@end
