//
//  ICHomeCustomCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 31/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ICHomeCustomCell.h"

@implementation ICHomeCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
        // Initialization code
    }
    
    return self;
}

- (void)setupCell
{
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ICHomeVCSelectionbg.png"] ];
}

- (void)awakeFromNib
{
    [self setupCell];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
