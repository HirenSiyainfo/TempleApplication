//
//  ItemOptionStockCell.m
//  RapidRMS
//
//  Created by Siya on 24/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemOptionStockCell.h"

@implementation ItemOptionStockCell


- (void)awakeFromNib {
    // Initialization code
    self.textValue1.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, self.textValue1.bounds.size.height)];
    self.textValue1.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
