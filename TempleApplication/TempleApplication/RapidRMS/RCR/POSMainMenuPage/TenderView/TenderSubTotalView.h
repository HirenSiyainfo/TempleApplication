//
//  TenderSubTotalView.h
//  RapidRMS
//
//  Created by siya-IOS5 on 12/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TenderSubTotalView : UIView



-(void)updateSubtotalViewWithBillAmount:(CGFloat )totalBillAmount withCollectedAmount:(CGFloat)collectedAmount withChangeDue:(CGFloat )changeDue withTipAmount:(CGFloat)tip ;
-(void)updateSubtotalViewWithTipAmount:(CGFloat )tipAmounts andWithCollectAmount:(CGFloat)collectedAmounts;

@end
