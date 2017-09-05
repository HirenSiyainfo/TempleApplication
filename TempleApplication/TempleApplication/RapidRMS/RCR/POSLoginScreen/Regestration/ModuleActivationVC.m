//
//  ModuleActivationVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 04/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ModuleActivationVC.h"
#import "RmsDbController.h"
#import "DashBoardSettingVC.h"
#import "Configuration+Dictionary.h"
#import "Configuration.h"
#import "RimsController.h"
#import "Keychain.h"
#import "UserActivationViewController.h"
#import "UpdateManager.h"
#import "ModuleApplicationSettingVC.h"
#import "ModuleAvailableAppsViewController.h"
#import "ModuleActiveAppsVC.h"
#import "HConfigurationVC.h"

//#import "ModuleActivationCustomCell.h"

@interface ModuleActivationVC ()
{
    NSIndexPath *clickedIndexpath;
    int moduleCount;
    
    ModuleAvailableAppsViewController *moduleappsAvailable;
    
    ModuleApplicationSettingVC *moduleapplicationSettingVC;
    ModuleActiveAppsVC *moduleactiveAppsVC;
}

@property (nonatomic, weak) IBOutlet UILabel *lblCurrentDate;
@property (nonatomic, weak) IBOutlet UIView *uvButtonNavigation;
@property (nonatomic, weak) IBOutlet UIView *uvNotActivatedApps;
@property (nonatomic, weak) IBOutlet UIView *uvActiveApps;
@property (nonatomic, weak) IBOutlet UIView *uvOthers;
@property (nonatomic, weak) IBOutlet UILabel *lblActiveMenuName;
@property (nonatomic, weak) IBOutlet UIView *uvMenuInnerView;
@property (nonatomic, weak) IBOutlet UIView *uvConformation;
@property (nonatomic, weak) IBOutlet UIButton *btnNotActivated;
@property (nonatomic, weak) IBOutlet UIButton *btnActiveApp;
@property (nonatomic, weak) IBOutlet UIButton *btnOthers;
@property (nonatomic, weak) IBOutlet UIButton *btnCancel;
@property (nonatomic, weak) IBOutlet UITextField *txtRegisterName;
@property (nonatomic, weak) IBOutlet UIView *appsSettingView;
@property (nonatomic, weak) IBOutlet UITableView *tblNotActivated;
@property (nonatomic, weak) IBOutlet UITableView *tblActive;
@property (nonatomic, weak) IBOutlet UITableView *tblAlertview;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic,strong) NSMutableArray *deactiveDevResult;
@property (nonatomic,strong) NSMutableArray *activeDevResult;
@property (nonatomic,strong) NSMutableArray *arrTempActive;
@property (nonatomic,strong) NSMutableArray *arrTempDeActive;
@property (nonatomic,strong) NSMutableArray *displayModuleData;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController *_rimController;
@property (nonatomic, strong) RapidWebServiceConnection *deviceSetupWC;

@end

@implementation ModuleActivationVC
@synthesize arrDeviceAuthentication;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize updateManager;

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.rmsDbController.appsActvDeactvSettingarray=self.arrDeviceAuthentication;
    self.deviceSetupWC = [[RapidWebServiceConnection alloc] init];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self._rimController = [RimsController sharedrimController];
         
         self.deactiveDevResult = [[NSMutableArray alloc] init];
         self.activeDevResult = [[NSMutableArray alloc] init];
         
         self.displayModuleData = [[NSMutableArray alloc] init];
         
         self.arrTempActive = [[NSMutableArray alloc] init];
         self.arrTempDeActive = [[NSMutableArray alloc] init];
         self.managedObjectContext = self.rmsDbController.managedObjectContext;
         
         _uvConformation.hidden = YES;
         
         self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
         
         NSMutableArray *activeDevice = [arrDeviceAuthentication.firstObject valueForKey:@"objDeviceInfo"];
         
         int temp = 0;
         int temp2 = 1;
         
         // Inactive Table
         NSPredicate *deactive = [NSPredicate predicateWithFormat:@"IsActive == %d", temp];
         self.deactiveDevResult = [[activeDevice filteredArrayUsingPredicate:deactive] mutableCopy ];
         
         NSArray * uniqueArray = [self.deactiveDevResult valueForKeyPath:@"@distinctUnionOfObjects.ModuleId"];
         for (NSNumber *moduleId in uniqueArray) {
         NSPredicate *moduleIdPre = [NSPredicate predicateWithFormat:@"ModuleId == %@", moduleId];
         NSArray *tempArray = [self.deactiveDevResult filteredArrayUsingPredicate:moduleIdPre];
         if(tempArray.count > 0)
         {
         NSMutableDictionary *moduleDict = [tempArray.firstObject mutableCopy ];
         moduleDict[@"Count"] = @(tempArray.count);
         [self.displayModuleData addObject:moduleDict];
         }
         }
         
         // Active Table
         NSPredicate *active = [NSPredicate predicateWithFormat:@"IsActive == %d", temp2];
         self.activeDevResult = [[activeDevice filteredArrayUsingPredicate:active] mutableCopy ];
         self.arrTempActive = [self.activeDevResult mutableCopy];
         
         [self.tblNotActivated reloadData];
         [self.tblActive reloadData];
         
         if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
         {
         _uvMenuInnerView.layer.borderWidth = 1.0;
         _uvMenuInnerView.layer.borderColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0].CGColor;
         
         _uvButtonNavigation.hidden = YES;
         
         [_btnNotActivated setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         _btnNotActivated.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
         
         [_btnActiveApp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         _btnActiveApp.backgroundColor = [UIColor whiteColor ];
         
         [_btnOthers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         _btnOthers.backgroundColor = [UIColor whiteColor ];
         
         [_btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         _btnCancel.backgroundColor = [UIColor whiteColor ];
         }
         else
         {
         _uvButtonNavigation.layer.borderWidth = 1.0;
         _uvButtonNavigation.layer.borderColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0].CGColor;
         
         [_btnNotActivated setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         _btnNotActivated.backgroundColor = [UIColor whiteColor];
         
         [_btnActiveApp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         _btnActiveApp.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
         
         [_btnOthers setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         _btnOthers.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
         }
         
         _uvNotActivatedApps.hidden = NO;
         _uvActiveApps.hidden = YES;
         _uvOthers.hidden = YES;
    }
    else
    {
        [self goToAppsetting];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    _lblCurrentDate.text = [formatter stringFromDate:date];
}

-(IBAction)btnMenuClicked:(id)sender
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if(screenBounds.size.height == 568)
    {
        _uvButtonNavigation.frame = CGRectMake(10, 338, 150, 187);
    }
    else
    {
        _uvButtonNavigation.frame = CGRectMake(10, 250, 150, 187);
    }
    _uvButtonNavigation.hidden = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _uvButtonNavigation.hidden = YES;
    }
}

-(IBAction)btnNotActivatedClicked:(id)sender
{
    _uvNotActivatedApps.hidden = NO;
    _uvActiveApps.hidden = YES;
    _uvOthers.hidden = YES;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _lblActiveMenuName.text = @"Not Activated Apps";
        
        [_btnNotActivated setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnNotActivated.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        
        [_btnActiveApp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnActiveApp.backgroundColor = [UIColor whiteColor];
        
        [_btnOthers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnOthers.backgroundColor = [UIColor whiteColor ];
        
        [_btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnCancel.backgroundColor = [UIColor whiteColor ];
        
        _uvButtonNavigation.hidden = YES;
    }
    else
    {
        [_btnNotActivated setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnNotActivated.backgroundColor = [UIColor whiteColor];
        
        [_btnActiveApp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnActiveApp.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        
        [_btnOthers setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnOthers.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    }
    
    [self.tblNotActivated reloadData];
}

-(IBAction)btnActiveClicked:(id)sender
{
    _uvNotActivatedApps.hidden = YES;
    _uvActiveApps.hidden = NO;
    _uvOthers.hidden = YES;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _lblActiveMenuName.text = @"Active Apps";
        
        [_btnActiveApp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnActiveApp.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        
        [_btnNotActivated setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnNotActivated.backgroundColor = [UIColor  whiteColor];
        
        [_btnOthers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnOthers.backgroundColor = [UIColor whiteColor];
        
        [_btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnCancel.backgroundColor = [UIColor whiteColor ];
        
        _uvButtonNavigation.hidden = YES;
    }
    else
    {
        [_btnActiveApp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnActiveApp.backgroundColor = [UIColor whiteColor];
        
        [_btnNotActivated setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnNotActivated.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        
        [_btnOthers setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnOthers.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    }
    [self.tblActive reloadData];
    
}

-(IBAction)btnOthersClicked:(id)sender
{
    _uvNotActivatedApps.hidden = YES;
    _uvActiveApps.hidden = YES;
    _uvOthers.hidden = NO;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _lblActiveMenuName.text = @"Others";
        
        [_btnOthers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnOthers.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        
        [_btnActiveApp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnActiveApp.backgroundColor = [UIColor whiteColor];
        
        [_btnNotActivated setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnNotActivated.backgroundColor = [UIColor whiteColor];
        
        [_btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnCancel.backgroundColor = [UIColor whiteColor ];
        
        _uvButtonNavigation.hidden = YES;
    }
    else
    {
        [_btnOthers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnOthers.backgroundColor = [UIColor whiteColor];
        
        [_btnActiveApp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnActiveApp.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        
        [_btnNotActivated setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnNotActivated.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    }
}

#pragma mark -
#pragma mark TextFiled Delegate method

//call when press return key in keyboard.
- (BOOL) textFieldShouldReturn:(UITextField *)textFiled {
	[textFiled resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark UITableView Delegate method

-(void)fieldAllocation
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        imgBackGround = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 60, 60)];
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, 250, 25)];
        lblAvailableCount = [[UILabel alloc] initWithFrame:CGRectMake(75, 40, 150, 25)];
        lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(185, 40, 100, 25)];
        btnChecked = [[UIButton alloc] initWithFrame:CGRectMake(260, 40, 28, 23)];
        lblActiveDeviceName=[[UILabel alloc]initWithFrame:CGRectMake(75, 40, 200, 25)];
    }
    else
    {
        imgBackGround = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 70, 60)];
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(100, 15, 250, 25)];
        lblAvailableCount = [[UILabel alloc] initWithFrame:CGRectMake(100, 40, 150, 25)];
        lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(500, 20, 100, 25)];
        btnChecked = [[UIButton alloc] initWithFrame:CGRectMake(625, 20, 28, 23)];
        lblActiveDeviceName=[[UILabel alloc]initWithFrame:CGRectMake(100, 45, 200, 25)];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblAlertview)
    {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblAlertview)
    {
        if (section == 0) // Active section
        {
            return self.arrTempActive.count;
        }
        if (section == 1) // Deactive section
        {
            return self.arrTempDeActive.count;
        }
    }
    if(tableView == self.tblNotActivated)
    {
        return self.displayModuleData.count;
    }
    if(tableView == self.tblActive)
    {
        return self.activeDevResult.count;
    }
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == self.tblAlertview)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 430, 28)];
        
        UILabel *lblModuleType;
        UILabel *lblModuleCount;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone )
        {
            lblModuleType = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
            lblModuleCount = [[UILabel alloc] initWithFrame:CGRectMake(250, 0, 50, 25)];
        }
        else
        {
            lblModuleType = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
            lblModuleCount = [[UILabel alloc] initWithFrame:CGRectMake(380, 0, 50, 25)];
        }
        
        lblModuleType.textColor = [UIColor colorWithRed:2.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        lblModuleCount.textColor = [UIColor colorWithRed:43.0/255.0 green:192.0/255.0 blue:142.0/255.0 alpha:1.0];
        
        [headerView addSubview:lblModuleType];
        [headerView addSubview:lblModuleCount];
        
        if(section == 0) {
            lblModuleType.text = @"Activating";
            lblModuleCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.arrTempActive.count ];
        }
        if(section == 1) {
            lblModuleType.text = @"Deactivating";
            lblModuleCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.arrTempDeActive.count ];
        }
        return headerView;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == self.tblAlertview)
    {
        return 28;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    }
    
    if (tableView == self.tblNotActivated) // NotActive Tableview
    {
        [self fieldAllocation];
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if(([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] != 2) && ([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] != 3) && ([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] != 8) )
            {
                cell.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
                
                lblDeviceName.textColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
                
                lblAvailableCount.textColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
            }
        }
        
        AsyncImageView* oldImage = (AsyncImageView *)
        [cell.contentView viewWithTag:999];
        [oldImage removeFromSuperview];
        
        imgBackGround.image = [UIImage imageNamed:@"activeDeviceImg.png"];
        [cell.contentView addSubview:imgBackGround];
        
        AsyncImageView* itemImage = nil;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 58, 58)];
        }
        else
        {
            itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 68, 58)];
        }
        
        itemImage.tag = 999;
        itemImage.backgroundColor = [UIColor clearColor];
        itemImage.image = [UIImage imageNamed:@"noimage.png"];
        [cell.contentView addSubview:itemImage];
        
        lblDeviceName.text = [NSString stringWithFormat:@"%@",[(self.displayModuleData)[indexPath.row] valueForKey:@"Name"] ];
        lblDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
        [cell.contentView addSubview:lblDeviceName];
        
        lblAvailableCount.text = [NSString stringWithFormat:@"%@ - Available",[(self.displayModuleData)[indexPath.row] valueForKey:@"Count"]];
        lblAvailableCount.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        [cell.contentView addSubview:lblAvailableCount];
        
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if(([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] == 2) || ([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] == 3) || ([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] == 8))
            {
                if([[(self.displayModuleData)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
                {
                    lblStatus.text = @"Not Active";
                    lblStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
                    lblStatus.textColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
                }
                else
                {
                    lblStatus.text = @"Active";
                    lblStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
                    lblStatus.textColor = [UIColor colorWithRed:43.0/255.0 green:192.0/255.0 blue:142.0/255.0 alpha:1.0];
                    
                    [btnChecked setImage:[UIImage imageNamed:@"DeviceActiveArrow.png"] forState:UIControlStateNormal];
                    [cell.contentView addSubview:btnChecked];
                }
                [cell.contentView addSubview:lblStatus];
            }
        }
        else
        {
            if([[(self.displayModuleData)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
            {
                lblStatus.text = @"Not Active";
                lblStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
                lblStatus.textColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
            }
            else
            {
                lblStatus.text = @"Active";
                lblStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
                lblStatus.textColor = [UIColor colorWithRed:43.0/255.0 green:192.0/255.0 blue:142.0/255.0 alpha:1.0];
                
                [btnChecked setImage:[UIImage imageNamed:@"DeviceActiveArrow.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:btnChecked];
            }
            [cell.contentView addSubview:lblStatus];
        }
        
    }
    if (tableView == self.tblActive) // Active UITableview
    {
        [self fieldAllocation];
        
        AsyncImageView* oldImage = (AsyncImageView *)
        [cell.contentView viewWithTag:999];
        [oldImage removeFromSuperview];
        
        imgBackGround.image = [UIImage imageNamed:@"activeDeviceImg.png"];
        [cell.contentView addSubview:imgBackGround];
        
        AsyncImageView* itemImage = nil;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 58, 58)];
        }
        else
        {
            itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 68, 58)];
        }
        itemImage.tag = 999;
        itemImage.backgroundColor = [UIColor clearColor];
        itemImage.image = [UIImage imageNamed:@"noimage.png"];
        [cell.contentView addSubview:itemImage];
        
        lblDeviceName.text = [NSString stringWithFormat:@"%@",[(self.activeDevResult)[indexPath.row] valueForKey:@"Name"]];
        lblDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
        [cell.contentView addSubview:lblDeviceName];
        
        lblActiveDeviceName.text = [NSString stringWithFormat:@"%@",[(self.activeDevResult)[indexPath.row] valueForKey:@"RegisterName"]];
        lblActiveDeviceName.textColor = [UIColor grayColor];
        lblActiveDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
        [cell.contentView addSubview:lblActiveDeviceName];
        
        if([[(self.activeDevResult)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
        {
            lblStatus.text = @"Not Active";
            lblStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            lblStatus.textColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        }
        else
        {
            lblStatus.text = @"Active";
            lblStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            lblStatus.textColor = [UIColor colorWithRed:43.0/255.0 green:192.0/255.0 blue:142.0/255.0 alpha:1.0];
            
            [btnChecked setImage:[UIImage imageNamed:@"DeviceActiveArrow.png"] forState:UIControlStateNormal];
            [cell.contentView addSubview:btnChecked];
        }
        [cell.contentView addSubview:lblStatus];
    }
    if(tableView == self.tblAlertview) // Conformation Tableview
    {
        [self fieldAllocation];
        
        if(indexPath.section == 0)
        {
            AsyncImageView* oldImage = (AsyncImageView *)
            [cell.contentView viewWithTag:999];
            [oldImage removeFromSuperview];
            
            imgBackGround.image = [UIImage imageNamed:@"activeDeviceImg.png"];
            [cell.contentView addSubview:imgBackGround];
            
            AsyncImageView* itemImage = nil;
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 58, 58)];
            }
            else
            {
                itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 68, 58)];
            }
            itemImage.tag = 999;
            itemImage.backgroundColor = [UIColor clearColor];
            itemImage.image = [UIImage imageNamed:@"noimage.png"];
            [cell.contentView addSubview:itemImage];
            
            lblDeviceName.text = [NSString stringWithFormat:@"%@",[(self.arrTempActive)[indexPath.row] valueForKey:@"Name"]];
            lblDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            [cell.contentView addSubview:lblDeviceName];
        }
        
        if(indexPath.section == 1)
        {
            AsyncImageView* oldImage = (AsyncImageView *)
            [cell.contentView viewWithTag:999];
            [oldImage removeFromSuperview];
            
            imgBackGround.image = [UIImage imageNamed:@"activeDeviceImg.png"];
            [cell.contentView addSubview:imgBackGround];
            
            AsyncImageView* itemImage = nil;
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 58, 58)];
            }
            else
            {
                itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 68, 58)];
            }
            itemImage.tag = 999;
            itemImage.backgroundColor = [UIColor clearColor];
            itemImage.image = [UIImage imageNamed:@"noimage.png"];
            [cell.contentView addSubview:itemImage];
            
            lblDeviceName.text = [NSString stringWithFormat:@"%@",[(self.arrTempDeActive)[indexPath.row] valueForKey:@"Name"]];
            lblDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            [cell.contentView addSubview:lblDeviceName];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblNotActivated)
    {
        NSMutableDictionary *dictSelected = (self.displayModuleData)[indexPath.row];
        
        if([[dictSelected valueForKey:@"IsActive"] integerValue ] == 0 )
        {
            clickedIndexpath = [indexPath copy];
            
            
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                if(([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] == 2) || ([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] == 3)  || ([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] == 8))
                {
                    UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Are you sure you want to Active this Package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                    reqPer.tag = 1;
                    [reqPer show];
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
            NSInteger recordCount = [[dictSelected valueForKey:@"Count"] integerValue ];
            dictSelected[@"Count"] = @(recordCount + 1);
            
            for (int i = 0 ; i < self.arrTempActive.count ; i++)
            {
                NSMutableDictionary *dict = [(self.arrTempActive)[i] mutableCopy ];
                if([[dict valueForKey:@"Id" ] integerValue ] == [[dictSelected valueForKey:@"Id"] integerValue])
                {
                    [self.arrTempActive removeObjectAtIndex:i];
                }
            }
        }
        
        (self.displayModuleData)[indexPath.row] = dictSelected;
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
    return 75;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1) // To active Module in inactive table
    {
        if(buttonIndex == 1)
        {
            NSMutableDictionary *dictSelected = (self.displayModuleData)[clickedIndexpath.row];
            dictSelected[@"IsActive"] = @"1";
            dictSelected[@"MacAdd"] = (self.rmsDbController.globalDict)[@"DeviceId"];
            NSInteger recordCount = [[dictSelected valueForKey:@"Count"] integerValue ];
            dictSelected[@"Count"] = @(recordCount - 1);
            [self.arrTempActive addObject:dictSelected];
            (self.displayModuleData)[clickedIndexpath.row] = dictSelected;
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
            for (int isfnd = 0 ; isfnd < self.arrTempActive.count ; isfnd++)
            {
                NSMutableDictionary *dictActive = [(self.arrTempActive)[isfnd] mutableCopy ];
                if([[dictSelected valueForKey:@"Id" ] integerValue ] == [[dictActive valueForKey:@"Id"] integerValue])
                {
                    [self.arrTempActive removeObjectAtIndex:isfnd];
                }
            }
            [self.arrTempDeActive addObject:dictSelected];
            
            NSMutableDictionary *dictSelectedMoveToInactive = (self.activeDevResult)[clickedIndexpath.row];
            
            self.displayModuleData = [[NSMutableArray alloc] init];
            
//            [dictSelectedMoveToInactive setObject:@"0" forKey:@"IsActive"];
//            [dictSelectedMoveToInactive setObject:@"" forKey:@"MacAdd"];
//            [dictSelectedMoveToInactive setObject:@"" forKey:@"RegisterName"];
            
            [self.deactiveDevResult addObject:dictSelectedMoveToInactive];
            
            NSArray * uniqueArray = [self.deactiveDevResult valueForKeyPath:@"@distinctUnionOfObjects.ModuleId"];
            for (NSNumber *moduleId in uniqueArray) {
                NSPredicate *moduleIdPre = [NSPredicate predicateWithFormat:@"ModuleId == %@", moduleId];
                NSArray *tempArray = [self.deactiveDevResult filteredArrayUsingPredicate:moduleIdPre];
                if(tempArray.count > 0)
                {
                    NSMutableDictionary *moduleDict = [tempArray.firstObject mutableCopy ];
                    moduleDict[@"Count"] = @(tempArray.count);
                    [self.displayModuleData addObject:moduleDict];
                }
            }
            [self.activeDevResult removeObjectAtIndex:clickedIndexpath.row]; // Remove record which is deactivated
            
            [self.tblActive reloadData];
            [self.tblNotActivated reloadData];
        }
        else
        {
            [self.tblActive reloadData];
        }
    }
}

-(IBAction)btnCancelClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnNoClicked:(id)sender
{
    _uvConformation.hidden = YES;
}

-(IBAction)btnDoneClicked:(id)sender
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
    if(self.arrTempActive.count > 0)
    {
        if(_txtRegisterName.text.length == 0)
        {
            UIAlertView *nameAlert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Please Enter Your Device Name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [nameAlert show];
            return;
        }
        else
        {
            [self.tblAlertview reloadData];
            _uvConformation.hidden = NO;
            self.tblAlertview.scrollEnabled = YES;
        }
    }
    else
    {
        if(self.arrTempDeActive.count > 0)
        {
            [self.tblAlertview reloadData];
            _uvConformation.hidden = NO;
            self.tblAlertview.scrollEnabled = YES;
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Please Active or Deactive Module(s)." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(IBAction)btnYesClicked:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    //parameters: ModuleStatus[] activeDeviceInfo, ModuleStatus[] DeactiveDeviceInfo, long COMCOD, string RegisterName, string MacAdd, string dType, string dVersion, string TokenId, string ApplicationType
    
    NSMutableDictionary * dictDeviceActivation = [[NSMutableDictionary alloc] init];
    dictDeviceActivation[@"BranchId"] = @"1";
    dictDeviceActivation[@"COMCOD"] = arrDeviceAuthentication.firstObject[@"COMCOD"];
    dictDeviceActivation[@"RegisterName"] = _txtRegisterName.text;
    dictDeviceActivation[@"MacAdd"] = (self.rmsDbController.globalDict)[@"DeviceId"];
    dictDeviceActivation[@"dType"] = @"IOS-RCRIpad";
    dictDeviceActivation[@"dVersion"] = [UIDevice currentDevice].systemVersion;
    dictDeviceActivation[@"TokenId"] = (self.rmsDbController.globalDict)[@"TokenId"];
    dictDeviceActivation[@"ApplicationType"] = @"";
    
    dictDeviceActivation[@"DeactiveDeviceInfo"] = [self getModuleDeactiveDeviceData];
    
    dictDeviceActivation[@"activeDeviceInfo"] = [self getModuleActiveDeviceData];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self deviceSetupResponse:response error:error];
    };
    
    self.deviceSetupWC = [self.deviceSetupWC initWithRequest:KURL actionName:WSM_DEVICE_SETUP params:dictDeviceActivation completionHandler:completionHandler];
}

- (NSMutableArray *) getModuleDeactiveDeviceData
{
    NSMutableArray *arrDeActiveDeviceInfo = [[NSMutableArray alloc] init];
    
    if(self.arrTempDeActive.count>0)
    {
        for (int isup=0; isup<self.arrTempDeActive.count; isup++) {
            NSMutableDictionary *tmpSup=[(self.arrTempDeActive)[isup] mutableCopy ];
            // Id, IsActive, ModuleId
            
            [tmpSup removeObjectForKey:@"DBName"];
            [tmpSup removeObjectForKey:@"MacAdd"];
            [tmpSup removeObjectForKey:@"ModuleCode"];
            [tmpSup removeObjectForKey:@"ModuleType"];
            [tmpSup removeObjectForKey:@"RegisterName"];
            [tmpSup removeObjectForKey:@"ConfigurationId"];
            [tmpSup removeObjectForKey:@"Name"];
            
            [arrDeActiveDeviceInfo addObject:tmpSup];
        }
    }
	return arrDeActiveDeviceInfo;
}

- (NSMutableArray *) getModuleActiveDeviceData
{
    NSMutableArray *arrActiveDevice = [[NSMutableArray alloc] init];
    
    if(self.arrTempActive.count>0)
    {
        for (int isup=0; isup<self.arrTempActive.count; isup++) {
            NSMutableDictionary *tmpSup=[(self.arrTempActive)[isup] mutableCopy ];
            
            // Id, IsActive, ModuleId
            [tmpSup removeObjectForKey:@"DBName"];
            [tmpSup removeObjectForKey:@"MacAdd"];
            [tmpSup removeObjectForKey:@"ModuleCode"];
            [tmpSup removeObjectForKey:@"ModuleType"];
            [tmpSup removeObjectForKey:@"RegisterName"];
            [tmpSup removeObjectForKey:@"ConfigurationId"];
            [tmpSup removeObjectForKey:@"Name"];
            [tmpSup removeObjectForKey:@"Count"];
            [arrActiveDevice addObject:tmpSup];
        }
    }
	return arrActiveDevice;
}

- (void)deviceSetupResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *responseData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                
                (self.rmsDbController.globalDict)[@"BranchID"] = [responseData valueForKey:@"BranchId"];
                (self.rmsDbController.globalDict)[@"RegisterId"] = [responseData valueForKey:@"RegisterId"];
                (self.rmsDbController.globalDict)[@"ZId"] = [responseData valueForKey:@"ZId"];
                (self.rmsDbController.globalDict)[@"ZRequired"] = [responseData valueForKey:@"ZRequired"];
                (self.rmsDbController.globalDict)[@"RegisterName"] = [responseData valueForKey:@"RegisterName"];
                
                NSMutableArray *arryBranch=[responseData valueForKey:@"Branch_MArray"];
                if(arryBranch.count>0)
                {
                    NSMutableArray *responseBranchArray=[arryBranch mutableCopy];
                    
                    (self.rmsDbController.globalDict)[@"BranchInfo"] = responseBranchArray.firstObject;
                }
                
                self.rmsDbController.appsActvDeactvSettingarray = [responseData valueForKey:@"objDeviceInfo"];
                
                if([UIDevice currentDevice ].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ModuleCode==%@ && IsActive ==%@ && MacAdd==%@",@"VMS",@(1),self.rmsDbController.globalDict[@"DeviceId"]];
                    NSArray *arrayCount = [self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:predicate];
                    
                    if(arrayCount.count>0 && ![self isVendorActive])
                    {
                        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                        HConfigurationVC *objStoreVC = [storyBoard instantiateViewControllerWithIdentifier:@"HConfigurationVC"];
                        objStoreVC.dictBranchInfo=arryBranch.firstObject;
                        [self.navigationController pushViewController:objStoreVC animated:YES];
                        return;
                        
                    }
                    else{
                        
                        
                    }
                    
                }
                else
                {
                    UIViewController *rootViewController = nil;
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
                        [self.navigationController popToViewController:rootViewController animated:NO];
                    }
                    
                    self.rmsDbController.isRegisterFirstTime=TRUE;
                    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                    
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
                    [UpdateManager saveContext:privateContextObject];
                }
                
                [self.rmsDbController getItemDataFirstTime];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 2)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:response[@"Data"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                if([UIDevice currentDevice ].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    UserActivationViewController *objUser = [[UserActivationViewController alloc] initWithNibName:@"UserActivationVC_iPhone" bundle:nil];
                    [self.navigationController pushViewController:objUser animated:YES];
                }
                else
                {
                    UserActivationViewController *objUser = [[UserActivationViewController alloc] initWithNibName:@"UserActivationViewController" bundle:nil];
                    [self.navigationController pushViewController:objUser animated:YES];
                }
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:response[@"Data"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

-(BOOL)isVendorActive{
    
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


#pragma Ipad Module Actication Functionality

-(void)goToAppsetting
{
    moduleapplicationSettingVC=[[ModuleApplicationSettingVC alloc]initWithNibName:@"ModuleApplicationSettingVC" bundle:nil];
    availableAppsNav=[[UINavigationController alloc]initWithRootViewController:moduleapplicationSettingVC];
    availableAppsNav.view.frame = _appsSettingView.bounds;
    moduleapplicationSettingVC.moduleAvailableApps=self;
    [_appsSettingView addSubview:availableAppsNav.view];
    
    _appsSettingView.hidden = NO;
    [self.view bringSubviewToFront:_appsSettingView];
    
}
-(void)goToAvailableAppsMenu
{
    moduleappsAvailable=[[ModuleAvailableAppsViewController alloc]initWithNibName:@"ModuleAvailableAppsViewController" bundle:nil];
    //appsAvailable.dashAvailableApps = self;
    moduleappsAvailable.moduelAvailableApps=self;
    [availableAppsNav pushViewController:moduleappsAvailable animated:true];
}

-(void)goToActiveAppsMenu
{
    moduleactiveAppsVC=[[ModuleActiveAppsVC alloc]initWithNibName:@"ModuleActiveAppsVC" bundle:nil];
    moduleactiveAppsVC.moduleActiveApps = self;
    [availableAppsNav pushViewController:moduleactiveAppsVC animated:true];
}
-(void)goTODeviceActivation
{
    UserActivationViewController *objUser = [[UserActivationViewController alloc] initWithNibName:@"UserActivationViewController" bundle:nil];
    [self.navigationController pushViewController:objUser animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end