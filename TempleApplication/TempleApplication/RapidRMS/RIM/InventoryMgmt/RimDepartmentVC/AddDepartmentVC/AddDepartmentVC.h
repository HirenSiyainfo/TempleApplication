//
//  AddDepartmentVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 08/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddDepartmentVCDelegate <NSObject>

-(void)didAddedNewDepartment:(NSDictionary *)addedDepatmentDict;

@end

typedef NS_ENUM(NSInteger, DepartmentTags)
{
    DepartmentTagDeptType,
    DepartmentTagDoNotDispRIM,
    DepartmentTagAge,
    DepartmentTagPayout,
    DepartmentTagChargeType,
    DepartmentTagNotApplyItem,
    DepartmentTagTaxApplyIn,
    DepartmentTagDeptTax,
    DepartmentTagChackCash
};

@interface AddDepartmentVC : UIViewController

@property (nonatomic, weak) id<AddDepartmentVCDelegate> addDepartmentVCDelegate;

@property (nonatomic, strong) NSMutableDictionary *updateDepartmentDictioanry;

-(void)selectImageCaptureForDepartment:(UIButton *)sender;


@end
