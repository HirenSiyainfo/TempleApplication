//
//  ADModernPushTransition.h
//  AppLibrary
//
//  Created by Martin Guillon on 23/09/13.
//
//

#import "ADDualTransition.h"

@interface ADModernPushTransition : ADDualTransition
- (instancetype)initWithDuration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect NS_DESIGNATED_INITIALIZER;

@end
