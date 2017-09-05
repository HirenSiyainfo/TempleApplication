//
//  CCCommonHeaderVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 27/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CCCommonHeaderVC.h"
#import "NSString+Methods.h"

@interface CCCommonHeaderVC () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *lblTotal;
@property (nonatomic, weak) IBOutlet UILabel *lblTipAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblGrandTotal;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalTransactions;
@property (nonatomic, weak) IBOutlet UILabel *lblAvgTicket;

@property (nonatomic, weak) IBOutlet UITextField *txtSearchBar;

@end

@implementation CCCommonHeaderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)updateCCBatchCommonHeaderWith:(CCBatchTrnxDetailStruct *)cCBatchTrnxDetail
{
    NSString *total = [NSString stringWithFormat:@"%@",cCBatchTrnxDetail.total];
    self.lblTotal.text = [total applyCurrencyFormatter:total.floatValue];

    NSString *tipAmount = [NSString stringWithFormat:@"%@",cCBatchTrnxDetail.tipAmount];
    self.lblTipAmount.text = [tipAmount applyCurrencyFormatter:tipAmount.floatValue];
    
    NSString *grandTotal = [NSString stringWithFormat:@"%@",cCBatchTrnxDetail.grandTotal];
    self.lblGrandTotal.text = [grandTotal applyCurrencyFormatter:grandTotal.floatValue];

    self.lblTotalTransactions.text = [NSString stringWithFormat:@"%@",cCBatchTrnxDetail.totalTransaction];

    NSString *totalAvgTicket = [NSString stringWithFormat:@"%@",cCBatchTrnxDetail.totalAvgTicket];
    self.lblAvgTicket.text = [totalAvgTicket applyCurrencyFormatter:totalAvgTicket.floatValue];
}

- (void)clearSearchTextField {
    self.txtSearchBar.text = @"";
    [self.txtSearchBar resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text != nil && textField.text.length > 0) {
        [self.cCCommonHeaderVCDelegate didSearch:textField.text];
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(range.location == 0 && ([string isEqualToString:@""]))
    {
        [self.cCCommonHeaderVCDelegate didClearSearch];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.cCCommonHeaderVCDelegate didClearSearch];
    return YES;
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
