//
//  CL_HouseChargeCreditLimitVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CL_HouseChargeCreditLimitVC.h"

@interface CL_HouseChargeCreditLimitVC ()<UITextFieldDelegate>

@property (nonatomic , weak) IBOutlet UITextField *txtCreditLimit;
@property (nonatomic , weak) IBOutlet UILabel *lblCurrentCreditLimit;


@end

@implementation CL_HouseChargeCreditLimitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _lblCurrentCreditLimit.text = [NSString stringWithFormat:@" %.2f",_currentCreditLimit.floatValue];
    [self registerNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(IBAction)btnSave:(id)sender
{
    if (self.txtCreditLimit.text.length > 0 && self.txtCreditLimit.text.floatValue > 0.00)
    {
        [self.cl_HouseChargeCreditLimitVCDelegate setCreditLimit:_txtCreditLimit.text.floatValue];
    }
}

-(IBAction)btnCancel:(id)sender
{
    [self.cl_HouseChargeCreditLimitVCDelegate didCancelHouseChargeCreditLimitVC];

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
    [UIView setAnimationDuration:0.3];
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
