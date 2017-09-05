//
//  CCDetailsCustomeCell.m
//  RapidRMS
//
//  Created by Siya-mac5 on 27/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CCDetailsCustomeCell.h"

@implementation CCDetailsCustomeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)adjustTip:(id)sender{
    [self.cCDetailsCustomeCellDelegate didSelectRecordForTipAdjustmentAtIndexPath:self.indexPathForCell];
}

@end
