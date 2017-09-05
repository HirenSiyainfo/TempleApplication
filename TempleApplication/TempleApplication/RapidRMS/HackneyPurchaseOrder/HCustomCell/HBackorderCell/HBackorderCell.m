//
//  HBackorderCell.m
//  RapidRMS
//
//  Created by Siya on 19/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HBackorderCell.h"

@implementation HBackorderCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)resizeLabel:(UILabel *)label
{
    CGSize constraintSize = label.frame.size;
    constraintSize.height = 200;
    CGRect textRect = [label.text boundingRectWithSize:constraintSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:label.font}
                                               context:nil];
    CGSize size = textRect.size;
    CGRect lblNameFrame = label.frame;
    lblNameFrame.size.height = size.height;
    label.frame = lblNameFrame;
}

-(void)layoutSubviews
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        [self resizeLabel:_lblItemName];
    }
    else
    {
        [self resizeLabel:_lblItemName];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
