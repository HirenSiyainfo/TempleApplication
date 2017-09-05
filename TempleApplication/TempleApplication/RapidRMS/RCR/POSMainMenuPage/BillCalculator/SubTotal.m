//
//  SubTotal.m
//  RapidRMS
//
//  Created by siya-IOS5 on 2/19/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "SubTotal.h"

@implementation SubTotal
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.lineItemTaxArray = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
