//
//  ModuleInfo+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 11/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ModuleInfo+Dictionary.h"

@implementation ModuleInfo (Dictionary)

-(NSDictionary *)moduleInfoDictionary
{
    NSMutableDictionary *moduleInfo=[[NSMutableDictionary alloc]init];
    moduleInfo[@"CompanyId"] = [NSString stringWithFormat:@"%@",self.companyId];
    moduleInfo[@"DBName"] = [NSString stringWithFormat:@"%@",self.dBName];
    moduleInfo[@"IsActive"] = @(self.isActive.integerValue);
    moduleInfo[@"IsCustomerDisplay"] = @(self.isCustomerDisplay.integerValue);
    moduleInfo[@"IsRCRGAS"] = @(self.isRCRGAS.integerValue);
    moduleInfo[@"MacAdd"] = [NSString stringWithFormat:@"%@",self.macAdd];
    moduleInfo[@"ModuleAccessId"] = @(self.moduleAccessId.integerValue);
    moduleInfo[@"ModuleCode"] = [NSString stringWithFormat:@"%@",self.moduleCode];
    moduleInfo[@"ModuleId"] = @(self.moduleId.integerValue);
    moduleInfo[@"ModuleType"] = [NSString stringWithFormat:@"%@",self.moduleType];
    moduleInfo[@"Name"] = [NSString stringWithFormat:@"%@",self.name];
    moduleInfo[@"RegisterName"] = [NSString stringWithFormat:@"%@",self.registerName];
    moduleInfo[@"RegisterNo"] = @(self.registerNo.integerValue);
    moduleInfo[@"TokenId"] = [NSString stringWithFormat:@"%@",self.tokenId];
    moduleInfo[@"IsRelease"] = @(self.isRelease.integerValue);


    return moduleInfo;
}


-(void)updateModuleInfoDictionary :(NSDictionary *)moduleInfoDictionary
{
    self.companyId = [NSString stringWithFormat:@"%@",[moduleInfoDictionary valueForKey:@"CompanyId"]] ;
    self.dBName = [moduleInfoDictionary valueForKey:@"DBName"];
    self.isActive = @([[moduleInfoDictionary valueForKey:@"IsActive"] integerValue]);
    self.isCustomerDisplay = @([[moduleInfoDictionary valueForKey:@"IsCustomerDisplay"]integerValue]);
    self.isRCRGAS = @([[moduleInfoDictionary valueForKey:@"IsRCRGAS"]integerValue]);
    self.macAdd = [moduleInfoDictionary valueForKey:@"MacAdd"];
    self.moduleAccessId = @([[moduleInfoDictionary valueForKey:@"ModuleAccessId"] integerValue]);
    self.moduleCode = [moduleInfoDictionary valueForKey:@"ModuleCode"];
    self.moduleId = @([[moduleInfoDictionary valueForKey:@"ModuleId"] integerValue]);
    self.moduleType = [moduleInfoDictionary valueForKey:@"ModuleType"];
    self.name = [moduleInfoDictionary valueForKey:@"Name"];
    self.registerName = [moduleInfoDictionary valueForKey:@"RegisterName"];
    self.registerNo = @([[moduleInfoDictionary valueForKey:@"RegisterNo"] integerValue]);
    self.tokenId = [moduleInfoDictionary valueForKey:@"TokenId"];
    self.isRelease =  @([[moduleInfoDictionary valueForKey:@"IsRelease"] integerValue]);
}



@end
