//
//  SubDeptItemCollectionCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubDeptItemCollectionCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *itemName;
@property (nonatomic, weak) IBOutlet UILabel *itemNameNoImg;

@property (nonatomic, weak) IBOutlet UILabel *itemSalesPrice;
@property (nonatomic,weak) IBOutlet AsyncImageView *itemImage;
@property (nonatomic,weak) IBOutlet UIImageView *itemNoImage;


@property (nonatomic,weak) IBOutlet UIView *bgPrice;

@end