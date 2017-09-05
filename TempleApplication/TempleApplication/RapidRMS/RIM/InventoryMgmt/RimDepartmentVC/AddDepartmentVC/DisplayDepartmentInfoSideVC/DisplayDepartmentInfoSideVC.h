//
//  ItemInfoViewController.h
//  RapidRMS
//
//  Created by siya-IOS5 on 04/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddDepartmentVC.h"


@interface DisplayDepartmentInfoSideVC : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *departmentInfoDictionary;
@property (nonatomic, weak) IBOutlet UITableView *tblDepartmentInfo;
@property (nonatomic, strong) AsyncImageView * deptImage;

@property (nonatomic, weak) AddDepartmentVC *objAddDepartment;

-(void)didUpdateDepatmentInfo:(NSDictionary *)updatedDepatmentInfo;

@end
