//
//  CommonLabel.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/30/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonLabel : UILabel
-(void)configureLable :(CGRect)frame withFontName:(NSString *)fontName withFontSize:(float)fontSize withTextAllignment:(NSTextAlignment)alignment withTextColor:(UIColor *)color;

@end
