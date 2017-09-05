//
//  POSideMenuCustomCell.m
//  RapidRMS
//
//  Created by Siya on 23/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "POSideMenuCustomCell.h"

@interface POSideMenuCustomCell()
@property (nonatomic, weak) IBOutlet UIImageView *menuImageView;
@end

@implementation POSideMenuCustomCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configaureImageViewWithNoramalImage:(NSString *)imageName
{
    self.menuImageView.image = [UIImage imageNamed:imageName];
}

-(void)configaureImageViewWithHighlightedImage:(NSString *)imageName
{
    self.menuImageView.highlightedImage = [UIImage imageNamed:imageName];
}

@end
