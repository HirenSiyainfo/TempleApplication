//
//  CardDeviceManager.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/28/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrdigePayPaymentGateway.h"
#import "CardFlightReader.h"
@protocol CardDeviceManagerDelegate <NSObject>

- (void)didConnectToDevice :(NSString *)deviceName;
- (void)didDisconnectFromDevice :(NSString *)deviceName;
- (void)didSwipeFromDevice :(NSString *)accountNumber withExpirationDate:(NSString *)date WithNameOnCard :(NSString *)cardName deviceName:(NSString *)deviceName;
- (void)paymentProcessDidFinish :(NSDictionary *)cardPaymentDict;
- (void)paymentProcessDidFailed;
- (void)paymentProcessDidFailedWithDuplicateTranactionWithError :(NSError *)error;
-(void)didFailToRetriveCardInformation;
- (void)paymentProcessDidFailedWithTimeOut;


// ReadDataFrom card
// Transaction success /fail
//
@end

@interface CardDeviceManager : NSObject <PaymentGatewayDelegate,RmsCardReaderDelegate>

-(instancetype)initWithDelegate :(id<CardDeviceManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (void)closeDevice;

//-(void)processCardWithamount :(float)amount withInvoiceNo:(NSString *)invoiceNo withAccountNo:(NSString *)accountNo withTransType:(NSString *)transType withexpdate:(NSString *)expDate withCVNum:(NSString *)cvNum withDeviceName:(NSString *)deviceName withTransactionNo:(NSString *)transactionNo;
-(void)processCreditCardWithDictionary :(NSMutableDictionary *)creditCardDictionary;


-(void)processCardFlightManual :(NSMutableDictionary *)detaidictionary WithAmount:(float)amount withAccountNo:(NSString*)accountNo;


@end
