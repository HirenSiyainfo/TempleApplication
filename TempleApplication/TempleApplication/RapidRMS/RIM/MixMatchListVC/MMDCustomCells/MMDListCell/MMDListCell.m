//
//  MMDListCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 02/02/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDListCell.h"

@implementation MMDListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)btnDeleteRowFrom:(id)sender {
    if ([self.Delegate respondsToSelector:@selector(willDeleteRowAtIndexPath:)]) {
        [self.Delegate willDeleteRowAtIndexPath:[self.tableView indexPathForCell:self]];
    }
}
-(IBAction)btnEditRowFrom:(id)sender {
    if ([self.Delegate respondsToSelector:@selector(willEditRowAtIndexPath:)]) {
        [self.Delegate willEditRowAtIndexPath:[self.tableView indexPathForCell:self]];
    }
}
-(IBAction)willChangeStatusRowFrom:(UISwitch *)sender {
    if ([self.Delegate respondsToSelector:@selector(willChangeStatusRowAtIndexPath:withNewStatus:)]) {
        [self.Delegate willChangeStatusRowAtIndexPath:[self.tableView indexPathForCell:self] withNewStatus:sender.on];
    }
}
@end
