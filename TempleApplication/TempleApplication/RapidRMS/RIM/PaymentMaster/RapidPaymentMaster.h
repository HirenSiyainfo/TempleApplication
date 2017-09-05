//
//  RapidPaymentMaster.h
//  RapidRMS
//
//  Created by siya-IOS5 on 9/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TenderPay.h"

typedef NS_ENUM(NSInteger,AddPaymentField)
{
    PaymentNameField,
    PaymentCodeField,
    PaymentTypeField,
    SurchargeCheckBox,
    SurchargeDollorType,
    SurchargePercentageType,
    SurchargeAmount,
    DropCheckBox
};

@interface RapidPaymentMaster : NSObject

@property (nonatomic) BOOL flgSurcharge;
@property (nonatomic, strong) NSString * surchargeType;
@property (nonatomic, strong) NSNumber * chkDropAmt;
@property (nonatomic, strong) NSString * payCode;
@property (nonatomic, strong) NSString * paymentName;
@property (nonatomic, strong) NSString * cardIntType;
@property (nonatomic, strong) NSNumber * surchargeAmount;
@property (nonatomic, strong) NSNumber * payId;

-(void)setupRapidPaymentMaster:(NSDictionary *)customerDetailDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *rapidPaymentMasterDictionary;


@end
