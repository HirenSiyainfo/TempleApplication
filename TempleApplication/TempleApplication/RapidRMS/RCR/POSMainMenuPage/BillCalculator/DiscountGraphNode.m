//
//  DiscountGraphNode.m
//  TicTacToe
//
//  Created by siya info on 13/01/16.
//  Copyright © 2016 siya info. All rights reserved.
//

#import "DiscountGraphNode.h"

@interface DiscountGraphNode ()
@property (nonatomic, strong) LineItem *primaryItem;
@property (nonatomic, strong) LineItem *secondaryItem;
@end

@implementation DiscountGraphNode

- (instancetype)initWithDiscount:(MMDiscount*)discount primaryItem:(LineItem*)primaryItem secondaryItem:(LineItem*)secondaryItem {
    self = [super init];
    if (self) {
        _discount = discount;
        _primaryItem = primaryItem;
        _secondaryItem = secondaryItem;
    }
    return self;
}

- (instancetype)initWithDiscount:(MMDiscount*)discount primaryItems:(NSArray*)primaryItems secondaryItems:(NSArray*)secondaryItems
{
    self = [super init];
    if (self) {
        _discount = discount;
        _primaryItems = primaryItems;
        _secondaryItems = secondaryItems;
    }
    return self;
}
- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
    }
    return self;
}



- (float)estimatedCostToNode:(DiscountGraphNode *)node {
    return [self costToNode:node];
}

- (float)costToNode:(DiscountGraphNode *)node {
    return [node nodeCost];
}

- (float)nodeCost {
//    NSLog(@"nodeCost");
    float cost = [_discount discountedPrice:_primaryItems secondaryItems:_secondaryItems];
//    if (cost < 0) {
//        return 0;
//    }
    return cost;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"[%0x - Name:%@, Value:%@, Cost: %.2f]", (void*)self, self.discount.discount_M.discountType, self.discount.discount_M.free, [self nodeCost]];
}


- (float)totalPrice {
    return [_discount totalPrice:_primaryItems secondaryItems:_secondaryItems];
}

- (float)totalDiscount {
    return [_discount totalDiscount:_primaryItems secondaryItems:_secondaryItems];
}

- (float)discountedPrice {
    
    return [_discount discountedPrice:_primaryItems secondaryItems:_secondaryItems];

}



@end
