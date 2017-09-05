//
//  RapidAnimation.h
//  AnimationSampleApp
//
//  Created by siya-IOS5 on 9/24/14.
//  Copyright (c) 2014 siya-IOS5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADTransition.h"

typedef NS_ENUM(NSInteger, RapidAnimationType) {
    RapidAnimationTypeFade,         // slow at beginning and end
    RapidAnimationTypeSlide,
    RapidAnimationTypePushRotate,
    RapidAnimationTypeFold,
    RapidAnimationTypeBackFade,
    RapidAnimationTypeSwap,
    RapidAnimationTypeFlip,
    RapidAnimationTypeSwipeFade,
    RapidAnimationTypeScale,
    RapidAnimationTypeGlue,
    RapidAnimationTypeZoom,
    RapidAnimationTypeGhost,
    RapidAnimationTypeSwipe,
    RapidAnimationTypePush,
    RapidAnimationTypeCross,
    RapidAnimationTypeCube,
    RapidAnimationTypeCarrousel,
    //    RapidAnimationType,            // slow at beginning
    //    RapidAnimationType,           // slow at end
    //    RapidAnimationType
};

@interface RapidAnimation : NSObject

+(void)pushViewController :(UIViewController *)viewController withNavigationControlller:(UINavigationController *)navigationController withAnimationType:(RapidAnimationType)animationType;
+ (ADTransition*)fadeAnimationWithDuration :(CFTimeInterval)duration;
+ (ADTransition*)ghostAnimationWithDuration :(CFTimeInterval)duration;

-(void)addSubview:(UIView *)subview withSuperView :(UIView *)superView animationType:(RapidAnimationType)animationType;

-(void)hideSubview:(UIView *)subview withSuperView :(UIView *)superView shouldRemove :(BOOL)shouldRemove animationType:(RapidAnimationType)animationType;


@end
