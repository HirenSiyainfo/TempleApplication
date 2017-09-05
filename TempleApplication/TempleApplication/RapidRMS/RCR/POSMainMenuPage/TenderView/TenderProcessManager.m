//
//  TenderProcessManager.m
//  RapidRMS
//
//  Created by Siya-ios5 on 9/13/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "TenderProcessManager.h"
#import "TenderViewController.h"
@interface TenderProcessManager ()
{
    
}
@property (nonatomic , strong) TenderViewController *tenderViewController;

@end


@implementation TenderProcessManager

-(instancetype)initWithTenderDelegate:(TenderViewController *)tenderVC
{
    self = [super init];
    if (self) {
        self.tenderViewController = tenderVC;
    }
    return self;
}
-(BOOL)preProcess
{
    
    BOOL status = YES;
    
    switch (self.currentStep)
    {
        case TP_BEGIN:
            
         status = [self.tenderViewController preProcessForBegin];
            
            break;
        case TP_CHECK_HOUSE_CHARGE_DETAILS:
            [self.tenderViewController preprocessHouseChargeDetail];
            break;
            
            
        case TP_CHECK_GIFT_CARD_DETAIL:
            
            [self.tenderViewController preprocessCheckPaymentDetail];
            break;
            
            
            
            
        case TP_OPENCASH_DRAWER:
        {
            [self.tenderViewController setStatusmessage:@"" withWarning:FALSE];
        }
            break;
        case TP_CHECK_CARD_PAYMENT_DETAIL:
            
            
            break;
        case TP_PROCESS_CARDS:
        {
//            status = [self.tenderViewController preprocessProcessCard];
        }
            break;
            
        case TP_CAPTURE_SIGNATURE:
            [self.tenderViewController preprocessSignatureCapture];
            break;
            
        case  TP_PROCESS_CARDS_DONE:
            break;

        case TP_COUSTMER_TIP_ADJUSTMENT:
            
            break;
            
        case TP_PROCESS_CHANGEDUE:
            break;
            
        case TP_PROCESS_CARDSRECIPTPRINT:
            break;
            
        case TP_PROCESS_COUSTMERRECIPETPRINT:
            break;
        case TP_PRINT_PASS:
            break;
            
        case  TP_PRINT_GIFTCARD:
            break;
            
        case TP_PRINT_HOUSECHARGE:
            break;
            
        case TP_PRINT_HOUSECHARGE_SIGNATURE:
            break;

        case TP_CALL_SERVICE:
            break;
            
        case TP_PRINT_RECEIPT_PROMT:
            break;
        case TP_PROCESS_RECEIPT:
            break;
            
        case TP_GASPUMP_PREPAY_PROCESS:
            break;
            
        case TP_DONE:
            break;
        case TP_FINISH:
            break;
        case TP_TRANSACTION_DECLINED:
            break;
            
        case TP_IDLE:
            break;
    }
    return status;
}

- (void)performNextStep {
    // Restart Watch dog timer
    [self.tenderViewController restartWatchDogTimer];
    
    if ([self preProcess] == FALSE) {
        return;
    }
    
    
    BOOL isApplicable = FALSE;
    
    /*  if (crashStep == self.currentStep) {
     assert(0);
     }*/
    self.currentStep++;
    
    [self.tenderViewController updateBillDataWithCurrentStep];
    
    
    NSString *currentStep = [NSString stringWithFormat:@"Last Tender State = %@ - %@",[self currentStepName:self.currentStep],self.tenderViewController.strInvoiceNo];
    [[NSUserDefaults standardUserDefaults] setObject:currentStep forKey:@"TenderStateBeforeTermination"];
    
    switch (self.currentStep)
    {
            
        case TP_CHECK_HOUSE_CHARGE_DETAILS:
            isApplicable = [self.tenderViewController checkHouseChargeDetail];
            break;
            
        case TP_CHECK_GIFT_CARD_DETAIL:
            isApplicable = [self.tenderViewController checkGiftCardDetail];
            break;
            
            
        case TP_OPENCASH_DRAWER:
            isApplicable = [self.tenderViewController checkOpenCashDrawer];
            
            break;
        case TP_CHECK_CARD_PAYMENT_DETAIL:
            isApplicable = [self.tenderViewController checkPaymentDetail];
            
            break;
        
        case TP_PROCESS_CARDS:
            isApplicable = [self.tenderViewController checkCardProcess];
          
            break;
        
        case TP_CAPTURE_SIGNATURE:
            isApplicable = FALSE;
            
            break;
            
        case  TP_PROCESS_CARDS_DONE:
            isApplicable = FALSE;
            break;

            
        case TP_COUSTMER_TIP_ADJUSTMENT:
            
            isApplicable = [self.tenderViewController checkCustomerTipAdjustment];
            
            break;
            
        case TP_PROCESS_CHANGEDUE:
            [self.tenderViewController checkProcessChangeDue];
            isApplicable = TRUE;
            break;

        case TP_PROCESS_CARDSRECIPTPRINT:
            isApplicable = [self.tenderViewController checkProcessForCradReceiptPrint];
            
            break;
        case TP_PROCESS_COUSTMERRECIPETPRINT:
            
            isApplicable = NO;
            break;
        case TP_CALL_SERVICE:
            isApplicable = TRUE;
            [self.tenderViewController checkWebserviceCall];
            break;
        case TP_PRINT_RECEIPT_PROMT:
            isApplicable = NO;
            break;
        case TP_PROCESS_RECEIPT:
            
            isApplicable = [self.tenderViewController checkProcessReceipt] ;
                            
            break;
            
        case TP_PRINT_PASS:
            isApplicable = [self.tenderViewController checkPassPrint];
            
            break;
            
        case  TP_PRINT_GIFTCARD:
            
            isApplicable = [self.tenderViewController checkGiftCardPrint];
            break;
            
        case TP_PRINT_HOUSECHARGE:
            isApplicable = [self.tenderViewController checkHouseChargePrint:FALSE];
            break;
            
        case TP_PRINT_HOUSECHARGE_SIGNATURE:
            isApplicable = [self.tenderViewController checkHouseChargePrint:TRUE];

            break;
            
        case TP_GASPUMP_PREPAY_PROCESS:
            
            [self.tenderViewController checkGasPumpPrepayProcess];
            break;
        case TP_DONE:
            [self.tenderViewController checkDoneProcess];
        case TP_FINISH:
            isApplicable = TRUE;
            [self.tenderViewController checkFinishProcess];
            self.currentStep++;
            break;
        case TP_TRANSACTION_DECLINED:
            isApplicable = TRUE;
            [self.tenderViewController stopWatchDogTimer];
            break;
            
        case TP_IDLE:
            break;
            
        case TP_BEGIN:
            break;
            
            
            
    }
    if (!isApplicable) {
        [self performNextStep];
    }
}
- (NSString*)currentStepName :(TENDER_PROCESS_STEPS )step{
    NSString *currentStep;
    
    switch (step) {
        case TP_BEGIN:
            currentStep = @"TP_BEGIN";
            break;
            
        case TP_CHECK_HOUSE_CHARGE_DETAILS:
            currentStep = @"TP_CHECK_HOUSE_CHARGE_DETAILS";
            break;
            
        case TP_CHECK_GIFT_CARD_DETAIL:
            currentStep = @"TP_CHECK_GIFT_CARD_DETAIL";
            break;
            
        case TP_CHECK_CARD_PAYMENT_DETAIL:
            currentStep = @"TP_CHECK_CARD_PAYMENT_DETAIL";
            break;
            
        case TP_PROCESS_CARDS:
            currentStep = @"TP_PROCESS_CARDS";
            break;
            
        case TP_CAPTURE_SIGNATURE:
            currentStep = @"TP_CAPTURE_SIGNATURE";
            break;
            
        case TP_OPENCASH_DRAWER:
            currentStep = @"TP_OPENCASH_DRAWER";
            break;
            
        case TP_PROCESS_CHANGEDUE:
            currentStep = @"TP_PROCESS_CHANGEDUE";
            break;
            
        case TP_PROCESS_CARDSRECIPTPRINT:
            currentStep = @"TP_PROCESS_CARDSRECIPTPRINT";
            break;
            
        case TP_CALL_SERVICE:
            currentStep = @"TP_CALL_SERVICE";
            break;
            
        case TP_PROCESS_COUSTMERRECIPETPRINT:
            currentStep = @"TP_PROCESS_COUSTMERRECIPETPRINT";
            break;
            
        case TP_PRINT_RECEIPT_PROMT:
            currentStep = @"TP_PRINT_RECEIPT_PROMT";
            break;
            
        case TP_PROCESS_RECEIPT:
            currentStep = @"TP_PROCESS_RECEIPT";
            break;
        case TP_PRINT_PASS:
            currentStep = @"TP_PRINT_PASS";
            break;
        case TP_PRINT_GIFTCARD:
            currentStep = @"TP_PRINT_GIFTCARD";
            break;

        case TP_PRINT_HOUSECHARGE:
            currentStep = @"TP_PRINT_HOUSECHARGE";
            break;
            
        case TP_PRINT_HOUSECHARGE_SIGNATURE:
            currentStep = @"TP_PRINT_HOUSECHARGE_SIGNATURE";
            break;
            
        case TP_GASPUMP_PREPAY_PROCESS:
            currentStep = @"TP_GASPUMP_PREPAY_PROCESS";
            break;
            
        case TP_DONE:
            currentStep = @"TP_DONE";
            break;
            
        case TP_FINISH:
            currentStep = @"TP_FINISH";
            break;
            
        case TP_TRANSACTION_DECLINED:
            currentStep = @"TP_TRANSACTION_DECLINED";
            break;
            
        default:
            currentStep = [NSString stringWithFormat:@"Current step = %d", self.currentStep];
            break;
    }
    
    return currentStep;
}

-(void)updatePaymentDataWithCurrentStep
{
    [self.tenderViewController updateBillDataWithCurrentStep];
}

-(void)insertInvoiceToLocalDatabase
{
    [self.tenderViewController preprocessProcessCard];
    self.currentStep++;
    [self.tenderViewController updateBillDataWithCurrentStep];
}



@end
