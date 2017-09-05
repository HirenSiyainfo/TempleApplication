//
//  RegisterInfo+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 11/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "RegisterInfo.h"

@interface RegisterInfo (Dictionary)
-(void)updateRegisterInfoDictionary :(NSDictionary *)registerInfoDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *registerDictionary;

@end
