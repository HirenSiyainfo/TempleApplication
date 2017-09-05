//
//  DoCreditRequest.m
//  PaxControllerApp
//
//  Created by Siya Infotech on 15/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DoCreditRequest.h"
#import "PaxRequest+Internal.h"

#pragma mark - class DoCreditRequest
////////////////////////// DoCreditRequest //////////////////////////
@interface DoCreditRequest () {
}

@end
@implementation DoCreditRequest
- (instancetype)initWithTransaction:(EdcTransactionType)transaction amount:(float)amount tipAmount:(float)tipAmount cashBackAmount:(float)cashBackAmount merchantFee:(float)merchantFee taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    self = [super init];
    if (self) {
        _commandType = kPaxCommandDoCredit;
        _transaction = transaction;
        
        // Trace Information
        _invoiceNumber = invoiceNumber;
        _referenceNumber = referenceNumber;
        
        // Amounts
        _amount = amount;
        _tipAmount = tipAmount;
        _cashBackAmount = cashBackAmount;
        _merchantFee = merchantFee;
        _taxAmount = taxAmount;
        
        // Flags
        _isAmountApplicable = NO;
        _isCashBackApplicable = NO;
        _isTaxApplicable = NO;
        _isTipApplicable = NO;
    }
    return self;
}

// Amount
- (instancetype)initCreditAmount:(float)amount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    self = [self initWithTransaction:EdcTransactionTypeSaleRedeem amount:amount tipAmount:0.0 cashBackAmount:0.0 merchantFee:0.0 taxAmount:0.0 invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    if (self) {
        _isAmountApplicable = YES;
    }
    
    return self;
}

// Amount + Tip
- (instancetype)initCreditAmount:(float)amount tipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    self = [self initWithTransaction:EdcTransactionTypeSaleRedeem amount:amount tipAmount:tipAmount cashBackAmount:0.0 merchantFee:0.0 taxAmount:0.0 invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    if (self) {
        _isAmountApplicable = YES;
        _isTipApplicable = YES;
    }
    
    return self;
}

- (instancetype)initCreditAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    self = [self initWithTransaction:EdcTransactionTypeSaleRedeem amount:amount tipAmount:tipAmount cashBackAmount:0.0 merchantFee:0.0 taxAmount:taxAmount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    if (self) {
        _isAmountApplicable = YES;
        _isTipApplicable = YES;
        _isTaxApplicable = YES;
    }
    
    return self;
}

- (instancetype)initCreditAuthAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    self = [self initWithTransaction:EdcTransactionTypeAuth amount:amount tipAmount:tipAmount cashBackAmount:0.0 merchantFee:0.0 taxAmount:taxAmount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    if (self) {
        _transaction = EdcTransactionTypeAuth;
        _isAmountApplicable = YES;
        _isTipApplicable = NO;
        _isTaxApplicable = NO;
    }
    
    return self;
}




- (instancetype)initCreditCaptureAmount:(float)amount withInvoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber TransactionNumber:(NSString*)transactionNumber withAuthCode:(NSString *)authCode
{
    self = [self initWithTransaction:EdcTransactionTypePostauth amount:amount tipAmount:0.00 cashBackAmount:0.0 merchantFee:0.0 taxAmount:0.00 invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    if (self) {
        _transaction = EdcTransactionTypePostauth;
        _authCode = authCode;
        _transactionNumber = transactionNumber;
        _isAmountApplicable = YES;
        _isTipApplicable = NO;
        _isTaxApplicable = NO;
    }
    
    return self;
}
- (instancetype)initCreditPostAuthAmount:(float)amount withInvoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber TransactionNumber:(NSString*)transactionNumber withAuthCode:(NSString *)authCode
{
    self = [self initWithTransaction:EdcTransactionTypePostauth amount:amount tipAmount:0.00 cashBackAmount:0.0 merchantFee:0.0 taxAmount:0.00 invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    if (self) {
        _transaction = EdcTransactionTypePostauth;
        _authCode = authCode;
        _transactionNumber = transactionNumber;
        _isAmountApplicable = YES;
        _isTipApplicable = NO;
        _isTaxApplicable = NO;
    }
    
    return self;
}

- (instancetype)initVoidTransactionNumber:(NSString*)transactionNumber invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    self = [self initWithTransaction:EdcTransactionTypeVoid amount:0.0 tipAmount:0.0 cashBackAmount:0.0 merchantFee:0.0 taxAmount:0.0 invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    if (self) {
        _transaction = EdcTransactionTypeVoid;
        _transactionNumber = transactionNumber;
    }

    return self;
}

- (instancetype)initRefund:(NSString*)transactionNumber referenceNumber:(NSString*)referenceNumber amount:(float)amount {
    self = [self initWithTransaction:EdcTransactionTypeReturn amount:amount tipAmount:0.0 cashBackAmount:0.0 merchantFee:0.0 taxAmount:0.0 invoiceNumber:@"" referenceNumber:referenceNumber];
    
    if (self) {
        _transaction = EdcTransactionTypeReturn;
        _transactionNumber = transactionNumber;
        _isTaxApplicable = NO;
        _isAmountApplicable = YES;
    }
    
    return self;
}
-(instancetype)initWithTipAdjustment:(NSString*)transactionNumber referenceNumber:(NSString*)referenceNumber tipAmount:(float)tipAmount
{
    self = [self initWithTransaction:EdcTransactionTypeAdjust amount:0.0 tipAmount:0.0 cashBackAmount:tipAmount merchantFee:0.0 taxAmount:0.0 invoiceNumber:@"" referenceNumber:referenceNumber];
    if (self) {
        _transaction = EdcTransactionTypeAdjust;
        _transactionNumber = transactionNumber;
        _referenceNumber = referenceNumber;
        _tipAmount = tipAmount;
        _isAmountApplicable = YES;
        _isTipApplicable = YES;
    }
    
    return self;

}


- (NSMutableData *)requestTraceInformation {
    NSMutableData *traceInformation = [NSMutableData data];
    
    //// Reference Number
    // Reference Number : M : ans..16
    //    [self appendToData:traceInformation byte:'1'];
    [self appendToData:traceInformation string:_referenceNumber];
    
    //// Invoice number
    // Invoice number : O : ans..16
    [self appendToData:traceInformation byte:PaxControlCharUS];
    [self appendToData:traceInformation string:_invoiceNumber];
    
    
    //// Auth Code
    // Auth Code : O : ans..10
    if ((_transaction == EdcTransactionTypeVoid) || (_transaction == EdcTransactionTypeReturn) || (_transaction == EdcTransactionTypeAdjust) || (_transaction == EdcTransactionTypeForced) || (_transaction == EdcTransactionTypePostauth)) {
        
        [self appendToData:traceInformation byte:PaxControlCharUS];
        [self appendToData:traceInformation string:_authCode];
    }
    
    
    
    // The host authorization code, the transaction type is “FORCED”,
    // this field is NULL, terminal will prompt dialog to enter it.
    // NOTE: For now we will keep it blank
    if ((_transaction == EdcTransactionTypeVoid) || (_transaction == EdcTransactionTypeReturn) || (_transaction == EdcTransactionTypeAdjust)  || (_transaction == EdcTransactionTypeForced) || (_transaction == EdcTransactionTypePostauth)) {
        [self appendToData:traceInformation byte:PaxControlCharUS];
        // Let us keep it blank in all cases.
        // TransactionNumber  : M : ans..16
        [self appendToData:traceInformation string:_transactionNumber];
    }
    
    
    //// Time Stamp
    // Time Stamp : O : n..14
    // The date time, YYYYMMDDhhmmss, if this field is NULL, terminal will use local time.
    //
    // We will not set Time Stamp.
    // Let device use local time.
    
    
    return traceInformation;
}

/*- (NSMutableData *)requestTraceInformation {
    NSMutableData *traceInformation = [NSMutableData data];
    
    //// Reference Number
    // Reference Number : M : ans..16
//    [self appendToData:traceInformation byte:'1'];
    [self appendToData:traceInformation string:_referenceNumber];

    //// Invoice number
    // Invoice number : O : ans..16
    [self appendToData:traceInformation byte:PaxControlCharUS];
    [self appendToData:traceInformation string:_invoiceNumber];

    
    //// Auth Code
    // Auth Code : O : ans..10
    if ((_transaction == EdcTransactionTypeVoid) || (_transaction == EdcTransactionTypeReturn) || (_transaction == EdcTransactionTypeAdjust)) {
        [self appendToData:traceInformation byte:PaxControlCharUS];
    }
    
    

    // The host authorization code, the transaction type is “FORCED”,
    // this field is NULL, terminal will prompt dialog to enter it.
    // NOTE: For now we will keep it blank
    if ((_transaction == EdcTransactionTypeVoid) || (_transaction == EdcTransactionTypeReturn) || (_transaction == EdcTransactionTypeAdjust)) {
        [self appendToData:traceInformation byte:PaxControlCharUS];
        // Let us keep it blank in all cases.
        // TransactionNumber  : M : ans..16
        [self appendToData:traceInformation string:_transactionNumber];
    }


    //// Time Stamp
    // Time Stamp : O : n..14
    // The date time, YYYYMMDDhhmmss, if this field is NULL, terminal will use local time.
    //
    // We will not set Time Stamp.
    // Let device use local time.
    
    
    return traceInformation;
}*

/*-(void)nextRequestAmountMode
{
    BOOL valueAtIndex = [[requestAmountInformation objectAtIndex:currentRequestMode] boolValue];
    
    RequestAmountInformationOrder requestAmountInformationAtMode = [[requestAmountInformationOrder objectAtIndex:currentRequestMode] integerValue];

    NSInteger numberOfByteToAdd = currentRequestMode - lastSuccessFullAmountMode;
    if (numberOfByteToAdd > 0 && valueAtIndex == TRUE) {
        for (int i = 0; i < numberOfByteToAdd; i++) {
            [self appendToData:amountInformation byte:PaxControlCharUS];
        }
    }
    
    
    switch (requestAmountInformationAtMode) {
        case IsAmountApplicable:
            if (valueAtIndex) {
                [self appendAmount:_amount toData:amountInformation];
            }
            break;
        case IsTipApplicable:
            if (valueAtIndex) {
                [self appendAmount:_tipAmount toData:amountInformation];
            }
            break;
        case IsCashBackApplicable:
            if (valueAtIndex) {
                [self appendAmount:_cashBackAmount toData:amountInformation];
            }
            break;
        case IsMerchantFeeApplicable:
            if (valueAtIndex) {
                [self appendAmount:_merchantFee toData:amountInformation];
            }

            break;
        case IsTaxApplicable:
            if (valueAtIndex) {
                [self appendAmount:_taxAmount toData:amountInformation];
            }
            break;
        default:
            break;
    }
    if (valueAtIndex)
    {
        lastSuccessFullAmountMode = currentRequestMode;
    }
    currentRequestMode ++;
    [self nextRequestAmountMode];
}*/

- (NSMutableData *)requestAmountInformation {
    NSMutableData *amountInformation = [NSMutableData data];
    if (_isAmountApplicable) {
        [self appendAmount:_amount toData:amountInformation];
    }

    // TODO:
    // We need to incorporate order of amount, tip, cashback and tax
    if (_isCashBackApplicable | _isMerchantFeeApplicable | _isTaxApplicable | _isTipApplicable) {
        [self appendToData:amountInformation byte:PaxControlCharUS];
        if (_isTipApplicable) {
            [self appendAmount:_tipAmount toData:amountInformation];
        }
    }

    if (_isCashBackApplicable | _isMerchantFeeApplicable | _isTaxApplicable) {
        [self appendToData:amountInformation byte:PaxControlCharUS];
    }
  
    if (_isCashBackApplicable) {
        [self appendAmount:_cashBackAmount toData:amountInformation];
    }

    if (_isMerchantFeeApplicable | _isTaxApplicable) {
        [self appendToData:amountInformation byte:PaxControlCharUS];
    }
    if (_isMerchantFeeApplicable) {
        [self appendAmount:_merchantFee toData:amountInformation];
    }

    if (_isTaxApplicable) {
        [self appendToData:amountInformation byte:PaxControlCharUS];
      
    }
    if (_isTaxApplicable) {
        [self appendAmount:_taxAmount toData:amountInformation];
    }
    return amountInformation;
}

/**
 commandSpecificBody for DoCreditRequest.
 */
- (NSMutableData *)commandSpecificBody {
    NSMutableData *commandSpecificData = [NSMutableData data];

    //// Transaction Type
    // FS : M : 1
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // Transaction Type : M : n2
    NSString *transactionString = [NSString stringWithFormat:@"%02d", _transaction];
    [self appendToData:commandSpecificData string:transactionString];

    //// Amount Information
    // FS : M : 1
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // Ammount Information : O
    [commandSpecificData appendData:[self requestAmountInformation]];

    //// Account Information
    // FS : M : 1
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // Account Information : O
    //    [commandSpecificData appendData:[self requestAccountInformation]];

    //// Trace Information
    // FS : M : 1
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // Trace Information : M
    [commandSpecificData appendData:[self requestTraceInformation]];

    //// AVS Information
    // FS : M : 1
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // AVS Information : O
    //    [commandSpecificData appendData:[self requestAVSInformation]];

    //// Cashier Information
    // FS : M : 1
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // Cashier Information : O
    //    [commandSpecificData appendData:[self requestCashierInformation]];

    //// Commercial Information
    // FS : M : 1
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // Commercial Information : O
    //    [commandSpecificData appendData:[self requestCommercialInformation]];


    //// MOTO/E-Commerce
    // FS : M : 1
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // MOTO/E-Commerce : O
    //    [commandSpecificData appendData:[self requestECommerce]];

    //// Additional Information
    // FS : M : 1
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // Additional Information : O
    //    [commandSpecificData appendData:[self requestAdditionalInformation]];

    return commandSpecificData;
}
////////////////////////// DoCreditRequest //////////////////////////
@end
