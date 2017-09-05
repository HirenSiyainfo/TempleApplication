//
//  ADSwapTransition.h
//  AppLibrary
//
//  Created by Patrick Nollet on 14/03/11.
//  Copyright 2011 Applidium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADDualTransition.h"

@interface ADSwapTransition : ADDualTransition
- (instancetype)initWithDuration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect NS_DESIGNATED_INITIALIZER;
@end
