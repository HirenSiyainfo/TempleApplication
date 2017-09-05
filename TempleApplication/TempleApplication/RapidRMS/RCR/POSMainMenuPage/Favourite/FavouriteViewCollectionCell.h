//
//  FavouriteViewCollectionCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouriteViewCollectionCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *itemImage;
@property (nonatomic, weak) IBOutlet UILabel *lblSalesPrice;
@property (nonatomic, weak) IBOutlet UILabel *lblItemName;

@end
