//
//  AddDepartmentCell.h
//  RapidRMS
//
//  Created by Siya9 on 06/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddDepartmentModel.h"

@interface AddDepartmentCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel * lblTitle;
@property (nonatomic, weak) IBOutlet UISwitch * swiOnOff;
@property (nonatomic, weak) IBOutlet UIButton * btnDropDown;
@property (nonatomic, weak) IBOutlet UITextField * txtInput;
@property (nonatomic) DepartmentInfoCell rowType;

@end
