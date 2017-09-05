//
//  DiscountMasterListCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 5/29/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DiscountMasterListCell.h"

@implementation DiscountMasterListCell


- (void)awakeFromNib
{
    [self setUpCell];
}

-(void)setUpCell
{
    UIView *backGroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.backgroundView = backGroundView;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    UIImageView *selectedbackGroundView = [[UIImageView alloc]initWithFrame:self.bounds];
    self. selectedBackgroundView = selectedbackGroundView;
    self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
}


@end
