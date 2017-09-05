//
//  NSArray+Methods.h
//  RapidRMS
//
//  Created by siya-IOS5 on 9/23/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Methods)
- (NSArray*) filterByProperty:(NSString *) p WithValue:(NSString *)value;
-(NSArray *)sortingArrayWithValue :(NSString *)value WithAscendingType:(BOOL)isAscending;
-(NSArray *)sortingArrayWithMultipleValue :(NSArray *)values;

@end
