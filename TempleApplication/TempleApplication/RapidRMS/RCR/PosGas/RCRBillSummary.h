//
//  RCRBillSummary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 7/28/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCRBillSummary : NSObject
@property (nonatomic,strong) NSNumber *totalBillAmount;
@property (nonatomic,strong) NSNumber *totalSubTotalAmount;
@property (nonatomic,strong) NSNumber *totalCheckCashAmount;
@property (nonatomic,strong) NSNumber *totalExtraChargeAmount;
@property (nonatomic,strong) NSNumber *totalTaxAmount;
@property (nonatomic,strong) NSNumber *totalDiscountAmount;
@property (nonatomic,strong) NSNumber *totalVariationAmount;
@property (nonatomic,strong) NSNumber *totalVariationDiscount;
@property (nonatomic,strong) NSNumber *totalEBTAmount;
@property (nonatomic,strong) NSNumber *totalHouseChargeAmount;

@property (nonatomic, assign) BOOL isEbtApplied;
@property (nonatomic, assign) BOOL isEbtAppliedForDisplay;


-(void)updateBillSummrayWithDetail:(NSMutableArray *)reciptArray;
-(void)taxCalculateForReciptDataArray:(NSMutableArray *)reciptArray withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
