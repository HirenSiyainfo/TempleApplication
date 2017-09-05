//
//  PaymentModeItem.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/18/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum CreditCardTransactionStatus {
    Requesting  = 1,
    Approved,
    PartialApproved,
    Decline,
    Void,
    Refund
} CreditCardTransactionStatus;



@interface PaymentModeItem : NSObject

@property (nonatomic,strong)NSDictionary *paymentModeDictionary;
@property (nonatomic,strong)NSNumber *calculatedAmount;
@property (nonatomic,strong)NSNumber *actualAmount;
@property (nonatomic,strong)NSNumber *displayAmount;
@property (nonatomic,strong)NSString *creditTransactionId;
@property (nonatomic,strong)NSString *transactionServer;
@property (nonatomic,strong)NSString *transactionNo;
@property (nonatomic,strong)NSNumber *customerDisplayTipAmount;
@property (assign)BOOL isCustomerDiplayTipAdjusted;
@property (assign)BOOL isPartiallyApprovedPaymentMode;
@property (assign) BOOL isPartialApprove;
@property (nonatomic,strong)NSDictionary *cerditCardDictionary;
@property (nonatomic,strong)NSNumber *creditCardTransactionStatus;


@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *customerSignature;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *paymentType;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *paymentImage;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSNumber *paymentId;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *paymentName;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *transactionServerForPaymentMode;


@property (NS_NONATOMIC_IOSONLY, getter=isManualReceipt, readonly) BOOL manualReceipt;
@property (NS_NONATOMIC_IOSONLY) CGFloat tipAmount;
@property (NS_NONATOMIC_IOSONLY, getter=isMulipleCreditCardApplicable, readonly) BOOL mulipleCreditCardApplicable;
@property (NS_NONATOMIC_IOSONLY, getter=isCreditCardSwipeApplicable, readonly) BOOL isCreditCardSwipeApplicable;


-(NSString *)isCreditCardSwipe;
-(NSString *)creditTransactionId;
-(NSString *)transactionNo;

-(NSNumber *)giftCardApprovedAmount;
-(NSString *)giftCardNumber;
-(NSString *)isGiftCardApproved;
-(NSNumber *)giftCardBalanceAmount;

@end
