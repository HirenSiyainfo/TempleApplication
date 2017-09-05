//
//  ICHomeVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 31/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ICNewVC.h"
#import "RmsDbController.h"
#import "RimsController.h"

#import "ICHomeVC.h"
#import "ItemCountListVC.h"
#import "IntercomHandler.h"

@interface ICNewVC ()<UITextFieldDelegate,UpdateDelegate>
{
    NSDate *currentDate ;
    IntercomHandler  *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *endDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *invCountNo;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

//@property (nonatomic, weak) IBOutlet UITextField *remark;

@property (nonatomic, weak) IBOutlet UITextView *remark;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *iNewUpdateManager;

@property (nonatomic, strong) RapidWebServiceConnection *addInventoryCountSessionWC;
@property (nonatomic, strong) RapidWebServiceConnection *addInventoryCountUserSessionWC;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDictionary *dictNewINCountSession;

@end

@implementation ICNewVC
@synthesize managedObjectContext = __managedObjectContext;

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
    self.navigationController.navigationBarHidden = YES;
    [self configureUI];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.addInventoryCountSessionWC = [[RapidWebServiceConnection alloc] init];
    self.addInventoryCountUserSessionWC = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.iNewUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
   
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"helpbtn.png" selectedImage:@"helpbtnselected.png" withViewController:self];

    // Do any additional setup after loading the view from its nib.
}

-(void)configureUI
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSString* str = [formatter stringFromDate:date];
    _startDateLabel.text = str.uppercaseString;
}

-(IBAction)proceedToItemCountList:(id)sender
{
    if(_remark.text.length > 0 && ![_remark.text isEqualToString:@"ADD YOUR REMARK HERE."])
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [self generateNewSessionForInventoryCount];
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Please enter remark" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }

}

-(void) generateNewSessionForInventoryCount
{
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:_remark.text forKey:@"Remarks"];
    [param setValue:[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
    
    currentDate = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateValue = [formatter stringFromDate:currentDate];
    [param setValue:currentDateValue forKey:@"LocalDate"];

    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseNewSessionResponse:response error:error];
        });
    };
    
    self.addInventoryCountSessionWC = [self.addInventoryCountSessionWC initWithRequest:KURL actionName:WSM_ADD_INVENTORY_COUNT_SESSION params:param completionHandler:completionHandler];
}

- (void)responseNewSessionResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSDictionary *responseDictionary = [self.rmsDbController objectFromJsonString:[response  valueForKey:@"Data"]];
                self.dictNewINCountSession = [responseDictionary mutableCopy ];
                
                UIAlertController *customerAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ created successfully",_remark.text] message:@"Define your starting point" preferredStyle:UIAlertControllerStyleAlert];
                
                [customerAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
                 {
                     textField.placeholder = @"Starting point";
                 }];
                
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action)
                                         {
                                             [self backToHomeVC];
                                         }];
                UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          NSString *joineeName = customerAlert.textFields[0].text;
                                          if([joineeName isEqualToString:@""])
                                          {
                                              [self backToHomeVC];
                                          }
                                          else
                                          {
                                              _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                                              NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
                                              [param setValue:[self.dictNewINCountSession valueForKey:@"StockSessionId"] forKey:@"StockSessionId"];
                                              [param setValue:[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
                                              [param setValue:joineeName forKey:@"UserSessionName"];
                                              [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
                                              
                                              NSDate *aCurrentDate = [NSDate date];
                                              NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                                              formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
                                              NSString *currentDateValue = [formatter stringFromDate:aCurrentDate];
                                              [param setValue:currentDateValue forKey:@"LocalDate"];
                                              [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                                              
                                              NSMutableDictionary *invCountUserSessionParam = [[NSMutableDictionary alloc] init ];
                                              [invCountUserSessionParam setValue:param forKey:@"objInvCountUserSession"];
                                              
                                              CompletionHandler completionHandler = ^(id response, NSError *error) {
                                                  
                                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                      [self respAddInventoryCountUserSessionResponse:response error:error];
                                                  });

                                              };
                                              
                                              self.addInventoryCountUserSessionWC = [self.addInventoryCountUserSessionWC initWithRequest:KURL actionName:WSM_ADD_INVENTORY_COUNT_USER_SESSION params:invCountUserSessionParam completionHandler:completionHandler];
                                          }
                                      }];
                
                [customerAlert addAction:add];
                [customerAlert addAction:cancel];
                [self presentViewController:customerAlert animated:YES completion:nil];
                
                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error generate while creating inventory count. Please contact rapidrms." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

- (void)backToHomeVC
{
    NSArray *arryView = self.navigationController.viewControllers;
    for(int i=0; i< arryView.count; i++){
        
        UIViewController *viewCon = arryView[i];
        if([viewCon isKindOfClass:[ICHomeVC class]])
        {
            [self.navigationController popToViewController:viewCon animated:YES];
            break;
        }
    }
}

- (void)respAddInventoryCountUserSessionResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSString *sessionId = [response valueForKey:@"Data"];
                NSNumber *userSessionId = @(sessionId.integerValue);
                
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                [self.iNewUpdateManager insertInventoryCountSessionInLocalDataBaseWithDetail:[self createSessionDictionaryWithSessionId:self.dictNewINCountSession] withContext:privateContextObject];
                
                ItemInventoryCountSession *itemInventoryCountSession = [self.iNewUpdateManager fetchItemInventoryCountSession:[self.dictNewINCountSession valueForKey:@"StockSessionId"] moc:self.rmsDbController.managedObjectContext];
                
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
                ItemCountListVC *objItemCountList = [storyBoard instantiateViewControllerWithIdentifier:@"ItemCountListVC_sid"];
                objItemCountList.userSessionId = userSessionId;
                objItemCountList.currentItemInventoryCountSession = itemInventoryCountSession;
                objItemCountList.inventoryCountSessionDictionary = self.dictNewINCountSession;
                objItemCountList.isRecallList = NO;
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

-(NSMutableDictionary *)createSessionDictionaryWithSessionId :(NSDictionary *)responseDictionary
{
    NSMutableDictionary *sessionDictionary = [[NSMutableDictionary alloc]init];
    sessionDictionary[@"StockSessionId"] = [responseDictionary valueForKey:@"StockSessionId"];
    sessionDictionary[@"StartDate"] = currentDate;
    sessionDictionary[@"EndDate"] = currentDate;
    sessionDictionary[@"Status"] = [responseDictionary valueForKey:@"Status"];
    [sessionDictionary setValue:[responseDictionary valueForKey:@"Remarks"] forKey:@"Remarks"];
    [sessionDictionary setValue:[responseDictionary valueForKey:@"BranchId"] forKey:@"BranchId"];
    [sessionDictionary setValue:[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
    [sessionDictionary setValue:[responseDictionary valueForKey:@"RegisterId"] forKey:@"RegisterId"];
    return sessionDictionary;
}
-(void)updateQtyInLocalDataBase
{
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(IBAction)backToRootView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"ADD YOUR REMARK HERE."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"ADD YOUR REMARK HERE.";
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
