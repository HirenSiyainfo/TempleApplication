//
//  ReportViewController.m
//  POSFrontEnd
//
//  Created by Nirav Patel on 06/11/12.
//
//

typedef NS_ENUM(NSInteger, ReportPrint)
{
    ShiftReport,
    XReportPrint,
    ZReportPrint,
    ZZReportPrint,
    ManagerZReportPrint,
    ManagerZZReportPrint,
};

#import "ReportViewController.h"
#import "MyPrintPageRenderer.h"
#import "ZRequiredViewController.h"
#import "XReportPieChart.h"
#import "XReportBarChart.h"
#import "XReportpaymentPieChart.h"
#import "CashinOutViewController.h"
#import "RmsDbController.h"
#import "RcrController.h"
#import "ShiftInOutPopOverVC.h"
#import <MessageUI/MessageUI.h>
#import "CCbatchReportVC.h"
#import "XCCbatchReportVC.h"
#import "EmailFromViewController.h"
#import "InvoiceData_T+Dictionary.h"
#import "TaxMaster+Dictionary.h"
#import "CKOCalendarViewController.h"
#import "XReport.h"
#import "OfflineReportCalculation.h"
#import "Configuration+Dictionary.h"
#import "RapidCreditBatchDetailVC.h"
#import "ShiftOpenCloseVC.h"

#define SCROLLVIEWTAP_CONTENT_HEIGHT 1114
#define SCROLLVIEWTAP_CONTENT_WIDTH  665

//#define CheckRights

@interface ReportViewController () <ShiftInOutPopOverDelegate,MFMailComposeViewControllerDelegate,UpdateDelegate,UIPopoverControllerDelegate,UIPopoverPresentationControllerDelegate,XCCbatchReportDelegate,PrinterFunctionsDelegate , EmailFromViewControllerDelegate>
{
    UILabel *cardDate;
    UILabel *creditCardNumber;
    UILabel *cardType;
    UILabel *totalAmount;
    UILabel *authNumber;
    UILabel *referenceNumber;
    UILabel *invoiceNumber;
    
    XReportPieChart *objPieChart;
    XReportBarChart *objBarChart;
    XReportpaymentPieChart *objPaymentPieChart;
    ShiftInOutPopOverVC *shift;
    IntercomHandler *intercomHandler;
    CCbatchReportVC *ccBatchReport;
    XCCbatchReportVC *xccBatchReport;
    RapidCreditBatchDetailVC *rapidCreditBatchDetailVC;
    XReport *xReport;
    EmailFromViewController *emailFromViewController;
    ReportPrint reportPrint;
    CashinOutViewController *cashInView;
    ShiftOpenCloseVC *shiftOpenClose;


    BOOL isZOrZZPrint;
    BOOL isZPrint;
    BOOL emailView;
    
    UIDatePicker *datePicker;
    NSArray *array_port;
    NSInteger selectedPort;
    NSMutableArray *responseZArray;
    NSString *sPrint;
    NSString *strSelectButton;
    NSString* documentDirectoryFilename;
    UIView *datepickerBoderView;
    NSMutableArray *XmlResponseArray;
    UIViewController *emailPdfViewController;
    UIPopoverPresentationController *emailPdfPopOverController;
    NSString *zIdForOfflineInvoiceCount;
    NSDate *managerDate;
    BOOL isShiftOpen;
}

@property (nonatomic, weak) IBOutlet UILabel *lblCurrentDate;
@property (nonatomic, weak) IBOutlet UILabel *lblReportCount;
@property (nonatomic, weak) IBOutlet UILabel *lblMangerDate;
@property (nonatomic, weak) IBOutlet UILabel *lblCoustmerCount;
@property (nonatomic, weak) IBOutlet UILabel *lblChartValue;
@property (nonatomic, weak) IBOutlet UILabel *lblPaymentChartValue;

@property (nonatomic, weak) IBOutlet UIView *cardSattlementView;
@property (nonatomic, weak) IBOutlet UIView *managerReportView;
@property (nonatomic, weak) IBOutlet UIView *uvXReport;
@property (nonatomic, weak) IBOutlet UIView *uvXRepBar;
@property (nonatomic, weak) IBOutlet UIView *uvsampleView;
@property (nonatomic, weak) IBOutlet UIView *uvPaymentBarChart;
@property (nonatomic, weak) IBOutlet UIView *uvManagerHeaderView;
@property (nonatomic, weak) IBOutlet UIView *emailPdfView;
@property (nonatomic, weak) IBOutlet UIView *uvZZReportInfo;
@property (nonatomic, weak) IBOutlet UIView *uvZReportInfo;
@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UIView *shiftReportView;


@property (nonatomic, weak) IBOutlet UIButton *btnCurrencyIndicator;
@property (nonatomic, weak) IBOutlet UIButton *btnDollorView;
@property (nonatomic, weak) IBOutlet UIButton *btnPrctView;
@property (nonatomic, weak) IBOutlet UIButton *ccBatch;
@property (nonatomic, weak) IBOutlet UIButton *settleCC;
@property (nonatomic, weak) IBOutlet UIButton *btnManagerReport;
@property (nonatomic, weak) IBOutlet UIButton *btnShiftReport;
@property (nonatomic, weak) IBOutlet UIButton *btnXReport;
@property (nonatomic, weak) IBOutlet UIButton *btnZReport;
@property (nonatomic, weak) IBOutlet UIButton *btnMReport;
@property (nonatomic, weak) IBOutlet UIButton *btnZZReport;
@property (nonatomic, weak) IBOutlet UIButton *btnZZManager;
@property (nonatomic, weak) IBOutlet UIButton *btnPdf;
@property (nonatomic, weak) IBOutlet UIButton *btnPrint;
@property (nonatomic, weak) IBOutlet UIButton *pdfEmailBtn;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnShiftPrint;
@property (nonatomic, weak) IBOutlet UIButton *ccBatchButton;
@property (nonatomic, weak) IBOutlet UIButton *rapidCreditBatchButton;
@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UIButton *btnPreview;
@property (nonatomic, weak) IBOutlet UIButton *btnCCBatch;



@property (nonatomic, weak) IBOutlet UITableView *cardSettlementTableView;
@property (nonatomic, weak) IBOutlet UITableView *tblReportMode;
@property (nonatomic, weak) IBOutlet UITableView *tblManagerReportList;
@property (nonatomic, weak) IBOutlet UIScrollView *scrlChart;
@property (nonatomic, weak) IBOutlet UIToolbar *toolManagerBar;
@property (nonatomic, weak) IBOutlet UIWebView *PrintReport;
@property (nonatomic, weak) IBOutlet UIWebView *pdfFile;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) Configuration *configuration;

@property (nonatomic, strong) RapidWebServiceConnection *webServiceConnectionReportOffline;
@property (nonatomic, strong) RapidWebServiceConnection *reportGenerateWC;
@property (nonatomic, strong) RapidWebServiceConnection *employeeShiftOpenCheckWC;
@property (nonatomic, strong) RapidWebServiceConnection *zClosingNoReqDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *zReportGenerateWC;
@property (nonatomic, strong) RapidWebServiceConnection *zZManagerListDataWC;
@property (nonatomic, strong) RapidWebServiceConnection *zZManagerListDataWC2;
@property (nonatomic, strong) RapidWebServiceConnection *mReportGenerateWC;
@property (nonatomic, strong) RapidWebServiceConnection *mReportGenerateWC2;
@property (nonatomic, strong) RapidWebServiceConnection *zZManagerReportWC;
@property (nonatomic, strong) RapidWebServiceConnection *zManagerReportWC;
@property (nonatomic, strong) RapidWebServiceConnection *zZReportDataWC;
@property(nonatomic,strong) NDHTMLtoPDF *PDFCreator;

@property(nonatomic,assign)BOOL bZexit;
@property(nonatomic,assign)BOOL isZZPrint;

@property (atomic) NSInteger selectedIndexPath;
@property (nonatomic, strong) NSMutableArray *zReportPrintArray;
@property (nonatomic, strong) NSNumber  *tipSetting;
@property (nonatomic, strong) NSArray *offlineInvoice;
@property (nonatomic) NSInteger nextIndex;
@property (nonatomic, strong) NSString *parseingFunCall;
@property (nonatomic, strong) NSString *ZidForZZ;
@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, strong) UIPopoverController *calendarPopOverController;
@property (nonatomic, strong) UIPopoverController *ccBatchOptionSelectionPopOverView;

@property (nonatomic, strong) UIDocumentInteractionController *controller;
@property (nonatomic, strong) NSManagedObjectContext *offlineManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong) NSMutableArray *responseXArray;
@property(nonatomic,strong) NSMutableArray *arrayMangerReportList;
@property(nonatomic,strong) NSMutableArray *paymentCardTypearrayGlobal;


@end

@implementation ReportViewController

@synthesize PrintReport;
@synthesize lblChartValue,lblPaymentChartValue;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [ReportViewController setPortName:localPortName];
    [ReportViewController setPortSettings:array_port[selectedPort]];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    emailView=NO;
    
	self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.reportGenerateWC = [[RapidWebServiceConnection alloc] init];
    self.employeeShiftOpenCheckWC = [[RapidWebServiceConnection alloc] init];
    self.zClosingNoReqDetailWC = [[RapidWebServiceConnection alloc] init];
    self.zReportGenerateWC = [[RapidWebServiceConnection alloc] init];
    self.zZManagerListDataWC = [[RapidWebServiceConnection alloc] init];
    self.zZManagerListDataWC2 = [[RapidWebServiceConnection alloc] init];
    self.mReportGenerateWC = [[RapidWebServiceConnection alloc] init];
    self.mReportGenerateWC2 = [[RapidWebServiceConnection alloc] init];
    self.zZManagerReportWC = [[RapidWebServiceConnection alloc] init];
    self.zManagerReportWC = [[RapidWebServiceConnection alloc] init];
    self.zZReportDataWC = [[RapidWebServiceConnection alloc] init];
    self.paymentCardTypearrayGlobal = self.rmsDbController.paymentCardTypearray;
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];

    self.configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext ];
    self.tipSetting = self.configuration.localTipsSetting;
    
    
    self.offlineManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    self.webServiceConnectionReportOffline = [[RapidWebServiceConnection alloc] init];
    zIdForOfflineInvoiceCount = (self.rmsDbController.globalDict)[@"ZId"];
   // [self.rmsDbController cancelOfflineUploadProcess];
 //   [self sendOfflineDataToServer];

    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    self.responseXArray=[[NSMutableArray alloc]init];
    responseZArray=[[NSMutableArray alloc]init];
    _toolManagerBar.hidden=YES;
    emailPdfViewController = [[UIViewController alloc]init];
    _emailPdfView.hidden = YES;
    [_scrlChart setScrollEnabled:YES];
	_scrlChart.contentSize = CGSizeMake(SCROLLVIEWTAP_CONTENT_WIDTH,SCROLLVIEWTAP_CONTENT_HEIGHT);
    _scrlChart.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _scrlChart.layer.borderWidth = 0.5;
    
    _uvManagerHeaderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _uvManagerHeaderView.layer.borderWidth = 0.5;
    
    self.cardSettlementTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cardSettlementTableView.layer.borderWidth = 0.5;
    self.zReportPrintArray = [[NSMutableArray alloc]init];
    
    strSelectButton=@"";
    _strTypeofChart = @"Dollorwise";
    _managerReportView.hidden = YES;
    
    XmlResponseArray = [[NSMutableArray alloc] init];
    managerDate = [NSDate date];
    isZOrZZPrint = FALSE;
    isZPrint = FALSE;
    [self.view addSubview:_uvZZReportInfo];
    _uvZZReportInfo.hidden = YES;
    
    [self.view addSubview:_uvZReportInfo];
    _uvZReportInfo.hidden = YES;
    [self.btnCurrencyIndicator setTitle:self.rmsDbController.currencyFormatter.currencySymbol forState:UIControlStateNormal];
    [self.btnCurrencyIndicator setTitle:self.rmsDbController.currencyFormatter.currencySymbol forState:UIControlStateSelected];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    
    if ([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"CashInOutFlg"] boolValue] == TRUE ) {
        isShiftOpen = TRUE;
    }
}

-(void)showShiftReport
{
//    NSMutableDictionary *dictUInfo = [self.rmsDbController.globalDict valueForKey:@"UserInfo"];
//    
//    if([[dictUInfo valueForKey:@"CashInOutFlg"]integerValue]==0 && [[dictUInfo valueForKey:@"CashInRequire"]integerValue]==0){
//        
//        
//    }
//    else{
//        [dictUInfo setObject:@"1" forKey:@"CashInOutFlg"];
//        [dictUInfo setObject:@"0" forKey:@"CashInRequire"];
//        [self.rmsDbController.globalDict setObject:dictUInfo forKey:@"UserInfo"];
//    }
    
    sPrint=@"ShiftReport";
    self.shiftReportView.hidden = NO;
    shiftOpenClose =[[ShiftOpenCloseVC alloc]initWithNibName:@"ShiftInDailyReportVC" bundle:nil];
    shiftOpenClose.isShifInOutFromReport = YES;
    shiftOpenClose.view.frame = CGRectMake(0, 0, 1024, 655);
    shiftOpenClose.navigationController.navigationBarHidden = YES;
    [self addChildViewController:shiftOpenClose];
    [self.shiftReportView addSubview:shiftOpenClose.view];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    _lblCurrentDate.text = [formatter stringFromDate:date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
    if(emailView == NO)
    {
        if ([sPrint isEqualToString:@"Z"])
        {
            [self getZReport];
        }
        else if ( [sPrint isEqualToString:@"ZZ"])
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
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

-(IBAction)showShiftReportDetail:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self setSelectButton:(UIButton *)sender forView:_footerView];
    [self removeRapidCreditBatchSettleView];
    
    [[self.view viewWithTag:101] setHidden:YES];
    [[self.view viewWithTag:102]setHidden:YES];
    
 //   self.shiftReportView.hidden = NO;
    _btnDollorView.selected = NO;
    _btnPrctView.selected = NO;
    _ccBatch.selected = NO;
    _ccBatch.hidden = NO;
    _settleCC.hidden = NO;
    _cardSattlementView.hidden = YES;
    _ccBatchButton.selected = NO;
    xccBatchReport.view.hidden = YES;
    ccBatchReport.view.hidden = YES;

    [self showShiftReport];

}

#pragma mark -
#pragma mark Get XReport Detail

-(IBAction)getXreportDetail:(id)sender
{
    
    [self.rmsDbController playButtonSound];
    sPrint=@"X";
    
    [self setSelectButton:(UIButton *)sender forView:_footerView];
    [self removeRapidCreditBatchSettleView];

    
    _btnDollorView.selected = YES;
    _btnPrctView.selected = NO;
    _ccBatch.selected = NO;
    _ccBatch.hidden = NO;
    _settleCC.hidden = NO;
    _cardSattlementView.hidden = YES;
    _ccBatchButton.selected = NO;
    self.shiftReportView.hidden = YES;

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getXReport];
    });
}

-(void)getXReport
{
    //    [btnZReport setBackgroundImage:[UIImage imageNamed:@"_0002_button1A.png"] forState:UIControlStateNormal];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    sPrint=@"X";
    self.crmController.singleTap1.enabled=YES;
    [_btnPdf setEnabled:NO];
    [_btnPrint setEnabled:NO];
    NSMutableArray *arrayMain =[[NSMutableArray alloc]init];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    [arrayMain addObject:dict];
    
    NSMutableDictionary *dictMain =[[NSMutableDictionary alloc]init];
    dictMain[@"RequestData"] = dict;
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self xReportResponse:response error:error];
        });
    };
    
    self.reportGenerateWC = [self.reportGenerateWC initWithRequest:KURL actionName:
//#ifdef DEBUG
                             WSM_X_REPORT_DETAIL
//#else
//                             WSM_X_REPORT_DETAIL
//#endif
                                                            params:dictMain completionHandler:completionHandler];
    
}

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
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self uploadNextInvoiceData];
        });
    }
    else{
        self.isZZPrint=FALSE;
        [self showDefaultReportingView];
    }
}

- (void)showDefaultReportingView {
    //Show Default Reporting view according to User Rights.
#ifdef CheckRights
    BOOL shiftReportRights = [UserRights hasRights:UserRightShiftInOut];
    BOOL xReportRights = [UserRights hasRights:UserRightXReport];

    if (shiftReportRights && xReportRights) {
        self.btnShiftReport.enabled = YES;
        self.btnXReport.enabled = YES;
        [self showShiftReport];
    }
    else if (shiftReportRights && !xReportRights) {
        self.btnShiftReport.enabled = YES;
        self.btnXReport.enabled = NO;
        [self showShiftReport];
    }
    else if (!shiftReportRights && xReportRights) {
        self.btnShiftReport.enabled = NO;
        self.btnXReport.enabled = YES;
        [self getXReport];
    }
#else
    [self showShiftReport];
#endif
}

- (void)uploadNextInvoiceData
{
    if(self.nextIndex >= self.offlineInvoice.count)
    {
        [_activityIndicator hideActivityIndicator];;
        self.isZZPrint=FALSE;
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
    
    self.webServiceConnectionReportOffline = [self.webServiceConnectionReportOffline initWithAsyncRequest:KURL_INVOICE actionName:WSM_INVOICE_INSERT_LIST params:param asyncCompletionHandler:asyncCompletionHandler];
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
                    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                    invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                    invoiceDataT.isUpload = @(TRUE);
                    // [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                    [UpdateManager saveContext:privateManagedObjectContext];
                }
                else  if ([[response valueForKey:@"IsError"] intValue] == -2)
                {
                    InvoiceData_T *invoiceDataT = (self.offlineInvoice)[self.nextIndex];
                    NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
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





#pragma mark -
#pragma mark Generate XReport

- (void)addChart:(UIViewController *)chart toContainer:(UIView*)container tag:(int)tag {
    [[container viewWithTag:tag] removeFromSuperview];
    chart.view.tag = tag;
    chart.view.frame = container.bounds;
    chart.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [container addSubview:chart.view];
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

- (void)xReportResponse:(id)response error:(NSError *)error {
    _strTypeofChart = @"Dollorwise";
    [[self.view viewWithTag:101] setHidden:NO];
    [[self.view viewWithTag:102]setHidden:YES];
    ccBatchReport.view.hidden = YES;
    xccBatchReport.view.hidden = YES;
    _uvXReport.hidden=NO;
    _uvXRepBar.hidden=NO;
    _uvPaymentBarChart.hidden=NO;
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self.responseXArray removeAllObjects];
                self.responseXArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                NSMutableArray *arrayResponse = [[NSMutableArray alloc]initWithArray:self.responseXArray];
                
                OfflineReportCalculation *offlineReportCalculation = [[OfflineReportCalculation alloc]initWithArray:self.responseXArray withZid:(self.rmsDbController.globalDict)[@"ZId"]];
                [offlineReportCalculation updateReportWithOfflineDetail];
                
                self.responseXArray=[self.responseXArray mutableCopy];
                
                [_activityIndicator hideActivityIndicator];;
                
                ////  Get HTMl string From Array...
                NSString *strReport = [self printXFileReport:arrayResponse :@"X Report"];
                
                NSString *strReportForEmail = [self createHTMLFormateForEmail:strReport];
                /// Write Data On Document Directory.......
                NSData *data = [strReportForEmail dataUsingEncoding:NSUTF8StringEncoding];
                [self writeDataOnCacheDirectory:data];
                strReport =  [self createHTMLFormateForDisplayReportInWebView:strReport];
                ///// Load Data on Webview.....
                [PrintReport loadHTMLString:strReport baseURL:nil];
                PrintReport.hidden = NO;
                PrintReport.frame = CGRectMake(PrintReport.frame.origin.x, PrintReport.frame.origin.y, PrintReport.frame.size.width, PrintReport.frame.size.height);
                _uvsampleView.hidden=YES;
                
                // To Load Pie chart based on Department.
                objPieChart = [[XReportPieChart alloc] initWithNibName:@"XReportPieChart" bundle:nil];
                objPieChart.arrXRepDepartment = [[self.responseXArray.firstObject valueForKey:@"RptDepartment"] mutableCopy ];
                NSMutableDictionary *staticDataPiedict=[[NSMutableDictionary alloc]init];
                staticDataPiedict[@"Amount"] = @"0.00";
                staticDataPiedict[@"Count"] = @"0.00";
                staticDataPiedict[@"DepartId"] = @"0.00";
                staticDataPiedict[@"Descriptions"] = @"Not Available";
                staticDataPiedict[@"Per"] = @"100.0";
                if (objPieChart.arrXRepDepartment.count==0) {
                    [objPieChart.arrXRepDepartment addObject:staticDataPiedict];
                }
                NSMutableArray *arrTemp2 = [[NSMutableArray alloc] init];
                for (int i = 0 ; i < objPieChart.arrXRepDepartment.count; i++)
                {
                    NSMutableDictionary *arrTemp = (objPieChart.arrXRepDepartment)[i];
                    float percent = [[arrTemp valueForKey:@"Per" ] floatValue ];
                    if(percent != 0)
                    {
                        [arrTemp2 addObject:arrTemp];
                    }
                }
                objPieChart.objReportView = self;
                objPieChart.StrLableName=@"X Report";
                objPieChart.arrXRepDepartment = [arrTemp2 mutableCopy];
                if([_strTypeofChart isEqualToString:@"Dollorwise"])
                {
                    NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
                    lblChartValue.text = [self.crmController.currencyFormatter stringFromNumber:sum];
                }
                else
                    
                {
                    NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Per"];
                    lblChartValue.text = [NSString stringWithFormat:@"%.2f%%",sum.floatValue];
                }
                [self addChart:objPieChart toContainer:_uvXReport tag:20002];
                
                
                
                // To Load Bar chart based on customer visit.
                objBarChart = [[XReportBarChart alloc] initWithNibName:@"XReportBarChart" bundle:nil];
                //  objBarChart.view.frame=CGRectMake(0,20, objBarChart.view.frame.size.width, objBarChart.view.frame.size.height);
                objBarChart.arrXRepHours = [[self.responseXArray.firstObject valueForKey:@"RptHours"] mutableCopy ];
                NSMutableDictionary *staticDataBardict=[[NSMutableDictionary alloc]init];
                staticDataBardict[@"Amount"] = @"0.00";
                int decm=0;
                staticDataBardict[@"Count"] = @(decm);
                staticDataBardict[@"Hours"] = @"0.00";
                if (objBarChart.arrXRepHours.count==0) {
                    [ objBarChart.arrXRepHours addObject:staticDataBardict];
                }
                
                NSNumber *sum=[objBarChart.arrXRepHours valueForKeyPath:@"@sum.Count"];
                _lblCoustmerCount.text=[NSString stringWithFormat:@"%ld",(long)sum.integerValue];
                
                
                [self addChart:objBarChart toContainer:_uvXRepBar tag:20003];
                
                
                
                objPaymentPieChart = [[XReportpaymentPieChart alloc] initWithNibName:@"XReportpaymentPieChart" bundle:nil];
                objPaymentPieChart.arrXRepDepartment = [[self.responseXArray.firstObject valueForKey:@"RptTender"] mutableCopy ];
                NSMutableDictionary *staticDataPiedict1=[[NSMutableDictionary alloc]init];
                staticDataPiedict1[@"Amount"] = @"100.00";
                staticDataPiedict1[@"Count"] = @"0.00";
                staticDataPiedict1[@"TenderId"] = @"0.00";
                staticDataPiedict1[@"Descriptions"] = @"Not Available";
                if (objPaymentPieChart.arrXRepDepartment.count==0)
                {
                    [objPaymentPieChart.arrXRepDepartment addObject:staticDataPiedict1];
                }
                
                NSMutableArray *arrTemp21 = [[NSMutableArray alloc] init];
                for (int i = 0 ; i < objPaymentPieChart.arrXRepDepartment.count; i++)
                {
                    NSMutableDictionary *arrTempPayment = (objPaymentPieChart.arrXRepDepartment)[i];
                    float percent = [[arrTempPayment valueForKey:@"Amount" ] floatValue ];
                    if(percent != 0)
                    {
                        [arrTemp21 addObject:arrTempPayment];
                    }
                }
                objPaymentPieChart.objPayReportView = self;
                objPaymentPieChart.StrLableName=@"X Report";
                objPaymentPieChart.arrXRepDepartment = [arrTemp21 mutableCopy];
                if([_strTypeofChart isEqualToString:@"Dollorwise"])
                {
                    NSNumber *sum=[objPaymentPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
                    lblPaymentChartValue.text = [self.crmController.currencyFormatter stringFromNumber:sum];
                }
                else
                {
                    lblPaymentChartValue.text = @"100.00%";
                }
                [self addChart:objPaymentPieChart toContainer:_uvPaymentBarChart tag:20004];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];;
}

-(void)printZreport :(NSMutableArray *)responseArray
{
    [self.responseXArray removeAllObjects];
    self.responseXArray=[responseArray mutableCopy];
    [_activityIndicator hideActivityIndicator];
    
    ////  Get HTMl string From Array...
    NSString *strReport = [self printXFileReport:responseArray :@"Z Report"];
    
    NSString *strReportForEmail = [self createHTMLFormateForEmail:strReport];
    /// Write Data On Document Directory.......
    NSData *data = [strReportForEmail dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    strReport =  [self createHTMLFormateForDisplayReportInWebView:strReport];
	[PrintReport loadHTMLString:strReport baseURL:nil];
    _uvsampleView.hidden=YES;
	PrintReport.hidden = NO;
    PrintReport.frame = CGRectMake(PrintReport.frame.origin.x, PrintReport.frame.origin.y, PrintReport.frame.size.width, PrintReport.frame.size.height);
}

-(void)writeDataOnCacheDirectory :(NSData *)data
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

-(void)printZZreport :(NSMutableArray *)responseArray
{
    [self.responseXArray removeAllObjects];
    self.responseXArray=[responseArray mutableCopy];
    [_activityIndicator hideActivityIndicator];;
    
    ////  Get HTMl string From Array...
    NSString *strReport = [self printXFileReport:responseArray :@"ZZ Report"];
    
    NSString *strReportForEmail = [self createHTMLFormateForEmail:strReport];
    /// Write Data On Document Directory.......
    NSData *data = [strReportForEmail dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    strReport =  [self createHTMLFormateForDisplayReportInWebView:strReport];
	[PrintReport loadHTMLString:strReport baseURL:nil];
    _uvsampleView.hidden=YES;
	PrintReport.hidden = NO;
    PrintReport.frame = CGRectMake(PrintReport.frame.origin.x, PrintReport.frame.origin.y, PrintReport.frame.size.width, PrintReport.frame.size.height);
}
- (NSDate*) getDateFromJSON:(NSString *)dateString
{
    // Expect date in this format "/Date(1268123281843)/"
    NSInteger startPos = [dateString rangeOfString:@"("].location+1;
    NSInteger endPos = [dateString rangeOfString:@")"].location;
    NSRange range = NSMakeRange(startPos,endPos-startPos);
    unsigned long long milliseconds = [dateString substringWithRange:range].longLongValue;
    NSTimeInterval interval = milliseconds/1000;
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

-(NSDate*)jsonStringToNSDate :(NSString* ) string
{
    // Extract the numeric part of the date.  Dates should be in the format
    // "/Date(x)/", where x is a number.  This format is supplied automatically
    // by JSON serialisers in .NET.
    NSRange range = NSMakeRange(6, string.length - 8);
    NSString* substring = [string substringWithRange:range];
    
    // Have to use a number formatter to extract the value from the string into
    // a long long as the longLongValue method of the string doesn't seem to
    // return anything useful - it is always grossly incorrect.
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    NSNumber* milliseconds = [formatter numberFromString:substring];
    // NSTimeInterval is specified in seconds.  The value we get back from the
    // web service is specified in milliseconds.  Both values are since 1st Jan
    // 1970 (epoch).
    NSTimeInterval seconds = milliseconds.longLongValue / 1000;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

#pragma mark -
#pragma mark Create Html File

-(NSString *)printXFileReport :(NSMutableArray *)responseArray :(NSString *)reportName{
    XReport *xReporthtml = [[XReport alloc] initWithDictionary:responseArray.firstObject reportName:reportName isTips:self.tipSetting.boolValue];
    NSString *htmlData = xReporthtml.generateHtml;
    return htmlData;
}

- (void)PrintReport:(NSString *)portName portSettings:(NSString *)portSettings setReportObject:(NSMutableArray *)ReportData  ReportName:(NSString *)RptName
{
    if(ReportData.count>0)
    {
        xReport = [[XReport alloc] initWithDictionary:ReportData.firstObject reportName:RptName isTips:self.tipSetting.boolValue];
        [xReport printReportWithPort:portName portSettings:portSettings withDelegate:self];
        [_activityIndicator hideActivityIndicator];
    }
}

- (void)congigurePrintReport:(ReportPrint)_reportPrint
{
    reportPrint = _reportPrint;
}


#pragma mark - Printer Function Delegate

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    NSString *retryMessage = @"";
    switch (reportPrint) {
            
        case ShiftReport:
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
        default:
            break;
    }
    [self displayReportPrintRetryAlert:retryMessage];
}

-(void)displayReportPrintRetryAlert:(NSString *)message
{
    ReportViewController * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference printReport:nil];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)createPDFfromUIView:(UIView*)aView saveToDocumentsWithFileName:(NSString*)aFilename
{
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    PrintReport.frame = CGRectMake(PrintReport.frame.origin.x, PrintReport.frame.origin.y, PrintReport.scrollView.contentSize.width, PrintReport.scrollView.contentSize.height);
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, PrintReport.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
    
    [PrintReport.layer renderInContext:pdfContext];
    
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
    
    // Retrieves the document directories from the iOS device
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString* documentDirectory = documentDirectories.firstObject;
    documentDirectoryFilename= [documentDirectory stringByAppendingPathComponent:aFilename];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentDirectoryFilename]) {
		[[NSFileManager defaultManager] removeItemAtPath:documentDirectoryFilename error:nil];
	}
    
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:documentDirectoryFilename atomically:YES];
    /* //
     QLPreviewController *previewController = [[QLPreviewController alloc] init];
     
     //settnig the datasource property to self
     previewController.dataSource = self;
     
     //pusing the QLPreviewController to the navigation stack
     //[[self navigationController] pushViewController:previewController animated:YES];
     [pMain presentViewController:previewController animated:YES completion:nil];
     //remove the right bar print button
     [previewController.navigationItem setRightBarButtonItem:nil];
     [previewController release];*/
    
    NSURL *url = [NSURL fileURLWithPath:documentDirectoryFilename];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_pdfFile loadRequest:request];
    [_pdfFile setHidden:NO];
    PrintReport.frame = CGRectMake(PrintReport.frame.origin.x, PrintReport.frame.origin.y, 270.0 ,640.0);
}

#pragma mark -
#pragma mark WebView Delegate Method

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_btnPdf setEnabled:NO];
    [_btnPrint setEnabled:NO];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_btnPdf setEnabled:YES];
    [_btnPrint setEnabled:YES];
}


#pragma mark -
#pragma mark Create Pdf

-(IBAction)createEmailPDF:(id)sender
{
    [self.rmsDbController playButtonSound];
    if (self.shiftReportView.hidden == NO)
    {
        self.btnPreview.hidden = YES;
    }
    else{
        self.btnPreview.hidden = NO;
        
    }
    
    
    if (emailPdfPopOverController)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
    }
    _emailPdfView.hidden = NO;
    emailPdfViewController.view = _emailPdfView;
    
    // Present the view controller using the popover style.
    emailPdfViewController.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:emailPdfViewController animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    emailPdfPopOverController = [emailPdfViewController popoverPresentationController];
    emailPdfPopOverController.delegate = self;
    emailPdfViewController.preferredContentSize = CGSizeMake(emailPdfViewController.view.frame.size.width, emailPdfViewController.view.frame.size.height);
    emailPdfPopOverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    emailPdfPopOverController.sourceView = self.view;
    emailPdfPopOverController.sourceRect = CGRectMake(_pdfEmailBtn.frame.origin.x,
                                                      720,
                                                      _pdfEmailBtn.frame.size.width,
                                                      _pdfEmailBtn.frame.size.height);
}


-(IBAction)emailAction:(id)sender
{
    if (self.shiftReportView.hidden == NO)
    {
        emailView=YES;
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [shiftOpenClose emailButtonPressed];
    }
    else{
        [self EmailForReport];

    }
}
-(void)EmailForReport
{
    [self.rmsDbController playButtonSound];
    emailView=YES;
    [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSString *currentDateTime = [formatter stringFromDate:date];
    
    NSString *strsubjectLine = [NSString stringWithFormat:@"%@  %@  %@ Report",[self.rmsDbController.globalDict valueForKey:@"RegisterName"],currentDateTime,sPrint];
    
    NSData *myData = [NSData dataWithContentsOfFile:self.sourcePath];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    emailFromViewController.emailFromViewControllerDelegate = self;

    emailFromViewController.dictParameter =[[NSMutableDictionary alloc]init];
    (emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    (emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
    (emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
    (emailFromViewController.dictParameter)[@"postfile"] = myData;
    (emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
    
    [self.view addSubview:emailFromViewController.view];
}

-(void)didCancelEmail
{
    [emailFromViewController.view removeFromSuperview];
}


-(IBAction)pdfAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    /* if(![PrintReport isHidden]){
     NSString *fileName=@"PdfFromHtml.pdf";
     [self createPDFfromUIView:PrintReport saveToDocumentsWithFileName:fileName];
     }*/
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

#pragma mark -
#pragma mark Print Report Method

-(IBAction)printReport:(id)sender{
    [self.rmsDbController playButtonSound];
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([sPrint isEqualToString:@"X"])
        {
            [self congigurePrintReport:XReportPrint];
            [self PrintReport:portName portSettings:portSettings setReportObject:self.responseXArray ReportName:@"X Report"];
        }
        else if([sPrint isEqualToString:@"Z"])
        {
            [self congigurePrintReport:ZReportPrint];
            [self PrintReport:portName portSettings:portSettings setReportObject:self.responseXArray ReportName:@"Z Report"];
        }
        else if([sPrint isEqualToString:@"ZZ"])
        {
            [self congigurePrintReport:ZZReportPrint];
            [self PrintReport:portName portSettings:portSettings setReportObject:self.responseXArray ReportName:@"ZZ Report"];
        }
        else if([sPrint isEqualToString:@"Manager Z"])
        {
            [self congigurePrintReport:ManagerZReportPrint];
            [self PrintReport:portName portSettings:portSettings setReportObject:self.responseXArray ReportName:@"Manager Z"];
        }
        else if([sPrint isEqualToString:@"Manager ZZ"])
        {
            [self congigurePrintReport:ManagerZZReportPrint];
            [self PrintReport:portName portSettings:portSettings setReportObject:self.responseXArray ReportName:@"Manager ZZ"];
        }
        else if([sPrint isEqualToString:@"ShiftReport"])
        {
            [self congigurePrintReport:ShiftReport];
            [shiftOpenClose shiftPrint];
            [_activityIndicator hideActivityIndicator];
        }
        else
        {
            [_activityIndicator hideActivityIndicator];;
        }
    });
    // sPrint=@"";
}

#pragma mark -
#pragma mark Print Delegate Method
- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController {
    if(_bZexit==TRUE){
        exit(0);
    }
}

- (void)printInteractionControllerWillDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
}

#pragma mark -
#pragma mark Hide Report View

-(IBAction)close:(id)sender
{
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


-(void)requireZid
{
    ZRequiredViewController *objZReq = [[ZRequiredViewController alloc]initWithNibName:@"ZRequiredViewController" bundle:nil];
    objZReq.objReport=self;
    [self.view addSubview:objZReq.view];
    [objZReq.btnOpeningAmt setTitle:@"Closing Amount" forState:UIControlStateNormal];
    objZReq.btnOpeningAmt.tag = 1;
    objZReq.view.frame=CGRectMake(355.0, 20.0, 649.0, 660);
}

#pragma mark-
#pragma mark Z Report Generating

-(IBAction)generateZReport:(id)sender
{
    [self.rmsDbController playButtonSound];
    BOOL hasRights = [UserRights hasRights:UserRightZReportPrint];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to generate Z-Report. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    if (isZOrZZPrint) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Restart the application to check / print ZZ report again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    if([[self.rmsDbController.globalDict valueForKey:@"ZId"] integerValue ] == 0)
    {
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Restart the application to check / print ZZ report again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
    }
    else
    {
        [self setSelectButton:_btnZReport forView:_footerView];
        [self removeRapidCreditBatchSettleView];
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self setSelectButton:_btnXReport forView:_footerView];
        };
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            _uvXReport.hidden=YES;
            _uvXRepBar.hidden=YES;
            _uvPaymentBarChart.hidden=YES;
            [self.rmsDbController playButtonSound];
            PrintReport.hidden=YES;
            sPrint=@"Z";
            self.crmController.pReportView=self;
            self.crmController.bZexit=TRUE;
            self.isZZPrint=FALSE;
            [self checkShiftEmployee];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Do you want to proceed with Z report?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

-(void)checkShiftEmployee
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkShiftEmployeeResponse:response error:error];
        });
    };
    
    self.employeeShiftOpenCheckWC = [self.employeeShiftOpenCheckWC initWithRequest:KURL actionName:WSM_EMPLOYEE_SHIFT_OPEN_CHECK params:dict completionHandler:completionHandler];
}

-(void)checkShiftEmployeeResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                shift = [[ShiftInOutPopOverVC alloc]initWithNibName:@"ShiftInOutPopOverVC" bundle:nil];
                shift.shiftInOutPopOverDelegate = self;
                shift.strType = @"Shift-Close";
                shift.strZprint = @"Z print";
                if (self.isZZPrint) {
                    shift.strReportType = @"ZZ";
                }
                else
                {
                    shift.strReportType = @"Z";
                    
                }
                [self.view addSubview:shift.view];
                _btnShiftPrint.userInteractionEnabled = YES;
                _btnShiftPrint.enabled = YES;
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                _btnShiftPrint.userInteractionEnabled = NO;
                _btnShiftPrint.enabled = NO;
                [_btnShiftPrint setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [self getZReport];
            }
            else
            {
                
            }
        }
    }
}

-(void)printShiftReport
{
    cashInView.view.hidden = YES;
    [self getZReport];
}

-(void)getZReport
{

    sPrint=@"Z";
    _btnDollorView.selected = YES;
    _btnPrctView.selected = NO;
    _ccBatch.selected = NO;
    _ccBatch.hidden = YES;
    _settleCC.hidden = YES;
    _cardSattlementView.hidden = YES;
    self.shiftReportView.hidden = YES;
    
    [[self.view viewWithTag:101] setHidden:NO];
    [[self.view viewWithTag:102]setHidden:YES];
    ccBatchReport.view.hidden = YES;
    xccBatchReport.view.hidden = YES;
    if([(self.rmsDbController.globalDict)[@"ZRequired"]  boolValue])
    {
        [self requireZid];
    }
    else if(![(self.rmsDbController.globalDict)[@"ZRequired"] boolValue])
    {
        [self ZClosingDetailOperationReport:@"0"];
    }
}

-(void)ZClosingDetailOperationReport:(NSString *)strClosingAmt
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"Amount"] = strClosingAmt;
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSString *strDate=[NSString stringWithFormat:@"%@",destinationDate];
    
    dict[@"Datetime"] = strDate;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self zClosingNoReqDetailResponse:response error:error];
    };
    
    self.zClosingNoReqDetailWC = [self.zClosingNoReqDetailWC initWithRequest:KURL actionName:WSM_Z_CLOSING_DETAIL params:dict completionHandler:completionHandler];
}

- (void)zClosingNoReqDetailResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self getZReportData];
            }
            else
            {
                [_activityIndicator hideActivityIndicator];;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Restart the application to check / print ZZ report again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}


-(void)getZReportData
{
    NSMutableArray *arrayMain =[[NSMutableArray alloc]init];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"Amount"] = @"0";
    dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"] ;
    
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSString *strDate=[NSString stringWithFormat:@"%@",destinationDate];
    
    dict[@"Datetime"] = strDate;
    [arrayMain addObject:dict];
    
    NSMutableDictionary *dictMain =[[NSMutableDictionary alloc]init];
    dictMain[@"ZRequestData"] = dict;

    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self ZReportResponse:response error:error];
        });
    };
    
    self.zReportGenerateWC = [self.zReportGenerateWC initWithRequest:KURL actionName:WSM_Z_REPORT params:dictMain completionHandler:completionHandler];
}
#pragma mark -
#pragma mark Generate XReport

- (void)updatePaymentTypeWithOfflineData:(NSMutableArray *)zReportArray offlinePaymentArray:(NSMutableArray *)offlinePaymentArray
{
    NSMutableArray *zOnlinePaymentArray = [zReportArray.firstObject valueForKey:@"RptTender"];
    
    if (offlinePaymentArray.count > 0)
    {
        for (int i=0; i < zOnlinePaymentArray.count; i++)
        {
            NSMutableDictionary *zOfflineDictionary = zOnlinePaymentArray[i];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"PayId == %@", [zOnlinePaymentArray[i]valueForKey:@"TenderId"]];
            
            NSMutableArray *paymentResultArray = [[offlinePaymentArray filteredArrayUsingPredicate:predicate] mutableCopy];
            NSNumber *paymentResultOfflineSum = 0;
            if(paymentResultArray.count>0)
            {
                paymentResultOfflineSum =[paymentResultArray valueForKeyPath:@"@sum.BillAmount"];
                float amount = [[zOnlinePaymentArray[i]valueForKey:@"Amount"] floatValue];
                amount = amount + paymentResultOfflineSum.floatValue;
                
                NSInteger tenderCount = [[zOnlinePaymentArray[i]valueForKey:@"Count"] integerValue] + paymentResultArray.count;
                
                zOfflineDictionary[@"Amount"] = @(amount);
                zOfflineDictionary[@"Count"] = [NSString stringWithFormat:@"%ld",(long)tenderCount];
            }
        }
    }
}

- (void)updateMainTenderValueWithOfflineData:(NSMutableArray *)zReportArray offlinePaymentArray:(NSMutableArray *)offlinePaymentArray
{
    NSMutableArray *zOnlineMainArray = [zReportArray.firstObject valueForKey:@"RptMain"];
    if (zOnlineMainArray.count > 0)
    {
        NSMutableDictionary *zOnlineMainDictionary = zOnlineMainArray.firstObject;
        
        // update gross sales with offline data....
        CGFloat grossSales =  [self updateTotalSalesPriceWithofflineData:offlinePaymentArray withOnlinePaymentDictionary:zOnlineMainDictionary];
        
        // update collected tax with offline data....
        CGFloat collectedTax = [self updateCollectedTaxWithofflineData:[self fetchTaxDataFromInvoiceTable] withOnlinePaymentDictionary:zOnlineMainDictionary];
        
        // update sales for with offline data...
        CGFloat offlineSale = grossSales - collectedTax;
        [self updateSalesWithOfflineSales:offlineSale withOnlineMainDictionary:zOnlineMainDictionary];
        
        //hiten
        
        
        // for Tax
        NSMutableArray *arrayofflineTextDetail = [self fetchTaxDataFromInvoiceTable];
        
        [self checkAndAddNewTextFromOfflineArray:zReportArray offlineTaxArray:arrayofflineTextDetail];
        
        [self updateNameinTaxDictionary:zReportArray];
        
        [self updateTextTypeWithOfflineData:zReportArray offlinePaymentArray:arrayofflineTextDetail];
        
        // For Dept
        
        NSMutableArray *offlineItemsArray = [self fetchItemsFromInvoiceTable];
        
        [self updateDeptAmountWithOfflineData:zReportArray offlineDeptArray:offlineItemsArray];
        
        //hiten
    }
}
-(NSMutableArray *)fetchItemsFromInvoiceTable
{
    NSMutableArray *zOfflineItemArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"zId==%@ AND isUpload==%@",(self.rmsDbController.globalDict)[@"ZId"],@(FALSE)];
    
    fetchRequest.predicate = predicate;
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(object.count>0)
    {
        for (InvoiceData_T *invoice in object)
        {
            if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject] count]>0)
            {
                NSMutableArray *archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject];
                
                for(int i=0;i<archiveArray.count;i++){
                    
                    [zOfflineItemArray addObject:archiveArray[i]];
                }
            }
            
        }
    }
    return zOfflineItemArray;
}

#pragma mark Generate XReport

- (void)updateDeptAmountWithOfflineData:(NSMutableArray *)zReportArray offlineDeptArray:(NSMutableArray *)offlinePaymentArray
{
    NSMutableArray *zOnlineDeptArray = [zReportArray.firstObject valueForKey:@"RptDepartment"];
    
    if (offlinePaymentArray.count > 0)
    {
        for (int i=0; i < zOnlineDeptArray.count; i++)
        {
            NSNumber *deptID = @([[zOnlineDeptArray[i]valueForKey:@"DepartId"]integerValue]);
            
            NSString *strDeptID = [NSString stringWithFormat:@"%@",[zOnlineDeptArray[i]valueForKey:@"DepartId"]];
            
            NSMutableDictionary *zOfflineDictionary = zOnlineDeptArray[i];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(departId == %@ OR departId == %@)",strDeptID, deptID];
            
            NSMutableArray *paymentResultArray = [[offlinePaymentArray filteredArrayUsingPredicate:predicate] mutableCopy];
            NSNumber *paymentResultOfflineSum = 0;
            if(paymentResultArray.count>0)
            {
                paymentResultOfflineSum =[paymentResultArray valueForKeyPath:@"@sum.ItemBasicAmount"];
                float amount = [[zOnlineDeptArray[i]valueForKey:@"Amount"] floatValue];
                amount = amount + paymentResultOfflineSum.floatValue;
                
                NSInteger tenderCount = [[zOnlineDeptArray[i]valueForKey:@"Count"] integerValue] + paymentResultArray.count;
                
                zOfflineDictionary[@"Amount"] = @(amount);
                zOfflineDictionary[@"Count"] = [NSString stringWithFormat:@"%ld",(long)tenderCount];
            }
        }
    }
}

-(void)checkAndAddNewTextFromOfflineArray:(NSMutableArray *)zReportArray offlineTaxArray:(NSMutableArray *)parrayTextDetail{
    
    NSMutableArray *zOnlinePaymentArray = [zReportArray.firstObject valueForKey:@"RptTax"];
    
    for (int i=0; i < parrayTextDetail.count; i++)
    {
        NSMutableDictionary *dictTax;
        NSMutableDictionary *zOfflineDictionary = parrayTextDetail[i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TaxId == %@", [zOfflineDictionary valueForKey:@"TaxId"]];
        
        NSMutableArray *paymentResultArray = [[zOnlinePaymentArray filteredArrayUsingPredicate:predicate] mutableCopy];
        
        if(paymentResultArray.count==0)
        {
            dictTax = [[NSMutableDictionary alloc]init];
            dictTax[@"Amount"] = @"0.00";
            dictTax[@"Descriptions"] = @"";
            dictTax[@"TaxId"] = [zOfflineDictionary valueForKey:@"TaxId"];
            [zOnlinePaymentArray addObject:dictTax];
        }
        
    }
    
}
-(void)updateNameinTaxDictionary:(NSMutableArray *)zReportArray{
    
    NSMutableArray *zOnlinePaymentArray = [zReportArray.firstObject valueForKey:@"RptTax"];
    
    for(int i=0;i<zOnlinePaymentArray.count;i++)
    {
        NSMutableDictionary *dict = zOnlinePaymentArray[i];
        
        if([[dict valueForKey:@"Descriptions"] isEqualToString:@""])
        {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
            fetchRequest.entity = entity;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId == %@", [dict valueForKey:@"TaxId"]];
            
            fetchRequest.predicate = predicate;
            
            NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
            
            if (resultSet.count > 0)
            {
                for (TaxMaster *txMaster in resultSet) {
                    
                    dict[@"Descriptions"] = txMaster.taxNAME;
                    zOnlinePaymentArray[i] = dict;
                }
                
            }
            
        }
        
    }
    
}


-(void)updateZReportDetailWithOfflineData :(NSMutableArray *)zReportArray
{
    NSMutableArray *offlinePaymentArray = [self fetchPaymentDataFromInvoiceTable];
    
    /// update payment type detail with offline data.....
    [self updatePaymentTypeWithOfflineData:zReportArray offlinePaymentArray:offlinePaymentArray];
    
    /// update main tender data with offline data.......
    [self updateMainTenderValueWithOfflineData:zReportArray offlinePaymentArray:offlinePaymentArray];

}

- (void)updateTextTypeWithOfflineData:(NSMutableArray *)zReportArray offlinePaymentArray:(NSMutableArray *)parrayTextDetail
{
    NSMutableArray *zOnlinePaymentArray = [zReportArray.firstObject valueForKey:@"RptTax"];
    
    if (parrayTextDetail.count > 0)
    {
        for (int i=0; i < zOnlinePaymentArray.count; i++)
        {
            NSMutableDictionary *zOfflineDictionary = zOnlinePaymentArray[i];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TaxId == %@", [zOnlinePaymentArray[i]valueForKey:@"TaxId"]];
            
            NSMutableArray *paymentResultArray = [[parrayTextDetail filteredArrayUsingPredicate:predicate] mutableCopy];
            NSNumber *paymentResultOfflineSum = 0;
            if(paymentResultArray.count>0)
            {
                paymentResultOfflineSum =[paymentResultArray valueForKeyPath:@"@sum.ItemTaxAmount"];
                float amount = [[zOnlinePaymentArray[i]valueForKey:@"Amount"] floatValue];
                amount = amount + paymentResultOfflineSum.floatValue;
                
                zOfflineDictionary[@"Amount"] = @(amount);
                
            }
        }
    }
}
-(void)updateSalesWithOfflineSales :(CGFloat )offlineSales withOnlineMainDictionary:(NSMutableDictionary *)zOnlineMainDictionary
{
    NSMutableArray *offlineSalesArray = [self fetchItemFromInvoiceTable];
    
    if (offlineSalesArray.count == 0) {
        return;
    }
    
    NSNumber *itemTotalOfflineSum = 0;
    NSNumber *itemTotalOfflineExtrachargeSum = 0;
    
    NSNumber *itemTotalOfflineCheckcashSum = 0;
    NSNumber *itemTotalOfflineExtrachargeCheckcaseSum = 0;
    
    NSPredicate *isCheckcashFlasePredicate = [NSPredicate predicateWithFormat:@"isCheckCash == %@ OR isCheckCash == %@", @"0",@(0)];
    NSArray *isCheckcashFlaseArray = [offlineSalesArray filteredArrayUsingPredicate:isCheckcashFlasePredicate];
    if (isCheckcashFlaseArray.count > 0)
    {
        NSPredicate *isGreaterItemAmountPredicate = [NSPredicate predicateWithFormat:@"(ItemAmount > %@) AND (isDeduct == %@ OR isDeduct == %@)",@"0.00",@"0",@(0)];
        isCheckcashFlaseArray = [isCheckcashFlaseArray filteredArrayUsingPredicate:isGreaterItemAmountPredicate];
 
        if (isCheckcashFlaseArray.count > 0)
        {
            itemTotalOfflineSum = [isCheckcashFlaseArray valueForKeyPath:@"@sum.ItemAmount"];
            itemTotalOfflineExtrachargeSum = [isCheckcashFlaseArray valueForKeyPath:@"@sum.ExtraCharge"];
        }
    }
    
    
    
    NSPredicate *isCheckcashTruePredicate = [NSPredicate predicateWithFormat:@"isCheckCash == %@ OR isCheckCash == %@", @"0",@(0)];
    NSArray *isCheckcashTrueArray = [offlineSalesArray filteredArrayUsingPredicate:isCheckcashTruePredicate];
    
    if (isCheckcashTrueArray.count > 0)
    {
        NSPredicate *isGreaterItemAmountPredicate = [NSPredicate predicateWithFormat:@"(ItemAmount > %@) AND (isDeduct == %@ OR isDeduct == %@)",@"0.00",@"0",@(0)];
        isCheckcashTrueArray = [isCheckcashTrueArray filteredArrayUsingPredicate:isGreaterItemAmountPredicate];
        if (isCheckcashTrueArray.count > 0)
        {
            itemTotalOfflineCheckcashSum = [isCheckcashTrueArray valueForKeyPath:@"@sum.CheckCashAmount"];
            itemTotalOfflineExtrachargeCheckcaseSum = [isCheckcashTrueArray valueForKeyPath:@"@sum.ExtraCharge"];
        }
    }
    
    CGFloat salesTotalOnlineAndOffline = [[zOnlineMainDictionary valueForKey:@"Sales"] floatValue] + itemTotalOfflineSum.floatValue + itemTotalOfflineExtrachargeSum.floatValue + itemTotalOfflineCheckcashSum.floatValue + itemTotalOfflineExtrachargeCheckcaseSum.floatValue;
    
    
    zOnlineMainDictionary[@"Sales"] = @(salesTotalOnlineAndOffline);
}

-(CGFloat )updateCollectedTaxWithofflineData:(NSMutableArray *)offlineTaxArray withOnlinePaymentDictionary:(NSMutableDictionary *)zOnlineMainDictionary
{
    NSNumber *taxOfflineSum = 0;
    CGFloat amount =0.0;
    
    if (offlineTaxArray.count > 0)
    {
        taxOfflineSum =[offlineTaxArray valueForKeyPath:@"@sum.ItemTaxAmount"];
    }
    amount = [[zOnlineMainDictionary valueForKey:@"CollectTax"] floatValue];
    amount = amount + taxOfflineSum.floatValue;
    zOnlineMainDictionary[@"CollectTax"] = @(amount);
    
    return taxOfflineSum.floatValue;
}

-(CGFloat)updateTotalSalesPriceWithofflineData:(NSMutableArray *)offlinePaymentArray withOnlinePaymentDictionary:(NSMutableDictionary *)zOnlineMainDictionary
{
    NSNumber *salesPriceOfflineSum = 0;
    NSNumber *cahngeOfflineSum = 0;

    if (offlinePaymentArray.count > 0)
    {
        salesPriceOfflineSum =[offlinePaymentArray valueForKeyPath:@"@sum.BillAmount"];
        cahngeOfflineSum = [offlinePaymentArray valueForKeyPath:@"@sum.ReturnAmount"]; //ReturnAmount;
        salesPriceOfflineSum = @(salesPriceOfflineSum.floatValue - cahngeOfflineSum.floatValue);
    }
    float amount = [[zOnlineMainDictionary valueForKey:@"TotalSales"] floatValue];
    amount = amount + salesPriceOfflineSum.floatValue;
    zOnlineMainDictionary[@"TotalSales"] = @(amount);
    
    float change = [[zOnlineMainDictionary valueForKey:@"TotalChange"] floatValue];
    change = change + cahngeOfflineSum.floatValue;
    zOnlineMainDictionary[@"TotalChange"] = @(change);
   // TotalChange
    return amount;

}
-(NSMutableArray *)fetchPaymentDataFromInvoiceTable
{
    NSMutableArray *zOfflineArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"zId==%@ AND isUpload==%@",(self.rmsDbController.globalDict)[@"ZId"],@(FALSE)];
    fetchRequest.predicate = predicate;
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(object.count>0)
    {
        for (InvoiceData_T *invoice in object)
        {
            if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoicePaymentData] firstObject] count]>0)
            {
                NSMutableArray *archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoicePaymentData] firstObject];
                for(int i=0;i<archiveArray.count;i++){
                    
                    [zOfflineArray addObject:archiveArray[i]];
                }
            }
            
        }
    }
    return zOfflineArray;
}
-(NSMutableArray *)fetchItemFromInvoiceTable
{
    NSMutableArray *zOfflineArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"zId==%@ AND isUpload==%@",(self.rmsDbController.globalDict)[@"ZId"],@(FALSE)];
    fetchRequest.predicate = predicate;
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(object.count>0)
    {
        for (InvoiceData_T *invoice in object)
        {
            if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject] count]>0)
            {
                NSMutableArray *archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject];
                for(int i=0;i<archiveArray.count;i++){
                    
                    [zOfflineArray addObject:archiveArray[i]];
                }
            }
        }
    }
    return zOfflineArray;
}


-(NSMutableArray *)fetchTaxDataFromInvoiceTable
{
    NSMutableArray *zOfflineArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"zId==%@ AND isUpload==%@",(self.rmsDbController.globalDict)[@"ZId"],@(FALSE)];
    fetchRequest.predicate = predicate;
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(object.count>0)
    {
        for (InvoiceData_T *invoice in object)
        {
            if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoicePaymentData] firstObject] count]>0)
            {
                NSMutableArray *archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject];
                for(int i=0;i<archiveArray.count;i++){
                    
                    NSMutableArray * offlineTaxArray = [archiveArray[i] valueForKey:@"ItemTaxDetail"];
                    if ([offlineTaxArray isKindOfClass:[NSMutableArray class]])
                    {
                        if (offlineTaxArray.count > 0)
                        {
                            for(int j=0;j<offlineTaxArray.count;j++)
                            {
                                [zOfflineArray addObject:offlineTaxArray[j]];
                            }
                        }
                    }
                }
            }
        }
    }
    return zOfflineArray;
}


- (void)ZReportResponse:(id)response error:(NSError *)error
{
    _strTypeofChart = @"Dollorwise";
    _uvXReport.hidden=NO;
    _uvXRepBar.hidden=NO;
    _uvPaymentBarChart.hidden=NO;
    [_activityIndicator hideActivityIndicator];;
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                responseZArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                OfflineReportCalculation *offlineReportCalculation = [[OfflineReportCalculation alloc]initWithArray:responseZArray withZid:(self.rmsDbController.globalDict)[@"ZId"]];
                [offlineReportCalculation updateReportWithOfflineDetail];
                
                //   [self updateZReportDetailWithOfflineData:responseZArray];
                self.responseXArray=[responseZArray mutableCopy];
                [self printZreport:responseZArray];
                isZOrZZPrint = TRUE;
                isZPrint = TRUE;
                self.zReportPrintArray = [responseZArray mutableCopy];
                
                // To Load Pie chart based on Department.
                objPieChart = [[XReportPieChart alloc] initWithNibName:@"XReportPieChart" bundle:nil];
                objPieChart.arrXRepDepartment = [[responseZArray.firstObject valueForKey:@"RptDepartment"] mutableCopy ];
                NSMutableDictionary *staticDataPiedict=[[NSMutableDictionary alloc]init];
                staticDataPiedict[@"Amount"] = @"0.00";
                staticDataPiedict[@"Count"] = @"0.00";
                staticDataPiedict[@"DepartId"] = @"0.00";
                staticDataPiedict[@"Descriptions"] = @"Not Available";
                staticDataPiedict[@"Per"] = @"100.0";
                if (objPieChart.arrXRepDepartment.count==0)
                {
                    [objPieChart.arrXRepDepartment addObject:staticDataPiedict];
                }
                
                NSMutableArray *arrTemp2 = [[NSMutableArray alloc] init];
                for (int i = 0 ; i < objPieChart.arrXRepDepartment.count; i++)
                {
                    NSMutableDictionary *arrTemp = (objPieChart.arrXRepDepartment)[i];
                    float percent = [[arrTemp valueForKey:@"Per" ] floatValue ];
                    if(percent != 0)
                    {
                        [arrTemp2 addObject:arrTemp];
                    }
                }
                objPieChart.objReportView=self;
                //            objPieChart.view.tag=20002;
                objPieChart.StrLableName=@"Z Report";
                objPieChart.arrXRepDepartment = [arrTemp2 mutableCopy];
                
                if([_strTypeofChart isEqualToString:@"Dollorwise"])
                {
                    NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
                    lblChartValue.text = [self.crmController.currencyFormatter stringFromNumber:sum];
                }
                else
                    
                {
                    NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Per"];
                    lblChartValue.text = [NSString stringWithFormat:@"%.2f%%",sum.floatValue];
                }
                //            [uvXReport addSubview:objPieChart.view];
                [self addChart:objPieChart toContainer:_uvXReport tag:20002];
                
                // To Load Bar chart based on customer visit.
                objBarChart = [[XReportBarChart alloc] initWithNibName:@"XReportBarChart" bundle:nil];
                objBarChart.arrXRepHours = [[responseZArray.firstObject valueForKey:@"RptHours"] mutableCopy ];
                NSMutableDictionary *staticDataBardict=[[NSMutableDictionary alloc]init];
                staticDataBardict[@"Amount"] = @"0.00";
                int decm=0;
                staticDataBardict[@"Count"] = @(decm);
                staticDataBardict[@"Hours"] = @"0.00";
                if (objBarChart.arrXRepHours.count==0) {
                    [ objBarChart.arrXRepHours addObject:staticDataBardict];
                }
                //objBarChart.view.tag=20003;
                NSNumber *sum=[objBarChart.arrXRepHours valueForKeyPath:@"@sum.Count"];
                _lblCoustmerCount.text=[NSString stringWithFormat:@"%ld",(long)sum.integerValue];
                //[uvXRepBar addSubview:objBarChart.view];
                [self addChart:objBarChart toContainer:_uvXRepBar tag:20003];
                
                // Payment Pie Chart
                objPaymentPieChart = [[XReportpaymentPieChart alloc] initWithNibName:@"XReportpaymentPieChart" bundle:nil];
                objPaymentPieChart.arrXRepDepartment = [[responseZArray.firstObject valueForKey:@"RptTender"] mutableCopy ];
                NSMutableDictionary *staticDataPiedict1=[[NSMutableDictionary alloc]init];
                staticDataPiedict1[@"Amount"] = @"100.00";
                staticDataPiedict1[@"Count"] = @"0.00";
                staticDataPiedict1[@"TenderId"] = @"0.00";
                staticDataPiedict1[@"Descriptions"] = @"Not Available";
                if (objPaymentPieChart.arrXRepDepartment.count==0)
                {
                    [objPaymentPieChart.arrXRepDepartment addObject:staticDataPiedict1];
                }
                
                NSMutableArray *arrTemp21 = [[NSMutableArray alloc] init];
                for (int i = 0 ; i < objPaymentPieChart.arrXRepDepartment.count; i++)
                {
                    NSMutableDictionary *arrTempPayment = (objPaymentPieChart.arrXRepDepartment)[i];
                    float percent = [[arrTempPayment valueForKey:@"Amount" ] floatValue ];
                    if(percent != 0)
                    {
                        [arrTemp21 addObject:arrTempPayment];
                    }
                }
                objPaymentPieChart.objPayReportView = self;
                objPaymentPieChart.StrLableName=@"Z Report";
                objPaymentPieChart.arrXRepDepartment = [arrTemp21 mutableCopy];
                if([_strTypeofChart isEqualToString:@"Dollorwise"])
                {
                    NSNumber *sum=[objPaymentPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
                    
                    lblPaymentChartValue.text = [self.crmController.currencyFormatter stringFromNumber:sum];
                }
                else
                {
                    lblPaymentChartValue.text = @"100.00%";
                }
                //objPaymentPieChart.view.tag=20004;
                //            [uvPaymentBarChart addSubview:objPaymentPieChart.view];
                [self addChart:objPaymentPieChart toContainer:_uvPaymentBarChart tag:20004];
                
                
                if(self.isZZPrint)
                {
                    isZPrint = FALSE;
                    sPrint=@"ZZ";
                    [self getZZReportData];
                }
                else
                {
                    _uvZReportInfo.hidden = NO;
                }
                /* NSString *portName     = @"";
                 NSString *portSettings = @"";
                 [self SetPortInfo];
                 
                 portName     = [RcrController getPortName];
                 portSettings = [RcrController getPortSettings];
                 
                 [self PrintReport:portName portSettings:portSettings setReportObject:responseZArray];*/
                self.ZidForZZ = (self.rmsDbController.globalDict)[@"ZId"];
                NSArray *rptZDetail = [[responseZArray.firstObject valueForKey:@"RptZDetail"] mutableCopy];
                if (rptZDetail.count > 0 && [rptZDetail isKindOfClass:[NSArray class]]) {
                    NSString *zID = [rptZDetail.firstObject[@"ZId"] stringValue];
                    if ([zID isEqualToString:@"0"] || zID == nil) {
                        [self showRestartAppAlertAndSetDefultZID];
                        return;
                    }
                    [self.rmsDbController.globalDict removeObjectForKey:@"ZId"];
                    (self.rmsDbController.globalDict)[@"ZId"] = zID;
                    [self.updateManager updateZidWithRegisrterInfo:zID withContext:self.managedObjectContext];
                }
                else
                {
                    [self showRestartAppAlertAndSetDefultZID];
                }
            }
        }
    }
}

-(void)showRestartAppAlertAndSetDefultZID
{
    [self.rmsDbController.globalDict removeObjectForKey:@"ZId"];
    (self.rmsDbController.globalDict)[@"ZId"] = @"0";
    [self.updateManager updateZidWithRegisrterInfo:@"0" withContext:self.managedObjectContext];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please restart the application or contact to RapiRMS" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

-(IBAction)shiftReportPrint:(id)sender
{
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
    [shift LastEmpoyeeShiftWithZid:self.ZidForZZ];
}

-(IBAction)ZReportPrint:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightZReportPrint];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to print Z-Report. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self congigurePrintReport:ZReportPrint];
        [self PrintReport:portName portSettings:portSettings setReportObject:self.zReportPrintArray ReportName:@"Z"];
    });
}

-(IBAction)ZZReportPrint:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightZZReportPrint];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to print ZZ-Report. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self congigurePrintReport:ZZReportPrint];
        [self PrintReport:portName portSettings:portSettings setReportObject:self.responseXArray ReportName:@"ZZ"];
    });
}
-(IBAction)ZZPopoverClose:(id)sender
{
    _uvZZReportInfo.hidden = YES;
}
-(IBAction)ZPopoverClose:(id)sender
{
    _uvZReportInfo.hidden = YES;
}
#pragma mark -
#pragma mark Manager Report view Method
-(IBAction)managerReportClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self setSelectButton:(UIButton *)sender forView:_footerView];
    ccBatchReport.view.hidden = YES;
    [self.view bringSubviewToFront:_managerReportView];
    _managerReportView.hidden = NO;
    _ccBatchButton.selected = NO;
   // self.shiftReportView.hidden = YES;

}

-(IBAction)cancelManagerViewClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self setSelectButton:nil forView:_footerView];
    _managerReportView.hidden = YES;
}

#pragma mark -
#pragma mark Manager view Method
-(IBAction)showManagerView:(id)sender{
    [self.rmsDbController playButtonSound];
    BOOL hasRights = [UserRights hasRights:UserRightManagerZReport];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to generate Manager Z-Report. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    [self getManagerZReports];
    _managerReportView.hidden = YES;
    [self.crmController UserTouchEnable];
    strSelectButton=@"ManageZ";
    _ccBatchButton.selected = NO;
    self.shiftReportView.hidden = YES;
}

-(IBAction)showShiftReportForManagerView:(id)sender
{
#ifdef CheckRights
    BOOL hasRights = [UserRights hasRights:UserRightShiftInOut];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to generate Shift Report. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
#endif
    _managerReportView.hidden = YES;
    [self setSelectButton:(UIButton *)sender forView:_footerView];
    [[self.view viewWithTag:101] setHidden:YES];
    [[self.view viewWithTag:102]setHidden:YES];
    [self showShiftReport];
}

-(IBAction)closeMangerView:(id)sender{
    
    [PrintReport setHidden:YES];
    [[self.view viewWithTag:102] setHidden:YES];
    
}

#pragma mark -
#pragma mark Manager view Method
-(IBAction)showZZManagerView:(id)sender
{
    [self.rmsDbController playButtonSound];
    BOOL hasRights = [UserRights hasRights:UserRightManagerZZReport];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to generate Manager ZZ-Report. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    [self getManagerZZReports];
    _managerReportView.hidden = YES;
    strSelectButton=@"ManageZZ";
    [self.crmController UserTouchEnable];
    
    self.crmController.singleTap1.enabled=NO;
    //self.crmController=(RcrController *)[[UIApplication sharedApplication]delegate];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    _ccBatchButton.selected = NO;
    self.shiftReportView.hidden = YES;
}

-(void)getManagerZZReports
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *dictMain =[[NSMutableDictionary alloc]init];
    
    NSDate *date =  [NSDate date];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy";
    NSString *stringFromDate=[dateFormatter stringFromDate:date];
    _lblMangerDate.text=[NSString stringWithFormat:@"%@",stringFromDate];
    managerDate = date;
    dictMain[@"ZZDate"] = _lblMangerDate.text;
    dictMain[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self zzManagerDetailResponse:response error:error];
        });
    };
    
    self.zZManagerListDataWC = [self.zZManagerListDataWC initWithRequest:KURL actionName:WSM_ZZ_MANAGER_LIST_DATA params:dictMain completionHandler:completionHandler];
}

- (void)zzManagerDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];;
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            self.arrayMangerReportList = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            
            [PrintReport setHidden:YES];
            
            [[self.view viewWithTag:101] setHidden:YES];
            [[self.view viewWithTag:102]setHidden:NO];
            ccBatchReport.view.hidden = YES;
            xccBatchReport.view.hidden = YES;
            
            [self.view bringSubviewToFront:[self.view viewWithTag:102]];
            
            if (_arrayMangerReportList.count > 0) {
                [ PrintReport setHidden:YES];
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                [self getZZManagerData:_arrayMangerReportList.firstObject];
            }
            self.lblReportCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_arrayMangerReportList.count];
            self.selectedIndexPath = 0;
            [_tblManagerReportList reloadData];
        }
    }
}

-(IBAction)openDatePicker:(id)sender
{
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 300, 70)];
    datePicker.date = managerDate;
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.backgroundColor = [UIColor whiteColor];
    
    
    datepickerBoderView = [[UIView alloc]initWithFrame:CGRectMake(65, 48, 300, 162)];
    datepickerBoderView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    datepickerBoderView.layer.borderWidth = 0.5;
    datepickerBoderView.backgroundColor = [UIColor whiteColor];
    
    [datepickerBoderView addSubview:datePicker];
    
    [[self.view viewWithTag:102] addSubview:datepickerBoderView];
    
    [datePicker addTarget:self action:@selector(updateLabelFromPicker) forControlEvents:UIControlEventValueChanged];
}
- (void)updateLabelFromPicker
{
    NSDate *date =  datePicker.date;
    if ([strSelectButton isEqualToString:@"ManageZZ" ])
    {
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"yyyy";
        NSString *stringFromDate=[dateFormatter stringFromDate:date];
        _lblMangerDate.text=[NSString stringWithFormat:@"%@",stringFromDate];
        datePicker.date = datePicker.date;
        [datePicker removeFromSuperview];
        [datepickerBoderView removeFromSuperview];
        managerDate = datePicker.date;

        NSMutableDictionary *dictMain =[[NSMutableDictionary alloc]init];
        dictMain[@"ZZDate"] = _lblMangerDate.text;
        dictMain[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self zzManagerDetailResponse:response error:error];
            });
        };
        
        self.zZManagerListDataWC2 = [self.zZManagerListDataWC2 initWithRequest:KURL actionName:WSM_ZZ_MANAGER_LIST_DATA params:dictMain completionHandler:completionHandler];
    }
    else
        
    {
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM/yyyy";
        NSString *stringFromDate=[dateFormatter stringFromDate:date];
        _lblMangerDate.text=[NSString stringWithFormat:@"%@",stringFromDate];
        datePicker.date = datePicker.date;
        [datePicker removeFromSuperview];
        [datepickerBoderView removeFromSuperview];
        
        managerDate = datePicker.date;
        
        [PrintReport setHidden:YES];
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

        NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
        dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        dict[@"ZDate"] = _lblMangerDate.text;
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self managerReportResponse:response error:error];
            });
        };
        
        self.mReportGenerateWC = [self.mReportGenerateWC initWithRequest:KURL actionName:WSM_Z_MANAGER_LIST_DATA params:dict completionHandler:completionHandler];
    }
}

- (void)getManagerZReports {
    
    [PrintReport setHidden:YES];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    _arrayMangerReportList=[[NSMutableArray alloc]init];
    
    NSDate *date =  [NSDate date];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/yyyy";
    NSString *stringFromDate=[dateFormatter stringFromDate:date];
    _lblMangerDate.text=[NSString stringWithFormat:@"%@",stringFromDate];
    managerDate = date;

    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"ZDate"] = _lblMangerDate.text;

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self managerReportResponse:response error:error];
        });
    };
    
    self.mReportGenerateWC2 = [self.mReportGenerateWC2 initWithRequest:KURL actionName:WSM_Z_MANAGER_LIST_DATA params:dict completionHandler:completionHandler];
}

- (void)managerReportResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            self.arrayMangerReportList = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            
            [_activityIndicator hideActivityIndicator];;
            [[self.view viewWithTag:101] setHidden:YES];
            [[self.view viewWithTag:102]setHidden:NO];
            ccBatchReport.view.hidden = YES;
            xccBatchReport.view.hidden = YES;
            [self.view bringSubviewToFront:[self.view viewWithTag:102]];
            
            if (_arrayMangerReportList.count > 0) {
                [PrintReport setHidden:YES];
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                [self getZManagerData:_arrayMangerReportList.firstObject];
            }
            self.lblReportCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_arrayMangerReportList.count];
            self.selectedIndexPath = 0;
            [_tblManagerReportList reloadData];
        }
    }
}

#pragma mark -
#pragma mark TableView DataSource.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == self.cardSettlementTableView)
    {
        return 60;
    }
    else
    {
        return 95;
    }
    return 60;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.cardSettlementTableView)
    {
        return XmlResponseArray.count;
    }
    else
    {
        if(self.arrayMangerReportList.count>0 ){
            return self.arrayMangerReportList.count;
        }
        else{
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BaseCell"];
    
	UITableViewCell *cellCC = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"CCCell"];
    cellCC.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    if(tableView == _tblManagerReportList)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        tableView.separatorColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        if (indexPath.row == self.selectedIndexPath)
        {
            UIImageView * background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 684, 96)];
            background.contentMode = UIViewContentModeScaleToFill;
            background.image = [UIImage imageNamed:@"ReportActiveRowBlogBg.png"];
            [cell.contentView addSubview:background];
        }
        else
        {
            UIImageView * background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 684, 96)];
            background.contentMode = UIViewContentModeScaleToFill;
            background.image = [UIImage imageNamed:@"ReportBlogBg.png"];
            [cell.contentView addSubview:background];
        }
        
        
        UILabel * lblRegisterName = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 115, 25)];
        lblRegisterName.backgroundColor = [UIColor clearColor];
        lblRegisterName.textAlignment = NSTextAlignmentLeft;
        lblRegisterName.textColor = [UIColor colorWithRed:0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        lblRegisterName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblRegisterName.tag = 904;
        [cell.contentView addSubview:lblRegisterName];
        
        UILabel * lblRegisterNameValue = [[UILabel alloc] initWithFrame:CGRectMake(170, 8, 160, 25)];
        lblRegisterNameValue.backgroundColor = [UIColor clearColor];
        lblRegisterNameValue.textAlignment = NSTextAlignmentLeft;
        lblRegisterNameValue.textColor = [UIColor blackColor];
        lblRegisterNameValue.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblRegisterNameValue.tag = 905;
        [cell.contentView addSubview:lblRegisterNameValue];
        
        UILabel * lblDate = [[UILabel alloc] initWithFrame:CGRectMake(10, 34, 115, 25)];
        lblDate.backgroundColor = [UIColor clearColor];
        lblDate.textAlignment = NSTextAlignmentLeft;
        lblDate.textColor = [UIColor colorWithRed:0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        lblDate.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblDate.tag = 917;
        
        
        [cell.contentView addSubview:lblDate];
        
        UILabel * lblDateValue = [[UILabel alloc] initWithFrame:CGRectMake(170, 34, 160, 25)];
        lblDateValue.backgroundColor = [UIColor clearColor];
        lblDateValue.textAlignment = NSTextAlignmentLeft;
        lblDateValue.textColor = [UIColor blackColor];
        lblDateValue.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblDateValue.tag = 906;
        [cell.contentView addSubview:lblDateValue];
        
        UILabel * lblBatchNo = [[UILabel alloc] initWithFrame:CGRectMake(10, 59, 115, 25)];
        lblBatchNo.backgroundColor = [UIColor clearColor];
        lblBatchNo.textAlignment = NSTextAlignmentLeft;
        lblBatchNo.textColor = [UIColor colorWithRed:0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        lblBatchNo.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblBatchNo.tag = 907;
        [cell.contentView addSubview:lblBatchNo];
        
        UILabel * lblBatchNoValue = [[UILabel alloc] initWithFrame:CGRectMake(170, 59, 160, 25)];
        lblBatchNoValue.backgroundColor = [UIColor clearColor];
        lblBatchNoValue.textAlignment = NSTextAlignmentLeft;
        lblBatchNoValue.textColor = [UIColor blackColor];
        lblBatchNoValue.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblBatchNoValue.tag = 908;
        [cell.contentView addSubview:lblBatchNoValue];
        
        UILabel * lblSales = [[UILabel alloc] initWithFrame:CGRectMake(350, 8, 71, 25)];
        lblSales.backgroundColor = [UIColor clearColor];
        lblSales.textAlignment = NSTextAlignmentLeft;
        lblSales.textColor = [UIColor colorWithRed:0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        lblSales.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblSales.tag = 909;
        [cell.contentView addSubview:lblSales];
        
        UILabel * lblSalesValue = [[UILabel alloc] initWithFrame:CGRectMake(525, 8, 150, 25)];
        lblSalesValue.backgroundColor = [UIColor clearColor];
        lblSalesValue.textAlignment = NSTextAlignmentRight;
        lblSalesValue.textColor = [UIColor blackColor];
        lblSalesValue.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblSalesValue.tag = 910;
        [cell.contentView addSubview:lblSalesValue];
        
        UILabel * lblTax = [[UILabel alloc] initWithFrame:CGRectMake(350, 34, 71, 25)];
        lblTax.backgroundColor = [UIColor clearColor];
        lblTax.textAlignment = NSTextAlignmentLeft;
        lblTax.textColor = [UIColor colorWithRed:0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        lblTax.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblTax.tag = 911;
        [cell.contentView addSubview:lblTax];
        
        UILabel * lblTaxValue = [[UILabel alloc] initWithFrame:CGRectMake(525, 34, 150, 25)];
        lblTaxValue.backgroundColor = [UIColor clearColor];
        lblTaxValue.textAlignment = NSTextAlignmentRight;
        lblTaxValue.textColor = [UIColor blackColor];
        lblTaxValue.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblTaxValue.tag = 912;
        [cell.contentView addSubview:lblTaxValue];
        
        UILabel * lblTotalSale = [[UILabel alloc] initWithFrame:CGRectMake(350, 59, 71, 25)];
        lblTotalSale.backgroundColor = [UIColor clearColor];
        lblTotalSale.textAlignment = NSTextAlignmentLeft;
        lblTotalSale.textColor = [UIColor colorWithRed:0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        lblTotalSale.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblTotalSale.tag = 913;
        [cell.contentView addSubview:lblTotalSale];
        
        UILabel * lblTotalSaleValue = [[UILabel alloc] initWithFrame:CGRectMake(525, 59, 150, 25)];
        lblTotalSaleValue.backgroundColor = [UIColor clearColor];
        lblTotalSaleValue.textAlignment = NSTextAlignmentRight;
        lblTotalSaleValue.textColor = [UIColor blackColor];
        lblTotalSaleValue.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblTotalSaleValue.tag = 914;
        [cell.contentView addSubview:lblTotalSaleValue];
        
        UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 465, 115)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor blackColor];
        textLabel.tag = 915;
        [cell.contentView addSubview:textLabel];
        
        UILabel * textLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 465, 115)];
        textLabel1.backgroundColor = [UIColor clearColor];
        textLabel1.textAlignment = NSTextAlignmentCenter;
        textLabel1.textColor = [UIColor blackColor];
        textLabel1.tag = 916;
        [cell.contentView addSubview:textLabel1];
        if (indexPath.row == self.selectedIndexPath)
        {
            for (UILabel *lable in cell.contentView.subviews)
            {
                if ([lable isKindOfClass:[UILabel class]])
                {
                    if (lable.tag == 904 || lable.tag == 917 || lable.tag == 907 || lable.tag == 911 || lable.tag == 913 || lable.tag == 909 )
                    {
                        lable.textColor = [UIColor whiteColor];
                    }
                }
            }
        }
        
        if (self.arrayMangerReportList.count > 0 ) {
            
            for (int i=902; i<918; i++) {
                ((UILabel *)[cell.contentView viewWithTag:i]).text = @"";
            }
            ((UILabel *)[cell.contentView viewWithTag:904]).text = [NSString stringWithFormat:@"Register Name:"];
            
            NSString *strRegName =[NSString stringWithFormat:@"%@",(self.arrayMangerReportList)[indexPath.row][@"RegisterName"]];
            
            if([strRegName isEqualToString:@"<null>"])
            {
                strRegName = @"";
            }
            
            ((UILabel *)[cell.contentView viewWithTag:905]).text = strRegName;
            
            ((UILabel *)[cell.contentView viewWithTag:917]).text = [NSString stringWithFormat:@"Date :"];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            format.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
            format.dateFormat = @"MM/dd/yyyy";
            
            NSDate *now;
            NSString *dateString=@"";
            if ([strSelectButton isEqualToString:@"ManageZZ" ])
            {
                dateString = [(self.arrayMangerReportList)[indexPath.row] valueForKey:@"ZZDate"];
            }
            else
            {
                now = [self jsonStringToNSDate:[(self.arrayMangerReportList)[indexPath.row] valueForKey:@"ZDate"]];
                dateString=[format stringFromDate:now];
            }
            
            ((UILabel *)[cell.contentView viewWithTag:906]).text = dateString;
            ((UILabel *)[cell.contentView viewWithTag:907]).text = [NSString stringWithFormat:@"Batch No:"];
            ((UILabel *)[cell.contentView viewWithTag:908]).text = [NSString stringWithFormat:@"%@",[_arrayMangerReportList[indexPath.row] valueForKey:@"BatchNo"]];
            
            // SALES AMOUNT
            ((UILabel *)[cell.contentView viewWithTag:909]).text = [NSString stringWithFormat:@"Sales :"];
            NSNumber *slsAmt=@([[_arrayMangerReportList[indexPath.row] valueForKey:@"SalesAmt"] floatValue ]);
            NSString *salesAmt =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:slsAmt]];
            ((UILabel *)[cell.contentView viewWithTag:910]).text = salesAmt;
            
            // TAX AMOUNT
            ((UILabel *)[cell.contentView viewWithTag:911]).text = [NSString stringWithFormat:@"Tax:"];
            NSNumber *txAmt=@([[_arrayMangerReportList[indexPath.row] valueForKey:@"TaxAmount"]floatValue ]);
            NSString *taxAmount =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:txAmt]];
            ((UILabel *)[cell.contentView viewWithTag:912]).text = taxAmount;
            
            // TOTAL AMOUNT
            ((UILabel *)[cell.contentView viewWithTag:913]).text = [NSString stringWithFormat:@"Total Sale:"];
            NSNumber *ttlSlAmt=@([[_arrayMangerReportList[indexPath.row] valueForKey:@"TotalSales"]floatValue ]);
            NSString *totalSales =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:ttlSlAmt]];
            ((UILabel *)[cell.contentView viewWithTag:914]).text = totalSales;
            
        } else {
            for (int i=902; i<918; i++) {
                ((UILabel *)[cell.contentView viewWithTag:i]).text = @"";
            }
            ((UILabel *)[cell.contentView viewWithTag:916]).text = @"There is no data.";
        }
        return cell;
    }
    if (tableView == self.cardSettlementTableView) // card settlement tableview
    {
        if(XmlResponseArray.count > 0)
        {
            [self allocCardSattlement];
            
            NSString *rcdDate = [XmlResponseArray[indexPath.row] valueForKey:@"Tansactiondate"];
            NSString *getDate = [rcdDate substringToIndex:10];
            NSString *getTime = [rcdDate substringWithRange:NSMakeRange(11, 8)];
            
            //cardDate.text = [NSString stringWithFormat:@"%@",[[XmlResponseArray objectAtIndex:indexPath.row] valueForKey:@"Tansactiondate"]];
            cardDate.text = [NSString stringWithFormat:@"%@ %@",getDate, getTime];
            [self labelConfiguration:cardDate];
            cardDate.numberOfLines = 2;
            [cellCC addSubview:cardDate];
            
            creditCardNumber.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"CardNo"]];
            [self labelConfiguration:creditCardNumber];
            [cellCC addSubview:creditCardNumber];
            
            cardType.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"CardType"]];
            [self labelConfiguration:cardType];
            [cellCC addSubview:cardType];
            
            totalAmount.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"Amount"]];
            [self labelConfiguration:totalAmount];
            totalAmount.textAlignment = NSTextAlignmentRight;
            [cellCC addSubview:totalAmount];
            
            authNumber.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"Authentication"]];
            [self labelConfiguration:authNumber];
            [cellCC addSubview:authNumber];
            
            //            referenceNumber.text = [NSString stringWithFormat:@"%@",[[XmlResponseArray objectAtIndex:indexPath.row] valueForKey:@"ReferanceNo"]];
            //            [self labelConfiguration:referenceNumber];
            //            [cellCC addSubview:referenceNumber];
            
            invoiceNumber.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"InvoiceNo"]];
            [self labelConfiguration:invoiceNumber];
            invoiceNumber.textAlignment = NSTextAlignmentLeft;
            [cellCC addSubview:invoiceNumber];
        }
        return cellCC;
    }
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _tblManagerReportList)
    {
        self.selectedIndexPath = indexPath.row;
        [_tblManagerReportList reloadData];
        [self.crmController UserTouchEnable];
        if (_arrayMangerReportList.count >0)
        {
            if ([strSelectButton isEqualToString:@"ManageZZ" ])
            {
                [PrintReport setHidden:YES];
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                [self getZZManagerData:_arrayMangerReportList[indexPath.row]];
            }
            else
            {
                [PrintReport setHidden:YES];
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                [self getZManagerData:_arrayMangerReportList[indexPath.row]];
            }
        }
    }
}

#pragma mark -
#pragma mark Get ZZ Manager Report

-(void)getZZManagerData:(NSMutableArray *)arrZManagerdata
{
    NSMutableArray *arrayMain =[[NSMutableArray alloc]init];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = [arrZManagerdata valueForKey:@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    dict[@"ZZOpnDate"] = [arrZManagerdata valueForKey:@"ZZOpnDate"];
    dict[@"ZZClsDate"] = [arrZManagerdata valueForKey:@"ZZDate"];
    dict[@"BatchNo"] = [arrZManagerdata valueForKey:@"BatchNo"];
    dict[@"registerName"] = [arrZManagerdata valueForKey:@"RegisterName"];
    [arrayMain addObject:dict];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self ManagerZZReportResponse:response error:error];
        });
    };
    
    self.zZManagerReportWC = [self.zZManagerReportWC initWithRequest:KURL actionName:WSM_ZZ_MANAGER_LIST_DETAIL_RPT params:dict completionHandler:completionHandler];
}

#pragma mark -
#pragma mark Generate Z Manager Report

-(void)ManagerZZReportResponse:(id)response error:(NSError *)error{
    [_activityIndicator hideActivityIndicator];;
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            if (responseArray.count>0)
            {
                /// Get Html String frmo Array
                NSString *strReport = [self printXFileReport:responseArray :@"ZZ Report"];
                self.responseXArray=[responseArray mutableCopy];
                sPrint = @"Manager ZZ";
                
                NSString *strReportForEmail = [self createHTMLFormateForEmail:strReport];
                /// Write Data On Document Directory.......
                NSData *data = [strReportForEmail dataUsingEncoding:NSUTF8StringEncoding];
                [self writeDataOnCacheDirectory:data];
                strReport =  [self createHTMLFormateForDisplayReportInWebView:strReport];
                [PrintReport loadHTMLString:strReport baseURL:nil];
                _uvsampleView.hidden=YES;
                PrintReport.hidden = NO;
                PrintReport.frame = CGRectMake(PrintReport.frame.origin.x, PrintReport.frame.origin.y, PrintReport.frame.size.width, PrintReport.frame.size.height);
            }
        }
    }
}

#pragma mark -
#pragma mark Get Z Manager Report

-(void)getZManagerData:(NSMutableArray *)arrZManagerdata{
    NSMutableArray *arrayMain =[[NSMutableArray alloc]init];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"ZTransId"] = [arrZManagerdata valueForKey:@"ZTransId"];
    [arrayMain addObject:dict];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self ZManagerReportResponse:response error:error];
        });
    };
    
    self.zManagerReportWC = [self.zManagerReportWC initWithRequest:KURL actionName:WSM_Z_MANAGER_LIST_DETAIL_RPT params:dict completionHandler:completionHandler];
}

#pragma mark -
#pragma mark Generate Z Manager Report

-(void)ZManagerReportResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            if (responseArray.count>0)
            {
                sPrint=@"Manager Z";
            }
            [_activityIndicator hideActivityIndicator];;
            
            /// Get Html String From Array.....
            NSString *strReport = [self printXFileReport:responseArray :@"Manager Z"];
            self.responseXArray=[responseArray mutableCopy];
            
            NSString *strReportForEmail = [self createHTMLFormateForEmail:strReport];
            /// Write Data On Document Directory.......
            NSData *data = [strReportForEmail dataUsingEncoding:NSUTF8StringEncoding];
            [self writeDataOnCacheDirectory:data];
            strReport =  [self createHTMLFormateForDisplayReportInWebView:strReport];
            [PrintReport loadHTMLString:strReport baseURL:nil];
            _uvsampleView.hidden=YES;
            PrintReport.hidden = NO;
            PrintReport.frame = CGRectMake(PrintReport.frame.origin.x, PrintReport.frame.origin.y, PrintReport.frame.size.width, PrintReport.frame.size.height);
        }
    }
}

#pragma mark -
#pragma mark ZZ Report Delegate

-(IBAction)getZZreportDetail:(id)sender{
    [self.rmsDbController playButtonSound];
    BOOL hasRights = [UserRights hasRights:UserRightZZReportPrint];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to generate ZZ-Report. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    if(([[self.rmsDbController.globalDict valueForKey:@"ZId"] integerValue ] == 0 ) &&
       (self.isZZPrint) )
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Restart the application to check / print ZZ report again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
    }
    else
    {
        
        _btnDollorView.selected = YES;
        _btnPrctView.selected = NO;
        _ccBatch.selected = NO;
        _ccBatch.hidden = YES;
        _settleCC.hidden = YES;
        _cardSattlementView.hidden = YES;
        _ccBatchButton.selected = NO;
    //    self.shiftReportView.hidden = YES;


        [self setSelectButton:_btnZZReport forView:_footerView];

        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self setSelectButton:_btnXReport forView:_footerView];
        };
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            _uvXReport.hidden=YES;
            _uvXRepBar.hidden=YES;
            _uvPaymentBarChart.hidden=YES;
            [self.rmsDbController playButtonSound];
            PrintReport.hidden=YES;
            self.crmController.bZexit=FALSE;
            self.crmController.pReportView=self;
            self.isZZPrint=TRUE;
            if (isZPrint)
            {
                sPrint=@"ZZ";
                [self getZZReportData];
            }
            else
            {
                sPrint=@"Z";
                [self checkShiftEmployee];
            }
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@" Do you want to proceed with ZZ report?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

-(void)getZZReportData{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    _uvXReport.hidden=NO;
    _uvXRepBar.hidden=NO;
    _uvPaymentBarChart.hidden=NO;
    [[self.view viewWithTag:101] setHidden:NO];
    [[self.view viewWithTag:102]setHidden:YES];
    ccBatchReport.view.hidden = YES;
    ccBatchReport.view.hidden = YES;
    self.crmController.bZexit=TRUE;

    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self ZZReportResponse:response error:error];
        });
    };
    
    self.zZReportDataWC = [self.zZReportDataWC initWithRequest:KURL actionName:WSM_ZZ_REPORT params:dict completionHandler:completionHandler];
}
-(void)ZZReportResponse:(id)response error:(NSError *)error {
    _strTypeofChart = @"Dollorwise";
    [_activityIndicator hideActivityIndicator];;
    PrintReport.hidden=NO;
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                responseZArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                self.responseXArray=[responseZArray mutableCopy];
                sPrint=@"ZZ";
                [self printZZreport:responseZArray];
                isZOrZZPrint = TRUE;
                
                // To Load Pie chart based on Department.
                objPieChart = [[XReportPieChart alloc] initWithNibName:@"XReportPieChart" bundle:nil];
                objPieChart.arrXRepDepartment = [[responseZArray.firstObject valueForKey:@"RptDepartment"] mutableCopy ];
                NSMutableDictionary *staticDataPiedict=[[NSMutableDictionary alloc]init];
                staticDataPiedict[@"Amount"] = @"0.00";
                staticDataPiedict[@"Count"] = @"0.00";
                staticDataPiedict[@"DepartId"] = @"0.00";
                staticDataPiedict[@"Descriptions"] = @"Not Available";
                staticDataPiedict[@"Per"] = @"100.0";
                if (objPieChart.arrXRepDepartment.count==0) {
                    [objPieChart.arrXRepDepartment addObject:staticDataPiedict];
                }
                
                NSMutableArray *arrTemp2 = [[NSMutableArray alloc] init];
                for (int i = 0 ; i < objPieChart.arrXRepDepartment.count; i++)
                {
                    NSMutableDictionary *arrTemp = (objPieChart.arrXRepDepartment)[i];
                    float percent = [[arrTemp valueForKey:@"Per" ] floatValue ];
                    if(percent != 0)
                    {
                        [arrTemp2 addObject:arrTemp];
                    }
                }
                //objPieChart.view.tag=20002;
                objPieChart.StrLableName=@"ZZ Report";
                objPieChart.objReportView=self;
                objPieChart.arrXRepDepartment = [arrTemp2 mutableCopy];
                
                if([_strTypeofChart isEqualToString:@"Dollorwise"])
                {
                    NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
                    lblChartValue.text = [self.crmController.currencyFormatter stringFromNumber:sum];
                }
                else
                {
                    NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Per"];
                    lblChartValue.text = [NSString stringWithFormat:@"%.2f%%",sum.floatValue];
                }
                //[uvXReport addSubview:objPieChart.view];
                [self addChart:objPieChart toContainer:_uvXReport tag:20002];
                
                // To Load Bar chart based on customer visit.
                objBarChart = [[XReportBarChart alloc] initWithNibName:@"XReportBarChart" bundle:nil];
                objBarChart.arrXRepHours = [[responseZArray.firstObject valueForKey:@"RptHours"] mutableCopy ];
                NSMutableDictionary *staticDataBardict=[[NSMutableDictionary alloc]init];
                staticDataBardict[@"Amount"] = @"0.00";
                int decm=0;
                staticDataBardict[@"Count"] = @(decm);
                staticDataBardict[@"Hours"] = @"0.00";
                if (objBarChart.arrXRepHours.count==0) {
                    [ objBarChart.arrXRepHours addObject:staticDataBardict];
                }
                //objBarChart.view.tag=20003;
                NSNumber *sum=[objBarChart.arrXRepHours valueForKeyPath:@"@sum.Count"];
                _lblCoustmerCount.text=[NSString stringWithFormat:@"%ld",(long)sum.integerValue];
                
                //[uvXRepBar addSubview:objBarChart.view];
                [self addChart:objBarChart toContainer:_uvXRepBar tag:20003];
                
                // Payment Pie Chart
                objPaymentPieChart = [[XReportpaymentPieChart alloc] initWithNibName:@"XReportpaymentPieChart" bundle:nil];
                objPaymentPieChart.arrXRepDepartment = [[responseZArray.firstObject valueForKey:@"RptTender"] mutableCopy ];
                NSMutableDictionary *staticDataPiedict1=[[NSMutableDictionary alloc]init];
                staticDataPiedict1[@"Amount"] = @"100.00";
                staticDataPiedict1[@"Count"] = @"0.00";
                staticDataPiedict1[@"TenderId"] = @"0.00";
                staticDataPiedict1[@"Descriptions"] = @"Not Available";
                if (objPaymentPieChart.arrXRepDepartment.count==0)
                {
                    [objPaymentPieChart.arrXRepDepartment addObject:staticDataPiedict1];
                }
                
                NSMutableArray *arrTemp21 = [[NSMutableArray alloc] init];
                for (int i = 0 ; i < objPaymentPieChart.arrXRepDepartment.count; i++)
                {
                    NSMutableDictionary *arrTempPayment = (objPaymentPieChart.arrXRepDepartment)[i];
                    float percent = [[arrTempPayment valueForKey:@"Amount" ] floatValue ];
                    if(percent != 0)
                    {
                        [arrTemp21 addObject:arrTempPayment];
                    }
                }
                objPaymentPieChart.objPayReportView=self;
                objPaymentPieChart.StrLableName=@"ZZ Report";
                objPaymentPieChart.arrXRepDepartment = [arrTemp21 mutableCopy];
                
                
                if([_strTypeofChart isEqualToString:@"Dollorwise"])
                {
                    NSNumber *sum=[objPaymentPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
                    
                    lblPaymentChartValue.text = [self.crmController.currencyFormatter stringFromNumber:sum];
                }
                else
                {
                    lblPaymentChartValue.text = @"100.00%";
                }
                //objPaymentPieChart.view.tag=20004;
                //[uvPaymentBarChart addSubview:objPaymentPieChart.view];
                [self addChart:objPaymentPieChart toContainer:_uvPaymentBarChart tag:20004];
                
                if (isZPrint)
                {
                    _uvZZReportInfo.hidden = YES;
                }
                else
                {
                    _uvZZReportInfo.hidden = NO;
                    isZPrint = TRUE;
                }
                self.isZZPrint = FALSE;
                [self SetPortInfo];
            }
        }
    }
}

-(void)ZZManagerReport:(NSNotification *)notification{
    
	NSMutableArray *responseArray = notification.object;
    responseArray = [responseArray valueForKey:@"ZZManagerRptDataResult"];
    [_activityIndicator hideActivityIndicator];;
    
    /// Get Html String From Array
    NSString *strReport = [self printXFileReport:responseArray :@"ZZ Report"];
    
    NSString *strReportForEmail = [self createHTMLFormateForEmail:strReport];
    /// Write Data On Document Directory.......
    NSData *data = [strReportForEmail dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    strReport =  [self createHTMLFormateForDisplayReportInWebView:strReport];
	[PrintReport loadHTMLString:strReport baseURL:nil];
    PrintReport.hidden = NO;
    PrintReport.frame = CGRectMake(PrintReport.frame.origin.x, PrintReport.frame.origin.y, PrintReport.frame.size.width, PrintReport.frame.size.height);
    
#pragma Printer Controller Method
    
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
	if(!controller){
		return;
	}
    
	UIPrintInteractionCompletionHandler completionHandler =
	^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
		if(!completed && error){
		}
	};
    
	controller.delegate = self;
    
	// Obtain a printInfo so that we can set our printing defaults.
	UIPrintInfo *printInfo = [UIPrintInfo printInfo];
	// This application produces General content that contains color.
	printInfo.outputType = UIPrintInfoOutputGeneral;
	// We'll use the URL as the job name
	printInfo.jobName = @"Print Receipt";
	// Set duplex so that it is available if the printer supports it. We
	// are performing portrait printing so we want to duplex along the long edge.
	printInfo.duplex = UIPrintInfoDuplexLongEdge;
	// Use this printInfo for this print job.
	controller.printInfo = printInfo;
    
	// Be sure the page range controls are present for documents of > 1 page.
	controller.showsPageRange = YES;
	
	// This code uses a custom UIPrintPageRenderer so that it can draw a header and footer.
	MyPrintPageRenderer *myRenderer = [[MyPrintPageRenderer alloc] init];
	// The MyPrintPageRenderer class provides a jobtitle that it will label each page with.
	myRenderer.jobTitle = printInfo.jobName;
	// To draw the content of each page, a UIViewPrintFormatter is used.
	UIViewPrintFormatter *viewFormatter = [PrintReport viewPrintFormatter];
    
#if SIMPLE_LAYOUT
	/*
	 For the simple layout we simply set the header and footer height to the height of the
	 text box containing the text content, plus some padding.
	 
	 To do a layout that takes into account the paper size, we need to do that
	 at a point where we know that size. The numberOfPages method of the UIPrintPageRenderer
	 gets the paper size and can perform any calculations related to deciding header and
	 footer size based on the paper size. We'll do that when we aren't doing the simple
	 layout.
	 */
	UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:HEADER_FOOTER_TEXT_HEIGHT];
	//CGSize titleSize = [myRenderer.jobTitle sizeWithFont:font];
    CGSize titleSize = [myRenderer.jobTitle sizeWithAttributes:@{NSFontAttributeName: font}];
	myRenderer.headerHeight = myRenderer.footerHeight = titleSize.height + HEADER_FOOTER_MARGIN_PADDING;
#endif
	[myRenderer addPrintFormatter:viewFormatter startingAtPageAtIndex:0];
	// Set our custom renderer as the printPageRenderer for the print job.
	controller.printPageRenderer = myRenderer;
	
	// The method we use presenting the printing UI depends on the type of
	// UI idiom that is currently executing. Once we invoke one of these methods
	// to present the printing UI, our application's direct involvement in printing
	// is complete. Our custom printPageRenderer will have its methods invoked at the
	// appropriate time by UIKit.
	//[controller presentFromBarButtonItem:printButton animated:YES completionHandler:completionHandler];  // iPad
    
    CGRect popoverRect = [self.view convertRect:_btnZReport.frame fromView:_btnZReport.superview];
	[controller presentFromRect:popoverRect inView:self.view animated:YES completionHandler:completionHandler];
    
    _bZexit=TRUE;
}

#pragma mark -
#pragma mark SearchBar Delegate

- (void)removeSearchBarbackground:(UISearchBar *)searchBar1 {
	for (UIView *subview in searchBar1.subviews){
		if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
			subview.alpha = 0.0;
		}
		if([subview isKindOfClass:[UITextField class]]) {
			[(UITextField *)subview setEnablesReturnKeyAutomatically:NO];
			((UITextField *)subview).backgroundColor = [UIColor clearColor];
			//[(UITextField*)subview setBackground:nil];
			//[(UITextField*)subview setLeftView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchIcon.png"]] autorelease]];
		}
	}
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar1 {
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar1 textDidChange:(NSString *)searchText {
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar1 {
	[searchBar1 resignFirstResponder];
}

-(void)removeRapidCreditBatchSettleView
{
    if (rapidCreditBatchDetailVC) {
        [rapidCreditBatchDetailVC.view removeFromSuperview];
        rapidCreditBatchDetailVC = nil;
    }
}

-(IBAction)DollorChartView:(id)sender
{
    [self.rmsDbController playButtonSound];
    _strTypeofChart = @"Dollorwise";
    
    self.btnCurrencyIndicator.selected = YES;
    _btnPrctView.selected = NO;
    _ccBatch.selected = NO;
    
    _cardSattlementView.hidden = YES;
    [self removeRapidCreditBatchSettleView];
    _rapidCreditBatchButton.selected = NO;

    
    objPieChart = [[XReportPieChart alloc] initWithNibName:@"XReportPieChart" bundle:nil];
    objPieChart.arrXRepDepartment = [[self.responseXArray.firstObject valueForKey:@"RptDepartment"] mutableCopy ];
    NSMutableDictionary *staticDataPiedict=[[NSMutableDictionary alloc]init];
    staticDataPiedict[@"Amount"] = @"0.00";
    staticDataPiedict[@"Count"] = @"0.00";
    staticDataPiedict[@"DepartId"] = @"0.00";
    staticDataPiedict[@"Descriptions"] = @"Not Available";
    staticDataPiedict[@"Per"] = @"100.0";
    if (objPieChart.arrXRepDepartment.count==0) {
        [objPieChart.arrXRepDepartment addObject:staticDataPiedict];
    }
    
    NSMutableArray *arrTemp2 = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < objPieChart.arrXRepDepartment.count; i++)
    {
        NSMutableDictionary *arrTemp = (objPieChart.arrXRepDepartment)[i];
        float percent = [[arrTemp valueForKey:@"Per" ] floatValue ];
        if(percent != 0)
        {
            [arrTemp2 addObject:arrTemp];
        }
    }
    objPieChart.objReportView=self;
    //objPieChart.view.tag=20002;
    objPieChart.StrLableName=[NSString stringWithFormat:@"%@ Report",sPrint];
    objPieChart.arrXRepDepartment = [arrTemp2 mutableCopy];
    
    if([_strTypeofChart isEqualToString:@"Dollorwise"])
    {
        NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
        lblChartValue.text = [self.crmController.currencyFormatter stringFromNumber:sum];
    }
    else
        
    {
        NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Per"];
        lblChartValue.text = [NSString stringWithFormat:@"%.2f%%",sum.floatValue];
    }
    //[uvXReport addSubview:objPieChart.view];
    [self addChart:objPieChart toContainer:_uvXReport tag:20002];
    
    // To Load Bar chart based on customer visit.
    objBarChart = [[XReportBarChart alloc] initWithNibName:@"XReportBarChart" bundle:nil];
    objBarChart.arrXRepHours = [[self.responseXArray.firstObject valueForKey:@"RptHours"] mutableCopy ];
    NSMutableDictionary *staticDataBardict=[[NSMutableDictionary alloc]init];
    staticDataBardict[@"Amount"] = @"0.00";
    int decm=0;
    staticDataBardict[@"Count"] = @(decm);
    staticDataBardict[@"Hours"] = @"0.00";
    if (objBarChart.arrXRepHours.count==0) {
        [ objBarChart.arrXRepHours addObject:staticDataBardict];
    }
    NSNumber *sum=[objBarChart.arrXRepHours valueForKeyPath:@"@sum.Count"];
    _lblCoustmerCount.text=[NSString stringWithFormat:@"%ld",(long)sum.integerValue];
    //    objBarChart.view.tag=20003;
    //    [uvXRepBar addSubview:objBarChart.view];
    [self addChart:objBarChart toContainer:_uvXRepBar tag:20003];
    
    // Payment pie chart
    objPaymentPieChart = [[XReportpaymentPieChart alloc] initWithNibName:@"XReportpaymentPieChart" bundle:nil];
    objPaymentPieChart.arrXRepDepartment = [[self.responseXArray.firstObject valueForKey:@"RptTender"] mutableCopy ];
    NSMutableDictionary *staticDataPiedict1=[[NSMutableDictionary alloc]init];
    staticDataPiedict1[@"Amount"] = @"100.00";
    staticDataPiedict1[@"Count"] = @"0.00";
    staticDataPiedict1[@"TenderId"] = @"0.00";
    staticDataPiedict1[@"Descriptions"] = @"Not Available";
    if (objPaymentPieChart.arrXRepDepartment.count==0)
    {
        [objPaymentPieChart.arrXRepDepartment addObject:staticDataPiedict1];
    }
    
    NSMutableArray *arrTemp21 = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < objPaymentPieChart.arrXRepDepartment.count; i++)
    {
        NSMutableDictionary *arrTempPayment = (objPaymentPieChart.arrXRepDepartment)[i];
        float percent = [[arrTempPayment valueForKey:@"Amount" ] floatValue ];
        if(percent != 0)
        {
            [arrTemp21 addObject:arrTempPayment];
        }
    }
    objPaymentPieChart.objPayReportView = self;
    objPaymentPieChart.StrLableName=[NSString stringWithFormat:@"%@ Report",sPrint];
    objPaymentPieChart.arrXRepDepartment = [arrTemp21 mutableCopy];
    // objPaymentPieChart.view.tag=20004;
    
    if([_strTypeofChart isEqualToString:@"Dollorwise"])
    {
        NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
        
        lblPaymentChartValue.text = [self.crmController.currencyFormatter stringFromNumber:sum];
    }
    else
    {
        lblPaymentChartValue.text = @"100.00%";
    }
    [self addChart:objPaymentPieChart toContainer:_uvPaymentBarChart tag:20004];
    //    [uvPaymentBarChart addSubview:objPaymentPieChart.view];    //    -(IBAction)getXreportDetail:(id)sender{
}

-(IBAction)PercentageChartView:(id)sender
{
    [self.rmsDbController playButtonSound];
    _strTypeofChart = @"Percentagewise";
    
    self.btnCurrencyIndicator.selected = NO;
    _btnPrctView.selected = YES;
    _ccBatch.selected = NO;
    
    _cardSattlementView.hidden = YES;
    _rapidCreditBatchButton.selected = NO;

    [self removeRapidCreditBatchSettleView];

    objPieChart = [[XReportPieChart alloc] initWithNibName:@"XReportPieChart" bundle:nil];
    objPieChart.arrXRepDepartment = [[self.responseXArray.firstObject valueForKey:@"RptDepartment"] mutableCopy ];
    NSMutableDictionary *staticDataPiedict=[[NSMutableDictionary alloc]init];
    staticDataPiedict[@"Amount"] = @"0.00";
    staticDataPiedict[@"Count"] = @"0.00";
    staticDataPiedict[@"DepartId"] = @"0.00";
    staticDataPiedict[@"Descriptions"] = @"Not Available";
    staticDataPiedict[@"Per"] = @"100.0";
    if (objPieChart.arrXRepDepartment.count==0) {
        [objPieChart.arrXRepDepartment addObject:staticDataPiedict];
    }
    
    NSMutableArray *arrTemp2 = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < objPieChart.arrXRepDepartment.count; i++)
    {
        NSMutableDictionary *arrTemp = (objPieChart.arrXRepDepartment)[i];
        float percent = [[arrTemp valueForKey:@"Per" ] floatValue ];
        if(percent != 0)
        {
            [arrTemp2 addObject:arrTemp];
        }
    }
    objPieChart.objReportView=self;
    //    objPieChart.view.tag=12121;
    objPieChart.StrLableName=[NSString stringWithFormat:@"%@ Report",sPrint];
    objPieChart.arrXRepDepartment = [arrTemp2 mutableCopy];
    
    if([_strTypeofChart isEqualToString:@"Dollorwise"])
    {
        NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
        lblChartValue.text = [self.crmController.currencyFormatter stringFromNumber:sum];
    }
    else
    {
        NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Per"];
        lblChartValue.text = [NSString stringWithFormat:@"%.2f%%",sum.floatValue];
    }
    //[uvXReport addSubview:objPieChart.view];
    [self addChart:objPieChart toContainer:_uvXReport tag:20002];
    
    // To Load Bar chart based on customer visit.
    objBarChart = [[XReportBarChart alloc] initWithNibName:@"XReportBarChart" bundle:nil];
    objBarChart.arrXRepHours = [[self.responseXArray.firstObject valueForKey:@"RptHours"] mutableCopy ];
    NSMutableDictionary *staticDataBardict=[[NSMutableDictionary alloc]init];
    staticDataBardict[@"Amount"] = @"0.00";
    int decm=0;
    staticDataBardict[@"Count"] = @(decm);
    staticDataBardict[@"Hours"] = @"0.00";
    if (objBarChart.arrXRepHours.count==0) {
        [ objBarChart.arrXRepHours addObject:staticDataBardict];
    }
    //    objBarChart.view.tag=12122;
    NSNumber *sum=[objBarChart.arrXRepHours valueForKeyPath:@"@sum.Count"];
    _lblCoustmerCount.text=[NSString stringWithFormat:@"%ld",(long)sum.integerValue];
    //    [uvXRepBar addSubview:objBarChart.view];
    [self addChart:objBarChart toContainer:_uvXRepBar tag:20003];
    
    // Payment Pie Chart
    objPaymentPieChart = [[XReportpaymentPieChart alloc] initWithNibName:@"XReportpaymentPieChart" bundle:nil];
    objPaymentPieChart.arrXRepDepartment = [[self.responseXArray.firstObject valueForKey:@"RptTender"] mutableCopy ];
    NSMutableDictionary *staticDataPiedict1=[[NSMutableDictionary alloc]init];
    staticDataPiedict1[@"Amount"] = @"100.00";
    staticDataPiedict1[@"Count"] = @"0.00";
    staticDataPiedict1[@"TenderId"] = @"0.00";
    staticDataPiedict1[@"Descriptions"] = @"Not Available";
    if (objPaymentPieChart.arrXRepDepartment.count==0)
    {
        [objPaymentPieChart.arrXRepDepartment addObject:staticDataPiedict1];
    }
    
    NSMutableArray *arrTemp21 = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < objPaymentPieChart.arrXRepDepartment.count; i++)
    {
        NSMutableDictionary *arrTempPayment = (objPaymentPieChart.arrXRepDepartment)[i];
        float percent = [[arrTempPayment valueForKey:@"Amount" ] floatValue ];
        if(percent != 0)
        {
            [arrTemp21 addObject:arrTempPayment];
        }
    }
    objPaymentPieChart.objPayReportView = self;
    objPaymentPieChart.StrLableName=[NSString stringWithFormat:@"%@ Report",sPrint];
    objPaymentPieChart.arrXRepDepartment = [arrTemp21 mutableCopy];
    //objPaymentPieChart.view.tag=12123;
    
    if([_strTypeofChart isEqualToString:@"Dollorwise"])
    {
        NSNumber *sum=[objPieChart.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
        lblPaymentChartValue.text = [self.crmController.currencyFormatter stringFromNumber:sum];
    }
    else
    {
        lblPaymentChartValue.text = @"100.00%";
    }
    //    [uvPaymentBarChart addSubview:objPaymentPieChart.view];
    [self addChart:objPaymentPieChart toContainer:_uvPaymentBarChart tag:20004];
}



-(BOOL)checkGasPumpisActive{
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", self.rmsDbController.globalDict[@"DeviceId"]];
    
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    
    return [self isRcrGasActive:activeModulesArray];
}
-(BOOL)isRcrGasActive:(NSArray *)array
{
    BOOL isRcrActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@",@"RCRGAS"];
    NSArray *rcrArray = [array filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}



#pragma mark CC Batch Option view

-(void)optionForCCBath{
    
    if(!_ccBatchButton){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"GasPump" bundle:nil];
        _ccBatchButton = [storyBoard instantiateViewControllerWithIdentifier:@"CCBatchOptionVC"];
//        _ccBatchButton.cCBatchOptionDelegate = self;
        self.ccBatchOptionSelectionPopOverView = [[UIPopoverController alloc] initWithContentViewController:_ccBatchButton];
        self.ccBatchOptionSelectionPopOverView.popoverContentSize = CGSizeMake(200.0, 195.0);
        self.ccBatchOptionSelectionPopOverView.delegate =self;
        CGRect pooverRect = CGRectMake(self.btnCCBatch.frame.origin.x, 720.0, self.btnCCBatch.frame.size.width, self.btnCCBatch.frame.size.height);
        [self.ccBatchOptionSelectionPopOverView presentPopoverFromRect:pooverRect inView:self.view
                                              permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }

}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    [popoverController dismissPopoverAnimated:YES];
    _ccBatchButton = nil;
}

#pragma mark CC Batch Option Delegate Method

-(void)inSidePayCCInfo{
    
    NSPredicate *inSidePredicate = [NSPredicate predicateWithFormat:@"ServiceType like 'In-Side'"];
    self.rmsDbController.paymentCardTypearray = [[self.paymentCardTypearrayGlobal filteredArrayUsingPredicate:inSidePredicate] mutableCopy];
    
    [self openCCBatch];
    [self.ccBatchOptionSelectionPopOverView dismissPopoverAnimated:YES];
    _ccBatchButton = nil;
}
-(void)outSidePayCCInfo{
    
    NSPredicate *inSidePredicate = [NSPredicate predicateWithFormat:@"ServiceType like 'Out-Side'"];
    self.rmsDbController.paymentCardTypearray = [[self.paymentCardTypearrayGlobal filteredArrayUsingPredicate:inSidePredicate] mutableCopy];
    
    [self openCCBatch];
    
    [self.ccBatchOptionSelectionPopOverView dismissPopoverAnimated:YES];
    _ccBatchButton = nil;
}


-(IBAction)ccBatchClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    if([self checkGasPumpisActive]){
        
        [self optionForCCBath];
    }
    else
    {
        [self setSelectButton:(UIButton *)sender forView:_footerView];
        [self openCCBatch];

    }
}
-(void)openCCBatch{
    [xccBatchReport.view removeFromSuperview];
    xccBatchReport = nil;

#ifdef CheckRights
    BOOL hasRights = [UserRights hasRights:UserRightCCBatch];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have CC Batch rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
#endif
    self.parseingFunCall = @"ccBatch";
    _managerReportView.hidden = YES;
    self.shiftReportView.hidden = YES;
    
    
    [[self.view viewWithTag:101] setHidden:YES];
    [[self.view viewWithTag:102]setHidden:YES];
    
    xccBatchReport = [[XCCbatchReportVC alloc]initWithNibName:@"XCCbatchReportVC" bundle:nil];
    xccBatchReport.isTipsApplicable = self.tipSetting;
    xccBatchReport.xCCbatchReportDelegate = self;
    xccBatchReport.view.frame = CGRectMake(0, 0, xccBatchReport.view.frame.size.width, xccBatchReport.view.frame.size.height);
    [self.view addSubview:xccBatchReport.view];
    xccBatchReport.parseingFunCall=self.parseingFunCall;
    [self.view bringSubviewToFront:xccBatchReport.view];
}
-(void)cancelCCBatchReport
{
    [xccBatchReport.view removeFromSuperview];
    xccBatchReport = nil;
    [self setSelectButton:nil forView:_footerView];
}

-(void)allocCardSattlement
{
    cardDate = [[UILabel alloc] initWithFrame:CGRectMake(4, 8, 80, 40)];
    creditCardNumber = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 100, 30)];
    cardType = [[UILabel alloc] initWithFrame:CGRectMake(242, 10, 100, 30)];
    totalAmount = [[UILabel alloc] initWithFrame:CGRectMake(350, 10, 80, 30)];
    authNumber = [[UILabel alloc] initWithFrame:CGRectMake(470, 10, 100, 30)];
    //referenceNumber = [[UILabel alloc] initWithFrame:CGRectMake(499, 10, 100, 30)];
    invoiceNumber = [[UILabel alloc] initWithFrame:CGRectMake(615, 10, 100, 30)];
}

-(void)labelConfiguration:(UILabel *)sender
{
    sender.numberOfLines = 0;
    sender.textAlignment = NSTextAlignmentLeft;
    sender.backgroundColor = [UIColor clearColor];
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
}

-(NSString *)convertDateAndTime:(NSString *)xmlDate
{
    //    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    //    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    //    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    //    NSDate *date = [dateFormater dateFromString:dateString];
    //
    //    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    //    [timeFormatter setDateFormat:@"HH:mm"];
    //    [timeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    //    NSString *convertedTime = [timeFormatter stringFromDate:date];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    inputFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *inputDate = [inputFormatter dateFromString:xmlDate];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateFormat = @"MMM dd, HH:mm a";
    NSString *outputDate = [outputFormatter stringFromDate:inputDate];
    
    return outputDate;
}

-(BOOL)isShiftHasInvoiceInOffline
{
    BOOL isShiftHasInvoiceInOffline = FALSE;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"zId==%@ AND isUpload==%@",zIdForOfflineInvoiceCount,@(FALSE)];
    fetchRequest.predicate = predicate;
    
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
   
    if (object.count > 0)
    {
        isShiftHasInvoiceInOffline = TRUE;
    }
    return isShiftHasInvoiceInOffline;
}

#pragma mark -
#pragma mark Shift View Delegate Method

-(void)shiftIn_OutSuccessfullyDone
{
    shift.view.hidden = YES;
    
    
    if ([sPrint isEqualToString:@"Z"])
    {
        [self getZReport];
    }
    
}

-(void)ShiftIn_OutProcessFailed
{
    
}

-(void)dismissShiftIn_OutController
{
    shift.view.hidden = YES;
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    for (UIViewController *vc in viewControllerArray)
    {
        if ([vc isKindOfClass:[DashBoardSettingVC class]])
        {
            [self.navigationController popToViewController:vc animated:TRUE];
        }
    }
}

-(IBAction)cardSettlement:(id)sender
{
    [self.rmsDbController playButtonSound];
    _managerReportView.hidden = YES;
    [[self.view viewWithTag:101] setHidden:YES];
    [[self.view viewWithTag:102]setHidden:YES];
    
    ccBatchReport = [[CCbatchReportVC alloc]initWithNibName:@"CCbatchReportVC" bundle:nil];
    ccBatchReport.view.frame = CGRectMake(320, 84, ccBatchReport.view.frame.size.width, ccBatchReport.view.frame.size.height);
    [self.view addSubview:ccBatchReport.view];
    [self.view bringSubviewToFront:ccBatchReport.view];
}
-(IBAction)creditBatchDetail:(id)sender
{
    [self.rmsDbController playButtonSound];
    _managerReportView.hidden = YES;
    _rapidCreditBatchButton.selected = YES;
    self.btnCurrencyIndicator.selected = NO;
    _btnPrctView.selected = NO;
    
    [[self.view viewWithTag:101] setHidden:YES];
    [[self.view viewWithTag:102]setHidden:YES];
    
    [self removeRapidCreditBatchSettleView];;
    
    rapidCreditBatchDetailVC = [[RapidCreditBatchDetailVC alloc]initWithNibName:@"RapidCreditBatchDetailVC" bundle:nil];
    rapidCreditBatchDetailVC.view.frame = CGRectMake(320, 133, rapidCreditBatchDetailVC.view.frame.size.width, rapidCreditBatchDetailVC.view.frame.size.height);
    [self.view addSubview:rapidCreditBatchDetailVC.view];
    [self.view bringSubviewToFront:rapidCreditBatchDetailVC.view];
    
    if (self.ZidForZZ != nil)
    {
        [rapidCreditBatchDetailVC updateRapidCreditBatchDetailWithZID:self.ZidForZZ needToReload:YES];
    }
    else
    {
        [rapidCreditBatchDetailVC updateRapidCreditBatchDetailWithZID:(self.rmsDbController.globalDict)[@"ZId"] needToReload:YES];
    }
    
}

-(void)setSelectButton:(UIButton *)button forView:(UIView *)view
{
    for (UIButton *viewButton in view.subviews) {
        if ([viewButton isEqual:button]) {
            viewButton.selected = YES;
        }
        else
        {
            viewButton.selected = NO;
        }
    }
}

#pragma mark -
#pragma mark Other View Delegate Method

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//hiten

-(IBAction)previewandPrintReport:(id)sender{
    emailView=YES;
    [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.sourcePath]
                                         pathForPDF:@"~/Documents/previewreceiptreport.pdf".stringByExpandingTildeInPath
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

-(BOOL)checkTipShows
{
    BOOL showTips = NO;
    if (self.tipSetting.boolValue == TRUE)
    {
        showTips = YES;
    }
     return showTips;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}
- (CGFloat)roundTo2Decimals:(CGFloat)number {
    CGFloat roundedValue = number;
    roundedValue *= 100.0;
    roundedValue = round(roundedValue);
    roundedValue /= 100.0;
    return roundedValue;
}
-(void)dealloc
{
}

@end

