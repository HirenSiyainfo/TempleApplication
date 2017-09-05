//
//  AddPaymentMasterCommonCustomCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AddPaymentMasterCommonCustomCell.h"

#define AMOUNT_CHARECTERS @"0123456789."

@implementation AddPaymentMasterCommonCustomCell

- (void)awakeFromNib {
    if (self.txtValue) {
        self.txtValue.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, self.txtValue.bounds.size.height)];
        self.txtValue.leftViewMode = UITextFieldViewModeAlways;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)updatePaymentMasterCustomCell:(RapidPaymentMaster *)rapidPaymentmaster addPaymentField:(AddPaymentField)addPaymentField
{
    currentField = addPaymentField;
    switch (addPaymentField) {
            
        case PaymentNameField:
            self.txtValue.text = rapidPaymentmaster.paymentName;
            self.imgBg.hidden  = YES;

            break;
            
        case PaymentCodeField:
            self.txtValue.text =  rapidPaymentmaster.payCode ;
            self.imgBg.hidden  = YES;

            break;
            
        case PaymentTypeField:
            self.txtValue.text =  rapidPaymentmaster.cardIntType ;
            self.imgBg.hidden  = NO;
            self.imgBg.image = [UIImage imageNamed:@"RIM_DropDown_Bg"];
            self.imgBg.highlighted = [UIImage imageNamed:@"RIM_DropDown_Bg_sel"];

            [self.txtValue setEnabled:YES];
            break;
            
        case SurchargeCheckBox:
            break;
            
        case SurchargeDollorType:
            break;

        case SurchargePercentageType:
            break;

        case SurchargeAmount:
            self.txtValue.text = rapidPaymentmaster.surchargeAmount.stringValue;
            break;
            
        case DropCheckBox:
            break;
            
        default:
            break;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.addPaymentMasterCommonCustomCellDelegate addTextFieldAtIndexPath:self.currentCellIndexpath withValue:textField.text ];
    if (self.currentCellIndexpath.row == 2) {
        return FALSE;
    }
    else if (currentField == SurchargeAmount) {
        
        RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:self.pickerType NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
            if(numInput.floatValue > 0) {
                textField.text = numInput.stringValue;
            }
            [self textFieldDidEndEditing:textField];
        } NumberPadColseInput:^(UIViewController *popUpVC) {
            [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        }];
        objRIMNumberPadPopupVC.inputView = textField;
        [objRIMNumberPadPopupVC presentVCForRightSide:(UIViewController *)self.addPaymentMasterCommonCustomCellDelegate WithInputView:textField];
        //            [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:(UIViewController *)self.addPaymentMasterCommonCustomCellDelegate sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
        return FALSE;
    }
    return TRUE;
}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (currentField == PaymentTypeField)
//    {
//        [self.txtValue setEnabled:NO];
//
//    }
//    if (currentField == SurchargeAmount) {
//        NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:AMOUNT_CHARECTERS].invertedSet;
//        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
//        if ([textField.text rangeOfString:string].location != NSNotFound && [string  isEqualToString:@"."])
//        {
//            return NO;
//        }
//        else {
//            if ([string isEqualToString:filtered]) {
//                NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//                [self.addPaymentMasterCommonCustomCellDelegate addTextFieldAtIndexPath:self.currentCellIndexpath withValue:searchString];
//            }
//            return [string isEqualToString:filtered];
//        }
//    }
//    NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    [self.addPaymentMasterCommonCustomCellDelegate addTextFieldAtIndexPath:self.currentCellIndexpath withValue:searchString];
//    return YES;
//}
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    
//}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self.addPaymentMasterCommonCustomCellDelegate addTextFieldAtIndexPath:self.currentCellIndexpath withValue:textField.text ];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.addPaymentMasterCommonCustomCellDelegate addTextFieldAtIndexPath:self.currentCellIndexpath withValue:textField.text];
}

@end
