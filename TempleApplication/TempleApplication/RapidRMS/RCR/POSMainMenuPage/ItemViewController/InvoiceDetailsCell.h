//
//  InvoiceDetailsCell.h
//  RapidRMS
//
//  Created by siya8 on 23/09/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvoiceDetailsCell : UITableViewCell

@property(nonatomic, weak)IBOutlet UILabel *invoiceNumber;
@property(nonatomic, weak)IBOutlet UILabel *itemQty;
@property(nonatomic, weak)IBOutlet UILabel *invoiceDateTime;

@end
