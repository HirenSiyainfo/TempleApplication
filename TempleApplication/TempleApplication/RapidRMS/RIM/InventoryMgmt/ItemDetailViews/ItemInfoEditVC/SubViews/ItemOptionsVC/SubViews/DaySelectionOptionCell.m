//
//  DaySelectionOptionCell.m
//  RapidRMS
//
//  Created by Siya9 on 23/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "DaySelectionOptionCell.h"
#import "MMDDayTimeSelectionVC.h"

@implementation DaySelectionOptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(IBAction)btnweekDaySelectTapped:(UIButton *)sender {
    WeekDay isWeekdaySelected = (WeekDay)sender.tag;
    if (isDaySelected(self.intValidDays, isWeekdaySelected)) {
        clearOnDay(self.intValidDays, isWeekdaySelected);
    }
    else {
        applyOnDay(self.intValidDays, isWeekdaySelected);
    }
    [self resetDaySelectionButtons];
    self.daySelectionChanged(self.intValidDays);
}

-(IBAction)btnweekMultipleDaysTapped:(UIButton *)sender {
    self.intValidDays = (int)sender.tag;
    [self resetDaySelectionButtons];
    self.daySelectionChanged(self.intValidDays);
}
-(IBAction)btnweekDayClearTapped:(UIButton *)sender {
    self.intValidDays = 0;
    [self resetDaySelectionButtons];
    self.daySelectionChanged(self.intValidDays);
}
-(void)resetDaySelectionButtons{
    NSArray * arrAllDay =@[@(WeekDaySun),@(WeekDayMon),@(WeekDayTue),@(WeekDayWed),@(WeekDayThu),@(WeekDayFri),@(WeekDaySat)];
    for (NSNumber * numDay in arrAllDay) {
        WeekDay isWeekdaySelected = (WeekDay)numDay.intValue;
        UIButton * btnDay = [self viewWithTag:isWeekdaySelected];
        btnDay.selected = isDaySelected(self.intValidDays, isWeekdaySelected);
    }
    UIButton * btnAllDay = (UIButton *)[self viewWithTag:127];
    UIButton * btnWeekDay = (UIButton *)[self viewWithTag:30];
    UIButton * btnWeekendDay = (UIButton *)[self viewWithTag:97];
    btnAllDay.selected = FALSE;
    btnWeekDay.selected = FALSE;
    btnWeekendDay.selected = FALSE;
    switch (self.intValidDays) {
        case 127:
            btnAllDay.selected = TRUE;
            break;
        case 97:
            btnWeekendDay.selected = TRUE;
            break;
        case 30:
            btnWeekDay.selected = TRUE;
            break;
    }
}
@end
