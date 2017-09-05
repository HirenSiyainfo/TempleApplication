//
//  UserRights.m
//  RapidRMS
//
//  Created by Siya-mac5 on 25/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "UserRights.h"
#import "UserInfo+Dictionary.h"
#import "RmsDbController.h"

@interface UserRights()

@end
@implementation UserRights

+ (void)updateUserRights:(NSArray *)newUserRights
{
//    Delete Old Rights For Current User than Insert New Rights From Server.
    
    RmsDbController *rmsDbController = [RmsDbController sharedRmsDbController];
    
    //Create Private Context Object
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:rmsDbController.managedObjectContext];
    
    //Create Update Manager Object For Getting User Info
    UpdateManager *updateManager = [[UpdateManager alloc] initWithManagedObjectContext:privateContextObject delegate:nil];
    
    //Update Rights For Current User
    NSNumber *userId = [[rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userId];
    [updateManager deleteUserRights:privateContextObject usingPredicate:predicate];
    UserInfo *userInfo = [updateManager fetchUserInfo:userId usingMOC:privateContextObject usingPredicate:predicate];
    [updateManager updateRightInfoWithDetail:newUserRights forUser:userInfo withContext:privateContextObject];
    [UpdateManager saveContext:privateContextObject];
}

+ (BOOL)hasRights:(UserRight)userRight
{
    //Get User Info For Current User than Check Rights In User Rights from User Info.
    
    BOOL hasRights = false;
    RmsDbController *rmsDbController = [RmsDbController sharedRmsDbController];
    
    //Create Private Context Object
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:rmsDbController.managedObjectContext];
    
    //Create Update Manager Object For Getting User Info
    UpdateManager *updateManager = [[UpdateManager alloc] initWithManagedObjectContext:privateContextObject delegate:nil];
    
    //Get Current User Info
    NSNumber *userId = [[rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userId];
    UserInfo *userInfo = [updateManager fetchUserInfo:userId usingMOC:privateContextObject usingPredicate:predicate];
    NSMutableArray *userRights = [userInfo rightInfoForUser];
    
    //Check Rights
    NSPredicate *hasRightPredicate = [NSPredicate predicateWithFormat:@"(RightId == %d OR  RightId == %@) AND FlgRight == %d",userRight,[NSString stringWithFormat:@"%ld",(long)userRight],1];
    NSArray *resultRightArray = [userRights filteredArrayUsingPredicate:hasRightPredicate];
    if ([resultRightArray isKindOfClass:[NSArray class]]) {
        if (resultRightArray != nil && resultRightArray.count > 0) {
            hasRights =  true;
        }
    }
    return hasRights;
}

@end
