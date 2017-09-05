//
//  ICRecallSessionListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 06/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ICHistorySessionListVC.h"
#import "ICRecallListCustomCell.h"

#import "RmsDbController.h"
#import "RimsController.h"

#import "ItemReconcileListVC.h"
#import "ItemInventoryCountSession+Dictionary.h"

#import "IntercomHandler.h"

@interface ICHistorySessionListVC () <UpdateDelegate>
{
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UITableView *historySessionTableView;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *reconcileSessionHistoryWC;
@property (nonatomic, strong) UpdateManager *iHistoryUpdateManager;

@property (nonatomic, strong) NSMutableArray *historySessionList;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation ICHistorySessionListVC

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
    self.reconcileSessionHistoryWC = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.iHistoryUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    // Do any additional setup after loading the view.
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"helpbtn.png" selectedImage:@"helpbtnselected.png" withViewController:self];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.historySessionList = [[NSMutableArray alloc] init];
    [self getHistorySessionListData];
}

-(IBAction)backToRootView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getHistorySessionListData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self responseHistorySessionDataResponse:response error:error];
    };
    
    self.reconcileSessionHistoryWC = [self.reconcileSessionHistoryWC initWithRequest:KURL actionName:WSM_RECONCILE_SESSION_HISTORY params:param completionHandler:completionHandler];
}

- (void)reloadHistorySessionList:(NSMutableArray *)responseItemArray
{
    self.historySessionList = [[self.rmsDbController objectFromJsonString:[responseItemArray valueForKey:@"Data"]] mutableCopy ];
    
    for (int i = 0; i < self.historySessionList.count; i++) {
        CGFloat count = (float)self.historySessionList.count;
        CGFloat intPercentage = i / count ;
        [_activityIndicator updateProgressStatus:intPercentage];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_historySessionTableView reloadData];
    });
    [_activityIndicator hideActivityIndicator];
}

-(void)responseHistorySessionDataResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseItemArray = response;
                if(responseItemArray.count > 0)
                {
                    dispatch_async(dispatch_queue_create("responseReconcileSessionHistory", NULL), ^{
                        [self reloadHistorySessionList:responseItemArray];
                    });
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"No Record Found for History." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
            }
            else
            {
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error occur while generating history list." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historySessionList.count;
}

-(NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICRecallListCustomCell *iCRecallListCustomCell = (ICRecallListCustomCell *)[tableView dequeueReusableCellWithIdentifier:@"ICRecallListCustomCell"];
    
    NSMutableDictionary *historyDict = (self.historySessionList)[indexPath.row];
    
    iCRecallListCustomCell.invCountLabel.text = [NSString stringWithFormat:@"INC # %@",[historyDict valueForKey:@"StockSessionId"]];
    
    iCRecallListCustomCell.remarkLabel.text = [historyDict valueForKey:@"Remarks"];
    
    NSString  *aStartDate = [NSString stringWithFormat:@"%@",[historyDict valueForKey:@"DateStarted"]];
    iCRecallListCustomCell.startDateLabel.text = [self getStringFormate:aStartDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy hh:mm a"];
    
    NSString  *aHoldDate = [NSString stringWithFormat:@"%@",[historyDict valueForKey:@"DateEnding"]];
    iCRecallListCustomCell.holddate.text = [self getStringFormate:aHoldDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy hh:mm a"];
    
    return iCRecallListCustomCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        
        NSMutableDictionary *historyDict = (self.historySessionList)[indexPath.row];
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
        ItemInventoryCountSession *itemInventoryCountSession = [self.iHistoryUpdateManager insertInventoryCountSessionInLocalDataBaseWithDetail:historyDict withContext:privateContextObject];
        [_activityIndicator hideActivityIndicator];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
        ItemReconcileListVC *objItemReconcileList = [storyBoard instantiateViewControllerWithIdentifier:@"ItemReconcileListVC_sid"];
        objItemReconcileList.reConcileItemInvCountSession = (ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, self.managedObjectContext);
        objItemReconcileList.isViewOnly = YES;
        objItemReconcileList.isReconcileHistory = YES;
        
        [self.navigationController pushViewController:objItemReconcileList animated:YES];
    });
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
