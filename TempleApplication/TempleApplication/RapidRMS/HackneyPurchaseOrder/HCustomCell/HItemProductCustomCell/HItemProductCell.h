//
//  HItemProductCell.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HItemProductCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblProductName;
@property (nonatomic, weak) IBOutlet UILabel *lblProducts;
@property (nonatomic, weak) IBOutlet UILabel *lblPrice1;
@property (nonatomic, weak) IBOutlet UILabel *lblPrice2;

@property (nonatomic, weak) IBOutlet UIView *viewAddQty;
@property (nonatomic, weak) IBOutlet UILabel *lblUnitQty;
@property (nonatomic, weak) IBOutlet UILabel *lblCashQty;

@property (nonatomic, weak) IBOutlet UIButton *btnUnitQtyPlus;
@property (nonatomic, weak) IBOutlet UIButton *btnUnitQtyMinus;

@property (nonatomic, weak) IBOutlet UIButton *btnCashQtyPlus;
@property (nonatomic, weak) IBOutlet UIButton *btnCashQtyMinus;

@property (nonatomic, weak) IBOutlet UIButton *btnAddItem;
@property (nonatomic, weak) IBOutlet UILabel *lblEffectiveDate;

@end
