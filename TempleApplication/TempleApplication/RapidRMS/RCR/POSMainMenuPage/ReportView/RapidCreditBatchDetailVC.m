//
//  RapidCreditBatchDetailVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 2/20/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RapidCreditBatchDetailVC.h"
#import "RapidCreditBatchDetailCell.h"
#import "RmsDbController.h"

@interface RapidCreditBatchDetailVC ()
{
    IBOutlet UITableView *rapidCreditBatchDetailTable;
    IBOutlet UILabel *totalTransaction;
    IBOutlet UILabel *avgTicket;
    IBOutlet UILabel *totalAmount;
    NSMutableArray *rapidCreditBatchDetailArray;
}
@property (nonatomic, strong) RapidWebServiceConnection *rapidCreditBatchDetailConnection;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@end

@implementation RapidCreditBatchDetailVC

- (void)viewDidLoad {
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpCreditBatchUI {
    totalTransaction.text = @"0";
    avgTicket.text = @"$0.00";
    totalAmount.text = @"$0.00";
    if (rapidCreditBatchDetailArray && rapidCreditBatchDetailArray.count > 0) {
        [rapidCreditBatchDetailArray removeAllObjects];
    }
    [rapidCreditBatchDetailTable reloadData];
}

-(void)updateRapidCreditBatchDetailWithZID:(NSString *)zId needToReload:(BOOL)needToReload
{
    if (!needToReload) {
        if (rapidCreditBatchDetailArray.count > 0) {
            [self updateUI];
        }
        return;
    }
    [self setUpCreditBatchUI];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:zId forKey:@"ZId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseUpdateRapidCreditBatchDetailResponse:response error:error];
        });
    };

    self.rapidCreditBatchDetailConnection = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_CREDIT_CARD_DATA_BY_ZID params:param completionHandler:completionHandler];
}

-(void)responseUpdateRapidCreditBatchDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                rapidCreditBatchDetailArray = [[NSMutableArray alloc] init];
                NSMutableArray *responseArray  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                rapidCreditBatchDetailArray = [responseArray mutableCopy];
                if (rapidCreditBatchDetailArray.count > 0) {
                    [self updateUI];
                }
                else
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Record found For Credit Batch." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
        }
    }
}

- (void)updateUI {
    totalTransaction.text = [NSString stringWithFormat:@"%lu",(unsigned long)rapidCreditBatchDetailArray.count];
    avgTicket.text = [NSString stringWithFormat:@"%@",[self averageTransactionForAll:rapidCreditBatchDetailArray]];
    totalAmount.text = [self.rmsDbController applyCurrencyFomatter:[self totalAmount:rapidCreditBatchDetailArray]];
    [rapidCreditBatchDetailTable reloadData];
}

-(NSString *)averageTransactionForAll:(NSMutableArray *)responseArray
{
    NSMutableArray * cardCountDict = [responseArray mutableCopy];
    NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.BillAmount"];
    NSString *str = [NSString stringWithFormat:@"%f",sum.floatValue];
    float averageTotal;
    if(cardCountDict.count > 0)
    {
        averageTotal = str.floatValue / cardCountDict.count;
    }
    else
    {
        averageTotal = 0.00;
    }
    return [NSString stringWithFormat:@"%.2f",averageTotal];
}


-(NSString *)totalAmount:(NSMutableArray *)responseArray
{
    NSNumber *sum=[responseArray valueForKeyPath:@"@sum.BillAmount"];
    NSString *str = [NSString stringWithFormat:@"%.2f",sum.floatValue];
    return str;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rapidCreditBatchDetailArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RapidCreditBatchDetailCell *rapidCreditBatchDetailCell = (RapidCreditBatchDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"RapidCreditBatchDetailCell"];
    rapidCreditBatchDetailCell.amount.text = [self.rmsDbController applyCurrencyFomatter:[rapidCreditBatchDetailArray[indexPath.row] valueForKey:@"BillAmount"]];
    rapidCreditBatchDetailCell.authCode.text = [NSString stringWithFormat:@"%@",[rapidCreditBatchDetailArray[indexPath.row] valueForKey:@"AuthCode"]];
    rapidCreditBatchDetailCell.lblDate.text = [NSString stringWithFormat:@"%@",[rapidCreditBatchDetailArray[indexPath.row] valueForKey:@"BillDate"]];
    rapidCreditBatchDetailCell.cardType.text = [NSString stringWithFormat:@"%@",[rapidCreditBatchDetailArray[indexPath.row] valueForKey:@"CardType"]];
    rapidCreditBatchDetailCell.invoice.text = [NSString stringWithFormat:@"%@",[rapidCreditBatchDetailArray[indexPath.row] valueForKey:@"RegisterInvNo"]];
    rapidCreditBatchDetailCell.accountNo.text = [NSString stringWithFormat:@"%@",[rapidCreditBatchDetailArray[indexPath.row] valueForKey:@"AccNo"]];
    
    NSString *strDate = [self getStringFormat:[rapidCreditBatchDetailArray[indexPath.row] valueForKey:@"BillDate"] fromFormat:@"MM-dd-yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy"];
    
    NSString *strTime = [self getStringFormat:[rapidCreditBatchDetailArray[indexPath.row] valueForKey:@"BillDate"] fromFormat:@"MM-dd-yyyy HH:mm:ss" toFormate:@"hh:mm a"];
    
    rapidCreditBatchDetailCell.lblDate.text = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
    rapidCreditBatchDetailCell.contentView.backgroundColor = [UIColor clearColor];
    rapidCreditBatchDetailCell.backgroundColor = [UIColor clearColor];
    return rapidCreditBatchDetailCell;
}
-(NSString *)getStringFormat:(NSString *)pstrDate fromFormat:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
