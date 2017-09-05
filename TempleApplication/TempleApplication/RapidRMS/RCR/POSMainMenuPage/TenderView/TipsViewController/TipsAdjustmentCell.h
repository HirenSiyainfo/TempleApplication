//
//  TipsAdjustmentCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 12/16/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipsAdjustmentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *paymentName;
@property (nonatomic, weak) IBOutlet UILabel *billAmount;
@property (nonatomic, weak) IBOutlet UILabel *tipsAmount;

@end
