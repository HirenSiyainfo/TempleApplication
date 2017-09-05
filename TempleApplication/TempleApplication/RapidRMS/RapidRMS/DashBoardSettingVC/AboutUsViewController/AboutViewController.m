//
//  AboutViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 20/01/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "AboutViewController.h"
#import "RmsDbController.h"

@interface AboutViewController ()<UIPopoverPresentationControllerDelegate>
{
    UIPopoverPresentationController *popoverController;
    
    UIViewController *tempviewController;
    
    NSMutableArray *arrayNotificationResponse;
}

@property (nonatomic, weak) IBOutlet UIButton *btn_preInstall;
@property (nonatomic, weak) IBOutlet UIButton *btn_updateInstall;
@property (nonatomic, weak) IBOutlet UIButton *btnPreviousinstall;
@property (nonatomic, weak) IBOutlet UIButton *btnupdateInstall;

@property (nonatomic, weak) IBOutlet UILabel *lblPerviousidname;
@property (nonatomic, weak) IBOutlet UILabel *lblupdateIdName;
@property (nonatomic, weak) IBOutlet UILabel *lblCurrentIdName;
@property (nonatomic, weak) IBOutlet UILabel *lblPreviousVersion;
@property (nonatomic, weak) IBOutlet UILabel *lblUpdatedVersion;
@property (nonatomic, weak) IBOutlet UILabel *lblCurrentVersion;
@property (nonatomic, weak) IBOutlet UILabel *lblAppVersion;

@property (nonatomic, weak) IBOutlet UIView *uvUpdateVersion;
@property (nonatomic, weak) IBOutlet UIView *uvPreVersion;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *getNotificationDetailWC;

@property (nonatomic, strong) NSMutableArray *arrayNotificationResponse;

@property (nonatomic, strong) NSString *strUpdateURL;

@end

@implementation AboutViewController
@synthesize btn_preInstall,btn_updateInstall,arrayNotificationResponse,strUpdateURL;

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
    self.getNotificationDetailWC = [[RapidWebServiceConnection alloc] init];
    self.arrayNotificationResponse = [[NSMutableArray alloc]init];
    [self GetNotificationDetail];
    _uvUpdateVersion.hidden = YES;
    _uvPreVersion.hidden = YES;
    self.btn_preInstall.enabled = NO;
    self.btn_updateInstall.enabled = NO;
    
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSString *buildVersion = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey];
    _lblAppVersion.text = appVersion;
    _lblCurrentVersion.text = buildVersion;
    
    tempviewController = [[UIViewController alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)GetNotificationDetail
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegId"];
    NSString  *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [param setValue:buildVersion forKey:@"Version"];
    [param setValue:@"RCR" forKey:@"ApplicationType"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self GetNotificationDetailResponse:response error:error];
    };
    
    self.getNotificationDetailWC = [self.getNotificationDetailWC initWithRequest:KURL actionName:WSM_GET_NOTIFICATION_DETAIL params:param completionHandler:completionHandler];
}

-(void)GetNotificationDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responsearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                self.arrayNotificationResponse=[responsearray mutableCopy];
                if (self.arrayNotificationResponse.count>0)
                {
                    [self setBuildValues];
                }
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                NSString  *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
                _lblCurrentVersion.text = buildVersion;
                _lblCurrentIdName.text=[NSString stringWithFormat:@"%@ / %@",(self.rmsDbController.globalDict)[@"BranchInfo"][@"BranchName"],(self.rmsDbController.globalDict)[@"RegisterName"]];;
                _lblPerviousidname.text=[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"BranchInfo"][@"BranchName"]];
                _lblupdateIdName.text=[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"BranchInfo"][@"BranchName"]];
                self.btn_preInstall.enabled=NO;
                self.btn_updateInstall.enabled=NO;
            }
        }
    }
}


-(void)setBuildValues
{
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    _lblAppVersion.text = appVersion;
    // set current build values
    _lblCurrentVersion.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    _lblCurrentIdName.text = [NSString stringWithFormat:@"%@ / %@",(self.rmsDbController.globalDict)[@"BranchInfo"][@"BranchName"],(self.rmsDbController.globalDict)[@"RegisterName"]];;
    // set update build values
    if([[self.arrayNotificationResponse.firstObject valueForKey:@"UpdateId"] integerValue] >0)
    {
        btn_updateInstall.enabled = TRUE;
        _lblUpdatedVersion.text = [NSString stringWithFormat:@"Rapid Version %@",[self.arrayNotificationResponse.firstObject valueForKey:@"UpdateVersion"]];
        _lblupdateIdName.text=[NSString stringWithFormat:@"%@ / %@",(self.rmsDbController.globalDict)[@"BranchInfo"][@"BranchName"],(self.rmsDbController.globalDict)[@"RegisterName"]];
        _btnupdateInstall.enabled=YES;
    }
    
    // set previous build values
    if([[self.arrayNotificationResponse.firstObject valueForKey:@"RollbackId"] integerValue] >0 )
    {
        btn_preInstall.enabled = TRUE;
        _lblPreviousVersion.text = [NSString stringWithFormat:@"Rapid Version %@",[self.arrayNotificationResponse.firstObject valueForKey:@"RollbackVersion"]];
        _lblPerviousidname.text=[NSString stringWithFormat:@"%@ / %@",(self.rmsDbController.globalDict)[@"BranchInfo"][@"BranchName"],(self.rmsDbController.globalDict)[@"RegisterName"]];
        self.btn_preInstall.enabled=YES;
        
        if(![[self.arrayNotificationResponse.firstObject valueForKey:@"IsRollBack"] integerValue ]!=0)
        {
            _btnPreviousinstall.enabled = NO;
        }
    }
    
}

- (IBAction)btn_UpdateInstall:(id)sender
{
    [self.rmsDbController playButtonSound];

    self.strUpdateURL= [NSString stringWithFormat:@"%@",[self.arrayNotificationResponse.firstObject valueForKey:@"UpdateURL"]];
    self.strUpdateURL = [self.strUpdateURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.strUpdateURL]];

}

- (IBAction)btn_PreviousIntall:(id)sender
{
    [self.rmsDbController playButtonSound];

    self.strUpdateURL= [NSString stringWithFormat:@"%@",[self.arrayNotificationResponse.firstObject valueForKey:@"RollbackURL"]];
    self.strUpdateURL = [self.strUpdateURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.strUpdateURL]];

}

-(IBAction)btn_Update:(id)sender
{
    [self.rmsDbController playButtonSound];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _uvUpdateVersion.hidden = NO;
        _uvPreVersion.hidden = YES;
    }
    else
    {
        if (popoverController)
        {
            [tempviewController dismissViewControllerAnimated:YES completion:nil];
        }
        _uvUpdateVersion.hidden = NO;
        _uvPreVersion.hidden = YES;
        tempviewController.view = _uvUpdateVersion;
        
        // Present the view controller using the popover style.
        tempviewController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:tempviewController animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        popoverController = [tempviewController popoverPresentationController];
        popoverController.delegate = self;
        tempviewController.preferredContentSize = CGSizeMake(tempviewController.view.frame.size.width, tempviewController.view.frame.size.height);
        popoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        popoverController.sourceView = self.view;
        popoverController.sourceRect = CGRectMake(self.btn_updateInstall.frame.origin.x,
                                                  self.btn_updateInstall.frame.origin.y,
                                                  self.btn_updateInstall.frame.size.width,
                                                  self.btn_updateInstall.frame.size.height);
    }
}

-(IBAction)btn_Previous:(id)sender
{
    [self.rmsDbController playButtonSound];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _uvUpdateVersion.hidden = YES;
        _uvPreVersion.hidden = NO;
    }
    else
    {
        if (popoverController)
        {
            [tempviewController dismissViewControllerAnimated:YES completion:nil];
        }
        _uvUpdateVersion.hidden = YES;
        _uvPreVersion.hidden = NO;
        tempviewController.view = _uvPreVersion;
        
        // Present the view controller using the popover style.
        tempviewController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:tempviewController animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        popoverController = [tempviewController popoverPresentationController];
        popoverController.delegate = self;
        tempviewController.preferredContentSize = CGSizeMake(tempviewController.view.frame.size.width, tempviewController.view.frame.size.height);
        popoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        popoverController.sourceView = self.view;
        popoverController.sourceRect = CGRectMake(self.btn_preInstall.frame.origin.x,
                                                  self.btn_preInstall.frame.origin.y,
                                                  self.btn_preInstall.frame.size.width,
                                                  self.btn_preInstall.frame.size.height);
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
