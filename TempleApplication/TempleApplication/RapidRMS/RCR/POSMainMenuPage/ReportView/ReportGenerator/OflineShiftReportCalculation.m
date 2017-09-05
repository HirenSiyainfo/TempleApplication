//
//  OflineShiftReportCalculation.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "OflineShiftReportCalculation.h"

@implementation OflineShiftReportCalculation


- (NSMutableDictionary *)onlineReportSummary
{
    NSMutableArray *zOnlineMainArray = [onlineReportArray.firstObject valueForKey:@"objShiftDetail"];
    NSMutableDictionary *zOnlineMainDictionary = zOnlineMainArray.firstObject;
    return zOnlineMainDictionary;
}

- (NSMutableArray *)onlineTenderDetail
{
    NSMutableArray *zOnlineTenderArray = [onlineReportArray.firstObject valueForKey:@"objShiftTender"];
    return [zOnlineTenderArray mutableCopy];
}
-(NSString *)tenderKeyForReport
{
    return @"objShiftTender";
}
@end
