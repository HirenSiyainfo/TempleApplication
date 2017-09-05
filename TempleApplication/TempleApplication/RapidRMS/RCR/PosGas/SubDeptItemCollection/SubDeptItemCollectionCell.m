//
//  SubDeptItemCollectionCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "SubDeptItemCollectionCell.h"

@implementation SubDeptItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
//        [self resizeLabel:self.itemName];
//        [self resizeLabel:self.itemSalesPrice];
    }
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
