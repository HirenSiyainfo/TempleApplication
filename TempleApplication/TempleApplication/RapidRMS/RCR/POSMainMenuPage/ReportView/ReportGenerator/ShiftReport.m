//
//  ShiftReport.m
//  HtmlSS
//
//  Created by Siya Infotech on 20/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ShiftReport.h"
#import "ReportConstants.h"

@interface ShiftReport ()
{
    RmsDbController *_rmsDbController;
    NSNumberFormatter *currencyFormatter;
    BOOL _isRcrGasActive;
}
@end

@implementation ShiftReport

- (void)configureXReportSections {
    
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (_rmsDbController.globalDict)[@"DeviceId"]];
    
    NSArray *activeModulesArray = [[_rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    
    _isRcrGasActive = [self isRcrGasActive:activeModulesArray];
    if(_isRcrGasActive){
        
        _sections = @[
                      @(ReportSectionReportHeader),
                      @(ReportSectionHeader),
                      //@(ReportSectionSales),
                      // @(ReportSectionPetroSales),
                      // @(ReportSection3),
                      @(ReportSectionDailySales),
                      @(ReportSectionGroup5A),
                      // @(ReportSectionAllTaxes),
                      //@(ReportSectionAllDetails),
                      @(ReportSectionOpeningAmount),
                      @(ReportSectionNoneSales),
                      @(ReportSectionMerchandiseSales),
                      @(ReportSectionLotterySales),
                      @(ReportSectionGasSales),
                      @(ReportSectionMoneyOrder),
                      @(ReportSectionGiftCardSales),
                      @(ReportSectionCheckCash),
                      @(ReportSectionVendorPayout),
                      @(ReportSectionHouseCharge),
                      @(ReportSectionSalesOther),
                      @(ReportSectionAllSalesTotal),
                      @(ReportSection4),
                      @(ReportSectionOverShort),
                      @(ReportSection6),
                      @(ReportSection7),
                      // @(ReportSectionCustomer),
                      @(ReportSectionDiscount),
                      @(ReportSectionPaymentMode),
                      @(ReportSectionTenderTips),
                      //                      @(ReportSectionGiftCard),
                      @(ReportSectionCardType),
                      @(ReportSectionCardTypeOutSide),
                      //                      @(ReportSectionGroup20A),
                      //                      @(ReportSectionGroup20),
                      //                      @(ReportSectionGroup21),
                      //                      @(ReportSectionGroup22),
                      //                      @(ReportSectionGroup23A),
                      //                      @(ReportSectionGroup23B),
                      //                      @(ReportSectionGroup24),
                      @(ReportSectionCardFuelSummery),
                      @(ReportSectionPumpSummery),
                      @(ReportSectionReportFooter),
                      ];
        [self removeBlankMerchandiseSection:_sections];
    }
    else{
        _sections = @[
                      @(ReportSectionReportHeader),
                      @(ReportSectionHeader),
                      //@(ReportSectionSales),
                      //@(ReportSection3),
                      @(ReportSectionDailySales),
                      // @(ReportSectionAllTaxes),
                      //@(ReportSectionAllDetails),
                      @(ReportSectionOpeningAmount),
                      @(ReportSectionNoneSales),
                      @(ReportSectionMerchandiseSales),
                      @(ReportSectionLotterySales),
                      // @(ReportSectionGasSales),
                      @(ReportSectionMoneyOrder),
                      @(ReportSectionGiftCardSales),
                      @(ReportSectionCheckCash),
                      @(ReportSectionVendorPayout),
                      @(ReportSectionHouseCharge),
                      @(ReportSectionSalesOther),
                      @(ReportSectionAllSalesTotal),
                      @(ReportSection4),
                      @(ReportSectionOverShort),
                      @(ReportSection6),
                      @(ReportSection7),
                      //@(ReportSectionCustomer),
                      @(ReportSectionDiscount),
                      @(ReportSectionPaymentMode),
                      @(ReportSectionTenderTips),
                      //                      @(ReportSectionGiftCard),
                      @(ReportSectionCardType),
                      @(ReportSectionReportFooter),
                      ];
        [self removeBlankMerchandiseSection:_sections];
    }
    
    /*
     Report Header
     
     Sales Summary
     Shift Summary
     CashFlow
     Over/Short
     
     Average
     Discount
     Taxes
     Tender Type
     Gift Card
     Credit Cards
     Departments
     Outflow
     Hourly Sales
     */
    NSArray *reportHeaderSectionFields = @[
                                           @(ReportFieldStoreName),
                                           @(ReportFieldAddressLine1),
                                           @(ReportFieldAddressLine2),
                                           @(ReportFieldReportName),
                                           ];
    
    NSArray *headerSectionFields = @[
                                     @(ReportFieldReportDay),
                                     @(ReportFielShiftOpenBy),
                                     @(ReportFieldName),
                                     @(ReportFieldRegister),
                                     @(ReportFieldDateTime),
                                     @(ReportFieldStartDateTime),
                                     @(ReportFieldEndDateTime),
                                     @(ReportFieldBatchNo),
                                     @(ReportFieldShiftNo),
                                     ];
    
    NSArray *salesSectionFields = @[
                                    @(ReportFieldGrossSales),
                                    @(ReportFieldTaxes),
                                    @(ReportFieldNetSales),
                                    @(ReportFieldGrossSales),
                                    ];
    
    NSArray *petroSalesSectionFields = @[
                                         @(ReportFieldPetroNetFuelSales),
                                         ];
    
    
    NSArray *sectionDailySales = @[
                                   @(ReportFieldGrossSales),
                                   @(ReportFieldDailySales),
                                   //@(ReportFieldInsideGasSales),
                                   //@(ReportFieldOutSideGasSales),
                                   @(ReportFieldAllTaxes),
                                   @(ReportFieldNetSales),
                                   @(ReportFieldDeposit)
                                   ];
    
    NSArray *sectionGroupAllTaxesFields = @[
                                            @(ReportFieldAllTaxes),
                                            ];
    
    NSArray *section3Fields = @[
                                @(ReportFieldOpeningAmount),
                                @(ReportFieldSales),
                                @(ReportFieldReturn),
                                @(ReportFieldSection3Total),
                                @(ReportFieldSection3Taxes),
                                @(ReportFieldSurCharge),
                                @(ReportFieldTips),
                                @(ReportFieldGiftCard),
                                @(ReportFieldMoneyOrder),
                                ];
    
    NSArray *sectionGroup5AFields = @[
                                      @(ReportFieldGrossFuelSales),
                                      @(ReportFieldFuelRefund),
                                      @(ReportFieldNetFuelSales),
                                      ];
    
    NSArray *sectionGroupOpeningAmountFields = @[
                                                 @(ReportFieldOpeningAmount),
                                                 ];
    NSArray *sectionGroupNoneFields = @[
                                        @(ReportFieldSales),
                                        @(ReportFieldReturn),
                                        @(ReportFieldSection3Total),
                                        ];
    
    NSArray *sectionGroupMerchandiseFields = @[
                                               @(ReportFieldMerchandiseSales),
                                               @(ReportFieldMerchandiseReturn),
                                               @(ReportFieldMerchandiseDiscount),
                                               ];
    
    
    
    NSArray *sectionGroupAllTaxesDetailsFields = @[
                                                   @(ReportFieldAllTaxesDetails),
                                                   ];
    
    
    
    NSArray *sectionGroupLotteryFields = @[
                                           @(ReportFieldLotterySales),
                                           @(ReportFieldLotteryProfit),
                                           @(ReportFieldLotteryReturn),
                                           @(ReportFieldLotteryDiscount),
                                           @(ReportFieldLotteryPayout)
                                           ];
    
    NSArray *sectionGroupGasFields = @[
                                       @(ReportFieldGasSales),
                                       @(ReportFieldGasProfit),
                                       @(ReportFieldGasReturn),
                                       @(ReportFieldGasDiscount),
                                       @(ReportFieldGasQty),
                                       ];
    
    NSArray *sectionGroupMoneyOrderFields = @[
                                              @(ReportFieldMoneyOrderSales),
                                              @(ReportFieldMoneyOrderSalesFee),
                                              @(ReportFieldMoneyOrderReturn),
                                              @(ReportFieldMoneyOrderDiscount)
                                              ];
    
    NSArray *sectionGroupGiftCardFields = @[
                                            @(ReportFieldGiftCardSales),
                                            @(ReportFieldGiftCardFee),
                                            @(ReportFieldGiftCardReturn),
                                            @(ReportFieldGiftCardDiscount)
                                            ];
    
    NSArray *sectionGroupCheckCashFields = @[
                                             @(ReportFieldCheckCashSales),
                                             @(ReportFieldCheckCashFee),
                                             @(ReportFieldCheckCashReturn),
                                             @(ReportFieldCheckCashDiscount),
                                             ];
    
    NSArray *sectionGroupPayoutFields = @[
                                          @(ReportFieldPayoutSales),
                                          @(ReportFieldPayoutReturn),
                                          @(ReportFieldPayoutDiscount),
                                          ];
    
    NSArray *sectionGroupHouseChargeFields = @[
                                               @(ReportFieldHouseChargeSales),
                                               @(ReportFieldHouseChargeReturn),
                                               @(ReportFieldHouseChargeDiscount),
                                               ];
    
    
    NSArray *sectionOtherSalesFields = @[
                                         @(ReportFieldOtherSales),
                                         @(ReportFieldOtherReturn),
                                         @(ReportFieldOtherDiscount),
                                         ];
    
    
    NSArray *sectionAllSalesTotalFields = @[
                                            @(ReportFieldAllTips),
                                            @(ReportFieldAllTipsTotal),
                                            @(ReportFieldSection3Taxes),
                                            @(ReportFieldSurCharge),
                                            @(ReportFieldTips),
                                            @(ReportFieldGiftCard),
                                            @(ReportFieldMoneyOrder),
                                            ];
    
    
    NSArray *section4Fields = @[
                                @(ReportFieldDropAmount),
                                @(ReportFieldPaidOut),
                                @(ReportFieldClosingAmount),
                                @(ReportFieldTenderTypeXCashOther)
                                ];
    
    
    NSArray *sectionOverShort = @[
                                  @(ReportFieldOverShort),
                                  ];
    
    NSArray *section6 = @[
                          @(ReportFieldNoSales),
                          @(ReportFieldLineItemVoid),
                          @(ReportFieldCancelTrans),
                          @(ReportFieldPriceChangeCount),
                          @(ReportFieldVoidTrans)
                          ];
    
    
    
    NSArray *section7 = @[
                          @(ReportFieldGCLiabiality),
                          @(ReportFieldCheckCash),
                          @(ReportFieldCostofGoods),
                          @(ReportFieldMargin),
                          @(ReportFieldProfit),
                          @(ReportFieldInventory)
                          ];
    
    
    NSArray *sectionCustomer = @[
                                 @(ReportFieldCustomer),
                                 @(ReportFieldAvgTicket),
                                 ];
    
    NSArray *discountSectionFields = @[
                                       @(ReportFieldDiscountSection),
                                       @(ReportFieldCustomizedDiscount),
                                       @(ReportFieldManualDiscount),
                                       @(ReportFieldPreDefinedDiscount),
                                       ];
    
    NSArray *sectionPaymentMode = @[
                                    @(ReportFieldTenderType)
                                    ];
    
    NSArray *sectionTenderTips = @[
                                   @(ReportFieldTenderTips)
                                   ];
    
    NSArray *giftCardSectionfields = @[
                                       @(ReportFieldGiftCardPreviousBalance),
                                       @(ReportFieldLoadGiftCard),
                                       @(ReportFieldRedeemGiftCard),
                                       @(ReportFieldGiftCardTotal)
                                       ];
    
    
    NSArray *cardTypeSectionFields = @[
                                       @(ReportFieldCardType)
                                       ];
    
    NSArray *cardTypeOutSideSectionFields = @[
                                              @(ReportFieldCardTypeOutSide)
                                              ];
    
    NSArray *fuelSummerySectionFields = @[
                                          @(ReportFieldFuelSummery)
                                          ];
    
    NSArray *pumpSummerySectionFields = @[
                                          @(ReportFieldPumpSummery)
                                          ];
    
    
    
    
    NSArray *sectionGroup20AFields = @[
                                       @(ReportFieldGroup20AGrossFuelSales),
                                       @(ReportFieldGroup20AOther),
                                       @(ReportFieldGroup20AFuelRefund),
                                       @(ReportFieldGroup20ANetFuelSales),
                                       ];
    
    NSArray *sectionGroup20Fields = @[
                                      @(ReportFieldGroup20FuelType),
                                      @(ReportFieldGroup20Other),
                                      ];
    NSArray *sectionGroup21Fields = @[
                                      @(ReportFieldGroup21FuelType),
                                      @(ReportFieldGroup21Other),
                                      ];
    
    NSArray *sectionGroup22Fields = @[
                                      @(ReportFieldGroup22FuelInventory),
                                      ];
    
    NSArray *sectionGroup23AFields = @[
                                       @(ReportFieldGroup23ATotalFuelTrnx),
                                       @(ReportFieldGroup23AOtherTrnx),
                                       @(ReportFieldGroup23AVoidFuelTrnx),
                                       @(ReportFieldGroup23ALineItemDelete),
                                       @(ReportFieldGroup23ACancelTrnx),
                                       @(ReportFieldGroup23APriceChanges),
                                       @(ReportFieldGroup23ADriveOffs),
                                       @(ReportFieldGroup23AFuelType),
                                       ];
    
    NSArray *sectionGroup23BFields = @[
                                       @(ReportFieldGroup23BFuelSalesbyPump),
                                       ];
    
    NSArray *sectionGroup24Fields = @[
                                      @(ReportFieldGroup24HourlyGasSales),
                                      ];
    
    
    NSArray *footerSectionFields = @[
                                     ];
    
    sectionDailySales = [self removeInsideOutSideGasSales:sectionDailySales isGasActive:_isRcrGasActive];
    sectionAllSalesTotalFields = [self removeGiftCardMoneyOrder:sectionAllSalesTotalFields];
    section7 = [self removeCheckCash:section7];

    
    if (_isRcrGasActive) {
        sectionGroup5AFields = [self removeGrossFuelSales:sectionGroup5AFields];
        _fields = @[
                    reportHeaderSectionFields,
                    headerSectionFields,
                    //salesSectionFields,
                    //petroSalesSectionFields,
                    //section3Fields,
                    sectionDailySales,
                    sectionGroup5AFields,
                    //sectionGroupAllTaxesFields,
                    //sectionGroupAllTaxesDetailsFields,
                    sectionGroupOpeningAmountFields,
                    sectionGroupNoneFields,
                    sectionGroupMerchandiseFields,
                    sectionGroupLotteryFields,
                    sectionGroupGasFields,
                    sectionGroupMoneyOrderFields,
                    sectionGroupGiftCardFields,
                    sectionGroupCheckCashFields,
                    sectionGroupPayoutFields,
                    sectionGroupHouseChargeFields,
                    sectionOtherSalesFields,
                    sectionAllSalesTotalFields,
                    section4Fields,
                    sectionOverShort,
                    section6,
                    section7,
                    // sectionCustomer,
                    discountSectionFields,
                    sectionPaymentMode,
                    sectionTenderTips,
                    //                giftCardSectionfields,
                    cardTypeSectionFields,
                    cardTypeOutSideSectionFields,
                    //                sectionGroup20AFields,
                    //                sectionGroup20Fields,
                    //                sectionGroup21Fields,
                    //                sectionGroup22Fields,
                    //                sectionGroup23AFields,
                    //                sectionGroup23BFields,
                    //                sectionGroup24Fields,
                    fuelSummerySectionFields,
                    pumpSummerySectionFields,
                    footerSectionFields,
                    ];
        [self removeBlankMerchandiseFields:_fields withobject:@[sectionGroupMerchandiseFields,sectionGroupLotteryFields,sectionGroupGasFields,sectionGroupMoneyOrderFields,sectionGroupGiftCardFields,sectionGroupCheckCashFields,sectionGroupPayoutFields,sectionGroupHouseChargeFields,sectionOtherSalesFields]];
    }
    else {
        
        _fields = @[
                    reportHeaderSectionFields,
                    headerSectionFields,
                    //salesSectionFields,
                    //section3Fields,
                    sectionDailySales,
                    // sectionGroupAllTaxesFields,
                    // sectionGroupAllTaxesDetailsFields,
                    sectionGroupOpeningAmountFields,
                    sectionGroupNoneFields,
                    sectionGroupMerchandiseFields,
                    sectionGroupLotteryFields,
                    sectionGroupMoneyOrderFields,
                    sectionGroupGiftCardFields,
                    sectionGroupCheckCashFields,
                    sectionGroupPayoutFields,
                    sectionGroupHouseChargeFields,
                    sectionOtherSalesFields,
                    sectionAllSalesTotalFields,
                    section4Fields,
                    sectionOverShort,
                    section6,
                    section7,
                    // sectionCustomer,
                    discountSectionFields,
                    sectionPaymentMode,
                    sectionTenderTips,
                    //                    giftCardSectionfields,
                    cardTypeSectionFields,
                    footerSectionFields,
                    ];
        [self removeBlankMerchandiseFields:_fields withobject:@[sectionGroupMerchandiseFields,sectionGroupLotteryFields,sectionGroupGasFields,sectionGroupMoneyOrderFields,sectionGroupGiftCardFields,sectionGroupCheckCashFields,sectionGroupPayoutFields,sectionGroupHouseChargeFields,sectionOtherSalesFields]];
    }
}

-(NSArray *)removeInsideOutSideGasSales:(NSArray *)sectionDailySales isGasActive:(BOOL)isGas{
    
    if(!isGas){
        
        NSMutableArray *dailySales = [sectionDailySales mutableCopy];
        [dailySales removeObject: @(ReportFieldInsideGasSales)];
        [dailySales removeObject: @(ReportFieldOutSideGasSales)];
        sectionDailySales = dailySales;
        return sectionDailySales;
    }
    else{
        return sectionDailySales;
    }
}

-(NSArray *)removeGiftCardMoneyOrder:(NSArray *)sectionAllSalesTotalFields {
    
    NSMutableArray *sections = [sectionAllSalesTotalFields mutableCopy];
    
    if([self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder] && [[self reportSummary] [@"MoneyOrder"] doubleValue] == 0){
        [sections removeObject:@(ReportFieldMoneyOrder)];
    }
    if([self getSalesByDeptTypebyId:DepartmentTypeGiftCard] && [[self reportSummary] [@"LoadAmount"] doubleValue] == 0){
        [sections removeObject:@(ReportFieldGiftCard)];
    }
    return sections;
}

-(NSArray *)removeCheckCash:(NSArray *)sectionAllSalesTotalFields {
    NSMutableArray *sections = [sectionAllSalesTotalFields mutableCopy];
    if([self getSalesByDeptTypebyId:DepartmentTypeCheckCash] && [[self reportSummary] [@"CheckCash"] doubleValue] == 0){
        [sections removeObject:@(ReportFieldCheckCash)];
    }
    return sections;
}

-(NSArray *)removeGrossFuelSales:(NSArray *)sectionAllSalesTotalFields {
    
    NSMutableArray *sections = [sectionAllSalesTotalFields mutableCopy];
    
    if([self getSalesByDeptTypebyId:DepartmentTypeGas] && [[self reportSummary] [@"GrossFuelSales"] doubleValue] == 0){
        [sections removeObject:@(ReportFieldGrossFuelSales)];
        [sections removeObject:@(ReportFieldFuelRefund)];
        [sections removeObject:@(ReportFieldNetFuelSales)];
    }
    return sections;
}

-(void)removeBlankMerchandiseSection:(NSArray *)mainSections{
    
    NSMutableArray *sections = [mainSections mutableCopy];
    
    if(![self getSalesByDeptTypebyId:DepartmentTypeMerchandise]){
        [sections removeObject:@(ReportSectionMerchandiseSales)];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeLottery]){
        [sections removeObject:@(ReportSectionLotterySales)];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeGas]){
        [sections removeObject:@(ReportSectionGasSales)];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder]){
        [sections removeObject:@(ReportSectionMoneyOrder)];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeGiftCard]){
        [sections removeObject:@(ReportSectionGiftCardSales)];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeCheckCash]){
        [sections removeObject:@(ReportSectionCheckCash)];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeVendorPayout]){
        [sections removeObject:@(ReportSectionVendorPayout)];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeHouseCharge]){
        [sections removeObject:@(ReportSectionHouseCharge)];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeOther]){
        [sections removeObject:@(ReportSectionSalesOther)];
    }
    _sections = sections;
}
-(void)removeBlankMerchandiseFields:(NSArray *)mainField withobject:(NSArray *)objects{
    
    NSMutableArray *fields = [mainField mutableCopy];
    
    if(![self getSalesByDeptTypebyId:DepartmentTypeMerchandise]){
        [fields removeObject:objects[0]];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeLottery]){
        [fields removeObject:objects[1]];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeGas]){
        [fields removeObject:objects[2]];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeMoneyOrder]){
        [fields removeObject:objects[3]];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeGiftCard]){
        [fields removeObject:objects[4]];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeCheckCash]){
        [fields removeObject:objects[5]];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeVendorPayout]){
        [fields removeObject:objects[6]];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeHouseCharge]){
        [fields removeObject:objects[7]];
    }
    if(![self getSalesByDeptTypebyId:DepartmentTypeOther]){
        [fields removeObject:objects[8]];
    }
    _fields = fields;
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
- (instancetype)initWithDictionary:(NSDictionary *)shiftReportData reportName:(NSString *)reportName
{
    self = [super init];
    if (self) {
        _reportData = shiftReportData;
        _reportName = reportName;
        [self configureXReportSections];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)shiftReportData reportName:(NSString *)reportName isTips:(BOOL)isTips {
     _rmsDbController = [RmsDbController sharedRmsDbController];
    self = [self initWithDictionary:shiftReportData reportName:reportName];
    _isTipSetting = isTips;
    currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatter.maximumFractionDigits = 2;
    return self;
}



#pragma mark - Print Methods
-(NSDictionary *)getSalesByDeptType:(NSString *)deptType{
    
    NSArray *salesArray  = _reportData[@"objShiftSales"];
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
    
    NSArray *salesArray  = _reportData[@"objShiftSales"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DeptTypeId  = %d",deptTypeid];
    salesArray = [salesArray filteredArrayUsingPredicate:predicate];
    if(salesArray.count > 0){
        return salesArray[0];
    }
    else{
        return nil;
    }
}

-(NSMutableArray *)getTipTender{
    
    NSMutableArray *tenderArray = _reportData[@"objShiftTender"];
    if(tenderArray.count > 0){
        return tenderArray;
    }
    return nil;
}
- (NSDictionary*)reportSummary {
    return _reportData[@"objShiftDetail"][0];
}
- (NSArray*)fuelTypeDetail {
    return _reportData[@"objShiftFuel"];
}
- (NSArray*)pumpDetail {
    return _reportData[@"objShiftPump"];
}

- (NSArray*)tenderTypeDetail {
    return _reportData[@"objShiftTender"];
}
- (NSArray*)cardTypeDetail {
    return _reportData[@"objShiftCardType"];
}
- (NSArray *)discountDetails
{
    return _reportData[@"objShiftDiscount"];
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

- (void)printShiftOpenBy {
    NSString *text1 = REPORT_SHIFT_OPEN_BY;
    NSString *text2 = [self reportSummary][@"ShiftOpenByUser"];
    [_printJob printText1:text1 text2:text2];
}

- (void)printName {
    NSString *text1 = REPORT_SHIFT_USER_NAME;
    NSString *text2 = [self reportSummary][@"UserName"];
    [_printJob printText1:text1 text2:text2];
}

- (void)printEndDateTime
{
    NSString *endDate = [self dateFromDictionary:[self reportSummary] timeKey:@"CloseTime" dateKey:@"CloseDate"];
    [_printJob printText1:@"End Date & Time:" text2:endDate];
}

- (void)printStartDateTime {
    NSString *startDate = [self dateFromDictionary:[self reportSummary] timeKey:@"StartTime" dateKey:@"Startdate"];
    [_printJob printText1:@"Start Date & Time:" text2:startDate];
}

- (void)printShiftNo {
    [_printJob printText1:REPORT_SHIFT_NO text2:[[self reportSummary][@"ShiftNo"] stringValue]];
}

#pragma mark - Html Methods

- (NSString *)htmlForShiftOpenBy
{
    return [self htmlForkey:REPORT_SHIFT_OPEN_BY value:[self reportSummary] [@"ShiftOpenByUser"]];
}

- (NSString *)htmlForName
{
    return [self htmlForkey:REPORT_SHIFT_USER_NAME value:[self reportSummary] [@"UserName"]];
}

- (NSString *)htmlForStartDateTime {
    NSString *dateAndTime = [self dateFromDictionary:[self reportSummary] timeKey:@"StartTime" dateKey:@"Startdate"];
    return [self htmlForkey:REPORT_START_DATE_AND_START_TIME value:dateAndTime];
}

- (NSString *)htmlForEndDateTime {
    NSString *endDate = [self dateFromDictionary:[self reportSummary] timeKey:@"CloseTime" dateKey:@"CloseDate"];
    return [self htmlForkey:REPORT_END_DATE_AND_END_TIME value:endDate];
}

- (NSString *)htmlForShiftNo {
    return [self htmlForkey:REPORT_SHIFT_NO value:[self reportSummary][@"ShiftNo"]];
}

@end
