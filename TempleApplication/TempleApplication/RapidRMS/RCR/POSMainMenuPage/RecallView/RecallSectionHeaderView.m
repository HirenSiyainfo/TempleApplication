//
//  RecallSectionHeaderView.m
//  RapidRMS
//
//  Created by siya-IOS5 on 10/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RecallSectionHeaderView.h"

@implementation RecallSectionHeaderView


-(instancetype)initWithFrame:(CGRect)frame  withHeaderTitle:(NSString *)headerTitle
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *headerBackGroundView = [[UIImageView alloc] initWithFrame:frame];
        UIImage *stretchableImage  =  [[UIImage imageNamed:@"recallsectionheader.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,200,0,0)];
        headerBackGroundView.image = stretchableImage;
        [self addSubview:headerBackGroundView];
        
        UIImageView *bulletImageView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 19, 5, 5)];
        bulletImageView.image = [UIImage imageNamed:@"bullet.png"];
        [self addSubview:bulletImageView];
        
        UILabel *sectionTitleHeader = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 200, 20)];
        sectionTitleHeader.textColor = [UIColor blackColor];
        sectionTitleHeader.font = [UIFont fontWithName:@"Lato" size:14.0];
        sectionTitleHeader.text = headerTitle;
        [self addSubview:sectionTitleHeader];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
