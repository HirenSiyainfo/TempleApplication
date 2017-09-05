//
//  TenderViewController.h
//  POSRetail
//
//  Created by Keyur Patel on 29/04/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerDisplayViewController.h"
#import "CardProcessingVC.h"
#import "SignatureViewController.h"
#import "GiftCardPosVC.h"
#import "RapidCustomerLoyalty.h"
#import "RCRBillSummary.h"
#import "BillAmountCalculator.h"



@protocol TenderDelegate<NSObject>
-(void)didFinishTransactionSuccessFully;
-(void)didFailTransaction;
-(void)didCancelTransaction;
@end

@interface TenderViewController : UIViewController <UIPrintInteractionControllerDelegate, UIWebViewDelegate, UpdateDelegate, CardProcessingDelegate,SignatureViewControllerDelegate,UIPopoverControllerDelegate,GiftCardPosDelegate>
{
}

@property (nonatomic, weak) id<TenderDelegate> tenderDelegate;

@property (nonatomic, strong) RapidCustomerLoyalty *tenderRapidCustomerLoyalty;
@property (nonatomic, strong) RCRBillSummary *rcrBillSummary;
@property (nonatomic, strong) BillAmountCalculator *billAmountCalculator;

@property (nonatomic, strong) NSMutableArray *receiptDataArray;
@property (nonatomic, strong) NSMutableArray *paymentForVoid;
@property (nonatomic, strong) NSMutableArray *tenderReciptDataAry;

@property (nonatomic, strong) NSMutableDictionary * dictAmoutInfo;
@property (nonatomic, strong) NSMutableDictionary *dictCustomerInfo;
@property (nonatomic ,strong)  NSMutableDictionary *selectedFuelType;

@property (nonatomic, strong) NSString *billItemDetailString;
@property (nonatomic, strong) NSString *tenderType;
@property (nonatomic, strong) NSNumber *payId;

@property (nonatomic, strong) NSString * moduleIdentifier;

@property (nonatomic)  NSInteger tenderItemCount;

@property (nonatomic, assign) CGFloat checkcashAmount;

@property (assign) CGFloat ebtAmount;
@property (assign) CGFloat houseChargeValue;
@property (nonatomic, assign) CGFloat houseChargeAmount;
@property (nonatomic, strong) NSString *strInvoiceNo;


@property (nonatomic, assign) BOOL isCheckCashApplicableAplliedToBill;
@property (nonatomic, assign) BOOL isVoidForInvoice;
@property (nonatomic, assign) BOOL isHouseChargePay;
@property (nonatomic, assign) BOOL isGasItem;


-(NSMutableArray *)reciptDataAryForBillOrder;
@property (nonatomic, strong) NSManagedObjectID * restaurantOrderTenderObjectId;

-(void)GetPaymentData;
- (void)SetPortInfo;

-(IBAction)rcdNormalScreen:(id)sender;
-(IBAction)btnNoteClick:(id)sender;
-(IBAction)btnCloseclick:(id)sender;
-(IBAction)btntenderClick:(id)sender;

- (void)stopWatchDogTimer;
- (void)restartWatchDogTimer;
-(void)setStatusmessage :(NSString *)message withWarning:(BOOL)isWarning;
- (void)updateBillDataWithCurrentStep;

-(BOOL)checkHouseChargeDetail;
-(BOOL)checkGiftCardDetail;
-(BOOL)checkOpenCashDrawer;
-(BOOL)checkPaymentDetail;
-(BOOL)checkCardProcess;
-(BOOL)checkCustomerTipAdjustment;
-(void)checkProcessChangeDue;
-(BOOL)checkProcessForCradReceiptPrint;
-(void)checkWebserviceCall;
-(BOOL)checkProcessReceipt;
-(BOOL)checkPassPrint;
-(void)checkGasPumpPrepayProcess;
-(void)checkDoneProcess;
-(void)checkFinishProcess;
-(BOOL)preProcessForBegin;
-(void)preprocessHouseChargeDetail;
-(void)preprocessCheckPaymentDetail;
-(BOOL)preprocessProcessCard;
-(void)preprocessSignatureCapture;
-(BOOL)checkGiftCardPrint;
-(BOOL)checkHouseChargePrint:(BOOL)isSignature;


@end
