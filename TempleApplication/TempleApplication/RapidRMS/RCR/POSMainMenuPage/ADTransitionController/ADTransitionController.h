//
//  ADTransitionController.h
//  Transition
//
//  Created by Patrick Nollet on 21/02/11.
//  Copyright 2011 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+ADTransitionController.h"
#import "ADTransition.h"
#import "ADDualTransition.h"
#import "ADTransformTransition.h"
#import "ADCarrouselTransition.h"
#import "ADCubeTransition.h"
#import "ADCrossTransition.h"
#import "ADFadeTransition.h"
#import "ADFlipTransition.h"
#import "ADSwapTransition.h"
#import "ADGhostTransition.h"
#import "ADBackFadeTransition.h"
#import "ADZoomTransition.h"
#import "ADSwipeTransition.h"
#import "ADSwipeFadeTransition.h"
#import "ADScaleTransition.h"
#import "ADGlueTransition.h"
#import "ADPushRotateTransition.h"
#import "ADFoldTransition.h"
#import "ADSlideTransition.h"
#import "ADModernPushTransition.h"
#import "ADTransitioningDelegate.h"
#import "ADNavigationControllerDelegate.h"
#import "ADTransitioningViewController.h"

// Our container view must be backed by a CATransformLayer
@interface ADTransitionView : UIView
@end

@protocol ADTransitionControllerDelegate;

@interface ADTransitionController : UIViewController <ADTransitionDelegate, UINavigationBarDelegate, UIToolbarDelegate> {
    NSMutableArray *  _viewControllers;
    NSMutableArray *  _transitions; // Transition stack, paired with the view controller stack
    BOOL              _isContainerViewTransitioning;
    BOOL              _isNavigationBarTransitioning;
    UINavigationBar * _navigationBar;
    UIToolbar *       _toolbar;
    UIView *          _containerView;
}

@property (nonatomic, copy) NSMutableArray * viewControllers;
@property (nonatomic, readonly, retain) UIViewController * topViewController;
@property (nonatomic, readonly, retain) UIViewController * visibleViewController;
@property(nonatomic, readonly) UINavigationBar * navigationBar;
@property (nonatomic, readonly) UIToolbar * toolbar;
@property (nonatomic, assign) id<ADTransitionControllerDelegate> delegate;
@property(nonatomic, getter = isNavigationBarHidden, setter = setNavigationBarHidden:) BOOL navigationBarHidden;
@property(nonatomic, getter = isToolbarHidden, setter = setToolbarHidden:) BOOL toolbarHidden;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController NS_DESIGNATED_INITIALIZER;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)viewController withTransition:(ADTransition *)transition;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIViewController *popViewController;
- (UIViewController *)popViewControllerWithTransition:(ADTransition *)transition;
- (NSArray *)popToViewController:(UIViewController *)viewController;
- (NSArray *)popToViewController:(UIViewController *)viewController withTransition:(ADTransition *)transition ;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *popToRootViewController;
- (NSArray *)popToRootViewControllerWithTransition:(ADTransition *)transition;
@end

@protocol ADTransitionControllerDelegate <NSObject>
- (void)transitionController:(ADTransitionController *)transitionController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)transitionController:(ADTransitionController *)transitionController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end