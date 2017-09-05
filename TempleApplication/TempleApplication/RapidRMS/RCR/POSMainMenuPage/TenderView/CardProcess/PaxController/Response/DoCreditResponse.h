//
//  DoCreditResponse.h
//  PaxControllerApp
//
//  Created by siya info on 17/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxResponse.h"
#import "ResponseHostInformation.h"

#pragma mark - DoCreditResponse
@interface DoCreditResponse : PaxResponse {
}
//@property (nonatomic, readonly) NSString *serialNumber;



@property (nonatomic, strong, readonly) NSString *transactionType;
@property (nonatomic, strong, readonly) NSString *approvedAmount;
@property (nonatomic, strong, readonly) NSString *amountDue;
@property (nonatomic, strong, readonly) NSString *tipAmount;
@property (nonatomic, strong, readonly) NSString *cashBackAmount;
@property (nonatomic, strong, readonly) NSString *merchantSurchargeFee;
@property (nonatomic, strong, readonly) NSString *taxAmount;
@property (nonatomic, strong, readonly) NSString *balance1;
@property (nonatomic, strong, readonly) NSString *balance2;

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


@property (nonatomic, strong, readonly) NSString *transactionNumber;
@property (nonatomic, strong, readonly) NSString *referenceNumber;
@property (nonatomic, strong, readonly) NSString *timeStamp;

@property (nonatomic, strong, readonly) NSString *avsApprovalCode;
@property (nonatomic, strong, readonly) NSString *avsMessage;

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

#ifdef USE_HOSTINFORMATION
@property (nonatomic, strong, readonly) NSString *transactionResponseCode;
@property (nonatomic, strong, readonly) NSString *transactionResponseMessage;
@property (nonatomic, strong, readonly) NSString *authCode;
@property (nonatomic, strong, readonly) NSString *hostReferenceNumber;
@property (nonatomic, strong, readonly) NSString *traceNumber;
@property (nonatomic, strong, readonly) NSString *batchNumber;
#else
@property (nonatomic, readonly, strong) ResponseHostInformation *hostInformation;
#endif

@property (nonatomic, strong) NSMutableDictionary *additionalInformation;


+ (DoCreditResponse*)responseFromData:(NSData*)data;

- (instancetype)initWithData:(NSData*)data NS_DESIGNATED_INITIALIZER;
@end
