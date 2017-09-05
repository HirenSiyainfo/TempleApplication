//
//  ReportsGraphVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 12/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ReportsGraphVC.h"
#import "ReportsGraphCustomeCell.h"
#import "XReportPieChart.h"
#import "XReportBarChart.h"
#import "XReportpaymentPieChart.h"
#import "RmsDbController.h"

typedef NS_ENUM(NSInteger, ReportGraphSection)
{
    ReportGraphSectionDepartment,
    ReportGraphSectionHours,
    ReportGraphSectionTender,
};

@interface ReportsGraphVC () <UITableViewDataSource,UITableViewDelegate> {
    NSArray *graphSections;
    XReportPieChart *xReportPieChart;
    XReportBarChart *xReportBarChart;
    XReportpaymentPieChart *xReportpaymentPieChart;
}

@property (nonatomic, weak) IBOutlet UITableView *tblReportGraph;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@end

@implementation ReportsGraphVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    // Do any additional setup after loading the view.
}

- (void)loadGraph {
    graphSections = @[@(ReportGraphSectionDepartment),@(ReportGraphSectionHours),@(ReportGraphSectionTender)];
    [self.tblReportGraph reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return graphSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 44)] ;
    headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    UILabel *headerTitle = [self configuredLabel:CGRectMake(35,5,200,30) textAlignment:NSTextAlignmentLeft fontSize:17];
    UILabel *headerTitleValue = [self configuredLabel:CGRectMake(434,5,250,30) textAlignment:NSTextAlignmentRight fontSize:20];

    ReportGraphSection reportGraphSection = section;
    switch (reportGraphSection) {
        case ReportGraphSectionDepartment:
            imageView.frame = CGRectMake(0,5,30,30);
            imageView.image = [UIImage imageNamed:@"departmenticon_grap.png"];
            headerTitle.text = @"DEPARTMENT";
            if([self.typeOfChart isEqualToString:@"Dollorwise"])
            {
                headerTitleValue.text = [self.rmsDbController.currencyFormatter stringFromNumber:[xReportPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"]];
            }
            else
            {
                headerTitleValue.text = [NSString stringWithFormat:@"%.2f%%",[[xReportPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Per"] floatValue]];
            }
            break;
            
        case ReportGraphSectionHours:
            imageView.frame = CGRectMake(0,7,28,27);
            imageView.image = [UIImage imageNamed:@"humanicon.png"];
            headerTitle.text = @"CUSTOMER COUNT";
            headerTitleValue.text = [NSString stringWithFormat:@"%ld",(long)[[xReportBarChart.arrXRepHours valueForKeyPath:@"@sum.Count"] integerValue]];
            break;
            
        case ReportGraphSectionTender:
            imageView.frame = CGRectMake(0,7,31,28);
            imageView.image = [UIImage imageNamed:@"paymenticon.png"];
            headerTitle.text = @"PAYMENT";
            if([self.typeOfChart isEqualToString:@"Dollorwise"])
            {
                headerTitleValue.text = [self.rmsDbController.currencyFormatter stringFromNumber:[xReportpaymentPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"]];
            }
            else
            {
                headerTitleValue.text = @"100.00%";
            }
            break;
            
        default:
            break;
    }
    
    [headerView addSubview:imageView];
    [headerView addSubview:headerTitle];
    [headerView addSubview:headerTitleValue];
    UIView *sapertorView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, tableView.bounds.size.width, 1)] ;
    sapertorView.backgroundColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0];
    [headerView addSubview:sapertorView];
    return headerView;
}

- (UILabel *)configuredLabel:(CGRect)frame textAlignment:(NSTextAlignment)textAlignment fontSize:(CGFloat)size {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = textAlignment;
    label.font = [UIFont fontWithName:@"Lato" size:size];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReportsGraphCustomeCell *reportsGraphCustomeCell = (ReportsGraphCustomeCell *)[tableView dequeueReusableCellWithIdentifier:@"ReportsGraphCustomeCell"];
    ReportGraphSection reportGraphSection = indexPath.section;
    [[reportsGraphCustomeCell.contentView viewWithTag:20002] removeFromSuperview];
    [[reportsGraphCustomeCell.contentView viewWithTag:20003] removeFromSuperview];
    [[reportsGraphCustomeCell.contentView viewWithTag:20004] removeFromSuperview];
    switch (reportGraphSection) {
        case ReportGraphSectionDepartment:
            [self showPieChartInView:reportsGraphCustomeCell.chartContainer usingArray:[(self.reportsArray).firstObject valueForKey:@"RptDepartment"]];
            break;
            
        case ReportGraphSectionHours:
            [self showBarChartInView:reportsGraphCustomeCell.chartContainer usingArray:[(self.reportsArray).firstObject valueForKey:@"RptHours"]];
            break;

        case ReportGraphSectionTender:
            [self showPaymentPieChartInView:reportsGraphCustomeCell.chartContainer usingArray:[(self.reportsArray).firstObject valueForKey:@"RptTender"]];
            break;

        default:
            break;
    }
    reportsGraphCustomeCell.contentView.backgroundColor = [UIColor clearColor];
    reportsGraphCustomeCell.backgroundColor = [UIColor clearColor];
    return reportsGraphCustomeCell;
}

- (void)showPieChartInView:(UIView *)view usingArray:(NSMutableArray *)array {
    xReportPieChart = [[XReportPieChart alloc] initWithNibName:@"XReportPieChart" bundle:nil];
    xReportPieChart.arrXRepDepartment = [array mutableCopy];
    if ((xReportPieChart.arrXRepDepartment).count==0) {
        [xReportPieChart.arrXRepDepartment addObject:@{
                                                   @"Amount":@"0.00",
                                                   @"Count":@"0.00",
                                                   @"DepartId":@"0.00",
                                                   @"Descriptions":@"Not Available",
                                                   @"Per":@"100.0",
                                                   }];
    }
    NSMutableArray *arrTempXRepDepartment = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < (xReportPieChart.arrXRepDepartment).count; i++)
    {
        NSMutableDictionary *dict = (xReportPieChart.arrXRepDepartment)[i];
        float percent = [[dict valueForKey:@"Per"] floatValue];
        if(percent != 0)
        {
            [arrTempXRepDepartment addObject:dict];
        }
    }
    xReportPieChart.arrXRepDepartment = [arrTempXRepDepartment mutableCopy];
    xReportPieChart.view.backgroundColor = [UIColor clearColor];
    [self addChart:xReportPieChart intoContainer:view tag:20002];
}

- (void)showBarChartInView:(UIView *)view usingArray:(NSMutableArray *)array {
    xReportBarChart = [[XReportBarChart alloc] initWithNibName:@"XReportBarChart" bundle:nil];
    xReportBarChart.arrXRepHours = [array mutableCopy];
    int decm = 0;
    if ((xReportBarChart.arrXRepHours).count==0) {
        [xReportBarChart.arrXRepHours addObject:@{
                                               @"Amount":@"0.00",
                                               @"Count":@(decm),
                                               @"Hours":@"0.00",
                                               }];
    }
    xReportBarChart.view.backgroundColor = [UIColor clearColor];
    [self addChart:xReportBarChart intoContainer:view tag:20003];
}

- (void)showPaymentPieChartInView:(UIView *)view usingArray:(NSMutableArray *)array {
    xReportpaymentPieChart = [[XReportpaymentPieChart alloc] initWithNibName:@"XReportpaymentPieChart" bundle:nil];
    xReportpaymentPieChart.arrXRepDepartment = [array mutableCopy];
    if ((xReportpaymentPieChart.arrXRepDepartment).count==0)
    {
        [xReportpaymentPieChart.arrXRepDepartment addObject:@{
                                                              @"Amount":@"100.00",
                                                              @"Count":@"0.00",
                                                              @"TenderId":@"0.00",
                                                              @"Descriptions":@"Not Available",
                                                              }];
    }
    NSMutableArray *arrTempXRepDepartment = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < (xReportpaymentPieChart.arrXRepDepartment).count; i++)
    {
        NSMutableDictionary *tempPaymentDict = (xReportpaymentPieChart.arrXRepDepartment)[i];
        float percent = [[tempPaymentDict valueForKey:@"Amount"] floatValue];
        if(percent != 0)
        {
            [arrTempXRepDepartment addObject:tempPaymentDict];
        }
    }
    xReportpaymentPieChart.arrXRepDepartment = [arrTempXRepDepartment mutableCopy];
    xReportpaymentPieChart.view.backgroundColor = [UIColor clearColor];
    [self addChart:xReportpaymentPieChart intoContainer:view tag:20004];
}

- (void)addChart:(UIViewController *)chart intoContainer:(UIView *)container tag:(int)tag {
    [[container viewWithTag:tag] removeFromSuperview];
    chart.view.tag = tag;
    chart.view.frame = container.bounds;
    chart.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [container addSubview:chart.view];
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
