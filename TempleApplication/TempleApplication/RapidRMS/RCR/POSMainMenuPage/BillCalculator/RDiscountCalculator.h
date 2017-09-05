//
//  RDiscountCalculator.h
//  RapidDiscountDemo
//
//  Created by siya info on 20/01/16.
//  Copyright © 2016 siya info. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BillAmountCalculator.h"
#import "MMDiscount.h"

@class GKGraph;
@class DiscountGraphNode;

@interface RDiscountCalculator : NSObject

@property (nonatomic ,assign) CGFloat totalDiscount;
@property (nonatomic ,assign) CGFloat billAmount;


-(NSMutableArray * )calculateDiscountForReceiptArray:(NSMutableArray *)receiptArray withBillAmountCalculator:(BillAmountCalculator *)billAmountCalculator;

- (GKGraph*)discountGraph;
- (DiscountGraphNode*)headNode;
-(NSArray *)pathForDiscount;
@end

@interface DiscountBlock : NSObject
@property (nonatomic) float discountAmount;
@property (nonatomic) float discountedPrice;
@property (nonatomic) NSInteger discountQuantity;
@property (nonatomic) float averagePrice;
@property (nonatomic) NSInteger appliedFactor;
@property (nonatomic) NSInteger maximumFactor;
@property (nonatomic , strong) MMDiscount *discount;
@end


@interface DiscountGroup : NSObject
@property (nonatomic , strong) NSMutableArray *discounts;
@property (nonatomic , strong) NSMutableSet *discountGrouplineItems;
@property (nonatomic , strong) NSMutableArray *lineItemForDiscount;

@end

