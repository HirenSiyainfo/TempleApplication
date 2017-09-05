//
//  InvnetoryInCustomCell.m
//  I-RMS
//
//  Created by Siya Infotech on 17/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "PendingDeliveryCustomCell.h"

@implementation PendingDeliveryCustomCell
@synthesize lblBarcode,lblItemName,lblQTY;
@synthesize txtCostPrice,txtProfit,txtRemarks,txtReOrder,txtSalesPrice,lblbacktitle,imgBackOrder,imgBackground;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}
-(void)layoutSubviews
{
    CGSize constraintSize = self.lblItemName.frame.size;
    constraintSize.height = 100;
    CGRect textRect = [self.lblItemName.text boundingRectWithSize:constraintSize
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:self.lblItemName.font}
                                                          context:nil];
    CGSize size = textRect.size;
    CGRect lblNameFrame = self.lblItemName.frame;
    lblNameFrame.size.height = size.height;
    self.lblItemName.frame = lblNameFrame;
    
}

- (void)awakeFromNib {
    
 
    txtReOrder.layer.borderWidth = 1.0;
    txtReOrder.layer.borderColor = [UIColor lightGrayColor].CGColor;

    txtRemarks.layer.borderWidth = 1.0;
    txtRemarks.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    txtCostPrice.layer.borderWidth = 1.0;
    txtCostPrice.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:87.0/255.0 blue:71.0/255.0 alpha:1.0].CGColor;
    
    txtSalesPrice.layer.borderWidth = 1.0;
    txtSalesPrice.layer.borderColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0].CGColor;
    
    txtProfit.layer.borderWidth = 1.0;
    txtProfit.layer.borderColor = [UIColor colorWithRed:44.0/255.0 green:192.0/255.0 blue:142.0/255.0 alpha:1.0].CGColor;
}

-(void)prepareForReuse{
    
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
