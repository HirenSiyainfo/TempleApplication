//
//  PaxDevice.h
//  PaxTestApp
//
//  Created by Siya Infotech on 05/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaxConstants.h"

@class PaxResponse;
@class PaxDevice;

#pragma mark - PaxDeviceDelegate
@protocol PaxDeviceDelegate <NSObject>
- (void)paxDevice:(PaxDevice*)paxDevice willSendRequest:(NSString*)request;
- (void)paxDevice:(PaxDevice*)paxDevice response:(PaxResponse*)response;
- (void)paxDevice:(PaxDevice*)paxDevice failed:(NSError*)error response:(PaxResponse *)response;


- (void)paxDevice:(PaxDevice*)paxDevice isConncted:(BOOL)isConncted;
- (void)paxDeviceDidTimeout:(PaxDevice*)paxDevice;
@end

#pragma mark - PaxDevice
@interface PaxDevice : NSObject

// Delegate
@property (nonatomic, weak) id<PaxDeviceDelegate> paxDeviceDelegate;

// Busy
@property (nonatomic, readonly, getter=isBusy) BOOL busy;
@property (assign)PDResponse pdResonse;

@property (nonatomic, strong) NSMutableData *requestData;
@property (nonatomic, strong) NSMutableData *responseData;

- (instancetype)initWithIp:(NSString*)_serverIp port:(NSString*)_port NS_DESIGNATED_INITIALIZER;
- (void)checkConnectivity;


// This is private method
//- (void)sendRequestWithId:(PDRequest)pdRequest;



#pragma mark - Commands
// Implemented
/**
 Move methods which implemented here from COMMANDS_NOT_IMPEMENTED.
 */
//// Administration Commands ////
- (void)initializeDevice;
- (void)getVariable:(NSString*)variableName;
- (void)setVariable:(NSString*)variableName withVarialbleValue:(NSString*)variableValue;


/// Signture
// Do Signature
- (void)doSignatureWithEdcType:(EdcType)edcType;
// Get Signature
- (void)getSignature;

//// Transaction Commands ////

/// Credit
// Amount
- (void)doCreditWithAmount:(float)amount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Amount + Tip
- (void)doCreditWithAmount:(float)amount tipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Amount + Tip + Tax
- (void)doCreditWithAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Adjust
- (void)adjustCreditTipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber transactionNumber:(NSString*)transactionNumber;// Refund
- (void)refundCreditAmount:(float)refundAmount transactionNumber:(NSString*)transactionNumber referenceNumber:(NSString*)referenceNumber;
// Void
- (void)voidCreditTransactionNumber:(NSString*)transactionNumber invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;

/// Debit
// Amount
- (void)doDebitWithAmount:(float)amount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Amount + Tip
- (void)doDebitWithAmount:(float)amount tipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Amount + Tip + Tax
- (void)doDebitWithAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Adjust
- (void)adjustDebitTipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber  transactionNumber:(NSString*)transactionNumber;
// Refund
- (void)refundDebitAmount:(float)refundAmount transactionNumber:(NSString*)transactionNumber referenceNumber:(NSString*)referenceNumber;
// Void
- (void)voidDebitTransactionNumber:(NSString*)transactionNumber invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;

/// Ebt
// Amount
- (void)doEbtWithAmount:(float)amount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Amount + Tip
- (void)doEbtWithAmount:(float)amount tipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Amount + Tip + Tax
- (void)doEbtWithAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Adjust
- (void)adjustEbtTipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;
// Refund
- (void)refundEbtAmount:(float)refundAmount transactionNumber:(NSString*)transactionNumber referenceNumber:(NSString*)referenceNumber;
// Void
- (void)voidEbtTransactionNumber:(NSString*)transactionNumber invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;

//Auth
- (void)doCreditAuthWithAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber;

//Post Auth
- (void)doCreditPostAuthWithAmount:(float)amount withInvoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber transactionNumber:(NSString*)transactionNumber withAuthCode:(NSString *)authCode ;

//Capture
- (void)doCreditCaptureWithAmount:(float)amount withInvoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber transactionNumber:(NSString*)transactionNumber withAuthCode:(NSString *)authCode;

//// Batch Commands ////
- (void)closeBatch;
- (void)forceCloseBatch;
- (void)clearBatch:(EdcType)edcType;
- (void)hostReport;
- (void)historyReport;
- (void)localTotalReport;
- (void)getLocalDetailReportForRecordNumber:(NSInteger)recordNumber ;
- (void)getLocalDetailReportForReferenceNumber:(NSString *) referenceNumber;

//// Report Commands ////


#pragma mark - Not implemented
// Not Implemented
// Never define NOT_IMPEMENTED
#ifdef COMMANDS_NOT_IMPEMENTED
//// Administration Commands ////
// ** We can add methods for specific variables
- (id)getVariable:(NSString*)variableName;
// There can be enum to return status
- (ErrorCode)setVariable:(NSString*)variableName value:(id)value;
- (void)showDialogTitle:(NSString*)title message:(NSString*)message buttons:(NSArray*)buttonTitles;
- (UIImage*)getSignature;
- (void)showMessage:(NSString*)message;
- (void)clearMessage;
// Cancel Transaction
- (void)cancel;
- (void)resetDevice;
- (ErrorCode)updateImage:(UIImage*)image;
- (void)doSignature;
- (void)deleteImage;
- (void)showCenterAligned:(BOOL)centerAligned message:(NSString*)message;
- (void)reboot;
- (NSString*)getPinBlock;
- (void)inputAccount;
// MSR - Magnetic Stripe Reader
- (void)resetMSR;
- (void)reportStatus;
- (void)inputText;
- (void)checkFile;


//// Transaction Commands ////
- (void)doDebitWithAmount:(float)amount;
- (void)doEbtWithAmount:(float)amount;
- (void)doGiftWithAmount:(float)amount;
- (void)doLoyaltyWithAmount:(float)amount;
- (void)doCashWithAmount:(float)amount; // ???
- (void)doCheckWithAmount:(float)amount; // ???


//// Batch Commands ////
- (void)batchClose;
- (void)forceBatchClose;
- (void)batchClear;

//// Report Commands ////
- (void)localTotalReport;
- (void)localDetailReport;
- (void)localFailedReport;
- (void)historyReport;

#endif



@end
