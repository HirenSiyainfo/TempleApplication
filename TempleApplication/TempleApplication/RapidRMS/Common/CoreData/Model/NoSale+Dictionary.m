//
//  NoSale+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 3/4/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "NoSale+Dictionary.h"

@implementation NoSale (Dictionary)
-(void)updateNoSaleDictionary :(NSDictionary *)noSaleDictionary
{
    self.noSaleType = [NSString stringWithFormat:@"%@",[noSaleDictionary valueForKey:@"NoSaleType"]] ;
    self.datetime = [NSDate date];
    self.userId = [NSString stringWithFormat:@"%@",[noSaleDictionary valueForKey:@"UserId"]];
    self.zId = [NSString stringWithFormat:@"%@",[noSaleDictionary valueForKey:@"ZId"]];
    self.registerId = [NSString stringWithFormat:@"%@",[noSaleDictionary valueForKey:@"RegisterId"]];
    self.branchId = [NSString stringWithFormat:@"%@",[noSaleDictionary valueForKey:@"BranchId"]];
    self.noSaleID = [NSString stringWithFormat:@"%@",[noSaleDictionary valueForKey:@"NoSaleID"]];
}
-(NSDictionary *)noSaleDictionary
{
    return nil;
}
@end
