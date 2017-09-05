//
//  ItemInfoDataObject.m
//  RapidRMS
//
//  Created by Siya Infotech on 06/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemInfoDataObject.h"

@implementation ItemInfoDataObject

#pragma mark - ItemMain -

-(void)setItemMainDataFrom:(NSDictionary *)dictItemMain{
    self.BlockActive = FALSE;
    if (dictItemMain) {
        self.Active = [[dictItemMain valueForKey:@"Active"] boolValue];
        self.oldActive = [[dictItemMain valueForKey:@"Active"] boolValue];
        if (dictItemMain[@"BlockActive"]) {
            self.BlockActive = [[dictItemMain valueForKey:@"BlockActive"] boolValue];
        }
        
        self.DisplayInPOS = [[dictItemMain valueForKey:@"DisplayInPOS"] boolValue];
        self.oldDisplayInPOS = [[dictItemMain valueForKey:@"DisplayInPOS"] boolValue];
        
        self.IsFavourite = [[dictItemMain valueForKey:@"IsFavourite"] boolValue];
        self.oldIsFavourite = [[dictItemMain valueForKey:@"IsFavourite"] boolValue];
        
        self.IsPriceAtPOS = [[dictItemMain valueForKey:@"IsPriceAtPOS"] boolValue];
        self.oldIsPriceAtPOS = [[dictItemMain valueForKey:@"IsPriceAtPOS"] boolValue];
        
        self.IsduplicateUPC = [[dictItemMain valueForKey:@"IsduplicateUPC"] boolValue];
        self.oldIsduplicateUPC = [[dictItemMain valueForKey:@"IsduplicateUPC"] boolValue];
        
        self.Memo = [[dictItemMain valueForKey:@"Memo"] boolValue];
        self.oldMemo = [[dictItemMain valueForKey:@"Memo"] boolValue];
        
        self.isItemPayout = [[dictItemMain valueForKey:@"isItemPayout"] boolValue];
        self.oldisItemPayout = [[dictItemMain valueForKey:@"isItemPayout"] boolValue];
        
        self.isQtyDiscount = [[dictItemMain valueForKey:@"isQtyDiscount"] boolValue];
        self.oldisQtyDiscount = [[dictItemMain valueForKey:@"isQtyDiscount"] boolValue];
        
        self.isTax = YES;
        self.oldisTax = YES;
        
//        self.isTax = [[dictItemMain valueForKey:@"isTax"] boolValue];
//        self.oldisTax = [[dictItemMain valueForKey:@"isTax"] boolValue];
        
        self.quantityManagementEnabled = [[dictItemMain valueForKey:@"quantityManagementEnabled"] boolValue];
        self.oldquantityManagementEnabled = [[dictItemMain valueForKey:@"quantityManagementEnabled"] boolValue];
        
        self.POSDISCOUNT = [[dictItemMain valueForKey:@"POSDISCOUNT"] boolValue];
        self.oldPOSDISCOUNT = [[dictItemMain valueForKey:@"POSDISCOUNT"] boolValue];
        
        //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.zzz"];
        //    self.LastReceivedDate= [dateFormatter dateFromString:[dictItemMain valueForKey:@"LastReceivedDate"]];
        //    self.oldLastReceivedDate= [dateFormatter dateFromString:[dictItemMain valueForKey:@"LastReceivedDate"]];
        //10
        self.AverageCost = @([[dictItemMain valueForKey:@"AverageCost"] floatValue]);
        self.oldAverageCost = @([[dictItemMain valueForKey:@"AverageCost"] floatValue]);
        
        self.Barcode = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"Barcode"]];
        self.oldBarcode = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"Barcode"]];
        
        self.CITM_Code = @([[dictItemMain valueForKey:@"CITM_Code"] integerValue]);
        self.oldCITM_Code = @([[dictItemMain valueForKey:@"CITM_Code"] integerValue]);
        
        self.CashierNote = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"CashierNote"]];
        self.oldCashierNote = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"CashierNote"]];
        
        self.CateId = @([[dictItemMain valueForKey:@"CateId"] integerValue]);
        self.oldCateId = @([[dictItemMain valueForKey:@"CateId"] integerValue]);
        
        self.ChildQty = @([[dictItemMain valueForKey:@"ChildQty"] integerValue]);
        self.oldChildQty = @([[dictItemMain valueForKey:@"ChildQty"] integerValue]);
        
        self.CostPrice = @([[dictItemMain valueForKey:@"CostPrice"] floatValue]);
        self.oldCostPrice = @([[dictItemMain valueForKey:@"CostPrice"] floatValue]);
        
        self.DepartId = @([[dictItemMain valueForKey:@"DepartId"] integerValue]);
        self.oldDepartId = @([[dictItemMain valueForKey:@"DepartId"] integerValue]);
        
        self.DepartmentName = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"DepartmentName"]];
        self.oldDepartmentName = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"DepartmentName"]];
        
        self.Description = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"Description"]];
        self.oldDescription = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"Description"]];
        
        self.EBT = @([[dictItemMain valueForKey:@"EBT"] integerValue]);
        self.oldEBT = @([[dictItemMain valueForKey:@"EBT"] integerValue]);
        
        self.GroupName = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"GroupName"]];
        self.oldGroupName = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"GroupName"]];
        
        self.ITM_Type = @([[dictItemMain valueForKey:@"ITM_Type"] integerValue]);
        self.oldITM_Type = @([[dictItemMain valueForKey:@"ITM_Type"] integerValue]);
        
        self.ItemId = @([[dictItemMain valueForKey:@"ItemId"] integerValue]);
        self.oldItemId = @([[dictItemMain valueForKey:@"ItemId"] integerValue]);
        
        self.ItemImage = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"ItemImage"]];
        self.oldItemImage = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"ItemImage"]];
        
        self.ItemName = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"ItemName"]];
        self.oldItemName = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"ItemName"]];
        
        self.ItemNo = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"ItemNo"]];
        self.oldItemNo = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"ItemNo"]];
        
        self.LastInvoice = @([[dictItemMain valueForKey:@"LastInvoice"] integerValue]);
        self.oldLastInvoice = @([[dictItemMain valueForKey:@"LastInvoice"] integerValue]);
        
        self.MaxStockLevel = @([[dictItemMain valueForKey:@"MaxStockLevel"] integerValue]);
        self.oldMaxStockLevel = @([[dictItemMain valueForKey:@"MaxStockLevel"] integerValue]);
        
        self.MinStockLevel = @([[dictItemMain valueForKey:@"MinStockLevel"] integerValue]);
        self.oldMinStockLevel = @([[dictItemMain valueForKey:@"MinStockLevel"] integerValue]);
        
        self.NoDiscountFlg = @([[dictItemMain valueForKey:@"NoDiscountFlg"] integerValue]);
        self.oldNoDiscountFlg = @([[dictItemMain valueForKey:@"NoDiscountFlg"] integerValue]);
        
        self.PriceScale = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"PriceScale"]];
        self.oldPriceScale = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"PriceScale"]];
        
        self.ProfitAmt = @([[dictItemMain valueForKey:@"ProfitAmt"] floatValue]);
        self.oldProfitAmt = @([[dictItemMain valueForKey:@"ProfitAmt"] floatValue]);
        
        self.ProfitType = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"ProfitType"]];
        self.oldProfitType = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"ProfitType"]];
        if ([self.ProfitType.lowercaseString isEqualToString:@"margin"]) {
            self.rowSwitch = TRUE;
        }
        self.Remark = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"Remark"]];
        self.oldRemark = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"Remark"]];
        
        self.SalesPrice = @([[dictItemMain valueForKey:@"SalesPrice"] floatValue]);
        self.oldSalesPrice = @([[dictItemMain valueForKey:@"SalesPrice"] floatValue]);
        
        self.SubDepartId = @([[dictItemMain valueForKey:@"SubDeptId"] integerValue]);
        self.oldSubDepartId = @([[dictItemMain valueForKey:@"SubDeptId"] integerValue]);
        
        self.SubDepartmentName = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"SubDepartmentName"]];
        self.oldSubDepartmentName = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"SubDepartmentName"]];
        
        if(dictItemMain[@"TaxType"]==nil || [[dictItemMain valueForKey:@"TaxType"] isEqualToString:@"0"]){
            self.TaxType = @"Department wise";
            self.oldTaxType = @"";
        }
        else if([[dictItemMain valueForKey:@"TaxType"] isEqualToString:@"1"]){
            self.TaxType = @"Tax wise";
            self.oldTaxType = @"";
        }
        else{
            self.TaxType = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"TaxType"]];
            self.oldTaxType = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"TaxType"]];
        }
        
        self.WeightQty = @([[dictItemMain valueForKey:@"WeightQty"] integerValue]);
        self.oldWeightQty = @([[dictItemMain valueForKey:@"WeightQty"] integerValue]);
        
        self.WeightType = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"WeightType"]];
        self.oldWeightType = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"WeightType"]];
        
        self.avaibleQty = @([[dictItemMain valueForKey:@"avaibleQty"] integerValue]);
        self.oldavaibleQty = @([[dictItemMain valueForKey:@"avaibleQty"] integerValue]);
        
        self.cate_MixMatchDiscription = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"cate_MixMatchDiscription"]];
        self.oldcate_MixMatchDiscription = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"cate_MixMatchDiscription"]];
        
        self.cate_MixMatchFlg = @([[dictItemMain valueForKey:@"cate_MixMatchFlg"] integerValue]);
        self.oldcate_MixMatchFlg = @([[dictItemMain valueForKey:@"cate_MixMatchFlg"] integerValue]);
        
        self.cate_MixMatchId = @([[dictItemMain valueForKey:@"cate_MixMatchId"] integerValue]);
        self.oldcate_MixMatchId = @([[dictItemMain valueForKey:@"cate_MixMatchId"] integerValue]);
        
        self.mixMatchDiscription = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"mixMatchDiscription"]];
        self.oldmixMatchDiscription = [NSString stringWithFormat:@"%@",[dictItemMain valueForKey:@"mixMatchDiscription"]];
        
        self.mixMatchFlg = @([[dictItemMain valueForKey:@"mixMatchFlg"] integerValue]);
        self.oldmixMatchFlg = @([[dictItemMain valueForKey:@"mixMatchFlg"] integerValue]);
        
        self.mixMatchId = @([[dictItemMain valueForKey:@"mixMatchId"] integerValue]);
        self.oldmixMatchId = @([[dictItemMain valueForKey:@"mixMatchId"] integerValue]);
        
        self.selected = @([[dictItemMain valueForKey:@"selected"] integerValue]);
        self.oldselected = @([[dictItemMain valueForKey:@"selected"] integerValue]);
    }
    else {
        self.Active = TRUE;
        self.oldActive = TRUE;
        
        self.DisplayInPOS = FALSE;
        self.oldDisplayInPOS = FALSE;
        
        self.IsFavourite = FALSE;
        self.oldIsFavourite = FALSE;
        
        self.IsPriceAtPOS = FALSE;
        self.oldIsPriceAtPOS = FALSE;
        
        self.IsduplicateUPC = FALSE;
        self.oldIsduplicateUPC = FALSE;
        
        self.Memo = FALSE;
        self.oldMemo = FALSE;
        
        self.isItemPayout = FALSE;
        self.oldisItemPayout = FALSE;
        
        self.isQtyDiscount = FALSE;
        self.oldisQtyDiscount = FALSE;
        
        self.isTax = FALSE;
        self.oldisTax = FALSE;
        
        self.quantityManagementEnabled = TRUE;
        self.oldquantityManagementEnabled = TRUE;
        
        self.POSDISCOUNT = FALSE;
        self.oldPOSDISCOUNT = FALSE;
        
        //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.zzz"];
        //    self.LastReceivedDate= [dateFormatter dateFromString:[dictItemMain valueForKey:@"LastReceivedDate"]];
        //    self.oldLastReceivedDate= [dateFormatter dateFromString:[dictItemMain valueForKey:@"LastReceivedDate"]];
        //10
        self.AverageCost = @0.0f;
        self.oldAverageCost = @0.0f;
        
        self.Barcode = @"";
        self.oldBarcode = @"";
        
        self.CITM_Code = @0;
        self.oldCITM_Code = @0;
        
        self.CashierNote = @"";
        self.oldCashierNote = @"";
        
        self.CateId = @0;
        self.oldCateId = @0;
        
        self.ChildQty = @0;
        self.oldChildQty = @0;
        
        self.CostPrice = @0.0f;
        self.oldCostPrice = @0.0f;
        
        self.DepartId = @0;
        self.oldDepartId = @0;
        
        self.DepartmentName = @"";
        self.oldDepartmentName = @"";
        
        self.Description = @"";
        self.oldDescription = @"";
        
        self.EBT = @0;
        self.oldEBT = @0;
        
        self.GroupName = @"";
        self.oldGroupName = @"";
        
        self.ITM_Type = @0;
        self.oldITM_Type = @0;
        
        self.ItemId = @0;
        self.oldItemId = @0;
        
        self.ItemImage = @"";
        self.oldItemImage = @"";
        
        self.ItemName = @"";
        self.oldItemName = @"";
        
        self.ItemNo = @"";
        self.oldItemNo = @"";
        
        self.LastInvoice = @0;
        self.oldLastInvoice = @0;
        
        self.MaxStockLevel = @0;
        self.oldMaxStockLevel = @0;
        
        self.MinStockLevel = @0;
        self.oldMinStockLevel = @0;
        
        self.NoDiscountFlg = @0;
        self.oldNoDiscountFlg = @0;
        
        self.PriceScale = @"";
        self.oldPriceScale = @"";
        
        self.ProfitAmt = @0.0f;
        self.oldProfitAmt = @0.0f;
        
        self.ProfitType = @"";
        self.oldProfitType = @"";
        
        self.Remark = @"";
        self.oldRemark = @"";
        
        self.SalesPrice = @0.0f;
        self.oldSalesPrice = @0.0f;
        
        self.SubDepartId = @0;
        self.oldSubDepartId = @0;
        
        self.SubDepartmentName = @"";
        self.oldSubDepartmentName = @"";
        
        self.TaxType = @"Department wise";
        self.oldTaxType = @"";
        
        self.WeightQty = @0;
        self.oldWeightQty = @0;
        
        self.WeightType = @"";
        self.oldWeightType = @"";
        
        self.avaibleQty = @0;
        self.oldavaibleQty = @0;
        
        self.cate_MixMatchDiscription = @"";
        self.oldcate_MixMatchDiscription = @"";
        
        self.cate_MixMatchFlg = @0;
        self.oldcate_MixMatchFlg = @0;
        
        self.cate_MixMatchId = @0;
        self.oldcate_MixMatchId = @0;
        
        self.mixMatchDiscription = @"";
        self.oldmixMatchDiscription = @"";
        
        self.mixMatchFlg = @0;
        self.oldmixMatchFlg = @0;
        
        self.mixMatchId = @0;
        self.oldmixMatchId = @0;
        
        self.selected = @0;
        self.oldselected = @0;
    }
}
-(NSMutableDictionary *)getItemMainUpdateData{
    NSMutableDictionary * dictItemMainData = [[NSMutableDictionary alloc]init];
    
    if (self.Active != self.oldActive || !self.BlockActive) {
        [self setBoolValuein:dictItemMainData boolObject:self.Active withKey:@"Active"];
    }
    
    if (self.DisplayInPOS != self.oldDisplayInPOS) {
        [self setBoolValuein:dictItemMainData boolObject:self.DisplayInPOS withKey:@"DisplayInPOS"];
    }
    
    if (self.IsFavourite != self.oldIsFavourite) {
        [self setBoolValuein:dictItemMainData boolObject:self.IsFavourite withKey:@"IsFavourite"];
    }
    
    if (self.IsPriceAtPOS != self.oldIsPriceAtPOS) {
        [self setBoolValuein:dictItemMainData boolObject:self.IsPriceAtPOS withKey:@"IsPriceAtPOS"];
    }
    
    //    if (self.IsduplicateUPC != self.oldIsduplicateUPC) {
    [self setBoolValuein:dictItemMainData boolObject:self.IsduplicateUPC withKey:@"IsduplicateUPC"];
    //    }
    
    if (self.Memo != self.oldMemo) {
        [self setBoolValuein:dictItemMainData boolObject:self.Memo withKey:@"Memo"];
    }
    
    if (self.isItemPayout != self.oldisItemPayout) {
        [self setBoolValuein:dictItemMainData boolObject:self.isItemPayout withKey:@"isItemPayout"];
        [self setBoolValuein:dictItemMainData boolObject:!self.isItemPayout withKey:@"TaxApply"];
    }
    
    
    if (self.isQtyDiscount != self.oldisQtyDiscount) {
        [self setBoolValuein:dictItemMainData boolObject:self.isQtyDiscount withKey:@"Qty_Discount"];
    }
    
//    if (self.isTax != self.oldisTax) {
//        [self setBoolValuein:dictItemMainData boolObject:self.isTax withKey:@"TaxApply"];
//    }
    
    if (self.quantityManagementEnabled != self.oldquantityManagementEnabled) {
        [self setBoolValuein:dictItemMainData boolObject:self.quantityManagementEnabled withKey:@"quantityManagementEnabled"];
    }
    
    if (self.POSDISCOUNT != self.oldPOSDISCOUNT) {
        [self setBoolValuein:dictItemMainData boolObject:self.POSDISCOUNT withKey:@"POS_DISCOUNT"];
    }
    
    if (self.LastReceivedDate !=nil && self.LastReceivedDate != self.oldLastReceivedDate) {
        dictItemMainData[@"LastReceivedDate"] = [NSString stringWithFormat:@"%@",self.LastReceivedDate];
    }
    
//    if (![self.AverageCost isEqualToNumber:self.oldAverageCost]) {
//        [dictItemMainData setObject:[NSString stringWithFormat:@"%@",self.AverageCost] forKey:@"AverageCost"];
//    }
    
    if (![self.Barcode isEqualToString:self.oldBarcode]) {
        dictItemMainData[@"Barcode"] = [NSString stringWithFormat:@"%@",self.Barcode];
    }
    
    if (![self.CITM_Code isEqualToNumber: self.oldCITM_Code]) {
        dictItemMainData[@"CITM_Code"] = [NSString stringWithFormat:@"%@",self.CITM_Code];
    }
    
    if (![self.CashierNote isEqualToString: self.oldCashierNote]) {
        dictItemMainData[@"CashierNote"] = [NSString stringWithFormat:@"%@",self.CashierNote];
    }
    
    if (![self.CateId isEqualToNumber:self.oldCateId]) {
        dictItemMainData[@"CatId"] = [NSString stringWithFormat:@"%@",self.CateId];
    }
    
    if (![self.ChildQty isEqualToNumber: self.oldChildQty]) {
        dictItemMainData[@"Child_Qty"] = [NSString stringWithFormat:@"%@",self.ChildQty];
    }
    
    if (![self.CostPrice isEqualToNumber:self.oldCostPrice]) {
        dictItemMainData[@"CostPrice"] = [NSString stringWithFormat:@"%@",self.CostPrice];
    }
    
    if (![self.DepartId isEqualToNumber: self.oldDepartId]) {
        dictItemMainData[@"DeptId"] = [NSString stringWithFormat:@"%@",self.DepartId];
    }
    
//    if (![self.DepartmentName isEqualToString:self.oldDepartmentName]) {
//        [dictItemMainData setObject:[NSString stringWithFormat:@"%@",self.DepartmentName] forKey:@"DepartmentName"];
//    }
    
    if (![self.Description isEqualToString: self.oldDescription]) {
        dictItemMainData[@"Description"] = [NSString stringWithFormat:@"%@",self.Description];
    }
    
    if (![self.EBT isEqualToNumber: self.oldEBT]) {
        dictItemMainData[@"EBT"] = [NSString stringWithFormat:@"%@",self.EBT];
    }
    
    if (![self.GroupName isEqualToString: self.oldGroupName]) {
        dictItemMainData[@"GroupName"] = [NSString stringWithFormat:@"%@",self.GroupName];
    }
    
//    if (![self.ITM_Type isEqualToNumber: self.oldITM_Type]) {
        dictItemMainData[@"itmtype"] = [NSString stringWithFormat:@"%@",self.ITM_Type];
//    }
    
    //    if (![self.ItemId isEqualToNumber:self.oldItemId]) {
    dictItemMainData[@"ItemId"] = [NSString stringWithFormat:@"%@",self.ItemId];
    //    }
    
//    if (![self.ItemImage isEqualToString: self.oldItemImage]) {
//        [dictItemMainData setObject:[NSString stringWithFormat:@"%@",self.ItemImage] forKey:@"ItemImage"];
//    }
    
    if (![self.ItemName isEqualToString:self.oldItemName]) {
        dictItemMainData[@"ITEM_Desc"] = [NSString stringWithFormat:@"%@",self.ItemName];
    }
    dictItemMainData[@"ItemName"] = [NSString stringWithFormat:@"%@",self.ItemName];
    if (![self.ItemNo isEqualToString:self.oldItemNo]) {
        dictItemMainData[@"Item_No"] = [NSString stringWithFormat:@"%@",self.ItemNo];
    }
    
    if (![self.LastInvoice isEqualToNumber:self.oldLastInvoice]) {
        dictItemMainData[@"LastInvoice"] = [NSString stringWithFormat:@"%@",self.LastInvoice];
    }
    
    if (![self.MaxStockLevel isEqualToNumber:self.oldMaxStockLevel]) {
        dictItemMainData[@"ITEM_MaxStockLevel"] = [NSString stringWithFormat:@"%@",self.MaxStockLevel];
    }
    
    if (![self.MinStockLevel isEqualToNumber: self.oldMinStockLevel]) {
        dictItemMainData[@"ITEM_MinStockLevel"] = [NSString stringWithFormat:@"%@",self.MinStockLevel];
    }
    
    if (![self.NoDiscountFlg isEqualToNumber: self.oldNoDiscountFlg]) {
        dictItemMainData[@"NoDiscountFlg"] = [NSString stringWithFormat:@"%@",self.NoDiscountFlg];
    }
    
    if (![self.PriceScale isEqualToString:self.oldPriceScale]) {
        dictItemMainData[@"PriceScale"] = [NSString stringWithFormat:@"%@",self.PriceScale];
    }
    
    if (![self.ProfitAmt isEqualToNumber:self.oldProfitAmt]) {
        dictItemMainData[@"Profit_Amt"] = [NSString stringWithFormat:@"%@",self.ProfitAmt];
    }
    
    if (![self.ProfitType isEqualToString:self.oldProfitType]) {
        dictItemMainData[@"Profit_Type"] = [NSString stringWithFormat:@"%@",self.ProfitType];
    }
    
    if (![self.Remark isEqualToString: self.oldRemark]) {
        dictItemMainData[@"Item_Remarks"] = [NSString stringWithFormat:@"%@",self.Remark];
    }
    
    if (![self.SalesPrice isEqualToNumber:self.oldSalesPrice]) {
        dictItemMainData[@"SalesPrice"] = [NSString stringWithFormat:@"%@",self.SalesPrice];
    }
    
    if (![self.SubDepartId isEqualToNumber: self.oldSubDepartId]) {
        dictItemMainData[@"SubDeptId"] = [NSString stringWithFormat:@"%@",self.SubDepartId];
    }
    
//    if (![self.SubDepartmentName isEqualToString: self.oldSubDepartmentName]) {
//        [dictItemMainData setObject:[NSString stringWithFormat:@"%@",self.SubDepartmentName] forKey:@"SubDepartmentName"];
//    }
    
    if (![self.TaxType isEqualToString:self.oldTaxType]) {
        dictItemMainData[@"TaxType"] = [NSString stringWithFormat:@"%@",self.TaxType];
    }
    
    if (![self.WeightQty isEqualToNumber:self.oldWeightQty]) {
        dictItemMainData[@"WeightQty"] = [NSString stringWithFormat:@"%@",self.WeightQty];
    }
    
    if (![self.WeightType isEqualToString:self.oldWeightType]) {
        dictItemMainData[@"WeightType"] = [NSString stringWithFormat:@"%@",self.WeightType];
    }
    
    if (![self.avaibleQty isEqualToNumber:self.oldavaibleQty]) {
        dictItemMainData[@"ITEM_InStock"] = [NSString stringWithFormat:@"%@",self.avaibleQty];
    }
    dictItemMainData[@"StokUpdateReason"] = @"OPN";
//    if (![self.cate_MixMatchDiscription isEqualToString:self.oldcate_MixMatchDiscription]) {
//        [dictItemMainData setObject:[NSString stringWithFormat:@"%@",self.cate_MixMatchDiscription] forKey:@"cate_MixMatchDiscription"];
//    }
    
    if (![self.cate_MixMatchFlg isEqualToNumber:self.oldcate_MixMatchFlg]) {
        dictItemMainData[@"cate_MixMatchFlg"] = [NSString stringWithFormat:@"%@",self.cate_MixMatchFlg];
    }
    
    if (![self.cate_MixMatchId isEqualToNumber: self.oldcate_MixMatchId]) {
        dictItemMainData[@"cate_MixMatchId"] = [NSString stringWithFormat:@"%@",self.cate_MixMatchId];
    }
    
//    if (![self.mixMatchDiscription isEqualToString:self.oldmixMatchDiscription]) {
//        [dictItemMainData setObject:[NSString stringWithFormat:@"%@",self.mixMatchDiscription] forKey:@"mixMatchDiscription"];
//    }
    
    if (![self.mixMatchFlg isEqualToNumber: self.oldmixMatchFlg]) {
        dictItemMainData[@"mixMatchFlg"] = [NSString stringWithFormat:@"%@",self.mixMatchFlg];
    }
    
    if (![self.mixMatchId isEqualToNumber: self.oldmixMatchId]) {
        dictItemMainData[@"mixMatchId"] = [NSString stringWithFormat:@"%@",self.mixMatchId];
    }
    
//    if (![self.selected isEqualToNumber:self.oldselected]) {
//        [dictItemMainData setObject:[NSString stringWithFormat:@"%@",self.selected] forKey:@"selected"];
//    }
    
    //    return dictItemMainData;
    //    NSArray * arrKeys = [dictItemMainData allKeys];
    //    NSMutableArray * arrItemMain = [[NSMutableArray alloc]init];
    //    for (NSString * strKey in arrKeys) {
    //        NSDictionary * dictInfo = @{strKey : [dictItemMainData valueForKey:strKey]};
    //        [arrItemMain addObject:dictInfo];
    //    }
    return dictItemMainData;
}
-(void)setBoolValuein:(NSMutableDictionary *)dictItemMain boolObject:(BOOL)setValue withKey:(NSString *)strKey{
    if (setValue) {
        dictItemMain[strKey] = @"1";
    }
    else {
        dictItemMain[strKey] = @"0";
    }
}
-(NSMutableDictionary *)getItemMainInsertData{
    NSMutableDictionary * dictItemMainData = [[NSMutableDictionary alloc]init];
    
    [self setBoolValuein:dictItemMainData boolObject:!self.Active withKey:@"inActive"];
    
    [self setBoolValuein:dictItemMainData boolObject:self.DisplayInPOS withKey:@"DisplayInPOS"];
    
    [self setBoolValuein:dictItemMainData boolObject:self.IsFavourite withKey:@"IsFavourite"];
    
    [self setBoolValuein:dictItemMainData boolObject:self.IsPriceAtPOS withKey:@"IsPriceAtPOS"];
    
    [self setBoolValuein:dictItemMainData boolObject:self.IsduplicateUPC withKey:@"IsduplicateUPC"];
    
    [self setBoolValuein:dictItemMainData boolObject:self.Memo withKey:@"Memo"];
    
    [self setBoolValuein:dictItemMainData boolObject:self.isItemPayout withKey:@"isItemPayout"];
    
    [self setBoolValuein:dictItemMainData boolObject:self.isQtyDiscount withKey:@"isQtyDiscount"];
    
//    [self setBoolValuein:dictItemMainData boolObject:self.isTax withKey:@"isTax"];
    
    [self setBoolValuein:dictItemMainData boolObject:self.quantityManagementEnabled withKey:@"quantityManagementEnabled"];

    if (self.LastReceivedDate !=nil) {
        dictItemMainData[@"LastReceivedDate"] = [NSString stringWithFormat:@"%@",self.LastReceivedDate];
    }
    else {
        dictItemMainData[@"LastReceivedDate"] = @"";
    }
    
    dictItemMainData[@"AverageCost"] = [NSString stringWithFormat:@"%@",self.AverageCost];
    
    dictItemMainData[@"Barcode"] = [NSString stringWithFormat:@"%@",self.Barcode];
    
    dictItemMainData[@"CITM_Code"] = [NSString stringWithFormat:@"%@",self.CITM_Code];
    
    dictItemMainData[@"CashierNote"] = [NSString stringWithFormat:@"%@",self.CashierNote];
    
    dictItemMainData[@"CateId"] = [NSString stringWithFormat:@"%@",self.CateId];
    
    dictItemMainData[@"ChildQty"] = [NSString stringWithFormat:@"%@",self.ChildQty];
    
    dictItemMainData[@"CostPrice"] = [NSString stringWithFormat:@"%f",self.CostPrice.floatValue];
    
    dictItemMainData[@"DepartId"] = [NSString stringWithFormat:@"%@",self.DepartId];
    
    dictItemMainData[@"DepartmentName"] = [NSString stringWithFormat:@"%@",self.DepartmentName];
    
    dictItemMainData[@"Description"] = [NSString stringWithFormat:@"%@",self.Description];
    
    dictItemMainData[@"EBT"] = [NSString stringWithFormat:@"%@",self.EBT];
    
    dictItemMainData[@"GroupName"] = [NSString stringWithFormat:@"%@",self.GroupName];
    
    dictItemMainData[@"ITMType"] = [NSString stringWithFormat:@"%@",self.ITM_Type];
    
    dictItemMainData[@"ItemId"] = [NSString stringWithFormat:@"%@",self.ItemId];
    if ([self.ItemImage isKindOfClass:[NSString class]]) {
        dictItemMainData[@"ItemImage"] = [NSString stringWithFormat:@"%@",self.ItemImage];
    }
    else {
        dictItemMainData[@"ItemImage"] = self.ItemImage;
    }
    
    dictItemMainData[@"ItemName"] = [NSString stringWithFormat:@"%@",self.ItemName];
    
    dictItemMainData[@"ItemNo"] = [NSString stringWithFormat:@"%@",self.ItemNo];
    
    dictItemMainData[@"LastInvoice"] = [NSString stringWithFormat:@"%@",self.LastInvoice];
    
    dictItemMainData[@"MaxStockLevel"] = [NSString stringWithFormat:@"%@",self.MaxStockLevel];
    
    dictItemMainData[@"MinStockLevel"] = [NSString stringWithFormat:@"%@",self.MinStockLevel];
    
    dictItemMainData[@"NoDiscountFlg"] = [NSString stringWithFormat:@"%@",self.NoDiscountFlg];
    
    [self setBoolValuein:dictItemMainData boolObject:self.POSDISCOUNT withKey:@"POSDISCOUNT"];
    
    dictItemMainData[@"PriceScale"] = [NSString stringWithFormat:@"%@",self.PriceScale];
    
    dictItemMainData[@"ProfitAmt"] = [NSString stringWithFormat:@"%f",self.ProfitAmt.floatValue];
    
    dictItemMainData[@"ProfitType"] = [NSString stringWithFormat:@"%@",self.ProfitType];
    
    dictItemMainData[@"Remark"] = [NSString stringWithFormat:@"%@",self.Remark];
    
    dictItemMainData[@"SalesPrice"] = [NSString stringWithFormat:@"%f",self.SalesPrice.floatValue];
    
    dictItemMainData[@"SubDeptId"] = [NSString stringWithFormat:@"%@",self.SubDepartId];
    
    dictItemMainData[@"SubDepartmentName"] = [NSString stringWithFormat:@"%@",self.SubDepartmentName];
    
    dictItemMainData[@"TaxType"] = [NSString stringWithFormat:@"%@",self.TaxType];
    
    dictItemMainData[@"WeightQty"] = [NSString stringWithFormat:@"%@",self.WeightQty];
    
    dictItemMainData[@"WeightType"] = [NSString stringWithFormat:@"%@",self.WeightType];
    
    dictItemMainData[@"availableQty"] = [NSString stringWithFormat:@"%@",self.avaibleQty];

    dictItemMainData[@"cate_MixMatchDiscription"] = [NSString stringWithFormat:@"%@",self.cate_MixMatchDiscription];
    
    dictItemMainData[@"cate_MixMatchFlg"] = [NSString stringWithFormat:@"%@",self.cate_MixMatchFlg];
    
    dictItemMainData[@"cate_MixMatchId"] = [NSString stringWithFormat:@"%@",self.cate_MixMatchId];
    
    dictItemMainData[@"mixMatchDiscription"] = [NSString stringWithFormat:@"%@",self.mixMatchDiscription];
    
    dictItemMainData[@"mixMatchFlg"] = [NSString stringWithFormat:@"%@",self.mixMatchFlg];
    
    dictItemMainData[@"mixMatchId"] = [NSString stringWithFormat:@"%@",self.mixMatchId];
    
    dictItemMainData[@"selected"] = [NSString stringWithFormat:@"%@",self.selected];
    
    if (self.isItemPayout) {
        dictItemMainData[@"isTax"] = @"0";
    }
    else {
        dictItemMainData[@"isTax"] = @"1";
    }
    
    return dictItemMainData;

}
//#pragma mark - new item -
//-(void)addsomeKeys:(NSMutableDictionary *) dictItemMain {
//    [dictItemMain setObject:@"0" forKey:@"lastCost"];
//    [dictItemMain setObject:@"0" forKey:@"lastsalePrice"];
//    [dictItemMain setObject:@"" forKey:@"selingDate"];
//    [dictItemMain setObject:@"0" forKey:@"lastWeek"];
//    [dictItemMain setObject:@"0" forKey:@"last3Week"];
//    [dictItemMain setObject:@"0" forKey:@"last6Week"];
//    [dictItemMain setObject:@"0" forKey:@"lastYear"];
//    
////    [itemDataDict setObject:[NSString stringWithFormat:@"%@",self.mixMatchFlg] forKey:@"MixMatchFlg"];
////    [itemDataDict setObject:[NSString stringWithFormat:@"%@",self.mixMatchId] forKey:@"MixMatchId"];
////    [itemDataDict setObject:[NSString stringWithFormat:@"%@",self.cate_MixMatchFlg] forKey:@"Cate_MixMatchFlg"];
////    [itemDataDict setObject:[NSString stringWithFormat:@"%@",self.cate_MixMatchId] forKey:@"Cate_MixMatchId"];
//}
#pragma mark - Item Ticket Info -

-(void)setItemTicketDataFrom:(NSDictionary *)dictItemTicket {
    if (dictItemTicket) {
        self.SelectedOption = [[dictItemTicket valueForKey:@"AllDays"] boolValue];
        self.oldSelectedOption = [[dictItemTicket valueForKey:@"AllDays"] boolValue];
        
        self.IsExpiration = [[dictItemTicket valueForKey:@"IsExpiration"] boolValue];
        self.oldIsExpiration = [[dictItemTicket valueForKey:@"IsExpiration"] boolValue];
        
        self.Sunday = [[dictItemTicket valueForKey:@"Sunday"] boolValue];
        self.oldSunday = [[dictItemTicket valueForKey:@"Sunday"] boolValue];
        
        self.Monday = [[dictItemTicket valueForKey:@"Monday"] boolValue];
        self.oldMonday = [[dictItemTicket valueForKey:@"Monday"] boolValue];
        
        self.Tuesday = [[dictItemTicket valueForKey:@"Tuesday"] boolValue];
        self.oldTuesday = [[dictItemTicket valueForKey:@"Tuesday"] boolValue];
        
        self.Wednesday = [[dictItemTicket valueForKey:@"Wednesday"] boolValue];
        self.oldWednesday = [[dictItemTicket valueForKey:@"Wednesday"] boolValue];
        
        self.Thursday = [[dictItemTicket valueForKey:@"Thursday"] boolValue];
        self.oldThursday = [[dictItemTicket valueForKey:@"Thursday"] boolValue];
        
        self.Friday = [[dictItemTicket valueForKey:@"Friday"] boolValue];
        self.oldFriday = [[dictItemTicket valueForKey:@"Friday"] boolValue];
        
        self.Saturday = [[dictItemTicket valueForKey:@"Saturday"] boolValue];
        self.oldSaturday = [[dictItemTicket valueForKey:@"Saturday"] boolValue];
        
        self.NoOfPerson = @([[dictItemTicket valueForKey:@"NoOfPerson"] integerValue]);
        self.oldNoOfPerson = @([[dictItemTicket valueForKey:@"NoOfPerson"] integerValue]);
        
        self.ExpirationDays = @([[dictItemTicket valueForKey:@"DaysofExpiry"] integerValue]);
        self.oldExpirationDays = @([[dictItemTicket valueForKey:@"DaysofExpiry"] integerValue]);
        
        self.NoOfdays = @([[dictItemTicket valueForKey:@"ValidDays"] integerValue]);
        self.oldNoOfdays = @([[dictItemTicket valueForKey:@"ValidDays"] integerValue]);
    }
    else {
        self.SelectedOption = FALSE;
        self.oldSelectedOption = FALSE;
        
        self.IsExpiration = FALSE;
        self.oldIsExpiration = FALSE;
        
        self.Sunday = FALSE;
        self.oldSunday = FALSE;
        
        self.Monday = FALSE;
        self.oldMonday = FALSE;
        
        self.Tuesday = FALSE;
        self.oldTuesday = FALSE;
        
        self.Wednesday = FALSE;
        self.oldWednesday = FALSE;
        
        self.Thursday = FALSE;
        self.oldThursday = FALSE;
        
        self.Friday = FALSE;
        self.oldFriday = FALSE;
        
        self.Saturday = FALSE;
        self.oldSaturday = FALSE;
        
        self.NoOfPerson = @0;
        self.oldNoOfPerson = @0;
        
        self.ExpirationDays = @0;
        self.oldExpirationDays = @0;
        
        self.NoOfdays = @0;
        self.oldNoOfdays = @0;
    }
}
-(NSMutableDictionary *)getItemTicketInfo{
    NSMutableDictionary * dictItemTicketData = [[NSMutableDictionary alloc]init];
    
    [self setBoolValuein:dictItemTicketData boolObject:self.SelectedOption withKey:@"SelectedOption"];

    [self setBoolValuein:dictItemTicketData boolObject:self.IsExpiration withKey:@"IsExpiration"];

    [self setBoolValuein:dictItemTicketData boolObject:self.Sunday withKey:@"Sunday"];

    [self setBoolValuein:dictItemTicketData boolObject:self.Monday withKey:@"Monday"];

    [self setBoolValuein:dictItemTicketData boolObject:self.Tuesday withKey:@"Tuesday"];

    [self setBoolValuein:dictItemTicketData boolObject:self.Wednesday withKey:@"Wednesday"];

    [self setBoolValuein:dictItemTicketData boolObject:self.Thursday withKey:@"Thursday"];

    [self setBoolValuein:dictItemTicketData boolObject:self.Friday withKey:@"Friday"];

    [self setBoolValuein:dictItemTicketData boolObject:self.Saturday withKey:@"Saturday"];

    dictItemTicketData[@"NoOfPerson"] = [NSString stringWithFormat:@"%@",self.NoOfPerson];

    dictItemTicketData[@"ExpirationDays"] = [NSString stringWithFormat:@"%@",self.ExpirationDays];

    dictItemTicketData[@"NoOfdays"] = [NSString stringWithFormat:@"%@",self.NoOfdays];

    return dictItemTicketData;
}
-(BOOL)isChangeItemTicketInfo{
    BOOL isChanged = FALSE;
    if (self.SelectedOption != self.oldSelectedOption) {
        isChanged = TRUE;
    }
    else if (self.IsExpiration != self.oldIsExpiration) {
        isChanged = TRUE;
    }
    else if (self.Sunday != self.oldSunday) {
        isChanged = TRUE;
    }
    else if (self.Monday != self.oldMonday) {
        isChanged = TRUE;
    }
    else if (self.Tuesday != self.oldTuesday) {
        isChanged = TRUE;
    }
    else if (self.Wednesday != self.oldWednesday) {
        isChanged = TRUE;
    }
    else if (self.Thursday != self.oldThursday) {
        isChanged = TRUE;
    }
    else if (self.Friday != self.oldFriday) {
        isChanged = TRUE;
    }
    else if (self.Saturday != self.oldSaturday) {
        isChanged = TRUE;
    }
    else if (![self.NoOfPerson isEqualToNumber:self.oldNoOfPerson]) {
        isChanged = TRUE;
    }
    else if (![self.ExpirationDays isEqualToNumber:self.oldExpirationDays]) {
        isChanged = TRUE;
    }
    else if (![self.NoOfdays isEqualToNumber:self.oldNoOfdays]) {
        isChanged = TRUE;
    }
    
    return isChanged;
}
#pragma mark - barcode -
-(void)createDuplicateItemBarcodeArray {
    self.oldarrItemAllBarcode = [self createDuplicateArrayFrom:self.arrItemAllBarcode];
}
-(NSString *)getDuplicateBarcodenumber{
    if (self.IsduplicateUPC) {
        return @"";
    }
    else{
        NSMutableArray * arrDuplicateBarcode = [NSMutableArray array];
        for (NSDictionary * dictItemBarcode in self.arrItemAllBarcode) {
            NSMutableArray * arrBarCodeTypes = [@[@"Single Item",@"Case",@"Pack"] mutableCopy];
            [arrBarCodeTypes removeObject:dictItemBarcode[@"PackageType"]];
            for (NSString * strBarcodeTypes in arrBarCodeTypes) {
                if ([self isBarcode:dictItemBarcode[@"Barcode"] Duplication:strBarcodeTypes]) {
                    [arrDuplicateBarcode addObject:dictItemBarcode[@"Barcode"]];
                    break;
                }
            }
        }
        if (arrDuplicateBarcode.count == 0) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isExist = %@",@"YES"];
            NSArray *isExist = [self.arrItemAllBarcode filteredArrayUsingPredicate:predicate];
            if(isExist.count > 0) {
                [arrDuplicateBarcode addObjectsFromArray:[isExist valueForKeyPath:@"@distinctUnionOfObjects.PackageType"]];
            }
        }
        NSSet * setBarcode = [[NSSet alloc]initWithArray:arrDuplicateBarcode];
        return [setBarcode.allObjects componentsJoinedByString:@", "];
    }
}

-(BOOL)isBarcode:(NSString *)strBarcode Duplication:(NSString *)barcodeType {
    NSPredicate *isBarcodePred;
    if (barcodeType) {
        isBarcodePred = [NSPredicate predicateWithFormat:@"PackageType == %@ AND Barcode == %@",barcodeType,strBarcode];
    }
    else{
        isBarcodePred = [NSPredicate predicateWithFormat:@"Barcode == %@",strBarcode];
    }
    NSArray * duplicate = [self.arrItemAllBarcode filteredArrayUsingPredicate:isBarcodePred];
    return (duplicate.count > 0)?TRUE:FALSE;
}

-(NSArray *)arrAddedBarcodeList{

    NSMutableArray * arrAddedBarcode = [self findAddedDictFromPredicatekey:@"Barcode" NewValue:self.arrItemAllBarcode withBackupCopy:self.oldarrItemAllBarcode];

    for (NSMutableDictionary * dictbarcodeInfo in arrAddedBarcode) {
        [dictbarcodeInfo removeObjectsForKeys:@[@"isExist",@"notAllowItemCode"]];
    }
    return arrAddedBarcode;
}
-(NSArray *)arrDeletedBarcodeList{
    

    NSMutableArray * arrDeletedBarcode = [self findDeletedDictFromPredicatekey:@"Barcode" NewValue:self.arrItemAllBarcode withBackupCopy:self.oldarrItemAllBarcode];
    for (NSMutableDictionary * dictbarcodeInfo in arrDeletedBarcode) {
        [dictbarcodeInfo removeObjectsForKeys:@[@"isExist",@"notAllowItemCode"]];
    }
    return arrDeletedBarcode;
}
-(NSMutableArray *)findAddedDictFromPredicatekey:(NSString *) strkey NewValue:(NSMutableArray *)arrNewValue withBackupCopy:(NSMutableArray *) arrBackUp{
    NSMutableArray * arrAddedDicts;
    NSMutableArray * arrPredicate = [NSMutableArray array];
    for (NSDictionary * dictBarcode in arrBackUp) {
       [arrPredicate addObject:[NSPredicate predicateWithFormat:@"NOT (Barcode == %@ AND PackageType == %@)",dictBarcode[@"Barcode"],dictBarcode[@"PackageType"]]];
    }
    if (arrBackUp && arrBackUp.count > 0) {
        NSPredicate *compoundpred = [NSCompoundPredicate andPredicateWithSubpredicates:arrPredicate];
        
        arrAddedDicts = [[arrNewValue filteredArrayUsingPredicate:compoundpred] mutableCopy];
    }
    else {
        arrAddedDicts = arrNewValue;
    }
    return [self createDuplicaArrayFrom:arrAddedDicts];
}
-(NSMutableArray *)findDeletedDictFromPredicatekey:(NSString *) strkey NewValue:(NSMutableArray *)arrNewValue withBackupCopy:(NSMutableArray *) arrBackUp{
    return [self findAddedDictFromPredicatekey:strkey NewValue:arrBackUp withBackupCopy:arrNewValue];
}
#pragma mark - Item pricing  -
-(void)createDuplicateItemPricingArray {
    
    self.olditemPricingArray = [self createDuplicateArrayFrom:self.itemPricingArray];
}

-(NSMutableArray *)getChangedItemPricingSingle{
    
    return [self FindChangedKeyChangeDict:self.itemPricingArray[0] withDictBackup:self.olditemPricingArray[0]];
}
-(NSMutableArray *)getChangedItemPricingCase{
    
    return [self FindChangedKeyChangeDict:self.itemPricingArray[1] withDictBackup:self.olditemPricingArray[1]];
}
-(NSMutableArray *)getChangedItemPricingPack{
    
    return [self FindChangedKeyChangeDict:self.itemPricingArray[2] withDictBackup:self.olditemPricingArray[2]];
}

-(NSMutableArray *)getChangedItemWeightScalePricingSingle{
    
    return [self FindChangedKeyChangeDict:self.itemWeightScaleArray[0] withDictBackup:self.olditemWeightScaleArray[0]];
}
-(NSMutableArray *)getChangedItemWeightScalePricingCase{
    
    return [self FindChangedKeyChangeDict:self.itemWeightScaleArray[1] withDictBackup:self.olditemWeightScaleArray[1]];
}
-(NSMutableArray *)getChangedItemWeightScalePricingPack{
    
    return [self FindChangedKeyChangeDict:self.itemWeightScaleArray[2] withDictBackup:self.olditemWeightScaleArray[2]];
}

-(void)createDuplicateItemWeightScaleArray {
    
    self.olditemWeightScaleArray = [self createDuplicateArrayFrom:self.itemWeightScaleArray];
}
-(NSMutableArray *)getChangedItemWeightScaleArray {
//    return [self changedValueFromChangedArray:self.itemWeightScaleArray withBackupCopy:self.olditemWeightScaleArray];
    return [[NSMutableArray alloc]init];
}

#pragma mark - Item Tax  -

-(void)createDuplicateItemTaxArray {
    
    self.olditemtaxarray = [self createDuplicateArrayFrom:self.itemtaxarray];
}

-(NSMutableArray *)getChangedItemAddedTaxArray{

    return [self findAddedValueFromNewValue:self.itemtaxarray withBackupCopy:self.olditemtaxarray];
}
-(NSString *)getChangedItemDeletedTaxArray{

    NSMutableArray * arrDeletedTax = [self findDeletedValueFromNewValue:self.itemtaxarray withBackupCopy:self.olditemtaxarray];
    NSArray * arrTaxids = [arrDeletedTax valueForKeyPath:@"TaxId"];
    NSString * strTaxIds = [arrTaxids componentsJoinedByString:@","];
    return strTaxIds;
}

#pragma mark - Item Supplier  -


-(void)createDuplicateItemSupplierarray{
    if (self.olditemsupplierarray==nil) {
        self.olditemsupplierarray = [[NSMutableArray alloc] init];
    }
    else {
        [self.olditemsupplierarray removeAllObjects];
    }
    for (NSMutableDictionary * dictPriceInfo in self.itemsupplierarray) {
        NSMutableDictionary * dpriceInfo = [[NSMutableDictionary alloc]initWithDictionary:dictPriceInfo];
        NSMutableArray * arrSalsripesentatives = [[NSMutableArray alloc]initWithArray:dictPriceInfo[@"SalesRepresentatives"]];
        dpriceInfo[@"SalesRepresentatives"] = arrSalsripesentatives;
        [self.olditemsupplierarray addObject:dpriceInfo];
    }
}

-(NSMutableArray *)getChangedItemAddedSupplierarray {
    
    return [self changedInSupplierarrayNewObject:self.itemsupplierarray witholdobject:self.olditemsupplierarray];
}

-(NSMutableArray *)getChangedItemDeletedSupplierarray {
    
    return [self changedInSupplierarrayNewObject:self.olditemsupplierarray witholdobject:self.itemsupplierarray];
}

-(NSMutableArray *)changedInSupplierarrayNewObject:(NSMutableArray *)arrNewGlobleObjec witholdobject:(NSMutableArray *) arrOldGlobleObject{
    NSMutableArray * arrPriceValueReturn = [[NSMutableArray alloc] init];
    for (NSMutableDictionary * dictPriceInfo in arrNewGlobleObjec) {
        
        NSMutableDictionary * dictNewInfo =[[NSMutableDictionary alloc]initWithDictionary:dictPriceInfo];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"VendorId == %d",[dictNewInfo[@"VendorId"] intValue]];
        NSArray * arrtest = [arrOldGlobleObject filteredArrayUsingPredicate:predicate];
        if (arrtest.count > 0) {
            NSDictionary * backUpdict = arrtest.firstObject;
            NSMutableArray * arrOld = [[NSMutableArray alloc]initWithArray:backUpdict[@"SalesRepresentatives"]];
            NSMutableArray * arrChanged = [[NSMutableArray alloc]initWithArray:dictNewInfo[@"SalesRepresentatives"]];
            [self addSupplierarray:arrPriceValueReturn NewObject:arrChanged witholdobject:arrOld];
        }
        else {
            NSMutableArray * arrChanged = [[NSMutableArray alloc]initWithArray:dictNewInfo[@"SalesRepresentatives"]];
            if (arrChanged.count > 0) {
                NSMutableArray * arrOld = [[NSMutableArray alloc]init];
                [self addSupplierarray:arrPriceValueReturn NewObject:arrChanged witholdobject:arrOld];
            }
            else{
                [dictNewInfo removeObjectsForKeys:@[@"CompanyName",@"ContactNo",@"Email",@"ItemCode",@"SalesRepresentatives"]];
                dictNewInfo[@"Id"] = @(0);
                [arrPriceValueReturn addObject:dictNewInfo];

            }
        }
    }
    return arrPriceValueReturn;
}
-(void)addSupplierarray:(NSMutableArray *)arrPriceValueReturn NewObject:(NSMutableArray *)arrChanged witholdobject:(NSMutableArray *) arrOld{
    
    for (NSMutableDictionary * dictPriceInfo in arrChanged) {
        if (![arrOld containsObject:dictPriceInfo]) {
            NSMutableDictionary * dictAdded = [[NSMutableDictionary alloc]initWithDictionary:dictPriceInfo];
            [dictAdded removeObjectsForKeys:@[@"CompanyName",@"ContactNo",@"Email",@"FirstName",@"Position"]];
            [arrPriceValueReturn addObject:dictAdded];
        }
    }
}
#pragma mark - Item Tag  -

-(void)createDuplicateItemresponseTagArray {

    self.oldresponseTagArray = [self createDuplicateArrayFrom:self.responseTagArray];
}

-(NSMutableArray *)getChangedItemAddedTagArray{

    return [self findAddedValueFromNewValue:self.responseTagArray withBackupCopy:self.oldresponseTagArray];
}
-(NSString *)getChangedItemDeletedTagArray{
    NSMutableArray * arrDeletedTag = [self findDeletedValueFromNewValue:self.responseTagArray withBackupCopy:self.oldresponseTagArray];
    NSArray * arrTagids = [arrDeletedTag valueForKeyPath:@"SizeId"];
    NSString * strTagIds = [arrTagids componentsJoinedByString:@","];
    return strTagIds;
}

#pragma mark - Item Discount  -

-(void)createDuplicateItemDiscountDetailsArray {

    self.olddiscountDetailsArray = [self createDuplicateArrayFrom:self.discountDetailsArray];
}

-(NSMutableArray *)getChangedItemAddedDiscountDetailsArray {

    NSMutableArray * discountList =  [self findAddedValueFromNewValue:self.discountDetailsArray withBackupCopy:self.olddiscountDetailsArray];
    NSMutableArray * discountData = [[NSMutableArray alloc]init];
    if(discountList.count > 0) {
        for(int isDisc=0; isDisc<discountList.count;isDisc++) {
            NSMutableDictionary *discountDictionary = discountList[isDisc];
            NSString *newRowId = [NSString stringWithFormat:@"%d",isDisc];
            [discountDictionary removeObjectForKey:@"UnitPriceWithTax"];
            [discountDictionary removeObjectForKey:@"applyTax"];
            NSNumber *disUnitPrice = [discountDictionary valueForKey:@"DIS_UnitPrice"];
            NSNumber *disQty = [discountDictionary valueForKey:@"DIS_Qty"];
            if(disUnitPrice != nil && disQty != nil ) {
                [discountDictionary setValue:newRowId forKeyPath:@"RowId"];
                [discountData addObject:discountDictionary];
            }
        }
    }
    return discountData;
}
-(NSString *)getChangedItemDeletedDiscountDetailsArray {

    NSMutableArray * arrDeletedTax = [self findDeletedValueFromNewValue:self.discountDetailsArray withBackupCopy:self.olddiscountDetailsArray];
    NSArray * arrTaxids = [arrDeletedTax valueForKeyPath:@"DiscountId"];
    NSString * strTaxIds = [arrTaxids componentsJoinedByString:@","];
    return strTaxIds;
}
-(NSMutableArray *)createDuplicaArrayFrom:(NSMutableArray *) arrList{
    NSMutableArray * arrPriceValue = [[NSMutableArray alloc] init];
    for (NSMutableDictionary * dictPriceInfo in arrList) {
        NSMutableDictionary * needToChanged = [[NSMutableDictionary alloc]initWithDictionary:dictPriceInfo];
        [arrPriceValue addObject:needToChanged];
    }
    return arrPriceValue;
}

#pragma mark - Create Duplicate, Added, Deleted Value -

-(NSMutableArray *)createDuplicateArrayFrom:(NSMutableArray *)arrChenged{

    NSMutableArray * arrBackup = [[NSMutableArray alloc] init];

    for (NSMutableDictionary * dictPriceInfo in arrChenged) {
        NSMutableDictionary * dpriceInfo = [[NSMutableDictionary alloc]initWithDictionary:dictPriceInfo];
        [arrBackup addObject:dpriceInfo];
    }
    return arrBackup;
}

-(NSMutableArray *)findAddedValueFromNewValue:(NSMutableArray *)arrNewValue withBackupCopy:(NSMutableArray *) arrBackUp{
    NSMutableArray * arrChangedValue = [[NSMutableArray alloc] init];
    for (NSMutableDictionary * dictPriceInfo in arrNewValue) {
        if (![arrBackUp containsObject:dictPriceInfo]) {
            [arrChangedValue addObject:dictPriceInfo];
        }
    }
    return arrChangedValue;
}

-(NSMutableArray *)findDeletedValueFromNewValue:(NSMutableArray *)arrNewValue withBackupCopy:(NSMutableArray *) arrBackUp{
    return [self findAddedValueFromNewValue:arrBackUp withBackupCopy:arrNewValue];
}
#pragma mark - ManualItem ItemUpdate -
-(BOOL)isChangeInfoInManualItem {
    BOOL isChanged = FALSE;
    if (self.IsduplicateUPC != self.oldIsduplicateUPC) {
        isChanged = TRUE;
    }
    else if (![self.ItemName isEqualToString:self.oldItemName]) {
        isChanged = TRUE;
    }
    else if (![self.ItemNo isEqualToString:self.oldItemNo]) {
        isChanged = TRUE;
    }
    else if (self.arrDeletedBarcodeList.count > 0|| self.arrDeletedBarcodeList.count > 0){
        isChanged = TRUE;
    }
    
    else if ([(self.itemPricingArray[0])[@"Cost"] floatValue] != [(self.olditemPricingArray[0])[@"Cost"] floatValue]){
        isChanged = TRUE;
    }
    else if ([(self.itemPricingArray[0])[@"UnitPrice"] floatValue] != [(self.olditemPricingArray[0])[@"UnitPrice"] floatValue]){
        isChanged = TRUE;
    }
    else if ([(self.itemPricingArray[0])[@"Qty"] floatValue] != [(self.olditemPricingArray[0])[@"Qty"] floatValue]){
        isChanged = TRUE;
    }

    else if ([(self.itemPricingArray[1])[@"Cost"] floatValue] != [(self.olditemPricingArray[1])[@"Cost"] floatValue]){
        isChanged = TRUE;
    }
    else if ([(self.itemPricingArray[1])[@"UnitPrice"] floatValue] != [(self.olditemPricingArray[1])[@"UnitPrice"] floatValue]){
        isChanged = TRUE;
    }
    else if ([(self.itemPricingArray[1])[@"Qty"] floatValue] != [(self.olditemPricingArray[1])[@"Qty"] floatValue]){
        isChanged = TRUE;
    }

    else if ([(self.itemPricingArray[2])[@"Cost"] floatValue] != [(self.olditemPricingArray[2])[@"Cost"] floatValue]){
        isChanged = TRUE;
    }
    else if ([(self.itemPricingArray[2])[@"UnitPrice"] floatValue] != [(self.olditemPricingArray[2])[@"UnitPrice"] floatValue]){
        isChanged = TRUE;
    }
    else if ([(self.itemPricingArray[2])[@"Qty"] floatValue] != [(self.olditemPricingArray[2])[@"Qty"] floatValue]){
        isChanged = TRUE;
    }
    else if (![self.ProfitType isEqualToString:self.oldProfitType]){
        isChanged = TRUE;
    }
    else if (self.arrAddedBarcodeList.count > 0 || self.arrDeletedBarcodeList.count > 0){
        isChanged = TRUE;
    }
    return isChanged;
}

-(NSMutableDictionary *)itemInfoDataForManual {
    NSMutableDictionary * dictItemMainData = [[NSMutableDictionary alloc]init];
    
    [self setBoolValuein:dictItemMainData boolObject:self.IsduplicateUPC withKey:@"IsduplicateUPC"];
    
    dictItemMainData[@"ItemId"] = [NSString stringWithFormat:@"%@",self.ItemId];
    
    dictItemMainData[@"ItemName"] = self.ItemName;
    
    if (![self.ItemNo isEqualToString:self.oldItemNo]) {
        dictItemMainData[@"Item_No"] = [NSString stringWithFormat:@"%@",self.ItemNo];
    }
    
    if (![self.Barcode isEqualToString:self.oldBarcode]) {
        dictItemMainData[@"Barcode"] = [NSString stringWithFormat:@"%@",self.Barcode];
    }
    if (![self.CostPrice isEqualToNumber:self.oldCostPrice]) {
        dictItemMainData[@"CostPrice"] = [NSString stringWithFormat:@"%@",self.CostPrice];
    }
    if (![self.PriceScale isEqualToString:self.oldPriceScale]) {
        dictItemMainData[@"PriceScale"] = [NSString stringWithFormat:@"%@",self.PriceScale];
    }
    
    if (![self.ProfitAmt isEqualToNumber:self.oldProfitAmt]) {
        dictItemMainData[@"Profit_Amt"] = [NSString stringWithFormat:@"%@",self.ProfitAmt];
    }
    
    if (![self.ProfitType isEqualToString:self.oldProfitType]) {
        dictItemMainData[@"Profit_Type"] = [NSString stringWithFormat:@"%@",self.ProfitType];
    }
    if (![self.SalesPrice isEqualToNumber:self.oldSalesPrice]) {
        dictItemMainData[@"SalesPrice"] = [NSString stringWithFormat:@"%@",self.SalesPrice];
    }
    
    return dictItemMainData;
}

-(NSMutableArray *)getManualPricingDataAt:(int)index {
    return [self ManualFindChangedKeyChangeDict:self.itemPricingArray[index] withDictBackup:self.olditemPricingArray[index]];
}

#pragma mark - Arrary Changed Finder -

-(NSMutableArray *)ManualFindChangedKeyChangeDict:(NSMutableDictionary *) dictChange withDictBackup:(NSMutableDictionary *) dictBackup{
    NSMutableArray * arrChangeKeyValueArray = [[NSMutableArray alloc]init];
    NSArray * strKeys = dictChange.allKeys;
    for (NSString * strKey in strKeys) {
        id changedValue = dictChange[strKey];
        
        if ([changedValue isKindOfClass:[NSString class]]) {
            NSString * strChangedV = dictChange[strKey];
            NSString * strOldV = dictBackup[strKey];
            if (![strChangedV isEqualToString:strOldV]) {
                NSDictionary * dictKeyChanged = @{strKey : strChangedV};
                [arrChangeKeyValueArray addObject:dictKeyChanged];
            }
        }
        else if ([changedValue isKindOfClass:[NSNumber class]]) {
            NSNumber * numChangedV = @([dictChange[strKey] floatValue]);
            NSNumber * numOldV = @([dictBackup[strKey] floatValue]);
            if (![numChangedV isEqualToNumber:numOldV]) {
                NSDictionary * dictKeyChanged = @{strKey : numChangedV.stringValue};
                [arrChangeKeyValueArray addObject:dictKeyChanged];
            }
        }
        else {
            
        }
    }
    NSMutableArray * arrMSinglePriceInfo = [[NSMutableArray alloc]init];
    for (NSMutableDictionary * dictPriceInfo in arrChangeKeyValueArray) {
        NSArray * arrKeys = dictPriceInfo.allKeys;
        for (NSString * strKey in arrKeys) {
            if (![strKey isEqualToString:@"ReceivedQty"]) {
                [arrMSinglePriceInfo addObject:@{@"Key":strKey,@"Value":[dictPriceInfo valueForKey:strKey]}];
            }
        }
    }
    
    return arrMSinglePriceInfo;
}

-(NSMutableArray *)FindChangedKeyChangeDict:(NSMutableDictionary *) dictChange withDictBackup:(NSMutableDictionary *) dictBackup {
    NSMutableArray * arrChangeKeyValueArray = [[NSMutableArray alloc]init];
    NSArray * strKeys = dictChange.allKeys;
    for (NSString * strKey in strKeys) {
        id newValue = dictChange[strKey];
        id oldValue = dictBackup[strKey];
        if (![self isSameValues:newValue with:oldValue]) {
            NSDictionary * dictKeyChanged = @{strKey : newValue};
            [arrChangeKeyValueArray addObject:dictKeyChanged];
        }
    }
    NSMutableArray * arrMSinglePriceInfo = [[NSMutableArray alloc]init];
    for (NSMutableDictionary * dictPriceInfo in arrChangeKeyValueArray) {
        NSArray * arrKeys = dictPriceInfo.allKeys;
        for (NSString * strKey in arrKeys) {
            [arrMSinglePriceInfo addObject:@{@"Key":strKey,@"Value":[dictPriceInfo valueForKey:strKey]}];
        }
    }
    
    return arrMSinglePriceInfo;
}
-(BOOL)isSameValues:(id)value1 with:(id)value2 {
    BOOL isSame = FALSE;
    if ([value1 isKindOfClass:[NSString class]] && [value2 isKindOfClass:[NSString class]]) {
        NSString * strValue1 = value1;
        NSString * strValue2 = value2;
        if ([strValue1 isEqualToString:strValue2]) {
            isSame = TRUE;
        }
    }
    else {
        NSNumber * numValue1 = @([value1 floatValue]);
        NSNumber * numValue2 = @([value2 floatValue]);

        if ([numValue1 isEqualToNumber:numValue2]) {
            isSame = TRUE;
        }
    }
    return isSame;
}
@end
