//
//  BranchInfo+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 11/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "BranchInfo+Dictionary.h"

@implementation BranchInfo (Dictionary)

-(NSDictionary *)branchInfoDictionary
{
    NSMutableDictionary *userInfo=[[NSMutableDictionary alloc]init];
    userInfo[@"Address1"] = [NSString stringWithFormat:@"%@",self.address1];
    userInfo[@"Address2"] = self.address2;
    userInfo[@"BranchId"] = self.branchId;
    userInfo[@"BranchName"] = self.branchName;
    userInfo[@"City"] = self.city;
    userInfo[@"Country"] = self.country;
    userInfo[@"Email"] = [NSString stringWithFormat:@"%@",self.email];
    userInfo[@"FilePath"] = self.filePath;
    userInfo[@"IsDeleted"] = @(self.is_Deleted.integerValue);
    userInfo[@"PhoneNo1"] = self.phoneNo1;
    userInfo[@"PhoneNo2"] = self.phoneNo2;
    userInfo[@"State"] = [NSString stringWithFormat:@"%@",self.state];
    userInfo[@"ZipCode"] = [NSString stringWithFormat:@"%@",self.zipCode];
    userInfo[@"objmodule"] = self.objmodule;
    userInfo[@"HelpMessage1"] = [NSString stringWithFormat:@"%@",self.helpMessage1];
    userInfo[@"HelpMessage2"] = [NSString stringWithFormat:@"%@",self.helpMessage2];
    userInfo[@"HelpMessage3"] = [NSString stringWithFormat:@"%@",self.helpMessage3];
    userInfo[@"SupportEmail"] = [NSString stringWithFormat:@"%@",self.supportEmail];

    return userInfo;
    
}

-(void)updateBranchInfoDictionary :(NSDictionary *)branchInfoDictionary
{
   self.address1 = [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"Address1"]];
   self.address2 = [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"Address2"]];
   self.branchId= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"BranchId"]];
   self.branchName= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"BranchName"]];
   self.city= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"City"]];
   self.country= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"Country"]];
   self.email= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"Email"]];
   self.filePath= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"FilePath"]];
   self.is_Deleted= @([[branchInfoDictionary valueForKey:@"IsDeleted"] integerValue]);
   self.phoneNo1= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"PhoneNo1"]];
   self.phoneNo2= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"PhoneNo2"]];
   self.state= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"State"]];
   self.zipCode= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@""]];
   self.objmodule= [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"objmodule"]];
    self.helpMessage1 = [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"HelpMessage1"]];
    self.helpMessage2 = [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"HelpMessage2"]];
    self.helpMessage3 = [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"HelpMessage3"]];
    self.supportEmail = [NSString stringWithFormat:@"%@",[branchInfoDictionary valueForKey:@"SupportEmail"]];
}

@end
