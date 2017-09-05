//
//  GuestSelectionCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/17/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GuestSelectionCell.h"

@implementation GuestSelectionCell
- (void)awakeFromNib
{
    [self setUpCell];
}

-(void)setUpCell
{
    UIImageView *backGroundimageView = [[UIImageView alloc]initWithFrame:self.bounds];
    backGroundimageView.backgroundColor = [UIColor whiteColor];
    backGroundimageView.layer.borderWidth = 1.0;
    backGroundimageView.layer.cornerRadius = 25.0;
    self.backgroundView = backGroundimageView;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
   
    UIImageView *backGroundActiveimageView = [[UIImageView alloc]initWithFrame:self.bounds];
    backGroundActiveimageView.backgroundColor = [UIColor colorWithRed:1.000 green:0.627 blue:0.000 alpha:1.000];
    backGroundActiveimageView.layer.borderWidth = 1.0;
    backGroundActiveimageView.layer.cornerRadius = 25.0;
    self. selectedBackgroundView = backGroundActiveimageView;
    self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView.layer.borderColor = [UIColor colorWithRed:0.078 green:0.133 blue:0.239 alpha:1.000].CGColor;
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:1.000 green:0.627 blue:0.000 alpha:1.000];
    self.selectedBackgroundView.layer.borderColor = [UIColor colorWithRed:1.000 green:0.627 blue:0.000 alpha:1.000].CGColor;

    
}
@end
