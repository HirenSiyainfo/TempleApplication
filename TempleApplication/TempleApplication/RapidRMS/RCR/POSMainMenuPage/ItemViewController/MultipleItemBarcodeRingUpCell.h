//
//  MultipleItemBarcodeRingUpCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 9/15/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultipleItemBarcodeRingUpCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *itemName;
@property (nonatomic,weak) IBOutlet UILabel *itemPrice;
@property (nonatomic,weak) IBOutlet UILabel *itemQty;
@property (nonatomic,weak) IBOutlet UILabel *department;
@property (nonatomic,weak) IBOutlet AsyncImageView *itemImage;


@end
