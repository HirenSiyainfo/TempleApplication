//
//  ItemInfoImageCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 30/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ItemInfoImageCell : UITableViewCell

@property (nonatomic, weak) IBOutlet AsyncImageView * asyncImageVDetail;
@property (nonatomic, weak) IBOutlet UIButton * btnValue;
@end
