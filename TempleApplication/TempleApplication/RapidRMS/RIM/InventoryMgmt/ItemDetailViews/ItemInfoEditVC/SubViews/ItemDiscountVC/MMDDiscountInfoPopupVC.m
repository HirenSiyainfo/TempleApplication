//
//  MMDDiscountInfoPopupVC.m
//  RapidRMS
//
//  Created by Siya9 on 21/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDDiscountInfoPopupVC.h"
#import "MMDDayTimeSelectionVC.h"

@interface MMDDiscountInfoPopupVC ()<UIPopoverPresentationControllerDelegate>


@property (nonatomic, weak) IBOutlet UILabel * lblDiscountname;
@property (nonatomic, weak) IBOutlet UILabel * lblDiscountDetail;
@property (nonatomic, weak) IBOutlet UILabel * lblDiscountType;
@property (nonatomic, weak) IBOutlet UILabel * lblDiscountDate;
@property (nonatomic, weak) IBOutlet UILabel * lblDiscountDays;
@property (nonatomic, weak) IBOutlet UILabel * lblDiscountTime;
@end

@implementation MMDDiscountInfoPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.lblDiscountname.text = [self getStringFromKey:@"name"];
    self.lblDiscountDetail.text = [self getStringFromKey:@"descriptionText"];
    
    self.lblDiscountType.text = @"Buy X Get Y";
    if ([self.dictMMDInfo[@"discountType"] intValue] == 1) {
        self.lblDiscountType.text = @"Quantity Discount";
    }
    [self setStartDateEndDate];
    [self setDaysNameInLabel];
    [self setStartTimeEndTime];
}
-(void)setStartDateEndDate{
    NSDate * startDate,* endDate;
    startDate = self.dictMMDInfo[@"startDate" ];
    endDate = self.dictMMDInfo[@"endDate" ];
    NSMutableAttributedString * strADate;
    if (endDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd/MM/yyyy";
        NSString * strStartDate = [formatter stringFromDate:startDate];
        NSString * strEndDate = [formatter stringFromDate:endDate];
        NSString * strMurgeDate;
        if (IsPhone()) {
            strMurgeDate = [NSString stringWithFormat:@"Start Date%@\nEnd Date  %@",strStartDate,strEndDate];
        }
        else{
            strMurgeDate = [NSString stringWithFormat:@"Start Date %@  End Date  %@",strStartDate,strEndDate];
        }
        strADate = [[NSMutableAttributedString alloc]initWithString:strMurgeDate];
        [strADate addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[strMurgeDate rangeOfString:@"Start Date"]];
        [strADate addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[strMurgeDate rangeOfString:@"End Date  "]];
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd/MM/yyyy";
        NSString * strStartDate = [formatter stringFromDate:startDate];
        NSString * strMurgeDate;
        if (IsPhone()) {
            strMurgeDate = [NSString stringWithFormat:@"Start Date %@\nNever Expires",strStartDate];
        }
        else {
            strMurgeDate = [NSString stringWithFormat:@"Start Date %@  Never Expires",strStartDate];
        }
        strADate = [[NSMutableAttributedString alloc]initWithString:strMurgeDate];
        [strADate addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[strMurgeDate rangeOfString:@"Start Date"]];
        [strADate addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[strMurgeDate rangeOfString:@"Never Expires"]];
    }
    self.lblDiscountDate.attributedText = strADate;
}
-(void)setDaysNameInLabel{
    NSMutableArray * arrDaysToDisplay = [NSMutableArray array];
    int validDays = [self.dictMMDInfo[@"validDays"] intValue];
    switch (validDays) {
        case 127:
            [arrDaysToDisplay addObject:@"All Days"];
            break;
        case 97:
            [arrDaysToDisplay addObject:@"Weekends"];
            break;
        case 30:
            [arrDaysToDisplay addObject:@"Weekdays"];
            break;
        default:{
            
            NSArray * arrAllDay =@[@(WeekDaySun),@(WeekDayMon),@(WeekDayTue),@(WeekDayWed),@(WeekDayThu),@(WeekDayFri),@(WeekDaySat)];
            NSArray * arrDays = @[@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday"];
            for (int i = 0; i< arrAllDay.count; i++ ) {
                if (isDaySelected(validDays, [arrAllDay[i] intValue])) {
                    [arrDaysToDisplay addObject:arrDays[i]];
                }
            }
            break;
        }
    }
    self.lblDiscountDays.text = [arrDaysToDisplay componentsJoinedByString:@", "];
}
-(void)setStartTimeEndTime{
    NSDate * startTime,* endTime;
    
    startTime = self.dictMMDInfo[@"startTime" ];
    endTime = self.dictMMDInfo[@"endTime" ];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    timeFormatter.dateFormat = @"hh:mm a";
    
    
    NSDateFormatter *timeFormatter1 = [[NSDateFormatter alloc] init];
    [timeFormatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [timeFormatter1 setDateFormat:@"HH:mm:ss"];

    NSString * strMurgeTime;
    if ([endTime isEqual:[timeFormatter1 dateFromString:@"23:59:59"]])
    {
        strMurgeTime = [NSString stringWithFormat:@"%@  To  %@",[timeFormatter stringFromDate:startTime] ,@"12:00 AM"];
    }
    else
    {
        strMurgeTime = [NSString stringWithFormat:@"%@  To  %@",[timeFormatter stringFromDate:startTime] ,[timeFormatter stringFromDate:endTime]];
    }
    NSMutableAttributedString * strATime = [[NSMutableAttributedString alloc]initWithString:strMurgeTime];
    [strATime addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[strMurgeTime rangeOfString:@"  To  "]];
    self.lblDiscountTime.attributedText = strATime;
}

-(NSString *)getStringFromKey:(NSString *)strKey{
    NSString * strValue = self.dictMMDInfo[strKey];
    if (strValue && strValue.length > 0) {
        return strValue;
    }
    else{
        return @"----";
    }
}

-(IBAction)btnClosePopup:(UIButton *)sender {
    [self popoverPresentationControllerShouldDismissPopover];
}

-(IBAction)btnRemoveItemFromDiscount:(UIButton *)sender {
    [self popoverPresentationControllerShouldDismissPopover];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.removeDiscountAt(self.index);
    });
}
//
//-(void)presentViewControllerForviewConteroller:(UIViewController *) objView sourceView:(UIView *)sourceView ArrowDirection:(UIPopoverArrowDirection)arrowDirection {
//    
//    self.modalPresentationStyle = UIModalPresentationPopover;
//    
//    CGRect frame = self.view.frame;
//    self.preferredContentSize = frame.size;
//    [objView presentViewController:self animated:YES completion:nil];
//    
//    UIPopoverPresentationController * popup =self.popoverPresentationController;
//    popup.delegate = self;
//    popup.backgroundColor = [UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000];
//    popup.permittedArrowDirections = arrowDirection;
//    popup.sourceView = sourceView;
//    popup.sourceRect = sourceView.bounds;
//}
@end
