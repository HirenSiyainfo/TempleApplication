//
//  POCloseOrderCell.h
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POCloseOrderCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel *poNo;
@property(nonatomic,weak)IBOutlet UILabel *invoiceNo;
@property(nonatomic,weak)IBOutlet UILabel *deliveryDate;
@property(nonatomic,weak)IBOutlet UILabel *closeDate;

@end
