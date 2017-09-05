//
//  ClockInCustomCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 5/9/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ClockInCustomCell.h"

@implementation ClockInCustomCell
@synthesize clockInDate,clockInTime,clockOutTime,clockInDay,totalHours;
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
