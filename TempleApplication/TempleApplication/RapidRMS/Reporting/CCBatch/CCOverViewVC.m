//
//  CCOverViewVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 18/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CCOverViewVC.h"
#import "OverViewPieChartVC.h"
#import "CCCommonHeaderVC.h"

@interface CCOverViewVC ()
{
    OverViewPieChartVC *overViewPieChartVC;
    CCCommonHeaderVC *cCCommonHeaderVC;
}

@property (nonatomic, weak) IBOutlet UIView *chartView;

@end

@implementation CCOverViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)loadCCBatchPieChart:(NSMutableArray *)creditCardDetail
{
    [overViewPieChartVC.view removeFromSuperview];
    overViewPieChartVC.view.frame = CGRectMake(20, 45, 984, 370);
    overViewPieChartVC.cardDetails = creditCardDetail;
    [self.chartView addSubview:overViewPieChartVC.view];
}

- (void)updateCommonHeaderWith:(CCBatchTrnxDetailStruct *)cCBatchTrnxDetail {
    [cCCommonHeaderVC updateCCBatchCommonHeaderWith:cCBatchTrnxDetail];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"OverViewPieChartVCSegue"]) {
        overViewPieChartVC = (OverViewPieChartVC*) segue.destinationViewController;
    }
    else if ([segueIdentifier isEqualToString:@"OverViewCCCommonHeaderVCSegue"]) {
        cCCommonHeaderVC = (CCCommonHeaderVC*) segue.destinationViewController;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
