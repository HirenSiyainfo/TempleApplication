//
//  PaxSetupVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 07/07/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PaxSetupVC.h"

@interface PaxSetupVC () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *txtIpAddress;
@property (nonatomic, weak) IBOutlet UITextField *txtPort;

@property (nonatomic, weak) IBOutlet UILabel *lblConnectionStatus;

@end

@implementation PaxSetupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hidePaxConnectionStatus];
    // Do any additional setup after loading the view.
}

- (void)displayPaxConnectionDetail:(NSDictionary *)paxDictionary {
    self.txtIpAddress.text = paxDictionary [@"PaxIpAddress"];
    self.txtPort.text = paxDictionary [@"Port"];
}

- (IBAction)btnSaveClicked:(id)sender {
    [self hidePaxConnectionStatus];
    [self.paxSetupVCDelegate didSavePaxData:@{
                                              @"PaxIpAddress":self.txtIpAddress.text,
                                              @"Port":self.txtPort.text,
                                              }];
    [self.txtIpAddress resignFirstResponder];
    [self.txtPort resignFirstResponder];
}

- (IBAction)btnCancelClicked:(id)sender {
    [self.paxSetupVCDelegate didCancelPaxSetUp];
}

- (IBAction)btnConnectionClicked:(id)sender {
    [self.paxSetupVCDelegate startActivityIndicatorForPax];
    [self.paxSetupVCDelegate didRequestedForConnectOtherPaxDevice];
}

- (IBAction)btnFetchCCDataClicked:(id)sender {
    [self.paxSetupVCDelegate didFetchDataForOtherConnectedPaxDevice];
}

- (void)statusForOtherPaxDeviceConnection:(NSString *)status {
    [self.paxSetupVCDelegate stopActivityIndicatorForPax];
    [self showPaxConnectionStatus];
    self.lblConnectionStatus.text = status;
}

- (void)hidePaxConnectionStatus {
    self.lblConnectionStatus.hidden = YES;
}

- (void)showPaxConnectionStatus {
    self.lblConnectionStatus.hidden = NO;
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
