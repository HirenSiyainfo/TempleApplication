//
//  Item_Discount_MD2+Dictionary.m
//  POSRetail
//
//  Created by Siya Infotech on 13/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"

@implementation Item_Discount_MD2 (Dictionary)
-(NSDictionary *)itemDiscount_MD2Dictionary
{
    NSMutableDictionary *itemDiscount_MD2Dictionary=[[NSMutableDictionary alloc]init];
    itemDiscount_MD2Dictionary[@"DIS_Qty"] = self.md2Tomd.dis_Qty;
    itemDiscount_MD2Dictionary[@"DIS_UnitPrice"] = self.md2Tomd.dis_UnitPrice;
    itemDiscount_MD2Dictionary[@"DayId"] = self.dayId.stringValue;
    itemDiscount_MD2Dictionary[@"EndDate"] = self.endDate;
    itemDiscount_MD2Dictionary[@"RowId"] = self.discountId.stringValue;
    itemDiscount_MD2Dictionary[@"StartDate"] = self.startDate;
    return itemDiscount_MD2Dictionary;
}

-(NSDictionary *)itemDiscount_MD2DictionaryRim
{
    NSMutableDictionary *itemDiscount_MD2Dictionary=[[NSMutableDictionary alloc]init];

    itemDiscount_MD2Dictionary[@"DiscountId"] = self.discountId;
    itemDiscount_MD2Dictionary[@"DIS_Qty"] = self.md2Tomd.dis_Qty;
    itemDiscount_MD2Dictionary[@"DIS_UnitPrice"] = self.md2Tomd.dis_UnitPrice;
    itemDiscount_MD2Dictionary[@"DayId"] = self.dayId.stringValue;
    itemDiscount_MD2Dictionary[@"EndDate"] = self.endDate;
    itemDiscount_MD2Dictionary[@"RowId"] = self.rowId.stringValue;
    itemDiscount_MD2Dictionary[@"StartDate"] = self.startDate;
    return itemDiscount_MD2Dictionary;
}



- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    format.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
    
    NSTimeZone *destinationGMTOffset=[NSTimeZone timeZoneForSecondsFromGMT:0];
    format.timeZone = destinationGMTOffset;
    NSString *datestring=[format stringFromDate:date];
    return datestring;

}


- (NSDate *)dateFromString:(NSString *)datestring
{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    format.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
    NSDate *date=[format dateFromString:datestring];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date] ;
    return destinationDate;
}

-(void)updateItemDiscount_Md2FromDictionary :(NSDictionary *)itemDiscount_MD2Dictionary
{
    self.dayId= @([[itemDiscount_MD2Dictionary valueForKey:@"DayId"] integerValue]);
    self.discountId = @([[itemDiscount_MD2Dictionary valueForKey:@"DiscountId"] integerValue]);
    NSString *datestring = [itemDiscount_MD2Dictionary valueForKey:@"EndDate"];
    if([datestring isKindOfClass:[NSString class]])
    {
        self.endDate = datestring;
    }
    else
    {
        self.endDate = @"1/1/1900 12:00:00 AM";
    }
    NSString *datestringStart = [itemDiscount_MD2Dictionary valueForKey:@"StartDate"];
    if([datestringStart isKindOfClass:[NSString class]])
    {
        self.startDate=datestringStart;
    }
    else
    {
        self.startDate = @"1/1/1900 12:00:00 AM";
    }
    self.rowId = [itemDiscount_MD2Dictionary valueForKey:@"RowId"];
}

-(NSDate*)jsonStringToNSDate :(NSString* ) string
{
    // Extract the numeric part of the date.  Dates should be in the format
    // "/Date(x)/", where x is a number.  This format is supplied automatically
    // by JSON serialisers in .NET.
    NSRange range = NSMakeRange(6, string.length - 8);
    NSString* substring = [string substringWithRange:range];
    
    // Have to use a number formatter to extract the value from the string into
    // a long long as the longLongValue method of the string doesn't seem to
    // return anything useful - it is always grossly incorrect.
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    NSNumber* milliseconds = [formatter numberFromString:substring];
    // NSTimeInterval is specified in seconds.  The value we get back from the
    // web service is specified in milliseconds.  Both values are since 1st Jan
    // 1970 (epoch).
    NSTimeInterval seconds = milliseconds.longLongValue / 1000;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

@end
