//
//  CommonLabel.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/30/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CommonLabel.h"

@implementation CommonLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)configureLable :(CGRect)frame withFontName:(NSString *)fontName withFontSize:(float)fontSize withTextAllignment:(NSTextAlignment)alignment withTextColor:(UIColor *)color;
{
    self.frame = frame;
    self.font = [UIFont fontWithName:fontName size:fontSize];
    self.textAlignment = alignment;
    self.textColor = color;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
