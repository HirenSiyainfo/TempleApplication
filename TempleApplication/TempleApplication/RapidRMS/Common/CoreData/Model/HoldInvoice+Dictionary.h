//
//  HoldInvoice+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HoldInvoice.h"

@interface HoldInvoice (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *holdInvoiceDictionary;
-(void)updateholdInvoiceFromDictionary :(NSDictionary *)holdInvoiceDictionary;
@end
