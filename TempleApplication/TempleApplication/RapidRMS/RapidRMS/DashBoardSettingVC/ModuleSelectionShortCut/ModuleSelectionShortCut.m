//
//  CashRegisterDisplayVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 19/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ModuleSelectionShortCut.h"
#import "RmsDbController.h"

@interface ModuleSelectionShortCut ()
{
    NSMutableArray *moduleArray;
    NSMutableArray *globalModuleSelectionArray;
}

@property (nonatomic, weak) IBOutlet UITableView *tblModule;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *activeModulesArray;

@end

@implementation ModuleSelectionShortCut
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

    globalModuleSelectionArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"ModuleSelectionShortCut"]mutableCopy];
 
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
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ OR ModuleCode == %@", @"RCR",@"RCRGAS"];
    NSArray *rcrArray = [self.activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}

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
    lable.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    lable.backgroundColor = [UIColor whiteColor];
    lable.tag=500;
    [cell addSubview:lable];
    
    
    UISwitch *switchOnoff = [[UISwitch alloc] initWithFrame:CGRectMake(610, 7, 51, 31)];
    [switchOnoff addTarget:self action:@selector(moduleShortCutSelection:) forControlEvents:UIControlEventValueChanged];
    if([self checkActiveModule:strindex].count>0)
    {
        switchOnoff.on=YES;
        
    }
    else{
        switchOnoff.on=NO;
    }

    switchOnoff.tag=indexPath.row;
    [cell addSubview:switchOnoff];
    return cell;
}

-(IBAction)moduleShortCutSelection:(id)sender
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
}


-(void)removeFromGlobalArray:(NSString *)strTag{
    
    for(int i=0;i<globalModuleSelectionArray.count;i++){
        
        NSMutableDictionary *dict = globalModuleSelectionArray[i];
        if([[dict valueForKey:@"moduleIndex"] isEqualToString:strTag]){
            [globalModuleSelectionArray removeObjectAtIndex:i];
        }
    }
    [[NSUserDefaults standardUserDefaults]setObject:globalModuleSelectionArray forKey:@"ModuleSelectionShortCut"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableArray *)checkActiveModule:(NSString *)moduleId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moduleIndex == %@",moduleId];
    NSMutableArray *isFoundArray = [[globalModuleSelectionArray filteredArrayUsingPredicate:predicate] mutableCopy ];
    return isFoundArray;
}


-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
    
}

@end
