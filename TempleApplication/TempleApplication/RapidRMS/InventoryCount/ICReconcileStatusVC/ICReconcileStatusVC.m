//
//  ICJoinCountVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 1/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ICReconcileStatusVC.h"
#import "ICReconcileStatusCustomCell.h"
#import "ItemReconcileListVC.h"

#import "RmsDbController.h"
#import "RimsController.h"
#import "ItemInventoryCount+Dictionary.h"
#import "ItemInventoryCountSession+Dictionary.h"

#import "IntercomHandler.h"

@interface ICReconcileStatusVC () <UpdateDelegate>
{
    NSIndexPath *reconcileIndexPath;
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UITableView *reConcileListTableView;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *getOpenInventoryCountSessionWC;
@property (nonatomic, strong) RapidWebServiceConnection *deleteInventoryCountSessionWC;
@property (nonatomic, strong) UpdateManager *iReconcileStatUpdateManager;

@property (nonatomic, strong) NSMutableArray *reConcileListArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation ICReconcileStatusVC

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
    self.getOpenInventoryCountSessionWC = [[RapidWebServiceConnection alloc] init];
    self.deleteInventoryCountSessionWC = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.iReconcileStatUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"helpbtn.png" selectedImage:@"helpbtnselected.png" withViewController:self];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.reConcileListArray = [[NSMutableArray alloc] init];
    [self getJoinCountData];
}

-(IBAction)backToRootView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getJoinCountData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self getJoinCountDataResponse:response error:error];
    };
    
    self.getOpenInventoryCountSessionWC = [self.getOpenInventoryCountSessionWC initWithRequest:KURL actionName:WSM_GET_OPEN_INVENTORY_COUNT_SESSION params:param completionHandler:completionHandler];
}

- (void)reloadReconcileList:(NSMutableArray *)responseItemArray
{
    self.reConcileListArray = [self.rmsDbController objectFromJsonString:[responseItemArray valueForKey:@"Data"]];
    
    for (int i = 0; i < self.reConcileListArray.count; i++) {
        CGFloat count = (float)self.reConcileListArray.count;
        CGFloat intPercentage = i / count ;
        [_activityIndicator updateProgressStatus:intPercentage];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_reConcileListTableView reloadData];
    });
    [_activityIndicator hideActivityIndicator];

}

-(void)getJoinCountDataResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseItemArray = response;
                if(responseItemArray.count > 0)
                {
                    dispatch_async(dispatch_queue_create("responseGetOpenInventoryCountSession", NULL), ^{
                        [self reloadReconcileList:responseItemArray];
                    });
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];
                    
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"No Record found for reconcile status" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
            }
            else
            {
                [_activityIndicator hideActivityIndicator];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error occur while generation Reconcile list" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Response of Deleted session
- (void)resDeleteInventoryCountSessionResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self.reConcileListArray removeObjectAtIndex:reconcileIndexPath.section];
                [_reConcileListTableView reloadData];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Getting error while deleting selected session" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


#pragma mark - UITableView Delegeate Method

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES; // Return YES, if enable delete on swipe.
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == _reConcileListTableView )
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            
            reconcileIndexPath = [indexPath copy];
            NSMutableDictionary *reConcileDict = (self.reConcileListArray)[indexPath.section];
            
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
            [param setValue:[reConcileDict valueForKey:@"StockSessionId"] forKey:@"StockSessionId"];
            NSDate *currentDate = [NSDate date];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
            NSString *currentDateValue = [formatter stringFromDate:currentDate];
            [param setValue:currentDateValue forKey:@"CurrentDate"];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self resDeleteInventoryCountSessionResponse:response error:error];
                });
            };
            
            self.deleteInventoryCountSessionWC = [self.deleteInventoryCountSessionWC initWithRequest:KURL actionName:WSM_DELETE_INVENTORY_COUNT_SESSION params:param completionHandler:completionHandler];
        }
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 35.0;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.reConcileListArray.count;
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSMutableDictionary *reConcileDict = (self.reConcileListArray)[section];
//    NSString *invCount = [NSString stringWithFormat:@"INVENTORY COUNT # %@",[reConcileDict valueForKey:@"StockSessionId"]];
//    
//    UIView *invCountView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 35)];
//    invCountView.backgroundColor = [UIColor clearColor];
//    
//    UILabel *inventoruCount = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 35)];
//    inventoruCount.backgroundColor = [UIColor clearColor];
//    inventoruCount.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
//    inventoruCount.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
//    inventoruCount.text = invCount;
//    [invCountView addSubview:inventoruCount];
//    
//    return invCountView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(IsPad())
    {
        return 55.0;
    }
    return 96.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICReconcileStatusCustomCell *iCJointCountCustomCell = (ICReconcileStatusCustomCell *)[tableView dequeueReusableCellWithIdentifier:@"ICReconcileStatusCustomCell"];

    NSMutableDictionary *reConcileDict = (self.reConcileListArray)[indexPath.section];
    NSString *invCount = [NSString stringWithFormat:@"%@",[reConcileDict valueForKey:@"StockSessionId"]];

    iCJointCountCustomCell.deviceName.text = [NSString stringWithFormat:@"%@",[reConcileDict valueForKey:@"Remarks"]];
    iCJointCountCustomCell.incCountNumber.text = [NSString stringWithFormat:@"%@",invCount];
    iCJointCountCustomCell.startDate.text = [NSString stringWithFormat:@"%@",[reConcileDict valueForKey:@"LocalDate"]];
    iCJointCountCustomCell.status.text = [NSString stringWithFormat:@"%@",[reConcileDict valueForKey:@"Status"]];
    
    return iCJointCountCustomCell;
}

-(ItemInventoryCountSession *)createInventoryCountSessionForDictionary:(NSMutableDictionary *)inventoryCountDictionary
{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryCountSession" inManagedObjectContext:privateContextObject];
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:privateContextObject FetchRequest:fetchRequest];
    for (NSManagedObject *product in arryTemp)
    {
        [UpdateManager deleteFromContext:privateContextObject object:product];
    }
    [UpdateManager saveContext:privateContextObject];
    // DELETE EXISTING SESSION
    
    // CREATE NEW SESSION AND ASSIGN NEW ITEM TO THAT SESSION
    ItemInventoryCountSession *itemInventoryCountSession = [self.iReconcileStatUpdateManager insertInventoryCountSessionInLocalDataBaseWithDetail:inventoryCountDictionary withContext:privateContextObject];
    
    return itemInventoryCountSession;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *reConcileDict = (self.reConcileListArray)[indexPath.section];
//    ItemInventoryCountSession *itemInventoryCountSession = [self.iReconcileStatUpdateManager fetchItemInventoryCountSession:[reConcileDict valueForKey:@"StockSessionId"] moc:self.managedObjectContext];
    
    ItemInventoryCountSession *itemInventoryCountSession = (ItemInventoryCountSession *)[self createInventoryCountSessionForDictionary:reConcileDict];

    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
    ItemReconcileListVC *objItemReconcileList = [storyBoard instantiateViewControllerWithIdentifier:@"ItemReconcileListVC_sid"];
    objItemReconcileList.reConcileItemInvCountSession =  (ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, self.managedObjectContext);;
    objItemReconcileList.reconcileSessionDictionary = reConcileDict;
    objItemReconcileList.isViewOnly = NO;
    [self.navigationController pushViewController:objItemReconcileList animated:YES];
}
@end
