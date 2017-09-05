//
//  HItemProductCell.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HItemProductCell.h"

@implementation HItemProductCell

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
    self.btnCashQtyMinus.layer.cornerRadius=5.0;
    self.btnCashQtyMinus.layer.masksToBounds=YES;
    self.btnCashQtyMinus.layer.borderColor=[UIColor blackColor].CGColor;
    self.btnCashQtyMinus.layer.borderWidth= 1.0f;
    
    self.btnCashQtyPlus.layer.cornerRadius=5.0;
    self.btnCashQtyPlus.layer.masksToBounds=YES;
    self.btnCashQtyPlus.layer.borderColor=[UIColor blackColor].CGColor;
    self.btnCashQtyPlus.layer.borderWidth= 1.0f;

    self.btnUnitQtyMinus.layer.cornerRadius=5.0;
    self.btnUnitQtyMinus.layer.masksToBounds=YES;
    self.btnUnitQtyMinus.layer.borderColor=[UIColor blackColor].CGColor;
    self.btnUnitQtyMinus.layer.borderWidth= 1.0f;
    
    self.btnUnitQtyPlus.layer.cornerRadius=5.0;
    self.btnUnitQtyPlus.layer.masksToBounds=YES;
    self.btnUnitQtyPlus.layer.borderColor=[UIColor blackColor].CGColor;
    self.btnUnitQtyPlus.layer.borderWidth= 1.0f;
    

    self.lblUnitQty.layer.cornerRadius=5.0;
    self.lblUnitQty.layer.masksToBounds=YES;
    self.lblUnitQty.layer.borderColor=[UIColor colorWithRed:0.0/255.0 green:160.0/255.0 blue:79.0/255.0 alpha:1.0].CGColor ;
    self.lblUnitQty.layer.borderWidth= 3.0f;


    self.lblCashQty.layer.cornerRadius=5.0;
    self.lblCashQty.layer.masksToBounds=YES;
    self.lblCashQty.layer.borderColor=[UIColor colorWithRed:0.0/255.0 green:160.0/255.0 blue:79.0/255.0 alpha:1.0].CGColor ;
    self.lblCashQty.layer.borderWidth= 3.0f;

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
        [self resizeLabel:_lblProductName];
    }
    else
    {
        [self resizeLabel:_lblProductName];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
