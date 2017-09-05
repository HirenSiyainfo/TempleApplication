//
//  DepartmentSelectionCell.h
//  RapidRMS
//
//  Created by Siya9 on 21/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DepartmentSelectionCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lblDeptName;
@property (nonatomic, weak) IBOutlet UILabel *lblDoNotApply;
@property (nonatomic, weak) IBOutlet UIImageView *imgIsSelected;
@end
