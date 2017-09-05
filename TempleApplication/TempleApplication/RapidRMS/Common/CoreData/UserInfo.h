//
//  UserInfo.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/23/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CredentialInfo, RightInfo, RoleInfo;

@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * cashInOutFlg;
@property (nonatomic, retain) NSNumber * cashInRequire;
@property (nonatomic, retain) NSNumber * clockInOutFlg;
@property (nonatomic, retain) NSNumber * clockInRequire;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * formEnumData;
@property (nonatomic, retain) NSNumber * isBranchAdmin;
@property (nonatomic, retain) NSNumber * isChangePwdOnLogin;
@property (nonatomic, retain) NSNumber * isFirstTimeLogin;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * messageName;
@property (nonatomic, retain) NSNumber * roleId;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *userRight;
@property (nonatomic, retain) NSSet *userRole;
@property (nonatomic, retain) NSSet *userCredential;
@end

@interface UserInfo (CoreDataGeneratedAccessors)

- (void)addUserRightObject:(RightInfo *)value;
- (void)removeUserRightObject:(RightInfo *)value;
- (void)addUserRight:(NSSet *)values;
- (void)removeUserRight:(NSSet *)values;

- (void)addUserRoleObject:(RoleInfo *)value;
- (void)removeUserRoleObject:(RoleInfo *)value;
- (void)addUserRole:(NSSet *)values;
- (void)removeUserRole:(NSSet *)values;

- (void)addUserCredentialObject:(CredentialInfo *)value;
- (void)removeUserCredentialObject:(CredentialInfo *)value;
- (void)addUserCredential:(NSSet *)values;
- (void)removeUserCredential:(NSSet *)values;

@end
