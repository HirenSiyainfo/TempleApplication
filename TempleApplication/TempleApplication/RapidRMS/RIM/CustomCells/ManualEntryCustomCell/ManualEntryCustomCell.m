//
//  ManualEntryCustomCell.m
//  RapidRMS
//
//  Created by Siya on 13/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ManualEntryCustomCell.h"

@implementation ManualEntryCustomCell
@synthesize lblInventoryName,lblBarcode,txtPrice,txtQty;
@synthesize imgBackGround,imgArrow,txtDiscount;
@synthesize txtCost,lblItemNumber;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
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
    if (IsPad())
    {
        [self resizeLabel:lblInventoryName];
        [self resizeLabel:lblBarcode];
    }
    else
    {
        [self resizeLabel:lblInventoryName];
    }
}

-(void)prepareForReuse
{
    if(IsPad())
    {
        lblInventoryName.textColor = [UIColor blackColor];
        lblBarcode.textColor = [UIColor blackColor];
    }
    else
    {
        lblInventoryName.textColor = [UIColor blackColor];
        lblBarcode.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];
    }
    txtPrice.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
    txtQty.textColor = [UIColor blackColor];
    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
