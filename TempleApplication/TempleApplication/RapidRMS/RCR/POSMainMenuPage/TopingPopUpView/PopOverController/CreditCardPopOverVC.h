//
//  CreditCardPopOverVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/18/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CreditCardPopOverDelegate<NSObject>

-(void)didEnterCreditCardValue :(NSString *)value;
-(void)didCancelCreditcardPopOver;

@end

@interface CreditCardPopOverVC : UIViewController

@property (nonatomic, weak) id<CreditCardPopOverDelegate> creditCardPopOverDelegate;

@end
