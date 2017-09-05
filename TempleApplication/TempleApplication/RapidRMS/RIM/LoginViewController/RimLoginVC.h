//
//  ViewController.h
//  I-RMS
//
//  Created by Siya Infotech on 02/08/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashBoardSettingVC.h"

@protocol RimLoginDelegate<NSObject>

-(void)openSettingView;
-(void)cancelSettingView;


@end
@interface RimLoginVC : UIViewController <UITextFieldDelegate, UpdateDelegate>

@property (nonatomic, weak) id<RimLoginDelegate> rimLoginDelegate;

@end
