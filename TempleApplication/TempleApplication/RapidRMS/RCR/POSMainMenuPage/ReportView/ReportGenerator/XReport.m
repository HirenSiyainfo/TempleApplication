    //
//  ShiftReport.m
//  HtmlSS
//
//  Created by Siya Infotech on 20/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "XReport.h"
#import "RmsDbController.h"
#import "ReportConstants.h"

//#ifdef DEBUG
#define PETRO_SECTIONS_ENABLED
//#endif

@interface XReport () {
    RmsDbController *_rmsDbController;
    NSNumberFormatter *currencyFormatter ;
    BOOL _isRcrGasActive;
}

@end

@implementation XReport

- (void)configureXReportSections {
    
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (_rmsDbController.globalDict)[@"DeviceId"]];
    
    NSArray *activeModulesArray = [[_rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    
    _isRcrGasActive = [self isRcrGasActive:activeModulesArray];

    if (_isRcrGasActive) {
        _sections = @[
                      @(ReportSectionReportHeader),
                      @(ReportSectionHeader),
                     // @(ReportSectionSales),
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
                      //@(ReportSectionCustomer),
                      @(ReportSectionTaxes),
                      @(ReportSectionPaymentMode),
                      @(ReportSectionTenderTips),
//                      @(ReportSectionGiftCard),
                      @(ReportSectionCardType),
                      @(ReportSectionCardTypeOutSide),
                      @(ReportSectionDiscount),
                      @(ReportSectionDepartment),
                      @(ReportSectionNonMerchandiseDepartment),
                      @(ReportSectionPayout),
                      @(ReportSectionHourlySales),
//                      @(ReportSectionGroup20A),
//                      @(ReportSectionGroup20),
//                      @(ReportSectionGroup21),
//                      @(ReportSectionGroup22),
//                      @(ReportSectionGroup23A),
//                      @(ReportSectionGroup23B),
                     // @(ReportSectionGroup24),
                      @(ReportSectionCardFuelSummery),
                      @(ReportSectionPumpSummery),
                      @(ReportSectionReportFooter),
                      ];
         [self removeBlankMerchandiseSection:_sections];
        
//#ifdef MERCHANDIZE_ENABLE
//        NSMutableArray *sections = [_sections mutableCopy];
//        [sections removeObject:@(ReportSectionPetroSales)];
//        [sections removeObject:@(ReportSection3)];
//        [sections removeObject:@(ReportSectionGroup5A)];
//        _sections = sections;
//#endif
     
        
    }
    else
    {
        _sections = @[
                      @(ReportSectionReportHeader),
                      @(ReportSectionHeader),
                      //@(ReportSectionSales),
                     // @(ReportSection3),
                      @(ReportSectionDailySales),
                     // @(ReportSectionAllTaxes),
                      //@(ReportSectionAllDetails),
                      @(ReportSectionOpeningAmount),
                      @(ReportSectionNoneSales),
                      @(ReportSectionMerchandiseSales),
                      @(ReportSectionLotterySales),
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
                      @(ReportSectionTaxes),
                      @(ReportSectionPaymentMode),
                      @(ReportSectionTenderTips),
//                      @(ReportSectionGiftCard),
                      @(ReportSectionCardType),
                      @(ReportSectionDiscount),
                      @(ReportSectionDepartment),
                      @(ReportSectionNonMerchandiseDepartment),
                      @(ReportSectionPayout),
                      @(ReportSectionHourlySales),
                      @(ReportSectionReportFooter),
                      ];
        
         [self removeBlankMerchandiseSection:_sections];
        
//#ifdef MERCHANDIZE_ENABLE
//        NSMutableArray *sections = [_sections mutableCopy];
//        [sections removeObject:@(ReportSection3)];
//        _sections = sections;
//#endif
        
      //
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
                                     @(ReportFieldName),
                                     @(ReportFieldRegister),
                                     @(ReportFieldDateTime),
                                     @(ReportFieldStartDateTime),
                                     @(ReportFieldEndDateTime),
                                     @(ReportFieldBatchNo),
                                     @(ReportFieldCentralizeRegister),
                                     ];
    
    NSArray *salesSectionFields = @[
                                    @(ReportFieldGrossSales),
                                    @(ReportFieldTaxes),
                                    @(ReportFieldNetSales),
                                    ];
    
    NSArray *petroSalesSectionFields = @[
                                    @(ReportFieldPetroNetFuelSales),
                                    ];
    
    
    NSArray *sectionDailySales = @[
                                   @(ReportFieldGrossSales),
                                   @(ReportFieldDailySales),
                                   @(ReportFieldAllTaxes),
//                                   @(ReportFieldInsideGasSales),
//                                   @(ReportFieldOutSideGasSales),
                                   @(ReportFieldNetSales),
                                   @(ReportFieldDeposit)
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
    
    NSArray *sectionGroupAllTaxesFields = @[
                                            @(ReportFieldAllTaxes),
                                               ];

    NSArray *sectionGroupAllTaxesDetailsFields = @[
                                                   @(ReportFieldAllTaxesDetails),
                                                   ];
    
    NSArray *sectionGroupLotryFields = @[
                                         @(ReportFieldLotterySales),
                                         @(ReportFieldLotteryProfit),
                                         @(ReportFieldLotteryReturn),
                                         @(ReportFieldLotteryDiscount),
                                         @(ReportFieldLotteryPayout),
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
    
    NSArray *sectionGroupHouseChargeFields = @[
                                               @(ReportFieldHouseChargeSales),
                                               @(ReportFieldHouseChargeReturn),
                                               @(ReportFieldHouseChargeDiscount),
                                               ];
    
    NSArray *sectionGroupPayoutFields = @[
                                          @(ReportFieldPayoutSales),
                                          @(ReportFieldPayoutReturn),
                                          @(ReportFieldPayoutDiscount),
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

    
    NSArray *sectionGroupCheckCashFields = @[
                                             @(ReportFieldCheckCashSales),
                                             @(ReportFieldCheckCashFee),
                                             @(ReportFieldCheckCashReturn),
                                             @(ReportFieldCheckCashDiscount),
                                             ];
    
    NSArray *section4Fields = @[
                                @(ReportFieldDropAmount),
                                @(ReportFieldPaidOut),
                                @(ReportFieldClosingAmount),
                                @(ReportFieldTenderTypeXCashOther),
//                                @(ReportFieldCreditCardTotal),
//                                @(ReportFieldStandAloneTotal),
//                                @(ReportFieldChequeTotal),
//                                @(ReportFieldGiftCardTotal),
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

    NSArray *sectionTaxes = @[
                              @(ReportFieldTaxesSection)
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
    
    NSArray *sectionDepartment = @[
                                   @(ReportFieldDepartment),
                                   ];
    
    NSArray *sectionNonMerchandiseDepartment = @[
                                     @(ReportFieldNonMerchandiseDepartment)
                                     ];

    NSArray *payoutSectionFields = @[
                                   @(ReportFieldPayOutDepartment)
                                   ];

    NSArray *sectionHourlySales = @[
                                    @(ReportFieldHourlySales)
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
                                     @(ReportFieldVersionFooter),
                                     ];

    if([_reportName isEqualToString:@"Centralize Z"]){
       
        NSMutableArray *headerFields = [headerSectionFields mutableCopy];
        [headerFields removeObject:@(ReportFieldRegister)];
        [headerFields removeObject:@(ReportFieldStartDateTime)];
        [headerFields removeObject:@(ReportFieldEndDateTime)];
        [headerFields removeObject:@(ReportFieldBatchNo)];
        headerSectionFields = headerFields;
    }
    else{
        NSMutableArray *headerFields = [headerSectionFields mutableCopy];
        [headerFields removeObject: @(ReportFieldCentralizeRegister)];
        headerSectionFields = headerFields;
       
    }
    
    sectionDailySales = [self removeInsideOutSideGasSales:sectionDailySales isGasActive:_isRcrGasActive];
    sectionAllSalesTotalFields = [self removeGiftCardMoneyOrder:sectionAllSalesTotalFields];
    section7 = [self removeCheckCash:section7];
    
    if (_isRcrGasActive) {
        sectionGroup5AFields = [self removeGrossFuelSales:sectionGroup5AFields];
        _fields = @[
                    reportHeaderSectionFields,
                    headerSectionFields,
                   // salesSectionFields,
                    //petroSalesSectionFields,
                   // section3Fields,
                    sectionDailySales,
                    sectionGroup5AFields,
                    //sectionGroupAllTaxesFields,
                    //sectionGroupAllTaxesDetailsFields,
                    sectionGroupOpeningAmountFields,
                    sectionGroupNoneFields,
                    sectionGroupMerchandiseFields,
                    sectionGroupLotryFields,
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
                    //sectionCustomer,
                    sectionTaxes,
                    sectionPaymentMode,
                    sectionTenderTips,
//                    giftCardSectionfields,
                    cardTypeSectionFields,
                    cardTypeOutSideSectionFields,
                    discountSectionFields,
                    sectionDepartment,
                    sectionNonMerchandiseDepartment,
                    payoutSectionFields,
                    sectionHourlySales,
//                    sectionGroup20AFields,
//                    sectionGroup20Fields,
//                    sectionGroup21Fields,
//                    sectionGroup22Fields,
//                    sectionGroup23AFields,
//                    sectionGroup23BFields,
                   // sectionGroup24Fields,
                    fuelSummerySectionFields,
                    pumpSummerySectionFields,
                    footerSectionFields,
                    ];
  
         [self removeBlankMerchandiseFields:_fields withobject:@[sectionGroupMerchandiseFields,sectionGroupLotryFields,sectionGroupGasFields,sectionGroupMoneyOrderFields,sectionGroupGiftCardFields,sectionGroupCheckCashFields,sectionGroupPayoutFields,sectionGroupHouseChargeFields,sectionOtherSalesFields]];
        
    }
    else
    {
        _fields = @[
                    reportHeaderSectionFields,
                    headerSectionFields,
                   // salesSectionFields,
                   // section3Fields,
                    sectionDailySales,
                    //sectionGroupAllTaxesFields,
                    //sectionGroupAllTaxesDetailsFields,
                    sectionGroupOpeningAmountFields,
                    sectionGroupNoneFields,
                    sectionGroupMerchandiseFields,
                    sectionGroupLotryFields,
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
                    //sectionCustomer,
                    sectionTaxes,
                    sectionPaymentMode,
                    sectionTenderTips,
//                    giftCardSectionfields,
                    cardTypeSectionFields,
                    discountSectionFields,
                    sectionDepartment,
                    sectionNonMerchandiseDepartment,
                    payoutSectionFields,
                    sectionHourlySales,
                    footerSectionFields,
                    ];
        
         [self removeBlankMerchandiseFields:_fields withobject:@[sectionGroupMerchandiseFields,sectionGroupLotryFields,sectionGroupGasFields,sectionGroupMoneyOrderFields,sectionGroupGiftCardFields,sectionGroupCheckCashFields,sectionGroupPayoutFields,sectionGroupHouseChargeFields,sectionOtherSalesFields]];
    
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



- (instancetype)initWithDictionary:(NSDictionary *)xReportData reportName:(NSString *)reportName {
    self = [super init];
    if (self) {
        _reportData = xReportData;
        _reportName = reportName;
        [self configureXReportSections];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)xReportData reportName:(NSString *)reportName isTips:(BOOL)isTips {
    _rmsDbController = [RmsDbController sharedRmsDbController];

    self = [self initWithDictionary:xReportData reportName:reportName];
    currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatter.maximumFractionDigits = 2;
    _isTipSetting = isTips;
    return self;
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

#pragma mark - Print Methods
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

-(NSMutableArray *)getTipTender{
    
    NSMutableArray *tenderArray = _reportData[@"RptTender"];
    if(tenderArray.count > 0){
        return tenderArray;
    }
    return nil;
}
- (NSArray*)fuelTypeDetail {
    return _reportData[@"RptFuel"];
}
- (NSArray*)pumpDetail {
    return _reportData[@"RptPump"];
}
//#pragma mark HTML Report
//
//- (NSString *)htmlForCommonHeader
//{
//    NSString *htmlForCommonHeader = [[NSString alloc] initWithFormat:@"<html>$$STYLE$$<body>"];
//    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<div \" style=\"font-family:Helvetica Neue; $$WIDTH$$ ; margin:auto; font-size:14px;\">"];
//    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<table  style=\"font-family:Helvetica Neue; $$WIDTHCOMMONHEADER$$; font-size:14px; background-color:#f7f7f7; margin-left:-8px; margin-top:-8px;padding-top:8px;padding-bottom:8px; padding-right:8px;border-bottom:1px solid #a5a6a6; \">"];
//    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">%@</td></tr>",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]];
//    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">%@  , %@</td></tr>",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]];
//    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">%@ , %@ - %@</td></tr>",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]];
//    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\">Phone No : %@</td></tr>",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"PhoneNo1"]];
//    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"</table>"];
//    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<table cellpadding=\"0\" cellspacing=\"0\" width:100%@; font-size: 13px;\" border=\"0\" width=100%@>",@"%",@"%"];
//    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td align=\"center\" style=\"font-family:Helvetica Neue; font-size:14px; padding-top:10px;padding-bottom:10px;\"><strong>%@</strong></td></tr>",_reportName];
//    htmlForCommonHeader = [htmlForCommonHeader stringByAppendingFormat:@"<tr><td><table cellpadding=\"0\" cellspacing=\"0\"  style=\" width:100%@; font-size: 13px;\" border=\"0\" width=100%@>",@"%",@"%"];
//    return htmlForCommonHeader;
//}
//
//- (NSString *)htmlForDay
//{
//    NSString *htmlForDay = @"";
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
//    NSInteger weekday = [comps weekday];
//    htmlForDay = [htmlForDay stringByAppendingFormat:@"<tr><td><strong>Day</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[self dayFromWeekDay:weekday]];
//    htmlForDay = [htmlForDay stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    return htmlForDay;
//}
//
//- (NSString *)htmlForkey:(NSString *)key value:(NSString *)value
//{
//   NSString *htmlForName = [NSString stringWithFormat:@"<tr><td>%@</td><td><div align=\"right\">%@ </div></td></tr>",key,value];
//    return htmlForName;
//}
//
//- (NSString *)htmlForName
//{
//    return [self htmlForkey:REPORT_USER_NAME value:[self reportSummary] [@"CurrentUser"]];
//}
//
//- (NSString *)htmlForRegister {
//    return [self htmlForkey:REPORT_REGISTER_NAME value:[self reportSummary] [@"RegisterName"]];
//}
//
//
//- (NSString *)htmlForDateTime {
//    return [self htmlForkey:REPORT_DATE_AND_TIME value:[self getCurrentDateAndTime]];
//}
//
//- (NSString *)htmlForStartDateTime {
//    NSString *dateAndTime = [self dateFromDictionary:[self reportSummary] timeKey:@"StartTime" dateKey:@"Startdate"];
//    return [self htmlForkey:REPORT_DATE_AND_TIME value:dateAndTime];
//}
//
//- (NSString *)htmlForEndDateTime {
//    NSString *endDate = [self dateFromDictionary:[self reportSummary] timeKey:@"ReportTime" dateKey:@"ReportDate"];
//    return [self htmlForkey:REPORT_END_DATE_AND_END_TIME value:endDate];
//}
//
//- (NSString *)htmlForBatchNo {
//    return [self htmlForkey:REPORT_BATCH value:[self reportSummary][@"BatchNo"]];
//}
//
//- (NSString *)htmlForGrossSales {
//    NSString *htmlForGrossSales = [NSString stringWithFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    htmlForGrossSales = [htmlForGrossSales stringByAppendingFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#0073aa;\">%@</td><td style=\"font-family:Helvetica Neue;color:#0073aa;\"><div align=\"right\">%@ </div></td></tr>",REPORT_GROSS_SALES,[currencyFormatter stringFromNumber:[self reportSummary][@"TotalSales"]]];
//    return htmlForGrossSales;
//}
//
//- (NSString *)htmlForTaxes {
//  return  [NSString stringWithFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#0073aa;\">%@</td><td><div style=\"font-family:Helvetica Neue;color:#0073aa;\" align=\"right\">%@ </div></td></tr>",REPORT_TAXES,[currencyFormatter stringFromNumber:[self reportSummary][@"CollectTax"]]];
//     ;
//}
//
//- (NSString *)htmlForNetSales {
//    float netSales = [[self reportSummary][@"TotalSales"] doubleValue] - [[self reportSummary][@"CollectTax"]doubleValue];
//    NSNumber *netSale = [NSNumber numberWithFloat:netSales];
//    NSString *htmlForNetSales = [NSString stringWithFormat:@"<tr><td style=\"font-family:Helvetica Neue;color:#0073aa;\">%@</td><td style=\"font-family:Helvetica Neue;color:#0073aa;\"><div align=\"right\">%@ </div></td></tr>",REPORT_NET_SALES,[currencyFormatter stringFromNumber:netSale]];
//    htmlForNetSales = [htmlForNetSales stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    return htmlForNetSales;
//}
//
//- (NSString *)htmlForOpeningAmount {
//    NSString *htmlForOpeningAmount = [NSString stringWithFormat:@"<tr><td style=\"padding-bottom:5px;\">%@</style></td><td style=\"padding-bottom:5px;\"><div align=\"right\">%@ </div></style></td></tr>",REPORT_OPENING_AMOUNT,[currencyFormatter stringFromNumber:[self reportSummary][@"OpeningAmount"]]];
//    return htmlForOpeningAmount;
//}
//
//- (NSString *)htmlForSales {
//    
//    return [self htmlForkey:REPORT_SALES value:[currencyFormatter stringFromNumber:[self reportSummary][@"Sales"]]];
//}
//
//- (NSString *)htmlForReturn {
//    double returnAmount = [[self reportSummary][@"Return"] doubleValue];
//    NSNumber *returnAmountNumber = [NSNumber numberWithDouble:fabs(returnAmount)];
//    return [self htmlForkey:REPORT_RETURN value:[currencyFormatter stringFromNumber: returnAmountNumber]];
//}
//
//- (NSString *)htmlForSection3Total {
//    NSString *htmlForSection3Total = @"";
//    double sum1 = [[self reportSummary] [@"Sales"] doubleValue] + [[self reportSummary] [@"Return"] doubleValue];
//    NSNumber *sum1number = [NSNumber numberWithDouble:sum1];
//    htmlForSection3Total = [htmlForSection3Total stringByAppendingFormat:@"<tr><td style=\"padding-bottom:5px;\"><strong>Total </strong></td></style><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sum1number]];
//    return htmlForSection3Total;
//}
//
//- (NSString *)htmlForSection3Taxes {
//    return [self htmlForkey:REPORT_TAXES value:[currencyFormatter stringFromNumber:[self reportSummary] [@"CollectTax"]]];
//}
//
//- (NSString *)htmlForSurCharge {
//    return [self htmlForkey:REPORT_SURCHARGE value:[currencyFormatter stringFromNumber:[self reportSummary] [@"Surcharge"]]];
//}
//
//- (NSString *)htmlForTips
//{
//    NSString *htmlForTips = @"";
//    if (_isTipSetting)
//    {
//        htmlForTips = [htmlForTips stringByAppendingFormat:@"<tr><td>%@ </td><td><div align=\"right\">%@ </div></td></tr>",REPORT_TIPS,[currencyFormatter stringFromNumber:[self reportSummary] [@"TotalTips"]]];
//    }
//   return  htmlForTips;
//}
//
//- (NSString *)htmlForGiftCard {
//    return [self htmlForkey:REPORT_GIFTCARD value:[currencyFormatter stringFromNumber:[self reportSummary] [@"LoadAmount"]]];
//}
//
//- (NSString *)htmlForMoneyOrder {
//    return [self htmlForkey:REPORT_MONEY_ORDER value:[currencyFormatter stringFromNumber:[self reportSummary] [@"MoneyOrder"]]];
//}
//
//- (NSString *)htmlForDropAmount {
//    NSString *htmlForDropAmount = @"";
//    htmlForDropAmount = [htmlForDropAmount stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    htmlForDropAmount = [htmlForDropAmount stringByAppendingFormat:@"<tr><td>%@ </td><td><div align=\"right\">%@</div></td></tr>",REPORT_DROP_AMOUNT,[currencyFormatter stringFromNumber: [self reportSummary] [@"DropAmount"]]];
//    return htmlForDropAmount;
//}
//
//- (NSString *)htmlForPaidOut {
//    double paidOutAmount = [[self reportSummary][@"PayOut"] doubleValue];
//    NSNumber *paidOutAmountNumber = [NSNumber numberWithDouble:fabs(paidOutAmount)];
//    return [self htmlForkey:REPORT_PAYOUT value:[currencyFormatter stringFromNumber: paidOutAmountNumber]];
//}
//
//- (NSString *)htmlForClosingAmount {
//    
//    return [self htmlForkey:REPORT_CLOSING_AMOUNT value:[currencyFormatter stringFromNumber:[self reportSummary] [@"ClosingAmount"]]];
//}
//
//- (NSString *)htmlForTenderCardData {
//    NSString *htmlForTenderCardData = @"";
//    NSArray *tenderCardData= [self tenderTypeDetail];
//    if([tenderCardData  isKindOfClass:[NSArray class]])
//    {
//        for (int i=0; i<[tenderCardData  count]; i++) {
//            NSMutableDictionary *tenderRptCard=[tenderCardData objectAtIndex:i];
//            NSString *strCashType=[NSString stringWithFormat:@"%@",[tenderRptCard valueForKey:@"CashInType"]];
//            
//            if(![strCashType isEqualToString:@"Cash"])
//            {
//                    htmlForTenderCardData = [htmlForTenderCardData stringByAppendingFormat:@"<tr><td>%@</td><td><div align=\"right\">%@ </div></td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[currencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"Amount"]]];
//            }
//        }
//    }
//    return htmlForTenderCardData;
//}
//
//- (NSString *)htmlForOverShort {
//    NSString *htmlForOverShort = @"";
//    htmlForOverShort = [htmlForOverShort stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    double doubleOverShort = [self calculateSum3WithTenderArray:[self tenderTypeDetail]withRptMain:[self reportSummary]] - [self calculateSum2withRptMain:[self reportSummary]];
//    NSNumber *doubleOverShortnumber = [NSNumber numberWithDouble:doubleOverShort];
//    htmlForOverShort = [htmlForOverShort stringByAppendingFormat:@"<tr><td colspan=\"2\"><div align=\"right\"></div></td></tr><tr><td style=\"font-family:Helvetica Neue;color:#0073aa;\">%@</td><td style=\"font-family:Helvetica Neue;color:#0073aa;\" ><div align=\"right\">%@</div></td></tr>", REPORT_OVER_SHORT,[currencyFormatter stringFromNumber:doubleOverShortnumber]];
//    htmlForOverShort = [htmlForOverShort stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    return htmlForOverShort;
//}
//
//- (NSString *)htmlForGCLiabiality {
//    return [self htmlForkey:REPORT_GC_LIABIALITY value:[currencyFormatter stringFromNumber:[self reportSummary] [@"GCLiablity"]]];
//}
//
//- (NSString *)htmlForCheckCash {
//    return [self htmlForkey:REPORT_CHECK_CASH value:[currencyFormatter stringFromNumber:[self reportSummary] [@"CheckCash"]]];
//}
//
//- (NSString *)htmlForDiscount{
//    return [self htmlForkey:REPORT_DISCOUNT value:[currencyFormatter stringFromNumber:[self reportSummary] [@"Discount"]]];
//}
//- (NSString *)htmlForNonTaxSales {
//    return [self htmlForkey:REPORT_NON_TAX_SALES value:[currencyFormatter stringFromNumber:[self reportSummary] [@"NonTaxSales"]]];
//}
//
//- (NSString *)htmlForCostofGoods {
//    return [self htmlForkey:REPORT_COSTOFGOODS value:[currencyFormatter stringFromNumber:[self reportSummary] [@"CostofGoods"]]];
//}
//
//- (NSString *)htmlForMargin {
//    return [self htmlForkey:REPORT_MARGIN value:[currencyFormatter stringFromNumber:[self reportSummary] [@"Margin"]]];
//}
//
//- (NSString *)htmlForNoSales {
//    return [self htmlForkey:REPORT_NO_SALES value:[self reportSummary] [@"NoSales"]];
//}
//
//- (NSString *)htmlForVoidTrans {
//    return [self htmlForkey:REPORT_VOID value:[self reportSummary] [@"AbortedTrans"]];
//}
//
//- (NSString *)htmlForLineItemVoid {
//    return [self htmlForkey:REPORT_LINE_ITEM_VOID value:[self reportSummary] [@"LineItemVoid"]];
//}
//
//- (NSString *)htmlForCustomer {
//    return [self htmlForkey:REPORT_CUSTOMER value:[self reportSummary] [@"CustomerCount"]];
//}
//
//- (NSString *)htmlForAvgTicket {
//    return [self htmlForkey:REPORT_AVG_TICKET value:[self reportSummary] [@"AvgTicket"]];
//}
//
//- (NSString *)htmlForDiscountSection{
//    NSString *htmlForDiscountSection = @"";
//    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
//    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><strong><FONT SIZE = 2>Discount Type</FONT></strong></td><td class = \"TaxSales\" align=\"right\"><strong><FONT SIZE = 2>Sales</FONT></strong></td><td class = \"TaxTax\" align=\"right\"><strong><FONT SIZE = 2>Discount</FONT> </strong></td><td class = \"TaxCustCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
//    
//    NSDictionary *customizedDiscountDict = [self customizedDiscount];
//    NSDictionary *manualDiscountDict = [self manualDiscount];
//    NSDictionary *preDefinedDiscountDict = [self preDefinedDiscount];
//
//    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxSales\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxTax\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxCustCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Customized",[currencyFormatter stringFromNumber:[customizedDiscountDict valueForKey:@"Sales"]],[currencyFormatter stringFromNumber:[customizedDiscountDict valueForKey:@"Amount"]],[customizedDiscountDict valueForKey:@"Count"]];
//    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxSales\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxTax\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxCustCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"Manual",[currencyFormatter stringFromNumber:[manualDiscountDict valueForKey:@"Sales"]],[currencyFormatter stringFromNumber:[manualDiscountDict valueForKey:@"Amount"]],[manualDiscountDict valueForKey:@"Count"]];
//    htmlForDiscountSection = [htmlForDiscountSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxSales\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxTax\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxCustCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"PreDefined",[currencyFormatter stringFromNumber:[preDefinedDiscountDict valueForKey:@"Sales"]],[currencyFormatter stringFromNumber:[preDefinedDiscountDict valueForKey:@"Amount"]],[preDefinedDiscountDict valueForKey:@"Count"]];
//
//    return htmlForDiscountSection;
//}
//
//- (NSString *)htmlForTaxesSection{
//    NSString *htmlForTaxesSection = @"";
//    htmlForTaxesSection = [htmlForTaxesSection stringByAppendingFormat:@"</table><tr><td>&nbsp;</td><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    
//    htmlForTaxesSection = [htmlForTaxesSection stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
//    
//    htmlForTaxesSection = [htmlForTaxesSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><strong><FONT SIZE = 2>Type </FONT></strong></td><td class = \"TaxSales\" align=\"right\"><strong><FONT SIZE = 2>Sales</FONT></strong></td><td class = \"TaxTax\" align=\"right\"><strong><FONT SIZE = 2>Tax</FONT> </strong></td><td class = \"TaxCustCount\" align=\"right\"><p><strong><FONT SIZE = 2>Cust. Count</FONT> </strong></p></td></tr>"];
//    
//    NSArray *taxReport= _reportData [@"RptTax"];
//    if([taxReport  isKindOfClass:[NSArray class]])
//    {
//        for (int itx=0; itx<[taxReport  count]; itx++) {
//            NSDictionary *taxRptDisc = [taxReport objectAtIndex:itx];
//            htmlForTaxesSection = [htmlForTaxesSection stringByAppendingFormat:@"<tr><td class = \"TaxType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxSales\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxTax\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TaxCustCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[taxRptDisc valueForKey:@"Descriptions"],[currencyFormatter stringFromNumber:[taxRptDisc valueForKey:@"Sales"]],[currencyFormatter stringFromNumber:[taxRptDisc valueForKey:@"Amount"]],[taxRptDisc valueForKey:@"Count"]];
//        }
//    }
//    return htmlForTaxesSection;
//}
//
//- (NSString *)htmlForTenderType {
//    NSString *htmlForTenderType = @"";
//    htmlForTenderType = [htmlForTenderType stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
//    
//    htmlForTenderType = [htmlForTenderType stringByAppendingFormat:@"<tr><td  class = \"TederType\"><strong><FONT SIZE = 2>Tender Type</FONT></strong></td><td class = \"TederTypeAmount\" align=\"right\"><strong><FONT SIZE = 2>Amount</FONT></strong></td><td class = \"TederTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2>Avg Ticket</FONT> </strong></td><td class = \"TederTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"TederTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
//    
//    NSArray *tenderReport= [self tenderTypeDetail];
//    if([tenderReport  isKindOfClass:[NSArray class]])
//    {
//        for (int itx=0; itx<[tenderReport  count]; itx++) {
//            NSDictionary *tenderRptDisc = [tenderReport objectAtIndex:itx];
//            
//            double tenderAmount = [[tenderRptDisc valueForKey:@"Amount"] doubleValue];
//            if (_isTipSetting)
//            {
//                tenderAmount = tenderAmount + [[tenderRptDisc valueForKey:@"TipsAmount"] doubleValue];
//            }
//            NSNumber *numTenderAmount = [NSNumber numberWithDouble:tenderAmount];
//
//            htmlForTenderType = [htmlForTenderType stringByAppendingFormat:@"<tr><td class = \"TederType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TederTypeAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TederTypeAvgTicket\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TederTypePer\" align=\"right\"><FONT SIZE = 2>%.2f</FONT></td><td class = \"TederTypeCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[tenderRptDisc valueForKey:@"Descriptions"],[currencyFormatter stringFromNumber:numTenderAmount],[currencyFormatter stringFromNumber:[tenderRptDisc valueForKey:@"AvgTicket"]],[[tenderRptDisc valueForKey:@"Percentage"] floatValue],[tenderRptDisc valueForKey:@"Count"]];
//        }
//    }
//    return htmlForTenderType;
//}
//
//
//- (NSString *)htmlForGiftCardPreviousBalance {
//    NSString *htmlForGiftCardPreviousBalance = @"";
//    htmlForGiftCardPreviousBalance = [htmlForGiftCardPreviousBalance stringByAppendingFormat:@"<tr><td><FONT SIZE = 2>GC ADY</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"",[currencyFormatter stringFromNumber:[self reportSummary] [@"TotalGCADY"]],@""];
//    return htmlForGiftCardPreviousBalance;
//}
//
//- (NSString *)htmlForLoadGiftCard {
//    NSString *htmlForLoadGiftCard = @"";
//    htmlForLoadGiftCard = [htmlForLoadGiftCard stringByAppendingFormat:@"<tr><td><FONT SIZE = 2>Load</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[currencyFormatter stringFromNumber:[self reportSummary] [@"LoadAmount"]],[currencyFormatter stringFromNumber:[self reportSummary] [@"TotalLoadAmount"]],[self reportSummary] [@"LoadCount"]];
//    return htmlForLoadGiftCard;
//}
//
//- (NSString *)htmlForRedeemGiftCard {
//    NSString *htmlForRedeemGiftCard = @"";
//    htmlForRedeemGiftCard = [htmlForRedeemGiftCard stringByAppendingFormat:@"<tr><td><FONT SIZE = 2>Redeem</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td><td align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[currencyFormatter stringFromNumber:[self reportSummary] [@"RedeemAmount"]],[currencyFormatter stringFromNumber:[self reportSummary] [@"TotalRedeemAmount"]],[self reportSummary] [@"RedeemCount"]];
//
//    return htmlForRedeemGiftCard;
//}
//
//- (NSString *)htmlForTenderTips {
//    NSString *htmlForTenderTips = @"";
//    if (_isTipSetting) {
//        htmlForTenderTips = [htmlForTenderTips stringByAppendingFormat:@"</td><tr><td><table style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
//        
//        htmlForTenderTips = [htmlForTenderTips stringByAppendingFormat:@"<tr><td class = \"TipsTederType\"><strong><FONT SIZE = 2>Type</FONT></strong></td><td class = \"TipsTederAmount\" align=\"right\" ><strong><FONT SIZE = 2>Amount</FONT></strong></td><td class = \"TipsTeder\" align=\"right\"><strong><FONT SIZE = 2>Tips</FONT> </strong></td><td class = \"TipsTederTotal\" align=\"right\"><strong><FONT SIZE = 2>Total</FONT></strong></td></tr>"];
//
//        NSArray *tenderReport= [self tenderTypeDetail];
//        if([tenderReport  isKindOfClass:[NSArray class]])
//        {
//            for (int itx=0; itx<[tenderReport  count]; itx++) {
//                NSDictionary *tenderRptDisc = [tenderReport objectAtIndex:itx];
//                
//                double tenderAmount = [[tenderRptDisc valueForKey:@"Amount"] doubleValue] + [[tenderRptDisc valueForKey:@"TipsAmount"] doubleValue];
//                NSNumber *numTenderAmount = [NSNumber numberWithDouble:tenderAmount];
//                
//                htmlForTenderTips = [htmlForTenderTips stringByAppendingFormat:@"<tr><td class = \"TipsTederType\"><FONT SIZE = 2>%@</FONT></td><td class = \"TipsTederAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TipsTeder\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"TipsTederTotal\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[tenderRptDisc valueForKey:@"Descriptions"],[currencyFormatter stringFromNumber:[tenderRptDisc valueForKey:@"Amount"]],[currencyFormatter stringFromNumber:[tenderRptDisc valueForKey:@"TipsAmount"]],[currencyFormatter stringFromNumber:numTenderAmount]];
//            }
//        }
//    }
//    return htmlForTenderTips;
//}
//
//- (NSString *)htmlForCardType
//{
//    NSString *htmlForCardType = @"";
//    htmlForCardType = [htmlForCardType stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
//    
//    htmlForCardType = [htmlForCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><strong><FONT SIZE = 2>Card Type</FONT></strong></td><td class = \"CardTypeAmount\" align=\"right\" ><strong><FONT SIZE = 2>Amount</FONT></strong></td><td class = \"CardTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2>Avg Ticket</FONT> </strong></td><td class = \"CardTypeTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"CardTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
//    
//    NSMutableArray *cardTypeReport= _reportData[@"RptCardType"];
//    if([cardTypeReport isKindOfClass:[NSArray class]])
//    {
//        for (int itx=0; itx<[cardTypeReport count]; itx++) {
//            NSMutableDictionary *cardTypeRptDisc = [cardTypeReport objectAtIndex:itx];
//            htmlForCardType = [htmlForCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><FONT SIZE = 2>%@</FONT></td><td class = \"CardTypeAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"CardTypeAvgTicket\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"CardTypeTypePer\" align=\"right\"><FONT SIZE = 2>%.2f</FONT></td><td class = \"CardTypeCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",[cardTypeRptDisc valueForKey:@"CardType"],[currencyFormatter stringFromNumber:[cardTypeRptDisc valueForKey:@"Amount"]],[currencyFormatter stringFromNumber:[cardTypeRptDisc valueForKey:@"AvgTicket"]],[[cardTypeRptDisc valueForKey:@"Percentage"] floatValue],[cardTypeRptDisc valueForKey:@"Count"]];
//        }
//    }
//    return htmlForCardType;
//}
//
//
//
//
//- (NSString *)htmlForDepartment {
//    NSString *htmlForDepartment = @"";
//    htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    
//    htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
//    
//    htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><strong><FONT SIZE = 2>Department</FONT></strong></td><td class = \"DepartmentCost\" align=\"right\"><strong><FONT SIZE = 2>Cost</FONT></strong></td><td class = \"DepartmentAmount\" align=\"right\"><strong><FONT SIZE = 2>Price</FONT> </strong></td><td class = \"DepartmentMargin\" align=\"right\"><p><strong><FONT SIZE = 2>Margin (%%)</FONT> </strong></p></td><td class = \"DepartmentPer\" align=\"right\"><p><strong><FONT SIZE = 2>%%</FONT> </strong></p></td><td class = \"DepartmentCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
//
//    NSMutableArray *departmentReport = _reportData [@"RptDepartment"];
//    
//    NSPredicate *departmentPredicate = [NSPredicate predicateWithFormat:@"IsPayout = %@",@(0)];
//    NSArray *department = [departmentReport filteredArrayUsingPredicate:departmentPredicate];
//
//    htmlForDepartment = [self generateHtmlFromArray:department withString:htmlForDepartment];
//    return htmlForDepartment;
//}
//
//- (NSString *)generateHtmlFromArray:(NSArray *)array withString:(NSString *)htmlForDepartment
//{
//    for (int idpt=0; idpt<[array count]; idpt++) {
//        NSMutableDictionary *departRptDisc=[array objectAtIndex:idpt];
//        NSString *departmentName = @"";
//        if ([[departRptDisc valueForKey:@"Descriptions"] length] > 18) {
//            departmentName = [[departRptDisc valueForKey:@"Descriptions"] substringToIndex:18];
//            departmentName = [departmentName stringByAppendingString:@"..."];
//        }
//        else
//        {
//            departmentName = [departRptDisc valueForKey:@"Descriptions"];
//        }
//        
//        htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\" colspan= \"5\" ><FONT SIZE = 2>%@</FONT></td></tr>",departmentName];
//
//        htmlForDepartment = [htmlForDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><FONT SIZE = 2>%@</FONT></td><td class = \"DepartmentCost\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"DepartmentAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"DepartmentMargin\" align=\"right\" style=\"padding-right:24px\"><FONT SIZE = 2>%.2f</FONT></td><td class = \"DepartmentPer\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"DepartmentCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",@"",[currencyFormatter stringFromNumber:[departRptDisc valueForKey:@"Cost"]],[currencyFormatter stringFromNumber:[departRptDisc valueForKey:@"Amount"]],[[departRptDisc valueForKey:@"Margin"] floatValue],[NSString stringWithFormat:@"%.2f",[[departRptDisc valueForKey:@"Per"] floatValue]],[departRptDisc valueForKey:@"Count"]];
//    }
//    return htmlForDepartment;
//}
//
//- (NSString *)htmlForPayOutDepartment {
//    NSString *htmlForPayOutDepartment = @"";
//    htmlForPayOutDepartment = [htmlForPayOutDepartment stringByAppendingFormat:@"<tr><td width=400px><strong><FONT SIZE = 2>P/O</FONT></strong></td>"];
//    NSMutableArray *departmentReport = _reportData [@"RptDepartment"];
//    NSPredicate *payOutPredicate = [NSPredicate predicateWithFormat:@"IsPayout = %@",@(1)];
//    NSArray *payOut = [departmentReport  filteredArrayUsingPredicate:payOutPredicate];
//    htmlForPayOutDepartment = [self generateHtmlFromArray:payOut withString:htmlForPayOutDepartment];
//    return htmlForPayOutDepartment;
//}
//
//- (NSString *)htmlForHourlySales {
//    NSString *htmlForHourlySales = @"";
//    htmlForHourlySales = [htmlForHourlySales stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    htmlForHourlySales = [htmlForHourlySales stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
//    htmlForHourlySales = [htmlForHourlySales stringByAppendingFormat:@"<tr><td class = \"HourlySales\"><strong><FONT SIZE = 2>HourlySales</FONT></strong></td><td class = \"HourlySalesCost\" align=\"right\"><strong><FONT SIZE = 2>Cost</FONT></strong></td><td class = \"HourlySalesAmount\" align=\"right\"><strong><FONT SIZE = 2>Price</FONT> </strong></td><td class = \"HourlySalesMargin\" align=\"right\"><p><strong><FONT SIZE = 2>Margin (%%)</FONT> </strong></p></td><td class = \"HourlySalesCount\" align=\"right\"><p><strong><FONT SIZE = 2>Count</FONT> </strong></p></td></tr>"];
//    
//    NSMutableArray *hoursReport = _reportData [@"RptHours"];
//    if([hoursReport isKindOfClass:[NSArray class]])
//    {
//        for (int idpt=0; idpt<[hoursReport  count]; idpt++) {
//            NSMutableDictionary *hoursRptDisc=[hoursReport objectAtIndex:idpt];
//            NSString *dateReturn= [NSString stringWithFormat:@"%@",[hoursRptDisc valueForKey:@"Hours"]];
//            NSDate *date=[self jsonStringToNSDate:dateReturn];
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//            [formatter setDateFormat:@"hh:mm a"];
//            NSString *stringFromDate = [formatter stringFromDate:date];
//            
//            htmlForHourlySales = [htmlForHourlySales stringByAppendingFormat:@"<tr><td class = \"HourlySales\"><FONT SIZE = 2>%@</FONT></td><td class = \"HourlySalesCost\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"HourlySalesAmount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td><td class = \"HourlySalesMargin\" align=\"right\"><FONT SIZE = 2>%.2f</FONT></td><td class = \"HourlySalesCount\" align=\"right\"><FONT SIZE = 2>%@</FONT></td></tr>",stringFromDate,[currencyFormatter stringFromNumber:[hoursRptDisc valueForKey:@"Cost"]],[currencyFormatter stringFromNumber:[hoursRptDisc valueForKey:@"Amount"]],[[hoursRptDisc valueForKey:@"Margin"] floatValue],[hoursRptDisc valueForKey:@"Count"]];
//        }
//    }
//    return htmlForHourlySales;
//}
//
//
//#pragma mark - Html Section Header Report
//
//- (NSString *)htmlHeaderForSectionHeader {
//    NSString *htmlHeaderForSectionHeader = @"";
//    return htmlHeaderForSectionHeader;
//}
//
//- (NSString *)htmlHeaderForSectionSales {
//    NSString *htmlHeaderForSectionSales = @"";
//    return htmlHeaderForSectionSales;
//}
//
//- (NSString *)htmlHeaderForSection3 {
//    NSString *htmlHeaderForSectionHeader = @"";
//    return htmlHeaderForSectionHeader;
//}
//
//- (NSString *)htmlHeaderForSection4 {
//    NSString *htmlHeaderForSection4 = @"";
//    return htmlHeaderForSection4;
//}
//
//- (NSString *)htmlHeaderForSectionOverShort {
//    NSString *htmlHeaderForSectionOverShort = @"";
//    return htmlHeaderForSectionOverShort;
//}
//
//- (NSString *)htmlHeaderForSection6 {
//    NSString *htmlHeaderForSection6 = @"";
//    return htmlHeaderForSection6;
//}
//
//- (NSString *)htmlHeaderForSectionCustomer {
//    NSString *htmlHeaderForSectionCustomer = @"";
//    return htmlHeaderForSectionCustomer;
//}
//
//- (NSString *)htmlHeaderForSectionDiscount {
//    NSString *htmlHeaderForSectionDiscount = @"";
//    return htmlHeaderForSectionDiscount;
//}
//
//- (NSString *)htmlHeaderForSectionTaxes {
//    NSString *htmlHeaderForSectionTaxes = @"";
//    return htmlHeaderForSectionTaxes;
//}
//
//- (NSString *)htmlHeaderForSectionPaymentMode {
//    NSString *htmlHeaderForSectionPaymentMode = @"";
//    return htmlHeaderForSectionPaymentMode;
//}
//
//- (NSString *)htmlHeaderForSectionTenderTips
//{
//    NSString *htmlHeaderForSectionTenderTips = @"";
//    return htmlHeaderForSectionTenderTips;
//}
//
//- (NSString *)htmlHeaderForSectionGiftCard {
//    NSString *htmlHeaderForSectionGiftCard = @"";
//    htmlHeaderForSectionGiftCard = [htmlHeaderForSectionGiftCard stringByAppendingFormat:@"</td><tr><td><table  style=\"$$WIDTH$$; margin:Auto\" cellpadding=\"0\" cellspacing=\"0\"  border=\"0\">"];
//    
//    htmlHeaderForSectionGiftCard = [htmlHeaderForSectionGiftCard stringByAppendingFormat:@"<tr><td><strong><FONT SIZE = 2>Gift Card</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>Register</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>Total</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>Count</FONT> </strong></td></tr>"];
//
//    return htmlHeaderForSectionGiftCard;
//}
//
//- (NSString *)htmlHeaderForSectionCardType {
//    NSString *htmlHeaderForSectionCardType = @"";
//    return htmlHeaderForSectionCardType;
//}
//
//- (NSString *)htmlHeaderForSectionDepartment {
//    NSString *htmlHeaderForSectionDepartment = @"";
//    return htmlHeaderForSectionDepartment;
//}
//
//- (NSString *)htmlHeaderForSectionPayout {
//    NSString *htmlHeaderForSectionPayout = @"";
//    return htmlHeaderForSectionPayout;
//}
//
//- (NSString *)htmlHeaderForHourlySales {
//    NSString *htmlHeaderForHourlySales = @"";
//    return htmlHeaderForHourlySales;
//}
//
//
//#pragma mark - Html Section Footer Report
//
//- (NSString *)htmlFooterForSectionHeader {
//    NSString *htmlFooterForSectionHeader = @"";
//    return htmlFooterForSectionHeader;
//}
//
//- (NSString *)htmlFooterForSectionSales {
//    NSString *htmlFooterForSectionSales = @"";
//    return htmlFooterForSectionSales;
//}
//
//- (NSString *)htmlFooterForSection3 {
//    NSString *htmlFooterForSection3 = @"";
//    double sum2 = [self calculateSum2withRptMain:[self reportSummary]];
//    NSNumber *sum2number = [NSNumber numberWithDouble:sum2];
//    htmlFooterForSection3 = [htmlFooterForSection3 stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div></strong></td></tr>",[currencyFormatter stringFromNumber:sum2number]];
//    return htmlFooterForSection3;
//}
//
////- (double)calculateSum2withRptMain:(NSDictionary *)reportData
////{
////    double sum1 = [reportData [@"Sales"] doubleValue] + [reportData [@"Return"] doubleValue];
////    double sum2 = sum1 + [reportData [@"CollectTax"] doubleValue] + [reportData [@"Surcharge"] doubleValue] + [reportData [@"OpeningAmount"] doubleValue];
////    if (_isTipSetting)
////    {
////        sum2 = sum2 + [reportData [@"TotalTips"] doubleValue];
////    }
////    return sum2;
////}
//
////- (double)calculateSum3WithTenderArray:(NSArray *)tenderCardData withRptMain:(NSDictionary *)reportData
////{
////    double paidOutAmount;
////
////    if (reportData[@"PayOut"]) {
////        paidOutAmount = fabs ([reportData[@"PayOut"] doubleValue]);
////    } else {
////        paidOutAmount = fabs ([reportData[@"RptMain"][0][@"PayOut"] doubleValue]);
////    }
////
////    double sum = [reportData [@"DropAmount"] doubleValue] + paidOutAmount + [reportData [@"ClosingAmount"] doubleValue];
////    double  rptCardAmount = 0;
////    if([tenderCardData isKindOfClass:[NSArray class]])
////    {
////        for (int i=0; i<[tenderCardData  count]; i++) {
////            NSMutableDictionary *tenderRptCard=[tenderCardData objectAtIndex:i];
////            NSString *strCashType=[NSString stringWithFormat:@"%@",[tenderRptCard valueForKey:@"CashInType"]];
////            if(![strCashType isEqualToString:@"Cash"])
////            {
////                if(![strCashType isEqualToString:@"Other"])
////                {
////                    rptCardAmount += [[tenderRptCard valueForKey:@"Amount"]doubleValue];
////                }
////            }
////        }
////    }
////    double sum3 = sum + rptCardAmount;
////    return sum3;
////}
//
//- (NSString *)htmlFooterForSection4 {
//    NSString *htmlFooterForSection4 = @"";
//    double sum3 = [self calculateSum3WithTenderArray:[self tenderTypeDetail] withRptMain:[self reportSummary]];
//    NSNumber *sum3Number = [NSNumber numberWithDouble:sum3];
//    htmlFooterForSection4 = [htmlFooterForSection4 stringByAppendingFormat:@"<tr><td><strong>Total</strong></td><td><strong><div align=\"right\">%@ </div><strong></td></tr>",[currencyFormatter stringFromNumber:sum3Number]];
//    return htmlFooterForSection4;
//}
//
//- (NSString *)htmlFooterForSectionOverShort {
//    NSString *htmlFooterForSectionOverShort = @"";
//    return htmlFooterForSectionOverShort;
//}
//
//- (NSString *)htmlFooterForSection6 {
//    NSString *htmlFooterForSection6 = @"";
//    return htmlFooterForSection6;
//}
//
//- (NSString *)htmlFooterForSectionCustomer {
//    NSString *htmlFooterForSectionCustomer = @"";
//    return htmlFooterForSectionCustomer;
//}
//
//- (NSString *)htmlFooterForSectionDiscount {
//    NSString *htmlFooterForSectionDiscount = @"";
//    NSArray *arrDiscount = _reportData [@"RptDiscount"];
//    CGFloat totalSalesAmount = 0.00;
//    CGFloat totalDiscountAmount = 0.00;
//    NSInteger totalDiscountCount = 0;
//    for (NSDictionary *discountDict in arrDiscount) {
//        totalSalesAmount += [discountDict[@"Sales"] floatValue];
//        totalDiscountAmount += [discountDict[@"Amount"] floatValue];
//        totalDiscountCount += [discountDict[@"Count"] integerValue];
//    }
//    htmlFooterForSectionDiscount = [htmlFooterForSectionDiscount stringByAppendingFormat:@"<tr><td class = \"TaxType\"><strong><FONT SIZE = 2>Total </FONT></strong></td><td class = \"TaxSales\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"TaxTax\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"TaxCustCount\" align=\"right\"><p><strong><FONT SIZE = 2>%ld</FONT> </strong></p></td></tr>",[currencyFormatter stringFromNumber:[NSNumber numberWithFloat:totalSalesAmount]],[currencyFormatter stringFromNumber:[NSNumber numberWithFloat:totalDiscountAmount]],(long)totalDiscountCount];
//    htmlFooterForSectionDiscount = [htmlFooterForSectionDiscount stringByAppendingFormat:@"</table></font></td></tr>"];
//    return htmlFooterForSectionDiscount;
//}
//
//- (NSString *)htmlFooterForSectionTaxes {
//    NSString *htmlFooterForSectionTaxes = @"";
//    double  rptTaxesAmount = 0;
//    double  rptTaxesSales = 0;
//    int  rptTaxCount = 0;
//    NSMutableArray *taxReport= _reportData [@"RptTax"];
//    if([taxReport isKindOfClass:[NSArray class]])
//    {
//        for (int itx=0; itx<[taxReport count]; itx++) {
//            NSMutableDictionary *taxRptDisc = [taxReport objectAtIndex:itx];
//            rptTaxesAmount += [[taxRptDisc valueForKey:@"Amount"]doubleValue];
//            rptTaxesSales += [[taxRptDisc valueForKey:@"Sales"]doubleValue];
//            rptTaxCount += [[taxRptDisc valueForKey:@"Count"]intValue];
//        }
//    }
//    htmlFooterForSectionTaxes = [htmlFooterForSectionTaxes stringByAppendingFormat:@"<tr><td class = \"TaxType\"><strong><FONT SIZE = 2>Total </FONT></strong></td><td class = \"TaxSales\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"TaxTax\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"TaxCustCount\" align=\"right\"><p><strong><FONT SIZE = 2>%d</FONT> </strong></p></td></tr>",@"",[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:rptTaxesAmount]],rptTaxCount];
//
//    htmlFooterForSectionTaxes = [htmlFooterForSectionTaxes stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:30px;\"><div align=\"right\"></div></td></tr>"];
//    
//    htmlFooterForSectionTaxes = [htmlFooterForSectionTaxes stringByAppendingFormat:@"</table></font></td></tr>"];
//
//    return htmlFooterForSectionTaxes;
//}
//
//- (NSString *)htmlFooterForSectionPaymentMode {
//    NSString *htmlFooterForSectionPaymentMode = @"";
//    double  rptPaymentModeAmount = 0.00;
//    double  rptPaymentModeAvgTicket = 0;
//    double  rptPaymentModePercentage = 0;
//    int  rptPaymentModeCount = 0;
//
//    NSArray *tenderReport= [self tenderTypeDetail];
//    if([tenderReport  isKindOfClass:[NSArray class]])
//    {
//        for (int itx=0; itx<[tenderReport  count]; itx++) {
//            NSMutableDictionary *tenderRptDisc = [tenderReport objectAtIndex:itx];
//            rptPaymentModeAmount += [[tenderRptDisc valueForKey:@"Amount"]doubleValue];
//            rptPaymentModeAvgTicket += [[tenderRptDisc valueForKey:@"AvgTicket"]doubleValue];
//            rptPaymentModePercentage += [[tenderRptDisc valueForKey:@"Percentage"]floatValue];
//            rptPaymentModeCount += [[tenderRptDisc valueForKey:@"Count"]intValue];
//        }
//    }
//    
//    htmlFooterForSectionPaymentMode = [htmlFooterForSectionPaymentMode stringByAppendingFormat:@"<tr><td class = \"TederType\"><strong><FONT SIZE = 2>Total</FONT></strong></td><td class = \"TederTypeAmount\" align=\"right\" ><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"TederTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"TederTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%.2f</FONT> </strong></p></td><td class = \"TederTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2>%d</FONT> </strong></p></td></tr>",[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:rptPaymentModeAmount]],[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:rptPaymentModeAvgTicket]],rptPaymentModePercentage,rptPaymentModeCount];
//
//    htmlFooterForSectionPaymentMode = [htmlFooterForSectionPaymentMode stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:30px;\"><div align=\"right\"></div></td></tr>"];
//    
//    htmlFooterForSectionPaymentMode = [htmlFooterForSectionPaymentMode stringByAppendingFormat:@"</table></font></td></tr>"];
//
//    return htmlFooterForSectionPaymentMode;
//}
//
//- (NSString *)htmlFooterForSectionTenderTips
//{
//    NSString *htmlFooterForSectionTenderTips = @"";
//    if (_isTipSetting) {
//        double tenderAmount = 0.0;
//        double tenderTips = 0.0;
//        double tenderTotal = 0.0;
//        
//        NSArray *tenderReport= [self tenderTypeDetail];
//        if([tenderReport isKindOfClass:[NSArray class]])
//        {
//            for (int itx=0; itx<[tenderReport  count]; itx++) {
//                NSDictionary *tenderRptDisc = [tenderReport objectAtIndex:itx];
//                tenderAmount += [[tenderRptDisc valueForKey:@"Amount"] doubleValue];
//                tenderTips += [[tenderRptDisc valueForKey:@"TipsAmount"] doubleValue];
//                tenderTotal += [[tenderRptDisc valueForKey:@"Amount"] doubleValue] + [[tenderRptDisc valueForKey:@"TipsAmount"] doubleValue];
//            }
//        }
//        
//        NSNumber *numTenderAmount = [NSNumber numberWithDouble:tenderAmount];
//        NSNumber *numTenderTips = [NSNumber numberWithDouble:tenderTips];
//        NSNumber *numTenderTotal = [NSNumber numberWithDouble:tenderTotal];
//        
//        htmlFooterForSectionTenderTips = [htmlFooterForSectionTenderTips stringByAppendingFormat:@"<tr><td class = \"TipsTederType\"><strong><FONT SIZE = 2>Total</FONT></strong></td><td class = \"TipsTederAmount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"TipsTeder\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"TipsTederTotal\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td></tr>",[currencyFormatter stringFromNumber:numTenderAmount],[currencyFormatter stringFromNumber:numTenderTips],[currencyFormatter stringFromNumber:numTenderTotal]];
//        
//        htmlFooterForSectionTenderTips = [htmlFooterForSectionTenderTips stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:30px;\"><div align=\"right\"></div></td></tr>"];
//        
//        htmlFooterForSectionTenderTips = [htmlFooterForSectionTenderTips stringByAppendingFormat:@"</table></font></td></tr>"];
//
//    }
//    return htmlFooterForSectionTenderTips;
//}
//
//- (NSString *)htmlFooterForSectionGiftCard {
//    NSString *htmlFooterForSectionGiftCard = @"";
//    
//    NSInteger totalcount = [[self reportSummary] [@"LoadCount"]integerValue] + [[self reportSummary] [@"RedeemCount"]integerValue];
////    float totalRegAmount = [[self reportSummary] [@"LoadAmount"]floatValue] + [[self reportSummary] [@"RedeemAmount"]floatValue];
////    NSNumber *numtotRegAmount = [NSNumber numberWithFloat:totalRegAmount];
////    
//    float totalAmount = [[self reportSummary] [@"TotalGCADY"]floatValue] + [[self reportSummary] [@"TotalLoadAmount"]floatValue] + [[self reportSummary] [@"TotalRedeemAmount"]floatValue];
//    NSNumber *numtotAmount = [NSNumber numberWithFloat:totalAmount];
//    
//    htmlFooterForSectionGiftCard = [htmlFooterForSectionGiftCard stringByAppendingFormat:@"<tr><td><strong><FONT SIZE = 2>Total</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td align=\"right\"><strong><FONT SIZE = 2>%ld</FONT> </strong></td></tr>",@"",[currencyFormatter stringFromNumber:numtotAmount],(long)totalcount];
//    htmlFooterForSectionGiftCard = [htmlFooterForSectionGiftCard stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:30px;\"><div align=\"right\"></div></td></tr>"];
//    htmlFooterForSectionGiftCard = [htmlFooterForSectionGiftCard stringByAppendingFormat:@"</table></font></td></tr>"];
//    return htmlFooterForSectionGiftCard;
//}
//
//- (NSString *)htmlFooterForSectionCardType {
//    NSString *htmlFooterForSectionCardType = @"";
//    double  rptCardTypeAmount = 0.00;
//    double  rptCardTypeAvgTicket = 0;
//    double  rptCardTypePercentage = 0;
//    int  rptCardTypeCount = 0;
//    
//    NSMutableArray *cardTypeReport= _reportData[@"RptCardType"];
//    if([cardTypeReport isKindOfClass:[NSArray class]])
//    {
//        for (int itx=0; itx<[cardTypeReport count]; itx++) {
//            NSMutableDictionary *cardTypeReportDisc = [cardTypeReport objectAtIndex:itx];
//            rptCardTypeAmount += [[cardTypeReportDisc valueForKey:@"Amount"]doubleValue];
//            rptCardTypeAvgTicket += [[cardTypeReportDisc valueForKey:@"AvgTicket"]doubleValue];
//            rptCardTypePercentage += [[cardTypeReportDisc valueForKey:@"Percentage"]floatValue];
//            rptCardTypeCount += [[cardTypeReportDisc valueForKey:@"Count"]intValue];
//        }
//    }
//    htmlFooterForSectionCardType = [htmlFooterForSectionCardType stringByAppendingFormat:@"<tr><td class = \"CardType\"><strong><FONT SIZE = 2>Total</FONT></strong></td><td class = \"CardTypeAmount\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"CardTypeAvgTicket\" align=\"right\"><strong><FONT SIZE = 2>%@</FONT> </strong></td><td class = \"CardTypeTypePer\" align=\"right\"><p><strong><FONT SIZE = 2>%.2f</FONT> </strong></p></td><td class = \"CardTypeCount\" align=\"right\"><p><strong><FONT SIZE = 2>%d</FONT> </strong></p></td></tr>",[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:rptCardTypeAmount]],[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:rptCardTypeAvgTicket]],rptCardTypePercentage,rptCardTypeCount];
//    
//    htmlFooterForSectionCardType = [htmlFooterForSectionCardType stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    
//    htmlFooterForSectionCardType = [htmlFooterForSectionCardType stringByAppendingFormat:@"</table></font></td></tr>"];
//    
//    return htmlFooterForSectionCardType;
//}
//
//- (NSString *)htmlFooterForSectionDepartment {
//    NSString *htmlFooterForSectionDepartment = @"";
//    NSMutableArray *departmentReport = _reportData [@"RptDepartment"];
//    NSPredicate *departmentPredicate = [NSPredicate predicateWithFormat:@"IsPayout = %@",@(0)];
//    NSArray *department = [departmentReport filteredArrayUsingPredicate:departmentPredicate];
//    htmlFooterForSectionDepartment = [self generateFooterHtmlFromArray:department withString:htmlFooterForSectionDepartment];
//    return htmlFooterForSectionDepartment;
//}
//
//- (NSString *)generateFooterHtmlFromArray:(NSArray *)array withString:(NSString *)htmlFooterForSectionDepartment
//{
//    double  rptDeptAmout = 0.00;
//    double  rptDeptCost = 0;
//    double  rptDeptPerc = 0;
//    int  rptDeptCustCount = 0;
//    CGFloat avgMargine = 0.00;
//    
//    for (int idpt=0; idpt<[array count]; idpt++) {
//        NSMutableDictionary *departRptDisc=[array objectAtIndex:idpt];
//        rptDeptCost += [[departRptDisc valueForKey:@"Cost"]doubleValue];
//        rptDeptAmout += [[departRptDisc valueForKey:@"Amount"]doubleValue];
//        rptDeptPerc += [[departRptDisc valueForKey:@"Per"]floatValue];
//        rptDeptCustCount += [[departRptDisc valueForKey:@"Count"]intValue];
//    }
//    
//    NSNumber *rptDeptAmtCnt = [NSNumber numberWithDouble:rptDeptAmout];
//    
//    avgMargine = [self calculateAvgMargineFromArray:array];
//    
//    NSString *rptDeptAmoutCnt =[NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:rptDeptAmtCnt]];
//    htmlFooterForSectionDepartment = [htmlFooterForSectionDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><strong><FONT SIZE = 2>Total</font></strong></td><td class = \"DepartmentCost\" align=\"right\" ><strong><FONT SIZE = 2>%@</font></strong></td><td class = \"DepartmentAmount\" align=\"right\" ><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"DepartmentMargin\" align=\"right\" style=\"padding-right:24px\"><strong><FONT SIZE = 2>%.2f</font></strong></td><td class = \"DepartmentPer\" align=\"right\"><strong><FONT SIZE = 2>%.2f</font></strong></td><td class = \"DepartmentCount\" align=\"right\"><strong><FONT SIZE = 2>%d</Font></strong></td></tr>",[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:rptDeptCost]],rptDeptAmoutCnt,avgMargine,rptDeptPerc,rptDeptCustCount];
//    
//    htmlFooterForSectionDepartment = [htmlFooterForSectionDepartment stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//
//    return htmlFooterForSectionDepartment;
//}
//
//- (NSString *)generateFooterHtmlForGrandTotalFromArray:(NSArray *)array withString:(NSString *)htmlFooterForSectionDepartment
//{
//    double  rptDeptAmout = 0.00;
//    double  rptDeptCost = 0;
//    double  rptDeptPerc = 0;
//    int  rptDeptCustCount = 0;
//    CGFloat avgMargine = 0.00;
//    
//    for (int idpt=0; idpt<[array count]; idpt++) {
//        NSMutableDictionary *departRptDisc=[array objectAtIndex:idpt];
//        rptDeptCost += [[departRptDisc valueForKey:@"Cost"]doubleValue];
//        rptDeptAmout += [[departRptDisc valueForKey:@"Amount"]doubleValue];
//        rptDeptPerc += [[departRptDisc valueForKey:@"Per"]floatValue];
//        rptDeptCustCount += [[departRptDisc valueForKey:@"Count"]intValue];
//    }
//    
//    NSNumber *rptDeptAmtCnt = [NSNumber numberWithDouble:rptDeptAmout];
//    
//    NSPredicate *departmentPredicate = [NSPredicate predicateWithFormat:@"IsPayout = %@",@(0)];
//    NSArray *department = [array filteredArrayUsingPredicate:departmentPredicate];
//    CGFloat avgMargineForDepartment = [self calculateAvgMargineFromArray:department];
//
//    NSPredicate *payOutPredicate = [NSPredicate predicateWithFormat:@"IsPayout = %@",@(1)];
//    NSArray *payOut = [array filteredArrayUsingPredicate:payOutPredicate];
//    CGFloat avgMargineForpayOut = [self calculateAvgMargineFromArray:payOut];
//    
//    avgMargine = avgMargineForDepartment + avgMargineForpayOut;
//    
//    NSString *rptDeptAmoutCnt =[NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:rptDeptAmtCnt]];
//    htmlFooterForSectionDepartment = [htmlFooterForSectionDepartment stringByAppendingFormat:@"<tr><td class = \"DepartmentName\"><strong><FONT SIZE = 2>G.Total</font></strong></td><td class = \"DepartmentCost\" align=\"right\" ><strong><FONT SIZE = 2>%@</font></strong></td><td class = \"DepartmentAmount\" align=\"right\" ><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"DepartmentMargin\" align=\"right\" style=\"padding-right:24px\"><strong><FONT SIZE = 2>%.2f</font></strong></td><td class = \"DepartmentPer\" align=\"right\"><strong><FONT SIZE = 2>%@</font></strong></td><td class = \"DepartmentCount\" align=\"right\"><strong><FONT SIZE = 2>%d</Font></strong></td></tr>",[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:rptDeptCost]],rptDeptAmoutCnt,avgMargine,@"100.00",rptDeptCustCount];
//    
//    htmlFooterForSectionDepartment = [htmlFooterForSectionDepartment stringByAppendingFormat:@"<tr><td style=\"padding-bottom:10px;\"><div align=\"right\"></div></td></tr>"];
//    
//    return htmlFooterForSectionDepartment;
//}
//
//- (CGFloat)calculateAvgMargineFromArray:(NSArray *)array
//{
//    double  rptDeptMargin = 0;
//    if ([array isKindOfClass:[NSArray class]] && [array count] > 0) {
//        for (int idpt=0; idpt<[array count]; idpt++) {
//            NSMutableDictionary *departRptDisc=[array objectAtIndex:idpt];
//            rptDeptMargin += [[departRptDisc valueForKey:@"Margin"]floatValue];
//        }
//    }
//    CGFloat avgMargine = 0.00;
//    if ([array count] > 0 && rptDeptMargin > 0) {
//        avgMargine = rptDeptMargin / [array count];
//    }
//    return avgMargine;
//}
//
//- (NSString *)htmlFooterForSectionPayout {
//    NSString *htmlFooterForSectionPayout = @"";
//    NSMutableArray *departmentReport = _reportData [@"RptDepartment"];
//    NSPredicate *departmentPredicate = [NSPredicate predicateWithFormat:@"IsPayout = %@",@(1)];
//    NSArray *payOut = [departmentReport  filteredArrayUsingPredicate:departmentPredicate];
//    htmlFooterForSectionPayout = [self generateFooterHtmlFromArray:payOut withString:htmlFooterForSectionPayout];
//    htmlFooterForSectionPayout = [self generateFooterHtmlForGrandTotalFromArray:departmentReport  withString:htmlFooterForSectionPayout];
//    htmlFooterForSectionPayout = [htmlFooterForSectionPayout stringByAppendingFormat:@"</table></font></td></tr>"];
//    return htmlFooterForSectionPayout;
//}
//
//- (NSString *)htmlFooterForHourlySales {
//    NSString *htmlFooterForHourlySales = @"";
//    double  rptHourlyCost = 0;
//    double  rptHourlyAmount = 0;
//    int  rptHourlyCount = 0;
//    CGFloat avgMargine = 0.00;
//
//    NSArray *hoursReport = _reportData [@"RptHours"];
//    if([hoursReport  isKindOfClass:[NSArray class]])
//    {
//        for (int idpt=0; idpt<[hoursReport  count]; idpt++) {
//            NSMutableDictionary *hoursRptDisc=[hoursReport objectAtIndex:idpt];
//            rptHourlyCost += [[hoursRptDisc valueForKey:@"Cost"]doubleValue];
//            rptHourlyAmount += [[hoursRptDisc valueForKey:@"Amount"]doubleValue];
//            rptHourlyCount += [[hoursRptDisc valueForKey:@"Count"]intValue];
//        }
//    }
//    if([hoursReport  count] > 0)
//    {
//        avgMargine = [self calculateAvgMargineFromArray:hoursReport ];
//    }
//    htmlFooterForHourlySales = [htmlFooterForHourlySales stringByAppendingFormat:@"<tr><td class = \"HourlySales\"><strong><FONT SIZE = 2>Total</font></strong></td><td class = \"HourlySalesCost\" align=\"right\"><strong><FONT SIZE = 2>%@</font></strong></td><td class = \"HourlySalesAmount\" align=\"right\" ><strong><FONT SIZE = 2>%@</FONT></strong></td><td class = \"HourlySalesMargin\"  align=\"right\" ><strong><FONT SIZE = 2>%.2f</font></strong></td><td class = \"HourlySalesCount\" align=\"right\" ><strong><FONT SIZE = 2>%d</font></strong></td></tr>",[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:rptHourlyCost]],[currencyFormatter stringFromNumber:[NSNumber numberWithDouble:rptHourlyAmount]],avgMargine,rptHourlyCount];
//    htmlFooterForHourlySales = [htmlFooterForHourlySales stringByAppendingFormat:@"<tr><td>&nbsp;</td><td style=\"padding-bottom:30px;\"><div align=\"right\"></div></td></tr>"];
//    htmlFooterForHourlySales = [htmlFooterForHourlySales stringByAppendingFormat:@"</table></font></td></tr>"];
//    htmlFooterForHourlySales = [htmlFooterForHourlySales stringByAppendingFormat:@"</div>"];
//    htmlFooterForHourlySales = [htmlFooterForHourlySales stringByAppendingFormat:@"</body></html>"];
//    return htmlFooterForHourlySales;
//}


#pragma mark - Report Data for printing
- (NSDictionary*)reportSummary {
    return [_reportData[@"RptMain"] firstObject];
}

- (NSArray*)tenderTypeDetail {
    return _reportData[@"RptTender"];
}
- (NSArray*)cardTypeDetail {
    return _reportData[@"RptCardType"];
}

#pragma mark - Configure
/*
 - (void)configureData {
    NSArray *responseArray;
    NSArray *mainReport= [responseArray  valueForKey:@"RptMain"];
    mainRptDisc = mainReport ;

    tenderCarddata= [responseArray valueForKey:@"RptTender"];
    taxReport= [responseArray valueForKey:@"RptTax"];
    tenderReport= [responseArray valueForKey:@"RptTender"];
    tendeReport = [responseArray valueForKey:@"RptTender"];
    departmentReport = [responseArray valueForKey:@"RptDepartment"];
    hoursReport= [[responseArray valueForKey:@"RptHours"] mutableCopy];
}
*/
@end
