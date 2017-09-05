//
//  ADSlideTransition.h
//  ADTransitionController
//
//  Created by Pierre Felgines on 30/05/13.
//  Copyright (c) 2013 Applidium. All rights reserved.
//

#import "ADDualTransition.h"

@interface ADSlideTransition : ADDualTransition
- (instancetype)initWithDuration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect NS_DESIGNATED_INITIALIZER;
@end
