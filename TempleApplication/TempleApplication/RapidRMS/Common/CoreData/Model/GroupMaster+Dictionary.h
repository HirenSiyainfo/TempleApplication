//
//  GroupMaster+Dictionary.h
//  RapidRMS
//
//  Created by Siya Infotech on 14/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "GroupMaster.h"

@interface GroupMaster (Dictionary)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *groupMasterDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *groupMasterLoadDictionary;
-(void)updateGroupMasterFromDictionary :(NSDictionary *)groupMasterDictionary;

@end
