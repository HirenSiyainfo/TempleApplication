//
//  CreditCardViewController.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/26/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrdigePayPaymentGateway.h"
#import "PaymentData.h"
#import "TenderProcessManager.h"
typedef NS_ENUM(NSInteger, CreditCardProcessingStep) {
    CreditCardProcessingStepBegan,
    CreditCardProcessingStepFinished,
    CreditCardProcessingStepCanceled,
    CreditCardProcessingStepFailed,
    CreditCardProcessingStepSignature,
};

@class WTReTextField;
@protocol CardProcessingDelegate
-(void)cardProcessingDidFinish:(BOOL)isPartiallyApprovedTransaction ;
-(void)cardProcessingDidCancel:(BOOL)isPartiallyApprovedTransaction;
-(void)cardProcessingDidFail;
@end
@interface CardProcessingVC : UIViewController <UIScrollViewDelegate>
{
    
}

@property (nonatomic,strong) NSDictionary *billInfo;
@property (nonatomic,strong) NSMutableArray *tipInfo;
@property (nonatomic,strong) NSMutableArray *cardProcessingArray;

@property (nonatomic, strong) NSString *invoiceNo;
@property (nonatomic, strong) NSString *regstrationPrefix;
@property (nonatomic, strong) NSString *paxSerialNo;

@property (nonatomic, weak) id <CardProcessingDelegate> cardProcessingDelegate;

@property (nonatomic, strong) PaymentData *paymentCardData;
@property (nonatomic, strong) TenderProcessManager *tenderProcessCreditManager;


@property (nonatomic ,assign) BOOL isPaxConnectedToRapid;
@property (nonatomic ,assign) BOOL isGasItem;

@end
