//
//  NSString+Methods.h
//  RapidRMS
//
//  Created by siya-IOS5 on 9/23/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Methods)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *trimeString;
-(BOOL)contains:(NSString *)string;
@property (NS_NONATOMIC_IOSONLY, getter=isBlank, readonly) BOOL blank;
- (NSString*)add:(NSString*)string;
-(NSString *)applyCurrencyFormatter:(CGFloat)amount;
@end
