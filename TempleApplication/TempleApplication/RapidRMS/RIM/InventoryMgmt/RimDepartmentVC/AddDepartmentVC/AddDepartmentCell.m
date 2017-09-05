//
//  AddDepartmentCell.m
//  RapidRMS
//
//  Created by Siya9 on 06/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "AddDepartmentCell.h"

@implementation AddDepartmentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.txtInput) {
        self.txtInput.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, self.txtInput.bounds.size.height)];
        self.txtInput.leftViewMode = UITextFieldViewModeAlways;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
