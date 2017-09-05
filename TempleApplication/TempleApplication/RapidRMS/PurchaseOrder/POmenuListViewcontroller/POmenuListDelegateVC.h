//
//  POmenuListDelegateVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 19/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#ifndef RapidRMS_POmenuListDelegateVC_h
#define RapidRMS_POmenuListDelegateVC_h

@protocol POmenuListVCDelegate <NSObject>
    -(void)willPushViewController:(UIViewController *)viewController animated:(BOOL)animated;
    -(UIViewController *)willPopViewControllerAnimated:(BOOL)animated;

    -(void)willPresentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion;
    -(void)willDismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion;

    @property (NS_NONATOMIC_IOSONLY, getter=getPOmenuListNavigationController, readonly, strong) UINavigationController *POmenuListNavigationController;
    - (void)showViewFromViewController:(UIViewController*)viewController;
    - (void)showItemManagementView:(UIViewController *)itemMultipleSelectionVC;
    @property (NS_NONATOMIC_IOSONLY, getter=getCurrentSelectedMenu, readonly) int currentSelectedMenu;
@end
#endif
