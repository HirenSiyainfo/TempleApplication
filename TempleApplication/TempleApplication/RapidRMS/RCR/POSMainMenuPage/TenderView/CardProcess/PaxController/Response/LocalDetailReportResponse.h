//
//  LocalDetailReportResponse.h
//  PaxControllerApp
//
//  Created by siya-IOS5 on 1/11/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaxResponse.h"
#import "ResponseHostInformation.h"

@interface LocalDetailReportResponse : PaxResponse

@property (nonatomic,strong) NSString *totalrecord;
@property (nonatomic,strong) NSString *recordNumber;
@property (nonatomic,strong) NSString *edcType;
@property (nonatomic,strong) NSString *transactionType;
@property (nonatomic,strong) NSString *orignalTransactionType;


@property (nonatomic, strong, readonly) NSString *accountNumber;
@property (nonatomic, strong, readonly) NSString *entryMode;
@property (nonatomic, strong, readonly) NSString *expiryDate;
@property (nonatomic, strong, readonly) NSString *ebtType;
@property (nonatomic, strong, readonly) NSString *voucherNumber;
@property (nonatomic, strong, readonly) NSString *neuAccountNo;
@property (nonatomic, strong, readonly) NSString *cardType;
@property (nonatomic, strong, readonly) NSString *cardHolder;
@property (nonatomic, strong, readonly) NSString *cvdApprovalCode;
@property (nonatomic, strong, readonly) NSString *cvdMessage;
@property (nonatomic, strong, readonly) NSString *cardPresentIndicator;


@property (nonatomic, strong, readonly) NSString *approvedAmount;
@property (nonatomic, strong, readonly) NSString *amountDue;
@property (nonatomic, strong, readonly) NSString *tipAmount;
@property (nonatomic, strong, readonly) NSString *cashBackAmount;
@property (nonatomic, strong, readonly) NSString *merchantSurchargeFee;
@property (nonatomic, strong, readonly) NSString *taxAmount;
@property (nonatomic, strong, readonly) NSString *balance1;
@property (nonatomic, strong, readonly) NSString *balance2;

@property (nonatomic, strong, readonly) NSString *transactionNumber;
@property (nonatomic, strong, readonly) NSString *referenceNumber;
@property (nonatomic, strong, readonly) NSString *timeStamp;


@property (nonatomic, strong, readonly) NSString *poNumber;
@property (nonatomic, strong, readonly) NSString *customerCode;
@property (nonatomic, strong, readonly) NSString *taxExempt;
@property (nonatomic, strong, readonly) NSString *taxExemptId;

@property (nonatomic, strong, readonly) NSString *motoECommerceMode;
@property (nonatomic, strong, readonly) NSString *eCommerceTransactionType;
@property (nonatomic, strong, readonly) NSString *eCommerceSecureType;
@property (nonatomic, strong, readonly) NSString *eCommerceOrderNumber;
@property (nonatomic, strong, readonly) NSString *eCommerceInstallments;
@property (nonatomic, strong, readonly) NSString *eCommerceCurrentInstallment;


@property (nonatomic, strong) NSMutableDictionary *additionalInformation;

@property (nonatomic, readonly, strong) ResponseHostInformation *hostInformation;



@end
