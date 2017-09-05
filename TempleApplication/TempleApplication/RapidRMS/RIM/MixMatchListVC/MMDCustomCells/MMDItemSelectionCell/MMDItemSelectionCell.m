//
//  MMDItemSelectionCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 20/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDItemSelectionCell.h"

@implementation MMDItemSelectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)btnDeleteRowAt:(id)sender {
    if ([self.Delegate respondsToSelector:@selector(didDeleteRowAtIndexPath:)]) {
        [self.Delegate didDeleteRowAtIndexPath:[self.tableView indexPathForCell:self]];
    }
}
@end
