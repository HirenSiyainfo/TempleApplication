//
//  VariationCustomCell.m
//  RapidRMS
//
//  Created by Siya on 13/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "VariationDisplayCustomCell.h"

@implementation VariationDisplayCustomCell

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
