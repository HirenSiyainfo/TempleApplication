//
//  ModuleActiveDeactiveVC.m
//  RapidRMS
//
//  Created by Siya on 17/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ModuleActiveDeactiveVC.h"
#import "RmsDbController.h"
#import "AvailableModuleVC.h"
#import "ActiveModuleVC.h"
#import "ReleaseModuleVC.h"
#import "UpdateManager.h"
#import "Keychain.h"
#import "DashBoardSettingVC.h"
#import "ModuleInfo+Dictionary.h"
#import "UserActivationViewController.h"
#import "BranchInfo+Dictionary.h"
#import "RegisterInfo+Dictionary.h"
#import "ModuleActiveDeactiveSideInfoVC.h"
#import "RmsDashboardVC.h"
#import "HConfigurationVC.h"

typedef NS_ENUM(NSInteger, ACTIVEDEACTIVE)
{
    ACTIVE,
    DEACTIVE,
};

@interface ModuleActiveDeactiveVC ()<ModuleActiveDeactiveDelegate,ActiveModuleVCDelegate,ReleaseModuleVCDelegate>
{
    NSString *strCOMCOD;
    IntercomHandler *intercomHandler;
    BOOL isRcrActive;
    BOOL isSaveClicked;
}

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UITextField *txtDevicename;
@property (nonatomic, weak) IBOutlet UIButton *btnSaveAndClose;
@property (nonatomic, weak) IBOutlet UIButton *btnSave;
@property (nonatomic, weak) IBOutlet UIButton *btnDashboard;
@property (nonatomic, weak) IBOutlet UIImageView *userProfilePic;

@property (nonatomic, weak) IBOutlet UIView *sideInfoContainer;
@property (nonatomic, weak) IBOutlet UIView *moduleInfoContainer;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) AvailableModuleVC *objAvailableMVC;
@property (nonatomic, strong) ActiveModuleVC *objActiveMVC;
@property (nonatomic, strong) ReleaseModuleVC *objReleaseMVC;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) ModuleActiveDeactiveSideInfoVC *activeDeactiveSideInfo;

@property (nonatomic, strong) RapidWebServiceConnection *moduleActiveDeactiveWC;

@property (nonatomic, strong) NSMutableArray *deactiveDevResult;
@property (nonatomic, strong) NSMutableArray *activeDevResult;
@property (nonatomic, strong) NSMutableArray *activeModules;
@property (nonatomic, strong) NSMutableArray *displayModuleData;
@property (nonatomic, strong) NSMutableArray *rcrModuleData;
@property (nonatomic, strong) NSMutableArray *otherModulData;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RcrController *crmController;


@end

@implementation ModuleActiveDeactiveVC
@synthesize arrDeviceAuthentication;

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

    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    self.moduleActiveDeactiveWC  = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    NSString *imageName = @"";
    if (IsPad()) {
        imageName = @"activeUserIcon.png";
    }
    else {
        imageName = @"placeholdericon_iphone.png";
    }
    UIImage *profilePic = [UIImage imageNamed:imageName];
    self.userProfilePic.layer.cornerRadius = self.userProfilePic.frame.size.width/2;
    self.userProfilePic.image = profilePic;
    if (IsPad()) {
        [self setBgImagesToSaveAndCloseButton:YES];
    }
    if (!self.bFromDashborad) {
        self.btnSave.hidden = YES;
        if (IsPad()) {
            self.btnSaveAndClose.frame = CGRectMake(self.btnSave.frame.origin.x, self.btnSaveAndClose.frame.origin.y, self.btnSaveAndClose.frame.size.width*2, self.btnSaveAndClose.frame.size.height);
            [self setBgImagesToSaveAndCloseButton:NO];
            [self setImageToButton:self.btnDashboard noramalImage:@"closeicon.png" selectedImage:@"closeiconselected.png"];
        }
        else {
            self.btnSaveAndClose.frame = CGRectMake(0, 0, self.view.frame.size.width, self.btnSaveAndClose.frame.size.height);
            [self setImageToButton:self.btnDashboard noramalImage:@"closeicon_iPhone.png" selectedImage:@"closeiconselected_iPhone.png"];
        }
    }
    else
    {
        if (IsPad()) {
            [self setImageToButton:self.btnDashboard noramalImage:@"dashboardicon.png" selectedImage:@"dashboardiconselected.png"];
        }
        else {
            [self setImageToButton:self.btnDashboard noramalImage:@"dashboardicon_iPhone.png" selectedImage:@"dashboardiconselected_iphone.png"];
        }
    }

    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"HelpIconNew.png" selectedImage:@"HelpIconNewSelected.png" withViewController:self];
    isSaveClicked = NO;
    [self configureDataToUpdateUserInterface];
    // Do any additional setup after loading the view.
}

- (void)setBgImagesToSaveAndCloseButton:(BOOL)isSmall
{
    if (isSmall) {
        [self.btnSaveAndClose setBackgroundImage:[UIImage imageNamed:@"SalesSaveClose.png"] forState:UIControlStateNormal];
        [self.btnSaveAndClose setBackgroundImage:[UIImage imageNamed:@"SalesSaveCloseSelected.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        [self.btnSaveAndClose setBackgroundImage:[UIImage imageNamed:@"savecloselarge.png"] forState:UIControlStateNormal];
        [self.btnSaveAndClose setBackgroundImage:[UIImage imageNamed:@"savecloselargeselected.png"] forState:UIControlStateHighlighted];
    }
}

- (void)setImageToButton:(UIButton *)button noramalImage:(NSString *)noramalImage selectedImage:(NSString *)selectedImage
{
    [button setImage:[UIImage imageNamed:noramalImage] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateHighlighted | UIControlStateSelected];
}

-(void)configureDataToUpdateUserInterface
{
    [self setRegisterNameAndCompnyId];
    self.activeDevResult = [[self activeDeviceArray] mutableCopy];
    self.deactiveDevResult = [[self deActiveDeviceArray] mutableCopy];
    self.activeModules = [[self activeModulesForCurrentRegister] mutableCopy];
    isRcrActive = [self isRCRActive];
    self.displayModuleData = [[self createModuleDataToDisplay] mutableCopy];
    self.rcrModuleData = [self createRCRModuleWiseList];
    self.otherModulData = [self createOtherModuleWiseList];
    [self loadSideInfoVC];
}

-(void)setRegisterNameAndCompnyId
{
    NSString *strname = (self.rmsDbController.globalDict)[@"RegisterName"];
    
    if(strname.length>0){
        self.txtDevicename.text = (self.rmsDbController.globalDict)[@"RegisterName"];
        self.txtDevicename.enabled=NO;
    }
    
    strCOMCOD = self.arrDeviceAuthentication.firstObject[@"COMCOD"];
    
    if(strCOMCOD==nil)
    {
        strCOMCOD = [[self.arrDeviceAuthentication.firstObject valueForKey:@"objDeviceInfo"] firstObject][@"CompanyId"];
    }
}

-(NSArray *)activeDeviceArray
{
    NSArray *deviceArray = [[self.arrDeviceAuthentication.firstObject valueForKey:@"objDeviceInfo"] copy];
    NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"(IsActive == 1 OR IsActive == %@) AND IsRelease == 0",@"1"];
    return [deviceArray filteredArrayUsingPredicate:activePredicate];
}

-(NSArray *)deActiveDeviceArray
{
    NSArray *deviceArray = [[self.arrDeviceAuthentication.firstObject valueForKey:@"objDeviceInfo"] copy];
    NSPredicate *activePredicate;
    if (IsPad()) {
        activePredicate = [NSPredicate predicateWithFormat:@"(IsActive == 0 OR IsActive == %@ OR IsRelease == 1) AND ModuleCode != %@",@"0",@"VMS"];
    }
    else {
        activePredicate = [NSPredicate predicateWithFormat:@"(IsActive == 0 OR IsActive == %@ OR IsRelease == 1)",@"0"];
    }
    return [deviceArray filteredArrayUsingPredicate:activePredicate];
}

-(NSArray *)releaseDeviceArray
{
    NSArray *releaseDeviceArray = [[self.arrDeviceAuthentication.firstObject valueForKey:@"objReleasedRegisterObject"] copy];
    return releaseDeviceArray;
}

- (NSArray *)activeModulesForCurrentRegister
{
    NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND (IsActive == 1 OR IsActive == %@) AND IsRelease == 0",(self.rmsDbController.globalDict)[@"DeviceId"],@"1"];
    return [self.activeDevResult filteredArrayUsingPredicate:activePredicate];
}

-(BOOL)isRCRActive
{
    BOOL isRCRActive = FALSE;
    NSPredicate *rcrPredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d OR ModuleId == %d OR ModuleId == %d OR ModuleId == %d",1,5,6,7];
    NSArray *rcrActiveArray = [self.activeModules filteredArrayUsingPredicate:rcrPredicate];
    if (rcrActiveArray.count > 0)
    {
        isRCRActive = TRUE;
    }
    else
    {
        isRCRActive = FALSE;
    }
    return isRCRActive;
}

-(NSMutableArray *)createModuleDataToDisplay
{
    NSMutableArray *moduleData = [[NSMutableArray alloc] init];
    NSArray *uniqueArray = [self.deactiveDevResult valueForKeyPath:@"@distinctUnionOfObjects.ModuleId"];
    
    for (NSNumber *moduleId in uniqueArray) {
        NSPredicate *moduleIdPre = [NSPredicate predicateWithFormat:@"ModuleId == %@", moduleId];
        NSArray *tempArray = [self.deactiveDevResult filteredArrayUsingPredicate:moduleIdPre];
        if(tempArray.count > 0)
        {
            NSMutableDictionary *moduleDict = [tempArray.firstObject mutableCopy ];
            moduleDict[@"Count"] = @(tempArray.count);
            [moduleData addObject:moduleDict];
        }
    }
    return moduleData;
}

-(NSMutableArray *)createOtherModuleWiseList
{
    NSPredicate *rcrPredicate;
    if (IsPad()) {
        rcrPredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d || ModuleId == %d || ModuleId == %d", 2,3,4];
    }
    else {
        rcrPredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d || ModuleId == %d || ModuleId == %d || ModuleId == %d ", 2,3,4,8];
    }
    NSMutableArray *arrActiveUser = [[self.displayModuleData filteredArrayUsingPredicate:rcrPredicate] mutableCopy ];
    [self getCurrentDeviceNameFirst:arrActiveUser];
    return arrActiveUser;
}

-(NSMutableArray *)createRCRModuleWiseList
{
    NSPredicate *rcrPredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d OR ModuleId == %d OR ModuleId == %d OR ModuleId == %d", 1,5,6,7];
    NSMutableArray *arrActiveUser = [[self.displayModuleData filteredArrayUsingPredicate:rcrPredicate] mutableCopy ];
    [self getCurrentDeviceNameFirst:arrActiveUser];
    return arrActiveUser;
}

- (void)getCurrentDeviceNameFirst:(NSMutableArray *)tempModuleArray
{
    for (int i =0 ; i<tempModuleArray.count; i++) {
        NSMutableDictionary *dict = tempModuleArray[i];
        if([[dict valueForKey:@"MacAdd"] isKindOfClass:[NSNull class]]){
            dict[@"MacAdd"] = @"";
        }
        if ([[dict valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]])
        {
            [tempModuleArray removeObjectAtIndex:i];
            [tempModuleArray insertObject:dict atIndex:0];
            break;
        }
    }
}

-(void)loadSideInfoVC{
    NSString *storyBoardName = @"";
    NSString *identifierForModuleActiveDeactiveSideInfoVC = @"";
    CGRect frameForSideInfo;
    if (IsPad()) {
        storyBoardName = @"Main";
        identifierForModuleActiveDeactiveSideInfoVC = @"ModuleActiveDeactiveSideInfoVC";
        frameForSideInfo = CGRectMake(624.0, 78.0, 400.0, 690.0);
    }
    else {
        storyBoardName = @"ActiveDeactive_iPhone";
        identifierForModuleActiveDeactiveSideInfoVC = @"ModuleActiveDeactiveSideInfoVC_iPhone";
        frameForSideInfo = CGRectMake(0.0, 0.0, 320.0, 250.0);
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    self.activeDeactiveSideInfo= [storyBoard instantiateViewControllerWithIdentifier:identifierForModuleActiveDeactiveSideInfoVC];
    self.activeDeactiveSideInfo.storeName = [self.arrDeviceAuthentication.firstObject valueForKey:@"STORENAME"];
    NSMutableArray *arryBranchinfo = [self.arrDeviceAuthentication.firstObject valueForKey:@"objBranchInfo"];
    if(arryBranchinfo != nil && arryBranchinfo.count > 0)
    {
        self.activeDeactiveSideInfo.storeAddress = [arryBranchinfo.firstObject valueForKey:@"Address1"];
    }
    self.activeDeactiveSideInfo.userName = [self.arrDeviceAuthentication.firstObject valueForKey:@"USERNAME"];
    self.activeDeactiveSideInfo.activeDevices = self.activeDevResult;
    self.activeDeactiveSideInfo.releaseDevices = [[self releaseDeviceArray] mutableCopy];
    self.activeDeactiveSideInfo.arrDeviceAuthentication = [self.arrDeviceAuthentication mutableCopy];
    self.activeDeactiveSideInfo.moduleSelectionChangeDelegate = self;
    [self addChildViewController:self.activeDeactiveSideInfo];
    self.activeDeactiveSideInfo.isfromDashBoard = self.bFromDashborad;
    self.activeDeactiveSideInfo.view.frame = frameForSideInfo;
    self.activeDeactiveSideInfo.lblAvailableApp.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.deactiveDevResult.count];
    if (IsPad()) {
        [self.view addSubview:self.activeDeactiveSideInfo.view];
    }
    else {
        self.activeDeactiveSideInfo.view.frame = self.sideInfoContainer.bounds;
        [self.sideInfoContainer addSubview:self.activeDeactiveSideInfo.view];
    }
}

-(void)loadAvailableApp {
    NSString *storyBoardName = @"";
    NSString *identifierForAvailableModuleVC = @"";
    CGRect frameForAvailableApp;
    if (IsPad()) {
        storyBoardName = @"Main";
        identifierForAvailableModuleVC = @"AvailableModuleVC";
        frameForAvailableApp = CGRectMake(0.0, 150.0, 624.0, 540.0);
    }
    else {
        storyBoardName = @"ActiveDeactive_iPhone";
        identifierForAvailableModuleVC = @"AvailableModuleVC_iPhone";
        frameForAvailableApp = CGRectMake(0.0, 0.0, 320.0, 250.0);
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    [self.btnSaveAndClose setHidden:NO];
    if (self.bFromDashborad) {
        [self.btnSave setHidden:NO];
    }
    [self removeSubViewsFromContainer];
    if(!self.objAvailableMVC)
    {
        self.objAvailableMVC = [storyBoard instantiateViewControllerWithIdentifier:identifierForAvailableModuleVC];
        self.objAvailableMVC.view.frame = frameForAvailableApp;
        self.objAvailableMVC.view.tag = 1000;
        [self addChildViewController:self.objAvailableMVC];
    }
    if (IsPad()) {
        [self.view addSubview:self.objAvailableMVC.view];
    }
    else {
        self.objAvailableMVC.view.frame = self.moduleInfoContainer.bounds;
        [self.moduleInfoContainer addSubview:self.objAvailableMVC.view];
    }
    self.objAvailableMVC.activationDisable = [[self.arrDeviceAuthentication.firstObject valueForKey:@"DisableActivation"] boolValue];
    self.objAvailableMVC.isRcrActive = isRcrActive;
    self.objAvailableMVC.activeModules = self.activeModules;
    self.objAvailableMVC.deactiveDeviceArray = self.deactiveDevResult;
    self.objAvailableMVC.displayModuleData = self.displayModuleData;
    self.objAvailableMVC.rcrModuleData = self.rcrModuleData;
    self.objAvailableMVC.otherModulData = self.otherModulData;
    self.objAvailableMVC.objModActi = self;
    [self.objAvailableMVC reloadAvailableModuleData];
}

- (void)removeSubViewsFromContainer {
    [[self.view viewWithTag:1000] removeFromSuperview];
    [[self.view viewWithTag:10001] removeFromSuperview];
    [[self.view viewWithTag:10002] removeFromSuperview];
    [self.objAvailableMVC removeFromParentViewController];
    [self.objActiveMVC removeFromParentViewController];
    [self.objReleaseMVC removeFromParentViewController];
}

-(void)loadActiveApp
{
    NSString *storyBoardName = @"";
    NSString *identifierForActiveModuleVC = @"";
    CGRect frameForActiveApp;
    if (IsPad()) {
        storyBoardName = @"Main";
        identifierForActiveModuleVC = @"ActiveModuleVC";
        frameForActiveApp = CGRectMake(0.0, 150.0, 624.0, 540.0);
    }
    else {
        storyBoardName = @"ActiveDeactive_iPhone";
        identifierForActiveModuleVC = @"ActiveModuleVC_iPhone";
        frameForActiveApp = CGRectMake(0.0, 0.0, 320.0, 250.0);
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    [self.btnSaveAndClose setHidden:NO];
    if (self.bFromDashborad) {
        [self.btnSave setHidden:NO];
    }
    [self removeSubViewsFromContainer];
    
    if(!self.objActiveMVC)
    {
        self.objActiveMVC = [storyBoard instantiateViewControllerWithIdentifier:identifierForActiveModuleVC];
        self.objActiveMVC.view.frame = frameForActiveApp;
        self.objActiveMVC.view.tag = 10001;
        self.objActiveMVC.activeModuleVCDelegate = self;
        [self addChildViewController:self.objActiveMVC];
    }
    if (IsPad()) {
        [self.view addSubview:self.objActiveMVC.view];
    }
    else {
        self.objActiveMVC.view.frame = self.moduleInfoContainer.bounds;
        [self.moduleInfoContainer addSubview:self.objActiveMVC.view];
    }
    self.objActiveMVC.strCOMCOD = [[self.arrDeviceAuthentication.firstObject valueForKey:@"objDeviceInfo"] firstObject][@"CompanyId"];
    self.objActiveMVC.strBranchId = [[[self.arrDeviceAuthentication.firstObject valueForKey:@"objBranchInfo"] firstObject] valueForKey:@"BranchId"];
    self.objActiveMVC.activeDevices = self.activeDevResult;
    self.objActiveMVC.activeModules = self.activeModules;
    self.objActiveMVC.strCOMCOD = strCOMCOD;
    self.objActiveMVC.isRcrActive = isRcrActive;
    [self.objActiveMVC makeUserWiseActiveModule];
}

-(void)loadReleaseModules {
    NSString *storyBoardName = @"";
    NSString *identifierForReleaseModuleVC = @"";
    CGRect frameForReleaseModules;
    if (IsPad()) {
        storyBoardName = @"Main";
        identifierForReleaseModuleVC = @"ReleaseModuleVC";
        frameForReleaseModules = CGRectMake(0.0, 150.0, 624.0, 540.0);
    }
    else {
        storyBoardName = @"ActiveDeactive_iPhone";
        identifierForReleaseModuleVC = @"ReleaseModuleVC_iPhone";
        frameForReleaseModules = CGRectMake(0.0, 0.0, 320.0, 250.0);
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    [self.btnSaveAndClose setHidden:YES];
    [self.btnSave setHidden:YES];
    [self removeSubViewsFromContainer];
    
    if(!self.objReleaseMVC)
    {
        self.objReleaseMVC = [storyBoard instantiateViewControllerWithIdentifier:identifierForReleaseModuleVC];
        self.objReleaseMVC.view.frame=frameForReleaseModules;
        self.objReleaseMVC.view.tag = 10002;
        self.objReleaseMVC.releaseModuleVCDelegate = self;
        [self addChildViewController:self.objReleaseMVC];
    }
    if (IsPad()) {
        [self.view addSubview:self.objReleaseMVC.view];
    }
    else {
        self.objReleaseMVC.view.frame = self.moduleInfoContainer.bounds;
        [self.moduleInfoContainer addSubview:self.objReleaseMVC.view];
    }
    self.objReleaseMVC.activeDevResultRelease = [self.arrDeviceAuthentication.firstObject valueForKey:@"objReleasedRegisterObject"];
    self.objReleaseMVC.strBranchId = [NSString stringWithFormat:@"%@",[[[self.arrDeviceAuthentication.firstObject valueForKey:@"objBranchInfo"] firstObject] valueForKey:@"BranchId"]];
    self.objReleaseMVC.activeModules = self.activeModules;
    self.objReleaseMVC.strCOMCOD = strCOMCOD;
    self.objReleaseMVC.isRcrActive = isRcrActive;
    [self.objReleaseMVC makeReleaseActiveModule];
}

-(void)loadRegisterUserModuleall{
    if(self.objActiveMVC){
        [self.objActiveMVC loadAllUserModule];
    }
}

-(void)loadActiveRegisterModule:(NSNumber *)registerNumber {
    if(self.objActiveMVC){
        [self.objActiveMVC filterWithRegisterWise:registerNumber];
    }
}

-(void)loadReleaseUserModule:(NSString *)regUser{
    if(self.objReleaseMVC){
        [self.objReleaseMVC filterWithUserWiseReleaseModule:regUser];
    }
}

-(IBAction)btnDashboardClicked:(id)sender
{
    if (self.bFromDashborad) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers != nil && viewControllers.count > 0) {
            for (UIViewController *viewController in viewControllers) {
                Class destinationClass;
                if (IsPad()) {
                    destinationClass = [DashBoardSettingVC class];
                }
                else {
                    destinationClass = [RmsDashboardVC class];
                }
                if ([viewController isKindOfClass:destinationClass]) {
                    [self.navigationController popToViewController:viewController animated:YES];
                }
            }
        }
    }
    else
    {
        [self goTODeviceActivation];
    }
}

-(IBAction)btnSaveAndCloseClicked:(id)sender
{
    [self activeDeactiveModuleMethod];
}

-(IBAction)btnSaveClicked:(id)sender
{
    isSaveClicked = YES;
    [self activeDeactiveModuleMethod];
}

-(void)activeDeactiveModuleMethod{
    
    if(self.txtDevicename.text.length > 0){
        
        NSMutableArray *activeDeviceArray = [self getModuleActiveDeviceData];
        NSMutableArray *deActiveDeviceArray = [self getModuleDeactiveDeviceData];

        if((activeDeviceArray.count > 0) || deActiveDeviceArray.count > 0){
            NSString *strBranchID = [NSString stringWithFormat:@"%@",[[[self.arrDeviceAuthentication.firstObject valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"BranchId"]];
            
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            NSMutableDictionary * dictDeviceActivation = [[NSMutableDictionary alloc] init];
            dictDeviceActivation[@"BranchId"] = strBranchID;
            dictDeviceActivation[@"COMCOD"] = strCOMCOD;
            dictDeviceActivation[@"RegisterName"] = self.txtDevicename.text;
            dictDeviceActivation[@"MacAdd"] = (self.rmsDbController.globalDict)[@"DeviceId"];
            dictDeviceActivation[@"dType"] = @"IOS-RCRIpad";
            dictDeviceActivation[@"dVersion"] = [UIDevice currentDevice].systemVersion;
            dictDeviceActivation[@"TokenId"] = (self.rmsDbController.globalDict)[@"TokenId"];
            
            dictDeviceActivation[@"ConfigurationId"] = (self.rmsDbController.globalDict)[@"CONFIGID"];
            
            dictDeviceActivation[@"ApplicationType"] = @"";
            
            //check both active deactive array before service call
            dictDeviceActivation[@"activeDeviceInfo"] = activeDeviceArray;
            dictDeviceActivation[@"DeactiveDeviceInfo"] = deActiveDeviceArray;
            dictDeviceActivation[@"LocalDate"] = [self localeDate];
            NSString *buildVersion = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey];
            if ([buildVersion isKindOfClass:[NSString class]])
            {
                dictDeviceActivation[@"BuildVersion"] = buildVersion;
            }
            else
            {
                dictDeviceActivation[@"BuildVersion"] = @"";
            }

            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self moduleActivationResponse:response error:error];
                });
            };
            
            self.moduleActiveDeactiveWC = [self.moduleActiveDeactiveWC initWithRequest:KURL actionName:WSM_DEVICE_SETUP_NEW params:dictDeviceActivation completionHandler:completionHandler];
        }
        else{
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Active/Deactive Application" message:@"Please select Module" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    }
    else{
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Active Application" message:@"Please enter Device Name" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

- (void)moduleActivationResponse:(id)response error:(NSError *)error
{
    if (response != nil)
    {
        [self deviceActivationResponse:response error:error withResponseResultKey:@"DeviceSetup01062015Result"];
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Active Application" message:@"Error occured in Active Deactive Process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [_activityIndicator hideActivityIndicator];
}

- (NSString *)localeDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    return currentDateTime;
}

- (NSMutableArray *)getModuleDeactiveDeviceData
{
    NSMutableArray *arrDeActiveDevice = [[NSMutableArray alloc] init];
    if(self.objActiveMVC.activeDevices.count>0)
    {
        NSPredicate *deActiveDevicePredicate = [NSPredicate predicateWithFormat:@"IsActive == 0 OR IsActive == %@",@"0"];
        NSArray *deActiveDevices = [[self.objActiveMVC.activeDevices filteredArrayUsingPredicate:deActiveDevicePredicate] copy];
        if (deActiveDevices != nil && deActiveDevices.count > 0) {
            for (NSDictionary *deActiveDict in deActiveDevices) {
                NSMutableDictionary *dictToDeActivateDevice = [[NSMutableDictionary alloc] init];
                dictToDeActivateDevice[@"Id"] = deActiveDict [@"Id"];
                dictToDeActivateDevice[@"IsActive"] = deActiveDict [@"IsActive"];
                dictToDeActivateDevice[@"IsCustomerDisplay"] = deActiveDict [@"IsCustomerDisplay"];
                dictToDeActivateDevice[@"IsRelease"] = deActiveDict [@"IsRelease"];
                dictToDeActivateDevice[@"ModuleAccessId"] = deActiveDict [@"ModuleAccessId"];
                dictToDeActivateDevice[@"ModuleId"] = deActiveDict [@"ModuleId"];
                [arrDeActiveDevice addObject:dictToDeActivateDevice];
            }
        }
    }
    return arrDeActiveDevice;
}

- (NSMutableArray *)getModuleActiveDeviceData
{
    NSMutableArray *arrActiveDevice = [[NSMutableArray alloc] init];
    
    if(self.objAvailableMVC.deactiveDeviceArray.count>0)
    {
        NSPredicate *activeDevicePredicate = [NSPredicate predicateWithFormat:@"IsActive == 1 OR IsActive == %@",@"1"];
        NSArray *activeDevices = [self.objAvailableMVC.deactiveDeviceArray filteredArrayUsingPredicate:activeDevicePredicate];
        if (activeDevices != nil && activeDevices.count > 0) {
            for (NSDictionary *activeDict in activeDevices) {
                NSMutableDictionary *dictToActivateDevice = [[NSMutableDictionary alloc] init];
                dictToActivateDevice[@"Id"] = activeDict [@"Id"];
                dictToActivateDevice[@"IsActive"] = activeDict [@"IsActive"];
                dictToActivateDevice[@"IsCustomerDisplay"] = activeDict [@"IsCustomerDisplay"];
                dictToActivateDevice[@"IsRelease"] = activeDict [@"IsRelease"];
                dictToActivateDevice[@"ModuleAccessId"] = activeDict [@"ModuleAccessId"];
                dictToActivateDevice[@"ModuleId"] = activeDict [@"ModuleId"];
                [arrActiveDevice addObject:dictToActivateDevice];
            }
        }
    }
    return arrActiveDevice;
}

-(void)deviceActivationResponse:(id)response error:(NSError *)error withResponseResultKey:(NSString *)responseResultKey {
    [self.rmsDbController.globalDict removeObjectForKey:@"STORENAME"];
    [self.rmsDbController.globalDict removeObjectForKey:@"LoginUserName"];
    
    RegisterInfo *registerInfo = [self.updateManager updateRegisterInfoMoc:self.managedObjectContext];
    NSString * strOlddBName = registerInfo.dBName;
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            int errorCode = [[response valueForKey:@"IsError"] intValue];
            if(errorCode == 0)
            {
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                
                NSMutableDictionary *responseData = [self checkforActiveDeviceInfoForStore:responseArray];
                
                self.rmsDbController.appsActvDeactvSettingarrayWithStore=[responseArray mutableCopy];
                
                self.rmsDbController.appsActvDeactvSettingarrayWithStore = [self replacekeyValuepairDetials:self.rmsDbController.appsActvDeactvSettingarrayWithStore];
                
                if ([responseData valueForKey:@"BranchId"]) {
                    (self.rmsDbController.globalDict)[@"BranchID"] = [responseData valueForKey:@"BranchId"];
                }
                if ([responseData valueForKey:@"RegisterId"]) {
                    (self.rmsDbController.globalDict)[@"RegisterId"] = [responseData valueForKey:@"RegisterId"];
                }
                if ([responseData valueForKey:@"ZId"]) {
                    (self.rmsDbController.globalDict)[@"ZId"] = [responseData valueForKey:@"ZId"];
                }
                if ([responseData valueForKey:@"ZRequired"]) {
                    (self.rmsDbController.globalDict)[@"ZRequired"] = [responseData valueForKey:@"ZRequired"];
                }
                if ([responseData valueForKey:@"RegisterName"]) {
                    (self.rmsDbController.globalDict)[@"RegisterName"] = [responseData valueForKey:@"RegisterName"];
                }
                
                NSMutableArray *arryBranch=[responseData valueForKey:@"Branch_MArray"];
                if(arryBranch.count>0)
                {
                    NSMutableArray *responseBranchArray=[arryBranch mutableCopy];
                    NSMutableDictionary *dictBranchInfo = responseBranchArray.firstObject;
                    dictBranchInfo[@"HelpMessage1"] = [responseData valueForKey:@"HelpMessage1"];
                    dictBranchInfo[@"HelpMessage2"] = [responseData valueForKey:@"HelpMessage2"];
                    dictBranchInfo[@"HelpMessage3"] = [responseData valueForKey:@"HelpMessage3"];
                    dictBranchInfo[@"SupportEmail"] = [responseData valueForKey:@"SupportEmail"];
                    (self.rmsDbController.globalDict)[@"BranchInfo"] = dictBranchInfo;
                }
                
                self.rmsDbController.appsActvDeactvSettingarray = [responseData valueForKey:@"objDeviceInfo"];
                
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
                
                if ([responseResultKey isEqualToString:@"ReplaceWithRegisterResult"]) {
                    if (![[responseData valueForKey:@"BranchConfigurationSetting"] isKindOfClass:[NSNull class]])
                    {
                        //Remove Old Setting
                        [self.rmsDbController removeAppSettings];
                        if (self.crmController.globalArrTenderConfig && self.crmController.globalArrTenderConfig.count > 0) {
                            [self.crmController.globalArrTenderConfig removeAllObjects];
                        }

                        //Set New Setting
                        NSDictionary *rapidConfigSetting = [[responseData valueForKey:@"BranchConfigurationSetting"] firstObject];
                        [self.rmsDbController setAppSetting:rapidConfigSetting];
                    }
                }
                
                if (![strOlddBName isEqualToString:responseData[@"DBName"]]) {
                    [self configureAppAfterActiveDeactiveProcess:responseArray responseData:responseData];
                    if (IsPhone()) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ModuleCode==%@ && IsActive ==%@ && MacAdd==%@",@"VMS",@(1),self.rmsDbController.globalDict[@"DeviceId"]];
                        NSArray *arrayCount = [self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:predicate];
                        if(arrayCount.count>0 && ![self isVendorActive])
                        {
                            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                            HConfigurationVC *objStoreVC = [storyBoard instantiateViewControllerWithIdentifier:@"HConfigurationVC"];
                            objStoreVC.dictBranchInfo = (self.rmsDbController.globalDict)[@"BranchInfo"];
                            [self.navigationController pushViewController:objStoreVC animated:YES];
                            return;
                        }
                    }
                    [self.rmsDbController removeDatabaseInfoAndConfigureWithNewBarnch];
                }
                else{
                    if (isSaveClicked) {
                        isSaveClicked = NO;
                        self.arrDeviceAuthentication = [self.rmsDbController.appsActvDeactvSettingarrayWithStore mutableCopy];
                        [self configureDataToUpdateUserInterface];
                    }
                    else
                    {
                        [self configureAppAfterActiveDeactiveProcess:responseArray responseData:responseData];
                        [self.rmsDbController getItemDataFirstTime];
                    }
                }
                [self.rmsDbController addEventForMasterUpdateWithKey:kModuelActivation];
            }
            else if(errorCode == 1){
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Applications" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
            else if(errorCode == 2){
                
                if ([responseResultKey isEqualToString:@"ReplaceWithRegisterResult"]) {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Applications" message:@"Please purchase module" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else
                {
                    (self.rmsDbController.globalDict)[@"RegisterName"] = @"";
                    (self.rmsDbController.globalDict)[@"DBName"] = @"";
                    ModuleActiveDeactiveVC * __weak myWeakReference = self;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        [myWeakReference goTODeviceActivation];
                    };
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Applications" message:@"User has been deactivated all modules successfully from respected this device, please reactivate modules as per your requirement for further transactions.." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Applications" message:@"Server Error" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Applications" message:@"Error occured in Active Deactive Process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

- (void)configureAppAfterActiveDeactiveProcess:(NSMutableArray *)responseArray responseData:(NSMutableDictionary *)responseData {
    if([UIDevice currentDevice ].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        [self configureDatabaseWithDeviceConfiguration:privateContextObject responseData:responseData responseArray:responseArray];
        [UpdateManager saveContext:privateContextObject];
    }
    else
    {
        UIViewController *rootViewController = nil;
        // NSArray *array = self.navigationController.viewControllers;
        
        for (UIViewController *aController in self.navigationController.viewControllers) {
            if (rootViewController) {
                rootViewController = aController;
                break;
            } else {
                if([aController isKindOfClass:[DashBoardSettingVC class]])
                {
                    rootViewController = aController;
                }
            }
        }
        
        if (rootViewController) {
            self.appDelegate.navigationController.viewControllers=@[rootViewController];
        }
        
        self.rmsDbController.isRegisterFirstTime=TRUE;
        
        [self.rmsDbController disconnect];
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        [self.rmsDbController setInvoiceNoFromDict:responseData privateContextObject:privateContextObject];
        NSString *storeInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
        if (storeInvoiceNo)
        {
            Configuration *configuration = [self.updateManager insertConfigurationMoc:privateContextObject ];
            configuration.regPrefixNo = [responseData valueForKey:@"InvPrefix"];
        }
        else
        {
            Configuration *configuration = [self.updateManager insertConfigurationMoc:privateContextObject];
            if(configuration.invoiceNo != 0)
            {
                [Keychain saveString:configuration.invoiceNo.stringValue forKey:@"tenderInvoiceNo"];
                configuration.regPrefixNo = [responseData valueForKey:@"InvPrefix"];
            }
            else
            {
                [Keychain saveString:@"0" forKey:@"tenderInvoiceNo"];
                configuration.regPrefixNo = [responseData valueForKey:@"InvPrefix"];
                
            }
        }
        
        [self configureDatabaseWithDeviceConfiguration:privateContextObject responseData:responseData responseArray:responseArray];
        
        
        [UpdateManager saveContext:privateContextObject];
    }
}

- (void)configureDatabaseWithDeviceConfiguration:(NSManagedObjectContext *)privateContextObject responseData:(NSMutableDictionary *)responseData responseArray:(NSMutableArray *)responseArray
{
    NSPredicate *filterRcrPredicate = [NSPredicate predicateWithFormat:@"MacAdd = %@",(self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray * array = [ self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:filterRcrPredicate];
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
    [registerInfo updateRegisterInfoDictionary:responseData];
    
    BranchInfo *branchInfo = [self.updateManager updateBranchInfoMoc:privateContextObject];
    [branchInfo updateBranchInfoDictionary:[ self.rmsDbController.globalDict valueForKey:@"BranchInfo"]];
    
    NSDictionary *userInfo = [[responseData valueForKey:@"UserInfo"] firstObject];
    [self.updateManager deleteDetailOfUserInfo:privateContextObject];
    [self.updateManager updateDetailWithUserInfo:userInfo withmoc:privateContextObject];
    [UpdateManager saveContext:privateContextObject];
}

-(BOOL)isVendorActive {
    
    BOOL vItem=NO;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Vendor_Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (arryTemp.count == 0)
    {
        vItem=NO;
    }
    else{
        vItem=YES;
    }
    return  vItem;
    
}

-(NSMutableDictionary *)checkforActiveDeviceInfoForStore:(NSMutableArray *)aStore{
    
    NSMutableDictionary *dictActiveStore;
    
    for(int i=0;i<aStore.count;i++){
        
        NSMutableDictionary *dictStore = [aStore[i]mutableCopy];
        
        NSMutableArray *arrayDeviceInfo = [dictStore valueForKey:@"objDeviceInfo"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"MacAdd = %@",[self.rmsDbController.globalDict valueForKey:@"DeviceId"]];
        
        NSArray *arrayTemp = [arrayDeviceInfo filteredArrayUsingPredicate:predicate];
        if(arrayTemp.count>0)
        {
            dictActiveStore=dictStore;
        }
        else{
            dictStore[@"DisableActivation"] = @"";
            aStore[i] = dictStore;
        }
    }
    
    return dictActiveStore;
}

-(NSMutableArray *)replacekeyValuepairDetials:(NSMutableArray *)pArray{
    
    for(int i=0;i<pArray.count;i++){
        
        NSMutableDictionary *dictStore = [pArray[i]mutableCopy];
        
        dictStore[@"objBranchInfo"] = [dictStore valueForKey:@"Branch_MArray"];
        [dictStore removeObjectForKey:@"Branch_MArray"];
        pArray[i] = dictStore;
    }
    return pArray;
    
}
-(void)removeModuleShortcutSelection{
    
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    
    NSMutableArray *arrayActiveModule= [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive]mutableCopy];
    
    
    BOOL isRcractive = [self isRcrActive:arrayActiveModule];
    if (!isRcractive)
    {
        for(int i=2;i<=4;i++){
            [self removeFromUserDefault:[NSString stringWithFormat:@"%d", i]];
        }
    }
    
    BOOL isRimActive = [self isRimActive:arrayActiveModule];
    if (!isRimActive)
    {
        [self removeFromUserDefault:@"5"];
    }
    
    BOOL isPurChaseActive = [self isPurchaseOrdeActive:arrayActiveModule];
    if (!isPurChaseActive)
    {
        [self removeFromUserDefault:@"6"];
    }
    
}
-(void)removeFromUserDefault:(NSString *)strTag{
    
    NSMutableArray *globalModuleSelectionArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"ModuleSelectionShortCut"]mutableCopy];
    
    for(int i=0;i<globalModuleSelectionArray.count;i++){
        
        NSMutableDictionary *dict = globalModuleSelectionArray[i];
        if([[dict valueForKey:@"moduleIndex"] isEqualToString:strTag]){
            [globalModuleSelectionArray removeObjectAtIndex:i];
        }
    }
    [[NSUserDefaults standardUserDefaults]setObject:globalModuleSelectionArray forKey:@"ModuleSelectionShortCut"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//hiten

-(BOOL)isRimActive:(NSMutableArray *)pmoduleArray
{
    BOOL isRimActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@", @"RIM"];
    NSArray *rimArray = [pmoduleArray filteredArrayUsingPredicate:rcrActive];
    if (rimArray.count > 0) {
        isRimActive = TRUE;
    }
    return isRimActive;
}

-(BOOL)isPurchaseOrdeActive:(NSMutableArray *)pmoduleArray
{
    BOOL isPurchaseOrdeActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@", @"PO"];
    NSArray *rimArray = [pmoduleArray filteredArrayUsingPredicate:rcrActive];
    if (rimArray.count > 0) {
        isPurchaseOrdeActive = TRUE;
    }
    return isPurchaseOrdeActive;
}

-(BOOL)isRcrActive:(NSMutableArray *)pmoduleArray
{
    BOOL isRCRActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ OR ModuleCode == %@", @"RCR",@"RCRGAS"];
    NSArray *rcrArray = [pmoduleArray filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRCRActive = TRUE;
    }
    return isRCRActive;
}

-(void)goTODeviceActivation
{
    NSString *nibName = @"";
    if (IsPad()) {
        nibName = @"UserActivationViewController";
    }
    else {
        nibName = @"UserActivationVC_iPhone";
    }
    UserActivationViewController *objUser = [[UserActivationViewController alloc] initWithNibName:nibName  bundle:nil];
    objUser.bFromDashborad = NO;
    if (IsPad()) {
        self.navigationController.viewControllers=@[objUser];
    }
    else {
        self.appDelegate.navigationController.viewControllers=@[objUser];
    }
}

- (void)replaceRegisterResponse:(id)response error:(NSError *)error
{
    if (response != nil)
    {
        [self deviceActivationResponse:response error:error withResponseResultKey:@"ReplaceWithRegisterResult"];
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Replace Register" message:@"Error occured in Replace Register" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}


//call when press return key in keyboard.
- (BOOL) textFieldShouldReturn:(UITextField *)textFiled {
    [textFiled resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnHomeClicked:(id)sender
{
    [self loadSideInfoVC];
}


-(IBAction)btnCancelClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ActiveModuleVCDelegate

- (void)startActivityIndicator {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
}

- (void)stopActivityIndicator {
    [_activityIndicator hideActivityIndicator];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
