//
//  globalCalendarVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 17/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "CKOCalendarViewController.h"
#import "CKOCalendarView.h"

@interface CKOCalendarViewController () <CKOCalendarDelegate>

@property(nonatomic, weak) CKOCalendarView *calendar;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;
@property(nonatomic, strong) NSArray *disabledDates;

@end

@implementation CKOCalendarViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        CKOCalendarView *calendar = [[CKOCalendarView alloc] initWithStartDay:startMonday];
        self.calendar = calendar;
        calendar.delegate = self;
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"dd/MM/yyyy";
        self.minimumDate = [self.dateFormatter dateFromString:@"01/01/2013"];
        
//        self.disabledDates = @[
//                               [self.dateFormatter dateFromString:@"05/01/2013"],
//                               [self.dateFormatter dateFromString:@"06/01/2013"],
//                               [self.dateFormatter dateFromString:@"07/01/2013"]
//                               ];
        
        calendar.onlyShowCurrentMonth = NO;
        calendar.adaptHeightToNumberOfWeeksInMonth = YES;
        
        calendar.frame = CGRectMake(0, 0, 250, 275);
        self.view.frame = CGRectMake(0, 0, 250, 241);
        [self.view addSubview:calendar];
        
        //self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(calendar.frame) + 4, self.view.bounds.size.width, 24)];
//        [self.view addSubview:self.dateLabel];
        
        self.view.backgroundColor = [UIColor clearColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange) name:NSCurrentLocaleDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)locationDidChange {
    self.calendar.locale = [NSLocale currentLocale];
}

- (BOOL)dateIsDisabled:(NSDate *)date {
    for (NSDate *disabledDate in self.disabledDates) {
        if ([disabledDate isEqualToDate:date]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark - CKCalendarDelegate

- (void)calendar:(CKOCalendarView *)calendar configureDateItem:(CKODateItem *)dateItem forDate:(NSDate *)date {
    // TODO: play with the coloring if we want to...
    if ([self dateIsDisabled:date]) {
        dateItem.backgroundColor = [UIColor redColor];
        dateItem.textColor = [UIColor whiteColor];
    }
}

- (BOOL)calendar:(CKOCalendarView *)calendar willSelectDate:(NSDate *)date {
    return ![self dateIsDisabled:date];
}

- (void)calendar:(CKOCalendarView *)calendar didSelectDate:(NSDate *)date {
    self.dateLabel.text = [self.dateFormatter stringFromDate:date];
}

- (BOOL)calendar:(CKOCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    if ([date laterDate:self.minimumDate] == date) {
        self.calendar.backgroundColor = [UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000];
        return YES;
    } else {
        self.calendar.backgroundColor = [UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000];
        return NO;
    }
}

- (void)calendar:(CKOCalendarView *)calendar didLayoutInRect:(CGRect)frame {
    if (self.calendarPopover) {
        [self.calendarPopover setPopoverContentSize:CGSizeMake(frame.size.width, frame.size.height) animated:NO];
        self.calendarPopover.backgroundColor = [UIColor clearColor];

    }
    else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.preferredContentSize = CGSizeMake(frame.size.width, frame.size.height);
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end