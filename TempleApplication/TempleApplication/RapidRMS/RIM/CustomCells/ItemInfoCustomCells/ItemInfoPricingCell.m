//
//  ItemInfoPricingCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 21/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemInfoPricingCell.h"
#import "ItemPricingVC.h"
#import "RmsDbController.h"
#import "RIMNumberPadPopupVC.h"

@implementation ItemInfoPricingCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.txtInputSingle.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, self.txtInputSingle.bounds.size.height)];
    self.txtInputSingle.leftViewMode = UITextFieldViewModeAlways;
    
    self.txtInputCase.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, self.txtInputSingle.bounds.size.height)];
    self.txtInputCase.leftViewMode = UITextFieldViewModeAlways;
    
    self.txtInputPack.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, self.txtInputSingle.bounds.size.height)];
    self.txtInputPack.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - UITextFieldDelegate -

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    if (self.cellType == PricingSectionItemQty) {
        textField.text=@"";
    }
    else if (self.cellType == PricingSectionItemNoOfQty){
        textField.text=@"";
    }
    else{
        textField.text=@"$0.00";
    }
    
    int index=0;
    if (textField == self.txtInputSingle) {
        index=0;
    }
    else if (textField == self.txtInputCase){
        index=1;
    }
    else if (textField == self.txtInputPack){
        index=2;
    }
    [self.priceChangeDelegate didPriceChangeOf:self.cellType inputValue:@0.00 ValueIndex:index];
    return NO;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.cellType == PricingSectionItemCost || self.cellType == PricingSectionItemProfit || self.cellType == PricingSectionItemSales) {
        RmsDbController *rmsDbController = [RmsDbController sharedRmsDbController];
        BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
        if (!hasRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [rmsDbController popupAlertFromVC:(UIViewController *)self.priceChangeDelegate title:@"User Rights" message:@"You don't have rights to change item information. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return NO;
        }
    }

//    if(IsPhone()){
//        if (self.priceChangeDelegate.currentEditingView) {
//            [self.priceChangeDelegate.currentEditingView resignFirstResponder];
//            return NO;
//        }
//        else{
//            if ((textField == self.txtInputCase || textField == self.txtInputPack) && self.cellType == PricingSectionItemQty) {
//                if(textField == self.txtInputCase && [self.priceChangeDelegate willChangeItemQtyOHat:1]){
//                    [self InputKeybordView:textField];
//                }
//                else if (textField == self.txtInputPack && [self.priceChangeDelegate willChangeItemQtyOHat:2]){
//                    [self InputKeybordView:textField];
//                }
//                else{
//                    [self.priceChangeDelegate showMessageOfChangePriceTitle:@"Item Management" withMessage:@"Please Enter No of Items for Case."];
//                    return NO;
//                }
//            }
//            else{
//                [self InputKeybordView:textField];
//            }
//            return YES;
//        }
//    }
//    else{ // if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPad)
        if (self.cellType == PricingSectionItemUnitQty_Unit) {
            [self InputViewWeightScale:textField];
        }
        else if (self.cellType == PricingSectionItemQty){
            if(textField == self.txtInputSingle){
                [self editQtyForPackageType:textField];
            }
            else if(textField == self.txtInputCase && [self.priceChangeDelegate willChangeItemQtyOHat:1]){
                [self editQtyForPackageType:textField];
            }
            else if (textField == self.txtInputPack && [self.priceChangeDelegate willChangeItemQtyOHat:2]){
                [self editQtyForPackageType:textField];
            }
            else{
                NSString * strMassge = @"Please Enter No of Items for Pack.";
                if (textField == self.txtInputCase) {
                    strMassge = @"Please Enter No of Items for Case.";
                }
                [self.priceChangeDelegate showMessageOfChangePriceTitle:@"Item Management" withMessage:strMassge];
            }
        }
        else{
            if (self.cellType == PricingSectionItemCost || self.cellType == PricingSectionItemProfit || self.cellType == PricingSectionItemSales) {
                if(textField == self.txtInputSingle){
                    [self InputPopUpViewForCostProfitSales:textField];
                }
                else if(textField == self.txtInputCase && [self.priceChangeDelegate willChangeItemQtyOHat:1]){
                    [self InputPopUpViewForCostProfitSales:textField];
                }
                else if (textField == self.txtInputPack && [self.priceChangeDelegate willChangeItemQtyOHat:2]){
                    [self InputPopUpViewForCostProfitSales:textField];
                }
                else{
                    NSString * strMassge = @"Please Enter No of Items for Pack.";
                    if (textField == self.txtInputCase) {
                        strMassge = @"Please Enter No of Items for Case.";
                    }
                    [self.priceChangeDelegate showMessageOfChangePriceTitle:@"Item Management" withMessage:strMassge];
                }
            }
            else {
                [self InputPopUpViewForCostProfitSales:textField];
            }
        }
        return NO;
//    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.priceChangeDelegate setCurrentEdintingViewWithTextField:textField];
    textField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:153.0/255.0 alpha:1.0];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    textField.backgroundColor = [UIColor clearColor];
    if (IsPhone() && self.cellType==PricingSectionItemQty) {
        if (![self isValidValueinputView:textField]) {
            textField.text=@"";
            [self.priceChangeDelegate setCurrentEdintingViewWithTextField:nil];
            return;
        }
    }
    NSString *inputValue = [textField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    [self didEnter:textField inputValue:@(inputValue.floatValue)];
    [self.priceChangeDelegate setCurrentEdintingViewWithTextField:nil];
}
-(BOOL)isValidValueinputView:(UITextField *)inputTextField{
    BOOL isValid=TRUE;
    NSString * strQty=inputTextField.text;
    int index=0;
    if (inputTextField == self.txtInputSingle) {
        index=0;
    }
    else if (inputTextField == self.txtInputCase){
        index=1;
    }
    else if (inputTextField == self.txtInputPack){
        index=2;
    }
    int qty=[self.priceChangeDelegate willGetOfQtyValueForQtyOH:index];
    NSArray * arrCom=[strQty componentsSeparatedByString:@"."];
    if(arrCom.count == 2)
    {
        NSString * strValue=arrCom[1];
        if (strValue.length>1) {
            strValue = [strValue substringToIndex:1];
        }
        if(strValue.integerValue >= qty )
        {
            [self.priceChangeDelegate showMessageOfChangePriceTitle:@"Item Management" withMessage:@"Please enter correct quantity."];

            isValid=false;
        }
    }
    return isValid;
}
-(void)InputKeybordView:(UITextField *)textField{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(priceAddBtn)]];
    textField.inputAccessoryView = numberToolbar;
}
-(void)InputPopUpViewForCostProfitSales:(UITextField *)textField {
    NumberPadPickerTypes inputType = NumberPadPickerTypesPrice;
    if (self.cellType == PricingSectionItemProfit) {
        inputType = NumberPadPickerTypesPercentage;
    }
    else if (self.cellType == PricingSectionItemNoOfQty) {
        inputType = NumberPadPickerTypesQTY;
    }
    
    RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:inputType NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
        [self didEnter:inputView inputValue:numInput];
    } NumberPadColseInput:^(UIViewController *popUpVC) {
        [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objRIMNumberPadPopupVC.inputView = textField;
    [objRIMNumberPadPopupVC presentVCForRightSide:(UIViewController *)self.priceChangeDelegate WithInputView:textField];
//    [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:(UIViewController *)self.priceChangeDelegate sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
}
- (void)editQtyForPackageType:(UITextField *)textField{
    NumberPadPickerTypes inputType = NumberPadPickerTypesQTYFloat;
    int itemQTYOH = 2;
    if (textField == self.txtInputSingle) {
        inputType = NumberPadPickerTypesQTY;
        itemQTYOH = 0;
    }
    else if (textField == self.txtInputCase) {
        itemQTYOH = 1;
    }
    RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:inputType NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
        [self didEnter:inputView inputValue:numInput];
    } NumberPadColseInput:^(UIViewController *popUpVC) {
        [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objRIMNumberPadPopupVC.maxInput = @(1000000);
    objRIMNumberPadPopupVC.multiplierUnit = @([self.priceChangeDelegate willGetOfQtyValueForQtyOH:itemQTYOH]);
    objRIMNumberPadPopupVC.inputView = textField;
    [objRIMNumberPadPopupVC presentVCForRightSide:(UIViewController *)self.priceChangeDelegate WithInputView:textField];
//    [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:(UIViewController *)self.priceChangeDelegate sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
    
}
-(void)InputViewWeightScale:(UITextField *)textField{

    RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:NumberPadPickerTypesWeightScale NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
        [self didEnterWeightScale:inputView inputValue:numInput unitType:strInput];
    } NumberPadColseInput:^(UIViewController *popUpVC) {
        [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objRIMNumberPadPopupVC.inputView = textField;
    [objRIMNumberPadPopupVC presentVCForRightSide:(UIViewController *)self.priceChangeDelegate WithInputView:textField];
//    [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:(UIViewController *)self.priceChangeDelegate sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
}

# pragma mark - PriceInputDelegate Method -
- (void)priceAddBtn{
    [self.priceChangeDelegate.currentEditingView resignFirstResponder];
}
-(void)didEnter:(id)inputControl inputValue:(NSNumber *)inputValue{
    
    UITextField *inputTextField = (UITextField *)inputControl;
    int index=0;
    if (inputTextField == self.txtInputSingle) {
        index=0;
    }
    else if (inputTextField == self.txtInputCase){
        index=1;
    }
    else if (inputTextField == self.txtInputPack){
        index=2;
    }
    if (self.cellType == PricingSectionItemNoOfQty && inputValue.floatValue == 1 && index > 0) {
        return;
    }
    int noOfItems = [self.priceChangeDelegate willGetOfQtyValueForQtyOH:index];
    if (self.cellType == PricingSectionItemQty) {
        NSString * strInput = inputValue.stringValue;
        NSArray *stringArray = [strInput componentsSeparatedByString:@"." ];
        if(stringArray.count == 2) {
            NSInteger y = [stringArray[1] integerValue ];
            if(y >= noOfItems )
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        [self textFieldShouldBeginEditing:inputTextField];
                    };
                    [[RmsDbController sharedRmsDbController] popupAlertFromVC:(UIViewController *)self.priceChangeDelegate title:@"Item Management" message:@"Please enter correct quantity." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                });
                return;
            }
        }
    }
    [self.priceChangeDelegate didPriceChangeOf:self.cellType inputValue:inputValue ValueIndex:index];
}

#pragma mark - WeightScaleInputDelegate Method -
-(void)didEnterWeightScale:(id)inputControl inputValue:(NSNumber *)inputValue unitType:(NSString *)unitType{
    UITextField *inputTextField = (UITextField *)inputControl;
    int index=0;
    if (inputTextField == self.txtInputSingle) {
        index=0;
    }
    else if (inputTextField == self.txtInputCase){
        index=1;
    }
    else if (inputTextField == self.txtInputPack){
        index=2;
    }
    [self.priceChangeDelegate didPriceChangeOfInputWeight:inputValue InputWeightUnit:unitType ValueIndex:index];
}

@end
