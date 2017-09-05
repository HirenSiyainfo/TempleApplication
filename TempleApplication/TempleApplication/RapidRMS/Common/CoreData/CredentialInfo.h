//
//  CredentialInfo.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/23/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfo;

@interface CredentialInfo : NSManagedObject

@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * quickAccess;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) UserInfo *credentialToUser;

@end
