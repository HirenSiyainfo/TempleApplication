//
//  ICJoinCountVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 1/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ICJoinCountVC.h"
#import "ICJointCountCustomCell.h"

#import "RmsDbController.h"
#import "RimsController.h"
#import "ItemCountListVC.h"
#import "ItemInventoryCountSession+Dictionary.h"
#import "NSString+Methods.h"
#import "IntercomHandler.h"

@interface ICJoinCountVC ()<UpdateDelegate>
{
    NSIndexPath *joineeIndexPath;
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UITableView *jointCountTableView;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *iJoinUpdateManager;

@property (nonatomic, strong) RapidWebServiceConnection *getOpenInventoryCountSessionWC;
@property (nonatomic, strong) RapidWebServiceConnection *deleteInventoryCountSessionWC;
@property (nonatomic, strong) RapidWebServiceConnection *addInventoryCountUserSessionWC;

@property (nonatomic, strong) NSMutableArray *joinCountListArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation ICJoinCountVC

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
    self.addInventoryCountUserSessionWC = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.iJoinUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];

    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"helpbtn.png" selectedImage:@"helpbtnselected.png" withViewController:self];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.joinCountListArray = [[NSMutableArray alloc] init];
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

- (void)reloadJoinCountList:(NSMutableArray *)responseItemArray
{
    self.joinCountListArray = [self.rmsDbController objectFromJsonString:[responseItemArray valueForKey:@"Data"]];
    
    for (int i = 0; i < self.joinCountListArray.count; i++) {
        CGFloat count = (float)self.joinCountListArray.count;
        CGFloat intPercentage = i / count ;
        [_activityIndicator updateProgressStatus:intPercentage];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_jointCountTableView reloadData];
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
                        [self reloadJoinCountList:responseItemArray];
                    });
                }
                else
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"No Record Found join count data." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    [_activityIndicator hideActivityIndicator];
                    
                }
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error occur while generating list." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [_activityIndicator hideActivityIndicator];
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
                [self.joinCountListArray removeObjectAtIndex:joineeIndexPath.row];
                [_jointCountTableView reloadData];
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
    
    if(tableView == _jointCountTableView )
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            
            joineeIndexPath = [indexPath copy];
            NSMutableDictionary *joinDict = (self.joinCountListArray)[joineeIndexPath.row];
            
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
            [param setValue:[joinDict valueForKey:@"StockSessionId"] forKey:@"StockSessionId"];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
       return self.joinCountListArray.count;
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
    ICJointCountCustomCell *iCJointCountCustomCell = (ICJointCountCustomCell *)[tableView dequeueReusableCellWithIdentifier:@"ICJointCountCustomCell"];
    
    UIView *viewBG = [[UIView alloc] initWithFrame:iCJointCountCustomCell.bounds];
    viewBG.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    iCJointCountCustomCell.selectedBackgroundView = viewBG;

    NSMutableDictionary *joinDict = (self.joinCountListArray)[indexPath.row];
    
    NSString  *aStartDate = [NSString stringWithFormat:@"%@",[joinDict valueForKey:@"LocalDate"]];
    iCJointCountCustomCell.startDateLabel.text = [self getStringFormate:aStartDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy hh:mm a"];
    
    iCJointCountCustomCell.invCountLabel.text = [NSString stringWithFormat:@"%@",[joinDict valueForKey:@"StockSessionId"]];
    iCJointCountCustomCell.remarkLabel.text = [NSString stringWithFormat:@"%@",[joinDict valueForKey:@"Remarks"]];
    NSString * icUserName = [NSString stringWithFormat:@"%@",[joinDict valueForKey:@"UserName"]];
    if (![joinDict valueForKey:@"UserName"] || [[joinDict valueForKey:@"UserName"] isKindOfClass:[NSNull class]]) {
        iCJointCountCustomCell.currentUserLabel.text = @"-";
    }
    else{
        iCJointCountCustomCell.currentUserLabel.text = icUserName;
    }
    return iCJointCountCustomCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *joinDict = (self.joinCountListArray)[indexPath.row];
    NSString *remarks = [NSString stringWithFormat:@"%@",[joinDict valueForKey:@"Remarks"]];
    
    UIAlertController *customerAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ about to joining",remarks] message:@"Define your starting point" preferredStyle:UIAlertControllerStyleAlert];
    
    [customerAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Starting point";
     }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 
                             }];
    UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action)
                          {
                              NSString *joineeName = customerAlert.textFields[0].text;
                              if([joineeName isEqualToString:@""])
                              {
                                  
                              }
                              else
                              {
                                  NSMutableDictionary *joinDict = (self.joinCountListArray)[joineeIndexPath.row];
                                  _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                                  NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
                                  [param setValue:[joinDict valueForKey:@"StockSessionId"] forKey:@"StockSessionId"];
                                  [param setValue:[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
                                  [param setValue:joineeName forKey:@"UserSessionName"];
                                  [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
                                  NSDate *currentDate = [NSDate date];
                                  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                                  formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
                                  NSString *currentDateValue = [formatter stringFromDate:currentDate];
                                  [param setValue:currentDateValue forKey:@"LocalDate"];
                                  [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                                  
                                  NSMutableDictionary *invCountUserSessionParam = [[NSMutableDictionary alloc] init ];
                                  [invCountUserSessionParam setValue:param forKey:@"objInvCountUserSession"];
                                  
                                  CompletionHandler completionHandler = ^(id response, NSError *error) {
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                          [self addInventoryCountUserSessionResponse:response error:error];
                                      });
                                  };
                                  
                                  self.addInventoryCountUserSessionWC = [self.addInventoryCountUserSessionWC initWithRequest:KURL actionName:WSM_ADD_INVENTORY_COUNT_USER_SESSION params:invCountUserSessionParam completionHandler:completionHandler];
                              }
                          }];
    
    [customerAlert addAction:add];
    [customerAlert addAction:cancel];
    [self presentViewController:customerAlert animated:YES completion:nil];
    
    joineeIndexPath = [indexPath copy];
}

- (void)addInventoryCountUserSessionResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self deleteOlduserSessionData];
                NSString *sessionId = [response valueForKey:@"Data"];
                NSNumber *userSessionId = @(sessionId.integerValue);
                
                NSMutableDictionary *joinDict = (self.joinCountListArray)[joineeIndexPath.row];
                
                ItemInventoryCountSession *itemInventoryCountSession = [self.iJoinUpdateManager fetchItemInventoryCountSession:[joinDict valueForKey:@"StockSessionId"] moc:self.managedObjectContext];
                if (itemInventoryCountSession == nil)
                {
                    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                    itemInventoryCountSession = [self.iJoinUpdateManager insertInventoryCountSessionInLocalDataBaseWithDetail:joinDict withContext:privateContextObject];
                    itemInventoryCountSession = (ItemInventoryCountSession *)OBJECT_COPY(itemInventoryCountSession, self.managedObjectContext);
                }
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
                ItemCountListVC *objItemCountList = [storyBoard instantiateViewControllerWithIdentifier:@"ItemCountListVC_sid"];
                objItemCountList.userSessionId = userSessionId;
                objItemCountList.currentItemInventoryCountSession = itemInventoryCountSession;
                objItemCountList.inventoryCountSessionDictionary = joinDict;
                [self.navigationController pushViewController:objItemCountList animated:YES];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error occur while joining selected session, please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

-(void)deleteOlduserSessionData {
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
