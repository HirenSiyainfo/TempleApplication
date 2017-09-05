//
//  TenderPay+Dictionary.h
//  RapidRMS
//
//  Created by Siya Infotech on 21/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TenderPay.h"

@interface TenderPay (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *tenderPayDictionary;
-(void)updateTenderPayFromDictionary :(NSDictionary *)tenderPayDictionary;
@end
