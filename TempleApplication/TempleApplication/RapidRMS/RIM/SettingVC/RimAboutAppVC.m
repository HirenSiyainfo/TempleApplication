//
//  RimAboutViewController.h
//  I-RMS
//
//  Created by Siya Infotech on 20/01/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "RimAboutAppVC.h"
#import "RmsDbController.h"

@interface RimAboutAppVC () {
    UIPopoverController *popoverController;
    UIViewController *tempviewController;
}

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, weak) IBOutlet UIView *uvUpdateVersion;
@property (nonatomic, weak) IBOutlet UIView *uvPreVersion;

@property (nonatomic, weak) IBOutlet UIButton *btn_preInstall;
@property (nonatomic, weak) IBOutlet UIButton *btn_updateInstall;
@property (nonatomic, weak) IBOutlet UIButton *btn_InstallPrevious;

@property (nonatomic, weak) IBOutlet UIImageView *imgPrevious;
@property (nonatomic, weak) IBOutlet UIImageView *imgUpdate;
@property (nonatomic, weak) IBOutlet UILabel *lblPreBtnName;
@property (nonatomic, weak) IBOutlet UILabel *lblUpdtBtnName;
@property (nonatomic, weak) IBOutlet UILabel *lblCurVersion;
@property (nonatomic, weak) IBOutlet UILabel *lblAppVersion;
@property (nonatomic, weak) IBOutlet UILabel *lblCurBranchIDName;
@property (nonatomic, weak) IBOutlet UILabel *lblPreVersion;
@property (nonatomic, weak) IBOutlet UILabel *lblPreBranchIDName;
@property (nonatomic, weak) IBOutlet UILabel *lblUpdVersion;
@property (nonatomic, weak) IBOutlet UILabel *lblUpdBranchIDName;

@property (nonatomic, strong) NSString *strUpdateURL;
@property (nonatomic, strong) NSString *strPreviousURL;

@property (nonatomic, strong) NSMutableArray *arrNotificationRes;

@property (nonatomic, strong) RapidWebServiceConnection * getIphoneNotificationWC;

@end

@implementation RimAboutAppVC

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
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.getIphoneNotificationWC = [[RapidWebServiceConnection alloc]init];
   
    _uvUpdateVersion.hidden = YES;
    _uvPreVersion.hidden = YES;
    
    _btn_updateInstall.enabled = NO;
    
    _btn_preInstall.enabled = NO;
    
    tempviewController = [[UIViewController alloc] init];
    _arrNotificationRes = [[NSMutableArray alloc] init];
    
    // set current build values
    _lblCurVersion.text = [NSString stringWithFormat:@"Rapid Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey]];
    _lblCurBranchIDName.text = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]];
    
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSString *buildVersion = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey];
    _lblAppVersion.text = appVersion;
    _lblCurVersion.text = buildVersion;
    
    [self getiPhoneNotification];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)btnBackClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    if (IsPad())
    {
        [self.view removeFromSuperview];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(IsPhone())
    {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        
    }
}

// application update notification

-(void)getiPhoneNotification
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegId"];
    NSString  *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    [param setValue:buildVersion forKey:@"Version"];
    param[@"ApplicationType"] = @"RCR";
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getIphoneNotificationDetailResponse:response error:error];
        });
    };
    
    self.getIphoneNotificationWC = [self.getIphoneNotificationWC initWithRequest:KURL actionName:WSM_GET_NOTIFICATION_DETAIL params:param completionHandler:completionHandler];
}

-(void)getIphoneNotificationDetailResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responsearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                _arrNotificationRes=[responsearray mutableCopy];
                
                if(_arrNotificationRes.count > 0)
                {
                    [self setBuildValues];
                }
            }
            else
            {
                _lblCurVersion.text = [NSString stringWithFormat:@"Rapid Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey]];
                _lblCurBranchIDName.text = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]];
            }

        }
    }
}

-(void)setBuildValues
{
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSString *buildVersion = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey];
    _lblAppVersion.text = appVersion;
    _lblCurVersion.text = buildVersion;
    // set update build values
    if([[_arrNotificationRes.firstObject valueForKey:@"UpdateId"] integerValue ] > 0 )
    {
        _btn_updateInstall.enabled = TRUE;
        
        // UpdateVersionTabActive.png
        _imgUpdate.image = [UIImage imageNamed:@"UpdateVersionTabActive.png"];
        
        _lblUpdVersion.text = [NSString stringWithFormat:@"Rapid Version %@",[_arrNotificationRes.firstObject valueForKey:@"UpdateVersion" ]];
        _lblUpdBranchIDName.text = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]];
    }
    
    // set previous build values
    if([[_arrNotificationRes.firstObject valueForKey:@"RollbackId"] integerValue ] > 0 )
    {
        _btn_preInstall.enabled = TRUE;
        
        // PreviousVersionTabActive.png
        _imgPrevious.image = [UIImage imageNamed:@"PreviousVersionTabActive.png"];
        
        _lblPreVersion.text = [NSString stringWithFormat:@"Rapid Version %@",[_arrNotificationRes.firstObject valueForKey:@"RollbackVersion"]];
        _lblPreBranchIDName.text = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]];
        if([[_arrNotificationRes.firstObject valueForKey:@"IsRollBack"] integerValue ] != 0)
        {
            _btn_InstallPrevious.enabled = NO;
        }
        else
        {
            _btn_InstallPrevious.enabled = YES;
        }
    }
}

-(IBAction)btn_InstallUpdateBuild:(id)sender
{
    self.strUpdateURL= [NSString stringWithFormat:@"%@",[_arrNotificationRes.firstObject valueForKey:@"UpdateURL"]];
    self.strUpdateURL = [self.strUpdateURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.strUpdateURL]];
}

-(IBAction)btn_InstallPreviousBuild:(id)sender
{
    self.strPreviousURL=[NSString stringWithFormat:@"%@",[_arrNotificationRes.firstObject valueForKey:@"RollbackURL"]];
    self.strPreviousURL = [self.strPreviousURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.strPreviousURL]];
}

-(IBAction)btn_Update:(id)sender
{
    if(IsPhone())
    {
        _uvPreVersion.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showUpdateViewIphone];
        });
    }
    else
    {
        if (popoverController.popoverVisible)
        {
            [popoverController dismissPopoverAnimated:YES];
        }
        else
        {
            _uvUpdateVersion.hidden = NO;
            _uvPreVersion.hidden = YES;
            tempviewController.view = _uvUpdateVersion;
            popoverController = [[UIPopoverController alloc] initWithContentViewController:tempviewController];
            popoverController.popoverContentSize = CGSizeMake(tempviewController.view.frame.size.width, tempviewController.view.frame.size.height) ;
            CGRect popRect = CGRectMake(self.btn_updateInstall.frame.origin.x,
                                        self.btn_updateInstall.frame.origin.y,
                                        self.btn_updateInstall.frame.size.width,
                                        self.btn_updateInstall.frame.size.height);
            [popoverController presentPopoverFromRect:popRect inView:self.view
                             permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
    }
}

-(void)showUpdateViewIphone
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if(screenBounds.size.height == 568)
    {
        _uvUpdateVersion.hidden = NO;
    }
    else
    {
        _uvUpdateVersion.hidden = NO;
        _uvUpdateVersion.frame = CGRectMake(_uvUpdateVersion.frame.origin.x, _uvUpdateVersion.frame.origin.y-90, _uvUpdateVersion.frame.size.width, _uvUpdateVersion.frame.size.height);
        _uvPreVersion.frame = CGRectMake(10, 163, 300, 357);
    }
}

-(IBAction)btn_Previous:(id)sender
{
    if(IsPhone())
    {
        _uvUpdateVersion.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showPreviousViewIphone];
        });
    }
    else
    {
//        objAppInstall = [[ApplicationInstallView alloc] initWithNibName:@"ApplicationInstallView" bundle:nil];
        if (popoverController.popoverVisible)
        {
            [popoverController dismissPopoverAnimated:YES];
        }
        else
        {
            _uvUpdateVersion.hidden = YES;
            _uvPreVersion.hidden = NO;
            tempviewController.view = _uvPreVersion;
            popoverController = [[UIPopoverController alloc] initWithContentViewController:tempviewController];
            popoverController.popoverContentSize = CGSizeMake(tempviewController.view.frame.size.width, tempviewController.view.frame.size.height) ;
            CGRect popRect = CGRectMake(self.btn_preInstall.frame.origin.x,
                                        self.btn_preInstall.frame.origin.y,
                                        self.btn_preInstall.frame.size.width,
                                        self.btn_preInstall.frame.size.height);
            [popoverController presentPopoverFromRect:popRect inView:self.view
                             permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
    }
}

-(void)showPreviousViewIphone
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if(screenBounds.size.height == 568)
    {
        _uvPreVersion.hidden = NO;
    }
    else
    {
        _uvPreVersion.hidden = NO;
        _uvPreVersion.frame = CGRectMake(_uvPreVersion.frame.origin.x, _uvPreVersion.frame.origin.y-90, _uvPreVersion.frame.size.width, _uvPreVersion.frame.size.height);
        _uvUpdateVersion.frame = CGRectMake(10, 163, 300, 357);
    }
}

-(IBAction)btn_HideUpdateView:(id)sender
{
    _uvUpdateVersion.hidden = YES;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if(screenBounds.size.height == 568)
    {
        
    }
    else
    {
        _uvUpdateVersion.frame = CGRectMake(10, 163, 300, 357);
    }
}

-(IBAction)btn_HidePreviousView:(id)sender
{
    _uvPreVersion.hidden = YES;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if(screenBounds.size.height == 568)
    {
        
    }
    else
    {
        _uvPreVersion.frame = CGRectMake(10, 163, 300, 357);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
