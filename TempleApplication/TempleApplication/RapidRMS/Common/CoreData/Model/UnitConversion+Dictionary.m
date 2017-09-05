//
//  UnitConversion+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 11/19/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "UnitConversion+Dictionary.h"

@implementation UnitConversion (Dictionary)


-(void)updateUnitScaleUnitDictionary :(NSDictionary *)unitScaleUnitDictionary
{
    self.fromUnitType = [unitScaleUnitDictionary valueForKey:@"fromUnitType"];
    self.toUnitType = [unitScaleUnitDictionary valueForKey:@"toUnitType"];
    self.factor = [unitScaleUnitDictionary valueForKey:@"factor"];
}


@end
