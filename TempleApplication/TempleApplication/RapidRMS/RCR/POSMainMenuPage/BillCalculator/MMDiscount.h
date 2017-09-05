//
//  MMDiscount.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Discount_M.h"

typedef NS_ENUM(NSInteger, DiscountType) {
    Amount = 1,
    Percentage,
    Free,
    AmountFor,
    AmountAt,
    
};
typedef NS_ENUM(NSInteger, DiscountAppliedOn) {
    Single,
    Case,
    Pack,
   	All,
};


@interface MMDiscount : NSObject

@property (nonatomic , strong) Discount_M *discount_M;

@property (nonatomic , strong) NSString *discountName;

@property (nonatomic, strong) NSMutableArray *applicableLineItems;
@property (nonatomic, strong) NSMutableArray *remainingLineItems;
@property (nonatomic, strong) NSMutableArray *applicableSecondaryItems;
@property (nonatomic, strong) NSMutableArray *applicableRefundLineItems;
@property (nonatomic, strong) NSMutableArray *applicableSecondaryRefundLineItems;
@property (nonatomic, assign) CGFloat primaryQty;
@property (nonatomic, strong) NSNumber *itemCode;
@property (nonatomic, assign) CGFloat applicablePrice;

@property (nonatomic, strong) NSMutableArray *updatedDiscountDictionaryArray;

- (instancetype)initWithDiscountM:(Discount_M*)discount_M ;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary ;

- (BOOL)isApplicableToLineItems:(NSArray*)lineItems;
- (NSArray *)lineItemsForDiscount:(NSArray *)lineItems;
-(CGFloat)primaryItemQty;

//- (NSMutableArray *)remaningLineItems:(NSArray *)lineItems;

- (float)discountedPrice:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItems;
-(float)totalPrice:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItems;
- (float)totalDiscount:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItem;
- (BOOL)isApplicableToLineItems:(NSArray*)lineItems withDiscountArray:(NSMutableArray *)discountArray;

@end
