//
//  POSideMenuCustomCell.h
//  RapidRMS
//
//  Created by Siya on 23/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POSideMenuCustomCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel *menuName;
@property(nonatomic,weak)IBOutlet UIImageView *menuImg;

-(void)configaureImageViewWithNoramalImage:(NSString *)imageName;
-(void)configaureImageViewWithHighlightedImage:(NSString *)imageName;

@end
