//
//  InvnetoryInCustomCell.h
//  I-RMS
//
//  Created by Siya Infotech on 17/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvnetoryInCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet AsyncImageView * imgItem;
@property (nonatomic, weak) IBOutlet UILabel *lblInventoryName;
@property (nonatomic, weak) IBOutlet UILabel *lblBarcode;
@property (nonatomic, weak) IBOutlet UITextField *txtCostPrice;
@property (nonatomic, weak) IBOutlet UITextField *txtSellingPrice;
@property (nonatomic, weak) IBOutlet UITextField *txtAvaQTY;
@property (nonatomic, weak) IBOutlet UITextField *txtAddQTY;

// swipe view control
@property (nonatomic, weak) IBOutlet UIView *viewOperation;
@property (nonatomic, weak) IBOutlet UIButton *btnEdit;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic, weak) IBOutlet UIButton *btnCopy;

@end
