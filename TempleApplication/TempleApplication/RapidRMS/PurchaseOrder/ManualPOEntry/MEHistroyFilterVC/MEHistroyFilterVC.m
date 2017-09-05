//
//  MEHistroyFilterVC.m
//  RapidRMS
//
//  Created by Siya10 on 04/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MEHistroyFilterVC.h"

typedef NS_ENUM(NSInteger, ME_DatePicker) {
    ME_FromDatePicker,
    ME_ToDatePicker,
};

@interface MEHistroyFilterVC ()


@property(nonatomic, weak)IBOutlet UILabel *lblFrom;
@property(nonatomic, weak)IBOutlet UILabel *lblTo;
@property(nonatomic, weak)IBOutlet UILabel *fromLabel;
@property(nonatomic, weak)IBOutlet UILabel *toLabel;

@property(nonatomic, weak)IBOutlet UIDatePicker *fromDatePicker;
@property(nonatomic, assign)NSInteger selectedDatePickerFormat;


@end

@implementation MEHistroyFilterVC
@synthesize meFilterDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.selectedDatePickerFormat = ME_FromDatePicker;
    self.lblFrom.textColor = [UIColor colorWithRed:251.0/255.0 green:143.0/255.0 blue:14.0/255.0 alpha:1.0];
    self.lblTo.textColor = [UIColor whiteColor];
    
    self.fromLabel.textColor = [UIColor colorWithRed:251.0/255.0 green:143.0/255.0 blue:14.0/255.0 alpha:1.0];
    self.toLabel.textColor = [UIColor whiteColor];

    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    self.lblFrom.text = [dateFormatter stringFromDate:self.fromdate];
    self.lblTo.text = [dateFormatter stringFromDate:self.todate];
    [_fromDatePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    SEL selector = NSSelectorFromString(@"setHighlightsToday:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDatePicker instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    [invocation setArgument:&no atIndex:2];
    [invocation invokeWithTarget:self.fromDatePicker];
}

-(IBAction)datePickerValueChanged:(id)sender
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSDate *datePickerSelectedDate = self.fromDatePicker.date;
    
    if (self.selectedDatePickerFormat == ME_FromDatePicker) {
        self.fromdate = self.fromDatePicker.date;
        self.lblFrom.text = [dateFormatter stringFromDate:datePickerSelectedDate];
            }
    
    if (self.selectedDatePickerFormat == ME_ToDatePicker) {
        self.todate = self.fromDatePicker.date;
        self.lblTo.text = [dateFormatter stringFromDate:datePickerSelectedDate];
            }
}

-(IBAction)displayDatePicker:(UIButton *)sender
{
   // self.fromDatePicker.hidden = NO;
    if (sender.tag == 1) {
        self.selectedDatePickerFormat = ME_FromDatePicker;
        self.lblFrom.textColor = [UIColor colorWithRed:251.0/255.0 green:143.0/255.0 blue:14.0/255.0 alpha:1.0];
        self.lblTo.textColor = [UIColor whiteColor];
        self.fromLabel.textColor = [UIColor colorWithRed:251.0/255.0 green:143.0/255.0 blue:14.0/255.0 alpha:1.0];
        self.toLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        self.selectedDatePickerFormat = ME_ToDatePicker;
        self.lblTo.textColor = [UIColor colorWithRed:251.0/255.0 green:143.0/255.0 blue:14.0/255.0 alpha:1.0];
        self.lblFrom.textColor = [UIColor whiteColor];
        self.toLabel.textColor = [UIColor colorWithRed:251.0/255.0 green:143.0/255.0 blue:14.0/255.0 alpha:1.0];
        self.fromLabel.textColor = [UIColor whiteColor];
    }
}

-(IBAction)submitButton:(id)sender
{
    
    if ([self.fromdate compare:self.todate] == NSOrderedAscending)
    {
        [self.meFilterDelegate didSubmitewithDate:self.fromdate toDate:self.todate];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Info" message:@"Please provide valid Date range." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
