//
//  PaymnetCreditModeData.h
//  RapidRMS
//
//  Created by siya-IOS5 on 9/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaymentModeItem.h"
#import "PaymentData.h"
@interface PaymnetCreditModeData : NSObject
@property (nonatomic,strong)NSMutableArray *creditPaymentArray;


-(void)setCreditCardDictionaryAtIndex :(NSInteger)index withDetail:(NSDictionary *)creditCardDictionary;
-(BOOL)setCreditCardDictionaryAtIndex :(NSInteger)index withDetail:(NSDictionary *)creditCardDictionary withAdditionalCreditcardDetail:(NSMutableDictionary *)additionalCreditCardDetail withPaymentData:(PaymentData *)paymentData;


-(NSString *)paymentNameOfPaymentMode :(PaymentModeItem *)paymentModeItem;
-(NSString *)paymentTypeOfPaymentMode :(PaymentModeItem *)paymentModeItem;
-(CGFloat)actualAmountOfPaymentMode :(PaymentModeItem *)paymentModeItem;
-(CGFloat)calculatedAmountOfPaymentMode :(PaymentModeItem *)paymentModeItem;
-(BOOL )isCreditCardSwipedAtPaymentMode :(PaymentModeItem *)paymentModeItem;
-(CGFloat)tipAmountOfPaymentMode :(PaymentModeItem *)paymentModeItem;
-(NSString *)tranctionServerPaymentMode:(PaymentModeItem *)paymentModeItem;
-(NSNumber *)paymentIdOfPaymentMode :(PaymentModeItem *)paymentModeItem;
-(void)setCustomerImageAtIndex :(NSInteger)index withDetail:(UIImage *)paymentImage;
-(void)setManualReceiptAtIndex :(NSInteger)index;

-(void)setCustomerDiplayTipAmountAtIndex :(NSInteger)index withDetail:(NSNumber *)customerDiplayTipAmount;
-(void)updatePaymentModeItem:(PaymentModeItem *)paymentModeItem withTransactionId:(NSString *)transactionId withStatus:(NSNumber *)creditCardTransactionStatus;

@end
