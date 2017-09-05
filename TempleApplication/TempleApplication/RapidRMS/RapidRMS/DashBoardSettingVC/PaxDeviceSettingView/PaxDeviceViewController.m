//
//  PaxDeviceViewController.m
//  RapidRMS
//
//  Created by Siya Infotech on 04/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxDeviceViewController.h"
#import "RmsDbController.h"
#import "PaxDevice.h"
#import "InitializeResponse.h"
#import "SetVariableResponse.h"
#import "GetVariableResponse.h"
#import "RmsActivityIndicator.h"

@interface PaxDeviceViewController ()<UITextFieldDelegate , UIAlertViewDelegate,PaxDeviceDelegate>
{
    IBOutlet UITextField *txtDeviceIP;
    IBOutlet UITextField *txtDevicePort;
    PaxDevice *paxDevice;
    IBOutlet UIButton *testPaxButton;
    IBOutlet UILabel *testPaxConection;
    IBOutlet UIView *testView;
    IBOutlet UISwitch *switchSwipeAnyTime;
    IBOutlet UILabel *lblSwipeAnyTimeStatus;
}
@property (nonatomic,strong) RmsDbController *rmsDbController;
@property (nonatomic,weak) RmsActivityIndicator *activityIndicator;


@end

@implementation PaxDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Pax Device Configuration";
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictDevice = [userDefault objectForKey:@"PaxDeviceConfig"];
    testView.hidden = YES;
    switchSwipeAnyTime.on = FALSE;
    if (dictDevice != nil)
    {
        txtDeviceIP.text = dictDevice [@"PaxDeviceIp"];
        txtDevicePort.text = dictDevice [@"PaxDevicePort"];
        testPaxButton.hidden = NO;
        testView.hidden = NO;
    }
}


-(IBAction)btnSaveClicked:(id)sender
{
    if (!(txtDeviceIP.text.length > 0))
    {
        [self showAlertWithMessage:@"Please enter device IP" forTextField:txtDeviceIP];
    }
    else if (!(txtDevicePort.text.length > 0))
    {
        [self showAlertWithMessage:@"Please enter device Port" forTextField:txtDevicePort];
    }
    else
    {
        testPaxButton.hidden = NO;
        testView.hidden = NO;
        NSDictionary *dictDevice = @{
                                     @"PaxDeviceIp" : txtDeviceIP.text,
                                     @"PaxDevicePort" : txtDevicePort.text,
                                     };
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:dictDevice forKey:@"PaxDeviceConfig"];
        [userDefault synchronize];
        [self showAlertWithMessage:@"Successfully Saved" forTextField:nil];
        [txtDeviceIP resignFirstResponder];
        [txtDevicePort resignFirstResponder];
        if (self.paxDeviceSettingVCDelegate) {
            [self dismissViewControllerAnimated:TRUE completion:^{
                [self.paxDeviceSettingVCDelegate didUpdatePaxDeviceSetting];
            }];
        }
    }
}

-(IBAction)testPaxConnection:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    paxDevice = [[PaxDevice alloc] initWithIp:txtDeviceIP.text port: txtDevicePort.text];
    paxDevice.paxDeviceDelegate = self;
    paxDevice.pdResonse = PDRequestInitialize;
    [paxDevice initializeDevice];
}

-(IBAction)btnSwipeAnyTime:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    NSString *strSwipeValue ;
    if (switchSwipeAnyTime.on) {
        strSwipeValue = @"Y";
    }
    else{
        strSwipeValue = @"N";
    }
     paxDevice.pdResonse = PDRequestSetVariable;
    [paxDevice setVariable:@"swipeAnyTime" withVarialbleValue:strSwipeValue];
}
-(void)showAlertWithMessage:(NSString *)message forTextField:(UITextField *)textField
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [textField becomeFirstResponder];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtDeviceIP)
    {
        [textField resignFirstResponder];
    }
    else if (textField == txtDevicePort)
    {
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)paxDevice:(PaxDevice*)paxDevice willSendRequest:(NSString*)request
{
    
}
- (void)paxDevice:(PaxDevice*)paxDevice response:(PaxResponse*)response
{
    [_activityIndicator hideActivityIndicator];

    if ([response isKindOfClass:[InitializeResponse class]])
    {
        InitializeResponse *initializeResponse = (InitializeResponse *)response;
        if (initializeResponse.responseCode.integerValue == 0) {
            dispatch_async(dispatch_get_main_queue(),  ^{
                NSDictionary *dictPaxDevice = @{
                                                @"PaxConnectionStatus" : @(1),
                                                @"PaxSerialNumber" : [NSString stringWithFormat:@"%@",initializeResponse.serialNumber],
                                                };
                [[NSUserDefaults standardUserDefaults] setObject:dictPaxDevice forKey:@"PaxDeviceStatus"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                testView.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:135.0/255.0 blue:25.0/255.0 alpha:1.0];
                testPaxConection.text = [NSString stringWithFormat:@"Pax Connected"];
                [self getVarialble];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),  ^{
                NSDictionary *dictPaxDevice = @{
                                                @"PaxConnectionStatus" : @(0),
                                                @"PaxSerialNumber" : [NSString stringWithFormat:@"%@",initializeResponse.serialNumber],
                                                };
                [[NSUserDefaults standardUserDefaults] setObject:dictPaxDevice forKey:@"PaxDeviceStatus"];
                [[NSUserDefaults standardUserDefaults]synchronize];

                testView.backgroundColor = [UIColor redColor];
                testPaxConection.text = [NSString stringWithFormat:@"Pax Connection Failed"];
            });
        }
    }
    else if ([response isKindOfClass:[SetVariableResponse class]])
    {
        SetVariableResponse *setVariableResponse = (SetVariableResponse *)response;
        if (setVariableResponse.responseCode.integerValue == 0) {
            
            dispatch_async(dispatch_get_main_queue(),  ^{
                if (switchSwipeAnyTime.on) {
                    lblSwipeAnyTimeStatus.text = @"Y";
                }
                else{
                    lblSwipeAnyTimeStatus.text = @"N";
                }
            });
    }
    }
    else if ([response isKindOfClass:[GetVariableResponse class]])
    {
        GetVariableResponse *getVariableResponse = (GetVariableResponse *)response;
            dispatch_async(dispatch_get_main_queue(),  ^{
                lblSwipeAnyTimeStatus.text = getVariableResponse.variableValue;
                if ([getVariableResponse.variableValue isEqualToString:@"Y"])
                    {
                        switchSwipeAnyTime.on = TRUE;
                    }
                    else
                    {
                        switchSwipeAnyTime.on = FALSE;
                    }
            });
    }
}

-(void)getVarialble
{
    paxDevice.pdResonse = PDRequestGetVariable;
    [paxDevice getVariable:@"swipeAnyTime"];
    // [paxDevice getVariable:@"cardSwipedTimeout"];

}
- (void)paxDevice:(PaxDevice*)paxDevice failed:(NSError*)error response:(PaxResponse *)response
{
    [_activityIndicator hideActivityIndicator];

    dispatch_async(dispatch_get_main_queue(),  ^{
        
       if ([response isKindOfClass:[SetVariableResponse class]])
        {
            lblSwipeAnyTimeStatus.text = @"N";
            switchSwipeAnyTime.on = FALSE;
        }
       else{
           
           NSDictionary *dictPaxDevice = @{
                                           @"PaxConnectionStatus" : @(0),
                                           @"PaxSerialNumber" : [NSString stringWithFormat:@"%@",@""],
                                           };
           
           [[NSUserDefaults standardUserDefaults] setObject:dictPaxDevice forKey:@"PaxDeviceStatus"];
           [[NSUserDefaults standardUserDefaults]synchronize];

           testView.backgroundColor = [UIColor redColor];
           testPaxConection.text = [NSString stringWithFormat:@"Pax Connection Failed"];
       }
    });
}

- (void)paxDevice:(PaxDevice*)paxDevice isConncted:(BOOL)isConncted
{
    
}
- (void)paxDeviceDidTimeout:(PaxDevice*)paxDevice
{
    [_activityIndicator hideActivityIndicator];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
