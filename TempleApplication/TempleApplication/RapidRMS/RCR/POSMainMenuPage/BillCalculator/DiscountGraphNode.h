//
//  DiscountGraphNode.h
//  TicTacToe
//
//  Created by siya info on 13/01/16.
//  Copyright © 2016 siya info. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>
#import "MMDiscount.h"
#import "LineItem.h"

@interface DiscountGraphNode : GKGraphNode
@property (nonatomic, strong, readonly) MMDiscount *discount;
@property (nonatomic, strong, readonly) LineItem *primaryItem;
@property (nonatomic, strong, readonly) LineItem *secondaryItem;


@property (nonatomic, strong, readonly) NSArray *primaryItems;
@property (nonatomic, strong, readonly) NSArray *secondaryItems;



- (instancetype)initWithDiscount:(MMDiscount*)discount primaryItem:(LineItem*)primaryItem secondaryItem:(LineItem*)secondaryItem;
- (instancetype)initWithDiscount:(MMDiscount*)discount primaryItems:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItems;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (float)estimatedCostToNode:(DiscountGraphNode *)node;
- (float)costToNode:(DiscountGraphNode *)node;

- (float)totalPrice;
- (float)totalDiscount;
- (float)discountedPrice;

@end
