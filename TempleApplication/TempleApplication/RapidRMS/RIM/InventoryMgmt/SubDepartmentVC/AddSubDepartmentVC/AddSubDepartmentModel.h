//
//  AddSubDepartmentModel.h
//  RapidRMS
//
//  Created by Siya9 on 21/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, SubDepartmentInfoCell)
{
    //    info
    SubDepartmentInfoCellName,
    SubDepartmentInfoCellCode,
    SubDepartmentInfoCellRemark,
//    SubDepartmentInfoCell,
//    SubDepartmentInfoCell,
//    SubDepartmentInfoCell,
};
@interface AddSubDepartmentModel : NSObject

@property (nonatomic, strong) NSString * strSubDeptName;
@property (nonatomic, strong) NSString * strSubDeptCode;
@property (nonatomic, strong) NSString * strSubRemarks;
@property (nonatomic) BOOL isNotDisplayInventory;
@property (nonatomic, strong) NSString * strDepartment;
@property (nonatomic, strong) NSString * strDepartmentID;

-(void)updateViewWithsubDepartmentDetail:(NSMutableDictionary *)subDepartmentDictionary;
@end
