//
//  HReceiveOrderItemInfo.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HReceiveOrderItemInfo : UIViewController<UpdateDelegate,UITextFieldDelegate>

@property (nonatomic, strong) VPurchaseOrderItem *vpurchaseOrderitem;

@property (nonatomic, strong) NSString *strPOID;
@property (nonatomic, strong) NSString *strItemId;

@property (nonatomic, strong) NSMutableDictionary *dictitemOrderInfo;

@end
