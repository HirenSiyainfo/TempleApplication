//
//  ItemPackageTypeCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 2/27/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemPackageTypeCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *itemPrice;
@property (nonatomic,weak) IBOutlet UILabel *itemQty;
@property (nonatomic,weak) IBOutlet UILabel *department;
@property (nonatomic,weak) IBOutlet AsyncImageView *itemImage;

@end
