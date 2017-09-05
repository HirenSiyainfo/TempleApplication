//
//  UserInfo+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 11/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "UserInfo+Dictionary.h"
#import "RightInfo+Dictionary.h"

@implementation UserInfo (Dictionary)

-(NSDictionary *)userInfoDictionary
{
    NSMutableDictionary *userInfo=[[NSMutableDictionary alloc]init];
    userInfo[@"UserId"] = [NSString stringWithFormat:@"%@",self.userId];
    userInfo[@"UserName"] = self.userName;
    userInfo[@"CashInOutFlg"] = self.cashInOutFlg;
    userInfo[@"CashInRequire"] = self.cashInRequire;
    userInfo[@"ClockInOutFlg"] = self.clockInOutFlg;
    userInfo[@"ClockInRequire"] = self.clockInRequire;
    userInfo[@"Email"] = [NSString stringWithFormat:@"%@",self.email];
    userInfo[@"FormEnumData"] = self.formEnumData;
    userInfo[@"IsBranchAdmin"] = self.isBranchAdmin;
    userInfo[@"IsChangePwdOnLogin"] = self.isChangePwdOnLogin;
    userInfo[@"IsFirstTimeLogin"] = self.isFirstTimeLogin;
    userInfo[@"MessageId"] = [NSString stringWithFormat:@"%@",self.messageId];
    userInfo[@"MessageName"] = [NSString stringWithFormat:@"%@",self.messageName];
    userInfo[@"RoleId"] = @(0);
    return userInfo;

}


-(NSMutableArray *)rightInfoForUser
{
    NSArray *userRightArray = self.userRight.allObjects;
    NSMutableArray *rightInfoForUserDetail = [[NSMutableArray alloc]init];
    for (RightInfo *rightInfoForUser in userRightArray) {
        NSMutableDictionary *rightInfo=[[NSMutableDictionary alloc]init];
        rightInfo[@"UserId"] = [NSString stringWithFormat:@"%@",self.userId];
        rightInfo[@"FlgRight"] = rightInfoForUser.flgRight;
        rightInfo[@"POSRight"] = rightInfoForUser.pOSRight;
        rightInfo[@"RightId"] = [NSString stringWithFormat:@"%@",rightInfoForUser.rightId];
        [rightInfoForUserDetail addObject:rightInfo];
    }
    return rightInfoForUserDetail;
}

-(void)updateUserInfoDictionary :(NSDictionary *)userInfoDictionary
{
    self.userId = @([[userInfoDictionary valueForKey:@"UserId"] integerValue]);
    self.userName = [userInfoDictionary valueForKey:@"UserName"];
    self.cashInOutFlg = @([[userInfoDictionary valueForKey:@"CashInOutFlg"]integerValue]);
    self.cashInRequire= @([[userInfoDictionary valueForKey:@"CashInRequire"]integerValue]);
    self.clockInOutFlg= @([[userInfoDictionary valueForKey:@"ClockInOutFlg"]integerValue]);
    self.clockInRequire= @([[userInfoDictionary valueForKey:@"ClockInRequire"]integerValue]);
    self.email = [NSString stringWithFormat:@"%@",[userInfoDictionary valueForKey:@"Email"]];
    if([[userInfoDictionary valueForKey:@"FirstName"] isKindOfClass:[NSString class]]){
        self.firstName = [userInfoDictionary valueForKey:@"FirstName"];
    }
    self.formEnumData = [userInfoDictionary valueForKey:@"FormEnumData"];
    self.isBranchAdmin = @([[userInfoDictionary valueForKey:@"IsBranchAdmin"]integerValue]);
    self.isChangePwdOnLogin = @([[userInfoDictionary valueForKey:@"IsChangePwdOnLogin"]integerValue]);
    self.isFirstTimeLogin= [userInfoDictionary valueForKey:@"IsFirstTimeLogin"];
    self.messageId = [NSString stringWithFormat:@"%@",[userInfoDictionary valueForKey:@"MessageId"]];
    self.messageName = [userInfoDictionary valueForKey:@"MessageName"];
    self.updateDate = [NSDate date];
    self.roleId = @(0);
}

@end
