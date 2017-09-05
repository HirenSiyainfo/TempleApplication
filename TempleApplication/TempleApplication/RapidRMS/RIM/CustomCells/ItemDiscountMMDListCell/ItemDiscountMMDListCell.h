//
//  ItemDiscountMMDListCell.h
//  RapidRMS
//
//  Created by Siya9 on 30/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemDiscountMMDListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lblDiscountName;
@property (nonatomic, weak) IBOutlet UILabel *lblDiscountEndDate;
@property (nonatomic, weak) IBOutlet UIButton *btnDiscountRemove;
@property (nonatomic, weak) IBOutlet UIButton *btnDiscountInfo;
@end
