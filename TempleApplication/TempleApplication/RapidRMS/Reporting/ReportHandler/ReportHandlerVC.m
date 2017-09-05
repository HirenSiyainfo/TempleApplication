//
//  ReportHandlerVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 12/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ReportHandlerVC.h"
#import "RmsDbController.h"
#import "OfflineReportCalculation.h"
#import "ReportsGraphVC.h"
#import "RapidCreditBatchDetailVC.h"

typedef NS_ENUM(NSInteger, TabButton)
{
    TabButtonDollar = 2501,
    TabButtonPercentage,
    TabButtonCreditBatch,
};

@interface ReportHandlerVC () {
    ReportName reportType;
    NSString *serviceName;
    BOOL needToReloadCreditBatchForX;
    BOOL needToReloadCreditBatchForZ;
    BOOL needToReloadCreditBatchForZZ;
}

@property (nonatomic, weak) IBOutlet UIView *headerView;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) ReportsGraphVC *reportsGraphVC;
@property (nonatomic, strong) RapidCreditBatchDetailVC *rapidCreditBatchDetailVC;

@property (nonatomic, strong) RapidWebServiceConnection *reportWSC;

@property (nonatomic, strong) NSMutableArray *reportsArray;


@end

@implementation ReportHandlerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    // Do any additional setup after loading the view.
}

#pragma mark - Configure UI

- (void)configureView:(UIView *)view {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.graphContainer.hidden = YES;
        self.creditBatchContainer.hidden = YES;
        view.hidden = NO;
    });
}

#pragma mark - Access Reports

- (void)access:(ReportName)report usingDictionary:(NSMutableDictionary *)mangerDetailsDict
{
    reportType = report;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    NSDictionary *dictMain;
    
    switch (reportType) {
        case ReportNameX:
            dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
            dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
            dictMain = @{@"RequestData" : dict};
            serviceName = WSM_X_REPORT_DETAIL;
            break;
        case ReportNameZ:
            dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
            dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
            dict[@"Amount"] = @"0";
            dict[@"Datetime"] = [self getDate];
            dictMain = @{@"ZRequestData" : dict};
            serviceName = WSM_Z_REPORT;
            break;
        case ReportNameZZ:
            dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
            dictMain = [dict mutableCopy];
            serviceName = WSM_ZZ_REPORT;
            break;
        case ReportNameManagerZ:
            dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
            dict[@"ZTransId"] = [mangerDetailsDict valueForKey:@"ZTransId"];
            dictMain = [dict mutableCopy];
            serviceName = WSM_Z_MANAGER_LIST_DETAIL_RPT;
            break;
        case ReportNameManagerZZ:
            dict[@"RegisterId"] = mangerDetailsDict[@"RegisterId"];
            dict[@"ZZOpnDate"] = [mangerDetailsDict valueForKey:@"ZZOpnDate"];
            dict[@"ZZClsDate"] = [mangerDetailsDict valueForKey:@"ZZDate"];
            dict[@"BatchNo"] = [mangerDetailsDict valueForKey:@"BatchNo"];
            dict[@"registerName"] = [mangerDetailsDict valueForKey:@"RegisterName"];
            dictMain = [dict mutableCopy];
            serviceName = WSM_ZZ_MANAGER_LIST_DETAIL_RPT;
            break;
        case ReportNameCentralizedZ:
            dict[@"CloseDate"] = [mangerDetailsDict valueForKey:@"ZClsDate"];
            dictMain = [dict mutableCopy];
            serviceName = WSM_Z_CENTERALIZE_INFO;
            break;
        default:
            break;
    }
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reportResponse:response error:error];
        });
    };
    
    self.reportWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:serviceName params:dictMain completionHandler:completionHandler];
}

- (void)reportResponse:(id)response error:(NSError *)error {
    [self setCreditBatchReloadInfoForAppropriateReport];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self.reportsArray removeAllObjects];
                self.reportsArray = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] mutableCopy];
                if (reportType != ReportNameZZ && reportType != ReportNameManagerZ && reportType != ReportNameManagerZZ && reportType != ReportNameCentralizedZ) {
                    //Add Offline Report calculation Online Report calculation
                    OfflineReportCalculation *offlineReportCalculation = [[OfflineReportCalculation alloc] initWithArray:self.reportsArray withZid:(self.rmsDbController.globalDict)[@"ZId"]];
                    [offlineReportCalculation updateReportWithOfflineDetail];
                }
                if (reportType != ReportNameManagerZ && reportType != ReportNameManagerZZ && reportType != ReportNameCentralizedZ) {
                    //Load Dollorwise Graph for Reports
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self setSelected:TabButtonDollar];
                        [self loadGraphWithType:@"Dollorwise"];
                    });
                }
                //Completion call back of Report
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.reportHandlerVCDelegate didCompleteReport:reportType responseArray:self.reportsArray];
                });
                return;
            }
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.reportHandlerVCDelegate didCompleteReport:reportType responseArray:nil];
    });
}

#pragma mark - Credit Batch Reload Info

- (void)setCreditBatchReloadInfoForAppropriateReport {
    switch (reportType) {
        case ReportNameX:
            needToReloadCreditBatchForX = true;
            break;
            
        case ReportNameZ:
            needToReloadCreditBatchForZ = true;
            break;
            
        case ReportNameZZ:
            needToReloadCreditBatchForZZ = true;
            break;

        default:
            break;
    }
}

#pragma mark - Load Graph

- (void)loadGraphWithType:(NSString *)typeOfChart {
    self.reportsGraphVC.reportsArray = self.reportsArray;
    self.reportsGraphVC.typeOfChart = typeOfChart;
    [self.reportsGraphVC loadGraph];
}

#pragma mark - Load Credit Batch

- (void)loadCreditBatch {
    if (self.zIdForZZ != nil)
    {
        [self.rapidCreditBatchDetailVC updateRapidCreditBatchDetailWithZID:self.zIdForZZ needToReload:needToReloadCreditBatchForZZ];
        needToReloadCreditBatchForZZ = false;
    }
    else
    {
        if (reportType == ReportNameX) {
            [self.rapidCreditBatchDetailVC updateRapidCreditBatchDetailWithZID:(self.rmsDbController.globalDict)[@"ZId"] needToReload:needToReloadCreditBatchForX];
            needToReloadCreditBatchForX = false;
        }
        else if (reportType == ReportNameZ) {
            [self.rapidCreditBatchDetailVC updateRapidCreditBatchDetailWithZID:(self.rmsDbController.globalDict)[@"ZId"] needToReload:needToReloadCreditBatchForZ];
            needToReloadCreditBatchForZ = false;
        }
    }

}

#pragma mark - Tab Button Events

- (void)setSelected:(TabButton)tabButton {
    for (UIButton *button in self.headerView.subviews) {
        if (button.tag == tabButton) {
            button.selected = YES;
        }
        else
        {
            button.selected = NO;
        }
    }
}

- (IBAction)tabButtonClicked:(UIButton *)sender {
    TabButton tabButton = sender.tag;
    [self setSelected:tabButton];
    switch (tabButton) {
        case TabButtonDollar:
            //Load Dollorwise Graph for Reports
            [self configureView:self.graphContainer];
            [self loadGraphWithType:@"Dollorwise"];
            break;
        case TabButtonPercentage:
            //Load Dollorwise Graph for Reports
            [self configureView:self.graphContainer];
            [self loadGraphWithType:@"Percentagewise"];
            break;
        case TabButtonCreditBatch:
            //Load Credit Batch
            [self configureView:self.creditBatchContainer];
            [self loadCreditBatch];
            break;
        default:
            break;
    }
}

#pragma mark - Utility

- (NSString *)getDate {
    NSDate *sourceDate = [NSDate date];
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone *destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSString *strDate = [NSString stringWithFormat:@"%@",destinationDate];
    return strDate;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"ReportsGraphVCSegue"]) {
        self.reportsGraphVC  = (ReportsGraphVC*) segue.destinationViewController;
    }
    if ([segueIdentifier isEqualToString:@"RapidCreditBatchDetailVCSegue"]) {
        self.rapidCreditBatchDetailVC  = (RapidCreditBatchDetailVC*) segue.destinationViewController;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
