//
//  CL_ItemListCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CL_ItemListCell : UITableViewCell

@property(nonatomic , weak) IBOutlet UILabel *lblItemNameAndNo;
@property(nonatomic , weak) IBOutlet UILabel *lblItemNo;
@property(nonatomic , weak) IBOutlet UILabel *lblItemUPC;
@property(nonatomic , weak) IBOutlet UILabel *lblItemVendor;
@property(nonatomic , weak) IBOutlet UILabel *lblItemPrice;
@property(nonatomic , weak) IBOutlet UILabel *lblItemInvoiceNo;

@end
