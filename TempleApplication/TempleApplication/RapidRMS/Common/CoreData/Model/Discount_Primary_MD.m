//
//  Discount_Primary_MD.m
//  RapidRMS
//
//  Created by Siya Infotech on 02/02/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "Discount_Primary_MD.h"
#import "Discount_M.h"
#import "Item.h"

@implementation Discount_Primary_MD

// Insert code here to add functionality to your managed object subclass
-(void)updateDiscountPrimaryMDFromDictionary :(NSDictionary *)discountDictionary {
    self.primaryId = @([discountDictionary[@"Id"] integerValue]);
    self.discountId = @([discountDictionary[@"DiscountId"] integerValue]);
    self.itemType = @([discountDictionary[@"ItemType"] integerValue]);
    
    self.itemId = @([discountDictionary[@"ItemCode"] integerValue]);
    self.isDelete = @([discountDictionary[@"IsDelete"] integerValue]);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy";
    self.createdDate = [formatter dateFromString:discountDictionary[@"DateCreated"]];
}
-(NSDictionary *)discountPrimaryDisctionary {
    NSMutableDictionary * dictDetailInfo = [[NSMutableDictionary alloc]init];
    dictDetailInfo[@"DiscountId"] = self.primaryItem.discountId.stringValue;
    dictDetailInfo[@"ItemType"] = self.itemType.stringValue;
    dictDetailInfo[@"ItemCode"] = self.itemId.stringValue;
    
    return dictDetailInfo;
}
@end
