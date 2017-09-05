//
//  ICHomeVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 31/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemReconcileListVC : UIViewController


@property (nonatomic, strong) ItemInventoryCountSession *reConcileItemInvCountSession;

@property (nonatomic, strong) NSMutableDictionary *reconcileSessionDictionary;

@property (nonatomic) BOOL isViewOnly;
@property (nonatomic) BOOL isReconcileHistory;

@end