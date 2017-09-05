//
//  TenderGiftCardProcessVC.h
//  RapidRMS
//
//  Created by Siya-ios5 on 12/1/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentData.h"

@protocol TenderGiftCardProcessVCDelegate <NSObject>

-(void)didFinishGiftCardProcess;
-(void)didFailGiftCardProcess;
-(void)didCancelGiftCardProcess;;

@end

@interface TenderGiftCardProcessVC : UIViewController

@property (nonatomic, strong) PaymentData *paymentGiftData;

@property(nonatomic,strong)NSMutableDictionary *dictCustomerInfo;
@property(nonatomic, weak)id <TenderGiftCardProcessVCDelegate>tenderGiftCardProcessVCDelegate;

@end
