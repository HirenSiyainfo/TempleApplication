//
//  RimMenuVC.m
//  I-RMS
//
//  Created by Siya Infotech on 22/10/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "RimMenuVC.h"

#import "RimsController.h"
#import "RmsDbController.h"
#import "RimDepartmentVC.h"
#import "SubDepartmentVC.h"
#import "GroupModifierListVC.h"
#import "ItemModifierListVC.h"
#import "NewOrderScannerView.h"
#import "InventoryOutScannerView.h"
#import "OpenOrderVC.h"
#import "CloseOrderVC.h"
#import "SupplierInventoryVC.h"
#import "CameraScanVC.h"
#import "ItemInfoEditVC.h"
#import "RmsDashboardVC.h"
#import "TaxMasterListVC.h"
#import "PaymentMasterListVC.h"
#import "RapidWebViewVC.h"
#import "RcrPosRestaurantVC.h"
#import "RcrPosVC.h"
#import "InventoryItemListVC.h"
#import "Configuration.h"
#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif


@interface RimMenuVC () <SideMenuVCDelegate,UIPopoverControllerDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,CameraScanVCDelegate
#ifdef LINEAPRO_SUPPORTED
,DTDeviceDelegate
#endif
>
{
    // Barcode Variable
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
    NSMutableArray *menuOptions;
    UIStoryboard * storyRim;
    NSIndexPath * indSelindex;
    Configuration *configuration;

}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UpdateManager *updateManagerItemHome;


@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic) BOOL boolslidingMenuView;

@property (nonatomic, weak) UIViewController * currentActiveVC;
@property (nonatomic, weak) IBOutlet UIView *gestureView;
@property (nonatomic, weak) IBOutlet UIView *itemManagementView;
@property (nonatomic, weak) IBOutlet UIView *uvLoadSideView;
@property (nonatomic, weak) IBOutlet UIView *slidingMenuView;

@property (nonatomic, weak) IBOutlet UITableView *tblItemOperation;
@property (nonatomic, weak) IBOutlet UITextField *txtMainBarcode;
@property (nonatomic, weak) IBOutlet UIButton *btnSlidingMenu;
@property (nonatomic, weak) IBOutlet UILabel *currentViewController;
@property (nonatomic, weak) IBOutlet UILabel *currenctDate;

@property (nonatomic, strong) UINavigationController * itemManagementNavigationController;
@property (nonatomic, strong) UINavigationController * InactiveitemList;
@property (nonatomic, strong) UINavigationController * objInvenInIpad;
@property (nonatomic, strong) UINavigationController * objInvenOutIpad;
@property (nonatomic, strong) UINavigationController * objInventoryCountIpad;
@property (nonatomic, strong) UINavigationController * objOpenOrder;
@property (nonatomic, strong) UINavigationController * objCloseOrder;
@property (nonatomic, strong) UINavigationController * objSupplierInvenIpad;
@property (nonatomic, strong) UINavigationController * objDepartmentViewIpad;
@property (nonatomic, strong) UINavigationController * objMixMatchViewIpad;
@property (nonatomic, strong) UINavigationController * objSupplierViewIpad;
@property (nonatomic, strong) UINavigationController * objGroupViewIpad;
@property (nonatomic, strong) UINavigationController * objSubDepartmentIpad;
@property (nonatomic, strong) UINavigationController * objGroupModifierIpad;
@property (nonatomic, strong) UINavigationController * objItemModifierIpad;
@property (nonatomic, strong) UINavigationController * objTaxMasterIpad;
@property (nonatomic, strong) UINavigationController * objPaymentMasterIpad;
@property (nonatomic, strong) UINavigationController * objChangeGroupPrice;


@property (nonatomic, strong) RapidWebServiceConnection * homeItemInsertWC;



@end

@implementation RimMenuVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.boolslidingMenuView = TRUE;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    recognizer.delegate = self;
    recognizer.delaysTouchesBegan = YES;
    [self.gestureView addGestureRecognizer:recognizer];
    
   // appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rimsController.managedObjectContext;
    self.homeItemInsertWC = [[RapidWebServiceConnection alloc]init];
    
    storyRim = [UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL];
    
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];

    [self updateDateLabels];
    [self allocOperationComponents];
    if (IsPad()) {
        [self setupRimObject];
        self.currentViewController.text = @"Item Management".uppercaseString;
        indSelindex = [NSIndexPath indexPathForItem:0 inSection:0];
        [self SlideInout];
    }

#ifdef LINEAPRO_SUPPORTED
    // Linea Barcode device connection
    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [dtdev connect];
#endif
   // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.rimsController.scannerButtonCalled=@"Home";
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
- (void)setupRimObject {

    //InventoryManagement

    InventoryItemListVC * inventoryManagement = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemListVC_sid"];
    inventoryManagement.sideMenuVCDelegate = self;
    inventoryManagement.isItemActive = TRUE;
    self.itemManagementNavigationController = [self createNavigationControlerWithRootViewControler:inventoryManagement];
    if (IsPad()) {
        [self showViewFromViewController:self.itemManagementNavigationController WithViewType:IM_InventoryManagement];
    }
    //Inactive item list

    InventoryItemListVC * unActiveinventoryManagement = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemListVC_sid"];
    unActiveinventoryManagement.sideMenuVCDelegate = self;
    unActiveinventoryManagement.isItemActive = FALSE;
    self.InactiveitemList = [self createNavigationControlerWithRootViewControler:unActiveinventoryManagement];
    
    // Department
    RimDepartmentVC *departmentVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimDepartmentVC_sid"];
    departmentVC.sideMenuVCDelegate = self;
    self.objDepartmentViewIpad = [self createNavigationControlerWithRootViewControler:departmentVC];
    
    //SubDepartment
    SubDepartmentVC *subDepartmentVC = [storyRim instantiateViewControllerWithIdentifier:@"SubDepartmentVC_sid"];
    subDepartmentVC.sideMenuVCDelegate = self;
    self.objSubDepartmentIpad = [self createNavigationControlerWithRootViewControler:subDepartmentVC];

    //Group Modifier
    GroupModifierListVC *groupModifier = [storyRim instantiateViewControllerWithIdentifier:@"GroupModifierListVC_sid"];
    groupModifier.sideMenuVCDelegate = self;
    self.objGroupModifierIpad = [self createNavigationControlerWithRootViewControler:groupModifier];
    
    //Item Modifier of Group
    ItemModifierListVC *itemModifier = [storyRim instantiateViewControllerWithIdentifier:@"ItemModifierListVC_sid"];
    itemModifier.sideMenuVCDelegate = self;
    self.objItemModifierIpad = [self createNavigationControlerWithRootViewControler:itemModifier];
    
    //// Tax Master
    TaxMasterListVC *taxMasterListVC = [storyRim instantiateViewControllerWithIdentifier:@"TaxMasterListVC_sid"];
    taxMasterListVC.sideMenuVCDelegate = self;
    self.objTaxMasterIpad = [self createNavigationControlerWithRootViewControler:taxMasterListVC];
    
    //// Payment Master
    PaymentMasterListVC *paymentMasterListVC = [storyRim instantiateViewControllerWithIdentifier:@"PaymentMasterListVC_sid"];
    paymentMasterListVC.sideMenuVCDelegate = self;
    self.objPaymentMasterIpad = [self createNavigationControlerWithRootViewControler:paymentMasterListVC];

    // InventoryIN
    NewOrderScannerView *inventoryInVC = [storyRim instantiateViewControllerWithIdentifier:@"NewOrderScannerView_sid"];
    //    inventoryInVC.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    inventoryInVC.sideMenuVCDelegate = self;
    inventoryInVC.isItemOrderUpdate=FALSE;
    inventoryInVC.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.objInvenInIpad = [self createNavigationControlerWithRootViewControler:inventoryInVC];
    
    // InvnetoryOUT
    InventoryOutScannerView *inventoryOutVC = [storyRim instantiateViewControllerWithIdentifier:@"InventoryOutScannerView_sid"];
    inventoryOutVC.isItemOrderUpdate=FALSE;
    inventoryOutVC.sideMenuVCDelegate = self;
    inventoryOutVC.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.objInvenOutIpad = [self createNavigationControlerWithRootViewControler:inventoryOutVC];

    // OpenOrder
    OpenOrderVC *openOrder = [storyRim instantiateViewControllerWithIdentifier:@"OpenOrderVC_sid"];
    openOrder.sideMenuVCDelegate = self;
    self.objOpenOrder = [self createNavigationControlerWithRootViewControler:openOrder];
    
    // Close Order
    CloseOrderVC *closeOrderVC = [storyRim instantiateViewControllerWithIdentifier:@"CloseOrderVC_sid"];
    closeOrderVC.sideMenuVCDelegate = self;
    self.objCloseOrder = [self createNavigationControlerWithRootViewControler:closeOrderVC];
    
    // SupplierInventory
    SupplierInventoryVC *supplierVC = [storyRim instantiateViewControllerWithIdentifier:@"SupplierInventoryVC_sid"];
    supplierVC.sideMenuVCDelegate = self;
    self.objSupplierInvenIpad = [self createNavigationControlerWithRootViewControler:supplierVC];
    
    //RapidWebViewVC
    RapidWebViewVC *rapidWebVC = [storyRim instantiateViewControllerWithIdentifier:@"RapidWebViewVC_sid"];
    rapidWebVC.pageId = PageIdChangeGroupPrice;
    rapidWebVC.isMenuEnable = NO;
    self.objChangeGroupPrice = [self createNavigationControlerWithRootViewControler:rapidWebVC];

    // MixMatch
//    rimMixMatchListVC *mixMatchVC = [[rimMixMatchListVC alloc]initWithNibName:@"rimMixMatchListVC_iPad" bundle:nil];
//    objMixMatchViewIpad = [self createNavigationControlerWithRootViewControler:mixMatchVC];
//    
//    // Supplier Master
//    SupplierMasterListVC *supplierMasterVC = [[SupplierMasterListVC alloc]initWithNibName:@"SupplierMasterListVC_iPad" bundle:nil];
//    objSupplierViewIpad = [self createNavigationControlerWithRootViewControler:supplierMasterVC];
//    
//    //Group Master
//    GroupMasterListVC *groupMasterListVC = [[GroupMasterListVC alloc]initWithNibName:@"GroupMasterListVC_iPad" bundle:nil];
//    objGroupViewIpad = [self createNavigationControlerWithRootViewControler:groupMasterListVC];
//
//
//    // InventoryManagement
//    if(self._rimController.objInvenMgmt == nil)
//    {
//        self._rimController.objInvenMgmt = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemListVC_sid"];
//    }
//    
//    self.objInvenMgmtIpad = self._rimController.objInvenMgmt;
    
}
-(UINavigationController *)createNavigationControlerWithRootViewControler:(UIViewController *)viewControler{
    UINavigationController * objNavi = [[UINavigationController alloc]initWithRootViewController:viewControler];
    objNavi.navigationBarHidden = TRUE;
    return objNavi;
}
- (void)updateDateLabels
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    self.currenctDate.text = [formatter stringFromDate:date];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    [self SlideInout];
}

-(IBAction)rimMenuHideShow:(id)sender
{
    [self.view endEditing:YES];
    [self SlideInout];

}

-(void)SlideInout
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame;
        if(self.boolslidingMenuView == FALSE)
        {
            frame = self.slidingMenuView.frame;
            frame.origin.x = 0;
            self.slidingMenuView.hidden = NO;
//            self.btnSlidingMenu.frame = CGRectMake(300, 26, 50, 44);
        }
        else
        {
            frame = self.slidingMenuView.frame;
            frame.origin.x = -300;
//            self.btnSlidingMenu.frame = CGRectMake(0, 26, 50, 44);
        }
        self.slidingMenuView.frame = frame;
        [self.view bringSubviewToFront:self.slidingMenuView];
        
    } completion:^(BOOL finished) {
        if(self.boolslidingMenuView == FALSE)
        {
            self.boolslidingMenuView = TRUE;
//            self.btnSlidingMenu.frame = CGRectMake(300, 26, 50, 44);

        }
        else{
            self.boolslidingMenuView = FALSE;
            self.slidingMenuView.hidden = YES;
//            self.btnSlidingMenu.frame = CGRectMake(0, 26, 50, 44);
        }
    }];
    //[self.tblItemOperation reloadData];
}

-(BOOL)isSubdepartmentActive
{
    BOOL isSubdepart = FALSE;
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    NSPredicate *restaurentActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@", @"RCR",@"RCRGAS",@"RRRCR",@"RRCR"];
    NSArray *restaurentArray = [activeModulesArray filteredArrayUsingPredicate:restaurentActive];
    if (restaurentArray.count > 0)
    {
        NSString * moduleCode = [[restaurentArray valueForKey:@"ModuleCode"]firstObject];
        if ([moduleCode isEqualToString:@"RCR"] && [configuration.subDepartment isEqual:@(1)]) {
            isSubdepart = TRUE;
        }
        else if ([moduleCode isEqualToString:@"RRRCR"] && [configuration.subDepartment isEqual:@(1)]) {
            isSubdepart = TRUE;
        }
        else if([moduleCode isEqualToString:@"RCRGAS"])
        {
            isSubdepart= FALSE;
        }
        else if([moduleCode isEqualToString:@"RRCR"])
        {
            isSubdepart = TRUE;
        }
        
    }
    else if([configuration.subDepartment isEqual:@(1)]){
        isSubdepart = TRUE;
    }
    else{
        isSubdepart = FALSE;
    }
    return isSubdepart;
    
}

-(void)allocOperationComponents
{
    NSDictionary *itemMgtSectionDict = @{@"SectionName": @"ITEM MANAGEMENT",
                                         @"Menu Items" : @[
                                                 @{@"menuId": @(IM_InventoryManagement),
                                                   @"Image" : @"RIM_Menu_Item",
                                                   @"Selected Image" : @"RIM_Menu_Item_sel"},
                                                 @{@"menuId": @(IM_InactiveItemManagement),
                                                   @"Image" : @"RIM_Menu_inactive_Item",
                                                   @"Selected Image" : @"RIM_Menu_inactive_Item_sel"},
                                                 @{@"menuId": @(IM_ChangeGroupPrice),
                                                   @"Image" : @"RIM_Menu_GroupPrice",
                                                   @"Selected Image" : @"RIM_Menu_GroupPrice_sel"},
                                                 ]
                                         };
    
    NSDictionary *masterSectionDict;
    
    if([self isSubdepartmentActive] && IsPad()){
        masterSectionDict = @{@"SectionName": @"MASTER",
                              @"Menu Items" : @[
                                      @{@"menuId": @(IM_DepartmentView),
                                        @"Image" : @"RIM_Menu_Department",
                                        @"Selected Image" : @"RIM_Menu_Department_sel"},
                                      
                                      @{@"menuId": @(IM_SubDepartment),
                                        @"Image" : @"RIM_Menu_SubDepartment",
                                        @"Selected Image" :@"RIM_Menu_SubDepartment_sel"},
                                      
                                      @{@"menuId": @(IM_GroupModifier),
                                        @"Image" : @"RIM_Menu_ModifierGroup",
                                        @"Selected Image" : @"RIM_Menu_ModifierGroup_sel"},
                                      
                                      @{@"menuId": @(IM_GroupItemModifier),
                                        @"Image" : @"RIM_Menu_Modifier",
                                        @"Selected Image" : @"RIM_Menu_Modifier_sel"},
                                      
                                      @{@"menuId": @(IM_TaxMaster),
                                        @"Image" : @"RIM_Menu_TaxMaster",
                                        @"Selected Image" : @"RIM_Menu_TaxMaster_sel"},
                                      
                                      @{@"menuId": @(IM_PaymentMaster),
                                        @"Image" : @"RIM_Menu_PaymentMaster",
                                        @"Selected Image" : @"RIM_Menu_PaymentMaster_sel"
                                        },
                                      ]
                              };
    }
    else if(![self isSubdepartmentActive] && IsPad()){
        masterSectionDict = @{@"SectionName": @"MASTER",
                              @"Menu Items" : @[
                                      @{@"menuId": @(IM_DepartmentView),
                                        @"Image" : @"RIM_Menu_Department",
                                        @"Selected Image" : @"RIM_Menu_Department_sel"},
                                      
                                      @{@"menuId": @(IM_GroupModifier),
                                        @"Image" : @"RIM_Menu_ModifierGroup",
                                        @"Selected Image" : @"RIM_Menu_ModifierGroup_sel"},
                                      
                                      @{@"menuId": @(IM_GroupItemModifier),
                                        @"Image" : @"RIM_Menu_Modifier",
                                        @"Selected Image" : @"RIM_Menu_Modifier_sel"},
                                      
                                      @{@"menuId": @(IM_TaxMaster),
                                        @"Image" : @"RIM_Menu_TaxMaster",
                                        @"Selected Image" : @"RIM_Menu_TaxMaster_sel"},
                                      
                                      @{@"menuId": @(IM_PaymentMaster),
                                        @"Image" : @"RIM_Menu_PaymentMaster",
                                        @"Selected Image" : @"RIM_Menu_PaymentMaster_sel"
                                        },
                                      ]
                              };
    }
    else
    {
        masterSectionDict = @{@"SectionName": @"MASTER",
                              @"Menu Items" : @[
                                      @{@"menuId": @(IM_DepartmentView),
                                        @"Image" : @"RIM_Menu_Department",
                                        @"Selected Image" : @"RIM_Menu_Department_sel"},
                                      
                                      @{@"menuId": @(IM_TaxMaster),
                                        @"Image" : @"RIM_Menu_TaxMaster",
                                        @"Selected Image" : @"RIM_Menu_TaxMaster_sel"},
                                      
                                      @{@"menuId": @(IM_PaymentMaster),
                                        @"Image" : @"RIM_Menu_PaymentMaster",
                                        @"Selected Image" : @"RIM_Menu_PaymentMaster_sel"
                                        },
                              ]
                              };
    }
    
    NSDictionary *itemSectionDict =  @{@"SectionName": @"",
                                       @"Menu Items" : @[
                                               @{@"menuId": @(IM_NewOrderScannerView),
                                                 @"Image" : @"RIM_Menu_IN",
                                                 @"Selected Image" : @"RIM_Menu_IN_sel"},
                                               
                                               @{@"menuId": @(IM_InventoryOutScannerView),
                                                 @"Image" : @"RIM_Menu_Out",
                                                 @"Selected Image" : @"RIM_Menu_Out_sel"},
                                               
                                               @{@"menuId": @(IM_OpenOrderViewController),
                                                 @"Image" : @"RIM_Menu_OpenOder",
                                                 @"Selected Image" : @"RIM_Menu_OpenOder_sel"},
                                               
                                               @{@"menuId": @(IM_CloseOrderViewController),
                                                 @"Image" : @"RIM_Menu_CloseOder",
                                                 @"Selected Image" : @"RIM_Menu_CloseOder_sel"},
                                               ]
                                       };
    
    NSDictionary *supplierSectionDict = @{@"SectionName": @"",
                                          @"Menu Items" : @[
                                                  @{@"menuId": @(IM_SupplierInventoryView),
                                                    @"Image" : @"RIM_Menu_Vendor",
                                                    @"Selected Image" : @"RIM_Menu_Vendor_sel"},
                                                  ]
                                          };
    menuOptions = [[NSMutableArray alloc] initWithObjects:itemMgtSectionDict,masterSectionDict,itemSectionDict,supplierSectionDict, nil];
}


#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return menuOptions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionDictionary = menuOptions[section];
    NSArray *menuItems = sectionDictionary[@"Menu Items"];
    return menuItems.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 23.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 23.0f)];
    
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, view.frame.size.width-20, view.frame.size.height)];
    [label setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0]];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    NSString *sectionTitle = @"";
    switch (section) {
        case 0:
            sectionTitle = @"ITEM MANAGEMENT";
            break;
        case 1:
            sectionTitle = @"ITEM MASTER";
            break;
        case 2:
            sectionTitle = @"IN-OUT";
            break;
        case 3:
            sectionTitle = @"VENDOR";
            break;
            
        default:
            break;
    }
    label.text = sectionTitle;
    if (IsPhone()) {
        label.textColor = [UIColor whiteColor];
    }
    else {
        label.textColor = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    }
    UIView * ovjSepreter = [[UIView alloc]initWithFrame:CGRectMake(20, view.frame.size.height-1, view.frame.size.width-20, 1)];
    ovjSepreter.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.200];
    
    [view addSubview:label];
    [view addSubview:ovjSepreter];
    [view setBackgroundColor:[UIColor clearColor]]; //your background color...
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RIMMenuCell  *cell=[tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    NSDictionary *sectionDictionary = menuOptions[indexPath.section];
    NSArray *menuItems = sectionDictionary[@"Menu Items"];
    NSDictionary *menuItemDictionary = menuItems [indexPath.row];
    
    NSString * strImageName = @"Image";
    if ([indexPath isEqual:indSelindex]) {
        strImageName = @"Selected Image";
    }
    cell.imgBG.image = [UIImage imageNamed:menuItemDictionary[strImageName]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    indSelindex = indexPath;
    NSDictionary *sectionDictionary = menuOptions[indexPath.section];
    NSArray *menuItems = sectionDictionary[@"Menu Items"];
    NSDictionary *menuItemDictionary = menuItems [indexPath.row];

    ItemManagementVCType menuItem = [menuItemDictionary [@"menuId"] integerValue];
    [self menuButtonOperations:menuItem];
    if (IsPhone()) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction -
-(IBAction)dashboardButtonTapped:(UIButton *)sender {

    
    [Appsee addEvent:kRIMMenuDashboard];
    [self.rmsDbController playButtonSound];
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    for (UIViewController *vc in viewControllerArray) {
        if ([vc isKindOfClass:[RcrPosRestaurantVC class]] || [vc isKindOfClass:[RcrPosVC class]]) {
            [self.navigationController popToViewController:vc animated:TRUE];
            return;
        }
    }
    for (UIViewController *vc in viewControllerArray)
    {
        if ([vc isKindOfClass:[DashBoardSettingVC class]] || [vc isKindOfClass:[RmsDashboardVC class]])
        {
            //[self cleanUpNavigationController];
            [self.navigationController popToViewController:vc animated:TRUE];
            break;
        }
    }
}

-(IBAction)logoutClicked:(id)sender {
    
    [Appsee addEvent:kRIMMenuLogout];
    [self updateDateLabels];
    [self.rmsDbController playButtonSound];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)menuButtonOperations:(ItemManagementVCType )menuItemId
{
    [self updateDateLabels];
    [self.rmsDbController playButtonSound];
    [self.currentActiveVC.view removeFromSuperview];
    switch (menuItemId) {
            // Item List
        case IM_InventoryManagement:{
//            self._rimController.objInvenMgmt.checkSearchRecord = FALSE;
//            [self selectedSideMenuView:btnItemList];
            self.currentViewController.text = @"Item Management".uppercaseString;
            [self showViewFromViewController:self.itemManagementNavigationController WithViewType:IM_InventoryManagement];
            [Appsee addEvent:kRIMMenuItemList];
        }
            break;
            // Inactive Item List
        case IM_InactiveItemManagement:{
            self.currentViewController.text = @"Inactive Item Management".uppercaseString;
            [self showViewFromViewController:self.InactiveitemList WithViewType:IM_InactiveItemManagement];
            [Appsee addEvent:kRIMMenuItemList];
        }
            break;
            // Item In
        case IM_NewOrderScannerView:{
//            [self selectedSideMenuView:btnItemIn];
            self.currentViewController.text = @"Item In".uppercaseString;
            [self showViewFromViewController:self.objInvenInIpad WithViewType:IM_NewOrderScannerView];
//            [self._rimController.objInvenMgmt restoreItemSElectionForLabdelforIpad];
            [Appsee addEvent:kRIMMenuItemIn];
        }
            break;
            // Item out
        case IM_InventoryOutScannerView:{
//            [self selectedSideMenuView:btnItemOut];
            self.currentViewController.text = @"Item Out".uppercaseString;
            [self showViewFromViewController:self.objInvenOutIpad WithViewType:IM_InventoryOutScannerView];
//            [self._rimController.objInvenMgmt restoreItemSElectionForLabdelforIpad];
            [Appsee addEvent:kRIMMenuItemOut];
        }
            break;
            // Open Order
        case IM_OpenOrderViewController:{
//            [self selectedSideMenuView:btnItemOpen];
            self.currentViewController.text = @"Open Order".uppercaseString;
            [self showViewFromViewController:self.objOpenOrder WithViewType:IM_OpenOrderViewController];
            [Appsee addEvent:kRIMMenuItemOpenOrder];
        }
            break;
            // close
        case IM_CloseOrderViewController:{
//            [self selectedSideMenuView:btnItemClosed];
            self.currentViewController.text = @"Close Order".uppercaseString;
            [self showViewFromViewController:self.objCloseOrder WithViewType:IM_CloseOrderViewController];
            [Appsee addEvent:kRIMMenuItemCloseOrder];
        }
            break;
            // Inventory Count
//        case RimMenuItemInventoryCount:{
//            [self selectedSideMenuView:btnInvenCount];
//            self.currentViewController.text = @"Inventory Count";
//            [self showViewFromViewController:objInventoryCountIpad];
//            [Appsee addEvent:kRIMMenuItemInventoryCount];
//        }
//            break;
            // Supplier Inventory
        case IM_SupplierInventoryView:{
//            [self selectedSideMenuView:btnSupplierInven];
            self.currentViewController.text = @"Supplier Inventory".uppercaseString;
            [self showViewFromViewController:self.objSupplierInvenIpad WithViewType:IM_SupplierInventoryView];
            [Appsee addEvent:kRIMMenuItemSupplierInventory];
        }
            break;
            // Department Master
        case IM_DepartmentView:{
//            [self selectedSideMenuView:btnDepartment];
            self.currentViewController.text = @"Department".uppercaseString;
            [self showViewFromViewController:self.objDepartmentViewIpad WithViewType:IM_DepartmentView];
            [Appsee addEvent:kRIMMenuDepartmentMaster];
        }
            break;
            
        case IM_TaxMaster:{
            //            [self selectedSideMenuView:btnDepartment];
            self.currentViewController.text = @"Tax Master".uppercaseString;
            [self showViewFromViewController:self.objTaxMasterIpad WithViewType:IM_TaxMaster];
            [Appsee addEvent:kRIMMenuTaxMaster];
        }
            break;
            
        case IM_PaymentMaster:{
            //            [self selectedSideMenuView:btnDepartment];
            self.currentViewController.text = @"Payment Master".uppercaseString;
            [self showViewFromViewController:self.objPaymentMasterIpad WithViewType:IM_PaymentMaster];
            [Appsee addEvent:kRIMMenuPaymentMaster];
        }
            break;
        // DashBoard
        case IM_DashBoardLoad:{
            [self dashboardButtonTapped:nil];
        }
            break;
//            // MixMatch Master
//        case RimMenuItemMixMatchMaster:{
//            [self selectedSideMenuView:btnMixMatch];
//            self.currentViewController.text = @"MixMatch";
//            [self showViewFromViewController:objMixMatchViewIpad];
//            [Appsee addEvent:kRIMMenuMixMatchMaster];
//        }
//            break;
//            // Supplier Master
//        case RimMenuItemSupplierMaster:{
//            [self selectedSideMenuView:btnSupplier];
//            self.currentViewController.text = @"Supplier";
//            [self showViewFromViewController:objSupplierViewIpad];
//            [Appsee addEvent:kRIMMenuSupplierMaster];
//        }
//            break;
//            // Group Master
//        case RimMenuItemGroupMaster:{
//            [self selectedSideMenuView:btnGroup];
//            self.currentViewController.text = @"Group";
//            [self showViewFromViewController:objGroupViewIpad];
//            [Appsee addEvent:kRIMMenuGroupMaster];
//        }
//            break;
//            // Sub Department
        case IM_SubDepartment:{
//            [self selectedSideMenuView:btnSubDepartment];
            self.currentViewController.text = @"SubDepartment".uppercaseString;
            [self showViewFromViewController:self.objSubDepartmentIpad WithViewType:IM_SubDepartment];
            [Appsee addEvent:kRIMMenuSubDepartment];
        }
            break;
            // Modifier Group
        case IM_GroupModifier:{
//            [self selectedSideMenuView:btnModifierGroup];
            self.currentViewController.text = @"Group Modifier".uppercaseString;
            [self showViewFromViewController:self.objGroupModifierIpad WithViewType:IM_GroupModifier];
            [Appsee addEvent:kRIMMenuModifierGroup];
        }
            break;
            // Modifier
        case IM_GroupItemModifier:{
//            [self selectedSideMenuView:btnModifier];
            self.currentViewController.text = @"Item Modifier".uppercaseString;
            [self showViewFromViewController:self.objItemModifierIpad WithViewType:IM_GroupItemModifier];
            [Appsee addEvent:kRIMMenuItemModifier];
        }
            break;
            
        case IM_ChangeGroupPrice:{
            [self showViewFromViewController:self.objChangeGroupPrice WithViewType:IM_ChangeGroupPrice];
            [Appsee addEvent:kRIMMenuChangeGroupPrice];
        }
            break;
        default:
            break;
    }
    
    [self SlideInout];
}

- (void)showViewFromViewController:(UIViewController*)viewController  WithViewType:(ItemManagementVCType )menuItemId {
    
    if (IsPhone()) {
        [self.navigationController pushViewController:[self createNewViewControllerWithType:menuItemId] animated:YES];
    }
    else {
        [self.currentActiveVC.view removeFromSuperview];
        [self.currentActiveVC removeFromParentViewController];
        viewController.view.frame = self.itemManagementView.bounds;
        [self addChildViewController:viewController];
        [self.itemManagementView addSubview:viewController.view];
    }

    self.currentActiveVC=viewController;
}

#pragma mark - SideMenuVCDelegate -

-(void)willPushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self.navigationController pushViewController:viewController animated:animated];
}

-(UIViewController *)willPopViewControllerAnimated:(BOOL)animated{
    UIViewController * popedVC = [self.navigationController popViewControllerAnimated:animated];
    return popedVC;
}

-(void)willPresentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion{
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

-(void)willDismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion{
    [self dismissViewControllerAnimated:flag completion:completion];
}

- (UIViewController *)viewContorllerFor:(ItemManagementVCType)vcType
{
    UIViewController *vcToDisplay= nil;
    switch (vcType) {
        case IM_InventoryManagement:
            vcToDisplay = self.itemManagementNavigationController;
            break;
        case IM_InactiveItemManagement:
            vcToDisplay = self.InactiveitemList;
            break;
        case IM_NewOrderScannerView:
            vcToDisplay = self.objInvenInIpad;
            break;
        case IM_InventoryOutScannerView:
            vcToDisplay = self.objInvenOutIpad;
            break;
        case IM_OpenOrderViewController:
            vcToDisplay = self.objOpenOrder;
            break;
        case IM_CloseOrderViewController:
            vcToDisplay = self.objCloseOrder;
            break;
        case IM_InventoryCountView:
            vcToDisplay = self.objInventoryCountIpad;
            break;
        case IM_SupplierInventoryView:
            vcToDisplay = self.objSupplierInvenIpad;
            break;
        case IM_DepartmentView:
            vcToDisplay = self.objDepartmentViewIpad;
            break;
        case IM_TaxMaster:
            vcToDisplay = self.objTaxMasterIpad;
            break;
        case IM_PaymentMaster:
            vcToDisplay = self.objPaymentMasterIpad;
            break;
        case IM_MixMatch:
            vcToDisplay = self.objMixMatchViewIpad;
            break;
        case IM_Supplier:
            vcToDisplay = self.objSupplierViewIpad;
            break;
        case IM_Group:
            vcToDisplay = self.objGroupViewIpad;
            break;
        case IM_SubDepartment:
            vcToDisplay = self.objSubDepartmentIpad;
            break;
        case IM_GroupModifier:
            vcToDisplay = self.objGroupModifierIpad;
            break;
        case IM_GroupItemModifier:
            vcToDisplay = self.objItemModifierIpad;
            break;
            
        default:
            break;
    }
    return vcToDisplay;
}

- (void)showViewController:(ItemManagementVCType)vcType {
    UIViewController *vcToDisplay = nil;
    vcToDisplay = [self viewContorllerFor:vcType];
    if(vcToDisplay) {
        [self showViewFromViewController:vcToDisplay WithViewType:vcType];
    }
}
-(void)showViewControllerFromPopUpMenu:(ItemManagementVCType)vcType {
    
    Class TypeOfVC=[self GetClass:vcType];
    NSArray * ListVC = self.navigationController.viewControllers;
    for (int i=0; i<ListVC.count; i++) {
        
        UIViewController * pushedView=ListVC[i];
        if ([pushedView isMemberOfClass:TypeOfVC] ) {
            
            if (vcType == IM_InventoryManagement) {
                
                InventoryItemListVC * objSelVC=(InventoryItemListVC *) pushedView;
                if (objSelVC.isItemActive) {
                    [self.navigationController popToViewController:pushedView animated:YES];
                    return;
                }
            }
            else if (vcType == IM_InactiveItemManagement) {
                
                InventoryItemListVC * objSelVC=(InventoryItemListVC *) pushedView;
                if (!objSelVC.isItemActive) {
                    
                    [self.navigationController popToViewController:pushedView animated:YES];
                    return;
                }
            }
            else{
                
                [self.navigationController popToViewController:pushedView animated:YES];
                return;
            }
        }
    }
    UIViewController * pushingVC=[self createNewViewControllerWithType:vcType];
    [self.navigationController pushViewController:pushingVC animated:YES];
    
}
-(Class)GetClass:(ItemManagementVCType)vcType {
    Class returnClass;
    switch (vcType) {
        case IM_InventoryManagement: {
            returnClass=[InventoryItemListVC class];
            break;
        }
        case IM_InactiveItemManagement: {
            returnClass=[InventoryItemListVC class];
            break;
        }
        case IM_DepartmentView: {
            returnClass=[RimDepartmentVC class];
            break;
        }
        case IM_SubDepartment: {
            returnClass=[SubDepartmentVC class];
            break;
        }
        case IM_GroupModifier: {
            returnClass=[GroupModifierListVC class];
            break;
        }
        case IM_GroupItemModifier: {
            returnClass=[ItemModifierListVC class];
            break;
        }
        case IM_NewOrderScannerView: {
            returnClass=[NewOrderScannerView class];
            break;
        }
        case IM_InventoryOutScannerView: {
            returnClass=[InventoryOutScannerView class];
            break;
        }
        case IM_OpenOrderViewController: {
            returnClass=[OpenOrderVC class];
            break;
        }
        case IM_CloseOrderViewController: {
            returnClass=[CloseOrderVC class];
            break;
        }

        case IM_SupplierInventoryView: {
            returnClass=[SupplierInventoryVC class];
            break;
        }
        case IM_TaxMaster: {
            returnClass=[TaxMasterListVC class];
            break;
        }
        case IM_PaymentMaster: {
            returnClass=[PaymentMasterListVC class];
            break;
        }
            
            
        default: {
            break;
        }
    }
    return returnClass;
}

-(UIViewController *)createNewViewControllerWithType:(ItemManagementVCType)vcType {
    
    UIViewController * viewController;
    switch (vcType) {
        case IM_InventoryManagement: {
            //InventoryManagement
            InventoryItemListVC * inventoryManagement = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemListVC_sid"];
            inventoryManagement.sideMenuVCDelegate = self;
            inventoryManagement.isItemActive = TRUE;
            viewController = inventoryManagement;
            
//            [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemListVC_sid"];
//            inventoryManagement.sideMenuVCDelegate = self;
//            inventoryManagement.isItemActive = TRUE;
            
            break;
        }
        case IM_InactiveItemManagement: {
            //Inactive item list
            
            InventoryItemListVC * unActiveinventoryManagement = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemListVC_sid"];
            unActiveinventoryManagement.sideMenuVCDelegate = self;
            unActiveinventoryManagement.isItemActive = FALSE;
            viewController = unActiveinventoryManagement;
            break;
        }
        case IM_DepartmentView: {
            // Department
            RimDepartmentVC *departmentVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimDepartmentVC_sid"];
            departmentVC.sideMenuVCDelegate = self;
            viewController = departmentVC;
            break;
        }
            
        case IM_TaxMaster: {
            TaxMasterListVC *taxMasterListVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"TaxMasterListVC_sid"];
            taxMasterListVC.sideMenuVCDelegate = self;
            viewController = taxMasterListVC;
            break;
        }
            
        case IM_PaymentMaster: {
            PaymentMasterListVC *paymentMasterListVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"PaymentMasterListVC_sid"];
            paymentMasterListVC.sideMenuVCDelegate = self;
            viewController = paymentMasterListVC;
            break;
        }
        case IM_SubDepartment: {
            //SubDepartment
            SubDepartmentVC *subDepartmentVC = [storyRim instantiateViewControllerWithIdentifier:@"SubDepartmentVC_sid"];
            subDepartmentVC.sideMenuVCDelegate = self;
            viewController = subDepartmentVC;
            break;
        }
        case IM_GroupModifier: {
            //Group Modifier
            GroupModifierListVC *groupModifier = [storyRim instantiateViewControllerWithIdentifier:@"GroupModifierListVC_sid"];
            groupModifier.sideMenuVCDelegate = self;
            viewController = groupModifier;
            break;
        }
        case IM_GroupItemModifier: {
            //Item Modifier of Group
            ItemModifierListVC *itemModifier = [storyRim instantiateViewControllerWithIdentifier:@"ItemModifierListVC_sid"];
            itemModifier.sideMenuVCDelegate = self;
            viewController = itemModifier;
            break;
        }
        case IM_NewOrderScannerView: {
            // InventoryIN
            NewOrderScannerView *inventoryInVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"NewOrderScannerView_sid"];
            inventoryInVC.sideMenuVCDelegate = self;
            inventoryInVC.isItemOrderUpdate=FALSE;
            inventoryInVC.managedObjectContext = self.rmsDbController.managedObjectContext;
            viewController = inventoryInVC;
            break;
        }
        case IM_InventoryOutScannerView: {
            // InvnetoryOUT
            InventoryOutScannerView *inventoryOutVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryOutScannerView_sid"];
            inventoryOutVC.isItemOrderUpdate=FALSE;
            inventoryOutVC.sideMenuVCDelegate = self;
            inventoryOutVC.managedObjectContext = self.rmsDbController.managedObjectContext;
            viewController = inventoryOutVC;
            break;
        }
        case IM_OpenOrderViewController: {
            // OpenOrder
            OpenOrderVC *openOrder = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"OpenOrderVC_sid"];
            openOrder.sideMenuVCDelegate = self;
            viewController = openOrder;
            break;
        }
        case IM_CloseOrderViewController: {
            // Close Order
            CloseOrderVC *closeOrderVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CloseOrderVC_sid"];
            closeOrderVC.sideMenuVCDelegate = self;
            viewController = closeOrderVC;
            break;
        }
        case IM_SupplierInventoryView: {
            // SupplierInventory
            SupplierInventoryVC *supplierVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"SupplierInventoryVC_sid"];
            supplierVC.sideMenuVCDelegate = self;
            viewController = supplierVC;
            break;
        }
        default: {
            break;
        }
    }
    return viewController;
}

-(UINavigationController *)getCurrentNavigationController {
    return self.navigationController;
}

#pragma mark - For Iphone only -

-(IBAction)btnCameraScanSearch:(id)sender
{
    self.cameraScanVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    [self presentViewController:self.cameraScanVC animated:YES completion:^{
        self.cameraScanVC.delegate = self;
    }];
}

#pragma mark - Camera Scan Delegate Methods

-(void)barcodeScanned:(NSString *)strBarcode
{
    _txtMainBarcode.text = strBarcode;
    [self textFieldShouldReturn:_txtMainBarcode];
}

#pragma mark UITextField Delegate Method

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField.text.length != 0){
        [self btn_UniversalItemSearchHome:nil];
    }
    return YES;
}

-(IBAction)btn_UniversalItemSearchHome:(id)sender {
    
    [self.rmsDbController playButtonSound];
    NSFetchRequest *fetchRequest;
    if (_txtMainBarcode.text != nil && ![_txtMainBarcode.text isEqualToString:@""]) {
        
        NSString * strSearchBarcode = _txtMainBarcode.text;
        BOOL isNumeric;
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:strSearchBarcode];
        isNumeric = [alphaNums isSupersetOfSet:inStringSet];
        if (isNumeric) // numeric
        {
            strSearchBarcode = [self.rmsDbController trimmedBarcode:strSearchBarcode];
        }
        fetchRequest = [self getFetchrequest:strSearchBarcode];
    }
    else
    {
        [_txtMainBarcode resignFirstResponder];
        return;
    }
    
    NSInteger isRecordFound = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
    
    if(isRecordFound == 0)
    {
        BOOL valid;
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:_txtMainBarcode.text];
        valid = [alphaNums isSupersetOfSet:inStringSet];
        if (valid) // numeric
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            
            NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
            [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
            NSString * strSearchBarcode = [self.rmsDbController trimmedBarcode:_txtMainBarcode.text];
            [itemparam setValue:strSearchBarcode forKey:@"Code"];
            [itemparam setValue:@"Barcode" forKey:@"Type"];
            
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self responseItemHomeDataResponse:response error:error];
                });
            };
            
            self.homeItemInsertWC = [self.homeItemInsertWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
        }
        else // non numeric
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                _txtMainBarcode.text = @"";
//                [status setString:@""];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"No item found." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            _txtMainBarcode.text = @"";
            [_txtMainBarcode becomeFirstResponder];
        }
    }
    else
    {
        //InventoryManagement
        InventoryItemListVC * inventoryManagement = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemListVC_sid"];
        inventoryManagement.sideMenuVCDelegate = self;
        inventoryManagement.isItemActive = TRUE;
        
        inventoryManagement.strSearchText = _txtMainBarcode.text;
        //hiten_28102014
        [self.navigationController pushViewController:inventoryManagement animated:TRUE];
    }
}

-(void)responseItemHomeDataResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]]   firstObject];
            
            NSMutableArray *itemResponseArray = [responseDictionary valueForKey:@"ItemArray"];
            if(itemResponseArray.count > 0)
            {
                [self.updateManagerItemHome updateObjectsFromResponseDictionary:responseDictionary];
                [self.updateManagerItemHome linkItemToDepartmentFromResponseDictionary:responseDictionary];
                //InventoryManagement
                InventoryItemListVC * inventoryManagement = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemListVC_sid"];
                inventoryManagement.sideMenuVCDelegate = self;
                inventoryManagement.isItemActive = TRUE;
                inventoryManagement.strSearchText = _txtMainBarcode.text;
                [self.navigationController pushViewController:inventoryManagement animated:TRUE];
            }
            else
            {
                [_txtMainBarcode resignFirstResponder];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    _txtMainBarcode.text = @"";
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    if(IsPhone())
                    {
//                        self.rimsController.scannerButtonCalled=@"InvAdd";
//                        ItemInfoEditVC *objInventoryAdd = [[UIStoryboard storyboardWithName:@"RimStoryboard_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];
//                        objInventoryAdd.strScanBarcode=_txtMainBarcode.text;
//                        [self.navigationController pushViewController:objInventoryAdd animated:YES];
                        ItemInfoEditVC * itemInfoEditVC = [[UIStoryboard storyboardWithName:@"RimStoryboard_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];
                        
                        if (itemInfoEditVC.itemInfoDataObject==nil) {
                            itemInfoEditVC.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
                        }
                        [itemInfoEditVC.itemInfoDataObject setItemMainDataFrom:nil];
                        itemInfoEditVC.isCopy = FALSE;
                        itemInfoEditVC.isInvenManageCalled = TRUE;
                        itemInfoEditVC.strScanBarcode = _txtMainBarcode.text;
                        [self.navigationController pushViewController:itemInfoEditVC animated:YES];

                    }
                    else // iPad Home page not avaiable
                    {
                        
                    }
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"No item found, are you sure you want to add item with new UPC?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
            }

        }
    }
}

-(NSFetchRequest *)getFetchrequest:(NSString *)strSearchWord {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    fetchRequest.predicate = [self searchPredicateForText:strSearchWord];
    
    return fetchRequest;
}
-(NSPredicate *)searchPredicateForText:(NSString *)searchData {
//    barcodeSearch.searchText = searchData;
    BOOL isNumeric;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:searchData];
    isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) { // numeric
//        barcodeSearch.barcode = searchData;
        searchData = [self.rmsDbController trimmedBarcode:searchData];
//        barcodeSearch.modifiedBarCode = searchData;
    }
    else {
//        barcodeSearch.barcode = @"";
//        barcodeSearch.modifiedBarCode = @"";
    }
    NSMutableCharacterSet *separators = [[NSMutableCharacterSet alloc] init];
    [separators addCharactersInString:@","];
    
    NSMutableArray *textArray = [[searchData componentsSeparatedByCharactersInSet:separators] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;
    
    dbFields = @[ @"item_Desc contains[cd] %@",@"item_No == %@", @"barcode == [cd] %@", @"item_Remarks BEGINSWITH[cd] %@",@"itemDepartment.deptName BEGINSWITH[cd] %@", @"ANY itemBarcodes.barCode == %@",@"ANY itemTags.tagToSizeMaster.sizeName contains[cd] %@"];
    
    for (int i=0; i<textArray.count; i++) {
        NSString *str=textArray[i];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *searchTextPredicates = [NSMutableArray array];
        for (NSString *dbField in dbFields) {
            if (![str isEqualToString:@""]) {
                [searchTextPredicates addObject:[NSPredicate predicateWithFormat:dbField, str]];
            }
        }
        NSPredicate *compoundpred = [NSCompoundPredicate orPredicateWithSubpredicates:searchTextPredicates];
        [fieldWisePredicates addObject:compoundpred];
    }
    [fieldWisePredicates addObjectsFromArray:[self defaultFilterForItem]];
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
    return finalPredicate;
}

-(NSArray *)defaultFilterForItem {
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itm_Type != %@ AND active == %d AND isNotDisplayInventory == %@",@(-1),1,@(0)];
    [fieldWisePredicates addObject:predicate];
    return fieldWisePredicates;
}
//-(NSPredicate *)searchPredicateForText:(NSString *)searchData
//{
//    NSMutableArray *textArray=[[searchData componentsSeparatedByString:@","] mutableCopy];
//    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
//    
//    NSArray *dbFields = @[ @"item_Desc contains[cd] %@", @"barcode == %@", @"item_Remarks BEGINSWITH[cd] %@",@"itemDepartment.deptName BEGINSWITH[cd] %@"];
//    for (int i=0; i<textArray.count; i++)
//    {
//        NSString *str=textArray[i];
//        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//        
//        NSMutableArray *searchTextPredicates = [NSMutableArray array];
//        for (NSString *dbField in dbFields)
//        {
//            if (![str isEqualToString:@""])
//            {
//                [searchTextPredicates addObject:[NSPredicate predicateWithFormat:dbField, str]];
//            }
//        }
//        NSPredicate *compoundpred = [NSCompoundPredicate orPredicateWithSubpredicates:searchTextPredicates];
//        [fieldWisePredicates addObject:compoundpred];
//    }
//    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
//    return finalPredicate;
//}

#pragma DTDevice Delegate Methods
#ifdef LINEAPRO_SUPPORTED

-(void)connectionState:(int)state
{
    switch (state) {
        case CONN_DISCONNECTED:
        case CONN_CONNECTING:
            break;
        case CONN_CONNECTED:
            break;
    }
}

-(void)deviceButtonPressed:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"Home"])
        {
            _txtMainBarcode.text = @"";
        }
    }
}

-(void)deviceButtonReleased:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"Home"])
        {
            if(![_txtMainBarcode.text isEqualToString:@""] )
            {
                [_txtMainBarcode resignFirstResponder];
                [self btn_UniversalItemSearchHome:nil];
            }
        }
    }
}

-(void)barcodeData:(NSString *)barcode type:(int)type
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        _txtMainBarcode.text = barcode;
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please set Scanner type as Scanner." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}
#endif

@end
@implementation RIMMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
