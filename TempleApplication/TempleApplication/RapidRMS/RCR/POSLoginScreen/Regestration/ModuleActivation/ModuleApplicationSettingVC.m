//
//  ApplicationSettingVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/7/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ModuleApplicationSettingVC.h"
#import "RmsDbController.h"

@interface ModuleApplicationSettingVC ()

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation ModuleApplicationSettingVC
@synthesize moduleAvailableApps;

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
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Apps";
}

-(IBAction)btnAvailableApps:(id)sender
{
    self.title = @"Available Apps";
    [moduleAvailableApps goToAvailableAppsMenu];
      
}
-(IBAction)btnActiveApps:(id)sender
{
    self.title = @"Active Apps";
    [moduleAvailableApps goToActiveAppsMenu];
   
   
}

//call when press return key in keyboard.
- (BOOL) textFieldShouldReturn:(UITextField *)textFiled {
	[textFiled resignFirstResponder];
	return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
