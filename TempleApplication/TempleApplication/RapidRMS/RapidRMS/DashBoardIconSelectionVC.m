//
//  DashBoardIconSelectionVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 03/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DashBoardIconSelectionVC.h"
#import "RmsDbController.h"
#import "Configuration.h"

@interface DashBoardIconSelectionVC ()
{
    NSMutableArray *moduleArray;
    NSMutableArray *globalModuleSelectionArray;
    Configuration *objConfiguration;
}


@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *activeModulesArray;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation DashBoardIconSelectionVC
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    // Module Selection
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    moduleArray = [[NSMutableArray alloc]init];
    
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (self.rmsDbController.globalDict)[@"DeviceId"]];
    
    self.activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    
    NSMutableDictionary *dicttemp = [[NSMutableDictionary alloc]init];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        BOOL isRcractive = [self isRcrActive];
        if (isRcractive)
        {
            dicttemp[@"moduleIndex"] = @"1";
            dicttemp[@"module"] = @"Cash Register";
            [moduleArray addObject:[dicttemp mutableCopy]];
            
            dicttemp[@"moduleIndex"] = @"2";
            dicttemp[@"module"] = @"Clock In-Out";
            [moduleArray addObject:[dicttemp mutableCopy]];
            
            dicttemp[@"moduleIndex"] = @"3";
            dicttemp[@"module"] = @"Shift In-Out";
            [moduleArray addObject:[dicttemp mutableCopy]];
            
            dicttemp[@"moduleIndex"] = @"4";
            dicttemp[@"module"] = @"Daily Report";
            [moduleArray addObject:[dicttemp mutableCopy]];
            
            BOOL isRcrGasactive = [self isRcrGasActive];
            if (isRcrGasactive)
            {
                dicttemp[@"moduleIndex"] = @"11";
                dicttemp[@"module"] = @"Rcr Gas";
                [moduleArray addObject:[dicttemp mutableCopy]];
            }
        }
    }
    BOOL isRimActive = [self isRimActive];
    if (isRimActive)
    {
        dicttemp[@"moduleIndex"] = @"5";
        dicttemp[@"module"] = @"Inventory Management";
        [moduleArray addObject:[dicttemp mutableCopy]];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            dicttemp[@"moduleIndex"] = @"6";
            dicttemp[@"module"] = @"Inventory Count";
            [moduleArray addObject:[dicttemp mutableCopy]];
        }
    }
    
    BOOL isPurChaseActive = [self isPurchaseOrderActive];
    if (isPurChaseActive)
    {
        dicttemp[@"moduleIndex"] = @"7";
        dicttemp[@"module"] = @"Purchase Order";
        [moduleArray addObject:[dicttemp mutableCopy]];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            dicttemp[@"moduleIndex"] = @"8";
            dicttemp[@"module"] = @"Manual Entry";
            [moduleArray addObject:[dicttemp mutableCopy]];
        }
    }
    
    objConfiguration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    BOOL isTicket =  objConfiguration.localTicketSetting.boolValue;
    if (isTicket)
    {
        dicttemp[@"moduleIndex"] = @"9";
        dicttemp[@"module"] = @"Ticket Validation";
        [moduleArray addObject:[dicttemp mutableCopy]];
    }
    
    objConfiguration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    BOOL isCustomerLoyalty =  objConfiguration.localCustomerLoyalty.boolValue;
    if (isCustomerLoyalty)
    {
        dicttemp[@"moduleIndex"] = @"10";
        dicttemp[@"module"] = @"Customer Loyalty";
        [moduleArray addObject:[dicttemp mutableCopy]];
    }
    
    //added by sonali
    
    if(self.rmsDbController.isFirstDashboardIcon)
    {
        globalModuleSelectionArray = [moduleArray mutableCopy];
        [[NSUserDefaults standardUserDefaults] setObject:globalModuleSelectionArray forKey:@"DashBoardIconSelection"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.rmsDbController.isFirstDashboardIcon = false;
    }
    globalModuleSelectionArray = [[[NSUserDefaults standardUserDefaults] valueForKey:@"DashBoardIconSelection"]mutableCopy];
    
    if(globalModuleSelectionArray.count==0)
    {
        globalModuleSelectionArray = [[NSMutableArray alloc]init];
    }
    
    // Do any additional setup after loading the view from its nib.
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Module Shortcuts Settings

-(BOOL)isRcrActive
{
    BOOL isRcrActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@", @"RCR",@"RCRGAS",@"RRRCR",@"RRCR"];
    NSArray *rcrArray = [self.activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0)
    {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}

-(BOOL)isRimActive
{
    BOOL isRimActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@", @"RIM"];
    NSArray *rimArray = [self.activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rimArray.count > 0)
    {
        isRimActive = TRUE;
    }
    return isRimActive;
}

-(BOOL)isPurchaseOrderActive
{
    BOOL isPurchaseOrdeActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@", @"PO"];
    NSArray *rimArray = [self.activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rimArray.count > 0)
    {
        isPurchaseOrdeActive = TRUE;
    }
    return isPurchaseOrdeActive;
}

-(IBAction)dashboardSelectionOption:(id)sender
{
    NSMutableDictionary *dicttemp = moduleArray[[sender tag]];
    
    NSString *strindex = [dicttemp valueForKey:@"moduleIndex"];
    if([self checkActiveModule:strindex].count>0)
    {
        [self removeFromGlobalArray:strindex];
    }
    else
    {
        [globalModuleSelectionArray addObject:[dicttemp mutableCopy]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:globalModuleSelectionArray forKey:@"DashBoardIconSelection"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.iconSelectionTableView reloadData];
}

-(void)removeFromGlobalArray:(NSString *)strTag
{
    
    for(int i=0;i<globalModuleSelectionArray.count;i++){
        
        NSMutableDictionary *dict = globalModuleSelectionArray[i];
        if([[dict valueForKey:@"moduleIndex"] isEqualToString:strTag]){
            [globalModuleSelectionArray removeObjectAtIndex:i];
        }
    }
}

-(NSMutableArray *)checkActiveModule:(NSString *)moduleId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moduleIndex == %@",moduleId];
    NSMutableArray *isFoundArray = [[globalModuleSelectionArray filteredArrayUsingPredicate:predicate] mutableCopy ];
    
    
    return isFoundArray;
}

-(IBAction)selectedIcon:(id)sender
{
    if (globalModuleSelectionArray != nil && globalModuleSelectionArray.count > 0) {
        [self.dashBoardIconSelectionVCDelegate selectedDashBoardIcon:globalModuleSelectionArray];
    }
    else
    {
        [self.dashBoardIconSelectionVCDelegate skipDashBoardIconSelection];
    }
}

-(IBAction)skipIconSelection:(id)sender
{
    [self.dashBoardIconSelectionVCDelegate skipDashBoardIconSelection];
}

#pragma mark - TableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(moduleArray.count>0)
    {
        return moduleArray.count;
    }
    return 1 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBgWhite.png"]];
    [cell addSubview:img];
    
    UILabel *templbl =(UILabel *)[cell viewWithTag:500];
    [templbl removeFromSuperview];
    
    NSMutableDictionary *dictSelection = moduleArray[indexPath.row];
    NSString *strindex = [dictSelection valueForKey:@"moduleIndex"];
    UISwitch *tempswitch =(UISwitch *)[cell viewWithTag:strindex.intValue];
    [tempswitch removeFromSuperview];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, 500, 30)];
    NSMutableDictionary *dicttemp = moduleArray[indexPath.row];
    lable.text = [dicttemp valueForKey:@"module"];
    lable.textAlignment = NSTextAlignmentLeft;
    lable.font = [UIFont fontWithName:@"Helvetica Neue" size:17.0];
    lable.backgroundColor = [UIColor whiteColor];
    lable.tag = 500;
    [cell addSubview:lable];
    
    UISwitch *switchOnoff = [[UISwitch alloc] initWithFrame:CGRectMake(610, 7, 51, 31)];
    [switchOnoff addTarget:self action:@selector(dashboardSelectionOption:) forControlEvents:UIControlEventValueChanged];
    
    if([self checkActiveModule:strindex].count>0){
        switchOnoff.on=YES;
    } else {
        switchOnoff.on=NO;
    }
    
    switchOnoff.tag=indexPath.row;
    [cell addSubview:switchOnoff];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
