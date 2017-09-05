//
//  MMDDateTimePickerVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 27/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CLIOTimePickerVC.h"
#import "RmsDbController.h"

@interface CLIOTimePickerVC () {
    NSString *strClockInDate;
    NSString *strClockOutDate;
}

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;

@property (nonatomic, weak) IBOutlet UILabel *lblClockInTime;
@property (nonatomic, weak) IBOutlet UILabel *lblClockOutTime;

@property (nonatomic, weak) IBOutlet UIButton *btnClockInTime;
@property (nonatomic, weak) IBOutlet UIButton *btnClockOutTime;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation CLIOTimePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [self initialSetup];
    [self clockInTimeClicked:nil];
    [super viewDidAppear:animated];
}

- (void)initialSetup {
    strClockInDate = [NSString stringWithFormat:@"%@ %@",_clockInOutTimeDictionary [@"Date"],_clockInOutTimeDictionary [@"ClockInTime"]];
    strClockOutDate = [NSString stringWithFormat:@"%@ %@",_clockInOutTimeDictionary [@"Date"],_clockInOutTimeDictionary [@"ClockOutTime"]];
    _lblClockInTime.text = [NSString stringWithFormat:@"%@",_clockInOutTimeDictionary [@"ClockInTime"]];
    _lblClockOutTime.text = [NSString stringWithFormat:@"%@",_clockInOutTimeDictionary [@"ClockOutTime"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString *)getStringFromDate:(NSDate *)date formate:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *strDate = [formatter stringFromDate:date];
    return strDate;
}

- (NSDate *)getDateFromString:(NSString *)stringDate formate:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:stringDate];
    return date;
}

#pragma mark - IBAction -

-(IBAction)dateChanged:(id)sender {
    if (_btnClockInTime.selected) {
        strClockInDate = [NSString stringWithFormat:@"%@",[self getStringFromDate:_datePicker.date formate:@"MMMM dd, yyyy hh:mm a"]];
        _lblClockInTime.text = [NSString stringWithFormat:@"%@",[self getStringFromDate:_datePicker.date formate:@"hh:mm a"]];
    }
    else {
        strClockOutDate = [NSString stringWithFormat:@"%@",[self getStringFromDate:_datePicker.date formate:@"MMMM dd, yyyy hh:mm a"]];
        _lblClockOutTime.text = [NSString stringWithFormat:@"%@",[self getStringFromDate:_datePicker.date formate:@"hh:mm a"]];
    }
}

-(IBAction)clockInTimeClicked:(id)sender {
    [self setSelected:_btnClockInTime];
    _datePicker.date = [self getDateFromString:strClockInDate formate:@"MMMM dd, yyyy hh:mm a"];
    NSString *clockInDate = [self getStringFromDate:[self getDateFromString:strClockInDate formate:@"MMMM dd, yyyy hh:mm a"] formate:@"MMMM dd, yyyy"];
    if (!self.isNewEntry) {
        _datePicker.minimumDate = [self getDateFromString:[NSString stringWithFormat:@"%@ %@",clockInDate,@"12:00 AM"] formate:@"MMMM dd, yyyy hh:mm a"];
        _datePicker.maximumDate = [self getDateFromString:strClockOutDate formate:@"MMMM dd, yyyy hh:mm a"];
    }
}

-(IBAction)clockOutTimeClicked:(id)sender {
    [self setSelected:_btnClockOutTime];
    _datePicker.date = [self getDateFromString:strClockOutDate formate:@"MMMM dd, yyyy hh:mm a"];
    NSString *clockOutDate = [self getStringFromDate:[self getDateFromString:strClockOutDate formate:@"MMMM dd, yyyy hh:mm a"] formate:@"MMMM dd, yyyy"];
    if (!self.isNewEntry) {
        _datePicker.minimumDate = [self getDateFromString:strClockInDate formate:@"MMMM dd, yyyy hh:mm a"];
        _datePicker.maximumDate = [self getDateFromString:[NSString stringWithFormat:@"%@ %@",clockOutDate,@"11:59 PM"] formate:@"MMMM dd, yyyy hh:mm a"];
    }
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:_datePicker.date];
    if (today) {
        _datePicker.maximumDate = [NSDate date];
    }
}

- (void)setSelected:(UIButton *)button {
    _btnClockInTime.selected = NO;
    _btnClockOutTime.selected = NO;
    button.selected = YES;
}

- (BOOL)timeDoseNotChanged {
    BOOL timeDoseNotChanged = false;
    NSString *clockInTime = [NSString stringWithFormat:@"%@",[self getStringFromDate:[self getDateFromString:strClockInDate formate:@"MMMM dd, yyyy hh:mm a"] formate:@"hh:mm a"]];
    NSString *clockOutTime = [NSString stringWithFormat:@"%@",[self getStringFromDate:[self getDateFromString:strClockOutDate formate:@"MMMM dd, yyyy hh:mm a"] formate:@"hh:mm a"]];
    
    if (!self.isNewEntry && ([clockInTime isEqualToString:_clockInOutTimeDictionary [@"ClockInTime"]] && [clockOutTime isEqualToString:_clockInOutTimeDictionary [@"ClockOutTime"]])) {
        timeDoseNotChanged = true;
    }
    return timeDoseNotChanged;
}

- (NSInteger)minutesBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:dt1 toDate:dt2 options:0];
    return [components minute];
}

- (BOOL)timeDifferenceGreaterThanTwentyFourHours {
    BOOL timeDifferenceGreaterThanTwentyFourHours = false;
    NSInteger minutes = [self minutesBeetweenDate];
    NSInteger hours = minutes / 60;
    if (((hours == 24) && (minutes % 60)>0) || (hours > 24)) {
        timeDifferenceGreaterThanTwentyFourHours = true;
    }
    return timeDifferenceGreaterThanTwentyFourHours;
}

- (NSInteger)minutesBeetweenDate {
    NSInteger minutes = [self minutesBetween:[self getDateFromString:strClockInDate formate:@"MMMM dd, yyyy hh:mm a"] and:[self getDateFromString:strClockOutDate formate:@"MMMM dd, yyyy hh:mm a"]];
    return minutes;
}

- (BOOL)isTimeDifferenceInMinus {
    BOOL isTimeDifferenceInMinus = false;
    NSInteger minutes = [self minutesBeetweenDate];
    if (minutes<0) {
        isTimeDifferenceInMinus = true;
    }
    return isTimeDifferenceInMinus;
}

- (BOOL)isSameDateAndTimeSelected {
    BOOL isSameDateAndTimeSelected = false;
    if ([strClockInDate isEqualToString:strClockOutDate]) {
        isSameDateAndTimeSelected = true;
    }
    return isSameDateAndTimeSelected;
}

-(IBAction)doneTapped:(id)sender {
    if ([self timeDoseNotChanged]) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please change clock-in/out time." buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
        return;
    }
    if ([self timeDifferenceGreaterThanTwentyFourHours]) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Clock-in/out time is difference greater than 24 hours.Please change clock-in/out time." buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
        return;
    }
    if ([self isTimeDifferenceInMinus]) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select valid clock-in/out time." buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
        return;
    }
    if ([self isSameDateAndTimeSelected]) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select different clock-in/out time." buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
        return;
    }
    [self.cLIOTimePickerVCDelegate didUpdateClockInOutTime:@{@"ClockInTime":strClockInDate,@"ClockOutTime":strClockOutDate}];
}

-(IBAction)closeTapped:(id)sender {
    [self.cLIOTimePickerVCDelegate didCancelUpdateClockInOutTime];
}
@end
