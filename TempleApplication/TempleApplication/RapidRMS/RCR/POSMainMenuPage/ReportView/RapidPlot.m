//
//  RapidPlot.m
//  RapidRMS
//
//  Created by siya-IOS5 on 7/8/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RapidPlot.h"

@implementation RapidPlot


-(NSUInteger)numberOfLegendEntries
{
   NSInteger numberOfLegends = super.numberOfLegendEntries;
    return MIN(14, numberOfLegends);
}


@end
