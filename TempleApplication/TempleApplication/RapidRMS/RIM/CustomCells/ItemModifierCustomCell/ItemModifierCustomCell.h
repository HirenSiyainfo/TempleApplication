//
//  InvnetoryInCustomCell.h
//  I-RMS
//
//  Created by Siya Infotech on 17/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemModifierCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet AsyncImageView *itemModifierImage;
@property (nonatomic, weak) IBOutlet UILabel *itemModifierName;

@end