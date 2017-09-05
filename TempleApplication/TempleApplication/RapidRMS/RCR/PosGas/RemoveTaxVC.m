//
//  RemoveTaxVC.m
//  RapidRMS
//
//  Created by Siya on 27/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RemoveTaxVC.h"

@interface RemoveTaxVC ()

@end

@implementation RemoveTaxVC
@synthesize imgChk1,imgChk2;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelRemoveTax:(id)sender{
   
    [self.removeTaxDelegate didCancelRemoveTax];
}

-(IBAction)removeAllTax:(id)sender{
    [self.imgChk1 setHidden:NO];
    [self.imgChk2 setHidden:YES];

    [self.removeTaxDelegate didSelectAll];
}

-(IBAction)removeTaxSelecteItem:(id)sender{
    [self.imgChk1 setHidden:YES];
    [self.imgChk2 setHidden:NO];    
    [self.removeTaxDelegate selectedItems];
}

-(IBAction)saveClick:(id)sender{

    [self.removeTaxDelegate didremoveTax:self.txtMessage.text];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
