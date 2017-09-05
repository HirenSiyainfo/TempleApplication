//
//  MMDDayTimeSelectionVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 25/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDDayTimeSelectionVC.h"
#import "MMDOfferListVC.h"
#import "MMDDetailInfoVC.h"
#import "MMDiscountListVC.h"
#import "MMDDateTimePickerVC.h"
#import "RmsDbController.h"

#ifdef __IPHONE_8_0
#define GregorianCalendar NSCalendarIdentifierGregorian
#else
#define GregorianCalendar NSGregorianCalendar
#endif

@interface MMDDayTimeSelectionVC () <MMDDateTimePickerVCDelegate>{
    
    int intValidDays;
    
    MMDOfferListVC * mMDOfferListVC;
    MMDDateTimePickerVC * mMDDateTimePickerVC;
    UIView * viewPopupView;
}
@property (nonatomic, weak) IBOutlet UIView * viewOfferDetail;
@property (nonatomic, weak) IBOutlet UIButton * btnNoExpires;
@property (nonatomic, weak) IBOutlet UIButton * btnEndDate;
@property (nonatomic, weak) IBOutlet UITextField * txtStartDate;
@property (nonatomic, weak) IBOutlet UITextField * txtEndDate;
@property (nonatomic, weak) IBOutlet UITextField * txtStartTime;
@property (nonatomic, weak) IBOutlet UITextField * txtEndTime;
@end

@implementation MMDDayTimeSelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    intValidDays = 0;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [formatter setDateFormat:@"hh:mm a"];
    
    if (!self.objMixMatch.startTime) {
        self.objMixMatch.startTime = [formatter dateFromString:@"12:00 AM"];
    }
    if (!self.objMixMatch.endTime) {
        [formatter setDateFormat:@"HH:mm:ss"];
        self.objMixMatch.endTime = [formatter dateFromString:@"23:59:59"];
    }
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadValueToView];
    if (!mMDOfferListVC) {
        mMDOfferListVC = [[UIStoryboard storyboardWithName:@"MMDiscount"
                                                    bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDOfferListVC_sid"];
        mMDOfferListVC.view.frame = _viewOfferDetail.bounds;
        [self addChildViewController:mMDOfferListVC];
        [_viewOfferDetail addSubview:mMDOfferListVC.view];
    }
}

-(void)loadValueToView {
    intValidDays = self.objMixMatch.validDays.intValue;
    [self resetDaySelectionButtons];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"MM/dd/yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    _txtStartDate.text = @"MM/DD/YYYY";

    if (self.objMixMatch.startDate) {
        _txtStartDate.text = [formatter stringFromDate:self.objMixMatch.startDate];
    }
    
    _btnNoExpires.selected = TRUE;
    _txtEndDate.text = @"MM/DD/YYYY";

    if (self.objMixMatch.endDate) {
        _txtEndDate.text = [formatter stringFromDate:self.objMixMatch.endDate];
        _btnEndDate.selected = TRUE;
        _btnNoExpires.selected = FALSE;
    }

    [formatter setDateFormat:@"hh:mm a"];
    _txtStartTime.text = @"HH:MM";
    _txtEndTime.text = @"HH:MM";
    
    if (self.objMixMatch.startTime) {
        _txtStartTime.text = [formatter stringFromDate:self.objMixMatch.startTime];
    }
    
    [formatter setDateFormat:@"HH:mm:ss"];
    if ([self.objMixMatch.endTime isEqual:[formatter dateFromString:@"23:59:59"]])
    {
        [formatter setDateFormat:@"hh:mm a"];
        _txtEndTime.text = [formatter stringFromDate:[formatter dateFromString:@"12:00 AM"]];
    }
    else
    {
        [formatter setDateFormat:@"hh:mm a"];
        _txtEndTime.text = [formatter stringFromDate:self.objMixMatch.endTime];
    }
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{        // return NO to disallow editing.
    NSString * strTitle;
    UIDatePickerMode pickerMode = UIDatePickerModeTime;
    NSDate * selDate,* minDate, * maxDate;

    if (textField.tag == 101) {
        strTitle = @"Start Date";
        pickerMode = UIDatePickerModeDate;
        minDate = [self getCurrentDateAsUTC];
        selDate = self.objMixMatch.startDate;
        maxDate = self.objMixMatch.endDate;
    }
    else if (textField.tag == 102) {
        strTitle = @"End Date";
        pickerMode = UIDatePickerModeDate;
        selDate = self.objMixMatch.endDate;
        if (self.objMixMatch.startDate) {
            minDate = self.objMixMatch.startDate;
        }
        else {
            minDate = [self getCurrentDateAsUTC];
        }

    }
    else if (textField.tag == 201) {
        strTitle = @"Start Time";
        pickerMode = UIDatePickerModeTime;
        
 //       NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     //   [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
     //   [formatter setDateFormat:@"HH:mm:ss"];
     //   minDate = [formatter dateFromString:@"09:00:00"];
        selDate = [NSDate date];
        if (self.objMixMatch.startTime) {
            selDate = self.objMixMatch.startTime;
        }
        if (self.objMixMatch.endTime) {
            maxDate = self.objMixMatch.endTime;
        }
        else {
         //   maxDate = [formatter dateFromString:@"22:00:00"];
        }
        
    }
    else if (textField.tag == 202) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [formatter setDateFormat:@"HH:mm:ss"];
        //   minDate = [formatter dateFromString:@"09:00:00"];
        strTitle = @"End Time";
        pickerMode = UIDatePickerModeTime;
        
        selDate = [NSDate date];
        NSDate * dateLastTime = [formatter dateFromString:@"23:59:59"];
        if ([self.objMixMatch.endTime isEqual:dateLastTime]) {
            selDate = [formatter dateFromString:@"00:00:00"];
            if (self.objMixMatch.startTime) {
                minDate = self.objMixMatch.startTime;
            }
        }
        else{
            if (self.objMixMatch.endTime) {
                selDate = self.objMixMatch.endTime;
            }
            
            if (self.objMixMatch.startTime) {
                minDate = self.objMixMatch.startTime;
            }
        }
    }
    [self showDateTimePickerInputView:textField PickerType:pickerMode PickerTitle:strTitle selectedDate:selDate minDate:minDate maxDate:maxDate];
    return NO;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - IBActions -

-(IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)btnCloseMMD:(id)sender {
    NSArray * arrViewC = self.navigationController.viewControllers;
    for (UIViewController *vc in arrViewC) {
        if ([vc isKindOfClass:[MMDiscountListVC class]]) {
            [self.navigationController popToViewController:vc animated:TRUE];
            return;
        }
    }
}
-(IBAction)btnSaveOrNext:(id)sender {
    self.objMixMatch.validDays = @(intValidDays);

    if (self.objMixMatch.startDate == nil) {
        [self showMessageWithTitle:nil withMessage:@"Please enter start date"];
    }
    else if (self.objMixMatch.endDate == nil && _btnEndDate.selected) {
        [self showMessageWithTitle:nil withMessage:@"Please enter end date"];
    }
    else if (self.objMixMatch.validDays.intValue == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please select validity of days"];
    }
    else if (self.objMixMatch.startTime == nil) {
        [self showMessageWithTitle:nil withMessage:@"Please enter start time"];
    }
    else if (self.objMixMatch.endTime == nil) {
        [self showMessageWithTitle:nil withMessage:@"Please enter end time"];
    }
    else {
        MMDDetailInfoVC * mMDDetailInfoVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDDetailInfoVC_sid"];
        mMDDetailInfoVC.moc = self.moc;
        mMDDetailInfoVC.objMixMatch = self.objMixMatch;
        
        [self.navigationController pushViewController:mMDDetailInfoVC animated:YES];
    }
}
-(void)showMessageWithTitle:(NSString *)strTitle withMessage:(NSString *) strMessage{
    if (!strTitle) {
        strTitle = @"Discount";
    }
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
    };
    [[RmsDbController sharedRmsDbController] popupAlertFromVC:self title:strTitle message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    
}

#pragma mark - IBActions -

-(IBAction)changeStartDateEndDate:(UIButton *)sender {
    [self.view endEditing:YES];
    _btnNoExpires.selected = FALSE;
    _btnEndDate.selected = FALSE;
    if ([sender isEqual:_btnNoExpires]) {
        [self setDateInView:nil withInputView:_txtEndDate];
        _btnNoExpires.selected = TRUE;
    }
    else {
        [self showDateTimePickerInputView:_txtEndDate PickerType:UIDatePickerModeDate PickerTitle:@"End Date" selectedDate:self.objMixMatch.endDate minDate:self.objMixMatch.startDate maxDate:nil];
        _btnEndDate.selected = TRUE;
    }
}
-(IBAction)btnweekDaySelectTapped:(UIButton *)sender {
    WeekDay isWeekdaySelected = (WeekDay)sender.tag;
    if (isDaySelected(intValidDays, isWeekdaySelected)) {
        clearOnDay(intValidDays, isWeekdaySelected);
    }
    else {
        applyOnDay(intValidDays, isWeekdaySelected);
    }
    self.objMixMatch.validDays = @(intValidDays);
    [self resetDaySelectionButtons];
}
-(IBAction)btnweekMultipleDaysTapped:(UIButton *)sender {
    
    intValidDays = (int)sender.tag;
    self.objMixMatch.validDays = @(intValidDays);
    [self resetDaySelectionButtons];
}
-(IBAction)btnweekDayClearTapped:(UIButton *)sender {
    
    intValidDays = 0;
    self.objMixMatch.validDays = @(intValidDays);
    [self resetDaySelectionButtons];
}
-(void)resetDaySelectionButtons{
    NSArray * arrAllDay =@[@(WeekDaySun),@(WeekDayMon),@(WeekDayTue),@(WeekDayWed),@(WeekDayThu),@(WeekDayFri),@(WeekDaySat)];
    for (NSNumber * numDay in arrAllDay) {
        WeekDay isWeekdaySelected = (WeekDay)numDay.intValue;
        UIButton * btnDay = [self.view viewWithTag:isWeekdaySelected];
        btnDay.selected = isDaySelected(intValidDays, isWeekdaySelected);
    }
    UIButton * btnAllDay = (UIButton *)[self.view viewWithTag:127];
    UIButton * btnWeekDay = (UIButton *)[self.view viewWithTag:30];
    UIButton * btnWeekendDay = (UIButton *)[self.view viewWithTag:97];
    btnAllDay.selected = FALSE;
    btnWeekDay.selected = FALSE;
    btnWeekendDay.selected = FALSE;
    switch (intValidDays) {
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
    NSLog(@"%d",intValidDays);
}

#pragma mark - date picker delegate-

-(void)showDateTimePickerInputView:(id)inputView PickerType:(UIDatePickerMode)pickerMode PickerTitle:(NSString *) strPickerTitle selectedDate:(NSDate *)selDate minDate:(NSDate *)minDate maxDate:(NSDate *)maxDate{
    
    mMDDateTimePickerVC = [[MMDDateTimePickerVC alloc] initWithNibName:@"MMDDateTimePickerVC" bundle:nil];
    viewPopupView = [[UIView alloc]initWithFrame:self.view.bounds];
    viewPopupView.backgroundColor =[UIColor colorWithWhite:0.000 alpha:0.500];
    mMDDateTimePickerVC.view.center = viewPopupView.center;
    [viewPopupView addSubview:mMDDateTimePickerVC.view];
    [self addChildViewController:mMDDateTimePickerVC];
    [self.view addSubview:viewPopupView];
    mMDDateTimePickerVC.view.layer.cornerRadius = 8.0f;
    mMDDateTimePickerVC.Delegate = self;
    mMDDateTimePickerVC.inputView = inputView;
    mMDDateTimePickerVC.strTitle = strPickerTitle;
    mMDDateTimePickerVC.datePicker.datePickerMode = pickerMode;
    [mMDDateTimePickerVC.datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];

    if (selDate) {
        mMDDateTimePickerVC.datePicker.date = selDate;
    }
    mMDDateTimePickerVC.datePicker.minimumDate = minDate;
    mMDDateTimePickerVC.datePicker.maximumDate = maxDate;
}

-(void)didEnterNewDate:(NSDate *)date withInputView:(id) inputView {
    UITextField * txtInputView = (UITextField *)inputView;
    [self setDateInView:date withInputView:txtInputView];

    [self didCancelEditItemPopOver];
}
-(void)setDateInView:(NSDate *)selDate withInputView:(UITextField *) inputView{
    switch (inputView.tag) {
        case 101: {
            self.objMixMatch.startDate = selDate;
            break;
        }
        case 102: {
            self.objMixMatch.endDate = selDate;
            break;
        }
        case 201: {
            self.objMixMatch.startTime = selDate;
            break;
        }
        case 202: {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [formatter setDateFormat:@"HH:mm:ss"];
            if ([selDate isEqual:[formatter dateFromString:@"00:00:00"]])
            {
                selDate = [formatter dateFromString:@"23:59:59"];
            }
            self.objMixMatch.endTime = selDate;
            break;
        }
        default:
            break;
    }
    [self loadValueToView];
}
-(NSDate *)getCurrentDateAsUTC {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *stringConverted = [formatter stringFromDate:[NSDate date]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return [formatter dateFromString:stringConverted];

}
-(void)didCancelEditItemPopOver {
    [UIView animateWithDuration:0.5 animations:^{
        viewPopupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        NSArray * arrView = viewPopupView.subviews;
        for (UIView * view in arrView) {
            [view removeFromSuperview];
        }
        [viewPopupView removeFromSuperview];
        [mMDDateTimePickerVC removeFromParentViewController];
        viewPopupView = nil;
    }];
}

@end
