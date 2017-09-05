//
//  CardDeviceManager.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/28/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CardDeviceManager.h"
#import "PaymentGateway.h"
#import "BrdigePayPaymentGateway.h"
#import "RmsDbController.h"
#import "RmsCardReader.h"
#import "MagtekReader.h"
@interface CardDeviceManager ()


@property (readonly, weak, nonatomic) id<CardDeviceManagerDelegate> cardDeviceManagerDelegate;
@property (nonatomic, strong) NSString *sendData;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) PaymentGateway *paymentGateway;
@property (nonatomic, strong) RmsDbController  *rmsDbController;
@property (nonatomic, strong) RmsCardReader  *rmsCardReader;

@end

@implementation CardDeviceManager

-(instancetype)initWithDelegate :(id<CardDeviceManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        _cardDeviceManagerDelegate = delegate;
        [self setupPaymentGateway];
        [self setupCardReaders];
    }
    return self;
}

// Method For Initialize The Card Readers OF diffrent Types....
- (void)setupCardReaders {
    // Magtek
    [self setupMagtekReader];
    [self setUpCardFlightReader];
}

// Method for setup The MagTek CardReader
-(void)setupMagtekReader
{
   // self.rmsCardReader = [[MagtekReader alloc] initWithDelegate:self];

}
 -(void)setUpCardFlightReader
{
  //  self.rmsCardReader = [[CardFlightReader alloc] initWithDelegate:self];
}
-(void)setupPaymentGateway
{
    NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
    if ([gateWay isEqualToString:@"CardFlight"])
    {
//        self.paymentGateway = [[CardFlightPaymentGateway alloc]initDictionary:nil withDelegate:self];
//        self.rmsCardReader = [[CardFlightReader alloc] initWithDelegate:self];
    }
    else
    {
        // BridgePay
        self.paymentGateway = [[BrdigePayPaymentGateway alloc]initDictionary:nil withDelegate:self];
        self.rmsCardReader = [[MagtekReader alloc] initWithDelegate:self];
    }
}


- (void)closeDevice
{
    [self.rmsCardReader closeDevice];
}


-(void)processCreditCardWithDictionary :(NSMutableDictionary *)creditCardDictionary
{
    NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
    if ([gateWay isEqualToString:@"CardFlight"])
    {
        creditCardDictionary[@"Username"] = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"];
        creditCardDictionary[@"password"] = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"];
        creditCardDictionary[@"URL"] = [NSString stringWithFormat:@"%@/%@",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"URL"],@"ProcessCreditCard"];
        creditCardDictionary[@"merchantId"] = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"MerchantId"];
        [self.paymentGateway processCreditCardWithDetails:creditCardDictionary];
    }
    else
    {
        creditCardDictionary[@"Username"] = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"];
        creditCardDictionary[@"password"] = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"];
        creditCardDictionary[@"URL"] = [NSString stringWithFormat:@"%@/%@",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"URL"],@"ProcessCreditCard"];
        [self.paymentGateway processCreditCardWithDetails:creditCardDictionary];
    }
}


// Method for Process the Card
/*-(void)processCardWithamount :(float)amount withInvoiceNo:(NSString *)invoiceNo withAccountNo:(NSString *)accountNo withTransType:(NSString *)transType withexpdate:(NSString *)expDate withCVNum:(NSString *)cvNum withDeviceName:(NSString *)deviceName  withTransactionNo:(NSString *)transactionNo
{
    NSString *gateWay = [[self.rmsDbController.paymentCardTypearray firstObject] valueForKey:@"Gateway"];
    
    if ([gateWay isEqualToString:@"CardFlight"])
    {
        NSDictionary *detail= @{@"accountNo": [NSString stringWithFormat:@"%@",accountNo],
                                @"Username": [[self.rmsDbController.paymentCardTypearray firstObject] valueForKey:@"Username"],
                                @"password": [[self.rmsDbController.paymentCardTypearray firstObject] valueForKey:@"password"],
                                @"transType": transType,
                                @"expDate": expDate,
                                @"cvNum": cvNum,
                                @"amount": @(amount),
                                @"URL": [NSString stringWithFormat:@"%@/%@",[[self.rmsDbController.paymentCardTypearray firstObject] valueForKey:@"URL"],@"ProcessCreditCard"],
                                @"merchantId": [[self.rmsDbController.paymentCardTypearray firstObject] valueForKey:@"MerchantId"],
                                };
        [self.paymentGateway processCreditCardWithDetails:detail];
    }
   else
    {
    NSDictionary *detail= @{@"accountNo": [NSString stringWithFormat:@"%@",accountNo],
                            @"Username": [[self.rmsDbController.paymentCardTypearray firstObject] valueForKey:@"Username"],
                            @"password": [[self.rmsDbController.paymentCardTypearray firstObject] valueForKey:@"password"],
                            @"transType": transType,
                            @"expDate": expDate,
                            @"cvNum": cvNum,
                            @"amount": @(amount),
                            @"URL": [NSString stringWithFormat:@"%@/%@",[[self.rmsDbController.paymentCardTypearray firstObject] valueForKey:@"URL"],@"ProcessCreditCard"],
                            @"invoiceNo": invoiceNo,
                            @"TransactionNo": transactionNo
               };
    [self.paymentGateway processCreditCardWithDetails:detail];
    }
}*/


-(void)paymentSuccessFullyDone :(NSDictionary *)dictionary
{
    [self.cardDeviceManagerDelegate paymentProcessDidFinish:dictionary];
}
-(void)paymentProcessFailed
{
    [self.cardDeviceManagerDelegate paymentProcessDidFailed];
}

#pragma mark-
#pragma CardReader Methods
#pragma mark-
- (void)didConnectToReaderDevice :(NSString *)deviceName
{
    [self.cardDeviceManagerDelegate didConnectToDevice:deviceName];
}
- (void)didDisconnectFromReaderDevice :(NSString *)deviceName
{
    [self.cardDeviceManagerDelegate didDisconnectFromDevice:deviceName];
}
- (void)didSwipeFromReaderDevice :(NSString *)accountNumber withExpirationDate:(NSString *)date WithNameOnCard :(NSString *)cardName  withDeviceName:(NSString *)deviceName cardData:(NSMutableDictionary *)cardData
{
    self.paymentGateway.paymentCardData = [[NSMutableDictionary alloc]init];
    self.paymentGateway.paymentCardData = cardData;
     [self.cardDeviceManagerDelegate didSwipeFromDevice:accountNumber withExpirationDate:date WithNameOnCard:cardName deviceName:deviceName];
}
-(void)didFailToRetriveCardData
{
    [self.cardDeviceManagerDelegate didFailToRetriveCardInformation];
}


- (void)paymentGateway:(PaymentGateway*)paymentGateway didFinishTransaction:(CARD_TRANSACTION_TYPE)transaction response:(NSDictionary*)response
{
    [self.cardDeviceManagerDelegate paymentProcessDidFinish:response];

}
- (void)paymentGateway:(PaymentGateway*)paymentGateway didFailTransaction:(CARD_TRANSACTION_TYPE)transaction error:(NSError *)error
{
    [self.cardDeviceManagerDelegate paymentProcessDidFailed];

}

- (void)paymentGateway:(PaymentGateway*)paymentGateway didFailWithTimeOut:(CARD_TRANSACTION_TYPE)transaction error:(NSError *)error
{
    NSLog(@"paymentGateway:(PaymentGateway*)paymentGateway didFailWithTimeOut:(CARD_TRANSACTION_TYPE)transaction error:(NSError *)error");

    [self.cardDeviceManagerDelegate paymentProcessDidFailedWithTimeOut];
}

- (void)paymentGateway:(PaymentGateway*)paymentGateway didFailWithDuplicateTransaction:(CARD_TRANSACTION_TYPE)transaction error:(NSError *)error
{
    [self.cardDeviceManagerDelegate paymentProcessDidFailedWithDuplicateTranactionWithError:error];

}

-(void)processCardFlightManual :(NSMutableDictionary *)detaidictionary WithAmount:(float)amount withAccountNo:(NSString*)accountNo
{
    self.paymentGateway.paymentCardData = [[NSMutableDictionary alloc]init];
    self.paymentGateway.paymentCardData = detaidictionary;
    
    NSDictionary *detail= @{@"accountNo": [NSString stringWithFormat:@"%@",accountNo],
                            @"Username": [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],
                            @"password": [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],
                            @"amount": @(amount),
                            @"merchantId": [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"MerchantId"],
                            };
    [self.paymentGateway processCreditCardWithDetails:detail];
}

@end
