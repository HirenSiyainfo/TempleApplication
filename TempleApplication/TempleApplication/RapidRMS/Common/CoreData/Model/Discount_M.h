//
//  Discount_M.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/02/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
typedef NS_ENUM(NSUInteger, MMDFreeType)
{
    MMDFreeTypeAmount = 1,
    MMDFreeTypePercentage,
    MMDFreeTypeFree,
    MMDFreeTypeFor,
    MMDFreeTypeUnitAmount,
    MMDFreeTypePriceWithTax,
};
typedef NS_ENUM(NSUInteger, MMDQuantityType)
{
    MMDQuantityTypeExact = 1,
    MMDQuantityTypeODD,
};
@class Discount_Primary_MD, Discount_Secondary_MD;

NS_ASSUME_NONNULL_BEGIN

@interface Discount_M : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
-(void)updateDiscountFromDictionary :(nullable NSDictionary *)itemDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary * _Nonnull discountDetailDisctionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray * _Nonnull discountPrimaryArray;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray * _Nonnull discountSecondaryArray;

@end

NS_ASSUME_NONNULL_END

#import "Discount_M+CoreDataProperties.h"
