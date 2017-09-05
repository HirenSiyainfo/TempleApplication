//
//  CreditcardCredetnial+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 11/28/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CreditcardCredetnial.h"

@interface CreditcardCredetnial (Dictionary)
-(void)updateCreditcardCredetnialDictionary :(NSDictionary *)creditcardCredetnialDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *creditcardCredetnialDictionary;

@end
