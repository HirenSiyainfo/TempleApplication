//
//  GiftCardCheckBalanceVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 29/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GiftCardCheckBalancePosDelegate <NSObject>

-(void)opneLoadGiftCard:(NSString *)strGiftCardNo;
-(void)didCancelCheckBalanceGiftCard;

@end

@interface GiftCardCheckBalanceVC : UIViewController
{
    IBOutlet UIView *uvManualTextField;
    IBOutlet UIButton *btnSubmit;
}
@property(nonatomic, weak)id <GiftCardCheckBalancePosDelegate>giftCardCheckBalancePosDelegate;

@property(nonatomic,strong)NSString *custName;
@property(nonatomic,strong)NSMutableDictionary *dictCustomerInfo;

@property(nonatomic,assign)BOOL isLoad;
@property(nonatomic,assign)BOOL isFromTender;
@property(nonatomic,assign)BOOL isRapidGiftCard;
@property(nonatomic,assign)BOOL isRefund;

@end
