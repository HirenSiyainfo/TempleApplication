//
//  DashBoardCollectionCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DashBoardCollectionCell.h"

@implementation DashBoardCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setSelected:(BOOL)selected{
    super.selected = selected;
}
@end
