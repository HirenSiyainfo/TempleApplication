//
//  PaymentGateway.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/29/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum __CARD_TRANSACTION_TYPE__ {
    CTT_PROCESS_DEBIT_CARD,
    CTT_PROCESS_CREDIT_CARD,
    CTT_PROCESS_GIFT_CARD,
    CTT_PROCESS_LOYALTY_CARD,
    CTT_PROCESS_EBT_CARD,
} CARD_TRANSACTION_TYPE;

@class PaymentGateway;

@protocol PaymentGatewayDelegate <NSObject>
- (void)paymentGateway:(PaymentGateway*)paymentGateway didFinishTransaction:(CARD_TRANSACTION_TYPE)transaction response:(NSDictionary*)response;
- (void)paymentGateway:(PaymentGateway*)paymentGateway didFailTransaction:(CARD_TRANSACTION_TYPE)transaction error:(NSError *)error;
- (void)paymentGateway:(PaymentGateway*)paymentGateway didFailWithDuplicateTransaction:(CARD_TRANSACTION_TYPE)transaction error:(NSError *)error;

- (void)paymentGateway:(PaymentGateway*)paymentGateway didFailWithTimeOut:(CARD_TRANSACTION_TYPE)transaction error:(NSError *)error;

@end

@interface PaymentGateway : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)cardData withDelegate:(id<PaymentGatewayDelegate>)delegate NS_DESIGNATED_INITIALIZER;

#pragma mark - Transactions
- (void)processDebitCardWithDetails :(NSDictionary *)details ;
- (void)processCreditCardWithDetails :(NSDictionary *)details;
- (void)processGiftCardWithDetails :(NSDictionary *)details;
- (void)processLoyaltyCardWithDetails :(NSDictionary *)details;
- (void)processEbtCardWithDetails :(NSDictionary *)details;
@property (nonatomic,strong)NSMutableDictionary *paymentCardData;

@property (readonly, strong, nonatomic) id<PaymentGatewayDelegate> paymentGatewayDelegate;

-(void)manualCCProcessing :(float)amount withInvoiceNo:(NSString *)invoiceNo withAccountNo:(NSString *)accountNo withTransType:(NSString *)transType withexpdate:(NSString *)expDate withCVNum:(NSString *)cvNum;
@end
