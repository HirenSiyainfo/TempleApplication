//
//  SubDepartmentCollectionCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 12/13/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubDepartmentCollectionCell : UICollectionViewCell
@property (nonatomic,weak) IBOutlet UILabel *departMentName;
@property (nonatomic,weak) IBOutlet UILabel *departMentNameNoImage;

@property (nonatomic,weak) IBOutlet AsyncImageView *deptImage;
@property (nonatomic,weak) IBOutlet UIImageView *deptNoImage;

@property (nonatomic,weak) IBOutlet UILabel *price;
@property (nonatomic,weak) IBOutlet UIView *bgPrice;

@end
