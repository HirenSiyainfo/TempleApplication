//
//  CL_HouseChargeRefundCreditVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/07/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CL_HouseChargeRefundCreditVC.h"
#import "RmsDbController.h"


@interface CL_HouseChargeRefundCreditVC ()
@property (nonatomic , weak) IBOutlet UILabel *lblCreditLimit;
@property (nonatomic , weak) IBOutlet UILabel *lblBalanceAmount;
@property (nonatomic , weak) IBOutlet UITextField *txtRefundCredit;

@property (nonatomic , strong) RmsDbController *rmsDbController;

@end

@implementation CL_HouseChargeRefundCreditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNotifications];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    _lblBalanceAmount.text = [NSString stringWithFormat:@" %.2f",_balance.floatValue];
    
    _lblCreditLimit.text = [NSString stringWithFormat:@" %.2f",_creditLimit.floatValue];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnSave:(id)sender
{
    if (_creditLimit.floatValue > 0.00)
    {
        if (_txtRefundCredit.text.floatValue > 0 && _txtRefundCredit.text.floatValue <= _creditLimit.floatValue)
        {
            [self.cl_HouseChargeRefundCreditVCDelegate didRefundCreditAmount:-(_txtRefundCredit.text.floatValue)];
        }
        else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Credit not Refund . Try Again" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
        
    }
    else
    {
        [self.cl_HouseChargeRefundCreditVCDelegate didRefundCreditAmount:-(_txtRefundCredit.text.floatValue)];
    }
}

-(IBAction)btnCancel:(id)sender
{
    [self.cl_HouseChargeRefundCreditVCDelegate didCancelHouseChargeRefundCreditVC];
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
