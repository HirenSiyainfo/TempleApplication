//
//  HoldTransactionVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/5/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HoldTransactionDelegate<NSObject>

-(void)didHoldTransactionWithHoldMessage :(NSString *)message;
-(void)didCancelHoldTransaction;

@end

@interface HoldTransactionVC : UIViewController

@property (nonatomic, weak) id<HoldTransactionDelegate> holdTransactionDelegate;

@property (nonatomic, weak) NSString *strMessage ;

@end
