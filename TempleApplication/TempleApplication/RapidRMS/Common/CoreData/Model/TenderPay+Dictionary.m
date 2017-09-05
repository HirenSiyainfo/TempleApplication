//
//  TenderPay+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 21/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TenderPay+Dictionary.h"

@implementation TenderPay (Dictionary)

-(NSDictionary *)tenderPayDictionary
{
    NSMutableDictionary *tenderPayDictionary = [[NSMutableDictionary alloc] init];
    tenderPayDictionary[@"PayId"] = [NSString stringWithFormat:@"%@", self.payId];
    tenderPayDictionary[@"PaymentName"] = [NSString stringWithFormat:@"%@", self.paymentName];
    tenderPayDictionary[@"CardIntType"] = [NSString stringWithFormat:@"%@", self.cardIntType];
    tenderPayDictionary[@"PayImage"] = [NSString stringWithFormat:@"%@", self.payImage];
    tenderPayDictionary[@"PayCode"] = [NSString stringWithFormat:@"%@", self.payCode];
    tenderPayDictionary[@"SurchargeType"] = [NSString stringWithFormat:@"%@", self.surchargeType];
    tenderPayDictionary[@"ShortcutKeys"] = [NSString stringWithFormat:@"%@", self.shortcutKeys];
    tenderPayDictionary[@"FlgSurcharge"] = [NSString stringWithFormat:@"%@", self.flgSurcharge];
    tenderPayDictionary[@"SurchargeFixAmt"] = [NSString stringWithFormat:@"%@", self.surchargeFixAmt];
    tenderPayDictionary[@"ChkDropAmt"] = [NSString stringWithFormat:@"%@", self.chkDropAmt];
    tenderPayDictionary[@"GasAmountLimit"] = [NSString stringWithFormat:@"%@", self.gasAmountLimit];
    return tenderPayDictionary;
}

-(void)updateTenderPayFromDictionary :(NSDictionary *)tenderPayDictionary
{
    self.payId =  @([[tenderPayDictionary valueForKey:@"PayId"] integerValue]);
    self.paymentName =[tenderPayDictionary valueForKey:@"PaymentName"] ;
    self.payImage =[tenderPayDictionary valueForKey:@"PayImage"];
    self.cardIntType = [tenderPayDictionary valueForKey:@"CardIntType"];
    self.payCode = [tenderPayDictionary valueForKey:@"PayCode"];
    self.flgSurcharge = @([[tenderPayDictionary valueForKey:@"FlgSurcharge"] boolValue]);
    self.surchargeType = [tenderPayDictionary valueForKey:@"SurchargeType"];
    self.surchargeFixAmt = @([[tenderPayDictionary valueForKey:@"SurchargeFixAmt"] floatValue]);
    self.shortcutKeys = [tenderPayDictionary valueForKey:@"ShortcutKeys"];
    self.chkDropAmt = @([[tenderPayDictionary valueForKey:@"ChkDropAmt"] boolValue]);
    
    self.gasAmountLimit =  @([[tenderPayDictionary valueForKey:@"GasAmountLimit"] integerValue]);

}

@end
