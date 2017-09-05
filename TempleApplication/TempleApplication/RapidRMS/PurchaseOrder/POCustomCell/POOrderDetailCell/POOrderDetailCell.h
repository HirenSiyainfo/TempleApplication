//
//  POOrderDetailCell.h
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POOrderDetailCell : UITableViewCell


@property(nonatomic,weak)IBOutlet UILabel *itemName;
@property(nonatomic,weak)IBOutlet UILabel *itemBarcode;
@property(nonatomic,weak)IBOutlet UILabel *vendorName;

@property(nonatomic,weak)IBOutlet UILabel *QhSingle;
@property(nonatomic,weak)IBOutlet UILabel *QhCashPack;

@property(nonatomic,weak)IBOutlet UILabel *RqSingle;
@property(nonatomic,weak)IBOutlet UILabel *RqCashPack;

@property(nonatomic,weak)IBOutlet UIButton *checkMark;
@property(nonatomic,weak)IBOutlet UIButton *buttonAction;

@property(nonatomic,weak)IBOutlet UIView *viewOperation;
@property(nonatomic,weak)IBOutlet UIButton *editItem;
@property(nonatomic,weak)IBOutlet UIButton *btncopyItem;
@property(nonatomic,weak)IBOutlet UIButton *deleteItem;
@property(nonatomic,weak)IBOutlet UIButton *backOrder;

-(void)configureItemDetail:(NSDictionary *)dictItem withItem:(Item *)anItem;

@end
