//
//  PaxDetailReportCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 1/28/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaxDetailReportCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *salesAmount;
@property(nonatomic,weak) IBOutlet UILabel *salesCount;
@property(nonatomic,weak) IBOutlet UILabel *returnAmount;
@property(nonatomic,weak) IBOutlet UILabel *returnCount;



@end
