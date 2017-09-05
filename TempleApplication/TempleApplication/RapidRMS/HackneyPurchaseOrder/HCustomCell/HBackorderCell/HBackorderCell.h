//
//  HBackorderCell.h
//  RapidRMS
//
//  Created by Siya on 19/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBackorderCell : UITableViewCell


@property (nonatomic, weak) IBOutlet UILabel *lblItemName;
@property (nonatomic, weak) IBOutlet UILabel *lblBarcode;

@property (nonatomic, weak) IBOutlet UIImageView *imgChecked;

@end
