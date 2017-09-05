//
//  HConfigurationVC.m
//  RapidRMS
//
//  Created by Siya on 08/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HConfigurationVC.h"
#import "RmsDbController.h"
#import "HConfigurationCell.h"
#import "RmsDbController.h"
#import "LoadingViewController.h"

typedef NS_ENUM(NSUInteger, CONFIG_INFO)
{
    FTP_URL,
    USERNAME,
    PASSWORD,
    WHEREHOUSENO,
    VENDOR_ID,
    ZONE,
};

@interface HConfigurationVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblConfig;

@property (nonatomic, weak) IBOutlet UIButton *btnback;

@property (nonatomic, weak) IBOutlet UILabel *lblStoreName;
@property (nonatomic, weak) IBOutlet UILabel *lbladdress;
@property (nonatomic, weak) IBOutlet UILabel *lblcity;
@property (nonatomic, weak) IBOutlet UILabel *lblphoneno;
@property (nonatomic, weak) IBOutlet UILabel *lblCellTitle;

@property (nonatomic, weak) IBOutlet UITextField *txtvendorId;
@property (nonatomic, weak) IBOutlet UITextField *txtZone;
@property (nonatomic, weak) IBOutlet UITextField *txtWherehouseNo;
@property (nonatomic, weak) IBOutlet UITextField *txtFtpUrl;
@property (nonatomic, weak) IBOutlet UITextField *txtUserName;
@property (nonatomic, weak) IBOutlet UITextField *txtPassword;


@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) RapidWebServiceConnection *vendorConfiguratinoWebService;
@property (nonatomic, strong) RapidWebServiceConnection *vendorItemWebService;

@property (nonatomic, strong) NSMutableArray *storeInfo;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HConfigurationVC
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
    
    if(self.alreadyActive){
        [self.btnback setHidden:YES];
    }
    else{
        [self.btnback setHidden:NO];
    }
    self.appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [self attachKeyboardHelper];
    self.storeInfo = [[NSMutableArray alloc] initWithObjects:@(FTP_URL),@(USERNAME),@(PASSWORD),@(WHEREHOUSENO),@(VENDOR_ID),@(ZONE),nil];
    self.vendorConfiguratinoWebService = [[RapidWebServiceConnection alloc]init];
    
    self.vendorItemWebService = [[RapidWebServiceConnection alloc]init];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    _dictBranchInfo = [self.rmsDbController.globalDict valueForKey:@"BranchInfo"];
    
    _lblStoreName.text=[NSString stringWithFormat:@"%@",[_dictBranchInfo valueForKey:@"BranchName"]];
    _lbladdress.text=[NSString stringWithFormat:@"%@",[_dictBranchInfo valueForKey:@"Address1"]];
    _lblcity.text=[NSString stringWithFormat:@"%@ %@ - %@",[_dictBranchInfo valueForKey:@"Country"],[_dictBranchInfo valueForKey:@"City"],[_dictBranchInfo valueForKey:@"ZipCode"]];
    
    _lblphoneno.text=[NSString stringWithFormat:@"%@",[_dictBranchInfo valueForKey:@"PhoneNo1"]];
    
    
    [self allocTextField];
    
    // Do any additional setup after loading the view.
}

-(void)allocTextField{
    
    NSMutableDictionary *dictInfo = [[NSUserDefaults standardUserDefaults]valueForKey:@"HConfigInfo"];
    
    self.txtFtpUrl = [[UITextField alloc]init];
    self.txtFtpUrl.text = @"ftp://ftp.hackneyco.com/180360/";
    self.txtUserName = [[UITextField alloc]init];
    self.txtUserName.text = @"cu180360";
    self.txtPassword = [[UITextField alloc]init];
    self.txtPassword.text = @"fm180360";

    self.txtvendorId = [[UITextField alloc]init];
    self.txtvendorId.text = [dictInfo valueForKey:@"VendorId"];
    
    self.txtWherehouseNo = [[UITextField alloc]init];
    self.txtWherehouseNo.text = [dictInfo valueForKey:@"Wherehouseno"];
    self.txtZone = [[UITextField alloc]init];
    self.txtZone.text = [dictInfo valueForKey:@"Zone"];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.storeInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellHistory= @"HConfigurationCell";
    
    HConfigurationCell *configcell = (HConfigurationCell *)[tableView dequeueReusableCellWithIdentifier:cellHistory];
    
    configcell.backgroundColor = [UIColor clearColor];
    configcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CONFIG_INFO InfoSection = [self.storeInfo[indexPath.row] integerValue];
    
    CGRect lableFrame = CGRectMake(20.0,10.0,128.0,21.0);
    CGRect textBoxFrame = CGRectMake(145.0,7.0,156.0,30.0);

    [[configcell viewWithTag:500]removeFromSuperview];
    
     self.lblCellTitle = [[UILabel alloc]initWithFrame:lableFrame];
    self.lblCellTitle.font=[UIFont fontWithName:@"Helvetica Neue" size:14.0];
    self.lblCellTitle.tag=500;

    switch (InfoSection) {
        case FTP_URL:
        {
            self.txtFtpUrl.frame=textBoxFrame;
            [self setTextFileProperty: self.txtFtpUrl];
            [configcell addSubview:self.txtFtpUrl];
            self.lblCellTitle.text=@"FTP URL :";
            break;
        }
        case USERNAME:
        {
            self.txtUserName.frame=textBoxFrame;
            [self setTextFileProperty: self.txtUserName];
            [configcell addSubview:self.txtUserName];
            self.lblCellTitle.text=@"UserName :";
            break;
        }
        case PASSWORD:
        {
            self.txtPassword.frame = textBoxFrame;
            [self setTextFileProperty: self.txtPassword];
            [configcell addSubview:self.txtPassword];
            self.lblCellTitle.text=@"Password :";
              break;
        }
        case WHEREHOUSENO:
        {
            self.txtWherehouseNo.frame = textBoxFrame;
            [self setTextFileProperty: self.txtWherehouseNo];
            [configcell addSubview:self.txtWherehouseNo];
            self.lblCellTitle.text=@"Whearehouse No :";
            break;
        }
        case VENDOR_ID:
        {
            self.txtvendorId.frame = textBoxFrame;
            [self setTextFileProperty: self.txtvendorId];
            [configcell addSubview:self.txtvendorId];
            self.lblCellTitle.text=@"Vendor ID :";
            break;
        }
        case ZONE:
        {
            self.txtZone.frame = textBoxFrame;
            [self setTextFileProperty: self.txtZone];
            [configcell addSubview:self.txtZone];
            self.lblCellTitle.text=@"Zone :";
            break;
        }
        default:
            break;
            
    }
    [configcell addSubview: self.lblCellTitle];
    
    
    return configcell;
}

-(void)setTextFileProperty:(UITextField *)txtField{
    
    txtField.borderStyle = UITextBorderStyleRoundedRect;
    txtField.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
    txtField.delegate=self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Required Method
-(BOOL)checkRequireFields{
    
    if([_txtvendorId.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Vendor Id" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
        return FALSE;
        
    }
    else if([_txtZone.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Zone" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
        return FALSE;
        
    }
    else if([_txtWherehouseNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Wherehouse no" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
        return FALSE;
        
    }
    else{
        return TRUE;
    }
}

-(IBAction)nextClick:(id)sender{
    [self callWebServiceForVendorConfiguration];
}

- (void)callWebServiceForVendorConfiguration
{
    if([self checkRequireFields]){
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
        [param setValue:_txtvendorId.text forKey:@"VendorId"];
        [param setValue:_txtZone.text forKey:@"Zone"];
        
        [param setValue:_txtWherehouseNo.text forKey:@"Warehouse"];
        [param setValue:_txtFtpUrl.text forKey:@"FTPURL"];
        [param setValue:_txtUserName.text forKey:@"FTPUserName"];
        [param setValue:_txtPassword.text forKey:@"FTPPassword"];
        [param setValue:@"Hackney" forKey:@"Supplier"];
        
        [self storeconfigInfo];

        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                [self vendorConfigurationResponse:response error:error];
                });
        };
        
        self.vendorConfiguratinoWebService = [self.vendorConfiguratinoWebService initWithRequest:KURL actionName:WSM_VENDOR_CONFIGURATION params:param completionHandler:completionHandler];
    
    }
    
}

- (void)vendorConfigurationResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSString *strVID = [response valueForKey:@"Data"];
                if([strVID isKindOfClass:[NSString class]]){
                    
                    [[NSUserDefaults standardUserDefaults] setObject:strVID forKey:@"HSupplierID"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSMutableDictionary *dictInfo = [[NSUserDefaults standardUserDefaults]valueForKey:@"HConfigInfo"];
                    
                    if([dictInfo isKindOfClass:[NSMutableDictionary class]]){
                        
                        if([[dictInfo valueForKey:@"Zone"] isEqualToString:_txtZone.text] && [[dictInfo valueForKey:@"VendorId"] isEqualToString:_txtvendorId.text] && [[dictInfo valueForKey:@"Wherehouseno"] isEqualToString:_txtWherehouseNo.text] && [self fetchVendorItems:self.managedObjectContext].count>0){
                            
                            [self.rmsDbController disconnect];
                            [self launchDashboard];
                            
                        }
                        else{
                            
                            [self cleanVendorTable];
                            [self callWebServiceForVendorItems];
                        }
                    }
                    else{
                        if([self checkItem].count>0){
                            
                            [self callWebServiceForVendorItems];
                        }
                        else{
                            [self.rmsDbController getItemDataFirstTime];
                        }
                    }
                    
                }
                else{
                    
                    if([self checkItem].count>0){
                        [self launchDashboard];
                    }
                    else{
                        [self.rmsDbController getItemDataFirstTime];
                    }
                }
            }
            else{
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    if([self checkItem].count>0){
                        [self launchDashboard];
                    }
                    else{
                        [self.rmsDbController getItemDataFirstTime];
                    }
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:[NSString stringWithFormat:@"%@",[response  valueForKey:@"Data"]] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
    }
}

-(void)launchDashboard{
    
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *dashBoard = [storyBoard instantiateViewControllerWithIdentifier:@"RmsDashBoard_iPhone"];
    self.appDelegate.navigationController.viewControllers = @[dashBoard];
}

-(NSArray *)checkItem{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (arryTemp.count == 0)
    {
        
    }
    return arryTemp;
}
                   
                   
// Vendor Items

- (void)callWebServiceForVendorItems
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:@"Hackney" forKey:@"SupplierDbName"];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        LoadingViewController *objLoadingScreen = [[LoadingViewController alloc] initWithNibName:@"LoadingVC_iPhone" bundle:nil];
        objLoadingScreen.startingTime=[NSDate date];
      //  [self.appDelegate.navigationController pushViewController:objLoadingScreen animated:TRUE];
        [self.appDelegate.navigationController pushViewController:objLoadingScreen animated:YES];
    }
    else
    {
        LoadingViewController *objLoadingScreen = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
        objLoadingScreen.startingTime=[NSDate date];
       // [self.appDelegate.navigationController pushViewController:objLoadingScreen animated:TRUE];
        [self.appDelegate.navigationController pushViewController:objLoadingScreen animated:YES];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self vendorItemsResponse:response error:error];
                   });
        };
        
        self.vendorItemWebService = [self.vendorItemWebService initWithRequest:KURL actionName:WSM_GET_ITEM_SUPLIER_HACKNEY_DATA params:param completionHandler:completionHandler];
        
    });
    
}

- (void)vendorItemsResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *vendorItem = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                for(NSMutableDictionary *dictVendor in vendorItem){
                    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                    [self.updateManager insertVendorItemWithItem:dictVendor moc:privateContextObject];
                }
                [self launchDashboard];
                [self.rmsDbController dbVersionUpdate];
                
            }
            else{
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:[response  valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
    }
    
}


-(void)cleanVendorTable {
    NSManagedObjectContext *moc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSArray *vendorItems=[self fetchVendorItems:moc];
    for (NSManagedObject *posession in vendorItems)
    {
        [UpdateManager deleteFromContext:moc object:posession];
    }
    [UpdateManager saveContext:moc];
}

- (NSArray*)fetchVendorItems:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vendor_Item" inManagedObjectContext:moc];
    fetchRequest.entity = entity;

    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}


-(void)storeconfigInfo{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict[@"Zone"] = _txtZone.text;
    dict[@"VendorId"] = _txtvendorId.text;
    dict[@"Wherehouseno"] = _txtWherehouseNo.text;
    
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"HConfigInfo"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

- (void)keyboardWillAppear:(NSNotification *)notification{
    NSDictionary* userInfo = notification.userInfo;
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    if(self.view==self.tblConfig){
        CGRect newTableFrame = CGRectMake(self.tblConfig.frame.origin.x, self.tblConfig.frame.origin.y, self.tblConfig.frame.size.width, self.view.bounds.size.height-keyboardFrame.size.height);
        self.tblConfig.frame = newTableFrame;
    }else{
        CGRect newTableFrame = CGRectMake(self.tblConfig.frame.origin.x, self.tblConfig.frame.origin.y, self.tblConfig.frame.size.width, self.view.bounds.size.height-self.tblConfig.frame.origin.y-keyboardFrame.size.height);
        self.tblConfig.frame = newTableFrame;
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary* userInfo = notification.userInfo;
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    CGRect newTableFrame = CGRectMake(self.tblConfig.frame.origin.x, self.tblConfig.frame.origin.y, self.tblConfig.frame.size.width, 250.0);
    self.tblConfig.frame = newTableFrame;
    if(newTableFrame.size.height>self.tblConfig.contentSize.height-self.tblConfig.contentOffset.y){
        float newOffset=MAX(self.tblConfig.contentSize.height-newTableFrame.size.height, 0);
        [self.tblConfig setContentOffset:CGPointMake(0, newOffset) animated:YES];
    }
    
}
- (void)attachKeyboardHelper{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(IBAction)backClick:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self detachKeyboardHelper];
}

- (void)detachKeyboardHelper{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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
