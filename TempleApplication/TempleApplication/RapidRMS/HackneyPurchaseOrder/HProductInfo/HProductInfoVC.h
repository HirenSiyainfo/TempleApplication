//
//  HProductInfoVC.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPurchaseOrderItem.h"
#import "HReceiveOrderItemListVC.h"

@interface HProductInfoVC : UIViewController<UpdateDelegate,UITextFieldDelegate>

@property (nonatomic, strong) VPurchaseOrderItem *vpurchaseOrderItem;

@property (nonatomic, strong) NSString *strPoId;

@property (nonatomic, assign) BOOL isfromItem;
@property (nonatomic, assign) BOOL isUpdate;

@property (nonatomic, strong) NSMutableDictionary *dictProductInfo;

@end
