//
//  RoleInfo+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/23/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RoleInfo.h"

@interface RoleInfo (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *roleInfoDictionary;
-(void)updateRoleInfoDictionary :(NSDictionary *)roleInfoDictionary;
@end
