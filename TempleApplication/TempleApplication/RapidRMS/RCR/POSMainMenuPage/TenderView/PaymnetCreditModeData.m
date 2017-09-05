//
//  PaymnetCreditModeData.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PaymnetCreditModeData.h"
#import "PaymentModeItem.h"

@implementation PaymnetCreditModeData

-(void)setCreditCardDictionaryAtIndex :(NSInteger)index withDetail:(NSDictionary *)creditCardDictionary
{
    PaymentModeItem *paymentModeItem = [self getPaymentModeItemAtIndex:index];
    paymentModeItem.paymentModeDictionary = [self updatePaymentDictionaryWithDetail:[creditCardDictionary mutableCopy] withPaymentModeItem:paymentModeItem];
}

-(BOOL)setCreditCardDictionaryAtIndex :(NSInteger)index withDetail:(NSDictionary *)creditCardDictionary withAdditionalCreditcardDetail:(NSMutableDictionary *)additionalCreditCardDetail withPaymentData:(PaymentData *)paymentData
{
    
    BOOL isPartiallyApprovedTransaction = FALSE;
    
    PaymentModeItem *paymentModeItem = [self getPaymentModeItemAtIndex:index];
    paymentModeItem.paymentModeDictionary = [self updatePaymentDictionaryWithDetail:[creditCardDictionary mutableCopy] withPaymentModeItem:paymentModeItem];
    
    CGFloat totalAmountOfPaymentMode = paymentModeItem.actualAmount.floatValue + paymentModeItem.calculatedAmount.floatValue;
    CGFloat totalDifference = totalAmountOfPaymentMode - [[creditCardDictionary valueForKey:@"ApprovedAmount"] floatValue];
    
    if (totalDifference > 0.009) {
    
        [paymentData setActualAmount:[[creditCardDictionary valueForKey:@"ApprovedAmount"] floatValue] forpaymentMode:paymentModeItem];
        paymentModeItem.isPartialApprove = TRUE;
        paymentModeItem.creditCardTransactionStatus = @(PartialApproved);
        isPartiallyApprovedTransaction = TRUE;
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
        
    return isPartiallyApprovedTransaction;
}


-(NSString *)valueForKey:(NSString *)key ForDictionary:(NSDictionary *)paxAdditionalFieldsDictionary
{
    NSString *value = @"";
    if ([paxAdditionalFieldsDictionary valueForKey:key]) {
        value = [paxAdditionalFieldsDictionary valueForKey:key];
    }
    return value;
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
-(PaymentModeItem *)getPaymentModeItemAtIndex :(NSInteger )index
{
    PaymentModeItem *updateToPaymentModeItem = (self.creditPaymentArray)[index];
    return updateToPaymentModeItem;
}


-(void)setCustomerImageAtIndex :(NSInteger)index withDetail:(UIImage *)paymentImage
{
    PaymentModeItem *paymentModeItem = [self getPaymentModeItemAtIndex:index];
    paymentModeItem.paymentModeDictionary = [self updatePaymentImage:paymentImage withPaymentModeItem:paymentModeItem];
}

-(void)setCustomerDiplayTipAmountAtIndex :(NSInteger)index withDetail:(NSNumber *)customerDiplayTipAmount
{
    PaymentModeItem *paymentModeItem = [self getPaymentModeItemAtIndex:index];
    paymentModeItem.customerDisplayTipAmount = customerDiplayTipAmount;
}


-(void)setManualReceiptAtIndex :(NSInteger)index
{
    PaymentModeItem *paymentModeItem = [self getPaymentModeItemAtIndex:index];
    paymentModeItem.paymentModeDictionary = [self updateManualReciptFlagwithPaymentModeItem:paymentModeItem];
}

-(NSDictionary *)updateManualReciptFlagwithPaymentModeItem:(PaymentModeItem *)paymentmodeItem
{
    NSMutableDictionary *paymentModeDictionary = [paymentmodeItem.paymentModeDictionary mutableCopy];
    paymentModeDictionary[@"IsManualReceipt"] = @(1);
    return paymentModeDictionary;
}
-(NSDictionary *)updatePaymentImage :(UIImage *)paymentImage withPaymentModeItem:(PaymentModeItem *)paymentmodeItem
{
    NSMutableDictionary *paymentModeDictionary = [paymentmodeItem.paymentModeDictionary mutableCopy];
    paymentModeDictionary[@"SignatureImage"] = paymentImage;
    
    return paymentModeDictionary;
}
-(NSString *)paymentTypeOfPaymentMode :(PaymentModeItem *)paymentModeItem
{
    return paymentModeItem.paymentType;
}
-(NSNumber *)paymentIdOfPaymentMode :(PaymentModeItem *)paymentModeItem
{
    return paymentModeItem.paymentId;
}

-(NSString *)paymentNameOfPaymentMode :(PaymentModeItem *)paymentModeItem
{
    return paymentModeItem.paymentName;
}
-(CGFloat)actualAmountOfPaymentMode :(PaymentModeItem *)paymentModeItem
{
    return paymentModeItem.actualAmount.floatValue;
}
-(CGFloat)calculatedAmountOfPaymentMode :(PaymentModeItem *)paymentModeItem
{
    return paymentModeItem.calculatedAmount.floatValue;
}

-(CGFloat)tipAmountOfPaymentMode :(PaymentModeItem *)paymentModeItem
{
    return paymentModeItem.tipAmount;
}

-(void)updatePaymentModeItem:(PaymentModeItem *)paymentModeItem withTransactionId:(NSString *)transactionId withStatus:(NSNumber *)creditCardTransactionStatus
{
    paymentModeItem.creditTransactionId = transactionId;
    paymentModeItem.creditCardTransactionStatus = creditCardTransactionStatus;

}

-(NSString *)tranctionServerPaymentMode:(PaymentModeItem *)paymentModeItem
{
    return paymentModeItem.transactionServerForPaymentMode;
}

-(BOOL )isCreditCardSwipedAtPaymentMode :(PaymentModeItem *)paymentModeItem
{
    BOOL iscreditCardSwiped = FALSE;
    NSString *isCreditCardSwipeString = [paymentModeItem isCreditCardSwipe];
    
    if ([isCreditCardSwipeString isEqualToString:@"1"])
    {
        iscreditCardSwiped = TRUE;
    }
    return iscreditCardSwiped;
}
@end
