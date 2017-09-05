//
//  CALayer+Customize.m
//  RapidRMS
//
//  Created by Siya9 on 03/09/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CALayer+Customize.h"

@implementation CALayer (Customize)

-(void)setLBorderColor:(UIColor *)LBorderColor{
    self.borderColor = LBorderColor.CGColor;
}
@end
