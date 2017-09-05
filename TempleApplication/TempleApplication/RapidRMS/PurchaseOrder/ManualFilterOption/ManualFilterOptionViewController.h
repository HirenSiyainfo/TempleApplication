//
//  ManualFilterOptionViewController.h
//  RapidRMS
//
//  Created by Siya on 21/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PurchaseOrderFilterListDetail;
@class GenerateOrderView;

@interface ManualFilterOptionViewController : UIViewController

@property (nonatomic, strong) PurchaseOrderFilterListDetail *objPur;
@property (nonatomic, strong) GenerateOrderView *objGOrder;

@property (nonatomic, strong) NSMutableArray *arrayMainPurchaseOrderList;

@property (nonatomic, assign) BOOL manualOption;

@end
