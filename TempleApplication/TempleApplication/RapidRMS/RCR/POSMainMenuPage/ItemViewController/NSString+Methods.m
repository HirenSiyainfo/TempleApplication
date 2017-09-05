//
//  NSString+Methods.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/23/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "NSString+Methods.h"

@implementation NSString (Methods)

-(NSString *)trimeString
{
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSArray *)arrayFromString :(NSString *)string WithSepratedComponents:(NSString *)component
{
    return [string componentsSeparatedByString:component];
}
-(BOOL)isBlank
{
    if([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || [self isKindOfClass:[NSNull class]])
        return YES;
    return NO;
}

-(BOOL)contains:(NSString *)string
{
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}
- (NSString*)add:(NSString*)string
{
    if(!string || string.length == 0)
        return self;
    return [self stringByAppendingString:string];
}

-(NSString *)applyCurrencyFormatter:(CGFloat)amount
{
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatter.maximumFractionDigits = 2;
    
    NSNumber *amountNumber = @(amount);
    NSString * stringValue = [NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:amountNumber]];
    return stringValue;
}



@end
