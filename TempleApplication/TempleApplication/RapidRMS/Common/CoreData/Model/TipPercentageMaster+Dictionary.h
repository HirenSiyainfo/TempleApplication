//
//  TipPercentageMaster+Dictionary.h
//  RapidRMS
//
//  Created by Siya Infotech on 11/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TipPercentageMaster.h"

@interface TipPercentageMaster (Dictionary)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *tipPercentageMasterDictionary;
-(void)updateTipPercentageMasterDictionary :(NSDictionary *)tipPercentageMasterDictionary;

@end
