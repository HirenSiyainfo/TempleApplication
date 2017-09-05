//
//  BasicReport.h
//  HtmlSS
//
//  Created by Siya Infotech on 20/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintJob.h"
#import "RmsDbController.h"
#import "BasicPrint.h"

#ifdef DEBUG
// Should be defined only for DEBUG
#define PRINT_A_FEW
#endif

typedef NS_ENUM(NSInteger, ReportDataKey) {
    ReportDataKeyBranchName,
    ReportDataKeyAddress1,
    ReportDataKeyAddress2,
    ReportDataKeyCity,
    ReportDataKeyState,
    ReportDataKeyZipCode,
};

@interface BasicReport : BasicPrint  {
    NSArray *reportDataKeys;
}

- (NSString *)htmlForSectionAtIndex:(NSInteger)sectionIndex;
- (NSString *)htmlForFieldAtIndex:(NSInteger)fieldIndex sectionIndex:(NSInteger)sectionIndex;

- (NSString *)headerHtmlForSectionAtIndex:(NSInteger)sectionId;
- (NSString *)footerHtmlForSectionAtIndex:(NSInteger)sectionId;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForCommonHeader;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForDay;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForShiftOpenBy;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForName;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForRegister;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForDateTime;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForStartDateTime;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForEndDateTime;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForBatchNo;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForShiftNo;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForGrossSales;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForTaxes;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForNetSales;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForOpeningAmount;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForSales;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForReturn;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForSection3Total;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForSection3Taxes ;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForSurCharge;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForTips;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForGiftCard;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForMoneyOrder;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForGrossFuelSales;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForFuelRefund;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForNetFuelSales;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForDropAmount;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForPaidOut;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForClosingAmount;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForTenderCardData;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForOverShort;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForGCLiabiality;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForCheckCash;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForDiscount;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForNonTaxSales;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForCostofGoods;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForMargin;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForProfit;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForNoSales;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForVoidTrans;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForLineItemVoid;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForCustomer;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForAvgTicket;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForDiscountSection;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForTaxesSection;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForTenderType;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForGiftCardPreviousBalance;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForLoadGiftCard;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForRedeemGiftCard;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForTenderTips;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForCardType;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForDepartment;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForPayOutDepartment;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlForHourlySales;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionHeader;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionSales;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSection3;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSection4;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionOverShort;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSection6;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionCustomer;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionDiscount;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionTaxes;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionPaymentMode;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionTenderTips;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionGiftCard;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionCardType;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionDepartment;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForSectionPayout;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlHeaderForHourlySales;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionHeader;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionSales;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSection3;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSection4;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionOverShort;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSection6;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionCustomer;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionDiscount;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionTaxes;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionPaymentMode;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionTenderTips;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionGiftCard;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionCardType;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionDepartment;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForSectionPayout;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *htmlFooterForHourlySales;

- (NSString *)htmlForkey:(NSString *)key value:(NSString *)value;

-(NSString *)dayFromWeekDay:(NSInteger )weekday;

-(NSDate*)jsonStringToNSDate:(NSString*)string;

- (double)calculateSum3WithTenderArray:(NSArray *)tenderCardData withRptMain:(NSDictionary *)reportData;
- (double)calculateSum2withRptMain:(NSDictionary *)reportData;

@property (NS_NONATOMIC_IOSONLY, getter=getCurrentDateAndTime, readonly, copy) NSString *currentDateAndTime;
- (NSString *)dateFromDictionary:(NSDictionary *)dictionary timeKey:(NSString *)timeKey dateKey:(NSString *)dateKey;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *customizedDiscount;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *manualDiscount;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *preDefinedDiscount;

@end
