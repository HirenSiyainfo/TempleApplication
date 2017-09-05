//
//  DepartmentCollectionCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/30/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DepartmentCollectionCell : UICollectionViewCell
@property (nonatomic,weak) IBOutlet UILabel *departMentName;
@property (nonatomic,weak) IBOutlet AsyncImageView *deptImage;
@property (nonatomic,weak) IBOutlet UIImageView *deptImageNoImg;
@property (nonatomic,weak) IBOutlet UILabel *departMentNameNoImg;


@end
