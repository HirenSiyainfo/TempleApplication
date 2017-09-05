//
//  RightInfo+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/23/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RightInfo.h"

@interface RightInfo (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *rightInfoDictionary;
-(void)updateRightInfoDictionary :(NSDictionary *)rightInfoDictionary;
@end
