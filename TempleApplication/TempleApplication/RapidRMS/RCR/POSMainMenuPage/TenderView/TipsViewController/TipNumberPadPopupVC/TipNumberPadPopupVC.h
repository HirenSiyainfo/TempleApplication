//
//  popOverController.h
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TipsInputDelegate <NSObject>

-(void)didEnterTip:(CGFloat)tipValue;
-(void)didCancelTip;

@end

@interface TipNumberPadPopupVC : UIViewController
{
    
}

@property (nonatomic, weak) id inputControl;

@property (nonatomic, weak) id<TipsInputDelegate> tipsInputDelegate;

@end