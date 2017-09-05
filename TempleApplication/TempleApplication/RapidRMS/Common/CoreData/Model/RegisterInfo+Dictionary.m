//
//  RegisterInfo+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 11/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "RegisterInfo+Dictionary.h"

@implementation RegisterInfo (Dictionary)


-(NSDictionary *)registerDictionary
{
    NSMutableDictionary *registerInfo = [[NSMutableDictionary alloc]init];
    registerInfo[@"BranchId"] = [NSString stringWithFormat:@"%@",self.branchId];
    registerInfo[@"DBName"] = self.dBName;
    registerInfo[@"InvPrefix"] = self.invPrefix;
    registerInfo[@"RegisterId"] = self.registerId;
    registerInfo[@"RegisterInvNo"] = self.registerInvNo;
    registerInfo[@"RegisterName"] = self.registerName;
    registerInfo[@"TokenId"] = self.tokenId;
    registerInfo[@"ZId"] = [NSString stringWithFormat:@"%@",self.zId];
    registerInfo[@"ZRequired"] = @(self.zRequired.integerValue);
    return registerInfo;
}



-(void)updateRegisterInfoDictionary :(NSDictionary *)registerInfoDictionary
{
    self.branchId = [NSString stringWithFormat:@"%@",[registerInfoDictionary valueForKey:@"BranchId"]] ;
    self.dBName= [registerInfoDictionary valueForKey:@"DBName"];
    self.invPrefix= [registerInfoDictionary valueForKey:@"InvPrefix"];
    self.registerId= [NSString stringWithFormat:@"%@",[registerInfoDictionary valueForKey:@"RegisterId"]];
    self.registerInvNo= [NSString stringWithFormat:@"%@",[registerInfoDictionary valueForKey:@"RegisterInvNo"]];
    self.registerName= [registerInfoDictionary valueForKey:@"RegisterName"];
    self.tokenId= [registerInfoDictionary valueForKey:@"TokenId"];
    self.zId= [NSString stringWithFormat:@"%@",[registerInfoDictionary valueForKey:@"ZId"]];
    self.zRequired= @([[registerInfoDictionary valueForKey:@"ZRequired"] integerValue]);

}

@end
