//
//  CreditCardReaderManager.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/4/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaymentModeItem.h"
#import "CardProcessingVC.h"
#import "PaxResponse.h"

typedef NS_ENUM(NSInteger, DeviceSignatureCaputure)
{
    PaxSignatureCapture_Request ,
    VariFoneSignartureCapture_Request,
} ;
@protocol CreditCardReaderManagerDelegate

// Pax Device Delegate Methods.....
-(void)didConnectedCreditCardReader:(NSString *)deviceName;
-(void)didDisconnectedCreditCardReader;
-(void)didFinishCreditCardReaderTransctionSuccessfullyWithDetail:(NSDictionary *)creditcardDetail withCreditCardAdditionalDetail:(NSMutableDictionary *)additionalDetailDict;
-(void)didFailTransction:(NSError *)error response:(PaxResponse *)response;


/// Signature Capture Delegate Methods......
-(void)didFinishSignatureImage:(UIImage *)signatureImage;
-(void)didFailSignatureProcess;
- (void)displayAlertInCreditCardProcessingWithTitle:(NSString*)title withMessage:(NSString *)message withButtonTitles:(NSArray *)buttonTitles withButtonHandlers:(NSArray *)buttonHandlers;
- (void)continueNextCardWithoutSignature;

@end

@interface CreditCardReaderManager : NSObject
-(instancetype)initWithDelegate:(id<CreditCardReaderManagerDelegate>)delegate withPaxConnectionStatus:(BOOL)paxConnected NS_DESIGNATED_INITIALIZER;

-(void)doCreditCardReaderRequestWithPaymentModeItem:(PaymentModeItem *)paymentModeItem WithRegisterInvNo:(NSString *)registerInvNo withTransactionId:(NSString *)trasnactionId isGasItem:(BOOL)isGas;

-(void)creditCardSignatureRequestWithId:(DeviceSignatureCaputure)deviceSignatureCaputure;

@end
