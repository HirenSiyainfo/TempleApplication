//
//  BasicReport.m
//  HtmlSS
//
//  Created by Siya Infotech on 20/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "BasicReport.h"
#import "ReportConstants.h"
#import "RasterPrintJob.h"

@interface BasicReport () {
    
}

@end

@implementation BasicReport

- (instancetype)init {
    self = [super init];
    if (self) {
        _sections = @[];
        _fields = @[];
        _rmsDbController = [RmsDbController sharedRmsDbController];
        currencyFormatter = [[NSNumberFormatter alloc] init];
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        currencyFormatter.maximumFractionDigits = 2;
        _printerWidth = 48;
        reportDataKeys = @[
                            @"BranchName",
                            @"Address1",
                            @"Address2",
                            @"City",
                            @"State",
                            @"ZipCode",
                            ];
    }
    return self;
}

- (NSString *)addHtmlHeaderBeforString:(NSString *)string
{
    NSMutableString *htmlWithHeader = [[NSMutableString alloc] init];
    [htmlWithHeader appendString:self.htmlForCommonHeader];
    [htmlWithHeader appendString:string];
    return htmlWithHeader;
}

- (NSString *)addHtmlCardDataAfterString:(NSString *)string
{
    NSMutableString *htmlWithCardData = [[NSMutableString alloc] init];
    [htmlWithCardData appendString:string];
    [htmlWithCardData appendString:self.htmlForTenderCardData];
    return htmlWithCardData;
}
- (NSString *)htmlForFieldId:(ReportField)fieldId
{
    NSString *htmlForFieldId;
    switch (fieldId) {
        case ReportFieldReportDay:
            htmlForFieldId = [self addHtmlHeaderBeforString:self.htmlForDay];
            break;
        case ReportFielShiftOpenBy:
            htmlForFieldId = self.htmlForShiftOpenBy;
            break;
        case ReportFieldName:
            htmlForFieldId = self.htmlForName;
            break;
        case ReportFieldRegister:
            htmlForFieldId = self.htmlForRegister;
            break;
        case ReportFieldCentralizeRegister:
            htmlForFieldId = self.htmlForCentralizeRegister;
            break;
        case ReportFieldDateTime:
            htmlForFieldId = self.htmlForDateTime;
            break;
        case ReportFieldStartDateTime:
            htmlForFieldId = self.htmlForStartDateTime;
            break;
        case ReportFieldEndDateTime:
            htmlForFieldId = self.htmlForEndDateTime;
            break;
        case ReportFieldBatchNo:
            htmlForFieldId = self.htmlForBatchNo;
            break;
        case ReportFieldShiftNo:
            htmlForFieldId = self.htmlForShiftNo;
            break;
        case ReportFieldGrossSales:
            htmlForFieldId = self.htmlForGrossSales;
            break;
        case ReportFieldTaxes:
            htmlForFieldId = self.htmlForTaxes;
            break;
        case ReportFieldNetSales:
            htmlForFieldId = self.htmlForNetSales;
            break;
        case ReportFieldDeposit:
            htmlForFieldId = self.htmlForDeposit;
            break;
        case ReportFieldPetroNetFuelSales:
            htmlForFieldId = [self htmlForPetroNetFuelSales];
            break;
        case ReportFieldOpeningAmount:
            htmlForFieldId = self.htmlForOpeningAmount;
            break;
        case ReportFieldDailySales:
            htmlForFieldId = self.htmlForDailySales;
            break;
        case ReportFieldInsideGasSales:
            htmlForFieldId = self.htmlForDailyInsideGasSales;
            break;
        case ReportFieldOutSideGasSales:
            htmlForFieldId = self.htmlForDailyOutSideGasSales;
            break;
        case ReportFieldGasSales:
            htmlForFieldId = self.htmlForGasSales;
            break;
        case ReportFieldGasProfit:
            htmlForFieldId = self.htmlForGasProfit;
            break;
        case ReportFieldSales:
            htmlForFieldId = self.htmlForSales;
            break;
        case ReportFieldReturn:
            htmlForFieldId = self.htmlForReturn;
            break;
        case ReportFieldSection3Total:
            htmlForFieldId = self.htmlForSection3Total;
            break;
        case ReportFieldSection3Taxes:
            htmlForFieldId = self.htmlForSection3Taxes;
            break;
        case ReportFieldSurCharge:
            htmlForFieldId = self.htmlForSurCharge;
            break;
        case ReportFieldTips:
            htmlForFieldId = self.htmlForTips;
            break;
        case ReportFieldAllTips:
            htmlForFieldId = self.htmlForAllTips;
            break;
        case ReportFieldAllTipsTotal:
            htmlForFieldId = self.htmlForAllTipsTotal;
            break;
        case ReportFieldGiftCard:
            htmlForFieldId = self.htmlForGiftCard;
            break;
        case ReportFieldMoneyOrder:
            htmlForFieldId = self.htmlForMoneyOrder;
            break;
        case ReportFieldGrossFuelSales:
            htmlForFieldId = self.htmlForGrossFuelSales;
            break;
        case ReportFieldFuelRefund:
            htmlForFieldId = self.htmlForFuelRefund;
            break;
        case ReportFieldNetFuelSales:
            htmlForFieldId = self.htmlForNetFuelSales;
            break;
        case ReportFieldMerchandiseSales:
            htmlForFieldId = self.htmlForMerchandiseSales;
            break;
        case ReportFieldMerchandiseReturn:
            htmlForFieldId = self.htmlForMerchandiseReturn;
            break;
        case ReportFieldMerchandiseDiscount:
            htmlForFieldId = self.htmlForMerchandiseDiscount;
            break;
        case ReportFieldAllTaxes:
            htmlForFieldId = self.htmlForAllTaxesField;
            break;
        case ReportFieldAllTaxesDetails:
            htmlForFieldId = self.htmlForAllTaxesFieldDetails;
            break;
        case ReportFieldLotterySales:
            htmlForFieldId = self.htmlForLotterySales;
            break;
        case ReportFieldLotteryProfit:
            htmlForFieldId = self.htmlForLotteryProfit;
            break;
        case ReportFieldLotteryReturn:
            htmlForFieldId = self.htmlForLotteryReturn;
            break;
        case ReportFieldLotteryDiscount:
            htmlForFieldId = self.htmlForLotteryDiscount;
            break;
        case ReportFieldLotteryPayout:
            htmlForFieldId = self.htmlForLotteryPayout;
            break;
        case ReportFieldGasReturn:
            htmlForFieldId = self.htmlForGasReturn;
            break;
        case ReportFieldGasDiscount:
            htmlForFieldId = self.htmlForGasDiscount;
            break;
        case ReportFieldGasQty:
            htmlForFieldId = self.htmlForGasQty;
            break;
        case ReportFieldMoneyOrderSales:
            htmlForFieldId = self.htmlForMoneyOrderSales;
            break;
        case ReportFieldMoneyOrderSalesFee:
            htmlForFieldId = self.htmlForMoneyOrderSalesFee;
            break;
        case ReportFieldMoneyOrderReturn:
            htmlForFieldId = self.htmlForMoneyOrderReturn;
            break;
        case ReportFieldMoneyOrderDiscount:
            htmlForFieldId = self.htmlForMoneyOrderDiscount;
            break;
            
        case ReportFieldGiftCardSales:
            htmlForFieldId = self.htmlForGiftCardSales;
            break;
        case ReportFieldGiftCardFee:
            htmlForFieldId = self.htmlForGiftCardFee;
            break;
        case ReportFieldGiftCardReturn:
            htmlForFieldId = self.htmlForGiftCardReturn;
            break;
        case ReportFieldGiftCardDiscount:
            htmlForFieldId = self.htmlForGiftCardDiscount;
            break;
        
        case ReportFieldCheckCashSales:
            htmlForFieldId = self.htmlForCheckCashSales;
            break;
        case ReportFieldCheckCashFee:
            htmlForFieldId = self.htmlForCheckCashFee;
            break;
        case ReportFieldCheckCashReturn:
            htmlForFieldId = self.htmlForCheckCashReturn;
            break;
        case ReportFieldCheckCashDiscount:
            htmlForFieldId = self.htmlForCheckCashDiscount;
            break;

        case ReportFieldPayoutSales:
            htmlForFieldId = self.htmlForPayoutSales;
            break;
        case ReportFieldPayoutReturn:
            htmlForFieldId = self.htmlForPayoutReturn;
            break;
        case ReportFieldPayoutDiscount:
            htmlForFieldId = self.htmlForPayoutDiscount;
            break;
            
        case ReportFieldHouseChargeSales:
            htmlForFieldId = self.htmlForHouseChargeSales;
            break;
        case ReportFieldHouseChargeReturn:
            htmlForFieldId = self.htmlForHouseChargeReturn;
            break;
        case ReportFieldHouseChargeDiscount:
            htmlForFieldId = self.htmlForHouseChargeDiscount;
            break;
        case ReportFieldOtherSales:
            htmlForFieldId = self.htmlForOtherSales;
            break;
        case ReportFieldOtherReturn:
            htmlForFieldId = self.htmlForOtherReturn;
            break;
        case ReportFieldOtherDiscount:
            htmlForFieldId = self.htmlForOtherDiscount;
            break;

        case ReportFieldDropAmount:
            htmlForFieldId = self.htmlForDropAmount;
            break;
        case ReportFieldPaidOut:
            htmlForFieldId = self.htmlForPaidOut;
            break;
        case ReportFieldClosingAmount:
            htmlForFieldId = [self addHtmlCardDataAfterString:self.htmlForClosingAmount];
            break;
        case ReportFieldOverShort:
            htmlForFieldId = self.htmlForOverShort;
            break;
        case ReportFieldGCLiabiality:
            htmlForFieldId = self.htmlForGCLiabiality;
            break;
        case ReportFieldInventory:
            htmlForFieldId = self.htmlForInventory;
            break;
        case ReportFieldCostofGoods:
            htmlForFieldId = self.htmlForCostofGoods;
            break;
        case ReportFieldCheckCash:
            htmlForFieldId = self.htmlForCheckCash;
            break;
        case ReportFieldDiscount:
            htmlForFieldId = self.htmlForDiscount;
            break;
        case ReportFieldNonTaxSales:
            htmlForFieldId = self.htmlForNonTaxSales;
            break;

        case ReportFieldMargin:
            htmlForFieldId = self.htmlForMargin;
            break;
        case ReportFieldProfit:
            htmlForFieldId = self.htmlForProfit;
            break;
        case ReportFieldNoSales:
            htmlForFieldId = self.htmlForNoSales;
            break;
        case ReportFieldVoidTrans:
            htmlForFieldId = self.htmlForVoidTrans;
            break;
        case ReportFieldLayaway:
            htmlForFieldId = self.htmlForLayaway;
            break;
            
        case ReportFieldPriceChangeCount:
            htmlForFieldId = self.htmlForPriceChangeCount;
            break;

        case ReportFieldCancelTrans:
            htmlForFieldId = self.htmlForCancelTrans;
            break;

        case ReportFieldLineItemVoid:
            htmlForFieldId = self.htmlForLineItemVoid;
            break;
        case ReportFieldCustomer:
            htmlForFieldId = self.htmlForCustomer;
            break;
        case ReportFieldAvgTicket:
            htmlForFieldId = self.htmlForAvgTicket;
            break;
        case ReportFieldDiscountSection:
            htmlForFieldId = self.htmlForDiscountSection;
            break;
        case ReportFieldTaxesSection:
            htmlForFieldId = self.htmlForTaxesSection;
            break;
        case ReportFieldTenderType:
            htmlForFieldId = self.htmlForTenderType;
            break;
        case ReportFieldGiftCardPreviousBalance:
            htmlForFieldId = self.htmlForGiftCardPreviousBalance;
            break;
        case ReportFieldLoadGiftCard:
            htmlForFieldId = self.htmlForLoadGiftCard;
            break;
        case ReportFieldRedeemGiftCard:
            htmlForFieldId = self.htmlForRedeemGiftCard;
            break;

        case ReportFieldTenderTips:
            htmlForFieldId = self.htmlForTenderTips;
            break;
        case ReportFieldCardType:
            htmlForFieldId = self.htmlForCardType;
            break;
        case ReportFieldCardTypeOutSide:
            htmlForFieldId = self.htmlForCardTypeOutSide;
            break;
        case ReportFieldFuelSummery:
            htmlForFieldId = self.htmlForGasFuelSummery;
            break;
        case ReportFieldPumpSummery:
            htmlForFieldId = self.htmlForGasPumpSummery;
            break;
        case ReportFieldDepartment:
            htmlForFieldId = self.htmlForDepartment;
            break;
        case ReportFieldNonMerchandiseDepartment:
            htmlForFieldId = self.htmlForNonMerchandiseDepartment;
            break;
        case ReportFieldPayOutDepartment:
            htmlForFieldId = self.htmlForPayOutDepartment;
            break;
        case ReportFieldHourlySales:
            htmlForFieldId = self.htmlForHourlySales;
            break;
        case ReportFieldGroup20AGrossFuelSales:
            htmlForFieldId = [self htmlForGroup20ASection];
            break;
        case ReportFieldGroup20FuelType:
            htmlForFieldId = [self htmlForGroup20Section];
            break;
        case ReportFieldGroup21FuelType:
            htmlForFieldId = [self htmlForGroup21Section];
            break;
        case ReportFieldGroup22FuelInventory:
            htmlForFieldId = [self htmlForGroup22Section];
            break;
        case ReportFieldGroup23ATotalFuelTrnx:
            htmlForFieldId = [self htmlForGroup23ASection];
            break;
        case ReportFieldGroup23BFuelSalesbyPump:
            htmlForFieldId = [self htmlForGroup23BSection];
            break;
        case ReportFieldGroup24HourlyGasSales:
            htmlForFieldId = [self htmlForGroup24Section];
            break;
        case ReportFieldVersionFooter:
            htmlForFieldId = [self htmlForVersion];
            break;
            
        default:
            break;
    }
    return htmlForFieldId;
}

- (NSString *)htmlForSectionHeader:(ReportSection)sectionId
{
    NSString *htmlForSection;
    switch (sectionId) {
        case ReportSectionHeader:
            htmlForSection = self.htmlHeaderForSectionHeader;
            break;
        case ReportSectionDailySales:
            htmlForSection = [self htmlHeaderForDailySales];
            break;
        case ReportSectionSales:
            htmlForSection = self.htmlHeaderForSectionSales;
            break;
        case ReportSectionPetroSales:
            htmlForSection = [self htmlHeaderForSectionPetroSales];
            break;
        case ReportSection3:
            htmlForSection = self.htmlHeaderForSection3;
            break;
        case ReportSectionOpeningAmount:
            htmlForSection = self.htmlHeaderForOpeningAmount;
            break;
        case ReportSectionNoneSales:
            htmlForSection = self.htmlHeaderForNoneSales;
            break;
        case ReportSectionMerchandiseSales:
            htmlForSection = self.htmlHeaderForMerchandiseSales;
            break;
        case ReportSectionAllTaxes:
            htmlForSection = self.htmlHeaderForAllTaxes;
            break;
        case ReportSectionAllDetails:
            htmlForSection = self.htmlHeaderForAllTaxesDetails;
            break;
        case ReportSectionLotterySales:
            htmlForSection = self.htmlHeaderForLotterySales;
            break;
        case ReportSectionGasSales:
            htmlForSection = self.htmlHeaderForGasSales;
            break;
        case ReportSectionMoneyOrder:
            htmlForSection = self.htmlHeaderForMoneyOrder;
            break;
        case ReportSectionGiftCardSales:
            htmlForSection = self.htmlHeaderForGiftCardSales;
            break;
        case ReportSectionCheckCash:
            htmlForSection = self.htmlHeaderForCheckCash;
            break;
        case ReportSectionVendorPayout:
            htmlForSection = self.htmlHeaderForVendorPayout;
            break;
        case ReportSectionHouseCharge:
            htmlForSection = self.htmlHeaderForHouseCharge;
            break;
        case ReportSectionSalesOther:
            htmlForSection = self.htmlHeaderForSalesOther;
            break;
        case ReportSectionAllSalesTotal:
            htmlForSection = self.htmlHeaderForAllSalesTotal;
            break;
        case ReportSection4:
            htmlForSection = self.htmlHeaderForSection4;
            break;
        case ReportSectionOverShort:
            htmlForSection = self.htmlHeaderForSectionOverShort;
            break;
        case ReportSection6:
            htmlForSection = self.htmlHeaderForSection6;
            break;
        case ReportSection7:
            htmlForSection = self.htmlHeaderForSection7;
            break;
        case ReportSectionCustomer:
            htmlForSection = self.htmlHeaderForSectionCustomer;
            break;
        case ReportSectionDiscount:
            htmlForSection = self.htmlHeaderForSectionDiscount;
            break;
        case ReportSectionTaxes:
            htmlForSection = self.htmlHeaderForSectionTaxes;
            break;
        case ReportSectionPaymentMode:
            htmlForSection = self.htmlHeaderForSectionPaymentMode;
            break;
        case ReportSectionTenderTips:
            htmlForSection = self.htmlHeaderForSectionTenderTips;
            break;
        case ReportSectionGiftCard:
            htmlForSection = self.htmlHeaderForSectionGiftCard;
            break;
        case ReportSectionCardType:
            htmlForSection = self.htmlHeaderForSectionCardType;
            break;
        case ReportSectionCardTypeOutSide:
            htmlForSection = self.htmlHeaderForSectionCardTypeOutSide;
            break;
        case ReportSectionCardFuelSummery:
            htmlForSection = self.htmlHeaderForGasFuelSummery;
            break;
        case ReportSectionPumpSummery:
            htmlForSection = self.htmlHeaderForGasPumpSummery;
            break;
        case ReportSectionDepartment:
            htmlForSection = self.htmlHeaderForSectionDepartment;
            break;
        case ReportSectionNonMerchandiseDepartment:
            htmlForSection = self.htmlHeaderForSectionNonMerchandiseDepartment;
            break;
        case ReportSectionPayout:
            htmlForSection = self.htmlHeaderForSectionPayout;
            break;
        case ReportSectionHourlySales:
            htmlForSection = self.htmlHeaderForHourlySales;
            break;
        default:
            break;
    }
    return htmlForSection;
}

- (NSString *)htmlForSectionFooter:(ReportSection)sectionId
{
    NSString *htmlForSection;
    switch (sectionId) {
        case ReportSectionHeader:
            htmlForSection = self.htmlFooterForSectionHeader;
            break;
        case ReportSectionDailySales:
            htmlForSection = self.htmlFooterForSectionDaily;
            break;
        case ReportSectionSales:
            htmlForSection = self.htmlFooterForSectionSales;
            break;
        case ReportSectionPetroSales:
            htmlForSection = [self htmlFooterForSectionPetroSales];
            break;
        case ReportSection3:
            htmlForSection = self.htmlFooterForSection3;
            break;
        case ReportSectionOpeningAmount:
            htmlForSection = self.htmlFooterForOpeningAmount;
            break;
        case ReportSectionNoneSales:
            htmlForSection = self.htmlFooterForNoneSales;
            break;
        case ReportSectionMerchandiseSales:
            htmlForSection = self.htmlFooterForMerchandiseSales;
            break;
        case ReportSectionAllTaxes:
            htmlForSection = self.htmlFooterForAllTaxes;
            break;
        case ReportSectionAllDetails:
            htmlForSection = self.htmlFooterForAllTaxesDetails;
            break;
        case ReportSectionLotterySales:
            htmlForSection = self.htmlFooterForLotterySales;
            break;
        case ReportSectionGasSales:
            htmlForSection = self.htmlFooterForGasSales;
            break;
        case ReportSectionMoneyOrder:
            htmlForSection = self.htmlFooterForMoneyOrderSales;
            break;
        case ReportSectionGiftCardSales:
            htmlForSection = self.htmlFooterForGiftCardSales;
            break;
        case ReportSectionCheckCash:
            htmlForSection = self.htmlFooterForCheckCash;
            break;
        case ReportSectionVendorPayout:
            htmlForSection = self.htmlFooterForVendorPayout;
            break;
        case ReportSectionHouseCharge:
            htmlForSection = self.htmlFooterForHouseCharge;
            break;
        case ReportSectionSalesOther:
            htmlForSection = self.htmlFooterForSalesOther;
            break;
        case ReportSectionAllSalesTotal:
            htmlForSection = self.htmlFooterForAllSalesTotal;
            break;
        case ReportSectionGroup5A:
            htmlForSection = [self htmlFooterForSectionGroup5A];
            break;
        case ReportSection4:
            htmlForSection = self.htmlFooterForSection4;
            break;
        case ReportSectionOverShort:
            htmlForSection = self.htmlFooterForSectionOverShort;
            break;
        case ReportSection6:
            htmlForSection = self.htmlFooterForSection6;
            break;
        case ReportSection7:
            htmlForSection = self.htmlFooterForSection7;
            break;
        case ReportSectionCustomer:
            htmlForSection = self.htmlFooterForSectionCustomer;
            break;
        case ReportSectionDiscount:
            htmlForSection = self.htmlFooterForSectionDiscount;
            break;
        case ReportSectionTaxes:
            htmlForSection = self.htmlFooterForSectionTaxes;
            break;
        case ReportSectionPaymentMode:
            htmlForSection = self.htmlFooterForSectionPaymentMode;
            break;
        case ReportSectionTenderTips:
            htmlForSection = self.htmlFooterForSectionTenderTips;
            break;
        case ReportSectionGiftCard:
            htmlForSection = self.htmlFooterForSectionGiftCard;
            break;
        case ReportSectionCardType:
            htmlForSection = self.htmlFooterForSectionCardType;
            break;
        case ReportSectionCardTypeOutSide:
            htmlForSection = self.htmlFooterForSectionCardTypeOutSide;
            break;

        case ReportSectionCardFuelSummery:
            htmlForSection = self.htmlFooterForGasFuelSummery;
            break;
        case ReportSectionPumpSummery:
            htmlForSection = self.htmlFooterForGasPumpSummery;
            break;
            
        case ReportSectionDepartment:
            htmlForSection = self.htmlFooterForSectionDepartment;
            break;
        case ReportSectionNonMerchandiseDepartment:
            htmlForSection = self.htmlFooterForSectionNonMerchandiseDepartment;
            break;
        case ReportSectionPayout:
            htmlForSection = self.htmlFooterForSectionPayout;
            break;
        case ReportSectionHourlySales:
            htmlForSection = self.htmlFooterForHourlySales;
            break;
        case ReportSectionGroup24:
            htmlForSection = [self htmlFooterForHourlyGasSales];
            break;
            
        default:
            break;
    }
    return htmlForSection;
}

- (NSString *)generateHtml
{
    NSMutableString *html = [[NSMutableString alloc] init];
    for (int i = 0 ; i < _sections.count; i++) {
       NSString *htmlForSection = [self htmlForSectionAtIndex:i];
       [html appendString:htmlForSection];
    }
    return html;
}

- (NSString *)htmlForSectionAtIndex:(NSInteger)sectionIndex {
    NSMutableString *html = [[NSMutableString alloc] init];
    [html appendString: [self headerHtmlForSectionAtIndex:sectionIndex]];
    NSArray *sectionFields = _fields[sectionIndex];
    for (int j = 0; j < sectionFields.count; j++) {
        [html appendString:[self htmlForFieldAtIndex:j sectionIndex:sectionIndex]];
    }
    [html appendString: [self footerHtmlForSectionAtIndex:sectionIndex]];
    return html;
}

- (NSString *)htmlForFieldAtIndex:(NSInteger)fieldIndex sectionIndex:(NSInteger)sectionIndex {
    NSString *html;
    NSNumber *fieldNumber = _fields[sectionIndex][fieldIndex];
    ReportField fieldId = fieldNumber.integerValue;
    html = [self htmlForFieldId:fieldId];
    if(html == nil)
    {
        html = @"";
    }
    return html;
}

- (NSString *)headerHtmlForSectionAtIndex:(NSInteger)sectionId
{
    NSString *html;
    NSNumber *sectionNumber = _sections[sectionId];
    ReportSection section = sectionNumber.integerValue;
    html = [self htmlForSectionHeader:section];
    if(html == nil)
    {
        html = @"";
    }
    return html;
}

- (NSString *)footerHtmlForSectionAtIndex:(NSInteger)sectionId
{
    NSString *html;
    NSNumber *sectionNumber = _sections[sectionId];
    ReportSection section = sectionNumber.integerValue;
    html = [self htmlForSectionFooter:section];
    if(html == nil)
    {
        html = @"";
    }
    return html;
}


#pragma mark HTML Report

- (NSString *)htmlForCommonHeader
{
    NSString *htmlForCommonHeader = [[NSString alloc] initWithFormat:@"<html>$$STYLE$$<body>"];
    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<div \" style=\"font-family:Helvetica Neue; $$WIDTH$$ ; margin:auto; font-size:14px;\">"];
    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<table  style=\"font-family:Helvetica Neue; $$WIDTHCOMMONHEADER$$; font-size:14px; background-color:#FFFFFF; margin-left:-8px; margin-top:-8px;padding-top:8px;padding-bottom:8px; padding-right:8px; \">"];
    
    if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">%@</td></tr>",[NSString stringWithFormat:@"%@",(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"StoreName"]]];
    }
    else
    {
        htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">%@</td></tr>",[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReportDataKeyBranchName]]];
    }

    if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        
        htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">%@</td></tr>",[NSString stringWithFormat:@"%@",(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]]];
    }
    else {
        htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">%@</td></tr>",[NSString stringWithFormat:@"%@%@",[self branchInfoValueForKeyIndex:ReportDataKeyAddress1],[self branchInfoValueForKeyIndex:ReportDataKeyAddress2]]];
    }

    if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">%@</td></tr>",[NSString stringWithFormat:@"%@ - %@",email,phoneNo]];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">%@</td></tr>",[NSString stringWithFormat:@"%@",phoneNo]];
        }
    }
    else {
        
        htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">%@</td></tr>",[NSString stringWithFormat:@"%@%@%@",[self branchInfoValueForKeyIndex:ReportDataKeyCity],[self branchInfoValueForKeyIndex:ReportDataKeyState],[self branchInfoValueForKeyIndex:ReportDataKeyZipCode]]];
    }

    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"</table>"];
    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<table cellpadding=\"0\" cellspacing=\"0\" width:100%@; font-size: 13px;\" border=\"0\" width=100%@>",@"%",@"%"];
    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\" style=\"font-family:Helvetica Neue;background-color:#FCA104; font-size:14px;color:#FFFFFF; padding-top:2px;padding-bottom:2px;\"><strong>%@</strong></td></tr>",_reportName];
    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td><table cellpadding=\"0\" cellspacing=\"0\"  style=\" width:100%@; font-size: 13px;\" border=\"0\" width=100%@>",@"%",@"%"];
    return htmlForCommonHeader;
}

- (NSString *)weekDayNameForDate:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = comps.weekday;
    NSString *weekDayName = [self dayFromWeekDay:weekday];
    return weekDayName;
}

- (NSString *)htmlForDay
{
    NSString *htmlForDay = @"";
    NSString *strDate = @"";
    if([_reportName isEqualToString:@"Centralize Z"]){
       strDate = [self stringFromDate:[self jsonStringToNSDate:[[_reportData[@"RptZRegister"] firstObject] valueForKey:@"ZCloseDate"]] format:@"MM/dd/yyyy hh:mm a"];
    }
    else {
        strDate = [self dateFromDictionary:[self reportSummary] timeKey:@"ReportTime" dateKey:@"ReportDate"];
    }
    NSString *weekDayName = [self weekDayNameForDate:strDate];
    htmlForDay = [htmlForDay stringByAppendingFormat:@"<tr><td><strong>Day</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>", weekDayName];
    htmlForDay = [htmlForDay stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    return htmlForDay;
}

- (NSString *)htmlForkey:(NSString *)key value:(NSString *)value
{
    NSString *htmlForName = @"";
    if (!value || ([value isKindOfClass:[NSString class]] && !value.length > 0)) {
        htmlForName = [NSString stringWithFormat:@"<tr><td>%@</td><td><div align=\"right\"></div></td></tr>",key];
    }
    else {
        htmlForName = [NSString stringWithFormat:@"<tr><td>%@</td><td><div align=\"right\">%@ </div></td></tr>",key,value];
    }
    return htmlForName;
}

- (NSString *)htmlForName
{
    return [self htmlForkey:REPORT_USER_NAME value:[self reportSummary] [@"CurrentUser"]];
}

- (NSString *)htmlForRegister {
    return [self htmlForkey:REPORT_REGISTER_NAME value:[self reportSummary] [@"RegisterName"]];
}

- (NSString *)htmlForCentralizeRegister {
    
    NSString *htmlCentralizeRegister = [NSString stringWithFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    for (NSDictionary *registerDict in _reportData[@"RptZRegister"]) {
        
        NSString *registerName = registerDict[@"RegisterName"];
        if (!registerName || ([registerName isKindOfClass:[NSString class]] && !(registerName.length > 0))) {
            
            
            
            htmlCentralizeRegister = [htmlCentralizeRegister stringByAppendingFormat:@"<tr><td></td><td><div align=\"right\"></div></td></tr>"];
        }
        else {
            htmlCentralizeRegister = [htmlCentralizeRegister stringByAppendingFormat:@"<tr><td><strong>%@<strong></td><td><div align=\"right\"></div></td></tr>",registerName];
        }
        
        NSString *dateAndTime = [self convertJsonDate:registerDict[@"ZOpenDate"]];
        NSString *endDate = [self convertJsonDate:registerDict[@"ZCloseDate"]];
        
        htmlCentralizeRegister = [htmlCentralizeRegister stringByAppendingString:[self htmlForkey:REPORT_START_DATE_AND_START_TIME value:dateAndTime]];
        
        htmlCentralizeRegister = [htmlCentralizeRegister stringByAppendingString:[self htmlForkey:REPORT_END_DATE_AND_END_TIME value:endDate]];
    }
    
    htmlCentralizeRegister = [htmlCentralizeRegister stringByAppendingString:@"<tr><td></td><td><div align=\"right\"></div></td></tr>"];
    
    return htmlCentralizeRegister;
}
-(NSString *)convertJsonDate:(NSString *)jsonDate{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSDate *now = [[RmsDbController sharedRmsDbController] getDateFromJSONDate:jsonDate];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    format.timeZone = gmt;
    NSString *dateString = [format stringFromDate:now];
    return dateString;
}

- (NSString *)htmlForDateTime {
    return [self htmlForkey:REPORT_DATE_AND_TIME value:self.currentDateAndTime];
}

- (NSString *)htmlForStartDateTime {
    NSString *dateAndTime = [self dateFromDictionary:[self reportSummary] timeKey:@"StartTime" dateKey:@"Startdate"];
    return [self htmlForkey:REPORT_START_DATE_AND_START_TIME value:dateAndTime];
}

- (NSString *)htmlForEndDateTime {
    NSString *endDate = [self dateFromDictionary:[self reportSummary] timeKey:@"ReportTime" dateKey:@"ReportDate"];
    return [self htmlForkey:REPORT_END_DATE_AND_END_TIME value:endDate];
}

- (NSString *)htmlForBatchNo {
    return [self htmlForkey:REPORT_BATCH value:[self reportSummary][@"BatchNo"]];
}

- (NSString *)htmlForGrossSales {
    NSString *htmlForGrossSales = [NSString stringWithFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForGrossSales = [htmlForGrossSales stringByAppendingFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\"><div align=\"right\">%@ </div></td></tr>",REPORT_GROSS_SALES,[currencyFormatter stringFromNumber:[self reportSummary][@"TotalSales"]]];
    return htmlForGrossSales;
}

- (NSString *)htmlForTaxes {
    return  [NSString stringWithFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td><div style=\"font-family:Helvetica Neue;color:#FC2001;\" align=\"right\">%@ </div></td></tr>",REPORT_TAXES,[currencyFormatter stringFromNumber:[self reportSummary][@"CollectTax"]]];
    ;
}

-(NSString *)htmlForVersion
{
    NSString  *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];

    return  [NSString stringWithFormat:@"<tr><td style=\"font-family:Helvetica Neue;\"><strong><center>%@</center></strong></td></tr>",[NSString stringWithFormat:@"RapidRms (iOS v %@ / %@)",appVersion, buildVersion]];
    
}

- (NSString *)htmlForPetroRefund {
    NSString *htmlForPetroRefund  =  [NSString stringWithFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td><div style=\"font-family:Helvetica Neue;color:#FC2001;\" align=\"right\">%@ </div></td></tr>",REPORT_PETRO_REFUND,[currencyFormatter stringFromNumber:[self reportSummary][@"FuelRefund"]]];
    
     htmlForPetroRefund = [htmlForPetroRefund stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    return htmlForPetroRefund;
}

- (NSString *)htmlForNetSales {
    float netSales = [[self reportSummary][@"TotalSales"] doubleValue] - [[self reportSummary][@"CollectTax"]doubleValue];
    NSNumber *netSale = @(netSales);
    NSString *htmlForNetSales = [NSString stringWithFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\"><div align=\"right\">%@ </div></td></tr>",REPORT_NET_SALES,[currencyFormatter stringFromNumber:netSale]];
    return htmlForNetSales;
}


- (NSString *)htmlForDeposit {
    
    NSArray *tenderReport = [self tenderTypeDetail];
    
    NSPredicate *predicateCash = [NSPredicate predicateWithFormat:@"CashInType = %@",@"Cash"];
    NSArray *cashArray = [tenderReport filteredArrayUsingPredicate:predicateCash];
    
    NSPredicate *predicatecheque= [NSPredicate predicateWithFormat:@"CashInType = %@",@"Check"];
    NSArray *chequeArray = [tenderReport filteredArrayUsingPredicate:predicatecheque];

    CGFloat totalCash = [[cashArray valueForKeyPath:@"@sum.Amount"] floatValue];
    CGFloat totalCheque = [[chequeArray valueForKeyPath:@"@sum.Amount"] floatValue];
    
    CGFloat deposite = totalCash + totalCheque;
    NSNumber *numDeposite = @(deposite);
    
    NSString *htmlForDeposit = [NSString stringWithFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\"><div align=\"right\">%@ </div></td></tr>",REPORT_DEPOSIT,[currencyFormatter stringFromNumber:numDeposite]];
     htmlForDeposit = [htmlForDeposit stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    return htmlForDeposit;
}
- (NSString *)htmlForOpeningAmount {
    NSString *htmlForOpeningAmount = [NSString stringWithFormat:@"<tr><td style=\"padding-bottom:10px;\">%@</style></td><td style=\"padding-bottom:5px;\"><div align=\"right\">%@ </div></style></td></tr>",REPORT_OPENING_AMOUNT,[currencyFormatter stringFromNumber:[self reportSummary][@"OpeningAmount"]]];
    return htmlForOpeningAmount;
}
- (NSString *)htmlForDailySales {
    NSString *htmlForDailySales = @"";
    htmlForDailySales = [htmlForDailySales stringByAppendingFormat:@"<tr><td colspan=\"2\"><div align=\"right\"></div></td></tr><tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\" ><div align=\"right\">%@</div></td></tr>",REPORT_DAILY_SALES,[currencyFormatter stringFromNumber:[self reportSummary][@"DailySales"]]];
    return htmlForDailySales;
}
- (NSString *)htmlForDailyInsideGasSales {
    NSString *htmlForDailyInsideGasSales = @"";
    htmlForDailyInsideGasSales = [htmlForDailyInsideGasSales stringByAppendingFormat:@"<tr><td colspan=\"2\"><div align=\"right\"></div></td></tr><tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\" ><div align=\"right\">%@</div></td></tr>",REPORT_GAS_INSIDE_SALES,[currencyFormatter stringFromNumber:[self reportSummary][@"InSideGrossFuelSales"]]];
    return htmlForDailyInsideGasSales;
}
- (NSString *)htmlForDailyOutSideGasSales {
    NSString *htmlForDailyOutSideGasSales = @"";
    htmlForDailyOutSideGasSales = [htmlForDailyOutSideGasSales stringByAppendingFormat:@"<tr><td colspan=\"2\"><div align=\"right\"></div></td></tr><tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\" ><div align=\"right\">%@</div></td></tr>",REPORT_GAS_OUT_SALES,[currencyFormatter stringFromNumber:[self reportSummary][@"OutSideGrossFuelSales"]]];
    return htmlForDailyOutSideGasSales;
}
- (NSString *)htmlForSales {
    NSString *htmlForSales = [NSString stringWithFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\"><div align=\"right\">%@ </div></td></tr>",REPORT_SALES,[currencyFormatter stringFromNumber:[self reportSummary][@"Sales"]]];
    return htmlForSales;
}

- (NSString *)htmlForReturn {
    double returnAmount = [[self reportSummary][@"Return"] doubleValue];
    NSNumber *returnAmountNumber = @(fabs(returnAmount));
    NSString *htmlForReturn = [NSString stringWithFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\"><div align=\"right\">%@ </div></td></tr>",REPORT_RETURN,[currencyFormatter stringFromNumber: returnAmountNumber]];
    return htmlForReturn;
}

- (NSString *)htmlForSection3Total {
    NSString *htmlForSection3Total = @"";
    double sum1 = [[self reportSummary] [@"Sales"] doubleValue] + [[self reportSummary] [@"Return"] doubleValue];
    NSNumber *sum1number = @(sum1);
    htmlForSection3Total = [NSString stringWithFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\"><div align=\"right\">%@ </div></td></tr>",@"Total",[currencyFormatter stringFromNumber:sum1number]];
    htmlForSection3Total = [htmlForSection3Total stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    return htmlForSection3Total;
}

- (NSString *)htmlForSection3Taxes {
    return [self htmlForkey:REPORT_TAXES value:[currencyFormatter stringFromNumber:[self reportSummary] [@"CollectTax"]]];
}

- (NSString *)htmlForSurCharge {
    return [self htmlForkey:REPORT_SURCHARGE value:[currencyFormatter stringFromNumber:[self reportSummary] [@"Surcharge"]]];
}

- (NSString *)htmlForTips
{
    NSString *htmlForTips = @"";
    if (_isTipSetting)
    {
        htmlForTips = [htmlForTips stringByAppendingFormat:@"<tr><td>%@ </td><td><div align=\"right\">%@ </div></td></tr>",REPORT_TIPS,[currencyFormatter stringFromNumber:[self reportSummary] [@"TotalTips"]]];
    }
    return  htmlForTips;
}

-(NSMutableArray *)getTipTender{
    
    NSMutableArray *tenderArray = _reportData[@"RptTender"];
    if(tenderArray.count > 0){
        return tenderArray;
    }
    return nil;
}

- (NSString *)htmlForAllTipsTotal
{
    NSString *htmlForAllTipsTotal = @"";
    if (_isTipSetting)
    {
       
        htmlForAllTipsTotal = [htmlForAllTipsTotal stringByAppendingFormat:@"<tr><td><strong>%@ </strong></td><td><div align=\"right\"><strong>%@</strong></div></td></tr>",@"Total",[currencyFormatter stringFromNumber:[self reportSummary] [@"TotalTips"]]];
        
    }
    return htmlForAllTipsTotal;
}

- (NSString *)htmlForAllTips
{
    NSString *htmlForAllTips = @"";
    if (_isTipSetting)
    {
        NSMutableArray *cardTypeReport= [self getTipTender];
        
        if([cardTypeReport isKindOfClass:[NSArray class]])
        {
            for (int itx=0; itx<cardTypeReport.count; itx++) {
                NSMutableDictionary *cardTypeRptDisc = cardTypeReport[itx];

            htmlForAllTips = [htmlForAllTips stringByAppendingFormat:@"<tr><td>%@ </td><td><div align=\"right\">%@ </div></td></tr>",[cardTypeRptDisc valueForKey:@"Descriptions"],[currencyFormatter stringFromNumber:[cardTypeRptDisc valueForKey:@"TipsAmount"]]];
            }
        }
    }
    return  htmlForAllTips;
}

- (NSString *)htmlForGiftCard {
    return [self htmlForkey:REPORT_GIFTCARD value:[currencyFormatter stringFromNumber:[self reportSummary] [@"LoadAmount"]]];
}

- (NSString *)htmlForMoneyOrder {
    return [self htmlForkey:REPORT_MONEY_ORDER value:[currencyFormatter stringFromNumber:[self reportSummary] [@"MoneyOrder"]]];
}

- (NSString *)htmlForGrossFuelSales {
    return [self htmlForkey:REPORT_GROSS_FUEL_SALES value:[currencyFormatter stringFromNumber:[self reportSummary] [@"GrossFuelSales"]]];
}


-(NSDictionary *)getSalesByDeptType:(NSString *)deptType{
    
    NSArray *salesArray  = _reportData[@"RptSales"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DeptType  = %@",deptType];
    salesArray = [salesArray filteredArrayUsingPredicate:predicate];
    if(salesArray.count > 0){
         return salesArray[0];
    }
    else{
        return nil;
    }
}
-(NSDictionary *)getSalesByDeptTypebyId:(NSInteger)deptTypeid{
    
    NSArray *salesArray  = _reportData[@"RptSales"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DeptTypeId  = %d",deptTypeid];
    salesArray = [salesArray filteredArrayUsingPredicate:predicate];
    if(salesArray.count > 0){
        return salesArray[0];
    }
    else{
        return nil;
    }
}


// Merchandise SALES
- (NSString *)htmlForMerchandiseSales {
    
    if([self calculateMerchandiseSales] != 0){
       
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Merchandise"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMerchandise];

        return [self htmlForkey:REPORT_NONMERCHANDIZE_SALES value:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
    return nil;

}

- (NSString *)htmlForMerchandiseReturn {
    
    if([self calculateMerchandiseSales] != 0){
        
       // NSDictionary *salesDict = [self getSalesByDeptType:@"Merchandise"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMerchandise];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        return [self htmlForkey:REPORT_NONMERCHANDIZE_RETURN value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
            
    }
    return nil;
}
-(double)addMinusSign:(double)amount{
    
    if(amount < 0){
        return amount;
    }
    else if(amount != 0){
        amount =  amount*-1;
        return amount;
    }
    else{
        return amount;
    }
   
}
- (NSString *)htmlForMerchandiseDiscount {
    
    if([self calculateMerchandiseSales] != 0){

       // NSDictionary *salesDict = [self getSalesByDeptType:@"Merchandise"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMerchandise];
        double discount = [salesDict [@"Discount"] doubleValue];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_DISCOUNT value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
        
    }
    return nil;
}

// All Taxes

- (NSString *)htmlForAllTaxesField {
    NSString *htmlForAllTaxesField = @"";
    htmlForAllTaxesField = [htmlForAllTaxesField stringByAppendingFormat:@"<tr><td colspan=\"2\"><div align=\"right\"></div></td></tr><tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\" ><div align=\"right\">%@</div></td></tr>",REPORT_TAXES,[currencyFormatter stringFromNumber: [self reportSummary] [@"CollectTax"]]];
    return htmlForAllTaxesField;
}

// All Taxes Details

- (NSString *)htmlForAllTaxesFieldDetails {
    
    NSString *htmlForAllTaxesFieldDetails = @"";
    
    NSArray *taxReport= _reportData[@"RptTax"];
    if([taxReport  isKindOfClass:[NSArray class]])
    {
        for (int itx=0; itx<taxReport.count; itx++) {
            NSDictionary *taxRptDisc = taxReport[itx];
            
            htmlForAllTaxesFieldDetails = [htmlForAllTaxesFieldDetails stringByAppendingFormat:@"<tr><td style=\"padding-bottom:5px;\">%@</style></td><td style=\"padding-bottom:5px;\"><div align=\"right\">%@ </div></style></td></tr>",[taxRptDisc valueForKey:@"Descriptions"],[currencyFormatter stringFromNumber:[taxRptDisc valueForKey:@"Amount"]]];
        }
    }
    return htmlForAllTaxesFieldDetails;
}

// LOATRY SALES

- (NSString *)htmlForLotterySales {
    
    if([self calculateLotterySales] != 0)
    {
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_SALES value:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
    return nil;
}
- (NSString *)htmlForLotteryProfit {
    
    if([self calculateLotterySales] != 0)
    {
       // NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_PROFIT value:[currencyFormatter stringFromNumber:salesDict[@"Profit"]]];
    }
    return nil;
}

- (NSString *)htmlForLotteryReturn {
    
    if([self calculateLotterySales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        return [self htmlForkey:REPORT_NONMERCHANDIZE_RETURN value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
    return nil;
}

- (NSString *)htmlForLotteryDiscount {
    
    if([self calculateLotterySales] != 0){

         //NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
        double discount = [salesDict [@"Discount"] doubleValue];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_DISCOUNT value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
    return nil;
}
- (NSString *)htmlForLotteryPayout {
    if([self calculateLotterySales] != 0){

        //NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
        return [self htmlForkey:REPORT_LOTTERY_PAYOUT value:[currencyFormatter stringFromNumber:salesDict[@"PayoutSales"]]];
    }
    return nil;
}

// GAS SALES

- (NSString *)htmlForGasSales {
    
    if([self calculateGasSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_SALES value:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
    return nil;
}
- (NSString *)htmlForGasProfit {
    
    if([self calculateGasSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_PROFIT value:[currencyFormatter stringFromNumber:salesDict[@"Profit"]]];
    }
    return nil;
}

- (NSString *)htmlForGasReturn {
    if([self calculateGasSales] != 0){
        // NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        return [self htmlForkey:REPORT_NONMERCHANDIZE_RETURN value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
    return nil;
}

- (NSString *)htmlForGasDiscount {
    if([self calculateGasSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
        double discount = [salesDict [@"Discount"] doubleValue];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_DISCOUNT value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
    return nil;
   
}
- (NSString *)htmlForGasQty{
    if([self calculateGasSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
         NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_QTY value:salesDict[@"Qty"]];
    }
    return nil;
   
}

// MONEY ORDER SALES

- (NSString *)htmlForMoneyOrderSales {
    if([self calculateMoneyOrderSales] != 0){
        
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Money Order"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_SALES value:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
    return nil;
    
}
- (NSString *)htmlForMoneyOrderSalesFee {
    if([self calculateMoneyOrderSales] != 0){
     //NSDictionary *salesDict = [self getSalesByDeptType:@"Money Order"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder];
    return [self htmlForkey:REPORT_NONMERCHANDIZE_FEE value:[currencyFormatter stringFromNumber:salesDict[@"SalesFee"]]];
    }
    return nil;
}

- (NSString *)htmlForMoneyOrderReturn {
    if([self calculateMoneyOrderSales] != 0){

        //NSDictionary *salesDict = [self getSalesByDeptType:@"Money Order"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        return [self htmlForkey:REPORT_NONMERCHANDIZE_RETURN value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
        }
    return nil;
}

- (NSString *)htmlForMoneyOrderDiscount {
    if([self calculateMoneyOrderSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Money Order"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder];
        double discount = [salesDict [@"Discount"] doubleValue];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_DISCOUNT value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
    return nil;
}

// GIFT CARD SALES

- (NSString *)htmlForGiftCardSales {
    if([self calculateGiftCardSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gift Card"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGiftCard];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_SALES value:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
    return nil;
}
- (NSString *)htmlForGiftCardFee {
    if([self calculateGiftCardSales] != 0){

        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gift Card"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGiftCard];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_FEE value:[currencyFormatter stringFromNumber:salesDict[@"SalesFee"]]];
    }
    return nil;
}
- (NSString *)htmlForGiftCardReturn {
     if([self calculateGiftCardSales] != 0){
        // NSDictionary *salesDict = [self getSalesByDeptType:@"Gift Card"];
         NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGiftCard];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
         return [self htmlForkey:REPORT_NONMERCHANDIZE_RETURN value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
     }
    return nil;
}
- (NSString *)htmlForGiftCardDiscount {
    if([self calculateGiftCardSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gift Card"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGiftCard];
        double discount = [salesDict [@"Discount"] doubleValue];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_DISCOUNT value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
    return nil;
}

// CHECK CASH SALES

- (NSString *)htmlForCheckCashSales {
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Check cash"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
    if([salesDict[@"Sales"] doubleValue] != 0){
         NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_SALES value:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
    return nil;
}
- (NSString *)htmlForCheckCashFee {
     NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
    if([salesDict[@"Sales"] doubleValue] != 0){
         NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_FEE value:[currencyFormatter stringFromNumber:salesDict[@"CheckCashAmount"]]];
        }
    return  nil;
}

- (NSString *)htmlForCheckCashReturn {
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Check cash"];
     NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
    if([salesDict[@"Sales"] doubleValue] != 0){

        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        return [self htmlForkey:REPORT_NONMERCHANDIZE_RETURN value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
    return nil;
}

- (NSString *)htmlForCheckCashDiscount{
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Check cash"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
   if([salesDict[@"Sales"] doubleValue] != 0){
       double discount = [salesDict [@"Discount"] doubleValue];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_DISCOUNT value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
    return nil;
}

// PAYOUT SALES

- (NSString *)htmlForPayoutSales {
    
    if([self calculateVendorPayoutSales] != 0){
       // NSDictionary *salesDict = [self getSalesByDeptType:@"Vendor Payout"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeVendorPayout];
        return [self htmlForkey:REPORT_PAYOUT_AMOUNT value:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
    return nil;
}

- (NSString *)htmlForPayoutReturn {
     if([self calculateVendorPayoutSales] != 0){
         //NSDictionary *salesDict = [self getSalesByDeptType:@"Vendor Payout"];
         NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeVendorPayout];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        return [self htmlForkey:REPORT_NONMERCHANDIZE_RETURN value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
     }
    return nil;
}

- (NSString *)htmlForPayoutDiscount{
    if([self calculateVendorPayoutSales] != 0){

       // NSDictionary *salesDict = [self getSalesByDeptType:@"Vendor Payout"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeVendorPayout];
        double discount = [salesDict [@"Discount"] doubleValue];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_DISCOUNT value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
    return nil;
}
// HOUSE CHARGE SALES

- (NSString *)htmlForHouseChargeSales {

    if([self calculateHouseChargeSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"House Charge"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeHouseCharge];
        return [self htmlForkey:REPORT_DEPOSITE_AMOUNT value:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
    return nil;
    
}

- (NSString *)htmlForHouseChargeReturn {
    if([self calculateHouseChargeSales] != 0){
        // NSDictionary *salesDict = [self getSalesByDeptType:@"House Charge"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeHouseCharge];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        return [self htmlForkey:REPORT_NONMERCHANDIZE_RETURN value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
    return nil;
}

- (NSString *)htmlForHouseChargeDiscount{
    if([self calculateHouseChargeSales] != 0){

         //NSDictionary *salesDict = [self getSalesByDeptType:@"House Charge"];
         NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeHouseCharge];
        double discount = [salesDict [@"Discount"] doubleValue];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_DISCOUNT value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
    return nil;
}

// OTHER SALES

- (NSString *)htmlForOtherSales {
    if([self calculateOtherSales] != 0){
    // NSDictionary *salesDict = [self getSalesByDeptType:@"Other"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeOther];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_SALES value:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
     return nil;
}

- (NSString *)htmlForOtherReturn {
    if([self calculateOtherSales] != 0){
         //NSDictionary *salesDict = [self getSalesByDeptType:@"Other"];
         NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeOther];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        return [self htmlForkey:REPORT_NONMERCHANDIZE_RETURN value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
    return nil;
}

- (NSString *)htmlForOtherDiscount{
    if([self calculateOtherSales] != 0){
        // NSDictionary *salesDict = [self getSalesByDeptType:@"Other"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeOther];
        double discount = [salesDict [@"Discount"] doubleValue];
        return [self htmlForkey:REPORT_NONMERCHANDIZE_DISCOUNT value:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
    return nil;
}


- (NSString *)htmlForGross {
    return [self htmlForkey:REPORT_GROSS_FUEL_SALES value:[currencyFormatter stringFromNumber:[self reportSummary] [@"GrossFuelSales"]]];
}


- (NSString *)htmlForFuelRefund {
    return [self htmlForkey:REPORT_FUEL_REFUND value:[currencyFormatter stringFromNumber:[self reportSummary] [@"FuelRefund"]]];
}
- (NSString *)htmlForPetroNetFuelSales {
    NSString *htmlForPetroNetFuelSales = @"";
    NSNumber *numNetFuelSales = [self calculateNetFuelSales];
   
    htmlForPetroNetFuelSales = [htmlForPetroNetFuelSales stringByAppendingFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\"><div align=\"right\">%@ </div></td></tr>",REPORT_NET_FUEL_SALES,[self currencyFormattedAmount:numNetFuelSales]];
    
    
     htmlForPetroNetFuelSales = [htmlForPetroNetFuelSales stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    return htmlForPetroNetFuelSales;
}
- (NSString *)htmlForNetFuelSales {
    [self defaultFormatForTwoColumn];
    NSNumber *numNetFuelSales = [self calculateNetFuelSales];
    return [self htmlForkey:REPORT_NET_FUEL_SALES value:[self currencyFormattedAmount:numNetFuelSales]];
}

- (NSString *)htmlForDropAmount {
    NSString *htmlForDropAmount = @"";
    htmlForDropAmount = [htmlForDropAmount stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForDropAmount = [htmlForDropAmount stringByAppendingFormat:@"<tr><td>%@ </td><td><div align=\"right\">%@</div></td></tr>",REPORT_DROP_AMOUNT,[currencyFormatter stringFromNumber: [self reportSummary] [@"DropAmount"]]];
    return htmlForDropAmount;
}

- (NSString *)htmlForPaidOut {
    double paidOutAmount = [[self reportSummary][@"PayOut"] doubleValue];
    NSNumber *paidOutAmountNumber = @(fabs(paidOutAmount));
    return [self htmlForkey:REPORT_PAYOUT value:[currencyFormatter stringFromNumber: paidOutAmountNumber]];
}

- (NSString *)htmlForClosingAmount {
    
    return [self htmlForkey:REPORT_CLOSING_AMOUNT value:[currencyFormatter stringFromNumber:[self reportSummary] [@"ClosingAmount"]]];
}

- (NSString *)htmlForTenderCardData {
    NSString *htmlForTenderCardData = @"";
    NSArray *tenderCardData= [self tenderTypeDetail];
    if([tenderCardData  isKindOfClass:[NSArray class]])
    {
        for (int i=0; i<tenderCardData.count; i++) {
            NSMutableDictionary *tenderRptCard=tenderCardData[i];
            NSString *strCashType=[NSString stringWithFormat:@"%@",[tenderRptCard valueForKey:@"CashInType"]];
            
            if(![strCashType isEqualToString:@"Cash"])
            {
                htmlForTenderCardData = [htmlForTenderCardData stringByAppendingFormat:@"<tr><td>%@</td><td><div align=\"right\">%@ </div></td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[currencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"Amount"]]];
            }
        }
    }
    return htmlForTenderCardData;
}
-(BOOL)isRcrGasActive:(NSArray *)array
{
    BOOL isRcrActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@",@"RCRGAS"];
    NSArray *rcrArray = [array filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}
- (NSString *)htmlForOverShort {
    
    NSString *htmlForOverShort = @"";
    /*NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (_rmsDbController.globalDict)[@"DeviceId"]];
    
    NSArray *activeModulesArray = [[_rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    BOOL isRcrGasActive = [self isRcrGasActive:activeModulesArray];

    
    NSString *htmlForOverShort = @"";
    htmlForOverShort = [htmlForOverShort stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    double doubleOverShort;
    NSNumber *doubleOverShortnumber;
    if(isRcrGasActive){
        doubleOverShort = [self calculateSum3WithTenderArray:[self tenderTypeDetail]withRptMain:[self reportSummary]] - [self totalFuelSales];
        doubleOverShortnumber = @(doubleOverShort);
    }
    else{
        doubleOverShort = [self calculateSum3WithTenderArray:[self tenderTypeDetail]withRptMain:[self reportSummary]] - [self calculateSum2withRptMain:[self reportSummary]];
        doubleOverShortnumber = @(doubleOverShort);

    }*/
    
    //double doubleOverShort = [self calculateSum3WithTenderArray:[self tenderTypeDetail] withRptMain:[self reportSummary]] - [self calculateSum2withRptMain:[self reportSummary]];
    
    double sum3 = [self calculateSum3WithTenderArray:[self tenderTypeDetail] withRptMain:[self reportSummary]];
    
    double doubleOverShort =  sum3 - [self allSalesTotalAmount];
    
    NSNumber *doubleOverShortnumber = @(doubleOverShort);
    
    htmlForOverShort = [htmlForOverShort stringByAppendingFormat:@"<tr><td colspan=\"2\"><div align=\"right\"></div></td></tr><tr><td style=\"font-family:Helvetica Neue;color:#FC2001;\">%@</td><td style=\"font-family:Helvetica Neue;color:#FC2001;\" ><div align=\"right\">%@</div></td></tr>", REPORT_OVER_SHORT,[currencyFormatter stringFromNumber:doubleOverShortnumber]];
    htmlForOverShort = [htmlForOverShort stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    return htmlForOverShort;
}
-(double )totalFuelSales{
   
    double sum1 = [self calculateSum2withRptMain:[self reportSummary]];
    double sum2 = sum1 +  [self calculateNetFuelSales].floatValue;
    return sum2;
}


- (NSString *)htmlForGCLiabiality {
    return [self htmlForkey:REPORT_GC_LIABIALITY value:[currencyFormatter stringFromNumber:[self reportSummary] [@"GCLiablity"]]];
}
- (NSString *)htmlForInventory {
    return [self htmlForkey:REPORT_INVENTORY value:[currencyFormatter stringFromNumber:[self reportSummary] [@"TotalInventory"]]];
}
- (NSString *)htmlForCheckCash {
    return [self htmlForkey:REPORT_CHECK_CASH value:[currencyFormatter stringFromNumber:[self reportSummary] [@"CheckCash"]]];
}

- (NSString *)htmlForDiscount{
    return [self htmlForkey:REPORT_DISCOUNT value:[currencyFormatter stringFromNumber:[self reportSummary] [@"Discount"]]];
}
- (NSString *)htmlForNonTaxSales {
    return [self htmlForkey:REPORT_NON_TAX_SALES value:[currencyFormatter stringFromNumber:[self reportSummary] [@"NonTaxSales"]]];
}

- (NSString *)htmlForCostofGoods {
    return [self htmlForkey:REPORT_COSTOFGOODS value:[currencyFormatter stringFromNumber:[self reportSummary] [@"CostofGoods"]]];
}

- (NSString *)htmlForMargin {
    float netSales = [[self reportSummary][@"TotalSales"] doubleValue] - [[self reportSummary][@"CollectTax"]doubleValue];
    float costOfGoods = [[self reportSummary] [@"CostofGoods"] doubleValue];
    float margin;
    NSNumber *profitNumber = [self calculateProfit];
    if (profitNumber.doubleValue > 0)
        margin = (1 - (costOfGoods/ netSales)) * 100;
    else
        margin = 0;
//    NSNumber *marginNumber = @(margin);
    return [self htmlForkey:REPORT_MARGIN value:[NSString stringWithFormat:@"%.2f %%",margin]];
}

- (NSNumber *)calculateProfit {
    float netSales = [[self reportSummary][@"TotalSales"] doubleValue] - [[self reportSummary][@"CollectTax"]doubleValue];
    float costOfGoods = [[self reportSummary] [@"CostofGoods"] doubleValue];
    float profit = netSales - costOfGoods;
    NSNumber *profitNumber = @(profit);
    return profitNumber;
}

- (NSString *)htmlForProfit {
    NSNumber *profitNumber = [self calculateProfit];
    return [self htmlForkey:REPORT_PROFIT value:[currencyFormatter stringFromNumber:profitNumber]];
}

- (NSString *)htmlForNoSales {
    return [self htmlForkey:REPORT_NO_SALES value:[self reportSummary] [@"NoSales"]];
}

- (NSString *)htmlForPriceChangeCount {
    return [self htmlForkey:REPORT_PRICE_CHANGE_COUNT value:[self reportSummary] [@"PriceChangeCount"]];
}

- (NSString *)htmlForLayaway {
    return [self htmlForkey:REPORT_LAYAWAY value:[self reportSummary] [@"Layaway"]];
}
- (NSString *)htmlForVoidTrans {
    return [self htmlForkey:REPORT_VOID value:[self reportSummary] [@"AbortedTrans"]];
}

- (NSString *)htmlForCancelTrans {
    return [self htmlForkey:REPORT_CANCEL_TNX value:[self reportSummary] [@"CancelTrnxCount"]];
}
- (NSString *)htmlForLineItemVoid {
    return [self htmlForkey:REPORT_LINE_ITEM_VOID value:[self reportSummary] [@"LineItemVoid"]];
}

- (NSString *)htmlForCustomer {
    return [self htmlForkey:REPORT_CUSTOMER value:[self reportSummary] [@"CustomerCount"]];
}

- (NSString *)htmlForAvgTicket {
    return [self htmlForkey:REPORT_AVG_TICKET value:[self reportSummary] [@"AvgTicket"]];
}

- (NSString *)htmlForDiscountSection{
    NSString *htmlForDiscountSection = @"";
    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><strong><FONT SIZE = 2>Discount Type</FONT></strong></td><td class = \"TaxSales\" align=\"right\"><strong><FONT SIZE = 2>Sales</FONT></strong></td><td class = \"TaxTax\" align=\"right\"><strong><FONT SIZE = 2>Discount</FONT> </strong></td><td class = \"TaxCustCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
    
    NSDictionary *customizedDiscountDict = self.customizedDiscount;
    NSDictionary *manualDiscountDict = self.manualDiscount;
    NSDictionary *preDefinedDiscountDict = self.preDefinedDiscount;
    
    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxSales\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxTax\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxCustCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Customized",[currencyFormatter stringFromNumber:[customizedDiscountDict valueForKey:@"Sales"]],[currencyFormatter stringFromNumber:[customizedDiscountDict valueForKey:@"Amount"]],[customizedDiscountDict valueForKey:@"Count"]];
    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxSales\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxTax\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxCustCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Manual",[currencyFormatter stringFromNumber:[manualDiscountDict valueForKey:@"Sales"]],[currencyFormatter stringFromNumber:[manualDiscountDict valueForKey:@"Amount"]],[manualDiscountDict valueForKey:@"Count"]];
    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxSales\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxTax\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxCustCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"PreDefined",[currencyFormatter stringFromNumber:[preDefinedDiscountDict valueForKey:@"Sales"]],[currencyFormatter stringFromNumber:[preDefinedDiscountDict valueForKey:@"Amount"]],[preDefinedDiscountDict valueForKey:@"Count"]];
    
    return htmlForDiscountSection;
}

- (NSString *)htmlForTaxesSection{
    NSString *htmlForTaxesSection = @"";
    htmlForTaxesSection = [htmlForTaxesSection stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    htmlForTaxesSection = [htmlForTaxesSection stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    
    htmlForTaxesSection = [htmlForTaxesSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><strong><FONT SIZE = 2> Tax Type </FONT></strong></td><td class = \"TaxSales\" align=\"right\"><strong><FONT SIZE = 2>Sales Amount</FONT></strong></td><td class = \"TaxTax\" align=\"right\"><strong><FONT SIZE = 2>Tax Amount</FONT> </strong></td><td class = \"TaxCustCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
    
    NSArray *taxReport= _reportData[@"RptTax"];
    if([taxReport  isKindOfClass:[NSArray class]])
    {
        for (int itx=0; itx<taxReport.count; itx++) {
            NSDictionary *taxRptDisc = taxReport[itx];
            htmlForTaxesSection = [htmlForTaxesSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxSales\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxTax\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxCustCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[taxRptDisc valueForKey:@"Descriptions"],[currencyFormatter stringFromNumber:[taxRptDisc valueForKey:@"Sales"]],[currencyFormatter stringFromNumber:[taxRptDisc valueForKey:@"Amount"]],[taxRptDisc valueForKey:@"Count"]];
        }
    }
    return htmlForTaxesSection;
}

- (NSString *)htmlForTenderType {
    NSString *htmlForTenderType = @"";
    htmlForTenderType = [htmlForTenderType stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    
    htmlForTenderType = [htmlForTenderType stringByAppendingFormat:@"<tr><td  class = \"TederType\"><strong><FONT SIZE = 2>Tender Type</FONT></strong></td><td class = \"TederTypeAmount\" align=\"right\"><strong><FONT SIZE = 2>Amount</FONT></strong></td><td class = \"TederTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2>Avg Ticket</FONT> </strong></td><td class = \"TederTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"TederTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
    
    NSArray *tenderReport= [self tenderTypeDetail];
    if([tenderReport  isKindOfClass:[NSArray class]])
    {
        for (int itx=0; itx<tenderReport.count; itx++) {
            NSDictionary *tenderRptDisc = tenderReport[itx];
            
            double tenderAmount = [[tenderRptDisc valueForKey:@"Amount"] doubleValue];
            if (_isTipSetting)
            {
                tenderAmount = tenderAmount + [[tenderRptDisc valueForKey:@"TipsAmount"] doubleValue];
            }
            NSNumber *numTenderAmount = @(tenderAmount);
            
            htmlForTenderType = [htmlForTenderType stringByAppendingFormat:@"<tr><td class = \"TederType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TederTypeAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TederTypeAvgTicket\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TederTypePer\" align=\"right\"><FONT SIZE = 2>%.2f</FONT></td><td class = \"TederTypeCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[tenderRptDisc valueForKey:@"Descriptions"],[currencyFormatter stringFromNumber:numTenderAmount],[currencyFormatter stringFromNumber:[tenderRptDisc valueForKey:@"AvgTicket"]],[[tenderRptDisc valueForKey:@"Percentage"] floatValue],[tenderRptDisc valueForKey:@"Count"]];
        }
    }
    return htmlForTenderType;
}


- (NSString *)htmlForGiftCardPreviousBalance {
    NSString *htmlForGiftCardPreviousBalance = @"";
    htmlForGiftCardPreviousBalance = [htmlForGiftCardPreviousBalance stringByAppendingFormat:@"<tr><td><FONT SIZE = 2>GC ADY</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"",[currencyFormatter stringFromNumber:[self reportSummary] [@"TotalGCADY"]],@""];
    return htmlForGiftCardPreviousBalance;
}

- (NSString *)htmlForLoadGiftCard {
    NSString *htmlForLoadGiftCard = @"";
    htmlForLoadGiftCard = [htmlForLoadGiftCard stringByAppendingFormat:@"<tr><td><FONT SIZE = 2>Load</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[currencyFormatter stringFromNumber:[self reportSummary] [@"LoadAmount"]],[currencyFormatter stringFromNumber:[self reportSummary] [@"TotalLoadAmount"]],[self reportSummary] [@"LoadCount"]];
    return htmlForLoadGiftCard;
}

- (NSString *)htmlForRedeemGiftCard {
    NSString *htmlForRedeemGiftCard = @"";
    htmlForRedeemGiftCard = [htmlForRedeemGiftCard stringByAppendingFormat:@"<tr><td><FONT SIZE = 2>Redeem</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[currencyFormatter stringFromNumber:[self reportSummary] [@"RedeemAmount"]],[currencyFormatter stringFromNumber:[self reportSummary] [@"TotalRedeemAmount"]],[self reportSummary] [@"RedeemCount"]];
    
    return htmlForRedeemGiftCard;
}

- (NSString *)htmlForTenderTips {
    NSString *htmlForTenderTips = @"";
    if (_isTipSetting) {
        htmlForTenderTips = [htmlForTenderTips stringByAppendingFormat:@"</td><tr><td><table style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
        
        htmlForTenderTips = [htmlForTenderTips stringByAppendingFormat:@"<tr><td class = \"TipsTederType\"><strong><FONT SIZE = 2>Type</FONT></strong></td><td class = \"TipsTederAmount\" align=\"right\" ><strong><FONT SIZE = 2>Amount</FONT></strong></td><td class = \"TipsTeder\" align=\"right\"><strong><FONT SIZE = 2>Tips</FONT> </strong></td><td class = \"TipsTederTotal\" align=\"right\"><strong><FONT SIZE = 2>Total</FONT></strong></td></tr>"];
        
        NSArray *tenderReport= [self tenderTypeDetail];
        if([tenderReport  isKindOfClass:[NSArray class]])
        {
            for (int itx=0; itx<tenderReport.count; itx++) {
                NSDictionary *tenderRptDisc = tenderReport[itx];
                
                double tenderAmount = [[tenderRptDisc valueForKey:@"Amount"] doubleValue] + [[tenderRptDisc valueForKey:@"TipsAmount"] doubleValue];
                NSNumber *numTenderAmount = @(tenderAmount);
                
                htmlForTenderTips = [htmlForTenderTips stringByAppendingFormat:@"<tr><td class = \"TipsTederType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TipsTederAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TipsTeder\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TipsTederTotal\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[tenderRptDisc valueForKey:@"Descriptions"],[currencyFormatter stringFromNumber:[tenderRptDisc valueForKey:@"Amount"]],[currencyFormatter stringFromNumber:[tenderRptDisc valueForKey:@"TipsAmount"]],[currencyFormatter stringFromNumber:numTenderAmount]];
            }
        }
    }
    return htmlForTenderTips;
}

- (NSString *)htmlForCardType
{
    NSString *htmlForCardType = @"";
    htmlForCardType = [htmlForCardType stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (_rmsDbController.globalDict)[@"DeviceId"]];
    
    NSArray *activeModulesArray = [[_rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    
    if([self isRcrGasActive:activeModulesArray]){
        
        htmlForCardType = [htmlForCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><strong><FONT SIZE = 2>Inside</FONT></strong></td><td class = \"CardTypeAmount\" align=\"right\" ><strong><FONT SIZE = 2></FONT></strong></td><td class = \"CardTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2></FONT> </strong></td><td class = \"CardTypeTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"CardTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2></FONT> </strong></p></td></tr>"];
    }
    
    htmlForCardType = [htmlForCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><strong><FONT SIZE = 2>Card Type</FONT></strong></td><td class = \"CardTypeAmount\" align=\"right\" ><strong><FONT SIZE = 2>Amount</FONT></strong></td><td class = \"CardTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2>Avg Ticket</FONT> </strong></td><td class = \"CardTypeTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"CardTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
    
    NSMutableArray *cardTypeReportMain = [[self cardTypeDetail] mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterType like %@",@"NotOutside"];
    NSMutableArray *cardTypeReport= [[cardTypeReportMain filteredArrayUsingPredicate:predicate] mutableCopy];
    
    if([cardTypeReport isKindOfClass:[NSArray class]])
    {
        for (int itx=0; itx<cardTypeReport.count; itx++) {
            NSMutableDictionary *cardTypeRptDisc = cardTypeReport[itx];
            htmlForCardType = [htmlForCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><FONT SIZE = 2>%@</FONT></td><td class = \"CardTypeAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"CardTypeAvgTicket\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"CardTypeTypePer\" align=\"right\"><FONT SIZE = 2>%.2f</FONT></td><td class = \"CardTypeCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[cardTypeRptDisc valueForKey:@"CardType"],[currencyFormatter stringFromNumber:[cardTypeRptDisc valueForKey:@"Amount"]],[currencyFormatter stringFromNumber:[cardTypeRptDisc valueForKey:@"AvgTicket"]],[[cardTypeRptDisc valueForKey:@"Percentage"] floatValue],[cardTypeRptDisc valueForKey:@"Count"]];
        }
    }
    return htmlForCardType;

}
- (NSString *)htmlForCardTypeOutSide
{
    NSString *htmlForCardType = @"";
    htmlForCardType = [htmlForCardType stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    
    htmlForCardType = [htmlForCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><strong><FONT SIZE = 2>OutSide</FONT></strong></td><td class = \"CardTypeAmount\" align=\"right\" ><strong><FONT SIZE = 2></FONT></strong></td><td class = \"CardTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2></FONT> </strong></td><td class = \"CardTypeTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"CardTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2></FONT> </strong></p></td></tr>"];
    
    htmlForCardType = [htmlForCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><strong><FONT SIZE = 2>Card Type</FONT></strong></td><td class = \"CardTypeAmount\" align=\"right\" ><strong><FONT SIZE = 2>Amount</FONT></strong></td><td class = \"CardTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2>Avg Ticket</FONT> </strong></td><td class = \"CardTypeTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"CardTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
    
    NSMutableArray *cardTypeReportMain = [[self cardTypeDetail] mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterType like %@",@"Outside"];
    NSMutableArray *cardTypeReport= [[cardTypeReportMain filteredArrayUsingPredicate:predicate] mutableCopy];
    
    if([cardTypeReport isKindOfClass:[NSArray class]])
    {
        for (int itx=0; itx<cardTypeReport.count; itx++) {
            NSMutableDictionary *cardTypeRptDisc = cardTypeReport[itx];
            htmlForCardType = [htmlForCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><FONT SIZE = 2>%@</FONT></td><td class = \"CardTypeAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"CardTypeAvgTicket\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"CardTypeTypePer\" align=\"right\"><FONT SIZE = 2>%.2f</FONT></td><td class = \"CardTypeCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[cardTypeRptDisc valueForKey:@"CardType"],[currencyFormatter stringFromNumber:[cardTypeRptDisc valueForKey:@"Amount"]],[currencyFormatter stringFromNumber:[cardTypeRptDisc valueForKey:@"AvgTicket"]],[[cardTypeRptDisc valueForKey:@"Percentage"] floatValue],[cardTypeRptDisc valueForKey:@"Count"]];
        }
    }
    return htmlForCardType;
}


- (NSString *)htmlForGasFuelSummery{
    NSString *htmlForGasFuelSummery = @"";
    htmlForGasFuelSummery = [htmlForGasFuelSummery stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    htmlForGasFuelSummery = [htmlForGasFuelSummery stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    
    htmlForGasFuelSummery = [htmlForGasFuelSummery stringByAppendingFormat:@"<tr><td class = \"Group20FuelType\"><strong><FONT SIZE = 2>Fuel Type</FONT></strong></td><td class = \"Group20Amount\" align=\"right\"><strong><FONT SIZE = 2>Amount</FONT></strong></td><td class = \"Group20Gallons\" align=\"right\"><strong><FONT SIZE = 2>Gallons</FONT> </strong></td><td class = \"Group20Count\" align=\"right\"><p><strong><FONT SIZE = 2>Cust. Count</FONT> </strong></p></td></tr>"];
    
    NSMutableArray *fuelTypes = [[self fuelTypeDetail]mutableCopy];
    
    for (NSMutableDictionary *fuelType in fuelTypes) {
        
        float gallons = [fuelType [@"PricePerGallon"] floatValue];
        NSNumber *numGallons = @(gallons);
        
        float fuelamount = [fuelType [@"amount"] floatValue];
        NSNumber *numFuelAmount = @(fuelamount);
        
        NSInteger gasCustomerCount = [fuelType [@"PumpCount"] integerValue];
        
        NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
        
        htmlForGasFuelSummery = [htmlForGasFuelSummery stringByAppendingFormat:@"<tr><td class = \"Group20FuelType\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20Amount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20Gallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20Count\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",fuelType[@"FuelTypeLabelTitle"],[self currencyFormattedAmount:numFuelAmount],numGallons,gasCustomerCountString];
    }
    
    NSNumber *totalnumGallons = [fuelTypes valueForKeyPath:@"@sum.PricePerGallon"];
    NSNumber *totalnumFuelAmount = [fuelTypes valueForKeyPath:@"@sum.amount"];
    NSNumber *totalCustCount = [fuelTypes valueForKeyPath:@"@sum.PumpCount"];
    
    htmlForGasFuelSummery = [htmlForGasFuelSummery stringByAppendingFormat:@"<tr><td class = \"Group20FuelType\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group20Amount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group20Gallons\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group20Count\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td></tr>",@"Total",[self currencyFormattedAmount:totalnumFuelAmount],totalnumGallons,totalCustCount];
    htmlForGasFuelSummery = [htmlForGasFuelSummery stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    return htmlForGasFuelSummery;
}
- (NSString *)htmlForGasPumpSummery{
    NSString *htmlForGasPumpSummery = @"";
    htmlForGasPumpSummery = [htmlForGasPumpSummery stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    htmlForGasPumpSummery = [htmlForGasPumpSummery stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    
    htmlForGasPumpSummery = [htmlForGasPumpSummery stringByAppendingFormat:@"<tr><td class = \"Group20FuelType\"><strong><FONT SIZE = 2>Pump #</FONT></strong></td><td class = \"Group20Amount\" align=\"right\"><strong><FONT SIZE = 2>Amount</FONT></strong></td><td class = \"Group20Gallons\" align=\"right\"><strong><FONT SIZE = 2>Gallons</FONT> </strong></td><td class = \"Group20Count\" align=\"right\"><p><strong><FONT SIZE = 2>Cust. Count</FONT> </strong></p></td></tr>"];
    
    NSMutableArray *pumps = [[self pumpDetail]mutableCopy];
    
    for (NSMutableDictionary *pumpInfo in pumps) {
        
        float gallons = [pumpInfo [@"Volume"] floatValue];
        NSNumber *numGallons = @(gallons);
        
        float fuelamount = [pumpInfo [@"amount"] floatValue];
        NSNumber *numFuelAmount = @(fuelamount);
        
        NSInteger gasCustomerCount = [pumpInfo [@"PumpCount"] integerValue];
        
        NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
        
        htmlForGasPumpSummery = [htmlForGasPumpSummery stringByAppendingFormat:@"<tr><td class = \"Group20FuelType\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20Amount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20Gallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20Count\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",pumpInfo[@"PumpName"],[self currencyFormattedAmount:numFuelAmount],numGallons,gasCustomerCountString];
    }
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setMaximumFractionDigits:3];
    
    NSNumber *totalnumGallons = [pumps valueForKeyPath:@"@sum.Volume"];
    NSNumber *totalnumFuelAmount = [pumps valueForKeyPath:@"@sum.amount"];
    NSNumber *totalCustCount = [pumps valueForKeyPath:@"@sum.PumpCount"];
    
    htmlForGasPumpSummery = [htmlForGasPumpSummery stringByAppendingFormat:@"<tr><td class = \"Group20FuelType\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group20Amount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group20Gallons\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group20Count\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td></tr>",@"Total",[self currencyFormattedAmount:totalnumFuelAmount],[fmt stringFromNumber: totalnumGallons],totalCustCount];
    htmlForGasPumpSummery = [htmlForGasPumpSummery stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    return htmlForGasPumpSummery;
}


- (NSString *)htmlForDepartment {
    NSString *htmlForDepartment = @"";
    htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    

    htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    
    htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><strong><FONT SIZE = 2>Merchandise</FONT></strong></td><td class = \"DepartmentCost\" align=\"right\"><strong><FONT SIZE = 2></FONT></strong></td><td class = \"DepartmentAmount\" align=\"right\"><strong><FONT SIZE = 2></FONT> </strong></td><td class = \"DepartmentMargin\" align=\"right\"><p><strong><FONT SIZE = 2></FONT> </strong></p></td><td class = \"DepartmentPer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"DepartmentCount\" align=\"right\"><p><strong><FONT SIZE = 2></FONT> </strong></p></td></tr>"];
    
    htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><strong><FONT SIZE = 2>Department</FONT></strong></td><td class = \"DepartmentCost\" align=\"right\"><strong><FONT SIZE = 2>Cost</FONT></strong></td><td class = \"DepartmentAmount\" align=\"right\"><strong><FONT SIZE = 2>Price</FONT> </strong></td><td class = \"DepartmentMargin\" align=\"right\"><p><strong><FONT SIZE = 2>Margin (%%)</FONT> </strong></p></td><td class = \"DepartmentPer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"DepartmentCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
    
    NSArray *departments = [self fetchNonPayOutDepartmentsWithMerchandise:YES];

    htmlForDepartment = [self generateHtmlFromArray:departments withString:htmlForDepartment];
    
    return htmlForDepartment;
}

- (NSString *)htmlForNonMerchandiseDepartment {
    
    NSString *htmlForNonMerchandiseDepartment = @"";
    
    htmlForNonMerchandiseDepartment = [htmlForNonMerchandiseDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><strong><FONT SIZE = 2>Non Merchandise</FONT></strong></td><td class = \"DepartmentCost\" align=\"right\"><strong><FONT SIZE = 2></FONT></strong></td><td class = \"DepartmentAmount\" align=\"right\"><strong><FONT SIZE = 2></FONT> </strong></td><td class = \"DepartmentMargin\" align=\"right\"><p><strong><FONT SIZE = 2></FONT> </strong></p></td><td class = \"DepartmentPer\" align=\"right\"><p><strong><FONT SIZE = 2></FONT> </strong></p></td><td class = \"DepartmentCount\" align=\"right\"><p><strong><FONT SIZE = 2></FONT> </strong></p></td></tr>"];
    
    htmlForNonMerchandiseDepartment = [htmlForNonMerchandiseDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><strong><FONT SIZE = 2>Department</FONT></strong></td><td class = \"DepartmentCost\" align=\"right\"><strong><FONT SIZE = 2>Cost</FONT></strong></td><td class = \"DepartmentAmount\" align=\"right\"><strong><FONT SIZE = 2>Price</FONT> </strong></td><td class = \"DepartmentMargin\" align=\"right\"><p><strong><FONT SIZE = 2>Margin (%%)</FONT> </strong></p></td><td class = \"DepartmentPer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"DepartmentCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
    
    NSArray *departments = [self fetchNonPayOutDepartmentsWithMerchandise:NO];
    
    htmlForNonMerchandiseDepartment = [self generateHtmlFromArray:departments withString:htmlForNonMerchandiseDepartment];
    return htmlForNonMerchandiseDepartment;

    }

- (NSString *)generateHtmlFromArray:(NSArray *)array withString:(NSString *)htmlForDepartment
{
    for (int idpt=0; idpt<array.count; idpt++) {
        NSMutableDictionary *departRptDisc=array[idpt];
        NSString *departmentName = @"";
        if ([[departRptDisc valueForKey:@"Descriptions"] isKindOfClass:[NSString class]]) {
            if (![[departRptDisc valueForKey:@"Descriptions"] isEqualToString:@"<null>"]) {
                if ([[departRptDisc valueForKey:@"Descriptions"] length] > 18) {
                    departmentName = [[departRptDisc valueForKey:@"Descriptions"] substringToIndex:18];
                    departmentName = [departmentName stringByAppendingString:@"..."];
                }
                else
                {
                    departmentName = [departRptDisc valueForKey:@"Descriptions"];
                }
            }
        }
        
        htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\" colspan= \"5\" ><FONT SIZE = 2>%@</FONT></td></tr>",departmentName];
        
        htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><FONT SIZE = 2>%@</FONT></td><td class = \"DepartmentCost\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"DepartmentAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"DepartmentMargin\" align=\"right\" style=\"padding-right:24px\"><FONT SIZE = 2>%.2f</FONT></td><td class = \"DepartmentPer\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"DepartmentCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"",[currencyFormatter stringFromNumber:[departRptDisc valueForKey:@"Cost"]],[currencyFormatter stringFromNumber:[departRptDisc valueForKey:@"Amount"]],[[departRptDisc valueForKey:@"Margin"] floatValue],[NSString stringWithFormat:@"%.2f",[[departRptDisc valueForKey:@"Per"] floatValue]],[departRptDisc valueForKey:@"Count"]];
    }
    return htmlForDepartment;
}

- (NSString *)htmlForPayOutDepartment {
    NSString *htmlForPayOutDepartment = @"";
    htmlForPayOutDepartment = [htmlForPayOutDepartment stringByAppendingFormat:@"<tr><td width=400px><strong><FONT SIZE = 2>P/O</FONT></strong></td>"];
    NSArray *departments = [self fetchPayOutDepartments:YES];
    htmlForPayOutDepartment = [self generateHtmlFromArray:departments withString:htmlForPayOutDepartment];
    return htmlForPayOutDepartment;
}

- (NSString *)htmlForHourlySales {
    NSString *htmlForHourlySales = @"";
    htmlForHourlySales = [htmlForHourlySales stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForHourlySales = [htmlForHourlySales stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    htmlForHourlySales = [htmlForHourlySales stringByAppendingFormat:@"<tr><td class = \"HourlySales\"><strong><FONT SIZE = 2>HourlySales</FONT></strong></td><td class = \"HourlySalesCost\" align=\"right\"><strong><FONT SIZE = 2>Cost</FONT></strong></td><td class = \"HourlySalesAmount\" align=\"right\"><strong><FONT SIZE = 2>Price</FONT> </strong></td><td class = \"HourlySalesMargin\" align=\"right\"><p><strong><FONT SIZE = 2>Margin (%%)</FONT> </strong></p></td><td class = \"HourlySalesCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
    
    NSMutableArray *hoursReport = _reportData [@"RptHours"];
    if([hoursReport isKindOfClass:[NSArray class]])
    {
        for (int idpt=0; idpt<hoursReport.count; idpt++) {
            NSMutableDictionary *hoursRptDisc=hoursReport[idpt];
            NSString *dateReturn= [NSString stringWithFormat:@"%@",[hoursRptDisc valueForKey:@"Hours"]];
        
            NSString *stringFromDate;
            
            if([self checkisJSonDate:dateReturn]){
               
                NSDate *date=[self jsonStringToNSDate:dateReturn];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                formatter.dateFormat = @"hh:mm a";
                stringFromDate = [formatter stringFromDate:date];
            }
            else{
                stringFromDate = dateReturn;
            }
            
            
            htmlForHourlySales = [htmlForHourlySales stringByAppendingFormat:@"<tr><td class = \"HourlySales\"><FONT SIZE = 2>%@</FONT></td><td class = \"HourlySalesCost\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"HourlySalesAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"HourlySalesMargin\" align=\"right\"><FONT SIZE = 2>%.2f</FONT></td><td class = \"HourlySalesCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",stringFromDate,[currencyFormatter stringFromNumber:[hoursRptDisc valueForKey:@"Cost"]],[currencyFormatter stringFromNumber:[hoursRptDisc valueForKey:@"Amount"]],[[hoursRptDisc valueForKey:@"Margin"] floatValue],[hoursRptDisc valueForKey:@"Count"]];
        }
    }
    return htmlForHourlySales;
}
-(BOOL)checkisJSonDate:(NSString *)strDate{
    BOOL isJsonDate = NO;
    if ([strDate rangeOfString:@"/Date"].location != NSNotFound)
    {
        isJsonDate = YES;
    }

    return isJsonDate;
}

- (NSString *)htmlForGroup20ASection{
    NSString *htmlForGroup20ASection = @"";
    htmlForGroup20ASection = [htmlForGroup20ASection stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    htmlForGroup20ASection = [htmlForGroup20ASection stringByAppendingFormat:@"<tr><td class = \"Group20AGFS\"><strong><FONT SIZE = 2>Total Fuel Summary</FONT></strong></td></tr>"];

    htmlForGroup20ASection = [htmlForGroup20ASection stringByAppendingFormat:@"<tr><td class = \"Group20AGFS\"><strong><FONT SIZE = 2>GrossFuelSales</FONT></strong></td><td class = \"Group20AGallons\" align=\"right\"><strong><FONT SIZE = 2>Gallons</FONT></strong></td><td class = \"Group20AAmount\" align=\"right\"><strong><FONT SIZE = 2>Amount</FONT> </strong></td><td class = \"Group20ACount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];

    NSDictionary *rptMainDict = [self reportSummary];
    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
    
    NSString *gasCustomerCount = [NSString stringWithFormat:@"%ld",(long)[rptMainDict [@"GasCustomerCount"] integerValue]];
    float fuelPrice = [rptMainDict [@"GrossFuelSales"] floatValue];
    
    NSNumber *numFuelPrice = @(fuelPrice);
    float fuelRefund = [rptMainDict [@"FuelRefund"] floatValue];
    
    NSNumber *numFuelRefund = @(fuelRefund);
    float netFuelSales = [rptMainDict [@"GrossFuelSales"] floatValue] - [rptMainDict [@"FuelRefund"] floatValue];
    
    NSNumber *numNetFuelSales = @(netFuelSales);

    htmlForGroup20ASection = [htmlForGroup20ASection stringByAppendingFormat:@"<tr><td class = \"Group20AGFS\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Other",gallonString,[self currencyFormattedAmount:numFuelPrice],gasCustomerCount];
    htmlForGroup20ASection = [htmlForGroup20ASection stringByAppendingFormat:@"<tr><td class = \"Group20AGFS\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Fuel Refund",@"",[self currencyFormattedAmount:numFuelRefund],@"0"];
    htmlForGroup20ASection = [htmlForGroup20ASection stringByAppendingFormat:@"<tr><td class = \"Group20AGFS\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Net Fuel Sales",@"",[self currencyFormattedAmount:numNetFuelSales],@"0"];
    htmlForGroup20ASection = [htmlForGroup20ASection stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForGroup20ASection = [htmlForGroup20ASection stringByAppendingFormat:@"</table></font></td></tr>"];

    return htmlForGroup20ASection;
}

- (NSString *)htmlForGroup20Section{
    NSString *htmlForGroup20Section = @"";
    htmlForGroup20Section = [htmlForGroup20Section stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForGroup20Section = [htmlForGroup20Section stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    htmlForGroup20Section = [htmlForGroup20Section stringByAppendingFormat:@"<tr><td class = \"Group20FuelType\"><strong><FONT SIZE = 2>Fueling Summary</FONT></strong></td></tr>"];
    
    htmlForGroup20Section = [htmlForGroup20Section stringByAppendingFormat:@"<tr><td class = \"Group20FuelType\"><strong><FONT SIZE = 2>Fuel Type</FONT></strong></td><td class = \"Group20Amount\" align=\"right\"><strong><FONT SIZE = 2>$</FONT></strong></td><td class = \"Group20Gallons\" align=\"right\"><strong><FONT SIZE = 2>Gallons</FONT> </strong></td><td class = \"Group20Count\" align=\"right\"><p><strong><FONT SIZE = 2>Cust. Count</FONT> </strong></p></td></tr>"];
    
    NSDictionary *rptMainDict = [self reportSummary];
    float fuelPrice = [rptMainDict [@"FuelPrice"] floatValue];
    NSInteger gasCustomerCount = [rptMainDict [@"GasCustomerCount"] integerValue];
    
    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
    
    NSNumber *numFuelPrice = @(fuelPrice);
    NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
    
    
    htmlForGroup20Section = [htmlForGroup20Section stringByAppendingFormat:@"<tr><td class = \"Group20FuelType\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20Amount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20Gallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group20Count\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Other",[self currencyFormattedAmount:numFuelPrice],gallonString,gasCustomerCountString];
    htmlForGroup20Section = [htmlForGroup20Section stringByAppendingFormat:@"<tr><td class = \"Group20FuelType\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group20Amount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group20Gallons\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group20Count\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td></tr>",@"Total",[self currencyFormattedAmount:numFuelPrice],gallonString,gasCustomerCountString];
    htmlForGroup20Section = [htmlForGroup20Section stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];

    return htmlForGroup20Section;
}

- (NSString *)htmlForGroup21Section{
    NSString *htmlForGroup21Section = @"";
    htmlForGroup21Section = [htmlForGroup21Section stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForGroup21Section = [htmlForGroup21Section stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    htmlForGroup21Section = [htmlForGroup21Section stringByAppendingFormat:@"<tr><td class = \"Group21FuelType\"><strong><FONT SIZE = 2>Fuel Trnx</FONT></strong></td></tr>"];

    htmlForGroup21Section = [htmlForGroup21Section stringByAppendingFormat:@"<tr><td class = \"Group21FuelType\"><strong><FONT SIZE = 2>Fuel Type</FONT></strong></td><td class = \"Group21Amount\" align=\"right\"><strong><FONT SIZE = 2>$</FONT></strong></td><td class = \"Group21Gallons\" align=\"right\"><strong><FONT SIZE = 2>Gallons</FONT> </strong></td><td class = \"Group21Count\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
    
    NSDictionary *rptMainDict = [self reportSummary];
    float fuelPrice = [rptMainDict [@"FuelPrice"] floatValue];
    NSInteger gasCustomerCount = [rptMainDict [@"GasCustomerCount"] integerValue];
    
    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
    
    NSNumber *numFuelPrice = @(fuelPrice);
    NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
    
    
    htmlForGroup21Section = [htmlForGroup21Section stringByAppendingFormat:@"<tr><td class = \"Group21FuelType\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group21Amount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group21Gallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group21Count\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Other",[self currencyFormattedAmount:numFuelPrice],gallonString,gasCustomerCountString];
    htmlForGroup21Section = [htmlForGroup21Section stringByAppendingFormat:@"<tr><td class = \"Group21FuelType\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group21Amount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group21Gallons\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group21Count\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td></tr>",@"Total",[self currencyFormattedAmount:numFuelPrice],gallonString,gasCustomerCountString];
    htmlForGroup21Section = [htmlForGroup21Section stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];

    return htmlForGroup21Section;
}

- (NSString *)htmlForGroup22Section{
    NSString *htmlForGroup22Section = @"";
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><strong><FONT SIZE = 2>Fuel Inventory</FONT></strong></td></tr>"];
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><strong><FONT SIZE = 2>Fuel Type</FONT></strong></td></tr>"];

    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><strong><FONT SIZE = 2>Starting Gallons</FONT></strong></td><td class = \"Group22Delivery\" align=\"right\"><strong><FONT SIZE = 2>Delivery</FONT></strong></td><td class = \"Group22EG\" align=\"right\"><strong><FONT SIZE = 2>Ending Gallons</FONT> </strong></td><td class = \"Group22Difference\" align=\"right\"><p><strong><FONT SIZE = 2>Difference</FONT> </strong></p></td></tr>"];
    
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><FONT SIZE = 2>Other</FONT></td></tr>"];
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22Delivery\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22EG\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22Difference\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"0.00",@"0.00",@"0.00",@"0.00"];
    
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><strong><FONT SIZE = 2>Total</FONT></strong></td></tr>"];
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group22Delivery\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group22EG\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group22Difference\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td></tr>",@"0.00",@"0.00",@"0.00",@"0.00"];
    
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group22Delivery\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22EG\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22Difference\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"",@"",@"",@""];

    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group22Delivery\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22EG\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22Difference\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"PriceChanges",@"",@"",@""];

    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group22Delivery\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22EG\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22Difference\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Fuel Type",@"",@"",@""];

    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group22Delivery\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22EG\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22Difference\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Other",@"",@"",@""];

    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group22Delivery\" align=\"right\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group22EG\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group22Difference\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td></tr>",@"Price",@"Gallons",@"Amount",@"Count"];

    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22Delivery\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22EG\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22Difference\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"$0.00",@"0.00",@"$0.00",@"0"];
  
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22Delivery\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22EG\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group22Difference\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"$0.00",@"0.00",@"$0.00",@"0"];

    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group22Delivery\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group22EG\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group22Difference\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td></tr>",@"Average Price",@"Total Gallons",@"Total Amount",@"Total Count"];

    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td class = \"Group22SG\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group22Delivery\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group22EG\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"Group22Difference\" align=\"right\"><p><strong><FONT SIZE = 2>%@</FONT> </strong></p></td></tr>",@"$0.00",@"0.00",@"$0.00",@"0"];
  
    htmlForGroup22Section = [htmlForGroup22Section stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];

    return htmlForGroup22Section;
}


- (NSString *)htmlForGroup23ASection{
    NSString *htmlForGroup23ASection = @"";
    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];

    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><strong><FONT SIZE = 2></FONT></strong></td><td class = \"Group23AGallons\" align=\"right\"><strong><FONT SIZE = 2>Gallons</FONT></strong></td><td class = \"Group23AAmount\" align=\"right\"><strong><FONT SIZE = 2>Amount</FONT> </strong></td><td class = \"Group23ACount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
    
    NSDictionary *rptMainDict = [self reportSummary];
    NSNumber *numNetFuelSales = [self calculateNetFuelSales];
    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
    NSInteger gasCustomerCount = [rptMainDict [@"GasCustomerCount"] integerValue];
    NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
    [self defaultFormatForFourColumn];

    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"TotalFuelTrnx",gallonString,[self currencyFormattedAmount:numNetFuelSales],gasCustomerCountString];
    
    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Other Trnx",gallonString,[self currencyFormattedAmount:numNetFuelSales],gasCustomerCountString];

    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"VoidFuelTrnx",@"0.0",@"$0.00",@"0"];


    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"LineItemDelete",@"0.0",@"$0.00",@"0"];
    
    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"CancelTrnx",@"0.0",@"$0.00",@"0"];

    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"PriceChanges",@"0.0",@"$0.00",@"0"];

    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"DriveOffs",@"0.0",@"$0.00",@"0"];

    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group23AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"FuelType",@"",@"",@""];

    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2><strong>%@</FONT></strong></td><td class = \"Group23AGallons\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group23AAmount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group23ACount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td></tr>",@"Amount",@"Gallons",@"Count",@"Gas Price"];
    
    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Other",@"",@"",@""];
    
    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td class = \"Group23A\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AGallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23AAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"$0.00",@"0.00",@"0",@"$0.00"];
    
    htmlForGroup23ASection = [htmlForGroup23ASection stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];

    return htmlForGroup23ASection;
}


- (NSString *)htmlForGroup23BSection{
    NSString *htmlForGroup23BSection = @"";
    htmlForGroup23BSection = [htmlForGroup23BSection stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForGroup23BSection = [htmlForGroup23BSection stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];

    htmlForGroup23BSection = [htmlForGroup23BSection stringByAppendingFormat:@"<tr><td class = \"Group23BGallons\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group23BAmount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group23BTotal\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"Group23ACount\" align=\"right\"><p><strong><FONT SIZE = 2>%@</FONT> </strong></p></td></tr>",@"Fuel Sales by Pump",@"",@"",@""];
    htmlForGroup23BSection = [htmlForGroup23BSection stringByAppendingFormat:@"<tr><td class = \"Group23BGallons\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group23BAmount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group23BTotal\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"Group23ACount\" align=\"right\"><p><strong><FONT SIZE = 2>%@</FONT> </strong></p></td></tr>",@"Unknown Pump",@"",@"",@""];

    htmlForGroup23BSection = [htmlForGroup23BSection stringByAppendingFormat:@"<tr><td class = \"Group23BGallons\"><strong><FONT SIZE = 2>Gallons</FONT></strong></td><td class = \"Group23BAmount\" align=\"right\"><strong><FONT SIZE = 2>Amount</FONT></strong></td><td class = \"Group23BTotal\" align=\"right\"><strong><FONT SIZE = 2>Total</FONT> </strong></td><td class = \"Group23ACount\" align=\"right\"><p><strong><FONT SIZE = 2>Customer Count</FONT> </strong></p></td></tr>"];
  
    htmlForGroup23BSection = [htmlForGroup23BSection stringByAppendingFormat:@"<tr><td class = \"Group23BGallons\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23BAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23BTotal\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Other",@"",@"",@""];
    
    NSDictionary *rptMainDict = [self reportSummary];
    CGFloat netFuelSales = [rptMainDict [@"GrossFuelSales"] floatValue] - [rptMainDict [@"FuelRefund"] floatValue];
    NSString *netFuelSalesString = [NSString stringWithFormat:@"$%.2f",netFuelSales];
    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
    NSInteger gasCustomerCount = [rptMainDict [@"GasCustomerCount"] integerValue];
    NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];

    htmlForGroup23BSection = [htmlForGroup23BSection stringByAppendingFormat:@"<tr><td class = \"Group23BGallons\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23BAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23BTotal\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group23ACount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",gallonString,netFuelSalesString,@"$0.00",gasCustomerCountString];

    htmlForGroup23BSection = [htmlForGroup23BSection stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    return htmlForGroup23BSection;
}

- (NSString *)htmlForGroup24Section{
    NSString *htmlForGroup24Section = @"";
    htmlForGroup24Section = [htmlForGroup24Section stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    htmlForGroup24Section = [htmlForGroup24Section stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    
    htmlForGroup24Section = [htmlForGroup24Section stringByAppendingFormat:@"<tr><td class = \"Group24FuelType\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group24Gallons\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group24Amount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"Group24Count\" align=\"right\"><p><strong><FONT SIZE = 2>%@</FONT> </strong></p></td></tr>",@"HourlyGasSales",@"",@"",@""];
    
    
    NSArray *rptGASHoursArray = _reportData [@"RptGASHours"];
    NSArray *fuelTypeArray = @[@{ @"FuelType":@"Other",
                                  }];
    
    if([rptGASHoursArray isKindOfClass:[NSArray class]]){
     
        for (NSDictionary *rptGASHoursDictionary in rptGASHoursArray) {
            NSString *stringFromDate;
            NSDate *date=[self jsonStringToNSDate:[rptGASHoursDictionary valueForKey:@"Hours"]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            formatter.dateFormat = @"hh:mm a";
            stringFromDate = [formatter stringFromDate:date];
            
            htmlForGroup24Section = [htmlForGroup24Section stringByAppendingFormat:@"<tr><td class = \"Group24FuelType\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group24Gallons\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"Group24Amount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"Group24Count\" align=\"right\"><p><strong><FONT SIZE = 2>%@</FONT> </strong></p></td></tr>",stringFromDate,@"Gallons",@"Amount",@"Customer Count"];
            
            for (NSDictionary *fuelTypeDictionary in fuelTypeArray) {
                NSString *textValue = [NSString stringWithFormat:@"%@",fuelTypeDictionary[@"FuelType"]];
                NSString *text1 = textValue;
                textValue = [NSString stringWithFormat:@"%.2f",[rptGASHoursDictionary[@"Gallons"] floatValue]];
                NSString *text2 = textValue;
                textValue = [NSString stringWithFormat:@"$%.2f",[rptGASHoursDictionary[@"Amount"] floatValue]];
                NSString *text3 = textValue;
                textValue = [NSString stringWithFormat:@"%ld",(long)[rptGASHoursDictionary[@"Count"] integerValue]];
                NSString *text4 = textValue;
                htmlForGroup24Section = [htmlForGroup24Section stringByAppendingFormat:@"<tr><td class = \"Group24FuelType\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group24Gallons\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group24Amount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"Group24Count\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",text1,text2,text3,text4];
            }
        }

    }

    return htmlForGroup24Section;
}



#pragma mark - Html Section Header Report

- (NSString *)htmlHeaderForSectionHeader {
    NSString *htmlHeaderForSectionHeader = @"";
    return htmlHeaderForSectionHeader;
}

- (NSString *)htmlHeaderForSectionSales {
    NSString *htmlHeaderForSectionSales = @"";
    return htmlHeaderForSectionSales;
}
- (NSString *)htmlHeaderForSectionPetroSales {
    NSString *htmlHeaderForSectionPetroSales = @"";
    return htmlHeaderForSectionPetroSales;
}
- (NSString *)htmlHeaderForDailySales {
    NSString *htmlHeaderForDailySales = @"";
    return htmlHeaderForDailySales;
}
- (NSString *)htmlHeaderForSection3 {
    NSString *htmlHeaderForSectionHeader = @"";
    return htmlHeaderForSectionHeader;
}

- (NSString *)htmlHeaderForSection4 {
    NSString *htmlHeaderForSection4 = @"";
    return htmlHeaderForSection4;
}
- (NSString *)htmlHeaderForOpeningAmount {
    NSString *htmlHeaderForOpeningAmount = @"";
    return htmlHeaderForOpeningAmount;
}
- (NSString *)htmlHeaderForNoneSales {
    NSString *htmlHeaderForNoneSales = @"";
    htmlHeaderForNoneSales = [htmlHeaderForNoneSales stringByAppendingFormat:@"<tr><td><strong>Default</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    return htmlHeaderForNoneSales;
}
- (NSString *)htmlHeaderForMerchandiseSales {
    NSString *htmlHeaderForMerchandiseSales = @"";
    htmlHeaderForMerchandiseSales = [htmlHeaderForMerchandiseSales stringByAppendingFormat:@"<tr><td><strong>Merchandise</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    return htmlHeaderForMerchandiseSales;
}
- (NSString *)htmlHeaderForAllTaxes {
    NSString *htmlHeaderForAllTaxes = @"";
    return htmlHeaderForAllTaxes;
}

- (NSString *)htmlHeaderForAllTaxesDetails {
    NSString *htmlHeaderForAllTaxesDetails = @"";
    return htmlHeaderForAllTaxesDetails;
}
- (NSString *)htmlHeaderForLotterySales {
    NSString *htmlHeaderForLotrySales = @"";
    htmlHeaderForLotrySales = [htmlHeaderForLotrySales stringByAppendingFormat:@"<tr><td><strong>Lottery</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    return htmlHeaderForLotrySales;
}
- (NSString *)htmlHeaderForGasSales {
    NSString *htmlHeaderForGasSales = @"";
    htmlHeaderForGasSales = [htmlHeaderForGasSales stringByAppendingFormat:@"<tr><td><strong>Gas</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    return htmlHeaderForGasSales;
}
- (NSString *)htmlHeaderForMoneyOrder {
    NSString *htmlHeaderForMoneyOrder = @"";
    htmlHeaderForMoneyOrder = [htmlHeaderForMoneyOrder stringByAppendingFormat:@"<tr><td><strong>Money Order</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    return htmlHeaderForMoneyOrder;
}

- (NSString *)htmlHeaderForGiftCardSales {
    NSString *htmlHeaderForGiftCardSales = @"";
    htmlHeaderForGiftCardSales = [htmlHeaderForGiftCardSales stringByAppendingFormat:@"<tr><td><strong>Gift Card</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    return htmlHeaderForGiftCardSales;
}
- (NSString *)htmlHeaderForCheckCash {
    NSString *htmlHeaderForCheckCash = @"";
    htmlHeaderForCheckCash = [htmlHeaderForCheckCash stringByAppendingFormat:@"<tr><td><strong>Check Cash</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    return htmlHeaderForCheckCash;
}
- (NSString *)htmlHeaderForVendorPayout {
    NSString *htmlHeaderForVendorPayout = @"";
    htmlHeaderForVendorPayout = [htmlHeaderForVendorPayout stringByAppendingFormat:@"<tr><td><strong>Vendor Payout</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    return htmlHeaderForVendorPayout;
}

- (NSString *)htmlHeaderForHouseCharge {
    NSString *htmlHeaderForHouseCharge = @"";
    htmlHeaderForHouseCharge = [htmlHeaderForHouseCharge stringByAppendingFormat:@"<tr><td><strong>House Charge</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    return htmlHeaderForHouseCharge;
}

- (NSString *)htmlHeaderForSalesOther {
    NSString *htmlHeaderForSalesOther = @"";
    htmlHeaderForSalesOther = [htmlHeaderForSalesOther stringByAppendingFormat:@"<tr><td><strong>Other</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    return htmlHeaderForSalesOther;
}
- (NSString *)htmlHeaderForAllSalesTotal {
    NSString *htmlHeaderForAllSalesTotal = @"";
    if(_isTipSetting){
        htmlHeaderForAllSalesTotal = [htmlHeaderForAllSalesTotal stringByAppendingFormat:@"<tr><td><strong>Tips</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",@""];
    }
    return htmlHeaderForAllSalesTotal;
}


- (NSString *)htmlHeaderForSectionOverShort {
    NSString *htmlHeaderForSectionOverShort = @"";
    return htmlHeaderForSectionOverShort;
}

- (NSString *)htmlHeaderForSection6 {
    NSString *htmlHeaderForSection6 = @"";
    return htmlHeaderForSection6;
}
- (NSString *)htmlHeaderForSection7 {
    NSString *htmlHeaderForSection7 = @"";
    return htmlHeaderForSection7;
}


- (NSString *)htmlHeaderForSectionCustomer {
    NSString *htmlHeaderForSectionCustomer = @"";
    return htmlHeaderForSectionCustomer;
}

- (NSString *)htmlHeaderForSectionDiscount {
    NSString *htmlHeaderForSectionDiscount = @"";
    return htmlHeaderForSectionDiscount;
}

- (NSString *)htmlHeaderForSectionTaxes {
    NSString *htmlHeaderForSectionTaxes = @"";
    return htmlHeaderForSectionTaxes;
}

- (NSString *)htmlHeaderForSectionPaymentMode {
    NSString *htmlHeaderForSectionPaymentMode = @"";
    return htmlHeaderForSectionPaymentMode;
}

- (NSString *)htmlHeaderForSectionTenderTips
{
    NSString *htmlHeaderForSectionTenderTips = @"";
    return htmlHeaderForSectionTenderTips;
}

- (NSString *)htmlHeaderForSectionGiftCard {
    NSString *htmlHeaderForSectionGiftCard = @"";
    htmlHeaderForSectionGiftCard = [htmlHeaderForSectionGiftCard stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
    
    htmlHeaderForSectionGiftCard = [htmlHeaderForSectionGiftCard stringByAppendingFormat:@"<tr><td><strong><FONT SIZE = 2>Gift Card</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>Register</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>Total</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>Count</FONT> </strong></td></tr>"];
    
    return htmlHeaderForSectionGiftCard;
}

- (NSString *)htmlHeaderForSectionCardType {
    NSString *htmlHeaderForSectionCardType = @"";
    return htmlHeaderForSectionCardType;
}
- (NSString *)htmlHeaderForSectionCardTypeOutSide {
    NSString *htmlHeaderForSectionCardTypeOutSide = @"";
    return htmlHeaderForSectionCardTypeOutSide;
}
- (NSString *)htmlHeaderForGasFuelSummery {
    NSString *htmlHeaderForGasFuelSummery = @"";
    return htmlHeaderForGasFuelSummery;
}
- (NSString *)htmlHeaderForGasPumpSummery {
    NSString *htmlHeaderForGasPumpSummery = @"";
    return htmlHeaderForGasPumpSummery;
}
- (NSString *)htmlHeaderForSectionDepartment {
    NSString *htmlHeaderForSectionDepartment = @"";
    return htmlHeaderForSectionDepartment;
}
- (NSString *)htmlHeaderForSectionNonMerchandiseDepartment {
    NSString *htmlHeaderForSectionNonMerchandiseDepartment = @"";
    return htmlHeaderForSectionNonMerchandiseDepartment;
}

- (NSString *)htmlHeaderForSectionPayout {
    NSString *htmlHeaderForSectionPayout = @"";
    return htmlHeaderForSectionPayout;
}

- (NSString *)htmlHeaderForHourlySales {
    NSString *htmlHeaderForHourlySales = @"";
    return htmlHeaderForHourlySales;
}


#pragma mark - Html Section Footer Report

- (NSString *)htmlFooterForSectionHeader {
    NSString *htmlFooterForSectionHeader = @"";
    return htmlFooterForSectionHeader;
}
- (NSString *)htmlFooterForSectionDaily {
    NSString *htmlFooterForSectionDaily = @"";
    return htmlFooterForSectionDaily;
}

- (NSString *)htmlFooterForSectionSales {
    NSString *htmlFooterForSectionSales = @"";
    return htmlFooterForSectionSales;
}

- (NSString *)htmlFooterForSectionPetroSales {
    NSString *htmlFooterForSectionPetroSales = @"";
    return htmlFooterForSectionPetroSales;
}
- (NSString *)htmlFooterForSection3 {
    NSString *htmlFooterForSection3 = @"";
    double sum2 = [self calculateSum2withRptMain:[self reportSummary]];
    NSNumber *sum2number = @(sum2);
    htmlFooterForSection3 = [htmlFooterForSection3 stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sum2number]];
    htmlFooterForSection3 = [htmlFooterForSection3 stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForSection3;
}

//- (double)calculateSum2withRptMain:(NSDictionary *)reportData
//{
//    double sum1 = [reportData [@"Sales"] doubleValue] + [reportData [@"Return"] doubleValue];
//    double sum2 = sum1 + [reportData [@"CollectTax"] doubleValue] + [reportData [@"Surcharge"] doubleValue] + [reportData [@"OpeningAmount"] doubleValue];
//    if (_isTipSetting)
//    {
//        sum2 = sum2 + [reportData [@"TotalTips"] doubleValue];
//    }
//    return sum2;
//}

//- (double)calculateSum3WithTenderArray:(NSArray *)tenderCardData withRptMain:(NSDictionary *)reportData
//{
//    double paidOutAmount;
//
//    if (reportData[@"PayOut"]) {
//        paidOutAmount = fabs ([reportData[@"PayOut"] doubleValue]);
//    } else {
//        paidOutAmount = fabs ([reportData[@"RptMain"][0][@"PayOut"] doubleValue]);
//    }
//
//    double sum = [reportData [@"DropAmount"] doubleValue] + paidOutAmount + [reportData [@"ClosingAmount"] doubleValue];
//    double  rptCardAmount = 0;
//    if([tenderCardData isKindOfClass:[NSArray class]])
//    {
//        for (int i=0; i<[tenderCardData  count]; i++) {
//            NSMutableDictionary *tenderRptCard=[tenderCardData objectAtIndex:i];
//            NSString *strCashType=[NSString stringWithFormat:@"%@",[tenderRptCard valueForKey:@"CashInType"]];
//            if(![strCashType isEqualToString:@"Cash"])
//            {
//                if(![strCashType isEqualToString:@"Other"])
//                {
//                    rptCardAmount += [[tenderRptCard valueForKey:@"Amount"]doubleValue];
//                }
//            }
//        }
//    }
//    double sum3 = sum + rptCardAmount;
//    return sum3;
//}

- (NSString *)htmlFooterForSectionGroup5A {
    NSString *htmlFooterForSection3 = @"";
//    double sum1 = [self calculateSum2withRptMain:[self reportSummary]];
//    double sum2 = sum1 +  [self calculateNetFuelSales].floatValue;
//    NSNumber *sum5Anumber = @(sum2);
//    
//    htmlFooterForSection3 = [htmlFooterForSection3 stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sum5Anumber]];
    htmlFooterForSection3 = [htmlFooterForSection3 stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForSection3;
}

- (NSString *)htmlFooterForSection4 {
    NSString *htmlFooterForSection4 = @"";
    double sum3 = [self calculateSum3WithTenderArray:[self tenderTypeDetail] withRptMain:[self reportSummary]];
    NSNumber *sum3Number = @(sum3);
    
    htmlFooterForSection4 = [htmlFooterForSection4 stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",[currencyFormatter stringFromNumber:sum3Number]];
    
    htmlFooterForSection4 = [htmlFooterForSection4 stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForSection4;
}

- (NSString *)htmlFooterForOpeningAmount {
    NSString *htmlFooterForOpeningAmount = @"";
    return htmlFooterForOpeningAmount;
}
- (NSString *)htmlFooterForNoneSales {
    NSString *htmlFooterForNoneSales = @"";
    htmlFooterForNoneSales = [htmlFooterForNoneSales stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];

    return htmlFooterForNoneSales;
}
- (NSString *)htmlFooterForMerchandiseSales {
    NSString *htmlFooterForMerchandiseSales = @"";
    
    double sum1 = [self calculateMerchandiseSales];
    NSNumber *sumMerchandisnumber = @(sum1);
    
    htmlFooterForMerchandiseSales = [htmlFooterForMerchandiseSales stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sumMerchandisnumber]];
    htmlFooterForMerchandiseSales = [htmlFooterForMerchandiseSales stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForMerchandiseSales;
}
- (NSString *)htmlFooterForAllTaxes {
    NSString *htmlFooterForAllTaxes = @"";
    htmlFooterForAllTaxes = [htmlFooterForAllTaxes stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForAllTaxes;
}
- (NSString *)htmlFooterForAllTaxesDetails {
    
    NSString *htmlFooterForAllTaxesDetails = @"";
    double  rptTaxesAmount = 0;

    NSMutableArray *taxReport= _reportData [@"RptTax"];
    if([taxReport isKindOfClass:[NSArray class]])
    {
        for (int itx=0; itx<taxReport.count; itx++) {
            NSMutableDictionary *taxRptDisc = taxReport[itx];
            rptTaxesAmount += [[taxRptDisc valueForKey:@"Amount"]doubleValue];
        }
    }
    htmlFooterForAllTaxesDetails = [htmlFooterForAllTaxesDetails stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:@(rptTaxesAmount)]];

    htmlFooterForAllTaxesDetails = [htmlFooterForAllTaxesDetails stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];

    return htmlFooterForAllTaxesDetails;
}

- (NSString *)htmlFooterForLotterySales {
    NSString *htmlFooterForLotterySales = @"";
    double sum1 = [self calculateLotterySales];
    NSNumber *sumlotterynumber = @(sum1);
    
    htmlFooterForLotterySales = [htmlFooterForLotterySales stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sumlotterynumber]];
     htmlFooterForLotterySales = [htmlFooterForLotterySales stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForLotterySales;
}

- (NSString *)htmlFooterForGasSales {
    NSString *htmlFooterForGas = @"";
    double sum1 = [self calculateGasSales];
    NSNumber *sumgasnumber = @(sum1);
    
    htmlFooterForGas = [htmlFooterForGas stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sumgasnumber]];
    htmlFooterForGas = [htmlFooterForGas stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForGas;
}
- (NSString *)htmlFooterForMoneyOrderSales {
    NSString *htmlFooterForMoneyOrderSales = @"";
    double sum1 = [self calculateMoneyOrderSales];
    NSNumber *sumMoneyOrdernumber = @(sum1);

    htmlFooterForMoneyOrderSales = [htmlFooterForMoneyOrderSales stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sumMoneyOrdernumber]];
    htmlFooterForMoneyOrderSales = [htmlFooterForMoneyOrderSales stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForMoneyOrderSales;
}

- (NSString *)htmlFooterForGiftCardSales {
    NSString *htmlFooterForGiftCardSales = @"";
    double sum1 = [self calculateGiftCardSales];
    NSNumber *sumgiftCardnumber = @(sum1);
    
    htmlFooterForGiftCardSales = [htmlFooterForGiftCardSales stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sumgiftCardnumber]];
    htmlFooterForGiftCardSales = [htmlFooterForGiftCardSales stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForGiftCardSales;
}
- (NSString *)htmlFooterForCheckCash {
    NSString *htmlFooterForCheckCash = @"";
    double sum1 = [self calculateCheckCashSales];
    NSNumber *sumCheckCashnumber = @(sum1);
    
    htmlFooterForCheckCash = [htmlFooterForCheckCash stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sumCheckCashnumber]];
    htmlFooterForCheckCash = [htmlFooterForCheckCash stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForCheckCash;
}

- (NSString *)htmlFooterForVendorPayout {
    NSString *htmlFooterForVendorPayout = @"";
    double sum1 = [self calculateVendorPayoutSales];
    NSNumber *sumVendorPayoutnumber = @(sum1);
    
    htmlFooterForVendorPayout = [htmlFooterForVendorPayout stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sumVendorPayoutnumber]];
    
    htmlFooterForVendorPayout = [htmlFooterForVendorPayout stringByAppendingFormat:@"<tr><td><Strong>Not Calculate in Total.</Strong></td><td style=\"padding-bottom:1px;\"><div align=\"right\"></div></td></tr>"];
    
    htmlFooterForVendorPayout = [htmlFooterForVendorPayout stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    
    return htmlFooterForVendorPayout;
}
- (NSString *)htmlFooterForHouseCharge {
    NSString *htmlFooterForHouseCharge = @"";
    double sum1 = [self calculateHouseChargeSales];
    NSNumber *sumHouseChargenumber = @(sum1);
    
    htmlFooterForHouseCharge = [htmlFooterForHouseCharge stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sumHouseChargenumber]];
    htmlFooterForHouseCharge = [htmlFooterForHouseCharge stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForHouseCharge;
}
- (NSString *)htmlFooterForSalesOther {
    NSString *htmlFooterForSalesOther = @"";
    double sum1 = [self calculateOtherSales];
    NSNumber *sumOtherenumber = @(sum1);
    
    htmlFooterForSalesOther = [htmlFooterForSalesOther stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sumOtherenumber]];
    htmlFooterForSalesOther = [htmlFooterForSalesOther stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForSalesOther;
}

- (NSString *)htmlFooterForAllSalesTotal {
    NSString *htmlFooterForAllSalesTotal = @"";

    double sum1 =  [self allSalesTotalAmount];
    NSNumber *sumAllSalesTotal = @(sum1);
    
    htmlFooterForAllSalesTotal = [htmlFooterForAllSalesTotal stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr><tr><td><strong>Gross Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sumAllSalesTotal]];
    htmlFooterForAllSalesTotal = [htmlFooterForAllSalesTotal stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForAllSalesTotal;
}


- (NSString *)htmlFooterForSectionOverShort {
    NSString *htmlFooterForSectionOverShort = @"";
    return htmlFooterForSectionOverShort;
}

- (NSString *)htmlFooterForSection6 {
    NSString *htmlFooterForSection6 = @"";
    htmlFooterForSection6 = [htmlFooterForSection6 stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:5px;\"><div align=\"right\"></div></td></tr>"];
    return htmlFooterForSection6;
}

- (NSString *)htmlFooterForSection7 {
    NSString *htmlFooterForSection7 = @"";
    return htmlFooterForSection7;
}
- (NSString *)htmlFooterForSectionCustomer {
    NSString *htmlFooterForSectionCustomer = @"";
    return htmlFooterForSectionCustomer;
}

- (NSString *)htmlFooterForSectionDiscount {
    NSString *htmlFooterForSectionDiscount = @"";
    NSArray *arrDiscount = [self discountDetails];
    CGFloat totalSalesAmount = 0.00;
    CGFloat totalDiscountAmount = 0.00;
    NSInteger totalDiscountCount = 0;
    for (NSDictionary *discountDict in arrDiscount) {
        totalSalesAmount += [discountDict[@"Sales"] floatValue];
        totalDiscountAmount += [discountDict[@"Amount"] floatValue];
        totalDiscountCount += [discountDict[@"Count"] integerValue];
    }
    htmlFooterForSectionDiscount = [htmlFooterForSectionDiscount stringByAppendingFormat:@"<tr><td class = \"TaxType\"><strong><FONT SIZE = 2>Total </FONT></strong></td><td class = \"TaxSales\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"TaxTax\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"TaxCustCount\" align=\"right\"><p><strong><FONT SIZE = 2>%ld</FONT> </strong></p></td></tr>",[currencyFormatter stringFromNumber:@(totalSalesAmount)],[currencyFormatter stringFromNumber:@(totalDiscountAmount)],(long)totalDiscountCount];
    htmlFooterForSectionDiscount = [htmlFooterForSectionDiscount stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:30px;\"><div align=\"right\"></div></td></tr>"];
    htmlFooterForSectionDiscount = [htmlFooterForSectionDiscount stringByAppendingFormat:@"</table></font></td></tr>"];
    return htmlFooterForSectionDiscount;
}

- (NSString *)htmlFooterForSectionTaxes {
    NSString *htmlFooterForSectionTaxes = @"";
    double  rptTaxesAmount = 0;
    double  rptTaxesSales = 0;
    int  rptTaxCount = 0;
    NSMutableArray *taxReport= _reportData [@"RptTax"];
    if([taxReport isKindOfClass:[NSArray class]])
    {
        for (int itx=0; itx<taxReport.count; itx++) {
            NSMutableDictionary *taxRptDisc = taxReport[itx];
            rptTaxesAmount += [[taxRptDisc valueForKey:@"Amount"]doubleValue];
            rptTaxesSales += [[taxRptDisc valueForKey:@"Sales"]doubleValue];
            rptTaxCount += [[taxRptDisc valueForKey:@"Count"]intValue];
        }
    }
    htmlFooterForSectionTaxes = [htmlFooterForSectionTaxes stringByAppendingFormat:@"<tr><td class = \"TaxType\"><strong><FONT SIZE = 2>Total </FONT></strong></td><td class = \"TaxSales\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"TaxTax\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"TaxCustCount\" align=\"right\"><p><strong><FONT SIZE = 2>%d</FONT> </strong></p></td></tr>",@"",[currencyFormatter stringFromNumber:@(rptTaxesAmount)],rptTaxCount];
    
    htmlFooterForSectionTaxes = [htmlFooterForSectionTaxes stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:30px;\"><div align=\"right\"></div></td></tr>"];
    
    htmlFooterForSectionTaxes = [htmlFooterForSectionTaxes stringByAppendingFormat:@"</table></font></td></tr>"];
    
    return htmlFooterForSectionTaxes;
}

- (NSString *)htmlFooterForSectionPaymentMode {
    NSString *htmlFooterForSectionPaymentMode = @"";
    double  rptPaymentModeAmount = 0.00;
    double  rptPaymentModeAvgTicket = 0;
    double  rptPaymentModePercentage = 0;
    int  rptPaymentModeCount = 0;
    
    NSArray *tenderReport= [self tenderTypeDetail];
    if([tenderReport  isKindOfClass:[NSArray class]])
    {
        for (int itx=0; itx<tenderReport.count; itx++) {
            NSMutableDictionary *tenderRptDisc = tenderReport[itx];
            rptPaymentModeAmount += [[tenderRptDisc valueForKey:@"Amount"]doubleValue];
            if (_isTipSetting)
            {
                rptPaymentModeAmount = rptPaymentModeAmount + [[tenderRptDisc valueForKey:@"TipsAmount"] doubleValue];
            }
            rptPaymentModeAvgTicket += [[tenderRptDisc valueForKey:@"AvgTicket"]doubleValue];
            rptPaymentModePercentage += [[tenderRptDisc valueForKey:@"Percentage"]floatValue];
            rptPaymentModeCount += [[tenderRptDisc valueForKey:@"Count"]intValue];
        }
    }
    
    htmlFooterForSectionPaymentMode = [htmlFooterForSectionPaymentMode stringByAppendingFormat:@"<tr><td class = \"TederType\"><strong><FONT SIZE = 2>Total</FONT></strong></td><td class = \"TederTypeAmount\" align=\"right\" ><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"TederTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"TederTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%.2f</FONT> </strong></p></td><td class = \"TederTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2>%d</FONT> </strong></p></td></tr>",[currencyFormatter stringFromNumber:@(rptPaymentModeAmount)],[currencyFormatter stringFromNumber:@(rptPaymentModeAvgTicket)],rptPaymentModePercentage,rptPaymentModeCount];
    
    htmlFooterForSectionPaymentMode = [htmlFooterForSectionPaymentMode stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:30px;\"><div align=\"right\"></div></td></tr>"];
    
    htmlFooterForSectionPaymentMode = [htmlFooterForSectionPaymentMode stringByAppendingFormat:@"</table></font></td></tr>"];
    
    return htmlFooterForSectionPaymentMode;
}

- (NSString *)htmlFooterForSectionTenderTips
{
    NSString *htmlFooterForSectionTenderTips = @"";
    if (_isTipSetting) {
        double tenderAmount = 0.0;
        double tenderTips = 0.0;
        double tenderTotal = 0.0;
        
        NSArray *tenderReport= [self tenderTypeDetail];
        if([tenderReport isKindOfClass:[NSArray class]])
        {
            for (int itx=0; itx<tenderReport.count; itx++) {
                NSDictionary *tenderRptDisc = tenderReport[itx];
                tenderAmount += [[tenderRptDisc valueForKey:@"Amount"] doubleValue];
                tenderTips += [[tenderRptDisc valueForKey:@"TipsAmount"] doubleValue];
                tenderTotal += [[tenderRptDisc valueForKey:@"Amount"] doubleValue] + [[tenderRptDisc valueForKey:@"TipsAmount"] doubleValue];
            }
        }
        
        NSNumber *numTenderAmount = @(tenderAmount);
        NSNumber *numTenderTips = @(tenderTips);
        NSNumber *numTenderTotal = @(tenderTotal);
        
        htmlFooterForSectionTenderTips = [htmlFooterForSectionTenderTips stringByAppendingFormat:@"<tr><td class = \"TipsTederType\"><strong><FONT SIZE = 2>Total</FONT></strong></td><td class = \"TipsTederAmount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"TipsTeder\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"TipsTederTotal\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td></tr>",[currencyFormatter stringFromNumber:numTenderAmount],[currencyFormatter stringFromNumber:numTenderTips],[currencyFormatter stringFromNumber:numTenderTotal]];
        
        htmlFooterForSectionTenderTips = [htmlFooterForSectionTenderTips stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:30px;\"><div align=\"right\"></div></td></tr>"];
        
        htmlFooterForSectionTenderTips = [htmlFooterForSectionTenderTips stringByAppendingFormat:@"</table></font></td></tr>"];
        
    }
    return htmlFooterForSectionTenderTips;
}

- (NSString *)htmlFooterForSectionGiftCard {
    NSString *htmlFooterForSectionGiftCard = @"";
    
    NSInteger totalcount = [[self reportSummary] [@"LoadCount"]integerValue] + [[self reportSummary] [@"RedeemCount"]integerValue];
    //    float totalRegAmount = [[self reportSummary] [@"LoadAmount"]floatValue] + [[self reportSummary] [@"RedeemAmount"]floatValue];
    //    NSNumber *numtotRegAmount = [NSNumber numberWithFloat:totalRegAmount];
    //
    float totalAmount = [[self reportSummary] [@"TotalGCADY"]floatValue] + [[self reportSummary] [@"TotalLoadAmount"]floatValue] + [[self reportSummary] [@"TotalRedeemAmount"]floatValue];
    NSNumber *numtotAmount = @(totalAmount);
    
    htmlFooterForSectionGiftCard = [htmlFooterForSectionGiftCard stringByAppendingFormat:@"<tr><td><strong><FONT SIZE = 2>Total</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>%ld</FONT> </strong></td></tr>",@"",[currencyFormatter stringFromNumber:numtotAmount],(long)totalcount];
    htmlFooterForSectionGiftCard = [htmlFooterForSectionGiftCard stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:30px;\"><div align=\"right\"></div></td></tr>"];
    htmlFooterForSectionGiftCard = [htmlFooterForSectionGiftCard stringByAppendingFormat:@"</table></font></td></tr>"];
    return htmlFooterForSectionGiftCard;
}
- (NSString *)htmlFooterForGasFuelSummery {
    NSString *htmlFooterForGasFuelSummery = @"";
    htmlFooterForGasFuelSummery = [htmlFooterForGasFuelSummery stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    htmlFooterForGasFuelSummery = [htmlFooterForGasFuelSummery stringByAppendingFormat:@"</table></font></td></tr>"];
    return htmlFooterForGasFuelSummery;
}
- (NSString *)htmlFooterForGasPumpSummery {
    NSString *htmlFooterForGasPumpSummery = @"";
    htmlFooterForGasPumpSummery = [htmlFooterForGasPumpSummery stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    htmlFooterForGasPumpSummery = [htmlFooterForGasPumpSummery stringByAppendingFormat:@"</table></font></td></tr>"];
    return htmlFooterForGasPumpSummery;
}

- (NSString *)htmlFooterForSectionCardType {
    NSString *htmlFooterForSectionCardType = @"";
    double  rptCardTypeAmount = 0.00;
    double  rptCardTypeAvgTicket = 0;
    double  rptCardTypePercentage = 0;
    int  rptCardTypeCount = 0;
    
    NSMutableArray *cardTypeReportMain= [[self cardTypeDetail] mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterType like %@",@"NotOutside"];
    NSMutableArray *cardTypeReport= [[cardTypeReportMain filteredArrayUsingPredicate:predicate] mutableCopy];
    if([cardTypeReport isKindOfClass:[NSArray class]])
    {
        for (int itx=0; itx<cardTypeReport.count; itx++) {
            NSMutableDictionary *cardTypeReportDisc = cardTypeReport[itx];
            rptCardTypeAmount += [[cardTypeReportDisc valueForKey:@"Amount"]doubleValue];
            rptCardTypeAvgTicket += [[cardTypeReportDisc valueForKey:@"AvgTicket"]doubleValue];
            rptCardTypePercentage += [[cardTypeReportDisc valueForKey:@"Percentage"]floatValue];
            rptCardTypeCount += [[cardTypeReportDisc valueForKey:@"Count"]intValue];
        }
    }
    htmlFooterForSectionCardType = [htmlFooterForSectionCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><strong><FONT SIZE = 2>Total</FONT></strong></td><td class = \"CardTypeAmount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"CardTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"CardTypeTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%.2f</FONT> </strong></p></td><td class = \"CardTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2>%d</FONT> </strong></p></td></tr>",[currencyFormatter stringFromNumber:@(rptCardTypeAmount)],[currencyFormatter stringFromNumber:@(rptCardTypeAvgTicket)],rptCardTypePercentage,rptCardTypeCount];
    
    htmlFooterForSectionCardType = [htmlFooterForSectionCardType stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    htmlFooterForSectionCardType = [htmlFooterForSectionCardType stringByAppendingFormat:@"</table></font></td></tr>"];
    
    return htmlFooterForSectionCardType;
}
- (NSString *)htmlFooterForSectionCardTypeOutSide {
    NSString *htmlFooterForSectionCardType = @"";
    double  rptCardTypeAmount = 0.00;
    double  rptCardTypeAvgTicket = 0;
    double  rptCardTypePercentage = 0;
    int  rptCardTypeCount = 0;
    
    NSMutableArray *cardTypeReportMain= [[self cardTypeDetail] mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterType like %@",@"Outside"];
    NSMutableArray *cardTypeReport= [[cardTypeReportMain filteredArrayUsingPredicate:predicate] mutableCopy];
    if([cardTypeReport isKindOfClass:[NSArray class]])
    {
        for (int itx=0; itx<cardTypeReport.count; itx++) {
            NSMutableDictionary *cardTypeReportDisc = cardTypeReport[itx];
            rptCardTypeAmount += [[cardTypeReportDisc valueForKey:@"Amount"]doubleValue];
            rptCardTypeAvgTicket += [[cardTypeReportDisc valueForKey:@"AvgTicket"]doubleValue];
            rptCardTypePercentage += [[cardTypeReportDisc valueForKey:@"Percentage"]floatValue];
            rptCardTypeCount += [[cardTypeReportDisc valueForKey:@"Count"]intValue];
        }
    }
    htmlFooterForSectionCardType = [htmlFooterForSectionCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><strong><FONT SIZE = 2>Total</FONT></strong></td><td class = \"CardTypeAmount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"CardTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"CardTypeTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%.2f</FONT> </strong></p></td><td class = \"CardTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2>%d</FONT> </strong></p></td></tr>",[currencyFormatter stringFromNumber:@(rptCardTypeAmount)],[currencyFormatter stringFromNumber:@(rptCardTypeAvgTicket)],rptCardTypePercentage,rptCardTypeCount];
    
    htmlFooterForSectionCardType = [htmlFooterForSectionCardType stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    htmlFooterForSectionCardType = [htmlFooterForSectionCardType stringByAppendingFormat:@"</table></font></td></tr>"];
    
    return htmlFooterForSectionCardType;
}

- (NSString *)htmlFooterForSectionDepartment {
    NSString *htmlFooterForSectionDepartment = @"";
    NSArray *departments = [self fetchNonPayOutDepartmentsWithMerchandise:YES];
    htmlFooterForSectionDepartment = [self generateFooterHtmlFromArray:departments withString:htmlFooterForSectionDepartment];
    return htmlFooterForSectionDepartment;
}
- (NSString *)htmlFooterForSectionNonMerchandiseDepartment {
    NSString *htmlFooterForSectionNonMerchandiseDepartment = @"";
    NSArray *departments = [self fetchNonPayOutDepartmentsWithMerchandise:NO];
    htmlFooterForSectionNonMerchandiseDepartment = [self generateFooterHtmlFromArray:departments withString:htmlFooterForSectionNonMerchandiseDepartment];
    return htmlFooterForSectionNonMerchandiseDepartment;
}
- (NSString *)generateFooterHtmlFromArray:(NSArray *)array withString:(NSString *)htmlFooterForSectionDepartment
{
    double  rptDeptAmout = 0.00;
    double  rptDeptCost = 0;
    double  rptDeptPerc = 0;
    int  rptDeptCustCount = 0;
    CGFloat avgMargine = 0.00;
    
    for (int idpt=0; idpt<array.count; idpt++) {
        NSMutableDictionary *departRptDisc=array[idpt];
        rptDeptCost += [[departRptDisc valueForKey:@"Cost"]doubleValue];
        rptDeptAmout += [[departRptDisc valueForKey:@"Amount"]doubleValue];
        rptDeptPerc += [[departRptDisc valueForKey:@"Per"]floatValue];
        rptDeptCustCount += [[departRptDisc valueForKey:@"Count"]intValue];
    }
    
    NSNumber *rptDeptAmtCnt = @(rptDeptAmout);
    
    if(rptDeptAmout > 0){
        avgMargine =  ((rptDeptAmout - rptDeptCost) * 100) / rptDeptAmout;
  
    }
    
    //avgMargine = [self calculateAvgMargineFromArray:array];
    
    NSString *rptDeptAmoutCnt =[NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:rptDeptAmtCnt]];
    htmlFooterForSectionDepartment = [htmlFooterForSectionDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><strong><FONT SIZE = 2>Total</font></strong></td><td class = \"DepartmentCost\" align=\"right\" ><strong><FONT SIZE = 2>%@</font></strong></td><td class = \"DepartmentAmount\" align=\"right\" ><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"DepartmentMargin\" align=\"right\" style=\"padding-right:24px\"><strong><FONT SIZE = 2>%.2f</font></strong></td><td class = \"DepartmentPer\" align=\"right\"><strong><FONT SIZE = 2>%.2f</font></strong></td><td class = \"DepartmentCount\" align=\"right\"><strong><FONT SIZE = 2>%d</Font></strong></td></tr>",[currencyFormatter stringFromNumber:@(rptDeptCost)],rptDeptAmoutCnt,avgMargine,rptDeptPerc,rptDeptCustCount];
    
    htmlFooterForSectionDepartment = [htmlFooterForSectionDepartment stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    return htmlFooterForSectionDepartment;
}

- (NSString *)generateFooterHtmlForGrandTotalFromArray:(NSArray *)array withString:(NSString *)htmlFooterForSectionDepartment
{
    double  rptDeptAmout = 0.00;
    double  rptDeptCost = 0;
    double  rptDeptPerc = 0;
    int  rptDeptCustCount = 0;
    CGFloat avgMargine = 0.00;
    
    for (int idpt=0; idpt<array.count; idpt++) {
        NSMutableDictionary *departRptDisc=array[idpt];
        rptDeptCost += [[departRptDisc valueForKey:@"Cost"]doubleValue];
        rptDeptAmout += [[departRptDisc valueForKey:@"Amount"]doubleValue];
        rptDeptPerc += [[departRptDisc valueForKey:@"Per"]floatValue];
        rptDeptCustCount += [[departRptDisc valueForKey:@"Count"]intValue];
    }
    
    NSNumber *rptDeptAmtCnt = @(rptDeptAmout);
    
    if(rptDeptAmout > 0){
        avgMargine =  ((rptDeptAmout - rptDeptCost) * 100) / rptDeptAmout;
        
    }
    
//    NSPredicate *departmentPredicate = [NSPredicate predicateWithFormat:@"IsPayout = %@",@(0)];
//    NSArray *department = [array filteredArrayUsingPredicate:departmentPredicate];
//    CGFloat avgMargineForDepartment = [self calculateAvgMargineFromArray:department];
//    
//    NSPredicate *payOutPredicate = [NSPredicate predicateWithFormat:@"IsPayout = %@",@(1)];
//    NSArray *payOut = [array filteredArrayUsingPredicate:payOutPredicate];
//    CGFloat avgMargineForpayOut = [self calculateAvgMargineFromArray:payOut];
    
//    avgMargine = avgMargineForDepartment + avgMargineForpayOut;
    
    NSString *rptDeptAmoutCnt =[NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:rptDeptAmtCnt]];
    htmlFooterForSectionDepartment = [htmlFooterForSectionDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><strong><FONT SIZE = 2>G.Total</font></strong></td><td class = \"DepartmentCost\" align=\"right\" ><strong><FONT SIZE = 2>%@</font></strong></td><td class = \"DepartmentAmount\" align=\"right\" ><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"DepartmentMargin\" align=\"right\" style=\"padding-right:24px\"><strong><FONT SIZE = 2>%.2f</font></strong></td><td class = \"DepartmentPer\" align=\"right\"><strong><FONT SIZE = 2>%@</font></strong></td><td class = \"DepartmentCount\" align=\"right\"><strong><FONT SIZE = 2>%d</Font></strong></td></tr>",[currencyFormatter stringFromNumber:@(rptDeptCost)],rptDeptAmoutCnt,avgMargine,@"100.00",rptDeptCustCount];
    
    htmlFooterForSectionDepartment = [htmlFooterForSectionDepartment stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
    
    return htmlFooterForSectionDepartment;
}



- (CGFloat)calculateAvgMargineFromArray:(NSArray *)array
{
    double  rptDeptMargin = 0;
    if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
        for (int idpt=0; idpt<array.count; idpt++) {
            NSMutableDictionary *departRptDisc=array[idpt];
            rptDeptMargin += [[departRptDisc valueForKey:@"Margin"]floatValue];
        }
    }
    CGFloat avgMargine = 0.00;
    if (array.count > 0 && rptDeptMargin > 0) {
        avgMargine = rptDeptMargin / array.count;
    }
    return avgMargine;
}

- (NSString *)htmlFooterForSectionPayout {
    NSString *htmlFooterForSectionPayout = @"";
    NSArray *departments = [self fetchPayOutDepartments:YES];
    htmlFooterForSectionPayout = [self generateFooterHtmlFromArray:departments withString:htmlFooterForSectionPayout];
    htmlFooterForSectionPayout = [self generateFooterHtmlForGrandTotalFromArray:_reportData [@"RptDepartment"]  withString:htmlFooterForSectionPayout];
    htmlFooterForSectionPayout = [htmlFooterForSectionPayout stringByAppendingFormat:@"</table></font></td></tr>"];
    return htmlFooterForSectionPayout;
}

- (NSString *)htmlFooterForHourlySales {
    NSString *htmlFooterForHourlySales = @"";
    double  rptHourlyCost = 0;
    double  rptHourlyAmount = 0;
    int  rptHourlyCount = 0;
    CGFloat avgMargine = 0.00;
    
    NSArray *hoursReport = _reportData [@"RptHours"];
    if([hoursReport  isKindOfClass:[NSArray class]])
    {
        for (int idpt=0; idpt<hoursReport.count; idpt++) {
            NSMutableDictionary *hoursRptDisc=hoursReport[idpt];
            rptHourlyCost += [[hoursRptDisc valueForKey:@"Cost"]doubleValue];
            rptHourlyAmount += [[hoursRptDisc valueForKey:@"Amount"]doubleValue];
            rptHourlyCount += [[hoursRptDisc valueForKey:@"Count"]intValue];
        }
    }
    if(hoursReport.count > 0)
    {
        avgMargine =  ((rptHourlyAmount - rptHourlyCost) * 100) / rptHourlyAmount;
    }
    htmlFooterForHourlySales = [htmlFooterForHourlySales stringByAppendingFormat:@"<tr><td class = \"HourlySales\"><strong><FONT SIZE = 2>Total</font></strong></td><td class = \"HourlySalesCost\" align=\"right\"><strong><FONT SIZE = 2>%@</font></strong></td><td class = \"HourlySalesAmount\" align=\"right\" ><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"HourlySalesMargin\"  align=\"right\" ><strong><FONT SIZE = 2>%.2f</font></strong></td><td class = \"HourlySalesCount\" align=\"right\" ><strong><FONT SIZE = 2>%d</font></strong></td></tr>",[currencyFormatter stringFromNumber:@(rptHourlyCost)],[currencyFormatter stringFromNumber:@(rptHourlyAmount)],avgMargine,rptHourlyCount];
    htmlFooterForHourlySales = [htmlFooterForHourlySales stringByAppendingFormat:@"</table></font></td></tr>"];
//    htmlFooterForHourlySales = [htmlFooterForHourlySales stringByAppendingFormat:@"</div>"];
//    htmlFooterForHourlySales = [htmlFooterForHourlySales stringByAppendingFormat:@"</body></html>"];
    return htmlFooterForHourlySales;
}

- (NSString *)htmlFooterForHourlyGasSales {
    NSString *htmlFooterForHourlyGasSales = @"";
    htmlFooterForHourlyGasSales = [htmlFooterForHourlyGasSales stringByAppendingFormat:@"</div>"];
    htmlFooterForHourlyGasSales = [htmlFooterForHourlyGasSales stringByAppendingFormat:@"</body></html>"];
    return htmlFooterForHourlyGasSales;
}

#pragma mark - Report Data for printing
- (NSDictionary *)reportSummary {
    return _reportData[@"RptMain"][0];
}
- (NSArray *)cardTypeDetail {
    return _reportData[@"objCardType"];
}
- (NSArray *)tenderTypeDetail {
    return _reportData[@"RptTender"];
}

- (NSArray *)discountDetails
{
   return _reportData[@"RptDiscount"];
}
- (NSDictionary *)customizedDiscount
{
    return [self discountDetailsForDiscountCategory:2];
}

- (NSDictionary *)manualDiscount
{
    return [self discountDetailsForDiscountCategory:3];
}

- (NSDictionary *)preDefinedDiscount
{
    return [self discountDetailsForDiscountCategory:1];
}

- (NSDictionary *)discountDetailsForDiscountCategory:(NSInteger)discountCategory {
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"DiscountCategory == %@", @(discountCategory)];
    NSArray *discount = [[self discountDetails] filteredArrayUsingPredicate:discountPredicate];
    NSMutableDictionary *discountDetail;
    if (discount.count > 0) {
        discountDetail = [discount.firstObject mutableCopy];
    }
    else
    {
        discountDetail = [[NSMutableDictionary alloc] init];
        discountDetail[@"Amount"] = @(0.00);
        discountDetail[@"Count"] = @(0);
        discountDetail[@"Sales"] = @(0.00);
        discountDetail[@"DiscountCategory"] = @(discountCategory);
    }
    return discountDetail;
}


#pragma mark - Content Printing
- (void)printHeaderForSection:(NSInteger)section {
    switch (section) {
        case ReportSection3:
//            [_printJob printLine:@"ReportSection3"];
            break;
        case ReportSectionDailySales:
            //            [_printJob printLine:@"ReportSectionPetroSales"];
            break;
        case ReportSectionOpeningAmount:
            break;
        case ReportSectionMerchandiseSales:
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"Merchandise" text2:@"" text3:@""];
            [_printJob enableBold:NO];
            break;
        case ReportSectionAllTaxes:
            break;
        case ReportSectionAllDetails:
            break;
        case ReportSectionNoneSales:
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"Default" text2:@""];
            [_printJob enableBold:NO];
            break;
        case ReportSectionLotterySales:
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"Lottery" text2:@"" text3:@""];
            [_printJob enableBold:NO];
            break;
            
        case ReportSectionGasSales:
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"Gas" text2:@"" text3:@""];
            [_printJob enableBold:NO];
            break;
            
        case ReportSectionMoneyOrder:
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"Money Order" text2:@"" text3:@""];
            [_printJob enableBold:NO];
            break;
            
        case ReportSectionGiftCardSales:
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"GiftCard" text2:@"" text3:@""];
            [_printJob enableBold:NO];

            break;
        case ReportSectionCheckCash:
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"Check Cash" text2:@"" text3:@""];
            [_printJob enableBold:NO];
            break;
        case ReportSectionVendorPayout:
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"Vendor Payout" text2:@"" text3:@""];
            [_printJob enableBold:NO];

            break;
        case ReportSectionHouseCharge:
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"House Charge" text2:@"" text3:@""];
            [_printJob enableBold:NO];
            break;
        case ReportSectionSalesOther:
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"Other" text2:@"" text3:@""];
            [_printJob enableBold:NO];
            break;
            
        case ReportSectionAllSalesTotal:
            if(_isTipSetting){
                [_printJob enableBold:YES];
                [self defaultFormatForTwoColumn];
                [_printJob printText1:@"Tips" text2:@"" text3:@""];
                [_printJob enableBold:NO];
            }
            break;
        case ReportSectionGroup5A:
            break;
        
        case ReportSection4:
//            [_printJob printLine:@"ReportSection4"];
            break;

    
        case ReportSection6:
//            [_printJob printLine:@"ReportSection6"];
            break;
        case ReportSection7:
            //            [_printJob printLine:@"ReportSection7"];
            break;

        case ReportSectionCardType:
        {
            
            [_printJob enableBold:YES];
            [self defaultFormatForThreeColumn];
            
            NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (_rmsDbController.globalDict)[@"DeviceId"]];
            
            NSArray *activeModulesArray = [[_rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
            
            if([self isRcrGasActive:activeModulesArray]){
                [_printJob printText1:@"InSide" text2:@"" text3:@""];
            }
            [_printJob printText1:@"CardType" text2:@"Amount" text3:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
            
        }

            break;
        case ReportSectionCardTypeOutSide:
            [_printJob enableBold:YES];
            [self defaultFormatForThreeColumn];
            [_printJob printText1:@"OutSide" text2:@"" text3:@""];
            [_printJob printText1:@"CardType" text2:@"Amount" text3:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
            
            break;

        case ReportSectionCardFuelSummery:
            [_printJob enableBold:YES];
            [self defaultFormatForFourColumn];
            [_printJob printText1:@"FuelType" text2:@"Amount" text3:@"Gallons" text4:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
            
            break;
        case ReportSectionPumpSummery:
            [_printJob enableBold:YES];
            [self defaultFormatForFourColumn];
            [_printJob printText1:@"Pump #" text2:@"Amount" text3:@"Gallons" text4:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
            
            break;
        case ReportSectionCustomer:
//            [_printJob printLine:@"ReportSectionCustomer"];
            break;
            
        case ReportSectionDepartment:
            [_printJob enableBold:YES];
            [self defaultFormatForDepartmentColumn];
            [_printJob printText1:@"Merchandise" text2:@"" text3:@"" text4:@""];
            [_printJob printText1:@"Department" text2:@"Price" text3:@"%" text4:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
            break;
        case ReportSectionNonMerchandiseDepartment:
            [_printJob enableBold:YES];
            [self defaultFormatForDepartmentColumn];
            [_printJob printText1:@"NonMerchandise" text2:@"" text3:@"" text4:@""];
            [_printJob printText1:@"Department" text2:@"Price" text3:@"%" text4:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
            break;
            
        case ReportSectionDiscount:
            [_printJob enableBold:YES];
            [self defaultFormatForDiscountColumn];
            [_printJob printText1:@"Discount Type" text2:@"Sales" text3:@"Discount" text4:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
            break;

        case ReportSectionGiftCard:
            [_printJob enableBold:YES];
            [self defaultFormatForDiscountColumn];
            [_printJob printText1:@"Gift Card" text2:@"Register" text3:@"Total" text4:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
            break;

        case ReportSectionHeader:
//            [_printJob printLine:@"ReportSectionHeader"];
            break;

        case ReportSectionHourlySales:
            [_printJob enableBold:YES];
            [self defaultFormatForThreeColumn];
            [_printJob printText1:@"HourlySales" text2:@"Price" text3:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
            break;

        case ReportSectionOverShort:
//            [_printJob printLine:@"ReportSectionOverShort"];
            break;

        case ReportSectionPaymentMode:
            [_printJob enableBold:YES];
            [self defaultFormatForThreeColumn];
            [_printJob printText1:@"TenderType" text2:@"Amount" text3:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
            break;

        case ReportSectionPayout:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForDepartmentColumn];
            [_printJob printText1:@"P/O" text2:@"" text3:@"" text4:@""];
            [_printJob printSeparator];
            [_printJob enableBold:NO];

        }
            break;

        case ReportSectionSales:
//            [_printJob printLine:@"ReportSectionSales"];
            [_printJob enableBold:YES];
            break;
        case ReportSectionPetroSales:
            //            [_printJob printLine:@"ReportSectionPetroSales"];
            [_printJob enableBold:YES];
            break;

        case ReportSectionTaxes:
        {
            [self defaultFormatForThreeColumn];
            [_printJob enableBold:YES];
            [_printJob printText1:@"Tax Type" text2:@"Sales Amount" text3:@"Tax Amount"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
        }
            break;

        case ReportSectionReportHeader:
            break;

        case ReportSectionReportFooter:
            break;
            
        case ReportSectionTenderTips:
        {
            if (_isTipSetting) {
                [_printJob enableBold:YES];
                [self defaultFormatForFourColumn];
                [_printJob printWrappedText1:@"Tender Type" text2:@"Amount" text3:@"Tips" text4:@"Total"];
                [_printJob printSeparator];
                [_printJob enableBold:NO];
            }
        }
            break;
            
        case ReportSectionGroup20A:
        {
            [_printJob enableBold:YES];
            [_printJob printLine:@"Total Fuel Summary"];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionGroup20:
        {
            [_printJob enableBold:YES];
            [_printJob printLine:@"Fueling Summary"];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionGroup21:
        {
            [_printJob enableBold:YES];
            [_printJob printLine:@"Fuel Trnx"];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionGroup22:
        {
            [_printJob enableBold:YES];
            [_printJob printLine:@"Fuel Inventory"];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionGroup23A:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForFourColumn];
            [_printJob printText1:@"" text2:@"Gallons" text3:@"Amount" text4:@"Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionGroup23B:
        {
            [_printJob enableBold:YES];
            [_printJob printLine:@"Fuel Sales by Pump"];
            [_printJob printLine:@"Unknown Pump"];

            [self defaultFormatForFourColumn];
            [_printJob printText1:@"Gallons" text2:@"Amount" text3:@"Total" text4:@"Customer Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];
        }

            break;
            
        case ReportSectionGroup24:
        {
            [_printJob enableBold:YES];
            [_printJob printLine:@"HourlyGasSales"];
            [_printJob enableBold:NO];
        }
            break;

            break;

        default:
      //      [_printJob printLine:[NSString stringWithFormat:@"Section Header - %@", @(section)]];
            break;
    }
}

- (void)tenderTypeFooterForTotal {
    NSArray *paymentModes = [self tenderTypeDetail];
    CGFloat totalCardTypeAmount = 0.00;
    NSInteger totalCardTypeCount = 0;
    for (NSDictionary *paymentMode in paymentModes) {
        totalCardTypeAmount += [paymentMode[@"Amount"] floatValue];
        totalCardTypeCount += [paymentMode[@"Count"] integerValue];
    }
    [_printJob enableBold:YES];
    [self defaultFormatForThreeColumn];
    [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:@(totalCardTypeAmount)] text3:[NSString stringWithFormat:@"%ld",(long)totalCardTypeCount]];
    [_printJob enableBold:NO];
}

-(void)printFooterForSection3
{
    double sum2 = [self calculateSum2withRptMain:[self reportSummary]];
    NSNumber *sum2number = @(sum2);
    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:@"Total:" text2:[self currencyFormattedAmount:sum2number]];
    [_printJob enableBold:NO];
}
-(void)printFooterForSection4
{
    double sum2 = [self calculateSum3WithTenderArray:[self tenderTypeDetail] withRptMain:[self reportSummary]];
    NSNumber *sum2number = @(sum2);
    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:@"Total:" text2:[self currencyFormattedAmount:sum2number]];
    [_printJob enableBold:NO];
}

- (void)printFooterForSection:(NSInteger)section {
    switch (section) {
        case ReportSection3:
        {
            [self printFooterForSection3];
        }
            break;
        case ReportSectionOpeningAmount:
        {
            
        }
            break;
        case ReportSectionMerchandiseSales:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            double sum1 = [self calculateMerchandiseSales];
            NSNumber *sumMerchandisnumber = @(sum1);
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:sumMerchandisnumber]];
            [_printJob enableBold:NO];
        }
            break;
        case ReportSectionAllTaxes:
        {
           
        }
            break;
        case ReportSectionAllDetails:
        {
            NSArray *taxes = _reportData [@"RptTax"];
            NSNumber *totalTaxValue = [taxes valueForKeyPath:@"@sum.Amount"];
            NSString *totalTax = [self currencyFormattedAmount:totalTaxValue];
            
            //            NSNumber *totalCountValue = [taxes valueForKeyPath:@"@sum.Count"];
            //            NSString *totalCount = [totalCountValue stringValue];
            
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            [_printJob printText1:@"Total :" text2:totalTax];
            //            [_printJob printText1:@"Total :" text2:@"" text3:totalTax text4:totalCount];
            [_printJob enableBold:NO];
        }
            break;


        case ReportSectionLotterySales:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            double sum1 = [self calculateLotterySales];
            NSNumber *sumLotterynumber = @(sum1);
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:sumLotterynumber]];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionGasSales:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            double sum1 = [self calculateGasSales];
            NSNumber *sumGasnumber = @(sum1);
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:sumGasnumber]];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionMoneyOrder:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            double sum1 = [self calculateMoneyOrderSales];
            NSNumber *sumMoneyOrdernumber = @(sum1);
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:sumMoneyOrdernumber]];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionGiftCardSales:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            double sum1 = [self calculateGiftCardSales];
            NSNumber *sumGiftCardnumber = @(sum1);
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:sumGiftCardnumber]];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionCheckCash:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            double sum1 = [self calculateCheckCashSales];
            NSNumber *sumcheckCashnumber = @(sum1);
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:sumcheckCashnumber]];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionVendorPayout:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            double sum1 = [self calculateVendorPayoutSales];
            NSNumber *sumVendorPayoutnumber = @(sum1);
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:sumVendorPayoutnumber]];
            [_printJob printText1:@"Not Calculate in Total." text2:@""];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionHouseCharge:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            double sum1 = [self calculateHouseChargeSales];
            NSNumber *sumHouseChargenumber = @(sum1);
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:sumHouseChargenumber]];
            [_printJob enableBold:NO];
        }
            break;
        case ReportSectionSalesOther:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            double sum1 = [self calculateOtherSales];
            NSNumber *sumOthernumber = @(sum1);
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:sumOthernumber]];
            [_printJob enableBold:NO];
        }
            break;

        case ReportSectionAllSalesTotal:
        {
            [_printJob enableBold:YES];
            [self defaultFormatForTwoColumn];
            double sum1 =  [self allSalesTotalAmount];
            NSNumber *sumAllSalesTotal = @(sum1);
            [_printJob printText1:@"Gross Total :" text2:[self currencyFormattedAmount:sumAllSalesTotal]];
            [_printJob enableBold:NO];
        }
            break;

        case ReportSectionGroup5A:
        {
//            [_printJob enableBold:YES];
//            [self defaultFormatForTwoColumn];
//            double sum1 = [self calculateSum2withRptMain:[self reportSummary]];
//            double sum2 = sum1 +  [self calculateNetFuelSales].floatValue;
//            NSNumber *sum5Anumber = @(sum2);
//            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:sum5Anumber]];
//            [_printJob enableBold:NO];
        }
            break;
        
        case ReportSection4:
        {
            [self printFooterForSection4];
        }
            break;
        case ReportSection6:
            [_printJob printLine:@""];
            break;
        case ReportSection7:
            break;
        case ReportSectionCardType:
        {
            NSArray *paymentModesMain = [[self cardTypeDetail] mutableCopy];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterType like %@",@"NotOutside"];
            NSMutableArray *paymentModes= [[paymentModesMain filteredArrayUsingPredicate:predicate] mutableCopy];
            CGFloat totalCardTypeAmount = 0.00;
            NSInteger totalCardTypeCount = 0;
            for (NSDictionary *paymentMode in paymentModes) {
                totalCardTypeAmount += [paymentMode[@"Amount"] floatValue];
                totalCardTypeCount += [paymentMode[@"Count"] integerValue];
            }
            [_printJob enableBold:YES];
            [self defaultFormatForThreeColumn];
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:@(totalCardTypeAmount)] text3:[NSString stringWithFormat:@"%ld",(long)totalCardTypeCount]];
            [_printJob enableBold:NO];
        }

            break;
        case ReportSectionCardTypeOutSide:
        {
            NSArray *paymentModesMain = [[self cardTypeDetail] mutableCopy];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterType like %@",@"Outside"];
            NSMutableArray *paymentModes= [[paymentModesMain filteredArrayUsingPredicate:predicate] mutableCopy];
            CGFloat totalCardTypeAmount = 0.00;
            NSInteger totalCardTypeCount = 0;
            for (NSDictionary *paymentMode in paymentModes) {
                totalCardTypeAmount += [paymentMode[@"Amount"] floatValue];
                totalCardTypeCount += [paymentMode[@"Count"] integerValue];
            }
            [_printJob enableBold:YES];
            [self defaultFormatForThreeColumn];
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:@(totalCardTypeAmount)] text3:[NSString stringWithFormat:@"%ld",(long)totalCardTypeCount]];
            [_printJob enableBold:NO];
        }
            break;
        case ReportSectionCardFuelSummery:
            
            break;
        case ReportSectionPumpSummery:
            
            break;
        case ReportSectionCustomer:
            break;

        case ReportSectionDepartment:
        {
            [self printDepartmentFooter];
        }
            break;
        case ReportSectionNonMerchandiseDepartment:
        {
            [self printNonMerchandiseDepartmentFooter];
        }
            break;
        case ReportSectionPayout:
        {
            [self printPayoutTotal];
        }
            break;
        case ReportSectionDiscount:
        {
            [self printDiscountFooter];
        }
            break;

        case ReportSectionGiftCard:
            break;

        case ReportSectionHeader:
            break;

        case ReportSectionHourlySales:
        {
            NSArray *paymentModes = _reportData [@"RptHours"];
            CGFloat totalCardTypeAmount = 0.00;
            NSInteger totalCardTypeCount = 0;
            for (NSDictionary *paymentMode in paymentModes) {
                totalCardTypeAmount += [paymentMode[@"Amount"] floatValue];
                totalCardTypeCount += [paymentMode[@"Count"] integerValue];

            }
            [_printJob enableBold:YES];
            [self defaultFormatForThreeColumn];
            [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:@(totalCardTypeAmount)] text3:[NSString stringWithFormat:@"%ld",(long)totalCardTypeCount]];
            [_printJob enableBold:NO];
        }
            break;

        case ReportSectionOverShort:
            break;

        case ReportSectionPaymentMode:
        {
            [self tenderTypeFooterForTotal];
        }
            break;
        case ReportSectionDailySales:
            break;
        case ReportSectionSales:
            [_printJob enableBold:NO];
            break;
        case ReportSectionPetroSales:
            [_printJob enableBold:NO];
            break;
        case ReportSectionTaxes:
        {
            NSArray *taxes = _reportData [@"RptTax"];
            NSNumber *totalTaxValue = [taxes valueForKeyPath:@"@sum.Amount"];
            NSString *totalTax = [self currencyFormattedAmount:totalTaxValue];

//            NSNumber *totalCountValue = [taxes valueForKeyPath:@"@sum.Count"];
//            NSString *totalCount = [totalCountValue stringValue];

            [_printJob enableBold:YES];
            [self defaultFormatForThreeColumn];
            [_printJob printText1:@"Total :" text2:@"" text3:totalTax];
//            [_printJob printText1:@"Total :" text2:@"" text3:totalTax text4:totalCount];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionReportHeader:
            break;

        case ReportSectionReportFooter:
            break;

        case ReportSectionTenderTips:
            [self printTenderTipsFooter];
            break;
            
        case ReportSectionGroup20A:
            break;
            
        case ReportSectionGroup20:
        {
            [self defaultFormatForFourColumn];
            NSDictionary *rptMainDict = [self reportSummary];
            float fuelPrice = [rptMainDict [@"FuelPrice"] floatValue];
            NSInteger gasCustomerCount = [rptMainDict [@"GasCustomerCount"] integerValue];
            
            NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
            NSNumber *numFuelPrice = @(fuelPrice);
            NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
            [_printJob enableBold:YES];
            [_printJob printWrappedText1:@"Total :" text2:[self currencyFormattedAmount:numFuelPrice] text3:gallonString text4:gasCustomerCountString];
            [_printJob enableBold:NO];
        }
            break;
            
        case ReportSectionGroup21:
            break;
            
        case ReportSectionGroup22:
            break;
            
        case ReportSectionGroup23A:
            break;
            
        case ReportSectionGroup23B:
            break;
            
        case ReportSectionGroup24:
            break;
            
        default:
           // [_printJob printLine:[NSString stringWithFormat:@"Section Footer - %@", @(section)]];
            break;
    }
    [_printJob printLine:@""];
}


- (void)printFieldWithId:(NSInteger)fieldId {
    switch (fieldId) {
        case ReportFieldAvgTicket:
            [self printAvgTicket];
            break;

        case ReportFieldBatchNo:
            [self printBatchNo];
            break;
            
        case ReportFieldShiftNo:
            [self printShiftNo];
            break;

        case ReportFieldClosingAmount:
            [self printClosingAmount];
            break;

        case ReportFieldTenderTypeXCashOther:
            [self printTenderTypeXCashOther];
            break;

        case ReportFieldCostofGoods:
            [self printCostofGoods];
            break;

        case ReportFieldCustomer:
            [self printCustomer];
            break;

        case ReportFieldDateTime:
            [self printDateTime];
            break;

        case ReportFieldDropAmount:
            [self printDropAmount];
            break;

        case ReportFieldEndDateTime:
            [self printEndDateTime];
            break;

        case ReportFieldGrossSales:
            [self printGrossSales];
            break;
        case ReportFieldPetroNetFuelSales:
            [self printNetFuelSales];
            break;
        case ReportFieldLineItemVoid:
            [self printLineItemVoid];
            break;

        case ReportFieldMargin:
            [self printMargin];
            break;

        case ReportFieldProfit:
            [self printProfit];
            break;

        case ReportFielShiftOpenBy:
            [self printShiftOpenBy];
            break;

        case ReportFieldName:
            [self printName];
            break;

        case ReportFieldNetSales:
            [self printNetSales];
            break;
        case ReportFieldDeposit:
            [self printDeposit];
            break;

        case ReportFieldDiscount:
            [self printDiscount];
            break;

        case ReportFieldNonTaxSales:
            [self printNonTaxSales];
            break;

        case ReportFieldGiftCard:
            [self printGiftCard];
            break;
        case ReportFieldMoneyOrder:
            [self printMoneyOrder];
            break;
            
        case ReportFieldGrossFuelSales:
            [self printGrossFuelSales];
            break;

        case ReportFieldFuelRefund:
            [self printFuelRefund];
            break;

        case ReportFieldNetFuelSales:
            [self printNetFuelSales];
            break;

        case ReportFieldNoSales:
            [self printNoSales];
            break;

        case ReportFieldMerchandiseSales:
            [self printMerchandiseSales];
            break;
            
        case ReportFieldMerchandiseReturn:
            [self printMerchandiseReturn];
            break;
            
        case ReportFieldMerchandiseDiscount:
            [self printMerchandiseDiscount];
            break;
        case ReportFieldAllTaxes:
            [self printAllTaxes];
            break;

        case ReportFieldAllTaxesDetails:
            [self printAllTaxesDetails];
            break;

        case ReportFieldLotterySales:
            [self printLotterySales];
            break;
        case ReportFieldLotteryProfit:
            [self printLotteryProfit];
            break;

        case ReportFieldLotteryReturn:
            [self printLotteryReturn];
            break;
            
        case ReportFieldLotteryDiscount:
            [self printLotteryDiscount];
            break;
        case ReportFieldLotteryPayout:
            [self printLotteryPayout];
            break;

        case ReportFieldGasSales:
            [self printGasSales];
            break;
        case ReportFieldGasProfit:
            [self printGasProfit];
            break;

        case ReportFieldGasReturn:
            [self printGasReturn];
            break;
            
        case ReportFieldGasDiscount:
            [self printGasDiscount];
            break;
        case ReportFieldGasQty:
            [self printGasQtyGallons];
            break;
        case ReportFieldMoneyOrderSales:
            [self printMoneyOrderSales];
            break;
        case ReportFieldMoneyOrderSalesFee:
            [self printMoneyOrderSalesFee];
            break;

        case ReportFieldMoneyOrderReturn:
            [self printMoneyOrderReturn];
            break;
            
        case ReportFieldMoneyOrderDiscount:
            [self printMoneyOrderDiscount];
            break;
        
        case ReportFieldGiftCardSales:
            [self printGiftCardSales];
            break;
        case ReportFieldGiftCardFee:
            [self printGiftCardFee];
            break;
        case ReportFieldGiftCardReturn:
            [self printGiftCardReturn];
            break;
        case ReportFieldGiftCardDiscount:
            [self printGiftCardDiscount];
            break;
        case ReportFieldCheckCashSales:
            [self printCheckCashSales];
            break;
        case ReportFieldCheckCashFee:
            [self printCheckCashFee];
            break;
        case ReportFieldCheckCashReturn:
            [self printCheckCashReturn];
            break;
        case ReportFieldCheckCashDiscount:
            [self printCheckCashDiscount];
            break;
        
        case ReportFieldPayoutSales:
            [self printPayOutSales];
            break;

        case ReportFieldPayoutReturn:
            [self printPayOutReturn];
            break;

        case ReportFieldPayoutDiscount:
            [self printPayOutDiscount];
            break;
            
        case ReportFieldHouseChargeSales:
            [self printHouseChargeSales];
            break;
        case ReportFieldHouseChargeReturn:
            [self printHouseChargeReturn];
            break;
        case ReportFieldHouseChargeDiscount:
            [self printHouseChargeDiscount];
            break;
        case ReportFieldOtherSales:
            [self printOtherSales];
            break;
        case ReportFieldOtherReturn:
            [self printOtherReturn];
            break;
        case ReportFieldOtherDiscount:
            [self printOtherDiscount];
            break;
        case ReportFieldOpeningAmount:
            [self printOpeningAmount];
            break;
        case ReportFieldDailySales:
            [self printDailySales];
            break;
        case ReportFieldInsideGasSales:
            [self printDailyInsideGasSales];
            break;
        case ReportFieldOutSideGasSales:
            [self printDailyOutSideGasSales];
            break;
        case ReportFieldOverShort:
            [self printOverShort];
            break;
            
        case ReportFieldGCLiabiality:
            [self printGCLiabiality];
            break;
        case ReportFieldInventory:
            [self printInventory];
            break;
        case ReportFieldCheckCash:
            [self printCheckCash];
            break;

        case ReportFieldPaidOut:
            [self printPayoutAmount];
            break;

        case ReportFieldRegister:
            [self printRegister];
            break;
        case ReportFieldCentralizeRegister:
            [self printCentralizeRegister];
            break;

        case ReportFieldReturn:
            [self printReturn];
            break;

        case ReportFieldSales:
            [self printSales];
            break;

        case ReportFieldSection3Taxes:
            [self printSection3Taxes];
            break;

        case ReportFieldSection3Total:
            [self printSection3Total];
            break;

        case ReportFieldStartDateTime:
            [self printStartDateTime];
            break;

        case ReportFieldSurCharge:
            [self printSurCharge];
            break;

        case ReportFieldTaxes:
            [self printTaxes];
            break;

        case ReportFieldVoidTrans:
            [self printVoidTrans];
            break;
            
        case ReportFieldCancelTrans:
            [self printCancelTrans];
            break;
            
        case ReportFieldLayaway:
            [self printLayaway];
            break;

        case ReportFieldPriceChangeCount:
            [self printPriceChangeCount];
            break;

        case ReportFieldStoreName:
            [self printStoreName];
            break;

        case ReportFieldAddressLine1:
            [self printAddressLine1];
            break;

        case ReportFieldAddressLine2:
            [self printAddressLine2];
            break;

        case ReportFieldReportName:
            [self printReportName];
            break;
        case ReportFieldReportDay:
            [self printDay];
            break;

        case ReportFieldTaxesSection:
            [self printTaxesBreakup];
            break;

        case ReportFieldDepartment:
            [self printDepartmentBreakup];
            break;
            
        case ReportFieldNonMerchandiseDepartment:
            [self printNonMerchandiseDepartmentBreakup];
            break;
        case ReportFieldPayOutDepartment:
            [self printPayoutBreakup];
            break;

        case ReportFieldTenderType:
            [self printTenderTypeBreakup];
            break;

        case ReportFieldHourlySales:
            [self printHourlyBreakup];
            break;

        case ReportFieldCardType:
            [self printCardType];
            break;
        case ReportFieldCardTypeOutSide:
            [self printCardTypeOutSide];
            break;
        case ReportFieldFuelSummery:
            [self printGasFuelSummery];
            break;
        case ReportFieldPumpSummery:
            [self printGasPumpSummery];
            break;
        case ReportFieldChequeTotal:
            [self printChequeTotal];
            break;

        case ReportFieldCreditCardTotal:
            [self printCreditCardTotal];
            break;

        case ReportFieldGiftCardTotal:
            [self printGiftCardTotal];
            break;

        case ReportFieldGiftCardPreviousBalance:
            [self printGiftCardPreviousBalance];
            break;
            
        case ReportFieldLoadGiftCard:
            [self printLoadGiftCard];
            break;
            
        case ReportFieldCustomizedDiscount:
            [self printCustomizedDiscount];
            break;
            
        case ReportFieldManualDiscount:
            [self printManualDiscount];
            break;

        case ReportFieldPreDefinedDiscount:
            [self printPreDefinedDiscount];
            break;

        case ReportFieldRedeemGiftCard:
            [self printRedeemGiftCard];
            break;

        case ReportFieldStandAloneTotal:
            [self printStandAloneTotal];
            break;

        case ReportFieldPayoutBreakup:
            [self printPayoutBreakup];
            break;

        case ReportFieldTips:
            [self printTipsTotal];
            break;

        case ReportFieldAllTips:
            [self printAllTips];
            break;
        case ReportFieldAllTipsTotal:
            [self printAllTipsTotal];
            break;
        case ReportFieldTenderTips:
            [self printTenderTipsBreakup];
            break;

        case ReportFieldGroup20AGrossFuelSales:
            [self printGroup20AGrossFuelSales];
            break;

        case ReportFieldGroup20AOther:
            [self printGroup20AOther];
            break;
            
        case ReportFieldGroup20AFuelRefund:
            [self printGroup20AFuelRefund];
            break;

        case ReportFieldGroup20ANetFuelSales:
            [self printGroup20ANetFuelSales];
            break;

        case ReportFieldGroup20FuelType:
            [self printGroup20FuelType];
            break;
            
        case ReportFieldGroup20Other:
            [self printGroup20Other];
            break;

        case ReportFieldGroup21FuelType:
            [self printGroup21FuelType];
            break;

        case ReportFieldGroup21Other:
            [self printGroup21Other];
            break;

        case ReportFieldGroup22FuelInventory:
            [self printGroup22FuelInventory];
            break;
            
        case ReportFieldGroup23ATotalFuelTrnx:
            [self printGroup23ATotalFuelTrnx];
            break;

        case ReportFieldGroup23AOtherTrnx:
            [self printGroup23AOtherTrax];
            break;
            
        case ReportFieldGroup23AVoidFuelTrnx:
            [self printGroup23AVoidFuelTrnx];
            break;

        case ReportFieldGroup23ALineItemDelete:
            [self printGroup23ALineItemDelete];
            break;

        case ReportFieldGroup23ACancelTrnx:
            [self printGroup23ACancelTrnx];
            break;
            
        case ReportFieldGroup23APriceChanges:
            [self printGroup23APriceChanges];
            break;

        case ReportFieldGroup23ADriveOffs:
            [self printGroup23ADriveOffs];
            break;

        case ReportFieldGroup23AFuelType:
            [self printGroup23AFuelType];
            break;
            
        case ReportFieldGroup23BFuelSalesbyPump:
            [self printGroup23BFuelSalesbyPump];
            break;

        case ReportFieldGroup24HourlyGasSales:
            [self printGroup24HourlyGasSales];
            break;
            
        case ReportFieldVersionFooter:
            [self printVersionFooter];
            break;
            

        default:
            NSLog(@"Implement Field - %@", @(fieldId));
            break;
    }
}

- (id)branchInfoValueForKeyIndex:(ReportDataKey)index
{
    return [self valueFromDictionary:[self branchInfo] forKeyIndex:index];
}

- (id)valueFromDictionary:(NSDictionary *)dictionary forKeyIndex:(ReportDataKey)index
{
    return dictionary[[self keyForIndex:index]];
}

- (NSString *)keyForIndex:(ReportDataKey)index
{
    return reportDataKeys[index];
}

- (NSDictionary *)branchInfo
{
    NSDictionary *dictBranchInfo = [_rmsDbController.globalDict valueForKey:@"BranchInfo"];
    return dictBranchInfo;
}

- (void)printStoreName {
    [_printJob setTextAlignment:TA_CENTER];
    if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        [_printJob printLine:(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"StoreName"]];
    }
    else
    {
        [_printJob printLine:[self branchInfoValueForKeyIndex:ReportDataKeyBranchName]];
    }
}

- (void)printAddressLine1 {
    [_printJob setTextAlignment:TA_CENTER];
    NSString *addressLine1;
    if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        addressLine1 = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]];
        
        NSArray *arrAddress = [addressLine1 componentsSeparatedByString:@"\r\n"];
        if(arrAddress.count == 1)
        {
            arrAddress = [addressLine1 componentsSeparatedByString:@","];
        }
        for (uint i=0; i < arrAddress.count ;i++)
        {
            NSString *address = [arrAddress objectAtIndex:i];
            [_printJob printLine:address];
        }
    }
    else {
        addressLine1 = [NSString stringWithFormat:@"%@  , %@", [self branchInfoValueForKeyIndex:ReportDataKeyAddress1],[self branchInfoValueForKeyIndex:ReportDataKeyAddress2]];
        [_printJob printLine:addressLine1];
    }
}

- (void)printAddressLine2 {
    [_printJob setTextAlignment:TA_CENTER];
    if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [_printJob printLine:email];
            [_printJob printLine:phoneNo];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (_rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [_printJob printLine:phoneNo];
        }
    }
    else {
        NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [self branchInfoValueForKeyIndex:ReportDataKeyCity],[self branchInfoValueForKeyIndex:ReportDataKeyState],[self branchInfoValueForKeyIndex:ReportDataKeyZipCode]];
        [_printJob printLine:addressLine2];
    }
}

- (void)printReportName {
    [_printJob setTextAlignment:TA_CENTER];
    [_printJob enableInvertColor:YES];
    [_printJob printLine:_reportName];
    [_printJob enableInvertColor:NO];
}

-(void)printDay
{
    NSString *strDate = @"";
    if([_reportName isEqualToString:@"Centralize Z"]){
        strDate = [self stringFromDate:[self jsonStringToNSDate:[[_reportData[@"RptZRegister"] firstObject] valueForKey:@"ZCloseDate"]] format:@"MM/dd/yyyy hh:mm a"];
    }
    else {
        strDate = [self dateFromDictionary:[self reportSummary] timeKey:@"ReportTime" dateKey:@"ReportDate"];
    }
    NSString *weekDayName = [self weekDayNameForDate:strDate];
    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:@"Day:" text2:weekDayName];
    [_printJob enableBold:NO];
}

-(NSString *)dayFromWeekDay:(NSInteger )weekday
{
    NSString *day = @"";
    switch (weekday) {
        case 1:
            day = @"Sunday";
            break;
        case 2:
            day = @"Monday";
            break;
        case 3:
            day = @"Tuesday";
            break;
        case 4:
            day = @"Wednesday";
            break;
        case 5:
            day = @"Thursday";
            break;
        case 6:
            day = @"Friday";
            break;
        case 7:
            day = @"Saturday";
            break;
            
        default:
            break;
    }
    return day;
}

- (void)defaultFormatForTwoColumn
{
    columnWidths[0] = 23;
    columnWidths[1] = 24;
    columnAlignments[0] = RCAlignmentLeft;
    columnAlignments[1] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForThreeColumn
{
    columnWidths[0] = 15;
    columnWidths[1] = 16;
    columnWidths[2] = 15;
    columnAlignments[0] = RCAlignmentLeft;
    columnAlignments[1] = RCAlignmentRight;
    columnAlignments[2] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForFourColumn
{
    columnWidths[0] = 14;
    columnWidths[1] = 11;
    columnWidths[2] = 9;
    columnWidths[3] = 11;
    columnAlignments[0] = RCAlignmentLeft;
    columnAlignments[1] = RCAlignmentRight;
    columnAlignments[2] = RCAlignmentRight;
    columnAlignments[3] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForDepartmentColumn
{
    columnWidths[0] = 10;
    columnWidths[1] = 14;
    columnWidths[2] = 14;
    columnWidths[3] = 7;
    columnAlignments[0] = RCAlignmentLeft;
    columnAlignments[1] = RCAlignmentRight;
    columnAlignments[2] = RCAlignmentRight;
    columnAlignments[3] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForDiscountColumn
{
    columnWidths[0] = 13;
    columnWidths[1] = 13;
    columnWidths[2] = 13;
    columnWidths[3] = 6;
    columnAlignments[0] = RCAlignmentLeft;
    columnAlignments[1] = RCAlignmentRight;
    columnAlignments[2] = RCAlignmentRight;
    columnAlignments[3] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForDepartmentBreakup
{
    columnWidths[0] = 25;
    columnWidths[1] = 14;
    columnWidths[2] = 7;
    columnAlignments[0] = RCAlignmentRight;
    columnAlignments[1] = RCAlignmentRight;
    columnAlignments[2] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)printShiftOpenBy {
}

- (void)printName {
    NSString *text1 = REPORT_USER_NAME;
    NSString *text2 = [self reportSummary][@"CurrentUser"];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:text1 text2:text2];
}

- (void)printRegister {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_REGISTER_NAME text2:[self reportSummary][@"RegisterName"]];
}

- (void)printCentralizeRegister {
    [self defaultFormatForTwoColumn];
    
    for (NSDictionary *registerDict in _reportData[@"RptZRegister"]) {
    
        [_printJob enableBold:YES];
        [_printJob printText1:registerDict[@"RegisterName"] text2:@""];
        [_printJob enableBold:NO];
        NSString *dateAndTime = [self convertJsonDate:registerDict[@"ZOpenDate"]];
        NSString *endDate = [self convertJsonDate:registerDict[@"ZCloseDate"]];
        
        [_printJob printText1:REPORT_START_DATE_AND_START_TIME text2:dateAndTime];
        [_printJob printText1:REPORT_END_DATE_AND_END_TIME text2:endDate];
    }
}


- (void)printDateTime {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_DATE_AND_TIME text2:[self stringFromDate:[NSDate date] format:@"MM/dd/yyyy hh:mm a"]];
}

- (void)printStartDateTime {
    NSString *startDate = [self dateFromDictionary:[self reportSummary] timeKey:@"StartTime" dateKey:@"Startdate"];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_START_DATE_AND_START_TIME text2:startDate];
}
- (NSString *)getCurrentDateAndTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *printDate = [dateFormatter stringFromDate:date];
    return printDate;
}

- (BOOL)isNil:(id)object {
    BOOL isNil = NO;
    if (object == nil || [object isKindOfClass:[NSNull class]]) {
        isNil = YES;
    }
    return isNil;
}

- (NSString *)dateFromDictionary:(NSDictionary *)dictionary timeKey:(NSString *)timeKey dateKey:(NSString *)dateKey
{
    NSString *dateString = dictionary[dateKey];
    NSString *timeString = dictionary[timeKey];
    NSString *endDate = @"";
    if ([self isNil:dateString] || [self isNil:timeString])
    {
        endDate = self.currentDateAndTime;
    }
    else
    {
        endDate = [NSString stringWithFormat:@"%@ %@", dateString, timeString];

        endDate = [self stringFromDate:endDate inputFormat:@"MM/dd/yyyy HH:mm:ss" outputFormat:@"MM/dd/yyyy hh:mm a"];
    }
    return endDate;
}

- (void)printEndDateTime
{
    NSString *endDate = [self dateFromDictionary:[self reportSummary] timeKey:@"ReportTime" dateKey:@"ReportDate"];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_END_DATE_AND_END_TIME text2:endDate];
}

- (void)printBatchNo {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_BATCH text2:[[self reportSummary][@"BatchNo"] stringValue]];
}

- (void)printShiftNo {
}

- (void)printGrossSales {
    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_GROSS_SALES text2:[self valueForReportKey:@"TotalSales"]];
    [_printJob enableBold:NO];
}
- (void)printPetroGrossSales {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_PETRO_GROSS_SALES text2:[self valueForReportKey:@"GrossFuelSales"]];
}
- (void)printPetroRefund {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_PETRO_REFUND text2:[self valueForReportKey:@"FuelRefund"]];
}

- (void)printTaxes {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_TAXES text2:[self valueForReportKey:@"CollectTax"]];
}

- (void)printNetSales {
    [_printJob enableBold:YES];
    float netSale = [_rmsDbController.currencyFormatter numberFromString:[self valueForReportKey:@"TotalSales"]].floatValue - [_rmsDbController.currencyFormatter numberFromString:[self valueForReportKey:@"CollectTax"]].floatValue;
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_NET_SALES text2:[self currencyFormattedAmount:@(netSale)]];
    [_printJob enableBold:NO];
}
- (void)printDeposit {
    NSArray *tenderReport = [self tenderTypeDetail];
    
    NSPredicate *predicateCash = [NSPredicate predicateWithFormat:@"CashInType = %@",@"Cash"];
    NSArray *cashArray = [tenderReport filteredArrayUsingPredicate:predicateCash];
    
    NSPredicate *predicatecheque= [NSPredicate predicateWithFormat:@"CashInType = %@",@"Check"];
    NSArray *chequeArray = [tenderReport filteredArrayUsingPredicate:predicatecheque];
    
    CGFloat totalCash = [[cashArray valueForKeyPath:@"@sum.Amount"] floatValue];
    CGFloat totalCheque = [[chequeArray valueForKeyPath:@"@sum.Amount"] floatValue];
    
    CGFloat deposite = totalCash + totalCheque;
    NSNumber *numDeposite = @(deposite);
    
    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    NSString *strDeposit = [self currencyFormattedAmount:numDeposite];

    [_printJob printText1:REPORT_DEPOSIT text2:strDeposit];
    [_printJob enableBold:NO];
}
- (void)printOpeningAmount {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_OPENING_AMOUNT text2:[self valueForReportKey:@"OpeningAmount"]];
}
- (void)printDailySales {
    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_DAILY_SALES text2:[self valueForReportKey:@"DailySales"]];
    [_printJob enableBold:NO];
}
- (void)printDailyInsideGasSales {
    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_GAS_INSIDE_SALES text2:[self valueForReportKey:@"InSideGrossFuelSales"]];
    [_printJob enableBold:NO];
}
- (void)printDailyOutSideGasSales {
    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_GAS_OUT_SALES text2:[self valueForReportKey:@"OutSideGrossFuelSales"]];
    [_printJob enableBold:NO];
}
- (void)printSales {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_SALES text2:[self valueForReportKey:@"Sales"]];
}

- (void)printReturn {
    NSNumber *returnAmount = [self reportSummary][@"Return"];
    float returnValue = returnAmount.floatValue;

    if (returnValue < 0) {
        returnValue = -returnValue;
    }
    returnAmount = @(returnValue);
    NSString *returnAmountString = [self currencyFormattedAmount:returnAmount];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_RETURN text2:returnAmountString];
}

- (void)printSection3Total {
    NSArray *keys = @[
                      @"Sales",
                      @"Return"
                      ];
    NSDictionary *sum1Dict = [self reportSummary];
    sum1Dict = [sum1Dict dictionaryWithValuesForKeys:keys];

    NSArray *allValues = sum1Dict.allValues;

    NSNumber *total = [allValues valueForKeyPath:@"@sum.self"];

    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:@"Total:" text2:[self currencyFormattedAmount:total]];
    [_printJob enableBold:NO];
}

- (NSString *)valueForReportKey:(NSString *)reportKey
{
    NSString *collectTax = [self currencyFormattedAmount:[self reportSummary][reportKey]];
    return collectTax;
}

- (void)printSection3Taxes {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_TAXES text2:[self valueForReportKey:@"CollectTax"]];
}

- (void)printSurCharge {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_SURCHARGE text2:[self valueForReportKey:@"Surcharge"]];
}

- (void)printDropAmount {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_DROP_AMOUNT text2:[self valueForReportKey:@"DropAmount"]];
}

- (void)printPayoutAmount {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_PAYOUT text2:[self valueForReportKey:@"PayOut"]];
}

- (void)printClosingAmount {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_CLOSING_AMOUNT text2:[self valueForReportKey:@"ClosingAmount"]];
}

- (double)calculateSum2withRptMain:(NSDictionary *)reportData
{
    double sum1 = [reportData [@"Sales"] doubleValue] + [reportData [@"Return"] doubleValue];
    double sum2 = sum1 + [reportData [@"CollectTax"] doubleValue] + [reportData [@"Surcharge"] doubleValue] + [reportData [@"LoadAmount"] doubleValue] + [reportData [@"MoneyOrder"] doubleValue] + [reportData [@"OpeningAmount"] doubleValue];
    if (_isTipSetting)
    {
        sum2 = sum2 + [reportData [@"TotalTips"] doubleValue];
    }
    
    
    return sum2;
}

//Merchandise Sales total Sales

-(double)calculateMerchandiseSales{
    
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Merchandise"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMerchandise];
    double returnAmt = -[salesDict [@"ReturnAmt"] doubleValue];
    double merchandiseSales = [salesDict [@"Sales"] doubleValue] - returnAmt - [salesDict [@"Discount"] doubleValue];
    return merchandiseSales;
}

//Lottery total Sales

-(double)calculateLotterySales{
    
   // NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
    double returnAmt = -[salesDict [@"ReturnAmt"] doubleValue];
    double discount = [salesDict [@"Discount"] doubleValue];
    if(discount < 0 && returnAmt < 0 ){
        discount = discount * -1;
    }
    double sales = [salesDict [@"OffPayoutSales"] doubleValue];
    if(sales < 0){
        sales = sales * -1;
    }
    double lotterySales = sales - returnAmt - discount;
    return lotterySales;
}
//Gas total Sales
-(double)calculateGasSales{
    
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
    double returnAmt = -[salesDict [@"ReturnAmt"] doubleValue];
    double gasSales = [salesDict [@"Sales"] doubleValue] - returnAmt - [salesDict [@"Discount"] doubleValue];
    return gasSales;
}

//Money Order total Sales
-(double)calculateMoneyOrderSales{
    
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Money Order"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder];
    double returnAmt = -[salesDict [@"ReturnAmt"] doubleValue];
    double moneyOrderSales = [salesDict [@"Sales"] doubleValue] + [salesDict [@"SalesFee"] doubleValue] - returnAmt - [salesDict [@"Discount"] doubleValue];
    return moneyOrderSales;
}
//Gift Card total Sales
-(double)calculateGiftCardSales{
    
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Gift Card"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGiftCard];
    double returnAmt = -[salesDict [@"ReturnAmt"] doubleValue];
    double giftCardSales = [salesDict [@"Sales"] doubleValue] + [salesDict [@"SalesFee"] doubleValue] - returnAmt - [salesDict [@"Discount"] doubleValue] ;
    return giftCardSales;
}
//Check Cash total Sales
-(double)calculateCheckCashSales{
    
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Check cash"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
    double returnAmt = -[salesDict [@"ReturnAmt"] doubleValue];
    double checkCashSales = [salesDict [@"SalesFee"] doubleValue] - returnAmt - [salesDict [@"Discount"] doubleValue];
    return checkCashSales;
}

//Vendor Payout total Sales
-(double)calculateVendorPayoutSales{
    
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Vendor Payout"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeVendorPayout];
    double returnAmt = -[salesDict [@"ReturnAmt"] doubleValue];
    double vendorPayoutSales = [salesDict [@"Sales"] doubleValue] - returnAmt - [salesDict [@"Discount"] doubleValue];
    return vendorPayoutSales;
}
//House Charge total Sales
-(double)calculateHouseChargeSales{
    
    //NSDictionary *salesDict = [self getSalesByDeptType:@"House Charge"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeHouseCharge];
    double returnAmt = -[salesDict [@"ReturnAmt"] doubleValue];
    double houseChargeSales = [salesDict [@"Sales"] doubleValue] - returnAmt - [salesDict [@"Discount"] doubleValue];
    return houseChargeSales;
}

//Other total Sales
-(double)calculateOtherSales{
    
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Other"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeOther];
    double returnAmt = -[salesDict [@"ReturnAmt"] doubleValue];
    double otherSales = [salesDict [@"Sales"] doubleValue] - returnAmt - [salesDict [@"Discount"] doubleValue];
    return otherSales;
}

-(double)allSalesTotalAmount{
    
    double salesAmt =  [[self reportSummary] [@"OpeningAmount"] doubleValue] + [self calculateMerchandiseSales] + [self calculateLotterySales] + [self calculateGasSales] + [self calculateMoneyOrderSales] + [self calculateGiftCardSales] + [self calculateCheckCashSales] + [self calculateHouseChargeSales] + [self calculateOtherSales] + [[self reportSummary] [@"Surcharge"] doubleValue] + [[self reportSummary] [@"TotalTips"] doubleValue] + [[self reportSummary] [@"CollectTax"] doubleValue] + [[self reportSummary] [@"Sales"] doubleValue] + [[self reportSummary] [@"Return"] doubleValue] + [[self reportSummary] [@"LoadAmount"] doubleValue] + [[self reportSummary][@"MoneyOrder"] doubleValue];
    return salesAmt;

}
 - (double)calculateSum3WithTenderArray:(NSArray *)tenderCardData withRptMain:(NSDictionary *)reportData
{
    double paidOutAmount;
    
    if (reportData[@"PayOut"]) {
        paidOutAmount = fabs ([reportData[@"PayOut"] doubleValue]);
    } else {
        paidOutAmount = fabs ([reportData[@"RptMain"][0][@"PayOut"] doubleValue]);
    }
    
    double sum = [reportData [@"DropAmount"] doubleValue] + paidOutAmount + [reportData [@"ClosingAmount"] doubleValue];
    double  rptCardAmount = 0;
    if([tenderCardData isKindOfClass:[NSArray class]])
    {
        for (int i=0; i<tenderCardData.count; i++) {
            NSMutableDictionary *tenderRptCard=tenderCardData[i];
            NSString *strCashType=[NSString stringWithFormat:@"%@",[tenderRptCard valueForKey:@"CashInType"]];
            if(![strCashType isEqualToString:@"Cash"])
            {
                    rptCardAmount += [[tenderRptCard valueForKey:@"Amount"]doubleValue];
            }
        }
    }
    double sum3 = sum + rptCardAmount;
    return sum3;
}

- (void)printOverShort {
    
   // double doubleOverShort = [self calculateSum3WithTenderArray:[self tenderTypeDetail] withRptMain:[self reportSummary]] - [self calculateSum2withRptMain:[self reportSummary]];

    double sum3 = [self calculateSum3WithTenderArray:[self tenderTypeDetail] withRptMain:[self reportSummary]];
    
    double doubleOverShort =  sum3 - [self allSalesTotalAmount];
    
    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_OVER_SHORT text2:[self currencyFormattedAmount:@(doubleOverShort)]];
    [_printJob enableBold:NO];
}

- (void)printGCLiabiality {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_GC_LIABIALITY text2:[self currencyFormattedAmount:[self reportSummary][@"GCLiablity"]]];
}
- (void)printInventory {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_INVENTORY text2:[self currencyFormattedAmount:[self reportSummary][@"TotalInventory"]]];
}
- (void)printCheckCash {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_CHECK_CASH text2:[self currencyFormattedAmount:[self reportSummary][@"CheckCash"]]];
}

- (void)printGiftCard {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_GIFTCARD text2:[self currencyFormattedAmount:[self reportSummary][@"LoadAmount"]]];
}

- (void)printMoneyOrder {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_MONEY_ORDER text2:[self currencyFormattedAmount:[self reportSummary][@"MoneyOrder"]]];
}

- (void)printGrossFuelSales {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_GROSS_FUEL_SALES text2:[self currencyFormattedAmount:[self reportSummary][@"GrossFuelSales"]]];
}

- (void)printFuelRefund {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_FUEL_REFUND text2:[self currencyFormattedAmount:[self reportSummary][@"FuelRefund"]]];
}

- (NSNumber *)calculateNetFuelSales {
    NSDictionary *rptMainDict = [self reportSummary];
    float netFuelSales = [rptMainDict [@"GrossFuelSales"] floatValue] - [rptMainDict [@"FuelRefund"] floatValue];
    NSNumber *numNetFuelSales = @(netFuelSales);
    return numNetFuelSales;
}

- (void)printNetFuelSales {
    [self defaultFormatForTwoColumn];
    NSNumber *numNetFuelSales = [self calculateNetFuelSales];
    [_printJob printText1:REPORT_NET_FUEL_SALES text2:[self currencyFormattedAmount:numNetFuelSales]];
}

//Merchandise Sales
- (void)printMerchandiseSales {
    if([self calculateMerchandiseSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Merchandise"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMerchandise];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_SALES text2:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
}

- (void)printMerchandiseReturn {
    
    if([self calculateMerchandiseSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Merchandise"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMerchandise];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_RETURN text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
}
- (void)printMerchandiseDiscount {
    
    if([self calculateMerchandiseSales] != 0){

        //NSDictionary *salesDict = [self getSalesByDeptType:@"Merchandise"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMerchandise];
        [self defaultFormatForTwoColumn];
        double discount = [salesDict [@"Discount"] doubleValue];
        [_printJob printText1:REPORT_NONMERCHANDIZE_DISCOUNT text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
        
    }
}

//All Taxes
- (void)printAllTaxes {
    [_printJob enableBold:YES];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_TAXES text2:[currencyFormatter stringFromNumber:[self reportSummary] [@"CollectTax"]]];
    [_printJob enableBold:NO];
}
//All Taxes Details

- (void)printAllTaxesDetails{
   
    NSArray *taxes = _reportData [@"RptTax"];
    for (NSDictionary *taxDictionary in taxes) {
        [self defaultFormatForTwoColumn];
        [_printJob printText1:taxDictionary[@"Descriptions"] text2:[self currencyFormattedAmount:taxDictionary[@"Amount"]]];
    }

}

//Loatry Sales
- (void)printLotterySales {
    
    if([self calculateLotterySales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_SALES text2:[currencyFormatter stringFromNumber:salesDict[@"OffPayoutSales"]]];
    }
}

- (void)printLotteryProfit {
    
    if([self calculateLotterySales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_PROFIT text2:[currencyFormatter stringFromNumber:salesDict[@"Profit"]]];
    }
}

- (void)printLotteryReturn {
    if([self calculateLotterySales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_RETURN text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
}
- (void)printLotteryDiscount {
    if([self calculateLotterySales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
        [self defaultFormatForTwoColumn];
        double discount = [salesDict [@"Discount"] doubleValue];
        [_printJob printText1:REPORT_NONMERCHANDIZE_DISCOUNT text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
}
- (void)printLotteryPayout {
    if([self calculateLotterySales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Lottery"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeLottery];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_LOTTERY_PAYOUT text2:[currencyFormatter stringFromNumber:salesDict[@"PayoutSales"]]];
    }
}

// Gas Sales

- (void)printGasSales {
    
     if([self calculateGasSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_SALES text2:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
     }
}
- (void)printGasProfit {
    
    if([self calculateGasSales] != 0){
       // NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_SALES text2:[currencyFormatter stringFromNumber:salesDict[@"Profit"]]];
    }
}
- (void)printGasReturn {
    if([self calculateGasSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_RETURN text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
}
- (void)printGasDiscount {
     if([self calculateGasSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
        [self defaultFormatForTwoColumn];
         double discount = [salesDict [@"Discount"] doubleValue];
        [_printJob printText1:REPORT_NONMERCHANDIZE_DISCOUNT text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
     }
}
- (void)printGasQtyGallons {
    if([self calculateGasSales] != 0){
   // NSDictionary *salesDict = [self getSalesByDeptType:@"Gas"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGas];
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_NONMERCHANDIZE_QTY text2:[currencyFormatter stringFromNumber:salesDict[@"Qty"]]];
    }
}
// Money Order Sales

- (void)printMoneyOrderSales {
    if([self calculateMoneyOrderSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Money Order"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_SALES text2:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
}
- (void)printMoneyOrderSalesFee {
    if([self calculateMoneyOrderSales] != 0){

        //NSDictionary *salesDict = [self getSalesByDeptType:@"Money Order"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_FEE text2:[currencyFormatter stringFromNumber:salesDict[@"SalesFee"]]];
    }
}
- (void)printMoneyOrderReturn {
    if([self calculateMoneyOrderSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Money Order"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_RETURN text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
}
- (void)printMoneyOrderDiscount {
    if([self calculateMoneyOrderSales] != 0){

        //NSDictionary *salesDict = [self getSalesByDeptType:@"Money Order"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder];
        [self defaultFormatForTwoColumn];
        double discount = [salesDict [@"Discount"] doubleValue];
        [_printJob printText1:REPORT_NONMERCHANDIZE_DISCOUNT text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
}

// Gift Card Sales

- (void)printGiftCardSales {
    if([self calculateGiftCardSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gift Card"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGiftCard];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_SALES text2:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
}
- (void)printGiftCardFee {
     if([self calculateGiftCardSales] != 0){
         //NSDictionary *salesDict = [self getSalesByDeptType:@"Gift Card"];
         NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGiftCard];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_FEE text2:[currencyFormatter stringFromNumber:salesDict[@"SalesFee"]]];
     }
}
- (void)printGiftCardReturn {
    if([self calculateGiftCardSales] != 0){
       // NSDictionary *salesDict = [self getSalesByDeptType:@"Gift Card"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGiftCard];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_RETURN text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
}
- (void)printGiftCardDiscount {
    if([self calculateGiftCardSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Gift Card"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeGiftCard];
        [self defaultFormatForTwoColumn];
        double discount = [salesDict [@"Discount"] doubleValue];
        [_printJob printText1:REPORT_NONMERCHANDIZE_DISCOUNT text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
}

// CHECK CASH Sales

- (void)printCheckCashSales {
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Check cash"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
     if([salesDict[@"Sales"] doubleValue] != 0){
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_SALES text2:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];

    }
}
- (void)printCheckCashFee {
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Check cash"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
    if([salesDict[@"Sales"] doubleValue] != 0){
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_FEE text2:[currencyFormatter stringFromNumber:salesDict[@"CheckCashAmount"]]];
    }
}
- (void)printCheckCashReturn {
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Check cash"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
      if([salesDict[@"Sales"] doubleValue] != 0){
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_RETURN text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
     }
}
- (void)printCheckCashDiscount {
    //NSDictionary *salesDict = [self getSalesByDeptType:@"Check cash"];
    NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeCheckCash];
    if([salesDict[@"Sales"] doubleValue] != 0){
        [self defaultFormatForTwoColumn];
        double discount = [salesDict [@"Discount"] doubleValue];
        [_printJob printText1:REPORT_NONMERCHANDIZE_DISCOUNT text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
}


// PAYOUT Sales

- (void)printPayOutSales {
    if([self calculateVendorPayoutSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Vendor Payout"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeVendorPayout];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_PAYOUT_AMOUNT text2:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
    
}
- (void)printPayOutReturn {
    if([self calculateVendorPayoutSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Vendor Payout"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeVendorPayout];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_RETURN text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
}
- (void)printPayOutDiscount {
    if([self calculateVendorPayoutSales] != 0){
        // NSDictionary *salesDict = [self getSalesByDeptType:@"Vendor Payout"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeVendorPayout];
        [self defaultFormatForTwoColumn];
        double discount = [salesDict [@"Discount"] doubleValue];
        [_printJob printText1:REPORT_NONMERCHANDIZE_DISCOUNT text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
}

// HOUSE CHARGE Sales

- (void)printHouseChargeSales {
     if([self calculateHouseChargeSales] != 0){
         //NSDictionary *salesDict = [self getSalesByDeptType:@"House Charge"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeHouseCharge];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_DEPOSITE_AMOUNT text2:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
     }
}
- (void)printHouseChargeReturn {
    if([self calculateHouseChargeSales] != 0){

         //NSDictionary *salesDict = [self getSalesByDeptType:@"House Charge"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeHouseCharge];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_RETURN text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
}
- (void)printHouseChargeDiscount {
    if([self calculateHouseChargeSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"House Charge"];
         NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeHouseCharge];
        [self defaultFormatForTwoColumn];
        double discount = [salesDict [@"Discount"] doubleValue];
        [_printJob printText1:REPORT_NONMERCHANDIZE_DISCOUNT text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
}

// OTHER Sales

- (void)printOtherSales {
    if([self calculateOtherSales] != 0){

        //NSDictionary *salesDict = [self getSalesByDeptType:@"Other"];
         NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeOther];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_SALES text2:[currencyFormatter stringFromNumber:salesDict[@"Sales"]]];
    }
}
- (void)printOtherReturn {
    if([self calculateOtherSales] != 0){
        //NSDictionary *salesDict = [self getSalesByDeptType:@"Other"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeOther];
        double returnAmt = [salesDict [@"ReturnAmt"] doubleValue];
        if(returnAmt < 0){
            returnAmt = -returnAmt;
        }
        [self defaultFormatForTwoColumn];
        [_printJob printText1:REPORT_NONMERCHANDIZE_RETURN text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:returnAmt]]]];
    }
}
- (void)printOtherDiscount {
    if([self calculateOtherSales] != 0){
       // NSDictionary *salesDict = [self getSalesByDeptType:@"Other"];
        NSDictionary *salesDict = [self getSalesByDeptTypebyId:DepartmentTypeOther];
        [self defaultFormatForTwoColumn];
        double discount = [salesDict [@"Discount"] doubleValue];
        [_printJob printText1:REPORT_NONMERCHANDIZE_DISCOUNT text2:[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[self addMinusSign:discount]]]];
    }
}


- (void)printDiscount{
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_DISCOUNT text2:[self currencyFormattedAmount:[self reportSummary][@"Discount"]]];
}

- (void)printNonTaxSales {
    [_printJob printText1:REPORT_NON_TAX_SALES text2:[self currencyFormattedAmount:[self reportSummary][@"NonTaxSales"]]];
}

- (void)printCostofGoods {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_COSTOFGOODS text2:[self currencyFormattedAmount:[self reportSummary][@"CostofGoods"]]];
}

- (void)printMargin {
    [self defaultFormatForTwoColumn];
    float netSales = [[self reportSummary][@"TotalSales"] doubleValue] - [[self reportSummary][@"CollectTax"]doubleValue];
    float costOfGoods = [[self reportSummary] [@"CostofGoods"] doubleValue];
    float margin;
    NSNumber *profitNumber = [self calculateProfit];
    if (profitNumber > 0)
        margin = (1 - (costOfGoods/ netSales)) * 100;
    else
        margin = 0;
//    NSNumber *marginNumber = @(margin);
//    [_printJob printText1:REPORT_MARGIN text2:[currencyFormatter stringFromNumber:marginNumber]];
    [_printJob printText1:REPORT_MARGIN text2:[NSString stringWithFormat:@"%.2f %%",margin]];
}

- (void)printProfit {
    [self defaultFormatForTwoColumn];
    NSNumber *profitNumber = [self calculateProfit];
    [_printJob printText1:REPORT_PROFIT text2:[currencyFormatter stringFromNumber:profitNumber]];
}

- (void)printNoSales {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_NO_SALES text2:[[self reportSummary][@"NoSales"] stringValue]];
}

- (void)printCancelTrans {
    [_printJob printText1:REPORT_CANCEL_TNX text2:[[self reportSummary][@"CancelTrnxCount"] stringValue]];
}
- (void)printPriceChangeCount {
    [_printJob printText1:REPORT_PRICE_CHANGE_COUNT text2:[[self reportSummary][@"PriceChangeCount"] stringValue]];
}
- (void)printLayaway {
    [_printJob printText1:REPORT_LAYAWAY text2:[[self reportSummary][@"Layaway"] stringValue]];
}

- (void)printVoidTrans {
    [_printJob printText1:REPORT_VOID text2:[[self reportSummary][@"AbortedTrans"] stringValue]];
}

- (void)printLineItemVoid {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_LINE_ITEM_VOID text2:[[self reportSummary][@"LineItemVoid"] stringValue]];
}

- (void)printCustomer {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_CUSTOMER text2:[[self reportSummary][@"CustomerCount"] stringValue]];
}


- (void)printAvgTicket {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:REPORT_AVG_TICKET text2:[self currencyFormattedAmount:[self reportSummary][@"AvgTicket"]]];
}

- (void)printTaxesBreakup {
    NSArray *taxes = _reportData [@"RptTax"];
    for (NSDictionary *taxDictionary in taxes) {
        [self defaultFormatForThreeColumn];
        [_printJob printText1:taxDictionary[@"Descriptions"] text2:[self currencyFormattedAmount:taxDictionary[@"Sales"]] text3:[self currencyFormattedAmount:taxDictionary[@"Amount"]]];
    }
}
- (NSArray*)fuelTypeDetail {
    return _reportData[@"RptFuel"];
}
- (NSArray*)pumpDetail {
    return _reportData[@"RptPump"];
}

- (void)printGasFuelSummery {
    [self defaultFormatForFourColumn];
    
    NSMutableArray *fuelTypes = [[self fuelTypeDetail]mutableCopy];
    
    for (NSMutableDictionary *fuelType in fuelTypes) {
        
        float gallons = [fuelType [@"PricePerGallon"] floatValue];
        NSNumber *numGallons = @(gallons);
        
        float fuelamount = [fuelType [@"amount"] floatValue];
        NSNumber *numFuelAmount = @(fuelamount);
        
        NSInteger gasCustomerCount = [fuelType [@"PumpCount"] integerValue];
        
        NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
        
        NSString *fuelTypeTitle = fuelType[@"FuelTypeLabelTitle"];
        if([fuelTypeTitle isKindOfClass:[NSString class]]){
            [_printJob printWrappedText1:fuelType[@"FuelTypeLabelTitle"] text2:[self currencyFormattedAmount:numFuelAmount] text3:numGallons.stringValue text4:gasCustomerCountString];
        }
        else{
            [_printJob printWrappedText1:@"" text2:[self currencyFormattedAmount:numFuelAmount] text3:numGallons.stringValue text4:gasCustomerCountString];
        }
        
    }
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setMaximumFractionDigits:3];
    
    NSNumber *totalnumGallons = [fuelTypes valueForKeyPath:@"@sum.PricePerGallon"];
    NSNumber *totalnumFuelAmount = [fuelTypes valueForKeyPath:@"@sum.amount"];
    NSNumber *totalCustCount = [fuelTypes valueForKeyPath:@"@sum.PumpCount"];
    [_printJob enableBold:YES];
    
    [_printJob printWrappedText1:@"Total" text2:[self currencyFormattedAmount:totalnumFuelAmount] text3:[fmt stringFromNumber:totalnumGallons] text4:totalCustCount.stringValue];
    
    [_printJob printSeparator];
    [_printJob enableBold:NO];
}

- (void)printGasPumpSummery {
    [self defaultFormatForFourColumn];
    
    NSMutableArray *pumps = [[self pumpDetail]mutableCopy];
    
    for (NSMutableDictionary *pumpInfo in pumps) {
        
        float gallons = [pumpInfo [@"Volume"] floatValue];
        NSNumber *numGallons = @(gallons);
        
        float fuelamount = [pumpInfo [@"amount"] floatValue];
        NSNumber *numFuelAmount = @(fuelamount);
        
        NSInteger gasCustomerCount = [pumpInfo [@"PumpCount"] integerValue];
        
        NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
        
        NSString *fuelTypeTitle = pumpInfo[@"PumpName"];
        if([fuelTypeTitle isKindOfClass:[NSString class]]){
            [_printJob printWrappedText1:pumpInfo[@"PumpName"] text2:[self currencyFormattedAmount:numFuelAmount] text3:numGallons.stringValue text4:gasCustomerCountString];
        }
        else{
            [_printJob printWrappedText1:@"" text2:[self currencyFormattedAmount:numFuelAmount] text3:numGallons.stringValue text4:gasCustomerCountString];
        }
        
    }
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setMaximumFractionDigits:3];
    
    NSNumber *totalnumGallons = [pumps valueForKeyPath:@"@sum.Volume"];
    NSNumber *totalnumFuelAmount = [pumps valueForKeyPath:@"@sum.amount"];
    NSNumber *totalCustCount = [pumps valueForKeyPath:@"@sum.PumpCount"];
    [_printJob enableBold:YES];
    [_printJob printWrappedText1:@"Total" text2:[self currencyFormattedAmount:totalnumFuelAmount] text3:[fmt stringFromNumber: totalnumGallons] text4:totalCustCount.stringValue];
    
    
    
    [_printJob printSeparator];
    [_printJob enableBold:NO];
}
- (void)printCardType {
    NSArray *paymentModesMain = [[self cardTypeDetail] mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterType like %@",@"NotOutside"];
    NSMutableArray *paymentModes= [[paymentModesMain filteredArrayUsingPredicate:predicate] mutableCopy];
    for (NSDictionary *paymentMode in paymentModes) {
        [self defaultFormatForThreeColumn];
        [_printJob printText1:paymentMode[@"CardType"] text2:[self currencyFormattedAmount:paymentMode[@"Amount"]] text3:[NSString stringWithFormat:@"%@", [paymentMode[@"Count"] stringValue]]];
    }
}
- (void)printCardTypeOutSide {
    NSArray *paymentModesMain = [[self cardTypeDetail] mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterType like %@",@"Outside"];
    NSMutableArray *paymentModes= [[paymentModesMain filteredArrayUsingPredicate:predicate] mutableCopy];
    for (NSDictionary *paymentMode in paymentModes) {
        [self defaultFormatForThreeColumn];
        [_printJob printText1:paymentMode[@"CardType"] text2:[self currencyFormattedAmount:paymentMode[@"Amount"]] text3:[NSString stringWithFormat:@"%@", [paymentMode[@"Count"] stringValue]]];
    }
}

- (void)printPaymentForPaymentMode:(NSString *)paymentMode title:(NSString*)title {
    NSArray *paymentModes = _reportData[@"RptCardType"];
    NSPredicate *chequePredicate = [NSPredicate predicateWithFormat:@"CashInType == %@", paymentMode];
    paymentModes = [paymentModes filteredArrayUsingPredicate:chequePredicate];
    CGFloat total = 0; //[[paymentModes valueForKeyPath:@"sum.Amount"] floatValue];
    for (NSDictionary *paymentMode in paymentModes) {
        total += [paymentMode[@"Amount"] floatValue];
    }
}

- (void)printChequeTotal {
    NSString *paymentMode = @"Check";
    [self printPaymentForPaymentMode:paymentMode title:@"Cheque:"];
}

- (void)printCreditCardTotal {
    NSString *paymentMode = @"Credit";
    [self printPaymentForPaymentMode:paymentMode title:@"Credit:"];
}

- (void)printGiftCardTotal {
    NSInteger totalcount = [[self reportSummary] [@"LoadCount"]integerValue] + [[self reportSummary] [@"RedeemCount"]integerValue];
    NSString *strTotCount = [NSString stringWithFormat:@"%ld",(long)totalcount];
    
    float totalAmount = [[self reportSummary] [@"TotalGCADY"]floatValue] + [[self reportSummary] [@"TotalLoadAmount"]floatValue] + [[self reportSummary] [@"TotalRedeemAmount"]floatValue];
    
    [_printJob enableBold:YES];
    [self defaultFormatForDiscountColumn];
    [_printJob printText1:@"Total" text2:@"" text3:[self currencyFormattedAmount:@(totalAmount)] text4:strTotCount];
    [_printJob enableBold:NO];
    
}

- (void)printGiftCardPreviousBalance {
    [self defaultFormatForDiscountColumn];
    [_printJob printText1:@"GC ADY" text2:@"" text3:[self currencyFormattedAmount:[self reportSummary][@"TotalGCADY"]] text4:@""];
}

- (void)printLoadGiftCard {
    [self defaultFormatForDiscountColumn];
    [_printJob printText1:@"Load" text2:[self currencyFormattedAmount:[self reportSummary][@"LoadAmount"]] text3:[self currencyFormattedAmount:[self reportSummary][@"TotalLoadAmount"]] text4:[[self reportSummary][@"LoadCount"]stringValue]];
}

- (void)printRedeemGiftCard {
    [self defaultFormatForDiscountColumn];
    [_printJob printText1:@"Redeem" text2:[self currencyFormattedAmount:[self reportSummary][@"RedeemAmount"]] text3:[self currencyFormattedAmount:[self reportSummary][@"TotalRedeemAmount"]] text4:[[self reportSummary][@"RedeemCount"]stringValue]];
}

- (void)printCustomizedDiscount {
    [self defaultFormatForDiscountColumn];
    [_printJob printText1:@"Customized" text2:[self currencyFormattedAmount:self.customizedDiscount[@"Sales"]] text3:[self currencyFormattedAmount:self.customizedDiscount[@"Amount"]] text4:[self.customizedDiscount[@"Count"] stringValue]];
}

- (void)printManualDiscount {
    [self defaultFormatForDiscountColumn];
    [_printJob printText1:@"Manual" text2:[self currencyFormattedAmount:self.manualDiscount[@"Sales"]] text3:[self currencyFormattedAmount:self.manualDiscount[@"Amount"]] text4:[self.manualDiscount[@"Count"] stringValue]];
}

- (void)printPreDefinedDiscount {
    [self defaultFormatForDiscountColumn];
    [_printJob printText1:@"PreDefined" text2:[self currencyFormattedAmount:self.preDefinedDiscount[@"Sales"]] text3:[self currencyFormattedAmount:self.preDefinedDiscount[@"Amount"]] text4:[self.preDefinedDiscount[@"Count"] stringValue]];
}

- (void)printStandAloneTotal {
    NSString *paymentMode = @"StandAlone";
    [self printPaymentForPaymentMode:paymentMode title:@"Stand Alone:"];
}

- (void)_printDepartmentBreakup:(NSArray *)departments {
#ifdef PRINT_A_FEW
    NSInteger count = 0;
#endif
    
    for (NSDictionary *departmentDictionary in departments) {
        
        [_printJob printLine:departmentDictionary[@"Descriptions"]];

        NSString *textValue = [self currencyFormattedAmount:departmentDictionary[@"Amount"]];
        NSString *text1 = textValue;//[_printJob rightAlignedText:textValue columnWidth:15];

        textValue = [self percentageFormattedAmount:departmentDictionary[@"Per"]];
        NSString *text2 = textValue;//[_printJob rightAlignedText:textValue columnWidth:16];

        textValue = [NSString stringWithFormat:@"%@", departmentDictionary[@"Count"]];
        NSString *text3 = textValue;//[_printJob rightAlignedText:textValue columnWidth:15];

        [self defaultFormatForDepartmentBreakup];
        [_printJob printText1:text1 text2:text2 text3:text3];


#ifdef PRINT_A_FEW
        count++;
        if (count == 3) {
            break;
        }
#endif
    }
}

- (NSArray *)fetchNonPayOutDepartmentsWithMerchandise:(BOOL)isMerchandise {
    NSArray *departments = [self fetchPayOutDepartments:NO];
    NSPredicate *nondepartmentPredicate;
    if (isMerchandise) {
        nondepartmentPredicate = [NSPredicate predicateWithFormat:@"DeptTypeId == %@",@(1)];
    }
    else {
        nondepartmentPredicate = [NSPredicate predicateWithFormat:@"DeptTypeId != %@",@(1)];
    }
    NSArray *departmentArray = [departments filteredArrayUsingPredicate:nondepartmentPredicate];
    return departmentArray;
}

- (NSArray *)fetchPayOutDepartments:(BOOL)isPayout {
    NSArray *departments = _reportData [@"RptDepartment"];
    NSPredicate *payoutPredicate = [NSPredicate predicateWithFormat:@"IsPayout == %d", isPayout];
    departments = [departments filteredArrayUsingPredicate:payoutPredicate];
    return departments;
}

- (void)printDepartmentBreakup {
    NSArray *departments = [self fetchNonPayOutDepartmentsWithMerchandise:YES];
    [self _printDepartmentBreakup:departments];
}

- (void)printNonMerchandiseDepartmentBreakup {
    NSArray *departments = [self fetchNonPayOutDepartmentsWithMerchandise:NO];
    [self _printDepartmentBreakup:departments];
}

- (void)printPayoutBreakup {
    NSArray *departments = [self fetchPayOutDepartments:YES];
    [self _printDepartmentBreakup:departments];
}

- (void)printTenderTypeBreakup {
#ifdef PRINT_A_FEW
    NSInteger count = 0;
#endif
    NSArray *paymentModes = [self tenderTypeDetail];
    for (NSDictionary *paymentDictionary in paymentModes) {
        NSString *text1 = [NSString stringWithFormat:@"%@", paymentDictionary[@"Descriptions"]];
        NSString *text2 = [self currencyFormattedAmount:paymentDictionary[@"Amount"]];
        NSString *text3 = [NSString stringWithFormat:@"%@", paymentDictionary[@"Count"]];
        [self defaultFormatForThreeColumn];
        [_printJob printText1:text1 text2:text2 text3:text3];
#ifdef PRINT_A_FEW
        count++;
        if (count == 3) {
            break;
        }
#endif
    }
}

- (void)printHourlyBreakup {
    NSArray *hourlyData = _reportData [@"RptHours"];
    for (NSDictionary *hourlyDictionary in hourlyData) {
        NSString *text1;
        NSDate *date = [self jsonStringToNSDate:hourlyDictionary[@"Hours"]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm";
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        text1 = [formatter stringFromDate:date];
        NSString *text2 = [self currencyFormattedAmount:hourlyDictionary[@"Amount"]];
        NSString *text3 = [NSString stringWithFormat:@"%@", hourlyDictionary[@"Count"]];
        [self defaultFormatForThreeColumn];
        [_printJob printText1:text1 text2:text2 text3:text3];
    }
}



- (void)printDepartmentFooter {
    NSArray *departments = [self fetchNonPayOutDepartmentsWithMerchandise:YES];

    CGFloat total;
    NSString *textValue;

    total = [[departments valueForKeyPath:@"@sum.Amount"] floatValue];
    textValue = [self currencyFormattedAmount:@(total)];
    NSString *text1 = textValue; //[_printJob rightAlignedText:textValue columnWidth:7];
//    text1 = textValue;//[NSString stringWithFormat:@"G.Total %@", text1];

//    total = [[departments valueForKeyPath:@"@sum.Per"] floatValue];

    textValue = [self percentageFormattedAmount:[departments valueForKeyPath:@"@sum.Per"]];
    NSString *text2 = textValue;//[_printJob rightAlignedText:textValue columnWidth:16];

    textValue = [NSString stringWithFormat:@"%@", [departments valueForKeyPath:@"@sum.Count"]];
    NSString *text3 = textValue;//[_printJob rightAlignedText:textValue columnWidth:15];

    [_printJob enableBold:YES];
    [_printJob printLine:@""];
    [self defaultFormatForDepartmentColumn];
    [_printJob printText1:@"Total" text2:text1 text3:text2 text4:text3];
    [_printJob enableBold:NO];
}

- (void)printNonMerchandiseDepartmentFooter {
    NSArray *departments = [self fetchNonPayOutDepartmentsWithMerchandise:NO];
    
    CGFloat total;
    NSString *textValue;
    
    total = [[departments valueForKeyPath:@"@sum.Amount"] floatValue];
    textValue = [self currencyFormattedAmount:@(total)];
    NSString *text1 = textValue; //[_printJob rightAlignedText:textValue columnWidth:7];
    //    text1 = textValue;//[NSString stringWithFormat:@"G.Total %@", text1];
    
    //    total = [[departments valueForKeyPath:@"@sum.Per"] floatValue];
    
    textValue = [self percentageFormattedAmount:[departments valueForKeyPath:@"@sum.Per"]];
    NSString *text2 = textValue;//[_printJob rightAlignedText:textValue columnWidth:16];
    
    textValue = [NSString stringWithFormat:@"%@", [departments valueForKeyPath:@"@sum.Count"]];
    NSString *text3 = textValue;//[_printJob rightAlignedText:textValue columnWidth:15];
    
    [_printJob enableBold:YES];
    [_printJob printLine:@""];
    [self defaultFormatForDepartmentColumn];
    [_printJob printText1:@"Total" text2:text1 text3:text2 text4:text3];
    [_printJob enableBold:NO];
}


- (void)printDiscountFooter
{
    NSArray *arrDiscount = [self discountDetails];
    CGFloat totalSalesAmount = 0.00;
    CGFloat totalDiscountAmount = 0.00;
    NSInteger totalDiscountCount = 0;
    for (NSDictionary *discountDict in arrDiscount) {
        totalSalesAmount += [discountDict[@"Sales"] floatValue];
        totalDiscountAmount += [discountDict[@"Amount"] floatValue];
        totalDiscountCount += [discountDict[@"Count"] integerValue];
    }
    [_printJob enableBold:YES];
    [self defaultFormatForDiscountColumn];
    [_printJob printText1:@"Total :" text2:[self currencyFormattedAmount:@(totalSalesAmount)] text3:[self currencyFormattedAmount:@(totalDiscountAmount)] text4:[NSString stringWithFormat:@"%ld",(long)totalDiscountCount]];
    [_printJob enableBold:NO];
}

- (void)printPayoutTotal {
    NSArray *departments = [self fetchPayOutDepartments:YES];
    CGFloat total;
    NSString *textValue;
    [_printJob enableBold:YES];

    total = [[departments valueForKeyPath:@"@sum.Amount"] floatValue];
    textValue = [self currencyFormattedAmount:@(total)];
    NSString *text1 = textValue; //[_printJob rightAlignedText:textValue columnWidth:9];
//    text1 = textValue;//[NSString stringWithFormat:@"Total %@", text1];

    total = [[departments valueForKeyPath:@"@sum.Per"] floatValue];
    textValue = [self percentageFormattedAmount:@(total)];
    NSString *text2 = textValue;//[_printJob rightAlignedText:textValue columnWidth:16];

    textValue = [NSString stringWithFormat:@"%@", [departments valueForKeyPath:@"@sum.Count"]];
    NSString *text3 = textValue;//[_printJob rightAlignedText:textValue columnWidth:15];
    [self defaultFormatForDepartmentColumn];
    [_printJob printText1:@"Total" text2:text1 text3:text2 text4:text3];
    [_printJob enableBold:NO];
    
    [_printJob printLine:@""];
    
     NSMutableArray *array = _reportData [@"RptDepartment"];
    
    double  rptDeptAmout = 0.00;
    double  rptDeptCost = 0;
    int  rptDeptCustCount = 0;
    
    for (int idpt=0; idpt<array.count; idpt++) {
        NSMutableDictionary *departRptDisc=array[idpt];
        rptDeptCost += [[departRptDisc valueForKey:@"Cost"]doubleValue];
        rptDeptAmout += [[departRptDisc valueForKey:@"Amount"]doubleValue];
        rptDeptCustCount += [[departRptDisc valueForKey:@"Count"]intValue];
    }
    
    NSNumber *rptDeptAmtCnt = @(rptDeptAmout);

    NSString *rptDeptAmoutCnt =[NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:rptDeptAmtCnt]];
    [_printJob enableBold:YES];
    [self defaultFormatForDepartmentColumn];
    [_printJob printText1:@"G.Total" text2:rptDeptAmoutCnt text3:@"100" text4:@(rptDeptCustCount).stringValue];
    [_printJob enableBold:NO];
    
}

- (void)printTenderTypeXCashOther {
    NSArray *paymentModes = [self tenderTypeDetail];

    for (NSDictionary *paymentDictionary in paymentModes) {
        NSString *cashInStype = paymentDictionary[@"CashInType"];

        // Exclude only Cash
        if ([cashInStype isEqualToString:@"Cash"]) {
            continue;
        }
        NSString *text1 = [NSString stringWithFormat:@"%@", paymentDictionary[@"Descriptions"]];
        NSString *text2 = [self currencyFormattedAmount:paymentDictionary[@"Amount"]];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:text1 text2:text2];
    }
}

- (void) printTipsTotal {
    if (_isTipSetting) {
        [self defaultFormatForTwoColumn];
        [_printJob printText1:@"Tips" text2:[self currencyFormattedAmount:[self reportSummary][@"TotalTips"]]];
    }
}
- (void) printTotalTips {
    if (_isTipSetting) {
        [self defaultFormatForTwoColumn];
        [_printJob printText1:@"Tips" text2:[self currencyFormattedAmount:[self reportSummary][@"TotalTips"]]];
    }
}
- (void) printAllTipsTotal {
     if (_isTipSetting) {
         [_printJob enableBold:YES];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:@"Total" text2:[self currencyFormattedAmount:[self reportSummary][@"TotalTips"]]];
         [_printJob enableBold:NO];
         [_printJob printLine:@""];
     }
}

- (void) printAllTips {
    if (_isTipSetting) {
        
        NSMutableArray *cardTypeReport= [self getTipTender];
        
        if([cardTypeReport isKindOfClass:[NSArray class]])
        {
            for (int itx=0; itx<cardTypeReport.count; itx++) {
                NSMutableDictionary *cardTypeRptDisc = cardTypeReport[itx];
                
                [self defaultFormatForTwoColumn];
                [_printJob printText1:[cardTypeRptDisc valueForKey:@"Descriptions"] text2:[currencyFormatter stringFromNumber:[cardTypeRptDisc valueForKey:@"TipsAmount"]]];
            }
        }
    }
}
- (void) printTenderTipsBreakup {
    if (!_isTipSetting) {
        return;
    }

    NSArray *tenderReport= [self tenderTypeDetail];

    for (NSMutableDictionary *tenderTypeDictionary in tenderReport) {
        double tenderAmount = [[tenderTypeDictionary valueForKey:@"Amount"] doubleValue] + [[tenderTypeDictionary valueForKey:@"TipsAmount"] doubleValue];
        [self defaultFormatForFourColumn];
        [_printJob printText1:tenderTypeDictionary[@"Descriptions"] text2:[self currencyFormattedAmount:tenderTypeDictionary[@"Amount"]] text3:[self currencyFormattedAmount:tenderTypeDictionary[@"TipsAmount"]] text4:[self currencyFormattedAmount:@(tenderAmount)]];
    }
}

- (void)printTenderTipsFooter {
    if (!_isTipSetting) {
        return;
    }

    NSArray *tenderReport= [self tenderTypeDetail];

    double tenderAmount = 0.0;
    for (NSMutableDictionary *tenderTypeDictionary in tenderReport) {
        tenderAmount += [[tenderTypeDictionary valueForKey:@"Amount"] doubleValue] + [[tenderTypeDictionary valueForKey:@"TipsAmount"] doubleValue];
    }

    [_printJob enableBold:YES];
    [self defaultFormatForFourColumn];
    [_printJob printWrappedText1:@"Total" text2:[self currencyFormattedAmount:[tenderReport valueForKeyPath:@"@sum.Amount"]] text3:[self currencyFormattedAmount:[tenderReport valueForKeyPath:@"@sum.TipsAmount"]] text4:[self currencyFormattedAmount:@(tenderAmount)]];
    [_printJob enableBold:NO];
}

- (void)printGroup20AGrossFuelSales {
    [self defaultFormatForFourColumn];
    [_printJob enableBold:YES];
    [_printJob printWrappedText1:@"GrossFuelSales" text2:@"Gallons" text3:@"Amount" text4:@"Count"];
    [_printJob printSeparator];
    [_printJob enableBold:NO];
}

- (void)printGroup20AOther {
    [self defaultFormatForFourColumn];
    NSDictionary *rptMainDict = [self reportSummary];
    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
    
    NSString *gasCustomerCount = [NSString stringWithFormat:@"%ld",(long)[rptMainDict [@"GasCustomerCount"] integerValue]];
    float fuelPrice = [rptMainDict [@"FuelPrice"] floatValue];
    
    NSNumber *numFuelPrice = @(fuelPrice);

    [_printJob printWrappedText1:@"Other" text2:gallonString text3:[self currencyFormattedAmount:numFuelPrice] text4:gasCustomerCount];
}

- (void)printGroup20AFuelRefund {
    [self defaultFormatForFourColumn];
    
    NSDictionary *rptMainDict = [self reportSummary];
    float fuelRefund = [rptMainDict [@"FuelRefund"] floatValue];
    
    NSNumber *numFuelRefund = @(fuelRefund);

    [_printJob printWrappedText1:@"Fuel Refund" text2:@"" text3:[self currencyFormattedAmount:numFuelRefund] text4:@"0"];
}

- (void)printGroup20ANetFuelSales {
    [self defaultFormatForFourColumn];
    
    NSDictionary *rptMainDict = [self reportSummary];
    float netFuelSales = [rptMainDict [@"GrossFuelSales"] floatValue];
    
    NSNumber *numNetFuelSales = @(netFuelSales);
    
    [_printJob printWrappedText1:@"Net Fuel Sales" text2:@"" text3:[self currencyFormattedAmount:numNetFuelSales] text4:@"0"];
}

- (void)printGroup20FuelType {
    [self defaultFormatForFourColumn];
    [_printJob enableBold:YES];
    [_printJob printWrappedText1:@"Fuel Type" text2:@"$" text3:@"Gallons" text4:@"Cust. Count"];
    [_printJob printSeparator];
    [_printJob enableBold:NO];
}

- (void)printGroup20Other {
    [self defaultFormatForFourColumn];
    
    NSDictionary *rptMainDict = [self reportSummary];
    float fuelPrice = [rptMainDict [@"FuelPrice"] floatValue];
    NSInteger gasCustomerCount = [rptMainDict [@"GasCustomerCount"] integerValue];
    
    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];

    NSNumber *numFuelPrice = @(fuelPrice);
    NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
    
    [_printJob printWrappedText1:@"Other" text2:[self currencyFormattedAmount:numFuelPrice] text3:gallonString text4:gasCustomerCountString];
}

- (void)printGroup21FuelType {
    [self defaultFormatForFourColumn];
    [_printJob enableBold:YES];
    [_printJob printWrappedText1:@"Fuel Type" text2:@"$" text3:@"Gallons" text4:@"Count"];
    [_printJob enableBold:NO];
    [_printJob printSeparator];
}

- (void)printGroup21Other {
    NSDictionary *rptMainDict = [self reportSummary];
    float fuelPrice = [rptMainDict [@"FuelPrice"] floatValue];
    NSInteger gasCustomerCount = [rptMainDict [@"GasCustomerCount"] integerValue];
    
    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
    NSNumber *numFuelPrice = @(fuelPrice);
    NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];

    [_printJob printWrappedText1:@"Other" text2:[self currencyFormattedAmount:numFuelPrice] text3:gallonString text4:gasCustomerCountString];
    [_printJob enableBold:YES];
    [_printJob printWrappedText1:@"Total" text2:[self currencyFormattedAmount:numFuelPrice] text3:gallonString text4:gasCustomerCountString];
    [_printJob enableBold:NO];
}

- (void)printFuelInventory {
    [_printJob enableBold:YES];
    [_printJob printLine:@"FuelType"];
    [self defaultFormatForFourColumn];
    [_printJob printText1:@"StartingGallons" text2:@"Delivery" text3:@"EndingGallons" text4:@"Difference"];
    [_printJob printSeparator];
    [_printJob enableBold:NO];
    NSArray *fuelTypeArray = @[@{ @"FuelType":@"Other",
                                  @"StartingGallons":@"0.00",
                                  @"Delivery":@"0.00",
                                  @"EndingGallons":@"0.00",
                                  @"Difference":@"0.00",
                                  },];
    [self printFuelInventoryBreakup:fuelTypeArray];
    [_printJob enableBold:YES];
    [_printJob printLine:@"Total"];
    [_printJob printText1:@"0.00" text2:@"0.00" text3:@"0.00" text4:@"0.00"];
    [_printJob enableBold:NO];
}

- (void)printFuelPriceChanges {
    [_printJob printLine:@""];
    [_printJob enableBold:YES];
    [_printJob printLine:@"PriceChanges"];
    [_printJob printLine:@"FuelType"];
    [_printJob enableBold:NO];
    NSArray *fuelTypeArray = @[@{ @"FuelType":@"Other",
                                  }];
    [self printPriceChangesBreakup:fuelTypeArray];
}

- (void)printGroup22FuelInventory {
    [self printFuelInventory];
    [self printFuelPriceChanges];
}

- (void)printFuelInventoryBreakup:(NSArray *)fuelTypeArray {
    for (NSDictionary *fuelTypeDictionary in fuelTypeArray) {
        [_printJob printLine:fuelTypeDictionary[@"FuelType"]];
        NSString *textValue = [NSString stringWithFormat:@"%.2f",[fuelTypeDictionary[@"StartingGallons"] floatValue]];
        NSString *text1 = textValue;
        textValue = [NSString stringWithFormat:@"%.2f",[fuelTypeDictionary[@"Delivery"] floatValue]];
        NSString *text2 = textValue;
        textValue = [NSString stringWithFormat:@"%.2f",[fuelTypeDictionary[@"EndingGallons"] floatValue]];
        NSString *text3 = textValue;
        textValue = [NSString stringWithFormat:@"%.2f",[fuelTypeDictionary[@"Difference"] floatValue]];
        NSString *text4 = textValue;
        [self defaultFormatForFourColumn];
        [_printJob printText1:text1 text2:text2 text3:text3 text4:text4];
    }
}

- (void)printPriceChangesBreakup:(NSArray *)fuelTypeArray {
    for (NSDictionary *fuelTypeDictionary in fuelTypeArray) {
        [_printJob enableBold:YES];
        [_printJob printLine:fuelTypeDictionary[@"FuelType"]];
        [self defaultFormatForFourColumn];
        [_printJob printText1:@"Price" text2:@"Gallons" text3:@"Amount" text4:@"Count"];
        [_printJob enableBold:NO];
        [_printJob printText1:@"$0.00" text2:@"0.00" text3:@"$0.00" text4:@"0"];
        [_printJob printText1:@"$0.00" text2:@"0.00" text3:@"$0.00" text4:@"0"];
        [_printJob enableBold:YES];
        [_printJob printText1:@"Average Price" text2:@"Total Gallons" text3:@"Total Amount" text4:@"Total Count"];
        [_printJob printText1:@"$0.00" text2:@"0.00" text3:@"$0.00" text4:@"0"];
        [_printJob enableBold:NO];
    }
}

- (void)printGroup23ATotalFuelTrnx {
    NSDictionary *rptMainDict = [self reportSummary];
    NSNumber *numNetFuelSales = [self calculateNetFuelSales];
    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
    NSInteger gasCustomerCount = [rptMainDict [@"GasCustomerCount"] integerValue];
    NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
    [self defaultFormatForFourColumn];
    [_printJob printText1:@"TotalFuelTrnx" text2:gallonString text3:[self currencyFormattedAmount:numNetFuelSales] text4:gasCustomerCountString];
}

- (void)printGroup23AOtherTrax {
    NSDictionary *rptMainDict = [self reportSummary];
    NSNumber *numNetFuelSales = [self calculateNetFuelSales];
    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
    NSInteger gasCustomerCount = [rptMainDict [@"GasCustomerCount"] integerValue];
    NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];
    [self defaultFormatForFourColumn];
    [_printJob printText1:@"Other Trnx" text2:gallonString text3:[self currencyFormattedAmount:numNetFuelSales] text4:gasCustomerCountString];
}

- (void)printGroup23AVoidFuelTrnx {
    [self defaultFormatForFourColumn];
    [_printJob printText1:@"VoidFuelTrnx" text2:@"0.0" text3:@"$0.00" text4:@"0"];
}

- (void)printGroup23ALineItemDelete {
    [self defaultFormatForFourColumn];
    [_printJob printText1:@"LineItemDelete" text2:@"0.0" text3:@"$0.00" text4:@"0"];
}

- (void)printGroup23ACancelTrnx {
    [self defaultFormatForFourColumn];
    [_printJob printText1:@"CancelTrnx" text2:@"0.0" text3:@"$0.00" text4:@"0"];
}

- (void)printGroup23APriceChanges {
    [self defaultFormatForFourColumn];
    [_printJob printText1:@"PriceChanges" text2:@"0.0" text3:@"$0.00" text4:@"0"];
}

- (void)printGroup23ADriveOffs {
    [self defaultFormatForFourColumn];
    [_printJob printText1:@"DriveOffs" text2:@"0.0" text3:@"$0.00" text4:@"0"];
    [_printJob printLine:@""];
}

- (void)printGroup23AFuelType {
    [_printJob enableBold:YES];
    [_printJob printLine:@"FuelType"];
    [self defaultFormatForFourColumn];
    [_printJob printText1:@"Amount" text2:@"Gallons" text3:@"Count" text4:@"Gas Price"];
    [_printJob enableBold:NO];
    
    NSArray *fuelTypeArray = @[@{ @"FuelType":@"Other",
                                  @"Amount":@"0.00",
                                  @"Gallons":@"0.00",
                                  @"Count":@"0",
                                  @"GasPrice":@"0.00",
                                  }];
    [self printGroup23AFuelTypeBreakup:fuelTypeArray];
}

- (void)printGroup23AFuelTypeBreakup:(NSArray *)fuelTypeArray {
    for (NSDictionary *fuelTypeDictionary in fuelTypeArray) {
        [_printJob printLine:fuelTypeDictionary[@"FuelType"]];
        NSString *textValue = [NSString stringWithFormat:@"$%.2f",[fuelTypeDictionary[@"Amount"] floatValue]];
        NSString *text1 = textValue;
        textValue = [NSString stringWithFormat:@"%.2f",[fuelTypeDictionary[@"Gallons"] floatValue]];
        NSString *text2 = textValue;
        textValue = [NSString stringWithFormat:@"%ld",(long)[fuelTypeDictionary[@"Count"] integerValue]];
        NSString *text3 = textValue;
        textValue = [NSString stringWithFormat:@"$%.2f",[fuelTypeDictionary[@"GasPrice"] floatValue]];
        NSString *text4 = textValue;
        [self defaultFormatForFourColumn];
        [_printJob printText1:text1 text2:text2 text3:text3 text4:text4];
    }
}

- (void)printGroup23BFuelSalesbyPump {
    NSDictionary *rptMainDict = [self reportSummary];
    CGFloat netFuelSales = [rptMainDict [@"GrossFuelSales"] floatValue] - [rptMainDict [@"FuelRefund"] floatValue];
    NSString *netFuelSalesString = [NSString stringWithFormat:@"%.2f",netFuelSales];

    NSString *gallonString = [NSString stringWithFormat:@"%.2f",[rptMainDict [@"FuelCount"] floatValue]];
    NSInteger gasCustomerCount = [rptMainDict [@"GasCustomerCount"] integerValue];
    NSString *gasCustomerCountString = [NSString stringWithFormat:@"%ld",(long)gasCustomerCount];

    NSArray *fuelTypeArray = @[@{@"FuelType":@"Other",
                                      @"Gallons":gallonString,
                                      @"Amount":netFuelSalesString,
                                      @"Total":@"0.00",
                                      @"Count":gasCustomerCountString,
                                      }];
    [self printFuelSalesbyPumpBreakup:fuelTypeArray];
}

- (void)printFuelSalesbyPumpBreakup:(NSArray *)fuelTypeArray {
    for (NSDictionary *fuelTypeDictionary in fuelTypeArray) {
        [_printJob printLine:fuelTypeDictionary[@"FuelType"]];
        NSString *textValue = [NSString stringWithFormat:@"%@",fuelTypeDictionary[@"Gallons"]];
        NSString *text1 = textValue;
        textValue = [NSString stringWithFormat:@"$%@",fuelTypeDictionary[@"Amount"]];
        NSString *text2 = textValue;
        textValue = [NSString stringWithFormat:@"$%@",fuelTypeDictionary[@"Total"]];
        NSString *text3 = textValue;
        textValue = [NSString stringWithFormat:@"%@",fuelTypeDictionary[@"Count"]];
        NSString *text4 = textValue;
        [self defaultFormatForFourColumn];
        [_printJob printText1:text1 text2:text2 text3:text3 text4:text4];
    }
}

- (void)printGroup24HourlyGasSales {
    [self defaultFormatForFourColumn];
    NSArray *rptGASHoursArray = _reportData [@"RptGASHours"];
    NSArray *fuelTypeArray = @[@{ @"FuelType":@"Other",
                                  }];
    if([rptGASHoursArray isKindOfClass:[NSArray class]]){
    
        for (NSDictionary *rptGASHoursDictionary in rptGASHoursArray) {
            [_printJob enableBold:YES];
            NSString *stringFromDate;
            NSDate *date=[self jsonStringToNSDate:[rptGASHoursDictionary valueForKey:@"Hours"]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            formatter.dateFormat = @"hh:mm a";
            stringFromDate = [formatter stringFromDate:date];

            [_printJob printText1:stringFromDate text2:@"Gallons" text3:@"Amount" text4:@"Customer Count"];
            [_printJob printSeparator];
            [_printJob enableBold:NO];

            [self printHourlyGasSalesBreakup:fuelTypeArray withHourlySalesDictionary:rptGASHoursDictionary];
        }
    }
}

-(void)printVersionFooter{
    NSString  *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    [_printJob enableBold:YES];
    [_printJob setTextAlignment:TA_CENTER];
    [_printJob printLine:[NSString stringWithFormat:@"RapidRms (iOS v %@ / %@)",appVersion, buildVersion]];
    [_printJob enableBold:NO];
}

- (void)printHourlyGasSalesBreakup:(NSArray *)fuelTypeArray withHourlySalesDictionary:(NSDictionary *)hourlySalesDictionary {
    for (NSDictionary *fuelTypeDictionary in fuelTypeArray) {
        NSString *textValue = [NSString stringWithFormat:@"%@",fuelTypeDictionary[@"FuelType"]];
        NSString *text1 = textValue;
        textValue = [NSString stringWithFormat:@"%.2f",[hourlySalesDictionary[@"Gallons"] floatValue]];
        NSString *text2 = textValue;
        textValue = [NSString stringWithFormat:@"$%.2f",[hourlySalesDictionary[@"Amount"] floatValue]];
        NSString *text3 = textValue;
        textValue = [NSString stringWithFormat:@"%ld",(long)[hourlySalesDictionary[@"Count"] integerValue]];
        NSString *text4 = textValue;
        [self defaultFormatForFourColumn];
        [_printJob printText1:text1 text2:text2 text3:text3 text4:text4];
    }
}

//#pragma mark - HTML
//
//-(void)LoadReceiptHtml:(NSString *)html{
//    webViewForTCPPrinting = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 576, 200)];
//    webViewForTCPPrinting.delegate = self;
//    NSString *strHtml = [self createHTMLFormateForDisplayReportInWebView:html];
//    [webViewForTCPPrinting loadHTMLString:strHtml baseURL:nil];
//}
//
//- (NSString *)createHTMLFormateForDisplayReportInWebView:(NSString *)html
//{
//    NSString *strReport = [html stringByReplacingOccurrencesOfString:@"$$STYLE$$" withString:@"<style>TD{} TD.TaxType {width: 25%;padding-bottom:3px;} TD.TaxSales {width: 25%;padding-bottom:3px;} TD.TaxTax {width: 25%;padding-bottom:3px;} TD.TaxCustCount {width: 25%;padding-bottom:3px;} TD.TederType { width: 30%;padding-bottom:3px;} TD.TederTypeAmount { width: 40%;padding-bottom:3px;} TD.TederTypeAvgTicket { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.TederTypePer { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.TederTypeCount { width: 30%;padding-bottom:3px;} TD.TipsTederType {width: 25%;padding-bottom:3px;} TD.TipsTederAmount {width: 25%;padding-bottom:3px;} TD.TipsTeder {width: 25%;padding-bottom:3px;}TD.TipsTederTotal {width: 25%;padding-bottom:3px;} TD.CardType { width: 30%;padding-bottom:3px;} TD.CardTypeAmount { width: 40%;padding-bottom:3px;} TD.CardTypeAvgTicket { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.CardTypeTypePer { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.CardTypeCount { width: 30%;padding-bottom:3px;} TD.DepartmentName { width: 25%; padding-bottom:3px;} TD.DepartmentCost { width: 0%; overflow: hidden; display: none; text-indent: -9999; padding-bottom:3px;} TD.DepartmentAmount { width: 25%;padding-bottom:3px;} TD.DepartmentMargin { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.DepartmentPer { width: 25%;padding-bottom:3px;} TD.DepartmentCount { width: 25%;padding-bottom:3px;}TD.HourlySales { width: 30%;padding-bottom:3px;} TD.HourlySalesCost { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.HourlySalesAmount { width: 40%;padding-bottom:3px;} TD.HourlySalesMargin { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.HourlySalesCount { width: 30%;padding-bottom:3px;}</style>"];
//    strReport =  [strReport stringByReplacingOccurrencesOfString:@"$$WIDTH$$" withString:@"width:286px"];
//    strReport = [strReport stringByReplacingOccurrencesOfString:@"$$WIDTHCOMMONHEADER$$" withString:@"width:300px"];
//    return strReport;
//}
//

//#pragma mark - Printing
//- (NSInteger)sectionAtSectionIndex:(NSInteger)sectionIndex {
//    return [_sections[sectionIndex] integerValue];
//}
//
//- (void)configurePrint:(NSString *)portSettings portName:(NSString *)portName withDelegate:(id)delegate
//{
//    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
//    
//    if (isBlueToothPrinter) {
//        _printJob = [[PrintJob alloc] initWithPort:portName portSettings:portSettings   deviceName:@"Printer" withDelegate:delegate];
//        [_printJob enableSlashedZero:YES];
//    }
//    else
//    {
//        _printJob = [[RasterPrintJob alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
//    }
//}
//
//- (void)concludePrint
//{
//    [_printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
//    [_printJob firePrint];
//    _printJob = nil;
//}
//
//- (void)printReportWithPort:(NSString*)portName portSettings:(NSString*)portSettings withDelegate:(id)delegate
//{
//    //    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
//    //
//    ////        #ifdef DEBUG
//    ////                isBlueToothPrinter = NO;
//    ////        #endif
//    //
//    //    if(!isBlueToothPrinter)
//    //    {
//    //        [self _tcpPrintReportWithPort:portName portSettings:portSettings];
//    //    }
//    //    else
//    //    {
//    [self _printReportWithPort:portName portSettings:portSettings withDelegate:delegate];
//    //    }
//}
//
//#pragma mark - TCP Printing
//
//- (void)_tcpPrintReportWithPort:(NSString*)portName portSettings:(NSString*)portSettings
//{
//    _printJob = [[PrintJob alloc] initWithPort:portName portSettings:portSettings deviceName:@"" withDelegate:nil];
//    if (self.generateHtml.length > 0 && self.generateHtml != nil) {
//        [self LoadReceiptHtml:self.generateHtml];
//    }
//}
//
//#pragma mark - Web View Delegate
//
//- (void)webViewDidStartLoad:(UIWebView *)webView{
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    CGFloat height = [webView stringByEvaluatingJavaScriptFromString:@"document.height"].floatValue;
//    CGFloat width = [webView stringByEvaluatingJavaScriptFromString:@"document.width"].floatValue;
//    CGRect frame = webView.frame;
//    frame.size.height = height;
//    frame.size.width = width;
//    webView.frame = frame;
//    [self printImagefromWebview:webView];
//    [webViewForTCPPrinting removeFromSuperview];
//}
//
//#pragma mark - Print Image From Html WebView
//
//-(void)printImagefromWebview:(UIWebView *)pwebview{
//    UIImage *img = [UIImage imageWithData:[self getImageFromView:pwebview]];
//    UIImage *printImage = [self imageResize:img andResizeTo:CGSizeMake(img.size.width * 1.4, img.size.height * 1.4)];
//    [_printJob printImage:printImage];
//    [_printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
//    [_printJob firePrint];
//}
//
//#pragma mark - Image Resizing
//
//- (UIImage *)imageResize:(UIImage*)img andResizeTo:(CGSize)newSize
//{
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
//    [img drawInRect:CGRectMake(-120,0,newSize.width,newSize.height)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}
//
//-(NSData *)getImageFromView:(UIView *)view  // Mine is UIWebView but should work for any
//{
//    NSData *pngImg;
//    //    CGFloat max, scale = 1.0;
//    //    CGSize viewSize = [view bounds].size;
//    
//    // Get the size of the the FULL Content, not just the bit that is visible
//    CGSize size = [view sizeThatFits:CGSizeZero];
//    
//    // Scale down if on iPad to something more reasonable
//    //    max = (viewSize.width > viewSize.height) ? viewSize.width : viewSize.height;
//    //    if( max > 960 )
//    //        scale = 960/max;
//    
//    UIGraphicsBeginImageContextWithOptions( size, YES, 1.0 );
//    
//    // Set the view to the FULL size of the content.
//    view.frame = CGRectMake(0, 0, size.width, size.height);
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [view.layer renderInContext:context];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    pngImg = UIImagePNGRepresentation(image);
//    
//    UIGraphicsEndImageContext();
//    NSLog(@"Image size is  == %@",NSStringFromCGSize(image.size));
//    return pngImg;    // Voila an image of the ENTIRE CONTENT, not just visible bit
//}
//
//#pragma mark - utility
//- (NSString*)stringFromDate:(NSString*)inputDate inputFormat:(NSString*)inputFormat outputFormat:(NSString*)outputFormat {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = inputFormat;
//    NSDate *date = [dateFormatter dateFromString:inputDate];
//
//    dateFormatter.dateFormat = outputFormat;
//
//    NSString *outputDate = [dateFormatter stringFromDate:date];
//    return outputDate;
//}
//
//- (NSString*)stringFromDate:(NSDate*)date format:(NSString*)format {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = format;
//
//    NSString *dateAsString = [dateFormatter stringFromDate:date];
//    return dateAsString;
//}
//
//- (NSString*)percentageFormattedAmount:(NSNumber*)amount {
//    if (![amount isKindOfClass:[NSNumber class]]) {
//        if ([amount isKindOfClass:[NSString class]]) {
//            amount = @(amount.floatValue);
//        }
//    }
//
//    NSString *formattedAmount = [NSString stringWithFormat:@"%.2f%%", amount.floatValue];
//    return formattedAmount;
//}
//
//- (NSString*)currencyFormattedAmount:(NSNumber*)amount {
//    if (![amount isKindOfClass:[NSNumber class]]) {
//        if ([amount isKindOfClass:[NSString class]]) {
//            amount = @(amount.floatValue);
//        }
//    }
//
//    NSString *formattedAmount = [_rmsDbController.currencyFormatter stringFromNumber:amount];
//    return formattedAmount;
//}
//
//- (NSString*)currencyFormattedAmountForKey:(NSString*)amountKey fromDictionary:(NSDictionary*)dictionary {
//    NSNumber *amount = dictionary[amountKey];
//    NSString *formattedAmount = [_rmsDbController.currencyFormatter stringFromNumber:amount];
//    return formattedAmount;
//}
//
//
//-(NSDate*)jsonStringToNSDate:(NSString*)string
//{
//    // Extract the numeric part of the date.  Dates should be in the format
//    // "/Date(x)/", where x is a number.  This format is supplied automatically
//    // by JSON serialisers in .NET.
//    NSRange range = NSMakeRange(6, string.length - 8);
//    NSString* substring = [string substringWithRange:range];
//
//    // Have to use a number formatter to extract the value from the string into
//    // a long long as the longLongValue method of the string doesn't seem to
//    // return anything useful - it is always grossly incorrect.
//    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
//    NSNumber* milliseconds = [formatter numberFromString:substring];
//    // NSTimeInterval is specified in seconds.  The value we get back from the
//    // web service is specified in milliseconds.  Both values are since 1st Jan
//    // 1970 (epoch).
//    NSTimeInterval seconds = milliseconds.longLongValue / 1000;
//
//    return [NSDate dateWithTimeIntervalSince1970:seconds];
//}
@end
