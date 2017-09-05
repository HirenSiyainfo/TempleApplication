//
//  ADTransitioningDelegate.h
//  ADTransitionController
//
//  Created by Patrick Nollet on 09/10/13.
//  Copyright (c) 2013 Applidium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADTransition.h"

@interface ADTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, ADTransitionDelegate>
@property (nonatomic, retain) ADTransition * transition;
- (instancetype)initWithTransition:(ADTransition *)transition;
@end