//
//  DatePickerVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/24/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DatePickerVC.h"

@interface DatePickerVC ()
{
    }
@property (nonatomic , weak) IBOutlet UIDatePicker *datePicker;

@end

@implementation DatePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _datePicker.maximumDate = [NSDate date];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)selectDate:(id)sender
{
    _datePicker.maximumDate = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSString *stringDate = [dateFormatter stringFromDate:_datePicker.date];
    [self.datePickerDelegate didSelectDate:stringDate];
}

-(IBAction)cancelDate:(id)sender
{
    [self.datePickerDelegate didCancelDatePicker];
}

-(IBAction)clearDate:(id)sender
{
    [self.datePickerDelegate didClearDatePicker];
}


@end
