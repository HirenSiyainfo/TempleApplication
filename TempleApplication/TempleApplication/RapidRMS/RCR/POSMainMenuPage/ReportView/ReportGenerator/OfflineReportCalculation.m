//
//  OfflineReportCalculation.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/4/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "OfflineReportCalculation.h"
#import "InvoiceData_T+Dictionary.h"
#import "RmsDbController.h"
#import "TaxMaster+Dictionary.h"
#import "TenderPay+Dictionary.h"
#import "Department+Dictionary.h"

#define MONEYORDER @"MoneyOrder"


/*
 This class is for offline calculation of RapidRms Report. Here we update the online report value
 with offline records which stores in device and which is not uploaded to RapidRms Server.
 */


@interface OfflineReportCalculation ()<UpdateDelegate>
{
    NSString *currentZId;
}

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;


@end
@implementation OfflineReportCalculation

- (instancetype)initWithArray:(NSMutableArray *)onlineReportDetail withZid:(NSString *)Zid
{
    self = [super init];
    if (self) {
        onlineReportArray = [[NSMutableArray alloc]init];
        onlineReportArray = onlineReportDetail;
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        self.managedObjectContext = self.rmsDbController.managedObjectContext;
        self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
        currentZId = Zid;

    }
    return self;
}
-(void)updateReportWithOfflineDetail
{
    [self updateGrossSalesWithOnlineDetail];
  
    [self updateTaxWithOnlineDetail];
   
    [self updateSalesWithOnlineDetail];
   
    [self updateReturnWithOnlineDetail];
    
    [self updateTaxArrayForOfflineDetail];
    
    [self updateTenderArrayForOfflineDetail];
    
    [self updatePayoutWithOfflineDetail];
   
    [self updateNontaxSalesWithOfflineDetail];
    
    [self updateCostOfGoodsWithOfflineDetail];
    
    [self updateDepartmentArrayForOfflineDetail];
    
    [self updateOfflineHourlySalesWithOnlineHourlySales];
}


- (NSMutableDictionary *)onlineReportSummary
{
    NSMutableArray *zOnlineMainArray = [onlineReportArray.firstObject valueForKey:@"RptMain"];
    NSMutableDictionary *zOnlineMainDictionary = zOnlineMainArray.firstObject;
    return zOnlineMainDictionary;
}
- (NSMutableArray *)onlineTaxDetail
{
    NSMutableArray *zOnlineTaxArray = [onlineReportArray.firstObject valueForKey:@"RptTax"];
    return [zOnlineTaxArray mutableCopy];
}
- (NSMutableArray *)onlineTenderDetail
{
    NSMutableArray *zOnlineTenderArray = [onlineReportArray.firstObject valueForKey:@"RptTender"];
    return [zOnlineTenderArray mutableCopy];
}
- (NSMutableArray *)onlineDepartmentDetail
{
    NSMutableArray *zOnlineDepartmentArray = [onlineReportArray.firstObject valueForKey:@"RptDepartment"];
    return [zOnlineDepartmentArray mutableCopy];
}
- (NSMutableArray *)onlineHourlySalesDetail
{
    NSMutableArray *zOnlineDepartmentArray = [onlineReportArray.firstObject valueForKey:@"RptHours"];
    return [zOnlineDepartmentArray mutableCopy];
}


- (NSArray *)removeIsdeductItemFromArray:(NSArray *)itemDetailArray_p
{
    NSPredicate *isDeductRemovePredicate = [NSPredicate predicateWithFormat:@"isDeduct == %@ OR isDeduct == %@",@"0",@(0)];
    return  [itemDetailArray_p filteredArrayUsingPredicate:isDeductRemovePredicate];
    
}
-(NSArray *)filterItemAsPerPredicate:(NSPredicate *)predicate forItemDetail:(NSArray *)itemDetail
{
    return  [itemDetail filteredArrayUsingPredicate:predicate];

}


#pragma mark - PayOut Calculation
-(void)updatePayoutWithOfflineDetail
{
    NSMutableDictionary *zOnlineMainDictionary = [self onlineReportSummary];

    NSArray *itemDetailArray = [self fetchItemDetailFromInvoiceTable];
    itemDetailArray = [self filterItemAsPerPredicate:[NSPredicate predicateWithFormat:@"isDeduct == %@ OR isDeduct == %@",@"1",@(1)] forItemDetail:itemDetailArray];
    
    CGFloat totalPayout = 0;
    if (itemDetailArray.count > 0)
    {
        for (NSDictionary *itemDictionary in itemDetailArray)
        {
            totalPayout += ([itemDictionary[@"ItemAmount"] floatValue] * [itemDictionary[@"ItemQty"] floatValue]);
         
            if (totalPayout < 0)
            {
                totalPayout = -totalPayout;
            }
        }
    }
    
    CGFloat payoutTotalOnlineAndOffline =
    [[zOnlineMainDictionary valueForKey:@"PayOut"] floatValue]
    + totalPayout;
    
    zOnlineMainDictionary[@"PayOut"] = [NSNumber numberWithFloat:payoutTotalOnlineAndOffline];
}

#pragma mark - NonTaxSales Calculation
- (NSArray *)getNonTaxSalesItemFrom:(NSArray *)itemDetailArray
{
    NSMutableArray *offlineNonSalesTaxDetailArray = [[NSMutableArray alloc]init];
    if(itemDetailArray.count>0)
    {
        for(int i=0;i<itemDetailArray.count;i++)
        {
            NSMutableArray * offlineTaxArray = [itemDetailArray[i] valueForKey:@"ItemTaxDetail"];
            if (![offlineTaxArray isKindOfClass:[NSMutableArray class]] ||  offlineTaxArray.count == 0)
            {
                [offlineNonSalesTaxDetailArray addObject:itemDetailArray[i]];
            }
        }
    }
    return offlineNonSalesTaxDetailArray;
}

-(void)updateNontaxSalesWithOfflineDetail
{
    NSMutableDictionary *zOnlineMainDictionary = [self onlineReportSummary];

    NSArray *itemDetailArray = [self fetchItemDetailFromInvoiceTable];
    itemDetailArray = [self filterItemAsPerPredicate:[NSPredicate predicateWithFormat:@"isDeduct == %@ OR isDeduct == %@",@"0",@(0)] forItemDetail:itemDetailArray];
    itemDetailArray = [self getNonTaxSalesItemFrom:itemDetailArray];
    
    
    NSNumber *itemTotalOfflineCheckcashSum = 0;
    NSNumber *itemTotalOfflineExtrachargeSum = 0;

    CGFloat totalNonTaxSales = 0.00;
    
    NSArray *isCheckcashExtraChargeFlaseArray = [self filterItemDetailArray:itemDetailArray forCheckCash:FALSE];
    if (isCheckcashExtraChargeFlaseArray.count > 0)
    {
        for (NSDictionary *itemDictionary in isCheckcashExtraChargeFlaseArray)
        {
            totalNonTaxSales += ([itemDictionary[@"ItemAmount"] floatValue] * [itemDictionary[@"ItemQty"] floatValue]);
        }
    }
    
    NSArray *isExtraChargeTrueArray = [self filterItemDetailArrayForExtraChargeItem:itemDetailArray];
    if (isExtraChargeTrueArray.count > 0)
    {
        if (isExtraChargeTrueArray.count > 0)
        {
            itemTotalOfflineExtrachargeSum = [isExtraChargeTrueArray valueForKeyPath:@"@sum.ExtraCharge"];
        }
    }
    
    
    NSArray *isCheckcashTrueArray = [self filterItemDetailArray:itemDetailArray forCheckCash:TRUE];
    if (isCheckcashTrueArray.count > 0)
    {
            itemTotalOfflineCheckcashSum = [isCheckcashTrueArray valueForKeyPath:@"@sum.CheckCashAmount"];
    }
    
    CGFloat nonTaxSalesTotalOnlineAndOffline =
    [[zOnlineMainDictionary valueForKey:@"NonTaxSales"] floatValue]
    + totalNonTaxSales
    + itemTotalOfflineCheckcashSum.floatValue
    + itemTotalOfflineExtrachargeSum.floatValue;
    
    
    zOnlineMainDictionary[@"NonTaxSales"] = [NSNumber numberWithFloat:nonTaxSalesTotalOnlineAndOffline];


}
#pragma mark - CostOfGoods Calculation
-(void)updateCostOfGoodsWithOfflineDetail
{
    NSMutableDictionary *zOnlineMainDictionary = [self onlineReportSummary];

    NSArray *itemDetailArray = [self fetchItemDetailFromInvoiceTable];
    itemDetailArray = [self filterItemAsPerPredicate:[NSPredicate predicateWithFormat:@"isDeduct == %@ OR isDeduct == %@",@"0",@(0)] forItemDetail:itemDetailArray];

    NSNumber *totalCostOfGood = 0;
    if (itemDetailArray.count > 0)
    {
         totalCostOfGood  = [itemDetailArray valueForKeyPath:@"@sum.ItemCost"];
    }
    
    CGFloat costOfGoodTotalOnlineAndOffline =
    [[zOnlineMainDictionary valueForKey:@"CostofGoods"] floatValue]
    + totalCostOfGood.floatValue;
    
    zOnlineMainDictionary[@"CostofGoods"] = [NSNumber numberWithFloat:costOfGoodTotalOnlineAndOffline];
}
#pragma mark - Customer Calculation
-(void)updateCustomerWithOfflineDetail
{
    
}
#pragma mark - Avgticket Calculation
-(void)updateAvgticketWithOfflineDetail
{
    
}

#pragma mark - GrossSales Calculation

-(NSPredicate *)predicateForIsCheckCashAndOthesItem:(BOOL)isCheckCash
{
    NSString *checkCashValue = [NSString stringWithFormat:@"%d",isCheckCash];
    return [NSPredicate predicateWithFormat:@"(isCheckCash == %@ OR isCheckCash == %@) AND (ExtraCharge == 0 OR ExtraCharge == %@)", checkCashValue,@(isCheckCash),@"0.000000"];
}
-(NSArray *)filterItemDetailArray:(NSArray *)itemDetail forCheckCash:(BOOL)isCheckCash
{
    return  [itemDetail filteredArrayUsingPredicate:[self predicateForIsCheckCashAndOthesItem:isCheckCash]];
}


-(NSPredicate *)predicateForIsExtraCharge
{
    return [NSPredicate predicateWithFormat:@"ExtraCharge > %@",@"0.00"];
    
}
-(NSArray *)filterItemDetailArrayForExtraChargeItem:(NSArray *)itemDetail
{
    return  [itemDetail filteredArrayUsingPredicate:[self predicateForIsExtraCharge]];
}


-(void)updateGrossSalesWithOnlineDetail
{
    NSMutableDictionary *zOnlineMainDictionary = [self onlineReportSummary];
    
    NSArray *itemDetailArray = [self fetchItemDetailFromInvoiceTable];
    itemDetailArray = [self removeIsdeductItemFromArray:itemDetailArray];
    
    NSNumber *itemTotalOfflineSum = 0;
  
    NSNumber *itemTotalOfflineCheckcashSum = 0;
    NSNumber *itemTotalOfflineCheckcashTaxSum = 0;
    
    NSNumber *itemTotalOfflineExtrachargeSum = 0;
    NSNumber *itemTotalOfflineExtrachargeTaxSum = 0;


    NSArray *isCheckcashExtraChargeFlaseArray = [self filterItemDetailArray:itemDetailArray forCheckCash:FALSE];
    if (isCheckcashExtraChargeFlaseArray.count > 0)
    {
        if (isCheckcashExtraChargeFlaseArray.count > 0)
        {
            
            CGFloat itemTotalOffline = [[isCheckcashExtraChargeFlaseArray valueForKeyPath:@"@sum.TotalItemAmount"] floatValue] - [[isCheckcashExtraChargeFlaseArray valueForKeyPath:@"@sum.ItemTaxAmount"] floatValue];
            itemTotalOfflineSum = @(itemTotalOffline);
        //    itemTotalOfflineSum = [isCheckcashExtraChargeFlaseArray valueForKeyPath:@"@sum.TotalItemAmount"];
        }
    }
    
    
    NSArray *isExtraChargeTrueArray = [self filterItemDetailArrayForExtraChargeItem:itemDetailArray];
    if (isExtraChargeTrueArray.count > 0)
    {
        if (isExtraChargeTrueArray.count > 0)
        {
            itemTotalOfflineExtrachargeSum = [isExtraChargeTrueArray valueForKeyPath:@"@sum.ExtraCharge"];
            itemTotalOfflineExtrachargeTaxSum = [isExtraChargeTrueArray valueForKeyPath:@"@sum.ItemTaxAmount"];
        }
    }
    
    NSArray *isCheckcashTrueArray = [self filterItemDetailArray:itemDetailArray forCheckCash:TRUE];
    if (isCheckcashTrueArray.count > 0)
    {
        if (isCheckcashTrueArray.count > 0)
        {
            itemTotalOfflineCheckcashSum = [isCheckcashTrueArray valueForKeyPath:@"@sum.CheckCashAmount"];
            itemTotalOfflineCheckcashTaxSum = [isCheckcashTrueArray valueForKeyPath:@"@sum.ItemTaxAmount"];
        }
    }
    
   CGFloat salesTotalOnlineAndOffline =
      [[zOnlineMainDictionary valueForKey:@"TotalSales"] floatValue]
    + itemTotalOfflineSum.floatValue
    + itemTotalOfflineExtrachargeSum.floatValue
    + itemTotalOfflineCheckcashSum.floatValue
    + itemTotalOfflineCheckcashTaxSum.floatValue
    + itemTotalOfflineExtrachargeTaxSum.floatValue;
    
   zOnlineMainDictionary[@"TotalSales"] = [NSNumber numberWithFloat:salesTotalOnlineAndOffline];
}

#pragma mark - TotalTax Calculation
- (NSMutableArray *)configureOfflineTaxDetailArrayFromItemDetail:(NSArray *)itemDetail
{
    NSMutableArray *offlineTaxDetailArray = [[NSMutableArray alloc]init];
        if(itemDetail.count>0)
        {
            for(int i=0;i<itemDetail.count;i++)
            {
                NSMutableArray * offlineTaxArray = [itemDetail[i] valueForKey:@"ItemTaxDetail"];
                if ([offlineTaxArray isKindOfClass:[NSMutableArray class]])
                {
                    if (offlineTaxArray.count > 0)
                    {
                        for(int j=0;j<offlineTaxArray.count;j++)
                        {
                            [offlineTaxDetailArray addObject:offlineTaxArray[j]];
                        }
                    }
                }
            }
        }
    
    return offlineTaxDetailArray;
}

-(void)updateTaxWithOnlineDetail
{
    NSArray *itemTaxDetail = [self fetchItemDetailFromInvoiceTable];
    itemTaxDetail = [self removeIsdeductItemFromArray:itemTaxDetail];
    [self updateCollectedTaxWithofflineData:[self configureOfflineTaxDetailArrayFromItemDetail:itemTaxDetail]];
}

-(CGFloat )updateCollectedTaxWithofflineData:(NSMutableArray *)offlineTaxArray
{
    NSMutableDictionary *zOnlineMainDictionary = [self onlineReportSummary];

    NSNumber *taxOfflineSum = 0;
    CGFloat amount =0.0;
    
    if (offlineTaxArray.count > 0)
    {
        taxOfflineSum =[offlineTaxArray valueForKeyPath:@"@sum.ItemTaxAmount"];
    }
    amount = [[zOnlineMainDictionary valueForKey:@"CollectTax"] floatValue];
    amount = amount + taxOfflineSum.floatValue;
    zOnlineMainDictionary[@"CollectTax"] = [NSNumber numberWithFloat:amount];
    return taxOfflineSum.floatValue;
}



-(NSMutableArray *)fetchItemDetailFromInvoiceTable
{
    NSMutableArray *offlineItemDetail = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"zId==%@ AND isUpload==%@",currentZId,@(FALSE)];
    fetchRequest.predicate = predicate;
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(object.count>0)
    {
        for (InvoiceData_T *invoice in object)
        {
            if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject] count]>0)
            {
                NSMutableArray *archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject];
                
                for(int i=0;i<archiveArray.count;i++){
                    
                    [offlineItemDetail addObject:archiveArray[i]];
                }
            }
            
        }
    }
    return offlineItemDetail;
}
#pragma mark - Sales Calculation
-(void)updateSalesWithOnlineDetail
{
    NSMutableDictionary *zOnlineMainDictionary = [self onlineReportSummary];
    
    NSArray *itemDetailArray = [self fetchItemDetailFromInvoiceTable];
    itemDetailArray = [self removeIsdeductItemFromArray:itemDetailArray];
    
    NSNumber *itemTotalOfflineCheckcashSum = 0;
    NSNumber *itemTotalOfflineExtrachargeSum = 0;

    
    CGFloat totalSales = 0.00;
    
    NSArray *isCheckcashExtraChargeFlaseArray = [self filterItemDetailArray:itemDetailArray forCheckCash:FALSE];
    if (isCheckcashExtraChargeFlaseArray.count > 0)
    {
        NSPredicate *isGreaterItemAmountPredicate = [NSPredicate predicateWithFormat:@"ItemAmount > %@",@"0.00"];
         isCheckcashExtraChargeFlaseArray = [isCheckcashExtraChargeFlaseArray filteredArrayUsingPredicate:isGreaterItemAmountPredicate];
        
        if (isCheckcashExtraChargeFlaseArray.count > 0)
        {
            for (NSDictionary *itemDictionary in isCheckcashExtraChargeFlaseArray)
            {
                totalSales += ([itemDictionary[@"ItemAmount"] floatValue] * [itemDictionary[@"ItemQty"] floatValue]);
            }
        }
    }
    
    
    NSArray *isExtraChargeTrueArray = [self filterItemDetailArrayForExtraChargeItem:itemDetailArray];
    if (isExtraChargeTrueArray.count > 0)
    {
        NSPredicate *isGreaterItemAmountPredicate = [NSPredicate predicateWithFormat:@"ItemAmount > %@",@"0.00"];
        isExtraChargeTrueArray = [isExtraChargeTrueArray filteredArrayUsingPredicate:isGreaterItemAmountPredicate];
        
        if (isExtraChargeTrueArray.count > 0)
        {
            itemTotalOfflineExtrachargeSum = [isExtraChargeTrueArray valueForKeyPath:@"@sum.ExtraCharge"];
        }
    }

    
    
    NSArray *isCheckcashTrueArray = [self filterItemDetailArray:itemDetailArray forCheckCash:TRUE];
    if (isCheckcashTrueArray.count > 0)
    {
        NSPredicate *isGreaterItemAmountPredicate = [NSPredicate predicateWithFormat:@"ItemAmount > %@",@"0.00"];
        isCheckcashTrueArray = [isCheckcashTrueArray filteredArrayUsingPredicate:isGreaterItemAmountPredicate];
        if (isCheckcashTrueArray.count > 0)
        {
            itemTotalOfflineCheckcashSum = [isCheckcashTrueArray valueForKeyPath:@"@sum.CheckCashAmount"];
        }
    }
    
    CGFloat salesTotalOnlineAndOffline =
    [[zOnlineMainDictionary valueForKey:@"Sales"] floatValue]
    + totalSales
    + itemTotalOfflineCheckcashSum.floatValue
    +itemTotalOfflineExtrachargeSum.floatValue;
    
    zOnlineMainDictionary[@"Sales"] = [NSNumber numberWithFloat:salesTotalOnlineAndOffline];
}

-(void)updateReturnWithOnlineDetail
{
    NSMutableDictionary *zOnlineMainDictionary = [self onlineReportSummary];
    
    NSArray *itemDetailArray = [self fetchItemDetailFromInvoiceTable];
    itemDetailArray = [self removeIsdeductItemFromArray:itemDetailArray];
    
    NSNumber *itemTotalOfflineCheckcashSum = 0;
//    NSNumber *itemTotalOfflineExtrachargeSum = 0;

    CGFloat totalSales = 0.00;

    NSArray *isCheckcashExtraChargeFlaseArray = [self filterItemDetailArray:itemDetailArray forCheckCash:FALSE];
    if (isCheckcashExtraChargeFlaseArray.count > 0)
    {
        NSPredicate *isGreaterItemAmountPredicate = [NSPredicate predicateWithFormat:@"ItemAmount < %@",@"0.00"];
        isCheckcashExtraChargeFlaseArray = [isCheckcashExtraChargeFlaseArray filteredArrayUsingPredicate:isGreaterItemAmountPredicate];
        
        if (isCheckcashExtraChargeFlaseArray.count > 0)
        {
            for (NSDictionary *itemDictionary in isCheckcashExtraChargeFlaseArray)
            {
                totalSales += ([itemDictionary[@"ItemAmount"] floatValue] * [itemDictionary[@"ItemQty"] floatValue]);            }
        }
    }
    
   
    NSArray *isExtraChargeTrueArray = [self filterItemDetailArrayForExtraChargeItem:itemDetailArray];
    if (isExtraChargeTrueArray.count > 0)
    {
        NSPredicate *isGreaterItemAmountPredicate = [NSPredicate predicateWithFormat:@"ItemAmount < %@",@"0.00"];
        isExtraChargeTrueArray = [isExtraChargeTrueArray filteredArrayUsingPredicate:isGreaterItemAmountPredicate];

        if (isExtraChargeTrueArray.count > 0)
        {
//            itemTotalOfflineExtrachargeSum = [isExtraChargeTrueArray valueForKeyPath:@"@sum.ExtraCharge"];
        }
    }
    
    
    
    NSArray *isCheckcashTrueArray = [self filterItemDetailArray:itemDetailArray forCheckCash:TRUE];
    if (isCheckcashTrueArray.count > 0)
    {
        NSPredicate *isGreaterItemAmountPredicate = [NSPredicate predicateWithFormat:@"ItemAmount < %@",@"0.00"];
        isCheckcashTrueArray = [isCheckcashTrueArray filteredArrayUsingPredicate:isGreaterItemAmountPredicate];
        
        if (isCheckcashTrueArray.count > 0)
        {
            itemTotalOfflineCheckcashSum = [isCheckcashTrueArray valueForKeyPath:@"@sum.CheckCashAmount"];
        }
    }
 

    CGFloat salesTotalOnlineAndOffline = [[zOnlineMainDictionary valueForKey:@"Return"] floatValue] + totalSales + itemTotalOfflineCheckcashSum.floatValue ;
    zOnlineMainDictionary[@"Return"] = [NSNumber numberWithFloat:salesTotalOnlineAndOffline];
}

-(void)updateTaxArrayForOfflineDetail
{
    NSArray *itemTaxDetail = [self fetchItemDetailFromInvoiceTable];
    itemTaxDetail = [self configureOfflineTaxDetailArrayFromItemDetail:itemTaxDetail];
    NSArray *taxIds = [itemTaxDetail valueForKeyPath:@"TaxId"];
    NSSet *taxSet = [NSSet setWithArray:taxIds];
    
    NSMutableArray *offlineTaxArray = [[NSMutableArray alloc]init];
    
    for (NSNumber *taxId in taxSet)
    {
        NSNumber *taxIdValue = taxId;
        if ([taxId isKindOfClass:[NSString class]]) {
            taxIdValue = @(taxId.integerValue);
        }

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TaxId == %@ OR TaxId == %@", taxIdValue , taxIdValue.stringValue];
        NSArray *taxIdFilterArray = [itemTaxDetail filteredArrayUsingPredicate:predicate];

        NSNumber *toatltaxAmountForTaxId = [taxIdFilterArray valueForKeyPath:@"@sum.ItemTaxAmount"];

        NSMutableDictionary  *dictTax = [[NSMutableDictionary alloc]init];
        dictTax[@"Amount"] = toatltaxAmountForTaxId;
        dictTax[@"Descriptions"] = [NSString stringWithFormat:@"%@",[self descriptionForTaxId:taxIdValue]];
        dictTax[@"TaxId"] = [taxIdFilterArray.firstObject valueForKey:@"TaxId"];
        dictTax[@"Sales"] = @"0";
        dictTax[@"Count"] = @(taxIdFilterArray.count);

        [offlineTaxArray addObject:dictTax];
    }
    NSLog(@"offlineTaxArray = %@",offlineTaxArray);
    [self updateTaxOfflineArrayWithOnlineArray:offlineTaxArray];
}


-(void)updateTaxOfflineArrayWithOnlineArray:(NSMutableArray *)taxOfflineArray
{
    NSMutableArray *onlineTaxArray = [self onlineTaxDetail];
    if (onlineTaxArray.count == 0) {
        return;
    }
    
    for (int i = 0; i < taxOfflineArray.count; i++)
    {
        NSMutableDictionary *taxOfflineDictionary = taxOfflineArray[i];
        NSPredicate *predicateForTax = [NSPredicate predicateWithFormat:@"TaxId == %@",[taxOfflineDictionary  valueForKey:@"TaxId"]];
        NSMutableArray *taxDetailForPredicate = [[onlineTaxArray filteredArrayUsingPredicate:predicateForTax] mutableCopy];
        if (taxDetailForPredicate.count > 0)
        {
            NSMutableDictionary * dictTax = taxDetailForPredicate.firstObject;
            CGFloat totalItemTaxAmount = [[taxOfflineDictionary valueForKey:@"Amount"]floatValue] +
            [[dictTax valueForKey:@"Amount"]floatValue];
            dictTax[@"Amount"] = @(totalItemTaxAmount);
            dictTax[@"Descriptions"] = [dictTax valueForKey:@"Descriptions"];
            dictTax[@"TaxId"] = [dictTax valueForKey:@"TaxId"];
            dictTax[@"Sales"] = [dictTax valueForKey:@"Sales"];
            dictTax[@"Count"] = [dictTax valueForKey:@"Count"];

        }
        else
        {
            NSMutableDictionary * dictTax = [[NSMutableDictionary alloc]init];
            CGFloat totalItemTaxAmount = [[taxOfflineDictionary valueForKey:@"Amount"] floatValue];
            dictTax[@"Amount"] = @(totalItemTaxAmount);
            dictTax[@"Descriptions"] = [taxOfflineDictionary valueForKey:@"Descriptions"];
            dictTax[@"TaxId"] = [taxOfflineDictionary valueForKey:@"TaxId"];
            dictTax[@"Sales"] = [taxOfflineDictionary valueForKey:@"Sales"];
            dictTax[@"Count"] = [taxOfflineDictionary valueForKey:@"Count"];

            [onlineTaxArray addObject:dictTax];
        }
    }
    
    NSMutableDictionary *zOnlineTaxDictionary = onlineReportArray.firstObject;
    if (onlineTaxArray == nil) {
        return;
    }
    zOnlineTaxDictionary[@"RptTax"] = onlineTaxArray;
}

   

-(NSString *)descriptionForTaxId:(NSNumber *)taxId
{
    NSString *description = @"";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId == %@", taxId];
    
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0)
    {
        for (TaxMaster *txMaster in resultSet) {
            description = txMaster.taxNAME;
        }
    }
    return description;
}
#pragma mark - TenderType Calculation
-(void)updateTenderArrayForOfflineDetail
{
    NSMutableArray *offlinePaymentArray = [self fetchPaymentDataFromInvoiceTable];
    NSArray *tenderIdArray = [offlinePaymentArray valueForKeyPath:@"PayId"];
    NSSet *tenderIdSet = [NSSet setWithArray:tenderIdArray];
    
    NSMutableArray *offlinePaymentDetailArray = [[NSMutableArray alloc]init];
    
    for (NSNumber *payId in tenderIdSet)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"PayId == %@ OR PayId == %@", payId , payId.stringValue];
        NSArray *tenderIdFilterArray = [offlinePaymentArray filteredArrayUsingPredicate:predicate];
     
        CGFloat totalPayment = 0.00;
     
        NSNumber *totalTips = [tenderIdFilterArray valueForKeyPath:@"@sum.TipsAmount"];

        for (NSDictionary *paymentDictionary in tenderIdFilterArray)
        {
            totalPayment += ([paymentDictionary[@"BillAmount"] floatValue] - [paymentDictionary[@"ReturnAmount"] floatValue]);
        }
        
        NSMutableDictionary  *dictTax = [[NSMutableDictionary alloc]init];
        dictTax[@"Amount"] = @(totalPayment);
        dictTax[@"AvgTicket"] = @(totalPayment);
        dictTax[@"CashInType"] = [NSString stringWithFormat:@"%@",[self descriptionForPaymentId:payId]];
        dictTax[@"Count"] = @(tenderIdFilterArray.count);
        dictTax[@"Descriptions"] = [NSString stringWithFormat:@"%@",[self descriptionForPaymentId:payId]];
        dictTax[@"Percentage"] = @(0);
        dictTax[@"TenderId"] = payId;
        dictTax[@"TipsAmount"] = totalTips;
        dictTax[@"TipsCount"] = @(totalPayment);
        [offlinePaymentDetailArray addObject:dictTax];
    }
  
    NSLog(@"offlinePaymentDetailArray = %@",offlinePaymentDetailArray);
    [self updateTenderOfflineArrayWithOnlineArray:offlinePaymentDetailArray];
}

-(NSString *)descriptionForPaymentId:(NSNumber *)paymentId
{
    NSString *description = @"";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payId == %@", paymentId];
    
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0)
    {
        for (TenderPay *tenderPay in resultSet) {
            description = tenderPay.paymentName;
        }
    }
    return description;
}
-(void)updateTenderOfflineArrayWithOnlineArray:(NSMutableArray *)tenderOfflineArray
{
    NSMutableArray *onlineTenderArray = [self onlineTenderDetail];
    
    for (int i = 0; i < tenderOfflineArray.count; i++)
    {
        NSMutableDictionary *tenderOfflineDictionary = tenderOfflineArray[i];
        NSPredicate *predicateForTender = [NSPredicate predicateWithFormat:@"TenderId == %@",[tenderOfflineDictionary  valueForKey:@"TenderId"]];
        NSMutableArray *tenderDetailForPredicate = [[onlineTenderArray filteredArrayUsingPredicate:predicateForTender] mutableCopy];
        if (tenderDetailForPredicate.count > 0)
        {
            NSMutableDictionary * dictTender = tenderDetailForPredicate.firstObject;
            CGFloat totalTenderAmount = [[tenderOfflineDictionary valueForKey:@"Amount"]floatValue] +
            [[dictTender valueForKey:@"Amount"]floatValue];
          
            dictTender[@"Amount"] = @(totalTenderAmount);
            dictTender[@"AvgTicket"] = [dictTender valueForKey:@"AvgTicket"];
            dictTender[@"CashInType"] = [dictTender valueForKey:@"CashInType"];
            dictTender[@"Count"] = [dictTender valueForKey:@"Count"];
            dictTender[@"Descriptions"] = [dictTender valueForKey:@"Descriptions"];
            dictTender[@"Percentage"] = [dictTender valueForKey:@"Percentage"];
            dictTender[@"TenderId"] = [dictTender valueForKey:@"TenderId"];
            dictTender[@"TipsAmount"] = [dictTender valueForKey:@"TipsAmount"];
            dictTender[@"TipsCount"] = [dictTender valueForKey:@"TipsCount"];
        }
        else
        {
            NSMutableDictionary * dictTender = [[NSMutableDictionary alloc]init];
            CGFloat totalTenderAmount = [[tenderOfflineDictionary valueForKey:@"Amount"]floatValue];
           
            dictTender[@"Amount"] = @(totalTenderAmount);
            dictTender[@"AvgTicket"] = [tenderOfflineDictionary valueForKey:@"AvgTicket"];
            dictTender[@"CashInType"] = [tenderOfflineDictionary valueForKey:@"CashInType"];
            dictTender[@"Count"] = [tenderOfflineDictionary valueForKey:@"Count"];
            dictTender[@"Descriptions"] = [tenderOfflineDictionary valueForKey:@"Descriptions"];
            dictTender[@"Percentage"] = [tenderOfflineDictionary valueForKey:@"Percentage"];
            dictTender[@"TenderId"] = [tenderOfflineDictionary valueForKey:@"TenderId"];
            dictTender[@"TipsAmount"] = [tenderOfflineDictionary valueForKey:@"TipsAmount"];
            dictTender[@"TipsCount"] = [tenderOfflineDictionary valueForKey:@"TipsCount"];
            
            [onlineTenderArray addObject:dictTender];
        }
    }
    
    NSMutableDictionary *zOnlineTenderDictionary = onlineReportArray.firstObject;
    zOnlineTenderDictionary[[self tenderKeyForReport]] = onlineTenderArray;
}

-(NSString *)tenderKeyForReport
{
    return @"RptTender";
}


-(NSMutableArray *)fetchPaymentDataFromInvoiceTable
{
    NSMutableArray *zOfflineArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"zId==%@ AND isUpload==%@",currentZId,@(FALSE)];
    fetchRequest.predicate = predicate;
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(object.count>0)
    {
        for (InvoiceData_T *invoice in object)
        {
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//            [calendar setTimeZone:sourceTimeZone];
//            NSDateComponents *dateComponents = [calendar components:NSCalendarUnitHour fromDate:invoice.invoiceDate];
//            NSLog(@"dateComponents.hour %ld",(long)dateComponents.hour);
          
            if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoicePaymentData] firstObject] count]>0)
            {
                NSMutableArray *archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoicePaymentData] firstObject];
                for(int i=0;i<archiveArray.count;i++){
                    
                    [zOfflineArray addObject:archiveArray[i]];
                }
            }
            
        }
    }
    return zOfflineArray;
}

#pragma mark - Department Calculation
-(void)updateDepartmentArrayForOfflineDetail
{
    NSArray *itemDepartmentDetail = [self fetchItemDetailFromInvoiceTable];
    NSArray *departmentId = [itemDepartmentDetail valueForKeyPath:@"departId"];
    NSSet *departmentSet = [NSSet setWithArray:departmentId];
    
    NSMutableArray *offlineDepartmentArray = [[NSMutableArray alloc]init];
    
    for (NSNumber *departmentId in departmentSet)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"departId == %@", departmentId];
        NSArray *departmentFilterArray = [itemDepartmentDetail filteredArrayUsingPredicate:predicate];
        
        
        CGFloat totalDepartmentAmount = 0.00;
        
        for (NSDictionary *departmentDictionary in departmentFilterArray)
        {
            totalDepartmentAmount += ([departmentDictionary[@"ItemAmount"] floatValue] * [departmentDictionary[@"ItemQty"] floatValue]) +
            [departmentDictionary[@"ExtraCharge"] floatValue] ;
        }
        
        Department *department = [self.updateManager fetchDepartmentWithDepartmentId:departmentId moc:self.managedObjectContext];
        if (department == nil) {
            continue;
        }
        
        
        NSMutableDictionary  *dictDepartment = [[NSMutableDictionary alloc]init];
        dictDepartment[@"Amount"] = @(totalDepartmentAmount);
        dictDepartment[@"Cost"] = @(totalDepartmentAmount);
        dictDepartment[@"IsPayout"] = department.deductChk;
        dictDepartment[@"Margin"] = @(totalDepartmentAmount);
        dictDepartment[@"Per"] = @(totalDepartmentAmount);
        dictDepartment[@"Descriptions"] = [NSString stringWithFormat:@"%@",department.deptName];
        dictDepartment[@"DepartId"] = @([[departmentFilterArray.firstObject valueForKey:@"departId"] integerValue]);
        dictDepartment[@"Count"] = @(departmentFilterArray.count);
        
        [offlineDepartmentArray addObject:dictDepartment];
    }
    NSLog(@"offlineDepartmentArray = %@",offlineDepartmentArray);
    [self updateDepartmentOfflineArrayWithOnlineArray:offlineDepartmentArray];
}


-(void)updateDepartmentOfflineArrayWithOnlineArray:(NSMutableArray *)departmentOfflineArray
{
    NSMutableArray *onlineDepartmentArray = [self onlineDepartmentDetail];
    
    
    for (int i = 0; i < departmentOfflineArray.count; i++)
    {
        NSMutableDictionary *departmentOfflineDictionary = departmentOfflineArray[i];
        
        NSPredicate *predicateForDepartment = [NSPredicate predicateWithFormat:@"DepartId == %@",[departmentOfflineDictionary  valueForKey:@"DepartId"]];
        NSMutableArray *departmentDetailForPredicate = [[onlineDepartmentArray filteredArrayUsingPredicate:predicateForDepartment] mutableCopy];
        if (departmentDetailForPredicate.count > 0)
        {
            NSMutableDictionary * dictDepartment = departmentDetailForPredicate.firstObject;
            CGFloat totalItemDepartmentAmount = [[departmentOfflineDictionary valueForKey:@"Amount"]floatValue] +
            [[dictDepartment valueForKey:@"Amount"]floatValue];
            dictDepartment[@"Amount"] = @(totalItemDepartmentAmount);
            dictDepartment[@"Descriptions"] = [dictDepartment valueForKey:@"Descriptions"];
            dictDepartment[@"Cost"] = [dictDepartment valueForKey:@"Cost"];
            dictDepartment[@"IsPayout"] = [dictDepartment valueForKey:@"IsPayout"];
            dictDepartment[@"Margin"] = [dictDepartment valueForKey:@"Margin"];
            dictDepartment[@"Per"] = [dictDepartment valueForKey:@"Per"];
            dictDepartment[@"DepartId"] = [dictDepartment valueForKey:@"DepartId"];
            dictDepartment[@"Count"] = [dictDepartment valueForKey:@"Count"];
            
        }
        else
        {
            NSMutableDictionary * dictDepartment = [[NSMutableDictionary alloc]init];
            CGFloat totalItemDepartmentAmount = [[departmentOfflineDictionary valueForKey:@"Amount"] floatValue];
            dictDepartment[@"Amount"] = @(totalItemDepartmentAmount);
            dictDepartment[@"Descriptions"] = [departmentOfflineDictionary valueForKey:@"Descriptions"];
            dictDepartment[@"Cost"] = [departmentOfflineDictionary valueForKey:@"Cost"];
            dictDepartment[@"IsPayout"] = [departmentOfflineDictionary valueForKey:@"IsPayout"];
            dictDepartment[@"Margin"] = [departmentOfflineDictionary valueForKey:@"Margin"];
            dictDepartment[@"Per"] = [departmentOfflineDictionary valueForKey:@"Per"];
            dictDepartment[@"DepartId"] = [departmentOfflineDictionary valueForKey:@"DepartId"];
            dictDepartment[@"Count"] = [departmentOfflineDictionary valueForKey:@"Count"];
            [onlineDepartmentArray addObject:dictDepartment];
        }
    }
    
    NSMutableDictionary *zOnlineDepartmentDictionary = onlineReportArray.firstObject;
    if (onlineDepartmentArray == nil) {
        return;
    }
    zOnlineDepartmentDictionary[@"RptDepartment"] = onlineDepartmentArray;
}



-(Department *)descriptionForDepartmentId:(NSNumber *)departmentId
{
    Department *department = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId == %@", departmentId];
    
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0)
    {
        department = resultSet.firstObject;
    }
    return department;
}

#pragma mark - Hourly Calculation

-(NSNumber *)sumOfItemCostForInvoice:(InvoiceData_T *)invoice
{
    NSNumber *totalItemCost = 0;
    if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject] count]>0)
    {
        NSArray *archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject];
        
        if (archiveArray.count > 0)
        {
            totalItemCost  = [archiveArray valueForKeyPath:@"@sum.ItemCost"];
        }
    }
    return totalItemCost;
}
-(void)updateOfflineHourlySalesWithOnlineHourlySales
{
    NSMutableArray *hourlSalesArray = [[NSMutableArray alloc]init];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"zId==%@ AND isUpload==%@",currentZId,@(FALSE)];
    fetchRequest.predicate = predicate;
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(object.count>0)
    {
        for (InvoiceData_T *invoice in object)
        {
            if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceMstData] firstObject] count]>0)
            {
                NSDictionary *invoiceMasterDictionary = [[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceMstData] firstObject] firstObject];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                formatter.dateFormat = @"hh:mm a";
                NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                formatter.timeZone = sourceTimeZone;
                NSString *dateString = [formatter stringFromDate:invoice.invoiceDate];
                NSMutableDictionary *hourlySaleDictionary = [[NSMutableDictionary alloc]init];
                hourlySaleDictionary[@"Amount"] = [invoiceMasterDictionary valueForKey:@"BillAmount"];
                if ([self sumOfItemCostForInvoice:invoice] != nil) {
                    hourlySaleDictionary[@"Cost"] = [self sumOfItemCostForInvoice:invoice];
                }
                hourlySaleDictionary[@"Count"] = @"";
                hourlySaleDictionary[@"Hours"] = dateString;
                hourlySaleDictionary[@"Margin"] = @"";
                [hourlSalesArray addObject:hourlySaleDictionary];
            }
        }
    }
    [self setupOfflineHourlyArrayFrom:hourlSalesArray];
}


-(void)setupOfflineHourlyArrayFrom:(NSMutableArray *)hourlySalesArray
{
    NSArray *totalHours = [hourlySalesArray valueForKeyPath:@"Hours"];
    NSSet *hourSet = [NSSet setWithArray:totalHours];
    
    NSMutableArray *offlineHoursArray = [[NSMutableArray alloc]init];
    
    for (NSString *hour in hourSet)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Hours == %@", hour];
        NSArray *hoursFilterArray = [hourlySalesArray filteredArrayUsingPredicate:predicate];
        
        NSNumber *totalhoursCost  = [hoursFilterArray valueForKeyPath:@"@sum.Cost"];
        NSNumber *totalhoursBillAmount  = [hoursFilterArray valueForKeyPath:@"@sum.Amount"];
        
        NSMutableDictionary  *dictHours = [[NSMutableDictionary alloc]init];
        dictHours[@"Amount"] = totalhoursBillAmount;
        dictHours[@"Cost"] = totalhoursCost;
        dictHours[@"Margin"] = @"";
        dictHours[@"Count"] = @(hoursFilterArray.count);
        dictHours[@"Hours"] = hour;
        [offlineHoursArray addObject:dictHours];
    }
    NSLog(@"offlineHoursArray = %@",offlineHoursArray);
    
    [self updateHourlySalesOfflineArrayWithOnlineArray:offlineHoursArray];

}


-(NSDate*)jsonStringToNSDate:(NSString*)string
{
    // Extract the numeric part of the date.  Dates should be in the format
    // "/Date(x)/", where x is a number.  This format is supplied automatically
    // by JSON serialisers in .NET.
    NSRange range = NSMakeRange(6, string.length - 8);
    NSString* substring = [string substringWithRange:range];
    
    // Have to use a number formatter to extract the value from the string into
    // a long long as the longLongValue method of the string doesn't seem to
    // return anything useful - it is always grossly incorrect.
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    NSNumber* milliseconds = [formatter numberFromString:substring];
    // NSTimeInterval is specified in seconds.  The value we get back from the
    // web service is specified in milliseconds.  Both values are since 1st Jan
    // 1970 (epoch).
    NSTimeInterval seconds = milliseconds.longLongValue / 1000;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}


-(void)configureOnlineHourlyArrayDateForUpdateWithOffline:(NSMutableArray *)onlineHourlySalesArray
{
    for (NSMutableDictionary *hourlyDictionary in onlineHourlySalesArray)
    {
        NSDate *date = [self jsonStringToNSDate:hourlyDictionary[@"Hours"]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm";
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        NSString *text1 = [formatter stringFromDate:date];
        hourlyDictionary[@"HourlyDateValue"] = [NSString stringWithFormat:@"%@",text1];
    }
}

-(void)updateHourlySalesOfflineArrayWithOnlineArray:(NSMutableArray *)hourlySalesOfflineArray
{
    NSMutableArray *onlineHourlySalesArray = [self onlineHourlySalesDetail];
    [self configureOnlineHourlyArrayDateForUpdateWithOffline:onlineHourlySalesArray];
    
    for (int i = 0; i < hourlySalesOfflineArray.count; i++)
    {
        NSMutableDictionary *hourlySalesOfflineDictionary = hourlySalesOfflineArray[i];
        
        NSPredicate *predicateForHourlySales = [NSPredicate predicateWithFormat:@"HourlyDateValue == %@",[hourlySalesOfflineDictionary  valueForKey:@"Hours"]];
        NSMutableArray *hourlyDetailDetailForPredicate = [[onlineHourlySalesArray filteredArrayUsingPredicate:predicateForHourlySales] mutableCopy];
        if (hourlyDetailDetailForPredicate.count > 0)
        {
            NSMutableDictionary * dictHourlySales = hourlyDetailDetailForPredicate.firstObject;
            CGFloat totalHourlyAmount = [[hourlySalesOfflineDictionary valueForKey:@"Amount"]floatValue] +
            [[dictHourlySales valueForKey:@"Amount"]floatValue];
            
            dictHourlySales[@"Amount"] = @(totalHourlyAmount);
            dictHourlySales[@"Cost"] = [dictHourlySales valueForKey:@"Cost"];
            dictHourlySales[@"Margin"] = [dictHourlySales valueForKey:@"Margin"];
            dictHourlySales[@"Count"] = @(hourlyDetailDetailForPredicate.count);
            dictHourlySales[@"Hours"] = [dictHourlySales valueForKey:@"Hours"];
        }
        else
        {
            NSMutableDictionary * dictHourlySales = [[NSMutableDictionary alloc]init];
            dictHourlySales[@"Amount"] = [hourlySalesOfflineDictionary valueForKey:@"Amount"];
            dictHourlySales[@"Cost"] = [hourlySalesOfflineDictionary valueForKey:@"Cost"];
            dictHourlySales[@"Margin"] = [hourlySalesOfflineDictionary valueForKey:@"Margin"];
            dictHourlySales[@"Count"] = @(hourlyDetailDetailForPredicate.count);
            dictHourlySales[@"Hours"] = [hourlySalesOfflineDictionary valueForKey:@"Hours"];
            [onlineHourlySalesArray addObject:dictHourlySales];
        }
    }
    
    NSMutableDictionary *zOnlineHourlyDictionary = onlineReportArray.firstObject;
    if (onlineHourlySalesArray == nil) {
        return;
    }
    zOnlineHourlyDictionary[@"RptHours"] = onlineHourlySalesArray;
}

#pragma mark - MoneyOrder calculation
-(void)updateMoneyOrderWithOfflineDetail
{
    NSMutableDictionary *zOnlineMainDictionary = [self onlineReportSummary];
    NSArray *itemDetailArray = [self fetchItemDetailFromInvoiceTable];
    itemDetailArray = [self removeIsdeductItemFromArray:itemDetailArray];
    NSNumber *itemTotalOfflineExtrachargeSum = 0;

    NSArray *isExtraChargeTrueArray = [self filterItemDetailArrayForExtraChargeItem:itemDetailArray];
    if (isExtraChargeTrueArray.count > 0)
    {
        if (isExtraChargeTrueArray.count > 0)
        {
            itemTotalOfflineExtrachargeSum = [isExtraChargeTrueArray valueForKeyPath:@"@sum.ExtraCharge"];
        }
    }
   
    CGFloat moneyOrderTotalOnlineAndOffline =
    [[zOnlineMainDictionary valueForKey:MONEYORDER] floatValue]
    + itemTotalOfflineExtrachargeSum.floatValue;
    
    zOnlineMainDictionary[MONEYORDER] = [NSNumber numberWithFloat:moneyOrderTotalOnlineAndOffline];
}


@end
