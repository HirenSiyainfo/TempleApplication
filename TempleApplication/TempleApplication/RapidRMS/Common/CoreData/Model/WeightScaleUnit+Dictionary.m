//
//  WeightScaleUnit+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 11/18/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "WeightScaleUnit+Dictionary.h"

@implementation WeightScaleUnit (Dictionary)
-(void)updateWeightScaleUnitDictionary :(NSDictionary *)weightScaleUnitDictionary
{
    self.weightScaleType = [weightScaleUnitDictionary valueForKey:@"weightScaleType"];
    self.unitType = [weightScaleUnitDictionary valueForKey:@"unitType"];
    self.unitScale = [weightScaleUnitDictionary valueForKey:@"unitScale"];
}

@end
