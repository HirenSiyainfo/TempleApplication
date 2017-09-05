//
//  POOrderListCell.h
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POOrderListCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel *poNumber;
@property(nonatomic,weak)IBOutlet UILabel *invoiceNumber;
@property(nonatomic,weak)IBOutlet UILabel *dateTime;

@property(nonatomic,weak)IBOutlet UIButton *buttonAction;

@end
