//
//  DaySelectionOptionCell.h
//  RapidRMS
//
//  Created by Siya9 on 23/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DaySelectionChanged)(NSInteger index);
@interface DaySelectionOptionCell : UITableViewCell

@property (nonatomic) int intValidDays;
@property (nonatomic, strong) DaySelectionChanged daySelectionChanged;
-(void)resetDaySelectionButtons;
@end
