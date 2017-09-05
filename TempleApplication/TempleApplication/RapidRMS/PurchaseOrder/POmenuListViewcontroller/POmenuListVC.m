//
//  POmenuListVC.m
//  RapidRMS
//
//  Created by Siya on 04/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "POmenuListVC.h"
#import "GenerateOrderView.h"
#import "OpenListVC.h"
#import "OpenListFilterVC.h"
#import "DeliveryListVC.h"
#import "CloseListVC.h"
#import "RmsDbController.h"
#import "InventoryManagement.h"
#import "RimsController.h"
//#import "InventoryAddNewSplitterVC.h"
//#import "ItemMultipleSelectionVC.h"
#import "SideMenuPOViewController.h"

#import "CKOCalendarViewController.h"
#import "POmenuListDelegateVC.h"
#import "POSideMenuCustomCell.h"
#import "RmsDashboardVC.h"
#import "RimLoginVC.h"
#import "RcrPosVC.h"
#import "RcrPosRestaurantVC.h"
#import "POOrderHistroy.h"

@interface POmenuListVC () <UIPopoverControllerDelegate,SideMenuPODelegate,POmenuListVCDelegate>
{
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnPurchaseOrder;
@property (nonatomic, weak) IBOutlet UIButton *btnOpenList;
@property (nonatomic, weak) IBOutlet UIButton *btnDeliveryOrder;
@property (nonatomic, weak) IBOutlet UIButton *btnCloseList;
@property (nonatomic, weak) IBOutlet UIView *uvLoadSideView;
@property (nonatomic, weak) IBOutlet UIView *sideMenuView;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UIView *generalOrderView;
@property (nonatomic, weak) IBOutlet UIButton *btnBackButtonClick;
@property (nonatomic, weak) IBOutlet UILabel *currenctDate;
@property (nonatomic, weak) IBOutlet UITableView *tblMenuOperation;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) GenerateOrderView *objGenerateOrderIpad;
@property (nonatomic, strong) OpenListVC *objOpenListIpad;
@property (nonatomic, strong) OpenListFilterVC *objOpenListFilterIpad;
@property (nonatomic, strong) DeliveryListVC *objDeliveryListIpad;
@property (nonatomic, strong) CloseListVC *objCloseListIpad;


@property (nonatomic, strong) SideMenuPOViewController *objSideMenuMainPO;

@property (nonatomic, strong) UIViewController *currentActiveVC;
@property (nonatomic, strong) UIPopoverController *calendarPopOverController;
@property (nonatomic, strong) UINavigationController *PONavigationController;


@property (nonatomic, strong) NSArray *menuList;
@property (nonatomic, strong) NSArray *menuImageList;


@property (nonatomic, assign) BOOL boolSideMenuView;

@property (nonatomic, strong) NSIndexPath *indPath;

@end

@implementation POmenuListVC


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
    
    self.boolSideMenuView=FALSE;
    self.PONavigationController = [[UINavigationController alloc] init];
    self.menuList = [NSArray arrayWithObjects:@"GENERATE ORDER",@"OPEN ORDER",@"PENDING ORDER",@"DELIVERY PENDING", @"ORDER HISTROY",@"LOG OUT",@"DASHBOARD", nil];
    
    self.menuImageList = [NSArray arrayWithObjects:@"po_menu_generateorder.png",@"po_menu_openorder.png",@"po_menu_pendingorder.png",@"po_menu_deliverypending.png", @"po_menu_orderhistory.png",@"po_menu_logout.png",@"po_menu_dashboard.png", nil];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.btnBackButtonClick.hidden=YES;
//    self.rimController.objPOMenuList=self;
    
    
    [self loadSideManuMainPO];
    [self updateDateLabels];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    // Do any additional setup after loading the view from its nib.
}

-(void)loadSideManuMainPO{
    
    self.objSideMenuMainPO = [[SideMenuPOViewController alloc] initWithNibName:@"SideMenuPOViewController" bundle:nil];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.objSideMenuMainPO.view.frame = self.generalOrderView.bounds;
//        [self.generalOrderView addSubview:self.objSideMenuMainPO.view];
        UINib *nib = [UINib nibWithNibName:@"POSideMenuCustomCell" bundle:nil];
        [self.tblMenuOperation registerNib:nib forCellReuseIdentifier:@"POSideMenuCustomCell"];
        self.indPath=[NSIndexPath indexPathForRow:-1 inSection:0];
    }
    else {
        self.objSideMenuMainPO.view.frame = CGRectMake(-320.0, 0, 320.0, self.objSideMenuMainPO.view.frame.size.height);
        [self menuButtonOperationCell:0];
        [self.view addSubview:self.objSideMenuMainPO.view];
    }
    self.objSideMenuMainPO.sideMenuPODelegate = self;
    
}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

-(IBAction)POMenuHideShow:(id)sender{
    [self.view endEditing:YES];
    [self SlideInout];
}

-(void)SlideInout{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame;
        if(self.boolSideMenuView==FALSE)
        {
            frame = CGRectMake(0, 0,1024,768);
        }
        else{
            
            frame = CGRectMake(-320, 0,320,768);
        }
        self.objSideMenuMainPO.view.frame = frame;
        [self.view bringSubviewToFront:self.objSideMenuMainPO.view];
        
    } completion:^(BOOL finished) {
        if(self.boolSideMenuView==FALSE)
        {
            self.boolSideMenuView=TRUE;
        }
        else{
            
            self.boolSideMenuView=FALSE;
        }
        
    }];
    
}


- (void)updateDateLabels
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    self.currenctDate.text = [formatter stringFromDate:date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
}

-(void)menuButtonOperationCell:(NSInteger)ptag {

    UIViewController * objDisplayView;
    switch (ptag) {
        case 0:// Generate order
        {
            [self loadGenerateOrder];
            [Appsee addEvent:kPOMenuGenerateOrder];
            self.navigationItem.title = @"GENERATE ORDER";
            self.lblTitle.text=@"GENERATE ORDER";
            objDisplayView = self.objGenerateOrderIpad;
        }
        break;
        case 1:
        {
            [self loadOpenOrder];
            [Appsee addEvent:kPOMenuPurchaseOrderList];
            self.lblTitle.text=@"OPEN ORDER";
            self.navigationItem.title = @"OPEN ORDER";
            objDisplayView = self.objOpenListFilterIpad;
        }
            break;
        case 2:
        {
            [self loadPendingOrder];
            [Appsee addEvent:kPOMenuOpenOrder];
            self.lblTitle.text=@"PENDING ORDER";
            self.navigationItem.title = @"PENDING ORDER";
            objDisplayView = self.objOpenListIpad;
        }
            break;
        case 3:
        {
            [self loadDeliveryPanding];
            [Appsee addEvent:kPOMenuDeliveryPending];
            self.lblTitle.text=@"DELIVERY PENDING";
            self.navigationItem.title = @"DELIVERY PENDING";
            objDisplayView=self.objDeliveryListIpad;
        }
            break;
        case 4:
        {
            [self loadOrderHistroy];
            [Appsee addEvent:kPOMenuCloseOrder];
            self.lblTitle.text=@"ORDER HISTROY";
            self.navigationItem.title = @"ORDER HISTROY";
            objDisplayView=self.objCloseListIpad;
        }
            break;
        case 5: // LOG OUT
        {
            [self logoutFromPO];
        }
            break;
        case 6: // DASHBOARD VIEW
        {
            [self gotoDashboard];
        }
            break;
            
        default:
            break;
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:objDisplayView animated:YES];
    }
    else {
        UINavigationController * objNav=[[UINavigationController alloc]initWithRootViewController:objDisplayView];
        objNav.navigationBarHidden = TRUE;
        [self showViewFromViewController:objNav];
        [self.objSideMenuMainPO.tblMenuOperation reloadData];
    }
}
-(void)loadGenerateOrder{
   
    if(IsPad())
    {
        self.objGenerateOrderIpad = [[GenerateOrderView alloc] initWithNibName:@"GenerateOrderView" bundle:nil];
        self.objGenerateOrderIpad.pOmenuListVCDelegate = self;
        
    }
    else{
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
        self.objGenerateOrderIpad = [storyBoard instantiateViewControllerWithIdentifier:@"POGenerateOrder"];
        self.objGenerateOrderIpad.pOmenuListVCDelegate = self;
        
    }
}

-(void)loadOpenOrder{
    
    if(IsPad()){
        
        self.objOpenListFilterIpad = [[OpenListFilterVC alloc] initWithNibName:@"OpenListFilterVC" bundle:nil];
        self.objOpenListFilterIpad.pOmenuListVCDelegate = self;
        
    }
    else{
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
        self.objOpenListFilterIpad = [storyBoard instantiateViewControllerWithIdentifier:@"POOpenOrder"];
        self.objOpenListFilterIpad.pOmenuListVCDelegate = self;
    }
    

}

-(void)loadPendingOrder{
    
    if(IsPad()){
        
        self.objOpenListIpad = [[OpenListVC alloc] initWithNibName:@"OpenListVC" bundle:nil];
        self.objOpenListIpad.pOmenuListVCDelegate = self;
    }
    else{
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
        self.objOpenListIpad = [storyBoard instantiateViewControllerWithIdentifier:@"POPendingOrder"];
        self.objOpenListIpad.pOmenuListVCDelegate = self;
    }
}

-(void)loadDeliveryPanding{
   
    if(IsPad()){
        
        self.objDeliveryListIpad = [[DeliveryListVC alloc] initWithNibName:@"DeliveryListVC" bundle:nil];
        self.objDeliveryListIpad.pOmenuListVCDelegate = self;
    }
    
    else{
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
        self.objDeliveryListIpad = [storyBoard instantiateViewControllerWithIdentifier:@"PODeliveryPending"];
        self.objDeliveryListIpad.pOmenuListVCDelegate = self;
    }

}

-(void)loadOrderHistroy{
    
    if(IsPad()){
        
        self.objCloseListIpad = [[CloseListVC alloc] initWithNibName:@"CloseListVC" bundle:nil];
        self.objCloseListIpad.pOmenuListVCDelegate = self;
        
    }
    else{
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
        self.objCloseListIpad = [storyBoard instantiateViewControllerWithIdentifier:@"POOrderHistroy"];
        self.objCloseListIpad.pOmenuListVCDelegate = self;
    }
}
-(void)logoutFromPO{
 
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)gotoDashboard{
 
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (UIViewController *viewCon in viewControllers) {
        if([viewCon isKindOfClass:[RmsDashboardVC class]]){
            [self.navigationController popToViewController:viewCon animated:YES];
        }
    }
}
-(IBAction)backfromPo:(id)sender{
    
    [self logoutFromPO];
}

-(IBAction)menuButtonOperations:(id)sender
{
//    self._rimController.objPOMenuList.btnBackButtonClick.hidden=YES;
    if([sender tag]==7) // Logout Button Clicked
    {
    
        [self.navigationController popViewControllerAnimated:YES];
        

    }
    else{
        
    }
    
    
}

- (void)showViewFromViewController:(UIViewController*)viewController {

    [self.currentActiveVC.view removeFromSuperview];
    [self.currentActiveVC removeFromParentViewController];
    viewController.view.frame = self.generalOrderView.bounds;
    [self addChildViewController:viewController];
    [self.generalOrderView addSubview:viewController.view];
    self.currentActiveVC=viewController;
    
    return;

}

- (void)showInventoryAddNew:(Item *)item {
    if (self.generalOrderView.subviews.count == 0) {
        assert(false);
    } else {
    }
}

- (void)showInventoryAddNew:(NSMutableDictionary *)item navigationInfo:(NSDictionary*)navigationInfo {
    if (self.generalOrderView.subviews.count == 0) {
        assert(false);
    } else {
    }
}


- (void)showPurchaseOrderView {
    BOOL callFrameworkMethods = YES;
    if (self.generalOrderView.subviews.count == 0) {
        self.PONavigationController.view.frame = self.generalOrderView.bounds;
        [self.generalOrderView addSubview:self.PONavigationController.view];
        callFrameworkMethods = NO;
    }
    
    if (callFrameworkMethods) {
//        [self._rimController.poGeneralOrder viewWillAppear:YES];
    }
    self.generalOrderView.hidden = NO;
    if (callFrameworkMethods) {
//        [self._rimController.poGeneralOrder viewDidAppear:YES];
    }
    
    self.uvLoadSideView.hidden = YES;
}

- (void)showItemManagementView:(UIViewController *)itemMultipleSelectionVC
{
    
    BOOL callFrameworkMethods = YES;
    if (self.generalOrderView.subviews.count > 0) {
        // Need to setup
        NSArray *subViews = self.generalOrderView.subviews;
        for (int i = 0; i < subViews.count; i++) {
            UIView *aView = subViews[i];
            [aView removeFromSuperview];
        }
        callFrameworkMethods = NO;
        
    }
    self.lblTitle.text = @"Item Management";
    self.PONavigationController = [[UINavigationController alloc] initWithRootViewController:itemMultipleSelectionVC];
    self.PONavigationController.view.frame = self.generalOrderView.bounds;
    [self addChildViewController:self.PONavigationController];
    [self.generalOrderView addSubview:self.PONavigationController.view];
    if (callFrameworkMethods) {
        [itemMultipleSelectionVC viewWillAppear:YES];
    }
    if (callFrameworkMethods) {
        [itemMultipleSelectionVC viewDidAppear:YES];
    }
    self.generalOrderView.hidden = NO;
    self.uvLoadSideView.hidden = YES;
}

-(IBAction)btnDashboard:(UIButton *)sender
{
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
        }
    }
}
-(IBAction)btnLogout:(UIButton *)sender
{
    [self.rmsDbController playButtonSound];
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    for (UIViewController *vc in viewControllerArray)
    {
        if ([vc isKindOfClass:[RimLoginVC class]])
        {
            //[self cleanUpNavigationController];
            [self.navigationController popToViewController:vc animated:TRUE];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IPhone Menu -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    POSideMenuCustomCell *pOSideMenuCustomCell = (POSideMenuCustomCell *)[tableView dequeueReusableCellWithIdentifier:@"POMenuCustomCell"];
    
    if(IsPad()){
        
        NSString *normalImage = @"";
        NSString *highlightedImage = @"";
        
        Menu menu = indexPath.row;
        switch (menu) {
            case GenerateOrderMenu:
                normalImage = @"generateOrder_ipad.png";
                highlightedImage = @"generateOrderActive_ipad.png";
                break;
                
            case PurchaseOrderListMenu:
                normalImage = @"PurchaseOrderList_ipad.png";
                highlightedImage = @"PurchaseOrderListActive_ipad.png";
                break;
                
            case OpenOrderMenu:
                normalImage = @"openMenu_ipad_po.png";
                highlightedImage = @"openMenuActive_ipad.png";
                break;
                
            case DeliveryPendingMenu:
                normalImage = @"DeliveryPending_ipad.png";
                highlightedImage = @"DeliveryPendingActive_ipad.png";
                break;
                
            case CloseOrderMenu:
                normalImage = @"closeMenu_ipad_po.png";
                highlightedImage = @"closeMenuActive_ipad.png";
                break;
            default:
                break;
        }
        if (self.indPath.row == indexPath.row) {
            normalImage = highlightedImage;
        }
        
        [pOSideMenuCustomCell configaureImageViewWithNoramalImage:normalImage];
        [pOSideMenuCustomCell configaureImageViewWithHighlightedImage:highlightedImage];

    }
    else{
        pOSideMenuCustomCell.menuName.text = self.menuList[indexPath.row];
        pOSideMenuCustomCell.menuImg.image = [UIImage imageNamed:self.menuImageList[indexPath.row]];
    }
   
    
    
    return pOSideMenuCustomCell;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 45.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.indPath=indexPath;
    [self menuButtonOperationCell:indexPath.row];
    [tableView reloadData];
}


#pragma mark - POMenuListDelegate -
-(void)willPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.navigationController pushViewController:viewController animated:animated];
}

-(UIViewController *)willPopViewControllerAnimated:(BOOL)animated {
    return [self.navigationController popViewControllerAnimated:animated];
}

-(void)willPresentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion {
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

-(void)willDismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion {
    [self dismissViewControllerAnimated:flag completion:completion];
}

-(UINavigationController *)getPOmenuListNavigationController {
    return self.navigationController;
}
- (int)getCurrentSelectedMenu {
    return (int)self.objSideMenuMainPO.indPath.row;
}
@end
