//
//  CardTransactionRequestVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 5/10/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "CardTransactionRequestVC.h"
#import "CardTransactionRequestCell.h"
#import "PaxDevice.h"
#import "LocalDetailReportResponse.h"
#import "InitializeResponse.h"
#import "DoCreditResponse.h"
#import "RmsActivityIndicator.h"
#import "RmsDbController.h"
#import "CCBatchVC.h"
#import "RapidWebServiceConnection.h"
#import "RcrController.h"



typedef NS_ENUM(NSInteger, CardTransactionProcess) {
    ConfigurePaxDevice,
    ConfigureTransactionStatusFromPax,
};

@interface CardTransactionRequestVC ()<PaxDeviceDelegate>
{
    NSString *paxDeviceIP;
    NSString *paxDevicePort;
    PaxDevice *paxReportDetailDevice;
    NSInteger currentFetchRecordIndex;
    BOOL isSplitTransaction;
    BOOL isVoidTransaction;
    NSString *strInvoiceNumber;
    NSMutableArray *paxVoidArray;

}
@property (nonatomic, weak) IBOutlet UITableView *tblCardTransactionDetail;
@property (nonatomic, weak) IBOutlet UIButton *btnContinue;

@property (nonatomic, assign)int paxTransactionType;
@property(nonatomic,strong) PaxResponse *response;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, weak) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;

@property (nonatomic, strong) RapidWebServiceConnection *creditCardAutoConnection;

@property (nonatomic, strong) NSMutableArray *paymentModeItemsArray;



@end

@implementation CardTransactionRequestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    currentFetchRecordIndex = -1;
    self.rmsDbController  = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];

    self.creditCardAutoConnection = [[RapidWebServiceConnection alloc] init];
    [_btnContinue setTitle:@"CONTINUE" forState:UIControlStateNormal];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configureCreditCardPaymentData];
    [self initializationProcessForPax];

}

-(void)configureCreditCardPaymentData
{
    NSMutableArray *paymentModeItems = self.paymentData.paymentModes;
    self.paymentModeItemsArray = [[NSMutableArray alloc]init];
    NSInteger totalPaymentMode = 0 ;
    isSplitTransaction = NO;
    for (int i =0; i < paymentModeItems.count; i++) {
        NSMutableArray *paymentModeArray = paymentModeItems[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            if (item.actualAmount.floatValue + item.calculatedAmount.floatValue != 0 ) {
                totalPaymentMode ++;
            }
            if ([[item.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"Credit"]  || [[item.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"Debit"])
            {
                if ((item.creditTransactionId.length > 0 && item.actualAmount.floatValue + item.calculatedAmount.floatValue)!= 0 && item.isCreditCardSwipeApplicable == TRUE)
                {
                    [self.paymentModeItemsArray addObject:item];
                }
            }
        }
        
        if (totalPaymentMode > 1 ) {
            isSplitTransaction = YES;
        }
    }
}

-(void)configureTransactionStatusFromPax
{
    [self fetchNextCreditCardTransaction];
}

-(void)fetchNextCreditCardTransaction
{
    currentFetchRecordIndex++;
    
    if (currentFetchRecordIndex >= self.paymentModeItemsArray.count) {
        [_activityIndicator hideActivityIndicator];
        currentFetchRecordIndex = -1;
        return;
    }
    
    PaymentModeItem *paymentModeItem = [self.paymentModeItemsArray objectAtIndex:currentFetchRecordIndex];
 
    if ((paymentModeItem.creditCardTransactionStatus == nil && paymentModeItem.creditCardTransactionStatus.integerValue != Requesting) ) {
        [self fetchNextCreditCardTransaction];
        return;
    }
        [self fetchCreditCardTransactionWithDetail:paymentModeItem];
}

-(void)fetchCreditCardTransactionWithDetail:(PaymentModeItem *)paymentModeItem
{
    [_activityIndicator updateLoadingMessage:[NSString stringWithFormat:@"Fetching Detail Of %@ For Amount %.2f",paymentModeItem.creditTransactionId, paymentModeItem.actualAmount.floatValue + paymentModeItem.calculatedAmount.floatValue]];
    [paxReportDetailDevice getLocalDetailReportForReferenceNumber:paymentModeItem.creditTransactionId];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.paymentModeItemsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CardTransactionRequestCell";
    CardTransactionRequestCell *cell = (CardTransactionRequestCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (!cell)
    {
        cell = [[CardTransactionRequestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CardTransactionRequestCell"];
    }
    
    PaymentModeItem *paymentModeItem = self.paymentModeItemsArray[indexPath.row];
    
     cell.statusLabel.text = [NSString stringWithFormat:@"%@ ",[self transactionStatus:paymentModeItem.creditCardTransactionStatus]];
    
    cell.lblAmount.text = [NSString stringWithFormat:@"%.2f ",paymentModeItem.actualAmount.floatValue + paymentModeItem.calculatedAmount.floatValue];
    
    
    if (paymentModeItem.creditTransactionId.length <= 6 ) {
        cell.lblInvoice.text = paymentModeItem.creditTransactionId;
    }
    else
    {
        cell.lblInvoice.text = [paymentModeItem.creditTransactionId substringToIndex:paymentModeItem.creditTransactionId.length - 6];
    }
    if (paymentModeItem.creditTransactionId.length > 0) {
        cell.lblTransactionID.text = [NSString stringWithFormat:@"%@" , paymentModeItem.creditTransactionId];
    }
    else{
        cell.lblTransactionID.text = @"";
    }
    
    NSMutableDictionary *paxAdditionalFieldDictionary = [paymentModeItem.paymentModeDictionary valueForKey:@"PaxAdditionalFields"];

    NSString *transactionType = [self getTransationType:[[paxAdditionalFieldDictionary valueForKey:@"TransactionType"] integerValue]];
    cell.lblTransType.text = transactionType;
    
    if (isSplitTransaction == FALSE || ([transactionType isEqualToString:@"Void"] || [transactionType isEqualToString:@"MENU"])) {
        cell.btnVoid.hidden = YES;
        isVoidTransaction = FALSE;
    }
    else
    {
        cell.btnVoid.hidden = NO;
        isVoidTransaction = TRUE;
    }
    cell.btnVoid.tag = indexPath.row;
    [cell.btnVoid addTarget:self action:@selector(btnVoidClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
}


-(NSString *)transactionStatus:(NSNumber *)transactionStatusValue
{
    NSString *transactionStatus = @"";
    
    
    switch (transactionStatusValue.integerValue) {
        case Approved:
            transactionStatus = @"Approved";

            break;
        case PartialApproved:
            transactionStatus = @"PartialApproved";

            break;
        case Void:
            transactionStatus = @"Void";

            break;
        case Refund:
            transactionStatus = @"Refund";

            break;
        case Requesting:
            transactionStatus = @"Not Approved";
            break;
        default:
            transactionStatus = @"Not Approved";
            break;
    }
    return transactionStatus;
}

-(void)btnVoidClicked:(UIButton*)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblCardTransactionDetail];
    NSIndexPath *indexPath = [self.tblCardTransactionDetail indexPathForRowAtPoint:buttonPosition];
    PaymentModeItem *paymentModeItem = self.paymentModeItemsArray[indexPath.row];
    paxVoidArray = [[NSMutableArray alloc] init];
    if (indexPath != nil)
    {
        NSMutableDictionary *paxCreditCardVoidDictionary = [[NSMutableDictionary alloc] init];
        NSString *invoiceNumber =  [NSString stringWithFormat:@"%@" , paymentModeItem.creditTransactionId];
        if (paymentModeItem.creditTransactionId.length >= 6) {
            invoiceNumber = [paymentModeItem.creditTransactionId substringToIndex:paymentModeItem.creditTransactionId.length - 6];
        }
        paxCreditCardVoidDictionary[@"TransactionNo"] = paymentModeItem.transactionNo ;
        paxCreditCardVoidDictionary[@"TransactionId"] = paymentModeItem.creditTransactionId;
        paxCreditCardVoidDictionary[@"PaymentModeItem"] = paymentModeItem;
        [paxVoidArray addObject:paxCreditCardVoidDictionary];
        [self didPaxVoidCardTransactionWithTransactionNumber:paymentModeItem.transactionNo withInvoiceNumber:invoiceNumber withTransactionID:paymentModeItem.creditTransactionId];
    }
}

-(void)didPaxVoidCardTransactionWithTransactionNumber:(NSString *)transactionNumber withInvoiceNumber:(NSString *)invoiceNumber withTransactionID:(NSString *)transactionID
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    paxReportDetailDevice.pdResonse = PDResponseDoCash;
    [paxReportDetailDevice voidCreditTransactionNumber:transactionNumber invoiceNumber:invoiceNumber referenceNumber:transactionID];
}


#pragma Pax Delegate Method

- (void)initializationProcessForPax {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [self configureIPAndPortOfPaxDeviceAsPerSetting];
    [self initializePax];
}

- (void)configureIPAndPortOfPaxDeviceAsPerSetting {
    NSDictionary *dictDevice = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceConfig"];
    if (dictDevice != nil)
    {
        paxDeviceIP = dictDevice [@"PaxDeviceIp"];
        paxDevicePort = dictDevice [@"PaxDevicePort"];
    }
}

- (void)initializePax {
    if (paxReportDetailDevice == nil) {
        [self configurePaxDevice];
    }
    [paxReportDetailDevice initializeDevice];
}

- (void)configurePaxDevice
{
    paxReportDetailDevice = [[PaxDevice alloc] initWithIp:paxDeviceIP port:paxDevicePort];
    paxReportDetailDevice.paxDeviceDelegate = self;
}

- (void)paxDevice:(PaxDevice*)paxDevice willSendRequest:(NSString*)request
{
    
}

- (void)paxDevice:(PaxDevice*)paxDevice failed:(NSError*)error response:(PaxResponse *)response
{
    NSString *infoMessage = @"Pax response error";
    NSString *errorMessage = [NSString stringWithFormat:@"%@",response.responseMessage];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        if (response.responseCode.integerValue == 100021) {
            NSDictionary *paxVoidDictionary = paxVoidArray.lastObject;
            PaymentModeItem *paymentModeItem = (PaymentModeItem *)[paxVoidDictionary valueForKey:@"PaymentModeItem"];
            paymentModeItem.creditCardTransactionStatus = @(Void);
            [self resetPaymentModeItem:paymentModeItem];
            [self.cardTransactionRequestVCDelegate didUpdateCardTransactionWithPaymentData:self.paymentData];
            [self.paymentModeItemsArray removeObject:paymentModeItem];
            [paxVoidArray removeLastObject];
            [self configureCreditCardPaymentData];
        }
//        else if (response.responseCode.integerValue == 100023) {
//            PaymentModeItem *paymentModeItem = [self.paymentModeItemsArray objectAtIndex:currentFetchRecordIndex];
//            [self resetPaymentModeItem:paymentModeItem];
//            [self.cardTransactionRequestVCDelegate didUpdateCardTransactionWithPaymentData:self.paymentData];
//            [self configureCreditCardPaymentData];
//        }
        [_activityIndicator hideActivityIndicator];
    };
    [self.rmsDbController popupAlertFromVC:self title:infoMessage message:errorMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (void)paxDevice:(PaxDevice*)paxDevice response:(PaxResponse*)response
{
    
    if ([response isKindOfClass:[InitializeResponse class]]) {
        
        InitializeResponse *initializeResponse = (InitializeResponse *)response;
        if (initializeResponse.responseCode.integerValue == 0) {
            dispatch_async(dispatch_get_main_queue(),  ^{
                [self configureTransactionStatusFromPax];
            });
        }
    }
    else if ([response isKindOfClass:[LocalDetailReportResponse class]])
    {
        dispatch_async(dispatch_get_main_queue(),  ^{
            [self setLocalDetailReportResponse:response];
        });

    }
    else if ([response isKindOfClass:[DoCreditResponse class]])
    {
        [_activityIndicator hideActivityIndicator];
        
        [self setDoCreditResponse:response];
    }
}

-(void)setLocalDetailReportResponse:(PaxResponse *)response
{
    NSMutableDictionary *creditcardResponseDictionary = [[NSMutableDictionary alloc] init];
    
    if (response.responseCode.integerValue == 0) {
        LocalDetailReportResponse *cr = (LocalDetailReportResponse *)response;
        
        ResponseHostInformation *responseHostInformation = (ResponseHostInformation *)cr.hostInformation;
        
        CGFloat approvedAmount = cr.approvedAmount.floatValue/100;
        if (cr.transactionType.integerValue == EdcTransactionTypeReturn) {
            approvedAmount = -approvedAmount;
        }
        
        creditcardResponseDictionary[@"ApprovedAmount"] = @(approvedAmount);
        creditcardResponseDictionary[@"AuthCode"] = [NSString stringWithFormat:@"%@",responseHostInformation.authCode];
        creditcardResponseDictionary[@"TransactionNo"] = [NSString stringWithFormat:@"%@",cr.transactionNumber];
        creditcardResponseDictionary[@"AccNo"] = [NSString stringWithFormat:@"%@",cr.accountNumber];
        creditcardResponseDictionary[@"CardType"] = [NSString stringWithFormat:@"%@",[self cardTypeOf:cr.cardType.integerValue]];
        creditcardResponseDictionary[@"ExpireDate"] = [NSString stringWithFormat:@"%@",cr.expiryDate];
        creditcardResponseDictionary[@"CardHolderName"] = [NSString stringWithFormat:@"%@",cr.cardHolder];
        creditcardResponseDictionary[@"RefundTransactionNo"] = @"0.00";
        creditcardResponseDictionary[@"GatewayType"] = @"Pax";
        creditcardResponseDictionary[@"IsCreditCardSwipe"] = @"1";
        creditcardResponseDictionary[@"CreditTransactionId"] = [NSString stringWithFormat:@"%@",cr.referenceNumber];
        creditcardResponseDictionary[@"EntryMode"] = [NSString stringWithFormat:@"%@",cr.entryMode];
        creditcardResponseDictionary[@"TransactionType"] = [NSString stringWithFormat:@"%@",cr.transactionType];
        creditcardResponseDictionary[@"HostReferenceNumber"] = [NSString stringWithFormat:@"%@",responseHostInformation.hostReferenceNumber];
        creditcardResponseDictionary[@"BatchNo"] = [NSString stringWithFormat:@"%@",responseHostInformation.batchNumber];
        [self setCreditCardDictionaryWithDetail:creditcardResponseDictionary withAdditionalCreditcardDetail:cr.additionalInformation];
        
        if (isSplitTransaction == FALSE) {
            [_btnContinue setTitle:@"COMPLETE" forState:UIControlStateNormal];
        }
        else
        {
            [_btnContinue setTitle:@"CONTINUE" forState:UIControlStateNormal];

        }
        [_tblCardTransactionDetail reloadData];
        [self fetchNextCreditCardTransaction];
    }
}


-(void)setDoCreditResponse:(PaxResponse *)response
{
    if (response.responseCode.integerValue == 0) {
        DoCreditResponse *cr = (DoCreditResponse *)response;
        
        NSDictionary *paxVoidDictionary = paxVoidArray.lastObject;
        PaymentModeItem *paymentModeItem = (PaymentModeItem *)[paxVoidDictionary valueForKey:@"PaymentModeItem"];
        paymentModeItem.paymentModeDictionary = [self updatePaymentDictionaryWithDetail:[paxVoidDictionary mutableCopy] withPaymentModeItem:paymentModeItem];
        
        dispatch_async(dispatch_get_main_queue(),  ^{
            [self paxCreditCardLogWithDetail:[self insertPaxCreditCardLogWithDetail:[self parseCreditCardResponse:response] withCreditCardAdditionalDetail:cr.additionalInformation]];
        });
        [self resetPaymentModeItem:paymentModeItem];
        [self.paymentModeItemsArray removeObject:paymentModeItem];
        [self.cardTransactionRequestVCDelegate didUpdateCardTransactionWithPaymentData:self.paymentData];
        [paxVoidArray removeLastObject];
        [self configureCreditCardPaymentData];
    }
}

-(NSDictionary *)updatePaymentDictionaryWithDetail :(NSMutableDictionary *)creditCardDictionary withPaymentModeItem:(PaymentModeItem *)paymentmodeItem
{
    NSMutableDictionary *paymentModeDictionary = [paymentmodeItem.paymentModeDictionary mutableCopy];
    paymentModeDictionary[@"CardType"] = creditCardDictionary[@"CardType"];
    paymentModeDictionary[@"AuthCode"] = creditCardDictionary[@"AuthCode"];
    paymentModeDictionary[@"AccNo"] = creditCardDictionary[@"AccNo"];
    paymentModeDictionary[@"TransactionNo"] = creditCardDictionary[@"TransactionNo"];
    paymentModeDictionary[@"CardHolderName"] = creditCardDictionary[@"CardHolderName"];
    paymentModeDictionary[@"ExpireDate"] = creditCardDictionary[@"ExpireDate"];
    paymentModeDictionary[@"RefundTransactionNo"] = creditCardDictionary[@"RefundTransactionNo"];
    paymentModeDictionary[@"GatewayType"] = creditCardDictionary[@"GatewayType"];
    paymentModeDictionary[@"IsCreditCardSwipe"] = creditCardDictionary[@"IsCreditCardSwipe"];
    paymentModeDictionary[@"CreditTransactionId"] = creditCardDictionary[@"CreditTransactionId"];
    return paymentModeDictionary;
}


-(void)setCreditCardDictionaryWithDetail:(NSDictionary *)creditCardDictionary withAdditionalCreditcardDetail:(NSMutableDictionary *)additionalCreditCardDetail 
{
     PaymentModeItem *paymentModeItem = [self.paymentModeItemsArray objectAtIndex:currentFetchRecordIndex];
    paymentModeItem.paymentModeDictionary = [self updatePaymentDictionaryWithDetail:[creditCardDictionary mutableCopy] withPaymentModeItem:paymentModeItem];
    
    CGFloat totalAmountOfPaymentMode = paymentModeItem.actualAmount.floatValue + paymentModeItem.calculatedAmount.floatValue;
    CGFloat totalDifference = totalAmountOfPaymentMode - [[creditCardDictionary valueForKey:@"ApprovedAmount"] floatValue];
    if (totalDifference > 0.009) {
        
        [self.paymentData setActualAmount:[[creditCardDictionary valueForKey:@"ApprovedAmount"] floatValue] forpaymentMode:paymentModeItem];
        paymentModeItem.isPartialApprove = TRUE;
        paymentModeItem.creditCardTransactionStatus = @(PartialApproved);
    }
    else
    {
        paymentModeItem.creditCardTransactionStatus = @(Approved);
    }
    
    NSMutableDictionary *paxAdditionalFieldDictionary = [paymentModeItem.paymentModeDictionary valueForKey:@"PaxAdditionalFields"];
    paxAdditionalFieldDictionary[@"AppName"] = [self valueForKey:@"APPPN" ForDictionary:additionalCreditCardDetail];
    paxAdditionalFieldDictionary[@"AID"] = [self valueForKey:@"AID" ForDictionary:additionalCreditCardDetail];
    paxAdditionalFieldDictionary[@"ARQC"] = [self valueForKey:@"TC" ForDictionary:additionalCreditCardDetail];
    paxAdditionalFieldDictionary[@"RemainingBalance"] = [self valueForKey:@"RemainingBalance" ForDictionary:additionalCreditCardDetail];
    paxAdditionalFieldDictionary[@"CVM"] = [self valueForKey:@"CVM" ForDictionary:additionalCreditCardDetail];
    paxAdditionalFieldDictionary[@"SN"] = [self valueForKey:@"SN" ForDictionary:additionalCreditCardDetail];
    paxAdditionalFieldDictionary[@"EntryMode"] = [self valueForKey:@"EntryMode" ForDictionary:creditCardDictionary];
    paxAdditionalFieldDictionary[@"TransactionType"] = [self valueForKey:@"TransactionType" ForDictionary:creditCardDictionary];
    paxAdditionalFieldDictionary[@"PaxHostReferenceNumber"] = [self valueForKey:@"HostReferenceNumber" ForDictionary:creditCardDictionary];
    paxAdditionalFieldDictionary[@"BatchNo"] = [self valueForKey:@"BatchNo" ForDictionary:creditCardDictionary];
}

- (void)paxDevice:(PaxDevice*)paxDevice isConncted:(BOOL)isConncted
{
}
- (void)paxDeviceDidTimeout:(PaxDevice*)paxDevice
{
    
}


-(IBAction)btnCancelClick:(id)sender
{
    [_activityIndicator hideActivityIndicator];
    if ([self.paymentData isCreditCardApprovedPaymentMode] == TRUE)
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Please Void All Transaction ."] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self.cardTransactionRequestVCDelegate didCancelCardTransactionRequestProcess];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Do you want to Cancel this Process ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}


-(IBAction)btnContinueClick:(id)sender
{
    [_activityIndicator hideActivityIndicator];
    [self.cardTransactionRequestVCDelegate didUpdateCardTransactionWithPaymentData:self.paymentData];

    if ([_btnContinue.titleLabel.text  isEqual: @"COMPLETE"]) {
        [self.cardTransactionRequestVCDelegate didComplateCardTransactionWithPaymentData:self.paymentData];

    }
    else{
        [self.cardTransactionRequestVCDelegate didContinueCardTransactionRequestProcessWithPaymentArray:self.paymentModeItemsArray];
    }
}


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
            strTransationType = @"Authorization";
            break;
            
        case TRANSACTIONTYPEPOSTAUTH:
            strTransationType = @"POSTAUTH";
            break;
            
        case TRANSACTIONTYPEFORCED:
            strTransationType = @"ForceCapture";
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
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVSALE:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVRTRN:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVAUTH:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVPOST:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVFRCD:
            strTransationType = @"Void";
            break;
            
        case TRANSACTIONTYPEVWITHDRAW:
            strTransationType = @"Void";
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


-(void)resetPaymentModeItem:(PaymentModeItem *)paymentModeItem
{
    NSMutableDictionary *paymentDict=[[NSMutableDictionary alloc]init];
    paymentDict[@"CardIntType"] = paymentModeItem.paymentType;
    paymentDict[@"PayId"] = paymentModeItem.paymentId;
    paymentDict[@"PayImage"] = paymentModeItem.paymentImage;
    paymentDict[@"PaymentName"] = paymentModeItem.paymentName;
    paymentDict[@"CardType"] = @"";
    paymentDict[@"AuthCode"] = @"";
    paymentDict[@"AccNo"] = @"";
    paymentDict[@"TransactionNo"] = @"";//PNRef
    paymentDict[@"CardHolderName"] = @"";//cardName
    paymentDict[@"ExpireDate"] = @"";//ExpireDate
    paymentDict[@"RefundTransactionNo"] = @"";//RefundTransactionNo
    paymentDict[@"GatewayType"] = @"";//GatewayType
    paymentDict[@"IsCreditCardSwipe"] = @"0";//GatewayType
    paymentDict[@"TipsAmount"] = @"0";//TipsAmount
    paymentDict[@"SignatureImage"] = @"";//SignatureImage
    paymentDict[@"IsManualReceipt"] = @(0);//IsManualReceipt
    paymentDict[@"CreditTransactionId"] = @"";//CreditTransactionId
    paymentDict[@"PaxAdditionalFields"] = [self paxAdditionalFields];////PaxAdditionalFields
    paymentDict[@"GiftCardNumber"] = @"";////GiftCardNumber
    paymentDict[@"GiftCardApprovedAmount"] = @(0.00);////GiftCardApprovedAmount
    paymentDict[@"IsGiftCardApproved"] = @"0";////GiftCardApproveAmount
    paymentDict[@"GiftCardBalanceAmount"] = @(0.00);////GiftCardBalanceAmount
    paymentDict[@"CreditCardSwipeApplicable"] = @(paymentModeItem.isCreditCardSwipeApplicable);
    paymentModeItem.isPartialApprove = FALSE;
    paymentModeItem.paymentModeDictionary = paymentDict;
    paymentModeItem.creditCardTransactionStatus = nil;
    paymentModeItem.creditTransactionId = @"";
    paymentModeItem.transactionNo = @"";
    [self.paymentData setActualAmount:0.00 forpaymentMode:paymentModeItem];
    dispatch_async(dispatch_get_main_queue(),  ^{
        [self.tblCardTransactionDetail reloadData];
    });
}

-(void)paxCreditCardLogWithDetail:(NSMutableDictionary *)paxResponseDict
{
    
    NSMutableDictionary *objCreditCardAuto = [[NSMutableDictionary alloc]init];
    objCreditCardAuto[@"objCreditCardAuto"] = paxResponseDict;
    
    NSLog(@"JSON PAX%@", [self.rmsDbController jsonStringFromObject:objCreditCardAuto]);
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self CreditCardAutoResponse:response error:error];
    };
    
    self.creditCardAutoConnection = [self.creditCardAutoConnection initWithRequest:KURL actionName:WSM_CREDIT_CARD_LOG params:objCreditCardAuto completionHandler:completionHandler];
    
}
- (void)CreditCardAutoResponse:(id)response error:(NSError *)error
{
    
}

-(NSMutableDictionary *)insertPaxCreditCardLogWithDetail:(NSDictionary *)creditcardDetail withCreditCardAdditionalDetail:(NSMutableDictionary *)additionalDetailDict {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSString *sInvAmt = creditcardDetail[@"ApprovedAmount"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    
    NSMutableDictionary *paxResponceDict = [[NSMutableDictionary alloc]init];
    paxResponceDict[@"CreditcardDetail"] = creditcardDetail;
    
    if (additionalDetailDict != nil) {
        paxResponceDict[@"AdditionalDetailDict"] = additionalDetailDict;
    }
    else {
        paxResponceDict[@"AdditionalDetailDict"] = @"";
    }
    
    dict[@"Id"] = @(0);
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"TransactionId"] = creditcardDetail[@"TransactionNo"];
    dict[@"TransType"] = creditcardDetail[@"TransactionType"];
    dict[@"Amount"] = sInvAmt;
    dict[@"InvNum"] = strInvoiceNumber;
    dict[@"MagData"] = @"";
    dict[@"ExtData"] = @"";
    dict[@"RespMSG"] = @"OK";
    dict[@"Message"] = @"OK";
    dict[@"AuthCode"] = [creditcardDetail valueForKey:@"AuthCode"];
    dict[@"HostCode"] = [creditcardDetail valueForKey:@"HostReferenceNumber"];
    dict[@"CommercialCard"] = @"";
    dict[@"GateWayType"] = @"Pax";
    dict[@"Response"] = [NSString stringWithFormat:@"%@",[self.rmsDbController jsonStringFromObject:paxResponceDict]];
    dict[@"CreatedDate"] = currentDateTime;
    dict[@"CardNo"] = @"";
    
    return dict;
}

-(NSMutableDictionary *)parseCreditCardResponse:(PaxResponse *)response
{
    self.response = response;
    DoCreditResponse *cr = (DoCreditResponse *)response;
    NSMutableDictionary *creditcardResponseDictionary = [[NSMutableDictionary alloc] init];
    if (cr.responseCode.integerValue == 0) {
        
        ResponseHostInformation *responseHostInformation = (ResponseHostInformation *)cr.hostInformation;
        creditcardResponseDictionary[@"AuthCode"] = [NSString stringWithFormat:@"%@",responseHostInformation.authCode];
        creditcardResponseDictionary[@"TransactionNo"] = [NSString stringWithFormat:@"%@",cr.transactionNumber];
        creditcardResponseDictionary[@"AccNo"] = [NSString stringWithFormat:@"%@",cr.accountNumber];
        creditcardResponseDictionary[@"CardType"] = [NSString stringWithFormat:@"%@",[self cardTypeOf:cr.cardType.integerValue]];
        creditcardResponseDictionary[@"ExpireDate"] = [NSString stringWithFormat:@"%@",cr.expiryDate];
        creditcardResponseDictionary[@"CardHolderName"] = [NSString stringWithFormat:@"%@",cr.cardHolder];
        creditcardResponseDictionary[@"RefundTransactionNo"] = @"0.00";
        creditcardResponseDictionary[@"GatewayType"] = @"Pax";
        creditcardResponseDictionary[@"IsCreditCardSwipe"] = @"1";
        creditcardResponseDictionary[@"CreditTransactionId"] = @"";
        creditcardResponseDictionary[@"EntryMode"] = [NSString stringWithFormat:@"%@",cr.entryMode];
        
        creditcardResponseDictionary[@"TransactionType"] = [NSString stringWithFormat:@"%@",cr.transactionType];
        
        self.paxTransactionType = [creditcardResponseDictionary[@"TransactionType"] intValue];
        
        creditcardResponseDictionary[@"Invoice"] = @"Void";
        NSDictionary *additionalCreditCardDetail = cr.additionalInformation;
        creditcardResponseDictionary[@"HostReferenceNumber"] = [NSString stringWithFormat:@"%@",responseHostInformation.hostReferenceNumber];
        creditcardResponseDictionary[@"AppName"] = [self valueForKey:@"APPPN" ForDictionary:additionalCreditCardDetail];
        creditcardResponseDictionary[@"AID"] = [self valueForKey:@"AID" ForDictionary:additionalCreditCardDetail];
        creditcardResponseDictionary[@"ARQC"] = [self valueForKey:@"TC" ForDictionary:additionalCreditCardDetail];
        creditcardResponseDictionary[@"RemainingBalance"] = [self valueForKey:@"RemainingBalance" ForDictionary:additionalCreditCardDetail];
        creditcardResponseDictionary[@"CVM"] = [self valueForKey:@"CVM" ForDictionary:additionalCreditCardDetail];
    }
    return creditcardResponseDictionary;
}

-(NSString *)cardTypeOf:(NSInteger)cardType
{
    NSString *creditCardType = @"";
    switch (cardType) {
        case VisaCard:
            creditCardType = @"VISA";
            break;
        case MasterCard:
            creditCardType = @"MASTER";
            break;
        case  AMEX:
            creditCardType = @"AMEX";
            break;
        case  Discover:
            creditCardType = @"Discover";
            break;
        case  DinerClub:
            creditCardType = @"DinerClub";
            break;
        case enRoute:
            creditCardType = @"enRoute";
            break;
        case  JCB :
            creditCardType = @"JCB";
            break;
        case RevolutionCard:
            creditCardType = @"RevolutionCard";
            break;
            
        default:
        case  OTHER:
            creditCardType = @"OTHER";
            
            break;
    }
    return creditCardType;
}

-(NSString *)valueForKey:(NSString *)key ForDictionary:(NSDictionary *)paxAdditionalFieldsDictionary
{
    NSString *value = @"";
    if ([paxAdditionalFieldsDictionary valueForKey:key]) {
        value = [paxAdditionalFieldsDictionary valueForKey:key];
    }
    return value;
}

-(NSMutableDictionary *)paxAdditionalFields
{
    NSMutableDictionary *paxAdditionalFieldsDictionary = [[NSMutableDictionary alloc] init];
    paxAdditionalFieldsDictionary[@"AppName"] = @"";
    paxAdditionalFieldsDictionary[@"AID"] = @"";
    paxAdditionalFieldsDictionary[@"ARQC"] = @"";
    paxAdditionalFieldsDictionary[@"EntryMode"] = @"";
    paxAdditionalFieldsDictionary[@"RemainingBalance"] = @"";
    paxAdditionalFieldsDictionary[@"CVM"] = @"";
    paxAdditionalFieldsDictionary[@"SN"] = @"";
    paxAdditionalFieldsDictionary[@"TransactionType"] = @"";
    paxAdditionalFieldsDictionary[@"PaxHostReferenceNumber"] = @""; /////PaxHostReferenceNumber
    paxAdditionalFieldsDictionary[@"PaxSerialNo"] = @""; /////PaxSerialNo
    paxAdditionalFieldsDictionary[@"BatchNo"] = @""; /////BatchNo
    
    return paxAdditionalFieldsDictionary;
    
}


@end
