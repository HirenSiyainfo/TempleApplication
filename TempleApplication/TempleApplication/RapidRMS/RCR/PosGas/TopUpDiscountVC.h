//
//  TopUpDiscountVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/5/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopUpDiscountDelegate<NSObject>

-(void)didAddTopupDiscountWithDiscountType :(NSString *)discountType withDiscountAmount:(NSString *)amount withItemDiscountType:(NSString *)itemDiscountType
                       selectedDiscountType:(NSString *)selectedDiscountType withItemDiscountID:(NSNumber *)discountId;
-(void)didRemoveTopupDiscount;
-(void)didCancelTopupDiscount;

@end

@interface TopUpDiscountVC : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<TopUpDiscountDelegate> topUpDiscountDelegate;

@end
