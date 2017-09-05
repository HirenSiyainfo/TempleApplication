//
//  ItemInfoTagCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 21/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemInfoTagCell.h"

@implementation ItemInfoTagCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)AddTagButtonTapped:(id)sender{
    [self.ItemInfoTagDetailDelegate didAddNewTag:self.txtTagName.text];
    self.txtTagName.text=@"";
}
@end
