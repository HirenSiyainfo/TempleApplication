//
//  POSLoginView.m
//  POSFrontEnd
//
//  Created by Minesh Purohit on 12/11/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "POSLoginView.h"
#import "ClockInDetailsView.h"
#import "PopOverController.h"
#import "ReportViewController.h"
#import "ZRequiredViewController.h"
#import "RmsDbController.h"
#import "SizeMaster+Dictionary.h"
#import "Keychain.h"

#import "CardSettlementVC.h"
#import "RcrPosVC.h"
#import "CredentialInfo.h"
#import "UserInfo+Dictionary.h"
#import "CKOCalendarViewController.h"
#import "RestaurantOrderList.h"
#import "CustomerViewController.h"
#import "Configuration.h"
#define NName @"POSCashInOut"
#define Offline_Login_Limit 2

//#define CheckRights

typedef NS_ENUM(NSInteger, LOGIN_PROCESS)
{
    ENTER_LOGIN_PROCESS,
    CLOCK_IN_LOGIN_PROCESS,
    CLOCK_OUT_LOGIN_PROCESS,
};

typedef NS_ENUM(NSInteger, ACTIVE_MODULE)
{
    ACTIVE_MODULE_RCR,
    ACTIVE_MODULE_GAS,
    ACTIVE_MODULE_RETAIL_RESTAURENT,
    ACTIVE_MODULE_RESTAURENT,
    ACTIVE_MODULE_INVALID,
};

@interface POSLoginView () <UpdateDelegate>

{
    IntercomHandler *intercomHandler;
    Configuration *configuration;
}

@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnQuickLogin;
@property (nonatomic, weak) IBOutlet UIButton *btnUsername;
@property (nonatomic, weak) IBOutlet UIButton *btnSignIn;
@property (nonatomic, weak) IBOutlet UITextField *userName;
@property (nonatomic, weak) IBOutlet UITextField *password;
@property (nonatomic, weak) IBOutlet UIButton *btnClockIn;
@property (nonatomic, weak) IBOutlet UIButton *btnClockOut;
@property (nonatomic, weak) IBOutlet UIView *uvLoginNumpad;
@property (nonatomic, weak) IBOutlet UIView *viewKeypad;
@property (nonatomic, weak) IBOutlet UILabel *lblDeviceName;
@property (nonatomic, weak) IBOutlet UILabel *lblModuleName;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) CashinOutViewController * cashInOutView;
@property (nonatomic, strong) UpdateManager *departmentUpdateManager;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;

@property (nonatomic, strong) RapidWebServiceConnection *recallCountWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *accessLoginWC;
@property (nonatomic, strong) RapidWebServiceConnection *quickLoginWC;
@property (nonatomic, strong) RapidWebServiceConnection *zOpeningNoReqOperationWC;

@property (nonatomic, strong) UIPopoverController *calendarPopOverController;

@property (nonatomic, strong) NSMutableArray *responseLoginData ;
@property (nonatomic, strong) NSDate *activeTime;
@property (nonatomic, strong) NSDate *resignTime;
@property (nonatomic, strong) NSString *process;
@property (atomic) NSInteger loginProcess;

@end

@implementation POSLoginView

@synthesize cashInOutView;
@synthesize displayText;

@synthesize managedObjectContext = __managedObjectContext;

// set the layout form them NIB file.
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // set up custom code.
        [self.view setNeedsDisplay];
    }
    return self;
}

- (void)updateDateLable
{
    // set initials first selected.
    NSDate* date = [NSDate date];
    
    //Create the dateformatter object
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    //Set the required date format
    formatter.dateFormat = @"MMMM dd, yyyy";
    
    //Get the string date
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    self.accessLoginWC = [[RapidWebServiceConnection alloc] init];
    self.quickLoginWC = [[RapidWebServiceConnection alloc] init];
    self.zOpeningNoReqOperationWC = [[RapidWebServiceConnection alloc] init];
    
    self.managedObjectContext = self.crmController.managedObjectContext;
    
    self.recallCountWebserviceConnection = [[RapidWebServiceConnection alloc] init];
    self.departmentUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    _btnSignIn.layer.cornerRadius = 6.0;
    
    self.lblDeviceName.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.globalDict valueForKey:@"RegisterName"]];
    [Appsee markViewAsSensitive:_uvLoginNumpad];
    [Appsee markViewAsSensitive:[self.view viewWithTag:1002]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self GetRecallDataCount];
    
    
    [self updateDateLable];
    
    
    [self setSideBarButtonAction];
    
    [self sideBarbuttonActionHandler:_btnQuickLogin];
    
    
    [_userName setValue:[UIColor colorWithRed:194.0/255.0 green:199.0/255.0 blue:214.0/255.0 alpha:1.0]
                    forKeyPath:@"_placeholderLabel.textColor"];
    [_password setValue:[UIColor colorWithRed:153.0/255.0 green:164.0/255.0 blue:177.0/255.0 alpha:1.0]
            forKeyPath:@"_placeholderLabel.textColor"];
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    //[self.view setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.5]];
    //
    //    NSString *zID = [NSString stringWithFormat:@"%@",[self.rmsDbController.globalDict objectForKey:@"ZId"]];
    //
    //    [self showAlertForZIDEqualToZero:zID];
    
    /* [self.view addSubview:viewQuickLogin];
     [viewQuickLogin setFrame:CGRectMake(63.0, 95.0, viewQuickLogin.frame.size.width, viewQuickLogin.frame.size.height)];*/
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];

}

-(void)showAlertForZIDEqualToZero:(NSString *)zID
{
    if ([zID isEqualToString:@"0"] || zID == nil) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self showAlertForZIDEqualToZero:zID];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please restart the application or contact to RapiRMS" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}
-(void)GetRecallDataCount
{
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self responseRecallCountlistResponse:response error:error];
    };
    
    self.recallCountWebserviceConnection = [self.recallCountWebserviceConnection initWithRequest:KURL actionName:WSM_RECALL_INVOICE_LIST_SERVICE params:param completionHandler:completionHandler];
}

- (void)responseRecallCountlistResponse:(id)response error:(NSError *)error
{
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray * responsearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(responsearray.count>0)
                {
                    self.crmController.recallCount = responsearray.count;
                }
                else
                {
                    self.crmController.recallCount = responsearray.count;
                }
                self.crmController.recallCount +=[self.departmentUpdateManager fetchEntityObjectsCounts:@"HoldInvoice" withManageObjectContext:self.managedObjectContext];
            }
        }
    }
    else
    {
        self.crmController.recallCount = [self.departmentUpdateManager fetchEntityObjectsCounts:@"HoldInvoice" withManageObjectContext:self.managedObjectContext];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if([self.rmsDbController.selectedModule isEqualToString:@"Setting"])
    {
            self.lblModuleName.text = @"Setting";
    }
    else{
        self.lblModuleName.text = @"Rapid Cash Register";
    }
}

-(void)applicationDidBecomeActive :(NSNotification *)notification
{
    self.activeTime = [NSDate date];
    NSDate* date1 = self.activeTime;
    NSDate* date2 = self.resignTime;
    NSTimeInterval distanceBetweenDates = [date1 timeIntervalSinceDate:date2];
    double secondsInAnHour = 3600;
    
    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    if(hoursBetweenDates>=2)
    {
        self.rmsDbController.isSynchronizing = YES;
        [self.rmsDbController startItemUpdate:0];
    }
}

-(void)applicationWillResignActive :(NSNotification *)notification
{
    self.resignTime = [NSDate date];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

#pragma mark -
#pragma mark KeyPad button action.

// call action on the press the keypad button.
- (IBAction) pressKeyPadButton:(id)sender
{
    [self.rmsDbController playButtonSound];
    UIButton *btn;
    
    for(int i=0;i<_uvLoginNumpad.subviews.count;i++){
        
        btn=(_uvLoginNumpad.subviews)[i];
        
        if([btn isKindOfClass:[UIButton class]]){
            if(btn.tag==[sender tag])
            {
                if(btn.tag==0)
                {
                    [btn setImage:[UIImage imageNamed:@"desk_num0Active.png"] forState:UIControlStateHighlighted];
                }
                else if(btn.tag==-99)
                {
                    [btn setImage:[UIImage imageNamed:@"desk_num_c_Active.png"] forState:UIControlStateHighlighted];
                }
                else if(btn.tag==101)
                {
                    [btn setImage:[UIImage imageNamed:@"desk_num_enter_active.png"] forState:UIControlStateHighlighted];
                    
                }
                else if (btn.tag > 0 && btn.tag < 10)
                {
                    NSString *strImg = [NSString stringWithFormat:@"desk_num%ldActive.png",(long)btn.tag];
                    [btn setImage:[UIImage imageNamed:strImg] forState:UIControlStateHighlighted];
                }
                else
                {
                }
            }
            
            
            else{
                
                if(btn.tag==0)
                {
                    [btn setImage:[UIImage imageNamed:@"desk_num0Normal.png"] forState:UIControlStateNormal];
                    
                }
                else if(btn.tag==-99)
                {
                    
                    [btn setImage:[UIImage imageNamed:@"desk_num_c_Normal.png"] forState:UIControlStateNormal];
                    
                }
                else if(btn.tag==101)
                {
                    [btn setImage:[UIImage imageNamed:@"desk_num_enter.png"] forState:UIControlStateNormal];
                }
                else if (btn.tag > 0 && btn.tag < 10)
                {
                    NSString *strImg = [NSString stringWithFormat:@"desk_num%ldNormal.png",(long)btn.tag];
                    [btn setImage:[UIImage imageNamed:strImg] forState:UIControlStateNormal];
                }
                else
                {
                    
                }
            }
        }
    }
    
    
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        NSString * displyValue = [displayText.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
        displayText.text = displyValue;
    }
    else if ([sender tag] == -99)
    {
        if (displayText.text.length > 0)
        {
            //displayText.text = [displayText.text substringToIndex:[displayText.text length]-1];
            displayText.text = @"";
            [self setKeypad];
        }
    } else if ([sender tag] == 101)
    {
        self.loginProcess = ENTER_LOGIN_PROCESS;
        [self doQuickLogin:nil];
        [self setKeypad];
    }
    
    [self setKeypad];
    
}



-(void)setKeypad
{
    UIButton *btn;
    
    for(int i=0;i<_uvLoginNumpad.subviews.count;i++)
    {
        btn=(_uvLoginNumpad.subviews)[i];
        
        if([btn isKindOfClass:[UIButton class]])
        {
            if(btn.tag==0)
            {
                [btn setImage:[UIImage imageNamed:@"desk_num0Normal.png"] forState:UIControlStateNormal];
                
            }
            else if(btn.tag==-99)
            {
                
                [btn setImage:[UIImage imageNamed:@"desk_num_c_Normal.png"] forState:UIControlStateNormal];
                
            }
            else if(btn.tag==101)
            {
                [btn setImage:[UIImage imageNamed:@"desk_num_enter.png"] forState:UIControlStateNormal];
                
            }
            else if (btn.tag > 0 && btn.tag < 10)
            {
                
                NSString *strImg = [NSString stringWithFormat:@"desk_num%ldNormal.png",(long)btn.tag];
                
                [btn setImage:[UIImage imageNamed:strImg] forState:UIControlStateNormal];
            }
            else
            {
                
            }
        }
    }
}

#pragma mark -
#pragma mark Side Bar Methods.


// set button action for the side bar.
- (void) setSideBarButtonAction {
    // for now we disable those buttons
    [_btnQuickLogin addTarget:self action:@selector(sideBarbuttonActionHandler:) forControlEvents:UIControlEventTouchUpInside];
    [_btnUsername addTarget:self action:@selector(sideBarbuttonActionHandler:) forControlEvents:UIControlEventTouchUpInside];
}
-(IBAction)btnUserLoginClick:(id)sender
{
}

// side bar button action handler.
- (void) sideBarbuttonActionHandler:(id)sender {
    
    [self highlightSideButton:sender];
    [_userName becomeFirstResponder];
    [self hideAllSubViewOfSlideBar];
    switch ([sender tag]) {
        case 501:
            [_btnQuickLogin setSelected:YES];
            [_btnUsername setSelected:NO];
            
            [self.rmsDbController playButtonSound];
            [_userName resignFirstResponder];
            [_password resignFirstResponder];
            [self setKeypad];
            displayText.text = @"";
            [[self.view viewWithTag:1001] setHidden:NO];
            break;
        case 502:
            [_btnQuickLogin setSelected:NO];
            [_btnUsername setSelected:YES];
            displayText.text = @"";
            [self.rmsDbController playButtonSound];
            _userName.text = @"";
            _password.text = @"";
            [_userName becomeFirstResponder];
            [[self.view viewWithTag:1002] setHidden:NO];
            break;
        case 503:
            break;
        case 504:
            break;
            
        default:
            break;
    }
}

// reset the button view.
- (void) highlightSideButton:(id)sender {
    [self resetButtonImage];
    switch ([sender tag]) {
        case 501:
            //[_btnQuickLogin setImage:[UIImage imageNamed:@"desk_KeypadActive.png"] forState:UIControlStateNormal];
            break;
        case 502:
            //	[_btnUsername setImage:[UIImage imageNamed:@"desk_UserActive.png"] forState:UIControlStateNormal];
            break;
        case 503:
            //	[btnCard setImage:[UIImage imageNamed:@"btn_3Active.png"] forState:UIControlStateNormal];
            break;
        case 504:
            //	[btnFingure setImage:[UIImage imageNamed:@"btn_4Active.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}
// hidden all view for frist time.
- (void) hideAllSubViewOfSlideBar {
    [[self.view viewWithTag:1001] setHidden:YES];
    [[self.view viewWithTag:1002] setHidden:YES];
    [[self.view viewWithTag:1003] setHidden:YES];
    [[self.view viewWithTag:1004] setHidden:YES];
}

// reset all images to the faded.
- (void)resetButtonImage {
}

- (void) ExitVoidResult:(NSNotification *) notification {
    if (notification.object != nil) {
        if ([[notification.object valueForKey:@"AddVoidInvoiceTransResult"] count] > 0) {
            
            if ([[[notification.object valueForKey:@"AddVoidInvoiceTransResult"]  valueForKey:@"IsError"] intValue] == 0)
            {
                // SAVE INCREMENTED INVOICE NUMBER IN KEYCHAIN
                NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
                NSInteger number = keyChainInvoiceNo.integerValue;
                number++;
                NSString *updatedTenderInvoiceNo = [NSString stringWithFormat: @"%d", (int)number];
                [Keychain saveString:updatedTenderInvoiceNo forKey:@"tenderInvoiceNo"];
                
                //[self.crmController.reciptDataAry removeAllObjects];
                [self.crmController.reciptItemLogDataAry removeAllObjects];
                
                self.crmController.singleTap1.enabled=NO;
                NSArray *viewControllerArray = self.navigationController.viewControllers;
                for (UIViewController *viewController in viewControllerArray)
                {
                    if ([viewController isKindOfClass:[DashBoardSettingVC class]])
                    {
                        [self.navigationController popToViewController:viewController animated:TRUE];
                    }
                }
            }
        }
    }
}


#pragma mark -
#pragma mark Calling WebServices

// method for clock in/out system.
- (IBAction) dobtnSignin:(id)sender {
    [self.rmsDbController playButtonSound];
    [self doSigninProcess:sender];
}



- (CredentialInfo*)fetchUsernamePasswordFromDatabaseWith :(NSString *)username withPassword:(NSString *)pasword withContext:(NSManagedObjectContext *)context
{
    CredentialInfo *credentialInfo=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CredentialInfo" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userName==%@ AND password==%@",username,pasword];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:context FetchRequest:fetchRequest];
    if (resultSet.count == 0)
    {
        credentialInfo = (CredentialInfo *)[self insertCredentialEntityWithName:@"CredentialInfo" moc:context];
    }
    else
    {
        credentialInfo = resultSet.firstObject;
    }
    return credentialInfo;
}

- (void)saveUserNamePassWordToDatabaseWithUserInfo :(NSDictionary *)userInfoDictionary
{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId==%@", [userInfoDictionary valueForKey:@"UserId"]];
    CredentialInfo *credentialInfo = [self fetchuserCredentilaFromDatabase:predicate withContext:privateContextObject];
    credentialInfo.userName = _userName.text;
    credentialInfo.password = _password.text;
    NSArray *totalUserInfoOfDataBase = [self fetchUserInfoFromDatabasewithContext:privateContextObject];
    for (UserInfo *userInfo in totalUserInfoOfDataBase)
    {
        userInfo.updateDate = [NSDate date];
    }
    [UpdateManager saveContext:privateContextObject];
}



-(void)doSigninProcess:(id)sender {
    if ([[_userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqual:@""]) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [_userName becomeFirstResponder];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Enter Username." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
    }
    else if([[_password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqual:@""])
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [_password becomeFirstResponder];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Enter Password." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    else {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:_userName.text forKey:@"UserName"];
        [param setValue:_password.text forKey:@"Password"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loginResponse:response error:error usingQuickAccess:NO];
            });
        };
        
        self.accessLoginWC = [self.accessLoginWC initWithRequest:KURL actionName:WSM_USER_SIGN_IN_PROCESS params:param completionHandler:completionHandler];
    }
}

- (NSInteger)userOfflineLoginPeriod:(CredentialInfo *)credentialInfo
{
    NSDate* date1 = credentialInfo.credentialToUser.updateDate;
    NSDate* date2 = [NSDate date];
    NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
    double secondsInAnHour = 3600 * 24;
    NSInteger daysBetweenDates = distanceBetweenDates / secondsInAnHour;
    return daysBetweenDates;
}

-(BOOL)isRcrActive
{
    BOOL isRcrActive = FALSE;
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ ",@"RCR"];
    NSArray *rcrArray = [activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0)
    {
        isRcrActive = TRUE;
    }
    else
    {
        isRcrActive = FALSE;
    }
    return isRcrActive;
}

-(ACTIVE_MODULE)activeModuleId
{
    ACTIVE_MODULE activeModule;
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    
    ///
    NSArray *moduleCodes = @[@"RCR",@"RCRGAS",@"RRRCR",@"RRCR"]; // must match order of Enum ACTIVE_MODULE....
    ///
    
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@" ModuleCode IN %@",moduleCodes];
    NSArray *moduleArray = [activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (moduleArray.count > 0) {
        
        NSString *moduleCode = [moduleArray.firstObject valueForKey:@"ModuleCode"];
        activeModule = [moduleCodes indexOfObject:moduleCode ];
    }
    else
    {
        activeModule = ACTIVE_MODULE_INVALID;
    }
    return activeModule;
}

-(void)launchGasPosDashboard:(NSString *)require
{
    // UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    NSString *identiFier = @"";
    
    ACTIVE_MODULE activeModule = [self activeModuleId];
    switch (activeModule) {
        case ACTIVE_MODULE_RCR:
            identiFier = @"RcrPosVC";
            break;
            
        case ACTIVE_MODULE_GAS:
            identiFier = @"RcrPosGasVC";
            break;
            
        case ACTIVE_MODULE_RETAIL_RESTAURENT:
            identiFier = @"RetailRestaurant";
            break;
            
        case ACTIVE_MODULE_RESTAURENT:
            identiFier = @"RcrPosRestaurantVC";
            break;
            
        default:
            break;
    }
    
    
    if(identiFier.length > 0)
    {
        if ([identiFier isEqualToString:@"RcrPosRestaurantVC"])
        {
            [self goToRestaurantOrderListWithShiftRequire:require];
        }
        else
        {
            if ([identiFier isEqualToString:@"RetailRestaurant"] && [configuration.subDepartment isEqual:@(1)]) {
                identiFier = @"RetailRestaurant";
            }
            else if ([identiFier isEqualToString:@"RetailRestaurant"] && [configuration.subDepartment isEqual:@(0)]) {
                identiFier = @"RcrPosVC";
            }
            else if ([identiFier isEqualToString:@"RcrPosVC"] && [configuration.subDepartment isEqual:@(1)]) {
                identiFier = @"RetailRestaurant";
            }
            else if ([identiFier isEqualToString:@"RcrPosVC"] && [configuration.subDepartment isEqual:@(0)]) {
                identiFier = @"RcrPosVC";
            }
            else if ([identiFier isEqualToString:@"RcrPosRestaurantVC"] && [configuration.subDepartment isEqual:@(1)]) {
                identiFier = @"RcrPosRestaurantVC";
            }
            else if ([identiFier isEqualToString:@"RcrPosRestaurantVC"] && [configuration.subDepartment isEqual:@(0)]) {
                identiFier = @"RcrPosRestaurantVC";
            }

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                RcrPosVC *dashboardVC = [storyBoard instantiateViewControllerWithIdentifier:identiFier];
                dashboardVC.managedObjectContext = self.rmsDbController.managedObjectContext;
                dashboardVC.shiftInRequire = require;
                dashboardVC.moduleIdentifierString = identiFier;
                [self.navigationController pushViewController:dashboardVC animated:YES];
            });
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Active module invalid" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(void)goToRestaurantOrderListWithShiftRequire:(NSString *)require
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    RestaurantOrderList *restaurantOrderList = [storyBoard instantiateViewControllerWithIdentifier:@"RestaurantOrderList"];
    restaurantOrderList.shiftRequire = require;
    [self.navigationController pushViewController:restaurantOrderList animated:TRUE];
    
}

-(void)gotoMainPoswithShiftin:(NSString *)require
{
    
    if([[[self.rmsDbController.globalDict valueForKeyPath:@"UserInfo"] valueForKey:@"CashInRequire"]boolValue]== TRUE)
    {
        require = @"Require";
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Department" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSInteger resultSet = [UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(resultSet > 0)
    {
#define RCR_POS_VC
#ifndef RCR_POS_VC
        self.crmController.objPOS.managedObjectContext = [self.rmsDbController managedObjectContext];
        self.crmController.objPOS.shiftInRequire = require;
        [self.navigationController pushViewController: self.crmController.objPOS animated:YES];
#else
        [self launchGasPosDashboard:require];
        /*  NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", [self.rmsDbController.globalDict objectForKey:@"DeviceId"]];
         NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
         NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ ",@"RCR"];
         NSArray *rcrArray = [activeModulesArray filteredArrayUsingPredicate:rcrActive];
         if ([rcrArray count] > 0)
         {
         self.crmController.objPOS.managedObjectContext = [self.rmsDbController managedObjectContext];
         //  self.crmController.objPOS.recallCount = recallCount;
         self.crmController.objPOS.shiftInRequire = require;
         [self.navigationController pushViewController: self.crmController.objPOS animated:YES];
         }
         else
         {
         [self launchGasPosDashboard:require];
         }*/
#endif
        /*NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", [self.rmsDbController.globalDict objectForKey:@"DeviceId"]];
         NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
         NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ ",@"RCR"];
         NSArray *rcrArray = [activeModulesArray filteredArrayUsingPredicate:rcrActive];
         if ([rcrArray count] > 0) {
         self.crmController.objPOS.managedObjectContext = [self.rmsDbController managedObjectContext];
         self.crmController.objPOS.recallCount = recallCount;
         self.crmController.objPOS.shiftInRequire = require;
         [self.navigationController pushViewController: self.crmController.objPOS animated:YES];
         }
         else
         {
         [self launchGasPosDashboard:require];
         }*/
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Application configuration failed, please restart the applicaion or wait for few seconds" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(void)pushToClockInOut
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Reporting" bundle:nil];
    ClockInDetailsView  *clockInOutDetail = [storyBoard instantiateViewControllerWithIdentifier:@"ClockInDetailsView"];
    [self.navigationController pushViewController:clockInOutDetail animated:YES];
}

// method for do quick login in pos.

-(NSManagedObject*)insertCredentialEntityWithName:(NSString*)entityName moc:(NSManagedObjectContext*)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
}
- (CredentialInfo*)fetchQuickAccessFromDatabase :(NSString *)quickAccess withContext:(NSManagedObjectContext *)context
{
    CredentialInfo *credentialInfo=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CredentialInfo" inManagedObjectContext:context];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"quickAccess==%@", quickAccess];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count == 0)
    {
        credentialInfo = (CredentialInfo *)[self insertCredentialEntityWithName:@"CredentialInfo" moc:context];
    }
    else
    {
        credentialInfo = resultSet.firstObject;
    }
    return credentialInfo;
}


- (CredentialInfo*)fetchuserNamePasswordFromDatabase :(NSString *)UserName withPassword:(NSString *)pasword withContext:(NSManagedObjectContext *)context
{
    CredentialInfo *credentialInfo=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CredentialInfo" inManagedObjectContext:context];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userName==%@ AND password==%@",UserName,pasword];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count == 0)
    {
        credentialInfo = (CredentialInfo *)[self insertCredentialEntityWithName:@"CredentialInfo" moc:context];
    }
    else
    {
        credentialInfo = resultSet.firstObject;
    }
    return credentialInfo;
}


- (UserInfo*)fetchUserInfoDatabasewithContext:(NSManagedObjectContext *)context
{
    UserInfo *userInfo=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"UserInfo" inManagedObjectContext:context];
    fetchRequest.entity = entity;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count == 0)
    {
        userInfo = (UserInfo *)[self insertCredentialEntityWithName:@"UserInfo" moc:context];
    }
    else
    {
        userInfo = resultSet.firstObject;
    }
    return userInfo;
}

- (CredentialInfo*)fetchuserCredentilaFromDatabase:(NSPredicate *)predicate withContext:(NSManagedObjectContext *)context
{
    CredentialInfo *credentialInfo=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CredentialInfo" inManagedObjectContext:context];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count > 0)
    {
        credentialInfo = resultSet.firstObject;
    }
    return credentialInfo;
}

-(NSArray *)fetchUserInfoFromDatabasewithContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"UserInfo" inManagedObjectContext:managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return resultSet;
}


- (void)saveQuickAccessToDatabaseWithUserInfo :(NSDictionary *)userInfoDictionary
{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId==%@", [userInfoDictionary valueForKey:@"UserId"]];
    CredentialInfo *credentialInfo = [self fetchuserCredentilaFromDatabase:predicate withContext:privateContextObject];
    if (credentialInfo!=nil) {
        credentialInfo.quickAccess = displayText.text;
    }
    NSArray *totalUserInfoOfDataBase = [self fetchUserInfoFromDatabasewithContext:privateContextObject];
    for (UserInfo *userInfo in totalUserInfoOfDataBase) {
        userInfo.updateDate = [NSDate date];
    }
    [UpdateManager saveContext:privateContextObject];
}

- (IBAction) doQuickLogin:(id)sender
{
    if (displayText.text.length > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:displayText.text forKey:@"Psw"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self quickLoginResponse:response error:error];
            });
        };
        
        self.quickLoginWC = [self.quickLoginWC initWithRequest:KURL actionName:WSM_USER_PASSCODE_LOGIN params:param completionHandler:completionHandler];
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please enter number in order to quick login." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}


- (void)setUserInfo:(NSDictionary *)response {
    self.responseLoginData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
    self.responseLoginData = [self.responseLoginData.firstObject valueForKey:@"UserInfo"];
    (self.rmsDbController.globalDict)[@"UserInfo"] = self.responseLoginData.firstObject;
}


- (void)doOnlineProcessAfterLoginResponse:(id)response usingQuickAccess:(BOOL)usingQuickAccess
{
    if ([[response valueForKey:@"IsError"] intValue] == 0) {
        self.responseLoginData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
        if (self.responseLoginData != nil)
        {
            (self.rmsDbController.globalDict)[@"UserInfo"] = [[self.responseLoginData.firstObject valueForKey:@"UserInfo"] firstObject];
            (self.rmsDbController.globalDict)[@"RightInfo"] = [self.responseLoginData.firstObject valueForKey:@"RightInfo"];
            [UserRights updateUserRights:[(self.responseLoginData).firstObject valueForKey:@"RightInfo"]];

            if (usingQuickAccess) {
                [self saveQuickAccessToDatabaseWithUserInfo:[[self.responseLoginData.firstObject valueForKey:@"UserInfo"] firstObject]];
            }
            else
            {
                [self saveUserNamePassWordToDatabaseWithUserInfo:[[self.responseLoginData.firstObject valueForKey:@"UserInfo"] firstObject]];
            }
            
            
            if([self.rmsDbController.selectedModule isEqualToString:@"Setting"])
            {
                [self Setting];
            }
            else
            {
                BOOL hasRights = [UserRights hasRights:UserRightOrderProcess];
                if (!hasRights) {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to access RCR. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    return;
                }
                
                self.process = @"Pos";
                
                NSString *strZId = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"ZId"]];
                if( [strZId isEqualToString:@"0"])
                {
                    [self ZOpeningNoReqOperation:@"0"];
                }
                else
                {
                    [self gotoMainPoswithShiftin:@""];
                }
                if(_isInvoiceCustomerRights)
                {
                    [_loginResultDelegate customerLoyalty];
                    return;
                }
                if(_loginResultDelegate && _isInvoiceCustomerRights == FALSE){
                    [_loginResultDelegate userDidLogin:self.responseLoginData.firstObject];
                    return;
                }
            }
            
        }
        else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Try Again" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            
            if (usingQuickAccess) {
                [self setKeypad];
                displayText.text=@"";
            }
            else
            {
                _userName.text = @"";
                _password.text = @"";
            }
        }
        
    } else if ([[response valueForKey:@"IsError"] intValue] == 1) {
        // clock in process
        if([self.rmsDbController.selectedModule isEqualToString:@"Setting"])
        {
            [self Setting];
        }
        else
        {
            [self setUserInfo:response];
            self.process = @"Clock-In";
            
            NSString *strZId = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"ZId"]];
            
            if( [strZId isEqualToString:@"0"])
            {
                [self ZOpeningNoReqOperation:@"0"];
            }
            else
            {
                [self pushToClockInOut];
            }
        }
    }
    else if ([[response valueForKey:@"IsError"] intValue] == -1)
    {
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:response[@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        if (usingQuickAccess) {
            [self deleteQuickAccessFromDatabase:displayText.text withContext:self.managedObjectContext];
        }
    }
    
    else if ([[response valueForKey:@"IsError"] intValue] == -30)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:response[@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    else
    {
        [self doOfflineProcessAfterLoginResponseUsingQuickAccess:usingQuickAccess];
    }
}

- (void)deleteQuickAccessFromDatabase :(NSString *)quickAccess withContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CredentialInfo" inManagedObjectContext:context];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"quickAccess==%@", quickAccess];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    for (NSManagedObject *managedObject in resultSet)
    {
        [self.managedObjectContext deleteObject:managedObject];
    }
    
}

-(void)Setting
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        [self.rmsDbController playButtonSound];
        BOOL hasRights = [UserRights hasRights:UserRightSetting];
        if (!hasRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have setting rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        else
        {
            [self.loginResultDelegate openSettingView];
        }
    }
}

- (void)doOfflineProcessAfterLoginResponseUsingQuickAccess:(BOOL)usingQuickAccess
{
    [_activityIndicator hideActivityIndicator];
    NSString *strZId = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"ZId"]];
    if([strZId isEqualToString:@"0"])
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"please check the internet connection or contact to rapidrms" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    
    NSString *message;
    if (usingQuickAccess) {
        message = @"Please enter valid quick access password";
    }
    else
    {
        message = @"Username or password is incorrect.";
    }
    
    CredentialInfo *credentialInfo;
    if (usingQuickAccess) {
        credentialInfo = [self fetchQuickAccessFromDatabase:displayText.text withContext:self.managedObjectContext];
    }
    else
    {
        credentialInfo = [self fetchuserNamePasswordFromDatabase:_userName.text withPassword:_password.text withContext:self.managedObjectContext];
    }
    
    if (credentialInfo)
    {
        if([self userOfflineLoginPeriod:credentialInfo] >= Offline_Login_Limit)
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Offline login period is expired." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        
        if (credentialInfo.credentialToUser.userInfoDictionary != nil) {
            (self.rmsDbController.globalDict)[@"UserInfo"] = credentialInfo.credentialToUser.userInfoDictionary;
            if (usingQuickAccess) {
                (self.rmsDbController.globalDict)[@"RightInfo"] = credentialInfo.credentialToUser.rightInfoForUser;
            }
            if([self.rmsDbController.selectedModule isEqualToString:@"Setting"])
            {
                [self Setting];
            }
            else
            {
                
                BOOL hasRights = [UserRights hasRights:UserRightOrderProcess];
                if (!hasRights) {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to access RCR. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    return;
                }
                
                [self gotoMainPoswithShiftin:@""];
                
            }
        }
        else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

- (void)loginResponse:(id)response error:(NSError *)error usingQuickAccess:(BOOL)usingQuickAccess
{
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            [self doOnlineProcessAfterLoginResponse:response usingQuickAccess:usingQuickAccess];
        }
    }
    else
    {
        [self doOfflineProcessAfterLoginResponseUsingQuickAccess:usingQuickAccess];
    }
    
    if (usingQuickAccess) {
        displayText.text = @"";
    }
    else{
        _userName.text = @"";
        _password.text = @"";
    }
    [_activityIndicator hideActivityIndicator];
}

-(void)quickLoginResponse:(id)response error:(NSError *)error {
    
    switch (self.loginProcess)
    {
        case CLOCK_IN_LOGIN_PROCESS:
            [self _clockInLoginResponse:response error:error];
            break;
            
        case ENTER_LOGIN_PROCESS:
            [self loginResponse:response error:error usingQuickAccess:YES];
            break;
            
        case CLOCK_OUT_LOGIN_PROCESS:
            [self _clockInLoginResponse:response error:error];
            break;
            
        default:
            break;
    }
}

-(void)ZOpeningNoReqOperation:(NSString *)strOpeningAmt {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSString *strDate=[NSString stringWithFormat:@"%@",destinationDate];
    
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"Amount"] = strOpeningAmt;
    dict[@"Datetime"] = strDate;
    
    // [arrayMain addObject:dict];
    
    NSMutableDictionary *dictMain =[[NSMutableDictionary alloc]init];
    dictMain[@"ZOpenningData"] = dict;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self ZOpeningNoReqResponse:response error:error];
    };
    
    self.zOpeningNoReqOperationWC = [self.zOpeningNoReqOperationWC initWithRequest:KURL actionName:WSM_Z_OPENING_DETAIL params:dictMain completionHandler:completionHandler];
}

- (void)ZOpeningNoReqResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];;
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSString *sData=[response valueForKey:@"Data"];
                (self.rmsDbController.globalDict)[@"ZId"] = sData;
                
                [self.departmentUpdateManager updateZidWithRegisrterInfo:sData withContext:self.managedObjectContext];
                
                if ([self.process isEqualToString:@"Pos"])
                {
                    [self gotoMainPoswithShiftin:@""];
                }
                else if ([self.process isEqualToString:@"Clock-In"]) {
                    [self pushToClockInOut];
                }
                else
                {
                }
            }
            else{
                NSString *zID = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"ZId"]];
                [self showAlertForZIDEqualToZero:zID];
            }
        }
    }
}

-(IBAction)cancelVoidPopup:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.view removeFromSuperview];
    return;
}


#pragma mark -
#pragma mark Direct CashInOut From.

- (IBAction) checkIsAvailableCashInOut:(id)sender {
    
    switch ([sender tag]) {
        case 7003:
            [self.rmsDbController playButtonSound];
            
        {
            NSArray *viewControllerArray = self.navigationController.viewControllers;
           
          
            for (UIViewController *viewController in viewControllerArray)
            {
                if ([viewController isKindOfClass:[DashBoardSettingVC class]])
                {
                    [self.navigationController popToViewController:viewController animated:TRUE];
                    break;
                }
                
            }
            [self.loginResultDelegate cancelSettingView];

            
        }
            break;
        default:
            break;
    }
}
#pragma mark -
#pragma mark TextFiled Delegate method

//call when press return key in keyboard.
- (BOOL) textFieldShouldReturn:(UITextField *)textFiled {
    [textFiled resignFirstResponder];
    return YES;
}

//call when press keyboard down key in keyboard.
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

//call when start editing the textfield.
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.crmController UserTouchEnable];
    
}

#pragma mark -
#pragma mark Memory Managment.

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||  interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        return YES;
    return NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    // [super dealloc];
    //[currentTypeValue release];
    //[currentClockInOutType release];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.crmController UserTouchEnable];
    return YES;
}

-(void)setDefaultValue{
    _btnClockIn.selected = FALSE;
    _btnClockOut.selected = FALSE;
}

-(IBAction)goToClockIn:(id)sender
{
    [self.rmsDbController playButtonSound];
    self.loginProcess = CLOCK_IN_LOGIN_PROCESS;
    [self doQuickLogin:nil];
}

-(IBAction)goToClockOut:(id)sender
{
    
    [self.rmsDbController playButtonSound];
    self.loginProcess = CLOCK_OUT_LOGIN_PROCESS;
    [self doQuickLogin:nil];
}

- (void)_clockInLoginResponse:(id)response error:(NSError *)error
{
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self setUserInfo:response];
                self.responseLoginData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                (self.rmsDbController.globalDict)[@"RightInfo"] = [self.responseLoginData.firstObject valueForKey:@"RightInfo"];
                [UserRights updateUserRights:[(self.responseLoginData).firstObject valueForKey:@"RightInfo"]];
#ifdef CheckRights
                BOOL hasRights = [UserRights hasRights:UserRightClockInOut];
                if (!hasRights) {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to access clock in out. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    [_activityIndicator hideActivityIndicator];;
                    return;
                }
#endif
                self.process = @"Clock-In";
                NSString *strZId = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"ZId"]];
                if( [strZId isEqualToString:@"0"])
                {
                    [self ZOpeningNoReqOperation:@"0"];
                }
                else
                {
                    [self pushToClockInOut];
                }
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                // clock in process
                [self setUserInfo:response];
                self.process = @"Clock-In";
                NSString *strZId = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"ZId"]];
                if( [strZId isEqualToString:@"0"])
                {
                    [self ZOpeningNoReqOperation:@"0"];
                }
                else
                {
                    [self pushToClockInOut];
                }
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:response[@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            
            else if ([[response valueForKey:@"IsError"] intValue] == -30)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:response[@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    else
    {
        
        
    }
    displayText.text = @"";
    [_activityIndicator hideActivityIndicator];;
}
-(IBAction)serviceChangeButton:(id)sender
{
    
}

@end
