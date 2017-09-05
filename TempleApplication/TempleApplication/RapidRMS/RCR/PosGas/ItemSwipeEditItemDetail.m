//
//  ItemSwipeEditItemDetail.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/27/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemSwipeEditItemDetail.h"

@implementation ItemSwipeEditItemDetail

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)configureItemDetailWithDictionary:(NSMutableDictionary *)itemDictionary
{
    self.itemName.text= itemDictionary[@"itemName"];
    if ([itemDictionary[@"ItemNo"] isEqualToString:@""])
    {
        self.itemNo.text= @"  -  ";
    }
    else
    {
        self.itemNo.text= itemDictionary[@"ItemNo"];
    }
    if ([itemDictionary[@"Barcode"] length] > 0) {
        self.upc.text=itemDictionary[@"Barcode"];
    }
    NSString *imgUrl = itemDictionary[@"itemImage"];
    self.itemImage.backgroundColor = [UIColor clearColor];
    self.itemImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.itemImage.layer.cornerRadius = 5.0;
    if ([imgUrl isEqualToString:@""])
    {
        self.itemImage.image = [UIImage imageNamed:@"RCR_NoImageForRingUp.png"];
    }
    else
    {
        [self.itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imgUrl]]];
    }
}

@end
