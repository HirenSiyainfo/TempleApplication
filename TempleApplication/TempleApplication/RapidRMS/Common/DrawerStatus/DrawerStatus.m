//
//  UserRights.m
//  RapidRMS
//
//  Created by Siya-mac5 on 25/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "DrawerStatus.h"
#import "RmsDbController.h"
#import "AppSettings.h"

@interface DrawerStatus() <PrinterFunctionsDelegate>
{
    NSArray *array_port;
    NSInteger selectedPort;
    
    AppSettings *appSettings;
}

@property (nonatomic, strong) RapidWebServiceConnection *webServiceConnectionSettingBG;

@end
@implementation DrawerStatus

- (instancetype)init
{
    self = [super init];
    if (self) {
        array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
        selectedPort = 0;
        appSettings = [[AppSettings alloc] init];
    }
    return self;
}

- (BOOL)isDrawerConfigured {
    BOOL isDrawerConfigured = false;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"DrawerDeviceStatus"] boolValue] == true) {
        isDrawerConfigured = true;
    }
    return isDrawerConfigured;
}

- (void)detectDrawerType {
    [self checkDrawerStatusWithDelegate:self needToSwitchDrawerType:NO];
}

- (void)checkDrawerStatusWithDelegate:(id)delegate needToSwitchDrawerType:(BOOL)needToSwitchDrawerType;
{
    SensorActive sensorType;
    NSDictionary *portInfo = [self printerPortInfo];
    if ([delegate isKindOfClass:[DrawerStatus class]]) {
        sensorType = SensorActiveHigh;
    }
    else {
        sensorType = [self getDrawerTypeForSelectedPrinter:needToSwitchDrawerType];
    }
    
    [PrinterFunctions CheckStatusWithPortname:portInfo[@"PortName"] portSettings:portInfo[@"PortSettings"] sensorSetting:sensorType withDelegate:delegate];
}

- (SensorActive)getDrawerTypeForSelectedPrinter:(BOOL)needToSwitchDrawerType {
    SensorActive sensorType;
    NSString *strPrinterSelection = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"];
    if(strPrinterSelection && strPrinterSelection.length > 0)
    {
        if ([strPrinterSelection isEqualToString:@"Bluetooth"]) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BluetoothDrawerDeviceType"]) {
                sensorType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"BluetoothDrawerDeviceType"] intValue];
            }
            else {
                sensorType = SensorActiveHigh;
            }
        }
        else if ([strPrinterSelection isEqualToString:@"TCP"]) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"TCPDrawerDeviceType"]) {
                sensorType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TCPDrawerDeviceType"] intValue];
            }
            else {
                sensorType = SensorActiveHigh;
            }
        }
        else {
            sensorType = SensorActiveHigh;
        }
    }
    else {
        sensorType = SensorActiveHigh;
    }
    if (needToSwitchDrawerType) {
        sensorType = [self switchedDrawerTypeForSelectedPrinter:sensorType];
        [self saveDrawerTypeSetting:sensorType isLocaly:false];
    }
    return sensorType;
}

- (SensorActive)switchedDrawerTypeForSelectedPrinter:(SensorActive)sensorType {
    if (sensorType == SensorActiveHigh) {
        sensorType = SensorActiveLow;
    }
    else {
        sensorType = SensorActiveHigh;
    }
    return sensorType;
}

- (SensorActive)identifyDrawerTypeFromDrawerStatus:(ActualDrawerStatus)actualDrawerStatus {
    SensorActive sensorType;
    if (actualDrawerStatus == ActualDrawerStatusClose) {
        sensorType = SensorActiveHigh;
    }
    else {
        sensorType = SensorActiveLow;
    }
    return sensorType;
}

- (void)saveDrawerTypeSetting:(SensorActive)newDrawerType isLocaly:(BOOL)isLocaly {
    NSString *printerSelection = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrinterSelection"];
    if(printerSelection.length > 0)
    {
        if ([printerSelection isEqualToString:@"Bluetooth"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@(newDrawerType) forKey:@"BluetoothDrawerDeviceType"];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@(newDrawerType) forKey:@"TCPDrawerDeviceType"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (!isLocaly) {
        [self storeUserDefaultSetting];
    }
}

-(void)storeUserDefaultSetting
{
    NSMutableDictionary *rapidMainSettingDict = [[NSMutableDictionary alloc]init];
    rapidMainSettingDict[@"BranchConfigurationSetting"] = [appSettings getRapidSettings];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self insertBranchConfigurationSettingResponse:response error:error];
    };
    
    self.webServiceConnectionSettingBG = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_INSERT_BRACH_CONFIGURATION_SETTING params:rapidMainSettingDict asyncCompletionHandler:asyncCompletionHandler];
}

-(void)insertBranchConfigurationSettingResponse:(id)response error:(NSError *)error
{
    
}

- (NSDictionary *)printerPortInfo {
    NSString *portName     = @"";
    NSString *portSettings = @"";
    [self setPortInfo];
    
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    return  @{
              @"PortName":portName,
              @"PortSettings":portSettings,
              };
}

+ (void)setPortName:(NSString *)m_portName
{
    [RcrController setPortName:m_portName];
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    [RcrController setPortSettings:m_portSettings];
}

- (void)setPortInfo
{
    NSString *localPortName;
    
    NSString *Str = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"];
    
    if(Str.length > 0)
    {
        if ([Str isEqualToString:@"Bluetooth"])
        {
            localPortName=@"BT:Star Micronics";
        }
        else if([Str isEqualToString:@"TCP"]){
            
            NSString *tcp = [[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"];
            localPortName=tcp;
        }
    }
    else{
        localPortName=@"BT:Star Micronics";
    }
    
    [DrawerStatus setPortName:localPortName];
    [DrawerStatus setPortSettings:array_port[selectedPort]];
}

#pragma-mark PrinterFunctionsDelegate

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {

}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp {

}

-(void)actualDrawerStatus:(ActualDrawerStatus)actualDrawerStatus {
    SensorActive drawerType = [self identifyDrawerTypeFromDrawerStatus:actualDrawerStatus];
    [self saveDrawerTypeSetting:drawerType isLocaly:true];
    [self.drawerStatusDelegate getDrawerStatusProcessCompleted];
}

-(void)errorOccuredInGettingStatusWithTitle:(NSString *)title message:(NSString *)message {
    [self.drawerStatusDelegate errorOccuredWhileGettingDrawerStatusWithTitle:title message:message];
}

@end
