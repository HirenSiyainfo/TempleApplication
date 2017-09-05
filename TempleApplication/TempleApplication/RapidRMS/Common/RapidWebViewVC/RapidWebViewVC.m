//
//  RapidWebViewVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 14/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RapidWebViewVC.h"
#import "RmsDbController.h"
#import "CredentialInfo.h"
#import "NSData+Encryption.h"

@interface RapidWebViewVC ()<UIWebViewDelegate>
{
    IBOutlet UIButton *menuButton;
    IBOutlet UIButton *backButton;
}

@property (strong, nonatomic) IBOutlet UIWebView *rapidWebView;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) RapidBackOfficeMenuVC * menuViewVC;

@end

@implementation RapidWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationItem.hidesBackButton = YES;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    self.managedObjectContext = self.crmController.managedObjectContext;
    if (_isMenuEnable) {
        menuButton.hidden = NO;
        self.menuViewVC= [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"RapidBackOfficeMenuVC_sid"];
        [self.view addSubview:self.menuViewVC.view];
        self.menuViewVC.view.hidden=TRUE;
        self.menuViewVC.view.backgroundColor=[UIColor clearColor];
        self.menuViewVC.rapidWebMenuVDelegate=self;
    }
    else
    {
        menuButton.hidden = YES;
    }
    backButton.hidden = NO;
    if(self.pageId < 8){
      backButton.hidden = YES;
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadUserWebGroupInWebView];
}

#pragma mark - UIWebView Delegate -
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //    if ([error code] != NSURLErrorCancelled) {
    //        //show error alert, etc.
    //    }
    //    switch ([error code]) {
    //        case NSURLErrorCancelled:
    //
    //            break;
    //
    //        default:
    //            break;
    //    }
    [_rapidWebView loadHTMLString:error.description baseURL:nil];
    [_activityIndicator hideActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_activityIndicator hideActivityIndicator];
}

#pragma mark - IBAction -

-(IBAction)ShowHideMenu:(id)sender{
    self.menuViewVC.view.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.menuViewVC.view.backgroundColor=[UIColor clearColor];
    [self.menuViewVC showMenu:sender];
}

-(IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WebViewLoadRequest -

-(void)loadUserWebGroupInWebView{
    if (![[self.rmsDbController.globalDict valueForKey:@"UserInfo"] isKindOfClass:[NSString class]]) {
        NSString *currentUserID = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        CredentialInfo *currentUserInfo = [self fetchCredentialInfoForUserId:currentUserID withContext:self.managedObjectContext];
        self.userName = currentUserInfo.email;
        self.password = currentUserInfo.password;
    }
    else
    {
        menuButton.hidden = YES;
        backButton.hidden = NO;
    }
    NSDictionary *parametersList;
   // if (self.pageId == PageIdChangeGroupPrice || self.pageId == PageIdChangeGroupPrice) {
        parametersList = @{@"UserName":self.userName, @"Password":self.password, @"PageId":[NSString stringWithFormat:@"%d",(int)self.pageId], @"DbName":[self.rmsDbController.globalDict valueForKey:@"DBName"]};
//    }
//    else {
//        parametersList = @{@"UserName":self.userName,@"Password":self.password,@"PageId":[NSString stringWithFormat:@"%d",(int)self.pageId]};
//    }

    NSString *jsonString;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parametersList options:NSJSONWritingPrettyPrinted error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        [_rapidWebView loadHTMLString:error.description baseURL:nil];
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSData * encodedData=[self encryptString:jsonString];
        NSString * base64UserInfoString=[encodedData base64EncodedStringWithOptions:0];
        
       // NSString * userGroupURL=[NSString stringWithFormat:@"http://www.rapidrms.com/Account/LoginIOS?Parameters=%@",base64UserInfoString];
        
       NSString * userGroupURL=[NSString stringWithFormat:@"%@Account/LoginIOS?Parameters=%@",RMS_SERVICE_URL, base64UserInfoString];
        
        NSLog(@"Loaded URL : %@",userGroupURL);
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:userGroupURL]];
        [_rapidWebView loadRequest:req];
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    }
}

#pragma mark - Fatch User Info -

- (CredentialInfo*)fetchCredentialInfoForUserId :(NSString *)userId withContext:(NSManagedObjectContext *)context
{
    CredentialInfo *credentialInfo=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CredentialInfo" inManagedObjectContext:context];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId ==%@", userId];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    credentialInfo = resultSet.firstObject;
    return credentialInfo;
}

#pragma mark - Encryption -

- (NSData*) encryptString:(NSString*)plaintext{
    return [[plaintext dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:@"c48ce8176ee24f809eb614d3da6be396"];
}

#pragma mark - ChangeSelectionDelegate -

-(void)didSelectionChangeManu:(PageId)setPage{
    if (self.pageId!=setPage) {
        self.pageId=setPage;
        [self loadUserWebGroupInWebView];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
