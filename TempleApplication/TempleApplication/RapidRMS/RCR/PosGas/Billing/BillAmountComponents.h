//
//  BillAmountComponents.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BillAmountComponents : NSObject

@property (nonatomic) double subTotal;
@property (nonatomic) double totalDiscount;
@property (nonatomic) double totalTax;
@property (nonatomic) double billAmount;

@end
