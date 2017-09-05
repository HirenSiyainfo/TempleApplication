//
//  DiscountMixMatchCellTableViewCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 13/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "AppropriatePriceLevelCell.h"
#import <QuartzCore/QuartzCore.h>
#import "RimsController.h"
#import "RmsDbController.h"
#import "RIMNumberPadPopupVC.h"


@interface AppropriatePriceLevelCell () <UITextFieldDelegate>

@property (nonatomic, strong) RimsController *rimsController;
@property (nonatomic, strong) RmsDbController * rmsDbController;

@end

@implementation AppropriatePriceLevelCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)refreshAppropriatePriceCell
{
    self.productName.text = self.pricingDictionary [@"PriceQtyType"];
    if ([self.productName.text.lowercaseString isEqualToString:@"pack"]) {
        self.imgProduct.image = [UIImage imageNamed:@"RIM_UnitType_Pack_blue"];
    }
    else if ([self.productName.text.lowercaseString isEqualToString:@"case"]) {
        self.imgProduct.image = [UIImage imageNamed:@"RIM_UnitType_Case_blue"];
    }
    else {
        self.imgProduct.image = [UIImage imageNamed:@"RIM_UnitType_Single_blue"];
    }
    self.productName.text = self.productName.text.uppercaseString;
    
    if(!([self.pricingDictionary [@"Qty"] intValue] == 0)){
        self.qty.text = [NSString stringWithFormat:@"%@",self.pricingDictionary [@"Qty"]];
    }
    else{
         self.qty.text=@"";
    }
   
    
    if(!([self.pricingDictionary [@"Cost"] floatValue] == 0.00)){
        self.costPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"Cost"] floatValue]];
    }
    else{
        self.costPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"Cost"] floatValue]];
    }
    
    if (self.isMargin) {
        self.profit.text=[self calculateMarginCost:[self.pricingDictionary [@"Cost"] floatValue] Sales:[self.pricingDictionary [@"UnitPrice"] floatValue]];
    }
    else{
        self.profit.text=[self calculateMarkUpCost:[self.pricingDictionary [@"Cost"] floatValue] Sales:[self.pricingDictionary [@"UnitPrice"] floatValue]];
    }
    
    if(!([self.pricingDictionary [@"UnitPrice"] floatValue] == 0.00)){
        self.unitPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"UnitPrice"] floatValue]];
    }
    else{
        self.unitPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"UnitPrice"] floatValue]];
    }
    
    if(!([self.pricingDictionary [@"PriceA"] floatValue] == 0.00)){
        self.priceLevelA.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"PriceA"] floatValue]];
    }
    else{
        self.priceLevelA.text=@"";
    }
    
    
    if(!([self.pricingDictionary [@"PriceB"] floatValue] == 0.00)){
        self.priceLevelB.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"PriceB"] floatValue]];
    }
    else{
        self.priceLevelB.text=@"";
    }
    
    if(!([self.pricingDictionary [@"PriceC"] floatValue] == 0.00)){
        self.priceLevelC.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"PriceC"] floatValue]];
    }
    else{
        self.priceLevelC.text=@"";
    }
    
    if ([self.pricingDictionary [@"IsPackCaseAllow"] intValue] == 0) {
        [self.allowPackageType setOn:NO ];
    }
    else{
        [self.allowPackageType setOn:YES ];
    }
    
    if([self.pricingDictionary [@"ApplyPrice"] isEqualToString:@"UnitPrice"]){
        [self selectedPriceLevel:self.unitPriceBtn];
    }
    else if([self.pricingDictionary [@"ApplyPrice"] isEqualToString:@"PriceA"]){
        [self selectedPriceLevel:self.aLevelBtn];
    }
    else if([self.pricingDictionary [@"ApplyPrice"] isEqualToString:@"PriceB"]){
        [self selectedPriceLevel:self.bLevelBtn];
    }
    else if([self.pricingDictionary [@"ApplyPrice"] isEqualToString:@"PriceC"]){
        [self selectedPriceLevel:self.cLevelBtn];
    }
}
- (NSString *)calculateMarginCost:(float)costPrice Sales:(float)salesPrice{
    float dProfitAmt=0;
    dProfitAmt=(1 - (costPrice/salesPrice)) * 100;
    NSString * marging=[NSString stringWithFormat:@"%.2f",dProfitAmt];
    if([marging isEqualToString:@"nan"] || [marging isEqualToString:@"-inf"] || [marging isEqualToString:@"inf"] || [marging isEqualToString:@"-100.00"])
    {
        marging = @"0.00";
    }
    return marging;
}
- (NSString *)calculateMarkUpCost:(float)costPrice Sales:(float)salesPrice{
    float dProfitAmt=0;
    float dsellingAmt=salesPrice;
    float dcostAmt=costPrice;
    NSString * markup;
    if(dcostAmt == 0){
        dProfitAmt=((dsellingAmt-dcostAmt)*100);
        markup = [NSString stringWithFormat:@"%.2f",dProfitAmt];
    }
    else{
        dProfitAmt=((dsellingAmt-dcostAmt)*100)/dcostAmt;
        markup = [NSString stringWithFormat:@"%.2f",dProfitAmt];
    }
    return markup;
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField == self.qty) {
        [self showInputPriceingView:textField];
    }
    else if(textField != self.qty && [self.PriceChangeInfoPricingDelegate willChangeItemQtyOHat:(int)self.cellIndex.row]){
        [self showInputPriceingView:textField];
    }
    else{
        if (self.cellIndex.row == 1) {
            [self.PriceChangeInfoPricingDelegate showMessageOfChangePriceTitle:@"Item Management" withMessage:@"Please Enter No of Items for Case."];
        }
        else
        {
            [self.PriceChangeInfoPricingDelegate showMessageOfChangePriceTitle:@"Item Management" withMessage:@"Please Enter No of Items for Pack."];
        }
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.PriceChangeInfoPricingDelegate setCurrentEdintingViewWithTextField:textField];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.PriceChangeInfoPricingDelegate setCurrentEdintingViewWithTextField:nil];
    NSString *inputValue = [textField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    [self didEnter:textField inputValue:@(inputValue.intValue)];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)unitPriceClicked:(id)sender{
    [self.pricingDictionary setValue:@"UnitPrice" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.unitPriceBtn];
}

-(IBAction)aLevelClicked:(id)sender{
    [self.pricingDictionary setValue:@"PriceA" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.aLevelBtn];
}

-(IBAction)bLevelClicked:(id)sender{
    [self.pricingDictionary setValue:@"PriceB" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.bLevelBtn];
}

-(IBAction)cLevelClicked:(id)sender{
    [self.pricingDictionary setValue:@"PriceC" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.cLevelBtn];
}

-(void)selectedPriceLevel:(UIButton *)selectedButton{
    self.unitPriceBtn.selected = NO;
    self.aLevelBtn.selected = NO;
    self.bLevelBtn.selected = NO;
    self.cLevelBtn.selected = NO;
    selectedButton.selected = YES;
    if (selectedButton.tag == 111)
        self.btnPriceLevel.selected = FALSE;
    else
        self.btnPriceLevel.selected = TRUE;
}

- (void)priceAddBtn{
     [self.PriceChangeInfoPricingDelegate.currentEditingView resignFirstResponder];
}
-(void)showInputPriceingView:(UITextField *)textField {
    if ((textField == self.qty) || (textField == self.costPrice) || (textField == self.profit) || (textField == self.unitPrice) || (textField == self.priceLevelA) || (textField == self.priceLevelB) || (textField == self.priceLevelC)){
        NumberPadPickerTypes inputType = NumberPadPickerTypesPrice;
        if (textField == self.self.profit) {
            inputType = NumberPadPickerTypesPercentage;
        }
        else if (textField == self.self.qty) {
            inputType = NumberPadPickerTypesQTY;
        }

        RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:inputType NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
            [self didEnter:inputView inputValue:numInput];
        } NumberPadColseInput:^(UIViewController *popUpVC) {
            [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        }];
        objRIMNumberPadPopupVC.inputView = textField;
        [objRIMNumberPadPopupVC presentVCForRightSide:(UIViewController *)self.PriceChangeInfoPricingDelegate WithInputView:textField];
//        [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:(UIViewController *)self.PriceChangeInfoPricingDelegate sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
    }
}
# pragma mark - RIMNumberPadPopupVC Method

-(void)didEnter:(id)inputControl inputValue:(NSNumber *)inputValue{
    UITextField *inputTextField = (UITextField *)inputControl;
    NSString *tempValue = [NSString stringWithFormat:@"%.2f",inputValue.floatValue];
    PricingSectionItem PricingValueType=0;
    if(inputTextField.tag == 100 || (inputTextField.tag == 101) || (inputTextField.tag == 102)){
        PricingValueType=PricingSectionItemNoOfQty;
    }
    else if(inputTextField.tag == 200){
        PricingValueType=PricingSectionItemCost;
    }
    else if(inputTextField.tag == 300){
        PricingValueType=PricingSectionItemProfit;
    }
    else if(inputTextField.tag == 400){
        PricingValueType=PricingSectionItemSales;
        [self.pricingDictionary setValue:tempValue forKeyPath:@"UnitPrice"];
    }
    else if(inputTextField.tag == 500){
        [self.pricingDictionary setValue:tempValue forKeyPath:@"PriceA"];
    }
    else if(inputTextField.tag == 600){
        [self.pricingDictionary setValue:tempValue forKeyPath:@"PriceB"];
    }
    else if(inputTextField.tag == 700){
        [self.pricingDictionary setValue:tempValue forKeyPath:@"PriceC"];
    }

    [self.PriceChangeInfoPricingDelegate didPriceChangeOf:PricingValueType inputValue:inputValue ValueIndex:(int)self.cellIndex.row];
}

@end
