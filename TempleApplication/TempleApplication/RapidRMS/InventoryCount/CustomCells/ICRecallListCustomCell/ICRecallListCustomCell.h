//
//  ICJointCountCustomCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 1/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICRecallListCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *invCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *currentUserLabel;
@property (nonatomic, weak) IBOutlet UILabel *holddate;
@property (nonatomic, weak) IBOutlet UILabel *remarkLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *separatorLeadingConstraint;
@property (nonatomic, weak) IBOutlet UIStackView *recallStackView;
@property (nonatomic, weak) IBOutlet UIImageView *imgSelected;

@end
