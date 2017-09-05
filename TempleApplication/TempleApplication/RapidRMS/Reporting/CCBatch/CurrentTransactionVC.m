//
//  CurrentTransactionVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 18/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CurrentTransactionVC.h"
#import "CCDetailsCustomeCell.h"
#import "NSString+Methods.h"

@interface CurrentTransactionVC () <CCDetailsCustomeCellDelegate,UITableViewDataSource>
{
    CCCommonHeaderVC *cCCommonHeaderVCWithTip;
    CCCommonHeaderVC *cCCommonHeaderVCWithOutTip;
}

@property (nonatomic, weak) IBOutlet UITableView *tblCurrentTrnx;

@property (nonatomic, weak) IBOutlet UIView *currentTransactionWithOutTip;
@property (nonatomic, weak) IBOutlet UIView *currentTransactionWithTip;

@property (nonatomic, strong) NSMutableArray *cardDetail;

@end

@implementation CurrentTransactionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Update UI

- (void)updateCurrentTrnxUIWithCardDetail:(NSMutableArray *)cardDetails {
    //Reload Data
    self.cardDetail = [cardDetails mutableCopy];
    [self.tblCurrentTrnx reloadData];
}

- (void)updateCommonHeaderWith:(CCBatchTrnxDetailStruct*)cCBatchTrnxDetail {
    if (self.isTipsApplicable.boolValue == YES) {
        [cCCommonHeaderVCWithTip updateCCBatchCommonHeaderWith:cCBatchTrnxDetail];
    }
    else {
        [cCCommonHeaderVCWithOutTip updateCCBatchCommonHeaderWith:cCBatchTrnxDetail];
    }
}

- (void)configureCurrentTransactionHeader {
    if (self.isTipsApplicable.boolValue == YES) {
        [self configureHeader:self.currentTransactionWithTip];
    }
    else {
        [self configureHeader:self.currentTransactionWithOutTip];
    }
}

- (void)configureHeader:(UIView *)view {
    self.currentTransactionWithOutTip.hidden = YES;
    self.currentTransactionWithTip.hidden = YES;
    view.hidden = NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cardDetail.count;
}

- (UITableViewCell *)configuareCCCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withIdentifier:(NSString *)identifier {
    CCDetailsCustomeCell *cell = (CCDetailsCustomeCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *strDate = [self getStringFormat:[(self.cardDetail)[indexPath.row] valueForKey:@"BillDate"] fromFormat:@"MM-dd-yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy"];
    
    NSString *strTime = [self getStringFormat:[(self.cardDetail)[indexPath.row] valueForKey:@"BillDate"] fromFormat:@"MM-dd-yyyy HH:mm:ss" toFormate:@"hh:mm a"];
    
    cell.lblDateAndTime.text = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
    
    NSString *cardNumber = [(self.cardDetail)[indexPath.row] valueForKey:@"AccNo"];
    if ([cardNumber length] == 4) {
        cardNumber = [NSString stringWithFormat:@"**** **** **** %@",cardNumber];
    }
    else {
        cardNumber = [NSString stringWithFormat:@"**** **** **** %@",[cardNumber substringFromIndex:cardNumber.length-4]];
    }
    cell.lblCardNumber.text = cardNumber;
    
    NSString *billAmount = [NSString stringWithFormat:@"%.2f",[[(self.cardDetail)[indexPath.row] valueForKey:@"BillAmount"] floatValue]];
    billAmount = [billAmount applyCurrencyFormatter:billAmount.floatValue];
    cell.lblAmount.text = billAmount;
    
    cell.lblCradType.text = [NSString stringWithFormat:@"%@",[(self.cardDetail)[indexPath.row] valueForKey:@"CardType"]];
    
    if ([identifier isEqualToString:@"CCDetailsCustomeCellWithTip"])
    {
        NSString *tipsAmount = [NSString stringWithFormat:@"%.2f",[[(self.cardDetail)[indexPath.row] valueForKey:@"TipsAmount"] floatValue]];
        tipsAmount = [tipsAmount applyCurrencyFormatter:tipsAmount.floatValue];
        cell.lblTips.text = tipsAmount;
        cell.indexPathForCell = indexPath;
        cell.cCDetailsCustomeCellDelegate = self;
    }
    
    CGFloat totalAmount = [[(self.cardDetail)[indexPath.row] valueForKey:@"BillAmount"] floatValue] +
    [[(self.cardDetail)[indexPath.row] valueForKey:@"TipsAmount"] floatValue];
    
    NSString *totalAmountText = @"";
    totalAmountText = [totalAmountText applyCurrencyFormatter:totalAmount];
    cell.lblTotalAmount.text = totalAmountText;
    cell.lblAuth.text = [NSString stringWithFormat:@"%@",[(self.cardDetail)[indexPath.row] valueForKey:@"AuthCode"]];
    cell.lblInvoiceNo.text = [NSString stringWithFormat:@"%@",[(self.cardDetail)[indexPath.row] valueForKey:@"RegisterInvNo"]];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString *identifier;
    if (self.isTipsApplicable.boolValue == YES)
    {
        identifier = @"CCDetailsCustomeCellWithTip";
    }
    else
    {
        identifier = @"CCDetailsCustomeCellWithoutTip";
    }
    cell = [self configuareCCCell:tableView cellForRowAtIndexPath:indexPath withIdentifier:identifier];
    return cell;
}

#pragma mark - CCDetailsCustomeCellDelegate

- (void)didSelectRecordForTipAdjustmentAtIndexPath:(NSIndexPath *)indexpath {
    [self.currentTransactionVCDelegate didSelectRecordForTipAdjustmentAtIndexPath:indexpath];
}

#pragma mark - Utility

-(NSString *)getStringFormat:(NSString *)pstrDate fromFormat:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
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
    if ([segueIdentifier isEqualToString:@"CTWithoutTipCCCommonHeaderVCSegue"]) {
        cCCommonHeaderVCWithOutTip = (CCCommonHeaderVC*) segue.destinationViewController;
    }
    if ([segueIdentifier isEqualToString:@"CTWithTipCCCommonHeaderVCSegue"]) {
        cCCommonHeaderVCWithTip = (CCCommonHeaderVC*) segue.destinationViewController;
    }

}

@end
