//
//  DisplayModuleCell.h
//  RapidRMS
//
//  Created by Siya on 17/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayModuleCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblRegName;
@property (nonatomic, weak) IBOutlet UILabel *lblCount;
@property (nonatomic, weak) IBOutlet UIView *viewBg;
@property (nonatomic, weak) IBOutlet UISwitch *moduleSwitch;
@property (nonatomic, weak) IBOutlet UIView *viewBorder;

@end
