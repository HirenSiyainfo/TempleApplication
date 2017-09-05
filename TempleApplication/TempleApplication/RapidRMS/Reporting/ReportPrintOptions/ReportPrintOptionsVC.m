//
//  ReportPrintOptionsVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 24/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ReportPrintOptionsVC.h"

@interface ReportPrintOptionsVC () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tblReportOptions;

@end

@implementation ReportPrintOptionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configurePrintOptionView];
}

#pragma mark - Configure UI

- (void)configurePrintOptionView {
    CGRect frame = self.view.frame;
    frame.size.height = [self setHeightForView];
    self.view.frame = frame;
}

#pragma mark - Close Print Option

- (IBAction)closeButtonClicked:(id)sender {
    [self.reportPrintOptionsVCDelegate didCancelPrinterOption];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.arrPrintOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PrintOptionsCell *printOptionsCell = [tableView dequeueReusableCellWithIdentifier:@"PrintOptionsCell" forIndexPath:indexPath];
    if ([self.arrPrintOptions[indexPath.row] isKindOfClass:[NSString class]]) {
        printOptionsCell.lblReportName.text = self.arrPrintOptions[indexPath.row];
        [printOptionsCell.btnReportPrint addTarget:self action:@selector(printReportClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (indexPath.row == PrintOptionShiftReport && !self.enableShiftPrintingOption) {
            printOptionsCell.btnReportPrint.enabled = NO;
        }
        else {
            printOptionsCell.btnReportPrint.enabled = YES;
        }
    }
    printOptionsCell.backgroundColor = [UIColor clearColor];
    printOptionsCell.contentView.backgroundColor = [UIColor clearColor];
    return printOptionsCell;
}

#pragma mark - Print Option Selected

-(IBAction)printReportClicked:(id)sender {
    PrintOptionsCell *printOptionsCell = (PrintOptionsCell *)[sender superview].superview;
    NSIndexPath *indexPath = [self.tblReportOptions indexPathForCell:printOptionsCell];
    PrintOption printOption = indexPath.row;
    [self.reportPrintOptionsVCDelegate didSelectPrinterOption:printOption];
}

#pragma mark - Dynamic View

- (float)setHeightForView {
    float height = (self.arrPrintOptions.count*55)+156;
    return height;
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


#pragma mark - PrintOptionsCell

@implementation PrintOptionsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end

