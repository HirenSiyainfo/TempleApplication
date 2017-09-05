//
//  DiscountMasterListCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 5/29/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscountMasterListCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *discountTitle;
@property (nonatomic, weak) IBOutlet UILabel *discountAmount;
@property (nonatomic,weak) IBOutlet UIView *discountRoundCornerView;

@end
