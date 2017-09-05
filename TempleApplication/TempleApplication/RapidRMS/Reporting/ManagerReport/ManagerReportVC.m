//
//  ManagerReportVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 13/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ManagerReportVC.h"
#import "RmsDbController.h"
#import "ManagerReportDetailsCell.h"
#import "MMDDateTimePickerVC.h"

#define CentralizeZZ_Tag 7005

typedef NS_ENUM(NSUInteger, ReportDetailsKey)
{
    ReportDetailsKeyDate = 0,
    ReportDetailsKeyRegisterName,
    ReportDetailsKeyBatchNo,
    ReportDetailsKeySalesAmt,
    ReportDetailsKeyTaxAmount,
    ReportDetailsKeyTotalSales,
};

@interface ManagerReportVC () <MMDDateTimePickerVCDelegate>
{
    ReportName _reportName;
    MMDDateTimePickerVC *mMDDateTimePickerVC;
    
    NSDate *managerReportDate;
    UIView *pickerBgView;
    NSArray *reportDetailsKeysArray;
}

@property (nonatomic, weak) IBOutlet UILabel *lblTotalAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblNumberOfRecords;

@property (nonatomic, weak) IBOutlet UITableView *tblMangerReportDetails;

@property (nonatomic, weak) IBOutlet UIButton *btnDate;

@property (nonatomic, weak) IBOutlet UIView *headerView;

@property (nonatomic, strong) NSMutableArray *mangerReportDetailsArray;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *mangerReportDetailsWC;

@end

@implementation ManagerReportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    managerReportDate = [NSDate date];
    // Do any additional setup after loading the view.
}

- (IBAction)managerTabOptionClicked:(UIButton *)sender {
    ManagerTabOption tabOptionButton = sender.tag;
    [self setSelected:tabOptionButton];
    [self.managerReportVCDelegate didSelectedMangerReportOption:tabOptionButton];
}

- (void)setSelected:(ManagerTabOption)tabOptionButton {
    for (UIButton *button in self.headerView.subviews) {
        if (button.tag == tabOptionButton) {
            button.selected = YES;
        }
        else
        {
            button.selected = NO;
        }
    }
}

- (void)needToShowAllTabOptions:(BOOL)needToShowAllTab {
    [self setSelected:ManagerTabOptionShiftHistory];
    if (needToShowAllTab) {
        [self hideManagerTabOption:ManagerTabOptionNone];
        [self.view viewWithTag:CentralizeZZ_Tag].hidden = YES;
    }
    else {
        [self showManagerTabOption:ManagerTabOptionShiftHistory];
    }
}

- (void)showManagerTabOption:(ManagerTabOption)tabOptionButton {
    for (UIButton *button in self.headerView.subviews) {
        if (button.tag == tabOptionButton) {
            button.hidden = NO;
            self.btnDate.hidden = NO;
        }
        else
        {
            button.hidden = YES;
        }
    }
}

- (void)hideManagerTabOption:(ManagerTabOption)tabOptionButton {
    for (UIButton *button in self.headerView.subviews) {
        if (button.tag == tabOptionButton) {
            button.hidden = YES;
        }
        else
        {
            button.hidden = NO;
        }
    }
}

#pragma mark - Date Picker

- (IBAction)selectManagerReportDate:(id)sender {
    //Open Date Picker
    mMDDateTimePickerVC = [[MMDDateTimePickerVC alloc] initWithNibName:@"MMDDateTimePickerVC" bundle:nil];
    pickerBgView = [[UIView alloc] initWithFrame:self.view.superview.bounds];
    pickerBgView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    mMDDateTimePickerVC.view.center = pickerBgView.center;
    [pickerBgView addSubview:mMDDateTimePickerVC.view];
    [self.view addSubview:pickerBgView];
    [self addChildViewController:mMDDateTimePickerVC];
    mMDDateTimePickerVC.view.layer.cornerRadius = 8.0f;
    mMDDateTimePickerVC.Delegate = self;
    mMDDateTimePickerVC.strTitle = @"Report Date";
    mMDDateTimePickerVC.datePicker.backgroundColor = [UIColor whiteColor];
    mMDDateTimePickerVC.datePicker.datePickerMode = UIDatePickerModeDate;
    if (managerReportDate) {
        mMDDateTimePickerVC.datePicker.date = managerReportDate;
    }
    mMDDateTimePickerVC.datePicker.maximumDate = [NSDate date];
}

-(void)didEnterNewDate:(NSDate *)date withInputView:(id) inputView {
    managerReportDate = date;
    switch (_reportName) {
        case ReportNameManagerZ:
            [self accessManagerReportsDetailsFor:date formatter:@"MM/yyyy" reportName:ReportNameManagerZ];
            break;
        case ReportNameManagerZZ:
            [self accessManagerReportsDetailsFor:date formatter:@"yyyy" reportName:ReportNameManagerZZ];
            break;
        case ReportNameShift:
            [self accessManagerReportsDetailsFor:date formatter:@"MM/yyyy" reportName:ReportNameShift];
            break;
        case ReportNameCentralizedZ:
            [self accessManagerReportsDetailsFor:date formatter:@"MM/yyyy" reportName:ReportNameCentralizedZ];
            break;
        default:
            break;
    }
}

-(void)didCancelEditItemPopOver {
    [self removePickerView];
}

- (void)removePickerView {
    [UIView animateWithDuration:0.5 animations:^{
        pickerBgView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        NSArray * arrView = pickerBgView.subviews;
        for (UIView * view in arrView) {
            [view removeFromSuperview];
        }
        [pickerBgView removeFromSuperview];
        pickerBgView = nil;
    }];
}

#pragma mark - Access Manager Reports

- (void)accessManagerReportsDetailsFor:(NSDate *)reportDate formatter:(NSString *)formatter reportName:(ReportName)reportName {
    _reportName = reportName;
    [self removePickerView];
    
    self.mangerReportDetailsArray = [[NSMutableArray alloc] init];
    NSString *strReportDate;
    NSString *serviceName;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    strReportDate = [self reportDate:reportDate formatter:formatter];
    [self.btnDate setTitle:[NSString stringWithFormat:@"DATE:%@",strReportDate] forState:UIControlStateNormal];

    switch (_reportName) {
        case ReportNameManagerZ:
            dict[@"ZDate"] = strReportDate;
            serviceName = WSM_Z_MANAGER_LIST_DATA;
            reportDetailsKeysArray = @[@"ZDate",@"RegisterName",@"BatchNo",@"SalesAmt",@"TaxAmount",@"TotalSales"];
            break;
            
        case ReportNameManagerZZ:
            dict[@"ZZDate"] = strReportDate;
            serviceName = WSM_ZZ_MANAGER_LIST_DATA;
            reportDetailsKeysArray = @[@"ZZDate",@"RegisterName",@"BatchNo",@"SalesAmt",@"TaxAmount",@"TotalSales"];
            break;

        case ReportNameShift:
        {
            dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
            NSDate *startDate = [self startOfMonthFromDate:reportDate];
            NSDate *endDate = [self endOfMonthFromDate:startDate];
            dict[@"StartDate"] = [NSString stringWithFormat:@"%@",[self stringFromDate:startDate]];
            dict[@"EndDate"] = [NSString stringWithFormat:@"%@",[self stringFromDate:endDate]];
            serviceName = WSM_SHIFT_HISTORY_LIST;
            reportDetailsKeysArray = @[@"ClsDate",@"RegisterName",@"BatchNo",@"Sales",@"Taxes",@"TotalSales"];
        }
            break;

        case ReportNameCentralizedZ:
        {
            NSDate *startDate = [self startOfMonthFromDate:reportDate];
            NSDate *endDate = [self endOfMonthFromDate:startDate];
            dict[@"FromDate"] = [NSString stringWithFormat:@"%@",[self stringFromDate:startDate]];
            dict[@"ToDate"] = [NSString stringWithFormat:@"%@",[self stringFromDate:endDate]];
            serviceName = WSM_Z_CENTRALIZE_LIST;
            reportDetailsKeysArray = @[@"ZClsDate",@"RegisterName",@"BatchNo",@"Sales",@"CollectTax",@"TotalSales"];
        }
            break;
            
        default:
            break;
    }
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self managerReportResponse:response error:error];
        });
    };
    
    self.mangerReportDetailsWC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:serviceName params:dict completionHandler:completionHandler];
}

- (void)managerReportResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.mangerReportDetailsArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                self.lblNumberOfRecords.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.mangerReportDetailsArray.count];
                [self.tblMangerReportDetails reloadData];
                if (self.mangerReportDetailsArray.count > 0) {
                    [self.managerReportVCDelegate accessMangerReport:_reportName usingDictionary:self.mangerReportDetailsArray.firstObject];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tblMangerReportDetails selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    self.lblTotalAmount.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:@([[self.mangerReportDetailsArray valueForKeyPath:@"@sum.TotalSales"] floatValue])]];
                }
                return;
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                if (_reportName == ReportNameShift) {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Shift Open | Close" message:@"No shift report found in history page" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                self.lblNumberOfRecords.text = @"0";
                self.lblTotalAmount.text = @"$0.00";
                [self.tblMangerReportDetails reloadData];
            }
        }
    }
    [self.managerReportVCDelegate accessMangerReport:_reportName usingDictionary:nil];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mangerReportDetailsArray == nil || self.mangerReportDetailsArray.count == 0) {
        return 1;
    }
    return self.mangerReportDetailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ManagerReportDefaultCell"];
    if ((self.mangerReportDetailsArray).count > 0 ) {
        ManagerReportDetailsCell *managerReportDetailsCell = (ManagerReportDetailsCell *)[tableView dequeueReusableCellWithIdentifier:@"ManagerReportDetailsCell"];
        managerReportDetailsCell.lblReportDate.text = [NSString stringWithFormat:@"%@",[self reportDateForIndexPath:indexPath]];
        NSString *strRegName = @"";
        if ((self.mangerReportDetailsArray)[indexPath.row][[self keyForIndex:ReportDetailsKeyRegisterName]]) {
            strRegName = [NSString stringWithFormat:@"%@",(self.mangerReportDetailsArray)[indexPath.row][[self keyForIndex:ReportDetailsKeyRegisterName]]];
            if([strRegName isEqualToString:@"<null>"])
            {
                strRegName = @"";
            }
        } else {
            strRegName = @"-";
        }
        managerReportDetailsCell.lblRegisterName.text = strRegName;
        NSString *batchNo = @"";
        if ([(self.mangerReportDetailsArray)[indexPath.row] valueForKey:[self keyForIndex:ReportDetailsKeyBatchNo]]) {
            batchNo = [NSString stringWithFormat:@"%@",[(self.mangerReportDetailsArray)[indexPath.row] valueForKey:[self keyForIndex:ReportDetailsKeyBatchNo]]];
        } else {
            batchNo = @"-";
        }
        managerReportDetailsCell.lblBatchNumber.text = batchNo;
        managerReportDetailsCell.lblSalesAmount.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:@([[(self.mangerReportDetailsArray) [indexPath.row] valueForKey:[self keyForIndex:ReportDetailsKeySalesAmt]] floatValue ])]];
        managerReportDetailsCell.lblTaxAmount.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:@([[(self.mangerReportDetailsArray) [indexPath.row] valueForKey:[self keyForIndex:ReportDetailsKeyTaxAmount]]floatValue ])]];
        managerReportDetailsCell.lblTotalSalesAmount.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:@([[(self.mangerReportDetailsArray) [indexPath.row] valueForKey:[self keyForIndex:ReportDetailsKeyTotalSales]]floatValue ])]];
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [UIColor whiteColor];
        managerReportDetailsCell.selectedBackgroundView = selectedView;
        cell = managerReportDetailsCell;
    }
    else {
        cell.textLabel.text = @"There is no data.";
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.managerReportVCDelegate accessMangerReport:_reportName usingDictionary:self.mangerReportDetailsArray[indexPath.row]];
}

#pragma mark - Utility

- (NSString *)keyForIndex:(ReportDetailsKey)index
{
    return reportDetailsKeysArray[index];
}

- (NSString *)reportDate:(NSDate *)date formatter:(NSString *)formatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatter;
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@", stringFromDate];
}

- (NSDate *)startOfMonthFromDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:date];
    NSDate *startOfMonth = [calendar dateFromComponents:currentDateComponents];
    return startOfMonth;
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *dateString = [format stringFromDate:date];
    return dateString;
}

- (NSDate *)endOfMonthFromDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentDateComponents = [[NSDateComponents alloc] init];
    currentDateComponents.calendar = calendar;
    currentDateComponents.month = 1;
    NSDate *endOfMonth = [calendar dateByAddingComponents:currentDateComponents toDate:date options:NSCalendarMatchStrictly];
    return endOfMonth;
}

- (NSString *)reportDateForIndexPath:(NSIndexPath *)indexPath {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    format.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
    NSDate *now;
    NSString *dateString = @"";
    if (_reportName == ReportNameManagerZZ || _reportName == ReportNameShift || _reportName == ReportNameCentralizedZ)
    {
        dateString = [(self.mangerReportDetailsArray)[indexPath.row] valueForKey:[self keyForIndex:ReportDetailsKeyDate]];
    }
    else
    {
        now = [self jsonStringToNSDate:[(self.mangerReportDetailsArray)[indexPath.row] valueForKey:[self keyForIndex:ReportDetailsKeyDate]]];
        dateString = [format stringFromDate:now];
    }
    return dateString;
}

- (NSDate*)jsonStringToNSDate :(NSString* ) string
{
    // Extract the numeric part of the date.  Dates should be in the format
    // "/Date(x)/", where x is a number.  This format is supplied automatically
    // by JSON serialisers in .NET.
    NSRange range = NSMakeRange(6, string.length - 8);
    NSString* substring = [string substringWithRange:range];
    
    // Have to use a number formatter to extract the value from the string into
    // a long long as the longLongValue method of the string doesn't seem to
    // return anything useful - it is always grossly incorrect.
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    NSNumber* milliseconds = [formatter numberFromString:substring];
    // NSTimeInterval is specified in seconds.  The value we get back from the
    // web service is specified in milliseconds.  Both values are since 1st Jan
    // 1970 (epoch).
    NSTimeInterval seconds = milliseconds.longLongValue / 1000;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
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
