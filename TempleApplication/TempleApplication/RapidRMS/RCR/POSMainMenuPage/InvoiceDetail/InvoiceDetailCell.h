//
//  InvoiceDetailCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/4/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvoiceDetailCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *registerInvoiceNo;
@property(nonatomic,weak) IBOutlet UILabel *dateTime;
@property(nonatomic,weak) IBOutlet UILabel *payment;
@property(nonatomic,weak) IBOutlet UILabel *total;
@property(nonatomic,weak) IBOutlet UILabel *change;
@property(nonatomic,weak) IBOutlet UILabel *voidLable;
@end
