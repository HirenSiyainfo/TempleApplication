//
//  RmsDashboardVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "RmsDashboardVC.h"
#import "AppDelegate.h"
#import "RmsDbController.h"
#import "RcrController.h"
#import "RimsController.h"
#import "DashBoardSettingVC.h"
#import "DashBoardCollectionCell.h"
#import "DashBoardCollectionHeaderView.h"
#import "RimLoginVC.h"
#import "SettingIphoneVC.h"
#import "CKOCalendarViewController.h"
#import "DashBoardIconSelectionVC.h"
#import "Configuration.h"
//#import "RapidPetroPOS.h"
#import "MMDiscountListVC.h"
#import "CameraScanVC.h"
#import "DebugLogManager.h"

@interface RmsDashboardVC () <DashBoardIconSelectionVCDelegate>
{
    IntercomHandler *intercomHandler;
    Configuration *objConfiguration;
    BOOL isUpdateDirtyPumpCart;
}

@property (nonatomic, weak) IBOutlet UILabel *companyName;
@property (nonatomic, weak) IBOutlet UILabel *lblDeviceName;
@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UILabel *lblCurrentDate;
@property (nonatomic, weak) IBOutlet UICollectionView *moduleCollectionView;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *getGasSettingWC;


@property (nonatomic, strong) UIPopoverController *calendarPopOverController;

@property (nonatomic, strong) NSMutableArray *activeModulesArray;
@property (nonatomic, strong) NSMutableArray *dashBoardArray;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation RmsDashboardVC
@synthesize managedObjectContext = _managedObjectContext;

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

	// Do any additional setup after loading the view.
   // AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.activeModulesArray = [[NSMutableArray alloc] init];
    self.getGasSettingWC  = [[RapidWebServiceConnection alloc]init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    NSString *strComapny = [[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"];
    _companyName.text  = [NSString stringWithFormat:@"Store Name : %@",strComapny.uppercaseString];
    NSString *strRegister = [self.rmsDbController.globalDict valueForKey:@"RegisterName"];
    _lblDeviceName.text = [NSString stringWithFormat:@"Register Name : %@",strRegister.uppercaseString];

    
    for(UIView *yourButton in self.view.subviews)
    {
        if([yourButton isKindOfClass:[UIButton class]])
        {
            yourButton.layer.cornerRadius = 10;
            [yourButton.layer setMasksToBounds:YES];
        }
    }
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    
    //// IMPORTANT /////
    #if RAPID_URL_SCHEME != RAPID_URL_SCHEME_LIVE
        NSString * strServerName = [NSString stringWithFormat:@"%@",RAPID_URL_SCHEME_LABEL_TEXT];
        UILabel * lblServerName = [[UILabel alloc]initWithFrame:CGRectMake(0, 155, self.view.bounds.size.width, 25)];
        lblServerName.backgroundColor = [UIColor whiteColor];
        lblServerName.textColor = [UIColor redColor];
        [lblServerName setFont:[UIFont boldSystemFontOfSize:16]];
        lblServerName.text = strServerName;
        lblServerName.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lblServerName];
    #endif
    
//    appDelegate.navigationController = self.navigationController;
    
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (self.rmsDbController.globalDict)[@"DeviceId"]];
    
    self.activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetBreakDown:) name:@"InternetBreakDown" object:nil];
    isUpdateDirtyPumpCart = TRUE;
}

- (void)internetBreakDown:(NSNotification *)notification
{
    
   // [self viewWillAppear:YES];
   [self loadDashBoardModuleIcons];
}

- (void)configureDashBoardArrayAccordingToActivateModule
{
    self.dashBoardArray = [[NSMutableArray alloc] init];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        BOOL isRcractive = [self isRcrActive];
        if (isRcractive)
        {
            [self.dashBoardArray addObject:@"Cash Register"];
            if (self.rmsDbController.isInternetRechable)
            {
                [self.dashBoardArray addObject:@"Clock In-Out"];
                [self.dashBoardArray addObject:@"Shift In-Out"];
                [self.dashBoardArray addObject:@"Daily Report"];
            }
        }
        BOOL isRcrGasactive = [self isRcrGasActive];
        if (isRcrGasactive)
        {
            if (self.rmsDbController.isInternetRechable)
            {
                [self.dashBoardArray addObject:@"Rcr Gas"];
            }
        }
    }
    BOOL isRimActive = [self isRimActive];
    if (isRimActive)
    {
        if (self.rmsDbController.isInternetRechable)
        {
            [self.dashBoardArray addObject:@"Inventory Management"];
            [self.dashBoardArray addObject:@"Inventory Count"];

        //    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
          //  {
           // }
        }
    }
    BOOL isPurChaseActive = [self isPurchaseOrdeActive];
    if (isPurChaseActive)
    {
        if (self.rmsDbController.isInternetRechable)
        {
            [self.dashBoardArray addObject:@"Purchase Order"];
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            {
                [self.dashBoardArray addObject:@"Manual Entry"];
            }
        }
    }
    //    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        BOOL isManagementPortal = [self isManagementPortal];
        if (isManagementPortal)
        {
            if (self.rmsDbController.isInternetRechable)
            {
                [self.dashBoardArray addObject:@"Management Portal"];
            }
        }
    }
    
    //// Change with Ticket Validation
    objConfiguration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    BOOL isTicket =  objConfiguration.localTicketSetting.boolValue;
    if (isTicket == YES)
    {
        if (self.rmsDbController.isInternetRechable)
        {
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            {
                [self.dashBoardArray addObject:@"Ticket Validation"];
            }
        }
    }
    
    objConfiguration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    BOOL isCustomerLoyalty =  objConfiguration.localCustomerLoyalty.boolValue;
    if (isCustomerLoyalty == YES)
    {
        if (self.rmsDbController.isInternetRechable)
        {
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            {
                [self.dashBoardArray addObject:@"Customer Loyalty"];
            }
        }
    }
    
    [self.moduleCollectionView reloadData];
#pragma mark - MMD -
    if(self.rmsDbController.isInternetRechable && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.dashBoardArray addObject:@"Discount"];
    }
}

- (void)loadDashBoardModuleIcons
{
    NSMutableArray *dashBoardSelectedIcon = [[[NSUserDefaults standardUserDefaults] valueForKey:@"DashBoardIconSelection"] mutableCopy];
    if(dashBoardSelectedIcon.count > 0)
    {
        [self configureDashBoardArrayAccordingToActivateModule];

        NSArray *dashboardSelectionArray = [dashBoardSelectedIcon valueForKey:@"module"];
        
        NSPredicate *dashboardSelectionPredicate = [NSPredicate predicateWithFormat:@"SELF IN %@",self.dashBoardArray];
        
        NSArray *finalArrayToDisplay = [dashboardSelectionArray filteredArrayUsingPredicate:dashboardSelectionPredicate];
        
        self.dashBoardArray = [finalArrayToDisplay mutableCopy];
#pragma mark - MMD -
        if(self.rmsDbController.isInternetRechable && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            [self.dashBoardArray addObject:@"Discount"];
            [self.dashBoardArray addObject:@"Inventory Count"];

        }
    }
    else
    {
        [self configureDashBoardArrayAccordingToActivateModule];
    }
    
    BOOL isRcrGasactive = [self isRcrGasActive];
    if (isRcrGasactive){
    
        
//        if(!self.rmsDbController.rapidPetroPos){
//            self.rmsDbController.rapidPetroPos = [RapidPetroPOS createInstance];
//        }
//        if([self.rmsDbController isRapidOnSite]){
//            if ([self.rmsDbController getGasPumpUrlEnabled]) {
//                self.rmsDbController.rapidPetroPos.onSiteStopListing = YES;
//            }
//            else{
//                PetroPosOnSite * petroPosOnSite = (PetroPosOnSite *)self.rmsDbController.rapidPetroPos;
//                if ([petroPosOnSite isKindOfClass:[PetroPosOnSite class]]) {
//                    if(!petroPosOnSite.bl.isListening){
//                        petroPosOnSite.bl.stopListing = NO;
//                        dispatch_queue_t gasPumpQue = dispatch_queue_create("Gas Pump Broadcast", NULL);
//                        dispatch_async(gasPumpQue, ^{
//                            [petroPosOnSite.bl startListening];
//                            
//                        });
//                    }
//                }
//            }
//        }
        [self.rmsDbController dbVersionUpdateGas];
        [self setDefaultValuesforGasPump];
        
        if (isUpdateDirtyPumpCart) {
            isUpdateDirtyPumpCart = FALSE;
//            NSPredicate * preIsDurty = [NSPredicate predicateWithFormat:@"isDirty == %@",@(1)];
//            NSArray<PumpCart *> * arrPumpCartList = [self.rmsDbController.updateManager fetchEntityDetail:preIsDurty intheEntity:@"PumpCart" manageObjectContext:self.rmsDbController.rapidPetroPos.petroMOC];
            
//            for (PumpCart * pumpCart in arrPumpCartList) {
//                [self.rmsDbController.rapidPetroPos addPumpCartWebServiceCallFor:pumpCart];
//            }
        }
    }
    else{
//        if(self.rmsDbController.rapidPetroPos){
//            PetroPosOnSite * petroPosOnSite = (PetroPosOnSite *)self.rmsDbController.rapidPetroPos;
//            petroPosOnSite.bl.stopListing = YES;
//        }
    }

    [self.moduleCollectionView reloadData];
}
#pragma mark Get Gas Setting

-(void)getGasSettings{
    
    NSMutableDictionary *param =[[NSMutableDictionary alloc]init];
    param[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            
            [self getGasSettingsResponse:response error:error];
        });
    };
    self.getGasSettingWC = [self.getGasSettingWC initWithRequest:KURL actionName:@"GetGasSettings" params:param completionHandler:completionHandler];
}

- (void)getGasSettingsResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0){
            
                NSDictionary *dict = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if([dict isKindOfClass:[NSDictionary class]])
                {
                    NSString *insideLimit = [NSString stringWithFormat:@"%@",dict[@"InsidePay"]];
                    [self setInsideLimit:insideLimit];
                    NSString *outsideLimit = [NSString stringWithFormat:@"%@",dict[@"OutsidePay"]] ;
                    [self setOutsideLimit:outsideLimit];
                    
                    NSString *preAuthorizeLimit = [NSString stringWithFormat:@"%@",dict[@"AuthorizationOutSide"]];
                    [self setPreAuthorizeLimit:preAuthorizeLimit];
                }
                else{
                    [self setDefaultAmountLimit];
                }
            }
            else {
                [self setDefaultAmountLimit];
            }
        }
    }
}

-(void)setDefaultAmountLimit{
    
    NSString *insideLimit = [[NSUserDefaults standardUserDefaults]valueForKey:@"InsidePaymentLimit"];
    [self setInsideLimit:insideLimit];
    
    NSString *outsideLimit = [[NSUserDefaults standardUserDefaults]valueForKey:@"OutsidePaymentLimit"];
    [self setOutsideLimit:outsideLimit];
    
    NSString *preAuthorizeLimit = [[NSUserDefaults standardUserDefaults]valueForKey:@"PreAuthorizeLimit"];
    [self setOutsideLimit:preAuthorizeLimit];
}

-(void)setDefaultValuesforGasPump{

    [self getGasSettings];
    
    NSDictionary *dictPetro = [[NSUserDefaults standardUserDefaults]valueForKey:@"RapidPetroSetting"];
    
    NSString *serviceMode = dictPetro[@"PetroSetting"][@"ServiceMode"];
    if(serviceMode==nil){
        [self setServiceModeValue:0];
    }
     NSMutableArray *payModes = (NSMutableArray *)[[[NSUserDefaults standardUserDefaults]valueForKey:@"PaymentMode"]mutableCopy];
    if(payModes==0){
        
        [self setPaymentModeValue:@"Cash"];
        [self setPaymentModeValue:@"Credit"];
    }
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    if(![[[defaults dictionaryRepresentation] allKeys] containsObject:@"BeepSelectionEnabled"]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@(1) forKey:@"BeepSelectionEnabled"];
        [userDefaults synchronize];
    }
}
-(void)setPaymentModeValue:(NSString *)paymentMode{
    
    NSMutableArray *payModes = (NSMutableArray *)[[[NSUserDefaults standardUserDefaults]valueForKey:@"PaymentMode"]mutableCopy];
    if(payModes.count == 0){
        payModes = [[NSMutableArray alloc]initWithObjects:paymentMode, nil];
    }
    else{
        if(![payModes containsObject:paymentMode]){
            [payModes addObject:paymentMode];
        }
        
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:payModes forKey:@"PaymentMode"];
    [userDefaults synchronize];
}
-(void)removePaymentModeValue:(int)paymentIndex{
    
    NSMutableArray *payModes = [[[NSUserDefaults standardUserDefaults]valueForKey:@"PaymentMode"]mutableCopy];
    if(payModes.count == 0){
        
    }
    else{
        [payModes removeObjectAtIndex:paymentIndex];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:payModes forKey:@"PaymentMode"];
    [userDefaults synchronize];
}

-(void)setServiceModeValue:(int)serviceMode{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[NSString stringWithFormat:@"%d",serviceMode] forKey:@"ServiceMode"];
    [userDefaults synchronize];
    
}
-(void)setPreAuthorizeLimit:(NSString *)amount{
    if (amount == nil) {
        amount = @"0";
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:amount forKey:@"PreAuthorizeLimit"];
    [userDefaults synchronize];
}

-(void)setInsideLimit:(NSString *)amount{
    if (amount == nil) {
        amount = @"0";
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:amount forKey:@"InsidePaymentLimit"];
    [userDefaults synchronize];
}

-(void)setOutsideLimit:(NSString *)amount{
    if (amount == nil) {
        amount = @"0";
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:amount forKey:@"OutsidePaymentLimit"];
    [userDefaults synchronize];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    
    self.moduleCollectionView.delegate = self;
    self.moduleCollectionView.dataSource = self;
    [self loadRmsModules];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.rmsDbController.isFirstTimeDataLoad = NO;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DashBoardIconSelection"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadDashBoardModuleIcons];
    }
    else
    {
        [self loadDashBoardModuleIcons];
    }

    BOOL isVMSVendor = [self isVMSVendorActive];
    if (isVMSVendor)
    {
        if (self.rmsDbController.isInternetRechable)
        {
            [self.dashBoardArray addObject:@"VMS Vendor"];
        }
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enteringDashBoard" object:nil];
}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

- (void)updateDateLabel
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    _lblCurrentDate.text = [formatter stringFromDate:date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
}

- (void)loadRmsModules
{
    [self updateDateLabel];
    
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (self.rmsDbController.globalDict)[@"DeviceId"]];
    
    self.activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    [self.moduleCollectionView reloadData];
}

-(BOOL)isRimActive
{
    BOOL isRimActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@", @"RIM"];
    NSArray *rimArray = [self.activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rimArray.count > 0) {
        isRimActive = TRUE;
    }
    return isRimActive;
}
-(BOOL)isVMSVendorActive
{
    BOOL isRimActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@", @"VMS"];
    NSArray *rimArray = [self.activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rimArray.count > 0) {
        isRimActive = TRUE;
    }
    return isRimActive;
}

-(BOOL)isPurchaseOrdeActive
{
    BOOL isPurchaseOrdeActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@", @"PO"];
    NSArray *rimArray = [self.activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rimArray.count > 0) {
        isPurchaseOrdeActive = TRUE;
    }
    return isPurchaseOrdeActive;
}
-(BOOL)isManagementPortal
{
    return FALSE;
    BOOL isManagementPortal = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@", @"PO"];
    NSArray *rimArray = [self.activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rimArray.count > 0) {
        isManagementPortal = TRUE;
    }
    return isManagementPortal;
}
-(BOOL)isRcrActive
{
    BOOL isRcrActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@", @"RCR",@"RCRGAS",@"RRRCR",@"RRCR"];
    NSArray *rcrArray = [self.activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}
-(BOOL)isRcrGasActive
{
    BOOL isRcrActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@",@"RCRGAS"];
    NSArray *rcrArray = [self.activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}

-(BOOL)isReportActive
{
    return [self isRcrActive];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"leavingDashBoard" object:nil];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dashBoardArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DashBoardCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ModuleCell" forIndexPath:indexPath];
    
    cell.moduleIconImage.layer.cornerRadius = 10;
    [cell.moduleIconImage.layer setMasksToBounds:YES];
    
    if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Cash Register"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"rcr_icn.png"];
        cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"rcr_icnActive.png"];
        cell.moduleName.text = @"CASH REGISTER";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Clock In-Out"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"Clockinout_icn.png"];
        cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"Clockinout_icn_Active.png"];
        cell.moduleName.text = @"CLOCK IN-OUT";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Shift In-Out"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"shiftinout_icn.png"];
        cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"shiftinout_icn_Active.png"];
        cell.moduleName.text = @"SHIFT IN-OUT";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Daily Report"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"dailyReport_icn.png"];
        cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"dailyReport_icn_Active.png"];
        cell.moduleName.text = @"DAILY REPORT";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Inventory Management"])
    {
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            (cell.moduleIconImage).image = [UIImage imageNamed:@"Inventory_icn_old.png"];
            (cell.moduleIconImage).highlightedImage = [UIImage imageNamed:@"Inventory_icn_old_Active.png"];

            cell.moduleName.text = @"INVENTORY MANAGEMENT";
        }
        else{
            cell.moduleIconImage.image = [UIImage imageNamed:@"Inventory_icn.png"];
            cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"Inventory_icn_Active.png"];
            cell.moduleName.text = @"INVENTORY MANAGEMENT";
        }
        
        
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Inventory Count"])
    {
       (cell.moduleIconImage).image = [UIImage imageNamed:@"Icon_Stock-Control.png"];
        (cell.moduleIconImage).highlightedImage = [UIImage imageNamed:@"Icon_Stock-Control_Active.png"];

        cell.moduleName.text = @"INVENTORY COUNT";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Purchase Order"])
    {
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            (cell.moduleIconImage).image = [UIImage imageNamed:@"purchaseOrder_old.png"];
            (cell.moduleIconImage).highlightedImage = [UIImage imageNamed:@"purchaseOrder_old_Active.png"];

             cell.moduleName.text = @"PURCHASE ORDER";
        }
        else
        {
            cell.moduleIconImage.image = [UIImage imageNamed:@"purchaseOrder.png"];
            cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"purchaseOrder_Active.png"];
             cell.moduleName.text = @"PURCHASE ORDER";
        }
        
       
    }
    
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"VMS Vendor"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"Hackney_icon.png"];
        cell.moduleName.text = @"VMS Vendor";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Manual Entry"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"manualEntry_icon.png"];
        cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"manualEntry_icon_Active.png"];
        cell.moduleName.text = @"MANUAL ENTRY";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Management Portal"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"webPortal_icon.png"] ;
        cell.moduleName.text = @"Management Portal";
    }
    
    //// Change With Ticket Validation
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Ticket Validation"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"Ticket_icn.png"];
        cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"Ticket_icn_Active.png"];
        cell.moduleName.text = @"TICKET VALIDATION";
    }
    /// Change Customer Loyalty
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Customer Loyalty"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"customerloyalty.png"];
        cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"customerloyalty_Active.png"];
        cell.moduleName.text = @"CUSTOMER LOYALTY";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Rcr Gas"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"gasPump.png"];
        cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"gasPumpActive.png"];
        cell.moduleName.text = @"GAS PRICES";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Discount"])
    {
        cell.moduleIconImage.image = [UIImage imageNamed:@"discount.png"];
        cell.moduleIconImage.highlightedImage = [UIImage imageNamed:@"discount_selected.png"];
        cell.moduleName.text = @"PROMOTIONS";
    }
    return cell;
}

-(void)moduleClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.moduleCollectionView];
    NSIndexPath *indexPath = [self.moduleCollectionView indexPathForItemAtPoint:buttonPosition];
    NSString *strModuleCode = (self.activeModulesArray)[indexPath.row][@"ModuleCode"];
    if([strModuleCode isEqualToString:@"RCR"])
    {
        //[self enableCRM:nil];
        [self.rmsDbController launchLoginScreenWithSelectedModule:@"" callModule:strModuleCode];
    }
    else if ([strModuleCode isEqualToString:@"RIM"])
    {
        [self.rmsDbController playButtonSound];
        //[self enableRIM:nil];
        [self.rmsDbController launchLoginScreenWithSelectedModule:@"" callModule:strModuleCode];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{    
    if (self.rmsDbController.wasDateModified == TRUE) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Date time of your device was changed. Please correct it and try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    
    NSString *selectedModule = @"";
    NSString *callModule = @"";
    
    if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Cash Register"])
    {
        selectedModule = @"RCR";
        callModule = @"RCR";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Clock In-Out"])
    {
        [self.rmsDbController playButtonSound];

        selectedModule = @"Clock In-Out";
        callModule = @"RCR";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Shift In-Out"])
    {
        [self.rmsDbController playButtonSound];

        selectedModule = @"Cash In-Out";
        callModule = @"RCR";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Daily Report"])
    {
        [self.rmsDbController playButtonSound];

        selectedModule = @"Daily Report";
        callModule = @"RCR";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Rcr Gas"])
    {
        [self.rmsDbController playButtonSound];
        selectedModule = @"Gas Prices";
        callModule = @"RCR";
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Inventory Management"])
    {
        [self.rmsDbController playButtonSound];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.rmsDbController.selectedModule = @"RIM";
            [self.rmsDbController playButtonSound];
            RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
            [self.navigationController pushViewController:loginView animated:YES];
            return;
        }
        else
        {
            selectedModule = @"RIM";
            callModule = @"RIM";
        }
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Inventory Count"])
    {
        [self.rmsDbController playButtonSound];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.rmsDbController.selectedModule = @"RIC";
            [self.rmsDbController playButtonSound];
            RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
            [self.navigationController pushViewController:loginView animated:YES];
            return;
        }
        else
        {
            selectedModule = @"RIC";
            callModule = @"RIM";
        }
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Purchase Order"])
    {
        [self.rmsDbController playButtonSound];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.rmsDbController.selectedModule = @"RPO";
            [self.rmsDbController playButtonSound];
            RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
            [self.navigationController pushViewController:loginView animated:YES];
            return;
        }
        else
        {
            selectedModule = @"RPO";
            callModule = @"RIM";
        }
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Manual Entry"])
    {
        [self.rmsDbController playButtonSound];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.rmsDbController.selectedModule = @"RME";
            [self.rmsDbController playButtonSound];
            RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
            [self.navigationController pushViewController:loginView animated:YES];
            return;
        }
        else
        {
            selectedModule = @"RME";
            callModule = @"RIM";
        }
    }
    
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"VMS Vendor"])
    {
        [self.rmsDbController playButtonSound];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
//            selectedModule = @"VMS";
            [self.rmsDbController playButtonSound];
            RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
            [self.navigationController pushViewController:loginView animated:YES];
            return;
        }
        else
        {
            selectedModule = @"VMS";
            callModule = @"RIM";
        }
    }
    ////// Change With Ticket validation
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Ticket Validation"])
    {
        [self.rmsDbController playButtonSound];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
           
            return;
        }
        else
        {
            selectedModule = @"TVM";
            callModule = @"TVM";
        }
    }
    
    //// Change Customer Loyalty
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Customer Loyalty"])
    {
        [self.rmsDbController playButtonSound];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            
            return;
        }
        else
        {
            selectedModule = @"CLM";
            callModule = @"CLM";
        }
    }

    
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Management Portal"])
    {
        [self.rmsDbController playButtonSound];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.rmsDbController.selectedModule = @"RMP";
            [self.rmsDbController playButtonSound];
            RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
            [self.navigationController pushViewController:loginView animated:YES];
            return;
        }
        else
        {
            selectedModule = @"RMP";
            callModule = @"RIM";
        }
    }
    else if([(self.dashBoardArray)[indexPath.row] isEqualToString:@"Discount"])
    {
        MMDiscountListVC * mMDiscountListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDiscountListVC_sid"];
        
        [self.navigationController pushViewController:mMDiscountListVC animated:YES];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.rmsDbController launchLoginScreenWithSelectedModule:selectedModule callModule:callModule];
    });
}

- (IBAction)enableCRM:(id)sender
{
    [self.rmsDbController launchLoginScreenWithSelectedModule:@"" callModule:@"RCR"];
}

- (IBAction)enableRIM:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.rmsDbController.selectedModule = @"RIM";
        [self.rmsDbController playButtonSound];
        RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
        [self.navigationController pushViewController:loginView animated:YES];
    }
    else
    {
        [self.rmsDbController launchLoginScreenWithSelectedModule:@"" callModule:@"RIM"];
    }
}

- (IBAction)enablePurchaseOrder:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.rmsDbController.selectedModule = @"RPO";
        [self.rmsDbController playButtonSound];
        RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
        [self.navigationController pushViewController:loginView animated:YES];
    }
    else
    {
        [self.rmsDbController launchLoginScreenWithSelectedModule:@"" callModule:@"RIM"];
    }
}


-(IBAction)btnSettingClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [self.rmsDbController playButtonSound];
        [self.rmsDbController launchLoginScreenWithSelectedModule:@"Setting" callModule:@"SETTING"];

//        RimLoginVC * loginView = [[RimLoginVC alloc] initWithNibName:@"RimLoginVC" bundle:nil];
//        [self.navigationController pushViewController:loginView animated:YES];
        
    }
    else
    {
        [self.rmsDbController launchLoginScreenWithSelectedModule:@"" callModule:@"SETTING"];
    }
}

#pragma mark - DashBoardIconSelectionVCDelegate Methods

-(void)selectedDashBoardIcon:(NSMutableArray *)selectedDashBoardModule
{
    self.dashBoardArray = [selectedDashBoardModule valueForKey:@"module"];
    [[self.view viewWithTag:20150302] removeFromSuperview];
    [self.moduleCollectionView reloadData];
}

-(void)skipDashBoardIconSelection
{
    [[self.view viewWithTag:20150302] removeFromSuperview];
}

@end
