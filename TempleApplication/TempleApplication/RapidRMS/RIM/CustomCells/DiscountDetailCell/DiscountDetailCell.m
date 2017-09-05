//
//  DiscountDetailCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 17/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DiscountDetailCell.h"

@implementation DiscountDetailCell
{
    UITextField * currentTextField;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)configureItemDetailWithDictionary:(NSDictionary *)itemDictionary{
    NSNumber *disUnitPrice = itemDictionary[@"DIS_UnitPrice"];
    NSNumber *disQty = [itemDictionary valueForKey:@"DIS_Qty"];
    if(disUnitPrice != nil )
    {
       self.itemDisPrice.text = [self.currencyFormatter stringFromNumber:disUnitPrice];
    }
    else
    {
        self.itemDisPrice.text = @"";
    }
    
    if (disQty != nil) {
        self.itemDisQty.text = [NSString stringWithFormat:@"%@", disQty ];
    }
    else
    {
        self.itemDisQty.text = @"";
    }
    if([[itemDictionary valueForKey:@"applyTax"] isEqualToString:@"0"])
    {
        self.itemPriceWithTax.text = @"";
        self.itemPriceWithTax.hidden = YES;
        [self.applyTax setOn:NO animated:NO];
    }
    else
    {
        self.itemPriceWithTax.hidden = NO;
        self.itemPriceWithTax.text = [NSString stringWithFormat:@"$%@",[itemDictionary valueForKey:@"UnitPriceWithTax"]];
        [self.applyTax setOn:YES animated:NO];
    }
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==self.itemDisQty) {
        [self.ItemDiscountPriceDetailDelegate didChangeItemQty:self.indexPath fromSender:textField];
    }
    else{
        [self.ItemDiscountPriceDetailDelegate didChangeItemPrice:self.indexPath fromSender:textField];
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(IsPhone()){
        if(textField != self.itemDisQty){
            NSString* tmpCost = [textField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            double currentValue = tmpCost.doubleValue;
            double cents = round(currentValue * 100.0f);
            
            if (string.length) {
                for (size_t i = 0; i < string.length; i++) {
                    unichar c = [string characterAtIndex:i];
                    if (isnumber(c)) {
                        cents *= 10;
                        cents += c - '0';
                    }
                }
            } else {
                cents = floor(cents / 10);
            }
            NSString * itemPrice;
            if(cents != 0){
                NSNumber *dcost = [NSNumber numberWithFloat:cents / 100.0f];
                itemPrice = [self.currencyFormatter stringFromNumber:dcost];
            }
            else{
                itemPrice=@"";
            }
            textField.text=itemPrice;
            return NO;
        }
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    currentTextField=textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self updateinputValue];
}
-(void)InputKeybordView:(UITextField *)textField{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(priceAddBtn)]];
    textField.inputAccessoryView = numberToolbar;
}
- (void)priceAddBtn{
    [self.contentView endEditing:YES];
}
-(void)updateinputValue{
    currentTextField.backgroundColor = [UIColor clearColor];
    NSString *inputValue = [currentTextField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    if (currentTextField==self.itemDisQty) {
        [self.ItemDiscountPriceDetailDelegate didChangeItemQtyNewQTY:inputValue atIndex:(int)self.indexPath.row];
    }
    else{
        [self.ItemDiscountPriceDetailDelegate didChangeItemPriceNewPrice:inputValue atIndex:(int)self.indexPath.row];
    }
}

- (IBAction)DeleteDiscountSection:(UIButton *)sender{
    [self.ItemDiscountPriceDetailDelegate didItemDelete:self.indexPath];
}
- (IBAction)applyDiscountSection:(UISwitch *)sender{
    [self.ItemDiscountPriceDetailDelegate didItemChangeApplyTax:sender forIndexPath:self.indexPath];
}
@end
