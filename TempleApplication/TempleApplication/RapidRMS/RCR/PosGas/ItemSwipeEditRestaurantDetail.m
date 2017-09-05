//
//  ItemSwipeEditRestaurantDetail.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/27/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemSwipeEditRestaurantDetail.h"

@implementation ItemSwipeEditRestaurantDetail

- (void)awakeFromNib
{
    [self setUpCell];
}

-(void)setUpCell
{
    UIView *backGroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.backgroundView = backGroundView;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    UIImageView *selectedbackGroundView = [[UIImageView alloc]initWithFrame:self.bounds];
    self. selectedBackgroundView = selectedbackGroundView;
    self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
}
-(void)updatePrintStatus:(NSDictionary *)editDictionary diplayPrintButtonForCell:(BOOL)diplayPrintButton
{
    self.printStatus.hidden = diplayPrintButton;
    if (diplayPrintButton == FALSE)
    {
        if ([editDictionary[@"NoPrintStatus"] boolValue] == TRUE) {
            [self.printStatus setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.printStatus setImage:[UIImage imageNamed:@"checkboxBlank.png"] forState:UIControlStateNormal];
        }
    }
}
-(void)updateDineInStatus:(NSDictionary *)editDictionary
{
    if ([editDictionary[@"isDineIn"] boolValue] == TRUE) {
        self.cellLabelText.text  = @"Dine In" ;
    }
    else
    {
        self.cellLabelText.text  = @"To Go" ;
    }
}


-(IBAction)noPrintButton:(id)sender
{
    [self.itemSwipeEditRestaurantDetailDelegate didEditRestaurantItemSectionAtIndexpath:self.currentIndexpathForRestaurant];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
