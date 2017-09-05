//
//  Department+Dictionary.m
//  POSRetail
//
//  Created by Siya Infotech on 14/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "Department+Dictionary.h"

@implementation Department (Dictionary)
-(NSDictionary *)departmentDictionary
{
    NSMutableDictionary *departmentDictionary=[[NSMutableDictionary alloc]init];
    departmentDictionary[@"itemId"] = self.itemcode;
    departmentDictionary[@"isAgeApply"] = self.isAgeApply;
    departmentDictionary[@"isCheckCash"] = self.chkCheckCash;
    departmentDictionary[@"isDeduct"] = self.deductChk;
    departmentDictionary[@"isExtraCharge"] = self.chkExtra;
    departmentDictionary[@"isTax"] = self.taxFlg;
    departmentDictionary[@"ApplyAgeDesc"] = self.applyAgeDesc;
    departmentDictionary[@"IsNotDisplayInventory"] = self.isNotDisplayInventory;
    return  departmentDictionary;
}

-(NSDictionary *)departmentLoadDictionary
{
    NSMutableDictionary *departmentDictionary=[[NSMutableDictionary alloc]init];
 //   [departmentDictionary setObject:self.itemcode forKey:@"itemId"];
    departmentDictionary[@"isAgeApply"] = self.isAgeApply;
    departmentDictionary[@"isCheckCash"] = self.chkCheckCash;
    departmentDictionary[@"isDeduct"] = self.deductChk;
    departmentDictionary[@"deptCode"] = self.deptCode;
    departmentDictionary[@"isExtra"] = self.chkExtra;
    departmentDictionary[@"isTax"] = self.taxFlg;
    departmentDictionary[@"ApplyAgeDesc"] = self.applyAgeDesc;
    departmentDictionary[@"ChargeAmount"] = self.chargeAmt;
    departmentDictionary[@"ChargeTyp"] = self.chargeTyp;
    departmentDictionary[@"CheckCashAmount"] = self.checkCashAmt;
    departmentDictionary[@"CheckCashType"] = self.checkCashType;
    departmentDictionary[@"DepartmentName"] = self.deptName;
    departmentDictionary[@"DeptId"] = self.deptId;
    departmentDictionary[@"DeptImage"] = self.imagePath;
    if (self.is_asItem != nil) {
        departmentDictionary[@"Is_asItem"] = self.is_asItem;
    }
    if (self.itemcode != nil) {
        departmentDictionary[@"Itemcode"] = self.itemcode;
    }
    departmentDictionary[@"Price"] = self.salesPrice;
    departmentDictionary[@"taxApplyIn"] = self.taxApplyIn;
    departmentDictionary[@"isPOS"] = self.isPOS;
    departmentDictionary[@"isNotApplyInItem"] = self.isNotApplyInItem;
    departmentDictionary[@"IsNotDisplayInventory"] = self.isNotDisplayInventory;
    return  departmentDictionary;
}

-(NSDictionary *)getdepartmentLoadDictionary
{
    NSMutableDictionary *departmentDictionary=[[NSMutableDictionary alloc]init];
    departmentDictionary[@"applyAgeDesc"] = self.applyAgeDesc;//
    departmentDictionary[@"chargeAmt"] = self.chargeAmt;//
    departmentDictionary[@"chargeTyp"] = self.chargeTyp;//
    departmentDictionary[@"checkCashAmt"] = self.checkCashAmt;
    departmentDictionary[@"checkCashType"] = self.checkCashType;//
    departmentDictionary[@"chkCheckCash"] = self.chkCheckCash;//
    departmentDictionary[@"chkExtra"] = self.chkExtra;//
    departmentDictionary[@"deductChk"] = self.deductChk;//
    departmentDictionary[@"deptCode"] = self.deptCode;//
    departmentDictionary[@"deptId"] = self.deptId;//
    departmentDictionary[@"deptTypeId"] = self.deptTypeId;//
    departmentDictionary[@"deptName"] = self.deptName;//
    departmentDictionary[@"imagePath"] = self.imagePath;//
    if (self.is_asItem != nil) {
        departmentDictionary[@"Is_asItem"] = self.is_asItem;//
    }
    if (self.itemcode != nil) {
        departmentDictionary[@"itemcode"] = self.itemcode;//
    }
    departmentDictionary[@"isAgeApply"] = self.isAgeApply;//
    departmentDictionary[@"isNotApplyInItem"] = self.isNotApplyInItem;//
    departmentDictionary[@"salesPrice"] = self.salesPrice;//
    departmentDictionary[@"taxApplyIn"] = self.taxApplyIn;
    departmentDictionary[@"taxFlg"] = self.taxFlg;
    departmentDictionary[@"isPOS"] = self.isPOS;
    departmentDictionary[@"ProfitMargin"] = self.profitMargin;
    departmentDictionary[@"IsNotDisplayInventory"] = self.isNotDisplayInventory;
    return  departmentDictionary;
}



-(void)updateDepartmentFromDictionary :(NSDictionary *)departmentDictionary
{
    self.applyAgeDesc = [departmentDictionary valueForKey:@"ApplyAgeDesc"];
    self.chargeAmt = @([[departmentDictionary valueForKey:@"ChargeAmt"] floatValue]);
    self.chargeTyp =[departmentDictionary valueForKey:@"ChargeTyp"];
    self.checkCashAmt =@([[departmentDictionary valueForKey:@"CheckCashAmt"] floatValue]);
    self.checkCashType = [departmentDictionary valueForKey:@"CheckCashType"];
    self.deptName = [departmentDictionary valueForKey:@"DeptName"] ;
    self.deptId = @([[departmentDictionary valueForKey:@"DeptId"] integerValue]);
    self.deptTypeId = @([departmentDictionary[@"DeptTypeId"] intValue]);
    self.imagePath = [departmentDictionary valueForKey:@"ImagePath"] ;
    self.is_asItem =[departmentDictionary valueForKey:@"Is_asItem"];
    self.itemcode = [departmentDictionary valueForKey:@"Itemcode"];
    self.salesPrice = @([[departmentDictionary valueForKey:@"SalesPrice"] floatValue]);
    self.isAgeApply = @([[departmentDictionary valueForKey:@"ChkApplyAge"] integerValue]);
    self.chkCheckCash=@([[departmentDictionary valueForKey:@"ChkCheckCash"] integerValue]);
    self.deductChk=@([[departmentDictionary valueForKey:@"DeductChk"] integerValue]);
    self.chkExtra=[departmentDictionary valueForKey:@"ChkExtra"];
    self.taxFlg=@([[departmentDictionary valueForKey:@"TaxFlg"] integerValue]);
    self.deptCode=[departmentDictionary valueForKey:@"DeptCode"];
    self.taxApplyIn=[departmentDictionary valueForKey:@"TaxApplyIn"];
    self.isNotApplyInItem=@([[departmentDictionary valueForKey:@"IsNotApplyInItem"] integerValue]);
    self.isPOS = @([[departmentDictionary valueForKey:@"IsPOS"] integerValue]);
    self.isNotDisplay = @([[departmentDictionary valueForKey:@"IsNotDisplay"] integerValue]);
    self.profitMargin = @([[departmentDictionary valueForKey:@"ProfitMargin"] floatValue]);
    self.isNotDisplayInventory = @([[departmentDictionary valueForKey:@"IsNotDisplayInventory"] integerValue]);
}
@end
