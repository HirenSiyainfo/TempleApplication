//
//  ItemVariation_Md+Dictionary.h
//  RapidRMS
//
//  Created by Siya on 28/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemVariation_Md.h"

@interface ItemVariation_Md (Dictionary)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemVariationMdDictionary;
-(void)updateitemVariationMdDictionary :(NSDictionary *)itemVariationMdDictionary;
@end
