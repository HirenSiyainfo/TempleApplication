//
//  NSDate+DateFormat.m
//  RapidRMS
//
//  Created by siya8 on 25/07/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//



#import "NSDate+DateFormat.h"


@implementation NSDateStorage
@end

@implementation NSDate (DateFormat)

+(NSDate *)selectDay:(NSDate *)date withDays:(NSInteger)days
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:date];
    components.day = days;
    NSDate *day = [cal dateByAddingComponents:components toDate: date options:0];
    return day;
}

+(NSDateStorage *)startDateOfWeek
{
    NSDateStorage *nsDateStorage = [[NSDateStorage alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDate *startOfTheWeek;
    NSTimeInterval interval;
    [cal rangeOfUnit:NSCalendarUnitWeekOfMonth
           startDate:&startOfTheWeek
            interval:&interval
             forDate:now];
    nsDateStorage.convertedDate = startOfTheWeek;
    nsDateStorage.calculatedInterval = interval;
    return nsDateStorage;

}
+(NSDate *)startDateOfCurrentWeek
{
    NSDateStorage *nsDateStorage = [self startDateOfWeek];
    return nsDateStorage.convertedDate;
}
+(NSDate *)endDateOfCurrentWeek
{
    NSDateStorage *nsDateStorage = [self startDateOfWeek];
    NSDate * endOfWeek = [nsDateStorage.convertedDate dateByAddingTimeInterval:nsDateStorage.calculatedInterval-1];
    return endOfWeek;
}
+(NSDate *)startDateOfLastWeek
{
    NSDateStorage *nsDateStorage = [self startDateOfWeek];
    NSDate * endOfWeek = [nsDateStorage.convertedDate dateByAddingTimeInterval:-nsDateStorage.calculatedInterval];
    return endOfWeek;
}

- (NSDate *)returnDateForMonth:(NSInteger)month year:(NSInteger)year day:(NSInteger)day {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = day;
    components.month = month;
    components.year = year;
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorian dateFromComponents:components];
}
-(NSDateStorage *)dateOfMonth:(NSInteger)selectedMonth
{
    NSDateStorage *nsDateStorage = [[NSDateStorage alloc] init];

    NSCalendar * cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *comps = [cal components:unitFlags fromDate:[NSDate date]];
    comps.month = (comps.month - selectedMonth);
    NSDate * firstDateOfMonth = [self returnDateForMonth:comps.month year:comps.year day:1];
    NSDate * lastDateOfMonth = [self returnDateForMonth:comps.month+1 year:comps.year day:1];
    nsDateStorage.firstDate = firstDateOfMonth;
    nsDateStorage.lastDate = lastDateOfMonth;

    return nsDateStorage;
}

@end
