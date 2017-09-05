//
//  CCbatchReportCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CCbatchReportCell.h"

@implementation CCbatchReportCell

- (void)awakeFromNib
{
    // Initialization code
}
/*-(void)test
{
    
}*/
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)adjustTip:(id)sender{
    [self.ccbatchReportCellDelegate didSelectTransactionAtIndexPath:self.indexPathForCell];
}

-(IBAction)forceTransaction:(id)sender{
    [self.ccbatchReportCellDelegate didSelectForceTransactionAtIndexPath:self.indexPathForCell];
}

-(IBAction)voidTransaction:(id)sender{
    [self.ccbatchReportCellDelegate didSelectVoidTransactionAtIndexPath:self.indexPathForCell];
}


@end
