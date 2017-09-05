//
//  CL_HouseChargePaymentVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CL_HouseChargePaymentVC.h"

@interface CL_HouseChargePaymentVC ()<UITextFieldDelegate>

@property (nonatomic , weak) IBOutlet UILabel *lblBalance;
@property (nonatomic , weak) IBOutlet UILabel *lblCustomerNumber;

@property (nonatomic , weak) IBOutlet UITextField *txtOtherAmount;

@property (nonatomic , weak) IBOutlet UIButton *btnPayFull;
@property (nonatomic , weak) IBOutlet UIButton *btnPayOtherAmount;

@end

@implementation CL_HouseChargePaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNotifications];
    _btnPayFull.selected = YES;
    _txtOtherAmount.enabled = NO;
    _lblBalance.text = [NSString stringWithFormat:@" %.2f" , -(_balance.floatValue)];
    _lblCustomerNumber.text = _customerNo;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnPayFullBalance:(id)sender
{
    _btnPayFull.selected = YES;
    _btnPayOtherAmount.selected = NO;
    _txtOtherAmount.enabled = NO;

}

-(IBAction)payOtherAmount:(id)sender
{
    _btnPayFull.selected = NO;
    _btnPayOtherAmount.selected = YES;
    _txtOtherAmount.enabled = YES;
}

-(IBAction)btnSave:(id)sender
{
    CGFloat balanceAmount = 0.00;
    if (self.btnPayFull.selected)
    {
        balanceAmount = _lblBalance.text.floatValue;
    }
    else if(self.btnPayOtherAmount.selected)
    {
        if (_txtOtherAmount.text.length>0)
        {
            balanceAmount = _txtOtherAmount.text.floatValue;
        }
    }
    [self.cl_HouseChargePaymentVCDelegate didAddBalanceAmount:balanceAmount];
}

-(IBAction)btnCancel:(id)sender
{
    [self.cl_HouseChargePaymentVCDelegate didCancelHouseChargePaymentVC];
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification *)note
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    CGPoint centerPoint = self.view.center;
    centerPoint.y = 120;
    self.view.frame = CGRectMake(self.view.frame.origin.x, centerPoint.y, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    CGPoint centerPoint = self.view.center;
    centerPoint.y = 209;
    self.view.frame = CGRectMake(self.view.frame.origin.x, centerPoint.y, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}




@end
