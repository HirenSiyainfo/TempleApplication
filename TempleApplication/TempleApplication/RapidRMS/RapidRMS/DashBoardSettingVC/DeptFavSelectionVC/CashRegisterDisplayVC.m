//
//  CashRegisterDisplayVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 19/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CashRegisterDisplayVC.h"
#import "DeptFavSelectionViewController.h"
#import "RmsDbController.h"

@interface CashRegisterDisplayVC ()
{
    DeptFavSelectionViewController *deptFavSelectionVC;
    IntercomHandler *intercomHandler;
    
    NSMutableArray *moduleArray;
    NSMutableArray *globalModuleSelectionArray;
}

@property (nonatomic, weak) IBOutlet UITableView *tblModule;

@property (nonatomic, weak) IBOutlet UILabel *lblSelected;

@property (nonatomic, weak) IBOutlet UISwitch *printRecieptSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *weightScaleSwitch;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *activeModulesArray;

@end

@implementation CashRegisterDisplayVC
@synthesize activeModulesArray;

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
    
// Module Selection
    globalModuleSelectionArray = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ModuleSelectionShortCut"]mutableCopy];

    if(globalModuleSelectionArray.count==0)
    {
        globalModuleSelectionArray=[[NSMutableArray alloc]init];
    }

    moduleArray = [[NSMutableArray alloc]init];

    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];

    self.activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];


    NSMutableDictionary *dicttemp = [[NSMutableDictionary alloc]init];
    dicttemp[@"moduleIndex"] = @"1";
    dicttemp[@"module"] = @"Dashboard";
    [moduleArray addObject:[dicttemp mutableCopy]];
    
    //if condition added by sonali
    

    if(self.rmsDbController.isFirstShortCutIcon)
    {
        NSMutableDictionary *dictDash = [[NSMutableDictionary alloc]init];
        dictDash[@"moduleIndex"] = @"1";
        dictDash[@"module"] = @"Dashboard";
        [globalModuleSelectionArray addObject:[dictDash mutableCopy]];
        
        [[NSUserDefaults standardUserDefaults]setObject:globalModuleSelectionArray forKey:@"ModuleSelectionShortCut"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.rmsDbController.isFirstShortCutIcon = FALSE ;
    }
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        BOOL isRcractive = [self isRcrActive];
        if (isRcractive)
        {
            //[moduleArray addObject:@"Cash Register"];
            dicttemp[@"moduleIndex"] = @"2";
            dicttemp[@"module"] = @"Clock In-Out";
            [moduleArray addObject:[dicttemp mutableCopy]];

            dicttemp[@"moduleIndex"] = @"3";
            dicttemp[@"module"] = @"Shift In-Out";
            [moduleArray addObject:[dicttemp mutableCopy]];

            dicttemp[@"moduleIndex"] = @"4";
            dicttemp[@"module"] = @"Daily Report";
            [moduleArray addObject:[dicttemp mutableCopy]];
        }
    }
    BOOL isRimActive = [self isRimActive];
    if (isRimActive)
    {
        dicttemp[@"moduleIndex"] = @"5";
        dicttemp[@"module"] = @"Inventory Management";
        [moduleArray addObject:[dicttemp mutableCopy]];
    }

    BOOL isPurChaseActive = [self isPurchaseOrdeActive];
    if (isPurChaseActive)
    {
        dicttemp[@"moduleIndex"] = @"6";
        dicttemp[@"module"] = @"Purchase Order";
        [moduleArray addObject:[dicttemp mutableCopy]];
    }
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

    deptFavSelectionVC = [[DeptFavSelectionViewController alloc]initWithNibName:@"DeptFavSelectionViewController" bundle:nil];
    NSString *strtemp = [[NSUserDefaults standardUserDefaults]objectForKey:@"Selection"];
    if (strtemp == nil) {
        deptFavSelectionVC.btnDepartment.selected = YES;
        deptFavSelectionVC.btnFavorite.selected = NO;
       // [deptFavSelectionVC.dictSet setObject:@"Department" forKey:@"Selection"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Department" forKey:@"Selection" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }

    self.lblSelected.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"Selection"];
    self.title=@"Cash Register";

    [self checkPrintStatus];

    UIImage* image3 = [UIImage imageNamed:@"RmsheaderLogo.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
   
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    UIBarButtonItem *intercom =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[mailbutton,intercom];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:button withViewController:self];

    [self checkWeighScaleStatus];

}
// Module Selection
#pragma mark - Module Shortcuts Settings

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

-(IBAction)moduleShortCutSelectionOption:(id)sender
{
    NSMutableDictionary *dicttemp = moduleArray[[sender tag]];

    NSString *strindex = [dicttemp valueForKey:@"moduleIndex"];
    if([self checkActiveModule:strindex].count>0)
    {
        [self removeFromGlobalArray:strindex];

    }
    else{

        [globalModuleSelectionArray addObject:[dicttemp mutableCopy]];
    }

    [[NSUserDefaults standardUserDefaults]setObject:globalModuleSelectionArray forKey:@"ModuleSelectionShortCut"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_tblModule reloadData];
}


-(void)removeFromGlobalArray:(NSString *)strTag{

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
    cell.backgroundColor = [UIColor whiteColor];

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
    lable.tag=500;
    [cell addSubview:lable];


    UISwitch *switchOnoff = [[UISwitch alloc] initWithFrame:CGRectMake(610, 7, 51, 31)];
    [switchOnoff addTarget:self action:@selector(moduleShortCutSelectionOption:) forControlEvents:UIControlEventValueChanged];
    
        if([self checkActiveModule:strindex].count>0)
        {
            switchOnoff.on=YES;
        }
        else
        {
            switchOnoff.on=NO;
        }
    
    

    switchOnoff.tag=indexPath.row;
    [cell addSubview:switchOnoff];
    return cell;
}


#pragma mark - Cash Register Settings

- (IBAction)btnDeptFavSelectionClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    [self.navigationController pushViewController:deptFavSelectionVC animated:YES];
}

- (IBAction)noSalePrintRecieptSwitch:(id)sender{
    if (self.printRecieptSwitch.on == YES) {
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"PrintRecieptStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
    else// if (self.printRecieptSwitch.on == NO)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"PrintRecieptStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
}

- (void)checkPrintStatus
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"PrintRecieptStatus"] isEqualToString:@"Yes"]){
        self.printRecieptSwitch.on = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"PrintRecieptStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
    else
    {
        self.printRecieptSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"PrintRecieptStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
}


// WeighScale

#pragma mark - Inventory Management Settings

- (void)checkWeighScaleStatus
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"WeightScaleStatus"] isEqualToString:@"Yes"])
    {
        self.weightScaleSwitch.on = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"WeightScaleStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
    else
    {
        self.weightScaleSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"WeightScaleStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
}

- (IBAction)weightScaleSwitch:(id)sender
{
    if (self.weightScaleSwitch.on == YES)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"WeightScaleStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"WeightScaleStatus" ];
        [[NSUserDefaults standardUserDefaults] synchronize ];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
