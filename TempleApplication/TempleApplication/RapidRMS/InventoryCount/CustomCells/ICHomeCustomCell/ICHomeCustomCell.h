//
//  ICHomeCustomCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 31/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICHomeCustomCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *selectedVCBg;
@property (nonatomic, weak) IBOutlet UILabel *viewControllerName;
@property (nonatomic, weak) IBOutlet UILabel *holdCount;

@end
