//
//  TipsAdjustmentVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 12/16/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TipsVC.h"

@protocol TipsAdjustmentVcDelegate <NSObject>

-(void)addTipAtPaymentTypeWithDetail:(NSDictionary *)tipCreditCardDictionary withTipAmount:(CGFloat )tipAmount;
-(void)didCancelAdjustTip;
-(void)didRemoveAdjustTip;

@end

@interface TipsAdjustmentVC :TipsVC<UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate>

@property(nonatomic,weak)id <TipsAdjustmentVcDelegate>tipsAdjustmentVcDelegate;

@property (nonatomic,strong) NSMutableArray *paymentTypeArray;

@end
