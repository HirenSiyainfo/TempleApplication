//
//  PriceLevelDiscount.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/8/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDiscount.h"

@interface PriceLevelDiscount : MMDiscount
//@property (nonatomic, assign) CGFloat primaryQty;
//@property (nonatomic, strong) NSNumber *itemCode;
//@property (nonatomic, assign) CGFloat applicablePrice;
@property (nonatomic, strong) NSString *packageType;

- (instancetype)initWithPrimaryQty:(CGFloat)primaryQtyValue withItemCode:(NSNumber *)itemCode withApplicablePrice:(CGFloat)applicablePrice ithApplicablePackageType:(NSString *)packageType;

@end
