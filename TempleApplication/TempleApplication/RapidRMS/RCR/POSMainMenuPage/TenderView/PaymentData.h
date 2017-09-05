//
//  PaymentData.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/18/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  "PaymentModeItem.h"
#import "RapidCustomerLoyalty.h"
#import "RCRBillSummary.h"
#import "BillAmountCalculator.h"

@interface PaymentData : NSObject

@property (nonatomic, strong) RapidCustomerLoyalty *rapidCustomerLoyalty;
@property (nonatomic, strong) RCRBillSummary *rcrBillSummary;
@property (nonatomic, strong) BillAmountCalculator *billAmountCalculator;

@property (assign ,readonly) CGFloat amountToPay;
@property (assign ,readonly) CGFloat balanceAmount;
@property (assign ,readonly) CGFloat collectionAmount;
@property (assign ,readonly) CGFloat billAmount;
@property (assign ,readonly) CGFloat tipAmount;
@property (assign , readonly) CGFloat ebtAmount;
@property (assign , readonly) CGFloat houseChargeValue;
@property (assign , readonly) CGFloat houseChargeAmount;
@property (assign , readonly) CGFloat checkcashAmount;

@property (assign ,readonly) NSInteger completedCreditCardSwipe;
@property (assign ,readonly) NSInteger tenderItemCount;

@property (nonatomic , strong ,readonly) NSNumber *isTipAdjustmentApplicable;
@property (nonatomic , strong ,readonly) NSNumber *payId;

@property (nonatomic,strong ,readonly) NSIndexPath *lastSelectedPaymentTypeIndexPath;

@property (nonatomic, strong , readonly) NSMutableArray *paymentGatewayResponse;
@property (nonatomic, strong , readonly) NSMutableArray *paymentModes;
@property (nonatomic, strong) NSMutableArray *receiptDataArray;
@property (nonatomic, strong) NSMutableArray *paymentForVoid;

@property (nonatomic , strong) NSMutableDictionary * dictAmoutInfo;
@property (nonatomic , strong) NSMutableDictionary *dictCustomerInfo;

@property (nonatomic, assign) BOOL isCheckCashApplicableAplliedToBill;
@property (nonatomic, assign) BOOL isVoidForInvoice;
@property (nonatomic, assign) BOOL isHouseChargePay;

@property (nonatomic, strong , readonly) NSString * moduleIdentifier;
@property (nonatomic, strong , readonly) NSString *strInvoiceNo;
@property (nonatomic, strong , readonly) NSString *billItemDetailString;
@property (nonatomic, strong , readonly) NSString *tenderType;
@property (nonatomic, strong ) NSString *paxSerialNumber;
@property (nonatomic, strong) NSString *numberOfGuest;
@property (nonatomic, strong) NSString *tableNo;


-(void)configureWith :(NSArray *)paymentModes;
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger countOfPaymentModes;
-(NSString *)paymentTypeAtIndex :(NSInteger)index;
-(CGFloat)calculatedAmountAtIndex :(NSInteger)index;
-(CGFloat)actualAmountAtIndex :(NSInteger)index;
//-(void)setActualAmount:(CGFloat)actualAmount AtIndex :(NSInteger)index;
//-(void)setCalculatedAmount:(CGFloat)calculatedAmount AtIndex :(NSInteger)index;
-(CGFloat)totalPartialAmount;
@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat totalCashAndOthers;
@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat totalCredit;

//-(void)setCreditCardDictionary :(NSDictionary *)cardDictionary  AtIndex:(NSInteger)index;
//
//-(NSDictionary *)creditCardDictionaryAtIndex:(NSInteger)index;
//
//
-(NSString *)paymentImageAtIndex :(NSInteger)index;

-(NSString *)paymentNameAtIndex :(NSInteger)index;

-(NSNumber *)paymentIdAtIndex :(NSInteger)index;

@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat totalCollection;
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger indexOfFirstCashType;

-(CGFloat)displayAmountAtIndexPath :(NSIndexPath *)index;
-(CGFloat)diplayAmountAtIndex :(NSInteger)index;


-(void)addPaymentItemAtPaymentId:(NSInteger)paymentId;

-(NSString *)paymentTypeAtIndexPath :(NSIndexPath *)index;
-(CGFloat)calculatedAmountAtIndexPath :(NSIndexPath *)index;
-(CGFloat)actualAmountAtIndexPath :(NSIndexPath *)index;
-(void)setActualAmount:(CGFloat)actualAmount AtIndexPath :(NSIndexPath *)index;
-(void)setActualAmount:(CGFloat)actualAmount forpaymentMode:(PaymentModeItem *)paymentModeItem;

-(void)setCalculatedAmount:(CGFloat)calculatedAmount AtIndexPath :(NSIndexPath *)index;
-(void)setCreditCardDictionary :(NSDictionary *)cardDictionary  AtIndexPath:(NSIndexPath *)index;
-(NSDictionary *)creditCardDictionaryAtIndexPath:(NSIndexPath *)index;
-(NSString *)paymentImageAtIndexPath :(NSIndexPath *)index;
-(NSString *)paymentNameAtIndexPath :(NSIndexPath *)index;
-(NSNumber *)paymentIdAtIndexPath :(NSIndexPath *)index;

-(NSInteger)countOfPaymentModesInSection :(NSInteger )section;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray *creditSwipeArrayofPaymentModeItem;
-(NSArray *)paymentModeArrayAtIndex :(NSInteger)index;
-(BOOL )isCreditCardSwipedForPayment :(NSIndexPath *)paymentIndexPath;
-(BOOL )isCreditCardSwipedAtPaymentMode :(PaymentModeItem *)paymentModeItem;
-(BOOL)isMultipleCardIsApplicable :(NSInteger)index;
-(BOOL)isCreditCardApprovedPaymentMode;
-(CGFloat)displayTotalAmountAtIndexPath :(NSIndexPath *)index;

-(void)setActualAmount :(CGFloat)actualAmount atPaymentType :(NSString *)paymentType withPayId:(NSNumber *)payId;
-(void)setCheckCashActualAmount :(CGFloat)actualAmount atPaymentType :(NSString *)paymentType;
-(void)addTipAmountAtIndexpath:(NSIndexPath *)indexpath tipAmount:(CGFloat )tipAmount;

-(void)setTipAmount:(CGFloat)tipAmount;
-(void)setCustomerDisplayTipAmount:(CGFloat)tipAmount;

-(void)addCustomerDisplayTipAmountAtForPaymentModeItem:(PaymentModeItem *)paymentModeItem tipAmount:(CGFloat )tipAmount;
@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat totalTipAmountForBill;
-(void)configureEBTPaymentModeWithEBTAmount:(CGFloat )ebtAmount;
-(void)configureHouseChargeModeWithHouseChargeAmount:(CGFloat )houseChargeAmount;
-(BOOL )isMultiplePaymentModeAtIndexPathForPaymentMode :(NSIndexPath *)index;

-(void)addPaymentItemAtSection :(NSInteger )section withDictionary:(NSMutableDictionary *)paymentModeDictionary;
-(NSInteger )paymentModeCountAtSection:(NSInteger )section;
-(NSIndexPath *)selectedIndexPathForPaymentMode;


-(BOOL)isEbtPaymentModeAtIndexpath:(NSIndexPath *)indexpath;
-(BOOL)isHouseChargePaymentModeAtIndexpath:(NSIndexPath *)indexpath;

-(NSMutableArray *)giftSwipeArrayofPaymentModeItem;
-(CGFloat)totalAmountForApprovedGiftCard;
-(BOOL)isGiftCardAlreadyApprovedForCardNumber:(NSString *)cardNumber;
-(BOOL )isGiftCardApproveForPaymentMode :(NSIndexPath *)indexPath;
-(PaymentModeItem *)setpaymentModeItemWithIndexPath :(NSIndexPath *)paymentIndexPath;


-(void)setIsTipAdjustmentApplicable:(NSNumber *)isTipAdjustmentApplicable;
-(void)setPayId:(NSNumber *)payId;

-(void)setAmountToPay:(CGFloat)amountToPay;
-(void)setBalanceAmount:(CGFloat)balanceAmount;
-(void)setCollectionAmount:(CGFloat)collectionAmount;
-(void)setBillAmount:(CGFloat)billAmount;
-(void)setHouseChargeAmount:(CGFloat)houseChargeAmount;
-(void)setEbtAmount:(CGFloat)ebtAmount;
-(void)setHouseChargeValue:(CGFloat)houseChargeValue;
-(void)setCheckcashAmount:(CGFloat)checkcashAmount;

-(void)setLastSelectedPaymentTypeIndexPath:(NSIndexPath *)lastSelectedPaymentTypeIndexPath;

-(void)setModuleIdentifier:(NSString *)moduleIdentifier;
-(void)setStrInvoiceNo:(NSString *)strInvoiceNo;
-(void)setBillItemDetailString:(NSString *)billItemDetailString;
-(void)setTenderType:(NSString *)tenderType;

@property (NS_NONATOMIC_IOSONLY, getter=isPartiallyApprovedPaymentMode, readonly) BOOL partiallyApprovedPaymentMode;

- (NSMutableArray *)generateInvoiceItemDetailWith:(NSMutableArray *)tenderReciptDataAry;
-(NSMutableArray *)invoicePaymentdetail;
- (NSMutableArray *)tenderInvoiceMst;


@end
