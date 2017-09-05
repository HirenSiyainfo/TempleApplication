//
//  UPCSettingCustomCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 25/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "UPCSettingCustomCell.h"
#import "RIMNumberPadPopupVC.h"
#import "PopOverControllerDelegate.h"

@interface UPCSettingCustomCell () <UITextFieldDelegate,PriceInputDelegate>


@end

@implementation UPCSettingCustomCell

- (void)awakeFromNib
{
    self.txtupcDigit.delegate = self;
    self.txtupcDigit.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.txtupcDigit.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)refreshUpcSettingCell
{
    [self.updSettingDict [@"UpcSwitch"] boolValue ] ? (self.upcSwitch.on = YES) : (self.upcSwitch.on = NO);
    [self.updSettingDict [@"LeadingDigit"] boolValue ] ? (self.leadingSwitch.on = YES) : (self.leadingSwitch.on = NO);
    [self.updSettingDict [@"CheckDigit"] boolValue ] ? (self.checkSwitch.on = YES) : (self.checkSwitch.on = NO);
    self.txtupcDigit.text = [NSString stringWithFormat:@"%@",[self.updSettingDict valueForKey:@"UpcLimit"]];
}

#pragma mark - UITextField Delegate Method

- (void)upcAddBtn
{
    [self.txtupcDigit resignFirstResponder];
    NSString *inputValue = [self.txtupcDigit.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
	[self didEnter:self.txtupcDigit inputValue:inputValue.floatValue];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.txtupcDigit)
    {
        [self showInputPriceingView:_txtupcDigit];
        return FALSE;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)UpcSettingswitchOnOff:(id)sender
{
    if (sender == self.upcSwitch)
    {
        if(self.upcSwitch.on == YES)
        {
            self.leadingSwitch.on = YES;
            self.checkSwitch.on = YES;
            (self.updSettingDict)[@"UpcSwitch"] = @"1";
            (self.updSettingDict)[@"LeadingDigit"] = @"1";
            (self.updSettingDict)[@"CheckDigit"] = @"1";
        }
        else
        {
            self.leadingSwitch.on = NO;
            self.checkSwitch.on = NO;
            (self.updSettingDict)[@"UpcSwitch"] = @"0";
            (self.updSettingDict)[@"LeadingDigit"] = @"0";
            (self.updSettingDict)[@"CheckDigit"] = @"0";
        }
        
    }
    if (sender == self.leadingSwitch)
    {
        if(self.leadingSwitch.on == YES)
        {
            if(self.checkSwitch.on == YES)
            {
                self.upcSwitch.on = YES;
                (self.updSettingDict)[@"UpcSwitch"] = @"1";
            }
            (self.updSettingDict)[@"LeadingDigit"] = @"1";
        }
        else
        {
            self.upcSwitch.on = NO;
            (self.updSettingDict)[@"UpcSwitch"] = @"0";
            (self.updSettingDict)[@"LeadingDigit"] = @"0";
        }
    }
    if (sender == self.checkSwitch)
    {
        if(self.checkSwitch.on == YES)
        {
            if(self.leadingSwitch.on == YES)
            {
                self.upcSwitch.on = YES;
                (self.updSettingDict)[@"UpcSwitch"] = @"1";
            }
            (self.updSettingDict)[@"CheckDigit"] = @"1";
        }
        else
        {
            self.upcSwitch.on = NO;
            (self.updSettingDict)[@"UpcSwitch"] = @"0";
            (self.updSettingDict)[@"CheckDigit"] = @"0";
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpcSettingChangedNotification" object:nil userInfo:self.updSettingDict];
//    [self updateUPCsetting];
}

# pragma mark - PriceInputDelegate Method for UPCSetting

-(void)didEnter:(id)inputControl inputValue:(CGFloat)inputValue
{
    UITextField *inputTextField = (UITextField *)inputControl;
    NSString *tempValue = [NSString stringWithFormat:@"%.0f",inputValue];
    NSArray *upcSettingArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"UPC_Setting"];
    if ([upcSettingArray isKindOfClass:[NSArray class]] && upcSettingArray.count > 0)
    {
        NSPredicate *upcPredicate = [NSPredicate predicateWithFormat:@"UpcLimit == %@",tempValue];
        NSArray *isResultFound = [upcSettingArray filteredArrayUsingPredicate:upcPredicate];
        if(isResultFound.count > 0)
        {
            [(UIViewController *)self.uPCSettingCustomCellDelegate dismissViewControllerAnimated:TRUE completion:^{
                
                UIAlertView *exist = [[UIAlertView alloc] initWithTitle:@"Info" message:@"UPC limit already exist." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [exist show];
            }];
        }
        else
        {
            if(inputTextField.tag == 11)
            {
                self.updSettingDict[@"UpcLimit"] = tempValue;
            }
            NSLog(@"%@",self.updSettingDict);
            inputTextField.text = tempValue;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpcSettingChangedNotification" object:nil userInfo:self.updSettingDict];
        }
    }
}
-(void)showInputPriceingView:(UITextField *)textField {
    
    RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:NumberPadPickerTypesQTY NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
        [self didEnter:inputView inputValue:numInput.floatValue];
    } NumberPadColseInput:^(UIViewController *popUpVC) {
        [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objRIMNumberPadPopupVC.inputView = textField;
    [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:(UIViewController *)self.uPCSettingCustomCellDelegate sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
    
}
-(void)didCancel {
    [(UIViewController *)self.uPCSettingCustomCellDelegate dismissViewControllerAnimated:TRUE completion:nil];
}

@end