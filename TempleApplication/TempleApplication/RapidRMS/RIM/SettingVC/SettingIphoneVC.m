//
//  SettingViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 07/01/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "SettingIphoneVC.h"
#import "QuartzCore/QuartzCore.h"
#import "ScannerSettingVC.h" 
#import "RimAboutAppVC.h"
#import "RmsDbController.h"
#import "SettingSoundVC.h"
#import "ModuleActivationVC.h"
#import "iPhoneModuleSettingViewController.h"
#import "SettingIphoneCell.h"
#import "UserActivationViewController.h"


@interface SettingIphoneVC ()<UITableViewDelegate , UITableViewDataSource>
{
    ScannerSettingVC *objScanner;
    RimAboutAppVC * objAboutApp;
    SettingSoundVC *objSound;
}

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UIView *viewAuthentication;
@property (nonatomic, weak) IBOutlet UITableView *tblSettingOption;
@property (nonatomic, weak) IBOutlet UITextField *txtUserID;
@property (nonatomic, weak) IBOutlet UITextField *txtpassword;
@property (nonatomic, strong) RapidWebServiceConnection *webServiceConnectionSettingBG;


@property (nonatomic, strong) RapidWebServiceConnection * userAccessLoginWC;

@end

@implementation SettingIphoneVC


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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.userAccessLoginWC = [[RapidWebServiceConnection alloc]init];
    _viewAuthentication.hidden=YES;
//    self.navigationController.navigationBarHidden=YES;
//    (self.navigationItem).title = @"SETTING";
//    self.navigationItem.hidesBackButton=YES;
//    
//    (self.navigationController.navigationBar).barTintColor = [UIColor colorWithRed:22.0/255.0 green:19.0/255.0 blue:36.0/255.0 alpha:1.0];
//    (self.navigationController.navigationBar).titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};

    if ([UIDevice currentDevice].systemVersion.floatValue >= 7)
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    UIColor *color = [UIColor whiteColor];
    _txtUserID.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"EMAIL OR USER ID" attributes:@{NSForegroundColorAttributeName:color}];
    _txtpassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName:color}];

    self.webServiceConnectionSettingBG = [[RapidWebServiceConnection alloc] init];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tblSettingOption reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(IsPhone())
    {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        
    }
}

-(IBAction)btnBack:(id)sender
{
    [self storeUserDefaultSetting];
    NSArray *arryView = self.navigationController.viewControllers;
    for(int i=0; i< arryView.count; i++)
    {
        UIViewController *viewCon = arryView[i];
        if([viewCon isKindOfClass:[RmsDashboardVC class]] )
        {
            [self.navigationController popToViewController:viewCon animated:YES];
            break;
        }
    }
}

-(void)storeUserDefaultSetting
{
    NSMutableDictionary *rapidMainSettingDict = [[NSMutableDictionary alloc]init];
    rapidMainSettingDict[@"BranchConfigurationSetting"] = [self configureRapidSetting];
    NSLog(@"%@",rapidMainSettingDict[@"BranchConfigurationSetting"]);
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self insertBranchConfigurationSettingResponse:response error:error];
    };
    
    self.webServiceConnectionSettingBG = [self.webServiceConnectionSettingBG initWithAsyncRequest:KURL actionName:WSM_INSERT_BRACH_CONFIGURATION_SETTING params:rapidMainSettingDict asyncCompletionHandler:asyncCompletionHandler];
}

-(void)insertBranchConfigurationSettingResponse:(id)response error:(NSError *)error
{
}
-(NSDictionary *)configureRapidSetting
{
    NSMutableDictionary *rapidSettingDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *settingDictionary = [[NSMutableDictionary alloc]init];
    [self soundSettingForRapidRMS:settingDictionary];
    [self scannerSettingForRapidRMS:settingDictionary];
    [self upcSettingForRapidRMS:settingDictionary];
    
    [rapidSettingDictionary setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [rapidSettingDictionary setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    if (self.rmsDbController.globalDict[@"UserInfo"] || ![self.rmsDbController.globalDict[@"UserInfo"] isKindOfClass:[NSNull class]]) {
        [rapidSettingDictionary setValue:[self.rmsDbController.globalDict [@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
      }
    else{
        [rapidSettingDictionary setValue:@"" forKey:@"UserId"];
    }
    
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
-(void)upcSettingForRapidRMS:(NSMutableDictionary *)settingDictionary
{
    NSMutableArray *upcSetting = [[NSUserDefaults standardUserDefaults] valueForKey:@"UPC_Setting"];
    if (upcSetting.count > 0)
    {
        settingDictionary[@"RapidUPC_Setting"] = upcSetting;
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

// tableview funtions start

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblSettingOption)
    {
        return 4;
        //return 3;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) // Scanner type
    {
        return 1;
    }
    if (section == 1) // About application
    {
        return 1;
    }
    if (section == 2) // Set Sound
    {
        return 1;
    }
    if (section == 3) // Set App Setting
    {
        return 1;
    }
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"SettingIphoneCell";
    SettingIphoneCell *settingIphoneCell = [self.tblSettingOption dequeueReusableCellWithIdentifier:CellIdentifier];
    settingIphoneCell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
           
           settingIphoneCell.lblTital.text = @"TYPE";
          
//            if (IsPhone())
//            {
//                lblScannerType = [[UILabel alloc] initWithFrame:CGRectMake(175, 7, 150, 30)];
//            }
//            else
//            {
//                lblScannerType = [[UILabel alloc] initWithFrame:CGRectMake(550, 7, 150, 30)];
//            }
            
            if([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Scanner"])
            {
                settingIphoneCell.lblValue.text= @"Linea Pro";
            }
            else
            {
                settingIphoneCell.lblValue.text = (self.rmsDbController.globalScanDevice)[@"Type"];
            }
        }
    }
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            settingIphoneCell.lblTital.text = @"ABOUT US";
            settingIphoneCell.lblValue.text = @"";
        }
    }
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            settingIphoneCell.lblTital.text = @"SOUND";
            settingIphoneCell.lblValue.text = @"";

        }
    }
    if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            settingIphoneCell.lblTital.text = @"APP SETTING";
            settingIphoneCell.lblValue.text = @"";

                    }
    }
    return settingIphoneCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.rmsDbController playButtonSound];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellStyleDefault;
    
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(tablereload) userInfo:Nil repeats:NO];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            if (objScanner==nil) {
                objScanner=[[ScannerSettingVC alloc]initWithNibName:@"ScannerSettingVC" bundle:nil];
            }
            if (IsPhone()) {
                
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                objScanner = [storyBoard instantiateViewControllerWithIdentifier:@"ScannerSettingVC_Iphone"];
                [self.navigationController pushViewController:objScanner animated:TRUE];
            }
            else {
                
                [self.view addSubview:objScanner.view];
            }
        }
    }
    if(indexPath.section == 1) {
        
        if(indexPath.row == 0) {
            
            if (objAboutApp==nil)
            {
                objAboutApp=[[RimAboutAppVC alloc]initWithNibName:@"RimAboutAppVC" bundle:nil];
            }
            if (IsPhone()) {
                
                [self.navigationController pushViewController:objAboutApp animated:TRUE];
            }
            else {
                
                [self.view addSubview:objAboutApp.view];
            }
        }
    }
    if(indexPath.section == 2)
    {
        
        if(indexPath.row == 0)
        {
            if (IsPhone())
            {
                
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                SettingSoundVC *objSoundiPhone = [storyBoard instantiateViewControllerWithIdentifier:@"SettingSoundVC_Iphone"];
                [self.navigationController pushViewController:objSoundiPhone animated:TRUE];
                
              //  SettingSoundVC *objSoundiPhone = [[SettingSoundVC alloc]initWithNibName:@"SettingSoundVC" bundle:nil];
              //  [self.navigationController pushViewController:objSoundiPhone animated:TRUE];
            }
            else
            {
                objSound = [[SettingSoundVC alloc]initWithNibName:@"SettingSoundVC" bundle:nil];
                [self.view addSubview:objSound.view];
            }
        }
    }
    if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            if (IsPhone()) {
                [self goTODeviceActivation];
            }
            else {
                self.navigationController.navigationBar.hidden=YES;
                _viewAuthentication.hidden=NO;
            }
        }
    }
}

-(void)goTODeviceActivation
{
    UserActivationViewController *objUser = [[UserActivationViewController alloc] initWithNibName:@"UserActivationVC_iPhone" bundle:nil];
    objUser.bFromDashborad = YES;
    [self.navigationController pushViewController:objUser animated:YES];
}

-(IBAction)hidelogin:(id)sender{
    [self.rmsDbController playButtonSound];
  //  self.navigationController.navigationBarHidden=NO;
  //  self.navigationController.navigationBar.hidden=NO;
    _viewAuthentication.hidden=YES;
}


-(IBAction)btnSignInClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    if([_txtUserID.text isEqualToString:@""] )
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please Enter Username." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else if([_txtpassword.text isEqualToString:@"" ])
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please Enter Password." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else
    {
        // username & password Login
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:_txtUserID.text forKey:@"UserName"];
        [param setValue:_txtpassword.text forKey:@"Password"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self responseUserAuthenticationResponse:response error:error];
            });
        };
        
        self.userAccessLoginWC = [self.userAccessLoginWC initWithRequest:KURL actionName:WSM_LOGIN_AUTHENTICATION params:param completionHandler:completionHandler];
    }
}

- (void)responseUserAuthenticationResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *responseData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if([[responseData valueForKey:@"IsBranchAdmin"] integerValue ] == 1)
                {
                    iPhoneModuleSettingViewController *objModuleActive = [[iPhoneModuleSettingViewController alloc] initWithNibName:@"iPhoneModuleSettingViewController" bundle:nil];
                    
                    objModuleActive.arrDeviceAuthentication = [self.rmsDbController.appsActvDeactvSettingarray mutableCopy];
                    [self.navigationController pushViewController:objModuleActive animated:YES];
                    
                }
                else
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Applications" message:@"User have no right to view Apps." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    
                }
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Applications" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    _txtUserID.text = @"";
    _txtpassword.text = @"";
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(void)tablereload
{
    [self.tblSettingOption reloadData];
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
