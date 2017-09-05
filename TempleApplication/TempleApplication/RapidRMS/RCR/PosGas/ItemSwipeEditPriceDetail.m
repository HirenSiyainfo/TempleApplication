//
//  ItemSwipeEditPriceDetail.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/27/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemSwipeEditPriceDetail.h"
#import "RmsDbController.h"


@interface ItemSwipeEditPriceDetail ()
{

}
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic,strong)NSDictionary *swipeDictionary;

@end

@implementation ItemSwipeEditPriceDetail

- (void)awakeFromNib
{
    
    [self setUpCell];
}

-(void)setUpCell
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    UIView *backGroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.backgroundView = backGroundView;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    UIImageView *selectedbackGroundView = [[UIImageView alloc]initWithFrame:self.bounds];
    self. selectedBackgroundView = selectedbackGroundView;
    self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
}
- (void)updateTaxWithTaxState:(NSDictionary *)itemSwipeDictionary
{
    RCR_EDIT_TAX_PROCESS rcr_EDIT_TAX_PROCESS = [itemSwipeDictionary[@"RCR_EDIT_TAX_PROCESS"] integerValue];
    switch (rcr_EDIT_TAX_PROCESS) {
        case RCR_TAX_INITIAL_STEP:
            self.imgRemoveItemTax.image = [UIImage imageNamed:@"RCREditItemcloseIcon.png"];
            break;
        case RCR_TAX_REMOVE_STEP:
            self.imgRemoveItemTax.image = [UIImage imageNamed:@"checkboxBlank.png"];
            break;
        case RCR_TAX_ADD_STEP:
            self.imgRemoveItemTax.image = [UIImage imageNamed:@"checkbox.png"];
            break;
        default:
            break;
    }
}

-(void)configureItemPriceDetail:(NSDictionary *)itemSwipeDictionary
{
    self.swipeDictionary = itemSwipeDictionary;
   /* if (![self.rmsDbController checkRightsForRightId:ChangePriceRight] ||  [[itemSwipeDictionary objectForKey:@"IsRefundFromInvoice"] boolValue] == TRUE)
    {
        self.priceEditTextField.enabled = NO;
    }
    else
    {
        self.priceEditTextField.enabled = YES;
    }*/
    
    
    
    
    self.priceEditTextField.text = [NSString stringWithFormat:@"%.2f",[itemSwipeDictionary[@"editItemPriceDisplay"] floatValue]];
   
    NSNumber *qty ;

    if(itemSwipeDictionary[@"PackageQty"])
    {
        qty = @([itemSwipeDictionary[@"itemQty"] intValue] / [itemSwipeDictionary[@"PackageQty"] intValue]);
        self.qtyEditTextField.text = [NSString stringWithFormat:@"%@ %@ ",qty , itemSwipeDictionary[@"PackageType"]];

    }
    else
    {
        qty = @([itemSwipeDictionary[@"itemQty"] intValue]);
        self.qtyEditTextField.text = [NSString stringWithFormat:@"%@",qty ];

    }
    
    self.qtyEditTextField.text = [NSString stringWithFormat:@"%@ %@ ",qty , itemSwipeDictionary[@"PackageType"]];
    self.taxPercentage.text = [NSString stringWithFormat:@"%@",itemSwipeDictionary[@"TotalTaxPercentage"]];
    self.memoEditTextField.text = [NSString stringWithFormat:@"%@",itemSwipeDictionary[@"Memo"]];

    NSString *seditDiscount =[NSString stringWithFormat:@"%@",itemSwipeDictionary[@"ItemDiscount"]];
    if([seditDiscount isEqualToString:@"0"])
    {
        self.discountLabel.text=@"-NA-";
    }
    else
    {
        if (itemSwipeDictionary[@"PriceAtPos"])
        {
            if ([itemSwipeDictionary[@"ItemBasicPrice"] floatValue]>[itemSwipeDictionary[@"PriceAtPos"] floatValue])
            {
                self.discountLabel.text=[NSString stringWithFormat:@"%.2f",[itemSwipeDictionary[@"ItemExternalDiscount"] floatValue]];
            }
            else
            {
                self.discountLabel.text=[NSString stringWithFormat:@"%.2f",[itemSwipeDictionary[@"ItemExternalDiscount"] floatValue]];
            }
        }
        else
        {
            self.discountLabel.text=[NSString stringWithFormat:@"%.2f",[itemSwipeDictionary[@"ItemExternalDiscount"] floatValue]];
        }
    }
    if ([[itemSwipeDictionary valueForKey:@"EBTApplied"] boolValue] == TRUE)
    {
        self.imgRemoveItemEBT.image = [UIImage imageNamed:@"checkbox.png"];

    }
    else{
        self.imgRemoveItemEBT.image = [UIImage imageNamed:@"checkboxBlank.png"];

    }
    [self updateTaxWithTaxState:itemSwipeDictionary];

    
}

-(IBAction)addRemoveTax:(id)sender
{
    [self.itemSwipeEditPriceDetailDelegate didUpdateStateOfTaxProcess];
}
-(IBAction)addRemoveEBT:(id)sender
{
    [self.itemSwipeEditPriceDetailDelegate didUpdateEBTStatus];

}

-(IBAction)removeDiscountButton:(id)sender
{
    [self.itemSwipeEditPriceDetailDelegate didRemoveItemDiscount];
    self.discountLabel.text=@"-NA-";
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    RCR_EDIT_PRICE_DETAIL_TEXTFIELD rcr_EDIT_PRICE_DETAIL_TEXTFIELD = RCR_EDIT_NOT_APPLICABLE_TEXTFIELD;
    if (textField == self.priceEditTextField) {
        if([[self.swipeDictionary valueForKey:@"Discription"] isEqualToString:@"POST-PAY"]){
            return NO;
        }
        rcr_EDIT_PRICE_DETAIL_TEXTFIELD = RCR_EDIT_PRICE_TEXTFIELD;
    }
    if (textField == self.qtyEditTextField) {
        rcr_EDIT_PRICE_DETAIL_TEXTFIELD = RCR_EDIT_QTY_TEXTFIELD;
    }
    if (textField == self.memoEditTextField) {
        
        if([[self.swipeDictionary valueForKey:@"Barcode"] isEqualToString:@"GAS"]){
            return NO;
        }
        rcr_EDIT_PRICE_DETAIL_TEXTFIELD = RCR_EDIT_MEMO_TEXTFIELD;
    }
    [self.itemSwipeEditPriceDetailDelegate didShowPopOverControllerForTextField:rcr_EDIT_PRICE_DETAIL_TEXTFIELD withTextField:textField];
    return NO;
}



@end
