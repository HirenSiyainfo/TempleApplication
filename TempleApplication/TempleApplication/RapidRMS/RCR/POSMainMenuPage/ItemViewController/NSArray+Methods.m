//
//  NSArray+Methods.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/23/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "NSArray+Methods.h"

@implementation NSArray (Methods)

- (NSArray*) filterByProperty:(NSString *)property WithValue:(id)value
{
    NSPredicate *Filterpredicate = [NSPredicate predicateWithFormat:@"%k == %@", property,value];
    return [self filteredArrayUsingPredicate:Filterpredicate];
}


-(NSArray *)sortingArrayWithValue :(NSString *)value WithAscendingType:(BOOL)isAscending
{
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:value
                                                                    ascending:isAscending];
    NSArray *sortDescriptors = @[firstDescriptor];
    
   return [self sortedArrayUsingDescriptors:sortDescriptors];
}

-(NSArray *)sortingArrayWithMultipleValue :(NSArray *)values
{
    NSMutableArray *shortDescriptorArray = [[NSMutableArray alloc]init];
    for (int i= 0; i < values.count; i++)
    {
        NSSortDescriptor *shortDescriptor = [[NSSortDescriptor alloc] initWithKey:values[i]
                                                                        ascending:YES];
        [shortDescriptorArray addObject:shortDescriptor];
        
    }
    NSArray *sortDescriptors = [NSArray arrayWithArray:shortDescriptorArray];
    
    return [self sortedArrayUsingDescriptors:sortDescriptors];
}

@end
