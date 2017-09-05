//
//  ShiftHistoryDetailsVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 19/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ShiftHistoryDetailsVC.h"
#import "ReportWebVC.h"

@interface ShiftHistoryDetailsVC ()<ManagerReportVCDelegate>

@property (nonatomic, strong) ManagerReportVC *managerReportVC;
@property (nonatomic, strong) ReportWebVC *reportWebVC;

@end

@implementation ShiftHistoryDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Shift History

- (void)loadShiftHistoryWithAllTabOptions:(BOOL)needToShowAllTab {
    [self.managerReportVC needToShowAllTabOptions:needToShowAllTab];
    [self.managerReportVC accessManagerReportsDetailsFor:[NSDate date] formatter:@"MM/yyyy" reportName:ReportNameShift];
}

- (void)loadHtmlForShiftHistoryUsing:(NSString *)html {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.reportWebVC loadHtmlReportInWebView:html];
    });
}

#pragma mark - ManagerReportVCDelegate

- (void)accessMangerReport:(ReportName)reportName usingDictionary:(NSMutableDictionary *)mangerDetailsDict {
    [self.shiftHistoryDetailsVCDelegate accessShiftReport:reportName usingDictionary:mangerDetailsDict];
}

- (void)didSelectedMangerReportOption:(ManagerTabOption)managerTabOption {
    [self.shiftHistoryDetailsVCDelegate didSelectedMangerReportOption:managerTabOption];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"ShiftHistoryDetailsVCToManagerSegue"]) {
        self.managerReportVC = (ManagerReportVC*) segue.destinationViewController;
        self.managerReportVC.managerReportVCDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"ShiftHistoryDetailsVCToWebViewSegue"]) {
        self.reportWebVC = (ReportWebVC*) segue.destinationViewController;
    }
}

@end
