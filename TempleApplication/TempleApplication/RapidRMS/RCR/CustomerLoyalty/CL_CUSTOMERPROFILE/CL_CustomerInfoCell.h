//
//  CL_CustomerInfoCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 16/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CL_CustomerInfoCell : UICollectionViewCell

@property (nonatomic , weak) IBOutlet UILabel *lblName ;
@property (nonatomic , weak) IBOutlet UILabel *lblDetail ;
@property (nonatomic , weak) IBOutlet UIImageView *imgBg ;

@end
