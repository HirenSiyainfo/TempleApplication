//
//  PurchaseOrderFilterViewController.h
//  RapidRMS
//
//  Created by Siya on 13/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GenerateOrderView;
@class PurchaseOrderFilterListDetail;
@class ManualFilterOptionViewController;

@interface PurchaseOrderFilterVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) PurchaseOrderFilterListDetail *objPlist;

@property (nonatomic, strong) NSMutableArray *arrayDepartment;
@property (nonatomic, strong) NSMutableArray *arraySupplier;
@property (nonatomic, strong) NSMutableArray *arrmainPurchaseOrderList;

@end
