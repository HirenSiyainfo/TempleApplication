//
//  ItemMixMatchDiscountCalculator.h
//  RapidRMS
//
//  Created by Siya Infotech on 11/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemMixMatchDiscountCalculator : NSObject
- (void)calculateDiscountForBillEntries:(NSArray*)billItemEntries;
@end
