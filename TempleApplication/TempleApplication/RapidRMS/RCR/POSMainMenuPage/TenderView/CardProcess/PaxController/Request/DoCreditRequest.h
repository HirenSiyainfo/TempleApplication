//
//  DoCreditRequest.h
//  PaxControllerApp
//
//  Created by Siya Infotech on 15/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxRequest.h"


typedef NS_ENUM(NSInteger, RequestAmountInformationOrder) {
    IsAmountApplicable,
    IsTipApplicable,
    IsCashBackApplicable,
    IsMerchantFeeApplicable,
    IsTaxApplicable,
};

@interface DoCreditRequest : PaxRequest {
    // Transaction Type
    EdcTransactionType _transaction;
    
    // Trace Information
    NSString *_referenceNumber;
    NSString *_invoiceNumber;
    NSString *_transactionNumber;
    NSString *_authCode;
    
    // Amounts
    float _amount;
    float _tipAmount;
    float _cashBackAmount;
    float _merchantFee;
    float _taxAmount;
    
    // Flags
    BOOL _isCashBackApplicable;
    BOOL _isMerchantFeeApplicable;
    BOOL _isTaxApplicable;
    BOOL _isTipApplicable;
    BOOL _isAmountApplicable;
    
//    NSArray *requestAmountInformation;
//    NSArray *requestAmountInformationOrder;
//    
//    NSInteger currentRequestMode;
//    NSInteger lastSuccessFullAmountMode;
//    NSMutableData *amountInformation ;
}

// Common Init
- (instancetype)initWithTransaction:(EdcTransactionType)transaction amount:(float)amount tipAmount:(float)tipAmount cashBackAmount:(float)cashBackAmount merchantFee:(float)merchantFee taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber NS_DESIGNATED_INITIALIZER;

/**
    - invoiceNumber: This is a must from POS
    - referenceNumber: This is mandatory field for all CC transactions
 */
// Amount
- (instancetype)initCreditAmount:(float)amount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Amount + Tip
- (instancetype)initCreditAmount:(float)amount tipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Amount + Tip + Tax
- (instancetype)initCreditAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;

- (instancetype)initCreditAuthAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;

- (instancetype)initCreditPostAuthAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber transactionNumber:(NSString*)transactionNumber;

- (instancetype)initCreditCaptureAmount:(float)amount withInvoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber TransactionNumber:(NSString*)transactionNumber withAuthCode:(NSString *)authCode;

- (instancetype)initCreditPostAuthAmount:(float)amount withInvoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber TransactionNumber:(NSString*)transactionNumber withAuthCode:(NSString *)authCode;

// Void
- (instancetype)initVoidTransactionNumber:(NSString*)transactionNumber invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;

// Refund
- (instancetype)initRefund:(NSString*)transactionNumber referenceNumber:(NSString*)referenceNumber amount:(float)amount;
-(instancetype)initWithTipAdjustment:(NSString*)transactionNumber referenceNumber:(NSString*)referenceNumber tipAmount:(float)tipAmount;

// TODO: There is no such command with PAX device
// Adjust Tip
//- (instancetype)initAdjust:(NSString*)transactionNumber amount:(float)amount;
@end
