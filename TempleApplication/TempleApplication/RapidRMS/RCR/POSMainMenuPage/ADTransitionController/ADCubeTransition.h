//
//  ADCubeTransition.h
//  AppLibrary
//
//  Created by Patrick Nollet on 14/03/11.
//  Copyright 2011 Applidium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADTransformTransition.h"

@interface ADCubeTransition : ADTransformTransition
- (instancetype)initWithDuration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect NS_DESIGNATED_INITIALIZER;
@end
