//
//  AddDepartmentModel.m
//  RapidRMS
//
//  Created by Siya9 on 05/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "AddDepartmentModel.h"

@implementation AddDepartmentModel


-(void)updateViewWithUpdateDetail:(NSMutableDictionary *)departmentDictionary
{
    if(departmentDictionary != nil)
    {
        self.strDeptName = [departmentDictionary valueForKey:@"deptName"];
        self.strDeptCode = [departmentDictionary valueForKey:@"deptCode"];
        self.strProfitMargin = [[departmentDictionary valueForKey:@"ProfitMargin"] stringValue];
        self.strCheckCashAmt = [NSString stringWithFormat:@"%@",[departmentDictionary valueForKey:@"checkCashAmt"]];
        self.strChargeAmt = [NSString stringWithFormat:@"%@",[departmentDictionary valueForKey:@"chargeAmt"]];
        
        self.strApplyAgeDesc = [departmentDictionary valueForKey:@"applyAgeDesc"];
        self.strCheckCashType = [departmentDictionary valueForKey:@"checkCashType"];
        self.strChargeTyp = [departmentDictionary valueForKey:@"chargeTyp"];
        self.strTaxApplyIn = [departmentDictionary valueForKey:@"taxApplyIn"];

        
        
        self.isNotDisplayInventory = [[departmentDictionary valueForKey:@"IsNotDisplayInventory"] boolValue];
        self.isChkApplyAge = [[departmentDictionary valueForKey:@"isAgeApply"] boolValue ];
        self.isChkCheckCash = [[departmentDictionary valueForKey:@"chkCheckCash"] boolValue ];
        self.isChkExtra = [[departmentDictionary valueForKey:@"chkExtra"] boolValue ];
        self.isNotApplyInItem = [[departmentDictionary valueForKey:@"isNotApplyInItem"] boolValue ];
        
        if([[departmentDictionary valueForKey:@"taxApplyIn"] length] > 0){
            if (![[departmentDictionary valueForKey:@"taxApplyIn"] isEqualToString:@"Select"]) {
                self.isTaxApplyIn = YES;
            }
            else{
                self.isTaxApplyIn = FALSE;
            }
        }
        else{
            self.isTaxApplyIn = NO;
        }
        
        if([[departmentDictionary valueForKey:@"taxFlg"] boolValue ]){
            self.isTaxFlg = YES;
        }
        else{
            self.isTaxFlg = NO;
        }
        
        self.isChkCheckCash = [[departmentDictionary valueForKey:@"chkCheckCash"] boolValue ];
        self.isDeductChk = [[departmentDictionary valueForKey:@"deductChk"] boolValue ];
        self.deptTypeId = [departmentDictionary[@"deptTypeId"] intValue];
    }
    else {
        self.deptTypeId = DepartmentTypeNone;
        self.isImageDeleted = FALSE;
        self.isDeductChk = NO;
        self.isChkCheckCash = NO;
        self.isChkExtra = NO;
        self.isNotApplyInItem = NO;
        self.isTaxApplyIn = NO;
        self.isTaxFlg = NO;
        
        self.strDeptName = @"";
        self.strDeptCode = @"";
        self.strProfitMargin = @"";
        self.strCheckCashAmt = @"";
        self.strChargeAmt = @"";
        
        self.strApplyAgeDesc = @"";
        self.strCheckCashType = @"";
        self.strChargeTyp = @"";
        self.strTaxApplyIn = @"";

        
    }
    if (self.strApplyAgeDesc.length == 0) {
        self.strApplyAgeDesc = @"Select";
    }
    if (self.strCheckCashType.length == 0) {
        self.strCheckCashType = @"Select";
    }
    if (self.strChargeTyp.length == 0) {
        self.strChargeTyp = @"Select";
    }
    if (self.strTaxApplyIn.length == 0) {
        self.strTaxApplyIn = @"Select";
    }
    if (self.strDepartmentTax.length == 0) {
        self.strDepartmentTax = @"Select";
    }
    if (self.strDepartmentTax.length == 0) {
        self.deptTypeId = 1;
    }
}
-(void)updateDepartmentType{
    self.isDeductChk = FALSE;
//    self.isChkCheckCash = FALSE;
    self.isChkExtra = FALSE;
    self.isNotApplyInItem = FALSE;
    self.isTaxApplyIn = FALSE;
    self.isTaxFlg = FALSE;
    self.isChkApplyAge = FALSE;
//    self.strCheckCashAmt = @"";
    self.strChargeAmt = @"";
    
    self.strApplyAgeDesc = @"Select";
    self.strCheckCashType = @"";
    self.strChargeTyp = @"";
    self.strTaxApplyIn = @"";
    if (self.isChkCheckCash) {
        self.isNotApplyInItem =TRUE;
    }
    if (self.strChargeTyp.length == 0) {
        self.strChargeTyp = @"Select";
    }
    if (self.strTaxApplyIn.length == 0) {
        self.strTaxApplyIn = @"Select";
    }
    [self.deptTaxArray removeAllObjects];
}

-(NSString *)getStringDepartmentType{
    switch (self.deptTypeId) {
        case DepartmentTypeNone:{
            return @"Default";
        }
        case DepartmentTypeMerchandise: {
            return @"Merchandise";
        }
        case DepartmentTypeLottery: {
            return @"Lottery";
        }
        case DepartmentTypeGas: {
            return @"Gas";
        }
        case DepartmentTypeMoneyOrder: {
            return @"Money Order";
        }
        case DepartmentTypeGiftCard: {
            return @"Gift Card";
        }
        case DepartmentTypeCheckCash: {
            return @"Check Cash";
        }
        case DepartmentTypeVendorPayout: {
            return @"Vendor Payout";
        }
        case DepartmentTypeHouseCharge: {
            return @"House Charge";
        }
        case DepartmentTypeOther:{
            return @"Other";
        }
    }
    return @"";
}
-(DepartmentType)getDeptIdFromString:(NSString *)strDeptType{
    if([strDeptType isEqualToString:@"Lottery"]){
        return DepartmentTypeLottery;
    }
    else if([strDeptType isEqualToString:@"Default"]){
        return DepartmentTypeNone;
    }
    else if([strDeptType isEqualToString:@"Gas"]){
        return DepartmentTypeGas;
    }
    else if([strDeptType isEqualToString:@"Money Order"]){
        return DepartmentTypeMoneyOrder;
    }
    else if([strDeptType isEqualToString:@"Gift Card"]){
        return DepartmentTypeGiftCard;
    }
    else if([strDeptType isEqualToString:@"Check Cash"]){
        return DepartmentTypeCheckCash;
    }
    else if([strDeptType isEqualToString:@"Vendor Payout"]){
        return DepartmentTypeVendorPayout;
    }
    else if([strDeptType isEqualToString:@"House Charge"]){
        return DepartmentTypeHouseCharge;
    }
    else if([strDeptType isEqualToString:@"Other"]){
        return DepartmentTypeOther;
    }
    return DepartmentTypeMerchandise;
}
@end
