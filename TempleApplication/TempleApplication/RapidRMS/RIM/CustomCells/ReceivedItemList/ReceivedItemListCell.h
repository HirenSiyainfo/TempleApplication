//
//  ReceivedItemListCell.h
//  RapidRMS
//
//  Created by Siya on 16/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceivedItemListCell : UITableViewCell


@property (nonatomic, weak) IBOutlet AsyncImageView *itemImage;
@property (nonatomic, weak) IBOutlet UIImageView *imgBackGround;
@property (nonatomic, weak) IBOutlet UILabel *lblInventoryName;
@property (nonatomic, weak) IBOutlet UILabel *lblBarcode;
@property (nonatomic, weak) IBOutlet UITextField *txtPrice;
@property (nonatomic, weak) IBOutlet UITextField *txtQty;
@property (nonatomic, weak) IBOutlet UIImageView *imgSelected;
@property (nonatomic, weak) IBOutlet UIImageView *imgArrow;
@property (nonatomic, weak) IBOutlet UITextField *txtDiscount;
@property (nonatomic, weak) IBOutlet UIImageView *qtyBackgroundImage;

@property (nonatomic, weak) IBOutlet UILabel *lblItemNumber;
@property (nonatomic, weak) IBOutlet UITextField *txtCost;
@property (nonatomic, weak) IBOutlet UITextField *txtExtendedCost;

// swoipe view to perform edit,copy and delete item.
@property (nonatomic, weak) IBOutlet UIView *viewOperation;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;

@property (nonatomic, weak) IBOutlet UITextField *txtReceivedSingelQty;
@property (nonatomic, weak) IBOutlet UITextField *txtReceivedCasePackValue;
@property (nonatomic, weak) IBOutlet UITextField *txtCasePackValue;
@end
