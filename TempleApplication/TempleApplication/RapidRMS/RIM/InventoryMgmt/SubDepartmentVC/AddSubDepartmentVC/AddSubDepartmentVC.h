//
//  AddDepartmentVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 08/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddSubDepartmentVCDelegate <NSObject>

-(void)didAddedNewSubDepartment:(NSDictionary *)addedSubDepatmentDict;

@end

@interface AddSubDepartmentVC : UIViewController

@property (nonatomic, weak) id<AddSubDepartmentVCDelegate> addSubDepartmentVCDelegate;

@property (nonatomic, weak) IBOutlet UITableView *tblAddSubDepartment;

@property (nonatomic, strong) NSMutableDictionary *updateSubDepartmentDictionary;
@property (nonatomic, strong) NSMutableArray *arrDepartment;

-(void)selectImageCaptureForSubDepartment:(UIButton *)sender;

@end
