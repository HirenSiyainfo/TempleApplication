//
//  MultipleItemBarcodeRingUpCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/15/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "InventoryCountItemSelectionCell.h"

@implementation InventoryCountItemSelectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end