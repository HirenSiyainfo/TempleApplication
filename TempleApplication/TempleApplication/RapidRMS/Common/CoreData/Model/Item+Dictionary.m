//
//  Item+Dictionary.m
//  POSRetail
//
//  Created by Siya Infotech on 11/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "Mix_MatchDetail+Dictionary.h"
#import "GroupMaster+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "Item_Price_MD.h"
#import "SubDepartment+Dictionary.h"
#import "RestaurantItem+Dictionary.h"
#import "RmsDbController.h"

@implementation Item (Dictionary)
-(NSDictionary *)itemDictionary
{
    NSMutableDictionary *itemDict=[[NSMutableDictionary alloc]init];
    itemDict[@"ItemName"] = self.item_Desc;
  //  [itemDict setObject:self.item_Desc forKey:@"AddedQty"];
    itemDict[@"Barcode"] = self.barcode;
    itemDict[@"DepartId"] = self.deptId.stringValue;
    itemDict[@"ItemId"] = self.itemCode.stringValue;
    itemDict[@"ItemImage"] = self.item_ImagePath;
    itemDict[@"MaxStockLevel"] = self.item_MaxStockLevel.stringValue;
    itemDict[@"MinStockLevel"] = self.item_MinStockLevel.stringValue;
    itemDict[@"ProfitAmt"] = self.profit_Amt.stringValue;
    itemDict[@"ProfitType"] = self.profit_Type;
    itemDict[@"Remark"] = self.item_Remarks;
    itemDict[@"Price"] = self.salesPrice.stringValue;
    itemDict[@"CostPrice"] = self.costPrice.stringValue;
    itemDict[@"isTax"] = self.taxApply;
    itemDict[@"TaxType"] = self.taxType;
    itemDict[@"ItemNo"] = self.item_No;
    itemDict[@"ITMType"] = self.itm_Type;
    itemDict[@"availableQty"] = self.item_InStock.stringValue;
    itemDict[@"IsPriceAtPOS"] = self.isPriceAtPOS;
    itemDict[@"IsNotDisplayInventory"] = self.isNotDisplayInventory;
    itemDict[@"Cashier Note"] = [NSString stringWithFormat:@"%@",self.cashierNote];
    itemDict[@"AverageCost"] = self.averageCost.stringValue;
    itemDict[@"LastInvoice"] = self.lastInvoice;
    itemDict[@"LastReceivedDate"] = self.lastReceivedDate;

    return  itemDict;
}

-(NSDictionary *)itemRMSDictionary
{
    // Item Inventory RMS block
    
    //    AddedQty, Barcode, CostPrice, DepartId, DepartmentName, ItemDiscount = ();, ItemId, ItemImage
    //    ItemName, ItemSupplierData = ();, ItemTag = ( );, MaxStockLevel, MinStockLevel
    //    ProfitAmt, ProfitType, Remark, SalesPrice, avaibleQty
    
    NSMutableDictionary *itemDict=[[NSMutableDictionary alloc]init];
    // [itemDict setObject:self.item_Desc forKey:@"AddedQty"];
    itemDict[@"Barcode"] = self.barcode;
    itemDict[@"CostPrice"] = self.costPrice.stringValue;
    itemDict[@"DepartId"] = self.deptId.stringValue;
    itemDict[@"SubDeptId"] = self.subDeptId.stringValue;
    itemDict[@"CateId"] = self.catId;
    //    [itemDict setObject:self.departmentName forKey:@"DepartmentName"];
    itemDict[@"ItemId"] = self.itemCode.stringValue;
    itemDict[@"ItemImage"] = self.item_ImagePath;
    itemDict[@"ItemName"] = self.item_Desc;
    itemDict[@"MaxStockLevel"] = self.item_MaxStockLevel.stringValue;
    itemDict[@"MinStockLevel"] = self.item_MinStockLevel.stringValue;
    itemDict[@"ProfitAmt"] = self.profit_Amt.stringValue;
    itemDict[@"ProfitType"] = self.profit_Type;
    itemDict[@"Remark"] = self.item_Remarks;
    itemDict[@"SalesPrice"] = self.salesPrice.stringValue;
    itemDict[@"avaibleQty"] = self.item_InStock.stringValue;
    itemDict[@"ItemNo"] = self.item_No;
    
    itemDict[@"EBT"] = self.eBT;
    itemDict[@"Active"] = self.active;
    itemDict[@"IsFavourite"] = self.isFavourite;
    itemDict[@"isQtyDiscount"] = self.qty_Discount;
    itemDict[@"NoDiscountFlg"] = self.noDiscountFlg;
    
    if(self.mixMatchFlg != nil)
    {
        itemDict[@"mixMatchFlg"] = self.mixMatchFlg.stringValue ;
    }
    else
    {
        itemDict[@"mixMatchFlg"] = @"0";
    }
    itemDict[@"mixMatchId"] = self.mixMatchId.stringValue ;
    
    if(self.cate_MixMatchFlg != nil)
    {
        itemDict[@"cate_MixMatchFlg"] = self.cate_MixMatchFlg.stringValue ;
    }
    else
    {
        itemDict[@"cate_MixMatchFlg"] = @"0";
    }
    itemDict[@"cate_MixMatchId"] = self.cate_MixMatchId.stringValue ;
    
    if(self.pos_DISCOUNT)
    {
        itemDict[@"POSDISCOUNT"] = self.pos_DISCOUNT;
    }
    else
    {
        itemDict[@"POSDISCOUNT"] = @"0";
    }
    
    itemDict[@"TaxType"] = self.taxType;
    itemDict[@"isTax"] = self.taxApply;
    itemDict[@"ITM_Type"] = self.itm_Type;
    
    itemDict[@"CITM_Code"] = self.citm_Code.stringValue;
    itemDict[@"ChildQty"] = self.child_Qty.stringValue ;
    itemDict[@"IsPriceAtPOS"] = self.isPriceAtPOS;
    itemDict[@"IsNotDisplayInventory"] = self.isNotDisplayInventory;
    itemDict[@"Description"] = self.descriptionText;
    itemDict[@"CashierNote"] = self.cashierNote;
    itemDict[@"DisplayInPOS"] = self.isDisplayInPos;
    
    itemDict[@"WeightQty"] = self.weightqty.stringValue;
    itemDict[@"IsduplicateUPC"] = self.isDuplicateBarcodeAllowed.stringValue;
    
    if(self.weightype != nil)
    {
        itemDict[@"WeightType"] = self.weightype;
    }
    else
    {
        itemDict[@"WeightType"] = @"";
    }
    
    itemDict[@"PriceScale"] = self.pricescale;
    
    NSString *is_SelectedVal = @"0";
    if([self.is_Selected.stringValue isEqualToString:@""])
    {
        itemDict[@"selected"] = self.is_Selected.stringValue ;
    }
    else if([self.is_Selected.stringValue isEqualToString:@"1"])
    {
        itemDict[@"selected"] = self.is_Selected.stringValue ;
    }
    else
    {
        itemDict[@"selected"] = is_SelectedVal;
    }
     itemDict[@"AverageCost"] = self.averageCost.stringValue;
    
    itemDict[@"LastInvoice"] = self.lastInvoice;
    itemDict[@"lastSoldDate"] = self.lastSoldDate;
    itemDict[@"LastReceivedDate"] = self.lastReceivedDate;
    
    itemDict[@"orderStatus"] = self.orderStatus;
    
    itemDict[@"quantityManagementEnabled"] = self.quantityManagementEnabled;
    itemDict[@"isItemPayout"] = self.isItemPayout;
    itemDict[@"Memo"] = self.memo;
    return  itemDict;
}

#pragma First time Item insert

-(void)updateItemFromDictionary :(NSDictionary *)itemDictionary
{
    self.barcode = [itemDictionary valueForKey:@"Barcode"];
    self.deptId= @([[itemDictionary valueForKey:@"DeptId"] integerValue]);
    
//    int subDeptId = (arc4random() % 5) + 1;
//    self.subDeptId = @(subDeptId);
    self.subDeptId = @([[itemDictionary valueForKey:@"SubDeptId"] integerValue]);
    
    self.catId = @([[itemDictionary valueForKey:@"CatId"] integerValue]);
    self.itemCode = @([[itemDictionary valueForKey:@"ITEMCode"] integerValue]);
    self.item_ImagePath = [itemDictionary valueForKey:@"Item_ImagePath"];
    self.item_Desc = [itemDictionary valueForKey:@"ITEM_Desc"];
    self.sectionLabel=@"#";
    if(![[itemDictionary valueForKey:@"ITEM_Desc"] isEqualToString:@""]){
        
        NSString *strCh  = [[itemDictionary valueForKey:@"ITEM_Desc"] substringToIndex:1];
        
        NSCharacterSet* notDigits = [NSCharacterSet decimalDigitCharacterSet].invertedSet;
        if ([strCh rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            
            self.sectionLabel=@"#";
        }
        else
        {
            self.sectionLabel=strCh.uppercaseString;
        }
    }
    
    
    self.item_MaxStockLevel = @([[itemDictionary valueForKey:@"ITEM_MaxStockLevel"] integerValue]);
    self.item_MinStockLevel = @([[itemDictionary valueForKey:@"ITEM_MinStockLevel"] integerValue]);
    
    self.profit_Amt = @([[itemDictionary valueForKey:@"Profit_Amt"] floatValue]);
    self.profit_Type =[itemDictionary valueForKey:@"Profit_Type"];
    self.item_Remarks = [itemDictionary valueForKey:@"ITEM_Remarks"];
    self.salesPrice = @([[itemDictionary valueForKey:@"SalesPrice"] floatValue]);
    self.item_InStock = @([[itemDictionary valueForKey:@"ITEM_InStock"] integerValue]);
    self.pos_DISCOUNT=@([[itemDictionary valueForKey:@"POS_DISCOUNT"] integerValue]);
    self.taxApply=@([[itemDictionary valueForKey:@"TaxApply"] integerValue]);
    self.taxType=[itemDictionary valueForKey:@"TaxType"];
    self.perbox_Qty=@([[itemDictionary valueForKey:@"PERBOX_Qty"] integerValue]);
    
    self.noDiscountFlg=@([[itemDictionary valueForKey:@"NoDiscountFlg"] integerValue]);
    self.item_No=[itemDictionary valueForKey:@"ITEM_No"];
    self.itm_Type=[itemDictionary valueForKey:@"ITM_Type"];
    self.active=@([[itemDictionary valueForKey:@"Active"] integerValue]);
    self.branchId=@([[itemDictionary valueForKey:@"BranchId"] integerValue]);
    self.child_Qty=@([[itemDictionary valueForKey:@"Child_Qty"] integerValue]);
    self.citm_Code=@([[itemDictionary valueForKey:@"CITM_Code"] integerValue]);
    self.costPrice=@([[itemDictionary valueForKey:@"CostPrice"] floatValue]);
    
    self.dis_CalcItm=@([[itemDictionary valueForKey:@"Dis_CalcItm"] integerValue]);
    self.eBT=@([[itemDictionary valueForKey:@"EBT"] integerValue]);
    self.isPriceAtPOS =@([[itemDictionary valueForKey:@"IsPriceAtPOS"] integerValue]);
    self.isNotDisplayInventory =@([[itemDictionary valueForKey:@"IsNotDisplayInventory"] integerValue]);
    self.isDisplayInPos =@([[itemDictionary valueForKey:@"DisplayInPOS"] integerValue]);
    self.isDelete=@([[itemDictionary valueForKey:@"IsDeleted"] integerValue]);
    self.isFavourite=@([[itemDictionary valueForKey:@"IsFavourite"] integerValue]);
    self.item_Discount=@([[itemDictionary valueForKey:@"ITEM_Discount"] integerValue]);
    self.qty_Discount=@([[itemDictionary valueForKey:@"Qty_Discount"] integerValue]);
    self.descriptionText = [itemDictionary valueForKey:@"Description"];
    self.cashierNote = [itemDictionary valueForKey:@"CashierNote"];
    
    self.cate_MixMatchFlg = @([[itemDictionary valueForKey:@"Cate_MixMatchFlg"] integerValue]);
    self.cate_MixMatchId = @([[itemDictionary valueForKey:@"Cate_MixMatchId"] integerValue]);
    self.mixMatchId = @([[itemDictionary valueForKey:@"MixMatchId"] integerValue]);
    self.mixMatchFlg = @([[itemDictionary valueForKey:@"MixMatchFlg"] integerValue]);
    self.pricescale = [itemDictionary valueForKey:@"PriceScale"];
    self.weightype = [itemDictionary valueForKey:@"WeightType"];
    self.weightqty = @([[itemDictionary valueForKey:@"WeightQty"] floatValue]);    
    self.averageCost=@([[itemDictionary valueForKey:@"AvgCost"] floatValue]);
    self.isTicket = @([[itemDictionary valueForKey:@"IsTicket"] boolValue]);

    
    if([[itemDictionary valueForKey:@"LastInvoice"] isKindOfClass:[NSString class]])
    {
        self.lastInvoice=[itemDictionary valueForKey:@"LastInvoice"];
    }
    else{
        self.lastInvoice=@"";
    }

//    NSDate *lastReceivedDate;
//    if([[itemDictionary valueForKey:@"LastReceivedDate"] isKindOfClass:[NSString class]])
//    {
//         lastReceivedDate = [[itemDictionary valueForKey:@"LastReceivedDate"]getJSONDate];
//       
//    }
//    else{
//            lastReceivedDate = [NSDate date];
//
//    }
//    self.lastReceivedDate=lastReceivedDate;
    
    if ([itemDictionary objectForKey:@"OrderStatus"]) {
        self.orderStatus = [itemDictionary valueForKey:@"OrderStatus"];
    }

    if ([itemDictionary objectForKey:@"LastInvoiceDate"]) {
        self.lastSoldDate = [[RmsDbController sharedRmsDbController] getDateFromJSONDate:[itemDictionary objectForKey:@"LastInvoiceDate"]];
    }
    
    if([[itemDictionary valueForKey:@"LastReceivedDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.zzz";
        NSDate *currentDate = [dateFormatter dateFromString:[itemDictionary valueForKey:@"LastReceivedDate"]];
        self.lastReceivedDate = currentDate;
    }
    else  if([[itemDictionary valueForKey:@"LastReceivedDate"] isKindOfClass:[NSDate class]])
    {
        self.lastReceivedDate = [itemDictionary valueForKey:@"LastReceivedDate"];
    }
    
    self.isDuplicateBarcodeAllowed = @([[itemDictionary valueForKey:@"IsduplicateUPC"] integerValue]);

    if (self.cate_MixMatchId.integerValue != 0)
    {
        self.mixMatchId = self.cate_MixMatchId;
    }    
    self.isItemPayout = @([[itemDictionary valueForKey:@"isItemPayout"] integerValue]);
    self.quantityManagementEnabled = @([[itemDictionary valueForKey:@"quantityManagementEnabled"] integerValue]);
    self.memo = @([[itemDictionary valueForKey:@"Memo"] integerValue]);
}

-(void)updateItemFromRimDictionary :(NSDictionary *)itemDictionary
{
    if (itemDictionary[@"ItemId"]) {
        self.itemCode =@([[itemDictionary valueForKey:@"ItemId"] integerValue]);
    }
    
    if (itemDictionary[@"Barcode"]) {
        self.barcode = [itemDictionary valueForKey:@"Barcode"];
    }
//    self.item_ImagePath = [NSString stringWithFormat:@"%@",imageNameURL];
    
    if (itemDictionary[@"CostPrice"]) {
        self.costPrice=@([[itemDictionary valueForKey:@"CostPrice"] floatValue]);
    }
    
    if (itemDictionary[@"EBT"]) {
        self.eBT = @([[itemDictionary valueForKey:@"EBT"] integerValue]);
    }
    
    if (itemDictionary[@"ItemName"]) {
        self.item_Desc = [itemDictionary valueForKey:@"ItemName"];
    }
    
    if (itemDictionary[@"ItemNo"]) {
         self.item_No=[itemDictionary valueForKey:@"ItemNo"];
    }
    //self.  [itemDataDict valueForKey:@"isQtyDiscount"]
    
    if (itemDictionary[@"NoDiscountFlg"]) {
        self.noDiscountFlg = @([[itemDictionary valueForKey:@"NoDiscountFlg"] integerValue]);
    }
    
    if (itemDictionary[@"POSDISCOUNT"]) {
        self.pos_DISCOUNT = @([[itemDictionary valueForKey:@"POSDISCOUNT"] integerValue]);
    }
    
    if (itemDictionary[@"ProfitAmt"]) {
        self.profit_Amt = @([[itemDictionary valueForKey:@"ProfitAmt"] integerValue]);
    }
    
    if (itemDictionary[@"ProfitType"]) {
        self.profit_Type =[itemDictionary valueForKey:@"ProfitType"];
    }
    
    if (itemDictionary[@"availableQty"]) {
        self.item_InStock = @([[itemDictionary valueForKey:@"availableQty"] integerValue]);
    }
    
    if (itemDictionary[@"Remark"]) {
        self.item_Remarks = [itemDictionary valueForKey:@"Remark"];
    }
    
    if (itemDictionary[@"SalesPrice"]) {
        self.salesPrice = @([[itemDictionary valueForKey:@"SalesPrice"] floatValue]);
    }
    
    if (itemDictionary[@"TaxType"]) {
        self.taxType=[itemDictionary valueForKey:@"TaxType"];
    }
    
    if (itemDictionary[@"isTax"]) {
        self.taxApply=@([[itemDictionary valueForKey:@"isTax"] integerValue]);
    }
    
    if (itemDictionary[@"DepartId"]) {
        self.deptId= @([[itemDictionary valueForKey:@"DepartId"] integerValue]);
    }
    
    if (itemDictionary[@"MaxStockLevel"]) {
        self.item_MaxStockLevel = @([[itemDictionary valueForKey:@"MaxStockLevel"] integerValue]);
    }
    
    if (itemDictionary[@"MinStockLevel"]) {
        self.item_MinStockLevel = @([[itemDictionary valueForKey:@"MinStockLevel"] integerValue]);
    }
    
    if (itemDictionary[@"ITMType"]) {
        self.itm_Type=[itemDictionary valueForKey:@"ITMType"];
    }
}

-(void)updateItemFromUpdateDict :(NSDictionary *)updateDictionary
{
    self.barcode = [updateDictionary valueForKey:@"Barcode"];
    self.deptId= @([[updateDictionary valueForKey:@"DepartId"] integerValue]);
    self.itemCode =@([[updateDictionary valueForKey:@"ItemId"] integerValue]);
    self.item_ImagePath = [updateDictionary valueForKey:@"ItemImage"];
    self.item_Desc = [updateDictionary valueForKey:@"ItemName"];
    self.item_MaxStockLevel = @([[updateDictionary valueForKey:@"MaxStockLevel"] integerValue]);
    self.item_MinStockLevel = @([[updateDictionary valueForKey:@"MinStockLevel"] integerValue]);
    
    self.profit_Amt = @([[updateDictionary valueForKey:@"ProfitAmt"] integerValue]);
    self.profit_Type =[updateDictionary valueForKey:@"ProfitType"];
    self.item_Remarks = [updateDictionary valueForKey:@"Remark"];
    self.salesPrice = @([[updateDictionary valueForKey:@"Price"] floatValue]);
    self.item_InStock = @([[updateDictionary valueForKey:@"availableQty"] integerValue]);
    self.taxApply=@([[updateDictionary valueForKey:@"isTax"] integerValue]);
    self.taxType=[updateDictionary valueForKey:@"TaxType"];
    
    self.item_No=[updateDictionary valueForKey:@"ItemNo"];
    self.itm_Type=[updateDictionary valueForKey:@"ITMType"];
  
    self.costPrice=@([[updateDictionary valueForKey:@"CostPrice"] floatValue]);
}

-(void)linkToDepartment :(Department *)department
{
    Department *oldDepartment = self.itemDepartment;
    [oldDepartment removeDepartmentItemsObject:self];
    [department addDepartmentItemsObject:self];
    self.itemDepartment=department;
}

-(void)linkToSubDepartment :(SubDepartment *)subDepartment
{
    SubDepartment *oldSubDepartment = self.itemSubDepartment;
    if (oldSubDepartment != nil) {
     [oldSubDepartment removeSubDepartmentItemsObject:self];
    }
    [subDepartment addSubDepartmentItemsObject:self];
    self.itemSubDepartment = subDepartment;
    if(subDepartment != nil && self.itemDepartment != nil && self.itemSubDepartment != nil)
    {
        [self.itemDepartment addDepartmentSubDepartmentsObject:subDepartment];
        [self.itemSubDepartment addSubDepartmentDepartmentsObject:self.itemDepartment];
    }
}

-(void)linkToMixMatch :(Mix_MatchDetail *)mix_Match
{
    Mix_MatchDetail *Oldmix_Match = self.itemMixMatchDisc;
    [Oldmix_Match removeMixMatchDiscountObject:self];
    [mix_Match addMixMatchDiscountObject:self];
    self.itemMixMatchDisc=mix_Match;
}

-(void)linkToGroup :(GroupMaster *)groupMaster
{
    GroupMaster *OldgroupMaster = self.itemGroupMaster;
    [OldgroupMaster removeGroupMasterItemsObject:self];
    [groupMaster addGroupMasterItemsObject:self];
    self.itemGroupMaster=groupMaster;
}

-(void)linkToBarcode :(ItemBarCode_Md *)itemBarCode_Md
{
    [self addItemBarcodesObject:itemBarCode_Md];
    itemBarCode_Md.barcodeItem = self;
}

-(void)linkToBarcodes :(NSArray *)itemBarCode_Mds
{
    [self addItemBarcodes:[NSSet setWithArray:itemBarCode_Mds]];
    for (ItemBarCode_Md *itemBarCode_Md in itemBarCode_Mds) {
        itemBarCode_Md.barcodeItem = self;
    }
}
-(void)linkToPrice :(NSArray *)itemPrice_Mds
{
    NSSet *OldItem_Price_MD = self.itemToPriceMd;
    [self removeItemToPriceMd:OldItem_Price_MD];
    
    [self addItemToPriceMd:[NSSet setWithArray:itemPrice_Mds]];
    for (Item_Price_MD *itemPrice_Md in itemPrice_Mds) {
        itemPrice_Md.priceToItem = self;
    }
}

@end