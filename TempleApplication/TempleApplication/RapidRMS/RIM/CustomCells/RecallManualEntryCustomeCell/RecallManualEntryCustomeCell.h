//
//  ManualEntryCustomCell.h
//  RapidRMS
//
//  Created by Siya on 13/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecallManualEntryCustomeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblVendorName;
@property (nonatomic, weak) IBOutlet UILabel *lblInvoiceNo;
@property (nonatomic, weak) IBOutlet UILabel *lblManualEntryPONo;
@property (nonatomic, weak) IBOutlet UILabel *lblDateReceived;
@property (nonatomic, weak) IBOutlet UILabel *lblDateStarted;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;

@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic, weak) IBOutlet UIView *viewOperation;

@end
