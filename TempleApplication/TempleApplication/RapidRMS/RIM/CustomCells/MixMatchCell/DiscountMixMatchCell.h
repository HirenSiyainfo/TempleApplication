//
//  DiscountMixMatchCellTableViewCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 13/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscountMixMatchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblSelectedItemScheme;
@property (nonatomic, weak) IBOutlet UILabel *lblCategoryDiscountScheme;
@property (nonatomic, weak) IBOutlet UILabel *lblSelectedGroupScheme;

@property (nonatomic, weak) IBOutlet UIButton *btnGetItemScheme;
@property (nonatomic, weak) IBOutlet UISwitch *switchCategoryOnOff;


@end
