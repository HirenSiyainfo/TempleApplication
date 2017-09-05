//
//  EBTViewController.m
//  RapidRMS
//
//  Created by Siya on 27/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "EBTViewController.h"

@interface EBTViewController ()
{

}
@property (nonatomic , weak) IBOutlet UIView *viewBg;

@end

@implementation EBTViewController
@synthesize imgChk1,imgChk2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    _viewBg.layer.cornerRadius = 12.0f;

    [super viewWillAppear:YES];
    [self.imgChk1 setHidden:YES];
    [self.imgChk2 setHidden:NO];

}

-(IBAction)cancelEBT:(id)sender{
    [self.eBTDelegate didCancelEBT];
}

-(IBAction)eBTForAllItems:(id)sender{
    [self.imgChk1 setHidden:NO];
    [self.imgChk2 setHidden:YES];
    [self.eBTDelegate didSelectEBTItemsWithIsThisChangeForAllItems:TRUE];
}

-(IBAction)eBTForEbtApplicableItems:(id)sender{
    [self.imgChk1 setHidden:YES];
    [self.imgChk2 setHidden:NO];
    [self.eBTDelegate didSelectEBTItemsWithIsThisChangeForAllItems:FALSE];
}

-(IBAction)RemoveClick:(id)sender{
    [self.eBTDelegate didRemoveEBT];
}

-(IBAction)saveClick:(id)sender{
    [self.eBTDelegate didEbtAppliedWithMessage:self.txtMessage.text];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
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
