//
//  CL_StitisticItemCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CL_StatisticItemCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblItemName;
@property (nonatomic,weak) IBOutlet AsyncImageView *imgItemBG;
@property (nonatomic,weak) IBOutlet UIImageView *imgNonItemBG;


@end
