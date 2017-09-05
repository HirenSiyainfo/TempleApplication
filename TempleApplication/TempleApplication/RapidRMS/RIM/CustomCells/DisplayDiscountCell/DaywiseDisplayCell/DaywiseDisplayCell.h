//
//  DaywiseDiscountCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DaywiseDisplayCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *dayName;
@property (nonatomic, weak) IBOutlet UILabel *startTime;
@property (nonatomic, weak) IBOutlet UILabel *endTime;

@end
