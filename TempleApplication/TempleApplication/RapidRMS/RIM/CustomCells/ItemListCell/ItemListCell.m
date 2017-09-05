//
//  ItemListCell.m
//  RapidRMS
//
//  Created by Siya on 15/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemListCell.h"

@implementation ItemListCell
@synthesize lblBarcode,lblItemName;


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
