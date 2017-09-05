//
//  ItemHistoryVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HistoryItemSoldCustomCell.h"
#import "Item_Price_MD+Dictionary.h"
#import "Item+Dictionary.h"
#import "ItemHistoryVC.h"
#import "RmsDbController.h"
#import "UITableView+AddBorder.h"


typedef NS_ENUM(NSInteger, HistorySectionItem)
{
    HistorySectionItemLastSoldInfo,
    HistorySectionItemLast5Invoice,
    HistorySectionItemSoldHistory,
    HistorySectionItemSoldQuarterly
};
@interface ItemHistoryVC ()<UITableViewDataSource,UITableViewDataSource>
{
    NSDictionary * dictItemInfo;
    NSArray * arrSectionInfo;
}
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) NSMutableArray *itemHistoryArray;
@property (nonatomic, strong) NSMutableArray *soldHistoryArray;
@property (nonatomic, strong) NSMutableArray *quarterlyArray;
@property (nonatomic, strong) NSArray *itemHistoryLastInvoice;

@property (nonatomic, strong) RapidWebServiceConnection * itemHistoryListWC;

@end

@implementation ItemHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.itemHistoryListWC = [[RapidWebServiceConnection alloc]init];
    [self setHistoryFieldsToArray];
    [self setDefualtValueToHistoryLabels];
    arrSectionInfo = [NSArray arrayWithObjects:@(HistorySectionItemLastSoldInfo),@(HistorySectionItemLast5Invoice),@(HistorySectionItemSoldHistory),@(HistorySectionItemSoldQuarterly),nil];
    [self getHistoryData];
    if (!self.itemQtyDict) {
        [self getPricingData];
    }
}

- (void)setHistoryFieldsToArray
{
    self.itemHistoryArray = [[NSMutableArray alloc] initWithObjects:
                             @"Last Cost",
                             @"Last Sold Price",
                             @"Last Qty before update",
                             @"Last Sold",nil ];
    self.soldHistoryArray = [[NSMutableArray alloc] initWithObjects:
                             @"Title",
                             @"Today",
                             @"Yesterday",
                             @"Weekly",
                             @"This Week",
                             @"Last Week",
                             @"Monthly",
                             @"This Month",
                             @"Last Month",
                             @"3 Month",
                             @"6 Month",
                             @"This Year",
                             @"Last Year",nil ];
    self.quarterlyArray = [[NSMutableArray alloc] initWithObjects:
                           @"Title",
                           @"Q1 (Jan - Mar)",
                           @"Q2 (Apr - Jun)",
                           @"Q3 (Jul - Sep)",
                           @"Q4 (Oct - Dec)",nil ];
    self.itemHistoryLastInvoice = [NSArray array];
}

#pragma mark - Get History Data

- (void)getHistoryData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *historyDict = [[NSMutableDictionary alloc] init];
    historyDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString * itemId = self.itemInfoDataObject.ItemId.stringValue;
    if (itemId.length>0) {
        historyDict[@"ItemCode"] = itemId;
    }
    else{
        historyDict[@"ItemCode"] = @"";
    }
    // New field added - LocalDate
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *LocalDate = [formatter stringFromDate:date];
    historyDict[@"LocalDate"] = LocalDate;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseHistoryData2Response:response error:error];
        });
    };
    
    self.itemHistoryListWC = [self.itemHistoryListWC initWithRequest:KURL actionName:WSM_INVOICE_ITEM_HISTORY_LIST params:historyDict completionHandler:completionHandler];
}

- (void)responseHistoryData2Response:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            NSMutableDictionary *dictHistoryData = responseArray.firstObject;
            
            NSMutableDictionary *dictHistoryDetail = ((NSArray *)dictHistoryData[@"ItemHistory"]).firstObject;
            dictItemInfo = [[NSDictionary alloc]initWithDictionary:dictHistoryDetail];
            self.itemHistoryLastInvoice = dictHistoryData[@"InvoiceHistory"];
        }
    }
    [self.tblHistory reloadData];
}

- (void)setDefualtValueToHistoryLabels
{
    NSMutableDictionary * dictItem = [NSMutableDictionary dictionary];
    dictItem[@"LastThreeMonth"] = @"0";
    dictItem[@"LastSixMonth"] = @"0";
    dictItem[@"LastCost"] = @"0";
    dictItem[@"LastWeekly"] = @"0";
    dictItem[@"Yearly"] = @"0";
    dictItem[@"LastSalesPrice"] = @"0";
    dictItem[@"LastQtyBeforeUpdate"] = @"0";
    dictItem[@"LastSellingDate"] = @"01-01-1900";
    dictItem[@"Today"] = @"0";
    dictItem[@"Yesterday"] = @"0";
    dictItem[@"thisWeek"] = @"0";
    dictItem[@"thismonth"] = @"0";
    dictItem[@"Lastmonth"] = @"0";
    dictItem[@"Lastyear"] = @"0";
    dictItem[@"Weekly"] = @"0";
    dictItem[@"Monthly"] = @"0";
    
    dictItem[@"Quarter1"] = @"0";
    dictItem[@"Quarter2"] = @"0";
    dictItem[@"Quarter3"] = @"0";
    dictItem[@"Quarter4"] = @"0";
    
    dictItemInfo =[[NSDictionary alloc]initWithDictionary:dictItem];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrSectionInfo.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return RIMHeaderHeight();
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 50;
//}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        if (indexPath.section > 0 && indexPath.row == 0) {
            [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:0];
        }
        else{
            [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath];
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    HistorySectionItem sectionInfo = (HistorySectionItem)[arrSectionInfo[section] intValue];
    NSInteger rows = 0;
    switch (sectionInfo) {
        case HistorySectionItemLastSoldInfo: {
            rows = self.itemHistoryArray.count;
            break;
        }
        case HistorySectionItemLast5Invoice: {
            rows = self.itemHistoryLastInvoice.count+1;
            break;
        }
        case HistorySectionItemSoldHistory: {
            rows = self.soldHistoryArray.count;
            break;
        }
        case HistorySectionItemSoldQuarterly: {
            rows = self.quarterlyArray.count;
            break;
        }
    }
    return rows;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HistorySectionItem sectionInfo = (HistorySectionItem)[arrSectionInfo[section] intValue];

    NSString * headerTitle = @"";
    switch (sectionInfo) {
        case HistorySectionItemLastSoldInfo: {
            headerTitle = @"ITEM HISTORY";
            break;
        }
        case HistorySectionItemLast5Invoice: {
            headerTitle = @"INVOICES";
            break;
        }
        case HistorySectionItemSoldHistory: {
            headerTitle = @"SOLD HISTORY";
            break;
        }
        case HistorySectionItemSoldQuarterly: {
            headerTitle = @"QUARTERLY";
            break;
        }
    }
    return [tableView defaultTableHeaderView:headerTitle];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 0 && indexPath.row == 0) {
        return 38;
    }
    else{
        return 55;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *historyCell;
    HistorySectionItem sectionInfo = (HistorySectionItem)[arrSectionInfo[indexPath.section] intValue];
    switch (sectionInfo) {
        case HistorySectionItemLastSoldInfo: {
            HistoryItemSoldCustomCell *historyCustomCell = (HistoryItemSoldCustomCell *)[self.tblHistory dequeueReusableCellWithIdentifier:@"LastSoldInfoCell"];
            
            historyCustomCell.lblTitle.text =  [NSString stringWithFormat:@"%@",(self.itemHistoryArray)[indexPath.row]].uppercaseString;
            switch (indexPath.row) {
                case 0:{
                    NSNumber * cost = dictItemInfo[@"LastCost"];
                    historyCustomCell.lblValue3.text = [NSString stringWithFormat:@"$ %.2f",cost.floatValue];
                    break;
                }
                case 1:{
                    NSNumber * price = dictItemInfo[@"LastSalesPrice"];
                    historyCustomCell.lblValue3.text = [NSString stringWithFormat:@"$ %.2f",price.floatValue];
                    break;
                }
                case 2:{
                    historyCustomCell.lblValue3.text = [NSString stringWithFormat:@"%@",dictItemInfo[@"LastQtyBeforeUpdate"]];
                    break;
                }
                case 3:{
                    historyCustomCell.lblValue3.text = [NSString stringWithFormat:@"%@",dictItemInfo[@"LastSellingDate"]];
                    break;
                }
            }
            historyCell = historyCustomCell;
            break;
        }
        case HistorySectionItemLast5Invoice: {
            HistoryItemSoldCustomCell *historyCustomCell;
            if (indexPath.row == 0) {
                historyCustomCell = [self.tblHistory dequeueReusableCellWithIdentifier:@"invoiceTitleCell"];
                if (self.itemHistoryLastInvoice.count == 0) {
                    historyCustomCell.lblTitle.text = @"No Invoice Found.";
                    historyCustomCell.lblValue1.text = @"";
                    historyCustomCell.lblValue2.text = @"";
                    historyCustomCell.lblValue3.text = @"";
                }
                else {
                    historyCustomCell.lblTitle.text = @"";
                    historyCustomCell.lblValue1.text = @"Invoice#".uppercaseString;
                    historyCustomCell.lblValue2.text = @"Quantity".uppercaseString;
                    historyCustomCell.lblValue3.text = @"Invoice Date".uppercaseString;
                }
            }
            else{
                historyCustomCell = (HistoryItemSoldCustomCell *)[self.tblHistory dequeueReusableCellWithIdentifier:@"LastInvoiceInfoCell"];
                historyCustomCell.lblTitle.text = @"";
                historyCustomCell.lblValue1.text = [NSString stringWithFormat:@"%@",self.itemHistoryLastInvoice[indexPath.row - 1][@"RegisterInvNo"]];
                historyCustomCell.lblValue2.text = [NSString stringWithFormat:@"%@",self.itemHistoryLastInvoice[indexPath.row - 1][@"ItemQty"]];
                
                NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                
                NSDate * date = [self.rmsDbController getDateFromJSONDate:self.itemHistoryLastInvoice[indexPath.row - 1][@"InvoiceDate"]];
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                formatter.timeZone = sourceTimeZone;
                formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
                historyCustomCell.lblValue3.text = [formatter stringFromDate:date];
            }
            historyCell = historyCustomCell;
            break;
        }
        case HistorySectionItemSoldHistory: {
            if (indexPath.row == 0) {
                historyCell = [self getTitleTableviewCell];
            }
            else{
                HistoryItemSoldCustomCell *historyItemSoldCell = (HistoryItemSoldCustomCell *)[self.tblHistory dequeueReusableCellWithIdentifier:@"LastSoldHistoryCell"];
                
                historyItemSoldCell.lblTitle.text = [NSString stringWithFormat:@"%@",(self.soldHistoryArray)[indexPath.row]].uppercaseString;
                
                switch (indexPath.row) {
                    case 1:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Today"]];
                        break;
                    case 2:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Yesterday"]];
                        break;
                    case 3:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Weekly"]];
                        break;
                    case 4:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"thisWeek"]];
                        break;
                    case 5:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"LastWeekly"]];
                        break;
                    case 6:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Monthly"]];
                        break;
                    case 7:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"thismonth"]];
                        break;
                    case 8:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Lastmonth"]];
                        break;
                    case 9:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"LastThreeMonth"]];
                        break;
                    case 10:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"LastSixMonth"]];
                        break;
                    case 11:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Yearly"]];
                        break;
                    case 12:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Lastyear"]];
                        break;
                }
                historyCell = historyItemSoldCell;
            }
            break;
        }
        case HistorySectionItemSoldQuarterly: {
            if (indexPath.row == 0) {
                historyCell = [self getTitleTableviewCell];
            }
            else{
                HistoryItemSoldCustomCell *historyItemSoldCell = (HistoryItemSoldCustomCell *)[self.tblHistory dequeueReusableCellWithIdentifier:@"LastSoldHistoryCell"];
                // HistoryQuarterly
                historyItemSoldCell.lblTitle.text = [NSString stringWithFormat:@"%@",(self.quarterlyArray)[indexPath.row]].uppercaseString;
                switch (indexPath.row) {
                    case 1:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Quarter1"]];
                        break;
                    case 2:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Quarter2"]];
                        break;
                    case 3:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Quarter3"]];
                        break;
                    case 4:
                        [self setHistoryItemSoldQty:historyItemSoldCell qtyDuration:dictItemInfo[@"Quarter4"]];
                        break;
                }
                historyCell = historyItemSoldCell;
            }
            break;
            
        }
    }
    historyCell.backgroundColor = [UIColor clearColor];
    historyCell.contentView.backgroundColor = [UIColor clearColor];
    return historyCell;
}
-(UITableViewCell *)getTitleTableviewCell{
    return (UITableViewCell *)[self.tblHistory dequeueReusableCellWithIdentifier:@"titleCell"];
}
- (void)setHistoryItemSoldQty:(HistoryItemSoldCustomCell *)historyItemSoldCell qtyDuration:(NSString *)qty
{
    historyItemSoldCell.lblValue1.text = [NSString stringWithFormat:@"%@",qty];
    NSString *strNumOfCase = [self.itemQtyDict valueForKey:@"NumOfCase"];
    NSString *strNumOfPack = [self.itemQtyDict valueForKey:@"NumOfPack"];

    if(![strNumOfCase isEqualToString: @""] && ![strNumOfCase isEqualToString: @"0"])
    {
        float result = qty.floatValue/strNumOfCase.floatValue;
        NSString *cq = [self getValueBeforeDecimal:result];
        NSInteger y = qty.integerValue % strNumOfCase.integerValue;
        y = labs(y);
        historyItemSoldCell.lblValue2.text = [NSString stringWithFormat:@"%@.%ld",cq,(long)y];
    }
    else
    {
        historyItemSoldCell.lblValue2.text = @"0.0";
    }
    
    if(![strNumOfPack isEqualToString: @""] && ![strNumOfPack isEqualToString: @"0"])
    {
        float result2 = qty.floatValue/strNumOfPack.floatValue;
        NSString *pq = [self getValueBeforeDecimal:result2];
        NSInteger x = qty.integerValue % strNumOfPack.integerValue;
        x = labs(x);
        historyItemSoldCell.lblValue3.text = [NSString stringWithFormat:@"%@.%ld",pq,(long)x];
    }
    else
    {
        historyItemSoldCell.lblValue3.text = @"0.0";
    }
}

- (NSString *)getValueBeforeDecimal:(float)result
{
    NSNumber *numberValue = @(result);
    NSString *floatString = numberValue.stringValue;
    NSArray *floatStringComps = [floatString componentsSeparatedByString:@"."];
    NSString *cq = [NSString stringWithFormat:@"%@",floatStringComps.firstObject];
    return cq;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GetCash pack -
-(void)getPricingData{

//    
//    NSManagedObjectContext *context = self.managedObjectContext;
    NSMutableArray * itemPriceInfo = [[NSMutableArray alloc]init];
    Item *anItem = [self fetchAllItems:self.itemInfoDataObject.ItemId.stringValue moc:self.managedObjectContext];

    for (Item_Price_MD *pricing in anItem.itemToPriceMd){
        NSMutableDictionary *pricingDict = [[NSMutableDictionary alloc]init];
        pricingDict[@"PriceQtyType"] = pricing.priceqtytype;
        pricingDict[@"Qty"] = pricing.qty;
        pricingDict[@"Cost"] = pricing.cost;
        pricingDict[@"Profit"] = pricing.profit;
        pricingDict[@"UnitPrice"] = pricing.unitPrice;
        pricingDict[@"PriceA"] = pricing.priceA;
        pricingDict[@"PriceB"] = pricing.priceB;
        pricingDict[@"PriceC"] = pricing.priceC;
        pricingDict[@"ApplyPrice"] = pricing.applyPrice;
        pricingDict[@"IsPackCaseAllow"] = pricing.isPackCaseAllow;
        pricingDict[@"UnitType"] = @"";
        pricingDict[@"UnitQty"] = @"0";
        [itemPriceInfo addObject:pricingDict];
    }
    itemPriceInfo = [self addPricingData:itemPriceInfo];
    if(itemPriceInfo.count < 3){
        NSArray *packageType = @[@"Single Item",@"Case",@"Pack"];
        NSMutableArray *priceQtyType = [itemPriceInfo valueForKey:@"PriceQtyType"];
        NSMutableArray *remainingPriceArray = [NSMutableArray arrayWithArray:packageType];
        [remainingPriceArray removeObjectsInArray:priceQtyType];
        
        NSMutableDictionary *pricingDictionary = [@{
                                                    @"PriceQtyType":@"",
                                                    @"Qty":@"0",
                                                    @"Cost":@"0.00",
                                                    @"Profit":@"0.00",
                                                    @"UnitPrice":@"0.00",
                                                    @"PriceA":@"0.00",
                                                    @"PriceB":@"0.00",
                                                    @"PriceC":@"0.00",
                                                    @"ApplyPrice":@"",
                                                    @"CreatedDate":@"",
                                                    @"IsPackCaseAllow":@"0",
                                                    @"UnitType":@"",
                                                    @"UnitQty":@"0",
                                                    } mutableCopy ];
        
        for (NSString *remPriceQtyType in remainingPriceArray){
            NSMutableDictionary *priceDict = [pricingDictionary mutableCopy];
            priceDict [@"PriceQtyType"] = remPriceQtyType;
            priceDict [@"ApplyPrice"] = @"UnitPrice";
            [itemPriceInfo addObject:priceDict];
        }
    }
    
    [itemPriceInfo sortUsingComparator:
     ^NSComparisonResult(id obj1, id obj2){
         
         NSDictionary *p1 = (NSDictionary *)obj1;
         NSDictionary *p2 = (NSDictionary *)obj2;
         
         int type1 = 10;
         int type2 = 10;
         
         type1 = [self qtyTypeForPricingDictionary:p1];
         type2 = [self qtyTypeForPricingDictionary:p2];
         
         if (type1 > type2) {
             return (NSComparisonResult)NSOrderedDescending;
         }
         if (type1 < type2) {
             return (NSComparisonResult)NSOrderedAscending;
         }
         return (NSComparisonResult)NSOrderedSame;
     }];
    self.itemQtyDict=@{@"NumOfCase": [NSString stringWithFormat:@"%@",itemPriceInfo[1][@"Qty"]],@"NumOfPack": [NSString stringWithFormat:@"%@",itemPriceInfo[2][@"Qty"]]};
}
-(NSMutableArray *)addPricingData:(NSMutableArray *)itemPricingArray {
    
    if(itemPricingArray.count > 3){
        
        NSMutableArray *itemPricingArrayTemp = [[NSMutableArray alloc]init];
        
        NSArray * arrayPricing = (NSArray *)itemPricingArray;
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Qty" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        arrayPricing = [(NSArray *)[arrayPricing sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
        
        // Check for Single Item Qty == 1
        
        NSPredicate *singlePredicate = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty == 1", @"Single Item"];
        NSArray *arraySingleItem = [arrayPricing filteredArrayUsingPredicate:singlePredicate];
        if(arraySingleItem.count>0){
            
            [itemPricingArrayTemp addObject:arraySingleItem.firstObject];
        }
        
        // Check for Single Item Qty > 1 then change to Case
        
        NSPredicate *singlePredicate1 = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty > 1", @"Single Item"];
        NSArray *arraySingleItem2 = [arrayPricing filteredArrayUsingPredicate:singlePredicate1];
        
        for (int i =0 ;i <arraySingleItem2.count;i++) {
            NSMutableDictionary *dictObject = arraySingleItem2[i];
            dictObject[@"PriceQtyType"] = @"Case";
        }
        
        // Predicate for Case and Qty > 1
        
        NSPredicate *casePredicate = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty > 1", @"Case"];
        NSArray *arrayCaseItem = [arrayPricing filteredArrayUsingPredicate:casePredicate];
        
        if(arrayCaseItem.count>0){
            
            [itemPricingArrayTemp addObject:arrayCaseItem.firstObject];
        }
        
        // Predicate for Case and Qty > 1
        
        NSPredicate *packPredicate = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty > 1", @"Pack"];
        NSArray *arrayPackItem = [arrayPricing filteredArrayUsingPredicate:packPredicate];
        
        if(arrayPackItem.count>0){
            
            [itemPricingArrayTemp addObject:arrayPackItem.firstObject];
        }
        return itemPricingArrayTemp;
    }
    else {
        return itemPricingArray;
    }
}
- (int)qtyTypeForPricingDictionary:(NSDictionary *)p1{
    int type = 10;
    if([p1[@"PriceQtyType"] isEqualToString:@"Single Item"] || [p1[@"PriceQtyType"] isEqualToString:@"SINGLE ITEM"] || [p1[@"PriceQtyType"] isEqualToString:@"Single item"]){
        type = 1;
    }
    else if([p1[@"PriceQtyType"] isEqualToString:@"Case"] || [p1[@"PriceQtyType"] isEqualToString:@"CASE"]){
        type = 2;
    }
    else if([p1[@"PriceQtyType"] isEqualToString:@"Pack"] || [p1[@"PriceQtyType"] isEqualToString:@"PACK"]){
        type = 3;
    }
    return type;
}
- (Item*)fetchAllItems :(NSString *)itemId moc:(NSManagedObjectContext *)moc{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    if (resultSet.count>0){
        item=resultSet.firstObject;
    }
    return item;
}
@end
