//
//  DailyReportVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 11/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "DailyReportVC.h"
#import "RmsDbController.h"
#import "RmsActivityIndicator.h"
#import "ReportWebVC.h"
#import "XReport.h"
#import "ReportHandlerVC.h"
#import "ShiftInOutPopOverVC.h"
#import "ManagerReportVC.h"
#import "CKOCalendarViewController.h"
#import "UserShiftDetailsVC.h"
#import "ShiftHistoryDetailsVC.h"
#import "ExportPopupVC.h"
#import "EmailFromViewController.h"
#import <MessageUI/MessageUI.h>
#import "ReportPrintOptionsVC.h"
#import "ShiftReport.h"
#import "CCBatchVC.h"
#import "PaxDeviceViewController.h"
#import "CCOverViewReceipt.h"
#import "CurrentTransactionReceipt.h"
#import "DeviceSummaryReceipt.h"
#import "DeviceBatchReceipt.h"

//#define CheckRights

@interface DailyReportVC () <ReportHandlerVCDelegate,ShiftInOutPopOverDelegate,UpdateDelegate,ManagerReportVCDelegate,UIPopoverControllerDelegate,UserShiftDetailsVCDelegate,ShiftHistoryDetailsVCDelegate,ExportPopupVCDelegate,MFMailComposeViewControllerDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate,ReportPrintOptionsVCDelegate,CCBatchVCDelegate , EmailFromViewControllerDelegate> {
    NSMutableString *strHtmlReport;
    NSMutableString *strHtmlReportForEmail;
    
    NSArray *array_port;
    NSArray *cCbatchPrintArray;
    
    NSDictionary *cCbatchFilterDictionary;

    BOOL isZOrZZPrint;
    BOOL isZZPrint;
    BOOL isZPrint;
    BOOL isShiftOpen;
    BOOL emailView;
    BOOL isCentralizedZPrintFromPopUp;
    BOOL enableShiftPrintOption;
    BOOL isCCBatchAllowed;
    
    ReportPrint reportPrint;
    PrintOption _printOption;
    XReport *xReport;
    
    CCOverViewReceipt *cCOverViewReceipt;
    CurrentTransactionReceipt *currentTransactionReceipt;
    DeviceSummaryReceipt *deviceSummaryReceipt;
    DeviceBatchReceipt *deviceBatchReceipt;

    EmailFromViewController *emailFromViewController;
    ReportPrintOptionsVC *reportPrintOptionsVC;
    
    PaymentGateWay selectedPaymentGateWay;
    FooterButton previousFooterButton;
    
    CCBatchTrnxDetailStruct *transactionsDetails;
}

@property (nonatomic, weak) IBOutlet UIView *ccBatchView;
@property (nonatomic, weak) IBOutlet UIView *shiftView;
@property (nonatomic, weak) IBOutlet UIView *reportsView;
@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UIView *graphContainer;
@property (nonatomic, weak) IBOutlet UIView *managerReportContainer;
@property (nonatomic, weak) IBOutlet UIView *popUpContainerView;
@property (nonatomic, weak) IBOutlet UIView *shiftDetailsView;
@property (nonatomic, weak) IBOutlet UIView *shiftHistoryView;
@property (nonatomic, weak) IBOutlet UIView *paymentGateWayView;

@property (nonatomic, weak) IBOutlet UILabel *lblPaymentGateWay;
@property (nonatomic, weak) IBOutlet UILabel *lblPageTitle;

@property (nonatomic, weak) IBOutlet UIButton *btnPdfAndEmail;
@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnSettleBatch;
@property (nonatomic, weak) IBOutlet UIButton *btnBack;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) ReportWebVC *reportWebVC;
@property (nonatomic, strong) ReportHandlerVC *reportHandlerVC;
@property (nonatomic, strong) Configuration *configuration;
@property (nonatomic, strong) ShiftInOutPopOverVC *shiftInOutPopOverVC;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) ManagerReportVC *managerReportVC;
@property (nonatomic, strong) IntercomHandler *intercomHandler;
@property (nonatomic, strong) UserShiftDetailsVC *userShiftDetailsVC;
@property (nonatomic, strong) ShiftHistoryDetailsVC *shiftHistoryDetailsVC;
@property (nonatomic, strong) CCBatchVC *cCBatchVC;

@property (nonatomic, strong) RapidWebServiceConnection *employeeShiftWC;
@property (nonatomic, strong) RapidWebServiceConnection *zClosingNoReqDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *offlineWC;

@property (nonatomic, strong) NDHTMLtoPDF *pdfCreator;

@property (nonatomic, strong) NSManagedObjectContext *offlineManagedObjectContext;

@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (nonatomic, strong) UIPopoverController *calendarPopOverController;

@property (nonatomic, strong) NSMutableArray *reportsArray;
@property (nonatomic, strong) NSMutableArray *zReportArray;
@property (nonatomic, strong) NSMutableArray *centralizedZReportArray;
@property (nonatomic, strong) NSMutableArray *shiftReportArray;

@property (nonatomic, strong) NSArray *offlineInvoice;

@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, strong) NSString *zIdForZZ;

@property (nonatomic, strong) NSNumber *tipSetting;

@property (nonatomic) NSInteger nextIndex;

@end

@implementation DailyReportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.reportsArray = [[NSMutableArray alloc] init];
    self.configuration = [UpdateManager getConfigurationMoc:self.rmsDbController.managedObjectContext];
    self.tipSetting = self.configuration.localTipsSetting;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    [self setPageTitle:@"Reporting"];
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    self.offlineManagedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.popUpContainerView.hidden = YES;
    isZOrZZPrint = FALSE;
    isZPrint = FALSE;
    emailView = false;
    enableShiftPrintOption = false;
    isCentralizedZPrintFromPopUp = false;
    _printOption = PrintOptionNone;
    self.intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"dr_helpbtn.png" selectedImage:@"dr_helpbtnselected.png" withViewController:self];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
    if ([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"CashInOutFlg"] boolValue] == TRUE ) {
        isShiftOpen = TRUE;
    }
    [self hideSettleBatchOption];
    self.lblPaymentGateWay.text = [[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] uppercaseString];
    [self hidePaymentGateWayView];
    [self hideBackButton];
    isCCBatchAllowed = YES;
#ifdef CheckRights
    isCCBatchAllowed = [UserRights hasRights:UserRightCCBatch];
#endif

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(emailView == false)
    {
        if (reportPrint == ZReportPrint) {
            [self getZReport];
        }
        else if (reportPrint == ZZReportPrint)
        {
            
        }
        else
        {
            [self.rmsDbController cancelOfflineUploadProcess];
            [self sendOfflineDataToServer];
        }
    }
}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [self.calendarPopOverController dismissPopoverAnimated:YES];
    self.calendarPopOverController = [[UIPopoverController alloc] initWithContentViewController:ckOCalendarViewController];
    self.calendarPopOverController.delegate = self;
    ckOCalendarViewController.calendarPopover = self.calendarPopOverController;
    CGRect popoverRect = [self.view convertRect:(self.showCalendar).frame fromView:self.view];
    [self.calendarPopOverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)backButtonClicked:(id)sender {
    [self hideBackButton];
    [self setPageTitle:@"Reporting"];
    [self configureShiftView:self.shiftDetailsView];
}

- (void)hidePaymentGateWayView {
    self.paymentGateWayView.hidden = YES;
}

- (void)showPaymentGateWayView {
    self.paymentGateWayView.hidden = NO;
}

- (void)showBackButton {
    self.btnBack.hidden = NO;
}

- (void)hideBackButton {
    self.btnBack.hidden = YES;
}

- (void)setPageTitle:(NSString *)title {
    self.lblPageTitle.text = title;
}

#pragma mark - Show Default Reporting View

- (void)showDefaultReportingView {
    //Show Default Reporting view according to User Rights.
#ifdef CheckRights
    BOOL shiftReportRights = [UserRights hasRights:UserRightShiftInOut];
    BOOL xReportRights = [UserRights hasRights:UserRightXReport];
    
    if (shiftReportRights && xReportRights) {
        [self setEnable:FooterButtonShiftReport];
        [self setEnable:FooterButtonXReport];
        [self showShiftReport];
    }
    else if (shiftReportRights && !xReportRights) {
        [self setEnable:FooterButtonShiftReport];
        [self setDisable:FooterButtonXReport];
        [self showShiftReport];
    }
    else if (!shiftReportRights && xReportRights) {
        [self setDisable:FooterButtonShiftReport];
        [self setEnable:FooterButtonXReport];
        [self showXReport];
    }
#else
    [self showShiftReport];
#endif
}

- (void)showShiftReport {
    [self setSelected:FooterButtonShiftReport];
    [self accessShiftReport];
}

- (void)showXReport {
    [self setSelected:FooterButtonXReport];
    [self accessXReport];
}

#pragma mark - Upload Offline Data to Server

-(void)sendOfflineDataToServer
{
    self.nextIndex = 0;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.offlineManagedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *offlineDataDisplayPredicate = [NSPredicate predicateWithFormat:@"isUpload == %@",@(FALSE)];
    fetchRequest.predicate = offlineDataDisplayPredicate;
    
    
    self.offlineInvoice = [UpdateManager executeForContext:self.offlineManagedObjectContext FetchRequest:fetchRequest];
    
    if(self.offlineInvoice.count > 0)
    {
        [self setSelected:FooterButtonShiftReport];
        [self configureShiftReportView];
        [self startActivityIndicator];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self uploadNextInvoiceData];
        });
    }
    else{
        isZZPrint = FALSE;
        [self showDefaultReportingView];
    }
}

- (void)uploadNextInvoiceData
{
    if(self.nextIndex >= self.offlineInvoice.count)
    {
        [self stopActivityIndicator];
        isZZPrint = FALSE;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showDefaultReportingView];
        });
        return;
    }
    
    InvoiceData_T *invoiceDataT = (self.offlineInvoice)[self.nextIndex];
    
    NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceMstData] firstObject];
    invoiceDetailDict[@"InvoiceItemDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceItemData] firstObject];
    invoiceDetailDict[@"InvoicePaymentDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoicePaymentData] firstObject];
    [invoiceDetail addObject:invoiceDetailDict];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init ];
    param[@"InvoiceDetail"] = invoiceDetail;
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self doAsynchOfflinePaymentInReportProcessResponse:response error:error];
    };
    
    self.offlineWC = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL_INVOICE actionName:WSM_INVOICE_INSERT_LIST params:param asyncCompletionHandler:asyncCompletionHandler];
}

- (void)doAsynchOfflinePaymentInReportProcessResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_queue_create("doAsynchOfflinePaymentProcess", NULL), ^{
        [self doAsynchOfflineProcessResponse:response error:error];
    });
}

- (void)doAsynchOfflineProcessResponse:(id)response error:(NSError *)error
{
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                InvoiceData_T *invoiceDataT = (self.offlineInvoice)[self.nextIndex];
                NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
                invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                invoiceDataT.isUpload = @(TRUE);
                // [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                [UpdateManager saveContext:privateManagedObjectContext];
            }
            else  if ([[response valueForKey:@"IsError"] intValue] == -2)
            {
                InvoiceData_T *invoiceDataT = (self.offlineInvoice)[self.nextIndex];
                NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
                invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                //  [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                invoiceDataT.isUpload = @(TRUE);
                [UpdateManager saveContext:privateManagedObjectContext];
            }
            else
            {
                
            }
        }
    }
    self.nextIndex++;
    [self uploadNextInvoiceData];
}

#pragma mark - Printer Function Delegate

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    NSString *retryMessage = @"";
    switch (_printOption) {
        case PrintOptionZReport:
            retryMessage = @"Failed to Z Report print receipt. Would you like to retry.?";
            break;
        case PrintOptionCentralizedZReport:
            retryMessage = @"Failed to Centralized Z Report print receipt. Would you like to retry.?";
            break;
        case PrintOptionZZReport:
            retryMessage = @"Failed to ZZ Report print receipt. Would you like to retry.?";
            break;
        case PrintOptionNone:
            retryMessage = [self printReportFailAlertMessage];
            break;
        default:
            retryMessage = [self printReportFailAlertMessage];
            break;
    }
    [self displayDailyReportPrintRetryAlert:retryMessage];
}

- (NSString *)printReportFailAlertMessage {
    NSString *retryMessage = @"";
    switch (reportPrint) {
        case ShiftReportPrint:
            retryMessage = @"Failed to Shift Report print receipt. Would you like to retry.?";
            break;
        case XReportPrint:
            retryMessage = @"Failed to X Report print receipt. Would you like to retry.?";
            break;
        case ZReportPrint:
            retryMessage = @"Failed to Z Report print receipt. Would you like to retry.?";
            break;
        case ZZReportPrint:
            retryMessage = @"Failed to ZZ Report print receipt. Would you like to retry.?";
            break;
        case ManagerZReportPrint:
            retryMessage = @"Failed to Manager Z Report print receipt. Would you like to retry.?";
            break;
        case ManagerZZReportPrint:
            retryMessage = @"Failed to Manager ZZ Report print receipt. Would you like to retry.?";
            break;
        case CentralizeZReportPrint:
            retryMessage = @"Failed to Centralize Z Report print receipt. Would you like to retry.?";
            break;
        case CCOverViewPrint:
            retryMessage = @"Failed to CCOverView print receipt. Would you like to retry.?";
            break;
        case DeviceSummaryPrint:
            retryMessage = @"Failed to Device Summary Report print receipt. Would you like to retry.?";
            break;
        default:
            break;
    }
    return retryMessage;
}

#pragma mark - Printing, Email And Pdf

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
    NSString *printerSelection = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"];
    if(printerSelection.length > 0)
    {
        if ([printerSelection isEqualToString:@"Bluetooth"])
        {
            localPortName=@"BT:Star Micronics";
        }
        else if([printerSelection isEqualToString:@"TCP"]){
            NSString *tcp = [[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"];
            localPortName = tcp;
        }
    }
    else{
        localPortName=@"BT:Star Micronics";
    }
    [DailyReportVC setPortName:localPortName];
    [DailyReportVC setPortSettings:array_port[0]];
}

- (void)printShiftReport:(NSString *)portName portSettings:(NSString *)portSettings {
    if (self.shiftReportArray && self.shiftReportArray.count > 0) {
        ShiftReport *shiftReportPrint = [[ShiftReport alloc] initWithDictionary:self.shiftReportArray.firstObject reportName:[NSString stringWithFormat:@"Shift #%ld",(long)[[[[self.shiftReportArray.firstObject valueForKey:@"objShiftDetail"] firstObject] valueForKey:@"ShiftNo"] integerValue]] isTips:self.tipSetting.boolValue];
        [shiftReportPrint printReportWithPort:portName portSettings:portSettings withDelegate:self];
    }
}

- (void)printReport:(NSString *)portName portSettings:(NSString *)portSettings withReportObject:(NSMutableArray *)reportData forReport:(NSString *)rptName
{
    if(reportData.count > 0)
    {
        xReport = [[XReport alloc] initWithDictionary:reportData.firstObject reportName:rptName isTips:self.tipSetting.boolValue ];
        [xReport printReportWithPort:portName portSettings:portSettings withDelegate:self];
        [self stopActivityIndicator];
    }
}

- (void)printCCOverView:(NSString *)portName portSettings:(NSString *)portSettings withPrintObject:(NSArray *)printArray
{
    if(printArray.count > 0)
    {
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Card"
                                                     ascending:YES ];
        NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
        NSArray *sortedArray;
        sortedArray = [[printArray sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];

        cCOverViewReceipt = [[CCOverViewReceipt alloc] initWithPortName:portName portSetting:portSettings receiptData:sortedArray receiptTitle:@"CC Overview" filterDetails:cCbatchFilterDictionary];
        [cCOverViewReceipt printCCBatchReceiptWithDelegate:self];
    }
    [self stopActivityIndicator];
}

- (void)printDeviceSummary:(NSString *)portName portSettings:(NSString *)portSettings withPrintObject:(NSArray *)printArray
{
    if(printArray.count > 0)
    {
        deviceSummaryReceipt = [[DeviceSummaryReceipt alloc] initWithPortName:portName portSetting:portSettings receiptData:printArray paymentGateWay:selectedPaymentGateWay receiptTitle:@"Device Summary" filterDetails:cCbatchFilterDictionary];
        [deviceSummaryReceipt printCCBatchReceiptWithDelegate:self];
    }
    [self stopActivityIndicator];
}

- (void)printReport:(NSString *)portName portSettings:(NSString *)portSettings
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        switch (reportPrint) {
            case ShiftReportPrint:
                [self printShiftReport:portName portSettings:portSettings];
                [self stopActivityIndicator];
                break;
            case XReportPrint:
                [self printReport:portName portSettings:portSettings withReportObject:self.reportsArray forReport:@"X Report"];
                break;
            case ZReportPrint:
                [self printReport:portName portSettings:portSettings withReportObject:self.reportsArray forReport:@"Z Report"];
                break;
            case ZZReportPrint:
                [self printReport:portName portSettings:portSettings withReportObject:self.reportsArray forReport:@"ZZ Report"];
                break;
            case ManagerZReportPrint:
                [self printReport:portName portSettings:portSettings withReportObject:self.reportsArray forReport:@"Manager Z"];
                break;
            case ManagerZZReportPrint:
                [self printReport:portName portSettings:portSettings withReportObject:self.reportsArray forReport:@"Manager ZZ"];
                break;
            case CentralizeZReportPrint:
                [self printReport:portName portSettings:portSettings withReportObject:self.reportsArray forReport:@"Centralize Z"];
                break;
            case CCOverViewPrint:
                [self printCCOverView:portName portSettings:portSettings withPrintObject:cCbatchPrintArray];
                break;
            case DeviceSummaryPrint:
                [self printDeviceSummary:portName portSettings:portSettings withPrintObject:cCbatchPrintArray];
                break;

            default:
                [self stopActivityIndicator];
                break;
        }
    });
}

- (IBAction)printReportsButtonClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    [self startActivityIndicator];
    [self printReport:portName portSettings:portSettings];
}

- (IBAction)pdfAndEmailButtonClicked:(id)sender {
    //    if (reportPrint == ShiftReportPrint)
    //    {
    //        emailView = true;
    //        [self.userShiftDetailsVC loadShiftReportEmail];
    //    }
    //    else {
    //
    if (previousFooterButton == FooterButtonCCBatch) {
        BOOL needToOpenPopUp = [self isHtmlDataWritenForCCBatch];
        if (!needToOpenPopUp) {
            return;
        }
    }
    ExportPopupVC *exportPopupVC = [[UIStoryboard storyboardWithName:@"Reporting" bundle:NULL] instantiateViewControllerWithIdentifier:@"ExportPopupVC_sid"];
    exportPopupVC.delegate = self;
    exportPopupVC.isHideArrow = true;
    [exportPopupVC presentViewControllerForviewConteroller:self sourceView:self.btnPdfAndEmail ArrowDirection:UIPopoverArrowDirectionDown];
    //    }
}

#pragma mark - ExportPopupVCDelegate

-(void)didSelectExportType:(ExportType)exportType withTag:(NSInteger)tag {
    switch (exportType) {
        case ExportTypeEmail:
            [self emailButtonClicked:nil];
            break;
        case ExportTypePrieview:
            [self previewButtonClicked:nil];
            break;

        default:
            break;
    }
}

- (IBAction)emailButtonClicked:(id)sender {
    emailView = true;
    [self emailForReport];
}

- (void)emailForReport
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
//    emailFromViewController = [[EmailFromViewController alloc] initWithNibName:@"EmailFromViewController" bundle:nil];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSString *currentDateTime = [formatter stringFromDate:date];
    NSString *reportPrintName = [self getPrintName];
    NSString *strsubjectLine = [NSString stringWithFormat:@"%@  %@  %@ Report",[self.rmsDbController.globalDict valueForKey:@"RegisterName"],currentDateTime,reportPrintName];
    NSData *htmlData = [NSData dataWithContentsOfFile:self.sourcePath];
    NSString *stringHtml = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    emailFromViewController.emailFromViewControllerDelegate = self;
    emailFromViewController.dictParameter = [[NSMutableDictionary alloc]init];
    (emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    (emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
    (emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
    (emailFromViewController.dictParameter)[@"postfile"] = htmlData;
    (emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
    
    [self.view addSubview:emailFromViewController.view];


}

-(void)didCancelEmail
{
    [emailFromViewController.view removeFromSuperview];
}

- (NSString *)getPrintName {
    NSString *reportPrintName = @"";
    switch (reportPrint) {
        case ShiftReportPrint:
            reportPrintName = @"Shift";
            break;
        case XReportPrint:
            reportPrintName = @"X";
            break;
        case ZReportPrint:
            reportPrintName = @"Z";
            break;
        case ZZReportPrint:
            reportPrintName = @"ZZ";
            break;
        case ManagerZReportPrint:
            reportPrintName = @"Manager Z";
            break;
        case ManagerZZReportPrint:
            reportPrintName = @"Manager ZZ";
            break;
        case CentralizeZReportPrint:
            reportPrintName = @"Centralize Z";
            break;
        case CCOverViewPrint:
            reportPrintName = @"CC Overview";
            break;
        case DeviceSummaryPrint:
            reportPrintName = @"Device Summary";
            break;

        default:
            break;
    }
    return reportPrintName;
}

- (BOOL)isHtmlDataWritenForCCBatch {
    BOOL needToOpenPopUp = false;
    switch (reportPrint) {
        case CCOverViewPrint:
            if(cCbatchPrintArray.count > 0)
            {
                needToOpenPopUp = true;
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Card"
                                                             ascending:YES ];
                NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
                NSArray *sortedArray;
                sortedArray = [[cCbatchPrintArray sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];

                cCOverViewReceipt = [[CCOverViewReceipt alloc] initWithPortName:nil portSetting:nil receiptData:sortedArray receiptTitle:@"CC Overview" filterDetails:cCbatchFilterDictionary];
                [self writeHtmlDataOnCacheDirectory:[[cCOverViewReceipt generateHtml] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            break;
        case CurrentTransactionPrint:
            if(cCbatchPrintArray.count > 0)
            {
                needToOpenPopUp = true;
                currentTransactionReceipt = [[CurrentTransactionReceipt alloc] initWithPortName:nil portSetting:nil receiptData:cCbatchPrintArray paymentGateWay:selectedPaymentGateWay receiptTitle:@"Current Transaction" cCBatchTrnxDetail:transactionsDetails isTipsApplicable:self.tipSetting filterDetails:cCbatchFilterDictionary];
                NSString *currentTransactionHtml = [self htmlAfterReplacingClassesAsPerTipSetting:self.tipSetting html:[currentTransactionReceipt generateHtml]];
                [self writeHtmlDataOnCacheDirectory:[currentTransactionHtml dataUsingEncoding:NSUTF8StringEncoding]];
            }
            break;
        case DeviceSummaryPrint:
            if(cCbatchPrintArray.count > 0)
            {
                needToOpenPopUp = true;
                deviceSummaryReceipt = [[DeviceSummaryReceipt alloc] initWithPortName:nil portSetting:nil receiptData:cCbatchPrintArray paymentGateWay:selectedPaymentGateWay receiptTitle:@"Device Summary" filterDetails:cCbatchFilterDictionary];
                [self writeHtmlDataOnCacheDirectory:[[deviceSummaryReceipt generateHtml] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            break;
        case DeviceBatchPrint:
            if(cCbatchPrintArray.count > 0)
            {
                needToOpenPopUp = true;
                deviceBatchReceipt = [[DeviceBatchReceipt alloc] initWithPortName:nil portSetting:nil receiptData:cCbatchPrintArray paymentGateWay:selectedPaymentGateWay receiptTitle:@"Device Batch" cCBatchTrnxDetail:transactionsDetails isTipsApplicable:self.tipSetting filterDetails:cCbatchFilterDictionary];
                NSString *deviceBatchHtml = [self htmlAfterReplacingClassesAsPerTipSetting:self.tipSetting html:[deviceBatchReceipt generateHtml]];
                [self writeHtmlDataOnCacheDirectory:[deviceBatchHtml dataUsingEncoding:NSUTF8StringEncoding]];
            }
            break;
            
        default:
            break;
    }
    return needToOpenPopUp;
}

- (NSString *)htmlAfterReplacingClassesAsPerTipSetting:(NSNumber *)isTipSettingEnable html:(NSString *)html {
    NSString *finalHtml;
    if (isTipSettingEnable.boolValue) {
        finalHtml = [html stringByReplacingOccurrencesOfString:@"$$STYLE$$" withString:@"<style>TD{} TD.CHTotal {width: 19%;padding-bottom:3px; padding-top:3px; height:102px;font-size:20px;} TD.CHTipAmount {width: 19%;padding-bottom:3px ; height:102px; font-size:20px;} TD.CHGrandTotal {width: 19%;padding-bottom:3px ; height:102px; font-size:20px;} TD.CHTotalTransactions {width: 25%;padding-bottom:3px ; height:102px; font-size:20px;} TD.CHAvgTicket {width: 18%;padding-bottom:3px; padding-top:3px;  height:102px; font-size:20px;} TD.HDateAndTime {width: 17%;padding-bottom:3px; padding-top:3px; padding-left:10px;} TD.HCardNumber {width: 14%;padding-bottom:3px; padding-top:3px; } TD.HCardType {width: 12%;padding-bottom:3px; padding-top:3px; } TD.HAmount {width: 11%;padding-bottom:3px; padding-top:3px; } TD.HTips {width: 11%;padding-bottom:3px; padding-top:3px; } TD.HTotalAmount {width: 12%;padding-bottom:3px; padding-top:3px; } TD.HAuth {width: 12%;padding-bottom:3px; padding-top:3px; } TD.HInvoice {width: 11%;padding-bottom:3px; padding-top:3px; }</style>"];
    }
    else {
        finalHtml = [html stringByReplacingOccurrencesOfString:@"$$STYLE$$" withString:@"<style>TD{} TD.CHTotal {width: 24%;padding-bottom:3px; padding-top:3px; height:102px;font-size:20px;} TD.CHTipAmount { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.CHGrandTotal {width: 24%;padding-bottom:3px ; height:102px; font-size:20px;} TD.CHTotalTransactions {width: 29%;padding-bottom:3px ; height:102px; font-size:20px;} TD.CHAvgTicket {width: 23%;padding-bottom:3px; padding-top:3px;  height:102px; font-size:20px;} TD.HDateAndTime {width: 18%;padding-bottom:3px; padding-top:3px; padding-left:10px;} TD.HCardNumber {width: 15%;padding-bottom:3px; padding-top:3px; } TD.HCardType {width: 13%;padding-bottom:3px; padding-top:3px; } TD.HAmount {width: 13%;padding-bottom:3px; padding-top:3px; } TD.HTips { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.HTotalAmount {width: 14%;padding-bottom:3px; padding-top:3px; } TD.HAuth {width: 14%;padding-bottom:3px; padding-top:3px; } TD.HInvoice {width: 13%;padding-bottom:3px; padding-top:3px; }</style>"];
    }
    return finalHtml;
}

- (IBAction)previewButtonClicked:(id)sender
{
    emailView = true;
    self.pdfCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.sourcePath]
                                         pathForPDF:(@"~/Documents/previewreceiptreport.pdf").stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
}

#pragma mark - NDHTMLtoPDFDelegate

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

#pragma mark - UIDocumentInteractionControllerDelegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}


#pragma mark - Delegate Methods

// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// -------------------------------------------------------------------------------
//	messageComposeViewController:didFinishWithResult:
//  Dismisses the message composition interface when users tap Cancel or Send.
//  Proceeds to update the feedback message field with the result of the
//  operation.
// -------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
            
            break;
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UIConfiguration

- (void)configureView:(UIView *)view {
    self.ccBatchView.hidden = YES;
    self.shiftView.hidden = YES;
    self.reportsView.hidden = YES;
    self.graphContainer.hidden = YES;
    if ([view isEqual:self.reportsView]) {
        self.graphContainer.hidden = NO;
        self.managerReportContainer.hidden = YES;
    }
    if ([view isEqual:self.managerReportContainer]) {
        self.reportsView.hidden = NO;
    }
    view.hidden = NO;
}

- (void)configureShiftView:(UIView *)view {
    self.shiftDetailsView.hidden = YES;
    self.shiftHistoryView.hidden = YES;
    view.hidden = NO;
}

- (void)setSelected:(FooterButton)footerButton {
    [self configureSettleBatchOptionFor:footerButton];
    for (UIButton *button in self.footerView.subviews) {
        if (button.tag == footerButton) {
            button.selected = YES;
        }
        else
        {
            button.selected = NO;
        }
    }
}

- (void)configureSettleBatchOptionFor:(FooterButton)footerButton {
    if (footerButton == FooterButtonCCBatch) {
        [self showSettleBatchOption];
    }
    else {
        [self hideSettleBatchOption];
    }
}

- (void)showSettleBatchOption {
    self.btnSettleBatch.hidden = NO;
}

- (void)hideSettleBatchOption {
    self.btnSettleBatch.hidden = YES;
}

- (void)setEnable:(FooterButton)footerButton {
    for (UIButton *button in self.footerView.subviews) {
        if (button.tag == footerButton) {
            button.enabled = YES;
        }
    }
}

- (void)setDisable:(FooterButton)footerButton {
    for (UIButton *button in self.footerView.subviews) {
        if (button.tag == footerButton) {
            button.enabled = NO;
        }
    }
}

- (void)startActivityIndicator {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
}

- (void)stopActivityIndicator {
    [_activityIndicator hideActivityIndicator];
}

- (void)backToPreviousSelection {
    [self setSelected:previousFooterButton];
    if (previousFooterButton == FooterButtonCCBatch) {
        [self showPaymentGateWayView];
    }
}

#pragma mark - Access Reports

- (IBAction)reportsButtonClicked:(UIButton *)sender {
    FooterButton footerButton = sender.tag;
    [self hideBackButton];
    [self hidePaymentGateWayView];
    [self setSelected:footerButton];
    switch (footerButton) {
        case FooterButtonShiftReport:
            [self accessShiftReport];
            break;
            
        case FooterButtonXReport:
            [self accessXReport];
            break;
            
        case FooterButtonZReport:
            [self accessZReport];
            break;
            
        case FooterButtonZZReport:
            [self accessZZReport];
            break;
            
        case FooterButtonManagerReport:
            [self accessManagerReport];
            break;

        case FooterButtonCCBatch:
            [self accessCCBatch];
            break;

        default:
            break;
    }
}

- (void)accessShiftReport {
    [self.rmsDbController playButtonSound];
    [self configureShiftReportView];
    [self.userShiftDetailsVC getCurrentShiftDetails];
}

- (void)configureShiftReportView {
    [self.managerReportVC needToShowAllTabOptions:NO];
    previousFooterButton = FooterButtonShiftReport;
    [self setPageTitle:@"Reporting"];
    reportPrint = ShiftReportPrint;
    [self configureView:self.shiftView];
    [self configureShiftView:self.shiftDetailsView];
}

- (void)accessXReport {
    [self.rmsDbController playButtonSound];
    reportPrint = XReportPrint;
    [self configureView:self.reportsView];
    self.reportHandlerVC.zIdForZZ = self.zIdForZZ;
    [self.reportHandlerVC configureView:self.reportHandlerVC.graphContainer];
    [self startActivityIndicator];
    [self.reportHandlerVC access:ReportNameX usingDictionary:nil];
}

- (void)accessZReport {
    [self.rmsDbController playButtonSound];
    self.reportHandlerVC.zIdForZZ = self.zIdForZZ;
    BOOL hasRights = [UserRights hasRights:UserRightZReportPrint];
    if (!hasRights) {
        [self displayReportAccessAlert:@"You don't have rights to generate Z-Report. Please contact to Admin." title:@"User Rights"];
        return;
    }
    if (isZOrZZPrint) {
        [self displayReportAccessAlert:@"Restart the application to check / print ZZ report again." title:@"Info"];
        return;
    }
    if([[self.rmsDbController.globalDict valueForKey:@"ZId"] integerValue ] == 0)
    {
        [self displayReportAccessAlert:@"Restart the application to check / print ZZ report again." title:@"Info"];
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self backToPreviousSelection];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            isZZPrint = FALSE;
            [self checkShiftEmployee];
            reportPrint = ZReportPrint;
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Do you want to proceed with Z report?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

- (void)accessZZReport {
    [self.rmsDbController playButtonSound];
    self.reportHandlerVC.zIdForZZ = self.zIdForZZ;
    BOOL hasRights = [UserRights hasRights:UserRightZZReportPrint];
    if (!hasRights) {
        [self displayReportAccessAlert:@"You don't have rights to generate ZZ-Report. Please contact to Admin." title:@"User Rights"];
        return;
    }
    
    if(([[self.rmsDbController.globalDict valueForKey:@"ZId"] integerValue ] == 0 ) &&
       (isZZPrint) )
    {
        [self displayReportAccessAlert:@"Restart the application to check / print ZZ report again." title:@"Info"];
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self backToPreviousSelection];
        };
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            isZZPrint=TRUE;
            if (isZPrint)
            {
                [self getZZReport];
            }
            else
            {
                reportPrint = ZReportPrint;
                [self checkShiftEmployee];
            }
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@" Do you want to proceed with ZZ report?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

- (void)accessManagerReport {
    [self.managerReportVC needToShowAllTabOptions:YES];
    previousFooterButton = FooterButtonManagerReport;
    [self accessShiftHistoryReport];
}

- (void)accessShiftHistoryReport {
    reportPrint = ShiftReportPrint;
    if (previousFooterButton == FooterButtonManagerReport) {
        [self configureView:self.managerReportContainer];
        [self loadShiftHistoryWithAllTabOptions:YES];
    }
    else {
        [self setPageTitle:@"Shift History"];
        [self.shiftHistoryDetailsVC loadShiftHistoryWithAllTabOptions:NO];
    }
}

- (void)accessManagerZReport {
    [self.rmsDbController playButtonSound];
    BOOL hasRights = [UserRights hasRights:UserRightManagerZReport];
    if (!hasRights) {
        [self displayReportAccessAlert:@"You don't have rights to generate Manager Z-Report. Please contact to Admin." title:@"User Rights"];
        return;
    }
    [self startActivityIndicator];
    [self setPageTitle:@"Manager Z"];
    [self.managerReportVC accessManagerReportsDetailsFor:[NSDate date] formatter:@"MM/yyyy" reportName:ReportNameManagerZ];
}

- (void)accessManagerZZReport {
    [self.rmsDbController playButtonSound];
    BOOL hasRights = [UserRights hasRights:UserRightManagerZZReport];
    if (!hasRights) {
        [self displayReportAccessAlert:@"You don't have rights to generate Manager ZZ-Report. Please contact to Admin." title:@"User Rights"];
        return;
    }
    [self startActivityIndicator];
    [self setPageTitle:@"Manager ZZ"];
    [self.managerReportVC accessManagerReportsDetailsFor:[NSDate date] formatter:@"yyyy" reportName:ReportNameManagerZZ];
}

- (void)accessManagerCentralizeZ {
    isCentralizedZPrintFromPopUp = false;
    [self.rmsDbController playButtonSound];
    [self startActivityIndicator];
    [self setPageTitle:@"Centralize Z"];
    [self.managerReportVC accessManagerReportsDetailsFor:[NSDate date] formatter:@"MM/yyyy" reportName:ReportNameCentralizedZ];
}

- (void)accessCCBatch {
    if (isCCBatchAllowed) {
        [self showPaymentGateWayView];
        [self.rmsDbController playButtonSound];
        previousFooterButton = FooterButtonCCBatch;
        [self setPageTitle:@"Tender Report"];
        [self configureView:self.ccBatchView];
        self.cCBatchVC.isTipsApplicable = self.tipSetting;
        [self.cCBatchVC displayCCBatchUI];
    }
    else {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to access CC Batch. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

#pragma mark - Pax Setting

- (void)showPaxConfigurationAlert {
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self showPaxSettingVC];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Credit card reader setting has not configured. Please configure it." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (void)showPaxSettingVC
{
    PaxDeviceViewController *paxDeviceViewController = [[PaxDeviceViewController alloc] initWithNibName:@"PaxDeviceViewController" bundle:NULL];
    paxDeviceViewController.paxDeviceSettingVCDelegate = (id)self.cCBatchVC;
    paxDeviceViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:paxDeviceViewController animated:YES completion:Nil];
}

#pragma mark - CCBatchVCDelegate

- (void)startActivityIndicatorForCCBatch {
    [self startActivityIndicator];
}

- (void)stopActivityIndicatorForCCBatch {
    [self stopActivityIndicator];
}

- (void)updateProgressStatusForCCBatch:(CGFloat)intPercentage {
    [_activityIndicator updateProgressStatus:intPercentage];
}

- (void)updateLoadingMessageForCCBatch:(NSString *)message {
    [_activityIndicator updateLoadingMessage:message];
}

- (void)addTipsView:(UIView *)tipsView {
    tipsView.frame = self.view.superview.bounds;
    [self.view.superview addSubview:tipsView];
}

- (void)removeTipsView:(UIView *)tipsView {
    [tipsView removeFromSuperview];
}

- (void)presentViewAsModalForCCBatch:(UIView *)view {
    [self presentViewAsModal:view];
}

- (void)removePresentedViewForCCBatch {
    [self removePresentModalView];
}

- (void)configurePaxDeviceFromSetting
{
    [self showPaxConfigurationAlert];
}

- (void)setSelectedPrintOptionForCCBatch:(ReportPrint)cCBatchReportPrint
{
    reportPrint = cCBatchReportPrint;
}

- (void)setPrintingData:(NSArray *)cCbatchPrintingArray paymentGateWay:(PaymentGateWay)paymentGateWay transactionDetails:(CCBatchTrnxDetailStruct*)transactionDetails filterDictionary:(NSDictionary *)filterDictionary {
    cCbatchPrintArray = [cCbatchPrintingArray copy];
    selectedPaymentGateWay = paymentGateWay;
    transactionsDetails = transactionDetails;
    cCbatchFilterDictionary = [filterDictionary copy];
}

#pragma mark - UserShiftDetailsVCDelegate

- (void)didHistoryButtonTapped {
    [self showBackButton];
    [self startActivityIndicator];
    [self setPageTitle:@"Shift History"];
    [self.shiftHistoryDetailsVC loadShiftHistoryWithAllTabOptions:NO];
}

- (void)loadShiftHistoryWithAllTabOptions:(BOOL)needToShowAllTab {
    [self startActivityIndicator];
    [self setPageTitle:@"Shift History"];
    [self.managerReportVC needToShowAllTabOptions:needToShowAllTab];
    [self.managerReportVC accessManagerReportsDetailsFor:[NSDate date] formatter:@"MM/yyyy" reportName:ReportNameShift];
}

- (void)didShiftCloseSuccessfully {
    
}

- (void)didGenerateHtml:(NSString *)html andPrintArray:(NSArray *)printArray forHistory:(BOOL)isForHistory emailHtmlPath:(NSString *)sourcePath {
    self.sourcePath = [sourcePath copy];
    if (printArray) {
        self.shiftReportArray = [printArray mutableCopy];
        if (previousFooterButton == FooterButtonManagerReport) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.reportWebVC loadHtmlReportInWebView:html];
            });
        }
        else {
            if (isForHistory) {
                [self.shiftHistoryDetailsVC loadHtmlForShiftHistoryUsing:html];
            }
            else {
                [self.userShiftDetailsVC loadHtmlForUserShiftUsing:html];
            }
        }
    }
    [self stopActivityIndicator];
}

- (void)didUserShiftServiceCall {
    [self startActivityIndicator];
}

- (void)didGetResponseOfUserShiftServiceCall {
    [self stopActivityIndicator];
}

#pragma mark - ShiftHistoryDetailsVCDelegate

- (void)accessShiftReport:(ReportName)reportName usingDictionary:(NSMutableDictionary *)shiftDetailsDict {
    if (reportName == ReportNameShift) {
        if (shiftDetailsDict) {
            [self stopActivityIndicator];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startActivityIndicator];
            });
            [self configureShiftView:self.shiftHistoryView];
            [self.userShiftDetailsVC accessShiftHistoryDetailsUsing:shiftDetailsDict];
            return;
        }
        [self stopActivityIndicator];
    }
}

#pragma mark - ManagerReportVCDelegate

- (void)accessMangerReport:(ReportName)reportName usingDictionary:(NSMutableDictionary *)mangerDetailsDict {
    [self startActivityIndicator];
    switch (reportName) {
        case ReportNameManagerZ:
            [self.reportHandlerVC access:ReportNameManagerZ usingDictionary:mangerDetailsDict];
            break;
        case ReportNameManagerZZ:
            [self.reportHandlerVC access:ReportNameManagerZZ usingDictionary:mangerDetailsDict];
            break;
        case ReportNameShift:
            [self.userShiftDetailsVC accessShiftHistoryDetailsUsing:mangerDetailsDict];
            break;
        case ReportNameCentralizedZ:
            [self.reportHandlerVC access:ReportNameCentralizedZ usingDictionary:mangerDetailsDict];
            break;
        default:
            break;
    }
}

- (void)didSelectedMangerReportOption:(ManagerTabOption)managerTabOption {
    switch (managerTabOption) {
        case ManagerTabOptionShiftHistory:
            [self accessShiftHistoryReport];
            break;
        case ManagerTabOptionZHistory:
            [self configureView:self.managerReportContainer];
            [self accessManagerZReport];
            break;
        case ManagerTabOptionZZHistory:
            [self configureView:self.managerReportContainer];
            [self accessManagerZZReport];
            break;
        case ManagerTabOptionCentralizedZHistory:
            [self configureView:self.managerReportContainer];
            [self accessManagerCentralizeZ];
            break;
        case ManagerTabOptionCentralizedZZHistory:
            break;
        default:
            break;
    }
}

#pragma mark - Present & Remove Modal View

- (void)presentViewAsModal :(UIView *)presentView
{
    presentView.center = self.popUpContainerView.center;
    [self.popUpContainerView addSubview:presentView];
    self.popUpContainerView.hidden = NO;
    [self.view bringSubviewToFront:self.popUpContainerView];
}

- (void)removePresentModalView
{
    for (UIView *presentView in self.popUpContainerView.subviews)
    {
        [presentView removeFromSuperview];
    }
    self.popUpContainerView.hidden = YES;
}

#pragma mark - Check Shift For Employee

-(void)checkShiftEmployee
{
    [self startActivityIndicator];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkShiftEmployeeResponse:response error:error];
        });
    };
    
    self.employeeShiftWC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_EMPLOYEE_SHIFT_OPEN_CHECK params:dict completionHandler:completionHandler];
}

-(void)checkShiftEmployeeResponse:(id)response error:(NSError *)error
{
    [self stopActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                enableShiftPrintOption = true;
                self.shiftInOutPopOverVC = [[ShiftInOutPopOverVC alloc] initWithNibName:@"ShiftInOutPopOverVC" bundle:nil];
                self.shiftInOutPopOverVC.shiftInOutPopOverDelegate = self;
                self.shiftInOutPopOverVC.strType = @"Shift-Close";
                self.shiftInOutPopOverVC.strZprint = @"Z print";
                if (isZZPrint) {
                    self.shiftInOutPopOverVC.strReportType = @"ZZ";
                }
                else
                {
                    self.shiftInOutPopOverVC.strReportType = @"Z";
                }
                [self presentViewAsModal:self.shiftInOutPopOverVC.view];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                enableShiftPrintOption = false;
                [self getZReport];
            }
        }
    }
}

- (void)getZReport {
    reportPrint = ZReportPrint;
    [self configureView:self.reportsView];
    [self.reportHandlerVC configureView:self.reportHandlerVC.graphContainer];
    if(![(self.rmsDbController.globalDict)[@"ZRequired"] boolValue])
    {
        [self ZClosingDetailOperationReport:@"0"];
    }
}

- (void)getZZReport {
    reportPrint = ZZReportPrint;
    [self startActivityIndicator];
    [self configureView:self.reportsView];
    [self.reportHandlerVC configureView:self.reportHandlerVC.graphContainer];
    [self.reportHandlerVC access:ReportNameZZ usingDictionary:nil];
}

#pragma mark - Z Closing Operation

-(void)ZClosingDetailOperationReport:(NSString *)strClosingAmt
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self startActivityIndicator];

    });
    
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"Amount"] = strClosingAmt;
    NSString *strDate = [self getDate];
    dict[@"Datetime"] = strDate;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self zClosingNoReqDetailResponse:response error:error];
    };
    
    self.zClosingNoReqDetailWC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_Z_CLOSING_DETAIL params:dict completionHandler:completionHandler];
}

- (void)zClosingNoReqDetailResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {

                [self.reportHandlerVC access:ReportNameZ usingDictionary:nil];
            }
            else
            {
                [self displayReportAccessAlert:@"Restart the application to check / print ZZ report again." title:@"Info"];
            }
        }
    }
}

#pragma mark - ReportHandlerVCDelegate

-(void)didCompleteReport:(ReportName)reportType responseArray:(NSArray *)responseArray {
    if (isCentralizedZPrintFromPopUp && reportType == ReportNameCentralizedZ) {
        self.centralizedZReportArray = [responseArray mutableCopy];
        [self printReportForPrintOption:CentralizeZReportPrint];
        return;
    }
    self.reportsArray = [responseArray mutableCopy];
    switch (reportType) {
        case ReportNameX:
            //Html Report Configuration & Load it into Webview
            previousFooterButton = FooterButtonXReport;
            [self setPageTitle:@"Reporting"];
            [self configureAndLoadHtmlReports:self.reportsArray :@"X Report"];
            break;
        case ReportNameZ:
            //Html Report Configuration & Load it into Webview
            previousFooterButton = FooterButtonZReport;
            [self setPageTitle:@"Reporting"];
            self.zReportArray = [self.reportsArray mutableCopy];
            [self configureAndLoadHtmlReports:self.reportsArray :@"Z Report"];
            [self proceessAfterZReport];
            break;
        case ReportNameZZ:
            //Html Report Configuration & Load it into Webview
            previousFooterButton = FooterButtonZZReport;
            [self setPageTitle:@"Reporting"];
            reportPrint = ZZReportPrint;
            [self configureAndLoadHtmlReports:self.reportsArray :@"ZZ Report"];
            [self proceessAfterZZReport];
            break;
        case ReportNameManagerZ:
            //Html Report Configuration & Load it into Webview
            previousFooterButton = FooterButtonManagerReport;
            reportPrint = ManagerZReportPrint;
            [self configureAndLoadHtmlReports:self.reportsArray :@"Manager Z"];
            break;
        case ReportNameManagerZZ:
            //Html Report Configuration & Load it into Webview
            previousFooterButton = FooterButtonManagerReport;
            reportPrint = ManagerZZReportPrint;
            [self configureAndLoadHtmlReports:self.reportsArray :@"Manager ZZ"];
            break;
        case ReportNameCentralizedZ:
            //Html Report Configuration & Load it into Webview
            previousFooterButton = FooterButtonManagerReport;
            reportPrint = CentralizeZReportPrint;
            [self configureAndLoadHtmlReports:self.reportsArray :@"Centralize Z"];
            break;
        default:
            break;
    }
    [self stopActivityIndicator];
}

- (void)proceessAfterZReport {
    isZOrZZPrint = TRUE;
    isZPrint = TRUE;
    if(isZZPrint)
    {
        isZPrint = FALSE;
        [self getZZReport];
    }
    else
    {
        [self showReportPrintOptions:@[@"SHIFT REPORT",@"Z REPORT",@"CENTRALIZED Z"]needToEnableShiftPrintOption:enableShiftPrintOption];
    }
    self.zIdForZZ = (self.rmsDbController.globalDict)[@"ZId"];
    NSArray *rptZDetail = [[self.reportsArray.firstObject valueForKey:@"RptZDetail"] mutableCopy];
    if (rptZDetail.count > 0 && [rptZDetail isKindOfClass:[NSArray class]]) {
        NSString *zID = [rptZDetail.firstObject[@"ZId"] stringValue];
        if ([zID isEqualToString:@"0"] || zID == nil) {
            [self showRestartAppAlertAndSetDefultZID];
            return;
        }
        [self.rmsDbController.globalDict removeObjectForKey:@"ZId"];
        (self.rmsDbController.globalDict)[@"ZId"] = zID;
        [self.updateManager updateZidWithRegisrterInfo:zID withContext:self.rmsDbController.managedObjectContext];
    }
    else
    {
        [self showRestartAppAlertAndSetDefultZID];
    }
}

- (void)proceessAfterZZReport {
    isZOrZZPrint = TRUE;
    if (isZPrint)
    {
        [self removePresentModalView];
    }
    else
    {
        [self showReportPrintOptions:@[@"SHIFT REPORT",@"Z REPORT",@"CENTRALIZED Z",@"ZZ REPORT"]needToEnableShiftPrintOption:enableShiftPrintOption];
        isZPrint = TRUE;
    }
    isZZPrint = FALSE;
}

-(void)showRestartAppAlertAndSetDefultZID
{
    [self.rmsDbController.globalDict removeObjectForKey:@"ZId"];
    (self.rmsDbController.globalDict)[@"ZId"] = @"0";
    [self.updateManager updateZidWithRegisrterInfo:@"0" withContext:self.rmsDbController.managedObjectContext];
    [self displayReportAccessAlert:@"Please restart the application or contact to RapiRMS" title:@"Info"];
}

#pragma mark - PrintReportOptions

- (void)showReportPrintOptions:(NSArray *)printOptionsArray needToEnableShiftPrintOption:(BOOL)isEnabled {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Reporting" bundle:nil];
    reportPrintOptionsVC = [storyBoard instantiateViewControllerWithIdentifier:@"ReportPrintOptionsVC"];
    reportPrintOptionsVC.reportPrintOptionsVCDelegate = self;
    reportPrintOptionsVC.arrPrintOptions = [printOptionsArray mutableCopy];
    reportPrintOptionsVC.enableShiftPrintingOption = isEnabled;
    reportPrintOptionsVC.view.frame = CGRectMake(310, 150, 402, 266);
    [self presentViewAsModal:reportPrintOptionsVC.view];
}

#pragma mark - ReportPrintOptionsVCDelegate

- (void)didSelectPrinterOption:(PrintOption)printOption {
    _printOption = printOption;
    switch (printOption) {
        case PrintOptionShiftReport:
            [self printShiftReport];
            break;
        case PrintOptionZReport:
            [self printZReport];
            break;
        case PrintOptionCentralizedZReport:
            [self printCentralizedZReport];
            break;
        case PrintOptionZZReport:
            [self printZZReport];
            break;

        default:
            break;
    }
}

- (void)didCancelPrinterOption {
    _printOption = PrintOptionNone;
    [self removePresentModalView];
}

- (void)printShiftReport {
#ifdef CheckRights
    BOOL hasRights = [UserRights hasRights:UserRightShiftInOut];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to print Shift Report. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
#endif
    [self.shiftInOutPopOverVC LastEmpoyeeShiftWithZid:self.zIdForZZ];
}

- (void)printZReport {
    BOOL hasRights = [UserRights hasRights:UserRightZReportPrint];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to print Z-Report. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    [self printReportForPrintOption:ZReportPrint];
}

- (void)printCentralizedZReport {
    isCentralizedZPrintFromPopUp = true;
    NSString *currentDate = [self getCurrentDate];
    NSMutableDictionary *centralizedDict = [[NSMutableDictionary alloc] init];
    centralizedDict [@"ZClsDate"] = currentDate;
    [self startActivityIndicator];
    [self.reportHandlerVC access:ReportNameCentralizedZ usingDictionary:centralizedDict];
}

- (NSString *)getCurrentDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *currentDate = [dateFormatter stringFromDate:date];
    return currentDate;
}

- (void)printZZReport {
    BOOL hasRights = [UserRights hasRights:UserRightZZReportPrint];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to print ZZ-Report. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    [self printReportForPrintOption:ZZReportPrint];
}

- (void)printReportForPrintOption:(ReportPrint)_reportPrint {
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    if (_activityIndicator) {
        [_activityIndicator hideActivityIndicator];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    });
    switch (_reportPrint) {
        case ZReportPrint:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self printReport:portName portSettings:portSettings withReportObject:self.zReportArray forReport:@"Z Report"];
            });
        }
            break;
        case ZZReportPrint:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self printReport:portName portSettings:portSettings withReportObject:self.reportsArray forReport:@"ZZ Report"];
            });
        }
            break;
        case CentralizeZReportPrint:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self printReport:portName portSettings:portSettings withReportObject:self.centralizedZReportArray forReport:@"Centralize Z"];
            });
        }
            break;

        default:
            break;
    }
}

- (void)printShiftReportAgain {
    [self.shiftInOutPopOverVC printShiftReport];
}

- (void)printReportAgainAfterFailer {
    switch (_printOption) {
        case PrintOptionZReport:
            [self printReportForPrintOption:ZReportPrint];
            break;
        case PrintOptionCentralizedZReport:
            [self printReportForPrintOption:CentralizeZReportPrint];
            break;
        case PrintOptionZZReport:
            [self printReportForPrintOption:ZZReportPrint];
            break;
        case PrintOptionNone:
            [self printReportsButtonClicked:nil];
            break;
        default:
            [self printReportsButtonClicked:nil];
            break;
    }
}

#pragma mark - ShiftInOutPopOverDelegate

-(void)shiftIn_OutSuccessfullyDone
{
    [self removePresentModalView];
    [self getZReport];
}

-(void)ShiftIn_OutProcessFailed
{
    
}

-(void)dismissShiftIn_OutController
{
    [self removePresentModalView];
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    for (UIViewController *vc in viewControllerArray)
    {
        if ([vc isKindOfClass:[DashBoardSettingVC class]])
        {
            [self.navigationController popToViewController:vc animated:TRUE];
        }
    }
}

-(void)didFailToPrintShiftReport {
    [self displayReportPrintRetryAlert:@"Failed to Shift Report print receipt. Would you like to retry.?"];
}

-(void)displayReportPrintRetryAlert:(NSString *)message
{
    DailyReportVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference printShiftReportAgain];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

#pragma mark - Write Html File

-(void)writeHtmlDataOnCacheDirectory:(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.sourcePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.sourcePath error:nil];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.sourcePath = [documentsDirectory stringByAppendingPathComponent:@"ReportDetail.html"];
    [data writeToFile:self.sourcePath atomically:YES];
}

#pragma mark - Create Html File

-(void)configureAndLoadHtmlReports:(NSMutableArray *)array :(NSString *)reportName {
    strHtmlReportForEmail = [[self createHTMLFormateForEmail:[self createHtmlReport:array :reportName]] mutableCopy];
    /// Write Data On Document Directory.......
    NSData *data = [strHtmlReportForEmail dataUsingEncoding:NSUTF8StringEncoding];
    [self writeHtmlDataOnCacheDirectory:data];
    strHtmlReport = [[self createHTMLFormateForDisplayReportInWebView:[self createHtmlReport:array :reportName]] mutableCopy];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.reportWebVC loadHtmlReportInWebView:strHtmlReport];
    });
}

-(NSString *)createHtmlReport:(NSMutableArray *)responseArray :(NSString *)reportName{
    XReport *xReporthtml = [[XReport alloc] initWithDictionary:responseArray.firstObject reportName:reportName isTips:self.tipSetting.boolValue];
    NSString *htmlData = xReporthtml.generateHtml;
    return htmlData;
}

- (NSString *)createHTMLFormateForEmail:(NSString *)html
{
    NSString *strReportForEmail = [html stringByReplacingOccurrencesOfString:@"$$STYLE$$" withString:@"<style>TD{} TD.TaxType {width: 25%;padding-bottom:3px;} TD.TaxSales {width: 25%;padding-bottom:3px;} TD.TaxTax {width: 25%;padding-bottom:3px;} TD.TaxCustCount {width: 25%;padding-bottom:3px;} TD.TipsTederType {width: 25%;padding-bottom:3px;} TD.TipsTederAmount {width: 25%;padding-bottom:3px;} TD.TipsTeder {width: 25%;padding-bottom:3px;}TD.TipsTederTotal {width: 25%;padding-bottom:3px;} TD.DepartmentName {width: 15%;padding-bottom:3px;} TD.DepartmentCost {width: 15%;padding-bottom:3px;} TD.DepartmentAmount {width: 17%;padding-bottom:3px;} TD.DepartmentMargin {width: 20%;padding-bottom:3px;} TD.DepartmentPer {width: 12%;padding-bottom:3px;} TD.DepartmentCount {width: 11%;padding-bottom:3px;}</style>"];
    strReportForEmail = [strReportForEmail stringByReplacingOccurrencesOfString:@"$$WIDTH$$" withString:@"width:450px"];
    strReportForEmail = [strReportForEmail stringByReplacingOccurrencesOfString:@"$$WIDTHCOMMONHEADER$$" withString:@"width:450px"];
    return strReportForEmail;
}

- (NSString *)createHTMLFormateForDisplayReportInWebView:(NSString *)html
{
    NSString *strReport = [html stringByReplacingOccurrencesOfString:@"$$STYLE$$" withString:@"<style>TD{} TD.TaxType {width: 25%;padding-bottom:3px;} TD.TaxSales {width: 25%;padding-bottom:3px;} TD.TaxTax {width: 25%;padding-bottom:3px;} TD.TaxCustCount {width: 25%;padding-bottom:3px;} TD.TederType { width: 30%;padding-bottom:3px;} TD.TederTypeAmount { width: 40%;padding-bottom:3px;} TD.TederTypeAvgTicket { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.TederTypePer { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.TederTypeCount { width: 30%;padding-bottom:3px;} TD.TipsTederType {width: 25%;padding-bottom:3px;} TD.TipsTederAmount {width: 25%;padding-bottom:3px;} TD.TipsTeder {width: 25%;padding-bottom:3px;}TD.TipsTederTotal {width: 25%;padding-bottom:3px;} TD.CardType { width: 30%;padding-bottom:3px;} TD.CardTypeAmount { width: 40%;padding-bottom:3px;} TD.CardTypeAvgTicket { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.CardTypeTypePer { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.CardTypeCount { width: 30%;padding-bottom:3px;} TD.DepartmentName { width: 25%; padding-bottom:3px;} TD.DepartmentCost { width: 0%; overflow: hidden; display: none; text-indent: -9999; padding-bottom:3px;} TD.DepartmentAmount { width: 25%;padding-bottom:3px;} TD.DepartmentMargin { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.DepartmentPer { width: 25%;padding-bottom:3px;} TD.DepartmentCount { width: 25%;padding-bottom:3px;}TD.HourlySales { width: 30%;padding-bottom:3px;} TD.HourlySalesCost { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.HourlySalesAmount { width: 40%;padding-bottom:3px;} TD.HourlySalesMargin { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.HourlySalesCount { width: 30%;padding-bottom:3px;} TD.Group20AGFS {width: 40%;padding-bottom:3px;} TD.Group20AGallons {width: 20%;padding-bottom:3px;} TD.Group20AAmount {width: 20%;padding-bottom:3px;} TD.Group20ACount {width: 20%;padding-bottom:3px;} TD.Group20FuelType {width: 40%;padding-bottom:3px;} TD.Group20Amount {width: 20%;padding-bottom:3px;} TD.Group20Gallons {width: 20%;padding-bottom:3px;} TD.Group20Count {width: 20%;padding-bottom:3px;} TD.Group21FuelType {width: 40%;padding-bottom:3px;} TD.Group21Amount {width: 20%;padding-bottom:3px;} TD.Group21Gallons {width: 20%;padding-bottom:3px;} TD.Group21Count {width: 20%;padding-bottom:3px;} TD.Group22SG {width: 25%;padding-bottom:3px;} TD.Group22Delivery {width: 25%;padding-bottom:3px;} TD.Group22EG {width: 25%;padding-bottom:3px;} TD.Group22Difference {width: 25%;padding-bottom:3px;} TD.Group23A {width: 30%;padding-bottom:3px;} TD.Group23AGallons {width: 27%;padding-bottom:3px;} TD.Group23AAmount {width: 28%;padding-bottom:3px;} TD.Group23ACount {width: 25%;padding-bottom:3px;} TD.Group23BGallons {width: 30%;padding-bottom:3px;} TD.Group23BAmount {width: 22%;padding-bottom:3px;} TD.Group23BTotal {width: 23%;padding-bottom:3px;} TD.Group23ACount {width: 25%;padding-bottom:3px;} TD.Group24FuelType {width: 25%;padding-bottom:3px;} TD.Group24Gallons {width: 25%;padding-bottom:3px;} TD.Group24Amount {width: 25%;padding-bottom:3px;} TD.Group24Count {width: 25%;padding-bottom:3px;} </style>"];
    strReport =  [strReport stringByReplacingOccurrencesOfString:@"$$WIDTH$$" withString:@"width:286px"];
    strReport = [strReport stringByReplacingOccurrencesOfString:@"$$WIDTHCOMMONHEADER$$" withString:@"width:300px"];
    return strReport;
}

#pragma mark - Settle Batch

- (IBAction)settleBatchClicked:(id)sender {
    [self.cCBatchVC settleBatchProcess];
}

#pragma mark - Exit From Reporting

- (IBAction)closeButtonClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    if ([self.rmsDbController.selectedModule isEqualToString:@"RCR"])
    {
        BOOL isShiftClosedByUser = FALSE;
        if ([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"CashInOutFlg"] boolValue] == FALSE)
        {
            isShiftClosedByUser = TRUE;
        }
        if (isZOrZZPrint || (isShiftOpen == TRUE &&  isShiftClosedByUser == TRUE) ) {
            [self goToDashBoard];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:TRUE];
        }
    }
    else
    {
        [self goToDashBoard];
    }
}

-(void)goToDashBoard
{
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    for (UIViewController *viewController in viewControllerArray)
    {
        if ([viewController isKindOfClass:[DashBoardSettingVC class]])
        {
            [self.navigationController popToViewController:viewController animated:TRUE];
        }
    }
}

#pragma mark - Utility

- (NSString *)getDate {
    NSDate *sourceDate = [NSDate date];
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone *destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSString *strDate=[NSString stringWithFormat:@"%@",destinationDate];
    return strDate;
}

- (void)displayDailyReportPrintRetryAlert:(NSString *)message
{
    DailyReportVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference printReportAgainAfterFailer];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)displayReportAccessAlert:(NSString *)message title:(NSString *)title
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:title message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"ReportHandlerVCSegue"]) {
        self.reportHandlerVC = (ReportHandlerVC*) segue.destinationViewController;
        self.reportHandlerVC.reportHandlerVCDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"ReportWebVCSegue"]) {
        self.reportWebVC = (ReportWebVC*) segue.destinationViewController;
    }
    if ([segueIdentifier isEqualToString:@"ManagerReportVCSegue"]) {
        self.managerReportVC = (ManagerReportVC*) segue.destinationViewController;
        self.managerReportVC.managerReportVCDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"DailyReportToUserShiftDetailsVC"]) {
        self.userShiftDetailsVC = (UserShiftDetailsVC*) segue.destinationViewController;
        self.userShiftDetailsVC.userShiftDetailsVCDelegate = self;
        self.userShiftDetailsVC.isShifInOutFromReport = true;
    }
    if ([segueIdentifier isEqualToString:@"DailyReportToShiftHistoryDetailsVCSegue"]) {
        self.shiftHistoryDetailsVC = (ShiftHistoryDetailsVC*) segue.destinationViewController;
        self.shiftHistoryDetailsVC.shiftHistoryDetailsVCDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"DailyReportToCCBatchVCSegue"]) {
        self.cCBatchVC = (CCBatchVC*) segue.destinationViewController;
        self.cCBatchVC.cCBatchVCDelegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
