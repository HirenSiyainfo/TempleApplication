//
//  ManagerReportPopUpVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 17/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ManagerReportPopUpVC.h"
#import "ManagerReportOptionsCell.h"

@interface ManagerReportPopUpVC () <UITableViewDataSource,UITableViewDelegate> {
    NSArray *managerReportOptionsArray;
}

@property (nonatomic, weak) IBOutlet UITableView *tblManagerReportOptions;
@end

@implementation ManagerReportPopUpVC

- (void)viewDidLoad {
    managerReportOptionsArray = @[@(ManagerReportOptionZReport),
                                  @(ManagerReportOptionZZReport),
                                  @(ManagerReportOptionShiftReport),
                                  ];
    [self.tblManagerReportOptions reloadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)closeManagerReport:(id)sender {
    [self.managerReportPopUpVCDelegate didCloseMangerReport];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return managerReportOptionsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManagerReportOptionsCell *managerReportOptionsCell = (ManagerReportOptionsCell *)[tableView dequeueReusableCellWithIdentifier:@"ManagerReportOptionsCell"];
    ManagerReportOption managerReportOption = indexPath.row;
    switch (managerReportOption) {
        case ManagerReportOptionZReport:
            managerReportOptionsCell.lblManagerReportOption.text = @"Z REPORT HISTORY";
            break;
            
        case ManagerReportOptionZZReport:
            managerReportOptionsCell.lblManagerReportOption.text = @"ZZ REPORT HISTORY";
            break;
            
        case ManagerReportOptionShiftReport:
            managerReportOptionsCell.lblManagerReportOption.text = @"SHIFT REPORT";
            break;
            
        default:
            break;
    }
    managerReportOptionsCell.contentView.backgroundColor = [UIColor clearColor];
    managerReportOptionsCell.backgroundColor = [UIColor clearColor];
    return managerReportOptionsCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ManagerReportOption managerReportOption = indexPath.row;
    [self.managerReportPopUpVCDelegate didSelectMangerReportOption:managerReportOption];
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
