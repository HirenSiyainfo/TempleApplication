//
//  BatchCloseResponse.h
//  PaxControllerApp
//
//  Created by siya info on 30/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxResponse.h"

#define USE_HOSTINFORMATION_CLASS

#ifdef USE_HOSTINFORMATION_CLASS
#import "ResponseHostInformation.h"
#endif

@interface BatchCloseResponse : PaxResponse

@property (nonatomic, readonly) NSInteger totalCount;
@property (nonatomic, readonly) float totalAmount;
@property (nonatomic, readonly, strong) NSString *timeStamp;

@property (nonatomic, readonly) NSInteger totalCreditCount;
@property (nonatomic, readonly) NSInteger totalDebitCount;
@property (nonatomic, readonly) NSInteger totalEBTCount;
@property (nonatomic, readonly) NSInteger totalGiftCount;
@property (nonatomic, readonly) NSInteger totalLoyaltyCount;
@property (nonatomic, readonly) NSInteger totalCheckCount;
@property (nonatomic, readonly) NSInteger totalCashCount;


@property (nonatomic, readonly) float totalCreditAmount;
@property (nonatomic, readonly) float totalDebitAmount;
@property (nonatomic, readonly) float totalEBTAmount;
@property (nonatomic, readonly) float totalGiftAmount;
@property (nonatomic, readonly) float totalLoyaltyAmount;
@property (nonatomic, readonly) float totalCheckAmount;
@property (nonatomic, readonly) float totalCashAmount;

@property (nonatomic,strong)  NSMutableDictionary *totalCountDetail ;
@property (nonatomic,strong) NSMutableDictionary *totalAmountDetail;

#ifdef USE_HOSTINFORMATION_CLASS
@property (nonatomic, readonly, strong) ResponseHostInformation *hostInformation;
#else
@property (nonatomic, strong, readonly) NSString *transactionResponseCode;
@property (nonatomic, strong, readonly) NSString *transactionResponseMessage;
@property (nonatomic, strong, readonly) NSString *authCode;
@property (nonatomic, strong, readonly) NSString *hostReferenceNumber;
@property (nonatomic, strong, readonly) NSString *traceNumber;
@property (nonatomic, strong, readonly) NSString *batchNumber;
#endif
@end
