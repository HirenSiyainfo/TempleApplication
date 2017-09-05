//
//  DeviceSummaryVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 18/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "DeviceSummaryVC.h"
#import "DeviceBatchSummaryCustomeCell.h"
#import "NSString+Methods.h"
#import "RmsDbController.h"

@interface DeviceSummaryVC ()<UICollectionViewDataSource>
{
    NSArray *arrDeviceSummary;
    NSMutableArray *arrPaxReportEnum;
    NSMutableArray *arrCardType;
}

@property (nonatomic, weak) IBOutlet UILabel *lblTotalAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalCount;
@property (nonatomic, weak) IBOutlet UILabel *lblFilterType;

@property (nonatomic, weak) IBOutlet UICollectionView *deviceSummaryCollectionView;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation DeviceSummaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    // Do any additional setup after loading the view.
}

- (void)displayDeviceSummaryUI:(NSMutableArray *)deviceSummaryArray paxReportEnum:(NSArray *)paxReportEnumArray withPaymentGateWay:(PaymentGateWay)paymentGateWay
{
    arrDeviceSummary = [deviceSummaryArray copy];
    selectedPaymentGateWay = paymentGateWay;
    switch (selectedPaymentGateWay) {
        case BridgePay:
            self.lblFilterType.text = @"CARD TYPE";
            [self deviceSummarizationForBridgePay];
            break;
            
        case Pax:
            self.lblFilterType.text = @"PAYMENT TYPE";
            [self deviceSummarizationForPax:paxReportEnumArray];
            break;

        default:
            break;
    }
    [self.deviceSummaryCollectionView reloadData];
}

- (void)deviceSummarizationForBridgePay {
    arrCardType = [arrDeviceSummary valueForKeyPath:@"@distinctUnionOfObjects.CardType"];
    [self updateHeaderDetailsForBridgePay];
}

- (void)deviceSummarizationForPax:(NSArray *)paxReportEnumArray {
    arrPaxReportEnum = [paxReportEnumArray mutableCopy];
    [self updateHeaderDetailsForPax];
}

- (void)updateHeaderDetailsForBridgePay {
    NSArray *salesTransactions = [self salesTransactionsForBridgePayFromArray:arrDeviceSummary];
    NSArray *authTransactions = [self authTransactionsForBridgePayFromArray:arrDeviceSummary];
    NSArray *forceTransactions = [self forceTransactionsForBridgePayFromArray:arrDeviceSummary];
    NSArray *refundTransactions = [self refundTransactionsForBridgePayFromArray:arrDeviceSummary];
    float totalAmount = [[salesTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue] + [[authTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue] + [[forceTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue] - [[refundTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
    NSString *strTotalAmount = [NSString stringWithFormat:@"%.2f",totalAmount];
    if (strTotalAmount != nil && strTotalAmount.length > 0) {
        self.lblTotalAmount.text = [strTotalAmount applyCurrencyFormatter:strTotalAmount.floatValue];
    }
    else {
        self.lblTotalAmount.text = @"$0.00";
    }
    self.lblTotalCount.text = [NSString stringWithFormat:@"%ld", (long)(salesTransactions.count + authTransactions.count + forceTransactions.count + refundTransactions.count)];
}

- (NSArray *)salesTransactionsForBridgePayFromArray:(NSArray *)array {
    NSPredicate *salesPredicate = [self predicateTransactionwith:@"Sale"];
    return [array filteredArrayUsingPredicate:salesPredicate];
}
- (NSArray *)authTransactionsForBridgePayFromArray:(NSArray *)array {
    NSPredicate *authPredicate = [self predicateTransactionwith:@"Authorization"];
    return [array filteredArrayUsingPredicate:authPredicate];
}

- (NSArray *)forceTransactionsForBridgePayFromArray:(NSArray *)array {
    NSPredicate *forcePredicate = [self predicateTransactionwith:@"ForceCapture"];
    return [array filteredArrayUsingPredicate:forcePredicate];
}

- (NSArray *)refundTransactionsForBridgePayFromArray:(NSArray *)array {
    NSPredicate *refundPredicate = [self predicateForRefundTransaction];
    return [array filteredArrayUsingPredicate:refundPredicate];
}

- (NSPredicate *)predicateTransactionwith:(NSString *)strTransType{
    return [NSPredicate predicateWithFormat:@"VoidSaleTrans  ==  %@ AND TransType == %@", @"0" ,strTransType ];
}

- (NSPredicate *)predicateForRefundTransaction {
    return [NSPredicate predicateWithFormat:@"TransType IN %@",@"Credit"];
}

- (void)updateHeaderDetailsForPax {
    float totalAmount = 0.00;
    NSInteger totalCount = 0;
    for (int index = 0; index < arrPaxReportEnum.count; index++) {
        totalAmount = totalAmount + [self calculateTotalAmount:index];
        totalCount = totalCount + [self calculateTotalCount:index];
    }
    NSString *strTotalAmount = [NSString stringWithFormat:@"%.2f", totalAmount];
    self.lblTotalAmount.text = [strTotalAmount applyCurrencyFormatter:strTotalAmount.floatValue];
    self.lblTotalCount.text = [NSString stringWithFormat:@"%ld", (long)totalCount];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItems;
    switch (selectedPaymentGateWay) {
        case BridgePay:
            numberOfItems = arrCardType.count;
            break;
            
        case Pax:
            numberOfItems = arrPaxReportEnum.count;
            break;
            
        default:
            break;
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceBatchSummaryCustomeCell *deviceBatchSummaryCustomeCell;
    switch (selectedPaymentGateWay) {
        case BridgePay:
            deviceBatchSummaryCustomeCell = [self configuareBridgePayDeviceBatchSummaryCollectionView:collectionView forItemAtIndexPath:indexPath];
            break;
            
        case Pax:
            deviceBatchSummaryCustomeCell = [self configuarePaxDeviceBatchSummaryCollectionView:collectionView forItemAtIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    return deviceBatchSummaryCustomeCell;
}

- (DeviceBatchSummaryCustomeCell *)configuareBridgePayDeviceBatchSummaryCollectionView:(UICollectionView *)collectionView forItemAtIndexPath:(NSIndexPath *)indexPath {
    DeviceBatchSummaryCustomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceBatchSummaryCustomeCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSString *cardType = [arrCardType objectAtIndex:indexPath.row];
    cell.lblPaymentType.text = [cardType uppercaseString];
    NSArray *arrFilteredDeviceSummary = [self deviceSummaryArrayByFilteringUsingCardType:cardType];
    NSArray *salesTransactions = [self salesTransactionsForBridgePayFromArray:arrFilteredDeviceSummary];
    NSArray *authTransactions = [self authTransactionsForBridgePayFromArray:arrFilteredDeviceSummary];
    NSArray *forceTransactions = [self forceTransactionsForBridgePayFromArray:arrFilteredDeviceSummary];
    NSArray *refundTransactions = [self refundTransactionsForBridgePayFromArray:arrFilteredDeviceSummary];
    CGFloat salesAmount = [[salesTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
    NSString *strSalesAmount = [NSString stringWithFormat:@"%.2f", salesAmount];
    NSString *strRefundAmount = [[refundTransactions valueForKeyPath:@"@sum.BillAmount"] stringValue];
    cell.lblSalesAmount.text = [strSalesAmount applyCurrencyFormatter:strSalesAmount.floatValue];
    cell.lblSalesCount.text = [NSString stringWithFormat:@"%ld", (long)salesTransactions.count];
    
    
    CGFloat authAmount = [[authTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
    NSString *strAuthAmount = [NSString stringWithFormat:@"%.2f", authAmount];
    cell.lblAuthAmount.text = [strAuthAmount applyCurrencyFormatter:strAuthAmount.floatValue];
    cell.lblAuthCount.text = [NSString stringWithFormat:@"%ld", (long)authTransactions.count];
    
    CGFloat forceAmount = [[forceTransactions valueForKeyPath:@"@sum.BillAmount"] floatValue];
    NSString *strForceAmount = [NSString stringWithFormat:@"%.2f", forceAmount];
    cell.lblForceAmount.text = [strForceAmount applyCurrencyFormatter:strForceAmount.floatValue];
    cell.lblForceCount.text = [NSString stringWithFormat:@"%ld", (long)forceTransactions.count];
    
    cell.lblPostAuthAmount.text = @"$0.00";
    cell.lblPostAuthCount.text = @"0";

    
    NSString *returnAmount;
    if (strRefundAmount.floatValue > 0) {
        returnAmount = [NSString stringWithFormat:@"-%@", [strRefundAmount applyCurrencyFormatter:strRefundAmount.floatValue]];
    }
    else {
        returnAmount = @"$0.00";
    }
    cell.lblReturnAmount.text = returnAmount;
    cell.lblReturnCount.text = [NSString stringWithFormat:@"%ld", (long)refundTransactions.count];
    float totalAmount = strSalesAmount.floatValue + strAuthAmount.floatValue + strForceAmount.floatValue - strRefundAmount.floatValue;
    NSString *strTotalAmount = [NSString stringWithFormat:@"%.2f", totalAmount];
    cell.lblTotalAmount.text = [strTotalAmount applyCurrencyFormatter:strTotalAmount.floatValue];
    cell.lblTotalCount.text = [NSString stringWithFormat:@"%ld", (long)(salesTransactions.count+authTransactions.count+forceTransactions.count+ refundTransactions.count)];
    return cell;
}

- (DeviceBatchSummaryCustomeCell *)configuarePaxDeviceBatchSummaryCollectionView:(UICollectionView *)collectionView forItemAtIndexPath:(NSIndexPath *)indexPath {
    DeviceBatchSummaryCustomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceBatchSummaryCustomeCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.lblPaymentType.text = [[self paymentType:indexPath] uppercaseString];
   
    NSString *saleAmount = [NSString stringWithFormat:@"%.2f",[[arrDeviceSummary[indexPath.row] valueForKey:@"SaleAmount"] floatValue]];
    saleAmount = [saleAmount applyCurrencyFormatter:saleAmount.floatValue];
    cell.lblSalesAmount.text = saleAmount;
    cell.lblSalesCount.text = [[arrDeviceSummary[indexPath.row] valueForKey:@"saleCount"] stringValue];
    
    NSString *authAmount = [NSString stringWithFormat:@"%.2f",[[arrDeviceSummary[indexPath.row] valueForKey:@"authAmount"] floatValue]];
    authAmount = [authAmount applyCurrencyFormatter:authAmount.floatValue];
    cell.lblAuthAmount.text = authAmount;
    cell.lblAuthCount.text = [[arrDeviceSummary[indexPath.row] valueForKey:@"authCount"] stringValue];
    if ([arrDeviceSummary[indexPath.row] valueForKey:@"authCount"] == nil) {
        cell.lblAuthCount.text = @"0";
    }
    NSString *forceAmount = [NSString stringWithFormat:@"%.2f",[[arrDeviceSummary[indexPath.row] valueForKey:@"forcedAmount"] floatValue]];
    forceAmount = [forceAmount applyCurrencyFormatter:forceAmount.floatValue];
    cell.lblForceAmount.text = forceAmount;
    cell.lblForceCount.text = [[arrDeviceSummary[indexPath.row] valueForKey:@"forcedCount"] stringValue];
    if ([arrDeviceSummary[indexPath.row] valueForKey:@"forcedCount"] == nil) {
        cell.lblForceCount.text = @"0";
    }
    NSString *postAuthAmount = [NSString stringWithFormat:@"%.2f",[[arrDeviceSummary[indexPath.row] valueForKey:@"postauthAmount"] floatValue]];
    postAuthAmount = [postAuthAmount applyCurrencyFormatter:postAuthAmount.floatValue];
    cell.lblPostAuthAmount.text = postAuthAmount;
    cell.lblPostAuthCount.text = [[arrDeviceSummary[indexPath.row] valueForKey:@"postauthCount"] stringValue];
    if ([arrDeviceSummary[indexPath.row] valueForKey:@"postauthCount"] == nil) {
        cell.lblPostAuthCount.text = @"0";
    }

    NSString *returnAmount = @"";
    if ([[arrDeviceSummary[indexPath.row] valueForKey:@"returnAmount"] floatValue] == 0) {
        returnAmount = @"$0.00";
    }
    else {
        returnAmount = [NSString stringWithFormat:@"-%.2f",[[arrDeviceSummary[indexPath.row] valueForKey:@"returnAmount"] floatValue]];
        returnAmount = [returnAmount applyCurrencyFormatter:returnAmount.floatValue];
    }
    cell.lblReturnAmount.text = returnAmount;
    cell.lblReturnCount.text = [[arrDeviceSummary[indexPath.row] valueForKey:@"returnCount"] stringValue];
    
    cell.lblTotalAmount.text = [self totalAmount:indexPath];
    cell.lblTotalCount.text = [self totalCount:indexPath];
    
    cell.salesDetailsView.layer.cornerRadius = 5.0;
    return cell;
}

- (NSString *)totalAmount:(NSIndexPath *)indexPath {
    NSString *totalAmount = @"";
    totalAmount = [NSString stringWithFormat:@"%.2f", [self calculateTotalAmount:indexPath.row]];
    totalAmount = [totalAmount applyCurrencyFormatter:totalAmount.floatValue];
    return totalAmount;
}

- (float)calculateTotalAmount:(NSInteger)index {
    float salesAmount = [[arrDeviceSummary[index] valueForKey:@"SaleAmount"] floatValue];
    float authAmount = [[arrDeviceSummary[index] valueForKey:@"authAmount"] floatValue];
    float forceAmount = [[arrDeviceSummary[index] valueForKey:@"forcedAmount"] floatValue];
    float postAuthAmount = [[arrDeviceSummary[index] valueForKey:@"postauthAmount"] floatValue];
    float returnAmount = [[arrDeviceSummary[index] valueForKey:@"returnAmount"] floatValue];
    
    float totalAmount = salesAmount + authAmount + forceAmount + postAuthAmount - returnAmount;
    return totalAmount;
}

- (NSString *)totalCount:(NSIndexPath *)indexPath {
    NSString *totalCount = @"";
    NSInteger totalCountInt = [self calculateTotalCount:indexPath.row];
    totalCount = [NSString stringWithFormat:@"%ld", (long)totalCountInt];
    return totalCount;
}

- (NSInteger)calculateTotalCount:(NSInteger)index {
    NSInteger totalCountInt = [[arrDeviceSummary[index] valueForKey:@"saleCount"] integerValue] + [[arrDeviceSummary[index] valueForKey:@"authCount"] integerValue] + [[arrDeviceSummary[index] valueForKey:@"forcedCount"] integerValue] + [[arrDeviceSummary[index] valueForKey:@"postauthCount"] integerValue] + [[arrDeviceSummary[index] valueForKey:@"returnCount"] integerValue];
    return totalCountInt;
}

- (NSString *)paymentType:(NSIndexPath *)indexPath {
    PaxLocalTotalReportDetails paxLocalTotalReportDetails = [arrPaxReportEnum[indexPath.row] integerValue];
    NSString *paymentType = @"";
    
    switch (paxLocalTotalReportDetails) {
        case PaxLocalTotalReportCredit:
            paymentType = @"Credit";
            break;
        case PaxLocalTotalReportDebit:
            paymentType = @"Debit";
            
            break;
        case PaxLocalTotalReportEBT:
            paymentType = @"EBT";
            
            break;
        case PaxLocalTotalReportGift:
            paymentType = @"Gift";
            
            break;
        case PaxLocalTotalReportLOYALTY:
            paymentType = @"Loyalty";
            
            break;
        case PaxLocalTotalReportCASH:
            paymentType = @"Cash";
            
            break;
        case PaxLocalTotalReportCHECK:
            paymentType = @"Check";
            
            break;
        default:
            break;
    }
    
    return paymentType;
}

- (NSArray *)deviceSummaryArrayByFilteringUsingCardType:(NSString *)cardType {
    NSPredicate *cardTypePredicate = [NSPredicate predicateWithFormat:@"CardType == %@",cardType];
    NSArray *filteredArray = [arrDeviceSummary filteredArrayUsingPredicate:cardTypePredicate];
    return filteredArray;
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
