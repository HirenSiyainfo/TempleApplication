//
//  PaymentGateway.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/29/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PaymentGateway.h"

@interface PaymentGateway ()


@property (strong, nonatomic) id<PaymentGatewayDelegate> paymentGatewayDelegate;
@end


@implementation PaymentGateway


- (instancetype)initWithDictionary:(NSDictionary*)cardData withDelegate:(id<PaymentGatewayDelegate>)delegate
{
    self = [super init];
    if (self) {
        _paymentGatewayDelegate = delegate;
        self.paymentCardData = [[NSMutableDictionary alloc]init];
    }
    return self;
}
- (void)processDebitCardWithDetails :(NSDictionary *)details
{
    
}
- (void)processCreditCardWithDetails :(NSDictionary *)details
{
    
}
- (void)processGiftCardWithDetails :(NSDictionary *)details
{
    
}
- (void)processLoyaltyCardWithDetails :(NSDictionary *)details
{
    
}
- (void)processEbtCardWithDetails :(NSDictionary *)details
{
    
}

-(void)bridgePay_manualCCProcessing :(float)amount withInvoiceNo:(NSString *)invoiceNo withAccountNo:(NSString *)accountNo withTransType:(NSString *)transType withexpdate:(NSString *)expDate withCVNum:(NSString *)cvNum
{
    
}
-(void)manualCCProcessing :(float)amount withInvoiceNo:(NSString *)invoiceNo withAccountNo:(NSString *)accountNo withTransType:(NSString *)transType withexpdate:(NSString *)expDate withCVNum:(NSString *)cvNum
{
    
}
@end
