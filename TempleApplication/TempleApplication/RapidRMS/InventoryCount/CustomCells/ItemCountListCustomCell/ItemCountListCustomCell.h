//
//  ICHomeCustomCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 31/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCountListCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *itemManualQtyOH;
@property (nonatomic, weak) IBOutlet UILabel *itemManualCasePack;
@property (nonatomic, weak) IBOutlet UILabel *itemName;
@property (nonatomic, weak) IBOutlet UILabel *itemBarcode;
@property (nonatomic, weak) IBOutlet UILabel *itemSalesPrice;
@property (nonatomic, weak) IBOutlet UILabel *itemCostPrice;
@property (nonatomic, weak) IBOutlet UILabel *itemDiscount;
@property (nonatomic, weak) IBOutlet UILabel *itemQtyOH;
@property (nonatomic, weak) IBOutlet UILabel *itemCasePack;
@property (nonatomic, weak) IBOutlet UIImageView *imageBackGround;
//@property (nonatomic, weak) IBOutlet UIView *dividerView;
@property (nonatomic, weak) IBOutlet UIImageView *dividerView;

@property (nonatomic, weak) IBOutlet UILabel *itemNumber;
@property (nonatomic, weak) IBOutlet UIImageView *imgSelected;



@end