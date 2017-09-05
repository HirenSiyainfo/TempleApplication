//
//  OpenOrder_iPhone.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "OpenOrder_iPhone.h"

@implementation OpenOrder_iPhone

- (void)awakeFromNib
{
    // Initialization code
}


-(void)layoutSubviews
{
    CGSize constraintSize = self.lblItemName.frame.size;
    constraintSize.height = 200;
    CGRect textRect = [self.lblItemName.text boundingRectWithSize:constraintSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:self.lblItemName.font}
                                               context:nil];
    CGSize size = textRect.size;
    CGRect lblNameFrame = self.lblItemName.frame;
    lblNameFrame.size.height = size.height;
    self.lblItemName.frame = lblNameFrame;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
