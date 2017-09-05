//
//  CashRegisterDisplayVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 19/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "InventoryManagementSetting.h"
#import "RmsDbController.h"

@interface InventoryManagementSetting ()

@property (nonatomic, weak) IBOutlet UISwitch *weightScaleSwitch;

@end

@implementation InventoryManagementSetting

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
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
    [self checkWeighScaleStatus];
}

- (void)checkWeighScaleStatus
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"WeightScaleStatus"] isEqualToString:@"Yes"])
    {
        self.weightScaleSwitch.on = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"WeightScaleStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
    else
    {
        self.weightScaleSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"WeightScaleStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)weightScaleSwitch:(id)sender
{
    if (self.weightScaleSwitch.on == YES)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"WeightScaleStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"WeightScaleStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
}
@end
