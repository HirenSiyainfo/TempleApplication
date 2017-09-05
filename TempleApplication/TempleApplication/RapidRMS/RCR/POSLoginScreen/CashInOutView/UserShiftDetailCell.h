//
//  UserShiftDetailCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/13/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserShiftDetailCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblUserName;

-(void)updateWithUserDetailDict :(NSMutableDictionary *)userDetail;

@end
