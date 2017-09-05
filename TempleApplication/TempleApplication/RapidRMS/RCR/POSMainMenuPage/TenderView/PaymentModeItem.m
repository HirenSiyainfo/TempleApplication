//
//  PaymentModeItem.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/18/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PaymentModeItem.h"

@interface PaymentModeItem ()<NSCoding>
@end

@implementation PaymentModeItem


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.paymentModeDictionary forKey:@"paymentModeDictionary"];
    [aCoder encodeObject:self.calculatedAmount forKey:@"calculatedAmount"];
    [aCoder encodeObject:self.actualAmount forKey:@"actualAmount"];
    [aCoder encodeObject:self.displayAmount forKey:@"displayAmount"];
    [aCoder encodeObject:self.creditTransactionId forKey:@"creditTransactionId"];
    [aCoder encodeObject:self.transactionNo forKey:@"transactionNo"];
    [aCoder encodeObject:self.transactionServer forKey:@"transactionServer"];
    [aCoder encodeObject:self.customerDisplayTipAmount forKey:@"customerDisplayTipAmount"];

    [aCoder encodeBool:self.isCustomerDiplayTipAdjusted forKey:@"isCustomerDiplayTipAdjusted"];
    [aCoder encodeBool:self.isPartiallyApprovedPaymentMode forKey:@"isPartiallyApprovedPaymentMode"];
    [aCoder encodeBool:self.isPartialApprove forKey:@"isPartialApprove"];
    [aCoder encodeObject:self.cerditCardDictionary forKey:@"cerditCardDictionary"];
    [aCoder encodeObject:self.creditCardTransactionStatus forKey:@"creditCardTransactionStatus"];

}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.paymentModeDictionary = [aDecoder decodeObjectForKey:@"paymentModeDictionary"];
        self.calculatedAmount = [aDecoder decodeObjectForKey:@"calculatedAmount"];
        self.actualAmount = [aDecoder decodeObjectForKey:@"actualAmount"];
        self.displayAmount = [aDecoder decodeObjectForKey:@"displayAmount"];
        self.creditTransactionId = [aDecoder decodeObjectForKey:@"creditTransactionId"];
        self.transactionNo = [aDecoder decodeObjectForKey:@"transactionNo"];
        self.transactionServer = [aDecoder decodeObjectForKey:@"transactionServer"];
        self.customerDisplayTipAmount = [aDecoder decodeObjectForKey:@"customerDisplayTipAmount"];
        
        self.isCustomerDiplayTipAdjusted = [aDecoder decodeBoolForKey:@"isCustomerDiplayTipAdjusted"];
        self.isPartiallyApprovedPaymentMode = [aDecoder decodeBoolForKey:@"isPartiallyApprovedPaymentMode"];
        self.isPartialApprove = [aDecoder decodeBoolForKey:@"isPartialApprove"];
        
        self.cerditCardDictionary = [aDecoder decodeObjectForKey:@"cerditCardDictionary"];
        self.creditCardTransactionStatus = [aDecoder decodeObjectForKey:@"creditCardTransactionStatus"];

    }
    
    return self;
    
}

-(NSString *)paymentType
{
    return [self.paymentModeDictionary valueForKey:@"CardIntType"];
}
-(NSString *)paymentImage
{
    return [self.paymentModeDictionary valueForKey:@"PayImage"];

}
-(NSNumber *)paymentId
{
    return [self.paymentModeDictionary valueForKey:@"PayId"];

}
-(NSString *)paymentName
{
    return [self.paymentModeDictionary valueForKey:@"PaymentName"];
}
-(NSString *)creditTransactionId
{
    return _creditTransactionId;
}

-(NSString *)transactionNo
{
    return [self.paymentModeDictionary valueForKey:@"TransactionNo"];
}

-(UIImage *)customerSignature
{
    return [self.paymentModeDictionary valueForKey:@"SignatureImage"];
}

-(BOOL)isManualReceipt
{
    return [[self.paymentModeDictionary valueForKey:@"IsManualReceipt"] boolValue];
}


-(BOOL)isMulipleCreditCardApplicable
{
    return [[self.paymentModeDictionary valueForKey:@"MulipleCreditCardApplicable"] boolValue];
}

-(BOOL)isCreditCardSwipeApplicable
{
    return [[self.paymentModeDictionary valueForKey:@"CreditCardSwipeApplicable"] boolValue];
}

-(CGFloat)tipAmount
{
    return [[self.paymentModeDictionary valueForKey:@"TipsAmount"] floatValue];
}

-(void)setTipAmount :(CGFloat)tipAmount
{
    NSMutableDictionary *paymentModeDictionary = [self.paymentModeDictionary mutableCopy];
    paymentModeDictionary[@"TipsAmount"] = [NSString stringWithFormat:@"%.2f",tipAmount];
    self.paymentModeDictionary = [NSDictionary dictionaryWithDictionary:paymentModeDictionary];
}

-(NSString *)transactionServerForPaymentMode
{
    return [self.paymentModeDictionary valueForKey:@"TransactionServer"];
}


-(NSString *)isCreditCardSwipe
{
    return [self.paymentModeDictionary valueForKey:@"IsCreditCardSwipe"];
}

- (NSString*)description
{
    NSString *description = [NSString stringWithFormat:@"<PaymentModeItem \n paymentType=%@ \n paymentImage=%@ \n paymentId=%@ \n paymentName=%@ \n calculatedAmount=%@ \n actualAmount=%@ \n isCreditCardSwipe=%@ \n creditCardTransactionStatus = %@> ",self.paymentType,self.paymentImage,self.paymentId,self.paymentName,self.calculatedAmount,self.actualAmount,[self.paymentModeDictionary valueForKey:@"IsCreditCardSwipe"],self.creditCardTransactionStatus];
    
    return description;
}

-(NSNumber *)giftCardBalanceAmount
{
    return [self.paymentModeDictionary valueForKey:@"GiftCardBalanceAmount"];
    
}

-(NSNumber *)giftCardApprovedAmount
{
    return [self.paymentModeDictionary valueForKey:@"GiftCardApprovedAmount"];
    
}


-(NSString *)giftCardNumber
{
    return [self.paymentModeDictionary valueForKey:@"GiftCardNumber"];
}

-(NSString *)isGiftCardApproved
{
    return [self.paymentModeDictionary valueForKey:@"IsGiftCardApproved"];
}


@end
