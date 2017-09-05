//
//  ItemVariation_M+Dictionary.h
//  RapidRMS
//
//  Created by Siya on 28/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemVariation_M.h"

@interface ItemVariation_M (Dictionary)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemVariationMDictionary;
-(void)updateitemVariationMDictionary :(NSDictionary *)itemVariationMDictionary;

@end
