//
//  AddDepartmentModel.h
//  RapidRMS
//
//  Created by Siya9 on 05/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RmsDbController.h"

typedef NS_ENUM(NSInteger, DepartmentInfoCell)
{
//    info
    DepartmentInfoTabTypeRow,
    DepartmentInfoTabNameRow,
    DepartmentInfoTabCodeRow,
    DepartmentInfoTabProfitRow,
    DepartmentInfoTabNotApplyInItemRow,
    DepartmentInfoTabAgeRow,
    DepartmentInfoTabPayoutRow,
//    setting
    DepartmentSettingTabChequeCash,
    DepartmentSettingTabChargeType,
    DepartmentSettingTabNotApplyItem,
    DepartmentSettingTabTaxApplyIn,
    DepartmentSettingTabDepartmentTax
};

@interface AddDepartmentModel : NSObject

@property (nonatomic) DepartmentType deptTypeId;
@property (nonatomic, strong) NSString * strDeptName;
@property (nonatomic, strong) NSString * strDeptCode;
@property (nonatomic, strong) NSString * strProfitMargin;
@property (nonatomic, strong) NSString * strCheckCashAmt;
@property (nonatomic, strong) NSString * strChargeAmt;
@property (nonatomic, strong) NSString * strApplyAgeDesc;
@property (nonatomic, strong) NSString * strCheckCashType;
@property (nonatomic, strong) NSString * strChargeTyp;
@property (nonatomic, strong) NSString * strTaxApplyIn;
@property (nonatomic, strong) NSString * strDepartmentTax;


@property (nonatomic, strong) NSMutableArray *deptTaxArray;

@property (nonatomic) BOOL isUpdateDepartment;

@property (nonatomic) BOOL isNotDisplayInventory;
@property (nonatomic) BOOL isChkApplyAge;

@property (nonatomic) BOOL isImageSet;
@property (nonatomic) BOOL isImageDeleted;

@property (nonatomic) BOOL isDeductChk;
@property (nonatomic) BOOL isChkCheckCash;
@property (nonatomic) BOOL isChkExtra;
@property (nonatomic) BOOL isNotApplyInItem;
@property (nonatomic) BOOL isTaxApplyIn;
@property (nonatomic) BOOL isTaxFlg;


-(void)updateViewWithUpdateDetail:(NSMutableDictionary *)departmentDictionary;
-(void)updateDepartmentType;
-(NSString *)getStringDepartmentType;
-(DepartmentType)getDeptIdFromString:(NSString *)strDeptType;

@end
