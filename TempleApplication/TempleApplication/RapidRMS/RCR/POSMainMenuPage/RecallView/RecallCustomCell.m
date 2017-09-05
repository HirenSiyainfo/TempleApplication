//
//  RecallCustomCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 3/3/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RecallCustomCell.h"

@implementation RecallCustomCell

- (void)awakeFromNib
{
    // Initialization code
    [self setUpCell];
}
-(void)setUpCell
{
    self.backgroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self. selectedBackgroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
