//
//  SoundViewController.h
//  RapidRMS
//
//  Created by Siya Infotech on 07/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingSoundVC : UIViewController <UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate>

-(void)SaveData;
-(void)HidePopover;

@end
