//
//  Discount_M.m
//  RapidRMS
//
//  Created by Siya Infotech on 02/02/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "Discount_M.h"
#import "Discount_Primary_MD.h"
#import "Discount_Secondary_MD.h"

@implementation Discount_M

// Insert code here to add functionality to your managed object subclass
-(void)updateDiscountFromDictionary :(nullable NSDictionary *)discountDictionary {
    if (discountDictionary) {
        self.discountId = @([discountDictionary[@"DiscountId"] integerValue]);
        self.discountType = @([discountDictionary[@"DiscountType"] integerValue]);
        
        self.name = discountDictionary[@"Name"];
        self.descriptionText = discountDictionary[@"Description"];
        self.code = discountDictionary[@"Code"];
        self.quantityType = @([discountDictionary[@"QuantityType"] integerValue]);
        
        self.taxType = @([discountDictionary[@"TaxType"] integerValue]);
        self.qtyLimit = @([discountDictionary[@"QtyLimit"] integerValue]);
        self.validDays = @([discountDictionary[@"ValidDays"] integerValue]);
        
        self.isUnit = @([discountDictionary[@"isUnit"] integerValue]);
        self.isCase = @([discountDictionary[@"isCase"] integerValue]);
        self.isPack = @([discountDictionary[@"isPack"] integerValue]);
        self.isStatus = @([discountDictionary[@"isStatus"] integerValue]);
        self.isDelete = @([discountDictionary[@"IsDelete"] integerValue]);
        
        self.primaryItemQty = @([discountDictionary[@"PrimaryItemQty"] integerValue]);
        self.secondaryItemQty = @([discountDictionary[@"SecondaryItemQty"] integerValue]);
        self.freeType = @([discountDictionary[@"FreeType"] integerValue]);
        self.free = @([discountDictionary[@"Free"] floatValue]);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];

        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        
        self.startDate = [formatter dateFromString:discountDictionary[@"Start"]];
        if ([discountDictionary[@"EndDate"] isEqualToString:@"01/01/1900"]) {
            self.endDate = nil;
        }
        else {
            self.endDate = [formatter dateFromString:discountDictionary[@"EndDate"]];
        }
        formatter.dateFormat = @"MM/dd/yyyy hh:mm:ss";
        self.createdDate = [formatter dateFromString:discountDictionary[@"LocalDateTime"]];
        
        formatter.dateFormat = @"HH:mm:ss";
        
        self.startTime = [formatter dateFromString:discountDictionary[@"StartTime"]];
        self.endTime = [formatter dateFromString:discountDictionary[@"EndTime"]];
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        NSString *stringConverted = [formatter stringFromDate:[NSDate date]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        self.startDate = [formatter dateFromString:stringConverted];
        self.validDays = @127;
        self.discountId = @(0);
        self.isStatus = @(1);
        self.isDelete = @(0);
        self.isUnit = @(1);
    }
}
-(NSDictionary *)discountDetailDisctionary {
    NSMutableDictionary * dictDetailInfo = [[NSMutableDictionary alloc]init];
    
    dictDetailInfo[@"DiscountId"] = self.discountId.stringValue;
    dictDetailInfo[@"DiscountType"] = self.discountType.stringValue;
    dictDetailInfo[@"Name"] = self.name;
    dictDetailInfo[@"Description"] = self.descriptionText;
    dictDetailInfo[@"Code"] = self.code;
    dictDetailInfo[@"TaxType"] = @(0);
    dictDetailInfo[@"QtyLimit"] = self.qtyLimit.stringValue;
    
    dictDetailInfo[@"ValidDays"] = self.validDays.stringValue;

    dictDetailInfo[@"PrimaryItemQty"] = self.primaryItemQty.stringValue;
    dictDetailInfo[@"SecondaryItemQty"] = self.secondaryItemQty.stringValue;
    dictDetailInfo[@"QuantityType"] = self.quantityType;
    dictDetailInfo[@"FreeType"] = self.freeType.stringValue;
    
    dictDetailInfo[@"Free"] = [NSString stringWithFormat:@"%.2f",self.free.floatValue];
    
    [self setBoolValuein:dictDetailInfo boolObject:self.isStatus.boolValue withKey:@"isStatus"];
    [self setBoolValuein:dictDetailInfo boolObject:self.isUnit.boolValue withKey:@"isUnit"];
    [self setBoolValuein:dictDetailInfo boolObject:self.isCase.boolValue withKey:@"isCase"];
    [self setBoolValuein:dictDetailInfo boolObject:self.isPack.boolValue withKey:@"isPack"];
    [self setBoolValuein:dictDetailInfo boolObject:self.isStatus.boolValue withKey:@"isStatus"];
    [self setBoolValuein:dictDetailInfo boolObject:FALSE withKey:@"isDelete"];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    [dictDetailInfo setObject:[formatter stringFromDate:self.startDate] forKey:@"Start"];
    if (self.endDate) {
        dictDetailInfo[@"EndDate"] = [formatter stringFromDate:self.endDate];
    }
    else {
        dictDetailInfo[@"EndDate"] = @"";
    }

    if (self.createdDate) {
        dictDetailInfo[@"LocalDateTime"] = [formatter stringFromDate:self.createdDate];
    }
    else {
        dictDetailInfo[@"LocalDateTime"] = [formatter stringFromDate:[NSDate date]];
    }
    
    formatter.dateFormat = @"HH:mm:ss";
    dictDetailInfo[@"StartTime"] = [formatter stringFromDate:self.startTime];
    dictDetailInfo[@"EndTime"] = [formatter stringFromDate:self.endTime];
    
    
    return dictDetailInfo;
}

-(NSArray *)discountPrimaryArray {
    NSMutableArray * arrPrimaryItems = [[NSMutableArray alloc]init];
    NSArray * arrItemList = self.primaryItems.allObjects;
    for (Discount_Primary_MD * anItem in arrItemList) {
        [arrPrimaryItems addObject:anItem.discountPrimaryDisctionary];
    }
    return arrPrimaryItems;
}
-(NSArray *)discountSecondaryArray {
    NSMutableArray * arrSecondaryItems = [[NSMutableArray alloc]init];
    NSArray * arrItemList = self.secondaryItems.allObjects;
    for (Discount_Secondary_MD * anItem in arrItemList) {
        [arrSecondaryItems addObject:anItem.discountSecondaryDisctionary];
    }
    return arrSecondaryItems;
}
-(void)setBoolValuein:(NSMutableDictionary *)dictInfo boolObject:(BOOL)setValue withKey:(NSString *)strKey{
    if (setValue) {
        dictInfo[strKey] = @"1";
    }
    else {
        dictInfo[strKey] = @"0";
    }
}
@end
