//
//  CustomTenderCell.m
//  POSRetail
//
//  Created by Keyur Patel on 14/06/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import "CustomTenderCell.h"

@implementation CustomTenderCell

@synthesize lblPaymentName,lblAmount,payImage,cellBackground,btnClickCell1,lblPayId,btnClickCell2;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
