//
//  CardTransactionRequestVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 5/10/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentData.h"

@protocol CardTransactionRequestVCDelegate<NSObject>

-(void)didCancelCardTransactionRequestProcess;
-(void)didContinueCardTransactionRequestProcessWithPaymentArray:(NSMutableArray *) paymentArray;
-(void)didUpdateCardTransactionWithPaymentData:(PaymentData *)paymentData;
-(void)didComplateCardTransactionWithPaymentData:(PaymentData *)paymentData;


@end


@interface CardTransactionRequestVC : UIViewController

@property (nonatomic, strong) NSMutableArray *arrayCardDetail;
@property (nonatomic, weak) id<CardTransactionRequestVCDelegate> cardTransactionRequestVCDelegate;
@property (nonatomic, strong) PaymentData *paymentData;



@end
