//
//  ICJointCountCustomCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 1/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICReconcileStatusCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *deviceName;
@property (nonatomic, weak) IBOutlet UILabel *incCountNumber;
@property (nonatomic, weak) IBOutlet UILabel *startDate;
@property (nonatomic, weak) IBOutlet UILabel *status;
@property (nonatomic, weak) IBOutlet UILabel *endDate;
@end
