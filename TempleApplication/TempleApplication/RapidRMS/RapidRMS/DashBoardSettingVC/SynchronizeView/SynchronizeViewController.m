//
//  ScannerSettingController.m
//  I-RMS
//  Created by Siya Infotech on 25/10/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "SynchronizeViewController.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "Item+Dictionary.h"

@interface SynchronizeViewController () <UpdateDelegate, SynchronizeVcDelegate>

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) DashBoardSettingVC *dashboardSettingObj;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation SynchronizeViewController


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
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    [_activityIndicator hideActivityIndicator];

    // Do any additional setup after loading the view from its nib.
}

-(IBAction)synchronizeDataClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    UIAlertView *synchronizeAlert = [[UIAlertView alloc] initWithTitle:@"Synchronize" message:@"Are you sure you want to do database synchronize process?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    synchronizeAlert.tag = 101;
    [synchronizeAlert show];
}

-(IBAction)synchronize24HoursClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseCompleteSyncData:) name:@"CompleteSyncData" object:nil];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [self.rmsDbController startSynchronizeUpdate:3600*24];
}

-(IBAction)synchronize1WeekClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseCompleteSyncData:) name:@"CompleteSyncData" object:nil];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [self.rmsDbController startSynchronizeUpdate:3600*24*7];
}

-(void)didSynchronizeComplete
{
    [_activityIndicator hideActivityIndicator];
    UIAlertView *synchronizeComplete = [[UIAlertView alloc] initWithTitle:@"Synchronize" message:@"Synchronization process successfully done" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    synchronizeComplete.tag = 102;
    [synchronizeComplete show];
}

-(void)didSynchronizeFailed
{
    [_activityIndicator hideActivityIndicator];
    UIAlertView *synchronizeFailed = [[UIAlertView alloc] initWithTitle:@"Synchronize" message:@"Synchronization process failed, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [synchronizeFailed show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 101)
    {
        if(buttonIndex == 1)
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view.superview.superview];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.rmsDbController.synchronizeVcDelegate = self;
                [self.rmsDbController doSynchronizeOperation];
            });
        }
    }
    if(alertView.tag == 102)
    {
        if(buttonIndex == 0)
        {
            [self.dashboardSettingObj secondMenuTapped:nil];
        }
    }
}

-(void)responseCompleteSyncData:(NSNotification *)notification
{
    
    [_activityIndicator hideActivityIndicator];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteSyncData" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
