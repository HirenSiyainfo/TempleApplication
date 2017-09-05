//
//  NSDate+DateFormat.h
//  RapidRMS
//
//  Created by siya8 on 25/07/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateStorage : NSObject
@property (strong, nonatomic) NSDate *convertedDate;
@property (strong, nonatomic) NSDate *firstDate;
@property (strong, nonatomic) NSDate *lastDate;

@property (assign) NSInteger calculatedInterval;
@property (assign) NSInteger month;

@end

@interface NSDate (DateFormat)

+(NSDate *)selectDay:(NSDate *)date withDays:(NSInteger)days;
+(NSDate *)startDateOfCurrentWeek;
+(NSDate *)endDateOfCurrentWeek;
+(NSDate *)startDateOfLastWeek;
-(NSDateStorage *)dateOfMonth:(NSInteger)month;
@end
