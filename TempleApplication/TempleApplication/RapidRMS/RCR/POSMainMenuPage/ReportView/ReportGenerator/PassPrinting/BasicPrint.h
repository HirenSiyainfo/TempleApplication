//
//  BasicPrint.h
//  RapidRMS
//
//  Created by Siya7 on 6/6/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintJob.h"
#import "RmsDbController.h"

typedef NS_ENUM(NSInteger, ReportField) {
    ReportFielShiftOpenBy = 200,
    ReportFieldName,
    ReportFieldRegister,
    ReportFieldCentralizeRegister,
    ReportFieldDateTime,
    ReportFieldStartDateTime,
    ReportFieldEndDateTime,
    ReportFieldBatchNo,
    ReportFieldShiftNo,
    ReportFieldGrossSales,
    ReportFieldTaxes,
    ReportFieldNetSales,
    ReportFieldDeposit,
    ReportFieldDailySales,
    ReportFieldInsideGasSales,
    ReportFieldOutSideGasSales,
    ReportFieldOpeningAmount,
    ReportFieldSales,
    ReportFieldReturn,
    ReportFieldSection3Total,
    ReportFieldSection3Taxes,
    ReportFieldSurCharge,
    ReportFieldTips,
    ReportFieldAllTips,
    ReportFieldAllTipsTotal,
    ReportFieldGiftCard,
    ReportFieldMoneyOrder,
    
    ReportFieldGrossFuelSales,
    ReportFieldFuelRefund,
    ReportFieldNetFuelSales,

    ReportFieldAllTaxes,
    
    ReportFieldAllTaxesDetails,

    ReportFieldMerchandiseSales,
    ReportFieldMerchandiseReturn,
    ReportFieldMerchandiseDiscount,
    
    ReportFieldLotterySales,
    ReportFieldLotteryProfit,
    ReportFieldLotteryReturn,
    ReportFieldLotteryDiscount,
    ReportFieldLotteryPayout,
    
    ReportFieldGasSales,
    ReportFieldGasProfit,
    ReportFieldGasReturn,
    ReportFieldGasDiscount,
    ReportFieldGasQty,
    
    ReportFieldMoneyOrderSales,
    ReportFieldMoneyOrderSalesFee,
    ReportFieldMoneyOrderReturn,
    ReportFieldMoneyOrderDiscount,
    
    ReportFieldGiftCardSales,
    ReportFieldGiftCardFee,
    ReportFieldGiftCardReturn,
    ReportFieldGiftCardDiscount,
    
    ReportFieldCheckCashSales,
    ReportFieldCheckCashFee,
    ReportFieldCheckCashReturn,
    ReportFieldCheckCashDiscount,
    
    ReportFieldPayoutSales,
    ReportFieldPayoutReturn,
    ReportFieldPayoutDiscount,
    
    ReportFieldHouseChargeSales,
    ReportFieldHouseChargeReturn,
    ReportFieldHouseChargeDiscount,
    
    ReportFieldOtherSales,
    ReportFieldOtherReturn,
    ReportFieldOtherDiscount,
    
    ReportFieldPetroNetFuelSales,
    
    ReportFieldDropAmount,
    ReportFieldPaidOut,
    ReportFieldClosingAmount,
    
    ReportFieldCreditCardTotal,
    ReportFieldStandAloneTotal,
    ReportFieldChequeTotal,
    ReportFieldGiftCardTotal,
    
    ReportFieldOverShort,
    ReportFieldGCLiabiality,

    ReportFieldInventory,
    
    ReportFieldCheckCash,
    ReportFieldDiscount,
    ReportFieldNonTaxSales,
    ReportFieldCostofGoods,
    ReportFieldMargin,
    ReportFieldProfit,
    ReportFieldNoSales,
    ReportFieldVoidTrans,
    ReportFieldCancelTrans,
    ReportFieldPriceChangeCount,
    ReportFieldLayaway,
    
    ReportFieldLineItemVoid,
    ReportFieldCustomer,
    ReportFieldAvgTicket,
    ReportFieldTaxesSection,
    
    ReportFieldPayoutBreakup,
    ReportFieldPayoutTotal,
    
    ReportFieldDiscountSection,
    ReportFieldCustomizedDiscount,
    ReportFieldManualDiscount,
    ReportFieldPreDefinedDiscount,
    
    ReportFieldGiftCardPreviousBalance,
    ReportFieldLoadGiftCard,
    ReportFieldRedeemGiftCard,
    
    ReportFieldTenderTypeXCashOther,
    
    ReportFieldTenderType,
    ReportFieldTenderTips,
    ReportFieldCardType,
    ReportFieldCardTypeOutSide,
    ReportFieldFuelSummery,
    ReportFieldPumpSummery,
    ReportFieldDepartment,
    ReportFieldNonMerchandiseDepartment,
    ReportFieldPayOutDepartment,
    ReportFieldHourlySales,
    ReportFieldStoreName,
    ReportFieldAddressLine1,
    ReportFieldAddressLine2,
    ReportFieldReportDay,
    ReportFieldReportName,

    ReportFieldGroup20AGrossFuelSales,
    ReportFieldGroup20AOther,
    ReportFieldGroup20AFuelRefund,
    ReportFieldGroup20ANetFuelSales,
    
    ReportFieldGroup20FuelType,
    ReportFieldGroup20Other,
    
    ReportFieldGroup21FuelType,
    ReportFieldGroup21Other,
    
    ReportFieldGroup22FuelInventory,
    
    ReportFieldGroup23ATotalFuelTrnx,
    ReportFieldGroup23AOtherTrnx,
    ReportFieldGroup23AVoidFuelTrnx,
    ReportFieldGroup23ALineItemDelete,
    ReportFieldGroup23ACancelTrnx,
    ReportFieldGroup23APriceChanges,
    ReportFieldGroup23ADriveOffs,
    ReportFieldGroup23AFuelType,
    
    ReportFieldGroup23BFuelSalesbyPump,
    
    ReportFieldGroup24HourlyGasSales,
    ReportFieldVersionFooter,
};

typedef NS_ENUM(NSInteger, ReportSection) {
    ReportSectionReportHeader = 500,
    ReportSectionHeader,
    ReportSectionSales,
    ReportSectionDailySales,
    ReportSectionPetroSales,
    ReportSection3,
    ReportSectionAllTaxes,
    ReportSectionAllDetails,
    ReportSectionOpeningAmount,
    ReportSectionNoneSales,
    ReportSectionMerchandiseSales,
    ReportSectionLotterySales,
    ReportSectionGasSales,
    ReportSectionMoneyOrder,
    ReportSectionGiftCardSales,
    ReportSectionCheckCash,
    ReportSectionVendorPayout,
    ReportSectionHouseCharge,
    ReportSectionSalesOther,
    ReportSectionAllSalesTotal,
    ReportSectionGroup5A,
    ReportSection4,
    ReportSectionOverShort,
    ReportSection6,
    ReportSection7,
    ReportSectionCustomer,
    ReportSectionDiscount,
    ReportSectionTaxes,
    ReportSectionPaymentMode,
    ReportSectionTenderTips,
    ReportSectionGiftCard,
    ReportSectionCardType,
    ReportSectionCardTypeOutSide,
    ReportSectionCardFuelSummery,
    ReportSectionPumpSummery,
    ReportSectionDepartment,
    ReportSectionNonMerchandiseDepartment,
    ReportSectionPayout,
    ReportSectionHourlySales,
    ReportSectionGroup20A,
    ReportSectionGroup20,
    ReportSectionGroup21,
    ReportSectionGroup22,
    ReportSectionGroup23A,
    ReportSectionGroup23B,
    ReportSectionGroup24,
    ReportSectionReportFooter,
};

//typedef NS_ENUM(NSUInteger, RCAlignment) {
//    RCAlignmentLeft,
//    RCAlignmentRight,
//    RCAlignmentCenter,
//};

@interface BasicPrint : NSObject <UIWebViewDelegate>
{
    NSArray *_sections;
    NSArray *_fields; // array of arrays
    
    NSInteger columnWidths[6];
    NSInteger columnAlignments[6];
    
    NSMutableArray *mainReportArray;
    NSDictionary *_reportData;
    NSString *_reportName;
    BOOL _isTipSetting;
    PrintJob *_printJob;
    NSInteger _printerWidth;
    UIWebView *webViewForTCPPrinting;
    NSNumberFormatter *currencyFormatter;
    RmsDbController *_rmsDbController;
}

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *generateHtml;

- (NSInteger)sectionAtSectionIndex:(NSInteger)sectionIndex;
- (void)configurePrint:(NSString *)portSettings portName:(NSString *)portName withDelegate:(id)delegate;
- (void)concludePrint;

- (void)printReportWithPort:(NSString*)portName portSettings:(NSString*)portSettings withDelegate:(id)delegate;
- (void)_printReportWithPort:(NSString*)portName portSettings:(NSString*)portSettings  withDelegate:(id)delegate;

- (NSString*)stringFromDate:(NSString*)inputDate inputFormat:(NSString*)inputFormat outputFormat:(NSString*)outputFormat;
- (NSString*)stringFromDate:(NSDate*)date format:(NSString*)format;
- (NSString*)percentageFormattedAmount:(NSNumber*)amount;
- (NSString*)currencyFormattedAmount:(NSNumber*)amount;
- (NSString*)currencyFormattedAmountForKey:(NSString*)amountKey fromDictionary:(NSDictionary*)dictionary;
- (NSDate*)jsonStringToNSDate:(NSString*)string;
- (void)printCommandForSectionAtIndex:(NSInteger)sectionIndex;
- (void)printCommandForFieldAtIndex:(NSInteger)fieldIndex sectionIndex:(NSInteger)sectionIndex;
- (void)printHeaderForSection:(NSInteger)section;
- (void)printFooterForSection:(NSInteger)section;
- (void)printFieldWithId:(NSInteger)fieldId;


@end


