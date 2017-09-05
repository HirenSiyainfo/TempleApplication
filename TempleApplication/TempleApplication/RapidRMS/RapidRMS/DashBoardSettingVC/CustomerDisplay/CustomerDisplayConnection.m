//
//  CustomerDisplayConnection.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/5/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CustomerDisplayConnection.h"
#import "RcrController.h"
#define kPOS_NAME @"PosName"

@interface CustomerDisplayConnection ()

@property (nonatomic, strong) RcrController *crmController;
@end

@implementation CustomerDisplayConnection

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.crmController = [RcrController sharedCrmController];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(IBAction)forGetDivice:(id)sender
{
    [self.crmController.customerDisplayClient disconnectFromDisplay];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPOS_NAME];
    [self.navigationController popViewControllerAnimated:true];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
