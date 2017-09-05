//
//  PaymentData.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/18/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PaymentData.h"
#import "PaymentModeItem.h"
#import "RcrController.h"
#import "RmsDbController.h"
#import "NSString+Methods.h"
@interface PaymentData ()<NSCoding>
{
//    CGFloat tipAmount;
}
@property (nonatomic, strong) RcrController *crmController;

@property (nonatomic, assign ,readwrite ) CGFloat amountToPay;
@property (nonatomic, assign ,readwrite) CGFloat balanceAmount;
@property (nonatomic, assign ,readwrite) CGFloat collectionAmount;
@property (nonatomic, assign ,readwrite) CGFloat billAmount;
@property (nonatomic, assign ,readwrite) CGFloat ebtAmount;
@property (nonatomic, assign ,readwrite) CGFloat houseChargeValue;
@property (nonatomic, assign ,readwrite) CGFloat houseChargeAmount;
@property (nonatomic, assign ,readwrite) CGFloat checkcashAmount;
@property (nonatomic, assign ,readwrite) CGFloat tipAmount;

@property (assign ,readwrite) NSInteger completedCreditCardSwipe;
@property (assign ,readwrite) NSInteger tenderItemCount;

@property (nonatomic , strong ,readwrite) NSNumber *isTipAdjustmentApplicable;
@property (nonatomic , strong ,readwrite) NSNumber *payId;

@property (nonatomic,strong ,readwrite) NSIndexPath *lastSelectedPaymentTypeIndexPath;

@property(nonatomic, strong ,readwrite) NSMutableArray *paymentGatewayResponse;
@property(nonatomic,strong , readwrite) NSMutableArray *paymentModes;

@property (nonatomic, strong , readwrite) NSString * moduleIdentifier;
@property (nonatomic, strong , readwrite) NSString *strInvoiceNo;
@property (nonatomic, strong , readwrite) NSString *billItemDetailString;
@property (nonatomic, strong , readwrite) NSString *tenderType;
@property (nonatomic, strong ) RmsDbController *rmsDbController;

@end

@implementation PaymentData

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.rcrBillSummary forKey:@"rcrBillSummary"];
    [aCoder encodeObject:self.rapidCustomerLoyalty forKey:@"rapidCustomerLoyalty"];
    [aCoder encodeObject:self.billAmountCalculator forKey:@"billAmountCalculator"];

    [aCoder encodeFloat:self.amountToPay forKey:@"amountToPay"];
    [aCoder encodeFloat:self.balanceAmount forKey:@"balanceAmount"];
    [aCoder encodeFloat:self.collectionAmount forKey:@"collectionAmount"];
    [aCoder encodeFloat:self.billAmount forKey:@"billAmount"];
    [aCoder encodeFloat:self.tipAmount forKey:@"tipAmount"];
    [aCoder encodeFloat:self.houseChargeValue forKey:@"houseChargeValue"];
    [aCoder encodeFloat:self.houseChargeAmount forKey:@"houseChargeAmount"];
    [aCoder encodeFloat:self.ebtAmount forKey:@"ebtAmount"];
    [aCoder encodeFloat:self.checkcashAmount forKey:@"checkcashAmount"];
    
    [aCoder encodeObject:@(self.completedCreditCardSwipe) forKey:@"completedCreditCardSwipe"];
   
    [aCoder encodeObject:self.isTipAdjustmentApplicable forKey:@"isTipAdjustmentApplicable"];
    [aCoder encodeObject:self.payId forKey:@"payId"];

    [aCoder encodeObject:self.lastSelectedPaymentTypeIndexPath forKey:@"lastSelectedPaymentTypeIndexPath"];
   
    [aCoder encodeObject:self.paymentGatewayResponse forKey:@"paymentGatewayResponse"];
    [aCoder encodeObject:self.paymentModes forKey:@"paymentModes"];
    [aCoder encodeObject:self.receiptDataArray forKey:@"receiptDataArray"];
    [aCoder encodeObject:self.paymentForVoid forKey:@"paymentForVoid"];
    
    [aCoder encodeObject:self.dictAmoutInfo forKey:@"dictAmoutInfo"];
    [aCoder encodeObject:self.dictCustomerInfo forKey:@"dictCustomerInfo"];

    [aCoder encodeObject:self.moduleIdentifier forKey:@"moduleIdentifier"];
    [aCoder encodeObject:self.strInvoiceNo forKey:@"strInvoiceNo"];
    [aCoder encodeObject:self.billItemDetailString forKey:@"billItemDetailString"];
    [aCoder encodeObject:self.tenderType forKey:@"tenderType"];
    [aCoder encodeObject:self.numberOfGuest forKey:@"numberOfGuest"];
    [aCoder encodeObject:self.tableNo forKey:@"tableNo"];

    [aCoder encodeBool:self.isCheckCashApplicableAplliedToBill forKey:@"isCheckCashApplicableAplliedToBill"];
    [aCoder encodeBool:self.isVoidForInvoice forKey:@"isVoidForInvoice"];
    [aCoder encodeBool:self.isHouseChargePay forKey:@"isHouseChargePay"];

}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.rcrBillSummary = [aDecoder decodeObjectForKey:@"rcrBillSummary"];
        self.rapidCustomerLoyalty = [aDecoder decodeObjectForKey:@"rapidCustomerLoyalty"];
        self.billAmountCalculator = [aDecoder decodeObjectForKey:@"billAmountCalculator"];

        self.amountToPay = [aDecoder decodeFloatForKey:@"amountToPay"];
        self.balanceAmount = [aDecoder decodeFloatForKey:@"balanceAmount"];
        self.collectionAmount = [aDecoder decodeFloatForKey:@"collectionAmount"];
        self.billAmount = [aDecoder decodeFloatForKey:@"billAmount"];
        self.tipAmount = [aDecoder decodeFloatForKey:@"tipAmount"];
        self.houseChargeAmount = [aDecoder decodeFloatForKey:@"houseChargeAmount"];
        self.houseChargeValue = [aDecoder decodeFloatForKey:@"houseChargeValue"];
        self.checkcashAmount = [aDecoder decodeFloatForKey:@"checkcashAmount"];
        self.ebtAmount = [aDecoder decodeFloatForKey:@"ebtAmount"];
        
        self.completedCreditCardSwipe = [[aDecoder decodeObjectForKey:@"completedCreditCardSwipe"] integerValue];
        
        self.isTipAdjustmentApplicable = [aDecoder decodeObjectForKey:@"isTipAdjustmentApplicable"];
        self.payId = [aDecoder decodeObjectForKey:@"payId"];

        self.lastSelectedPaymentTypeIndexPath = [aDecoder decodeObjectForKey:@"lastSelectedPaymentTypeIndexPath"];
        
        self.paymentGatewayResponse = [aDecoder decodeObjectForKey:@"paymentGatewayResponse"];
        self.paymentModes = [aDecoder decodeObjectForKey:@"paymentModes"];
        self.receiptDataArray = [aDecoder decodeObjectForKey:@"receiptDataArray"];
        self.paymentForVoid = [aDecoder decodeObjectForKey:@"paymentForVoid"];
        
        self.dictAmoutInfo = [aDecoder decodeObjectForKey:@"dictAmoutInfo"];
        self.dictCustomerInfo = [aDecoder decodeObjectForKey:@"dictCustomerInfo"];

        self.strInvoiceNo = [aDecoder decodeObjectForKey:@"strInvoiceNo"];
        self.moduleIdentifier = [aDecoder decodeObjectForKey:@"moduleIdentifier"];
        self.billItemDetailString = [aDecoder decodeObjectForKey:@"billItemDetailString"];
        self.tenderType = [aDecoder decodeObjectForKey:@"tenderType"];
        self.numberOfGuest = [aDecoder decodeObjectForKey:@"numberOfGuest"];
        self.tableNo = [aDecoder decodeObjectForKey:@"tableNo"];

        self.isCheckCashApplicableAplliedToBill = [aDecoder decodeBoolForKey:@"isCheckCashApplicableAplliedToBill"];
        self.isVoidForInvoice = [aDecoder decodeBoolForKey:@"isVoidForInvoice"];
        self.isHouseChargePay = [aDecoder decodeBoolForKey:@"isHouseChargePay"];
    }
    
    return self;

}

-(void)configureWith :(NSArray *)paymentModes
{
    _tipAmount = 0.0;
    self.paymentModes=[[NSMutableArray alloc]init];
    
    for (NSDictionary *paymentModeDictionary in paymentModes)
    {
        PaymentModeItem *paymentmode=[[PaymentModeItem alloc]init];
        paymentmode.paymentModeDictionary = paymentModeDictionary;
        [self.paymentModes addObject:[@[paymentmode] mutableCopy]];
    }
    //   NSInteger index= [self indexOfFirstCashType];
    //    if (index >= 0)
    //    {
    //        [self setCalculatedAmount:self.amountToPay AtIndex:index ];
    //    }
    [self calculateBalance];
}

-(void)addPaymentItemAtPaymentId:(NSInteger)paymentId
{
    int i = 0;
    for (NSDictionary *paymentModeDictionary in self.paymentModes)
    {
        if ([[[paymentModeDictionary valueForKey:@"paymentType"] firstObject] isEqualToString:@"Credit"] && paymentId ==[[[paymentModeDictionary valueForKey:@"paymentId"] firstObject] integerValue]  )
        {
            [self addPaymentItemAtSection:i];
        }
        i++;
    }
}
-(void)configureEBTPaymentModeWithEBTAmount:(CGFloat )ebtAmount
{
    for (int i =0; i < self.paymentModes.count; i++) {
        PaymentModeItem *item = [(self.paymentModes)[i] firstObject];
        if ([item.paymentType isEqualToString:@"EBT/Food Stamp"])
        {
            item.calculatedAmount = @(0.0);
            item.actualAmount = @(ebtAmount);
            break;
        }
    }
    [self calculateBalance];
}

-(void)configureHouseChargeModeWithHouseChargeAmount:(CGFloat )houseChargeAmount
{
    for (int i =0; i < self.paymentModes.count; i++) {
        PaymentModeItem *item = [(self.paymentModes)[i] firstObject];
        if ([item.paymentType isEqualToString:@"HouseCharge"])
        {
            item.calculatedAmount = @(0.0);
            item.actualAmount = @(houseChargeAmount);
            break;
        }
    }
    [self calculateBalance];
}


-(BOOL)isEbtPaymentModeAtIndexpath:(NSIndexPath *)indexpath
{
    BOOL isEbtPaymentModeAtIndexpath = FALSE;
    
    if (self.paymentModes.count <= indexpath.section) {
        return isEbtPaymentModeAtIndexpath;
    }
    
    NSMutableArray *actualAmountArray =(self.paymentModes)[indexpath.section];
    PaymentModeItem *paymentmode = actualAmountArray[indexpath.row];
    if ([paymentmode.paymentType isEqualToString:@"EBT/Food Stamp"])
    {
        isEbtPaymentModeAtIndexpath = TRUE;
    }
    return isEbtPaymentModeAtIndexpath;
}

-(BOOL)isHouseChargePaymentModeAtIndexpath:(NSIndexPath *)indexpath
{
    BOOL isHouseChargePaymentModeAtIndexpath = FALSE;
    
    if (self.paymentModes.count <= indexpath.section) {
        return isHouseChargePaymentModeAtIndexpath;
    }
    
    NSMutableArray *actualAmountArray =(self.paymentModes)[indexpath.section];
    PaymentModeItem *paymentmode = actualAmountArray[indexpath.row];
    if ([paymentmode.paymentType isEqualToString:@"HouseCharge"])
    {
        isHouseChargePaymentModeAtIndexpath = TRUE;
    }
    return isHouseChargePaymentModeAtIndexpath;
}

-(CGFloat)totalPartialAmount
{
    CGFloat totalCollection = 0.0;
  
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *calculatedAmountArray = (self.paymentModes)[i];
        for (int j =0; j < calculatedAmountArray.count; j++) {
            PaymentModeItem *item = calculatedAmountArray[j];
            if (item.isPartialApprove == FALSE)
            {
                continue;
            }
            if (item.actualAmount.floatValue == 0.0) {
                totalCollection+= item.calculatedAmount.floatValue;
            }
            else
            {
                totalCollection+= item.actualAmount.floatValue;
            }
        }
    }
    return totalCollection;
}



-(void)addCustomerDisplayTipAmountAtForPaymentModeItem:(PaymentModeItem *)paymentModeItem tipAmount:(CGFloat )tipAmount
{
    PaymentModeItem *paymentmode = paymentModeItem;
    CGFloat actualAmount = paymentmode.actualAmount.floatValue ;
    if (actualAmount == 0)
    {
        actualAmount = paymentmode.calculatedAmount.floatValue;
    }
    actualAmount+= tipAmount;
    paymentmode.actualAmount = @(actualAmount);
    paymentmode.calculatedAmount = @(0);
}

-(CGFloat)totalTipAmountForBill
{
    CGFloat totalTipAmount = 0.00;
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *paymentModeArray = (self.paymentModes)[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            if (item.isCustomerDiplayTipAdjusted == TRUE) {
                totalTipAmount+= item.calculatedAmount.floatValue;
            }
        }
    }
    totalTipAmount += self.tipAmount;
    return totalTipAmount;
    
}

-(void)addTipAmountAtIndexpath:(NSIndexPath *)indexpath tipAmount:(CGFloat )tipAmount
{
    if (self.paymentModes.count <= indexpath.section) {
        return ;
    }
    NSMutableArray *actualAmountArray =(self.paymentModes)[indexpath.section];
    PaymentModeItem *paymentmode = actualAmountArray[indexpath.row];
    CGFloat actualAmount = paymentmode.actualAmount.floatValue ;
    if (actualAmount == 0)
    {
        actualAmount = paymentmode.calculatedAmount.floatValue;
    }
    actualAmount+= tipAmount;
    paymentmode.actualAmount = @(actualAmount);
    paymentmode.calculatedAmount = @(0);
}

-(void)setActualAmount :(CGFloat)actualAmount atPaymentType :(NSString *)paymentType withPayId:(NSNumber *)payId
{
    for (int i =0; i < self.paymentModes.count; i++) {
        PaymentModeItem *item = [(self.paymentModes)[i] firstObject];
        if ([item.paymentType isEqualToString:paymentType] && [item.paymentId isEqualToNumber:payId])
        {
            item.calculatedAmount = @(0.0);
            item.actualAmount = @(actualAmount);
            [self calculateBalance];
            break;
        }
    }
}

-(void)setCheckCashActualAmount :(CGFloat)actualAmount atPaymentType :(NSString *)paymentType
{
    for (int i =0; i < self.paymentModes.count; i++) {
        PaymentModeItem *item = [(self.paymentModes)[i] firstObject];
        if ([item.paymentType isEqualToString:paymentType])
        {
            item.calculatedAmount = @(0.0);
            item.displayAmount = @(actualAmount);
            item.actualAmount = @(0.0);
        }
    }
}

-(NSIndexPath *)selectedIndexPathForPaymentMode
{
    NSIndexPath *selectedIndexPathForPaymentMode;
    
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *paymentModeArray = (self.paymentModes)[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            
            if ((item.actualAmount.floatValue + item.calculatedAmount.floatValue)!= 0 && item.displayAmount.floatValue == 0)
            {
                selectedIndexPathForPaymentMode = [NSIndexPath indexPathForRow:j inSection:i];
            }
        }
    }
    return selectedIndexPathForPaymentMode;
}

-(NSInteger )paymentModeCountAtSection:(NSInteger )section
{
    if (self.paymentModes.count <= section) {
        return 0;
    }
    NSMutableArray * paymentModeItems = (self.paymentModes)[section];
    return paymentModeItems.count;
}

-(void)addPaymentItemAtSection :(NSInteger )section withDictionary:(NSMutableDictionary *)paymentModeDictionary
{
    if (self.paymentModes.count <= section) {
        return;
    }
    NSMutableArray * paymentModeItems = (self.paymentModes)[section];
    PaymentModeItem *paymentModeItem=[[PaymentModeItem alloc] init];
    paymentModeItem.paymentModeDictionary = paymentModeDictionary;
    [paymentModeItems addObject:paymentModeItem];
}




-(void)addPaymentItemAtSection :(NSInteger )section
{
    if (self.paymentModes.count <= section) {
        return;
    }
    NSMutableArray * paymentModeItems = (self.paymentModes)[section];
    PaymentModeItem *firstItem = paymentModeItems.firstObject;
    if (firstItem == nil || firstItem.paymentModeDictionary == nil) {
        return;
    }
    PaymentModeItem *paymentModeItem=[[PaymentModeItem alloc] init];
    paymentModeItem.paymentModeDictionary = [firstItem.paymentModeDictionary mutableCopy];
    [paymentModeItems addObject:paymentModeItem];
}

-(NSInteger)countOfPaymentModes
{
    return self.paymentModes.count;
}
-(NSString *)paymentTypeAtIndex :(NSInteger)index
{
    if (self.paymentModes.count <= index) {
        return nil;
    }
    PaymentModeItem *paymentmode=[(self.paymentModes)[index] firstObject];
    if (paymentmode == nil)
    {
        return nil;
    }
    return paymentmode.paymentType;
}

-(CGFloat)calculatedAmountAtIndex :(NSInteger)index
{
    if (self.paymentModes.count <= index) {
        return 0;
    }
    CGFloat totalcalculatedAmount = 0.0;
    //    PaymentModeItem *paymentmode=[self.paymentModes objectAtIndex:index];
    NSArray * calculatedAmountArray = (self.paymentModes)[index];
    for (PaymentModeItem *paymentModesItem in calculatedAmountArray)
    {
        totalcalculatedAmount += paymentModesItem.calculatedAmount.floatValue;
    }
    return totalcalculatedAmount;
}

-(CGFloat)diplayAmountAtIndex :(NSInteger)index
{
    if (self.paymentModes.count <= index) {
        return 0;
    }
    CGFloat totalDisplayAmount = 0.0;
    //    PaymentModeItem *paymentmode=[self.paymentModes objectAtIndex:index];
    NSArray * calculatedAmountArray = (self.paymentModes)[index];
    for (PaymentModeItem *paymentModesItem in calculatedAmountArray)
    {
        totalDisplayAmount += paymentModesItem.displayAmount.floatValue;
    }
    return totalDisplayAmount;
}


-(CGFloat)actualAmountAtIndex :(NSInteger)index
{
    
    if (self.paymentModes.count <= index) {
        return 0;
    }
    //    PaymentModeItem *paymentmode=[self.paymentModes objectAtIndex:index];
    CGFloat totalactualAmount = 0.0;
    NSArray * calculateActualAmount = (self.paymentModes)[index];
    for (PaymentModeItem *paymentModesItem in calculateActualAmount)
    {
        totalactualAmount += paymentModesItem.actualAmount.floatValue;
    }
    return totalactualAmount;
}

-(void)setActualAmount:(CGFloat)actualAmount AtIndex :(NSInteger)index
{
    if (self.paymentModes.count <= index) {
        return ;
    }
    PaymentModeItem *paymentmode=(self.paymentModes)[index];
    paymentmode.calculatedAmount = @(0.0);
    paymentmode.actualAmount = @(actualAmount);
    [self calculateBalance];
}

-(void)setActualAmount:(CGFloat)actualAmount forpaymentMode:(PaymentModeItem *)paymentModeItem
{
    paymentModeItem.calculatedAmount = @(0.0);
    paymentModeItem.actualAmount = @(actualAmount);
    [self calculateBalance];
}


- (void)calculateBalance {
    self.collectionAmount = 0.0;
    self.amountToPay = self.billAmount + self.tipAmount;
    /*  for (PaymentModeItem *item in self.paymentModes) {
     if (item.actualAmount.floatValue == 0.0) {
     // self.collectionAmount += item.calculatedAmount.floatValue;
     }
     else
     {
     self.collectionAmount += item.actualAmount.floatValue;
     }
     }
     self.balanceAmount = self.amountToPay-self.collectionAmount;
     
     if (self.amountToPay < 0)
     {
     if (self.balanceAmount > 0)
     {
     self.balanceAmount = 0;
     }
     }*/
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *calculateBalanceArray = (self.paymentModes)[i];
        
        for (int j =0; j < calculateBalanceArray.count; j++) {
            PaymentModeItem *paymentmode = calculateBalanceArray[j];
            if (paymentmode.actualAmount.floatValue == 0.0) {
                // self.collectionAmount += item.calculatedAmount.floatValue;
            }
            else
            {
                self.collectionAmount += paymentmode.actualAmount.floatValue;
            }
        }
    }
    self.balanceAmount = self.amountToPay-self.totalCollection;
    if (self.amountToPay < 0)
    {
        if (self.balanceAmount > 0)
        {
            self.balanceAmount = 0;
        }
    }
    
    if (self.balanceAmount > -0.009 && self.balanceAmount < 0.009) {
        self.balanceAmount = 0.0;
    }
}

-(NSInteger)indexOfFirstCashType
{
    NSInteger indexOfFirstCashType = -1;
    
    //    for (int i =0; i < [self.paymentModes count]; i++)
    //    {
    //        PaymentModeItem *item = [self.paymentModes objectAtIndex:i];
    //        if ([item.paymentType isEqualToString:@"Cash"]) {
    //            indexOfFirstCashType = i;
    //            break;
    //        }
    //    }
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *indexOfFirstCashArray = (self.paymentModes)[i];
        if (indexOfFirstCashArray.count == 1) {
            PaymentModeItem *item = indexOfFirstCashArray.firstObject;
            NSString *paymentType = item.paymentType;
            if ([paymentType isEqualToString:@"Cash"]) {
                indexOfFirstCashType = i;
                break;
            }
        }
    }
    return indexOfFirstCashType;
}

-(NSString *)paymentImageAtIndex :(NSInteger)index
{
    if (self.paymentModes.count <= index) {
        return nil;
    }
    //    PaymentModeItem *paymentmode=[self.paymentModes objectAtIndex:index];
    PaymentModeItem *paymentmode=[(self.paymentModes)[index] firstObject];
    if (paymentmode == nil)
    {
        return nil;
    }
    return paymentmode.paymentImage;
}

-(NSString *)paymentNameAtIndex :(NSInteger)index
{
    if (self.paymentModes.count <= index) {
        return nil;
    }
    //    PaymentModeItem *paymentmode=[self.paymentModes objectAtIndex:index];
    PaymentModeItem *paymentmode=[(self.paymentModes)[index] firstObject];
    if (paymentmode == nil)
    {
        return nil;
    }
    return paymentmode.paymentName;
}

-(NSNumber *)paymentIdAtIndex :(NSInteger)index
{
    if (self.paymentModes.count <= index) {
        return nil;
    }
    //    PaymentModeItem *paymentmode=[self.paymentModes objectAtIndex:index];
    PaymentModeItem *paymentmode=[(self.paymentModes)[index] firstObject];
    if (paymentmode == nil)
    {
        return nil;
    }
    return paymentmode.paymentId;
}

-(BOOL)isMultipleCardIsApplicable :(NSInteger)index
{
    if (self.paymentModes.count <= index) {
        return 0;
    }
    PaymentModeItem *paymentmode=[(self.paymentModes)[index] firstObject];
    if (paymentmode == nil)
    {
        return 0;
    }
    return paymentmode.mulipleCreditCardApplicable;
}

-(CGFloat)totalCashAndOthers
{
    float totalCashOthers = 0;
    //    for (PaymentModeItem *item in self.paymentModes)
    //    {
    //        NSString *paymentType = [item paymentType];
    //        if ([paymentType isEqualToString:@"Cash"] || [paymentType isEqualToString:@"Others"])
    //        {
    //            totalCashOthers +=item.actualAmount.floatValue;
    //        }
    //    }
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *totalCashArray = (self.paymentModes)[i];
        for (int j =0; j < totalCashArray.count; j++) {
            PaymentModeItem *item = totalCashArray[j];
            NSString *paymentType = item.paymentType;
            if ([paymentType isEqualToString:@"Cash"])
            {
                totalCashOthers+= item.actualAmount.floatValue;
            }
        }
    }
    return totalCashOthers ;
}

-(CGFloat)totalCredit
{
    float totalCredit = 0;
   
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *totalCashArray = (self.paymentModes)[i];
        for (int j =0; j < totalCashArray.count; j++) {
            PaymentModeItem *item = totalCashArray[j];
            NSString *paymentType = item.paymentType;
            if (![paymentType isEqualToString:@"Cash"] && ![paymentType isEqualToString:@"Others"])
            {
                totalCredit+= item.actualAmount.floatValue + item.calculatedAmount.floatValue;
            }
        }
    }
    return totalCredit ;
}


-(void)setCalculatedAmount:(CGFloat)calculatedAmount AtIndex :(NSInteger)index
{
    for (int i =0; i < self.paymentModes.count; i++) {
        PaymentModeItem *item = (self.paymentModes)[i];
        if (i == index) {
            item.calculatedAmount = @(calculatedAmount);
        }
        else
        {
            item.calculatedAmount = @(0.0);
        }
    }
    [self calculateBalance];
}

- (NSString*)description
{
    NSString *description = [NSString stringWithFormat:@"<PaymentData \n amounToPay=%.2f \n balanceAmount=%.2f \n collectionAmount=%.2f \n (%@)>",self.amountToPay,self.balanceAmount,self.collectionAmount, self.paymentModes];
    
    return description;
}

-(CGFloat)totalCollection
{
    CGFloat totalCollection = 0.0;
    /*for (PaymentModeItem *item in self.paymentModes)
     {
     if (item.actualAmount.floatValue == 0.0) {
     totalCollection+= item.calculatedAmount.floatValue;
     }
     else
     {
     totalCollection+= item.actualAmount.floatValue;
     }
     }*/
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *calculatedAmountArray = (self.paymentModes)[i];
        for (int j =0; j < calculatedAmountArray.count; j++) {
            PaymentModeItem *item = calculatedAmountArray[j];
            if (item.actualAmount.floatValue == 0.0) {
                totalCollection+= item.calculatedAmount.floatValue;
            }
            else
            {
                totalCollection+= item.actualAmount.floatValue;
            }
        }
    }
    return totalCollection;
}

-(void)setCreditCardDictionary :(NSDictionary *)cardDictionary  AtIndex:(NSInteger)index;
{
    PaymentModeItem *paymentmode=(self.paymentModes)[index];
    paymentmode.paymentModeDictionary = cardDictionary;
}

-(NSDictionary *)creditCardDictionaryAtIndex:(NSInteger)index
{
    return nil;
    PaymentModeItem *paymentmode = (self.paymentModes)[index];
    return paymentmode.cerditCardDictionary;
}

//// Multiple Credit card implimentation
-(NSString *)paymentTypeAtIndexPath :(NSIndexPath *)index
{
    if (self.paymentModes.count <= index.section) {
        return nil;
    }
    PaymentModeItem *paymentmode=[(self.paymentModes)[index.section] firstObject];
    return paymentmode.paymentType;
}

-(CGFloat)calculatedAmountAtIndexPath :(NSIndexPath *)index
{
    if (self.paymentModes.count <= index.section) {
        return 0;
    }
    CGFloat totalactualAmount = 0.0;
    NSMutableArray * calculatedAmountArray = (self.paymentModes)[index.section];
    PaymentModeItem *paymentModesItem  = calculatedAmountArray[index.row];
    totalactualAmount = paymentModesItem.calculatedAmount.floatValue;
    return totalactualAmount;
}

-(CGFloat)actualAmountAtIndexPath :(NSIndexPath *)index
{
    if (self.paymentModes.count <= index.section) {
        return 0;
    }
    CGFloat totalactualAmount = 0.0;
    NSMutableArray * actualAmountAmount = (self.paymentModes)[index.section];
    PaymentModeItem *paymentModesItem  = actualAmountAmount[index.row];
    totalactualAmount = paymentModesItem.actualAmount.floatValue;
    return totalactualAmount;
}


-(CGFloat)displayTotalAmountAtIndexPath :(NSIndexPath *)index
{
    if (self.paymentModes.count <= index.section) {
        return 0;
    }
    CGFloat totalactualAmount = 0.0;
    NSMutableArray * actualAmountAmount = (self.paymentModes)[index.section];
    PaymentModeItem *paymentModesItem  = actualAmountAmount[index.row];
    totalactualAmount = paymentModesItem.actualAmount.floatValue + paymentModesItem.calculatedAmount.floatValue;
    return totalactualAmount;
}


-(CGFloat)displayAmountAtIndexPath :(NSIndexPath *)index
{
    if (self.paymentModes.count <= index.section) {
        return 0;
    }
    CGFloat totalactualAmount = 0.0;
    NSMutableArray * actualAmountAmount = (self.paymentModes)[index.section];
    PaymentModeItem *paymentModesItem  = actualAmountAmount[index.row];
    totalactualAmount = paymentModesItem.displayAmount.floatValue;
    return totalactualAmount;
}


-(void)setActualAmount:(CGFloat)actualAmount AtIndexPath :(NSIndexPath *)index
{
    if (self.paymentModes.count <= index.section) {
        return ;
    }
    NSMutableArray *actualAmountArray =(self.paymentModes)[index.section];
    PaymentModeItem *paymentmode = actualAmountArray[index.row];
    paymentmode.calculatedAmount = @(0.0);
    paymentmode.actualAmount = @(actualAmount);
    [self calculateBalance];
}

-(void)setCalculatedAmount:(CGFloat)calculatedAmount AtIndexPath :(NSIndexPath *)index
{
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *calculatedAmountArray = (self.paymentModes)[i];
        for (int j =0; j < calculatedAmountArray.count; j++) {
            PaymentModeItem *paymentmode = calculatedAmountArray[j];
            if (i == index.section && j == index.row) {
                paymentmode.calculatedAmount = @(calculatedAmount);
            }
            else
            {
                paymentmode.calculatedAmount = @(0.0);
            }
        }
    }
    [self calculateBalance];
}

-(void)setCreditCardDictionary :(NSDictionary *)cardDictionary  AtIndexPath:(NSIndexPath *)index
{
    
}

-(NSDictionary *)creditCardDictionaryAtIndexPath:(NSIndexPath *)index
{
    PaymentModeItem *paymentmode = (self.paymentModes)[index.section];
    return paymentmode.cerditCardDictionary;
}

-(NSString *)paymentImageAtIndexPath :(NSIndexPath *)index
{
    if (self.paymentModes.count <= index.section) {
        return nil;
    }
    PaymentModeItem *paymentmode=(self.paymentModes)[index.section][index.row];
    return paymentmode.paymentImage;
}

-(NSString *)paymentNameAtIndexPath :(NSIndexPath *)index
{
    if (self.paymentModes.count <= index.section) {
        return nil;
    }
    PaymentModeItem *paymentmode=(self.paymentModes)[index.section][index.row];
    return paymentmode.paymentName;
}


-(BOOL )isMultiplePaymentModeAtIndexPathForPaymentMode :(NSIndexPath *)index
{
    if (self.paymentModes.count <= index.section) {
        return FALSE;
    }
    PaymentModeItem *paymentmode=(self.paymentModes)[index.section][index.row];
    return paymentmode.isMulipleCreditCardApplicable;
}


-(NSNumber *)paymentIdAtIndexPath :(NSIndexPath *)index
{
    if (self.paymentModes.count <= index.section) {
        return nil;
    }
    PaymentModeItem *paymentmode=(self.paymentModes)[index.section];
    return paymentmode.paymentId;
}

-(NSInteger)countOfPaymentModesInSection :(NSInteger )section
{
    return [(self.paymentModes)[section] count];
}
-(NSMutableArray *)creditSwipeArrayofPaymentModeItem
{
    NSMutableArray *creditSwipeArray = [[NSMutableArray alloc]init];
    /*  for (PaymentModeItem *item in self.paymentModes)
     {
     if ([[item.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"Credit"])
     {
     [creditSwipeArray addObject:item];
     }
     }*/
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *paymentModeArray = (self.paymentModes)[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            
            if ([[item.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"Credit"]  || [[item.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"Debit"])
            {
                NSString *isCreditCardSwipeString = [item isCreditCardSwipe];
                if ([self isCardSwipeWithSpecOption:3 withPayId:item.paymentId.integerValue] && (item.actualAmount.floatValue + item.calculatedAmount.floatValue)!= 0 && [isCreditCardSwipeString isEqualToString:@"0"])
                {
                    [creditSwipeArray addObject:item];
                }
            }
        }
    }
    
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *paymentModeArray = (self.paymentModes)[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            NSString *isCreditCardSwipeString = [item isCreditCardSwipe];

            if ([[item.paymentModeDictionary valueForKey:@"CardIntType"]  isEqualToString:@"EBT/Food Stamp"] && (item.actualAmount.floatValue + item.calculatedAmount.floatValue)!= 0 && [isCreditCardSwipeString isEqualToString:@"0"])
            {
                    [creditSwipeArray insertObject:item atIndex:0];
            }
        }
    }
    
    return creditSwipeArray;
}

-(BOOL)isCardSwipeWithSpecOption:(int)specOption withPayId:(NSInteger)ipay
{
    BOOL isApplicable = FALSE;
    if (self.crmController == nil) {
        self.crmController = [RcrController sharedCrmController];
    }
    
    for(int tenderConfig = 0; tenderConfig<self.crmController.globalArrTenderConfig.count; tenderConfig++)
    {
        int itender=[[(self.crmController.globalArrTenderConfig)[tenderConfig] valueForKey:@"PayId" ] intValue ];
        if(ipay==itender)
        {
            if([[(self.crmController.globalArrTenderConfig)[tenderConfig] valueForKey:@"SpecOption"] intValue ] == specOption)
            {
                isApplicable = TRUE;
            }
        }
    }
    return isApplicable;
}


-(NSArray *)paymentModeArrayAtIndex :(NSInteger)index
{
    if (self.paymentModes.count <= index) {
        return nil;
    }
    return self.paymentModes[index];
}


-(BOOL )isCreditCardSwipedForPayment :(NSIndexPath *)paymentIndexPath
{
    BOOL iscreditCardSwiped = FALSE;
    if (self.paymentModes.count <= paymentIndexPath.section) {
        return iscreditCardSwiped;
    }
    PaymentModeItem *paymentmode=self.paymentModes[paymentIndexPath.section] [paymentIndexPath.row];
    return [self isCreditCardSwipedAtPaymentMode:paymentmode];
}

-(BOOL)isCreditCardSwipedAtPaymentMode :(PaymentModeItem *)paymentModeItem
{
    BOOL iscreditCardSwiped = FALSE;
    NSString *isCreditCardSwipeString = [paymentModeItem isCreditCardSwipe];
    if ([isCreditCardSwipeString isEqualToString:@"1"])
    {
        iscreditCardSwiped = TRUE;
    }
    return iscreditCardSwiped;
}


-(BOOL)isPartiallyApprovedPaymentMode
{
    BOOL isPartiallyApprovedPaymentMode = FALSE;
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *paymentModeArray = (self.paymentModes)[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            if (item.isPartiallyApprovedPaymentMode == TRUE)
            {
                isPartiallyApprovedPaymentMode = TRUE;
                break;
            }
        }
    }

    
    return isPartiallyApprovedPaymentMode;
}


-(BOOL)isCreditCardApprovedPaymentMode
{
    BOOL isCreditCardApprovedPaymentMode = FALSE;
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *paymentModeArray = (self.paymentModes)[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            if ([item.isCreditCardSwipe isEqualToString:@"1"])
            {
                isCreditCardApprovedPaymentMode = TRUE;
                break;
            }
        }
    }
    
    
    return isCreditCardApprovedPaymentMode;
}


-(void)setTipAmount:(CGFloat)tipAmount
{
    self.amountToPay = self.amountToPay - _tipAmount + tipAmount;
    
    _tipAmount = tipAmount;
    [self calculateBalance];
}
-(void)setCustomerDisplayTipAmount:(CGFloat)tipAmount
{
    self.amountToPay = self.amountToPay + tipAmount;
    _tipAmount = tipAmount;
}

#pragma GiftCard 
-(NSMutableArray *)giftSwipeArrayofPaymentModeItem
{
    NSMutableArray *giftSwipeArray = [[NSMutableArray alloc]init];
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *paymentModeArray = (self.paymentModes)[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            
            if ([[item.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"RapidRMS Gift Card"])
            {
                NSString *isGiftCardApprovedString = [item isGiftCardApproved];
                if ([isGiftCardApprovedString isEqualToString:@"0"] && (item.actualAmount.floatValue + item.calculatedAmount.floatValue)!= 0)
                {
                    [giftSwipeArray addObject:item];
                }
            }
        }
    }
    return giftSwipeArray;
}

-(CGFloat)totalAmountForApprovedGiftCard
{
    CGFloat totalAmountForApprovedGiftCard = 0.00;
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *paymentModeArray = (self.paymentModes)[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            
            if ([[item.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"RapidRMS Gift Card"])
            {
                NSString *isGiftCardApprovedString = [item isGiftCardApproved];
                if ([isGiftCardApprovedString isEqualToString:@"1"] && (item.actualAmount.floatValue + item.calculatedAmount.floatValue)!= 0)
                {
                    totalAmountForApprovedGiftCard = item.actualAmount.floatValue + item.calculatedAmount.floatValue;
                }
            }
        }
    }
    return totalAmountForApprovedGiftCard;
}


-(BOOL)isGiftCardAlreadyApprovedForCardNumber:(NSString *)cardNumber
{
    BOOL isGiftCardAlreadyApproved = FALSE;
    for (int i =0; i < self.paymentModes.count; i++) {
        NSMutableArray *paymentModeArray = (self.paymentModes)[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            
            if ([[item.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"RapidRMS Gift Card"])
            {
                NSString *isGiftCardApprovedString = [item isGiftCardApproved];
                NSString *isGiftCardApprovedCardNumber = [item giftCardNumber];
                if ([isGiftCardApprovedString isEqualToString:@"1"] && (item.actualAmount.floatValue + item.calculatedAmount.floatValue)!= 0 && [isGiftCardApprovedCardNumber isEqualToString:cardNumber])
                {
                    isGiftCardAlreadyApproved = TRUE;
                }
            }
        }
    }
    return isGiftCardAlreadyApproved;
}



-(BOOL )isGiftCardApproveForPaymentMode :(NSIndexPath *)indexPath
{
    BOOL isGiftCardApproveForPaymentMode = FALSE;
    if (self.paymentModes.count <= indexPath.section) {
        return FALSE;
    }
         PaymentModeItem *paymentmode=self.paymentModes[indexPath.section] [indexPath.row];
            if ([[paymentmode.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"RapidRMS Gift Card"])
            {
                NSString *isGiftCardApprovedString = [paymentmode isGiftCardApproved];
                if ([isGiftCardApprovedString isEqualToString:@"1"] && (paymentmode.actualAmount.floatValue + paymentmode.calculatedAmount.floatValue)!= 0)
                {
                    isGiftCardApproveForPaymentMode = TRUE;
                }
            }
    return isGiftCardApproveForPaymentMode;
}

-(PaymentModeItem *)setpaymentModeItemWithIndexPath :(NSIndexPath *)paymentIndexPath
{
    PaymentModeItem *paymentmode=self.paymentModes[paymentIndexPath.section] [paymentIndexPath.row];
    return paymentmode;
}

-(void)setAmountToPay:(CGFloat)amountToPay
{
    _amountToPay = amountToPay;
}

-(void)setBalanceAmount:(CGFloat)balanceAmount
{
    _balanceAmount = balanceAmount;
}

-(void)setCollectionAmount:(CGFloat)collectionAmount
{
    _collectionAmount = collectionAmount;
}

-(void)setBillAmount:(CGFloat)billAmount
{
    _billAmount = billAmount;
}

-(void)setHouseChargeAmount:(CGFloat)houseChargeAmount
{
    _houseChargeAmount = houseChargeAmount;
}

-(void)setEbtAmount:(CGFloat)ebtAmount
{
    _ebtAmount = ebtAmount;
}

-(void)setHouseChargeValue:(CGFloat)houseChargeValue
{
    _houseChargeValue = houseChargeValue;
}

-(void)setCheckcashAmount:(CGFloat)checkcashAmount
{
    _checkcashAmount = checkcashAmount;
}

-(void)setLastSelectedPaymentTypeIndexPath:(NSIndexPath *)lastSelectedPaymentTypeIndexPath
{
    _lastSelectedPaymentTypeIndexPath = lastSelectedPaymentTypeIndexPath;
}

-(void)setModuleIdentifier:(NSString *)moduleIdentifier
{
    _moduleIdentifier = moduleIdentifier;
}

-(void)setStrInvoiceNo:(NSString *)strInvoiceNo
{
    _strInvoiceNo = strInvoiceNo;
}

-(void)setBillItemDetailString:(NSString *)billItemDetailString
{
    _billItemDetailString = billItemDetailString;
}

-(void)setTenderType:(NSString *)tenderType
{
    _tenderType = tenderType;
}

-(void)setIsTipAdjustmentApplicable:(NSNumber *)isTipAdjustmentApplicable
{
    _isTipAdjustmentApplicable = isTipAdjustmentApplicable;
}

-(void)setPayId:(NSNumber *)payId
{
    _payId = payId;
}

#pragma mark -
#pragma Invoice Detail

- (NSMutableArray *)generateInvoiceItemDetailWith:(NSMutableArray *)tenderReciptDataAry
{
    if (self.rmsDbController == nil) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
    }
    
    if (self.crmController == nil) {
        self.crmController = [RcrController sharedCrmController];
    }

    
    NSMutableArray * invoiceItemDetail = [[NSMutableArray alloc] init];
    for (int i=0; i<tenderReciptDataAry.count; i++)
    {
        NSMutableDictionary * tempObject = tenderReciptDataAry[i];
        NSMutableDictionary * itemsDataDict = [[NSMutableDictionary alloc] init];
        
        if([tempObject valueForKey:@"CardNo"] && [tempObject valueForKey:@"CardType"] && [tempObject valueForKey:@"Remark"]){
            
            itemsDataDict[@"CardNo"] = [tempObject valueForKey:@"CardNo"];
            itemsDataDict[@"CardType"] = [tempObject valueForKey:@"CardType"];
            itemsDataDict[@"Remark"] = [tempObject valueForKey:@"Remark"];
        }
        else if ([tempObject valueForKey:@"CardType"] && [tempObject valueForKey:@"HouseChargeAmount"] ){
            itemsDataDict[@"CardType"] = [tempObject valueForKey:@"CardType"];
        }
        
        itemsDataDict[@"ItemCode"] = [tempObject valueForKey:@"itemId"];
        
        if([tempObject valueForKey:@"Reason"]){
            itemsDataDict[@"Reason"] = [tempObject valueForKey:@"Reason"];
        }
        
        if([tempObject valueForKey:@"ReasonType"]){
            itemsDataDict[@"ReasonType"] = [tempObject valueForKey:@"ReasonType"];
        }
        
        float retailAmount = [tempObject[@"itemPrice"] floatValue];
        float variationAmount = [tempObject[@"TotalVarionCost"] floatValue] / [[tempObject valueForKey:@"itemQty"] floatValue] ;
        
        itemsDataDict[@"VariationAmount"] = [NSString stringWithFormat:@"%f", variationAmount];
        itemsDataDict[@"RetailAmount"] = [NSString stringWithFormat:@"%f", retailAmount];
        
        if (tempObject[@"InvoiceVariationdetail"])
        {
            NSMutableArray * variationDetail = tempObject[@"InvoiceVariationdetail"];
            for (int iVar = 0; iVar < variationDetail.count; iVar++)
            {
                NSMutableDictionary *variatonDict = variationDetail[iVar];
                variatonDict[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
            }
            itemsDataDict[@"InvoiceVariationdetail"] = variationDetail;
        }
        else
        {
            itemsDataDict[@"InvoiceVariationdetail"] = @"";
        }
        ///////////// DeptTypeId
        itemsDataDict[@"DeptTypeId"] = [tempObject valueForKey:@"DeptTypeId"];
        
        if (tempObject[@"guestId"])
        {
            itemsDataDict[@"GuestNo"] = [NSString stringWithFormat:@"%@", tempObject[@"guestId"]];
        }
        else
        {
            itemsDataDict[@"GuestNo"] = @"";
        }
        
        if (tempObject[@"Discount"])
        {
            NSMutableArray * discountDetail = [tempObject objectForKey:@"Discount"];
            for (int discountIndex = 0; discountIndex < [discountDetail count]; discountIndex++)
            {
                NSMutableDictionary *discountDetailDict = [discountDetail objectAtIndex:discountIndex];
                [discountDetailDict setObject:[NSString stringWithFormat:@"%d",i+1] forKey:@"RowPosition"];
            }
            [itemsDataDict setObject: discountDetail forKey:@"ItemDiscountDetail"];
        }
        else
        {
            itemsDataDict[@"ItemDiscountDetail"] = [[NSMutableArray alloc] init];
        }
        
        if (tempObject[@"PassData"])
        {
            NSMutableArray *passDataArray = [[NSMutableArray alloc]init];
            NSMutableArray *itemPassDataArray = tempObject[@"PassData"];
            for (int passDataCount = 0; passDataCount < itemPassDataArray.count; passDataCount++) {
                NSDictionary *passDictionaryAtIndex = itemPassDataArray[passDataCount];
                NSMutableDictionary *passDataDictionary = [[NSMutableDictionary alloc]init];
                passDataDictionary[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
                passDataDictionary[@"ItemCode"] = passDictionaryAtIndex[@"ItemCode"];
                passDataDictionary[@"CRDNumber"] = passDictionaryAtIndex[@"CRDNumber"];
                passDataDictionary[@"ExpirationDay"] = passDictionaryAtIndex[@"ExpirationDay"];
                passDataDictionary[@"NoOfDay"] = passDictionaryAtIndex[@"NoOfDay"];
                passDataDictionary[@"QRCode"] = passDictionaryAtIndex[@"QRCode"];
                passDataDictionary[@"CustomerId"] = passDictionaryAtIndex[@"CustomerId"];
                passDataDictionary[@"IsVoid"] = passDictionaryAtIndex[@"IsVoid"];
                passDataDictionary[@"Remark"] = passDictionaryAtIndex[@"Remark"];
                [passDataArray addObject:passDataDictionary];
            }
            itemsDataDict[@"ItemTicketDetail"] = passDataArray;
        }
        else
        {
            itemsDataDict[@"ItemTicketDetail"] = [[NSMutableArray alloc] init];
        }
        
        
        float itemAmount = retailAmount + variationAmount;
        itemsDataDict[@"ItemAmount"] = [NSString stringWithFormat:@"%f", itemAmount];
        itemsDataDict[@"ItemImage"] = [tempObject valueForKey:@"itemImage"];
        itemsDataDict[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
//        if ([[tempObject valueForKey:@"InvoiceItemNo"] length] > 0 || ![[tempObject valueForKey:@"InvoiceItemNo"] isEqualToString:@""] )
//        {
//            itemsDataDict[@"ItemInvoiceNo"] = [NSString stringWithFormat:@"%@",[tempObject valueForKey:@"InvoiceItemNo"]];
//        }
//        else
//        {
//            itemsDataDict[@"ItemInvoiceNo"] = [NSString stringWithFormat:@"%@",@""];
//        }
        
        NSMutableDictionary *gasItemData  = [[tempObject valueForKey:@"InvoicePumpCart"] mutableCopy];
        BOOL isRefund = [[[tempObject valueForKey:@"item"] valueForKey:@"isRefund"]boolValue];
        if(gasItemData!=nil && !isRefund)
        {
            if([gasItemData[@"TransactionType"] isEqualToString:@"PRE-PAY"]){
                itemsDataDict[@"RefRowPosition"] = gasItemData[@"RowPosition"];
                itemsDataDict[@"RefItemCode"] = gasItemData[@"ItemCode"];
                itemsDataDict[@"RefRegInvNo"] = gasItemData[@"RegInvNo"];
                [gasItemData removeObjectForKey:@"RegInvNo"];
                [tempObject setObject:gasItemData forKey:@"InvoicePumpCart"];
            }
            else{
                itemsDataDict[@"RefRowPosition"] = @"0";
                itemsDataDict[@"RefItemCode"] = @"0";
                itemsDataDict[@"RefRegInvNo"] = @"0";
            }
        }
        else{
            itemsDataDict[@"RefRowPosition"] = @"0";
            itemsDataDict[@"RefItemCode"] = @"0";
            itemsDataDict[@"RefRegInvNo"] = @"0";
        }
        
        
        
        itemsDataDict[@"isCheckCash"] = [tempObject valueForKey:@"item"][@"isCheckCash"];
        itemsDataDict[@"isAgeApply"] = [tempObject valueForKey:@"item"][@"isAgeApply"];
        itemsDataDict[@"CheckCashAmount"] = [tempObject valueForKey:@"item"][@"CheckCashCharge"];
        itemsDataDict[@"isDeduct"] = [tempObject valueForKey:@"item"][@"isDeduct"];
        itemsDataDict[@"isAgeApply"] = [tempObject valueForKey:@"item"][@"isAgeApply"];
        
        float totalExtraCharge=[[tempObject valueForKey:@"itemQty"] floatValue]*[[tempObject valueForKey:@"item"][@"ExtraCharge"] floatValue];
        
        NSString *ExtraCharge = [NSString stringWithFormat:@"%f",totalExtraCharge];
        
        itemsDataDict[@"ExtraCharge"] = ExtraCharge;
        itemsDataDict[@"ItemType"] = [tempObject valueForKey:@"itemType"];
        itemsDataDict[@"PackageQty"] = [tempObject valueForKey:@"PackageQty"];
        itemsDataDict[@"PackageType"] = [tempObject valueForKey:@"PackageType"];
        
        
        itemsDataDict[@"UnitQty"] = @"";
        itemsDataDict[@"UnitType"] = @"";
        itemsDataDict[@"ItemMemo"] = [tempObject valueForKey:@"Memo"];
        
        if ([tempObject valueForKey:@"EBTApplied"])
        {
            itemsDataDict[@"IsEBT"] = [tempObject valueForKey:@"EBTApplied"];
        }
        
        
        itemsDataDict[@"departId"] = [tempObject valueForKey:@"departId"];
        if (tempObject[@"SubDeptId"])
        {
            itemsDataDict[@"SubDeptId"] = [tempObject valueForKey:@"SubDeptId"];
        }
        itemsDataDict[@"Barcode"] = [tempObject valueForKey:@"Barcode"];
        
        if ([tempObject[@"isDeduct"] boolValue] == TRUE )
        {
            itemsDataDict[@"ItemCost"] = [NSString stringWithFormat:@"-%@",[tempObject valueForKey:@"ItemCost"]];
        }
        else
        {
            itemsDataDict[@"ItemCost"] = [tempObject valueForKey:@"ItemCost"];
        }
        
        itemsDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        itemsDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        
        itemsDataDict[@"ItemName"] = [tempObject valueForKey:@"itemName"];
        NSString *totalDiscount = @"0.00";
        if ([tempObject objectForKey:@"Discount"])
        {
            NSMutableArray * discountArray = [tempObject valueForKey:@"Discount"];
            float sum = [[discountArray valueForKeyPath:@"@sum.Amount"]floatValue];
            totalDiscount  = [NSString stringWithFormat:@"%f",sum];
        }
        else{
            totalDiscount  = [NSString stringWithFormat:@"%f",[[tempObject valueForKey:@"ItemDiscount"] floatValue]];
            
        }
        
        itemsDataDict[@"ItemDiscountAmount"] = totalDiscount;
        
        
        itemsDataDict[@"ItemQty"] = [tempObject valueForKey:@"itemQty"];
        itemsDataDict[@"PackageQty"] = [tempObject valueForKey:@"PackageQty"];
        itemsDataDict[@"PackageType"] = [tempObject valueForKey:@"PackageType"];
        
        if ([[tempObject valueForKey:@"ItemBasicPrice"] floatValue] < 1 && [[tempObject valueForKey:@"ItemBasicPrice"] floatValue] > 0) {
            itemsDataDict[@"ItemBasicAmount"] = [NSString stringWithFormat:@"0%@",[tempObject valueForKey:@"ItemBasicPrice"]];
        } else if ([[tempObject valueForKey:@"ItemBasicPrice"] floatValue] < 0) {
            itemsDataDict[@"ItemBasicAmount"] = [NSString stringWithFormat:@"-0%@",[[tempObject valueForKey:@"ItemBasicPrice"] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        } else {
            itemsDataDict[@"ItemBasicAmount"] = [tempObject valueForKey:@"ItemBasicPrice"];
        }
        
        float TotTax=0.0;
        
        if (([tempObject[@"itemTax"] floatValue] != 0.0)) {
            
            TotTax=[tempObject[@"itemTax"] floatValue];
            
            itemsDataDict[@"ItemTaxAmount"] = [tempObject[@"itemTax"] stringValue];
        }
        else {
            itemsDataDict[@"ItemTaxAmount"] = @"0.0";
        }
        float totalItemAmount = itemAmount *[[tempObject valueForKey:@"itemQty"] intValue] + TotTax;
        itemsDataDict[@"TotalItemAmount"] = [NSString stringWithFormat:@"%f",totalItemAmount];
        
        itemsDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        
        if (![[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"] isEqual:@""]) {
            if ([[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"] count] > 0) {
                NSMutableArray * itemTaxArray = [[NSMutableArray alloc] init];
                for (int z=0; z<[[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"] count]; z++) {
                    NSMutableDictionary * tempTaxItem = [NSMutableDictionary dictionaryWithDictionary:[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"][z]];
                    tempTaxItem[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
                    tempTaxItem[@"ItemCode"] = [tempObject valueForKey:@"itemId"];
                    tempTaxItem[@"TaxId"] = [tempTaxItem valueForKey:@"TaxId"];
                    tempTaxItem[@"TaxPercentage"] = [tempTaxItem valueForKey:@"TaxPercentage"];
                    tempTaxItem[@"TaxAmount"] = [tempTaxItem valueForKey:@"TaxAmount"];
                    NSString *strTaxAmount=[NSString stringWithFormat:@"%f",[[tempTaxItem valueForKey:@"ItemTaxAmount"] floatValue]];
                    tempTaxItem[@"ItemTaxAmount"] = strTaxAmount;
                    tempTaxItem[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
                    
                    [itemTaxArray addObject:tempTaxItem];
                }
                itemsDataDict[@"ItemTaxDetail"] = itemTaxArray;
            } else {
                itemsDataDict[@"ItemTaxDetail"] = @"";
            }
        } else {
            itemsDataDict[@"ItemTaxDetail"] = @"";
        }
//        [self checkForFuelTypeSelected:itemsDataDict];
        if([[itemsDataDict valueForKey:@"Barcode"] isEqualToString:@"GAS"] && [[itemsDataDict valueForKey:@"ItemName"] isEqualToString:@"GAS"]){
            NSMutableArray *gasDetail = [[NSMutableArray alloc] init];
            
            
            NSMutableDictionary *gasItemData  = [[tempObject valueForKey:@"InvoicePumpCart"] mutableCopy];
            gasItemData[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
            [gasDetail addObject:gasItemData];
            itemsDataDict[@"InvoicePumpCart"] = gasDetail;
            
        }
        [invoiceItemDetail addObject:itemsDataDict];
    }
    return invoiceItemDetail;
}

-(NSMutableArray *)invoicePaymentdetail
{
    NSMutableArray *paymentDetailArray = [[NSMutableArray alloc] init];
    if (self.rmsDbController == nil) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
    }
    
    if (self.crmController == nil) {
        self.crmController = [RcrController sharedCrmController];
    }

    for(int i = 0; i < self.countOfPaymentModes; i++)
    {
        if (self.amountToPay == 0)
        {
            NSInteger index = self.indexOfFirstCashType;
            NSArray *itemArrayAtIndex = [self paymentModeArrayAtIndex:index];
            PaymentModeItem *paymentModeItem  = itemArrayAtIndex.firstObject;
            NSMutableDictionary * paymentDictionary = [paymentModeItem.paymentModeDictionary mutableCopy];
            paymentDictionary[@"PayMode"] = [paymentDictionary valueForKey:@"PaymentName"];
            [paymentDictionary removeObjectForKey:@"PaymentName"];
            paymentDictionary[@"BillAmount"] = @"0.00";
            paymentDictionary[@"ReturnAmount"] = @"0";
            
            if(self.rapidCustomerLoyalty)
            {
                paymentDictionary[@"CustId"] = self.rapidCustomerLoyalty.custId;
            }
            else{
                paymentDictionary[@"CustId"] = @"0";
            }
            
            paymentDictionary[@"Email"] = @"";
            paymentDictionary[@"SurchargeAmount"] = @"0.0";
            paymentDictionary[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
            paymentDictionary[@"SignatureImage"] = @"";
            paymentDictionary[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
            paymentDictionary[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
            [paymentDetailArray addObject:paymentDictionary];
            break;
        }
        NSArray *itemArrayAtIndex = [self paymentModeArrayAtIndex:i];
        for (int j = 0; j < itemArrayAtIndex.count; j++)
        {
            PaymentModeItem *paymentModeItem  = itemArrayAtIndex[j];
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calculatedAmount =  paymentModeItem.calculatedAmount.floatValue ;
            float displayAmount = paymentModeItem.displayAmount.floatValue;
            
            if (actualAmount == 0 )
            {
                actualAmount = calculatedAmount;
                if (actualAmount == 0)
                {
                    actualAmount = displayAmount;
                }
            }
            if(actualAmount!=0)
            {
                NSMutableDictionary * paymentDictionary = [[NSMutableDictionary alloc] init];
                NSDictionary *paymentModeDictionary = paymentModeItem.paymentModeDictionary;
                
                NSString *returnAmount =  [self formatedTextForAmountWithCurrencyFormatter:-self.balanceAmount];
                returnAmount = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:returnAmount]];
                
                if ([paymentModeItem.paymentType isEqualToString:@"Cash"] && self.amountToPay > 0)
                {
                    paymentDictionary[@"ReturnAmount"] = [NSString stringWithFormat:@"%@", returnAmount];
                }
                else
                {
                    paymentDictionary[@"ReturnAmount"] = @"0";
                }
                
                if(self.rapidCustomerLoyalty)
                {
                    paymentDictionary[@"CustId"] = self.rapidCustomerLoyalty.custId;
                }
                else
                {
                    paymentDictionary[@"CustId"] = @"0";
                }
                
                
                
                paymentDictionary[@"Email"] = @"";
                paymentDictionary[@"SurchargeAmount"] = @"0.0";
                paymentDictionary[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
                
                
                paymentDictionary[@"PayMode"] = [paymentModeDictionary valueForKey:@"PaymentName"];
                paymentDictionary[@"PayId"] = [paymentModeDictionary valueForKey:@"PayId"];
                paymentDictionary[@"CardType"] = [paymentModeDictionary valueForKey:@"CardType"];
                paymentDictionary[@"AuthCode"] = [paymentModeDictionary valueForKey:@"AuthCode"];
                paymentDictionary[@"AccNo"] = [paymentModeDictionary valueForKey:@"AccNo"];
                paymentDictionary[@"TransactionNo"] = [paymentModeDictionary valueForKey:@"TransactionNo"];
                paymentDictionary[@"CardHolderName"] = [paymentModeDictionary valueForKey:@"CardHolderName"];
                paymentDictionary[@"ExpireDate"] = [paymentModeDictionary valueForKey:@"ExpireDate"];
                paymentDictionary[@"RefundTransactionNo"] = [paymentModeDictionary valueForKey:@"RefundTransactionNo"];
                paymentDictionary[@"GatewayType"] = [paymentModeDictionary valueForKey:@"GatewayType"];
                paymentDictionary[@"TransactionId"] = [paymentModeDictionary valueForKey:@"CreditTransactionId"];
                paymentDictionary[@"BatchNo"] = @"";
                
                NSString  *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
                NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
                if ([paymentDictionary[@"GatewayType"] isEqualToString:@"Pax"]) {
                    
                    NSMutableDictionary *paxAdditionalFieldDictionary = [paymentModeItem.paymentModeDictionary valueForKey:@"PaxAdditionalFields"];
                    
                    
                    
                    paxAdditionalFieldDictionary[@"PaxSerialNo"] = [NSString stringWithFormat:@"%@",self.paxSerialNumber];
                    paxAdditionalFieldDictionary[@"BuildVersion"] = [NSString stringWithFormat:@"%@",buildVersion];
                    paxAdditionalFieldDictionary[@"AppVersion"] = [NSString stringWithFormat:@"%@",appVersion];
                    
                    paymentDictionary[@"GatewayResponse"] = [NSString stringWithFormat:@"%@",[self.rmsDbController jsonStringFromObject:paxAdditionalFieldDictionary]];
                    if ([[paxAdditionalFieldDictionary objectForKey:@"SN"] isBlank] == NO)
                    {
                        paymentDictionary[@"PaxSerialNo"] = [NSString stringWithFormat:@"%@",[paxAdditionalFieldDictionary valueForKey:@"SN"]];
                        
                    }
                    else
                    {
                        paymentDictionary[@"PaxSerialNo"] = [NSString stringWithFormat:@"%@",self.paxSerialNumber];
                    }
                    paymentDictionary[@"BatchNo"] = paxAdditionalFieldDictionary[@"BatchNo"];
                }
                else
                {
                    NSMutableDictionary *bridgepayAdditionalFields = [paymentModeItem.paymentModeDictionary valueForKey:@"BridgepayAdditionalFields"];
                    
                    bridgepayAdditionalFields[@"BuildVersion"] = [NSString stringWithFormat:@"%@",buildVersion];
                    bridgepayAdditionalFields[@"AppVersion"] = [NSString stringWithFormat:@"%@",appVersion];
                    
                    paymentDictionary[@"GatewayResponse"] = [NSString stringWithFormat:@"%@",bridgepayAdditionalFields];
                }
                
                if ([[paymentModeDictionary valueForKey:@"SignatureImage"] isKindOfClass:[UIImage class]]) {
                    if (![paymentModeItem.paymentType isEqualToString:@"Cash"])
                    {
                        UIImage *customerImage = [paymentModeDictionary valueForKey:@"SignatureImage"];
                        NSData *imageData = UIImagePNGRepresentation(customerImage);
                        if (imageData) {
                            paymentDictionary[@"SignatureImage"] = [imageData base64EncodedStringWithOptions:0];
                        }
                        else
                        {
                            paymentDictionary[@"SignatureImage"] = @"";
                        }
                    }
                    else
                    {
                        paymentDictionary[@"SignatureImage"] = @"";
                    }
                }
                else
                {
                    paymentDictionary[@"SignatureImage"] = @"";
                }
                
                paymentDictionary[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
                paymentDictionary[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
                
                paymentDictionary[@"BillAmount"] = [NSString stringWithFormat:@"%.2f",actualAmount];
                
                
                
                CGFloat lastIndexTipAmount = 0.00;
                if (self.lastSelectedPaymentTypeIndexPath.section == i && self.lastSelectedPaymentTypeIndexPath.row == j) {
                    lastIndexTipAmount = self.tipAmount;
                }
                CGFloat customerDisplayTipAmount = 0.00;
                if (paymentModeItem.isCustomerDiplayTipAdjusted == TRUE) {
                    customerDisplayTipAmount = paymentModeItem.customerDisplayTipAmount.floatValue;
                }
                
                actualAmount = actualAmount - lastIndexTipAmount - customerDisplayTipAmount;
                paymentDictionary[@"BillAmount"] = [NSString stringWithFormat:@"%.2f",actualAmount];
                paymentDictionary[@"TipsAmount"] = [NSString stringWithFormat:@"%.2f",lastIndexTipAmount + customerDisplayTipAmount];
                
                [paymentDetailArray addObject:paymentDictionary];
            }
        }
    }
    return paymentDetailArray;
    
}


- (NSMutableArray *)tenderInvoiceMst
{
    NSMutableArray * invoiceMst = [[NSMutableArray alloc] init];
    if (self.rmsDbController == nil) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
    }
    
    if (self.crmController == nil) {
        self.crmController = [RcrController sharedCrmController];
    }

    NSMutableDictionary * invoiceDataDict = [[NSMutableDictionary alloc] init];
    
    
    invoiceDataDict[@"InvoiceNo"] = @"0";
    
    if (self.crmController.isbillOrderFromRecall == TRUE && self.crmController.isbillOrderFromRecallOffline == FALSE)
    {
        if (self.crmController.recallInvoiceId != nil) {
            invoiceDataDict[@"InvoiceholdId"] = self.crmController.recallInvoiceId;
        }
        else
        {
            invoiceDataDict[@"InvoiceholdId"] = @"0";
        }
    }
    else
    {
        invoiceDataDict[@"InvoiceholdId"] = @"0";
    }
    
    if(self.rapidCustomerLoyalty)
    {
        invoiceDataDict[@"CustId"] = self.rapidCustomerLoyalty.custId;
    }
    else{
        invoiceDataDict[@"CustId"] = @"0";
    }
    invoiceDataDict[@"IsOffline"] = @"0";
    invoiceDataDict[@"Remarks"] = @"";
    
    invoiceDataDict[@"RegisterInvNo"] = self.strInvoiceNo;
    
    
    invoiceDataDict[@"DiscountAmount"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceDiscount"]] ];
    invoiceDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    invoiceDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    invoiceDataDict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    invoiceDataDict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    
    
    invoiceDataDict[@"SubTotal"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceSubTotal"]] ];
    
    
    invoiceDataDict[@"TaxAmount"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceTax"]] ];
    
    //
    invoiceDataDict[@"BillAmount"] = [self formatedTextForAmount:self.billAmount];
    invoiceDataDict[@"CheckCashAmount"] = [NSString stringWithFormat:@"%f",self.checkcashAmount];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:date];
    invoiceDataDict[@"Datetime"] = strDate;
    
    invoiceDataDict[@"NoOfGuest"] = [NSString stringWithFormat:@"%@",self.numberOfGuest];
    invoiceDataDict[@"TableNo"] = [NSString stringWithFormat:@"%@",self.tableNo];

    
    [invoiceMst addObject:invoiceDataDict];
    
    return invoiceMst;
}



-(NSString *)formatedTextForAmountWithCurrencyFormatter:(CGFloat)amount {
    
    if (amount <= 0.00 && amount > -0.009) {
        amount = 0.00;
    }
    NSNumber *amountNumber = @(amount);
    NSString * billAmount = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:amountNumber]];
    return billAmount;
}

-(CGFloat)RemoveSymbolFromString:(NSString *)stringToRemoveSymbol
{
    NSString *sAmount=[stringToRemoveSymbol stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    CGFloat fsAmount = [[self.crmController.currencyFormatter numberFromString:sAmount] floatValue];
    return fsAmount;
}

- (NSString *)formatedTextForAmount:(CGFloat)amount {
    NSString *billAmount = [NSString stringWithFormat:@"%.2f",amount];
    return billAmount;
}


@end
