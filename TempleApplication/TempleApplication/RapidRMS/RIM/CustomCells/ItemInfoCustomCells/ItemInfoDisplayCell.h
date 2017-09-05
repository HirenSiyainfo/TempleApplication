//
//  ItemInfoDisplayCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 21/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemInfoDisplayCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblCellName;
@property (nonatomic, weak) IBOutlet UITextField *txtInputValue;
@property (nonatomic, weak) IBOutlet UISwitch * swiIsDuplicate;
@property (nonatomic, weak) IBOutlet UIButton * btnValue;
@end
