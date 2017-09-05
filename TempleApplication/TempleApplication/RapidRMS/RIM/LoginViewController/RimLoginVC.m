//
//  ViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 02/08/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "CKOCalendarViewController.h"
#import "CustomerViewController.h"
#import "DashBoardSettingVC.h"
#import "ICHomeVC.h"
#import "ItemTicketValidation.h"
#import "ManualPOEntryHomeVC.h"
#import "POmenuListVC.h"
#import "RimLoginVC.h"
#import "RimMenuVC.h"
#import "RimsController.h"
#import "RmsDashboardVC.h"
#import "RmsDbController.h"
#import "SettingIphoneVC.h"

//#define CheckRights

@interface RimLoginVC () <UIPopoverControllerDelegate,ItemTicketValidationDelegate , DashBoardSettingDelegate>
{
    ItemTicketValidation * itemTicketValidation;
    IntercomHandler *intercomHandler;
}
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *departmentUpdateManager;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, weak) IBOutlet UIView *viewLogin;
@property (nonatomic, weak) IBOutlet UIView *viewQuick;
@property (nonatomic, weak) IBOutlet UITextField *displayText;
@property (nonatomic, weak) IBOutlet UITextField *txtusername;
@property (nonatomic, weak) IBOutlet UITextField *txtpassword;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UIButton *btnUsernName;
@property (nonatomic, weak) IBOutlet UIButton *btnKeyPad;
@property (nonatomic, weak) IBOutlet UIButton *btnExits;
@property (nonatomic, weak) IBOutlet UIButton *btnSignIn;
@property (nonatomic, weak) IBOutlet UILabel * currentDate;
@property (nonatomic, weak) IBOutlet UILabel *lblCompanyName;
@property (nonatomic, weak) IBOutlet UILabel *lblDeviceName;
@property (nonatomic, weak) IBOutlet UILabel *moduleName;

@property (nonatomic, strong) NSMutableArray *responseLoginData;

@property (nonatomic, strong) RapidWebServiceConnection *quickLoginWC;
@property (nonatomic, strong) RapidWebServiceConnection *accessLoginWC;
@property (nonatomic, strong) DashBoardSettingVC *dashActiveApps;

@end

@implementation RimLoginVC

#pragma mark - View -
- (void)viewDidLoad
{
    
    self.navigationController.navigationBarHidden=YES;
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.accessLoginWC = [[RapidWebServiceConnection alloc] init];
    self.quickLoginWC = [[RapidWebServiceConnection alloc] init];
    self.departmentUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    _btnSignIn.layer.cornerRadius = 6.0;
    [self.txtusername setValue:[UIColor colorWithRed:194.0/255.0 green:199.0/255.0 blue:214.0/255.0 alpha:1.0]
               forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtpassword setValue:[UIColor colorWithRed:153.0/255.0 green:164.0/255.0 blue:177.0/255.0 alpha:1.0]
               forKeyPath:@"_placeholderLabel.textColor"];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.displayText.text=@"";
    self.txtpassword.text=@"";
    self.txtusername.text=@"";
    
    self.lblCompanyName.text = [NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]];
    
    self.lblDeviceName.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.globalDict valueForKey:@"RegisterName"]];
    
    self.navigationController.navigationBarHidden=YES;
    
    if([self.rmsDbController.selectedModule isEqualToString:@"RIM"])
    {
        self.moduleName.text = @"Rapid Inventory Management";
    }
    else if([self.rmsDbController.selectedModule isEqualToString:@"RIC"])
    {
        self.moduleName.text = @"Rapid Inventory Count";
    }
    else if([self.rmsDbController.selectedModule isEqualToString:@"RPO"])
    {
        self.moduleName.text = @"Rapid Purchase Order";
    }
    else if([self.rmsDbController.selectedModule isEqualToString:@"VMS"])
    {
        self.moduleName.text = @"VMS Vendor";
    }
    else if([self.rmsDbController.selectedModule isEqualToString:@"RME"])
    {
        self.moduleName.text = @"Manual Entry";
    }
    else if([self.rmsDbController.selectedModule isEqualToString:@"RMP"])
    {
        self.moduleName.text = @"Rapid Management Portal";
    }
    else if([self.rmsDbController.selectedModule isEqualToString:@"TVM"])
    {
        self.moduleName.text = @"Ticket Validation";
    }
    //// Change With Customer loyalty
    else if([self.rmsDbController.selectedModule isEqualToString:@"CLM"])
    {
        self.moduleName.text = @"Customer Loyalty";
    }
    else if([self.rmsDbController.selectedModule isEqualToString:@"Setting"])
    {
        self.moduleName.text = @"Setting";
    }
    [self updateDateLable];
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
    NSString* str = [formatter stringFromDate:date];
    _currentDate.text = str;
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
}


#pragma mark - IBActions -

-(IBAction)showCalendar:(id)sender{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}


- (IBAction) pressKeyPadButton:(id)sender{
    [self.rmsDbController playButtonSound];
    if ([sender tag] >= 0 && [sender tag] < 10) {
        NSString * displyValue = [self.displayText.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
        self.displayText.text = displyValue;
    } else if ([sender tag] == -99) {
        if (self.displayText.text.length > 0) {
            self.displayText.text = @"";
        }
    } else if ([sender tag] == 101) {
        if (self.displayText.text.length > 0) {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            [self doQuickLogin:nil];
        } else {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:self.moduleName.text message:@"Please enter quick access password." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

-(IBAction)btn_Login:(id)sender
{
    [self.rmsDbController playButtonSound];
    [_btnUsernName setSelected:YES];
    [_btnKeyPad setSelected:NO];
    [_btnExits setSelected:NO];
    
    self.displayText.text = @"";
    self.viewLogin.hidden = FALSE;
    self.viewQuick.hidden = TRUE;
    
    [self.txtusername becomeFirstResponder];
}

-(IBAction)btn_QuickAcess:(id)sender
{
    [self.rmsDbController playButtonSound];
    [_btnUsernName setSelected:NO];
    [_btnKeyPad setSelected:YES];
    [_btnExits setSelected:NO];
    self.displayText.text = @"";
    
    self.viewLogin.hidden = TRUE;
    self.viewQuick.hidden = FALSE;
}

-(IBAction)btn_ExitsClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [_btnUsernName setSelected:NO];
    [_btnKeyPad setSelected:NO];
    [_btnExits setSelected:YES];
//    if (self.rimLoginDelegate)
//    {
//        [self.rimLoginDelegate cancelSettingView];
//    }
//    else
//    {
        self.navigationController.navigationBarHidden=YES;
        [self.navigationController popViewControllerAnimated:YES];
  //  }
    
    
}

// Quick login function
- (IBAction) doQuickLogin:(id)sender
{
    if (self.displayText.text.length == 0)
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:self.moduleName.text message:@"Please enter quick access code" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else
    {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:self.displayText.text forKey:@"Psw"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self rimQuickLoginResponse:response error:error];
            });
        };
        
        self.quickLoginWC = [self.quickLoginWC initWithRequest:KURL actionName:WSM_USER_PASSCODE_LOGIN params:param completionHandler:completionHandler];
    }
}

// username and password login function
-(IBAction)doLogin:(id)sender
{
    [self.rmsDbController playButtonSound];
    if([self.txtusername.text isEqualToString:@""])
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self.txtusername becomeFirstResponder];
        };
        [self.rmsDbController popupAlertFromVC:self title:self.moduleName.text message:@"Please enter username" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else if ([self.txtpassword.text isEqualToString:@"" ])
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self.txtpassword becomeFirstResponder];
        };
        [self.rmsDbController popupAlertFromVC:self title:self.moduleName.text message:@"Please enter password" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else
    {
        // username & password Login
        [self.txtusername resignFirstResponder];
        [self.txtpassword resignFirstResponder];

        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:self.txtusername.text forKey:@"UserName"];
        [param setValue:self.txtpassword.text forKey:@"Password"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];

        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self accessLoginResponse:response error:error];
            });
        };
        
        self.accessLoginWC = [self.accessLoginWC initWithRequest:KURL actionName:WSM_USER_SIGN_IN_PROCESS params:param completionHandler:completionHandler];
    }
}

#pragma mark - Responce -

- (void)launchAlertWithMessage:(NSString *)errorMessage {
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
    };
    [self.rmsDbController popupAlertFromVC:self title:self.moduleName.text message:errorMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

- (void)handleInvalidQuickAccessPassword{
    NSString * errorMessage=@"Please enter valid quick access password";
    [self launchAlertWithMessage:errorMessage];
    self.displayText.text = @"";
}

//- (void)launchClockinAlert:(NSDictionary *)response {
//    // clock in process
//    [self setRimUserInfo:response];
//    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//    {
//        
//    };
//    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
//    {
//        [self launchClockInOut];
//    };
//    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Would you like to clockin process?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
//}

//-(void)launchClockInOut {
//    
//    ClockInDetailsView  *clockInOutDetail = [[ClockInDetailsView alloc] initWithNibName:@"ClockInDetailsView" bundle:nil];
//    [self.navigationController pushViewController:clockInOutDetail animated:YES];
//}

- (void)launchInventoryManagement {
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You don't have inventory info rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    RimMenuVC * objInvenHome =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimMenuVC_sid"];

    [self.navigationController pushViewController:objInvenHome animated:YES];
}

- (void)launchInventoryCount {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ICStoryboard" bundle:nil];
        ICHomeVC *objICHome = [storyBoard instantiateViewControllerWithIdentifier:@"ICHomeVC_sid"];
        [self.navigationController pushViewController:objICHome animated:YES];
}

- (void)launchParchaseOrder {
    if (IsPad())
    {
        POmenuListVC *objPoMenu = [[POmenuListVC alloc] initWithNibName:@"POmenuListVC" bundle:nil];
        [self.navigationController pushViewController:objPoMenu animated:YES];
    }
    else
    {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
        POmenuListVC *objPoMenu = [storyBoard instantiateViewControllerWithIdentifier:@"POmenuListVC"];
        [self.navigationController pushViewController:objPoMenu animated:YES];

        
    }
}

- (void)launchManualEntry {
#ifdef CheckRights
    BOOL hasRights = [UserRights hasRights:UserRightManualEntry];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You don't have manual entry rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
#endif
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    ManualPOEntryHomeVC *manualEntry = [storyBoard instantiateViewControllerWithIdentifier:@"ManualPOEntryHomeVC"];
    
    [self.navigationController pushViewController:manualEntry animated:YES];
}

- (void)launchVMSVendor {
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//    {
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        HGenerateOrderVC *hgenerateorder = [storyBoard instantiateViewControllerWithIdentifier:@"HGenerateOrderVC"];
//        
//        [self.navigationController pushViewController:hgenerateorder animated:YES];
//    }
//    else
//    {
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//        HGenerateOrderVC *hgenerateorder = [storyBoard instantiateViewControllerWithIdentifier:@"HGenerateOrderVC"];
//        
//        [self.navigationController pushViewController:hgenerateorder animated:YES];
//    }
}

- (void)launchManagementPortal {
//    RapidWebViewVC * rapidWebVC=[[UIStoryboard storyboardWithName:@"RimStoryboard"  bundle:NULL] instantiateViewControllerWithIdentifier:@"RapidWebViewVC_sid"];
//    rapidWebVC.pageId=PageIdDashboard[self launchManagementPortel];
//    [self.navigationController pushViewController:rapidWebVC animated:YES];
}
-(void)TicketValidation{
    if (IsPad()) {
        [self.rmsDbController playButtonSound];
        BOOL hasRights = [UserRights hasRights:UserRightTickets];
        if (!hasRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You don't have tickets rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        else
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
            itemTicketValidation = [storyBoard instantiateViewControllerWithIdentifier:@"ItemTicketValidation"];
            itemTicketValidation.itemTicketValidationDelegate = self;
            [self.view addSubview:itemTicketValidation.view];
            
        }
        
    }
}
-(void)CustomerLoyalty{
    BOOL hasRights = [UserRights hasRights:UserRightCustomerLoyalty];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You don't have customer loyalty rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    if (IsPad())
    {
        [self.rmsDbController playButtonSound];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CustomerViewController * customerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CustomerViewController"];
        customerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        customerVC.isFromDashBoard = YES;
        customerVC.view.frame = self.view.bounds;
        [self.navigationController pushViewController:customerVC animated:YES];
    }
}

-(void)Setting
{
    BOOL hasRights = [UserRights hasRights:UserRightManualEntry];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You don't have manual entry rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    else{
        if (IsPad())
        {
            [self.rmsDbController playButtonSound];
            BOOL hasRights = [UserRights hasRights:UserRightSetting];
            if (!hasRights) {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You don't have setting rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                return;
            }
            else
            {
                [self.rimLoginDelegate openSettingView];
            }
        }
        else{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            SettingIphoneVC *objSetting = [storyBoard instantiateViewControllerWithIdentifier:@"SettingIphoneVC"];
            objSetting.objSettingHome = self;
            [self.navigationController pushViewController:objSetting animated:YES];
            
        }

    }

}

-(void)rimQuickLoginResponse:(id)response error:(NSError *)error{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if (([[response valueForKey:@"IsError"] intValue] == 0) || ([[response valueForKey:@"IsError"] intValue] == 1) || ([[response valueForKey:@"IsError"] intValue] == 2))
            {
                self.responseLoginData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if(self.responseLoginData != nil)
                {
                    [self setRimUserInfo:response];
                    if([self.rmsDbController.selectedModule isEqualToString:@"RIM"])
                    {
                        [self launchInventoryManagement];
                    }
                    else if([self.rmsDbController.selectedModule isEqualToString:@"RIC"])
                    {
                        [self launchInventoryCount];
                    }
                    else if([self.rmsDbController.selectedModule isEqualToString:@"RPO"]){
                        [self launchParchaseOrder];
                    }
                    else if([self.rmsDbController.selectedModule isEqualToString:@"RME"]){
                        [self launchManualEntry];
                    }
                    else if([self.rmsDbController.selectedModule isEqualToString:@"VMS"]){
                        [self launchVMSVendor];
                    }
                    else if([self.rmsDbController.selectedModule isEqualToString:@"RMP"]){
                        [self launchManagementPortal];
                    }
                    else if([self.rmsDbController.selectedModule isEqualToString:@"TVM"]) {
                        [self TicketValidation];
                    }
                    else if([self.rmsDbController.selectedModule isEqualToString:@"CLM"]) {
                        [self CustomerLoyalty];
                    }
                    else if([self.rmsDbController.selectedModule isEqualToString:@"Setting"])
                    {
                        [self Setting];
                    }
                }
                else{
                    [self launchAlertWithMessage:@"Please enter valid quick access password"];
                    self.displayText.text = @"";
                }
            }
//            else if ([[response valueForKey:@"IsError"] intValue] == 1) {
//                [self launchClockinAlert:response];
//            }
            else if ([[response valueForKey:@"IsError"] intValue] == -30)
            {
                [self launchAlertWithMessage:response[@"Data"]];
            }
            else
            {
                [self handleInvalidQuickAccessPassword];
            }
        }
    }
    else {
        [self launchAlertWithMessage:@"unable to login, please contact RapidRMS"];
    }
}

- (void)accessLoginResponse:(id)response error:(NSError *)error{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0 || ([[response valueForKey:@"IsError"] intValue] == 1)) {
                
                [self setRimUserInfo:response];
                
                if([self.rmsDbController.selectedModule isEqualToString:@"RIM"])
                {
                    [self launchInventoryManagement];
                }
                else if([self.rmsDbController.selectedModule isEqualToString:@"RIC"])
                {
                    [self launchInventoryCount];
                }
                else if([self.rmsDbController.selectedModule isEqualToString:@"RPO"]){
                    [self launchParchaseOrder];
                }
                else if([self.rmsDbController.selectedModule isEqualToString:@"RME"]){
                    [self launchManualEntry];
                }
                else if([self.rmsDbController.selectedModule isEqualToString:@"VMS"]){
                    [self launchVMSVendor];
                }
                else if([self.rmsDbController.selectedModule isEqualToString:@"RMP"]){
                    [self launchManagementPortal];
                }
                else if([self.rmsDbController.selectedModule isEqualToString:@"TVM"]) {
                    [self TicketValidation];
                }
                else if([self.rmsDbController.selectedModule isEqualToString:@"CLM"]) {
                    [self CustomerLoyalty];
                }
                else if([self.rmsDbController.selectedModule isEqualToString:@"Setting"]) {
                    [self Setting];
                }
            }
//            else if ([[response valueForKey:@"IsError"] intValue] == 1) {  // clock in process
//                [self setRimUserInfo:response];
//                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//                {
//                    
//                };
//                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
//                {
////                    [self launchClockInOut];
//                };
//                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Would you like to clockin process?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
//            }
            
            else if ([[response valueForKey:@"IsError"] intValue] == -30)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:self.moduleName.text message:response[@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:self.moduleName.text message:@"Invalid username / password." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                self.txtusername.text = @"";
                self.txtpassword.text = @"";
            }
        }
    }
    else {
        [self launchAlertWithMessage:@"unable to login, please contact RapidRMS"];
    }
}

// setUserInfo function
- (void)setRimUserInfo:(NSDictionary *)response
{
    self.responseLoginData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
    (self.rmsDbController.globalDict)[@"UserInfo"] = [[self.responseLoginData.firstObject valueForKey:@"UserInfo"] firstObject];
    (self.rmsDbController.globalDict)[@"RightInfo"] = [self.responseLoginData.firstObject valueForKey:@"RightInfo"];
    (self.rmsDbController.globalDict)[@"RoleInfo"] = [self.responseLoginData.firstObject valueForKey:@"RoleInfo"];
    [UserRights updateUserRights:[(self.responseLoginData).firstObject valueForKey:@"RightInfo"]];
}

-(void)hideItemTicketValidation
{
    [itemTicketValidation.view removeFromSuperview];
    
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    
    for (UIViewController *vc in viewControllerArray)
    {
        if ([vc isKindOfClass:[DashBoardSettingVC class]] || [vc isKindOfClass:[RmsDashboardVC class]])
        {
            //[self cleanUpNavigationController];
            [self.navigationController popToViewController:vc animated:TRUE];
        }
    }
    self.displayText.text = @"";
    
}
#pragma mark - TextFields -

// return NO to disallow editing.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag==999)
        return NO;
    else
        return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
