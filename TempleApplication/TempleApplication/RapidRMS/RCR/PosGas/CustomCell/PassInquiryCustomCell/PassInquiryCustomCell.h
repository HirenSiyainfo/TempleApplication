//
//  PassInquiryCustomCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassInquiryCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *qRCodeImageView;
@property (nonatomic, weak) IBOutlet UILabel *lblPassNo;
@property (nonatomic, weak) IBOutlet UILabel *lblInvoiceNo;
@property (nonatomic, weak) IBOutlet UILabel *lblInvoiceDate;
@property (nonatomic, weak) IBOutlet UILabel *lblItemDescription;

@end
