//
//  InvnetoryInCustomCell.h
//  I-RMS
//
//  Created by Siya Infotech on 17/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DepartmentCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet AsyncImageView *deptImage;
@property (nonatomic, weak) IBOutlet UILabel *departmentName;
@property (nonatomic, weak) IBOutlet UILabel *ageRestricted;

@property (nonatomic, weak) IBOutlet UIImageView *taxApply;
@property (nonatomic, weak) IBOutlet UIImageView *payoutApply;

@end