//
//  RightInfo.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/24/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfo;

@interface RightInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * flgRight;
@property (nonatomic, retain) NSString * pOSRight;
@property (nonatomic, retain) NSNumber * rightId;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) UserInfo *userInfo;

@end
