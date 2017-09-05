//
//  PosMenuCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 12/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PosMenuCell : UICollectionViewCell
- (void)setMenuItemTitle:(NSString*)menuTitle normalImage:(NSString*)normalImage selectedImage:(NSString*)selectedImage withOpasity:(float)alpha;
-(void)setOpasityforCell :(float)alphaOpasity;

@property (nonatomic, weak) IBOutlet UILabel *recallCountLabel;
@property (nonatomic, weak) IBOutlet UIImageView *recallNotificationImage;

@end
