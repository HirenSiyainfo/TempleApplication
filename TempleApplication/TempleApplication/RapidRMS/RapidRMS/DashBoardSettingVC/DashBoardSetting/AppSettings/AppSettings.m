//
//  AppSettings.m
//  RapidRMS
//
//  Created by Siya-mac5 on 25/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "AppSettings.h"
#import "RmsDbController.h"
#import "KitchenPrinter.h"
#import "Department.h"

@interface AppSettings()
{

}

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
@implementation AppSettings
@synthesize managedObjectContext = __managedObjectContext;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        self.managedObjectContext = self.rmsDbController.managedObjectContext;
    }
    return self;
}

- (NSDictionary *)getRapidSettings
{
    NSMutableDictionary *rapidSettingDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *settingDictionary = [[NSMutableDictionary alloc]init];
    [self soundSettingForRapidRMS:settingDictionary];
    [self scannerSettingForRapidRMS:settingDictionary];
    [self changeDueTimerAndTipsSettingForRapidRMS:settingDictionary];
    [self tenderSettingForRapidRMS:settingDictionary];
    [self rcrAndRIMSettingForRapidRMS:settingDictionary];
    [self flowerSettingForRapidRMS:settingDictionary];
    [self dashBoardIconSelectionSettingForRapidRMS:settingDictionary];
    [self upcSettingForRapidRMS:settingDictionary];
    [self kitchenPrinterForRapidRMS:settingDictionary];
    [self paxDeviceSettingForRapidRMS:settingDictionary];
    [self taxSettingForRapidRMS:settingDictionary];
    [self printerSettingForRapidRMS:settingDictionary];
    [self gasPumpSettingForRapidRMS:settingDictionary];
    
    [rapidSettingDictionary setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [rapidSettingDictionary setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    [rapidSettingDictionary setValue:[self.rmsDbController.globalDict [@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    [rapidSettingDictionary setValue:strDateTime forKey:@"DateCreated"];
    rapidSettingDictionary[@"KeyValue"] = [self.rmsDbController jsonStringFromObject:settingDictionary];
    rapidSettingDictionary[@"KeyName"] = @"KeyName";
    return rapidSettingDictionary;
}

-(void)soundSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *arrayForSound = [[NSMutableArray alloc]init];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"Sound"] length] > 0)
    {
        NSMutableDictionary *dictForSound = [[NSMutableDictionary alloc]init];
        dictForSound[@"Sound"] = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"Sound"]];
        dictForSound[@"SelectedSound"] = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedSound"]];
        [arrayForSound addObject:dictForSound];
        settingDictionary[@"RapidSoundSetting"] = arrayForSound;
    }
}

-(void)scannerSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *arrayForScanner = [[NSMutableArray alloc]init];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"ScannerType"] length] > 0)
    {
        NSMutableDictionary *dictForScanner = [[NSMutableDictionary alloc]init];
        dictForScanner[@"Type"] = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"ScannerType"]];
        [arrayForScanner addObject:dictForScanner];
        settingDictionary[@"RapidScannerSetting"] = arrayForScanner;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Bluetooth" forKey:@"Type"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        NSMutableDictionary *dictForScanner = [[NSMutableDictionary alloc]init];
        dictForScanner[@"Type"] = [NSString stringWithFormat:@"Bluetooth"];
        [arrayForScanner addObject:dictForScanner];
        settingDictionary[@"RapidScannerSetting"] = arrayForScanner;
    }
}

-(void)changeDueTimerAndTipsSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"ChangeDue_Setting"])
    {
        settingDictionary[@"RapidChangeDueTimeAndTipsSetting"] = [[NSUserDefaults standardUserDefaults]objectForKey:@"ChangeDue_Setting"];
    }
    else
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"TipsSwitch"] = @(0);
        dict[@"changeDueTimerSwitch"] = @(0);
        dict[@"changeDueTimerValue"] = @"";
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"ChangeDue_Setting"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        settingDictionary[@"RapidChangeDueTimeAndTipsSetting"] = [[NSUserDefaults standardUserDefaults]objectForKey:@"ChangeDue_Setting"];
    }
}

-(void)tenderSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *tenderSettingArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig"];
    if (tenderSettingArray.count > 0)
    {
        settingDictionary[@"RapidTenderSetting"] = tenderSettingArray;
    }
}

-(void)rcrAndRIMSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableDictionary *rcrAndRIMSettingDict = [[NSMutableDictionary alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Selection"]) {
        rcrAndRIMSettingDict[@"Selection"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"Selection"];
    }
    else
    {
        rcrAndRIMSettingDict[@"Selection"] = @"Department";
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PrintRecieptStatus"]) {
        rcrAndRIMSettingDict[@"PrintRecieptStatus"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrintRecieptStatus"];
    }
    else
    {
        rcrAndRIMSettingDict[@"PrintRecieptStatus"] = @"NO";
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"WeightScaleStatus"]) {
        rcrAndRIMSettingDict[@"WeightScaleStatus"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"WeightScaleStatus"];
    }
    else
    {
        rcrAndRIMSettingDict[@"WeightScaleStatus"] = @"NO";
    }
    
    settingDictionary[@"RapidRCRAndRIMSetting"] = rcrAndRIMSettingDict;
}

-(void)flowerSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *tenderSettingArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"ModuleSelectionShortCut"];
    if (tenderSettingArray.count > 0)
    {
        settingDictionary[@"RapidModuleSelectionShortCut"] = tenderSettingArray;
    }
}

-(void)dashBoardIconSelectionSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *dashBoardShortCutSelection = [[NSUserDefaults standardUserDefaults] valueForKey:@"DashBoardIconSelection"];
    if (dashBoardShortCutSelection.count > 0)
    {
        settingDictionary[@"RapidDashBoardIconSelection"] = dashBoardShortCutSelection;
    }
}

-(void)upcSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *upcSetting = [[NSUserDefaults standardUserDefaults] valueForKey:@"UPC_Setting"];
    if (upcSetting.count > 0)
    {
        settingDictionary[@"RapidUPC_Setting"] = upcSetting;
    }
}

-(void)kitchenPrinterForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *kitchprinters = [self getPrinterswithSelectedDepartment];
    if (kitchprinters.count > 0)
    {
        settingDictionary[@"KitchenPrinter_Setting"] = kitchprinters;
    }
}

-(void)paxDeviceSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *arrayPaxDevice = [[NSMutableArray alloc]init];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceConfig"] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dictPaxDevice = [[NSUserDefaults standardUserDefaults]valueForKey:@"PaxDeviceConfig"];
        [arrayPaxDevice addObject:dictPaxDevice];
        settingDictionary[@"PaxDeviceConfig"] = arrayPaxDevice;
    }
}

-(void)taxSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *arrayTaxSetting = [[NSMutableArray alloc]init];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Tax_Setting"] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dictTaxSetting = [[NSUserDefaults standardUserDefaults]valueForKey:@"Tax_Setting"];
        [arrayTaxSetting addObject:dictTaxSetting];
        settingDictionary[@"Tax_Setting"] = arrayTaxSetting;
    }
}

-(void)printerSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *arrayPrintSetting = [[NSMutableArray alloc]init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PrinterSelection"])
    {
        NSDictionary *dictTaxSetting = [[NSUserDefaults standardUserDefaults]valueForKey:@"PrinterSelection"];
        [arrayPrintSetting addObject:dictTaxSetting];
        settingDictionary[@"PrinterSelection"] = arrayPrintSetting;
        NSString *strSelectedPrinter = [[NSUserDefaults standardUserDefaults]valueForKey:@"PrinterSelection"];
        NSString *strPrinterIP = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedTCPPrinter"];
        NSMutableDictionary *dictPrinterUnfo = [NSMutableDictionary dictionary];
        dictPrinterUnfo[@"PrinterType"] = strSelectedPrinter;
        dictPrinterUnfo[@"PrinterIP"] = strPrinterIP;
        settingDictionary[@"PrinterWithIP"] = dictPrinterUnfo;
    }
    NSMutableDictionary *dictPrinterUnfo = [NSMutableDictionary dictionary];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"DrawerDeviceStatus"]) {
        dictPrinterUnfo[@"DrawerDeviceStatus"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"DrawerDeviceStatus"];
        settingDictionary[@"DeviceStatus"] = dictPrinterUnfo;
    }
    NSMutableDictionary *dictDrawerType = [NSMutableDictionary dictionary];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BluetoothDrawerDeviceType"]) {
        dictDrawerType[@"BluetoothDrawerDeviceType"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"BluetoothDrawerDeviceType"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"TCPDrawerDeviceType"]) {
        dictDrawerType[@"TCPDrawerDeviceType"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"TCPDrawerDeviceType"];
    }
    settingDictionary[@"DrawerType"] = dictDrawerType;
}

-(NSMutableArray *)getPrinterswithSelectedDepartment{
    
    NSMutableArray *arrayPrinter = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"KitchenPrinter" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    for(KitchenPrinter *printer in resultSet){
        
        NSMutableDictionary *printerdict = [[NSMutableDictionary alloc]init];
        printerdict[@"printer_ip"] = printer.printer_ip;
        printerdict[@"printer_Name"] = printer.printer_Name;
        
        NSMutableArray *deptArray = [[NSMutableArray alloc]init];
        for(Department *department in printer.printerDepartments){
            
            NSMutableDictionary *dictDept = [[NSMutableDictionary alloc]init];
            dictDept[@"DeptId"] = department.deptId;
            dictDept[@"DepartmentName"] = department.deptName;
            [deptArray addObject:[dictDept mutableCopy]];
            printerdict[@"SelectedDepartments"] = deptArray;
        }
        [arrayPrinter addObject:printerdict];
    }
    return arrayPrinter;
    
}

-(void)gasPumpSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableDictionary *petroSetting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RapidPetroSetting"] mutableCopy];
    petroSetting[@"BeepSelectionEnabled"] = petroSetting[@"PetroSetting"][@"BeepSelectionEnabled"];
    petroSetting[@"GradeSelectionEnabled"] = petroSetting[@"PetroSetting"][@"GradeSelectionEnabled"];
    petroSetting[@"PaymentMode"] = petroSetting[@"PetroSetting"][@"PaymentMode"];
    petroSetting[@"ServiceMode"] = petroSetting[@"PetroSetting"][@"ServiceMode"];
    petroSetting[@"UsePreAuth"] = petroSetting[@"PetroSetting"][@"UsePreAuth"];
    petroSetting[@"Simulation"] = petroSetting[@"PetroSetting"][@"Simulation"];
    petroSetting[@"GasPumpUrl"] = petroSetting[@"RapidOnsite"][@"GasPumpUrl"];
    petroSetting[@"GasPumpUrlEnabled"] = petroSetting[@"RapidOnsite"][@"GasPumpUrlEnabled"];
    
    [[NSUserDefaults standardUserDefaults] setObject:petroSetting forKey:@"RapidPetroSetting"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    settingDictionary[@"RapidPetroSetting"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"RapidPetroSetting"];
    
}

- (BOOL)isPreAuthEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults valueForKey:@"UsePreAuth"] boolValue];
}

- (BOOL)gasGradeSelectionEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults valueForKey:@"GradeSelectionEnabled"] boolValue];
}

- (BOOL)soundeSelectionEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults valueForKey:@"BeepSelectionEnabled"] boolValue];
}

- (BOOL)simulationEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults valueForKey:@"Simulation"] boolValue];
}

@end
