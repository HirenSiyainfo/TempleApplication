//
//  CreditCardReaderManager.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/4/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CreditCardReaderManager.h"
#import "RmsDbController.h"
#import "PaxDevice.h"
#import "PaymentModeItem.h"
#import "PaxResponse+Internal.h"
#import "PaxRequest+Internal.h"
#import "DoCreditResponse.h"
#import "InitializeResponse.h"
#import "DoSignatureResponse.h"
#import "GetSignatureResponse.h"
#import "DeviceSignatureCaptureDelegate.h"
#import "PaxSignatureCapture.h"

@interface CreditCardReaderManager () <PaxDeviceDelegate,DeviceSignatureCaptureDelegate>
{
    PaxSignatureCapture *paxSignatureCapture;
    NSString *creditTransctionId;
}
@property (nonatomic, strong) RmsDbController  *rmsDbController;
@property (nonatomic,strong) PaxDevice *paxDevice;

@property(nonatomic,weak) id <CreditCardReaderManagerDelegate>creditCardReaderManagerDelegate;

@end


@implementation CreditCardReaderManager
-(instancetype)initWithDelegate:(id<CreditCardReaderManagerDelegate>)delegate withPaxConnectionStatus:(BOOL)paxConnected
{
    self = [super init];
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        self.creditCardReaderManagerDelegate = delegate;
        [self setUpCreditCardReaderWithPaxConnectedStatus:paxConnected];
    }
    return self;
}

-(void)setUpCreditCardReaderWithPaxConnectedStatus:(BOOL)paxConnected
{
    NSDictionary *dictDevice = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceConfig"];
    if (dictDevice != nil)
    {
        NSString *paxDeviceIP = dictDevice [@"PaxDeviceIp"];
        NSString *paxDevicePort = dictDevice [@"PaxDevicePort"];
        self.paxDevice = [[PaxDevice alloc] initWithIp:paxDeviceIP port:paxDevicePort];
        self.paxDevice.paxDeviceDelegate = self;
        if (paxConnected == FALSE)
        {
            [self intializePaxDevice];
        }
    }
}
-(void)intializePaxDevice
{
    self.paxDevice.pdResonse = PDResponseInitialize;
    [self.paxDevice initializeDevice];
}

-(void)doCreditCardReaderRequestWithPaymentModeItem:(PaymentModeItem *)paymentModeItem WithRegisterInvNo:(NSString *)registerInvNo withTransactionId:(NSString *)trasnactionId isGasItem:(BOOL)isGas
{
//    trasnactionId = @"";
      creditTransctionId = trasnactionId;
     if ([paymentModeItem.paymentType isEqualToString:@"Credit"]) {
        CGFloat totalAmount = paymentModeItem.actualAmount.floatValue + paymentModeItem.calculatedAmount.floatValue;
        self.paxDevice.pdResonse = PDResponseDoCredit;
        
        if (totalAmount < 0) {
            totalAmount = -totalAmount;
            [self.paxDevice refundCreditAmount:totalAmount transactionNumber:nil referenceNumber:trasnactionId];
        }
        
       else if (paymentModeItem.tipAmount > 0)
        {
            if([self.rmsDbController isPreAuthEnabled]){
                        
                    if(isGas){
                        
                        [self.paxDevice doCreditAuthWithAmount:totalAmount tipAmount:paymentModeItem.tipAmount taxAmount:0.00 invoiceNumber:registerInvNo referenceNumber:trasnactionId];
                    }
                    else{
                         [self.paxDevice doCreditWithAmount:totalAmount tipAmount:paymentModeItem.tipAmount invoiceNumber:registerInvNo referenceNumber:trasnactionId];
                    }
                        
            }else{
                        
                    [self.paxDevice doCreditWithAmount:totalAmount tipAmount:paymentModeItem.tipAmount invoiceNumber:registerInvNo referenceNumber:trasnactionId];
                        
            }
            
           
        }
        else
        {
            
            if([self.rmsDbController isPreAuthEnabled]){
            
                if(isGas){
                
                    [self.paxDevice doCreditAuthWithAmount:totalAmount tipAmount:0.00 taxAmount:0.00 invoiceNumber:registerInvNo referenceNumber:trasnactionId];
                }
                else{
                    [self.paxDevice doCreditWithAmount:totalAmount invoiceNumber:registerInvNo referenceNumber:trasnactionId];
                }
            
            }else{
            
                    [self.paxDevice doCreditWithAmount:totalAmount invoiceNumber:registerInvNo referenceNumber:trasnactionId];
                        
            }
            
        }
    }
    else if ([paymentModeItem.paymentType isEqualToString:@"Debit"])
    {
        CGFloat totalAmount = paymentModeItem.actualAmount.floatValue + paymentModeItem.calculatedAmount.floatValue;
        self.paxDevice.pdResonse = PDResponseDoDebit;

        if (totalAmount < 0) {
            totalAmount = -totalAmount;
            [self.paxDevice refundDebitAmount:totalAmount transactionNumber:nil referenceNumber:trasnactionId];
        }
       else if (paymentModeItem.tipAmount > 0)
        {
            [self.paxDevice doDebitWithAmount:totalAmount tipAmount:paymentModeItem.tipAmount invoiceNumber:registerInvNo referenceNumber:trasnactionId];
        }
        else
        {
            [self.paxDevice doDebitWithAmount:totalAmount invoiceNumber:registerInvNo referenceNumber:trasnactionId];
        }
    }
    else if ([paymentModeItem.paymentType isEqualToString:@"EBT/Food Stamp"])
    {
        CGFloat totalAmount = paymentModeItem.actualAmount.floatValue + paymentModeItem.calculatedAmount.floatValue;
        self.paxDevice.pdResonse = PDResponseDoEBT;

        if (totalAmount < 0) {
            totalAmount = -totalAmount;
            [self.paxDevice refundEbtAmount:totalAmount transactionNumber:nil referenceNumber:trasnactionId];
        }
       else if (paymentModeItem.tipAmount > 0)
        {
            [self.paxDevice doEbtWithAmount:totalAmount tipAmount:paymentModeItem.tipAmount invoiceNumber:registerInvNo referenceNumber:trasnactionId];
        }
        else
        {
            [self.paxDevice doEbtWithAmount:totalAmount invoiceNumber:registerInvNo referenceNumber:trasnactionId];
        }
    }
}
-(void)creditCardSignatureRequestWithId:(DeviceSignatureCaputure)deviceSignatureCaputure;
{
    NSLog(@"creditCardSignatureRequestWithId");
    if (deviceSignatureCaputure == PaxSignatureCapture_Request) {
       paxSignatureCapture = [[PaxSignatureCapture alloc] initWithDelegate:self WithPaxDevice:self.paxDevice];
    }
    else if (deviceSignatureCaputure == VariFoneSignartureCapture_Request)
    {
    }
}

- (void)paxDevice:(PaxDevice*)paxDevice willSendRequest:(NSString*)request
{
    
}
- (void)paxDevice:(PaxDevice*)paxDevice response:(PaxResponse*)response
{
    NSString *code = response.commandType;
    if ([self isCreditTransaction:code]) {
        /// Parse credit card here....
        [self parseCreditCardResponse:response];
    }
    
   else  if ([self isDebitTransaction:code]) {
       [self parseCreditCardResponse:response];

        /// Parse debit card here....
    }
    
   else  if ([self isEbtTransaction:code]) {
       [self parseCreditCardResponse:response];

       /// Parse ebt card here....
   }
   else  if ([self isIntialize:code]) {
       /// Parse Intialize code here....
       [self parseIntializeProcess:response];
   }
}

-(void)parseCreditCardResponse:(PaxResponse *)response
{
    DoCreditResponse *cr = (DoCreditResponse *)response;
    NSMutableDictionary *creditcardResponseDictionary = [[NSMutableDictionary alloc] init];

    
    if (cr.responseCode.integerValue == 0) {
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
        creditcardResponseDictionary[@"CreditTransactionId"] = creditTransctionId;
        creditcardResponseDictionary[@"EntryMode"] = [NSString stringWithFormat:@"%@",cr.entryMode];
        creditcardResponseDictionary[@"TransactionType"] = [NSString stringWithFormat:@"%@",cr.transactionType];
        creditcardResponseDictionary[@"HostReferenceNumber"] = [NSString stringWithFormat:@"%@",responseHostInformation.hostReferenceNumber];
        creditcardResponseDictionary[@"BatchNo"] = [NSString stringWithFormat:@"%@",responseHostInformation.batchNumber];

        
        creditcardResponseDictionary[@"RequestData"] = [NSString stringWithFormat:@"%@",[self.paxDevice.requestData base64EncodedStringWithOptions:0]] ;
        creditcardResponseDictionary[@"ResponseData"] = [NSString stringWithFormat:@"%@",[self.paxDevice.responseData base64EncodedStringWithOptions:0]];
        
       /* NSString * strRequestData = creditcardResponseDictionary[@"RequestData"];
        NSData *dataRequestData = [[NSData alloc] initWithBase64EncodedString:strRequestData options:0];
        NSLog(@"RequestData = %@",dataRequestData);
        
        NSString *t = creditcardResponseDictionary[@"ResponseData"];
        NSData *d = [[NSData alloc] initWithBase64EncodedString:t options:0];
        NSLog(@"ResponseData = %@",d);*/
        
        [self.creditCardReaderManagerDelegate didFinishCreditCardReaderTransctionSuccessfullyWithDetail:creditcardResponseDictionary withCreditCardAdditionalDetail:cr.additionalInformation];
    }
    else
    {
        [self.creditCardReaderManagerDelegate didFailTransction:nil response:cr];
    }
    
    /*
     [message appendFormat:@"transactionResponseCode = %@\n", cr.transactionResponseCode];
     [message appendFormat:@"transactionResponseMessage = %@\n", cr.transactionResponseMessage];
     [message appendFormat:@"authCode = %@\n", cr.authCode];
     [message appendFormat:@"hostReferenceNumber = %@\n", cr.hostReferenceNumber];
     [message appendFormat:@"traceNumber = %@\n", cr.traceNumber];
     [message appendFormat:@"batchNumber = %@\n", cr.batchNumber];
     [message appendFormat:@"transactionType = %@\n", cr.transactionType];
     [message appendFormat:@"approvedAmount = %@\n", cr.approvedAmount];
     //        [message appendFormat:@"amountDue = %@\n", cr.amountDue];
     //        [message appendFormat:@"tipAmount = %@\n", cr.tipAmount];
     //        [message appendFormat:@"cashBackAmount = %@\n", cr.cashBackAmount];
     //        [message appendFormat:@"merchantSurchargeFee = %@\n", cr.merchantSurchargeFee];
     //        [message appendFormat:@"taxAmount = %@\n", cr.taxAmount];
     //        [message appendFormat:@"balance1 = %@\n", cr.balance1];
     //        [message appendFormat:@"balance2 = %@\n", cr.balance2];
     //        [message appendFormat:@"accountNumber = %@\n", cr.accountNumber];
     [message appendFormat:@"entryMode = %@\n", cr.entryMode];
     
     [message appendFormat:@"transactionNumber = %@\n", cr.transactionNumber];
     [message appendFormat:@"referenceNumber = %@\n", cr.referenceNumber];
     */
    /*   [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.hostReferenceNumber] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.traceNumber] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.batchNumber] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.transactionType] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.approvedAmount] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.amountDue] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.tipAmount] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.cashBackAmount] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.merchantSurchargeFee] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.taxAmount] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.balance1] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.balance2] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.approvedAmount] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.entryMode] forKey:@""];
     [creditcardResponseDictionary setObject:[NSString stringWithFormat:@"@%@",cr.referenceNumber] forKey:@""];*/
}

-(void)parseIntializeProcess:(PaxResponse *)response
{
    InitializeResponse *initializeResponse = (InitializeResponse *)response;
    if (initializeResponse.responseCode.integerValue == 0) {
        [self.creditCardReaderManagerDelegate didConnectedCreditCardReader:@"Pax"];
    }
    else
    {
        [self.creditCardReaderManagerDelegate didDisconnectedCreditCardReader];
    }
}
- (BOOL)isCreditTransaction:(NSString*)code {
    NSRange range = [code rangeOfString:@"T01"];
    return range.location != NSNotFound;
}
- (BOOL)isDebitTransaction:(NSString*)code {
    NSRange range = [code rangeOfString:@"T03"];
    return range.location != NSNotFound;
}
- (BOOL)isEbtTransaction:(NSString*)code {
    NSRange range = [code rangeOfString:@"T05"];
    return range.location != NSNotFound;
}

- (BOOL)isIntialize:(NSString*)code {
    NSRange range = [code rangeOfString:@"A01"];
    return range.location != NSNotFound;
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
- (void)paxDevice:(PaxDevice*)paxDevice failed:(NSError*)error response:(PaxResponse *)response
{
    [self.creditCardReaderManagerDelegate didFailTransction:error response:response];
}

- (void)paxDevice:(PaxDevice*)paxDevice isConncted:(BOOL)isConncted
{
}
- (void)paxDeviceDidTimeout:(PaxDevice*)paxDevice
{
}

#pragma mark
#pragma  mark- DeviceSignatureCaptureDelegate
- (void)didCaptureSignature:(UIImage*)signatureImage
{
    NSLog(@"didCaptureSignature");
    self.paxDevice.paxDeviceDelegate = self;
    [self.creditCardReaderManagerDelegate didFinishSignatureImage:signatureImage];
}
- (void)didFailToCaptureSignatureImageWitherror:(NSError *)error response:(PaxResponse *)response
{
//    self.paxDevice.paxDeviceDelegate = self;
    [self.creditCardReaderManagerDelegate didFailTransction:error response:response];
}
- (void)displayAlert:(NSString*)title withMessage:(NSString *)message withButtonTitles:(NSArray *)buttonTitles withButtonHandlers:(NSArray *)buttonHandlers
{
    [self.creditCardReaderManagerDelegate displayAlertInCreditCardProcessingWithTitle:title withMessage:message withButtonTitles:buttonTitles withButtonHandlers:buttonHandlers];
}

- (void)continueWithoutSignature
{
    self.paxDevice.paxDeviceDelegate = self;
    [self.creditCardReaderManagerDelegate continueNextCardWithoutSignature];
}



@end
