//
//  PendingDeliveryPOCell_iPhone.m
//  RapidRMS
//
//  Created by Siya Infotech on 27/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PendingDeliveryPOCell_iPhone.h"

@implementation PendingDeliveryPOCell_iPhone

- (void)awakeFromNib
{
    // Initialization code
}
-(void)layoutSubviews
{
    CGSize constraintSize = self.lblTitle.frame.size;
    constraintSize.height = 200;
    CGRect textRect = [self.lblTitle.text boundingRectWithSize:constraintSize
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                          context:nil];
    CGSize size = textRect.size;
    CGRect lblNameFrame = self.lblTitle.frame;
    lblNameFrame.size.height = size.height;
    self.lblTitle.frame = lblNameFrame;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
