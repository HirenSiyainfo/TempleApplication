//
//  ClockInCustomCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 5/9/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClockInCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *clockInDay;
@property (nonatomic, weak) IBOutlet UILabel *clockInDate;
@property (nonatomic, weak) IBOutlet UILabel *clockInTime;
@property (nonatomic, weak) IBOutlet UILabel *clockOutTime;
@property (nonatomic, weak) IBOutlet UILabel *totalHours;
@property (nonatomic, weak) IBOutlet UILabel *voidEntry;

@property (nonatomic,weak) IBOutlet UIButton *btnVoidUnvoid;
@property (nonatomic,weak) IBOutlet UIButton *btnEdit;

@property (nonatomic, weak) IBOutlet UIView *viewOperation;

@end
