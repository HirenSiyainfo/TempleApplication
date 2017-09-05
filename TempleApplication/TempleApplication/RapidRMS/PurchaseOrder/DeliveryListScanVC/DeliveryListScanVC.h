//
//  DeliveryListScanViewController.h
//  RapidRMS
//
//  Created by Siya on 26/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenListVC;
@class POMultipleItemSelectionVC;

@interface DeliveryListScanVC : UIViewController<UITextFieldDelegate,UpdateDelegate>

@property (nonatomic, strong) NSMutableArray * arrayDeliveryItemList;
@property (nonatomic, strong) OpenListVC * objOpenList;

@end
