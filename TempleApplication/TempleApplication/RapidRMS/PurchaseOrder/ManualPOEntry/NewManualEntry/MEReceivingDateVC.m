//
//  MEReceivingDateVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 6/20/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "MEReceivingDateVC.h"

@interface MEReceivingDateVC ()


@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;

@end

@implementation MEReceivingDateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sendClick:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSDate *dt = _datePicker.date;
    NSString *dateAsString = [formatter stringFromDate:dt];
    [self.meReceivingDateVCDelegate didSelectDate:dateAsString];
}


-(IBAction)closeClick:(id)sender{
    [self.meReceivingDateVCDelegate didCloseReceivingDate];
}



@end
