//
//  DiscountMixMatchCellTableViewCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 13/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "VariationCustomCell.h"
#import <QuartzCore/QuartzCore.h>
#import "RimsController.h"
#import "RmsDbController.h"
#import "RIMNumberPadPopupVC.h"

@interface VariationCustomCell () <UITextFieldDelegate>

@property (nonatomic, strong) RimsController * rimsController;
@property (nonatomic, strong) RmsDbController * rmsDbController;

@end

@implementation VariationCustomCell

- (void)awakeFromNib
{
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
    self.productName.text = self.pricingDictionary [@"Name"];
    self.productName.text = self.productName.text.uppercaseString;
    
    self.costPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"Cost"] floatValue]];
    
    if(!([self.pricingDictionary [@"Cost"] floatValue] == 0.00))
    {
        self.costPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"Cost"] floatValue]];
    }
    else
    {
        self.costPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"Cost"] floatValue]];
    }
    
    if(!([self.pricingDictionary [@"Profit"] floatValue] == 0.00)){
        if (self.isMargin) {
            self.profit.text=[self calculateMarginCost:[self.pricingDictionary [@"Cost"] floatValue] Sales:[self.pricingDictionary [@"UnitPrice"] floatValue]];
        }
        else{
            self.profit.text=[self calculateMarkUpCost:[self.pricingDictionary [@"Cost"] floatValue] Sales:[self.pricingDictionary [@"UnitPrice"] floatValue]];
        }

    }
    else{
        self.profit.text = [NSString stringWithFormat:@"%.2f",[self.pricingDictionary [@"Profit"] floatValue]];
    }
    
    if(!([self.pricingDictionary [@"UnitPrice"] floatValue] == 0.00))
    {
        self.unitPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"UnitPrice"] floatValue]];
    }
    else
    {
        self.unitPrice.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"UnitPrice"] floatValue]];
    }
    self.priceLevelA.text=@"";
    self.priceLevelB.text=@"";
    self.priceLevelC.text=@"";
    [self.allowPackageType setOn:YES ];
    if(!([self.pricingDictionary [@"PriceA"] floatValue] == 0.00)) {
        self.priceLevelA.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"PriceA"] floatValue]];
    }
    
    if(!([self.pricingDictionary [@"PriceB"] floatValue] == 0.00)){
        self.priceLevelB.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"PriceB"] floatValue]];
    }
    
    if(!([self.pricingDictionary [@"PriceC"] floatValue] == 0.00)){
        self.priceLevelC.text = [self.rmsDbController getStringPriceFromFloat:[self.pricingDictionary [@"PriceC"] floatValue]];
    }
    
    if ([self.pricingDictionary [@"IsPackCaseAllow"] intValue] == 0) {
        [self.allowPackageType setOn:NO ];
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
    if([markup isEqualToString:@"nan"] || [markup isEqualToString:@"-inf"] || [markup isEqualToString:@"inf"] || [markup isEqualToString:@"-100.00"])
    {
        markup = @"0.00";
    }
    return markup;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    currentEditedTextField = textField;
    [self showInputPriceingView:textField];
    return FALSE;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)unitPriceClicked:(id)sender
{
    [self.pricingDictionary setValue:@"UnitPrice" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.unitPriceBtn];
}

-(IBAction)aLevelClicked:(id)sender
{
    [self.pricingDictionary setValue:@"PriceA" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.aLevelBtn];
}

-(IBAction)bLevelClicked:(id)sender
{
    [self.pricingDictionary setValue:@"PriceB" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.bLevelBtn];
}

-(IBAction)cLevelClicked:(id)sender
{
    [self.pricingDictionary setValue:@"PriceC" forKeyPath:@"ApplyPrice"];
    [self selectedPriceLevel:self.cLevelBtn];
}

-(void)selectedPriceLevel:(UIButton *)selectedButton
{
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

- (void)calculateSalesPrice
{
    // calculate sales prices
    if(currentEditedTextField == self.profit)
    {
        NSString *tempProfit = [self.profit.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        NSString *tempCost = [self.costPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        tempProfit = [tempProfit stringByReplacingOccurrencesOfString:@"," withString:@""];
        tempCost = [tempCost stringByReplacingOccurrencesOfString:@"," withString:@""];
        
        if((![self.profit.text isEqualToString:@""]) && (![self.costPrice.text isEqualToString:@""]))
        {
            float dcostAmt=tempCost.floatValue;
            float dprofitper=tempProfit.floatValue;
            float dsellingamt=0;
            
            if([self.profit_type isEqualToString:@"MarkUp"]) // Markup
            {
                if(dcostAmt>0 && dprofitper>0)
                {
                    float dProfitAmt=0;
                    dProfitAmt=(dprofitper * dcostAmt)/100;
                    dsellingamt=dProfitAmt+dcostAmt;
                    
                    self.unitPrice.text = [self.rmsDbController getStringPriceFromFloat:dsellingamt];
                    self.unitPrice.text = [self.unitPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                }
            }
            else // Margin
            {
                dsellingamt= dcostAmt/((100-dprofitper)/100);
                self.unitPrice.text = [self.rmsDbController getStringPriceFromFloat:dsellingamt];
                self.unitPrice.text = [self.unitPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            }
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            nf.numberStyle = NSNumberFormatterCurrencyStyle;
            NSNumber *number = [nf numberFromString:self.unitPrice.text];
            float iSales = number.floatValue;
            [self.pricingDictionary setValue:[NSString stringWithFormat:@"%.2f",iSales] forKeyPath:@"UnitPrice"];
        }
        else
        {
            self.unitPrice.text=@"";
        }
    }
    else if(currentEditedTextField == self.unitPrice){
        if (self.isMargin) {
            self.profit.text=[self calculateMarginCost:[self.pricingDictionary [@"Cost"] floatValue] Sales:[self.pricingDictionary [@"UnitPrice"] floatValue]];
        }
        else{
            self.profit.text=[self calculateMarkUpCost:[self.pricingDictionary [@"Cost"] floatValue] Sales:[self.pricingDictionary [@"UnitPrice"] floatValue]];
        }
    }
}

- (void)priceAddBtn
{
    [currentEditedTextField resignFirstResponder];
    NSString *inputValue = [currentEditedTextField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
	[self didEnter:currentEditedTextField inputValue:inputValue.floatValue];
}

-(void)showInputPriceingView:(UITextField *)textField {
    if ((textField == self.costPrice) || (textField == self.profit) || (textField == self.unitPrice) || (textField == self.priceLevelA) || (textField == self.priceLevelB) || (textField == self.priceLevelC)) {
        NumberPadPickerTypes inputType = NumberPadPickerTypesPrice;
        if (textField == self.self.profit) {
            inputType = NumberPadPickerTypesPercentage;
        }
        
        RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:inputType NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
            [self didEnter:inputView inputValue:numInput.floatValue];
        } NumberPadColseInput:^(UIViewController *popUpVC) {
            [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        }];
        objRIMNumberPadPopupVC.inputView = textField;
        [objRIMNumberPadPopupVC presentVCForRightSide:(UIViewController *)self.PriceChangeInfoPricingDelegate WithInputView:textField];
//        [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:(UIViewController *)self.PriceChangeInfoPricingDelegate sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
    }
}

# pragma mark - PriceInputDelegate Method

-(void)didEnter:(id)inputControl inputValue:(CGFloat)inputValue
{
    UITextField *inputTextField = (UITextField *)inputControl;
    NSString *tempValue = [NSString stringWithFormat:@"%.2f",inputValue];
    if(inputTextField.tag == 100 || (inputTextField.tag == 101) || (inputTextField.tag == 102))
    {
        [self.pricingDictionary setValue:tempValue forKeyPath:@"Qty"];
    }
    if(inputTextField.tag == 200)
    {
        [self.pricingDictionary setValue:tempValue forKeyPath:@"Cost"];
    }
    if(inputTextField.tag == 300)
    {
        [self.pricingDictionary setValue:tempValue forKeyPath:@"Profit"];
    }
    if(inputTextField.tag == 400)
    {
        [self.pricingDictionary setValue:tempValue forKeyPath:@"UnitPrice"];
    }
    if(inputTextField.tag == 500)
    {
        [self.pricingDictionary setValue:tempValue forKeyPath:@"PriceA"];
    }
    if(inputTextField.tag == 600)
    {
        [self.pricingDictionary setValue:tempValue forKeyPath:@"PriceB"];
    }
    if(inputTextField.tag == 700)
    {
        [self.pricingDictionary setValue:tempValue forKeyPath:@"PriceC"];
    }
    
    if(inputTextField.tag == 100 || (inputTextField.tag == 101) || (inputTextField.tag == 102))
    {
        inputTextField.text = [NSString stringWithFormat:@"%.0f",inputValue];
    }
    else if(inputTextField.tag == 300)
    {
        inputTextField.text = [NSString stringWithFormat:@"%.2f",inputValue];
    }
    else
    {
        inputTextField.text = [self.rmsDbController getStringPriceFromFloat:inputValue];
        inputTextField.text = [inputTextField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    
    if(currentEditedTextField == self.profit || currentEditedTextField == self.unitPrice)
    {
        [self calculateSalesPrice];
    }
}

@end