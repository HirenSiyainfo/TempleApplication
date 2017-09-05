//
//  ADTransition.h
//  Transition
//
//  Created by Patrick Nollet on 21/02/11.
//  Copyright 2011 Applidium. All rights reserved.
//

// Abstract class

#import <Foundation/Foundation.h>
#import <QuartzCore/CoreAnimation.h>

extern NSString * ADTransitionAnimationKey;
extern NSString * ADTransitionAnimationInValue;
extern NSString * ADTransitionAnimationOutValue;

@class ADTransition;
@protocol ADTransitionDelegate
@optional
- (void)pushTransitionDidFinish:(ADTransition *)transition;
- (void)popTransitionDidFinish:(ADTransition *)transition;
@end

typedef NS_ENUM(unsigned int, ADTransitionType) {
    ADTransitionTypeNull,
    ADTransitionTypePush,
    ADTransitionTypePop
};

typedef NS_ENUM(unsigned int, ADTransitionOrientation) {
    ADTransitionRightToLeft,
    ADTransitionLeftToRight,
    ADTransitionTopToBottom,
    ADTransitionBottomToTop
};


@interface ADTransition : NSObject {
    ADTransitionType _type;
}

@property (nonatomic, assign) id <ADTransitionDelegate> delegate;
@property (nonatomic, assign) ADTransitionType type;
@property (nonatomic, readonly) NSTimeInterval duration; // abstract

+ (ADTransition *)nullTransition;
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) ADTransition *reverseTransition;
@property (NS_NONATOMIC_IOSONLY, getter=getCircleApproximationTimingFunctions, readonly, copy) NSArray *circleApproximationTimingFunctions;
@end
