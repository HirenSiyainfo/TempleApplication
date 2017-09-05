//
//  ItemSideInfoImageCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 04/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemSideInfoImageCell : UITableViewCell

@property (nonatomic, weak) IBOutlet AsyncImageView * asyItemImage_Item;

@property (nonatomic, weak) IBOutlet UILabel * lblName;
@property (nonatomic, weak) IBOutlet UILabel * lblUPC;
@property (nonatomic, weak) IBOutlet UILabel * lblDept;
@property (nonatomic, weak) IBOutlet UILabel * lblQty;

@property (nonatomic, weak) IBOutlet UIButton * btnSelectImage;
@end
