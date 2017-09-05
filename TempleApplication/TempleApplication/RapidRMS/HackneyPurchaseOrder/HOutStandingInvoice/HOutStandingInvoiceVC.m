//
//  HOutStandingInvoiceVC.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HOutStandingInvoiceVC.h"
#import "HOutStandingCustomCell.h"
#import "RmsDbController.h"

@interface HOutStandingInvoiceVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblOutStanding;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *poOutStandingwebservice;

@property (nonatomic, strong) NSMutableArray *arrayOutStanding;
@end

@implementation HOutStandingInvoiceVC

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

    NSString  *outstandingCell;
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        outstandingCell = @"HOutStandingCustomCell_iPhone";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:outstandingCell bundle:nil];
    [self.tblOutStanding registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HOutStandingCustomCell"];
    
    self.poOutStandingwebservice = [[RapidWebServiceConnection alloc]init];
    [self callWebServiceForOrderHistory];

}

- (void)callWebServiceForOrderHistory
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    param[@"Status"] = @"3";
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self outstandingInvoicesResponse:response error:error];
        });
    };
    
    self.poOutStandingwebservice = [self.poOutStandingwebservice initWithRequest:KURL actionName:WSM_LIST_HACKNEY_PO params:param completionHandler:completionHandler];
    
}

- (void)outstandingInvoicesResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _arrayOutStanding = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblOutStanding reloadData];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.arrayOutStanding.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100.0;
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"HOutStandingCustomCell";
    
    HOutStandingCustomCell *outstandingCell = (HOutStandingCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    outstandingCell.selectionStyle=UITableViewCellSelectionStyleNone;
    outstandingCell.backgroundColor=[UIColor clearColor];
    
    NSMutableDictionary *dictReceorder = (self.arrayOutStanding)[indexPath.row];
    
    NSString *startDate = [self getStringFormateFromString:[dictReceorder valueForKey:@"StartDate"] fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"MM/dd/yyy"];

    outstandingCell.lblDate.text = startDate;
    outstandingCell.lblOrderTitle.text = [dictReceorder valueForKey:@"OrderName"];
    outstandingCell.lblItemCount.text = [NSString stringWithFormat:@"%@ Items", [dictReceorder valueForKey:@"ItemCount"]];
    return outstandingCell;
    
}

- (NSString *)getStringFormateFromString:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
    dateFormatter2.dateFormat = pstrToformate;
    NSString *result = [dateFormatter2 stringFromDate:dateFromString];
    
    return result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)gotoHome:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
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
