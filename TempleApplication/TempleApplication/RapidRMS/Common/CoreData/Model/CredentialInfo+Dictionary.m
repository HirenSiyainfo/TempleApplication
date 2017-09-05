//
//  CredentialInfo+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 2/23/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CredentialInfo+Dictionary.h"

@implementation CredentialInfo (Dictionary)

-(NSDictionary *)credetnialDictionary
{
    return nil;
}

-(void)updateCredetnialDictionary :(NSDictionary *)creditcardCredetnialDictionary
{
    self.email = [creditcardCredetnialDictionary valueForKey:@"Email"];
    self.userName = [creditcardCredetnialDictionary valueForKey:@"UserName"];
    self.password = [creditcardCredetnialDictionary valueForKey:@"Password"];
    self.quickAccess = [creditcardCredetnialDictionary valueForKey:@"QuickAccessPSW"];
    self.userId = [creditcardCredetnialDictionary valueForKey:@"UserId"];
}

@end
