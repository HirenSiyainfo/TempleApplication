//
//  RCR_MemoVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/11/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCR_MemoDelegate<NSObject>

-(void)didAddMemo :(NSString *)message;
-(void)didCancelMemoVC;

@end

@interface RCR_MemoVC : UIViewController

@property (assign) BOOL isMemoFromEditState;

@property (nonatomic, weak) id<RCR_MemoDelegate> rcr_MemoDelegate;

@end
