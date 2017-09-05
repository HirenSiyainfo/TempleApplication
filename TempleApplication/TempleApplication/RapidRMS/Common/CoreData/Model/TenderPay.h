//
//  TenderPay.h
//  RapidRMS
//
//  Created by Siya Infotech on 01/10/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TenderPay : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSString * cardIntType;
@property (nonatomic, retain) NSNumber * chkDropAmt;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * payCode;
@property (nonatomic, retain) NSNumber * payId;
@property (nonatomic, retain) NSString * payImage;
@property (nonatomic, retain) NSString * paymentName;
@property (nonatomic, retain) NSNumber * surchargeFixAmt;
@property (nonatomic, retain) NSNumber * flgSurcharge;
@property (nonatomic, retain) NSString * surchargeType;
@property (nonatomic, retain) NSString * shortcutKeys;
@property (nonatomic, retain) NSNumber *gasAmountLimit;

@end
