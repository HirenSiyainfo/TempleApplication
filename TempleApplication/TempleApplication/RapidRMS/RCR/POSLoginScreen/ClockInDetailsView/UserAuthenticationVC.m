//
//  UserAuthenticationVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 5/28/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "UserAuthenticationVC.h"
#import "RmsDbController.h"
#import "ClockInDetailsView.h"
#import "CashinOutViewController.h"
#import "ReportViewController.h"
#import "ShiftOpenCloseVC.h"
#import "CKOCalendarViewController.h"
#import "DailyReportVC.h"
#import "ShiftReportDetailsVC.h"

//#define CheckRights

@interface UserAuthenticationVC ()<UpdateDelegate,UIPopoverControllerDelegate>
{
    
    IntercomHandler *intercomHandler;
}
@property (nonatomic, weak) IBOutlet UITextField * userName;
@property (nonatomic, weak) IBOutlet UITextField * password;
@property (nonatomic, weak) IBOutlet UITextField *displayText;

@property (nonatomic, weak) IBOutlet UIButton *userNameButton;
@property (nonatomic, weak) IBOutlet UIButton *btnKeyPad;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnSignIn;
@property (nonatomic, weak) IBOutlet UIButton *showCalendar;

@property (nonatomic, weak) IBOutlet UIView *uvLoginNumpad;
@property (nonatomic, weak) IBOutlet UIView *uvAccessPasswordView;
@property (nonatomic, weak) IBOutlet UIView *uvLoginView;

@property (nonatomic, weak) IBOutlet UILabel *lblLoginType;
@property (nonatomic, weak) IBOutlet UILabel *lblBranchName;
@property (nonatomic, weak) IBOutlet UILabel *lblDeviceName;
@property (nonatomic, weak) IBOutlet UILabel *currentDate;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic,strong) UpdateManager *updateManager;
@property (strong,nonatomic) RapidWebServiceConnection *userSignInProcessWC;
@property (strong,nonatomic) RapidWebServiceConnection *userPasscodeLoginWC;
@property (strong,nonatomic) RapidWebServiceConnection *zOpeningNoReqOperationWC;

@property (nonatomic, strong) UIPopoverController *calendarPopOverController;

@end

@implementation UserAuthenticationVC

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
    self.userSignInProcessWC = [[RapidWebServiceConnection alloc] init];
    self.userPasscodeLoginWC = [[RapidWebServiceConnection alloc] init];
    self.zOpeningNoReqOperationWC = [[RapidWebServiceConnection alloc] init];
    if ([self.rmsDbController.selectedModule isEqualToString: @"Cash In-Out"]) {
        self.lblLoginType.text = @"Shift In-Out";
    }
    else {
        self.lblLoginType.text =[NSString stringWithFormat:@"%@",self.rmsDbController.selectedModule];
    }
    
    [self updateDateLable];
    
    self.lblBranchName.text = [NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]];
    
    self.lblDeviceName.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.globalDict valueForKey:@"RegisterName"]];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    _uvAccessPasswordView.hidden = NO;
    _uvLoginView.hidden = YES;
    _btnSignIn.layer.cornerRadius = 6.0;
    
    
    [_userName setValue:[UIColor colorWithRed:194.0/255.0 green:199.0/255.0 blue:214.0/255.0 alpha:1.0]
             forKeyPath:@"_placeholderLabel.textColor"];
    [_password setValue:[UIColor colorWithRed:153.0/255.0 green:164.0/255.0 blue:177.0/255.0 alpha:1.0]
             forKeyPath:@"_placeholderLabel.textColor"];
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)updateDateLable
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSString* str = [formatter stringFromDate:date];
    _currentDate.text = str;
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

#pragma mark -
#pragma mark TextFiled Delegate method

//call when press return key in keyboard.
- (BOOL) textFieldShouldReturn:(UITextField *)textFiled {
    [textFiled resignFirstResponder];
    return YES;
}

- (IBAction)loginBtnAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:_userName.text forKey:@"UserName"];
    [param setValue:_password.text forKey:@"Password"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self userSignInProcessResponse:response error:error];
        });
    };
    
    self.userSignInProcessWC = [self.userSignInProcessWC initWithRequest:KURL actionName:WSM_USER_SIGN_IN_PROCESS params:param completionHandler:completionHandler];
}

- (void)userSignInProcessResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                NSMutableArray *responseLoginData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                (self.rmsDbController.globalDict)[@"UserInfo"] = [[responseLoginData.firstObject valueForKey:@"UserInfo"] firstObject];
                (self.rmsDbController.globalDict)[@"RightInfo"] = [responseLoginData.firstObject valueForKey:@"RightInfo"];
                [UserRights updateUserRights:[responseLoginData.firstObject valueForKey:@"RightInfo"]];
                if ([self.rmsDbController.selectedModule isEqualToString: @"Daily Report"])
                {
#ifdef CheckRights
                    BOOL shiftReportRights = [UserRights hasRights:UserRightShiftInOut];
                    BOOL xReportRights = [UserRights hasRights:UserRightXReport];
                    if (!shiftReportRights && !xReportRights) {
                        [_activityIndicator hideActivityIndicator];
                        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                        {
                        };
                        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have X-Report & Shift Report rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                        return;
                    }
#endif
                }
                
                NSString *strZId = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"ZId"]];
                
                if( [strZId isEqualToString:@"0"])
                {
                    [self ZopenigId];
                }
                else
                {
                    if ([self.rmsDbController.selectedModule isEqualToString: @"Cash In-Out"])
                    {
                        [self pushToCashInOut];
                    }
                    else if ([self.rmsDbController.selectedModule isEqualToString: @"Clock In-Out"])
                    {
                        [self pushToClockInOut];
                    }
                    else if ([self.rmsDbController.selectedModule isEqualToString: @"Daily Report"])
                    {
                        [self pushToReport];
                    }
                    else
                    {
                        
                    }
                }
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                [self processWhileUserDoesNotClockedIntoSystem:response];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -1)
            {
                if ([self.rmsDbController.selectedModule isEqualToString: @"Daily Report"])
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:response[@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -30)
            {
                if ([self.rmsDbController.selectedModule isEqualToString: @"Daily Report"])
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:response[@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else {
                    NSString *strAlert = self.lblLoginType.text;
                    if ([strAlert isEqualToString:@"Cash In-Out"]) {
                        strAlert = @"Shift In | Out";
                    }
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:strAlert message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
        }
    }
    else {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"unable to login, please contact RapidRMS" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    
    _userName.text = @"";
    _password.text = @"";
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
                    [btn setImage:[UIImage imageNamed:@"desk_num0Active.png"] forState:UIControlStateNormal];
                }
                else if(btn.tag==-99)
                {
                    [btn setImage:[UIImage imageNamed:@"desk_num_c_Active.png"] forState:UIControlStateNormal];
                }
                else if(btn.tag==101)
                {
                    [btn setImage:[UIImage imageNamed:@"desk_num_enter_active.png"] forState:UIControlStateNormal];
                    
                }
                else if (btn.tag > 0 && btn.tag < 10)
                {
                    NSString *strImg = [NSString stringWithFormat:@"desk_num%ldActive.png",(long)btn.tag];
                    [btn setImage:[UIImage imageNamed:strImg] forState:UIControlStateNormal];
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
        NSString * displyValue = [_displayText.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
        _displayText.text = displyValue;
    }
    else if ([sender tag] == -99)
    {
        if (_displayText.text.length > 0)
        {
            _displayText.text = @"";
            [self setKeypad];
        }
    } else if ([sender tag] == 101) {
        if (_displayText.text.length > 0)
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            [self doAccessLoginProcess];
        } else {
            
            NSString *strAlert = self.lblLoginType.text;
            if ([strAlert isEqualToString:@"Cash In-Out"]) {
                strAlert = @"Shift In | Out";
            }
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:strAlert message:@"Please enter quick access code" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
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


-(void)pushToClockInOut
{
#ifdef CheckRights
    BOOL hasRights = [UserRights hasRights:UserRightClockInOut];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to access clock in out. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
#endif
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Reporting" bundle:nil];
    ClockInDetailsView  *clockInOutDetail = [storyBoard instantiateViewControllerWithIdentifier:@"ClockInDetailsView"];
    [self.navigationController pushViewController:clockInOutDetail animated:YES];
}

-(void)pushToGasPumpSetting
{
    if ([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"ClockInOutFlg"] boolValue] == TRUE && [[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"ClockInRequire"] boolValue] == TRUE)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self pushToClockInOut];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Clock In | out" message:@"Are you sure want to clock in | out process?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
    else
    {
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"GasPump" bundle:nil];
////        self.fuelCountListVC = [storyBoard instantiateViewControllerWithIdentifier:@"FuelCountListVC"];
//        [self.navigationController pushViewController:self.fuelCountListVC animated:YES];
    }
}

-(NSMutableArray *)creatFuelTypeDefaultArray{
   
    NSMutableArray *fuelCount = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *fuel1 = [@{
                                    @"Name":@"Fuel 1",
                                    @"Price":@"10.00",
                                    @"Case Full":@"$12.20",
                                    @"Case Self":@"$13.11",
                                    @"Credit Full":@"$12.20",
                                    @"Credit Self":@"$14.20",
                                    } mutableCopy ];
    NSMutableDictionary *fuel2 = [@{
                                    @"Name":@"Fuel 2",
                                    @"Price":@"12.00",
                                    @"Case Full":@"$14.10",
                                    @"Case Self":@"$17.30",
                                    @"Credit Full":@"$13.20",
                                    @"Credit Self":@"$15.20",
                                    } mutableCopy ];
    
    NSMutableDictionary *fuel3 = [@{
                                    @"Name":@"Fuel 3",
                                    @"Price":@"12.00",
                                    @"Case Full":@"$14.10",
                                    @"Case Self":@"$17.30",
                                    @"Credit Full":@"$13.20",
                                    @"Credit Self":@"$15.20",
                                    } mutableCopy ];
    
    [fuelCount addObject:fuel1];
    [fuelCount addObject:fuel2];
    [fuelCount addObject:fuel3];
    
    return fuelCount;
}

-(void)pushToReport
{
    if ([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"ClockInOutFlg"] boolValue] == TRUE && [[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"ClockInRequire"] boolValue] == TRUE)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self pushToClockInOut];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Clock In | out" message:@"Are you sure want to clock in | out process?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
    else
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Reporting" bundle:nil];
        DailyReportVC *dailyReportVC = [storyBoard instantiateViewControllerWithIdentifier:@"DailyReportVC"];
        [self.navigationController pushViewController:dailyReportVC animated:YES];
        return;
        ReportViewController  *reportVC = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
        [self.navigationController pushViewController:reportVC animated:YES];
    }
}

-(void)pushToCashInOut
{
    if ([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"ClockInOutFlg"] boolValue] == TRUE && [[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"ClockInRequire"] boolValue] == TRUE)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self pushToClockInOut];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Clock In | out" message:@"Are you sure want to clock in | out process?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
    else
    {
#ifdef CheckRights
        BOOL hasRights = [UserRights hasRights:UserRightShiftInOut];
        if (!hasRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to access shift in out. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
#endif
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Reporting" bundle:nil];
        ShiftReportDetailsVC *shiftReportDetailsVC = [storyBoard instantiateViewControllerWithIdentifier:@"ShiftReportDetailsVC"];
        [self.navigationController pushViewController:shiftReportDetailsVC animated:YES];
        return;

        ShiftOpenCloseVC *shiftOpenClose =[[ShiftOpenCloseVC alloc]initWithNibName:@"ShiftOpenCloseVC" bundle:nil];
        [self.navigationController pushViewController:shiftOpenClose animated:YES];
    }
}

- (IBAction) cancelBtnAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self.navigationController popViewControllerAnimated:true];
}

-(void)doAccessLoginProcess
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    [param setValue:_displayText.text forKey:@"Psw"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self userPasscodeLoginResponse:response error:error];
        });
    };
    
    self.userPasscodeLoginWC = [self.userPasscodeLoginWC initWithRequest:KURL actionName:WSM_USER_PASSCODE_LOGIN params:param completionHandler:completionHandler];
}

- (void)userPasscodeLoginResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSMutableArray *responseLoginData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if (responseLoginData != nil)
                {
                    (self.rmsDbController.globalDict)[@"UserInfo"] = [[responseLoginData.firstObject valueForKey:@"UserInfo"] firstObject];
                    (self.rmsDbController.globalDict)[@"RightInfo"] = [responseLoginData.firstObject valueForKey:@"RightInfo"];
                    [UserRights updateUserRights:[responseLoginData.firstObject valueForKey:@"RightInfo"]];
                    if ([self.rmsDbController.selectedModule isEqualToString: @"Daily Report"])
                    {
#ifdef CheckRights
                        BOOL shiftReportRights = [UserRights hasRights:UserRightShiftInOut];
                        BOOL xReportRights = [UserRights hasRights:UserRightXReport];
                        if (!shiftReportRights && !xReportRights) {
                            [_activityIndicator hideActivityIndicator];
                            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                            {
                            };
                            [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have X-Report & Shift Report rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                            return;
                        }
#endif
                    }
                    NSString *strZId = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"ZId"]];
                    
                    if( [strZId isEqualToString:@"0"])
                    {
                        [self ZopenigId];
                    }
                    else
                    {
                        if ([self.rmsDbController.selectedModule isEqualToString: @"Cash In-Out"])
                        {
                            [self pushToCashInOut];
                        }
                        else if ([self.rmsDbController.selectedModule isEqualToString: @"Clock In-Out"])
                        {
                            [self pushToClockInOut];
                        }
                        else if ([self.rmsDbController.selectedModule isEqualToString: @"Daily Report"])
                        {
                            [self pushToReport];
                        }
                        else if ([self.rmsDbController.selectedModule isEqualToString: @"Gas Prices"])
                        {
                            _displayText.text = @"";
                            [self pushToGasPumpSetting];
                        }
                        else
                        {
                            
                        }
                    }
                }
                else
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Try Again" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    
                    _displayText.text=@"";
                }
                
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1) {
                [self processWhileUserDoesNotClockedIntoSystem:response];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -1)
            {
                if ([self.rmsDbController.selectedModule isEqualToString: @"Daily Report"])
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:response[@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -30)
            {
                if ([self.rmsDbController.selectedModule isEqualToString: @"Daily Report"])
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:response[@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else {
                    NSString *strAlert = self.lblLoginType.text;
                    if ([strAlert isEqualToString:@"Cash In-Out"]) {
                        strAlert = @"Shift In | Out";
                    }
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:strAlert message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
        }
    }
    else {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"unable to login, please contact RapidRMS" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

- (void)processWhileUserDoesNotClockedIntoSystem:(NSDictionary *)response {
    NSMutableArray *responseLoginData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
    if (responseLoginData != nil)
    {
        (self.rmsDbController.globalDict)[@"UserInfo"] = [[responseLoginData.firstObject valueForKey:@"UserInfo"] firstObject];
    }
    if ([self.rmsDbController.selectedModule isEqualToString: @"Clock In-Out"])
    {
        // Push CLIO
        [self pushToClockInOut];
    }
    else {
        NSString *strAlert = self.lblLoginType.text;
        
        if([strAlert isEqualToString:@"Gas Prices"]){
            // Push Gas Prices
            [self pushToGasPumpSetting];
            return;
        }

        if ([strAlert isEqualToString:@"Cash In-Out"]) {
            strAlert = @"Shift In | Out";
        }

        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:strAlert message:@"Please Clock-in first." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }

}
-(IBAction)btnUserName:(id)sender
{
    [self.rmsDbController playButtonSound];
    _uvAccessPasswordView.hidden = YES;
    _uvLoginView.hidden = NO;
    _displayText.text = @"";
    [_userNameButton setSelected:YES];
    [_btnKeyPad setSelected:NO];
    
}

-(IBAction)Keypad:(id)sender
{
    [self.rmsDbController playButtonSound];
    _uvAccessPasswordView.hidden = NO;
    [_userNameButton setSelected:NO];
    [_btnKeyPad setSelected:YES];
    _uvLoginView.hidden = YES;
    _displayText.text = @"";
    
}


-(void)ZopenigId {
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
    dict[@"Amount"] = @"0";
    dict[@"Datetime"] = strDate;
    
    // [arrayMain addObject:dict];
    
    NSMutableDictionary *dictMain =[[NSMutableDictionary alloc]init];
    dictMain[@"ZOpenningData"] = dict;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self ZopenigIdResponse:response error:error];
    };
    
    self.zOpeningNoReqOperationWC = [self.zOpeningNoReqOperationWC initWithRequest:KURL actionName:WSM_Z_OPENING_DETAIL params:dictMain completionHandler:completionHandler];
}

- (void)ZopenigIdResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];;
    if (response != nil) {
        if ([[response valueForKey:@"IsError"] intValue] == 0)
        {
            NSString *sData=[response valueForKey:@"Data"];
            (self.rmsDbController.globalDict)[@"ZId"] = sData;
            [self.updateManager updateZidWithRegisrterInfo:sData withContext:self.rmsDbController.managedObjectContext];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ZOpeningNoReqOperation" object:nil];
            if ([self.rmsDbController.selectedModule isEqualToString: @"Cash In-Out"])
            {
                [self pushToCashInOut];
            }
            else if ([self.rmsDbController.selectedModule isEqualToString: @"Clock In-Out"])
            {
                [self pushToClockInOut];
            }
            else if ([self.rmsDbController.selectedModule isEqualToString: @"Daily Report"])
            {
                [self pushToReport];
            }
            else
            {
                
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
