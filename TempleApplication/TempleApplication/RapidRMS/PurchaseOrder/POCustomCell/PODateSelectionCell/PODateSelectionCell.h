//
//  PODateSelectionCell.h
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PODateSelectionCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *selectedDate;
@property (nonatomic, weak) IBOutlet UIView *viewBorder;
@property (nonatomic, weak) IBOutlet UIButton *btnSelectDate;
@end
