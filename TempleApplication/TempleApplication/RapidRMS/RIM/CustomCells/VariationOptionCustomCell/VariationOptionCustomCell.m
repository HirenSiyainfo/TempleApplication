//
//  VariationOptionCustomCell.m
//  RapidRMS
//
//  Created by Siya on 01/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "VariationOptionCustomCell.h"

@interface VariationOptionCustomCell ()<UITextFieldDelegate>

@end

@implementation VariationOptionCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.txtVariationOption.delegate=self;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {

    [self.variationOptionCellDelegate startEdtingItemVariationItem:[self superTableView] inToInput:textField];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{

    UITableView *tblview =[self superTableView];
    
    [textField resignFirstResponder];
    
    [self.variationOptionCellDelegate didChangeOption:self.indexPath name:textField.text tableView:tblview];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(IBAction)removeVerationOption:(id)sender{
    
    UITableView *tblview =[self superTableView];
    [self.variationOptionCellDelegate didRemoveOption:self.indexPath tableView:tblview];
}
- (UITableView *)superTableView
{
    return (UITableView *)[self findTableView:self];
}

- (UIView *)findTableView:(UIView *)view
{
    if (view.superview && [view.superview isKindOfClass:[UITableView class]]) {
        return view.superview;
    }
    return [self findTableView:view.superview];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
