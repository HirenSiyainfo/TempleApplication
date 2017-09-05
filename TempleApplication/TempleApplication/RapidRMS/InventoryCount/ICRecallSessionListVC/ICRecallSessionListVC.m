//
//  ICRecallSessionListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 06/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ICRecallSessionListVC.h"
#import "ICRecallListCustomCell.h"

#import "RmsDbController.h"
#import "RimsController.h"
#import "IntercomHandler.h"

#import "ItemCountListVC.h"
#import "Item+Dictionary.h"
#import "ItemInventoryCountSession+Dictionary.h"
#import "ItemInventoryCount+Dictionary.h"

@interface ICRecallSessionListVC () <UpdateDelegate>
{
    NSIndexPath *reCallSessionIndexpath;
    IntercomHandler *intercomHandler;
    
}

@property (nonatomic, weak) IBOutlet UITableView *recallSessionTableView;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *inventoryCountUserSessionsWC;
@property (nonatomic, strong) RapidWebServiceConnection *deleteInventoryUserSessionWC;
@property (nonatomic, strong) RapidWebServiceConnection *recallUserSessionWC;
@property (nonatomic, strong) UpdateManager *iRecallUpdateManager;

@property (nonatomic, strong) NSMutableArray *reCallSessionListArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation ICRecallSessionListVC

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
    self.inventoryCountUserSessionsWC = [[RapidWebServiceConnection alloc] init];
    self.deleteInventoryUserSessionWC = [[RapidWebServiceConnection alloc] init];
    self.recallUserSessionWC = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.iRecallUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"helpbtn.png" selectedImage:@"helpbtnselected.png" withViewController:self];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.reCallSessionListArray = [[NSMutableArray alloc] init];
    [self getRecallSessionListData];
}

-(IBAction)backToRootView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getRecallSessionListData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self getRecallSessionDataResponse:response error:error];
    };
    
    self.inventoryCountUserSessionsWC = [self.inventoryCountUserSessionsWC initWithRequest:KURL actionName:WSM_INVENTORY_COUNT_USER_SESSION_LIST params:param completionHandler:completionHandler];
}

- (void)reloadRecallList:(NSMutableArray *)responseItemArray
{
    self.reCallSessionListArray = [[self.rmsDbController objectFromJsonString:[responseItemArray valueForKey:@"Data"]] mutableCopy ];
    for (int i = 0; i < self.reCallSessionListArray.count; i++) {
        CGFloat count = (float)self.reCallSessionListArray.count;
        CGFloat intPercentage = i / count ;
        [_activityIndicator updateProgressStatus:intPercentage];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_recallSessionTableView reloadData];
    });

    [_activityIndicator hideActivityIndicator];

}

-(void)getRecallSessionDataResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseItemArray = response;
                if(responseItemArray.count > 0)
                {
                    dispatch_async(dispatch_queue_create("responseInventoryCountUserSessions", NULL), ^{
                        [self reloadRecallList:responseItemArray];
                    });
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"No record found for Recall." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
            }
            else
            {
                [_activityIndicator hideActivityIndicator];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error occur while generating list." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

// Response of Deleted session
- (void)resDeleteInventoryUserSessionResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *reCallSessionDict = (self.reCallSessionListArray)[reCallSessionIndexpath.section][@"objInvUserSession"][reCallSessionIndexpath.row];
                [(self.reCallSessionListArray)[reCallSessionIndexpath.section][@"objInvUserSession"] removeObject:reCallSessionDict];
                [_recallSessionTableView reloadData];
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

#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES; // Return YES, if enable delete on swipe.
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == _recallSessionTableView )
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            
            reCallSessionIndexpath = [indexPath copy];
            NSMutableDictionary *reCallSessionDict = (self.reCallSessionListArray)[indexPath.section][@"objInvUserSession"][indexPath.row];
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
            [param setValue:[reCallSessionDict valueForKey:@"StockSessionId"] forKey:@"StockSessionId"];
            [param setValue:[reCallSessionDict valueForKey:@"UserSessionId"] forKey:@"UserSessionId"];
            NSDate *currentDate = [NSDate date];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
            NSString *currentDateValue = [formatter stringFromDate:currentDate];
            [param setValue:currentDateValue forKey:@"CurrentDate"];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self resDeleteInventoryUserSessionResponse:response error:error];
                });
            };
            
            self.deleteInventoryUserSessionWC = [self.deleteInventoryUserSessionWC initWithRequest:KURL actionName:WSM_DELETE_INVENTORY_USER_SESSION params:param completionHandler:completionHandler];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(IsPad())
    {
        return 75.0;
    }
    
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.reCallSessionListArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(self.reCallSessionListArray)[section][@"objInvUserSession"] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSMutableDictionary *reConcileDict = (self.reCallSessionListArray)[section];
    UIView *invCountView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];

    if(IsPad())
    {
        invCountView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        
        NSString *invCount = [NSString stringWithFormat:@"%@",[reConcileDict valueForKey:@"StockSessionId"]];
        UILabel *inventoruCount = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 140, 35)];
        inventoruCount.backgroundColor = [UIColor clearColor];
        inventoruCount.textColor = [UIColor blackColor];
        inventoruCount.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
        inventoruCount.text = invCount;
        [invCountView addSubview:inventoruCount];
        
        UILabel *newRemark = [[UILabel alloc]initWithFrame:CGRectMake(190, 20, 140, 35)];
        newRemark.backgroundColor = [UIColor clearColor];
        newRemark.textColor = [UIColor blackColor];
        newRemark.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
        newRemark.text = [reConcileDict valueForKey:@"Remarks"];
        [invCountView addSubview:newRemark];
        
        UIView *seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 73, self.view.frame.size.width-20, 1)];
        seperator.backgroundColor = [UIColor lightGrayColor];
        [invCountView addSubview:seperator];

    }
    else{
        invCountView.backgroundColor = [UIColor clearColor];
        NSString *invCount = [NSString stringWithFormat:@"INC # %@",[reConcileDict valueForKey:@"StockSessionId"]];
        UILabel *inventoruCount = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 140, 35)];
        inventoruCount.backgroundColor = [UIColor clearColor];
        inventoruCount.textColor = [UIColor colorWithRed:73.0/255.0 green:106.0/255.0 blue:121.0/255.0 alpha:1.0];
        inventoruCount.font = [UIFont fontWithName:@"Lato-Bold" size:14.0];
        inventoruCount.text = invCount;
        [invCountView addSubview:inventoruCount];
        
        UILabel *newRemark = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, 140, 35)];
        newRemark.backgroundColor = [UIColor whiteColor];
        newRemark.textColor = [UIColor blackColor];
        newRemark.textAlignment = NSTextAlignmentLeft;
        newRemark.font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
        newRemark.text = [reConcileDict valueForKey:@"Remarks"];
        [invCountView addSubview:newRemark];
        
        UIView *seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 34, self.view.frame.size.width, 1)];
        seperator.backgroundColor = [UIColor lightGrayColor];
        [invCountView addSubview:seperator];

    }
    return invCountView;
 
}

-(NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
//    NSString *strServerDate = @"Jan 01, 2015 12:00 AM";
//    NSDateFormatter *datePickerFormat = [[NSDateFormatter alloc] init];
//    [datePickerFormat setDateFormat:pstrToformate];
//    NSDate *serverDate = [datePickerFormat dateFromString:strServerDate];
//    NSDate *holdDate = [datePickerFormat dateFromString:result];
//    
//
//    NSComparisonResult checkHoldDate;
//    checkHoldDate = [holdDate compare:serverDate]; // comparing two dates
//    
//    if(checkHoldDate == NSOrderedAscending)
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICRecallListCustomCell *iCRecallListCustomCell = (ICRecallListCustomCell *)[tableView dequeueReusableCellWithIdentifier:@"ICRecallListCustomCell"];
    
    if(IsPad())
    {
        iCRecallListCustomCell.imgSelected.image = [UIImage imageNamed:@"RIM_Com_Arrow_Detail"];
        iCRecallListCustomCell.imgSelected.highlightedImage = [UIImage imageNamed:@"rim_inventory_arrow_selected"];
    }
    else
    {
        iCRecallListCustomCell.imgSelected.image = [UIImage imageNamed:@"ic_arrow.png"];
        iCRecallListCustomCell.imgSelected.highlightedImage = [UIImage imageNamed:@"ic_arrowselected.png"];

    }

    NSMutableDictionary *joinDict = (self.reCallSessionListArray)[indexPath.section][@"objInvUserSession"][indexPath.row];
    
    NSInteger indexpathValue = indexPath.row;
    NSInteger countArray = [[[self.reCallSessionListArray objectAtIndex:indexPath.section] valueForKey:@"objInvUserSession"] count];
    
    if (indexpathValue != countArray-1) {
        iCRecallListCustomCell.separatorLeadingConstraint.constant = 360;
        [iCRecallListCustomCell layoutSubviews];
    }
    else
    {
        iCRecallListCustomCell.separatorLeadingConstraint.constant = 20;
        [iCRecallListCustomCell layoutSubviews];
    }
    iCRecallListCustomCell.invCountLabel.text = [NSString stringWithFormat:@"%@",[joinDict valueForKey:@"StockSessionId"]];
    iCRecallListCustomCell.remarkLabel.text = [NSString stringWithFormat:@"%@",[joinDict valueForKey:@"UserSessionName"]];
    iCRecallListCustomCell.currentUserLabel.text = [joinDict valueForKey:@"UserName"];

    NSString  *aStartDate = [NSString stringWithFormat:@"%@",[joinDict valueForKey:@"CreatedDate"]];
    iCRecallListCustomCell.startDateLabel.text = [self getStringFormate:aStartDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy hh:mm a"];
    
    NSString  *aHoldDate = [NSString stringWithFormat:@"%@",[joinDict valueForKey:@"UpdatedDate"]];
    iCRecallListCustomCell.holddate.text = [self getStringFormate:aHoldDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy hh:mm a"];
    
    return iCRecallListCustomCell;
}

- (void)reCallClickedSession
{
    NSMutableDictionary *recallDict = (self.reCallSessionListArray)[reCallSessionIndexpath.section][@"objInvUserSession"][reCallSessionIndexpath.row];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:[recallDict valueForKey:@"UserSessionId"] forKey:@"UserSessionId"];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateValue = [formatter stringFromDate:currentDate];
    [param setValue:currentDateValue forKey:@"LocalDate"];
  
    NSLog(@"Start Time of webservice = %@" ,[NSDate date]);

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseRecallUserSessionResponse:response error:error];
        });
    };
    
    self.recallUserSessionWC = [self.recallUserSessionWC initWithRequest:KURL actionName:WSM_RECALL_USER_SESSION params:param completionHandler:completionHandler];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    reCallSessionIndexpath = [indexPath copy];
    NSMutableDictionary *recallDict = (self.reCallSessionListArray)[indexPath.section][@"objInvUserSession"][indexPath.row];
    
    if([[recallDict valueForKey:@"UserStatus"] isEqualToString:@"Inprocess"])
    {
        NSString *userSessionName = [NSString stringWithFormat:@"%@",[recallDict valueForKey:@"UserSessionName" ]];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self reCallClickedSession];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:[NSString stringWithFormat:@"%@ session is InProcess, still you sure want to join?",userSessionName] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
    else
    {
        [self reCallClickedSession];
    }
}

- (void)recreateInventoryCount:(NSDictionary *)response
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
    NSMutableDictionary *recallDict = (self.reCallSessionListArray)[reCallSessionIndexpath.section][@"objInvUserSession"][reCallSessionIndexpath.row];
    
    ItemInventoryCountSession *itemInventoryCountSession = [self.iRecallUpdateManager insertInventoryCountSessionInLocalDataBaseWithDetail:(self.reCallSessionListArray)[reCallSessionIndexpath.section] withContext:privateContextObject];
    
    NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"] ];
    NSUInteger currentItemIndex=0;
    
    // STORE EACH ITEM TO SESSION
    for (NSDictionary *eachSession in arrayRetString)
    {
        @autoreleasepool {
            Item *anItem = [self fetchAllItems:[eachSession valueForKey:@"ItemCode"]];
            Item *anItemPrivate = (Item *)OBJECT_COPY(anItem, privateContextObject);
            //                    [self.iRecallUpdateManager updateItemForInventoryCountListwithServerDetail:eachSession withItem:anItemPrivate withitemInventoryCount:nil withItemInventorySession:(ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, privateContextObject) withManageObjectContext:privateContextObject];
            [self.iRecallUpdateManager modifidedServerUpdateItemForInventoryCountListwithDetail:eachSession withItem:anItemPrivate withitemInventoryCount:nil withItemInventorySession:itemInventoryCountSession withInventoryCountSessionDetail:recallDict withManageObjectContext:privateContextObject];
            
            currentItemIndex ++;
            CGFloat count = (float)arrayRetString.count;
            CGFloat intPercentage = currentItemIndex / count ;
            
            [_activityIndicator updateProgressStatus:intPercentage];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
        ItemCountListVC *objItemCountList = [storyBoard instantiateViewControllerWithIdentifier:@"ItemCountListVC_sid"];
        objItemCountList.userSessionId = @([[recallDict valueForKey:@"UserSessionId"] integerValue]);
        objItemCountList.currentItemInventoryCountSession = (ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, self.managedObjectContext);
        objItemCountList.inventoryCountSessionDictionary = recallDict;
        objItemCountList.isRecallList = YES;

        [self.navigationController pushViewController:objItemCountList animated:YES];
    });

    [_activityIndicator hideActivityIndicator];
}

-(void)responseRecallUserSessionResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSLog(@"Start Time when response is get = %@" ,[NSDate date]);
//                dispatch_async(dispatch_queue_create("responseRecallUserSession", NULL), ^{
//                    [self recreateInventoryCount:response];
//                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self recreateInventoryCount:response];
                });
                NSLog(@"END Time when insert is end = %@" ,[NSDate date]);
                
                // REDIRECT TO ITEMLIST COUNT AFTER INSERTING ITEM
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error occur while recall inventory count session, please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [_activityIndicator hideActivityIndicator];
            }
        }
    }
}

#pragma mark Coredata table function

- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
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
