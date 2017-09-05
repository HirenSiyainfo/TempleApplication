//
//  PrinterSettingViewController.m
//  RapidRMS
//
//  Created by Siya on 10/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PrinterSettingViewController.h"
#import "TCPBluetoothViewController.h"
#import "RmsDbController.h"

@interface PrinterSettingViewController ()
{
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UILabel *lblSelected;

@property (nonatomic, weak) IBOutlet UISwitch *drawerSwitch;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) TCPBluetoothViewController *tcpbluetoothSetting;
@end

@implementation PrinterSettingViewController
@synthesize tcpbluetoothSetting;


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
    tcpbluetoothSetting = [[TCPBluetoothViewController alloc]initWithNibName:@"TCPBluetoothViewController" bundle:nil];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"DrawerDeviceStatus"]) {
        self.drawerSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DrawerDeviceStatus"] boolValue];
    }
    else {
        self.drawerSwitch.on = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"DrawerDeviceStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    NSString *strtemp = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"];
//    strtemp = nil;
    if (strtemp == nil)
    {
        self.lblSelected.text = @"Nothing";
//        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PrinterSelection"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"SelectedTCPPrinter"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PrinterWithIP"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        self.lblSelected.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"];
    }
    self.title=@"Printer Setting";
    
    UIImage *image3 = [UIImage imageNamed:@"RmsheaderLogo.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
  
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    UIBarButtonItem *intercom =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[mailbutton,intercom];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:button withViewController:self];
}

- (IBAction)btnPrinterSelectionClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self.navigationController pushViewController:tcpbluetoothSetting animated:YES];
}

- (IBAction)drawerSwitchValueChanged:(id)sender{
    if (self.drawerSwitch.on == YES) {
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"DrawerDeviceStatus" ];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"DrawerDeviceStatus" ];
    }
    [[NSUserDefaults standardUserDefaults] synchronize ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
