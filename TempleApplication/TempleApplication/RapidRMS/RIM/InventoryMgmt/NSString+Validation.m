//
//  NSString+Validation.m
//  RapidRMS
//
//  Created by Siya9 on 02/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

+(NSString *)trimSpacesFromStartAndEnd:(NSString *)strString{
    return [strString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
-(BOOL)isValidIP
{
    
        NSString *ipRegEx =
        @"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";
        
        NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegEx];
        BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:self];
        
        return myStringMatchesRegEx;
}
@end
