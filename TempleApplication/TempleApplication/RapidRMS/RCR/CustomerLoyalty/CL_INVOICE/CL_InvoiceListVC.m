//
//  CL_InvoiceListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 02/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CL_InvoiceListVC.h"
#import "CL_InvoiceListCell.h"
#import "CS_Invoice.h"
#import "RmsDbController.h"
#import "RmsActivityIndicator.h"
#import "RapidInvoicePrint.h"
#import "LastInvoiceReceiptPrint.h"
#import "NDHTMLtoPDF.h"
#import "EmailFromViewController.h"
#import "CL_InvoiceTagListCell.h"
#import "CL_InvoiceTagVC.h"
#import "Customer.h"
#define TABLE_TAG_DISPLAY_LIMIT 10


@interface CL_InvoiceListVC ()<UITableViewDataSource , UITableViewDelegate , CL_InvoiceListCellDelegate,RapidInvoicePrintDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate , CL_InvoiceTagVCDelegate  , UIPopoverPresentationControllerDelegate ,EmailFromViewControllerDelegate>
{
    NSIndexPath *currentSelectedIndexpath;
    NSIndexPath *SelectedIndexpath;
    NSInteger currentSelectedProcess;
    NSArray *array_port;
    NSInteger selectedPort;
    NSString * customerId;
    NSNumber *tipSetting;
    CGFloat balaceAmount;
    CGFloat creditLimitValue;
    UIViewController *invoiceTagView;
    UIPopoverPresentationController *invoiceTagPopOverController;
    EmailFromViewController *emailFromViewController;
}

@property (nonatomic, weak) IBOutlet UITableView *tblInvoiceList;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) CL_InvoiceTagVC *cl_InvoiceTagVC;
@property (nonatomic, strong) RapidCustomerLoyalty *rapidCustomerLoyaltyInvoiceListObject;
@property (nonatomic, strong) RapidWebServiceConnection *invoiceDetailConnection;
@property (nonatomic, strong) RapidWebServiceConnection *CheckHouseChargeCreditLimitWC;

@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIDocumentInteractionController *controller;
@property (nonatomic ,strong) NSMutableArray *invoiceListArray;
@property (nonatomic ,strong) NSMutableArray *invoiceTagsArray;
@property (nonatomic ,strong) NSMutableArray *getCustomerDetailArray;
@end

@implementation CL_InvoiceListVC


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
    [CL_InvoiceListVC setPortName:localPortName];
    [CL_InvoiceListVC setPortSettings:array_port[selectedPort]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.invoiceDetailConnection = [[RapidWebServiceConnection alloc] init];
    self.CheckHouseChargeCreditLimitWC = [[RapidWebServiceConnection alloc]init];

    Configuration *configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext ];
    tipSetting= configuration.localTipsSetting;

    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    SelectedIndexpath = nil;

    if (invoiceTagPopOverController)
    {
        [invoiceTagView dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tblInvoiceList.layer.cornerRadius = 10.0f;
    if (invoiceTagPopOverController)
    {
        [invoiceTagView dismissViewControllerAnimated:YES completion:nil];
    }
    
}
-(void)updateInvoiceListViewWithRapidCustomerLoyaltyObject:(RapidCustomerLoyalty *)rapidCustomerLoyalty withInvoiceList:(NSMutableArray *)invoiceList
{
    self.rapidCustomerLoyaltyInvoiceListObject = rapidCustomerLoyalty;
    self.invoiceListArray = invoiceList;
    [self.tblInvoiceList reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
 
    return 55.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return self.invoiceListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"CL_InvoiceListCell";
    CL_InvoiceListCell *invoiceListCell = (CL_InvoiceListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    invoiceListCell.cl_InvoiceListCellDelegate = self;
    invoiceListCell.currentCellIndexpath = indexPath;
    CS_Invoice *cl_Invoice = (self.invoiceListArray)[indexPath.row];
    
    invoiceListCell.lblDateTime.text = [NSString stringWithFormat:@"%@",cl_Invoice.invoiceDate];
    invoiceListCell.lblDateTime.numberOfLines = 2;

    invoiceListCell.lblInvoice.text = [NSString stringWithFormat:@"%@",cl_Invoice.invoiceNo];
    invoiceListCell.lblQTY.text = [NSString stringWithFormat:@"%@",cl_Invoice.itemQty] ;
    invoiceListCell.lblTotal.text = [NSString stringWithFormat:@"$ %.2f",cl_Invoice.amount.floatValue];
    invoiceListCell.lblPaymentType.text =  [NSString stringWithFormat:@"%@",cl_Invoice.paymentType];
    if (cl_Invoice.tags.count>0)
    {
        invoiceListCell.btnTags.enabled = YES;
    }
    else{
        invoiceListCell.btnTags.enabled = NO;
    }
    invoiceListCell.btnTags.tag = indexPath.row;
    if (indexPath == SelectedIndexpath)
    {
        invoiceListCell.btnTags.selected = YES;
    }
    else
    {
        invoiceListCell.btnTags.selected = NO;
    }
    [invoiceListCell.btnTags addTarget:self action:@selector(btnTagClick:) forControlEvents:UIControlEventTouchUpInside];
        
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(246/255.f) green:(246/255.f) blue:(246/255.f) alpha:0.1];
    invoiceListCell.selectedBackgroundView = selectionColor;

    invoiceListCell.backgroundColor = [UIColor clearColor];
    return invoiceListCell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (invoiceTagPopOverController)
    {
        [invoiceTagView dismissViewControllerAnimated:YES completion:nil];
    }
}

-(NSMutableArray *)configureInvoiceTagArrayWith:(CS_Invoice *)invoiceDetail
{
    NSMutableArray *customerArray = [[NSMutableArray alloc] init];

    if (invoiceDetail.tags.count > 0) {
        customerArray = [invoiceDetail.tags mutableCopy];
    }
    return customerArray;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (invoiceTagPopOverController)
    {
        [invoiceTagView dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)btnTagClick:(UIButton *)sender
{
    if (invoiceTagPopOverController)
    {
        [invoiceTagView dismissViewControllerAnimated:YES completion:nil];
    }

    UIButton *button = (UIButton *)sender;
    button.selected = YES;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblInvoiceList];
    SelectedIndexpath = [self.tblInvoiceList indexPathForRowAtPoint:buttonPosition];
    
    CS_Invoice *cs_invoice = (self.invoiceListArray)[SelectedIndexpath.row];
    self.invoiceTagsArray = [self configureInvoiceTagArrayWith:cs_invoice];
    
    if(self.invoiceTagsArray.count>0)
    {
        
        NSInteger intPaymentCount = self.invoiceTagsArray.count ;
        if (self.invoiceTagsArray.count > TABLE_TAG_DISPLAY_LIMIT)
        {
            intPaymentCount = TABLE_TAG_DISPLAY_LIMIT;
        }

        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomerLoyalty" bundle:nil];
        self.cl_InvoiceTagVC = [storyBoard instantiateViewControllerWithIdentifier:@"CL_InvoiceTagVC"];
        self.cl_InvoiceTagVC.arrInvoicetagList = self.invoiceTagsArray;
        invoiceTagView = self.cl_InvoiceTagVC;
        self.cl_InvoiceTagVC.cl_InvoiceTagVCDelegate=self;
        
        // Present the view controller using the popover style.
        invoiceTagView.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:invoiceTagView animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        invoiceTagPopOverController = [invoiceTagView popoverPresentationController];
        invoiceTagPopOverController.delegate = self;
        invoiceTagView.preferredContentSize = CGSizeMake(130, ((intPaymentCount*35)+10));
        invoiceTagPopOverController.permittedArrowDirections = UIPopoverArrowDirectionRight;
        invoiceTagPopOverController.sourceView = self.view;
        CGRect cellRect = [self.tblInvoiceList rectForRowAtIndexPath:SelectedIndexpath];
        CGRect tabelRect = [self.view convertRect:cellRect fromView:self.tblInvoiceList ];
        CGRect popRect = CGRectMake(930 , tabelRect.origin.y - 120, 130, 300);
        invoiceTagPopOverController.sourceRect = popRect;
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Data Found" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    [self.tblInvoiceList reloadData];
    
}


-(void)didPerformInvoiceProcess:(InvoiceProcess)invoiceProcess atIndexPath:(NSIndexPath *)indexPath
{
    currentSelectedProcess = invoiceProcess;
    currentSelectedIndexpath = indexPath;
    CS_Invoice *cl_Invoice = (self.invoiceListArray)[indexPath.row];
    if ([self isInvoiceAlreadyConfigured:cl_Invoice] == FALSE) {
        customerId = [NSString stringWithFormat:@"%@",cl_Invoice.custId ];
        [self creditLimitForHouseCharge];
        [self getInvoiceDetailForInvoiceNo:cl_Invoice.invoice];
    }
    else
    {
        customerId = [NSString stringWithFormat:@"%@",cl_Invoice.custId ];
        [self creditLimitForHouseCharge];
        [self configureInvoiceHtmlFor:nil forInvoiceObject:cl_Invoice];

        [self performInvoiceProcess:cl_Invoice];

    }
}

-(BOOL)isInvoiceAlreadyConfigured:(CS_Invoice *)cs_Invoice
{
    BOOL isInvoiceAlreadyConfigured = TRUE;
    if (cs_Invoice.invoiceItemDetail == nil || cs_Invoice.invoiceMasterDetail == nil || cs_Invoice.invoicePaymentDetail == nil || cs_Invoice.htmlString.length == 0) {
        isInvoiceAlreadyConfigured = FALSE;
    }
    return isInvoiceAlreadyConfigured;
}


-(void)getInvoiceDetailForInvoiceNo:(NSString *)invoiceNo
{

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:invoiceNo forKey:@"InvoiceNo"];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getInvoiceDetailForInvoiceNoResponse:response error:error];
        });
    };
    
    self.invoiceDetailConnection = [self.invoiceDetailConnection initWithRequest:KURL actionName:WSM_INVOICE_DETAIL_LIST params:itemparam completionHandler:completionHandler];

    
}

- (void)getInvoiceDetailForInvoiceNoResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
    
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                response = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self configureInvoice:response];
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

    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please try again later." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(void)searchInvoiceListData:(NSString*)invoiceListSearchString arrInvoicelListdata:(NSMutableArray *)invoicelListSearchArray
{
    NSPredicate *predicate = [self searchPredicateForText:invoiceListSearchString];
    NSArray *filteredArray = [invoicelListSearchArray filteredArrayUsingPredicate:predicate];
    
    if (filteredArray.count>0)
    {
        self.invoiceListArray = [filteredArray mutableCopy];
    }
    else
    {
        if ([invoiceListSearchString isEqualToString:@""])
        {
            self.invoiceListArray = invoicelListSearchArray;
        }
        else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                self.invoiceListArray = invoicelListSearchArray;
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No record found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    }
    [self.tblInvoiceList reloadData];
}


-(NSMutableArray *)invoiceListArray:(NSString*)invoiceListSearchString arrInvoicelListdata:(NSMutableArray *)invoicelListSearchArray
{
    NSPredicate *predicate = [self searchPredicateForText:invoiceListSearchString];
    NSArray *filteredArray = [invoicelListSearchArray filteredArrayUsingPredicate:predicate];
    NSMutableArray *arrayFilterInvoice ;
    if (filteredArray.count>0)
    {
        arrayFilterInvoice = [filteredArray mutableCopy];
    }
    else
    {
        arrayFilterInvoice = invoicelListSearchArray;
    }
    return arrayFilterInvoice;
}

-(NSPredicate *)searchPredicateForText:(NSString *)searchData
{
    NSMutableArray *textArray=[[searchData componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;
    
    dbFields = @[ @"SELF.invoiceNo contains[cd] %@",@"SELF.paymentType contains[cd] %@"];
    
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



-(void)configureInvoiceHtmlFor:(NSMutableArray *)responseArray forInvoiceObject:(CS_Invoice *)cs_Invoice
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    NSMutableArray *itemDetail = [cs_Invoice.invoiceItemDetail mutableCopy] ;
    NSMutableArray *paymentArray = [cs_Invoice.invoicePaymentDetail mutableCopy];
    NSMutableArray *masterDetail = [cs_Invoice.invoiceMasterDetail mutableCopy];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM / dd / yyyy HH:mm EEEE";
    NSDate *date = [formatter dateFromString:cs_Invoice.invoiceDate];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm";
    NSString *newDate = [formatter stringFromDate:date];
    
    LastInvoiceReceiptPrint *lastInvoiceReceiptPrint = [[LastInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:itemDetail withPaymentDatail:paymentArray tipSetting:tipSetting tipsPercentArray:nil receiptDate:newDate];
    cs_Invoice.htmlString = [lastInvoiceReceiptPrint generateHtmlForInvoiceNo:[masterDetail.firstObject valueForKey:@"RegisterInvNo"] withChangeDue:@""];
    
}

-(void)configureInvoice:(NSMutableArray*)invoiceProcess
{
    CS_Invoice *cs_Invoice = (self.invoiceListArray)[currentSelectedIndexpath.row];
    [cs_Invoice configureInvoiceDetail:invoiceProcess];
    [self configureInvoiceHtmlFor:invoiceProcess forInvoiceObject:cs_Invoice];
    [self performInvoiceProcess:cs_Invoice];
    if (invoiceTagPopOverController)
    {
        [invoiceTagView dismissViewControllerAnimated:YES completion:nil];
    }
  //  self.viewTagDetails.hidden = YES;

}

-(void)performInvoiceProcess:(CS_Invoice *)cs_Invoice
{
//    _getCustomerDetailArray = [cs_Invoice.invoiceMasterDetail mutableCopy];
//    [self creditLimitForHouseCharge];
    

    switch (currentSelectedProcess)
    {
        case InvoiceViewProcess:
            [self performInvoiceViewProcessWith:cs_Invoice];
            break;
            
        case InvoiceEmailProcess:
            [self performInvoiceEmailProcess:cs_Invoice];
            break;
            
        case InvoicePrintProcess:
            [self performInvoicePrintProcess:cs_Invoice];
            break;
            
        default:
            break;
    }
}



-(void)performInvoiceEmailProcess:(CS_Invoice *)cs_Invoice
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
    
    NSData *myData = [NSData dataWithContentsOfFile:cs_Invoice.htmlString];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    NSString *strsubjectLine = [NSString stringWithFormat:@"Your Receipt from %@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]];
  
    emailFromViewController.emailFromViewControllerDelegate = self;
    emailFromViewController.rapidEmailCustomerLoyalty = self.rapidCustomerLoyaltyInvoiceListObject;
    
    NSMutableDictionary * dictParameter =[[NSMutableDictionary alloc]init];
    dictParameter[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    dictParameter[@"Subject"] = strsubjectLine;
    dictParameter[@"InvoiceNo"] = @"";
    dictParameter[@"postfile"] = myData;
    dictParameter[@"HtmlString"] = stringHtml;
    
    emailFromViewController.dictParameter = dictParameter;
    emailFromViewController.modalPresentationStyle =  UIModalPresentationCustom;
    [self presentViewController:emailFromViewController animated:YES completion:nil];
    
}

-(void)didCancelEmail
{
    [emailFromViewController dismissViewControllerAnimated:YES completion:nil];

   // [emailFromViewController.view removeFromSuperview];
}


-(void)performInvoicePrintProcess:(CS_Invoice *)cs_Invoice
{
    RapidInvoicePrint *rapidInvoicePrint = [[RapidInvoicePrint alloc]init];

    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    rapidInvoicePrint.rapidCustomerArray = [self getUserDetail];

    NSMutableArray *itemDetail = [cs_Invoice.invoiceItemDetail mutableCopy] ;
    NSMutableArray *paymentDetail = [cs_Invoice.invoicePaymentDetail mutableCopy];
    NSMutableArray *masterDetail = [cs_Invoice.invoiceMasterDetail mutableCopy];

    
    rapidInvoicePrint.isFromCustomerLoyalty = TRUE;
//    rapidInvoicePrint.rapidCustomerArray = [self getUserDetail];
    rapidInvoicePrint = [rapidInvoicePrint initWithPortName:portName portSetting:portSettings ItemDetail:itemDetail  withPaymentDetail:paymentDetail withMasterDetails:masterDetail fromViewController:self withTipSetting:tipSetting tipsPercentArray:nil withChangeDue:cs_Invoice.changeDue withPumpCart:nil];
    [rapidInvoicePrint startPrint];
    rapidInvoicePrint.rapidInvoicePrintDelegate = self;

}
-(NSMutableArray *)getUserDetail{
    
    NSMutableArray *userDetail = [[NSMutableArray alloc]init];
    NSMutableDictionary *userDetailDict = [[NSMutableDictionary alloc]init];
    
        userDetailDict[@"Custid"] = _rapidCustomerLoyaltyInvoiceListObject.custId;
        userDetailDict[@"CustName"] = _rapidCustomerLoyaltyInvoiceListObject.firstName;
        userDetailDict[@"CustEmail"] = _rapidCustomerLoyaltyInvoiceListObject.email;
        userDetailDict[@"CustContactNo"] = _rapidCustomerLoyaltyInvoiceListObject.contactNo;
        userDetailDict[@"AvailableBalance"] = [NSString stringWithFormat:@"%.2f",balaceAmount];
        userDetailDict[@"CreditLimit"] = [NSString stringWithFormat:@"%.2f",creditLimitValue];
        [userDetail addObject:userDetailDict];
        
    return userDetail;
    
}

-(void)creditLimitForHouseCharge
{
    
    NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
    [param setValue:customerId forKey:@"CustomerId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkHouseChargeCreditLimitWCResponce:response error:error];
        });
    };
    
    self.CheckHouseChargeCreditLimitWC = [self.CheckHouseChargeCreditLimitWC initWithRequest:KURL actionName:WSM_CUSTOMER_CREDIT_LIMIT params:param completionHandler:completionHandler];
    
}

-(void)checkHouseChargeCreditLimitWCResponce:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *dictBalance = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                balaceAmount = [[dictBalance valueForKey:@"Balance"] floatValue] ;
                creditLimitValue = [[dictBalance valueForKey:@"CreditLimit"] floatValue];
            }
        }
    }
    else{
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            return;
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Can not reach to server for check credit limit. Do you want to retry?" buttonTitles:@[@"No",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

-(void)didFinishPrintProcessSuccessFully
{
}
-(void)didFailPrintProcess
{
}

-(void)performInvoiceViewProcessWith:(CS_Invoice *)cs_Invoice
{
   self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:cs_Invoice.htmlString]
                                     pathForPDF:@"~/Documents/previewCustomerInvoice.pdf".stringByExpandingTildeInPath
                                       delegate:self
                                       pageSize:kPaperSizeA4
                                        margins:UIEdgeInsetsMake(10, 5, 10, 5)];
}

#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    //    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    //    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
}

-(void)openDocumentwithSharOption:(NSString *)strpdfUrl{
    // here's a URL from our bundle
    NSURL *documentURL = [[NSURL alloc]initFileURLWithPath:strpdfUrl];
    
    // pass it to our document interaction controller
    self.controller.URL = documentURL;
    // present the preview
    [self.controller presentPreviewAnimated:YES];
    
}


- (UIDocumentInteractionController *)controller {
    
    if (!_controller) {
        _controller = [[UIDocumentInteractionController alloc]init];
        _controller.delegate = self;
    }
    return _controller;
}



#pragma mark - Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}



- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}



@end
