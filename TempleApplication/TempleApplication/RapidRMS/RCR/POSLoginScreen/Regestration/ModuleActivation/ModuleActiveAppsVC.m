//
//  ActiveAppsVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/9/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ModuleActiveAppsVC.h"
#import "RmsDbController.h"
#import "AsyncImageView.h"
#import "UserActivationViewController.h"
#import "UpdateManager.h"
#import "Keychain.h"

@interface ModuleActiveAppsVC ()
{
    UIImageView *imgBackGround;
    UILabel *lblDeviceName;
    UIButton *btnChecked;
    UILabel *lblStatus;
    UILabel *lblAvailableCount;
    UILabel *lblModuleName;
    
    UILabel *lblActiveDeviceName;
    NSIndexPath *clickedIndexpath;
    NSString *strCOMCOD;
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic,weak) IBOutlet UITableView *tblActive;

@property (nonatomic,strong) NSMutableArray *deactiveDevResult;
@property (nonatomic,strong) NSMutableArray *activeDevResult;
@property (nonatomic,strong) NSMutableArray *arrTempActive;
@property (nonatomic,strong) NSMutableArray *arrTempDeActive;

/// Rcr And Rim Active User Array
@property (nonatomic,strong) NSMutableArray *arrRcrActiveUser;
@property (nonatomic,strong) NSMutableArray *arrRimActiveUser;
@property (nonatomic,strong) NSMutableArray *arrPurChaseOrderUser;
@property (nonatomic,strong) NSMutableArray *arrCustomerDispUser;
@property (nonatomic,strong) NSMutableArray *arrRcrGasActiveUser;
@property (nonatomic,strong) NSMutableArray *arrRestaurentDispUser;
@property (nonatomic,strong) NSMutableArray *arrRestRcrActiveUser;

@property (nonatomic ,strong) RapidWebServiceConnection *deviceSetupWC;

@end

@implementation ModuleActiveAppsVC
@synthesize moduleActiveApps;
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
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.deviceSetupWC = [[RapidWebServiceConnection alloc] init];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    [self configureParameters];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)getCurrentDeviceNameFirst:(NSMutableArray *)tempModuleArray
{
    for (int i =0 ; i<tempModuleArray.count; i++) {
        NSMutableDictionary *dict = tempModuleArray[i];
        if ([[dict valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]])
        {
            [tempModuleArray removeObjectAtIndex:i];
            [tempModuleArray insertObject:dict atIndex:0];
            break;
        }
    }
}

/*-(void)viewWillAppear:(BOOL)animated
 {
 [super viewWillAppear:animated];
 if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
 {
 self.navigationController.navigationBarHidden = YES;
 }
 }
 
 -(void)viewWillDisappear:(BOOL)animated
 {
 [super viewWillDisappear:animated];
 if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
 {
 self.navigationController.navigationBarHidden = NO;
 }
 }*/

-(NSMutableArray *)createModuleWiseList:(int)moduleId
{
    NSPredicate *rcrPredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d", moduleId];
    NSMutableArray *arrActiveUser = [[self.activeDevResult filteredArrayUsingPredicate:rcrPredicate] mutableCopy ];
    [self getCurrentDeviceNameFirst:arrActiveUser];
    return arrActiveUser;
}

- (void)configureParameters
{
    self.deactiveDevResult = [[NSMutableArray alloc] init];
    self.activeDevResult = [[NSMutableArray alloc] init];
    
    self.arrTempActive = [[NSMutableArray alloc] init];
    self.arrTempDeActive = [[NSMutableArray alloc] init];
    self.arrRimActiveUser = [[NSMutableArray alloc] init];
    self.arrRcrActiveUser = [[NSMutableArray alloc] init];
    self.arrPurChaseOrderUser = [[NSMutableArray alloc]init];
    self.arrCustomerDispUser = [[NSMutableArray alloc]init];
    self.arrRcrGasActiveUser = [[NSMutableArray alloc]init];
    self.arrRestaurentDispUser = [[NSMutableArray alloc]init];
    self.arrRestRcrActiveUser = [[NSMutableArray alloc]init];
    
    NSMutableArray *activeDevice = [self.rmsDbController.appsActvDeactvSettingarray.firstObject valueForKey:@"objDeviceInfo"];
    
    strCOMCOD = self.rmsDbController.appsActvDeactvSettingarray.firstObject[@"COMCOD"];
    
    int temp = 0;
    int temp2 = 1;
    
    // Inactive Table
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"IsActive == %d", temp];
    self.deactiveDevResult = [[activeDevice filteredArrayUsingPredicate:deactive] mutableCopy ];
    
    // Active Table
    NSPredicate *active = [NSPredicate predicateWithFormat:@"IsActive == %d", temp2];
    self.activeDevResult = [[activeDevice filteredArrayUsingPredicate:active] mutableCopy ];
    self.arrTempActive = [self.activeDevResult mutableCopy];
    
    // Rim And Rcr Predicate
    int rcr = 1;
    int rim = 2;
    int purChase = 3;
    int Rcd = 4;
    int rcrGas = 5;
    int rrcr = 6; // Restaurant - 6
    int rrrcr = 7; // Restaurant + Retail - 7
    
    self.arrRcrActiveUser = [self createModuleWiseList:rcr];
    self.arrRimActiveUser = [self createModuleWiseList:rim];
    self.arrPurChaseOrderUser = [self createModuleWiseList:purChase];
    self.arrCustomerDispUser = [self createModuleWiseList:Rcd];
    self.arrRcrGasActiveUser = [self createModuleWiseList:rcrGas];
    self.arrRestaurentDispUser = [self createModuleWiseList:rrcr];
    self.arrRestRcrActiveUser = [self createModuleWiseList:rrrcr];
    
    [self.tblActive reloadData];
}

-(void)fieldAllocation
{
    
    lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(500, 15, 100, 25)];
    lblActiveDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    btnChecked = [[UIButton alloc] initWithFrame:CGRectMake(638, 10, 28, 23)];
    lblActiveDeviceName=[[UILabel alloc]initWithFrame:CGRectMake(20, 10, 250, 25)];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"     Cash Register";
    }
    else if(section == 1)
    {
        return @"     Inventory Management";
    }
    else if(section == 2)
    {
        return @"     Purchase Order";
    }
    else if(section == 3)
    {
        return @"     Customer Display";
    }
    else if(section == 4)
    {
        return @"     Cash Register + Gas";
    }
    else if(section == 5)
    {
        return @"     Restaurant";
    }
    else if(section == 6)
    {
        return @"     Restaurant + Retail";
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(tableView == self.tblActive)
    {
        if (section == 0) {
            return self.arrRcrActiveUser.count;
        }
        else if(section == 1)
        {
            return self.arrRimActiveUser.count;
        }
        else if(section == 2)
        {
            return self.arrPurChaseOrderUser.count;
        }
        else if(section == 3)
        {
            return self.arrCustomerDispUser.count;
        }
        else if(section == 4)
        {
            return self.arrRcrGasActiveUser.count;
        }
        else if(section == 5)
        {
            return self.arrRestaurentDispUser.count;
        }
        else if(section == 6)
        {
            return self.arrRestRcrActiveUser.count;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    if (tableView == self.tblActive)
    {
        [self fieldAllocation];
        
        imgBackGround.image = [UIImage imageNamed:@"activeDeviceImg.png"];
        [cell.contentView addSubview:imgBackGround];
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0)
            {
                if ([[(self.arrRcrActiveUser)[indexPath.row] valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]])
                {
                    lblActiveDeviceName.textColor = [UIColor colorWithRed:0.0/255 green:125.0/255 blue:255/255 alpha:1.0];
                }
            }
            else
            {
                lblActiveDeviceName.textColor = [UIColor blackColor];
            }
            
            lblActiveDeviceName.text = [NSString stringWithFormat:@"%@",[(self.arrRcrActiveUser)[indexPath.row] valueForKey:@"RegisterName"]];
            
            
            [cell.contentView addSubview:lblActiveDeviceName];
            
            
            
            if([[(self.arrRcrActiveUser)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
            {
                [btnChecked setImage:nil forState:UIControlStateNormal];
                
            }
            else
            {
                [btnChecked setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:btnChecked];
            }
            [cell.contentView addSubview:lblStatus];
        }
        
        else if(indexPath.section == 1)
        {
            if (indexPath.row == 0) {
                if ([[(self.arrRimActiveUser)[indexPath.row] valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]])
                {
                    lblActiveDeviceName.textColor = [UIColor colorWithRed:0.0/255 green:125.0/255 blue:255/255 alpha:1.0];
                }
            }
            else
            {
                lblActiveDeviceName.textColor = [UIColor blackColor];
            }
            
            lblActiveDeviceName.text = [NSString stringWithFormat:@"%@",[(self.arrRimActiveUser)[indexPath.row] valueForKey:@"RegisterName"]];
            
            [cell.contentView addSubview:lblActiveDeviceName];
            
            
            
            if([[(self.arrRimActiveUser)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
            {
                [btnChecked setImage:nil forState:UIControlStateNormal];
            }
            else
            {
                [btnChecked setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:btnChecked];
            }
            [cell.contentView addSubview:lblStatus];
        }
        
        else if(indexPath.section == 2)
        {
            if (indexPath.row == 0) {
                if ([[(self.arrPurChaseOrderUser)[indexPath.row] valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]])
                {
                    lblActiveDeviceName.textColor = [UIColor colorWithRed:0.0/255 green:125.0/255 blue:255/255 alpha:1.0];
                }
            }
            else
            {
                lblActiveDeviceName.textColor = [UIColor blackColor];
            }
            
            lblActiveDeviceName.text = [NSString stringWithFormat:@"%@",[(self.arrPurChaseOrderUser)[indexPath.row] valueForKey:@"RegisterName"]];
            
            [cell.contentView addSubview:lblActiveDeviceName];
            
            if([[(self.arrPurChaseOrderUser)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
            {
                [btnChecked setImage:nil forState:UIControlStateNormal];
            }
            else
            {
                [btnChecked setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:btnChecked];
            }
            [cell.contentView addSubview:lblStatus];
        }
        else if(indexPath.section == 3)
        {
            if (indexPath.row == 0) {
                if ([[(self.arrCustomerDispUser)[indexPath.row] valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]])
                {
                    lblActiveDeviceName.textColor = [UIColor colorWithRed:0.0/255 green:125.0/255 blue:255/255 alpha:1.0];
                }
            }
            else
            {
                lblActiveDeviceName.textColor = [UIColor blackColor];
            }
            lblActiveDeviceName.text = [NSString stringWithFormat:@"%@",[(self.arrCustomerDispUser)[indexPath.row] valueForKey:@"RegisterName"]];
            [cell.contentView addSubview:lblActiveDeviceName];
            
            if([[(self.arrCustomerDispUser)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
            {
                [btnChecked setImage:nil forState:UIControlStateNormal];
            }
            else
            {
                [btnChecked setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:btnChecked];
            }
            [cell.contentView addSubview:lblStatus];
        }
        else if(indexPath.section == 4)
        {
            if (indexPath.row == 0) {
                if ([[(self.arrRcrGasActiveUser)[indexPath.row] valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]])
                {
                    lblActiveDeviceName.textColor = [UIColor colorWithRed:0.0/255 green:125.0/255 blue:255/255 alpha:1.0];
                }
            }
            else
            {
                lblActiveDeviceName.textColor = [UIColor blackColor];
            }
            lblActiveDeviceName.text = [NSString stringWithFormat:@"%@",[(self.arrRcrGasActiveUser)[indexPath.row] valueForKey:@"RegisterName"]];
            [cell.contentView addSubview:lblActiveDeviceName];
            
            if([[(self.arrRcrGasActiveUser)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
            {
                [btnChecked setImage:nil forState:UIControlStateNormal];
            }
            else
            {
                [btnChecked setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:btnChecked];
            }
            [cell.contentView addSubview:lblStatus];
        }
        else if(indexPath.section == 5)
        {
            if (indexPath.row == 0) {
                if ([[(self.arrRestaurentDispUser)[indexPath.row] valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]])
                {
                    lblActiveDeviceName.textColor = [UIColor colorWithRed:0.0/255 green:125.0/255 blue:255/255 alpha:1.0];
                }
            }
            else
            {
                lblActiveDeviceName.textColor = [UIColor blackColor];
            }
            lblActiveDeviceName.text = [NSString stringWithFormat:@"%@",[(self.arrRestaurentDispUser)[indexPath.row] valueForKey:@"RegisterName"]];
            [cell.contentView addSubview:lblActiveDeviceName];
            
            if([[(self.arrRestaurentDispUser)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
            {
                [btnChecked setImage:nil forState:UIControlStateNormal];
            }
            else
            {
                [btnChecked setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:btnChecked];
            }
            [cell.contentView addSubview:lblStatus];
        }
        else if(indexPath.section == 6)
        {
            if (indexPath.row == 0) {
                if ([[(self.arrRestRcrActiveUser)[indexPath.row] valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]])
                {
                    lblActiveDeviceName.textColor = [UIColor colorWithRed:0.0/255 green:125.0/255 blue:255/255 alpha:1.0];
                }
            }
            else
            {
                lblActiveDeviceName.textColor = [UIColor blackColor];
            }
            lblActiveDeviceName.text = [NSString stringWithFormat:@"%@",[(self.arrRestRcrActiveUser)[indexPath.row] valueForKey:@"RegisterName"]];
            [cell.contentView addSubview:lblActiveDeviceName];
            
            if([[(self.arrRestRcrActiveUser)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
            {
                [btnChecked setImage:nil forState:UIControlStateNormal];
            }
            else
            {
                [btnChecked setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:btnChecked];
            }
            [cell.contentView addSubview:lblStatus];
        }
        
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tblActive)
    {
        if (indexPath.section == 0)
        {
            NSMutableDictionary *dictTemp = (self.arrRcrActiveUser)[indexPath.row];
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
                UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Active Apps" message:@"Are you sure you want to deactive this package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                reqPer.tag = 2;
                [reqPer show];
                
            }
            (self.arrRcrActiveUser)[indexPath.row] = dictTemp;
        }
        else if (indexPath.section == 1)
        {
            NSMutableDictionary *dictTemp = (self.arrRimActiveUser)[indexPath.row];
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
                UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Active Apps" message:@"Are you sure you want to deactive this package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                reqPer.tag = 2;
                [reqPer show];
                
                // [dictTemp setObject:@"0" forKey:@"IsActive"];
            }
            (self.arrRimActiveUser)[indexPath.row] = dictTemp;
            
        }
        else if (indexPath.section == 2)
        {
            NSMutableDictionary *dictTemp = (self.arrPurChaseOrderUser)[indexPath.row];
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
                UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Active Apps" message:@"Are you sure you want to deactive this package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                reqPer.tag = 2;
                [reqPer show];
            }
            (self.arrPurChaseOrderUser)[indexPath.row] = dictTemp;
            
        }
        else if (indexPath.section == 3)
        {
            NSMutableDictionary *dictTemp = (self.arrCustomerDispUser)[indexPath.row];
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
                UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Active Apps" message:@"Are you sure you want to deactive this package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                reqPer.tag = 2;
                [reqPer show];
            }
            (self.arrCustomerDispUser)[indexPath.row] = dictTemp;
        }
        else if (indexPath.section == 4)
        {
            NSMutableDictionary *dictTemp = (self.arrRcrGasActiveUser)[indexPath.row];
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
                UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Active Apps" message:@"Are you sure you want to deactive this package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                reqPer.tag = 2;
                [reqPer show];
            }
            (self.arrRcrGasActiveUser)[indexPath.row] = dictTemp;
        }
        else if (indexPath.section == 5)
        {
            NSMutableDictionary *dictTemp = (self.arrRestaurentDispUser)[indexPath.row];
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
                UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Active Apps" message:@"Are you sure you want to deactive this package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                reqPer.tag = 2;
                [reqPer show];
            }
            (self.arrRestaurentDispUser)[indexPath.row] = dictTemp;
        }
        else if (indexPath.section == 6)
        {
            NSMutableDictionary *dictTemp = (self.arrRestRcrActiveUser)[indexPath.row];
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
                UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Active Apps" message:@"Are you sure you want to deactive this package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                reqPer.tag = 2;
                [reqPer show];
            }
            (self.arrRestRcrActiveUser)[indexPath.row] = dictTemp;
        }
        
        [self.tblActive reloadData];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 2) // To Deactive module in Active table
    {
        if(buttonIndex == 1)
        {
            if (clickedIndexpath.section == 0) {
                NSMutableDictionary *dictSelected= (self.arrRcrActiveUser)[clickedIndexpath.row];
                dictSelected[@"IsActive"] = @"0";
                (self.arrRcrActiveUser)[clickedIndexpath.row] = dictSelected;
                [self.arrTempDeActive addObject:dictSelected];
            }
            if (clickedIndexpath.section == 1) {
                NSMutableDictionary *dictSelected = (self.arrRimActiveUser)[clickedIndexpath.row];
                dictSelected[@"IsActive"] = @"0";
                (self.arrRimActiveUser)[clickedIndexpath.row] = dictSelected;
                [self.arrTempDeActive addObject:dictSelected];
            }
            if (clickedIndexpath.section == 2) {
                NSMutableDictionary *dictSelected = (self.arrPurChaseOrderUser)[clickedIndexpath.row];
                dictSelected[@"IsActive"] = @"0";
                (self.arrPurChaseOrderUser)[clickedIndexpath.row] = dictSelected;
                [self.arrTempDeActive addObject:dictSelected];
            }
            if (clickedIndexpath.section == 3) {
                NSMutableDictionary *dictSelected = (self.arrCustomerDispUser)[clickedIndexpath.row];
                dictSelected[@"IsActive"] = @"0";
                (self.arrCustomerDispUser)[clickedIndexpath.row] = dictSelected;
                [self.arrTempDeActive addObject:dictSelected];
            }
            if (clickedIndexpath.section == 4) {
                NSMutableDictionary *dictSelected = (self.arrRcrGasActiveUser)[clickedIndexpath.row];
                dictSelected[@"IsActive"] = @"0";
                (self.arrRcrGasActiveUser)[clickedIndexpath.row] = dictSelected;
                [self.arrTempDeActive addObject:dictSelected];
            }
            if (clickedIndexpath.section == 5) {
                NSMutableDictionary *dictSelected = (self.arrRestaurentDispUser)[clickedIndexpath.row];
                dictSelected[@"IsActive"] = @"0";
                (self.arrRestaurentDispUser)[clickedIndexpath.row] = dictSelected;
                [self.arrTempDeActive addObject:dictSelected];
            }
            if (clickedIndexpath.section == 6) {
                NSMutableDictionary *dictSelected = (self.arrRestRcrActiveUser)[clickedIndexpath.row];
                dictSelected[@"IsActive"] = @"0";
                (self.arrRestRcrActiveUser)[clickedIndexpath.row] = dictSelected;
                [self.arrTempDeActive addObject:dictSelected];
            }
            
            [self.tblActive reloadData];
        }
        
    }
    
    
    else if (alertView.tag == 3)
    {
        
        [moduleActiveApps goTODeviceActivation];
        
        
        
        
    }
    else if (alertView.tag == 4)
    {
        if (buttonIndex == 1) // Yes Button Clicked
        {
            [self modulesActiveDeActive];
        }
    }
    
}

-(IBAction)btnDone:(id)sender
{
    
    
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSMutableArray *activeModulesArray = [[self.arrTempDeActive filteredArrayUsingPredicate:deactive] mutableCopy ];
    
    NSArray * uniqueArray = [self.activeDevResult valueForKeyPath:@"@distinctUnionOfObjects.ModuleId"];
    
    if(activeModulesArray.count == uniqueArray.count)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Active Apps" message:@"Do you want to delete all modules from this Device?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
        alert.tag = 4;
        [alert show];
    }
    else
    {
        [self modulesActiveDeActive];
    }
    
}
-(void)modulesActiveDeActive
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * dictDeviceActivation = [[NSMutableDictionary alloc] init];
    dictDeviceActivation[@"BranchId"] = @"1";
    dictDeviceActivation[@"COMCOD"] = strCOMCOD;
    NSString *registerName = (self.rmsDbController.globalDict)[@"RegisterName"];
    if(registerName == nil)
    {
        registerName = @"";
    }
    dictDeviceActivation[@"RegisterName"] = registerName;
    dictDeviceActivation[@"MacAdd"] = (self.rmsDbController.globalDict)[@"DeviceId"];
    dictDeviceActivation[@"dType"] = @"IOS-RCRIpad";
    dictDeviceActivation[@"dVersion"] = [UIDevice currentDevice].systemVersion;
    dictDeviceActivation[@"TokenId"] = (self.rmsDbController.globalDict)[@"TokenId"];
    dictDeviceActivation[@"ApplicationType"] = @"";
    
    dictDeviceActivation[@"DeactiveDeviceInfo"] = [self getDeactiveDeviceData];
    
    dictDeviceActivation[@"activeDeviceInfo"] = [self getactiveDeviceData];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self responseSettingActiveDeviceSetupResponse:response error:error];
    };
    
    self.deviceSetupWC = [self.deviceSetupWC initWithRequest:KURL actionName:WSM_DEVICE_SETUP params:dictDeviceActivation completionHandler:completionHandler];
}

- (NSMutableArray *) getDeactiveDeviceData
{
    NSMutableArray *arrDeActiveDeviceInfo = [[NSMutableArray alloc] init];
    
    if(self.arrTempDeActive.count>0)
    {
        for (int isup=0; isup<self.arrTempDeActive.count; isup++) {
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
    
    /*   if([self.arrTempActive count]>0)
     {
     for (int isup=0; isup<[self.arrTempActive count]; isup++) {
     NSMutableDictionary *tmpSup=[[self.arrTempActive objectAtIndex:isup] mutableCopy ];
     
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
     }*/
	return arrActiveDevice;
}

- (void)responseSettingActiveDeviceSetupResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if([[response valueForKey:@"IsError"] intValue] == 0)
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Active Apps" message:response[@"Data"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
