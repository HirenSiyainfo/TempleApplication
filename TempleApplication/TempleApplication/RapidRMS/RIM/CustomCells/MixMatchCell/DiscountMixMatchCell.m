//
//  DiscountMixMatchCellTableViewCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 13/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DiscountMixMatchCell.h"

@implementation DiscountMixMatchCell

- (void)awakeFromNib
{
    // Initialization code
}

//- (void)resizeLabel:(UILabel *)label
//{
//    CGSize constraintSize = label.frame.size;
//    constraintSize.height = 200;
//    CGRect textRect = [label.text boundingRectWithSize:constraintSize
//                                               options:NSStringDrawingUsesLineFragmentOrigin
//                                            attributes:@{NSFontAttributeName:label.font}
//                                               context:nil];
//    CGSize size = textRect.size;
//    CGRect lblNameFrame = label.frame;
//    lblNameFrame.size.height = size.height;
//    label.frame = lblNameFrame;
//}
//
//-(void)layoutSubviews
//{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
//        [self resizeLabel:self.lblSelectedGroupScheme];
//    }
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end