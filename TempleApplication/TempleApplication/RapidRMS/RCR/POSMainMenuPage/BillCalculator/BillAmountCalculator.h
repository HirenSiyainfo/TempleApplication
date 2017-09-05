//
//  BillAmountCalculator.h
//  RapidRMS
//
//  Created by Siya Infotech on 16/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item+Dictionary.h"

//@class UpdateManager;


typedef NS_ENUM(NSInteger, Discount) {
    QUANTITY,
    CASE_PACK,
    SWIPE_PRICE_CHANGE,
   	ITEM_WISE_PER_SALES,
    ITEM_WISE_D_SALES,
   	BILL_WISE_PER_SALES,
    BILL_WISE_D_SALES,
   	ITEM_WISE_PER_MANUAL,
    ITEM_WISE_D_MANUAL,
   	BILL_WISE_PER_MANUAL,
    BILL_WISE_D_MANUAL,
};


typedef NS_ENUM(NSInteger, BillWiseDiscountType) {
    BillWiseDiscountTypeNone,
    BillWiseDiscountTypePercentage,
    BillWiseDiscountTypeAmount,
};



@interface BillAmountCalculator : NSObject
@property (nonatomic, strong) NSNumber *billWiseDiscount;
@property (nonatomic) BillWiseDiscountType billWiseDiscountType;
//@property (nonatomic, getter = isBillWiseDiscountApplied) BOOL billWiseDiscountApplied;
@property (nonatomic, assign) BOOL isEbtApplied;
@property (nonatomic, assign) BOOL isEBTApplicaleForBill;



@property (nonatomic, getter = isItemRefund) BOOL itemRefund;
@property (nonatomic) float fCheckCashCharge;
@property (nonatomic) BOOL isCheckCash;

@property (nonatomic) float fExtraChargeAmt;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSMutableArray *variationDetail;
@property (nonatomic,strong)NSString *memoMessage;
@property (nonatomic,strong)NSString *packageType;
@property (nonatomic,strong)NSNumber *packageQty;


- (instancetype)initWithManageObjectcontext:(NSManagedObjectContext*)moc NS_DESIGNATED_INITIALIZER;
- (void)recalculateBillAmounts:(NSInteger)itemCodeId isPriceEdited:(BOOL)isPriceEdited;
- (void)calculateBillAmountsWithBillReceiptArray:(NSMutableArray*)billReceiptArray;

-(void)calculateItemAsPosSeprateCalculationWithBillDetail :(NSMutableArray*)billReceiptArray;



-(NSMutableDictionary *)setItemDetailWithBillEntry :(NSMutableDictionary *)billentryDictionary withItem:(Item *)anItem WithItemPrice:(NSString *)price WithItemQty:(NSString *)qty WithItemImage:(NSString *)itemImage withItemBarcode:(NSString *)itemBarcode withItemUnitType:(NSString *)itemUnitType withItemUnitQty:(NSString *)itemUnitQty;
-(NSMutableArray *)fetchTaxDetailForItem:(Item *)anItem;



@end
