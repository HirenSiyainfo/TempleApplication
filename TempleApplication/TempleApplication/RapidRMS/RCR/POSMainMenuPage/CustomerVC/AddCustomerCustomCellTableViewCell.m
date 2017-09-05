//
//  AddCustomerCustomCellTableViewCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/21/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AddCustomerCustomCellTableViewCell.h"

@implementation AddCustomerCustomCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
   // Configure the view for the selected state
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [self.addCustomerCustomCelldelegate didStartEditingInTextField:textField withIndexPath:self.currentIndexPath];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.currentIndexPath.section == 1 && self.currentIndexPath.row == 3)
    {
        [self.addCustomerCustomCelldelegate didUpdateCustomerValueAtIndexPath:self.currentIndexPath withValue:textField.text];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(!(self.currentIndexPath.section == 1 && self.currentIndexPath.row == 3))
    {
        [self.addCustomerCustomCelldelegate didUpdateCustomerValueAtIndexPath:self.currentIndexPath withValue:textField.text];
    }
}

-(IBAction)sameAsAddress:(id)sender
{
    [self.addCustomerCustomCelldelegate didSetSameAddressOfShippingAddress];
}

-(IBAction)autoGentaeCustomerNumberButton_Clicked:(id)sender
{
    [self.addCustomerCustomCelldelegate autoGenerateCustomerNumber];
}

@end
