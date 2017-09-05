//
//  IntercomHandler.h
//  RapidRMS
//
//  Created by Siya Infotech on 30/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntercomPopUpVC.h"
#import "AboutViewController.h"

@interface IntercomHandler : NSObject <IntercomPopUpVCDelegate,UIPopoverPresentationControllerDelegate>
{
    UIPopoverPresentationController *intercomPopOverController;
    IntercomPopUpVC *intercomPopUpVC;
    UIViewController *intercomPopup;
    UIViewController *sourceVC;
    AboutViewController *aboutViewController;

}

-(instancetype)initWithButtton:(UIButton *)button withViewController:(UIViewController *)viewController NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithButtton:(UIButton *)button normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage withViewController:(UIViewController *)viewController NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithSettingButtton:(UIButton *)button withViewController:(UIViewController *)viewController NS_DESIGNATED_INITIALIZER;


@end
