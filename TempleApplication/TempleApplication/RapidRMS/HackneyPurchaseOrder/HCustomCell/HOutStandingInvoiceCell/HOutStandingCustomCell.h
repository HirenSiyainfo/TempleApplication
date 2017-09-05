//
//  HOutStandingCustomCell.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HOutStandingCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblOrderTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblItemCount;

@end
