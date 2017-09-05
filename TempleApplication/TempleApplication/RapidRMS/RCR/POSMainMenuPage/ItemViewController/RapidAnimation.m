//
//  RapidAnimation.m
//  AnimationSampleApp
//
//  Created by siya-IOS5 on 9/24/14.
//  Copyright (c) 2014 siya-IOS5. All rights reserved.
//

#import "RapidAnimation.h"
#import "ADTransitioningDelegate.h"

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

ADTransitioningDelegate  *_customTransitioningDelegate;
ADNavigationControllerDelegate *navigationDelegate;
@implementation RapidAnimation

+(void)pushViewController :(UIViewController *)viewController withNavigationControlller:(UINavigationController *)navigationController withAnimationType:(RapidAnimationType)animationType
{
    ADTransition * transtion ;
            switch (animationType) {
                case RapidAnimationTypeFade:
                    transtion = [self fadeAnimationWithDuration:1.0];
                    break;
                case RapidAnimationTypeSlide:
                    
                transtion = [self slideAnimationWithDuration:0.5 withNavigationControlllerFrame:navigationController.view.frame
                                                withOrientation:ADTransitionTopToBottom];
                    break;
                
                case RapidAnimationTypePushRotate:
                    transtion = [self pushRotateAnimationWithDuration:0.5 withNavigationControlllerFrame:navigationController.view.frame withOrientation:ADTransitionTopToBottom];
                    break;
               
                case RapidAnimationTypeFold:
                    transtion = [self foldAnimationWithDuration:0.5 withNavigationControlllerFrame:navigationController.view.frame withOrientation:ADTransitionTopToBottom];
                    break;
             
                case RapidAnimationTypeBackFade:
                    transtion = [self backFadeAnimationWithDuration:0.5];
                    break;
              
                case RapidAnimationTypeSwap:
                    transtion = [self flipAnimationWithDuration:0.5 withNavigationControlllerFrame:navigationController.view.frame withOrientation:ADTransitionTopToBottom];
                    break;
             
                case RapidAnimationTypeFlip:
                    transtion = [self flipAnimationWithDuration:0.5 withNavigationControlllerFrame:navigationController.view.frame withOrientation:ADTransitionTopToBottom];
                    break;
             
                case RapidAnimationTypeSwipeFade:
                    break;
              
                case RapidAnimationTypeScale:
                    transtion = [self scaleAnimationWithDuration:0.5 withNavigationControlllerFrame:navigationController.view.frame withOrientation:ADTransitionTopToBottom];
                    break;
            
                case RapidAnimationTypeGlue:
                    transtion = [self glueAnimationWithDuration:0.5 withNavigationControlllerFrame:navigationController.view.frame withOrientation:ADTransitionLeftToRight];
                    break;
              
                case RapidAnimationTypeZoom:
                    transtion = [self focusAnimationWithDuration:0.5 withNavigationControlllerFrame:navigationController.view.frame];
                    break;
              
                case RapidAnimationTypeGhost:
                    transtion = [self ghostAnimationWithDuration:0.5];
                    break;
               
                case RapidAnimationTypeSwipe:
                    transtion = [self swipeFadeAnimationWithDuration:0.5 withNavigationControlllerFrame:navigationController.view.frame withOrientation:ADTransitionTopToBottom];
                    break;
               
                case RapidAnimationTypePush:
                    break;
                    
                case RapidAnimationTypeCross:
                    transtion = [self crossAnimationWithDuration:0.5];
                    break;
                    
                case RapidAnimationTypeCube:
                    transtion = [self cubeAnimationWithDuration:0.3 withNavigationControlllerFrame:navigationController.view.frame withOrientation:ADTransitionTopToBottom];
                    break;
                    
                case RapidAnimationTypeCarrousel:
                    transtion = [self carrouselAnimationWithDuration:0.5 withNavigationControlllerFrame:navigationController.view.frame withOrientation:ADTransitionRightToLeft];

                    break;
                
                    
                    
            }
    
    [self _pushViewControllerWithTransition:transtion WithViewController:viewController withNavigationController:navigationController];
}
#pragma mark -
#pragma mark Actions

+ (ADTransition *)slideAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    
    ADTransition * animation = [[ADSlideTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    return animation;
}
+ (ADTransition*)fadeAnimationWithDuration :(CFTimeInterval)duration
    {
    ADTransition * animation = [[ADFadeTransition alloc] initWithDuration:duration];
    return animation;
}
+ (ADTransition*)backFadeAnimationWithDuration :(CFTimeInterval)duration
{
    ADTransition * animation = [[ADBackFadeTransition alloc] initWithDuration:duration];

    return animation;
}
+ (ADTransition*)ghostAnimationWithDuration :(CFTimeInterval)duration
{
    ADTransition * animation = [[ADGhostTransition alloc] initWithDuration:duration];
    return animation;
}

+ (ADTransition*)cubeAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    ADTransition * animation = [[ADCubeTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    return animation;
}

+ (ADTransition*)carrouselAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    ADTransition * animation = [[ADCarrouselTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    return animation;
}

+ (ADTransition*)crossAnimationWithDuration :(CFTimeInterval)duration
{
    ADTransition * animation = [[ADCrossTransition alloc] initWithDuration:duration];
    return animation;
}

+ (ADTransition*)flipAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    ADDualTransition * animation = [[ADFlipTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    return animation;
}

+ (ADTransition*)swipeAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    ADTransition * animation = [[ADSwipeTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    return animation;
}
+ (ADTransition*)scaleAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    ADTransition * animation = [[ADScaleTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    return animation;
}
+ (ADTransition*)foldAnimationWithDuration  :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    ADTransition * animation = [[ADFoldTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    return animation;
}

+ (ADTransition*)glueAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    ADTransition * animation = [[ADGlueTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    
    return animation;
}

+ (ADTransition*)swapAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    ADTransition * animation = [[ADSwapTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    return animation;
}
+ (ADTransition*)pushRotateAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    ADTransition * animation = [[ADPushRotateTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    return animation;
}
+ (ADTransition*)focusAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect  {
    ADTransition * animation = [[ADZoomTransition alloc] initWithSourceRect:CGRectMake(500, 500, 100, 100) andTargetRect:rect forDuration:duration];
    return animation;
}
+ (ADTransition*)swipeFadeAnimationWithDuration :(CFTimeInterval)duration withNavigationControlllerFrame:(CGRect )rect withOrientation :(ADTransitionOrientation)orientation
{
    ADTransition * animation = [[ADSwipeFadeTransition alloc] initWithDuration:duration orientation:orientation sourceRect:rect];
    return animation;
}
/*
*/
/*
+ (ADTransition*)push{
    ADTransition * animation = [[ADModernPushTransition alloc] initWithDuration:_duration orientation:_orientation sourceRect:self.view.frame];

    return animation;
}*/


+ (void)_pushViewControllerWithTransition:(ADTransition *)transition WithViewController:(UIViewController *)viewController withNavigationController :(UINavigationController *)navigationController
{
# if 1
    navigationDelegate = [[ADNavigationControllerDelegate alloc] init];
    ((UINavigationController *)navigationController).delegate = navigationDelegate;
    _customTransitioningDelegate = [[ADTransitioningDelegate alloc] initWithTransition:transition];
    viewController.transitioningDelegate = _customTransitioningDelegate; // don't call the setter of the current
    [navigationController pushViewController:viewController animated:YES];
#else
        _customTransitioningDelegate = [[ADTransitioningDelegate alloc] initWithTransition:transition];
        [viewController setTransitioningDelegate:_customTransitioningDelegate]; // don't call the setter of the current
      [navigationController.topViewController presentViewController:viewController animated:YES completion:^{}];
#endif
}


#pragma mark - UIView Animation
- (CATransition *)transitionForAnimationType:(NSInteger )animationType
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    [self setAnimationTypeOfAnimation:animation withAnimationType:animationType];
    animation.type = kCATransitionFade;
    animation.subtype = kCATransitionFromTop;
    return animation;
}

-(void)setAnimationTypeOfAnimation :(CATransition *)animation withAnimationType:(NSInteger )animationType
{
    switch (animationType) {
        case RapidAnimationTypeFade:
            animation.type = kCATransitionFade;
        default:
            break;
    }
}

-(void)addSubview:(UIView *)subview withSuperView :(UIView *)superView animationType:(RapidAnimationType)animationType
{
    [superView addSubview:subview];
//    CATransition *animation =  [self transitionForAnimationType:animationType];
//    [superView.layer addAnimation:animation forKey:@"animation"];
}

-(void)hideSubview:(UIView *)subview withSuperView :(UIView *)superView shouldRemove :(BOOL)shouldRemove animationType:(RapidAnimationType)animationType
{
//    CATransition *animation =  [self transitionForAnimationType:animationType];
//    [superView.layer addAnimation:animation forKey:@"animation"];
    if (shouldRemove)
    {
        [subview removeFromSuperview];
    }
    else
    {
        subview.hidden = YES;
    }
}

@end
