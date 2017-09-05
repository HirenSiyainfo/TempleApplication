//
//  OfflineRecordVC.m
//  RapidRMS
//
//  Created by Siya on 08/09/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "OfflineRecordVC.h"
#import "OfflineRecordCustomCell.h"
#import "RmsDbController.h"
#import  "InvoiceData_T.h"
#import  "InvoiceData_T+Dictionary.h"
#import "TenderPay.h"
#import "TenderPay+Dictionary.h"
#import "OfflineReceiptPrint.h"
#import "Configuration.h"
#import "UpdateManager.h"


@interface OfflineRecordVC ()<UpdateDelegate>
{
    NSInteger nextIndex;
    BOOL isOfflineIploadingProcessInprogress;
    NSArray *array_port;
    Configuration *objConfiguration;


}

@property (nonatomic, weak) IBOutlet UITableView *tblOfflienRecord;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) NSNumber *tipSetting;


@property (nonatomic, strong) RapidWebServiceConnection *webServiceConnectionOfflineVC;
@property (nonatomic, strong) RapidWebServiceConnection *webServiceConnectionOfflineError;

@property (nonatomic, strong) NSFetchedResultsController *offlineInvoiceResultController;
@property (nonatomic, strong) NSFetchedResultsController *onlineInvoiceResultController;

@property (nonatomic, strong) NSArray *offlineInvoice;
@property (nonatomic, strong) NSMutableArray *arrayOfflineRecord;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation OfflineRecordVC
@synthesize arrayOfflineRecord;
@synthesize managedObjectContext = __managedObjectContext;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];

    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];

    self.webServiceConnectionOfflineVC = [[RapidWebServiceConnection alloc] init];
    self.webServiceConnectionOfflineError = [[RapidWebServiceConnection alloc] init];
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];

    
    objConfiguration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    self.tipSetting = objConfiguration.localTipsSetting;

    NSString  *generateorderCell = @"";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        generateorderCell = @"OfflineRecordCustomCell";
    }
    else{
        generateorderCell = @"OfflineRecordCustomCell";
    }
    UINib *mixGenerateirderNib = [UINib nibWithNibName:generateorderCell bundle:nil];
    [self.tblOfflienRecord registerNib:mixGenerateirderNib forCellReuseIdentifier:@"offlineRecord"];

  
    // Do any additional setup after loading the view from its nib.
}

- (NSFetchRequest *)invoiceFetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"zId" ascending:NO];
    NSSortDescriptor *bSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"invoiceDate" ascending:NO];
    
    NSArray *sortDescriptors = @[aSortDescriptor,bSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    return fetchRequest;
}

- (NSFetchedResultsController *)offlineInvoiceResultController {
    if (_offlineInvoiceResultController != nil) {
        return _offlineInvoiceResultController;
    }
    
    NSFetchRequest *fetchRequest;
    fetchRequest = [self invoiceFetchRequest];
//    NSPredicate *offlineDataDisplayPredicate = [NSPredicate predicateWithFormat:@"isUpload == %@",FALSE];
//    [fetchRequest setPredicate:offlineDataDisplayPredicate];
    // Create and initialize the fetch results controller.
    NSPredicate *offlineDataDisplayPredicate = [NSPredicate predicateWithFormat:@"isUpload == %@ || isUpload == %@", nil, @(FALSE)];
    fetchRequest.predicate = offlineDataDisplayPredicate;
    _offlineInvoiceResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:@"isUpload" cacheName:nil];
    
    [_offlineInvoiceResultController performFetch:nil];
    _offlineInvoiceResultController.delegate = self;
    
    return _offlineInvoiceResultController;
}

- (NSFetchedResultsController *)onlineInvoiceResultController {
    if (_onlineInvoiceResultController != nil) {
        return _onlineInvoiceResultController;
    }
    
    NSFetchRequest *fetchRequest;
    fetchRequest = [self invoiceFetchRequest];
    fetchRequest.fetchLimit = 4;
    NSPredicate *offlineDataDisplayPredicate = [NSPredicate predicateWithFormat:@"isUpload == %@",@(TRUE)];
    fetchRequest.predicate = offlineDataDisplayPredicate;
    // Create and initialize the fetch results controller.
    _onlineInvoiceResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:@"isUpload" cacheName:nil];
    
    [_onlineInvoiceResultController performFetch:nil];
    _onlineInvoiceResultController.delegate = self;
    
    return _onlineInvoiceResultController;
}

-(void)calculateTheAmountwithTypewithDetail :(NSMutableArray *)cardTypeArray
{
    for(int i=0;i<cardTypeArray.count;i++){
        
        [self.arrayOfflineRecord addObject:cardTypeArray[i]];
        
    }
}

-(CGFloat)calculateCash
{
    CGFloat cash =0.0;
    
    return cash;
}
#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"  OFFLINE";
            break;
            
        default:
            return @"  ONLINE";
            break;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        NSArray *sections = self.offlineInvoiceResultController.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
        NSLog(@"offlineInvoiceCount = %lu",(unsigned long)sectionInfo.numberOfObjects);
        return sectionInfo.numberOfObjects;
    }
    else
    {
        NSArray *sections = self.onlineInvoiceResultController.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
        return sectionInfo.numberOfObjects;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"offlineRecord";
    OfflineRecordCustomCell *celloffline = (OfflineRecordCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    InvoiceData_T * invoiceData;
    if (indexPath.section == 0) {
        invoiceData=[self.offlineInvoiceResultController objectAtIndexPath:indexPath];
        celloffline.btnPrint.hidden = NO;
        [celloffline.btnPrint addTarget:self action:@selector(btn_PrintClick:) forControlEvents:UIControlEventTouchUpInside];

    }
    else{
        celloffline.btnPrint.hidden = YES;
        NSIndexPath * onlineInvoiceIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        
        invoiceData=[self.onlineInvoiceResultController objectAtIndexPath:onlineInvoiceIndexPath];
    }
    NSData *invoicaMasterData = [invoiceData valueForKey:@"invoiceMstData"];
    NSMutableArray * billAmountArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoicaMasterData] firstObject];
    celloffline.lblBillAmount.text = [self.rmsDbController applyCurrencyFomatter:[[billAmountArray valueForKey:@"BillAmount"] firstObject]];
    celloffline.lblRegInvoiceNo.text = [[billAmountArray valueForKey:@"RegisterInvNo"] firstObject];
    NSString *invoiceDate = [self stringFromDate:[[billAmountArray valueForKey:@"Datetime"] firstObject] inputFormat:@"MM/dd/yyyy HH:mm:ss" outputFormat:@"MM/dd/yyyy hh:mm a"];
    celloffline.lblInvoiceDate.text = invoiceDate;

    NSData *invoicaPaymentData = [invoiceData valueForKey:@"invoicePaymentData"];
    NSMutableArray * paymentAmountArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoicaPaymentData] firstObject];
    celloffline.lblPaymentType.text = [self paymentNameAtIndex:paymentAmountArray];


	return celloffline;
}

- (NSString *)stringFromDate:(NSString *)inputDate inputFormat:(NSString *)inputFormat outputFormat:(NSString *)outputFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = inputFormat;
    NSDate *date = [dateFormatter dateFromString:inputDate];
    dateFormatter.dateFormat = outputFormat;
    
    NSString *outputDate = [dateFormatter stringFromDate:date];
    return outputDate;
}

- (IBAction)btn_PrintClick:(id)sender
{
    OfflineRecordCustomCell *clickCell = (OfflineRecordCustomCell *)[sender superview].superview;
    
    NSIndexPath *indexPath = [self.tblOfflienRecord indexPathForCell:clickCell];
    InvoiceData_T * invoiceData =[self.offlineInvoiceResultController objectAtIndexPath:indexPath];
   
    [self printReceipt:invoiceData];

}

-(void)printReceipt:(InvoiceData_T *)offlinedata
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    NSData *itemDetail = [offlinedata valueForKey:@"invoiceItemData"];
    NSMutableArray * billAmountArray = [[NSKeyedUnarchiver unarchiveObjectWithData:itemDetail] firstObject];
    
    NSData *masterDetail = [offlinedata valueForKey:@"invoiceMstData"];
    NSMutableArray * masterArray = [[NSKeyedUnarchiver unarchiveObjectWithData:masterDetail] firstObject];
    
    NSData *paymentData = [offlinedata valueForKey:@"invoicePaymentData"];
    NSMutableArray * paymentArray = [[[NSKeyedUnarchiver unarchiveObjectWithData:paymentData] firstObject] mutableCopy];
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSDate *date = [formatter dateFromString:[masterArray.firstObject valueForKey:@"Datetime"]];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm";
    NSString *newDate = [formatter stringFromDate:date];
    
    
    OfflineReceiptPrint *offlineReceiptPrint = [[OfflineReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:billAmountArray withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:newDate];
    
    [offlineReceiptPrint printInvoiceReceiptForInvoiceNo:[masterArray.firstObject valueForKey:@"RegisterInvNo"] withChangeDue:[[paymentArray valueForKey:@"ReturnAmount"] firstObject] withDelegate:self];
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
    
    [OfflineRecordVC setPortName:localPortName];
    [OfflineRecordVC setPortSettings:array_port[0]];
}
-(void)printerTaskDidSuccessWithDevice:(NSString *)device
{
    
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self btn_PrintClick:nil];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Failed to Invoice print receipt. Would you like to retry.?" buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}



-(NSString *)paymentNameAtIndex :(NSMutableArray *)paymentArray
{
    NSString *paymentName = @"";
   
    for (NSDictionary * keyDictionary  in paymentArray)
    {
        paymentName = [paymentName stringByAppendingFormat:@"  %@",[keyDictionary valueForKey:@"PayMode"]];
    }
    
    return paymentName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(IBAction)uploadDataToServer:(id)sender
{
    if (isOfflineIploadingProcessInprogress == FALSE) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        isOfflineIploadingProcessInprogress = TRUE;
        [self sendOfflineData];
    }
}

-(void)sendOfflineData
{
    nextIndex = 0;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *offlineDataDisplayPredicate = [NSPredicate predicateWithFormat:@"isUpload == %@ || isUpload == %@", nil, @(FALSE)];
    fetchRequest.predicate = offlineDataDisplayPredicate;

    self.offlineInvoice = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    
    if(self.offlineInvoice.count > 0)
    {
        [self uploadNextInvoiceData];
    } else {
        [_activityIndicator hideActivityIndicator];
    }
}

- (void)uploadNextInvoiceData
{
    if(nextIndex >= self.offlineInvoice.count)
    {
        [_activityIndicator hideActivityIndicator];
        isOfflineIploadingProcessInprogress = FALSE;
        return;
    }
    
    InvoiceData_T *invoiceDataT = (self.offlineInvoice)[nextIndex];
    NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceMstData] firstObject];
    invoiceDetailDict[@"InvoiceItemDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceItemData] firstObject];
    invoiceDetailDict[@"InvoicePaymentDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoicePaymentData] firstObject];
    [invoiceDetail addObject:invoiceDetailDict];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init ];
    param[@"InvoiceDetail"] = invoiceDetail;
    

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self doAsynchOfflineResponse:response error:error];
    };

    self.webServiceConnectionOfflineVC = [self.webServiceConnectionOfflineVC initWithRequest:KURL_INVOICE actionName:WSM_INVOICE_INSERT_LIST params:param completionHandler:completionHandler];
}

- (void)doAsynchOfflineResponse:(id)response error:(NSError *)error
{
    [self _doAsynchOfflineResponse:response error:error];
}

- (void)_doAsynchOfflineResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *responseDict = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSInteger recallCount = [[responseDict valueForKey:@"RecallCount"] integerValue];
                
                if(self.crmController.recallCount != recallCount)
                {
                    self.crmController.recallCount = recallCount;
                    NSDictionary *recallCountDict = @{@"Code" : @(recallCount)};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LiveHoldUpdateCount" object:recallCountDict];
                }
                
                InvoiceData_T *invoiceDataT = (self.offlineInvoice)[nextIndex];
                
                NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                //  [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                invoiceDataT.isUpload = @(TRUE);
                
                [UpdateManager saveContext:privateManagedObjectContext];
                
            }
            else  if ([[response valueForKey:@"IsError"] intValue] == -2)
            {
                InvoiceData_T *invoiceDataT = (self.offlineInvoice)[nextIndex];
                
                NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                // [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                invoiceDataT.isUpload = @(TRUE);
                
                [UpdateManager saveContext:privateManagedObjectContext];
            }
            else
            {
                [self uploadOfflineInvoice];
            }
            nextIndex++;
            [self uploadNextInvoiceData];
            
        }
    }
    else
    {
        [self uploadOfflineInvoice];
        nextIndex++;
        [self uploadNextInvoiceData];
    }
}

-(void)uploadOfflineInvoice
{
    InvoiceData_T *invoiceData_T = (self.offlineInvoice)[nextIndex];
    NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceData_T.invoiceMstData] firstObject];
    invoiceDetailDict[@"InvoiceItemDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceData_T.invoiceItemData] firstObject];
    invoiceDetailDict[@"InvoicePaymentDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceData_T.invoicePaymentData] firstObject];
    [invoiceDetail addObject:invoiceDetailDict];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init ];
    param[@"InvoiceDetail"] = invoiceDetail;
    
    NSMutableDictionary *offlineInvoiceDictionary = [[NSMutableDictionary alloc] init ];
    NSString *offlineInvoiceString = [self.rmsDbController jsonStringFromObject:param];
    offlineInvoiceDictionary[@"InvoiceData"] = offlineInvoiceString;
    offlineInvoiceDictionary[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    offlineInvoiceDictionary[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    offlineInvoiceDictionary[@"MacAddress"] = (self.rmsDbController.globalDict)[@"DeviceId"];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    offlineInvoiceDictionary[@"LocalDate"] = currentDateTime;
    offlineInvoiceDictionary[@"InvoiceNos"] = [[invoiceDetailDict[@"InvoiceMst"] valueForKey:@"RegisterInvNo"] firstObject];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self invoiceOfflineDataErrorResponse:response error:error];
    };
    
    self.webServiceConnectionOfflineError = [self.webServiceConnectionOfflineError initWithRequest:KURL actionName:WSM_INVOICE_OFFLINE_DATA params:offlineInvoiceDictionary completionHandler:completionHandler];
    
   // nextIndex++;
  //  [self uploadNextInvoiceData];
}

-(void)invoiceOfflineDataErrorResponse:(id)response error:(NSError *)error
{
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    NSLog(@"offline upload invoice beginUpdates");
    
    if (![controller isEqual:self.offlineInvoiceResultController] && ![controller isEqual:self.onlineInvoiceResultController]) {
        return;
    }
    [self.tblOfflienRecord beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
  
    if (![controller isEqual:self.offlineInvoiceResultController] && ![controller isEqual:self.onlineInvoiceResultController]) {
        return;
    }
    
    if ([controller isEqual:self.onlineInvoiceResultController]) {
        indexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:1];
        newIndexPath=[NSIndexPath indexPathForRow:newIndexPath.row inSection:1];
    }
    UITableView *tableView = self.tblOfflienRecord;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic] ;
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.offlineInvoiceResultController] && ![controller isEqual:self.onlineInvoiceResultController]) {
        return;
    }
    
    if ([controller isEqual:self.onlineInvoiceResultController]) {
        sectionIndex = 1;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblOfflienRecord reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblOfflienRecord reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tblOfflienRecord reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (![controller isEqual:self.offlineInvoiceResultController] && ![controller isEqual:self.onlineInvoiceResultController]) {
        return;
    }
    
    [self.tblOfflienRecord endUpdates];
    NSLog(@"endUpdates");
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
