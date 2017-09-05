//
//  InventoryCell.h
//  I-RMS
//
//  Created by Siya Infotech on 09/08/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemDisplayVCCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *itemUpc;
@property (nonatomic, weak) IBOutlet UILabel *itemname;
@property (nonatomic, weak) IBOutlet UILabel *itemNumber;
@property (nonatomic, weak) IBOutlet UILabel *itemQty;
@property (nonatomic, weak) IBOutlet UILabel *lblItemOption;
@property (nonatomic, weak) IBOutlet UILabel *lblCase;
@property (nonatomic, weak) IBOutlet UILabel *lblPack;

@property (nonatomic, weak) IBOutlet UILabel *itemSalesPrice;
@property (nonatomic, weak) IBOutlet UILabel *itemCasePrice;
@property (nonatomic, weak) IBOutlet UILabel *itemPackPrice;

@property (nonatomic, weak) IBOutlet UIImageView *discountImage;


@property (nonatomic, weak) IBOutlet UILabel *itemDepartment;

@end
