//
//  ADZoomTransition.h
//  AppLibrary
//
//  Created by Romain Goyet on 14/03/11.
//  Copyright 2011 Applidium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADDualTransition.h"

@interface ADZoomTransition : ADDualTransition
- (instancetype)initWithSourceRect:(CGRect)sourceRect andTargetRect:(CGRect)targetRect forDuration:(double)duration NS_DESIGNATED_INITIALIZER;
@end
