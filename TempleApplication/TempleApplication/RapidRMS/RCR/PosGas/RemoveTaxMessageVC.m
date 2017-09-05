//
//  RemoveTaxMessageVC.m
//  RapidRMS
//
//  Created by Siya on 27/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RemoveTaxMessageVC.h"

@interface RemoveTaxMessageVC ()
{
    
}
@property (nonatomic , weak) IBOutlet UITextView *messageTextView;

@end

@implementation RemoveTaxMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
   // [self registerNotifications];
    [_messageTextView becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}

-(void)keyboardWillShow:(NSNotification *)note
{
    //if(self.view.frame.origin.y != -150)
    {
        
        CGFloat kheight = [note.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        CGPoint centerPoint = self.view.center;
        centerPoint.y = self.view.frame.size.height/2 + 220 - kheight;
        self.view.center = centerPoint;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    // if(self.view.frame.origin.y == -150)
    {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        self.view.frame = self.view.bounds;
        
        [UIView commitAnimations];
        
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(IBAction)msgOk:(id)sender
{
    [self.removeTaxPopUpMessageDelegate didsendRemoveTaxMessage:_messageTextView.text];
}


-(IBAction)cancelClick:(id)sender{
    
    [self.removeTaxPopUpMessageDelegate didCancelRemoveTaxPopup];
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

-(void)removeKeyboardNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
