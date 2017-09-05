//
//  ButtonAndSwitchCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 17/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonAndSwitchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton * selectedButton;
@property (nonatomic, weak) IBOutlet UISwitch * selectedswitch;
@property (nonatomic, weak) IBOutlet UILabel * cellTitle;
@end
