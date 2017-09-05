//
//  RoleInfo.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/24/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfo;

@interface RoleInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * canEdit;
@property (nonatomic, retain) NSNumber * isView;
@property (nonatomic, retain) NSString * menuName;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * userRoleId;
@property (nonatomic, retain) UserInfo *roleToUser;

@end
