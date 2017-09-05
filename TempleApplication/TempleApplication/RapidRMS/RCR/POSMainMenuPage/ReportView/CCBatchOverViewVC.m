//
//  CCBatchOverViewVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 7/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CCBatchOverViewVC.h"
#import "CCBatchPieChartVC.h"
#import "NSString+Methods.h"

@interface CCBatchOverViewVC ()
{
    CCBatchPieChartVC *ccBatchPieChartVC;
    IBOutlet UIView *chartView;
    IBOutlet UILabel *totalTransction;
    IBOutlet UILabel *totalAmount;
    IBOutlet UILabel *totalAvgTicket;
}

@end

@implementation CCBatchOverViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  //  NSLog(@"%@",self.ccBatchFooterStruct.totalTransction);
    
//    totalTransction.text = [NSString stringWithFormat:@"%@",self.ccBatchFooterStruct.totalTransction];
//
//    NSString *totalAvgTickets = [NSString stringWithFormat:@"%@",self.ccBatchFooterStruct.totalAvgTicket];
//    totalAvgTicket.text = [totalAvgTickets applyCurrencyFormatter:totalAvgTickets.floatValue];
//    
//    
//    NSString *totalTransctionAmounts = [NSString stringWithFormat:@"%@",self.ccBatchFooterStruct.totalTransctionAmount];
//    totalAmount.text = [totalTransctionAmounts applyCurrencyFormatter:totalTransctionAmounts.floatValue];
    [self configureChartVC];
}


-(void)configureChartVC
{
    ccBatchPieChartVC = [[CCBatchPieChartVC alloc]initWithNibName:@"CCBatchPieChartVC" bundle:nil];
    ccBatchPieChartVC.view.frame = CGRectMake(10, 10, 1004, 370);
    ccBatchPieChartVC.cardDetails = self.creditCardDetail;
    [chartView addSubview:ccBatchPieChartVC.view];
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
