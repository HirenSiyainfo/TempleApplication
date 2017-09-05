//
//  UserShiftDetailCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/13/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "UserShiftDetailCell.h"

@implementation UserShiftDetailCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)updateWithUserDetailDict :(NSMutableDictionary *)userDetail
{
    self.lblUserName.text = [userDetail valueForKey:@"UserName"];
}

@end
