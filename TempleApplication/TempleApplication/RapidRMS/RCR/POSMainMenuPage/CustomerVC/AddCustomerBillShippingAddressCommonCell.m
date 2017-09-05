//
//  AddCustomerBillShippingAddressCommonCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 10/14/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AddCustomerBillShippingAddressCommonCell.h"

@implementation AddCustomerBillShippingAddressCommonCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
     [self.addCustomerBillShippingAddressCommonCelldelegate didStartEditingInAddressTextField:textField withIndexPath:self.currentIndexPath];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.addCustomerBillShippingAddressCommonCelldelegate didUpdateCustomerAddressTextFieldAtIndexPath:self.currentIndexPath withValue:textField.text inTextField:textField];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.addCustomerBillShippingAddressCommonCelldelegate didStartEditingInAddressTextView:textView withIndexPath:self.currentIndexPath ];
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.addCustomerBillShippingAddressCommonCelldelegate didUpdateCustomerAddressTextViewAtIndexPath:self.currentIndexPath withValue:textView.text inTextView:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
