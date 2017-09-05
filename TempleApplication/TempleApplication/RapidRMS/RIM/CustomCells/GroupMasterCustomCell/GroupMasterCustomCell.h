//
//  InvnetoryInCustomCell.h
//  I-RMS
//
//  Created by Siya Infotech on 17/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupMasterCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblGroup;
@property (nonatomic, weak) IBOutlet UILabel *lblCost;
@property (nonatomic, weak) IBOutlet UILabel *lblPrice;

@property (nonatomic, weak) IBOutlet UIImageView *imgBackGround;

@end