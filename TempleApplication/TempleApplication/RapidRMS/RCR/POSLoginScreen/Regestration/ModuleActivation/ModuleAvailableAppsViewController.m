//
//  AvailableAppsViewController.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/7/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ModuleAvailableAppsViewController.h"
#import "RmsDbController.h"
#import "AsyncImageView.h"
#import "AvailableAppsCell.h"
#import "UpdateManager.h"
#import "Keychain.h"

@interface ModuleAvailableAppsViewController ()
{
    UIImageView *imgBackGround;
    UILabel *lblDeviceName;
    UIButton *btnChecked;
    UILabel *lblStatus;
    UILabel *lblAvailableCount;
    UILabel *lblActiveDeviceName;
    NSIndexPath *clickedIndexpath;
    NSString *strCOMCOD;

}
@property (nonatomic, weak) IBOutlet UITextField *txtRegisterName;
@property (nonatomic, weak) IBOutlet UITableView *tblNotActivated;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) NSMutableArray *deactiveDevResult;
@property (nonatomic, strong) NSMutableArray *activeDevResult;
@property (nonatomic, strong) NSMutableArray *arrTempActive;
@property (nonatomic, strong) NSMutableArray *arrTempDeActive;
@property (nonatomic, strong) NSMutableArray *displayModuleData;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *deviceSetupWC;
@end

@implementation ModuleAvailableAppsViewController
@synthesize moduelAvailableApps;
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
    
    self.deviceSetupWC = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.departmentUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    self.deactiveDevResult = [[NSMutableArray alloc] init];
    self.activeDevResult = [[NSMutableArray alloc] init];
    
    self.displayModuleData = [[NSMutableArray alloc] init];
    
    self.arrTempActive = [[NSMutableArray alloc] init];
    self.arrTempDeActive = [[NSMutableArray alloc] init];
    _txtRegisterName.text = (self.rmsDbController.globalDict)[@"RegisterName"];

    NSMutableArray *activeDevice = [self.rmsDbController.appsActvDeactvSettingarray.firstObject valueForKey:@"objDeviceInfo"];
    
    strCOMCOD = self.rmsDbController.appsActvDeactvSettingarray.firstObject[@"COMCOD"];

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

    
    NSPredicate *active = [NSPredicate predicateWithFormat:@"IsActive == %d", temp2];
    self.activeDevResult = [[activeDevice filteredArrayUsingPredicate:active] mutableCopy ];
    self.arrTempActive = [self.activeDevResult mutableCopy];
     [self.tblNotActivated registerNib:[UINib nibWithNibName:@"AvailableAppsCell" bundle:nil]forCellReuseIdentifier:@"AvailableAppsCell"];
    [self.tblNotActivated reloadData];
    // Do any additional setup after loading the view from its nib.
}

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
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(90, 15, 250, 25)];
        lblAvailableCount = [[UILabel alloc] initWithFrame:CGRectMake(100, 40, 35, 35)];
        lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(500, 20, 100, 25)];
        btnChecked = [[UIButton alloc] initWithFrame:CGRectMake(700, 23, 28, 23)];
        lblActiveDeviceName=[[UILabel alloc]initWithFrame:CGRectMake(100, 45, 200, 25)];
        lblAvailableCount.textAlignment = NSTextAlignmentCenter;
        lblAvailableCount.layer.borderWidth=0.8;
        lblAvailableCount.layer.cornerRadius = 5.0;
        lblAvailableCount.textColor = [UIColor whiteColor];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.displayModuleData.count;
}

-(NSString *)moduleNameAtIndex :(NSInteger)Index
{
    NSString *strMOduleName = [NSString stringWithFormat:@"     %@",[(self.displayModuleData)[Index] valueForKey:@"Name"]];
    return strMOduleName;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    if (section == 0)
//    {
        return  [self moduleNameAtIndex:section];
//    }
//    else if(section == 1)
//    {
//        return  [self moduleNameAtIndex:section];
//    }
//    else if(section == 2)
//    {
//        return  [self moduleNameAtIndex:section];
//    }
//    else if(section == 3)
//    {
//        return  [self moduleNameAtIndex:section];
//    }
//    else if(section == 4)
//    {
//        return  [self moduleNameAtIndex:section];
//    }
//    else if(section == 5)
//    {
//        return  [self moduleNameAtIndex:section];
//    }
//    return @"";
}

/*-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *customTitleView = [ [UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
    UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(20, 10, 300, 20)];
    
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    
    titleLabel.text = [self moduleNameAtIndex:section];
    
    titleLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:108.0/255.0 blue:108.0/255.0 alpha:1.0];
    
    titleLabel.backgroundColor = [UIColor clearColor];
    
    [customTitleView addSubview:titleLabel];
    
    return customTitleView;
    
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblNotActivated)
    {
//        if (section == 0) {
//            return  1;
//        }
//        if (section == 1) {
//            return  1;
//        }
//        if (section == 2) {
//            return  1;
//        }
//        if (section == 3) {
//            return  1;
//        }
//        if (section == 4) {
//            return  1;
//        }
//        if (section == 5) {
            return  1;
//        }
    }
    return 1;
}


- (void)setModuleNameAndCount:(NSIndexPath *)indexPath cell:(AvailableAppsCell *)cell
{
    cell.lblDeviceName.text = [NSString stringWithFormat:@"%@",[(self.displayModuleData)[indexPath.section] valueForKey:@"Name"] ];
    cell.lblDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    [cell.contentView addSubview:lblDeviceName];
    cell. lblAvailableCount.text = [NSString stringWithFormat:@"%@",[(self.displayModuleData)[indexPath.section] valueForKey:@"Count"]];
    cell.lblAvailableCount.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    [cell.contentView addSubview:lblAvailableCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AvailableAppsCell *cell = (AvailableAppsCell*)[tableView dequeueReusableCellWithIdentifier:@"AvailableAppsCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if (tableView == self.tblNotActivated) // NotActive Tableview
    {
        // [self fieldAllocation];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] != 2)
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
            itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 8, 56, 56)];
        }
        
        itemImage.tag = 999;
        itemImage.backgroundColor = [UIColor clearColor];
        itemImage.image = [UIImage imageNamed:@"noimage.png"];
        [cell.contentView addSubview:itemImage];
        
//        if (indexPath.section == 0) {
            [self setModuleNameAndCount:indexPath cell:cell];
//        }
        
        if (indexPath.section == 1) {
            cell.lblDeviceName.text = [NSString stringWithFormat:@"%@",[(self.displayModuleData)[indexPath.section] valueForKey:@"Name"] ];
            cell. lblDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            [cell.contentView addSubview:lblDeviceName];
            cell. lblAvailableCount.text = [NSString stringWithFormat:@"%@",[(self.displayModuleData)[indexPath.section] valueForKey:@"Count"]];
            cell.lblAvailableCount.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
            [cell.contentView addSubview:lblAvailableCount];
        }
//
//        if (indexPath.section == 2) {
//            cell.lblDeviceName.text = [NSString stringWithFormat:@"%@",[[self.displayModuleData objectAtIndex:indexPath.section] valueForKey:@"Name"] ];
//            cell. lblDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
//            [cell.contentView addSubview:lblDeviceName];
//            cell. lblAvailableCount.text = [NSString stringWithFormat:@"%@",[[self.displayModuleData objectAtIndex:indexPath.section] valueForKey:@"Count"]];
//            cell.lblAvailableCount.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
//            [cell.contentView addSubview:lblAvailableCount];
//        }
//        
//        if (indexPath.section == 3) {
//            cell.lblDeviceName.text = [NSString stringWithFormat:@"%@",[[self.displayModuleData objectAtIndex:indexPath.section] valueForKey:@"Name"] ];
//            cell. lblDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
//            [cell.contentView addSubview:lblDeviceName];
//            cell. lblAvailableCount.text = [NSString stringWithFormat:@"%@",[[self.displayModuleData objectAtIndex:indexPath.section] valueForKey:@"Count"]];
//            cell.lblAvailableCount.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
//            [cell.contentView addSubview:lblAvailableCount];
//        }
//        
//        if (indexPath.section == 4) {
//            cell.lblDeviceName.text = [NSString stringWithFormat:@"%@",[[self.displayModuleData objectAtIndex:indexPath.section] valueForKey:@"Name"] ];
//            cell. lblDeviceName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
//            [cell.contentView addSubview:lblDeviceName];
//            cell. lblAvailableCount.text = [NSString stringWithFormat:@"%@",[[self.displayModuleData objectAtIndex:indexPath.section] valueForKey:@"Count"]];
//            cell.lblAvailableCount.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
//            [cell.contentView addSubview:lblAvailableCount];
//        }
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if([[(self.displayModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] == 2)
            {
                if([[(self.displayModuleData)[indexPath.row] valueForKey:@"IsActive"] integerValue ] == 0)
                {
                    //lblStatus.text = @"Not Active";
                    //lblStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
                    //lblStatus.textColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
                }
                else
                {
                    //lblStatus.text = @"Active";
                    //lblStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
                    //lblStatus.textColor = [UIColor colorWithRed:43.0/255.0 green:192.0/255.0 blue:142.0/255.0 alpha:1.0];
                    [ cell.btnChecked setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
                    [cell.contentView addSubview:btnChecked];
                }
                [cell.contentView addSubview:lblStatus];
            }
        }
        else
        {
            if([[(self.displayModuleData)[indexPath.section] valueForKey:@"IsActive"] integerValue ] == 0)
            {
                //lblStatus.text = @"Not Active";
                //lblStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
                //lblStatus.textColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
                [ cell.btnChecked setImage:nil forState:UIControlStateNormal];
                
            }
            else
            {
                //lblStatus.text = @"Active";
                //lblStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
                //lblStatus.textColor = [UIColor colorWithRed:43.0/255.0 green:192.0/255.0 blue:142.0/255.0 alpha:1.0];
                
                [cell.btnChecked setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:btnChecked];
            }
            [cell.contentView addSubview:lblStatus];
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblNotActivated)
    {
        NSMutableDictionary *dictSelected = (self.displayModuleData)[indexPath.section];
        
        if([[dictSelected valueForKey:@"IsActive"] integerValue ] == 0 )
        {
            clickedIndexpath = [indexPath copy];
            
            NSInteger temp = [[dictSelected valueForKey:@"ModuleId"] integerValue ];
            NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND ModuleId == %d", (self.rmsDbController.globalDict)[@"DeviceId"],temp];
            NSMutableArray *isFoundArray = [[self.arrTempActive filteredArrayUsingPredicate:deactive] mutableCopy ];
            
            if(isFoundArray.count > 0 )
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Active Application" message:[NSString stringWithFormat:@"%@ module is already active",[dictSelected valueForKey:@"Name"]] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                return;
            }
            
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                if([[(self.displayModuleData)[indexPath.section] valueForKey:@"ModuleId"] integerValue ] == 2)
                {
                    UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Active Application" message:@"Are you sure you want to active this package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                    reqPer.tag = 1;
                    [reqPer show];
                }
            }
            else
            {
                if(([[dictSelected valueForKey:@"ModuleId"] integerValue ] == 1) || ([[dictSelected valueForKey:@"ModuleId"] integerValue ] == 5) || ([[dictSelected valueForKey:@"ModuleId"] integerValue ] == 6) || ([[dictSelected valueForKey:@"ModuleId"] integerValue ] == 7) )
                {
                    if(self.arrTempActive.count > 0)
                    {
                        int ModuleAccessId = 1;
                        NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND ModuleAccessId == %d", (self.rmsDbController.globalDict)[@"DeviceId"],ModuleAccessId];
                        NSMutableArray *isFoundArray = [[self.arrTempActive filteredArrayUsingPredicate:rcrActive] mutableCopy ];
                        
                        if(isFoundArray.count > 0)
                        {
                            UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Active Application" message:@"You can select Either RCR or RCR + Gas or Restaurant or Restaurant + Retail Module, you can't active both module at a time" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [reqPer show];
                            return;
                        }
                    }
                }
                
                UIAlertView *reqPer = [[UIAlertView alloc] initWithTitle:@"Active Application" message:@"Are you sure you want to active this package?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
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
        
        (self.displayModuleData)[indexPath.section] = dictSelected;
        [self.tblNotActivated reloadData];
    }
   }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1) // To active Module in inactive table
    {
        if(buttonIndex == 1)
        {
            NSMutableDictionary *dictSelected = (self.displayModuleData)[clickedIndexpath.section];
            dictSelected[@"IsActive"] = @"1";
            dictSelected[@"MacAdd"] = (self.rmsDbController.globalDict)[@"DeviceId"];
            NSInteger recordCount = [[dictSelected valueForKey:@"Count"] integerValue ];
            dictSelected[@"Count"] = @(recordCount - 1);
            [self.arrTempActive addObject:dictSelected];
            (self.displayModuleData)[clickedIndexpath.section] = dictSelected;
            [self.tblNotActivated reloadData];
        }
        else
        {
            [self.tblNotActivated reloadData];
        }
    }
    
}

-(IBAction)btnYesClicked:(id)sender
{
    if(_txtRegisterName.text.length>0){
        
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
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary * dictDeviceActivation = [[NSMutableDictionary alloc] init];
        dictDeviceActivation[@"BranchId"] = @"1";
        dictDeviceActivation[@"COMCOD"] = strCOMCOD;
        dictDeviceActivation[@"RegisterName"] = _txtRegisterName.text;
        dictDeviceActivation[@"MacAdd"] = (self.rmsDbController.globalDict)[@"DeviceId"];
        dictDeviceActivation[@"dType"] = @"IOS-RCRIpad";
        dictDeviceActivation[@"dVersion"] = [UIDevice currentDevice].systemVersion;
        dictDeviceActivation[@"TokenId"] = (self.rmsDbController.globalDict)[@"TokenId"];
        dictDeviceActivation[@"ApplicationType"] = @"";
        
        dictDeviceActivation[@"DeactiveDeviceInfo"] = [self getModuleDeactiveDeviceData];
        
        dictDeviceActivation[@"activeDeviceInfo"] = [self getModuleActiveDeviceData];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self settingsDeviceSetupResponse:response error:error];
        };
        
        self.deviceSetupWC = [self.deviceSetupWC initWithRequest:KURL actionName:WSM_DEVICE_SETUP params:dictDeviceActivation completionHandler:completionHandler];
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Active Application" message:@"Please enter Device Name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }

}

- (NSMutableArray *) getModuleDeactiveDeviceData
{
    NSMutableArray *arrDeActiveDeviceInfo = [[NSMutableArray alloc] init];
    
/*    if([self.arrTempDeActive count]>0)
    {
        for (int isup=0; isup<[self.arrTempDeActive count]; isup++) {
            NSMutableDictionary *tmpSup=[[self.arrTempDeActive objectAtIndex:isup] mutableCopy ];
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
    }*/
	return arrDeActiveDeviceInfo;
}

- (NSMutableArray *) getModuleActiveDeviceData
{
    NSMutableArray *arrActiveDevice = [[NSMutableArray alloc] init];
    
    if(self.arrTempActive.count>0)
    {
        for (int isup=0; isup < self.arrTempActive.count; isup++) {
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


- (void)settingsDeviceSetupResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];;
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _txtRegisterName.text=@"";
                NSMutableDictionary *responseData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                
                (self.rmsDbController.globalDict)[@"BranchID"] = [responseData valueForKey:@"BranchId"];
                (self.rmsDbController.globalDict)[@"RegisterId"] = [responseData valueForKey:@"RegisterId"];
                (self.rmsDbController.globalDict)[@"ZId"] = [responseData valueForKey:@"ZId"];
                (self.rmsDbController.globalDict)[@"ZRequired"] = [responseData valueForKey:@"ZRequired"];
                (self.rmsDbController.globalDict)[@"RegisterName"] = [responseData valueForKey:@"RegisterName"];
                
                NSArray *departmentArray = [responseData valueForKey:@"Department_MArray"];
                if(departmentArray != (id)[NSNull null])
                {
                    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                    [self.departmentUpdateManager insertDepartmentFromDepartmentlist:departmentArray moc:privateContextObject];
                }
                
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
                    
                    //                if([[responseData valueForKey:@"RegisterInvNo"] integerValue] == 0)
                    //                {
                    //                    [Keychain saveString:[responseData valueForKey:@"RegisterInvNo"] forKey:@"tenderInvoiceNo"];
                    //                }
                    
                    [Keychain saveString:[NSString stringWithFormat:@"%@",[responseData valueForKey:@"RegisterInvNo"]] forKey:@"tenderInvoiceNo"];
                    
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
            else if([[response valueForKey:@"IsError"] intValue] == 1)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Active Application" message:[NSString stringWithFormat:@"%@",response[@"Data"]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                _txtRegisterName.text = @"";
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Active Application" message:@"Error occurred in device setup register process, Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Active Application" message:response[@"Data"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
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

@end
