//
//  RCR_MemoVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 2/11/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RCR_MemoVC.h"

@interface RCR_MemoVC ()
{
}

@property (nonatomic , weak) IBOutlet UITextView *messageTextView;


@end

@implementation RCR_MemoVC

- (void)viewDidLoad
{
    if (self.isMemoFromEditState == FALSE) {
        [self registerNotifications];
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{    if (self.isMemoFromEditState == FALSE) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    CGPoint centerPoint = self.view.center;
    centerPoint.y = 100;
    self.view.frame = CGRectMake(self.view.frame.origin.x, centerPoint.y, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}
}

-(void)keyboardWillShow:(NSNotification *)note
{
   
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

-(IBAction)msgOk:(id)sender
{
    [self.rcr_MemoDelegate didAddMemo:_messageTextView.text];
}

-(IBAction)msgCancel:(id)sender
{
    [self.rcr_MemoDelegate didCancelMemoVC];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
