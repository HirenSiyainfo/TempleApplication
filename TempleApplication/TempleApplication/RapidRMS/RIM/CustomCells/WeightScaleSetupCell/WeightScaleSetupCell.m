//
//  DiscountMixMatchCellTableViewCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 13/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "WeightScaleSetupCell.h"
#import "RimsController.h"
#import "RmsDbController.h"
#import "RIMNumberPadPopupVC.h"

@interface WeightScaleSetupCell () <UITextFieldDelegate>

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@end

@implementation WeightScaleSetupCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.rimsController = [RimsController sharedrimController];
    // Initialization code
    [self setTxtBoxProperty:self.qty];
    [self setTxtBoxProperty:self.costPrice];
    [self setTxtBoxProperty:self.profit];
    [self setTxtBoxProperty:self.unitPrice];
    [self setTxtBoxProperty:self.priceLevelA];
    [self setTxtBoxProperty:self.priceLevelB];
    [self setTxtBoxProperty:self.priceLevelC];
    [self setTxtBoxProperty:self.unitQty];
    self.allowPackageType.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.allowPackageType.layer.borderWidth = 0.5;
    self.allowPackageType.layer.cornerRadius = 16.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setTxtBoxProperty:(UITextField *)sender{
    sender.delegate = self;
    sender.layer.borderColor = [UIColor clearColor].CGColor;
    sender.layer.borderWidth = 0.5;
}

-(void)refreshWeightPriceCell{
    self.productName.text = self.weightDictionary [@"PriceQtyType"];
    self.productName.text = self.productName.text.uppercaseString;
    
    if(!([self.weightDictionary [@"Qty"] intValue] == 0)){
        self.qty.text = [NSString stringWithFormat:@"%@",self.weightDictionary [@"Qty"]];
    }
    else{
        self.qty.text=@"";
    }
    
//    // Unit Type
    self.unitQty.text = @"";
    if ([self.weightDictionary [@"UnitQty"] intValue] > 0) {
        self.unitQty.text = [NSString stringWithFormat:@"%d/%@",[self.weightDictionary [@"UnitQty"] intValue],self.weightDictionary [@"UnitType"]];
    }
    
    if(!([self.weightDictionary [@"Cost"] floatValue] == 0.00)){
        self.costPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.weightDictionary [@"Cost"] floatValue]];
    }
    else{
        self.costPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.weightDictionary [@"Cost"] floatValue]];
    }
    
    if(!([self.weightDictionary [@"Profit"] floatValue] == 0.00)){
        if (self.isMargin) {
            self.profit.text=[self calculateMarginCost:[self.weightDictionary [@"Cost"] floatValue] Sales:[self.weightDictionary [@"UnitPrice"] floatValue]];
        }
        else{
            self.profit.text=[self calculateMarkUpCost:[self.weightDictionary [@"Cost"] floatValue] Sales:[self.weightDictionary [@"UnitPrice"] floatValue]];
        }
        
    }
    else{
        self.profit.text = [NSString stringWithFormat:@"%.2f",[self.weightDictionary [@"Profit"] floatValue]];
    }
    
    if(!([self.weightDictionary [@"UnitPrice"] floatValue] == 0.00)){
        self.unitPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.weightDictionary [@"UnitPrice"] floatValue]];
    }
    else{
        self.unitPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.weightDictionary [@"UnitPrice"] floatValue]];
    }
    
    if(!([self.weightDictionary [@"PriceA"] floatValue] == 0.00)){
        self.priceLevelA.text = [self.rmsDbController getStringPriceFromFloat:[self.weightDictionary [@"PriceA"] floatValue]];
    }
    else{
        self.priceLevelA.text=@"";
    }
    
    
    if(!([self.weightDictionary [@"PriceB"] floatValue] == 0.00)){
        self.priceLevelB.text = [self.rmsDbController getStringPriceFromFloat:[self.weightDictionary [@"PriceB"] floatValue]];
    }
    else{
        self.priceLevelB.text=@"";
    }
    
    if(!([self.weightDictionary [@"PriceC"] floatValue] == 0.00)){
        self.priceLevelC.text = [self.rmsDbController getStringPriceFromFloat:[self.weightDictionary [@"PriceC"] floatValue]];
    }
    else{
        self.priceLevelC.text=@"";
    }
    
    if ([self.weightDictionary [@"IsPackCaseAllow"] intValue] == 0) {
        [self.allowPackageType setOn:NO ];
    }
    else{
        [self.allowPackageType setOn:YES ];
    }
    
    if([self.weightDictionary [@"ApplyPrice"] isEqualToString:@"UnitPrice"]){
        [self selectedItemTab:self.unitPriceBtn];
    }
    else if([self.weightDictionary [@"ApplyPrice"] isEqualToString:@"PriceA"]){
        [self selectedItemTab:self.aLevelBtn];
    }
    else if([self.weightDictionary [@"ApplyPrice"] isEqualToString:@"PriceB"]){
        [self selectedItemTab:self.bLevelBtn];
    }
    else if([self.weightDictionary [@"ApplyPrice"] isEqualToString:@"PriceC"]){
        [self selectedItemTab:self.cLevelBtn];
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
    if([markup isEqualToString:@"nan"] || [markup isEqualToString:@"-inf"] || [markup isEqualToString:@"inf"] || [markup isEqualToString:@"-100.00"])
    {
        markup = @"0.00";
    }
    return markup;
}
-(void)selectedItemTab:(UIButton *)selectedButton{
    [self.unitPriceBtn setSelected:NO];
    [self.aLevelBtn setSelected:NO];
    [self.bLevelBtn setSelected:NO];
    [self.cLevelBtn setSelected:NO];
    [selectedButton setSelected:YES];
}
#pragma mark - UITextFieldDelegate -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(IsPhone()){
        if(textField != self.qty){
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
                // back Space
                cents = floor(cents / 10);
            }
            if(cents != 0){
                if(textField != self.profit){
                    textField.text = [self.rmsDbController getStringPriceFromFloat:(float)cents / 100.0f];
                }
                else{
                    textField.text = [NSString stringWithFormat:@"%.2f", cents / 100.0f];
                }
            }
            else{
                textField.text = @"";
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    currentEditedTextField = textField;
    [self InputPopUpViewForCostProfitSales:textField];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)unitPriceClicked:(id)sender{
    [self.weightDictionary setValue:@"UnitPrice" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.unitPriceBtn];
}

-(IBAction)aLevelClicked:(id)sender{
    [self.weightDictionary setValue:@"PriceA" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.aLevelBtn];
}

-(IBAction)bLevelClicked:(id)sender{
    [self.weightDictionary setValue:@"PriceB" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.bLevelBtn];
}

-(IBAction)cLevelClicked:(id)sender{
    [self.weightDictionary setValue:@"PriceC" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.cLevelBtn];
}

-(void)selectedPriceLevel:(UIButton *)selectedButton{
    self.unitPriceBtn.selected = NO;
    self.aLevelBtn.selected = NO;
    self.bLevelBtn.selected = NO;
    self.cLevelBtn.selected = NO;
    selectedButton.selected = YES;
}
- (void)weightAddBtn{
    [currentEditedTextField resignFirstResponder];
    NSString *inputValue = [currentEditedTextField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
	[self didEnter:currentEditedTextField inputValue:@(inputValue.floatValue)];
}

# pragma mark - PriceInputDelegate Method

-(void)InputPopUpViewForCostProfitSales:(UITextField *)textField {
    NumberPadPickerTypes inputType = NumberPadPickerTypesPrice;
    if (textField == self.self.profit) {
        inputType = NumberPadPickerTypesPercentage;
    }
    else if (textField == self.unitQty) {
        inputType = NumberPadPickerTypesWeightScale;
    }
    else if (textField == self.qty) {
        inputType = NumberPadPickerTypesQTY;
    }
    RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:inputType NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
        if (inputType == NumberPadPickerTypesWeightScale) {
            [self didEnterWeightScale:inputView inputValue:numInput unitType:strInput];
        }
        else{
            [self didEnter:inputView inputValue:numInput];
        }
    } NumberPadColseInput:^(UIViewController *popUpVC) {
        [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objRIMNumberPadPopupVC.inputView = textField;
    [objRIMNumberPadPopupVC presentVCForRightSide:(UIViewController *)self.PriceChangeInfoPricingDelegate WithInputView:textField];
//    [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:(UIViewController *)self.PriceChangeInfoPricingDelegate sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
}

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
        [self.weightDictionary setValue:tempValue forKeyPath:@"UnitPrice"];
    }
    else if(inputTextField.tag == 500){
        [self.weightDictionary setValue:tempValue forKeyPath:@"PriceA"];
    }
    else if(inputTextField.tag == 600){
        [self.weightDictionary setValue:tempValue forKeyPath:@"PriceB"];
    }
    else if(inputTextField.tag == 700){
        [self.weightDictionary setValue:tempValue forKeyPath:@"PriceC"];
    }
    
    [self.PriceChangeInfoPricingDelegate didPriceChangeOf:PricingValueType inputValue:inputValue ValueIndex:(int)self.cellIndex.row];
}
// Weight Scale Delegate Method

-(void)didEnterWeightScale:(id)inputControl inputValue:(NSNumber *)inputValue unitType:(NSString *)unitType{
    UITextField *inputTextField = (UITextField *)inputControl;
    if(inputTextField.tag == 800){
        NSString *tempValue3 = [NSString stringWithFormat:@"%.0f",inputValue.floatValue];
        [self.weightDictionary setValue:tempValue3 forKeyPath:@"UnitQty"];
    }
    if(inputTextField.tag == 800){
        inputTextField.text = [NSString stringWithFormat:@"%.0f/%@",inputValue.floatValue,unitType];
    }
    self.lblMeasurement.text = unitType;
    [self.weightDictionary setValue:self.lblMeasurement.text forKeyPath:@"UnitType"];
    [self.PriceChangeInfoPricingDelegate didPriceChangeOfInputWeight:inputValue InputWeightUnit:unitType ValueIndex:(int)self.cellIndex.row];
}

@end
