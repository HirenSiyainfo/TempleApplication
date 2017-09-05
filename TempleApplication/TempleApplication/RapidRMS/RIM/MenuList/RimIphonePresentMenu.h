//
//  menuViewController.h
//  I-RMS
//
//  Created by Siya Infotech on 11/10/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuVCDelegate.h"

@interface RimIphonePresentMenu : UIViewController

@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;
@end
