//
//  RecallCustomCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/3/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecallCustomCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *invoiceNo;
@property (nonatomic,weak) IBOutlet UILabel *invoiceDate;
@property (nonatomic,weak) IBOutlet UILabel *amount;
@property (nonatomic,weak) IBOutlet UILabel *registerName;
@property (nonatomic,weak) IBOutlet UILabel *remarks;
@property (nonatomic,weak) IBOutlet UIButton *btnHoldInvoicePrint;

- (IBAction)btn_Print:(id)sender;


@end
