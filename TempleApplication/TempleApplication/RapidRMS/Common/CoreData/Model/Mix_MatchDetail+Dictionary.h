//
//  Mix_MatchDetail+Dictionary.h
//  RapidRMS
//
//  Created by Siya Infotech on 23/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Mix_MatchDetail.h"

@interface Mix_MatchDetail (Dictionary)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *mixMatchDetailDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *mixMatchLoadDictionary;
-(void)updateMixMatchDetailFromDictionary :(NSDictionary *)mixMatchDetailDictionary;

@end
