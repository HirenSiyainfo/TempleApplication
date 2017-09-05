//
//  RightInfo+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 2/23/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RightInfo+Dictionary.h"

@implementation RightInfo (Dictionary)

-(NSDictionary *)rightInfoDictionary
{
    NSMutableDictionary *rightInfo=[[NSMutableDictionary alloc]init];
    rightInfo[@"UserId"] = [NSString stringWithFormat:@"%@",self.userId];
    rightInfo[@"FlgRight"] = self.flgRight;
    rightInfo[@"POSRight"] = self.pOSRight;
    rightInfo[@"RightId"] = self.rightId;
    return rightInfo;
}
-(void)updateRightInfoDictionary :(NSDictionary *)rightInfoDictionary
{
    self.flgRight =  @([[rightInfoDictionary valueForKey:@"FlgRight"] boolValue]);
    self.pOSRight =[rightInfoDictionary valueForKey:@"POSRight"] ;
    self.rightId = @([[rightInfoDictionary valueForKey:@"RightId"] integerValue]) ;
    self.userId =[rightInfoDictionary valueForKey:@"UserId"] ;
}

@end
