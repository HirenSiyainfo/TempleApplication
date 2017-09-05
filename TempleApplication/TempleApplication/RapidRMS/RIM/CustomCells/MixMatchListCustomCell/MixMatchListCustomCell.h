//
//  InvnetoryInCustomCell.h
//  I-RMS
//
//  Created by Siya Infotech on 17/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MixMatchListCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblItemType;
@property (nonatomic, weak) IBOutlet UILabel *lblDiscription;
@property (nonatomic, weak) IBOutlet UILabel *lblDiscountType;

@property (nonatomic, weak) IBOutlet UIImageView *imgBackGround;

@end