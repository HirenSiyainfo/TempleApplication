//
//  BillWiseDiscountCalculator.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/5/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BillAmountCalculator.h"

@interface BillWiseDiscountCalculator : NSObject
- (instancetype)initWithReceiptArray:(NSMutableArray *)receiptArray WithBillAmountCalculator:(BillAmountCalculator *)billAmountCalc;
-(void)calculateBillWiseDiscount;

@end
