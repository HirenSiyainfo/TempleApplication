//
//  RoleInfo+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 2/23/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RoleInfo+Dictionary.h"

@implementation RoleInfo (Dictionary)
-(NSDictionary *)roleInfoDictionary{
    return nil;
}
-(void)updateRoleInfoDictionary :(NSDictionary *)roleInfoDictionary
{
    self.canEdit =  @([[roleInfoDictionary valueForKey:@"CanEdit"] boolValue]);;
    self.isView =[roleInfoDictionary valueForKey:@"IsView"] ;
    self.menuName = [NSString stringWithFormat:@"%@",[roleInfoDictionary valueForKey:@"MenuName"]] ;
    self.userId =[roleInfoDictionary valueForKey:@"UserId"] ;
}
@end
