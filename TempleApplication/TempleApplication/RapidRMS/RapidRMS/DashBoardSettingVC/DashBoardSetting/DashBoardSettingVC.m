//
//  DashBoardSettingVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 05/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DashBoardSettingVC.h"
#import "RmsDbController.h"
#import "rapidRMSSettingController.h"
#import "UserActivationViewController.h"
#import "RimsController.h"
#import "InvoiceData_T.h"
#import "AboutViewController.h"
#import "SettingSoundVC.h"
#import "ScannerSettingVC.h"
#import "CustomerDisplayViewController.h"
#import "RmsDashboardVC.h"

#import "TenderConfigurationViewController.h"
#import "TenderConfigurationSubViewController.h"
#import "TenderConfigurationSubEditVC.h"

#import "CustomerDisplayBrowserVC.h"
#import "CustomerDisplayConnection.h"
#import "AvailableAppsViewController.h"
#import "ApplicationSettingVC.h"
#import "ActiveAppsVC.h"
#import "DeptFavSelectionViewController.h"
#import "CashRegisterDisplayVC.h"
#import "SynchronizeViewController.h"
#import "PrinterSettingViewController.h"
#import "OfflineRecordVC.h"
#import "InventoryManagementSetting.h"
#import "ModuleSelectionShortCut.h"

#import "CKOCalendarViewController.h"
#import "DashBoardIconSelectionVC.h"
#import "KitchenPrinterVC.h"
#import "KitchenPrinter.h"
#import "Department+Dictionary.h"
#import "PaxDeviceViewController.h"
#import "POSLoginView.h"
#import "AppSettings.h"

typedef NS_ENUM(NSInteger, RmsSettingPageSection) {
    RmsSettingSection,
    RmsHardwareSettingSection,
    RmsOptionSection,
   // RmsMiscellaneousSection,
};

// RmsSettingSection
typedef NS_ENUM(NSInteger, RmsSettingSectionPages) {
    SettingAboutUs,
    SettingApps,
    SettingToolTipSetUp,
};

// RmsHardwareSettingSection
typedef NS_ENUM(NSInteger, RmsHardwareSettingSectionPages) {
    HardwareUPCScanner,
    HardwareTenderConfiguration,
    HardwareCustomerDisplay,
    HardwareRCRDashBoard,
    HardwarePrinter,
    HardwareSound,
    HardwareKitchenPrinter,
    HardwareOfflineRecord,
    HardwareGasPump,
    HardwarePaxDeviceSetting,

};

// RmsOptionSection
typedef NS_ENUM(NSInteger, RmsOptionSectionPages) {
   RCRSettingDashBoard,
    RCRSettingSynchronize,
    RCRSettingOption,
};

// RmsMiscellaneousSection
//typedef NS_ENUM(NSInteger, RmsMiscellaneousSectionPages) {
//    
//};

@interface DashBoardSettingVC () <UIPopoverControllerDelegate , LoginResultDelegate>
{
    NSIndexPath *clickedIndexpath;
    NSString *strCOMCOD;
    
    AppDelegate *appDelegate;
    AboutViewController *objInfoSetting;
    SettingSoundVC *objSettingSound;
    ScannerSettingVC *objScannerSet;
    TenderConfigurationViewController *objTenderConfig;
    CustomerDisplayBrowserVC *custDispvc;
    AvailableAppsViewController *appsAvailable;
    
    ApplicationSettingVC *applicationSettingVC;
    ActiveAppsVC *activeAppsVC;
    SynchronizeViewController *synchronizeVC;
    PrinterSettingViewController *printerSettingVC;
    KitchenPrinterVC *kitchenprinterSettingVC;
    PaxDeviceViewController *paxDeviceVC;
    
    OfflineRecordVC *objofflineRecord;
    InventoryManagementSetting *rimSetting;
    ModuleSelectionShortCut *moduleSelectionShortCut;
    DashBoardIconSelectionVC *dashBoardIconSelectionVC;
    
    RmsDashboardVC *dashboardVC;
    IntercomHandler *intercomHandler;
    
    POSLoginView * loginView;
    AppSettings *appSettings;
    
    UINavigationController *tenderSettingsNav;
    UINavigationController *customerDisplayNav;
    UINavigationController *deptFavSelectionNav;
    UINavigationController *availableAppsNav;
    UINavigationController *printerSettingNav;
    UINavigationController *kitchenprinterSettingNav;
    UINavigationController *paxDeviceSettingNav;
    UINavigationController *gasPumpSettingNav;
    
    NSMutableArray *arrayOfflineRecords;
}

@property (nonatomic, weak) IBOutlet UITableView *tblNotActivated;
@property (nonatomic, weak) IBOutlet UITableView *tblActive;
@property (nonatomic, weak) IBOutlet UITableView *tblSettingSideMenu;

@property (nonatomic, weak) IBOutlet UILabel *lblDashBardTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblSecondDate;
@property (nonatomic, weak) IBOutlet UILabel *lblCurrentDate;

@property (nonatomic, weak) IBOutlet UIButton *btnDoneApps;
@property (nonatomic, weak) IBOutlet UIButton *btnProfile;
@property (nonatomic, weak) IBOutlet UIButton *btnActiveApp;
@property (nonatomic, weak) IBOutlet UIButton *btnOthers;
@property (nonatomic, weak) IBOutlet UIButton *settingsButton;
@property (nonatomic, weak) IBOutlet UIButton *exitButton;
@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UIButton *showCalendarSecond;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, weak) IBOutlet UITextField *txtusername;
@property (nonatomic, weak) IBOutlet UITextField *txtpassword;
@property (nonatomic, weak) IBOutlet UITextField *txtRegisterName;

@property (nonatomic, weak) IBOutlet UIView *uvapps;
@property (nonatomic, weak) IBOutlet UIView *uvDispSubView;
@property (nonatomic, weak) IBOutlet UIView *customerDiplayView;
@property (nonatomic, weak) IBOutlet UIView *dashBoardIconView;
@property (nonatomic, weak) IBOutlet UIView *appsSettingView;
@property (nonatomic, weak) IBOutlet UIView *aboutUsView;
@property (nonatomic, weak) IBOutlet UIView *synchronizeView;
@property (nonatomic, weak) IBOutlet UIView *printerSettingview;
@property (nonatomic, weak) IBOutlet UIView *kitchenprinterSettingview;
@property (nonatomic, weak) IBOutlet UIView *paxDeviceSettingView;
@property (nonatomic, weak) IBOutlet UIView *uvRcr;
@property (nonatomic, weak) IBOutlet UIView *uvRim;
@property (nonatomic, weak) IBOutlet UIView *uvModuleShortCut;
@property (nonatomic, weak) IBOutlet UIView *uvAuthentication;
@property (nonatomic, weak) IBOutlet UIView *uvButtonNavigation;
@property (nonatomic, weak) IBOutlet UIView *uvNotActivatedApps;
@property (nonatomic, weak) IBOutlet UIView *uvActiveApps;
@property (nonatomic, weak) IBOutlet UIView *uvOthers;
@property (nonatomic, weak) IBOutlet UIView *tenderView;
@property (nonatomic, weak) IBOutlet UIView *viewOfflineRecord;
@property (nonatomic, weak) IBOutlet UIView *gasPumpView;
@property (nonatomic, weak) IBOutlet UIView *slidingView;
@property (nonatomic, weak) IBOutlet UIView *dashboardContainerView;

@property (nonatomic, strong) UIButton *btnApps;
@property (nonatomic, strong) UIButton *btnToolTipSetup;
@property (nonatomic, strong) UIButton *btnAboutUs;
@property (nonatomic, strong) UIButton *btnSound;
@property (nonatomic, strong) UIButton *btnUpcScan;
@property (nonatomic, strong) UIButton *btnCustDisp;
@property (nonatomic, strong) UIButton *btnTenderConfig;
@property (nonatomic, strong) UIButton *btnNotActivated;
@property (nonatomic, strong) UIButton *btnCashRegister;
@property (nonatomic, strong) UIButton *btnInventoryMgmt;
@property (nonatomic, strong) UIButton *btnSynchronize;
@property (nonatomic, strong) UIButton *btnPrinterSetting;
@property (nonatomic, strong) UIButton *btnKitchenPrinterSetting;
@property (nonatomic, strong) UIButton *btnGasPump;
@property (nonatomic, strong) UIButton *btnModuleSelection;
@property (nonatomic, strong) UIButton *btnDashBoardIconSelection;
@property (nonatomic, strong) UIButton *btnPaxDeviceSetting;
@property (nonatomic, strong) UIButton *btnChecked;
@property (nonatomic, strong) UIButton *btnOfflineRecord;

@property (nonatomic, strong) UIImageView *imgBackGround;

@property (nonatomic, strong) UILabel *lblModuleName;
@property (nonatomic, strong) UILabel *lblStatus;
@property (nonatomic, strong) UILabel *lblActiveDeviceName;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *deviceSetupWC;
@property (nonatomic, strong) RapidWebServiceConnection *userAccessLoginWC;
@property (nonatomic, strong) RapidWebServiceConnection *webServiceConnectionSettingBG;

@property (nonatomic, strong) UIPopoverController *calendarPopOverController;

@property (nonatomic, strong) NSMutableArray *deactiveDevResult;
@property (nonatomic, strong) NSMutableArray *activeDevResult;
@property (nonatomic, strong) NSMutableArray *arrTempActive;
@property (nonatomic, strong) NSMutableArray *arrTempDeActive;
@property (nonatomic, strong) NSMutableArray *rmsSettingSectionsArray;
@property (nonatomic, strong) NSMutableArray *settingArray;
@property (nonatomic, strong) NSMutableArray *hardwareSettingArray;
@property (nonatomic, strong) NSMutableArray *optionArray;
@property (nonatomic, strong) NSMutableArray *miscellaneousArray;
@property (nonatomic, strong) NSMutableArray *arrayOfflineRecords;

@property (nonatomic, assign) BOOL isChangesDone;
@property (nonatomic, assign) BOOL isUserAuthenticated;
@property (nonatomic, assign) BOOL isOfflieRecordFound;
@property (nonatomic, assign) BOOL isGasPumpFound;
@property (nonatomic, assign) BOOL isRestaurentFound;

@property (nonatomic, getter = isMenuVisible) BOOL menuVisible;

@property (nonatomic, strong) UIViewController *navVC;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation DashBoardSettingVC
@synthesize txtRegisterName;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize arrayOfflineRecords;

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
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _viewOfflineRecord.hidden=YES;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.deviceSetupWC = [[RapidWebServiceConnection alloc] init];
    self.userAccessLoginWC = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    appSettings = [[AppSettings alloc] init];
    [self.uvapps setHidden:YES];
    _uvAuthentication.hidden = YES;
    self.isUserAuthenticated = FALSE;
    _tenderView.hidden = YES;
    _customerDiplayView.hidden = YES;
    _appsSettingView.hidden = YES;
    _aboutUsView.hidden = YES;
    _synchronizeView.hidden = YES;
    _uvRcr.hidden = YES;
    _printerSettingview.hidden=YES;
    _paxDeviceSettingView.hidden = YES;
    _kitchenprinterSettingview.hidden=YES;
    
    self.webServiceConnectionSettingBG = [[RapidWebServiceConnection alloc] init];
    
   // self.rmsSettingSectionsArray = [[NSMutableArray alloc] initWithObjects:@(RmsSettingSection),@(RmsHardwareSettingSection),@(RmsOptionSection),@(RmsMiscellaneousSection), nil];
    self.rmsSettingSectionsArray = [[NSMutableArray alloc] initWithObjects:@(RmsSettingSection),@(RmsHardwareSettingSection),@(RmsOptionSection), nil];

    
    [self configureSlidingMenu];
    // Do any additional setup after loading the view from its nib.
   // [self loadGasPumpView];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
}

-(void)checkForOfflienRecords
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *offlineDataDisplayPredicate = [NSPredicate predicateWithFormat:@"isUpload == %@",@(FALSE)];
    fetchRequest.predicate = offlineDataDisplayPredicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count > 0)
    {
        _btnOfflineRecord.hidden=NO;
        NSString *strCount = [[NSString alloc]initWithFormat:@"      (%ld)",(unsigned long)resultSet.count];
        [_btnOfflineRecord setTitle:strCount forState:UIControlStateNormal];
        arrayOfflineRecords = [[NSMutableArray alloc]initWithArray:resultSet];
        self.isOfflieRecordFound = YES;
    }
    else
    {
        NSString *strCount = [NSString stringWithFormat:@"(%ld) Offline Records",(unsigned long)resultSet.count];
        [_btnOfflineRecord setTitle:strCount forState:UIControlStateNormal];
        _btnOfflineRecord.hidden = YES;
        self.isOfflieRecordFound = NO;
    }
}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}


- (void)configureParameters
{
    self.deactiveDevResult = [[NSMutableArray alloc] init];
    self.activeDevResult = [[NSMutableArray alloc] init];
    
    self.arrTempActive = [[NSMutableArray alloc] init];
    self.arrTempDeActive = [[NSMutableArray alloc] init];
    
    self.txtRegisterName.text = (self.rmsDbController.globalDict)[@"RegisterName"];
    
    NSMutableArray *activeDevice = [[NSMutableArray alloc]initWithArray:self.rmsDbController.appsActvDeactvSettingarray];
    
    strCOMCOD = activeDevice.firstObject[@"CompanyId"];
    
    int temp = 0;
    int temp2 = 1;
    
    // Inactive Table
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"IsActive == %d", temp];
    self.deactiveDevResult = [[activeDevice filteredArrayUsingPredicate:deactive] mutableCopy ];
    
    // Active Table
    NSPredicate *active = [NSPredicate predicateWithFormat:@"IsActive == %d", temp2];
    self.activeDevResult = [[activeDevice filteredArrayUsingPredicate:active] mutableCopy ];
    self.arrTempActive = [self.activeDevResult mutableCopy];
    
    [self.tblNotActivated reloadData];
    [self.tblActive reloadData];
    
    
    
    _uvButtonNavigation.layer.borderWidth = 1.0;
    _uvButtonNavigation.layer.borderColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0].CGColor;
    
    //    _uvNotActivatedApps.hidden = NO;
    _uvActiveApps.hidden = YES;
    _uvOthers.hidden = YES;
    
    [_btnNotActivated setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnNotActivated.backgroundColor = [UIColor whiteColor];
    
    [_btnActiveApp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnActiveApp.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    
    [_btnOthers setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnOthers.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
}

- (void) viewWillAppear:(BOOL)animated
{
    _lblDashBardTitle.text=@"";
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    [self checkForOfflienRecords];
    [self allocationOperationComponents];
    [self updateDateLabels];
}

//-(void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *dashboardVC = [storyBoard instantiateViewControllerWithIdentifier:@"RmsDashBoard"];
//}

- (void)updateDateLabels
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    self.lblCurrentDate.text = [formatter stringFromDate:date];
    self.lblSecondDate.text = [formatter stringFromDate:date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
    [_showCalendarSecond setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
    _showCalendarSecond.hidden = NO;
}

- (void)hideAllViews {
    _uvDispSubView.hidden = YES;
    _tenderView.hidden = YES;
    _customerDiplayView.hidden = YES;
    _appsSettingView.hidden = YES;
    _uvRcr.hidden = YES;
    _aboutUsView.hidden = YES;
    _synchronizeView.hidden = YES;
    _printerSettingview.hidden = YES;
    _paxDeviceSettingView.hidden = YES;
    _gasPumpView.hidden = YES;
    _viewOfflineRecord.hidden=YES;
    _uvRim.hidden = YES;
    _uvModuleShortCut.hidden=YES;
    _dashBoardIconView.hidden = YES;
    _kitchenprinterSettingview.hidden = YES;
}

- (void)deselctAllButtons {
    _btnApps.selected = NO;
    _btnProfile.selected = NO;
    _btnAboutUs.selected = NO;
    _btnToolTipSetup.selected = NO;
    _btnSound.selected = NO;
    _btnUpcScan.selected = NO;
    _btnCustDisp.selected = NO;
    _btnTenderConfig.selected = NO;
    _btnCashRegister.selected = NO;
    _btnSynchronize.selected = NO;
    _btnPrinterSetting.selected = NO;
    _btnKitchenPrinterSetting.selected = NO;
    _btnKitchenPrinterSetting.selected = NO;
    _btnGasPump.selected = NO;
    _btnOfflineRecord.selected=NO;
    _btnInventoryMgmt.selected = NO;
    _btnModuleSelection.selected=NO;
    _btnDashBoardIconSelection.selected = NO;
    _btnKitchenPrinterSetting.selected = NO;
    _btnPaxDeviceSetting.selected = NO;
}

-(IBAction)btnAppsClicked:(id)sender
{
    _lblDashBardTitle.text=@"";
    [self.rmsDbController playButtonSound];
    [self configureParameters];
    [self resetDashboardPartialView];
    
    [self hideAllViews];
    [self deselctAllButtons];
//    _btnApps.selected = YES;
    
    if(self.isUserAuthenticated)
    {
        [self.uvapps setHidden:NO];
    }
    else
    {
        _uvAuthentication.hidden = NO;
    }
    _uvDispSubView.hidden = YES;
    
    // Comment this below code for Old Activativation
    
    _uvAuthentication.hidden = YES;
    UserActivationViewController *objUser = [[UserActivationViewController alloc] initWithNibName:@"UserActivationViewController" bundle:nil];
    objUser.bFromDashborad=YES;
    
    [appDelegate.navigationController pushViewController:objUser animated:YES];
}

-(IBAction)btnToolTipClicked:(id)sender
{
    [self deselctAllButtons];
    _btnToolTipSetup.selected = YES;
}


-(IBAction)btnCashRegisterClicked:(id)sender
{
    _lblDashBardTitle.text=@"";
    [self.rmsDbController playButtonSound];
    [self configureParameters];
    [self menuOptionTapped:nil];
    
    [self hideAllViews];
    [self deselctAllButtons];
    
    _btnCashRegister.selected = YES;
    _uvRcr.hidden = NO;
    
    CashRegisterDisplayVC *cashRegVC=[[CashRegisterDisplayVC alloc]initWithNibName:@"CashRegisterDisplayVC" bundle:nil];
    deptFavSelectionNav=[[UINavigationController alloc]initWithRootViewController:cashRegVC];
    deptFavSelectionNav.view.frame = _customerDiplayView.bounds;
    cashRegVC.view.tag = 1212;
    [_uvRcr addSubview:deptFavSelectionNav.view];
    [self.view bringSubviewToFront:_uvRcr];
}

-(IBAction)btnInventoryMgmtClicked:(id)sender
{
    _lblDashBardTitle.text=@"";
    [self.rmsDbController playButtonSound];
    [self configureParameters];
    [self menuOptionTapped:nil];
    
    [self hideAllViews];
    [self deselctAllButtons];
    
    _btnInventoryMgmt.selected = YES;
    _uvRim.hidden = NO;
    
    [[self.view viewWithTag:1145] removeFromSuperview];
    
    rimSetting = [[InventoryManagementSetting alloc] initWithNibName:@"InventoryManagementSetting" bundle:nil];
    rimSetting.view.frame = CGRectMake(0, 0, _uvRim.frame.size.width, _uvRim.frame.size.height);
    rimSetting.view.tag = 1145;
    [_uvRim addSubview:rimSetting.view];
}

-(IBAction)btnModuleSelection:(id)sender
{
    _lblDashBardTitle.text=@"";
    [self.rmsDbController playButtonSound];
    [self configureParameters];
    [self menuOptionTapped:nil];
    
    [self hideAllViews];
    [self deselctAllButtons];
    
    _btnModuleSelection.selected = YES;
    _uvModuleShortCut.hidden = NO;
    
    [[self.view viewWithTag:1146] removeFromSuperview];
    
    moduleSelectionShortCut = [[ModuleSelectionShortCut alloc] initWithNibName:@"ModuleSelectionShortCut" bundle:nil];
    moduleSelectionShortCut.view.frame = CGRectMake(0, 0, _uvRim.frame.size.width, _uvRim.frame.size.height);
    moduleSelectionShortCut.view.tag = 1146;
    [_uvModuleShortCut addSubview:moduleSelectionShortCut.view];
}


-(IBAction)btnProfileClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    _uvAuthentication.hidden = YES;
    
    _btnSound.selected = NO;
    _btnUpcScan.selected = NO;
    _btnCustDisp.selected = NO;
    
    _aboutUsView.hidden = YES;
    
    _btnDoneApps.hidden = YES;
    _printerSettingview.hidden=YES;
    _paxDeviceSettingView.hidden = YES;
    _btnPrinterSetting.selected=NO;
    _btnKitchenPrinterSetting.selected = NO;
}

-(IBAction)btnAboutUsClicked:(id)sender
{
    _lblDashBardTitle.text=@"About Us";
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    
    [self deselctAllButtons];
    [self hideAllViews];
    _btnAboutUs.selected = YES;
    _aboutUsView.hidden = NO;
    
    [[self.view viewWithTag:1135] removeFromSuperview];
    
    objInfoSetting = [[AboutViewController alloc] initWithNibName:@"AboutViewController_iPad" bundle:nil];
    objInfoSetting.view.frame = CGRectMake(0, 0,objInfoSetting.view.frame.size.width, objInfoSetting.view.frame.size.height);
    objSettingSound.view.tag = 1135;
    [_aboutUsView addSubview:objInfoSetting.view];
}

-(IBAction)btnSoundClicked:(id)sender;
{
    _lblDashBardTitle.text=@"Touch Sound";
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    
    [self deselctAllButtons];
    [self hideAllViews];
    _btnSound.selected = YES;
    _uvDispSubView.hidden = NO;
    
    [[self.view viewWithTag:1136] removeFromSuperview];
    
    objSettingSound = [[SettingSoundVC alloc] initWithNibName:@"SettingSoundVC" bundle:nil];
    objSettingSound.view.frame = CGRectMake(0, 0,objSettingSound.view.frame.size.width, objSettingSound.view.frame.size.height);
    objSettingSound.view.tag = 1136 ;
    [_uvDispSubView addSubview:objSettingSound.view];
}

-(IBAction)btnUpcScannerClicked:(id)sender
{
    _lblDashBardTitle.text=@"Setting";
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    
    [self deselctAllButtons];
    [self hideAllViews];
    _btnUpcScan.selected = YES;
    _uvDispSubView.hidden = NO;
    
    [[self.view viewWithTag:1137] removeFromSuperview];
    
    objScannerSet = [[ScannerSettingVC alloc] initWithNibName:@"ScannerSettingVC" bundle:nil];
    objScannerSet.view.frame = CGRectMake(0, 0,objScannerSet.view.frame.size.width, objScannerSet.view.frame.size.height);
    objScannerSet.view.tag = 1137 ;
    [_uvDispSubView addSubview:objScannerSet.view];
}
-(IBAction)btnDeptFavClicked:(id)sender
{
    
    
}
-(IBAction)btnCustomerDispClicked:(id)sender
{
    _lblDashBardTitle.text=@"";
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    
    [self deselctAllButtons];
    [self hideAllViews];
    _btnCustDisp.selected = YES;
    
    //  [[self.view viewWithTag:1138] removeFromSuperview];
    if(customerDisplayNav==nil)
    {
        custDispvc=[[CustomerDisplayBrowserVC alloc]initWithNibName:@"CustomerDisplayBrowserVC" bundle:nil];
        customerDisplayNav=[[UINavigationController alloc]initWithRootViewController:custDispvc];
        customerDisplayNav.view.frame = _customerDiplayView.bounds;
        custDispvc.view.tag = 1138;
        custDispvc.dashCustomer = self;
        [_customerDiplayView addSubview:customerDisplayNav.view];
    }
    _customerDiplayView.hidden = NO;
    _synchronizeView.hidden = YES;
    _btnSynchronize.selected = NO;
    
    [self.view bringSubviewToFront:_customerDiplayView];
}

-(IBAction)btnDashBoardIconSelection:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    
    [self deselctAllButtons];
    [self hideAllViews];
    _btnDashBoardIconSelection.selected = YES;
    
    [[self.view viewWithTag:20150302] removeFromSuperview];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    dashBoardIconSelectionVC = [storyBoard instantiateViewControllerWithIdentifier:@"DashBoardIconSelectionVC"];
    dashBoardIconSelectionVC.view.tag = 20150302;
    dashBoardIconSelectionVC.view.frame = _dashBoardIconView.bounds;
    [_dashBoardIconView addSubview:dashBoardIconSelectionVC.view];
    dashBoardIconSelectionVC.OperationBtnView.hidden = YES;
    dashBoardIconSelectionVC.view.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    dashBoardIconSelectionVC.view.opaque = NO;
    
    CGRect tableFrame = dashBoardIconSelectionVC.iconSelectionTableView.frame;
    tableFrame.origin.y = 54.0;
    tableFrame.size.height = 400.0;
    dashBoardIconSelectionVC.iconSelectionTableView.frame = tableFrame;
    
    _dashBoardIconView.hidden = NO;
    [self.view bringSubviewToFront:_dashBoardIconView];
}

-(IBAction)btnTenderConfigClicked:(id)sender
{
    for(id view in _tenderView.subviews){
        [view removeFromSuperview];
    }
    _lblDashBardTitle.text = @"";
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    
    [self deselctAllButtons];
    [self hideAllViews];
    _btnTenderConfig.selected = YES;
    [[self.view viewWithTag:1139] removeFromSuperview];
    
    objTenderConfig = [[TenderConfigurationViewController alloc] initWithNibName:@"TenderConfigurationViewController" bundle:nil];
    objTenderConfig.view.tag = 1139;
    tenderSettingsNav = [[UINavigationController alloc]initWithRootViewController:objTenderConfig];
    objTenderConfig.dashBoard=self;
    tenderSettingsNav.view.frame = _tenderView.bounds;
    [_tenderView addSubview:tenderSettingsNav.view];
    
    _tenderView.hidden = NO;
    [self.view bringSubviewToFront:_tenderView];
}

-(IBAction)btnNotActivatedClicked:(id)sender
{
    //    _uvNotActivatedApps.hidden = NO;
    _uvActiveApps.hidden = YES;
    _uvOthers.hidden = YES;
    
    [_btnNotActivated setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnNotActivated.backgroundColor = [UIColor whiteColor];
    
    [_btnActiveApp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnActiveApp.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    
    [_btnOthers setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnOthers.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    
    [self goToAvailableAppsMenu];
    [self.tblNotActivated reloadData];
}

-(IBAction)btnActiveClicked:(id)sender
{
    _uvNotActivatedApps.hidden = YES;
    _uvActiveApps.hidden = NO;
    _uvOthers.hidden = YES;
    
    [_btnActiveApp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnActiveApp.backgroundColor = [UIColor whiteColor];
    
    [_btnNotActivated setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnNotActivated.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    
    [_btnOthers setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnOthers.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    
    [self.tblActive reloadData];
}

-(IBAction)btnOthersClicked:(id)sender
{
    _uvNotActivatedApps.hidden = YES;
    _uvActiveApps.hidden = YES;
    _uvOthers.hidden = NO;
    
    [_btnOthers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnOthers.backgroundColor = [UIColor whiteColor];
    
    [_btnActiveApp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnActiveApp.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    
    [_btnNotActivated setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnNotActivated.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
}

-(IBAction)btnSynchronizeClicked:(id)sender
{
    _lblDashBardTitle.text=@"Synchronize";
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    [self deselctAllButtons];
    [self hideAllViews];
    _btnSynchronize.selected = YES;
    _synchronizeView.hidden = NO;
    
    [[self.view viewWithTag:1140] removeFromSuperview];
    
    synchronizeVC = [[SynchronizeViewController alloc] initWithNibName:@"SynchronizeViewController_iPad" bundle:nil];
    synchronizeVC.view.frame = CGRectMake(0, 0, _synchronizeView.frame.size.width, _synchronizeView.frame.size.height);
    synchronizeVC.view.tag = 1140;
    [_synchronizeView addSubview:synchronizeVC.view];
}


//hiten

-(IBAction)btnPrinterSettingClicked:(id)sender
{
    _lblDashBardTitle.text=@"PrinterSetting";
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    
    
    [self deselctAllButtons];
    [self hideAllViews];
    _printerSettingview.hidden=NO;
    _btnPrinterSetting.selected=YES;
    
    [[self.view viewWithTag:1900] removeFromSuperview];
    
    printerSettingVC =[[PrinterSettingViewController alloc]initWithNibName:@"PrinterSettingViewController" bundle:nil];
    printerSettingNav=[[UINavigationController alloc]initWithRootViewController:printerSettingVC];
    printerSettingNav.view.frame = _printerSettingview.bounds;
    kitchenprinterSettingVC.view.tag = 1900;
    [_printerSettingview addSubview:printerSettingNav.view];
    [self.view bringSubviewToFront:_printerSettingview];
}

-(IBAction)btnPaxDeviceSettingClick:(id)sender
{
    _lblDashBardTitle.text=@"Pax Device";
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    [self deselctAllButtons];
    [self hideAllViews];
    _btnPaxDeviceSetting.selected = YES;
    _paxDeviceSettingView.hidden = NO;
    
    [[self.view viewWithTag:1901] removeFromSuperview];
    
    paxDeviceVC =[[PaxDeviceViewController alloc]initWithNibName:@"PaxDeviceViewController" bundle:nil];
    paxDeviceSettingNav=[[UINavigationController alloc]initWithRootViewController:paxDeviceVC];
    paxDeviceSettingNav.view.frame = _paxDeviceSettingView.bounds;
    kitchenprinterSettingVC.view.tag = 1901;
    [_paxDeviceSettingView addSubview:paxDeviceSettingNav.view];
    [self.view bringSubviewToFront:_paxDeviceSettingView];

}
// Kitchen Printing Setting

-(IBAction)btnKitchenPrinterSettingClicked:(id)sender
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Department" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSInteger resultSet = [UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if(resultSet > 0)
    {
        _lblDashBardTitle.text=@"Kitchen Printer Setting";
        [self.rmsDbController playButtonSound];
        [self menuOptionTapped:nil];
        
        [self deselctAllButtons];
        [self hideAllViews];
        _kitchenprinterSettingview.hidden=NO;
        _btnKitchenPrinterSetting.selected=YES;
        
        [[self.view viewWithTag:1950] removeFromSuperview];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        kitchenprinterSettingVC = [storyBoard instantiateViewControllerWithIdentifier:@"KitchenPrinterVC"];
        
        kitchenprinterSettingNav=[[UINavigationController alloc]initWithRootViewController:kitchenprinterSettingVC];
        kitchenprinterSettingNav.view.frame = _kitchenprinterSettingview.bounds;
        kitchenprinterSettingVC.view.tag = 1950;
        [_kitchenprinterSettingview addSubview:kitchenprinterSettingNav.view];
        [self.view bringSubviewToFront:_kitchenprinterSettingview];
        
    }
    else{
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Application configuration failed, please restart the applicaion or wait for few seconds" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];

    }

}

- (IBAction)btnGasPumpClicked:(id)sender {
    _lblDashBardTitle.text=@"Gas Pump";
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    [self deselctAllButtons];
    [self hideAllViews];
    
    _gasPumpView.hidden = NO;
    _btnGasPump.selected = YES;
    
    [[self.view viewWithTag:1257] removeFromSuperview];
    [gasPumpSettingNav removeFromParentViewController];
}

-(IBAction)showOfflienRecords:(id)sender{
    
    _lblDashBardTitle.text=@"Offline Record";
    [self.rmsDbController playButtonSound];
    [self menuOptionTapped:nil];
    [self deselctAllButtons];
    [self hideAllViews];
    _btnOfflineRecord.selected = YES;
    _viewOfflineRecord.hidden = NO;
    
    [[self.view viewWithTag:1150] removeFromSuperview];
    
    objofflineRecord = [[OfflineRecordVC alloc] initWithNibName:@"OfflineRecordVC" bundle:nil];
    objofflineRecord.view.frame = CGRectMake(0, 0, _viewOfflineRecord.frame.size.width, _viewOfflineRecord.frame.size.height);
    objofflineRecord.view.tag = 1150;
    [_viewOfflineRecord addSubview:objofflineRecord.view];
}

//
#pragma mark -
#pragma mark TextFiled Delegate method

//call when press return key in keyboard.
- (BOOL) textFieldShouldReturn:(UITextField *)textFiled {
    [textFiled resignFirstResponder];
    return YES;
}

-(void)allocationOperationComponents
{
    CGRect buttonFrame = CGRectMake(0,0, 313, 55);
    if(_btnAboutUs != nil)
    {
        return;
    }
    // section 0
    _btnAboutUs = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnAboutUs setImage:[UIImage imageNamed:@"About.png"] forState:UIControlStateNormal ];
    [_btnAboutUs setImage:[UIImage imageNamed:@"Aboutactive.png"] forState:UIControlStateSelected ];
    
    _btnApps = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnApps setImage:[UIImage imageNamed:@"appsNormal.png"] forState:UIControlStateNormal ];
    [_btnApps setImage:[UIImage imageNamed:@"appsActive.png"] forState:UIControlStateSelected ];
    
    _btnSound = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnSound setImage:[UIImage imageNamed:@"ToucSound.png"] forState:UIControlStateNormal ];
    [_btnSound setImage:[UIImage imageNamed:@"ToucSoundActive.png"] forState:UIControlStateSelected ];
    
    _btnToolTipSetup = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnToolTipSetup setImage:[UIImage imageNamed:@"TooltipSetup.png"] forState:UIControlStateNormal ];
    [_btnToolTipSetup setImage:[UIImage imageNamed:@"TooltipSetupSelected.png"] forState:UIControlStateSelected ];
    // section 1
    _btnUpcScan = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnUpcScan setImage:[UIImage imageNamed:@"UPCScanner.png"] forState:UIControlStateNormal ];
    [_btnUpcScan setImage:[UIImage imageNamed:@"UPCScannerActive.png"] forState:UIControlStateSelected ];
    
    _btnCustDisp = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnCustDisp setImage:[UIImage imageNamed:@"customerDisplay.png"] forState:UIControlStateNormal ];
    [_btnCustDisp setImage:[UIImage imageNamed:@"customerDisplayActive.png"] forState:UIControlStateSelected ];
    
    _btnTenderConfig = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnTenderConfig setImage:[UIImage imageNamed:@"TenderConfigration.png"] forState:UIControlStateNormal ];
    [_btnTenderConfig setImage:[UIImage imageNamed:@"TenderConfigrationActive.png"] forState:UIControlStateSelected ];
    
    _btnDashBoardIconSelection = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnDashBoardIconSelection setImage:[UIImage imageNamed:@"Dashboard_ipad.png"] forState:UIControlStateNormal ];
    [_btnDashBoardIconSelection setImage:[UIImage imageNamed:@"dashboard_active_ipad.png"] forState:UIControlStateSelected ];
    
    // section 2
    _btnCashRegister = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnCashRegister setImage:[UIImage imageNamed:@"OptionMenu_ipad.png"] forState:UIControlStateNormal ];
    [_btnCashRegister setImage:[UIImage imageNamed:@"OptionMenuActive_ipad.png"] forState:UIControlStateSelected ];
    
    _btnInventoryMgmt = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnInventoryMgmt setTitle:@"Inventory Management" forState:UIControlStateNormal];
    [_btnInventoryMgmt setTitle:@"Inventory Management" forState:UIControlStateSelected];
    [_btnInventoryMgmt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnInventoryMgmt setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_btnInventoryMgmt setBackgroundImage:nil forState:UIControlStateNormal ];
    [_btnInventoryMgmt setBackgroundImage:[UIImage imageNamed:@"globalgreen.png"] forState:UIControlStateSelected ];
    
    // for  Module Selection Short Cut button
    _btnModuleSelection = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnModuleSelection setTitle:@"Module Shortcut" forState:UIControlStateNormal];
    [_btnModuleSelection setTitle:@"Module Shortcut" forState:UIControlStateSelected];
    [_btnModuleSelection setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnModuleSelection setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_btnModuleSelection setBackgroundImage:nil forState:UIControlStateNormal ];
    [_btnModuleSelection setBackgroundImage:[UIImage imageNamed:@"globalgreen.png"] forState:UIControlStateSelected ];
    
    // secion 3
    _btnOfflineRecord = [[UIButton alloc] initWithFrame:buttonFrame];
 //   [_btnOfflineRecord setTitle:@"Offline Record" forState:UIControlStateNormal];
  //  [_btnOfflineRecord setTitle:@"Offline Record" forState:UIControlStateSelected];
  //  [_btnOfflineRecord setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
 //   [_btnOfflineRecord setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [_btnOfflineRecord setBackgroundImage:[UIImage imageNamed:@"offlinerecord.png"] forState:UIControlStateNormal ];
    [_btnOfflineRecord setBackgroundImage:[UIImage imageNamed:@"offlinerecordselected.png"] forState:UIControlStateSelected ];
    
    _btnSynchronize = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnSynchronize setImage:[UIImage imageNamed:@"SyncSetting.png"] forState:UIControlStateNormal ];
    [_btnSynchronize setImage:[UIImage imageNamed:@"SyncSettingActive.png"] forState:UIControlStateSelected ];
    
    _btnPrinterSetting = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnPrinterSetting setImage:[UIImage imageNamed:@"PrinterSetting.png"] forState:UIControlStateNormal ];
    [_btnPrinterSetting setImage:[UIImage imageNamed:@"PrinterSettingActive.png"] forState:UIControlStateSelected ];
    
    _btnPaxDeviceSetting = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnPaxDeviceSetting setImage:[UIImage imageNamed:@"PaxDevice_ipad.png"] forState:UIControlStateNormal ];
    [_btnPaxDeviceSetting setImage:[UIImage imageNamed:@"PaxDeviceActive_ipad.png"] forState:UIControlStateSelected ];
    
    _btnGasPump = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnGasPump setImage:[UIImage imageNamed:@"GasPumpSetting.png"] forState:UIControlStateNormal ];
    [_btnGasPump setImage:[UIImage imageNamed:@"GasPumpSettingActive.png"] forState:UIControlStateSelected ];
    
    _btnKitchenPrinterSetting = [[UIButton alloc] initWithFrame:buttonFrame];
    [_btnKitchenPrinterSetting setImage:[UIImage imageNamed:@"Kitchen_Printer.png"] forState:UIControlStateNormal ];
    [_btnKitchenPrinterSetting setImage:[UIImage imageNamed:@"Kitchen_Printer_Active.png"] forState:UIControlStateSelected ];
}

#pragma mark - UITableView Delegate method

-(void)fieldAllocation
{
    _imgBackGround = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 70, 60)];
    _lblModuleName = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 250, 25)];
    _lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(500, 20, 100, 25)];
    _btnChecked = [[UIButton alloc] initWithFrame:CGRectMake(625, 20, 28, 23)];
    _lblActiveDeviceName=[[UILabel alloc]initWithFrame:CGRectMake(100, 45, 200, 25)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSection;
    if(self.tblSettingSideMenu)
    {
        numberOfSection = self.rmsSettingSectionsArray.count;
    }
    else
    {
        numberOfSection = 1;
    }
    return numberOfSection;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 40;
    return height;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * sectionHeader = [[UILabel alloc] initWithFrame: CGRectMake(10, 5, 313, 15)];
    sectionHeader.textColor = [UIColor colorWithRed:239.0/255 green:140.0/255 blue:41.0/255 alpha:1.0];
    sectionHeader.font = [UIFont fontWithName:@"Lato-Regular" size:16];
    
    RmsSettingPageSection nameOfSection = [self.rmsSettingSectionsArray[section] integerValue ];
    switch (nameOfSection)
    {
        case RmsSettingSection:
            sectionHeader.text = @"    STARTUP";
            break;
            
        case RmsHardwareSettingSection:
             sectionHeader.text = @"    HARDWARE SETTINGS";
            break;
            
        case RmsOptionSection:
            sectionHeader.text = @"    RAPID SETTINGS";
            break;
            
//        case RmsMiscellaneousSection:
//            headerTitle = @" ";
//            break;
            
        default:
            break;
    }
    
    UIImageView *imgBG = [[UIImageView alloc]initWithFrame:CGRectMake(27, sectionHeader.frame.size.height+15, 290, 1)];
    imgBG.backgroundColor = [UIColor colorWithRed:42.0/255 green:46.0/255 blue:56.0/255 alpha:1.0];
   UIView *view = [[UIView alloc]init];
    [view addSubview:imgBG];
    [view addSubview:sectionHeader];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblNotActivated)
    {
        return self.deactiveDevResult.count;
    }
    if(tableView == self.tblActive)
    {
        return self.activeDevResult.count;
    }
    if(tableView == self.tblSettingSideMenu)
    {
        RmsSettingPageSection nameOfSection = [self.rmsSettingSectionsArray[section] integerValue ];
        switch (nameOfSection) {
            case RmsSettingSection:
                return self.settingArray.count;
                break;
                
            case RmsHardwareSettingSection:
                return self.hardwareSettingArray.count;
                break;
                
            case RmsOptionSection:
                return self.optionArray.count;
                break;
                
//            case RmsMiscellaneousSection:
//                return [self.miscellaneousArray count];
//                break;
                
            default:
                break;
        }
    }
    return 1;
}

- (void)configureSettingSection:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    RmsSettingSectionPages typeOfRow = [(self.settingArray)[indexPath.row] integerValue ];
    switch (typeOfRow) {
        case SettingAboutUs:
            [_btnAboutUs addTarget:self action:@selector(btnAboutUsClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnAboutUs];
            break;
            
        case SettingApps:
            [_btnApps addTarget:self action:@selector(btnAppsClicked:) forControlEvents:UIControlEventTouchUpInside];
            if ([[self.rmsDbController.globalDict valueForKey:@"IsSignUpForTrial"]integerValue] == 1) {
                _btnApps.enabled = NO;
            }
            else
            {
                _btnApps.enabled = YES;
            }
            [cell addSubview:_btnApps];
            break;
            
        case SettingToolTipSetUp:
            [_btnToolTipSetup addTarget:self action:@selector(btnToolTipClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnToolTipSetup];
            break;
            
        default:
            break;
    }
}

- (void)configureHardwareSettingSection:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    RmsHardwareSettingSectionPages typeOfRow = [(self.hardwareSettingArray)[indexPath.row] integerValue ];
    switch (typeOfRow)
    {
        case HardwareUPCScanner:
            [_btnUpcScan addTarget:self action:@selector(btnUpcScannerClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnUpcScan];
            break;
            
        case HardwareTenderConfiguration:
            [_btnTenderConfig addTarget:self action:@selector(btnTenderConfigClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnTenderConfig];
            break;
            
        case HardwareCustomerDisplay:
            [_btnCustDisp addTarget:self action:@selector(btnCustomerDispClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnCustDisp];
            break;
            
            
        case HardwarePrinter:
            [_btnPrinterSetting addTarget:self action:@selector(btnPrinterSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnPrinterSetting];
            break;
        case HardwareSound:
            [_btnSound addTarget:self action:@selector(btnSoundClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnSound];
            break;
            
        case HardwareKitchenPrinter:
            [_btnKitchenPrinterSetting addTarget:self action:@selector(btnKitchenPrinterSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnKitchenPrinterSetting];
            break;
        case HardwareOfflineRecord:
            [_btnOfflineRecord addTarget:self action:@selector(showOfflienRecords:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnOfflineRecord];
            break;
            
        case HardwareGasPump:
            [_btnGasPump addTarget:self action:@selector(btnGasPumpClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnGasPump];
            break;

        case HardwarePaxDeviceSetting:
            [_btnPaxDeviceSetting addTarget:self action:@selector(btnPaxDeviceSettingClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnPaxDeviceSetting];
            break;
 
        default:
            break;
    }
}

- (void)configureOptionSection:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    RmsOptionSectionPages typeOfRow = [(self.optionArray)[indexPath.row] integerValue ];
    switch (typeOfRow)
    {
        case RCRSettingDashBoard:
            [_btnDashBoardIconSelection addTarget:self action:@selector(btnDashBoardIconSelection:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnDashBoardIconSelection];
            break;
            
        case RCRSettingSynchronize:
            [_btnSynchronize addTarget:self action:@selector(btnSynchronizeClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:_btnSynchronize];
                break;

        case RCRSettingOption:
            [_btnCashRegister addTarget:self action:@selector(btnCashRegisterClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_btnCashRegister];
            break;
            
        default:
            break;
    }
}

- (void)configureMiscellaneousSection:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:7.0/255.0 green:14.0/255.0 blue:28.0/255.0 alpha:1.0];
    
    if (tableView == self.tblNotActivated)
    {
        [self fieldAllocation];
        
        AsyncImageView* oldImage = (AsyncImageView *)
        [cell.contentView viewWithTag:999];
        [oldImage removeFromSuperview];
        
        _imgBackGround.image = [UIImage imageNamed:@"activeDeviceImg.png"];
        [cell.contentView addSubview:_imgBackGround];
        
        AsyncImageView* itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 68, 58)];
        itemImage.tag = 999;
        itemImage.backgroundColor = [UIColor clearColor];
        itemImage.image = [UIImage imageNamed:@"noimage.png"];
        [cell.contentView addSubview:itemImage];
        
        _lblModuleName.text = [NSString stringWithFormat:@"%@",[(self.deactiveDevResult)[indexPath.row] valueForKey:@"Name"] ];
        [cell.contentView addSubview:_lblModuleName];
        
        if([[(self.deactiveDevResult)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
        {
            _lblStatus.text = @"Not Active";
            _lblStatus.textColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        }
        else
        {
            _lblStatus.text = @"Active";
            _lblStatus.textColor = [UIColor colorWithRed:43.0/255.0 green:192.0/255.0 blue:142.0/255.0 alpha:1.0];
            
            [_btnChecked setImage:[UIImage imageNamed:@"DeviceActiveArrow.png"] forState:UIControlStateNormal];
            [cell.contentView addSubview:_btnChecked];
        }
        [cell.contentView addSubview:_lblStatus];
        
    }
    if (tableView == self.tblActive)
    {
        [self fieldAllocation];
        
        AsyncImageView* oldImage = (AsyncImageView *)
        [cell.contentView viewWithTag:999];
        [oldImage removeFromSuperview];
        
        _imgBackGround.image = [UIImage imageNamed:@"activeDeviceImg.png"];
        [cell.contentView addSubview:_imgBackGround];
        
        AsyncImageView* itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 68, 58)];
        itemImage.tag = 999;
        itemImage.backgroundColor = [UIColor clearColor];
        itemImage.image = [UIImage imageNamed:@"noimage.png"];
        [cell.contentView addSubview:itemImage];
        
        _lblModuleName.text = [NSString stringWithFormat:@"%@",[(self.activeDevResult)[indexPath.row] valueForKey:@"Name"]];
        [cell.contentView addSubview:_lblModuleName];
        
        _lblActiveDeviceName.text = [NSString stringWithFormat:@"%@",[(self.activeDevResult)[indexPath.row] valueForKey:@"RegisterName"]];
        _lblActiveDeviceName.textColor = [UIColor grayColor];
        
        [cell.contentView addSubview:_lblActiveDeviceName];
        
        if([[(self.activeDevResult)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
        {
            _lblStatus.text = @"Not Active";
            _lblStatus.textColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        }
        else
        {
            _lblStatus.text = @"Active";
            _lblStatus.textColor = [UIColor colorWithRed:43.0/255.0 green:192.0/255.0 blue:142.0/255.0 alpha:1.0];
            
            [_btnChecked setImage:[UIImage imageNamed:@"DeviceActiveArrow.png"] forState:UIControlStateNormal];
            [cell.contentView addSubview:_btnChecked];
        }
        [cell.contentView addSubview:_lblStatus];
        
    }
    if(tableView == self.tblSettingSideMenu)
    {
        cell.backgroundColor = [UIColor colorWithRed:7.0/255.0 green:14.0/255.0 blue:28.0/255.0 alpha:1.0];
        RmsSettingPageSection nameOfSection = [self.rmsSettingSectionsArray[indexPath.section] integerValue ];
        switch (nameOfSection) {
            case RmsSettingSection:
                [self configureSettingSection:cell indexPath:indexPath];
                break;
            case RmsHardwareSettingSection:
                [self configureHardwareSettingSection:cell indexPath:indexPath];
                break;
                
            case RmsOptionSection:
                [self configureOptionSection:cell indexPath:indexPath];
                break;
                
//            case RmsMiscellaneousSection:
//                [self configureMiscellaneousSection:cell indexPath:indexPath];
//                break;
                
            default:
                break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isChangesDone = YES;
    if (tableView == self.tblNotActivated)
    {
        NSMutableDictionary *dictSelected = (self.deactiveDevResult)[indexPath.row];
        
        if([[dictSelected valueForKey:@"IsActive"] integerValue ] == 0 )
        {
            clickedIndexpath = [indexPath copy];
            
            NSInteger temp = [[dictSelected valueForKey:@"ModuleId"] integerValue ];
            NSPredicate *deactive = [NSPredicate predicateWithFormat:@"ModuleId == %d", temp];
            NSMutableArray *resultArray = [[self.arrTempActive filteredArrayUsingPredicate:deactive] mutableCopy ];
            
            if(resultArray.count > 0)
            {
                //NSString *tmpMac = @"DB6D900D-9E9F-41E2-84EE-C3AB99D4479B";
                NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
                //NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", tmpMac];
                NSMutableArray *isFoundArray = [[resultArray filteredArrayUsingPredicate:deactive] mutableCopy ];
                
                if(isFoundArray.count > 0)
                {
                    UIAlertView *notAllow = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Module is Already Active." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [notAllow show];
                }
                else
                {
                    UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Are you sure you want to Active this Package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                    reqPer.tag = 1;
                    [reqPer show];
                    //[dictSelected setObject:@"1" forKey:@"IsActive"];
                }
            }
            else
            {
                UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Are you sure you want to Active this Package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                reqPer.tag = 1;
                [reqPer show];
            }
        }
        else
        {
            dictSelected[@"IsActive"] = @"0";
            
            for (int i = 0 ; i < self.arrTempActive.count ; i++)
            {
                NSMutableDictionary *dict = [(self.arrTempActive)[i] mutableCopy ];
                if([[dict valueForKey:@"Id" ] integerValue ] == [[dictSelected valueForKey:@"Id"] integerValue])
                {
                    [self.arrTempActive removeObjectAtIndex:i];
                }
            }
        }
        (self.deactiveDevResult)[indexPath.row] = dictSelected;
        [self.tblNotActivated reloadData];
    }
    else if (tableView == self.tblActive)
    {
        NSMutableDictionary *dictTemp = (self.activeDevResult)[indexPath.row];
        if([[dictTemp valueForKey:@"IsActive"] integerValue ] == 0 )
        {
            dictTemp[@"IsActive"] = @"1";
            
            for (int i = 0 ; i < self.arrTempDeActive.count ; i++)
            {
                NSMutableDictionary *dict = [(self.arrTempDeActive)[i] mutableCopy ];
                if([[dict valueForKey:@"Id" ] integerValue ] == [[dictTemp valueForKey:@"Id"] integerValue])
                {
                    [self.arrTempDeActive removeObjectAtIndex:i];
                }
            }
        }
        else
        {
            clickedIndexpath = [indexPath copy];
            UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Are you sure you want to Deactive this Package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
            reqPer.tag = 2;
            [reqPer show];
            // [dictTemp setObject:@"0" forKey:@"IsActive"];
        }
        (self.activeDevResult)[indexPath.row] = dictTemp;
        [self.tblActive reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow;
    if(tableView == self.tblSettingSideMenu)
    {
        heightForRow = 55;
    }
    else
    {
        heightForRow = 75;
    }
    return heightForRow;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1) // To active Module in inactive table
    {
        if(buttonIndex == 1)
        {
            NSMutableDictionary *dictSelected = (self.deactiveDevResult)[clickedIndexpath.row];
            dictSelected[@"IsActive"] = @"1";
            dictSelected[@"MacAdd"] = (self.rmsDbController.globalDict)[@"DeviceId"];
            [self.arrTempActive addObject:dictSelected];
            (self.deactiveDevResult)[clickedIndexpath.row] = dictSelected;
            [self.tblNotActivated reloadData];
        }
        else
        {
            [self.tblNotActivated reloadData];
        }
    }
    else if(alertView.tag == 2) // To Deactive module in Active table
    {
        if(buttonIndex == 1)
        {
            NSMutableDictionary *dictSelected = (self.activeDevResult)[clickedIndexpath.row];
            dictSelected[@"IsActive"] = @"0";
            (self.activeDevResult)[clickedIndexpath.row] = dictSelected;
            [self.arrTempDeActive addObject:dictSelected];
            [self.tblActive reloadData];
        }
        else
        {
            [self.tblNotActivated reloadData];
        }
    }
    else if (alertView.tag == 3)
    {
        UserActivationViewController *objUser = [[UserActivationViewController alloc] initWithNibName:@"UserActivationViewController" bundle:nil];
        [self.navigationController pushViewController:objUser animated:YES];
    }
    else if (alertView.tag == 4)
    {
        if (buttonIndex == 1) // Yes Button Clicked
        {
            [self modulesActiveDeActive];
        }
    }
}

-(void)modulesActiveDeActive
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * dictDeviceActivation = [[NSMutableDictionary alloc] init];
    dictDeviceActivation[@"BranchId"] = @"1";
    dictDeviceActivation[@"COMCOD"] = strCOMCOD;
    dictDeviceActivation[@"RegisterName"] = self.txtRegisterName.text;
    dictDeviceActivation[@"MacAdd"] = (self.rmsDbController.globalDict)[@"DeviceId"];
    dictDeviceActivation[@"dType"] = @"IOS-RCRIpad";
    dictDeviceActivation[@"dVersion"] = [UIDevice currentDevice].systemVersion;
    dictDeviceActivation[@"TokenId"] = (self.rmsDbController.globalDict)[@"TokenId"];
    dictDeviceActivation[@"ApplicationType"] = @"";
    dictDeviceActivation[@"DeactiveDeviceInfo"] = [self getDeactiveDeviceData];
    dictDeviceActivation[@"activeDeviceInfo"] = [self getactiveDeviceData];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self settingDeviceSetupResponse:response error:error];
    };
    
    self.deviceSetupWC = [self.deviceSetupWC initWithRequest:KURL actionName:WSM_DEVICE_SETUP params:dictDeviceActivation completionHandler:completionHandler];
}

-(IBAction)btnExitClicked:(id)sender
{
    if(!self.isChangesDone)
    {
        [self secondMenuTapped:nil];
    }
    else
    {
        for (int i = 0 ; i < self.activeDevResult.count ; i++)
        {
            NSMutableDictionary *dict = [(self.activeDevResult)[i] mutableCopy ];
            
            for (int isfnd = 0 ; isfnd < self.arrTempActive.count ; isfnd++)
            {
                NSMutableDictionary *dictActive = [(self.arrTempActive)[isfnd] mutableCopy ];
                if([[dict valueForKey:@"Id" ] integerValue ] == [[dictActive valueForKey:@"Id"] integerValue])
                {
                    [self.arrTempActive removeObjectAtIndex:isfnd];
                }
            }
        }
        NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
        NSMutableArray *activeModulesArray = [[self.arrTempDeActive filteredArrayUsingPredicate:deactive] mutableCopy ];
        NSArray * uniqueArray = [self.activeDevResult valueForKeyPath:@"@distinctUnionOfObjects.ModuleId"];
        if(activeModulesArray.count == uniqueArray.count)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Do you want to delete all modules from this Device?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
            alert.tag = 4;
            [alert show];
        }
        else
        {
            [self modulesActiveDeActive];
        }
    }
}

- (NSMutableArray *) getDeactiveDeviceData
{
    NSMutableArray *arrDeActiveDeviceInfo = [[NSMutableArray alloc] init];
    
    if(self.arrTempDeActive.count>0)
    {
        for (int isup=0; isup < self.arrTempDeActive.count; isup++) {
            NSMutableDictionary *tmpSup=[(self.arrTempDeActive)[isup] mutableCopy ];
            // Id, IsActive, ModuleId
            [tmpSup removeObjectForKey:@"CompanyId"];
            [tmpSup removeObjectForKey:@"DBName"];
            [tmpSup removeObjectForKey:@"MacAdd"];
            [tmpSup removeObjectForKey:@"ModuleCode"];
            [tmpSup removeObjectForKey:@"ModuleType"];
            [tmpSup removeObjectForKey:@"Name"];
            [tmpSup removeObjectForKey:@"RegisterName"];
            [tmpSup removeObjectForKey:@"RegisterNo"];
            [tmpSup removeObjectForKey:@"TokenId"];
            
            [arrDeActiveDeviceInfo addObject:tmpSup];
        }
    }
    return arrDeActiveDeviceInfo;
}

- (NSMutableArray *) getactiveDeviceData
{
    NSMutableArray *arrActiveDevice = [[NSMutableArray alloc] init];
    
    if(self.arrTempActive.count>0)
    {
        for (int isup=0; isup < self.arrTempActive.count; isup++) {
            NSMutableDictionary *tmpSup=[(self.arrTempActive)[isup] mutableCopy ];
            
            // Id, IsActive, ModuleId
            [tmpSup removeObjectForKey:@"CompanyId"];
            [tmpSup removeObjectForKey:@"DBName"];
            [tmpSup removeObjectForKey:@"MacAdd"];
            [tmpSup removeObjectForKey:@"ModuleCode"];
            [tmpSup removeObjectForKey:@"ModuleType"];
            [tmpSup removeObjectForKey:@"Name"];
            [tmpSup removeObjectForKey:@"RegisterName"];
            [tmpSup removeObjectForKey:@"RegisterNo"];
            [tmpSup removeObjectForKey:@"TokenId"];
            [arrActiveDevice addObject:tmpSup];
        }
    }
    return arrActiveDevice;
}

- (void)settingDeviceSetupResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *responseData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                self.rmsDbController.appsActvDeactvSettingarray = [responseData valueForKey:@"objDeviceInfo"];
                [self secondMenuTapped:nil];
            }
            else // This Alert will come when all module will deactive from current device.
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applications" message:@"User has been deactivated all modules successfully from respected this device, please reactivate modules as per your requirement for further transactions.." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alert.tag = 3;
                [alert show];
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:response[@"Data"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(IBAction)btnCancelClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    _txtpassword.text = @"";
    _txtusername.text = @"";
    _uvAuthentication.hidden = YES;
    _btnApps.selected = NO;
    [self btnAboutUsClicked:nil];
}

-(IBAction)btnSignInClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    if([_txtusername.text isEqualToString:@""] )
    {
        UIAlertView *userAlert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Please Enter Username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [userAlert show];
    }
    else if([_txtpassword.text isEqualToString:@"" ])
    {
        UIAlertView *passAlert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Please Enter Password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [passAlert show];
    }
    else
    {
        // username & password Login
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:_txtusername.text forKey:@"UserName"];
        [param setValue:_txtpassword.text forKey:@"Password"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self responseUserAuthenticationResponse:response error:error];
        };
        
        self.userAccessLoginWC = [self.userAccessLoginWC initWithRequest:KURL actionName:WSM_LOGIN_AUTHENTICATION params:param completionHandler:completionHandler];
    }
}

- (void)responseUserAuthenticationResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *responseData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if([[responseData valueForKey:@"IsBranchAdmin"] integerValue ] == 1)
                {
                    [self goToAppsetting];
                }
                else
                {
                    _uvAuthentication.hidden = YES;
                    _btnDoneApps.hidden = YES;
                    [self.uvapps setHidden:YES];
                    _btnApps.selected = NO;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applications" message:@"User have no right to view Apps." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    _btnApps.enabled = NO;
                    [_btnApps setImage:[UIImage imageNamed:@"appsDeactive.png"] forState:UIControlStateNormal ];
                }
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applications" message:[response valueForKey:@"Data"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    _txtusername.text = @"";
    _txtpassword.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sliding Menu

- (void)leavingDashBoard:(NSNotification *)leavingNotification
{
    self.settingsButton.hidden = YES;
    _showCalendarSecond.hidden = YES;
}

- (void)enteringDashBoard:(NSNotification *)enteringNotification
{
    self.settingsButton.hidden = NO;
}

- (void)configureSlidingMenu
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leavingDashBoard:) name:@"leavingDashBoard" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteringDashBoard:) name:@"enteringDashBoard" object:nil];
    
    // Side menu view configuration
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    UIViewController *dashboardVC = [storyBoard instantiateViewControllerWithIdentifier:@"RmsDashBoard"];
    dashboardVC = [storyBoard instantiateViewControllerWithIdentifier:@"RmsDashBoard"];

#define ABCD
    
#ifdef ABCD
    dashboardVC.view.frame = self.dashboardContainerView.bounds;
    [self addChildViewController:dashboardVC];
    [self.dashboardContainerView addSubview:dashboardVC.view];
#else
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dashboardVC];
    
    CGRect frame = self.dashboardContainerView.frame;
    self.navVC = navigationController;
    
    navigationController.view.frame = frame;
    
    [self.dashboardContainerView addSubview:navigationController.view];
#endif
    
}

- (IBAction)menuButtonTapped:(id)sender
{
    [self.rmsDbController playButtonSound];
    
    self.rmsDbController.selectedModule = @"Setting";
    loginView = [[POSLoginView alloc] initWithNibName:@"POSLoginView" bundle:nil];
    loginView.loginResultDelegate = self;
    [self.view addSubview:loginView.view];
    
    // Check Rapid Cash Register + GAS
   }

-(void)cancelSettingView
{
    [loginView.view removeFromSuperview];
}

-(void)openSettingView
{
    [loginView.view removeFromSuperview];
    intercomHandler = [[IntercomHandler alloc] initWithSettingButtton:_btnIntercom withViewController:self];

    NSPredicate *isGasModuleActive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND ModuleId == %@", (self.rmsDbController.globalDict)[@"DeviceId"],@(5)];
    NSMutableArray *isGasModuleFound = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:isGasModuleActive] mutableCopy ];
    
    if(isGasModuleFound.count > 0)
    {
        _btnGasPump.hidden = NO;
        self.isGasPumpFound = YES;
    }
    else
    {
        _btnGasPump.hidden = YES;
        self.isGasPumpFound = NO;
    }
    
    // Check Restaurant + Retail  OR Restaurant is Active or not
    NSPredicate *isRestaturentActive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND ( ModuleId == %@ OR ModuleId == %@ )", (self.rmsDbController.globalDict)[@"DeviceId"],@(7),@(6)];
    NSMutableArray *isRestaurentFound = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:isRestaturentActive] mutableCopy ];
    
    if(isRestaurentFound.count > 0)
    {
        self.isRestaurentFound = YES;
    }
    else
    {
        self.isRestaurentFound = NO;
    }
    
    [self.rmsDbController playButtonSound];
    if (self.isMenuVisible)
    {
        [self slideIn];
    }
    else
    {
        [self checkForOfflienRecords];
        [self configureSectionsRows];
        [self slideOut];
    }
    _btnToolTipSetup.enabled = NO;

}

-(void)configureSectionsRows
{
    self.settingArray = [[NSMutableArray alloc] initWithObjects:@(SettingAboutUs),@(SettingApps),@(SettingToolTipSetUp), nil];
    
    if(self.isOfflieRecordFound) // offline record available
    {
    self.hardwareSettingArray = [[NSMutableArray alloc] initWithObjects:@(HardwareUPCScanner),@(HardwareTenderConfiguration),@(HardwareCustomerDisplay),@(HardwareSound),@(HardwarePrinter),@(HardwareKitchenPrinter),@(HardwareOfflineRecord),@(HardwareGasPump),@(HardwarePaxDeviceSetting), nil];
    }
    else
    {
    self.hardwareSettingArray = [[NSMutableArray alloc] initWithObjects:@(HardwareUPCScanner),@(HardwareTenderConfiguration),@(HardwareCustomerDisplay),@(HardwareSound),@(HardwarePrinter),@(HardwareKitchenPrinter),@(HardwareGasPump),@(HardwarePaxDeviceSetting), nil];
    }
    self.optionArray = [[NSMutableArray alloc] initWithObjects:@(RCRSettingDashBoard),@(RCRSettingSynchronize),@(RCRSettingOption), nil];
    //    if(self.isOfflieRecordFound) // offline record available
//    {
////        self.miscellaneousArray = [[NSMutableArray alloc] initWithObjects:@(MiscSynchronize),@(MiscPrinter),@(MiscKitchenPrinter),@(MiscOfflineRecord),@(MiscGasPump), nil];
//        self.miscellaneousArray = [[NSMutableArray alloc] initWithObjects:@(HardwareSynchronize),@(HardwarePrinter),@(HardwareKitchenPrinter),@(HardwareOfflineRecord),@(HardwareGasPump),@(HardwarePaxDeviceSetting), nil];
//
//    }
//    else // offline record not available
//    {
////        self.miscellaneousArray = [[NSMutableArray alloc] initWithObjects:@(MiscSynchronize),@(MiscPrinter),@(MiscKitchenPrinter),@(MiscGasPump), nil];
//        self.miscellaneousArray = [[NSMutableArray alloc] initWithObjects:@(HardwareSynchronize),@(HardwarePrinter),@(HardwareKitchenPrinter),@(HardwareGasPump),@(HardwarePaxDeviceSetting), nil];
//
//    }
    if(!self.isRestaurentFound)
    {
        [self.hardwareSettingArray removeObject:@(HardwareKitchenPrinter)];
    }
    if(!self.isGasPumpFound)
    {
        [self.hardwareSettingArray removeObject:@(HardwareGasPump)];
    }
}

-(void)storeUserDefaultSetting
{
    NSMutableDictionary *rapidMainSettingDict = [[NSMutableDictionary alloc]init];
    rapidMainSettingDict[@"BranchConfigurationSetting"] = [appSettings getRapidSettings];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self insertBranchConfigurationSettingResponse:response error:error];
    };

    self.webServiceConnectionSettingBG = [self.webServiceConnectionSettingBG initWithAsyncRequest:KURL actionName:WSM_INSERT_BRACH_CONFIGURATION_SETTING params:rapidMainSettingDict asyncCompletionHandler:asyncCompletionHandler];
}

-(void)insertBranchConfigurationSettingResponse:(id)response error:(NSError *)error
{
}

-(void)responseUserSetting:(NSNotification *)notification
{
    NSMutableArray *responsesetttingArray = notification.object;
    responsesetttingArray = [responsesetttingArray valueForKey:@"InsertConfigurationSetting12172014Result"];
    if(responsesetttingArray!= nil)
    {
        if ([[[notification.object valueForKey:@"InsertConfigurationSetting12172014Result"] valueForKey:@"IsError"] intValue] == 0)
        {
            //NSString * responsearray=[responsesetttingArray  valueForKey:@"Data"];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResponseUserSetting" object:nil];
}

//27112014
- (void)slideOut
{
    [self.tblSettingSideMenu reloadData];
    
    for(id view in _tenderView.subviews){
        [view removeFromSuperview];
    }
    
    for(id view in _uvRcr.subviews){
        [view removeFromSuperview];
    }
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.menuVisible = YES;
        CGRect frame = self.slidingView.frame;
        frame.origin = CGPointMake(313, 0);
        self.slidingView.frame = frame;
    } completion:^(BOOL finished) {
        self.settingsButton.hidden = YES;
        self.exitButton.hidden = NO;
        self.dashboardContainerView.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = YES;
        self.lblSecondDate.hidden = YES;
        self.lblCurrentDate.hidden = YES; // set NO when want to display date
        _showCalendar.hidden = NO;
        _showCalendarSecond.hidden = YES;
    }];
}

- (void)slideIn
{
    self.view.userInteractionEnabled = NO;
    [self.navVC viewWillAppear:YES ];
    [self hideAllViews];
    [self deselctAllButtons];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.menuVisible = NO;
        CGRect frame = self.slidingView.frame;
        frame.origin = CGPointMake(0, 0);
        self.slidingView.frame = frame;
    } completion:^(BOOL finished) {
        self.settingsButton.hidden = NO;
        self.exitButton.hidden = YES;
        self.dashboardContainerView.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
        
        self.lblSecondDate.hidden = YES;
        self.lblCurrentDate.hidden = YES;
        _showCalendar.hidden = YES;
        _showCalendarSecond.hidden = NO;
        
        self.isUserAuthenticated = NO;
        [self.uvapps setHidden:YES];
        _btnApps.enabled = YES;
        _btnApps.selected = NO;
        [_btnApps setImage:[UIImage imageNamed:@"appsNormal.png"] forState:UIControlStateNormal ];
    }];
}

- (IBAction)menuOptionTapped:(id)sender
{
    self.lblCurrentDate.hidden = YES;
    _showCalendar.hidden = NO;
    self.slidingView.hidden = YES;
}

- (void)resetDashboardPartialView
{
    self.lblCurrentDate.hidden = NO;
    _showCalendar.hidden = YES;
    self.slidingView.hidden = NO;
}

- (IBAction)secondMenuTapped:(id)sender
{
    // Store User Default
    if ([self checkGasPumpUrlSetting]) {
        [self storeUserDefaultSetting];
        [self.rmsDbController playButtonSound];
        self.slidingView.hidden = NO;
        [self slideIn];
        [dashboardVC loadDashBoardModuleIcons];
    }
//    [self checkGasPumpUrlSetting];
}

-(BOOL)checkGasPumpUrlSetting{
    
    return true;
}

-(BOOL)checkMenuSelected{
    
    if(_btnApps.selected || _btnProfile.selected || _btnToolTipSetup.selected ||_btnProfile.selected ||
       _btnAboutUs.selected || _btnSound.selected || _btnUpcScan.selected ||
       _btnCustDisp.selected || _btnTenderConfig.selected || _btnCashRegister.selected || _btnSynchronize.selected || _btnPrinterSetting.selected || _btnGasPump.selected || _btnOfflineRecord.selected || _btnInventoryMgmt.selected || _btnModuleSelection.selected || _btnDashBoardIconSelection.selected || _btnPaxDeviceSetting.selected )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)tenderConfigurationSub:(NSString *)strTitle Index:(NSString *)strIndex arrPaymentType:(NSMutableArray *)arryPaymentType
{
    TenderConfigurationSubEditVC *tenderSub = [[TenderConfigurationSubEditVC alloc]initWithNibName:@"TenderConfigurationSubEditVC" bundle:nil];
    tenderSub.strPayID = strTitle;
    tenderSub.strIndex = strIndex;
    tenderSub.arrpaymentType = arryPaymentType;
    [tenderSettingsNav pushViewController:tenderSub animated:YES];
}

-(void)goToDisplayConnection
{
    CustomerDisplayConnection *connection = [[CustomerDisplayConnection alloc] initWithNibName:@"CustomerDisplayConnection" bundle:nil];
    [customerDisplayNav pushViewController:connection animated:true];
}

-(void)goToAvailableAppsMenu
{
    appsAvailable=[[AvailableAppsViewController alloc]initWithNibName:@"AvailableAppsViewController" bundle:nil];
    appsAvailable.dashAvailableApps = self;
    [availableAppsNav pushViewController:appsAvailable animated:true];
}

-(void)goToActiveAppsMenu
{
    activeAppsVC=[[ActiveAppsVC alloc]initWithNibName:@"ActiveAppsVC" bundle:nil];
    activeAppsVC.dashActiveApps = self;
    [availableAppsNav pushViewController:activeAppsVC animated:true];
}

-(void)goToAppsetting
{
    applicationSettingVC=[[ApplicationSettingVC alloc]initWithNibName:@"ApplicationSettingVC" bundle:nil];
    availableAppsNav=[[UINavigationController alloc]initWithRootViewController:applicationSettingVC];
    availableAppsNav.view.frame = _appsSettingView.bounds;
    applicationSettingVC.dashAvailableApps = self;
    [_appsSettingView addSubview:availableAppsNav.view];
    _uvAuthentication.hidden = YES;
    _appsSettingView.hidden = NO;
    [self.view bringSubviewToFront:_appsSettingView];
}

-(void)goTODeviceActivation
{
    UserActivationViewController *objUser = [[UserActivationViewController alloc] initWithNibName:@"UserActivationViewController" bundle:nil];
    [self.navigationController pushViewController:objUser animated:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
