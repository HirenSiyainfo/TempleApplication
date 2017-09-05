//
//  PassInquiry.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PassInquiry.h"
#import "PassInquiryCustomCell.h"
#import "RmsDbController.h"
#import "PassPrinting.h"
#import "PrinterFunctions.h"

@interface PassInquiry() <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PrinterFunctionsDelegate>
{
    IBOutlet UITableView *tblPassInquiry;
    IBOutlet UITextField *searchTextField;
    IBOutlet UIButton *rePrintButton;

    NSMutableArray *arrPassInquiry;
    NSMutableArray *dispalyPassInquiryArray;
    NSMutableArray *rePrintPassArray;
    NSArray *array_port;
    NSInteger selectedPort;
}
@property (atomic) NSInteger printJobCount;

@property (strong,nonatomic) RmsDbController *rmsDbController;
@property (nonatomic,strong) RapidWebServiceConnection *passInquiryWebServiceConnection;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@end

@implementation PassInquiry

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.passInquiryWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    rePrintButton.enabled = NO;
    [self getPassInquiry];
}

- (void)getPassInquiry
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
   
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    dict[@"LocalDate"] = [dateFormatter stringFromDate:date];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responsePassInquiryDetailResponse:response error:error];
        });
    };
    
    self.passInquiryWebServiceConnection = [self.passInquiryWebServiceConnection initWithRequest:KURL actionName:WSM_GET_TICKET_ALL_DATA params:dict completionHandler:completionHandler];
}

-(void)responsePassInquiryDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                arrPassInquiry = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                dispalyPassInquiryArray = [arrPassInquiry mutableCopy];
                [tblPassInquiry reloadData];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Webservice response is nil" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dispalyPassInquiryArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"PassInquiryCell";
    PassInquiryCustomCell *passInquiryCustomCell = (PassInquiryCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSDictionary *passInquiryDict = dispalyPassInquiryArray[indexPath.row];
    passInquiryCustomCell.qRCodeImageView.image = [self generateQRCodeWithString:[passInquiryDict valueForKey:@"QRCode"]];
    passInquiryCustomCell.lblPassNo.text = [passInquiryDict valueForKey:@"CRDNumber"];
    passInquiryCustomCell.lblInvoiceNo.text = [passInquiryDict valueForKey:@"RegInvoiceNo"];
    passInquiryCustomCell.lblInvoiceDate.text = [passInquiryDict valueForKey:@"InvoiceDate"];
    passInquiryCustomCell.lblItemDescription.text = [passInquiryDict valueForKey:@"ItemName"];

    return passInquiryCustomCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedIndexpathArray = tblPassInquiry.indexPathsForSelectedRows;
    if (selectedIndexpathArray.count > 0) {
        rePrintButton.enabled = YES;
    }
    else
    {
        rePrintButton.enabled = NO;
    }
}

- (UIImage *)generateQRCodeWithString:(NSString *)string {
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    return [UIImage imageWithCIImage:filter.outputImage];
}

- (IBAction)btnReprintClicked:(id)sender
{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        NSArray *selectedIndexpathArray = tblPassInquiry.indexPathsForSelectedRows;
        NSMutableArray *passArray = [[NSMutableArray alloc] init];
        for (NSIndexPath *selectedIndexpath in selectedIndexpathArray) {
            [passArray addObject:dispalyPassInquiryArray[selectedIndexpath.row]];
            [tblPassInquiry deselectRowAtIndexPath:selectedIndexpath animated:YES];
            rePrintButton.enabled = NO;
        }
        [self genrateReprintPassArray:passArray];
        [self printNextPass];
        NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tblPassInquiry scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    };
    
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are sure want to reprint?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (IBAction)btnSearchClicked:(id)sender
{
    if(searchTextField.text.length > 0)
    {
        [searchTextField resignFirstResponder];
        NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tblPassInquiry scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSPredicate *searchPredicate = [self searchPredicateForText:searchTextField.text];
        NSArray *passArray = [arrPassInquiry filteredArrayUsingPredicate:searchPredicate];
        if(passArray.count > 0)
        {
            dispalyPassInquiryArray = [passArray mutableCopy];
            [tblPassInquiry reloadData];
        }
        else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Record Found" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
        [_activityIndicator hideActivityIndicator];;
    }
}

-(NSPredicate *)searchPredicateForText:(NSString *)searchData
{
    NSMutableArray *textArray=[[searchData componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields =  @[ @"CRDNumber contains[cd] %@",@"RegInvoiceNo contains[cd] %@",@"InvoiceDate contains[cd] %@",@"ItemName contains[cd] %@"];
    
    for (int i=0; i<textArray.count; i++)
    {
        NSString *str=textArray[i];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSMutableArray *searchTextPredicates = [NSMutableArray array];
        for (NSString *dbField in dbFields)
        {
            if (![str isEqualToString:@""])
            {
                [searchTextPredicates addObject:[NSPredicate predicateWithFormat:dbField, str]];
            }
        }
        NSPredicate *compoundpred = [NSCompoundPredicate orPredicateWithSubpredicates:searchTextPredicates];
        [fieldWisePredicates addObject:compoundpred];
    }
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
    return finalPredicate;
}

- (void)genrateReprintPassArray:(NSArray *)passArray
{
    rePrintPassArray = [NSMutableArray array];
    for (NSMutableDictionary *passDictionary in passArray) {
        NSMutableDictionary *reprintPassDictionary = [[NSMutableDictionary alloc] init];
        reprintPassDictionary[@"CRDNumber"] = passDictionary[@"CRDNumber"];
        reprintPassDictionary[@"QRCode"] = passDictionary[@"QRCode"];
        reprintPassDictionary[@"CustomerId"] = passDictionary[@"CustomerId"];
        reprintPassDictionary[@"IsVoid"] = passDictionary[@"IsVoid"];
        reprintPassDictionary[@"Remark"] = passDictionary[@"Remark"];
        reprintPassDictionary[@"ExpirationDay"] = [NSString stringWithFormat:@"%@",passDictionary[@"ExpirationDays"]];
        reprintPassDictionary[@"NoOfDay"] = [NSString stringWithFormat:@"%@",passDictionary[@"NoOfdays"]];
        reprintPassDictionary[@"InvoiceNo"] = passDictionary[@"RegInvoiceNo"];
        reprintPassDictionary[@"ItemName"] = passDictionary[@"ItemName"];
        [rePrintPassArray addObject:reprintPassDictionary];
    }
}

-(void)printNextPass
{
    if (rePrintPassArray.count == 0) {
        return;
    }
    
    PassPrinting *passPrinting = [[PassPrinting alloc] init];
    passPrinting._printingData = rePrintPassArray.lastObject;
    
    NSString *portName     = @"";
    NSString *portSettings = @"";
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    [passPrinting printingWithPort:portName portSettings:portSettings withDelegate:self];
}

#pragma mark - Printer Function Delegate

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
    if ([device isEqualToString:@"Printer"]) {
        self.printJobCount--;
        [rePrintPassArray removeLastObject];
        [self printNextPass];
    }
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    self.printJobCount--;
    NSString *retryMessage  ;
    retryMessage = @"Failed to pass print receipt. Would you like to retry.?";
    [self displayPassPrintRetryAlert:retryMessage];
}

-(void)displayPassPrintRetryAlert :(NSString *)message
{
    PassInquiry * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference printNextPass];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)setPortName:(NSString *)m_portName
{
    [RcrController setPortName:m_portName];
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    [RcrController setPortSettings:m_portSettings];
}

- (void)SetPortInfo
{
    NSString *localPortName;
    
    NSString *Str = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"];
    
    if(Str.length > 0)
    {
        if ([Str isEqualToString:@"Bluetooth"])
        {
            localPortName=@"BT:Star Micronics";
        }
        else if([Str isEqualToString:@"TCP"]){
            NSString *tcp = [[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"];
            localPortName=tcp;
        }
    }
    else{
        localPortName=@"BT:Star Micronics";
    }
    
    [PassInquiry setPortName:localPortName];
    [PassInquiry setPortSettings:array_port[selectedPort]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == searchTextField) {
        [self btnSearchClicked:nil];
        [searchTextField resignFirstResponder];
    }
    return true;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == searchTextField) {
        searchTextField.text =  @"";
        dispalyPassInquiryArray = [arrPassInquiry mutableCopy];
        [tblPassInquiry reloadData];
        [searchTextField resignFirstResponder];
    }
    return true;
}
@end
