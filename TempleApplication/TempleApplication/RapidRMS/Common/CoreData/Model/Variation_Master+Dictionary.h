//
//  Variation_Master+Dictionary.h
//  RapidRMS
//
//  Created by Siya on 03/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Variation_Master.h"

@interface Variation_Master (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemVariationMasteDictionary;
-(void)updateMasterVariationMDictionary :(NSDictionary *)itemVariationMDictionary;
@end
