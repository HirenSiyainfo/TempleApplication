//
//  PosMenuCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 12/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PosMenuCell.h"

@interface PosMenuCell ()

@property (nonatomic, weak) IBOutlet UIImageView *menuItemImageView;
@property (nonatomic, weak) IBOutlet UILabel *menuItemTitleLabel;

@end

@implementation PosMenuCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setOpasityforCell :(float)alphaOpasity
{
    self.menuItemImageView .alpha = alphaOpasity;
}

- (void)setMenuItemTitle:(NSString*)menuTitle normalImage:(NSString*)normalImage selectedImage:(NSString*)selectedImage withOpasity:(float)alpha {
    self.menuItemImageView.image = [UIImage imageNamed:normalImage];
    self.menuItemImageView.highlightedImage = [UIImage imageNamed:selectedImage];
    self.menuItemImageView .alpha = 1.0;
    self.menuItemTitleLabel.text = menuTitle;
}
@end
