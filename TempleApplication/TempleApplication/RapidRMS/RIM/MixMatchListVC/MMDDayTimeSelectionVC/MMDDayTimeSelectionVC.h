//
//  MMDDayTimeSelectionVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 25/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Discount_M.h"
typedef NS_ENUM(NSUInteger, WeekDay)
{
    WeekDaySun = 1,
    WeekDayMon = 2,
    WeekDayTue = 4,
    WeekDayWed = 8,
    WeekDayThu = 16,
    WeekDayFri = 32,
    WeekDaySat = 64,
};
#define applyOnDay(X, d) (X |= d)
#define clearOnDay(X, d) (X &= (~d))
#define isDaySelected(X, d) ((X & d) == d)

@interface MMDDayTimeSelectionVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext * moc;
@property (nonatomic, strong) Discount_M * objMixMatch;
@end
