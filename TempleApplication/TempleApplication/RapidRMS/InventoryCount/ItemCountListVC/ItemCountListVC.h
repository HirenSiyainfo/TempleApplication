//
//  ICHomeVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 31/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface ItemCountListVC : UIViewController

@property (nonatomic, strong) ItemInventoryCountSession *currentItemInventoryCountSession;

@property (nonatomic, strong) NSNumber *userSessionId;
@property (nonatomic, strong) NSDictionary *inventoryCountSessionDictionary;
@property (nonatomic) BOOL isRecallList;

@end