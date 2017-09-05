//
//  IntercomHandler.m
//  RapidRMS
//
//  Created by Siya Infotech on 30/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "IntercomHandler.h"

@interface IntercomHandler()
{
    UIButton *intercomButton;
    NSArray *intercomIconArray;
}

@end

@implementation IntercomHandler
-(instancetype)initWithButtton:(UIButton *)button withViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        [button setImage:[UIImage imageNamed:@"helpbtn.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"helpbtnselected.png"] forState:UIControlStateHighlighted];

        sourceVC = viewController;
        [button addTarget:self action:@selector(intercomPopUpClicked:) forControlEvents:UIControlEventTouchUpInside];
        intercomButton = button;
    }
    return self;
}

-(instancetype)initWithButtton:(UIButton *)button normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage withViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        [button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
        sourceVC = viewController;
        [button addTarget:self action:@selector(intercomPopUpClicked:) forControlEvents:UIControlEventTouchUpInside];
        intercomButton = button;

    }
    return self;
}
-(instancetype)initWithSettingButtton:(UIButton *)button withViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        [button setImage:[UIImage imageNamed:@"helpbtn.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"helpbtnselected.png"] forState:UIControlStateHighlighted];
        
        sourceVC = viewController;
        [button addTarget:self action:@selector(intercomPopUpFromSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        intercomButton = button;
    }
    return self;

}

-(IBAction)intercomPopUpClicked:(id)sender
{
    UIButton *intercomBtn = (UIButton *)sender;
    [self openIntercomPopUp:intercomBtn.frame];
}

-(IBAction)intercomPopUpFromSettingButtonClicked:(id)sender
{
    UIButton *intercomBtn = (UIButton *)sender;
    [self openIntercomPopUpForSetting:intercomBtn.frame];
}


-(void)openIntercomPopUp:(CGRect)frame
{
    if (intercomPopOverController)
    {
        [intercomPopup dismissViewControllerAnimated:YES completion:nil];
    }
    
    intercomIconArray =  @[
                           @{@"iconImage" : @"intercom_messageIcon.png",
                             @"iconText" : @"MESSAGES",
                             @"iconhighlightedImage" : @"intercom_messageIcon_selected.png"},
                           
                           @{@"iconImage" : @"intercom_ConvesationIcon.png",
                             @"iconText" : @"CONVERSATIONS",
                             @"iconhighlightedImage" : @"intercom_ConvesationIcon_selected.png"},
                           
                           @{@"iconImage" : @"helpIcon.png",
                             @"iconText" : @"SUPPORT",
                             @"iconhighlightedImage" : @"helpIcon_selcted.png"},
                           
                           @{@"iconImage" : @"intercomAboutus.png",
                             @"iconText" : @"WHAT IS RAPID",
                             @"iconhighlightedImage" : @"intercomAboutus selected.png"},
                           
                           ];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    intercomPopUpVC = [storyBoard instantiateViewControllerWithIdentifier:@"IntercomPopUpVC"];
    intercomPopUpVC.intercomDelegate = self;
    intercomPopUpVC.intercomDisplayIconArray = intercomIconArray.mutableCopy;
    intercomPopup = intercomPopUpVC;
    
    // Present the view controller using the popover style.
    intercomPopup.modalPresentationStyle = UIModalPresentationPopover;
    [sourceVC presentViewController:intercomPopup animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
   
    intercomPopOverController = [intercomPopup popoverPresentationController];
    intercomPopOverController.delegate = self;
    intercomPopup.preferredContentSize = CGSizeMake(206, 155);
    intercomPopOverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    intercomPopOverController.sourceView = sourceVC.view;
    intercomPopOverController.sourceRect = frame;
  
}

-(void)openIntercomPopUpForSetting:(CGRect)frame
{
    if (intercomPopOverController)
    {
        [intercomPopup dismissViewControllerAnimated:YES completion:nil];
    }
    
    intercomIconArray =  @[
                           @{@"iconImage" : @"intercom_messageIcon.png",
                             @"iconText" : @"MESSAGES",
                             @"iconhighlightedImage" : @"intercom_messageIcon_selected.png"},
                           
                           @{@"iconImage" : @"intercom_ConvesationIcon.png",
                             @"iconText" : @"CONVERSATIONS",
                             @"iconhighlightedImage" : @"intercom_ConvesationIcon_selected.png"},
                           
                           @{@"iconImage" : @"helpIcon.png",
                             @"iconText" : @"SUPPORT",
                             @"iconhighlightedImage" : @"helpIcon_selcted.png"},
                           
                           ];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    intercomPopUpVC = [storyBoard instantiateViewControllerWithIdentifier:@"IntercomPopUpVC"];
    intercomPopUpVC.intercomDelegate = self;
    intercomPopUpVC.intercomDisplayIconArray = intercomIconArray.mutableCopy;

    intercomPopup = intercomPopUpVC;
    
    // Present the view controller using the popover style.
    intercomPopup.modalPresentationStyle = UIModalPresentationPopover;
    [sourceVC presentViewController:intercomPopup animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    
    intercomPopOverController = [intercomPopup popoverPresentationController];
    intercomPopOverController.delegate = self;
    intercomPopup.preferredContentSize = CGSizeMake(206, 155);
    intercomPopOverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    intercomPopOverController.sourceView = sourceVC.view;
    intercomPopOverController.sourceRect = frame;
    
}


- (void)didSelectIntercomOption
{
    [intercomPopup dismissViewControllerAnimated:YES completion:nil];
}

-(void)didSelectAboutRapidRms{
    
    if (intercomPopOverController)
    {
        [intercomPopup dismissViewControllerAnimated:YES completion:nil];
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    aboutViewController = [storyBoard instantiateViewControllerWithIdentifier:@"AboutViewController_sid"];
    
    aboutViewController.modalPresentationStyle = UIModalPresentationPopover;
    
    // Present the view controller using the popover style.
    [sourceVC presentViewController:aboutViewController animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    
    intercomPopOverController = [aboutViewController popoverPresentationController];
    intercomPopOverController.delegate = self;
    aboutViewController.preferredContentSize = CGSizeMake(724, 703);
    intercomPopOverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    intercomPopOverController.sourceView = sourceVC.view;
    intercomPopOverController.sourceRect = intercomButton.frame;

}
@end
