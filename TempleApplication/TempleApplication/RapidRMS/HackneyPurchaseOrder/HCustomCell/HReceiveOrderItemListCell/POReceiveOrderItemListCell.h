//
//  POReceiveOrderItemListCell.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POReceiveOrderItemListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblItemName;
@property (nonatomic, weak) IBOutlet UILabel *lblUpc;
@property (nonatomic, weak) IBOutlet UILabel *lblcount;
@property (nonatomic, weak) IBOutlet UIButton *btnCheck;

@end
