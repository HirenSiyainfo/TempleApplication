//
//  MMDDateTimePickerVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 27/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDDateTimePickerVC.h"

@interface MMDDateTimePickerVC ()

@property (nonatomic, weak) IBOutlet UILabel * lblTitle;

@end

@implementation MMDDateTimePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(void)setStrTitle:(NSString *)strTitle {
    _strTitle = strTitle;
    _lblTitle.text = _strTitle.uppercaseString;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction -

-(IBAction)Oktapped:(id)sender {
    [self.Delegate didEnterNewDate:self.datePicker.date withInputView:self.inputView];
}

-(IBAction)closetapped:(id)sender {
    [self.Delegate didCancelEditItemPopOver];
}
@end
