//
//  HItemHistoryInfoCell.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HItemHistoryInfoCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblhistryType;
@property (nonatomic, weak) IBOutlet UILabel *lblthisweek;
@property (nonatomic, weak) IBOutlet UILabel *lbllastweek;
@property (nonatomic, weak) IBOutlet UILabel *lblthismonth;
@property (nonatomic, weak) IBOutlet UILabel *lbllastmonth;
@property (nonatomic, weak) IBOutlet UILabel *lblthisyear;
@end
