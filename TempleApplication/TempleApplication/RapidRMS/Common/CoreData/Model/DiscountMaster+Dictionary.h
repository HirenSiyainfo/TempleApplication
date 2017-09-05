//
//  DiscountMaster+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 5/29/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DiscountMaster.h"

@interface DiscountMaster (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *discountMasterDictionary;
-(void)updateDiscountMasterFromDictionary :(NSDictionary *)discountMasterDictionary;
@end
