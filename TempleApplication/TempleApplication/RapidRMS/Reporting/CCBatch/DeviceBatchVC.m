//
//  DeviceBatchVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 27/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "DeviceBatchVC.h"
#import "CCDetailsCustomeCell.h"
#import "NSString+Methods.h"
#import "RmsDbController.h"

@interface DeviceBatchVC () <UITableViewDataSource,CCCommonHeaderVCDelegate,CCDetailsCustomeCellDelegate,UITableViewDelegate>
{
    CCCommonHeaderVC *cCCommonHeaderVCWithTip;
    CCCommonHeaderVC *cCCommonHeaderVCWithOutTip;
    PaymentGateWay paymentGateWay;
}

@property (nonatomic, weak) IBOutlet UITableView *tblDeviceBatch;

@property (nonatomic, weak) IBOutlet UIView *deviceBatchViewWithOutTip;
@property (nonatomic, weak) IBOutlet UIView *deviceBatchViewWithTip;

@property (nonatomic, strong) NSMutableArray *cardDetail;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation DeviceBatchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    [self initiallyCheckSelecetdPaymentGateWay];
    // Do any additional setup after loading the view.
}

- (void)initiallyCheckSelecetdPaymentGateWay {
    if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Bridgepay"]) {
        paymentGateWay = BridgePay;
    }
    else {
        paymentGateWay = Pax;
    }
}

#pragma mark - Update UI

- (void)updateDeviceBatchUIWithCardDetail:(NSMutableArray *)cardDetails {
    //Reload Data
    self.cardDetail = [cardDetails mutableCopy];
    [self.tblDeviceBatch reloadData];
}

- (void)updateCommonHeaderWith:(CCBatchTrnxDetailStruct*)cCBatchTrnxDetail {
    if (self.isTipsApplicable.boolValue == YES) {
        [cCCommonHeaderVCWithTip updateCCBatchCommonHeaderWith:cCBatchTrnxDetail];
    }
    else {
        [cCCommonHeaderVCWithOutTip updateCCBatchCommonHeaderWith:cCBatchTrnxDetail];
    }
}

- (void)clearSearchTextFieldOfCommonHeader {
    [cCCommonHeaderVCWithTip clearSearchTextField];
}

- (void)configureDeviceBatchHeader {
    if (self.isTipsApplicable.boolValue == YES) {
        [self configureHeader:self.deviceBatchViewWithTip];
    }
    else {
        [self configureHeader:self.deviceBatchViewWithOutTip];
    }
}

- (void)configureHeader:(UIView *)view {
    self.deviceBatchViewWithOutTip.hidden = YES;
    self.deviceBatchViewWithTip.hidden = YES;
    view.hidden = NO;
}

#pragma mark - CCCommonHeaderVCDelegate

- (void)didSearch:(NSString *)text {
    [self.deviceBatchVCDelegate didSearch:text];
}

- (void)didClearSearch {
    [self.deviceBatchVCDelegate didClearSearch];
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
    cell.lblCardNumber.text = cardNumber;
    
    
    NSString *billAmount = [NSString stringWithFormat:@"%.2f",[[(self.cardDetail)[indexPath.row] valueForKey:@"BillAmount"] floatValue]];
    billAmount = [billAmount applyCurrencyFormatter:billAmount.floatValue];
    cell.lblAmount.text = billAmount;

    
    cell.lblCradType.text = [NSString stringWithFormat:@"%@",[[(self.cardDetail)[indexPath.row] valueForKey:@"CardType"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    cell.lblTransactionStatus.textColor = [UIColor blackColor];
    
    
    if ([[(self.cardDetail)[indexPath.row] valueForKey:@"VoidSaleTrans"] isEqualToString:@"1"] ) {
        cell.lblTransactionStatus.textColor = [UIColor redColor];
    }

   
//    NSString *transactionStatus = @"";
//    BOOL isRefunded = [self isRefundTransaction:@[(self.cardDetail)[indexPath.row]]];
//
//    switch (paymentGateWay) {
//        case BridgePay: {
//            if (isRefunded) {
//                billAmount = [NSString stringWithFormat:@"-%@",billAmount];
//            }
////            transactionStatus = [NSString stringWithFormat:@"%@",[[[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString]];
//            break;
//        }
//        case Pax: {
//        /*    NSInteger transationType = [[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] integerValue];
//            transactionStatus = [NSString stringWithFormat:@"%@",[self getTransationType:transationType]];
//            switch (transationType) {
//                case TRANSACTIONTYPEVOID:
//                case TRANSACTIONTYPEVSALE:
//                case TRANSACTIONTYPEVRTRN:
//                case TRANSACTIONTYPEVAUTH:
//                case TRANSACTIONTYPEVPOST:
//                case TRANSACTIONTYPEVFRCD:
//                case TRANSACTIONTYPEVWITHDRAW:
//                    cell.lblTransactionStatus.textColor = [UIColor redColor];
//                    break;
//                    
//                default:
//                    cell.lblTransactionStatus.textColor = [UIColor blackColor];
//                    break;
//            }*/
//            break;
//        }
//    }
    
    cell.lblTransactionStatus.text = [NSString stringWithFormat:@"%@",[[[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString]];

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
  /*  if (paymentGateWay == BridgePay) {
        if (isRefunded) {
            totalAmountText = [NSString stringWithFormat:@"-%@",totalAmountText];
        }
    }*/
    
    totalAmountText = [totalAmountText applyCurrencyFormatter:totalAmount];
    cell.lblTotalAmount.text = totalAmountText;
    
    NSString *authCode = [NSString stringWithFormat:@"%@",[(self.cardDetail)[indexPath.row] valueForKey:@"AuthCode"]];
    if (!authCode || authCode.length == 0) {
        authCode = @"-";
    }
    cell.lblAuth.text = authCode;
    cell.lblInvoiceNo.text = [NSString stringWithFormat:@"%@",[(self.cardDetail)[indexPath.row] valueForKey:@"RegisterInvNo"]];
    
    
    

    
    return cell;
}


-(UITableViewRowAction *)voidAction
{
    UITableViewRowAction *voidAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Void" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
            [self.deviceBatchVCDelegate setVoidTransactionProcess:indexPath];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Are you sure you want Void this Transaction ?"] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];    }];
    voidAction.backgroundColor = [UIColor blueColor];
    return voidAction;
}

-(UITableViewRowAction *)forceAction
{
    ///// ForceProcess
    UITableViewRowAction *forceAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Force"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
            [self.deviceBatchVCDelegate setForceTransactionProcess:indexPath];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Are you sure you want Force this Transaction ?"] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];    }];
    forceAction.backgroundColor = [UIColor redColor];
    return forceAction;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (([[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Sale"] || [[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"SALE/REDEEM"] || [[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Authorization"]) && [[(self.cardDetail)[indexPath.row] valueForKey:@"VoidSaleTrans"] isEqualToString:@"0"]){
        return YES;

    }
    
    if (([[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Authorization"] && [[(self.cardDetail)[indexPath.row] valueForKey:@"VoidSaleTrans"] isEqualToString:@"0"]))
    {
        return YES;
    }
    
    return NO;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    if (([[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Sale"] || [[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"SALE/REDEEM"] || [[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Authorization"]) && [[(self.cardDetail)[indexPath.row] valueForKey:@"VoidSaleTrans"] isEqualToString:@"0"]){
        [actions addObject:[self voidAction]];
    }
    
    if (([[(self.cardDetail)[indexPath.row] valueForKey:@"TransType"] isEqualToString:@"Authorization"] && [[(self.cardDetail)[indexPath.row] valueForKey:@"VoidSaleTrans"] isEqualToString:@"0"]))
    {
        [actions addObject:[self forceAction]];
    }
    return actions;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    [self.deviceBatchVCDelegate didSelectRecordForTipAdjustmentAtIndexPath:indexpath];
}

#pragma mark - Get Transation Type 

- (NSString *)getTransationType:(TRANSACTIONTYPE)transationType {
    NSString *strTransationType = @"";
    switch (transationType) {
        case TRANSACTIONTYPEMENU:
            strTransationType = @"MENU";
            break;
            
        case TRANSACTIONTYPESALEREDEEM:
            strTransationType = @"SALE/REDEEM";
            break;
            
        case TRANSACTIONTYPERETURN:
            strTransationType = @"RETURN";
            break;

        case TRANSACTIONTYPEAUTH:
            strTransationType = @"AUTH";
            break;
            
        case TRANSACTIONTYPEPOSTAUTH:
            strTransationType = @"POSTAUTH";
            break;
            
        case TRANSACTIONTYPEFORCED:
            strTransationType = @"FORCED";
            break;

        case TRANSACTIONTYPEADJUST:
            strTransationType = @"ADJUST";
            break;
            
        case TRANSACTIONTYPEWITHDRAWAL:
            strTransationType = @"WITHDRAWAL";
            break;

        case TRANSACTIONTYPEACTIVATE:
            strTransationType = @"ACTIVATE";
            break;
            
        case TRANSACTIONTYPEISSUE:
            strTransationType = @"ISSUE";
            break;
            
        case TRANSACTIONTYPEADD:
            strTransationType = @"ADD";
            break;

        case TRANSACTIONTYPECASHOUT:
            strTransationType = @"CASHOUT";
            break;

        case TRANSACTIONTYPEDEACTIVATE:
            strTransationType = @"DEACTIVATE";
            break;
            
        case TRANSACTIONTYPEREPLACE:
            strTransationType = @"REPLACE";
            break;
            
        case TRANSACTIONTYPEMERGE:
            strTransationType = @"MERGE";
            break;
            
        case TRANSACTIONTYPEREPORTLOST:
            strTransationType = @"REPORTLOST";
            break;
            
        case TRANSACTIONTYPEVOID:
            strTransationType = @"VOID";
            break;
            
        case TRANSACTIONTYPEVSALE:
            strTransationType = @"V/SALE";
            break;
            
        case TRANSACTIONTYPEVRTRN:
            strTransationType = @"V/RTRN";
            break;
            
        case TRANSACTIONTYPEVAUTH:
            strTransationType = @"V/AUTH";
            break;
            
        case TRANSACTIONTYPEVPOST:
            strTransationType = @"V/POST";
            break;
            
        case TRANSACTIONTYPEVFRCD:
            strTransationType = @"V/FRCD";
            break;

        case TRANSACTIONTYPEVWITHDRAW:
            strTransationType = @"V/WITHDRAW";
            break;

        case TRANSACTIONTYPEBALANCE:
            strTransationType = @"BALANCE";
            break;
            
        case TRANSACTIONTYPEVERIFY:
            strTransationType = @"VERIFY";
            break;
            
        case TRANSACTIONTYPEREACTIVATE:
            strTransationType = @"REACTIVATE";
            break;
            
        case TRANSACTIONTYPEFORCEDISSUE:
            strTransationType = @"FORCED ISSUE";
            break;

        case TRANSACTIONTYPEFORCEDADD:
            strTransationType = @"FORCED ADD";
            break;
            
        case TRANSACTIONTYPEUNLOAD:
            strTransationType = @"UNLOAD";
            break;
            
        case TRANSACTIONTYPERENEW:
            strTransationType = @"RENEW";
            break;
            
        case TRANSACTIONTYPEGETCONVERTDETAIL:
            strTransationType = @"GET CONVERT DETAIL";
            break;

        case TRANSACTIONTYPECONVERT:
            strTransationType = @"CONVERT";
            break;
            
        case TRANSACTIONTYPETOKENIZE:
            strTransationType = @"TOKENIZE";
            break;

        case TRANSACTIONTYPEREVERSAL:
            strTransationType = @"REVERSAL";
            break;

        default:
            break;
    }
    return strTransationType;
}

- (BOOL)isRefundTransaction:(NSArray *)array {
    BOOL isRefundTransaction = false;
    NSPredicate *refundPredicate = [self predicateForRefundTransaction];
    NSArray *refundTransactions = [array filteredArrayUsingPredicate:refundPredicate];
    if (refundTransactions != nil && refundTransactions.count > 0) {
        isRefundTransaction = true;
    }
    return isRefundTransaction;
}

- (NSPredicate *)predicateForRefundTransaction {
    return [NSPredicate predicateWithFormat:@"TransType IN %@",@"Credit              "];
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
    if ([segueIdentifier isEqualToString:@"DBWithoutTipCCCommonHeaderVCSegue"]) {
        cCCommonHeaderVCWithOutTip = (CCCommonHeaderVC*) segue.destinationViewController;
        cCCommonHeaderVCWithOutTip.cCCommonHeaderVCDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"DBWithTipCCCommonHeaderVCSegue"]) {
        cCCommonHeaderVCWithTip = (CCCommonHeaderVC*) segue.destinationViewController;
        cCCommonHeaderVCWithTip.cCCommonHeaderVCDelegate = self;
    }
}



@end
