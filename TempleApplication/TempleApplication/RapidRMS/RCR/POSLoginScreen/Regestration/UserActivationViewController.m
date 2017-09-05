//
//  UserActivationViewController.m
//  RapidRMS
//
//  Created by Siya Infotech on 04/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "UserActivationViewController.h"
#import "ModuleActivationVC.h"
#import "RimsController.h"
#import  "StoreSelectionVC.h"
#import "RmsDbController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "ModuleActiveDeactiveVC.h"
#import "RapidWebViewVC.h"
#import "Keychain.h"
#import "ModuleInfo+Dictionary.h"
#import "BranchInfo+Dictionary.h"
#import "RegisterInfo+Dictionary.h"

#ifdef DEBUG
//#define Test_BranchInfo
#endif

#define kOFFSET_FOR_KEYBOARD 80.0

@interface UserActivationViewController ()<UpdateDelegate>
{
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UITextField *txtusername;
@property (nonatomic, weak) IBOutlet UITextField *txtpassword;
@property (nonatomic, weak) IBOutlet UIButton *btnSignin;
@property (nonatomic, weak) IBOutlet UIButton *btnBack;
@property (nonatomic, weak) IBOutlet UIImageView *imgback;
@property (nonatomic, weak) IBOutlet UIImageView *plane;
@property (nonatomic, weak) IBOutlet UILabel *lblFreeTrialVersion;
@property (nonatomic, weak) IBOutlet UIButton *btnFreeTrialVersion;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property(nonatomic,weak)IBOutlet TPKeyboardAvoidingScrollView *scrollview;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *userActivationWC;

@property (nonatomic, strong) NSString *strServiceUrl;
@property (nonatomic, strong) NSString *strServiceResponse;

@end

@implementation UserActivationViewController
@synthesize bFromDashborad;

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
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
      _scrollview.contentSize = CGSizeMake(_scrollview.frame.size.width, 600);
    _btnSignin.layer.cornerRadius = 5.0;
    _btnSignin.layer.borderWidth = 0.5;
    _btnSignin.layer.masksToBounds = YES;
    _btnSignin.layer.borderColor = [UIColor clearColor].CGColor;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.userActivationWC = [[RapidWebServiceConnection alloc] init];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];

    if(!self.bFromDashborad)
    {
    
        NSString *companyId = (self.rmsDbController.globalDict)[@"DeviceId"];
        [Intercom reset];
        [Intercom setHMAC:[self.rmsDbController GetHMACFromUserID:companyId] data:companyId];
        dispatch_after(1.0, dispatch_get_main_queue(), ^ {
            [Intercom registerUserWithUserId:companyId];
            [Intercom updateUserWithAttributes:@{
                                                 @"name" : @"Guest"
                                                 }];
        });
        
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
    
    UIColor *color = [UIColor whiteColor];
    _txtusername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"EMAIL OR USER ID" attributes:@{NSForegroundColorAttributeName:color}];
    _txtpassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName:color}];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.bFromDashborad)
    {
        _btnBack.hidden = NO;
        _imgback.hidden = NO;
        self.strServiceUrl = @"LoginAuthentication";
        self.strServiceResponse = @"LoginAuthenticationResult";
        _btnFreeTrialVersion.hidden = YES;
        _lblFreeTrialVersion.hidden = YES;
        _plane.hidden = YES;
    }
    else
    {
        _btnBack.hidden = YES;
        _imgback.hidden = YES;
//        self.strServiceUrl = @"DeviceAuthentication";
//        self.strServiceResponse = @"DeviceAuthenticationResult";
        self.strServiceUrl = @"DeviceAuthentication07102015";
        self.strServiceResponse = @"DeviceAuthentication07102015Result";
        (self.rmsDbController.globalDict)[@"DBName"] = @"";

        _btnFreeTrialVersion.hidden = NO;
        _lblFreeTrialVersion.hidden = NO;
        _plane.hidden = NO;
    }
    _txtusername.text = @"";
    _txtpassword.text = @"";
#ifdef DEBUG
//    txtusername.text = @"test@ramesh.com";
//    txtpassword.text = @"Test@123";

//    txtusername.text = @"mitulmp@gmail.com";
//    txtpassword.text = @"Admin$123";

//    txtusername.text = @"info@rapidrms.com";
//    txtpassword.text = @"Admin$123";
    
    _txtusername.text = @"demo";
    _txtpassword.text = @"Admin$123";

#endif
    [_txtusername becomeFirstResponder];
}

#pragma mark -
#pragma mark TextFiled Delegate method

//call when press return key in keyboard.
- (BOOL) textFieldShouldReturn:(UITextField *)textFiled {
    if(textFiled == _txtusername)
    {
        [_txtpassword becomeFirstResponder];
    }
    if(textFiled == _txtpassword)
    {
        [textFiled resignFirstResponder];
        [self btnSignInClicked:_btnSignin];
    }
    return YES;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        
    }
}

-(IBAction)btnSignInClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    if([_txtusername.text isEqualToString:@""] )
    {
        [_txtusername becomeFirstResponder];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Activation" message:@"Please enter username" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    else if([_txtpassword.text isEqualToString:@"" ])
    {
        [_txtpassword becomeFirstResponder];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Activation" message:@"Please enter password" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    else
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:_txtusername.text forKey:@"UserName"];
        [param setValue:_txtpassword.text forKey:@"Password"];
        if(self.bFromDashborad)
        {
            [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        }
        if ([self.strServiceUrl isEqualToString:@"DeviceAuthentication07102015"]) {
            [param setValue:(self.rmsDbController.globalDict)[@"DeviceId"] forKey:@"MacAddress"];
            param[@"dType"] = @"IOS-RCRIpad";
            param[@"dVersion"] = [UIDevice currentDevice].systemVersion;
            param[@"LocalDate"] = [self localeDate];
        }
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self responseLoginAuthenticationResponse:response error:error];
            });
        };
        
        self.userActivationWC = [self.userActivationWC initWithRequest:KURL actionName:self.strServiceUrl params:param completionHandler:completionHandler];
    }
}

- (void)responseLoginAuthenticationResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                BOOL isSignUpForTrial = FALSE;
                if ([self.strServiceUrl isEqualToString:@"DeviceAuthentication07102015"]) {
                    isSignUpForTrial = [self.rmsDbController isSignUpForTrial:responseData];
                }
                if (isSignUpForTrial) {
                    [self processForTrialVersion:responseData];
                }
                else
                {
                    if(responseData.count > 0)
                    {
                        [self performActivationProcess:responseData];
                    }
                    else
                    {
                        NSArray *branchInfoArray = [responseData.firstObject valueForKey:@"objBranchInfo"];
#ifdef Test_BranchInfo
                        branchInfoArray = @[];
#endif
                        if (!branchInfoArray.count > 0 || branchInfoArray == nil) {
                            [self branchInfoNotFound];
                            return;
                        }
                    }
                }
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"User Activation" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                _txtusername.text = @"";
                _txtpassword.text = @"";
            }
        }
    }
}

- (void)processForTrialVersion:(NSMutableArray *)responseData {
    (self.rmsDbController.globalDict)[@"IsSignUpForTrial"] = [responseData.firstObject valueForKey:@"ISDEMO"];
    (self.rmsDbController.globalDict)[@"BranchID"] = [responseData.firstObject valueForKey:@"BranchId"];
    (self.rmsDbController.globalDict)[@"DBName"] = [responseData.firstObject valueForKey:@"DBName"];
    (self.rmsDbController.globalDict)[@"RegisterName"] = [responseData.firstObject valueForKey:@"RegisterName"];
    (self.rmsDbController.globalDict)[@"RegisterId"] = [responseData.firstObject valueForKey:@"RegisterId"];
    (self.rmsDbController.globalDict)[@"ZRequired"] = [responseData.firstObject valueForKey:@"ZRequired"];
    (self.rmsDbController.globalDict)[@"ZId"] = [responseData.firstObject valueForKey:@"ZId"];
    (self.rmsDbController.globalDict)[@"TokenId"] = [responseData.firstObject valueForKey:@"TokenId"];
    
    NSMutableArray *arryBranch = [responseData.firstObject valueForKey:@"Branch_MArray"];
    if(arryBranch.count > 0)
    {
        NSMutableArray *responseBranchArray = [arryBranch mutableCopy];
        NSMutableDictionary *dictBranchInfo = responseBranchArray.firstObject;
        dictBranchInfo[@"HelpMessage1"] = [responseData.firstObject valueForKey:@"HelpMessage1"];
        dictBranchInfo[@"HelpMessage2"] = [responseData.firstObject valueForKey:@"HelpMessage2"];
        dictBranchInfo[@"HelpMessage3"] = [responseData.firstObject valueForKey:@"HelpMessage3"];
        dictBranchInfo[@"SupportEmail"] = [responseData.firstObject valueForKey:@"SupportEmail"];
        (self.rmsDbController.globalDict)[@"BranchInfo"] = dictBranchInfo;
    }
    
    self.rmsDbController.appsActvDeactvSettingarray = [responseData.firstObject valueForKey:@"objDeviceInfo"];
    
    if (self.rmsDbController.appsActvDeactvSettingarray.count > 0) {
        NSString *userEmailId = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"BranchInfo"][@"Email"]];
        NSString *userId = [NSString stringWithFormat:@"%@",self.rmsDbController.appsActvDeactvSettingarray.firstObject[@"ConfigurationId"]];
        
        if (userEmailId != nil && userEmailId.length > 0 && userId != nil && userId.length > 0) {
            [Intercom reset];
            [Intercom setHMAC:[self.rmsDbController GetHMACFromUserID:userEmailId] data:userEmailId];
            dispatch_after(1.0, dispatch_get_main_queue(), ^ {
                [Intercom registerUserWithUserId:userId email:userEmailId];
                NSDictionary * userInfo=@{
                                          @"name":[self.rmsDbController.appsActvDeactvSettingarray.firstObject valueForKey:@"STORENAME"],
                                          @"id":self.rmsDbController.appsActvDeactvSettingarray.firstObject[@"ConfigurationId"]
                                          };
                [Intercom updateUserWithAttributes:@{
                                                     @"name" : [[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"],
                                                     @"company" : userInfo
                                                     }];
            });
        }
    }
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    [self.rmsDbController setInvoiceNoFromDict:responseData.firstObject privateContextObject:privateContextObject];
    [self setInvoicePrefixAndSaveInfoInDBFromArray:responseData privateContextObject:privateContextObject];
    [self.rmsDbController getItemDataFirstTime];
}

- (void)performActivationProcess:(NSMutableArray *)responseData {
    NSString *storyBoardName = @"";
    NSString *identifierForStoreSelection = @"";
    NSString *identifierForModuleActiveDeactive = @"";
    if (IsPad()) {
        storyBoardName = @"Main";
        identifierForStoreSelection = @"StoreSelectionVC";
        identifierForModuleActiveDeactive = @"ModuleActiveDeactiveVC";
    }
    else {
        storyBoardName = @"ActiveDeactive_iPhone";
        identifierForStoreSelection = @"StoreSelectionVC_iPhone";
        identifierForModuleActiveDeactive = @"ModuleActiveDeactiveVC_iPhone";
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];

    if(self.bFromDashborad)
    {
        if([[responseData valueForKey:@"IsBranchAdmin"] integerValue] == 1)
        {
            [self goToStoreSelection:storyBoard identifier:identifierForStoreSelection storeArray:self.rmsDbController.appsActvDeactvSettingarrayWithStore];
            NSMutableArray *arrayTemp = [self checkforActiveDeviceInfoForStore:self.rmsDbController.appsActvDeactvSettingarrayWithStore];
            if ([self getConfigrationID:arrayTemp]) {
                (self.rmsDbController.globalDict)[@"CONFIGID"] = [self getConfigrationID:arrayTemp];
            }
            [self goToModuleActivation:storyBoard identifier:identifierForModuleActiveDeactive storeArray:arrayTemp];
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
        if([[responseData[0] valueForKey:@"IsBranchAdmin"] integerValue ] == 1)
        {
            (self.rmsDbController.globalDict)[@"BranchID"] = [[[responseData.firstObject valueForKey:@"objBranchInfo"] valueForKey:@"BranchId"] firstObject];
            [self goToStoreSelection:storyBoard identifier:identifierForStoreSelection storeArray:responseData];
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Applications" message:@"User have no right to view Apps." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }

    
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
//    {
//    }
//    else
//    {
//        ModuleActivationVC *objModuleActive = [[ModuleActivationVC alloc] initWithNibName:@"ModuleActivationVC_iPhone" bundle:nil];
//        (self.rmsDbController.globalDict)[@"DBName"] = [responseData.firstObject valueForKey:@"DBNAME"];
//        objModuleActive.arrDeviceAuthentication = [self.rmsDbController objectFromJsonString:response[@"Data"]];
//        [self.navigationController pushViewController:objModuleActive animated:YES];
//    }
}

- (void)goToStoreSelection:(UIStoryboard *)storyBoard identifier:(NSString *)identifier storeArray:(NSMutableArray *)storeArray {
    StoreSelectionVC *objStoreVC = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    objStoreVC.arrayStore = [storeArray mutableCopy];
    objStoreVC.bFromDashborad = self.bFromDashborad;
    [self.appDelegate.navigationController pushViewController:objStoreVC animated:NO];
}

- (void)goToModuleActivation:(UIStoryboard *)storyBoard identifier:(NSString *)identifier storeArray:(NSMutableArray *)storeArray {
    ModuleActiveDeactiveVC *objActiveDeactive = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    objActiveDeactive.arrDeviceAuthentication = [storeArray mutableCopy];
    objActiveDeactive.bFromDashborad = self.bFromDashborad;
    [self.appDelegate.navigationController pushViewController:objActiveDeactive animated:YES];
}

- (void)setInvoicePrefixAndSaveInfoInDBFromArray:(NSMutableArray *)responseData privateContextObject:(NSManagedObjectContext *)privateContextObject
{
    NSString *storeInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
    if (storeInvoiceNo)
    {
        Configuration *configuration = [self.updateManager insertConfigurationMoc:privateContextObject ];
        configuration.regPrefixNo = [responseData.firstObject valueForKey:@"InvPrefix"];
    }
    else
    {
        Configuration *configuration = [self.updateManager insertConfigurationMoc:privateContextObject];
        if(configuration.invoiceNo != 0)
        {
            [Keychain saveString:configuration.invoiceNo.stringValue forKey:@"tenderInvoiceNo"];
            configuration.regPrefixNo = [responseData.firstObject valueForKey:@"InvPrefix"];
        }
        else
        {
            [Keychain saveString:@"0" forKey:@"tenderInvoiceNo"];
            configuration.regPrefixNo = [responseData.firstObject valueForKey:@"InvPrefix"];
            
        }
    }
    [self configureDatabaseWithDeviceConfiguration:privateContextObject usingArray:responseData];
    [UpdateManager saveContext:privateContextObject];
}

- (void)configureDatabaseWithDeviceConfiguration:(NSManagedObjectContext *)privateContextObject usingArray:(NSMutableArray *)responseData
{
    NSPredicate *filterRcrPredicate = [NSPredicate predicateWithFormat:@"MacAdd = %@",(self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *array = [self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:filterRcrPredicate];
    if (array.count > 0)
    {
        [self.updateManager deleteModuleInfoFromDatabaseWithContext:privateContextObject];
        
        for (NSDictionary *dictionary in array)
        {
            ModuleInfo *moduleInfo = [self.updateManager updateModuleInfoMoc:privateContextObject];
            [moduleInfo updateModuleInfoDictionary:dictionary];
        }
    }
    
    RegisterInfo *registerInfo = [self.updateManager updateRegisterInfoMoc:privateContextObject];
    [registerInfo updateRegisterInfoDictionary:responseData.firstObject];
    
    BranchInfo *branchInfo = [self.updateManager updateBranchInfoMoc:privateContextObject];
    [branchInfo updateBranchInfoDictionary:[self.rmsDbController.globalDict valueForKey:@"BranchInfo"]];
    
    NSDictionary *userInfo = [responseData.firstObject valueForKey:@"UserInfo"];
    [self.updateManager deleteDetailOfUserInfo:privateContextObject];
    [self.updateManager updateDetailWithUserInfo:userInfo withmoc:privateContextObject];
    [UpdateManager saveContext:privateContextObject];
}

- (NSString *)localeDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    return currentDateTime;
}

- (void)branchInfoNotFound
{
    [self showNotFoundAlertWithMessage:@"Branch info not found" forPageId:PageIdDashboard];
}

- (void)showNotFoundAlertWithMessage:(NSString *)message forPageId:(PageId)pageId
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self loadRapidWebViewWithPageId:pageId];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"User Activation" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (void)loadRapidWebViewWithPageId:(PageId)pageId
{
    RapidWebViewVC *rapidWebVC = [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"RapidWebViewVC_sid"];
    rapidWebVC.pageId = pageId;
    rapidWebVC.userName = _txtusername.text;
    rapidWebVC.password = _txtpassword.text;

    [self.navigationController pushViewController:rapidWebVC animated:YES];
}

-(NSMutableArray *)checkforActiveDeviceInfoForStore:(NSMutableArray *)aStore
{
    NSMutableArray *arrayTemp = [[NSMutableArray alloc]init];
    NSMutableDictionary *dictActiveStore;
    for(int i=0;i<aStore.count;i++)
    {
        NSMutableDictionary *dictStore = [aStore[i]mutableCopy];
        NSMutableArray *arrayDeviceInfo = [dictStore valueForKey:@"objDeviceInfo"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"MacAdd = %@",[self.rmsDbController.globalDict valueForKey:@"DeviceId"]];
        NSArray *arrayTemp = [arrayDeviceInfo filteredArrayUsingPredicate:predicate];
        if(arrayTemp.count>0)
        {
            dictActiveStore=dictStore;
            break;
        }
    }
    if(dictActiveStore != nil)
    {
        [arrayTemp addObject:dictActiveStore];
    }
    return arrayTemp;
}

-(NSString *)getConfigrationID:(NSMutableArray *)arrayTemp
{
    NSString *strconfigId;
    NSMutableArray *array = [arrayTemp.firstObject valueForKey:@"objDeviceInfo"];
    strconfigId = [array.firstObject valueForKey:@"ConfigurationId"];
    
    return strconfigId;
}

- (IBAction)openforgotPassword:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://demo.rapidrms.com/Account/ForgotPassword"]];
}

- (IBAction)freeTrialVersion:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rapidrms.com/Static/Signup"]];
}

-(IBAction)backtoDashboard:(id)sender
{
    NSMutableArray *responseData = [self checkforActiveDeviceInfoForStore:self.rmsDbController.appsActvDeactvSettingarrayWithStore];
    [responseData.firstObject valueForKey:@"objDeviceInfo"];
    self.rmsDbController.appsActvDeactvSettingarray = [responseData.firstObject valueForKey:@"objDeviceInfo"];;
    [self.appDelegate.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
