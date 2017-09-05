//
//  InvnetoryInCustomCell.h
//  I-RMS
//
//  Created by Siya Infotech on 17/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingDeliveryCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblBarcode;
@property (nonatomic, weak) IBOutlet UILabel *lblItemName;
@property (nonatomic, weak) IBOutlet UILabel *lblQTY;
@property (nonatomic, weak) IBOutlet UITextField *txtReOrder;
@property (nonatomic, weak) IBOutlet UITextField *txtCostPrice;
@property (nonatomic, weak) IBOutlet UITextField *txtSalesPrice;
@property (nonatomic, weak) IBOutlet UITextField *txtProfit;
@property (nonatomic, weak) IBOutlet UITextField *txtRemarks;
// swipe view control
@property (nonatomic, weak) IBOutlet UIView *viewOperation;
@property (nonatomic, weak) IBOutlet UIButton *btnEdit;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic, weak) IBOutlet UIButton *btnCopy;

@property (nonatomic, weak) IBOutlet UIButton *btnBacktoOrder;
@property (nonatomic, weak) IBOutlet UILabel *lblbacktitle;
@property (nonatomic, weak) IBOutlet UIImageView *imgBackOrder;

@property (nonatomic, weak) IBOutlet UIImageView *imgBackground;
@property (nonatomic, weak) IBOutlet UIButton *btnSelection;

@end
