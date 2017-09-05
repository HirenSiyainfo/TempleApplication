//
//  ModuleInfo+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 11/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ModuleInfo.h"

@interface ModuleInfo (Dictionary)
-(void)updateModuleInfoDictionary :(NSDictionary *)moduleInfoDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *moduleInfoDictionary;

@end
