//
//  GiftCardPopUpVC.h
//  RapidRMS
//
//  Created by Siya on 19/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GiftCardPopUpDelegate <NSObject>

-(void)opengiftCardView:(BOOL)isload withRefund:(BOOL)isRefund;
@end


@interface GiftCardPopUpVC : UIViewController
{
    
}

@property(nonatomic, weak)id <GiftCardPopUpDelegate>giftCardPopUpDelegate;

@property(nonatomic,assign)BOOL isRefund;

@end
