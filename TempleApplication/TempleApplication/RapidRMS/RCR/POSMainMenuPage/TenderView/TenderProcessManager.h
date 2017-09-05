//
//  TenderProcessManager.h
//  RapidRMS
//
//  Created by Siya-ios5 on 9/13/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum __TENDER_PROCESS_STEPS__ {
    TP_IDLE,
    TP_BEGIN,
    TP_CHECK_HOUSE_CHARGE_DETAILS,
    TP_CHECK_GIFT_CARD_DETAIL,
    TP_CHECK_CARD_PAYMENT_DETAIL,
    TP_PROCESS_CARDS,
    TP_PROCESS_CARDS_DONE,
    TP_CAPTURE_SIGNATURE,
    TP_COUSTMER_TIP_ADJUSTMENT,
    
    TP_PROCESS_CHANGEDUE,
    TP_OPENCASH_DRAWER,
    
    
    TP_PROCESS_CARDSRECIPTPRINT,
    
    TP_PRINT_PASS,
    
    TP_PRINT_GIFTCARD,
    TP_PRINT_HOUSECHARGE,
    TP_PRINT_HOUSECHARGE_SIGNATURE,

    TP_CALL_SERVICE,
    TP_PROCESS_COUSTMERRECIPETPRINT,
    
    
    TP_PRINT_RECEIPT_PROMT,
    TP_PROCESS_RECEIPT,
    
    
    TP_GASPUMP_PREPAY_PROCESS,
    
    TP_DONE,
    TP_FINISH,
    TP_TRANSACTION_DECLINED
} TENDER_PROCESS_STEPS;


typedef enum __SPEC_OPTIONS_ {
    SPEC_PRINT_RECIPT,
    SPEC_PRINT_PROMT,
    SPEC_OPEN_DRAWER,
    SPEC_CARD_PROCESS,
    SPEC_MULTIPLE_CARD_PROCESS,
    SPEC_POS_SIGN_RECEIPT = 6,
    SPEC_CUSTOMER_DISPLAY_SIGN_RECEIPT = 7,
    SPEC_TENDER_DISABLE = 11,
    SPEC_BRIDGEPAY_SERVER = 12,
    SPEC_RAPID_SERVER = 13,
    SPEC_BROD_POS_SERVER = 18,
    
} __SPEC_OPTIONS_;
@class TenderViewController;
@interface TenderProcessManager : NSObject

-(instancetype)initWithTenderDelegate:(TenderViewController *)tenderVC;


@property (atomic) TENDER_PROCESS_STEPS currentStep ;
- (void)performNextStep;
-(void)insertInvoiceToLocalDatabase;
-(void)updatePaymentDataWithCurrentStep;

@end
