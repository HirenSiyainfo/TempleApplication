//
//  AvailableAppsCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/9/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvailableAppsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *btnChecked;

@property (nonatomic, weak) IBOutlet UILabel *lblAvailableCount;
@property (nonatomic, weak) IBOutlet UILabel *lblDeviceName;

@end
