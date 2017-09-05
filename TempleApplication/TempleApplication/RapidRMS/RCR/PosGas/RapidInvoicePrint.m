//
//  RapidInvoicePrint.m
//  RapidRMS
//
//  Created by siya-IOS5 on 11/27/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RapidInvoicePrint.h"
#import "RmsDbController.h"
#import "LastInvoiceReceiptPrint.h"
#import "LastGasInvoiceReceiptPrint.h"
#import "LastPostpayGasInvoiceReceiptPrint.h"
#import "LastInvoiceData.h"
#import "PassPrinting.h"
#import "CardReceiptPrint.h"
#import "PaxEMVCardReceipt.h"
#import "PaxMagneticCardReceipt.h"
#import "PaxConstants.h"
#import "GiftCardReceiptPrint.h"
#import "HouseChargeReceiptPrint.h"
#import "RapidCustomerLoyalty.h"
#import "InvoiceDetail.h"
#import "UpdateManager.h"
#import "Customer.h"

typedef NS_ENUM(NSInteger, RapidPrintProcess) {
    RapidInvoice_PrintBegin,
    RapidInvoice_PassPrint,
    RapidInvoice_CardPrint,
    RapidInvoice_InvoicePrint,
    RapidInvoice_GiftCardPrint,
    RapidInvoice_HouseCharge,
    RapidInvoice_HouseCharge_Signature,
    RapidInvoice_PrintDone,
    RapidInvoice_PrintCancel,
};

@interface RapidInvoicePrint ()<PrinterFunctionsDelegate>
{
    NSInteger currentPrintStep;
    NSInteger signaturePrintStep;

    NSMutableArray *locallastInvoiceTicketPassArray;
    NSMutableArray *itemDetails;
    NSMutableArray *paymentDetails;
    NSMutableArray *masterDetails;
    NSMutableArray *arrayPumpCart;
    NSString *printerPortName;
    NSString *printerPortSetting;
    NSNumber *tipSettings;
    UIViewController *presentedInViewController;
    NSMutableArray *filterManualReceiptDetaiArray;
    NSMutableArray *tipPercentageDetail;
    NSString *changeDueValue;
    NSMutableArray *houseChargePrintDetail;
    NSMutableArray *giftCardPrintDetailArray;
    RapidCustomerLoyalty *rapidCustomerLoyalty;
    CGFloat balanceAmount;
}
@property (nonatomic,strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic,strong) RapidWebServiceConnection *checkGiftCardBalanceAmountConnection;
@property (nonatomic, strong) RapidWebServiceConnection *CheckHouseChargeCreditLimitWC;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation RapidInvoicePrint

-(instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings ItemDetail:(NSMutableArray *)itemDetail withPaymentDetail:(NSMutableArray *)paymentDetail withMasterDetails:(NSMutableArray *)masterDetail fromViewController:(UIViewController *)viewController withTipSetting:(NSNumber *)tipSettting tipsPercentArray:(NSMutableArray *)tipPercentageArray withChangeDue:(NSString *)changeDue withPumpCart:(NSMutableArray *)pumpCartDetail;
{
    self = [super init];
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        itemDetails = itemDetail;
        paymentDetails = paymentDetail;
        masterDetails = masterDetail;
        arrayPumpCart = pumpCartDetail;
        printerPortName = portName;
        printerPortSetting = portSettings;
        self.managedObjectContext = self.rmsDbController.managedObjectContext;

        [self configureItemTicketsPrintArrayForLastInvoice:itemDetails];

        currentPrintStep = RapidInvoice_PrintBegin;
        signaturePrintStep = 0;
        presentedInViewController = viewController;
        tipSettings = tipSettting;
        tipPercentageDetail = tipPercentageArray;
        changeDueValue = changeDue;
    }
    return self;
}
-(void)startPrint
{
    [self nextPrint];
}

- (void)configureItemTicketsPrintArrayForLastInvoice:(NSArray *)itemDetail
{
    locallastInvoiceTicketPassArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *item in itemDetail) {
        if (item[@"ItemTicketDetail"]) {
            NSArray * itemTicketDetail = item[@"ItemTicketDetail"];
            if ([itemTicketDetail isKindOfClass:[NSArray class]] && itemTicketDetail.count > 0) {
                
                for (NSMutableDictionary *itemTicketDictionary in itemTicketDetail) {
                    itemTicketDictionary[@"InvoiceNo"] = [masterDetails.firstObject valueForKey:@"RegisterInvNo"];
                    itemTicketDictionary[@"ItemName"] = [item valueForKey:@"ItemName"];
                    [locallastInvoiceTicketPassArray addObject:itemTicketDictionary];
                }
            }
        }
    }
}

- (void)nextPrint
{
    BOOL isApplicable = FALSE;
    currentPrintStep++;
    
    switch (currentPrintStep) {
        
        case RapidInvoice_PrintBegin:
            break;
        
        case RapidInvoice_PassPrint:
            if (locallastInvoiceTicketPassArray.count > 0) {
                isApplicable = TRUE;
                [self nextPassPrint];
            }
            break;
        
        case RapidInvoice_CardPrint:
            [self printCardReciept];
            isApplicable = TRUE;
            
            break;
        
        case RapidInvoice_InvoicePrint:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self printInvoiceReceipt];
            });
            isApplicable = TRUE;
        }
            break;
            
        case RapidInvoice_GiftCardPrint:
        {
            isApplicable = TRUE;
            [self printGiftCardReceipt];

        }
            break;
    
        case RapidInvoice_HouseCharge:
        {
            isApplicable = TRUE;
            [self printHouseChargeReceipt:FALSE];
            currentPrintStep++;

        }
            break;
        case RapidInvoice_HouseCharge_Signature:
        {
            isApplicable = TRUE;
            [self printHouseChargeReceipt:TRUE];
            currentPrintStep++;

        }
            break;

        case RapidInvoice_PrintDone:
            isApplicable = TRUE;
            [self.rapidInvoicePrintDelegate didFinishPrintProcessSuccessFully];
            break;

        case RapidInvoice_PrintCancel:
            isApplicable = TRUE;
            [self.rapidInvoicePrintDelegate didFailPrintProcess];
            break;
    
    }
    if (isApplicable == FALSE) {
        [self nextPrint];
    }
}

- (void)nextPassPrint
{
    if (locallastInvoiceTicketPassArray.count == 0) {
        [self nextPrint];
        return;
    }
    
    PassPrinting *passPrinting = [[PassPrinting alloc] init];
    passPrinting._printingData = locallastInvoiceTicketPassArray.lastObject;
    [passPrinting printingWithPort:printerPortName portSettings:printerPortSetting withDelegate:self];
}

-(NSMutableArray *)isManualCreditCardPrintAvailable :(NSArray *)paymentArray
{
    filterManualReceiptDetaiArray = [[NSMutableArray alloc] init];
    
    if([paymentArray isKindOfClass:[NSArray class]] && paymentArray.count > 0){
        
        for(int i = 0;i<paymentArray.count;i++)
        {
            NSMutableDictionary *paymentDict = paymentArray[i];
            
            if([[paymentDict valueForKey:@"AuthCode"]length]>0 && [[paymentDict valueForKey:@"CardType"]length]>0 && [[paymentDict valueForKey:@"TransactionNo"]length]>0 && [[paymentDict valueForKey:@"AccNo"]length]>0)
            {
                if (!([[paymentDict valueForKey:@"SignatureImage"]length] >0))
                {
                    [filterManualReceiptDetaiArray addObject:paymentDict];
                }
            }
        }
    }
    
    return filterManualReceiptDetaiArray;
}



-(void)printCardReciept
{
    if ([self isManualCreditCardPrintAvailable:paymentDetails] > 0)
    {
        [self processNextCardReceipt];
    }
    else
    {
        [self nextPrint];
    }
}

- (NSString *)lastInvoiceRecieptDate:(NSString *)strLastInvoiceDate
{
    if ([strLastInvoiceDate isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSDate *lastInvoiceDate = [dateFormatter dateFromString:strLastInvoiceDate];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    dateFormatter2.dateFormat = @"MM/dd/yyyy hh:mm a";
    return [dateFormatter2 stringFromDate:lastInvoiceDate];
}
-(void)processNextCardReceipt
{
    if (filterManualReceiptDetaiArray.count == 0) {
        [self nextPrint];
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self printCardReceipts:filterManualReceiptDetaiArray.lastObject];
    });
}

-(void)printCardReceipts:(NSMutableDictionary *)dictionary
{
    NSString *lastInvoiceDate = [self lastInvoiceRecieptDate:[masterDetails.firstObject valueForKey:@"Datetime"]];
    NSMutableArray *paymentArray = [[NSMutableArray alloc] init];
    [paymentArray addObject:dictionary];
    
    
    CardReceiptPrint *cardReceiptPrint;
    
    if ([[dictionary valueForKey:@"GatewayType"] isEqualToString:@"Pax"] )
    {
        NSDictionary *paxAdditionalFieldsDictionary = [self.rmsDbController objectFromJsonString:[dictionary valueForKey:@"GatewayResponse"]];
        if (paxAdditionalFieldsDictionary != nil) {
            if ([[paxAdditionalFieldsDictionary valueForKey:@"EntryMode"] integerValue] == Swipe) {
                cardReceiptPrint = [[PaxMagneticCardReceipt alloc] initWithPortName:printerPortName portSetting:printerPortSetting withPaymentDatail:paymentArray tipSetting:tipSettings tipsPercentArray:tipPercentageDetail receiptDate:lastInvoiceDate];
            }
            else
            {
                cardReceiptPrint = [[PaxEMVCardReceipt alloc] initWithPortName:printerPortName portSetting:printerPortSetting withPaymentDatail:paymentArray tipSetting:tipSettings tipsPercentArray:tipPercentageDetail receiptDate:lastInvoiceDate];
            }
        }
    }
    else
    {
        cardReceiptPrint = [[CardReceiptPrint alloc] initWithPortName:printerPortName portSetting:printerPortSetting withPaymentDatail:paymentArray tipSetting:tipSettings tipsPercentArray:tipPercentageDetail receiptDate:lastInvoiceDate];
    }
    cardReceiptPrint.isVoidCardReceipt = self.isVoidInvoice;
    [cardReceiptPrint printCardReceiptForInvoiceNo:[masterDetails.firstObject valueForKey:@"RegisterInvNo"] withDelegate:self];
}

-(void)printHouseChargeReceipt:(BOOL)isSignature
{
    houseChargePrintDetail = [NSMutableArray array];
    
    
    NSPredicate *predicateForHouseChargeItem = [NSPredicate predicateWithFormat:@"ItemName == %@",@"HouseCharge"];
    NSArray *houseChargeItemArray = [itemDetails filteredArrayUsingPredicate:predicateForHouseChargeItem];
    
    NSPredicate *predicateForHouseChargePayment = [NSPredicate predicateWithFormat:@"CardType == %@",@"HouseCharge"];
    NSArray *houseChargePaymentArray = [paymentDetails filteredArrayUsingPredicate:predicateForHouseChargePayment];

    if(_isFromCustomerLoyalty == TRUE){
        if (houseChargeItemArray.count > 0 || houseChargePaymentArray.count > 0  ) {
            NSMutableDictionary *houseChargeDictionary = [[NSMutableDictionary alloc]init];
            
            houseChargeDictionary[@"Custid"] = [_rapidCustomerArray.firstObject valueForKey:@"Custid"];
            houseChargeDictionary[@"CustName"] = [_rapidCustomerArray.firstObject valueForKey:@"CustName"];
            houseChargeDictionary[@"CustEmail"] = [_rapidCustomerArray.firstObject valueForKey:@"CustEmail"];
            houseChargeDictionary[@"CustContactNo"] = [_rapidCustomerArray.firstObject valueForKey:@"CustContactNo"];
            houseChargeDictionary[@"AvailableBalance"] = [_rapidCustomerArray.firstObject valueForKey:@"AvailableBalance"];
            houseChargeDictionary[@"CreditLimit"] = [_rapidCustomerArray.firstObject valueForKey:@"CreditLimit"];
            
            [houseChargePrintDetail addObject:houseChargeDictionary];
        }
        [self printNextHouseCharge:isSignature];

    }
    else{
        if (houseChargeItemArray.count > 0 || houseChargePaymentArray.count > 0  ) {
            NSMutableDictionary *houseChargeDictionary = [[NSMutableDictionary alloc]init];
            
            houseChargeDictionary[@"Custid"] = [_rapidCustomerArray.firstObject valueForKey:@"Custid"];
            houseChargeDictionary[@"CustName"] = [_rapidCustomerArray.firstObject valueForKey:@"CustName"];
            houseChargeDictionary[@"CustEmail"] = [_rapidCustomerArray.firstObject valueForKey:@"CustEmail"];
            houseChargeDictionary[@"CustContactNo"] = [_rapidCustomerArray.firstObject valueForKey:@"CustContactNo"];
            houseChargeDictionary[@"AvailableBalance"] = [_rapidCustomerArray.firstObject valueForKey:@"AvailableBalance"];
            houseChargeDictionary[@"CreditLimit"] = [_rapidCustomerArray.firstObject valueForKey:@"CreditLimit"];
            
            [houseChargePrintDetail addObject:houseChargeDictionary];
        }
        
        [self printNextHouseCharge:isSignature];
  
    }

}

-(void)printNextHouseCharge:(BOOL)isSignature{
    
    
    if (houseChargePrintDetail.count == 0) {
        [self nextPrint];
        return;
    }
    NSString *receiptDate = [NSString stringWithFormat:@"%@",[masterDetails.firstObject valueForKey:@"Datetime"]];

    HouseChargeReceiptPrint *houseChargeReceiptPrint = [[HouseChargeReceiptPrint alloc]init];
    houseChargeReceiptPrint = [houseChargeReceiptPrint initWithPortName:printerPortName portSetting:printerPortSetting printData:houseChargePrintDetail withReceiptDate:receiptDate withIsSignature:isSignature];
    [houseChargeReceiptPrint printHouseChargeReceiptWithDelegate:self];

    
}

-(void)printGiftCardReceipt
{
    giftCardPrintDetailArray = [[NSMutableArray alloc]init];
    NSPredicate *predicateForGiftCardItem = [NSPredicate predicateWithFormat:@"ItemName == %@",@"RapidRMS Gift Card"];
    
    NSArray *giftCardItemArray = [itemDetails filteredArrayUsingPredicate:predicateForGiftCardItem];
    for (NSDictionary *giftCardItemDictionary in giftCardItemArray) {
        NSMutableDictionary *giftCardPrintDetailDictionary = [[NSMutableDictionary alloc] init];
        giftCardPrintDetailDictionary[@"GiftCardNumber"] = giftCardItemDictionary[@"CardNo"];
        [giftCardPrintDetailArray addObject:giftCardPrintDetailDictionary];
    }
    NSPredicate *predicateForGiftCardPayment = [NSPredicate predicateWithFormat:@"CardType == %@",@"RMSGiftCard"];
    NSArray *giftCardPaymentArray = [paymentDetails filteredArrayUsingPredicate:predicateForGiftCardPayment];
    
    for (NSDictionary *giftCardPaymentDictionary in giftCardPaymentArray) {
        NSMutableDictionary *giftCardPrintDetailDictionary = [[NSMutableDictionary alloc] init];
        giftCardPrintDetailDictionary[@"GiftCardNumber"] = giftCardPaymentDictionary[@"AccNo"];
        [giftCardPrintDetailArray addObject:giftCardPrintDetailDictionary];
    }
    [self printNextGiftCard];
}


-(void)printNextGiftCard
{
    if (giftCardPrintDetailArray.count == 0) {
        [self nextPrint];
        return;
    }
    [self checkBalancebeforGiftCardNumber:giftCardPrintDetailArray.lastObject];
}

-(void)checkBalancebeforGiftCardNumber:(NSMutableDictionary *)giftcardDictionary{
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:presentedInViewController.view];
        NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
        [param setValue:giftcardDictionary[@"GiftCardNumber"] forKey:@"CRDNumber"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self checkBalancebeforePaymentResponse:response error:error];
            });
        };
        
        self.checkGiftCardBalanceAmountConnection = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_CHECK_BALANCE_RAPID_GIFTCARD params:param completionHandler:completionHandler];
}
- (void)checkBalancebeforePaymentResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *dictBalance = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                
                NSMutableDictionary *giftcardPaymentDictionary = giftCardPrintDetailArray.lastObject;
                [giftcardPaymentDictionary setObject:[dictBalance valueForKey:@"Balance"] forKey:@"GiftCardTotalBalance"];
                
                NSString *lastInvoiceDate = [self lastInvoiceRecieptDate:[masterDetails.firstObject valueForKey:@"Datetime"]];

                
                GiftCardReceiptPrint *giftCardReceiptPrint = [[GiftCardReceiptPrint alloc] initWithPortName:printerPortName portSetting:printerPortSetting printData:giftcardPaymentDictionary withReceiptDate:lastInvoiceDate];
                [giftCardReceiptPrint printGiftCardReceiptWithDelegate:self];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:presentedInViewController title:@"Message" message:@"Error occur while sending details" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


-(void)printInvoiceReceipt
{
    NSArray *itemDetail = [self itemDetailDictionary:itemDetails];
    
    NSString *lastInvoiceDate = [self lastInvoiceRecieptDate:[masterDetails.firstObject valueForKey:@"Datetime"]];
    
    if([self.rmsDbController checkGasPumpisActive] && arrayPumpCart.count > 0){
        
        if([self isPrepayTransaction:arrayPumpCart]){
          
            LastGasInvoiceReceiptPrint *gaslastInvoiceReceiptPrint = [[LastGasInvoiceReceiptPrint alloc] initWithPortName:printerPortName portSetting:printerPortSetting printData:itemDetail withPaymentDatail:paymentDetails tipSetting:tipSettings tipsPercentArray:tipPercentageDetail receiptDate:lastInvoiceDate];
            gaslastInvoiceReceiptPrint.arrPumpCartArray = arrayPumpCart;
            gaslastInvoiceReceiptPrint.isInvoiceReceipt = self.isInvoiceReceipt;
            gaslastInvoiceReceiptPrint.registerName = self.registerName;
            gaslastInvoiceReceiptPrint.cashierName = self.cashierName;
            gaslastInvoiceReceiptPrint.isVoidInvoicePrint = self.isVoidInvoice;
            [gaslastInvoiceReceiptPrint printInvoiceReceiptForInvoiceNo:[masterDetails.firstObject valueForKey:@"RegisterInvNo"] withChangeDue:changeDueValue withDelegate:self];
        }
        else{
            LastPostpayGasInvoiceReceiptPrint *postpaylastInvoiceReceiptPrint = [[LastPostpayGasInvoiceReceiptPrint alloc] initWithPortName:printerPortName portSetting:printerPortSetting printData:itemDetail withPaymentDatail:paymentDetails tipSetting:tipSettings tipsPercentArray:tipPercentageDetail receiptDate:lastInvoiceDate];
            postpaylastInvoiceReceiptPrint.arrPumpCartArray = arrayPumpCart;
            postpaylastInvoiceReceiptPrint.isInvoiceReceipt = self.isInvoiceReceipt;
            postpaylastInvoiceReceiptPrint.registerName = self.registerName;
            postpaylastInvoiceReceiptPrint.cashierName = self.cashierName;
            postpaylastInvoiceReceiptPrint.isVoidInvoicePrint = self.isVoidInvoice;
            [postpaylastInvoiceReceiptPrint printInvoiceReceiptForInvoiceNo:[masterDetails.firstObject valueForKey:@"RegisterInvNo"] withChangeDue:changeDueValue withDelegate:self];
        }
    }
    else{
        LastInvoiceReceiptPrint *lastInvoiceReceiptPrint = [[LastInvoiceReceiptPrint alloc] initWithPortName:printerPortName portSetting:printerPortSetting printData:itemDetail withPaymentDatail:paymentDetails tipSetting:tipSettings tipsPercentArray:tipPercentageDetail receiptDate:lastInvoiceDate];
        lastInvoiceReceiptPrint.isInvoiceReceipt = self.isInvoiceReceipt;
        lastInvoiceReceiptPrint.registerName = self.registerName;
        lastInvoiceReceiptPrint.cashierName = self.cashierName;
        lastInvoiceReceiptPrint.isVoidInvoicePrint = self.isVoidInvoice;
        [lastInvoiceReceiptPrint printInvoiceReceiptForInvoiceNo:[masterDetails.firstObject valueForKey:@"RegisterInvNo"] withChangeDue:changeDueValue withDelegate:self];
    }
    
}

- (NSArray *)itemDetailDictionary:(NSArray *)itemDetailsArray
{
    if (itemDetailsArray.count > 0 ) {
        for (NSMutableDictionary *dict in itemDetailsArray) {
            NSMutableDictionary *dictToAdd = [[NSMutableDictionary alloc] init];
            dictToAdd[@"CheckCashCharge"] = [dict valueForKey:@"CheckCashAmount"];
            dictToAdd[@"ExtraCharge"] = [dict valueForKey:@"ExtraCharge"];
            if ([[dict valueForKey:@"ExtraCharge"] floatValue] > 0) {
                dictToAdd[@"isExtraCharge"] = @(1);
            }
            else
            {
                dictToAdd[@"isExtraCharge"] = @(0);
            }
            dictToAdd[@"isAgeApply"] = [dict valueForKey:@"isAgeApply"];
            dictToAdd[@"isCheckCash"] = [dict valueForKey:@"isCheckCash"];
            dictToAdd[@"isDeduct"] = [dict valueForKey:@"isDeduct"];
            dict[@"Item"] = dictToAdd;
        }
    }
    return itemDetailsArray;
}

-(void)printerTaskDidSuccessWithDevice:(NSString *)device
{
    if ([device isEqualToString:@"Printer"]) {
        if (currentPrintStep == RapidInvoice_PassPrint) {
            [locallastInvoiceTicketPassArray removeLastObject];
            [self nextPassPrint];
        }
       else if (currentPrintStep == RapidInvoice_CardPrint) {
            [filterManualReceiptDetaiArray removeLastObject];
            [self processNextCardReceipt];
        }
       else if (currentPrintStep == RapidInvoice_GiftCardPrint) {
           [giftCardPrintDetailArray removeLastObject];
           [self printNextGiftCard];
       }
       else if (currentPrintStep == RapidInvoice_HouseCharge) {
           [self printHouseChargeReceipt:FALSE];
           currentPrintStep++;
       }
       else if (currentPrintStep == RapidInvoice_HouseCharge_Signature) {
           [self printHouseChargeReceipt:TRUE];
           currentPrintStep++;

       }

        else
        {
            [self nextPrint];
        }
    }
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    if ([device isEqualToString:@"Printer"]) {
        
        NSString *retryMessage;
        if (currentPrintStep == RapidInvoice_PassPrint) {
            retryMessage = @"Failed to pass print receipt. Would you like to retry.?";
            [self displayPassPrintRetryAlert:retryMessage];
        }
        else if (currentPrintStep == RapidInvoice_GiftCardPrint) {
            retryMessage = @"Failed to Gift print receipt. Would you like to retry.?";
            [self displayGiftCardPrintRetryAlert:retryMessage];
        }
        else if (currentPrintStep == RapidInvoice_HouseCharge) {
            retryMessage = @"Failed to House Charge receipt. Would you like to retry.?";
            [self displayHouseChargePrintRetryAlert:retryMessage];
        }

        else
        {
            if (currentPrintStep == RapidInvoice_CardPrint) {
                retryMessage = @"Failed to Card print receipt. Would you like to retry.?";
                [self diplayCardPrintRetryAlert:retryMessage];
            }
            else
            {
                retryMessage = @"Failed to Invoice print receipt. Would you like to retry.?";
                [self displayLastInvoicePrintRetryAlert:retryMessage];

            }
        }
    }
}

-(void)diplayCardPrintRetryAlert:(NSString *)message
{
    RapidInvoicePrint * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference processNextCardReceipt];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep = RapidInvoice_PrintDone;
        [myWeakReference nextPrint];
    };
    [self.rmsDbController popupAlertFromVC:presentedInViewController title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];

}
-(void)displayLastInvoicePrintRetryAlert:(NSString *)message
{
    RapidInvoicePrint * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep--;
        [myWeakReference nextPrint];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep = RapidInvoice_PrintDone;
        [myWeakReference nextPrint];
    };
    [self.rmsDbController popupAlertFromVC:presentedInViewController title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}


-(void)displayPassPrintRetryAlert:(NSString *)message
{
    RapidInvoicePrint * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self nextPassPrint];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep = RapidInvoice_PrintDone;
        [myWeakReference nextPrint];
    };
    [self.rmsDbController popupAlertFromVC:presentedInViewController title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}



-(void)displayGiftCardPrintRetryAlert:(NSString *)message
{
    RapidInvoicePrint * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self printNextGiftCard];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep = RapidInvoice_PrintDone;
        [myWeakReference nextPrint];
    };
    [self.rmsDbController popupAlertFromVC:presentedInViewController title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}
-(void)displayHouseChargePrintRetryAlert:(NSString *)message
{
    RapidInvoicePrint * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self printHouseChargeReceipt:FALSE];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep = RapidInvoice_PrintDone;
        [myWeakReference nextPrint];
    };
    [self.rmsDbController popupAlertFromVC:presentedInViewController title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}


-(BOOL)isPrepayTransaction:(NSMutableArray *)gasArray{
    BOOL prepay = NO;
    if([gasArray[0][@"TransactionType"] isEqualToString:@"PRE-PAY"]){
        prepay = YES;
    }
    return prepay;
    
}

@end
