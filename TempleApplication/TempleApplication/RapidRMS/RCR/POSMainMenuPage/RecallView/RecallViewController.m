//
//  RecallViewController.m
//  POSRetail
//
//  Created by Keyur Patel on 23/07/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import "RecallViewController.h"
#import "RcrController.h"
#import "RmsDbController.h"
#import "HoldInvoice+Dictionary.h"
#import "RecallCustomCell.h"
#import "RecallSectionHeaderView.h"
#import "PreOrderReceiptPrint.h"

typedef NS_ENUM(NSInteger, RECALL_DATA_SECTION) {
 OFFLINE_HOLD_INVOICE,
 ONLINE_HOLD_INVOICE,
};

@interface RecallViewController ()<UpdateDelegate>
{
    NSInteger nextIndex;
    BOOL isOfflineHoldInvoiceUploadProcessInprogress;
    IntercomHandler *intercomHandler;
    
    IBOutlet UIView *uvTblBg;
    
    NSMutableArray *recallarray;
    int itemArrayIndex;
    NSArray *array_port;
    NSMutableArray *holdDataItemArray;
    NSString *onlineHoldInvoiceDate;


}

@property (nonatomic , weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic , weak) IBOutlet UITableView *tblrecalllist;


@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *recallWebservice;
@property (nonatomic, strong) RapidWebServiceConnection *deleteRecallRecordConnection;
@property (nonatomic, strong) RapidWebServiceConnection *holdInvoiceOfflineUploadWC;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) NSArray *recallDataSection;
@property (nonatomic, strong) NSFetchedResultsController *recallDataDisplayResultController;
@property (nonatomic, strong) NSArray *offlineInvoice;
@property (nonatomic, strong) NSRecursiveLock *recallViewLock;

@property (nonatomic, strong) RapidWebServiceConnection *holdRecordWC;



@end

@implementation RecallViewController

@synthesize managedObjectContext = __managedObjectContext;
@synthesize recallDataDisplayResultController = __recallDataDisplayResultController;

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
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.recallWebservice= [[RapidWebServiceConnection alloc]init];
    self.holdInvoiceOfflineUploadWC = [[RapidWebServiceConnection alloc]init];
    self.deleteRecallRecordConnection = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    self.recallDataSection = @[@(OFFLINE_HOLD_INVOICE),@(ONLINE_HOLD_INVOICE)];
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    [_tblrecalllist registerNib:[UINib nibWithNibName:@"RecallCustomCell" bundle:nil] forCellReuseIdentifier:@"RecallCustomCell"];
    
    _tblrecalllist.layer.borderWidth = 1.0;
    _tblrecalllist.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _tblrecalllist.layer.cornerRadius = 5.0;
    
    uvTblBg.layer.cornerRadius = 5.0;
    
    itemArrayIndex=-1;
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self GetRecallData];
}
- (NSFetchedResultsController *)recallDataDisplayResultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.recallViewLock];
    if (__recallDataDisplayResultController != nil) {
        return __recallDataDisplayResultController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HoldInvoice" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"holdDate" ascending:YES selector:nil];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    __recallDataDisplayResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [__recallDataDisplayResultController performFetch:nil];
    __recallDataDisplayResultController.delegate = self;
    [lock unlock];
    return __recallDataDisplayResultController;
}

-(void) GetRecallData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    
//    CompletionHandler completionHandler = ^(id response, NSError *error) {
//        [self responseRecalllistResponse:response error:error];
//    };
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseRecalllistResponse:response error:error];
        });
    };
    
    self.recallWebservice = [self.recallWebservice initWithRequest:KURL actionName:WSM_RECALL_INVOICE_LIST_SERVICE params:param completionHandler:completionHandler];
    
}
- (void)responseRecalllistResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray * responsearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                recallarray = [[NSMutableArray alloc] init];
                if(responsearray.count>0)
                {
                    recallarray=[[NSMutableArray alloc]initWithArray:responsearray];
                    self.crmController.recallCount = recallarray.count;
                    self.crmController.recallCount +=[self.updateManager fetchEntityObjectsCounts:@"HoldInvoice" withManageObjectContext:self.managedObjectContext];
                }
                else
                {
                    self.crmController.recallCount = recallarray.count;
                    self.crmController.recallCount +=[self.updateManager fetchEntityObjectsCounts:@"HoldInvoice" withManageObjectContext:self.managedObjectContext];
                }
            }
        }
    }
    else
    {
        self.crmController.recallCount = [self.updateManager fetchEntityObjectsCounts:@"HoldInvoice" withManageObjectContext:self.managedObjectContext];
    }
    
    _tblrecalllist.delegate = self;
    _tblrecalllist.dataSource = self;
    self.recallDataDisplayResultController = nil;
    //    [self recallDataDisplayResultController];
    [_tblrecalllist reloadData];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.recallDataSection.count;
}
/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( [[self.recallDataSection objectAtIndex:section]integerValue] == OFFLINE_HOLD_INVOICE)
    {
        if([self.updateManager fetchEntityObjectsCounts:@"HoldInvoice" withManageObjectContext:self.managedObjectContext] > 0)
        {
            return @"  OFFLINE_HOLD_INVOICE";
        }
        return @"";
    }
    else if ([[self.recallDataSection objectAtIndex:section] integerValue] == ONLINE_HOLD_INVOICE)
    {
        if (recallarray.count > 0) {
            return @"  ONLINE_HOLD_INVOICE";
        }
        return @"";
    }
    return @"";
}*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( [(self.recallDataSection)[section]integerValue] == OFFLINE_HOLD_INVOICE)
    {
        if([self.updateManager fetchEntityObjectsCounts:@"HoldInvoice" withManageObjectContext:self.managedObjectContext] > 0)
        {
            return 40;
        }
    }
    else if ([(self.recallDataSection)[section] integerValue] == ONLINE_HOLD_INVOICE)
    {
        return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if ( [(self.recallDataSection)[section]integerValue] == OFFLINE_HOLD_INVOICE)
    {
        if([self.updateManager fetchEntityObjectsCounts:@"HoldInvoice" withManageObjectContext:self.managedObjectContext] > 0)
        {
            return [[RecallSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40) withHeaderTitle:@"OFFLINE INVOICES"];
        }
    }
    else if ([(self.recallDataSection)[section] integerValue] == ONLINE_HOLD_INVOICE)
    {
        if (recallarray.count > 0) {
            return [[RecallSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40) withHeaderTitle:@"ONLINE INVOICES"];
        }
    }
    return nil;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( [(self.recallDataSection)[section]integerValue] == OFFLINE_HOLD_INVOICE)
    {
        NSArray *sections = self.recallDataDisplayResultController.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
        return sectionInfo.numberOfObjects;
    }
    else if ([(self.recallDataSection)[section] integerValue] == ONLINE_HOLD_INVOICE)
    {
        return recallarray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecallCustomCell";
    RecallCustomCell *recallCustomCell = (RecallCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    if ( [(self.recallDataSection)[indexPath.section]integerValue] == OFFLINE_HOLD_INVOICE)
    {
        HoldInvoice *holdInvoiceAtIndexpath = [self.recallDataDisplayResultController objectAtIndexPath:indexPath];
        recallCustomCell.invoiceNo.text = holdInvoiceAtIndexpath.transActionNo.stringValue;
        recallCustomCell.amount.text =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:holdInvoiceAtIndexpath.billAmount]];
        recallCustomCell.registerName.text = holdInvoiceAtIndexpath.holdUserName;
        recallCustomCell.remarks.text = holdInvoiceAtIndexpath.holdRemark;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"MM/dd/yyyy";
        NSDate *now = holdInvoiceAtIndexpath.holdDate;
        NSString *dateString = [format stringFromDate:now];
        recallCustomCell.invoiceDate.text = dateString;

    }
    else if ([(self.recallDataSection)[indexPath.section] integerValue] == ONLINE_HOLD_INVOICE)
    {
        recallCustomCell.invoiceNo.text = [NSString stringWithFormat:@"%@",[recallarray[indexPath.row] valueForKey:@"SrNo"]];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"MM/dd/yyyy";
        NSDate *now = [self.rmsDbController getDateFromJSONDate:[recallarray[indexPath.row] valueForKey:@"InvoiceDate"]];
        NSString *dateString = [format stringFromDate:now];
        recallCustomCell.invoiceDate.text = dateString;
        
        NSNumber *amount= @([[recallarray[indexPath.row] valueForKey:@"Amount"] floatValue]);
        recallCustomCell.amount.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:amount]];
        recallCustomCell.registerName.text = [recallarray[indexPath.row] valueForKey:@"RegisterName"];
        recallCustomCell.remarks.text = [recallarray[indexPath.row] valueForKey:@"Remarks"];
    }
    
    [recallCustomCell.btnHoldInvoicePrint addTarget:self action:@selector(btn_Print:) forControlEvents:UIControlEventTouchUpInside];

    return recallCustomCell;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([(self.recallDataSection)[indexPath.section] integerValue] == ONLINE_HOLD_INVOICE)
        {
            BOOL hasRights = [UserRights hasRights:UserRightDeleteHoldInvoice];
            if (!hasRights) {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to delete hold invoice. Please contact to admin user." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                return;
            }
            RecallViewController * __weak myWeakReference = self;
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [myWeakReference deleteRecallDataForId:[recallarray[indexPath.row] valueForKey:@"SrNo"]];
            };
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to delete this record?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
            
        }
    }
}

-(void)didRecallOrderWithInvoiceId :(NSString *)invoiceId
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:invoiceId forKey:@"SrNoInvoiceHold"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self holdInvoiceResponse:response error:error];
        });
    };
    
    
    self.holdRecordWC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_RECALL_INVOICE_LIST params:param completionHandler:completionHandler];
    
}

- (void)holdInvoiceResponse:(id)response error:(NSError *)error{
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                holdDataItemArray = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] mutableCopy];
                
                NSString *billDetail = [holdDataItemArray.firstObject valueForKey:@"BillDetail"];
                
                NSError *jsonError;
                NSData *objectData = [billDetail dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *billDetailDictionary = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                     options:NSJSONReadingMutableContainers
                                                                                       error:&jsonError];
                
                NSArray *billReciptArray = [billDetailDictionary valueForKey:@"BillItemDetail"];
                
                [self printReceipt:billReciptArray receiptDate:onlineHoldInvoiceDate];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please try again later." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

- (IBAction)btn_Print:(id)sender
{
    RecallCustomCell *clickCell = (RecallCustomCell *)[sender superview].superview;
    
    NSIndexPath *indexPath = [self.tblrecalllist indexPathForCell:clickCell];
    RECALL_DATA_SECTION recallDataSection = indexPath.section;
  
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MM/dd/yyyy hh:mm a";
    format.timeZone = sourceTimeZone;

    NSDate *now;
    NSMutableArray *holdItemDetails;
    NSString *dateString;
    
    switch (recallDataSection)
    {
        case ONLINE_HOLD_INVOICE:
        {

            now = [self.rmsDbController getDateFromJSONDate:[recallarray[indexPath.row] valueForKey:@"InvoiceDate"]];
//            onlineHoldInvoiceDate = [format stringFromDate:now];
            
            NSString *stringDate = [format stringFromDate:now];
            NSDate *onlineHoldDate = [format dateFromString:stringDate];
            onlineHoldInvoiceDate = [format stringFromDate:onlineHoldDate];
            
            [self didRecallOrderWithInvoiceId:[[NSString alloc]initWithFormat:@"%@", recallarray[indexPath.row][@"SrNo"]]];
        }
            break;
            
        case OFFLINE_HOLD_INVOICE:
        {
            HoldInvoice *holdInvoice = [self.recallDataDisplayResultController objectAtIndexPath:indexPath];
            NSData *HoldData = [[NSData alloc]initWithData:holdInvoice.holdData];
            now = holdInvoice.holdDate;
            dateString = [format stringFromDate:now];
            holdItemDetails = [[[[NSKeyedUnarchiver unarchiveObjectWithData:HoldData] valueForKey:@"InvoiceDetail"] valueForKey:@"InvoiceItemDetail"] firstObject];
            [self printReceipt:holdItemDetails receiptDate:dateString];
        }
            break;
            
        default:
            break;
    }
}

-(void)printReceipt:(NSArray *)holdItemDetails receiptDate:(NSString *)dateString
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    PreOrderReceiptPrint *preOrderReceiptPrint = [[PreOrderReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:(NSArray *)holdItemDetails receiptDate:dateString];
    
    [preOrderReceiptPrint printInvoiceReceiptForInvoiceNo:nil withChangeDue:nil withDelegate:self];
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
    
    [RecallViewController setPortName:localPortName];
    [RecallViewController setPortSettings:array_port[0]];
}
-(void)printerTaskDidSuccessWithDevice:(NSString *)device
{
    
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self btn_Print:nil];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Failed to Invoice print receipt. Would you like to retry.?" buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}


-(void) deleteRecallDataForId:(NSString *)recallId
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:recallId forKey:@"SrNo"];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:date];
    
    param[@"DeleteDateTime"] = strDate;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deleteRecallDataForIdResponse:response error:error];
        });
    };
    
    self.deleteRecallRecordConnection = [self.deleteRecallRecordConnection initWithRequest:KURL actionName:WSM_RECALL_INVOICE_DELETE params:param completionHandler:completionHandler];
}

- (void)deleteRecallDataForIdResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];

    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *responseDict = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                    NSInteger recallCount = [[responseDict valueForKey:@"RecallCount"] integerValue];
                    
                    if(self.crmController.recallCount != recallCount)
                    {
                        self.crmController.recallCount = recallCount;
                        NSDictionary *recallCountDict = @{@"Code" : @(recallCount)};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LiveHoldUpdateCount" object:recallCountDict];
                    }
                    [self GetRecallData];
                });
            }
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [(self.recallDataSection)[indexPath.section]integerValue] == OFFLINE_HOLD_INVOICE)
    {
        self.crmController.recallInvoiceId = [[[self.recallDataDisplayResultController objectAtIndexPath:indexPath] valueForKey:@"transActionNo"] stringValue];
    }
    else if ([(self.recallDataSection)[indexPath.section] integerValue] == ONLINE_HOLD_INVOICE)
    {
        self.crmController.recallInvoiceId = [NSString stringWithFormat:@"%@",recallarray[indexPath.row][@"SrNo"]];
    }
}

-(IBAction)btnokClick:(id)sender
{
    [self.rmsDbController playButtonSound];
    
    NSIndexPath *selectedRow = _tblrecalllist.indexPathForSelectedRow;
    if (selectedRow == nil)
    {
        [self.view removeFromSuperview];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"please select the Record" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }

    if (selectedRow.section == OFFLINE_HOLD_INVOICE)
    {
        HoldInvoice *holdinvoice = [self.recallDataDisplayResultController objectAtIndexPath:selectedRow];
        [self.recallDelegate didRecallOrderWithOfflineInvoiceId:self.crmController.recallInvoiceId withOfflineData:holdinvoice.holdData];
        [self.view removeFromSuperview];

    }
    else  if (selectedRow.section == ONLINE_HOLD_INVOICE)
    {
        self.crmController.isbillOrderFromRecallOffline = FALSE;
        [self.view removeFromSuperview];
        [self.recallDelegate didRecallOrderWithInvoiceId:self.crmController.recallInvoiceId];
    }
 }
-(IBAction)btncancelClick:(id)sender
{
    [self.rmsDbController playButtonSound];
    
    [self.view removeFromSuperview];
    if (self.recallDelegate)
    {
        [self.recallDelegate didCancelRecallOrder];
    }
}
-(IBAction)uploadDataToServer:(id)sender
{
    if (isOfflineHoldInvoiceUploadProcessInprogress == FALSE) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        isOfflineHoldInvoiceUploadProcessInprogress = TRUE;
        [self sendOfflineData];
    }
}

-(void)sendOfflineData
{
    nextIndex = 0;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HoldInvoice" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    self.offlineInvoice = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(self.offlineInvoice.count > 0)
    {
        [self uploadNextInvoiceData];
    }
    else
    {
        [_activityIndicator hideActivityIndicator];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HoldInvoiceOfflineUpload" object:nil];
        isOfflineHoldInvoiceUploadProcessInprogress = FALSE;
    }
}

- (void)uploadNextInvoiceData
{
    if(nextIndex >= self.offlineInvoice.count)
    {
        [_activityIndicator hideActivityIndicator];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HoldInvoiceOfflineUpload" object:nil];
        [self GetRecallData];
        return;
    }
    
    HoldInvoice *holdInvoiceData = (self.offlineInvoice)[nextIndex];
    NSMutableDictionary * param = [NSKeyedUnarchiver unarchiveObjectWithData:holdInvoiceData.holdData];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doHoldInvoiceAsynchOfflineResponse:response error:error];
        });
    };

    self.holdInvoiceOfflineUploadWC = [self.holdInvoiceOfflineUploadWC initWithRequest:KURL actionName:WSM_ADD_HOLD_INVOICE_LIST params:param completionHandler:completionHandler];
}

- (void)doHoldInvoiceAsynchOfflineResponse:(id)response error:(NSError *)error
{
    [self _doHoldInvoiceAsynchOfflineResponse:response error:error];
}


- (void)_doHoldInvoiceAsynchOfflineResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                HoldInvoice *holdInvoice = (self.offlineInvoice)[nextIndex];
                NSManagedObjectID *objectIdForInvoiceData = holdInvoice.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                holdInvoice = (HoldInvoice *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                [UpdateManager deleteFromContext:privateManagedObjectContext object:holdInvoice];
                [UpdateManager saveContext:privateManagedObjectContext];
            }
        }
    }
    nextIndex++;
    [self uploadNextInvoiceData];
 }

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if (![controller isEqual:self.recallDataDisplayResultController]) {
        [self unlockResultController];
        return;
    }
    else if (__recallDataDisplayResultController == nil){
        [self unlockResultController];
        return;
    }

    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [_tblrecalllist beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.recallDataDisplayResultController]) {
        return;
    }
    else if (__recallDataDisplayResultController == nil){
        return;
    }

    UITableView *tableView = _tblrecalllist;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView cellForRowAtIndexPath:indexPath] ;
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.recallDataDisplayResultController]) {
        return;
    }
    else if (__recallDataDisplayResultController == nil){
        return;
    }

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_tblrecalllist insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tblrecalllist deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.recallDataDisplayResultController]) {
        return;
    }
    else if (__recallDataDisplayResultController == nil){
        return;
    }

    [_tblrecalllist endUpdates];
    [self unlockResultController];
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)recallViewLock {
    if (_recallViewLock == nil) {
        _recallViewLock = [[NSRecursiveLock alloc] init];
    }
    return _recallViewLock;
}

-(void)lockResultController
{
    [self.recallViewLock lock];
}

-(void)unlockResultController
{
    [self.recallViewLock unlock];
}

-(void)setRecallDataDisplayResultController:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.recallViewLock];
    __recallDataDisplayResultController = resultController;
    [lock unlock];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
