//
//  ItemInfoViewController.h
//  RapidRMS
//
//  Created by siya-IOS5 on 04/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddSubDepartmentVC.h"

@interface DisplaySubDepartmentInfoSideVC : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *subDepartmentInfoDictionary;
@property (nonatomic, weak) IBOutlet UITableView *tblSubDepartmentInfo;
@property (nonatomic, strong) AsyncImageView * subDeptImage;

@property (nonatomic, weak) AddSubDepartmentVC *objAddSubDepartmentVC;

-(void)didUpdateSubDepatmentInfo:(NSDictionary *)updatedSubDepatmentInfo;

@end
