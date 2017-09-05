//
//  UserInfo+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 11/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "UserInfo.h"

@interface UserInfo (Dictionary)
-(void)updateUserInfoDictionary :(NSDictionary *)userInfoDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *userInfoDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray *rightInfoForUser;

@end
