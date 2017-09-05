//
//  Discount_Secondary_MD.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/02/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Discount_M, Item;

NS_ASSUME_NONNULL_BEGIN

@interface Discount_Secondary_MD : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
-(void)updateDiscountSecondaryMDFromDictionary :(NSDictionary *)discountDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary * _Nonnull discountSecondaryDisctionary;
@end

NS_ASSUME_NONNULL_END

#import "Discount_Secondary_MD+CoreDataProperties.h"
