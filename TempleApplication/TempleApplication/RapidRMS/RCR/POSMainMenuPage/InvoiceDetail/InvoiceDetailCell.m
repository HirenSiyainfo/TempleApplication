//
//  InvoiceDetailCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 3/4/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "InvoiceDetailCell.h"

@implementation InvoiceDetailCell

- (void)awakeFromNib {
    [self setUpCell];
    // Initialization code
}
-(void)setUpCell
{
    self. selectedBackgroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(196/255.f) green:(237/255.f) blue:(224/255.f) alpha:1.0];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
