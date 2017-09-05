//
//  BrdigePayPaymentGateway.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/29/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "BrdigePayPaymentGateway.h"
#import "RmsDbController.h"

@interface BrdigePayPaymentGateway ()
{
    NSXMLParser *revParser;
    NSMutableArray *XmlResponseArray;
    NSMutableDictionary *dictCardElement;
    NSMutableString *currentElement;
    NSString *extDataString;
    NSDictionary *bridgePayErrorMessages;
    NSString *invoiceNO;
    NSLock *transactionLock;
    NSTimer *responseTimeOut;
    NSString *strCardNumber ;
}

@property (nonatomic,strong) NSString *payResult;
@property(nonatomic,strong)NSString *accountNumber;
@property (nonatomic, strong) RmsDbController  *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *creditCardDeclineConnection;
@property (nonatomic, strong) RapidWebServiceConnection *creditCardTransactionConnection;
@property (nonatomic, strong) RapidWebServiceConnection *autoCCProcessConnection;
@property (nonatomic, strong) RapidWebServiceConnection *bridgePayManualCCprocessWC;
@property (nonatomic, strong) RapidWebServiceConnection *bridgepayRapidProcessAckKnowledgement;
@property(nonatomic,strong)NSString *currentTransactionId;
@property(nonatomic,strong)NSString *invoiceNo;



@property(nonatomic,strong)NSMutableData *responseData;
@end

@implementation BrdigePayPaymentGateway


- (instancetype)initDictionary:(NSDictionary*)cardData withDelegate:(id<PaymentGatewayDelegate>)delegate
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self = [super initWithDictionary:cardData withDelegate:delegate];
    if (self) {
        self.PaymentGatewayDictionary = [cardData mutableCopy];
        self.PaymentGatewayArray = [[NSMutableArray alloc]init];
        self.creditCardDeclineConnection = [[RapidWebServiceConnection alloc]init];
        self.creditCardTransactionConnection = [[RapidWebServiceConnection alloc]init];
        self.autoCCProcessConnection = [[RapidWebServiceConnection alloc]init];
        self.bridgePayManualCCprocessWC = [[RapidWebServiceConnection alloc]init];
        self.bridgepayRapidProcessAckKnowledgement = [[RapidWebServiceConnection alloc] init];
        transactionLock = [[NSLock alloc]init];
       bridgePayErrorMessages = @{@"110": @"Duplicate Transaction Please Try Again",
                                @"50": @"Insufficient funds available.",
                                };
    }
    return self;
}

-(void)processCreditcardWithURL:(NSString *)url details:(NSString *)details
{
    [transactionLock lock];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseCreditCardTransctionResponse:response error:error];
        });
    };
    
    self.creditCardTransactionConnection = [self.creditCardTransactionConnection initWithAsyncRequestURL:url withDetailValues:details asyncCompletionHandler:asyncCompletionHandler];
}

-(void)responseCreditCardTransctionResponse:(id)response error:(NSError *)error
{
    [transactionLock unlock];

    if (response != nil) {
        if ([response isKindOfClass:[NSString class]]) {
            
                NSString *responseString = response;
                NSLog(@"responseString : %@",responseString);
                extDataString= @"";
                NSMutableArray *array = [self parseCCResponse:responseString];
                
                NSLog(@"parseArray : %@",array.firstObject);
                NSMutableDictionary *dictDisplay = array.firstObject;
                [dictDisplay setValue:[NSString stringWithFormat:@"%@",extDataString] forKey:@"ExtData"];
                if ([dictDisplay[@"RespMSG"]isEqualToString:@"Approved"])
                {
                    self.PaymentGatewayDictionary = [[NSMutableDictionary alloc]init];
                    if (dictDisplay[@"AuthCode"])
                    {
                        if(![dictDisplay[@"AuthCode"] isKindOfClass:[NSNull class]]
                           && [dictDisplay[@"AuthCode"]length] >0)
                        {
                            [self.PaymentGatewayDictionary setValue:dictDisplay[@"AuthCode"] forKey:@"AuthCode"];
                        }
                        else
                        {
                            [self.PaymentGatewayDictionary setValue:@"-" forKey:@"AuthCode"];
                        }
                    }
                    else
                    {
                        [self.PaymentGatewayDictionary setValue:@"-" forKey:@"AuthCode"];
                    }
                    [self.PaymentGatewayDictionary setValue:dictDisplay[@"ExtData"] forKey:@"CardType"];
                    [self.PaymentGatewayDictionary setValue:dictDisplay[@"PNRef"] forKey:@"TransactionNo"];
                    [self.PaymentGatewayDictionary setValue:self.accountNumber forKey:@"AccNo"];
                    NSLog(@"PaymentGatewayDictionary = %@",self.PaymentGatewayDictionary);
                    NSLog(@"accountNumber = %@",self.accountNumber);
                    
                    [self.paymentGatewayDelegate paymentGateway:self didFinishTransaction:CTT_PROCESS_CREDIT_CARD response:self.PaymentGatewayDictionary];
                }
                else
                {
                    NSString *responseString = response;
                    [self callDeclineWebservicewithErrorMessage:responseString];
                    
                    NSError *error = [[NSError alloc] initWithDomain:@"Card Processing" code:self.payResult.integerValue userInfo:[self createErrorDictionaryWithErrorCode:dictDisplay]];
                    [self.paymentGatewayDelegate paymentGateway:self didFailWithDuplicateTransaction:CTT_PROCESS_CREDIT_CARD error:error];
                }
            
        }
    }
    else
    {
        [self callDeclineWebservicewithErrorMessage:response];
        [self.paymentGatewayDelegate paymentGateway:self didFailTransaction:CTT_PROCESS_CREDIT_CARD error:nil];
    }
}

- (void)processPayment:(NSString *)url details:(NSString *)details
{
    [self processCreditcardWithURL:url details:details];
    return;
    /*
    [transactionLock lock];
    NSURL *gateWayUrl=[NSURL URLWithString:url];
    
    NSData *postData=[details dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:gateWayUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(urlData)
    {
        NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseString : %@",responseString);
      //  [self callDeclineWebservicewithErrorMessage:responseString];
        extDataString= @"";
        NSMutableArray *array = [self parseCCResponse:responseString];

        NSLog(@"parseArray : %@",[array firstObject]);
        
        NSMutableDictionary *dictDisplay = [array firstObject];
        [dictDisplay setValue:[NSString stringWithFormat:@"%@",extDataString] forKey:@"ExtData"];
        if ([[dictDisplay objectForKey:@"RespMSG"]isEqualToString:@"Approved"])
        {
            self.PaymentGatewayDictionary = [[NSMutableDictionary alloc]init];
            if ([dictDisplay objectForKey:@"AuthCode"])
            {
                [self.PaymentGatewayDictionary setValue:[dictDisplay objectForKey:@"AuthCode"] forKey:@"AuthCode"];
            }
            else
            {
                [self.PaymentGatewayDictionary setValue:@"-" forKey:@"AuthCode"];
                
            }
            [self.PaymentGatewayDictionary setValue:[dictDisplay objectForKey:@"ExtData"] forKey:@"CardType"];
            [self.PaymentGatewayDictionary setValue:[dictDisplay objectForKey:@"PNRef"] forKey:@"TransactionNo"];
            [self.PaymentGatewayDictionary setValue:self.accountNumber forKey:@"AccNo"];
            NSLog(@"PaymentGatewayDictionary = %@",self.PaymentGatewayDictionary);
            NSLog(@"accountNumber = %@",self.accountNumber);

            [self.paymentGatewayDelegate paymentGateway:self didFinishTransaction:CTT_PROCESS_CREDIT_CARD response:self.PaymentGatewayDictionary];
        }
        else
        {
            NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            [self callDeclineWebservicewithErrorMessage:responseString];
            
            NSError *error = [[NSError alloc] initWithDomain:@"Card Processing" code:[self.payResult integerValue] userInfo:[self createErrorDictionaryWithErrorCode:dictDisplay]];
            [self.paymentGatewayDelegate paymentGateway:self didFailWithDuplicateTransaction:CTT_PROCESS_CREDIT_CARD error:error];
        }
    }
    else
    {
        NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        [self callDeclineWebservicewithErrorMessage:responseString];
        [self.paymentGatewayDelegate paymentGateway:self didFailTransaction:CTT_PROCESS_CREDIT_CARD error:nil];
    }
    [transactionLock unlock];*/
}

-(NSDictionary *)createErrorDictionaryWithErrorCode :(NSDictionary *)responseDictionary
{
  
    NSDictionary *errorDictionary;
    if (responseDictionary[@"RespMSG"])
    {
       errorDictionary = @{NSLocalizedDescriptionKey: [responseDictionary valueForKey:@"RespMSG"],
                                          };;
    }
    else
    {
        errorDictionary = @{NSLocalizedDescriptionKey: @"Transaction declined Please Try Again",
                            };;
    }
    return errorDictionary;
}

-(void)callDeclineWebservicewithErrorMessage:(NSString *)errorMessage
{
    NSMutableDictionary *errorResponse = [[NSMutableDictionary alloc]init];
    errorResponse[@"errorMassege"] = [NSString stringWithFormat:@"%@",errorMessage];
    errorResponse[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    errorResponse[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    errorResponse[@"errorCode"] = @"";
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    errorResponse[@"transDate"] = currentDateTime;
    
    NSString *invoiceDetail = [NSString stringWithFormat:@"invoiceNo = %@",invoiceNO];
    errorResponse[@"invoiceDetail"] = invoiceDetail;
    
    NSMutableDictionary *dictMain = [[NSMutableDictionary alloc]init];
    dictMain[@"objCardDeclineProcessDetail"] = errorResponse;
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self callDeclineWebservicewithErrorMessageResponse:response error:error];
    };
    
    self.creditCardDeclineConnection = [self.creditCardDeclineConnection initWithRequest:KURL actionName:WSM_CREDIT_CARD_DECLINE_PROCESS params:dictMain completionHandler:completionHandler];
    
}
- (void) callDeclineWebservicewithErrorMessageResponse:(id)response error:(NSError *)error
{
    
}


- (void)removeNameSpace:(NSString*)nameSpaceString result:(NSMutableString *)result {
    NSRange stringRange;
    stringRange.location = 0;
    stringRange.length = result.length;
    
    [result replaceOccurrencesOfString:nameSpaceString withString:@"" options:NSCaseInsensitiveSearch range:stringRange];
}

- (void)processDebitCardWithDetails :(NSDictionary *)details
{
}

- (void)processCreditCardWithDetails  :(NSDictionary *)details
{
    NSString *sendData = [self.paymentCardData valueForKey:@"sendData"];
    NSString *transactionId = [NSString stringWithFormat:@"<TransactionID>%@</TransactionID>",[details valueForKey:@"currentCreditTransactionId"]];
    sendData = [sendData stringByAppendingString:transactionId];
    CGFloat amount = [details[@"amount"] floatValue];
    CGFloat tip =  [details[@"tip"] floatValue];
    CGFloat TotalAmount = amount + tip;
    self.currentTransactionId = [details valueForKey:@"currentCreditTransactionId"];
    
    NSString *adjustment = [NSString stringWithFormat:@"<TipAmt>%.2f</TipAmt><TotalAmt>%.2f</TotalAmt>",tip,TotalAmount];
    sendData = [sendData stringByAppendingString:adjustment];
    
    

    self.accountNumber = [details valueForKey:@"accountNo"];
    
    self.invoiceNo =  [details valueForKey:@"invoiceNo"];
    
    NSLog(@"processCreditCardWithDetails");
    NSLog(@"accountNumber = %@",self.accountNumber);
    NSLog(@"sendData = %@",sendData);
    NSLog(@"self.paymentCardData = %@",self.paymentCardData) ;
    
    
    

    if(sendData.length>0)
    {
        NSString *transDetails = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=%.2f&InvNum=%@&PNRef=%@&Zip=&Street=&CVNum=&ExtData=%@",[details valueForKey:@"Username"],[details valueForKey:@"password"],[details valueForKey:@"transType"],[[details valueForKey:@"amount"] floatValue],[details valueForKey:@"invoiceNo"],[details valueForKey:@"TransactionNo"],sendData];
          NSLog(@"TransDetail for Orignal Transction= %@",transDetails);
        invoiceNO = [details valueForKey:@"invoiceNo"];
        
        if([[details valueForKey:@"TransactionServer"] isEqualToString:@"RAPID CONNECT"]){
            
            NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
            dictParam[@"TransType"] = [details valueForKey:@"transType"];
            dictParam[@"Amount"] = [details valueForKey:@"amount"];
            dictParam[@"InvNum"] = [details valueForKey:@"invoiceNo"];
            dictParam[@"MagData"] = @"";
            dictParam[@"BranchId"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
            dictParam[@"ExtData"] = sendData;
            dictParam[@"TransactionId"] = [details valueForKey:@"currentCreditTransactionId"];
            dictParam[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
            dictParam[@"CardNo"] = self.accountNumber;
            [self processCraditCard:dictParam];
        
            NSLog(@"RAPID CONNECT %@ - %@",WSM_BRIDGEPAY_AUTO_CREDIT_CARD_PROCESS,[self.rmsDbController jsonStringFromObject:dictParam]);
        }
        else
        {
             [self processPayment:[details valueForKey:@"URL"] details:transDetails];
        }
        self.paymentCardData = nil;

    }
    else  // manual BridgePay CraditCard Process
    {
        [self manualCCProcessing:[[details valueForKey:@"amount"] floatValue] withInvoiceNo:[details valueForKey:@"invoiceNo"] withAccountNo:[details valueForKey:@"accountNo"] withTransType:[details valueForKey:@"transType"] withexpdate:[details valueForKey:@"expDate"] withCVNum:[details valueForKey:@"cvNum"]];
    }
}

-(void)removeNotificationAndWebServiceConnectionObject
{
    NSLog(@"Timer End Date%@",[NSDate date]);
    [responseTimeOut invalidate];
    NSLog(@"removeNotificationAndWebServiceConnectionObject");

    [self.paymentGatewayDelegate paymentGateway:self didFailWithTimeOut:CTT_PROCESS_CREDIT_CARD error:nil];
    [transactionLock unlock];

}

- (void)processCraditCard:(NSMutableDictionary *)paramValue
{
    [transactionLock lock];
    responseTimeOut = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(removeNotificationAndWebServiceConnectionObject) userInfo:nil repeats:NO];
    NSLog(@"Timer Start Date %@",[NSDate date]);
    
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self bridgePayAutoCCProcessResponse:response error:error];
    };
    
    self.autoCCProcessConnection = [self.autoCCProcessConnection initWithAsyncRequest:KURL_PAYMENT actionName:WSM_BRIDGEPAY_AUTO_CREDIT_CARD_PROCESS params:paramValue asyncCompletionHandler:asyncCompletionHandler];

}

-(void)bridgePayAutoCCProcessResponse:(id)response error:(NSError *)error{
    [transactionLock unlock];
    [responseTimeOut invalidate];
    NSLog(@"BridgepayAutoCreditCardProcess31102015Result = %@",response);
    
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *responseDict = [self.rmsDbController objectFromJsonString:response[@"Data"]];
            NSLog(@"BridgepayAutoCreditCardProcess31102015Result = %@",response);
            
            NSLog(@"WSM_BRIDGEPAY_AUTO_CREDIT_CARD_PROCESS Service Response : %@",responseDict);
            extDataString= @"";
            NSDictionary *dictDisplay = [self.rmsDbController objectFromJsonString:[responseDict valueForKey:@"Response"]];
            NSLog(@"dictDisplay %@",dictDisplay);
            //    [dictDisplay setValue:[NSString stringWithFormat:@"%@",[self getCardType:[dictDisplay objectForKey:@"ExtData"]]] forKey:@"ExtData"];
            if ([dictDisplay[@"RespMSG"]isEqualToString:@"Approved"])
            {
                self.PaymentGatewayDictionary = [[NSMutableDictionary alloc]init];
                if (dictDisplay[@"AuthCode"])
                {
                    if(![dictDisplay[@"AuthCode"] isKindOfClass:[NSNull class]]
                       && [dictDisplay[@"AuthCode"]length] >0)
                    {
                        [self.PaymentGatewayDictionary setValue:dictDisplay[@"AuthCode"] forKey:@"AuthCode"];
                    }
                    else
                    {
                        [self.PaymentGatewayDictionary setValue:@"-" forKey:@"AuthCode"];
                    }
                }
                else
                {
                    [self.PaymentGatewayDictionary setValue:@"-" forKey:@"AuthCode"];
                }
                
                if(![responseDict[@"TransactionId"] isKindOfClass:[NSNull class]]
                   && [responseDict[@"TransactionId"]length] >0)
                {
                    [self.PaymentGatewayDictionary setValue:responseDict[@"TransactionId"] forKey:@"CreditTransactionId"];
                }
                else
                {
                    [self.PaymentGatewayDictionary setValue:@"" forKey:@"CreditTransactionId"];
                }
                
                [self.PaymentGatewayDictionary setValue:[NSString stringWithFormat:@"%@",[self getCardType:dictDisplay[@"ExtData"]]] forKey:@"CardType"];
                [self.PaymentGatewayDictionary setValue:dictDisplay[@"PNRef"] forKey:@"TransactionNo"];
                [self.PaymentGatewayDictionary setValue:self.accountNumber forKey:@"AccNo"];
                NSLog(@"PaymentGatewayDictionary = %@",self.PaymentGatewayDictionary);
                NSLog(@"accountNumber = %@",self.accountNumber);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self rapidCreditCardAcknowledgementWithResponse:responseDict];
                });
                
                [self.paymentGatewayDelegate paymentGateway:self didFinishTransaction:CTT_PROCESS_CREDIT_CARD response:self.PaymentGatewayDictionary];
            }
            else
            {
                [self callDeclineWebservicewithErrorMessage:response];
                
                NSError *error = [[NSError alloc] initWithDomain:@"Card Processing" code:self.payResult.integerValue userInfo:[self createErrorDictionaryWithErrorCode:dictDisplay]];
                [self.paymentGatewayDelegate paymentGateway:self didFailWithDuplicateTransaction:CTT_PROCESS_CREDIT_CARD error:error];
            }
        }
    }
    else
    {
        [self callDeclineWebservicewithErrorMessage:response];
        [self.paymentGatewayDelegate paymentGateway:self didFailTransaction:CTT_PROCESS_CREDIT_CARD error:nil];
    }
}

- (void)processGiftCardWithDetails  :(NSDictionary *)details
{
}
- (void)processLoyaltyCardWithDetails  :(NSDictionary *)details
{
}
- (void)processEbtCardWithDetails  :(NSDictionary *)details
{
    
}

- (void)paymentGateway:(PaymentGateway*)paymentGateway didFinishTransaction:(CARD_TRANSACTION_TYPE)transaction response:(NSDictionary*)response
{
    
}
- (void)paymentGateway:(PaymentGateway*)paymentGateway didFailTransaction:(CARD_TRANSACTION_TYPE)transaction error:(NSError *)error
{
    
}

-(void)manualCCProcessing :(float)amount withInvoiceNo:(NSString *)invoiceNo withAccountNo:(NSString *)accountNo withTransType:(NSString *)transType withexpdate:(NSString *)expDate withCVNum:(NSString *)cvNum
{
    [transactionLock lock];
    self.accountNumber = accountNo;
    
    NSMutableDictionary * paramValue = [[NSMutableDictionary alloc] init];
    [paramValue setValue:transType forKey:@"TransType"];
    
    [paramValue setValue:accountNo forKey:@"CardNum"];
   
    if([accountNo length]> 6)
    {
        strCardNumber=[accountNo substringToIndex:6];
    }
    
    [paramValue setValue:expDate forKey:@"ExpDate"];
    [paramValue setValue:[NSString stringWithFormat:@"%.2f",amount] forKey:@"Amount"];
    [paramValue setValue:invoiceNo forKey:@"InvNum"];
    [paramValue setValue:cvNum forKey:@"CVNum"];
    [paramValue setValue:[NSString stringWithFormat:@"<TransactionID>%@</TransactionID> ",self.currentTransactionId]forKey:@"ExtData"];
    //hiten
    paramValue[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    [paramValue setValue:self.currentTransactionId forKey:@"TransactionId"];
    paramValue[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];

    
    //NSLog(@"Manual credit card parameter : %@",paramValue);

    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self bridgePayManualCCProcessResponse:response error:error];
        });
    };

    self.bridgePayManualCCprocessWC = [self.bridgePayManualCCprocessWC initWithAsyncRequest:KURL_PAYMENT actionName:WSM_BRIDGEPAY_MANUAL_CREDIT_CARD_PROCESS params:paramValue asyncCompletionHandler:asyncCompletionHandler];

}

-(BOOL)checkToCardType:(NSString *)strAccount
{
    BOOL isCradInRange = FALSE ;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = kCFNumberFormatterNoStyle;
    NSNumber *cardNum = [f numberFromString:strAccount];
    
    if (cardNum.integerValue >= 222100 && cardNum.integerValue <= 272099) {
        isCradInRange = TRUE;
    }
    
    return isCradInRange;
}



- (void)bridgePayManualCCProcessResponse:(id)response error:(NSError *)error
{
    [transactionLock unlock];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
                NSDictionary *responseDict = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                extDataString= @"";
                
                NSDictionary *dictDisplay = [self.rmsDbController objectFromJsonString:[responseDict valueForKey:@"Response"]];
                NSLog(@"dictDisplay %@",dictDisplay);
                
                if ([dictDisplay[@"RespMSG"]isEqualToString:@"Approved"])
                {
                    self.PaymentGatewayDictionary = [[NSMutableDictionary alloc]init];
                    NSString *strAuthCode = dictDisplay[@"AuthCode"];
                    if([strAuthCode isKindOfClass:[NSString class]] && strAuthCode.length > 0)
                    {
                        [self.PaymentGatewayDictionary setValue:dictDisplay[@"AuthCode"] forKey:@"AuthCode"];
                    }
                    else
                    {
                        [self.PaymentGatewayDictionary setValue:@"-" forKey:@"AuthCode"];
                    }
                    
                    if ([self checkToCardType:strCardNumber] == TRUE)
                    {
                        [self.PaymentGatewayDictionary setValue:@"MASTERCARD" forKey:@"CardType"];
                    }
                    else
                    {
                        
                        NSArray  *arryExtData = [dictDisplay[@"ExtData"] componentsSeparatedByString:@","];
                        for (NSString *strTem in arryExtData) {
                            NSRange rang = [strTem rangeOfString:@"CardType"];
                            if(rang.location!=NSNotFound)
                            {
                                NSArray  *arryExtData2 = [strTem componentsSeparatedByString:@"="];
                                if(arryExtData2.count>=2)
                                {
                                    [self.PaymentGatewayDictionary setValue:arryExtData2[1] forKey:@"CardType"];
                                }
                                else{
                                    [self.PaymentGatewayDictionary setValue:@"Manual" forKey:@"CardType"];
                                }
                                
                            }
                        }
                    }
                    if(![responseDict[@"TransactionId"] isKindOfClass:[NSNull class]]
                       && [responseDict[@"TransactionId"]length] >0)
                    {
                        [self.PaymentGatewayDictionary setValue:responseDict[@"TransactionId"] forKey:@"CreditTransactionId"];
                    }
                    else
                    {
                        [self.PaymentGatewayDictionary setValue:@"" forKey:@"CreditTransactionId"];
                    }
                    
                    NSString *str = [self.accountNumber substringFromIndex:self.accountNumber.length-4];
                    str = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",str];
                    [self.PaymentGatewayDictionary setValue:str forKey:@"AccNo"];
                    
                    [self.PaymentGatewayDictionary setValue:dictDisplay[@"PNRef"] forKey:@"TransactionNo"];
                    
                    NSLog(@"PaymentGatewayDictionary = %@",self.PaymentGatewayDictionary);
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self rapidCreditCardAcknowledgementWithResponse:responseDict];
                    });
                    
                    
                    
                    [self.paymentGatewayDelegate paymentGateway:self didFinishTransaction:CTT_PROCESS_CREDIT_CARD response:self.PaymentGatewayDictionary];
                }
                else
                {
                    NSString *result = [NSString stringWithFormat:@"%ld",(long)[dictDisplay[@"Result"] integerValue]];
                    NSError *error = [[NSError alloc] initWithDomain:@"Card Processing" code:result.integerValue userInfo:[self createErrorDictionaryWithErrorCode:dictDisplay]];
                    [self.paymentGatewayDelegate paymentGateway:self didFailWithDuplicateTransaction:CTT_PROCESS_CREDIT_CARD error:error];
                }
        }
    }
    else
    {
        [self callDeclineWebservicewithErrorMessage:response];
        [self.paymentGatewayDelegate paymentGateway:self didFailTransaction:CTT_PROCESS_CREDIT_CARD error:nil];
    }
}

-(void)rapidCreditCardAcknowledgementWithResponse:(NSDictionary *)response
{

    NSMutableDictionary * paramValue = [[NSMutableDictionary alloc] init];
    [paramValue setValue:@"1" forKey:@"IsSucsess"];
    [paramValue setValue:[NSString stringWithFormat:@"%@",response[@"TransactionId"]] forKey:@"TransactionId"];
    [paramValue setValue:[NSString stringWithFormat:@"%@",self.invoiceNo] forKey:@"InvNo"];
    [paramValue setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    NSLog(@"rapidCreditCardAcknowledgement paramValue %@",paramValue);
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self rapidCreditCardAcknowledgementResponse:response error:error];
    };
    
    self.bridgepayRapidProcessAckKnowledgement = [self.bridgepayRapidProcessAckKnowledgement initWithAsyncRequest:KURL actionName:WSM_SUCESS_CREDITCARD_TRANSACTION params:paramValue asyncCompletionHandler:asyncCompletionHandler];
}
- (void)rapidCreditCardAcknowledgementResponse:(id)response error:(NSError *)error
{
    NSLog(@"RapidCreditCardAcknowledgementResponse :%@",response);

}
// Cerdit Xml Parser Response
-(NSMutableArray*) parseCCResponse:(NSString *)xml
{
    XmlResponseArray = [[NSMutableArray alloc] init];
    dictCardElement = [[NSMutableDictionary alloc] init];
    xml = [xml stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    xml = [xml stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    
    revParser = [[NSXMLParser alloc] initWithData:data];
    revParser.delegate = self;
    [revParser setShouldProcessNamespaces:NO];
    [revParser setShouldReportNamespacePrefixes:NO];
    [revParser setShouldResolveExternalEntities:NO];
    [revParser parse];
    
    // insert dictionary in array
    [XmlResponseArray addObject:dictCardElement];
    
    // return array to called function
    return XmlResponseArray;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}

- (void) parser: (NSXMLParser *) parser parseErrorOccurred: (NSError *) parseError
{
    
}

//Calls when it finds the opening Tag

- (void) parser: (NSXMLParser *) parser didStartElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qName
     attributes: (NSDictionary *) attributeDict
{
    
}

- (NSString *)getCardType:(NSString *)ExtData
{
    NSArray *extDataArray = [ExtData componentsSeparatedByString:@","];
    
    NSArray *cardTypeArray ;
    for (NSString *cardType in extDataArray)
    {
        NSRange range = [cardType rangeOfString:@"CardType"];
        if (range.length > 0 )
        {
            cardTypeArray = [cardType componentsSeparatedByString:@"="];
            NSLog(@"match for %@",cardType);
        }
    }
    
    for (NSString * cardTypeCompare in cardTypeArray)
    {
        if (![cardTypeCompare isEqualToString:@"CardType"])
        {
            extDataString = cardTypeCompare;
            NSLog(@"match for %@",cardTypeCompare);
        }
    }
    return extDataString;
}

//Calls and have value of particular Tag so here what we do recognize the tag and then retrieve its value

- (void) parser: (NSXMLParser *) parser didEndElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qName
{
    // insert element result in dictionary
    if([elementName isEqualToString:@"Result"])
    {
        self.payResult = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if([self.payResult isEqualToString:@"0"]) // when payment done successfully /  Payment Approved.
    {
        dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = self.payResult;
        if([elementName isEqualToString:@"RespMSG"])
        {
            NSString* RespMSG = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = RespMSG;
        }
        if([elementName isEqualToString:@"Message"])
        {
            NSString* Message = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = Message;
        }
        if([elementName isEqualToString:@"Message1"])
        {
            NSString* Message1 = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = Message1;
        }
        if([elementName isEqualToString:@"AuthCode"])
        {
            NSString* AuthCode = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([AuthCode isEqual:[NSNull null]])
            {
                AuthCode = @"-";
            }
            
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = AuthCode;
        }
        if([elementName isEqualToString:@"PNRef"])
        {
            NSString* PNRef = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = PNRef;
        }
        if([elementName isEqualToString:@"HostCode"])
        {
            NSString* HostCode = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = HostCode;
        }
        if([elementName isEqualToString:@"GetCommercialCard"])
        {
            NSString* GetCommercialCard = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = GetCommercialCard;
        }
        if([elementName isEqualToString:@"ExtData"])
        {
           // NSString* ExtData = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //    NSString *extDataString = [self getCardType:ExtData];
          //  NSString *extDataString = [extDataArray objectAtIndex:1];
           // extDataString = [extDataString substringFromIndex:9];
          //  [dictCardElement setObject:extDataString forKey:[NSString stringWithFormat: @"%@", elementName]];
        }
    }
    else // when payment is not done successfully done or duplicate transaction.
    {
        dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = self.payResult;
        if([elementName isEqualToString:@"RespMSG"])
        {
            NSString* RespMSG = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = RespMSG;
        }
        if([elementName isEqualToString:@"Message"])
        {
            NSString* Message = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = Message;
        }
        if([elementName isEqualToString:@"PNRef"])
        {
            NSString* PNRef = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = PNRef;
        }
        if([elementName isEqualToString:@"HostCode"])
        {
            NSString* HostCode = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = HostCode;
        }
        if([elementName isEqualToString:@"GetGetOrigResult"])
        {
            NSString* GetGetOrigResult = @"GetGetOrigResult";
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = GetGetOrigResult;
        }
        if([elementName isEqualToString:@"GetCommercialCard"])
        {
            NSString* GetCommercialCard = @"GetCommercialCard";
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = GetCommercialCard;
        }
        if([elementName isEqualToString:@"ExtData"])
        {
            NSString* ExtData = @"ExtData";
            dictCardElement[[NSString stringWithFormat: @"%@", elementName]] = ExtData;
        }
    }
    
    currentElement = nil;
    
}

- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string{
    
    [self getCardType:string];
    if(!currentElement)
        currentElement = [[NSMutableString alloc] initWithString:string];
    else
       [currentElement appendString:string];
    
}

@end
