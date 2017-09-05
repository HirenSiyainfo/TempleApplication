//
//  FavouriteItemCollectionCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/7/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouriteItemCollectionCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet AsyncImageView *itemImage;
@property (nonatomic, weak) IBOutlet UILabel *salesPriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemNameLabelNoImg;
@property (nonatomic, weak) IBOutlet UIImageView *itemImageNoImg;

@end
