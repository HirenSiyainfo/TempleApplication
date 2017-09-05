//
//  BranchInfo+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 11/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "BranchInfo.h"

@interface BranchInfo (Dictionary)
-(void)updateBranchInfoDictionary :(NSDictionary *)branchInfoDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *branchInfoDictionary;

@end
