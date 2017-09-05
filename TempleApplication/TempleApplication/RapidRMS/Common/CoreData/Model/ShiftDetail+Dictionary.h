//
//  ShiftDetail+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/12/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ShiftDetail.h"

@interface ShiftDetail (Dictionary)
-(void)updateShiftDetailDictionary :(NSDictionary *)shiftDetailDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *shiftDetailDictionary;
@end
