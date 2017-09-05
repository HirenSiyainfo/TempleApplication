//
//  InvoiceDetail.m
//  POSRetail
//
//  Created by Keyur Patel on 04/07/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import "InvoiceDetail.h"
#import "CKCalendarView.h"
#import <CoreGraphics/CoreGraphics.h>
#import "RmsDbController.h"
#import "RcrController.h"
#import "EmailFromViewController.h"
#import "Item+Dictionary.h"
#import "GroupMaster+Dictionary.h"
#import "Mix_MatchDetail+Dictionary.h"
#import "RasterDocument.h"
#import "StarBitmap.h"
#import "TenderPay.h"
#import  "TenderPay+Dictionary.h"
#import "TipsAdjustmentVC.h"
#import "NDHTMLtoPDF.h"
#import "InvoiceDetailCell.h"
#import "InvoiceData_T+Dictionary.h"
#import "CameraScanVC.h"
#import "POSLoginView.h"
#import "InvoiceVoidPopupVC.h"
#import "TenderViewController.h"
#import "LastInvoiceReceiptPrint.h"
#import "LastGasInvoiceReceiptPrint.h"
#import "LastPostpayGasInvoiceReceiptPrint.h"
#import "CardReceiptPrint.h"
#import "Configuration+Dictionary.h"
#import "PassPrinting.h"
#import "TenderItemTableCustomCell.h"
#import "PrinterFunctions.h"
#import "InvoicePaymentTypeCell.h"
#import "PaxDevice.h"
#import "PaxResponse+Internal.h"
#import "RapidInvoicePrint.h"
#import "DoCreditResponse.h"
#import "ResponseHostInformation.h"
#import "PaxConstants.h"
#import "RCRBillSummary.h"
#import "Department.h"
#import "NSDate+DateFormat.h"
#import "CustomerViewController.h"
#import "RimLoginVC.h"
#import "InitializeResponse.h"
#import "RegisterInfo.h"
#import "UserInfo.h"
#import "HouseChargeReceiptPrint.h"
#import "CustomerLoyaltyVC.h"
#import "Customer.h"

#define TABLE_PAYMENT_TYPE_ROW_HEIGHT 35.0
#define TABLE_PAYMENT_TYPE_ROW_DISPLAY_LIMIT 15



typedef NS_ENUM(NSInteger, InvoicePrintProcess) {
    Invoice_PrintBegin,
    Invoice_PassPrint,
    Invoice_CardPrint,
    Invoice_BillPrint,
    Invoice_PrintDone,
    Invoice_PrintCancel,
};

@interface InvoiceDetail ()<CKCalendarDelegate,TipsAdjustmentVcDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate,CameraScanVCDelegate,LoginResultDelegate,TenderDelegate ,PrinterFunctionsDelegate,PaxDeviceDelegate,RapidInvoicePrintDelegate , EmailFromViewControllerDelegate , CustomerSelectionDelegate>

{
    TipsAdjustmentVC *tipsAdjustmentVC;
    EmailFromViewController *emailFromViewController;
    CKCalendarView *calendar;
    POSLoginView * loginView;
    AppDelegate *appDelegate;
    LastInvoiceReceiptPrint *lastInvoiceRcptPrint;
    CardReceiptPrint *cardRcptPrint;
    InvoiceVoidPopupVC *invPopUpvoid;
    IntercomHandler *intercomHandler;
    RCRBillSummary *rcrBillSummary;
    CustomerViewController *customerVC;
    InvoiceDetail *invoiceDetailView;


    NSDictionary *selectedTipDictionary;
    NSString *lastCalledWebservice;
    NSString *invoiceNoForSelectedInvoice;
    NSString *registerInvoiceNoForSelectedInvoice;
    NSMutableDictionary *selectedRegInvoice;
    CGFloat adjustedTipAmount;
    CGFloat creditLimitValue;
    CGFloat balaceAmount;
    NSNumber *customerIdForHouseCharge;
    NSMutableArray *invtypearray;
    NSMutableArray *invoiceItemarray;
    NSMutableArray *invoiceItemarraytemp;
    NSString *calselectedDate;
    NSDate *selectedCalenderDateForOffline;
    NSArray *array_port;
    NSInteger selectedPort;
    NSMutableArray *refundCheckArray;
    NSInteger invoiceIndexpath;
    NSInteger currentPrintStep;
    NSMutableArray *localInvoiceTicketPassArray;
    NSString *regstrationPrefix;
    NSString *paxSerialNo;
    NSNumber *payId;

    
    NSString *strTodate;
    NSString *strFromDate;

    
    BOOL isVoidInvoice;
    BOOL isTipsSettingEnable;
}

@property (nonatomic, weak) IBOutlet UIView *dummyView;

@property (nonatomic, weak) IBOutlet UIButton *tipsButton;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIImageView *upcBackgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *calendarNextPreviousBackImageView;
@property (nonatomic, weak) IBOutlet UIView *grandTotalBackView;
@property (nonatomic, weak) IBOutlet UIView *itemTableBottomView;
@property (nonatomic, weak) IBOutlet UILabel *grandTotalOfInvoice;
@property (nonatomic, weak) IBOutlet UILabel *tipOfInvoice;
@property (nonatomic, weak) IBOutlet UILabel *lblTips;
@property (nonatomic, weak) IBOutlet UIView *popupContainerView;
@property (nonatomic, weak) IBOutlet UIView *uvCalender;
@property (nonatomic, weak) IBOutlet UIButton *btnNext;
@property (nonatomic, weak) IBOutlet UILabel *lblmonthname;
@property (nonatomic, weak) IBOutlet UILabel *lblItemcount;
@property (nonatomic, weak) IBOutlet UITableView *tblinvtype;
@property (nonatomic, weak) IBOutlet UIButton *btninvtype;
@property (nonatomic, weak) IBOutlet UILabel *lblinvtype;
@property (nonatomic, weak) IBOutlet UIView *uvinvtype;
@property (nonatomic, weak) IBOutlet UIButton *btnCalcender;
@property (nonatomic, weak) IBOutlet UIButton *btn_refund;
@property (nonatomic, weak) IBOutlet UIView *uvBottomView;
@property (nonatomic, weak) IBOutlet UITableView *tblInvoicedetail;
@property (nonatomic, weak) IBOutlet UIView *uvInvoiceItemDetail;
@property (nonatomic, weak) IBOutlet UITableView *tblInvoiceItemdetail;
@property (nonatomic, weak) IBOutlet UITextField *txtBarcode;
@property (nonatomic, weak) IBOutlet UIButton *btnCancel;
@property (nonatomic, weak) IBOutlet UILabel *lblCalenderDetail;
@property (nonatomic, weak) IBOutlet UILabel *lblDiscount;
@property (nonatomic, weak) IBOutlet UILabel *lblSubTotal;
@property (nonatomic, weak) IBOutlet UILabel *lblTaxAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblLastInvoiceNo;
@property (nonatomic, weak) IBOutlet UILabel *lblLasttenderType;
@property (nonatomic, weak) IBOutlet UILabel *lblLastBillAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblLasttenderAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblLastChangeDue;
@property (nonatomic, weak) IBOutlet UILabel *lblFinalPaidAmount;
@property (nonatomic, weak) IBOutlet UIButton *btnLastInvRcpt;
@property (nonatomic, weak) IBOutlet UIButton *btnVoidTransaction;
@property (nonatomic, weak) IBOutlet UILabel *lblInvoiceCount;
@property (nonatomic, weak) IBOutlet UIButton *btnItemKeYboard;
@property (nonatomic, weak) IBOutlet UITextField *keyBoardTextField;
@property (nonatomic, weak) IBOutlet UITableView *tblPaymentType;
@property (nonatomic, weak) IBOutlet UIView *uvPaymentTable;
@property (nonatomic, weak) IBOutlet UILabel *lblVoid;
@property (nonatomic, weak) IBOutlet UILabel *lblCustomerName;
@property (nonatomic, weak) IBOutlet UIButton *btnRemoveCustomer;
@property (nonatomic, weak) IBOutlet UIButton *btnAddCustomer;
@property (nonatomic, weak) IBOutlet UIButton *btnSaveInvoice;

@property(nonatomic,strong) NSString *stradjustedAmount;
@property(nonatomic,strong) NSString *registerInvoiceNumber;
@property (nonatomic, assign)int paxTransactionType;
@property(nonatomic,strong) PaxResponse *response;


@property (nonatomic, strong) UIImage *customerSignatureImage;
@property (nonatomic, strong) NSMutableArray *arrayPaymentTypes;
@property (nonatomic, strong) NSMutableArray *arrayPumpCart;

@property (nonatomic, strong) NSString *strInvoiceZid;
@property (nonatomic, assign) BOOL iscurrentZid;
@property (nonatomic, assign) BOOL isOnlyCreditCardTransaction;
@property (nonatomic, assign) BOOL isOnlyHouseChargeTransaction;
@property (nonatomic, strong) NSString *moduleIdentifierString;
@property (nonatomic, strong) NSString *strVoidMessage;
@property (nonatomic, strong) NSMutableArray *InvRcptDetail;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatterMonth;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSArray *disabledDates;
@property (nonatomic, strong) NSMutableArray *invoicearray;
@property (nonatomic, strong) NSString *strInvoiceNoGloble;
@property (nonatomic, strong) NSString *strInvoiceNumber;
@property (nonatomic, strong) NSString *strinvoiceDate;
@property (nonatomic, strong) NSString *cardReciptHtml;
@property (nonatomic, strong) NSString *strinvoiceTime;
@property (nonatomic, strong) NSNumber  *tipSetting;
@property (nonatomic, strong) NSMutableArray *invoiceDetailArray;
@property (nonatomic, strong) NSString *emailReciptHtml;
@property (nonatomic, strong) NSMutableDictionary *emailTempDictionary;
@property (nonatomic, strong) NSMutableArray *paymentModesarray;
@property (nonatomic, strong) NSMutableArray *globalInvoiceArray;

@property (nonatomic, strong) UIDocumentInteractionController *controller;
@property (nonatomic, strong) UIViewController * delegateView;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RapidWebServiceConnection *voidCreditCardTransctionWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *voidFromBackEndWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *voidCreditCardRapidServerWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *voidHouseChargeWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *outSidePayVoideInvoiceWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *deleteOutSideCartWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *invoiceItemDetailWebseviceConnnection;
@property (nonatomic, strong) RapidWebServiceConnection *invoiceDetailBarcodeWC;
@property (nonatomic, strong) RapidWebServiceConnection *invoiceItemDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *invoiceDetailConnection;
@property (nonatomic, strong) RapidWebServiceConnection *reloadInvoiceDetailConnection;
@property (nonatomic, strong) RapidWebServiceConnection *invoiceDetailDateWiseConnection;
@property (nonatomic, strong) RapidWebServiceConnection *reloadInvoiceDetailDateWiseConnection;
@property (nonatomic, strong) RapidWebServiceConnection *tipAdjustmentWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *tipAdjustmentFromInvoiceWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *voidTransDetailsWC;
@property (nonatomic, strong) RapidWebServiceConnection *invoiceDetailBarcodeWC2;
@property (nonatomic, strong) RapidWebServiceConnection *tipsAdjustmentInvoiceWC;
@property (nonatomic, strong) RapidWebServiceConnection *addCustomerToInvoice;
@property (nonatomic, strong) RapidWebServiceConnection *creditCardAutoConnection;
@property (nonatomic, strong) RapidWebServiceConnection *creditCardAutoConnection2;
@property (nonatomic, strong) RapidWebServiceConnection *CheckHouseChargeCreditLimitWC;


@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) Configuration *configuration;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, strong) PaxDevice *paxDevice;
@property (nonatomic, strong) CKCalendarView *calendar;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) RimsController *_rimController;
@property (nonatomic ,weak) id<CustomerLoyaltyVCDelegate> customerLoyaltyVCDelegate;




@end

@implementation InvoiceDetail
@synthesize delegateView,lblItemcount,InvRcptDetail,strInvoiceNoGloble,appDelegate;
@synthesize managedObjectContext = __managedObjectContext,strInvoiceZid,iscurrentZid;
@synthesize moduleIdentifierString,arrayPumpCart;

@synthesize uvCalender,calendar,lblmonthname,tblInvoicedetail,invoicearray,strinvoiceDate,strinvoiceTime;
@synthesize customerSignatureImage;


- (instancetype)init {
    self = [super init];
    if (self) {
     
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)localeDidChange {
    self.calendar.locale = [NSLocale currentLocale];
}

- (BOOL)isTipSettingEnable:(NSNumber *)tipSetting
{
    BOOL isTipSettingEnable;
    return  isTipSettingEnable = tipSetting.boolValue;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.lblVoid.transform = CGAffineTransformMakeRotation(-M_PI / 4);
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.uvPaymentTable.hidden = YES;
    self.globalInvoiceArray = [[NSMutableArray alloc]init];
    calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:nil];

    self.invoiceDetailArray = [[NSMutableArray alloc]init];
    rcrBillSummary = [[RCRBillSummary alloc] init];

    
    // Webservice call object intialize
    self.invoiceDetailConnection = [[RapidWebServiceConnection alloc] init];
    self.invoiceDetailDateWiseConnection = [[RapidWebServiceConnection alloc] init];
    self.reloadInvoiceDetailConnection = [[RapidWebServiceConnection alloc] init];
    self.reloadInvoiceDetailDateWiseConnection = [[RapidWebServiceConnection alloc] init];
    self.tipAdjustmentWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    self.creditCardAutoConnection = [[RapidWebServiceConnection alloc]init];
    self.voidCreditCardTransctionWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    self.voidFromBackEndWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    self.voidCreditCardRapidServerWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    self.tipAdjustmentFromInvoiceWebserviceConnection = [[RapidWebServiceConnection alloc] init];
    self.outSidePayVoideInvoiceWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.voidTransDetailsWC = [[RapidWebServiceConnection alloc] init];
    self.invoiceDetailBarcodeWC2 = [[RapidWebServiceConnection alloc] init];
    self.invoiceItemDetailWC = [[RapidWebServiceConnection alloc] init];
    self.tipsAdjustmentInvoiceWC = [[RapidWebServiceConnection alloc] init];
    self.addCustomerToInvoice = [[RapidWebServiceConnection alloc]init];
    self.CheckHouseChargeCreditLimitWC = [[RapidWebServiceConnection alloc]init];

    self.calendar = calendar;
    calendar.delegate = self;
    
    _uvInvoiceItemDetail.hidden = YES;
    self.isOnlyCreditCardTransaction = YES;
    self.isOnlyHouseChargeTransaction = true;
    [_txtBarcode becomeFirstResponder];
    
    _dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    //_txtBarcode.inputView = _dummyView;

    self.arrayPaymentTypes = [[NSMutableArray alloc]init];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateFormatter.dateFormat = @"MMM dd, yyyy";
    
    self.dateFormatterMonth = [[NSDateFormatter alloc] init];
    self.dateFormatterMonth.timeStyle = NSDateFormatterNoStyle;
    self.dateFormatterMonth.dateFormat = @"LLLL yyyy";
    
    self.minimumDate = [self.dateFormatter dateFromString:@"20/09/2012"];
    isVoidInvoice = FALSE;
    
    lblmonthname.text = [self.dateFormatterMonth stringFromDate:calendar.monthShowing];
    invoiceIndexpath = -1;
    calendar.onlyShowCurrentMonth = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    
    calendar.frame = CGRectMake(5, 5, 645, 630); // change calender width and height
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        
        tblInvoicedetail.separatorInset = UIEdgeInsetsZero;
        _tblInvoiceItemdetail.separatorInset = UIEdgeInsetsZero;
        _tblinvtype.separatorInset = UIEdgeInsetsZero;
    }
    // set today date
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    
    components.hour = -components.hour;
    components.minute = -components.minute;
    components.second = -components.second;
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0];
    //_lblCalenderDetail.text = _lblinvtype.text;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"MM/dd/yyyy";
    NSString *TodayDate = [dateFormat stringFromDate:today];
    _lblCalenderDetail.text = [NSString stringWithFormat:@"%@",TodayDate];
    
    strFromDate = [NSString stringWithFormat:@"%@ 12:00 am", TodayDate];
    strTodate = [NSString stringWithFormat:@"%@ 11:59 pm", TodayDate];
   
    _btnVoidTransaction.enabled = NO;
    
    [self.view addSubview:_popupContainerView];
    _popupContainerView.hidden = YES;
    // end today date
   
    
    // Stretch image of Background view
    _upcBackgroundImageView.image = [[UIImage imageNamed:@"RCR_Invoice_patch.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,0,50)];

    // Register nib for tableView
    [self.tblInvoicedetail registerNib:[UINib nibWithNibName:@"InvoiceDetailCell" bundle:nil] forCellReuseIdentifier:@"InvoiceDetailCell"];
    [_tblInvoiceItemdetail registerNib:[UINib nibWithNibName:@"InvoiceItemCustomCell" bundle:nil] forCellReuseIdentifier:@"InvoiceItemCell"];
    [_tblinvtype registerNib:[UINib nibWithNibName:@"InvoicePaymentTypeCell" bundle:nil] forCellReuseIdentifier:@"InvoicePaymentTypeCell"];
    [self.tblPaymentType registerNib:[UINib nibWithNibName:@"InvoicePaymentTypeCell" bundle:nil] forCellReuseIdentifier:@"InvoicePaymentTypeCell"];

    
    _calendarNextPreviousBackImageView.layer.cornerRadius = 17.0;
    _lblInvoiceCount.layer.cornerRadius = 18.0;
    [self setCornerRadiusForView:_uvinvtype withCornerRadius:10.0 withBorderWidth:2.0 withBorderColor:[UIColor colorWithRed:20.0/255 green:34.0/255 blue:61.0/255.0 alpha:1.0]];
    [self setCornerRadiusForView:self.uvPaymentTable withCornerRadius:10.0 withBorderWidth:2.0 withBorderColor:[UIColor colorWithRed:20.0/255 green:34.0/255 blue:61.0/255.0 alpha:1.0]];
    [self setCornerRadiusForView:_uvBottomView withCornerRadius:8.0 withBorderWidth:0.0 withBorderColor:[UIColor colorWithRed:20.0/255 green:34.0/255 blue:61.0/255.0 alpha:1.0]];
    [self setCornerRadiusForView:_itemTableBottomView withCornerRadius:8.0 withBorderWidth:0.0 withBorderColor:[UIColor colorWithRed:20.0/255 green:34.0/255 blue:61.0/255.0 alpha:1.0]];
    [self setCornerRadiusForView:_grandTotalBackView withCornerRadius:8.0 withBorderWidth:0.0 withBorderColor:[UIColor colorWithRed:20.0/255 green:34.0/255 blue:61.0/255.0 alpha:1.0]];



    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    invtypearray = [[NSMutableArray alloc]initWithObjects:@"Today",@"Yesterday",@"This Week",@"Last Week",@"This Month",@"Last Month", nil];
    _lblinvtype.text = invtypearray.firstObject;
    _uvinvtype.hidden = YES;
    [_tblinvtype reloadData];
 
    self.strVoidMessage = @"";
    
    [self fetchPaymentTypes];


    
    [self.uvCalender addSubview:calendar];
    _btnCalcender.hidden = YES;
    refundCheckArray = [[NSMutableArray alloc]init];
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];

    selectedPort = 0;
    
    _btnLastInvRcpt.userInteractionEnabled = FALSE;
    
    [self GetInvoiceData];
  
    self.configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext ];
    regstrationPrefix = self.configuration.regPrefixNo;
    self.tipSetting= self.configuration.localTipsSetting;
    Configuration *configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext ];
    isTipsSettingEnable = [self isTipSettingEnable:configuration.localTipsSetting];
    _tipsButton.hidden = YES;
    if (isTipsSettingEnable == false) {
        _lblTips.hidden = YES;
        _tipOfInvoice.hidden = YES;
    }
    
    [self setCurrencyFormatterToBottomLabel];
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    _btnAddCustomer.hidden = YES;
    _btnRemoveCustomer.hidden = YES;
    _lblCustomerName.hidden = YES;
    _btnSaveInvoice.hidden = YES;

    if ([[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"] isEqualToString:@"Pax"])
    {
        [self configurePaxDevice];
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)configurePaxDevice
{
    NSDictionary *dictDevice = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceConfig"];
    if (dictDevice != nil)
    {
        NSString *paxDeviceIP = dictDevice [@"PaxDeviceIp"];
        NSString *paxDevicePort = dictDevice [@"PaxDevicePort"];
        self.paxDevice = [[PaxDevice alloc] initWithIp:paxDeviceIP port:paxDevicePort];
        self.paxDevice.paxDeviceDelegate = self;
        [self.paxDevice initializeDevice];
    }
}

- (void)setCurrencyFormatterToBottomLabel
{
    _lblLasttenderAmount.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
    _lblLastBillAmount.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
    _lblLastChangeDue.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
}

-(void)didCancelTransaction
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:@"ClearAllRecord" forKey:@"Tender"];
    [self.crmController writeDictionaryToCustomerDisplay:dict];
}

-(void)setCornerRadiusForView:(id)view1 withCornerRadius:(CGFloat)cornerRadius withBorderWidth:(CGFloat )borderWidth withBorderColor:(UIColor *)borderColor
{
    UIView *view = (UIView *)view1;
    view.layer.borderWidth = borderWidth;
    view.layer.borderColor = borderColor.CGColor;
    view.layer.cornerRadius = cornerRadius;
}

+ (void)setPortName:(NSString *)m_portName
{
    [RcrController setPortName:m_portName];
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    [RcrController setPortSettings:m_portSettings];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _uvinvtype.hidden = YES;
    self.uvPaymentTable.hidden = YES;
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
    [InvoiceDetail setPortName:localPortName];
    [InvoiceDetail setPortSettings:array_port[selectedPort]];
}
-(void)GetInvoiceData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:_lblinvtype.text forKey:@"WType"];
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSString *strDate = [NSString stringWithFormat:@"%@",destinationDate];
    param[@"Datetime"] = strDate;
    [param setValue:@"0" forKey:@"RowIndex"];
    lastCalledWebservice = WSM_INVOICE_LIST;

//    CompletionHandler completionHandler = ^(id response, NSError *error) {
//        [self responseInvoiceResponse:response error:error];
//    };
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseInvoiceResponse:response error:error];
        });
    };
    
    self.invoiceDetailConnection = [self.invoiceDetailConnection initWithRequest:KURL actionName:WSM_INVOICE_LIST params:param completionHandler:completionHandler];

}
-(void)GetInvoiceDatewiseData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    _uvinvtype.hidden = YES;
    self.uvPaymentTable.hidden = YES;
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:calselectedDate forKey:@"sDate"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:@"0" forKey:@"RowIndex"];

    lastCalledWebservice = WSM_INVOICE_LIST_DATEWISE;

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseInvoiceDatewiseResponse:response error:error];
        });
    };

    self.invoiceDetailDateWiseConnection = [self.invoiceDetailDateWiseConnection initWithRequest:KURL actionName:WSM_INVOICE_LIST_DATEWISE params:param completionHandler:completionHandler];
    
}
- (void)responseInvoiceDatewiseResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            [self.invoicearray removeAllObjects];
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(responseArray.count>0)
                {
                    self.invoicearray = responseArray;
                    _lblCalenderDetail.text = calselectedDate;
                    [self.globalInvoiceArray removeAllObjects];
                    self.globalInvoiceArray = [self.invoicearray mutableCopy];
                }
                else
                {
                    _lblCalenderDetail.text = calselectedDate;
                }
            }
            _lblCalenderDetail.text = calselectedDate;
            _lblInvoiceCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.invoicearray.count];
            invoiceIndexpath = -1;
            
        }
    }
    else
    {
        self.invoicearray = [[NSMutableArray alloc]init];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:( NSCalendarUnitDay ) fromDate:[[NSDate alloc] init]];
        NSDate *today = selectedCalenderDateForOffline;
        components.day = 1;
        NSDate *tomorrowDate = [cal dateByAddingComponents:components toDate: today options:0];
        NSPredicate *filterDateWisePredicate = [NSPredicate predicateWithFormat:@"invoiceDate > %@ AND invoiceDate < %@ ",today,tomorrowDate];
        
        NSArray *offlineObjectForInvoice = [self fetchInvoiceObjectFromDatabaseWithPredicate:filterDateWisePredicate];
        for (InvoiceData_T *invoice_Data in offlineObjectForInvoice)
        {
            [self.invoicearray addObject:[invoice_Data invoiceDetailDictionary]];
        }
        _lblInvoiceCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.invoicearray.count];

    }
    [self.tblInvoicedetail reloadData];
}


-(NSArray *)fetchInvoiceObjectFromDatabaseWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    if (predicate!=nil)
    {
        fetchRequest.predicate = predicate;
    }
    NSArray *invoiceDataObject = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return invoiceDataObject;
}

- (void)responseInvoiceResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            [self.invoicearray removeAllObjects];
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray   *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(responseArray.count>0)
                {
                    self.invoicearray = responseArray;
                    [self.globalInvoiceArray removeAllObjects];
                    self.globalInvoiceArray = [self.invoicearray mutableCopy];
                }
            }
        }
    }
    else
    {
        self.invoicearray = [[NSMutableArray alloc]init];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:( NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitWeekday ) fromDate:[[NSDate alloc] init]];
        NSPredicate *filterDateWisePredicate = [self selectedDateWithDateComponets:components withCalender:cal] ;
        NSArray *offlineObjectForInvoice = [self fetchInvoiceObjectFromDatabaseWithPredicate:filterDateWisePredicate];
        for (InvoiceData_T *invoice_Data in offlineObjectForInvoice)
        {
            [self.invoicearray addObject:[invoice_Data invoiceDetailDictionary]];
        }
    }
    _lblInvoiceCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.invoicearray.count];
    invoiceIndexpath = -1;
    [self.tblInvoicedetail reloadData];
}

-(NSPredicate *)predicateFromStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate
{
    return [NSPredicate predicateWithFormat:@"invoiceDate > %@ AND invoiceDate < %@ ",startDate,endDate];
}
-(NSPredicate *)predicateFromStartDateForMonth:(NSDate *)startDate withEndDate:(NSDate *)endDate
{
    return [NSPredicate predicateWithFormat:@"invoiceDate > %@ AND invoiceDate <= %@ ",startDate,endDate];
}


-(NSDate *)convertDateInToDateFormat:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd";
    NSString *stringToDate = [dateFormat stringFromDate:date];
    NSDate *dateToConvert = [dateFormat dateFromString:stringToDate];
    return dateToConvert;
}

-(NSDate *)dateFormatFromDate:(NSDate *)date
{
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy";
    NSString *stringDate = [formatter stringFromDate:date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    dateFormatter.timeZone = sourceTimeZone;
    return [dateFormatter dateFromString:stringDate];
}


-(NSPredicate *)selectedDateWithDateComponets:(NSDateComponents *)component withCalender:(NSCalendar *)calender
{
     NSPredicate *predicate;
    if([_lblinvtype.text isEqualToString:@"Today"])
    {
//        NSCalendar *cal = [NSCalendar currentCalendar];
//        NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
//        NSDate *date = [self dateFormatFromDate:[NSDate date]];
//        components.day = 1;
//        NSDate *tomorrowDate = [cal dateByAddingComponents:components toDate: date options:0];
//        return  [self predicateFromStartDate:date withEndDate:tomorrowDate];
        
        NSDate *today = [NSDate selectDay:[NSDate date] withDays:1];
        return  [self predicateFromStartDate:[self dateFormatFromDate:[NSDate date]] withEndDate:[self dateFormatFromDate:today]];
        
    }
    else if([_lblinvtype.text isEqualToString:@"Yesterday"])
    {
//        NSCalendar *cal = [NSCalendar currentCalendar];
//        NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
//        NSDate *today = [self dateFormatFromDate:[NSDate date]];
//        components.day = -1;
//        NSDate *yesterDayDate = [cal dateByAddingComponents:components toDate: today options:0];
//        return  [self predicateFromStartDate:yesterDayDate withEndDate:today];
//        NSDate *date = [self dateFormatFromDate:[NSDate date]];
        
        NSDate *yesterday = [NSDate selectDay:[NSDate date] withDays:-1];
        return  [self predicateFromStartDate:[self dateFormatFromDate:yesterday] withEndDate:[self dateFormatFromDate:[NSDate date]]];
        
    }
    else if([_lblinvtype.text isEqualToString:@"This Week"])
    {
        return[self predicateFromStartDate:[self dateFormatFromDate:[NSDate startDateOfCurrentWeek]] withEndDate:[self dateFormatFromDate:[NSDate endDateOfCurrentWeek]]];
    }
    else if([_lblinvtype.text isEqualToString:@"Last Week"])
    {
        return[self predicateFromStartDate:[self dateFormatFromDate:[NSDate startDateOfLastWeek]] withEndDate:[self dateFormatFromDate:[NSDate startDateOfCurrentWeek]]];
      
    }
    else if([_lblinvtype.text isEqualToString:@"This Month"])
    {
        NSDate *date = [NSDate date];
        NSDateStorage *dates = [date dateOfMonth:0];

        return [self predicateFromStartDateForMonth:[self dateFormatFromDate:dates.firstDate] withEndDate:[self dateFormatFromDate:dates.lastDate]];
    }
    
    else if([_lblinvtype.text isEqualToString:@"Last Month"])
    {
        
        NSDate *date = [NSDate date];
        NSDateStorage *dates = [date dateOfMonth:1];
        
        return [self predicateFromStartDateForMonth:[self dateFormatFromDate:dates.firstDate] withEndDate:[self dateFormatFromDate:dates.lastDate]];
        
    }
    
    else if([_lblinvtype.text isEqualToString:@"Custome Date"])
    {
    }
    
    else
    {
        
    }
    return predicate;
}

- (NSDate *)returnDateForMonth:(NSInteger)month year:(NSInteger)year day:(NSInteger)day {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    components.day = day;
    components.month = month;
    components.year = year;
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorian dateFromComponents:components];
}

- (void)responseInvoiceDatewise:(NSNotification *)notification {
    NSMutableArray * responseData = notification.object;
    [_activityIndicator hideActivityIndicator];
    if (notification.object!= nil)
    {
        if ([[notification.object valueForKey:WSM_INVOICE_LIST_DATEWISE_RESPONSEKEY] count] > 0)
        {
            [self.invoicearray removeAllObjects];
            if ([[[notification.object valueForKey:WSM_INVOICE_LIST_DATEWISE_RESPONSEKEY]  valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray   *responseArray = [self.rmsDbController objectFromJsonString:[[responseData valueForKey:WSM_INVOICE_LIST_DATEWISE_RESPONSEKEY]  valueForKey:@"Data"]];
                if(responseArray.count>0)
                {
                    self.invoicearray = responseArray;
                    _lblCalenderDetail.text = calselectedDate;
                    [self.globalInvoiceArray removeAllObjects];
                    self.globalInvoiceArray = [self.invoicearray mutableCopy];
                }
                else
                {
                    _lblCalenderDetail.text = calselectedDate;
                }
            }
            _lblCalenderDetail.text = calselectedDate;
            _lblInvoiceCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.invoicearray.count];
            invoiceIndexpath = -1;
        }
    }
    else
    {
        self.invoicearray = [[NSMutableArray alloc]init];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:( NSCalendarUnitDay ) fromDate:[[NSDate alloc] init]];
        NSDate *today = selectedCalenderDateForOffline;
        components.day = 1;
        NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
        NSPredicate *filterDateWisePredicate = [NSPredicate predicateWithFormat:@"invoiceDate > %@ AND invoiceDate < %@ ",today,yesterday];
        NSArray *offlineObjectForInvoice = [self fetchInvoiceObjectFromDatabaseWithPredicate:filterDateWisePredicate];
        for (InvoiceData_T *invoice_Data in offlineObjectForInvoice)
        {
            [self.invoicearray addObject:[invoice_Data invoiceDetailDictionary]];
        }
    }
    [self.tblInvoicedetail reloadData];
}

-(void)didSelectCustomerWithDetail:(RapidCustomerLoyalty *)rapidCustomerLoyalty customerDictionary:(NSDictionary *)customerDictionary withIsCustomerFromHouseCharge:(BOOL)isCustomerFromHouseCharge withIscollectPay:(BOOL)isCollectPay
{
    [loginView.view removeFromSuperview];
    _lblCustomerName.text = rapidCustomerLoyalty.customerName;
    _btnSaveInvoice.hidden = NO;
    _btnRemoveCustomer.hidden = NO;
    _lblCustomerName.hidden = NO;
    _rcrRapidCustomerLoayalty =  rapidCustomerLoyalty;
    [_btnRemoveCustomer setHidden:NO];
//    [customerVC.view removeFromSuperview];
}

- (IBAction)btnCustomerClick:(id)sender
{
    
    loginView = [[POSLoginView alloc] initWithNibName:@"POSVoidInvoiceLogin" bundle:nil];
    loginView.navigationController.navigationBar.hidden=YES;
    loginView.loginResultDelegate=self;
    loginView.view.frame = CGRectMake(0, 0, 1024, 768);
    loginView.isInvoiceCustomerRights = YES;
    [self.view addSubview:loginView.view];
}
- (IBAction)RemoveCustomer:(id)sender
{
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self hideCustomerView];
        _rcrRapidCustomerLoayalty = nil;
        
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to remove this customer?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(IBAction)saveInvoicedetail:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:_strInvoiceNumber forKey:@"InvoiceId"];
    [itemparam setValue:_rcrRapidCustomerLoayalty.custId forKey:@"CustId"];
 
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self addCustomerToInvoiceResponse:response error:error];
    };
    
    self.addCustomerToInvoice = [self.addCustomerToInvoice initWithRequest:KURL actionName:WSM_ADD_CUSTOMER_TO_INVOICE params:itemparam completionHandler:completionHandler];
    
}

- (void)addCustomerToInvoiceResponse:(id)response error:(NSError *)error{
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {

                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {

                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Customer is successfully attached with invoice" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
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
    [_activityIndicator hideActivityIndicator];
}

-(void)hideCustomerView{
    _lblCustomerName.text = @"";
    [_btnRemoveCustomer setHidden:YES];
    //    self.crmController.custName = @"";
    //    self.crmController.custId = @"";
    
}


-(IBAction)btnNextClick:(id)sender
{
    [calendar _moveCalendarToNextMonth];
}
-(IBAction)btnPreviousClick:(id)sender
{
    [calendar _moveCalendarToPreviousMonth];
}

-(IBAction)btnPaymentTypeDropDownClick:(id)sender
{
    self.uvPaymentTable.hidden = NO;
}

-(void)fetchPaymentTypes
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;

    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    [self.arrayPaymentTypes removeAllObjects];
    if(object.count>0)
    {
        for (TenderPay *tenderpay in object)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            dict[@"Payid"] = tenderpay.payId;
            dict[@"PaymentName"] = tenderpay.paymentName;
            [self.arrayPaymentTypes addObject:dict];

        }
    }
    NSMutableDictionary *dictvoid = [[NSMutableDictionary alloc]init];
    dictvoid[@"Payid"] = @"0";
    dictvoid[@"PaymentName"] = @"void Trans.";
    [self.arrayPaymentTypes addObject:dictvoid];

    
    NSInteger intPaymentCount = self.arrayPaymentTypes.count ;
    if (self.arrayPaymentTypes.count > TABLE_PAYMENT_TYPE_ROW_DISPLAY_LIMIT)
    {
        intPaymentCount = TABLE_PAYMENT_TYPE_ROW_DISPLAY_LIMIT;
    }
    self.tblPaymentType.frame = CGRectMake(self.tblPaymentType.frame.origin.x, 10, self.tblPaymentType.frame.size.width,(intPaymentCount*TABLE_PAYMENT_TYPE_ROW_HEIGHT)+10);
    self.uvPaymentTable.frame = CGRectMake(self.uvPaymentTable.frame.origin.x, self.uvPaymentTable.frame.origin.y, self.uvPaymentTable.frame.size.width,self.tblPaymentType.frame.size.height+10);
    [self.tblPaymentType reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _tblinvtype)
    {
    return invtypearray.count;
    }
    
    else if(tableView == tblInvoicedetail)
    {
        return invoicearray.count;
    }

    else if(tableView == self.tblPaymentType){
        return self.arrayPaymentTypes.count;
    }
    else
    {
        return invoiceItemarray.count;
    }
}

- (UILabel *)configureInvoiceListLabel:(CGRect)lableRect lableColor:(UIColor *)lableColor textAllignMent:(NSInteger)textAllignMent textColor:(UIColor *)textColor lableFont:(UIFont *)lableFont lableTag:(NSInteger)lableTag
{
    UILabel *label;
    label = [[UILabel alloc] initWithFrame:lableRect];
    label.backgroundColor = lableColor;
    label.textAlignment = textAllignMent;
    label.textColor = textColor;
    label.font = lableFont;
    label.tag = lableTag;
    return label;
}



- (void)configureInvoiceDetailWithOnlineDetail:(InvoiceDetailCell *)invoiceDetailCell indexPath:(NSIndexPath *)indexPath
{
    invoiceDetailCell.backgroundColor = [UIColor clearColor];
    if (self.invoicearray.count > 0) {
        
        NSDictionary *invoiceDictAtIndexpath = self.invoicearray[indexPath.row];
        
        if ([invoiceDictAtIndexpath valueForKey:@"payName"] != [NSNull null] &&[[invoiceDictAtIndexpath valueForKey:@"payName"] isEqualToString:@"void Trans."])
        {
            invoiceDetailCell.voidLable.hidden = NO;
        }
        else{
            invoiceDetailCell.voidLable.hidden = YES;
        }
        
        
        if ([invoiceDictAtIndexpath valueForKey:@"ChangeDue"] != [NSNull null])
        {
            NSNumber *numerPrice=@([[invoiceDictAtIndexpath valueForKey:@"ChangeDue"] floatValue]);
            NSString *sPrice =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:numerPrice]];
            invoiceDetailCell.change.text = sPrice;
        }
        else
        {
            invoiceDetailCell.change.text = @"No Due Change.";
        }
        invoiceDetailCell.registerInvoiceNo.text = [NSString stringWithFormat:@"%@",[invoiceDictAtIndexpath valueForKey:@"RegisterInvNo"]];
        
        
        if (!([[invoiceDictAtIndexpath valueForKey:@"InvoiceDate"] rangeOfString:@"/Date" options:NSCaseInsensitiveSearch].length > 0))
        {
            invoiceDetailCell.dateTime.text = [NSString stringWithFormat:@"%@",[invoiceDictAtIndexpath valueForKey:@"InvoiceDate"]];
        }
        else
        {
            NSDate *date = [self jsonStringToNSDate:[invoiceDictAtIndexpath valueForKey:@"InvoiceDate"]];
            NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
            formatterDate.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
            formatterDate.dateFormat = @"MM/dd/yyyy";
            NSString *stringFromDate = [formatterDate stringFromDate:date];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
            formatter.dateFormat = @"hh:mm a";
            NSString *stringFromtime = [formatter stringFromDate:date];
            
            NSString *strFinaldateTime = [NSString stringWithFormat:@"%@ & %@",stringFromDate,stringFromtime];
            invoiceDetailCell.dateTime.text = [NSString stringWithFormat:@"%@",strFinaldateTime];
            
        }
        
        NSString *strAccNo = [invoiceDictAtIndexpath valueForKey:@"AccNo"];
        if (strAccNo.length > 0)
        {
            NSString *strDisplayAccNo = @"";
            NSArray *arrAccNo = [strAccNo componentsSeparatedByString:@","];
            for (int i = 0; i < arrAccNo.count; i++)
            {
                NSString *strTemp = arrAccNo[i];
                strTemp = [strTemp substringFromIndex:MAX((int)[strTemp length]-4, 0)];
                strDisplayAccNo = [strDisplayAccNo stringByAppendingString:[NSString stringWithFormat:@"%@,",strTemp]];
            }
            strDisplayAccNo = [strDisplayAccNo substringToIndex:strDisplayAccNo.length - 1];
            invoiceDetailCell.payment.text = [NSString stringWithFormat:@"%@ - %@",[invoiceDictAtIndexpath valueForKey:@"payName"],strDisplayAccNo];
        }
        else
        {
            invoiceDetailCell.payment.text = [NSString stringWithFormat:@"%@",[invoiceDictAtIndexpath valueForKey:@"payName"]];
        }
        
        NSNumber *numPrice=@([[invoiceDictAtIndexpath valueForKey:@"BillAmount"] floatValue]);
        NSString *billPrice =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:numPrice]];
        invoiceDetailCell.total.text = billPrice;
        
        
        
        if (indexPath.row == self.invoicearray.count - 1)
        {
            if(self.invoicearray.count % 30 == 0)
            {
                [self reloadMoreDataInTableView];
            }
        }
        
    }
}


-(IBAction)voidTransaction:(id)sender{
    BOOL hasRights = [UserRights hasRights:UserRightVoidTransaction];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to void transaction. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    else
    {
            self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            loginView = [[POSLoginView alloc] initWithNibName:@"POSVoidInvoiceLogin" bundle:nil];
            loginView.navigationController.navigationBar.hidden=YES;
            loginView.loginResultDelegate=self;
            loginView.view.frame = CGRectMake(0, 0, 1024, 768);
            [self.view addSubview:loginView.view];
    }
    
}
-(void)customerLoyalty
{
    BOOL hasRights = [UserRights hasRights:UserRightCustomerLoyalty];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You don't have customer loyalty rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        [loginView.view removeFromSuperview];
        [self.rmsDbController playButtonSound];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        customerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CustomerViewController"];
        customerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        customerVC.customerSelectionDelegate = self;
        customerVC.isFromDashBoard = NO;
        customerVC.view.frame = self.view.bounds;
//        [self presentViewAsModalForInvoiceVoid:customerVC.view];
        [self.navigationController pushViewController:customerVC animated:YES];

    }

}

-(void)userDidLogin:(NSMutableDictionary *)userdict
{
    [loginView.view removeFromSuperview];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    invPopUpvoid = [storyBoard instantiateViewControllerWithIdentifier:@"InvoiceVoidPopupVC"];
    invPopUpvoid.invoiceVoidePopUpDelegate = self;
    [self presentViewAsModalForInvoiceVoid:invPopUpvoid.view];
}
-(NSString *)updateTransactionIdWithInvoiceNo:(NSString *)invoiceNo
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMddyyHHmmss";
    NSString *strDate = [formatter stringFromDate:date];
    NSLog(@"strDate = %@",strDate);
   return   [NSString stringWithFormat:@"%@_%@",regstrationPrefix,strDate];
}

-(void)paxVoidTransactionProcess
{
    if (!self.paxDevice) {
        return;
    }
    NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
    NSString *registerInvoiceNo = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"RegisterInvNo"]];
    NSDictionary *invoicePaymentDetailDictionary = self.paymentModesarray.firstObject;
    
    //        NSDictionary *paxAdditionalFieldDictionary = [self.rmsDbController objectFromJsonString:[[self.paymentModesarray firstObject] valueForKey:@"GatewayResponse"]];
    //        [self.paxDevice voidCreditTransactionNumber:@"1234" invoiceNumber:registerInvoiceNo referenceNumber:[self updateTransactionIdWithInvoiceNo:registerInvoiceNo]];
    //        return;
    if (invoicePaymentDetailDictionary) {
        if (invoicePaymentDetailDictionary[@"TransactionNo"]) {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            self.paxDevice.pdResonse = PDResponseDoCash;
            [self.paxDevice voidCreditTransactionNumber:invoicePaymentDetailDictionary[@"TransactionNo"] invoiceNumber:registerInvoiceNo referenceNumber:[invoicePaymentDetailDictionary valueForKey:@"TransactionId"]];
        }
    }
}

- (void)paxDevice:(PaxDevice*)paxDevice willSendRequest:(NSString*)request
{
    
}

- (void)paxDevice:(PaxDevice*)paxDevice failed:(NSError*)error response:(PaxResponse *)response
{
    NSString *infoMessage = @"Pax response error";
    NSString *errorMessage = [NSString stringWithFormat:@"%@",response.responseMessage];
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [_activityIndicator hideActivityIndicator];
    };
    [self.rmsDbController popupAlertFromVC:self title:infoMessage message:errorMessage buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
}

- (void)paxDevice:(PaxDevice*)paxDevice isConncted:(BOOL)isConncted
{
    
}

- (void)paxDeviceDidTimeout:(PaxDevice*)paxDevice
{
    
}

- (void)paxDevice:(PaxDevice*)paxDevice response:(PaxResponse*)response
{
    if ([response isKindOfClass:[InitializeResponse class]]) {
        InitializeResponse *initializeResponse = (InitializeResponse *)response;
        if (initializeResponse.responseCode.integerValue == 0) {
            dispatch_async(dispatch_get_main_queue(),  ^{
                paxSerialNo = [NSString stringWithFormat:@"%@",initializeResponse.serialNumber];
            });
        }
    }
    else {
        
        if (response.responseCode.integerValue == 0) {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            NSMutableDictionary *itemVoid = [[NSMutableDictionary alloc]init];
            [itemVoid setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
            NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
            NSString *strInvoiceNO = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"InvoiceNo"]];
            
            self.registerInvoiceNumber = strInvoiceNO;
            
            [itemVoid setValue:strInvoiceNO forKey:@"InvoiceNo"];
            [itemVoid setValue:self.strVoidMessage forKey:@"Reason"];
            itemVoid[@"GatewayResponse"] = [NSString stringWithFormat:@"%@",[self.rmsDbController jsonStringFromObject:[self parseCreditCardResponse:response]]];
            itemVoid[@"TransactionId"] = @"";
            DoCreditResponse *cr = (DoCreditResponse *)response;
            
            dispatch_async(dispatch_get_main_queue(),  ^{
                [self paxCreditCardLogWithDetail:[self insertPaxCreditCardLogWithDetail:[self parseCreditCardResponse:response] withCreditCardAdditionalDetail:cr.additionalInformation]];
            });
        
            AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
                [self insertVoidInvoiceResponse:response error:error];
            };
            
            self.voidFromBackEndWebserviceConnection = [self.voidFromBackEndWebserviceConnection initWithAsyncRequest:KURL actionName:WSM_INSERT_VOID_INVOICE params:itemVoid asyncCompletionHandler:asyncCompletionHandler];
        }
        else
        {
            NSString *infoMessage = @"Pax void response error";
            NSString *errorMessage = [NSString stringWithFormat:@"%@",response.responseMessage];
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [_activityIndicator hideActivityIndicator];
            };
            [self.rmsDbController popupAlertFromVC:self title:infoMessage message:errorMessage buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
        }
    }
}

#pragma mark Pax Credit Card Log Detail

-(NSMutableDictionary *)insertPaxCreditCardLogWithDetail:(NSDictionary *)creditcardDetail withCreditCardAdditionalDetail:(NSMutableDictionary *)additionalDetailDict

{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];

    NSString *sInvAmt = creditcardDetail[@"ApprovedAmount"];
    //    NSString *sInvAmtRemove=[NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:sInvAmt].floatValue];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    
    
    NSMutableDictionary *paxResponceDict = [[NSMutableDictionary alloc]init];
    paxResponceDict[@"CreditcardDetail"] = creditcardDetail;
    
    if (additionalDetailDict != nil)
    {
        paxResponceDict[@"AdditionalDetailDict"] = additionalDetailDict;
    }
    else
    {
        paxResponceDict[@"AdditionalDetailDict"] = @"";
    }
    
    dict[@"Id"] = @(0);
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"TransactionId"] = creditcardDetail[@"TransactionNo"];
    dict[@"TransType"] = creditcardDetail[@"TransactionType"];
    dict[@"Amount"] = sInvAmt;
    dict[@"InvNum"] = self.registerInvoiceNumber;
    dict[@"MagData"] = @"";
    dict[@"ExtData"] = @"";
    dict[@"RespMSG"] = @"OK";
    
    dict[@"Message"] = @"OK";
    dict[@"AuthCode"] = [creditcardDetail valueForKey:@"AuthCode"];
    dict[@"HostCode"] = [creditcardDetail valueForKey:@"HostReferenceNumber"];
    dict[@"CommercialCard"] = @"";
    dict[@"GateWayType"] = @"Pax";
    dict[@"Response"] = [NSString stringWithFormat:@"%@",[self.rmsDbController jsonStringFromObject:paxResponceDict]];
    dict[@"CreatedDate"] = currentDateTime;
    dict[@"CardNo"] = @"";
    dict[@"DeviceNo"] = [NSString stringWithFormat:@"%@",paxSerialNo];
    return dict;
}


-(void)paxCreditCardLogWithDetail:(NSMutableDictionary *)paxResponseDict
{
    
    NSMutableDictionary *objCreditCardAuto = [[NSMutableDictionary alloc]init];
    objCreditCardAuto[@"objCreditCardAuto"] = paxResponseDict;
    
    NSLog(@"JSON PAX%@", [self.rmsDbController jsonStringFromObject:objCreditCardAuto]);
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self CreditCardAutoResponse:response error:error];
    };
    
    self.creditCardAutoConnection = [self.creditCardAutoConnection initWithRequest:KURL actionName:WSM_CREDIT_CARD_LOG params:objCreditCardAuto completionHandler:completionHandler];
    
}
- (void)CreditCardAutoResponse:(id)response error:(NSError *)error
{
    if(self.paxTransactionType == 05){
        
        if (response != nil) {
            if ([response isKindOfClass:[NSDictionary class]]) {
                if ([[response valueForKey:@"IsError"] intValue] == 0)
                {
                    
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        [invoiceItemarray removeAllObjects];
                        [_tblInvoiceItemdetail reloadData];
                        [self GetInvoiceData];
                        _btnVoidTransaction.enabled=NO;
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Invoice Capture Successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else if ([[response valueForKey:@"IsError"] intValue] == 1)
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else {
                    
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please try again later." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
        }
   
    }
}



-(NSMutableDictionary *)parseCreditCardResponse:(PaxResponse *)response
{
    self.response = response;
    DoCreditResponse *cr = (DoCreditResponse *)response;
    NSMutableDictionary *creditcardResponseDictionary = [[NSMutableDictionary alloc] init];
    if (cr.responseCode.integerValue == 0) {

        ResponseHostInformation *responseHostInformation = (ResponseHostInformation *)cr.hostInformation;
        creditcardResponseDictionary[@"AuthCode"] = [NSString stringWithFormat:@"%@",responseHostInformation.authCode];
        creditcardResponseDictionary[@"TransactionNo"] = [NSString stringWithFormat:@"%@",cr.transactionNumber];
        creditcardResponseDictionary[@"AccNo"] = [NSString stringWithFormat:@"%@",cr.accountNumber];
        creditcardResponseDictionary[@"CardType"] = [NSString stringWithFormat:@"%@",[self cardTypeOf:cr.cardType.integerValue]];
        creditcardResponseDictionary[@"ExpireDate"] = [NSString stringWithFormat:@"%@",cr.expiryDate];
        creditcardResponseDictionary[@"CardHolderName"] = [NSString stringWithFormat:@"%@",cr.cardHolder];
        creditcardResponseDictionary[@"RefundTransactionNo"] = @"0.00";
        creditcardResponseDictionary[@"GatewayType"] = @"Pax";
        creditcardResponseDictionary[@"IsCreditCardSwipe"] = @"1";
        creditcardResponseDictionary[@"CreditTransactionId"] = @"";
        creditcardResponseDictionary[@"EntryMode"] = [NSString stringWithFormat:@"%@",cr.entryMode];
        
        creditcardResponseDictionary[@"TransactionType"] = [NSString stringWithFormat:@"%@",cr.transactionType];
        
        self.paxTransactionType = [creditcardResponseDictionary[@"TransactionType"] intValue];
        
        if([creditcardResponseDictionary[@"TransactionType"] intValue] == 05){
           
            creditcardResponseDictionary[@"Gas"] = @"InvoiceCapture";
            creditcardResponseDictionary[@"AmountCapture"] = self.stradjustedAmount;
            creditcardResponseDictionary[@"ApprovedAmount"] = self.stradjustedAmount;
        }
        else if([creditcardResponseDictionary[@"TransactionType"] intValue] == 17){
            
            creditcardResponseDictionary[@"Invoice"] = @"Void";

        }
        NSDictionary *additionalCreditCardDetail = cr.additionalInformation;
        creditcardResponseDictionary[@"HostReferenceNumber"] = [NSString stringWithFormat:@"%@",responseHostInformation.hostReferenceNumber];
        creditcardResponseDictionary[@"AppName"] = [self valueForKey:@"APPPN" ForDictionary:additionalCreditCardDetail];
        creditcardResponseDictionary[@"AID"] = [self valueForKey:@"AID" ForDictionary:additionalCreditCardDetail];
        creditcardResponseDictionary[@"ARQC"] = [self valueForKey:@"TC" ForDictionary:additionalCreditCardDetail];
        creditcardResponseDictionary[@"RemainingBalance"] = [self valueForKey:@"RemainingBalance" ForDictionary:additionalCreditCardDetail];
        creditcardResponseDictionary[@"CVM"] = [self valueForKey:@"CVM" ForDictionary:additionalCreditCardDetail];
    }
    return creditcardResponseDictionary;
}




-(NSString *)valueForKey:(NSString *)key ForDictionary:(NSDictionary *)paxAdditionalFieldsDictionary
{
    NSString *value = @"";
    if ([paxAdditionalFieldsDictionary valueForKey:key]) {
        value = [paxAdditionalFieldsDictionary valueForKey:key];
    }
    return value;
}


-(NSString *)cardTypeOf:(NSInteger)cardType
{
    NSString *creditCardType = @"";
    switch (cardType) {
        case VisaCard:
            creditCardType = @"VISA";
            break;
        case MasterCard:
            creditCardType = @"MASTER";
            break;
        case  AMEX:
            creditCardType = @"AMEX";
            break;
        case  Discover:
            creditCardType = @"Discover";
            break;
        case  DinerClub:
            creditCardType = @"DinerClub";
            break;
        case enRoute:
            creditCardType = @"enRoute";
            break;
        case  JCB :
            creditCardType = @"JCB";
            break;
        case RevolutionCard:
            creditCardType = @"RevolutionCard";
            break;
            
        default:
        case  OTHER:
            creditCardType = @"OTHER";
            
            break;
    }
    return creditCardType;
}


- (BOOL)isCreditTransaction:(NSString*)code {
    NSRange range = [code rangeOfString:@"T01"];
    return range.location != NSNotFound;
}
- (BOOL)isDebitTransaction:(NSString*)code {
    NSRange range = [code rangeOfString:@"T03"];
    return range.location != NSNotFound;
}
- (BOOL)isEbtTransaction:(NSString*)code {
    NSRange range = [code rangeOfString:@"T05"];
    return range.location != NSNotFound;
}

- (BOOL)isIntialize:(NSString*)code {
    NSRange range = [code rangeOfString:@"A01"];
    return range.location != NSNotFound;
}

-(void)didsendVoidMessage :(NSString *)message{
    
    self.strVoidMessage = message;
    [self removeVoidMessagePopup];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        if(self.isOnlyCreditCardTransaction){
            if([self currentZid])
            {
                if(self.arrayPumpCart.count > 0 && [self.arrayPumpCart[0][@"TransactionType"] isEqualToString:@"OUTSIDE-PAY"]){
                    
                    [self outsidePayInvoiceVoideProcess];
                }
                else
                {
                    if ([[self.paymentModesarray.firstObject valueForKey:@"GatewayType"] isEqualToString:@"Pax"]) {
                        [self paxVoidTransactionProcess];
                    }
                    else
                    {
                        [self creditCardVoidTransactionProcess];
                    }
                }
            }
            else
            {
                [self makeRefundAllInvoiceItem];
            }
        }
        else if (self.isOnlyHouseChargeTransaction) {
            //Perfom Void process for House Charge
            [self houseChargeVoidTransactionProcess];
        }
        else
        {
            [self makeRefundAllInvoiceItem];
        }
        
    };
    NSString *strInvoice = [NSString stringWithFormat:@"Confirm to void this invoice no:%@",[selectedRegInvoice valueForKey:@"RegisterInvNo"]];
    
    [self.rmsDbController popupAlertFromVC:self title:@"Message" message:strInvoice buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(void)didCancelInvoicePopup{
    
    [self removeVoidMessagePopup];
}

- (void)removeVoidMessagePopup
{
    for (UIView *presentView in _popupContainerView.subviews)
    {
        [presentView removeFromSuperview];
    }
    _popupContainerView.hidden = YES;
}


- (void)presentViewAsModalForInvoiceVoid :(UIView *)presentView
{
    presentView.center = _popupContainerView.center;
    [_popupContainerView addSubview:presentView];
    _popupContainerView.hidden = NO;
    [self.view bringSubviewToFront:_popupContainerView];
}


-(BOOL)currentZid{
    
    self.iscurrentZid = FALSE;
    
    NSInteger intZid = [(self.rmsDbController.globalDict)[@"ZId"]integerValue];
    if(intZid == strInvoiceZid.integerValue)
   {
       self.iscurrentZid = TRUE;
   }
    else{
       
        self.iscurrentZid = FALSE;
    }
    return self.iscurrentZid;
    
}

-(void)makeRefundAllInvoiceItem{
    
    invoiceItemarraytemp  = [[NSMutableArray alloc]init];
    
    for(int i=0;i<invoiceItemarray.count;i++){
        
        NSMutableDictionary *dict = [invoiceItemarray[i]mutableCopy];
        [invoiceItemarraytemp addObject:dict];
    }
    
    for(int i=0;i<invoiceItemarraytemp.count;i++){
    
        NSMutableDictionary *dict = invoiceItemarraytemp[i];
        
        if(dict[@"IdexPath"]){
            [dict removeObjectForKey:@"IdexPath"];
            [refundCheckArray removeLastObject];
        }
        else{
            dict[@"IdexPath"] = [NSString stringWithFormat:@"%ld",(long)i];
            [refundCheckArray addObject:@"1"];
        }
        invoiceItemarraytemp[i] = dict;
    }
    [refundCheckArray removeAllObjects];
    for (int i = 0; i<invoiceItemarraytemp.count; i++)
    {
        //NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] initWithDictionary:[invoiceItemarray objectAtIndex:((NSIndexPath *)[invoiceItemarray objectAtIndex:i]).row]];
        
        NSMutableDictionary * tempDict = invoiceItemarraytemp[i];
        
        tempDict[@"ReasonType"] = @"Void";
        tempDict[@"Reason"] = self.strVoidMessage;
        
//if(tempDict[@"IdexPath"])
       // {
            
            CGFloat itemPrice = [tempDict[@"itemPrice"] floatValue];
            if(itemPrice < 0 || [[[tempDict valueForKey:@"item"] valueForKey:@"isExtraCharge"] boolValue]== TRUE || [[[tempDict valueForKey:@"item"] valueForKey:@"isCheckCash"] boolValue] == TRUE)
            {
                
            }
            else
            {
                float QtyDisCount=[[tempDict valueForKey:@"ItemDiscount"] floatValue];
                float perQtyDiscount = QtyDisCount/[[tempDict valueForKey:@"itemQty"] floatValue];
                tempDict[@"ItemDiscount"] = [NSString stringWithFormat:@"-%.2f",perQtyDiscount];
                tempDict[@"DeptTypeId"] = [tempDict valueForKey:@"DeptTypeId"];

                
                if ([tempDict[@"ItemBasicPrice"] floatValue] > [[tempDict valueForKey:@"itemPrice"] floatValue])
                {
                    tempDict[@"PriceAtPos"] = [NSString stringWithFormat:@"-%.2f",[[tempDict valueForKey:@"itemPrice"] floatValue]];
                    tempDict[@"IsQtyEdited"] = @"0";
                    
                    float ItemDisCount= ([tempDict[@"ItemBasicPrice"] floatValue] * [tempDict[@"itemQty"] intValue]) - ([[tempDict valueForKey:@"itemPrice"] floatValue] * [tempDict[@"itemQty"] intValue]);
                    tempDict[@"ItemDiscount"] = [NSString stringWithFormat:@"-%.2f", ItemDisCount ];
                    float  totalItemPercenatge = ItemDisCount / [tempDict[@"ItemBasicPrice"] floatValue] *100;
                    tempDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
                }
                else if ([tempDict[@"ItemBasicPrice"] floatValue] < [[tempDict valueForKey:@"itemPrice"] floatValue])
                {
                    tempDict[@"PriceAtPos"] = [NSString stringWithFormat:@"-%.2f",[[tempDict valueForKey:@"itemPrice"] floatValue]];
                    tempDict[@"IsQtyEdited"] = @"0";
                    
                }
                else if ([tempDict[@"ItemBasicPrice"] floatValue] == [[tempDict valueForKey:@"itemPrice"] floatValue])
                {
                    [tempDict removeObjectForKey:@"PriceAtPos"];
                }
                
                if (tempDict[@"InvoiceVariationdetail"]) {
                    NSMutableArray *variationdetail = [tempDict valueForKey:@"InvoiceVariationdetail"];
                    for (int var = 0; var < variationdetail.count; var++) {
                        NSMutableDictionary *varDict = variationdetail[var];
                        float price = [[varDict valueForKey:@"Price"]floatValue];
                        [varDict setValue:[NSString stringWithFormat:@"-%.2f",price] forKey:@"Price"];
                        [varDict setValue:[NSString stringWithFormat:@"-%.2f",price] forKey:@"VariationBasicPrice"];
                    }
                    [tempDict setValue:[tempDict valueForKey:@"InvoiceVariationdetail"] forKey:@"InvoiceVariationdetail"];
                }
                
                if (tempDict[@"VariationAmount"]) {
                    [tempDict setValue:[NSString stringWithFormat:@"-%.2f",[[tempDict valueForKey:@"VariationAmount"]floatValue]] forKey:@"TotalVarionCost"];
                }
                if (tempDict[@"RetailAmount"]) {
                    [tempDict setValue:[NSString stringWithFormat:@"-%.2f",[[tempDict valueForKey:@"RetailAmount"]floatValue]] forKey:@"RetailAmount"];
                }
                
                
                
                tempDict[@"ItemBasicPrice"] = [NSString stringWithFormat:@"-%@",[tempDict valueForKey:@"ItemBasicPrice"]];
                tempDict[@"itemPrice"] = @(-itemPrice);
                
                tempDict[@"PackageType"] = [tempDict valueForKey:@"PackageType"];
                tempDict[@"PackageQty"] = [tempDict valueForKey:@"PackageQty"];

                NSString *strItemId=[NSString stringWithFormat:@"%ld",(long)[[tempDict valueForKey:@"itemId"] integerValue]];
                Item *anitem=[self fetchItemObjects:strItemId];
                if(anitem.itemGroupMaster.groupId)
                {
                    tempDict[@"categoryId"] = anitem.itemGroupMaster.groupId;
                    
                }
                else
                {
                    tempDict[@"categoryId"] = @"0";
                    
                }
                if(anitem.itemMixMatchDisc.mixMatchId)
                {
                    tempDict[@"mixMatchId"] = anitem.itemMixMatchDisc.mixMatchId;
                }
                else
                {
                    tempDict[@"mixMatchId"] = @"0";
                    
                }
                
                [tempDict setValue:[tempDict valueForKey:@"ItemMemo"] forKey:@"Memo"];
                
                
                tempDict[@"IsQtyEdited"] = @"0";
                tempDict[@"ItemDiscountPercentage"] = @(0);
                tempDict[@"ItemExternalDiscount"] = @(0);
                tempDict[@"ItemInternalDiscount"] = @(0);
                if (perQtyDiscount > 0)
                {
                    tempDict[@"ItemWiseDiscountValue"] = [NSString stringWithFormat:@"%f",perQtyDiscount];
                    tempDict[@"ItemWiseDiscountType"] = @"Amount";
                }
                
                NSMutableArray *itemTaxDetail = [[tempDict valueForKey:@"ItemTaxDetail"]mutableCopy];
                if(itemTaxDetail.count>0)
                {
                    for (int i = 0; i<itemTaxDetail.count; i++)
                    {
                        NSMutableDictionary *Dict = [itemTaxDetail[i]mutableCopy];
                        NSString *strItemTaxAmount = Dict[@"ItemTaxAmount"];
                        float ftAmount = strItemTaxAmount.floatValue;
//                        float ftTaxAmount = ftAmount/[[tempDict valueForKey:@"itemQty"] floatValue];
                        NSString *strSetAmount = [NSString stringWithFormat:@"-%.2f",ftAmount];
                        Dict[@"ItemTaxAmount"] = strSetAmount;
                        itemTaxDetail[i] = Dict;
                    }
                    tempDict[@"ItemTaxDetail"] = itemTaxDetail;
                }
                
                float ftAmount = [tempDict[@"itemTax"] floatValue];
               // float ftTaxAmount = ftAmount/[[tempDict valueForKey:@"itemQty"] floatValue];
                
                tempDict[@"itemTax"] = @(-ftAmount);
                
                if([tempDict valueForKey:@"item"] != nil) {
                    
                    [tempDict valueForKey:@"item"][@"isRefund"] = @"YES";
                }
                if([tempDict valueForKey:@"itemDetails"] != nil)
                {
                    if ([[tempDict valueForKey:@"itemDetails"] isKindOfClass:[NSMutableArray class]])
                    {
                        [[tempDict valueForKey:@"itemDetails"] firstObject][@"SellingPrice"] = [NSString stringWithFormat:@"-%@",[[[tempDict valueForKey:@"itemDetails"] firstObject] valueForKey:@"SellingPrice"]];
                        [[tempDict valueForKey:@"itemDetails"] firstObject][@"TaxAmount"] = [NSString stringWithFormat:@"-%@",[[[tempDict valueForKey:@"itemDetails"] firstObject] valueForKey:@"TaxAmount"]];
                    }
                }
                 [tempDict setValue:[self createInvoicePumpCartDict:[tempDict valueForKey:@"InvoicePumpCart"]] forKey:@"InvoicePumpCart"];
                [self.invoiceDetailArray addObject:tempDict];
            }
      //  }
    }

    if (self.invoiceDetailDelegate)
    {

            if(self.isOnlyCreditCardTransaction){
                [self tenderTransactionWithTenderType:@"Credit" withPayId:payId];
            }
            else{
                [self tenderTransactionWithTenderType:@"" withPayId:@(0)];
            }
        
    }
    
}

- (BOOL)allPaymentOptionDisable
{
    NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig"];
    NSPredicate * filterTenderPrediacte = [NSPredicate predicateWithFormat:@"SpecOption == %@",@"11"];
    BOOL allPaymentOptionDisable = FALSE;
    
    NSArray  *filterTenderDisablearray = [arrTemp filteredArrayUsingPredicate:filterTenderPrediacte];
    if (filterTenderDisablearray.count > 0) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        
        if (resultSet.count == filterTenderDisablearray.count)
        {
            allPaymentOptionDisable = TRUE;
            
        }
    }
    return allPaymentOptionDisable;
}

-(void)tenderTransactionWithTenderType :(NSString *)tenderType withPayId:(NSNumber *)payID
{
    NSMutableArray *reciptArray = [self.invoiceDetailArray mutableCopy];
    [rcrBillSummary updateBillSummrayWithDetail:reciptArray];

    [self.invoiceDetailArray removeAllObjects];
    if(reciptArray.count>0)
    {
        BOOL allPaymentOptionDisable;
        allPaymentOptionDisable = [self allPaymentOptionDisable];
        if (allPaymentOptionDisable)
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"All payment options are disabled. Please enable at least one payment option." buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
            return;
        }
        
        //        NSMutableArray *tenderArray = [reciptArray mutableCopy];
        //        [tenderArray addObject:[[self setSubTotalsToDictionary] mutableCopy]];
        //        NSDictionary *tenderDictionary = @{kPosTenderKey: tenderArray};
        //        [Appsee addEvent:kPosTender withProperties:tenderDictionary];
        
        TenderViewController *tenderview=[[TenderViewController alloc] initWithNibName:@"TenderViewController" bundle:nil];
        self.crmController.singleTap1.enabled=NO;
        tenderview.receiptDataArray = reciptArray;
        tenderview.billItemDetailString = [self billItemDetailStringForOrder:reciptArray];
        tenderview.tenderDelegate = self;
        NSMutableDictionary *dictAmoutInfo = [[self setSubTotalsToDictionaryForReciptArray:reciptArray] mutableCopy];
        tenderview.dictAmoutInfo = dictAmoutInfo;
     //   tenderview.rcrBillSummary = rcrBillSummary;
        tenderview.tenderType = tenderType;
        tenderview.payId = payID;
        tenderview.isVoidForInvoice = TRUE;
        tenderview.tenderItemCount = reciptArray.count;

        if(self.paymentModesarray.count>0){
            tenderview.paymentForVoid = [self.paymentModesarray mutableCopy];
        }
        tenderview.tenderReciptDataAry  = reciptArray;
        tenderview.checkcashAmount = [self totalCheckCashForBillOrderArray:reciptArray];
//        if ([[self moduleIdentifier] isEqualToString:@"RcrPosRestaurantVC"])
//        {
//            tenderview.restaurantOrderTenderObjectId = self.restaurantOrderObjectId;
//        }
        if ([self totalCheckCashForBillOrderArray:reciptArray] != 0)
        {
            tenderview.isCheckCashApplicableAplliedToBill = TRUE;
        }
        else
        {
            tenderview.isCheckCashApplicableAplliedToBill = FALSE;
        }
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        double delayInSeconds = 0.3;
        self.view.userInteractionEnabled = NO;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.view.userInteractionEnabled = YES;
            [_activityIndicator hideActivityIndicator];
            [self.navigationController pushViewController:tenderview animated:YES];
        });
        
        NSMutableArray *array = [reciptArray mutableCopy];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:@"ShowTender" forKey:@"Tender"];
        [dict setValue:array forKey:@"BillEntries"];
        [dict setValue:dictAmoutInfo forKey:@"TenderSubTotals"];
        [self.crmController writeDictionaryToCustomerDisplay:dict];
        
    }
}

- (NSString *)billItemDetailStringForOrder:(NSMutableArray *)reciptArray
{
    NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
    itemDictionary[@"BillItemDetail"] = reciptArray;
    itemDictionary[@"IsBillDiscountApplicable"] = @(0);
    itemDictionary[@"BillDiscountType"] = @(1);
    
    NSString *jsonStringOfBillData = [self.rmsDbController jsonStringFromObject:itemDictionary];
    return jsonStringOfBillData;
}

-(void)didFinishTransactionSuccessFully{
    
    [self GetInvoiceData];

}
-(void)didFailTransaction{
    
}

-(NSString *)moduleIdentifier
{
    return self.moduleIdentifierString;
}

-(CGFloat)totalCheckCashForBillOrderArray:(NSMutableArray *)reciptArray
{
    CGFloat totalCheckCashAmount = 0.00;
    for (int i = 0; i < reciptArray.count; i++)
    {
        NSDictionary *itemDictionary = [reciptArray[i] valueForKey:@"item"];
        
        BOOL isChargeCashvalue=[itemDictionary[@"isCheckCash"] boolValue];
        
        if (isChargeCashvalue == TRUE)
        {
            totalCheckCashAmount += [[reciptArray[i] valueForKey:@"itemPrice"] floatValue];
        }
    }
    return totalCheckCashAmount;
}
- (NSMutableDictionary *)setSubTotalsToDictionaryForReciptArray:(NSMutableArray *)dataArray
{
    NSMutableDictionary *dictAmoutInfo = [[NSMutableDictionary alloc]init];
    
    NSString *strSubTotal = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:rcrBillSummary.totalSubTotalAmount]];
    NSString *strTotalTax = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:rcrBillSummary.totalTaxAmount]];
    NSString *strTotalDiscount = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:rcrBillSummary.totalDiscountAmount]];
    float total = rcrBillSummary.totalSubTotalAmount.floatValue + rcrBillSummary.totalTaxAmount.floatValue;
    NSNumber *totalBillAmount= @(total);
    NSString *strTotalBillAmount = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:totalBillAmount]];
    
    CGFloat finalamount = [self.rmsDbController removeCurrencyFomatter:strTotalBillAmount];
    CGFloat subtotal = [self.rmsDbController removeCurrencyFomatter:strSubTotal];
    CGFloat taxamount = [self.rmsDbController removeCurrencyFomatter:strTotalTax];
    CGFloat discount = [self.rmsDbController removeCurrencyFomatter:strTotalDiscount];
    
    [dictAmoutInfo setValue:[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%.2f",finalamount]] forKey:@"InvoiceTotal"];
    [dictAmoutInfo setValue:[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%.2f",subtotal]] forKey:@"InvoiceSubTotal"];
    [dictAmoutInfo setValue:[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%.2f",taxamount]] forKey:@"InvoiceTax"];
    [dictAmoutInfo setValue:[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%.2f",discount]] forKey:@"InvoiceDiscount"];
    if (dataArray.count > 0)
    {
        NSString *strCount = [NSString stringWithFormat:@"%ld",(long)[[dataArray valueForKeyPath:@"@sum.itemQty"] integerValue]];
        dictAmoutInfo[@"TotalItemCount"] = strCount;
    }
    else
    {
        dictAmoutInfo[@"TotalItemCount"] = @"0";
    }
    return dictAmoutInfo;
}

- (NSString *)getCurrentDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    return currentDateTime;
}

- (void)houseChargeVoidTransactionProcess {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
    dictParam[@"BranchId"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
    NSString *strInvoiceNO = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"InvoiceNo"]];
    dictParam[@"InvoiceNo"] = strInvoiceNO;
    dictParam[@"Amount"] = [self.paymentModesarray.firstObject valueForKey:@"BillAmount"];
    dictParam[@"RegisterId"] = [NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterId"]];
    dictParam[@"UserId"] = [NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"]];
    dictParam[@"Remarks"] = self.strVoidMessage;
    dictParam[@"LocalDate"] = [self getCurrentDate];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self voidInvoiceProcessResponse:response error:error];
    };
    
    self.voidHouseChargeWebserviceConnection = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_HOUSE_CHARGE_VOID_INVOICE_PROCESS params:dictParam completionHandler:completionHandler];
}

-(void)creditCardVoidTransactionProcess{
    
    NSInteger intPayid = [[self.paymentModesarray.firstObject valueForKey:@"PayId"]integerValue];
    
    NSString *strTransactionServer = [self transctionServerForSpecOptionforPaymentId:intPayid];
    
    if([strTransactionServer isEqualToString:@"BRIDGEPAY"]){
        
        [self processVoidForBidgepay];
        
    }
    else{
        [self voidCraditCardProcessthroughRapidServer];
    }

}

#pragma mark -

-(void)voidCraditCardProcessthroughRapidServer{
    

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    
    dictParam[@"TransType"] = @"Void";
    dictParam[@"Reason"] = self.strVoidMessage;
    dictParam[@"Amount"] = [self.paymentModesarray.firstObject valueForKey:@"BillAmount"];
    dictParam[@"PNRef"] = [self.paymentModesarray.firstObject valueForKey:@"TransactionNo"];
    
    dictParam[@"InvNum"] = [selectedRegInvoice valueForKey:@"RegisterInvNo"];
    
    NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
    NSString *strInvoiceNO = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"InvoiceNo"]];
    
    dictParam[@"InvoiceNo"] = strInvoiceNO;
    
    NSString *extData = [NSString stringWithFormat:@"<TransactionID><Target>%@</Target></TransactionID>",[self.paymentModesarray.firstObject valueForKey:@"TransactionNo"]];
    
    dictParam[@"ExtData"] = extData;
    
    dictParam[@"BranchId"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    
    dictParam[@"LocalDate"] = currentDateTime;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self voidInvoiceProcessResponse:response error:error];
    };
    
    self.voidCreditCardRapidServerWebserviceConnection = [self.voidCreditCardRapidServerWebserviceConnection initWithRequest:KURL_PAYMENT actionName:WSM_BRIDGE_VOID_INVOICE_PROCESS params:dictParam completionHandler:completionHandler];
    
}

- (void)voidInvoiceProcessResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                
                NSString *strMsg = [NSString stringWithFormat:@"%@", [response valueForKey:@"Data"]];
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [invoiceItemarray removeAllObjects];
                    [_tblInvoiceItemdetail reloadData];
                    [self GetInvoiceData];
                    _btnVoidTransaction.enabled=NO;
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:strMsg buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please try again later." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

#pragma mark - Outside Pay Invoice Void Process
-(void)outsidePayInvoiceVoideProcess{

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    
    dictParam[@"TransType"] = @"Void";
    dictParam[@"Reason"] = self.strVoidMessage;
    dictParam[@"Amount"] = [self.paymentModesarray.firstObject valueForKey:@"BillAmount"];
    dictParam[@"PNRef"] = [self.paymentModesarray.firstObject valueForKey:@"TransactionNo"];
    
    dictParam[@"InvNum"] = [selectedRegInvoice valueForKey:@"RegisterInvNo"];
    
    NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
    NSString *strInvoiceNO = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"InvoiceNo"]];
    
    dictParam[@"InvoiceNo"] = strInvoiceNO;
    
    NSString *extData = [NSString stringWithFormat:@"<TransactionID><Target>%@</Target></TransactionID>",[self.paymentModesarray.firstObject valueForKey:@"TransactionNo"]];
    
    dictParam[@"ExtData"] = extData;
    
    dictParam[@"BranchId"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    
    dictParam[@"LocalDate"] = currentDateTime;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self outsidePayInvoiceVoideProcessResponse:response error:error];
    };
    
    self.voidCreditCardRapidServerWebserviceConnection = [self.voidCreditCardRapidServerWebserviceConnection initWithRequest:KURL_PAYMENT actionName:@"BridgepayOutSideVoidInvoiceProcess" params:dictParam completionHandler:completionHandler];
    
}

- (void)outsidePayInvoiceVoideProcessResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                
                NSString *strMsg = [NSString stringWithFormat:@"%@", [response valueForKey:@"Data"]];
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [invoiceItemarray removeAllObjects];
                    [_tblInvoiceItemdetail reloadData];
                    [self GetInvoiceData];
                    if(self.arrayPumpCart.count > 0 && [self.arrayPumpCart.firstObject[@"TransactionType"] isEqualToString:@"OUTSIDE-PAY"]){
                        [self deletePumpCartDataWebServiceCall];
                    }
                    _btnVoidTransaction.enabled=NO;
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:strMsg buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please try again later." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}
#pragma mark - Delete Failed PumpCart Service Code
-(void)deletePumpCartDataWebServiceCall{
    
    NSDictionary *pumpCartDict = self.arrayPumpCart.firstObject;
    self.deleteOutSideCartWebServiceConnection =[[RapidWebServiceConnection alloc]init];
    if (pumpCartDict) {
        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
        dictParam[@"PumpId"] = pumpCartDict[@"PumpId"];
        dictParam[@"CartId"] = pumpCartDict[@"CartId"];;
        dictParam[@"BranchId"] = [RmsDbController sharedRmsDbController].globalDict[@"BranchID"];
        
        AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
            [self pumpCartDeleteResponse:response error:error];
        };
        
        self.deleteOutSideCartWebServiceConnection = [self.deleteOutSideCartWebServiceConnection initWithAsyncRequest:KURL actionName:@"DeletePumpCart" params:dictParam asyncCompletionHandler:asyncCompletionHandler];
    }
}
- (void)pumpCartDeleteResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            //    [_activityIndicator hideActivityIndicator];
        }
    }
}


#pragma mark -

-(NSString *)transctionServerForSpecOptionforPaymentId:(NSInteger)paymentId
{
    NSString *applicableTransctionServer = @"";
    for(int i = 0;i<self.crmController.globalArrTenderConfig.count;i++)
    {
        int itender=[[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"PayId" ] intValue ];
        if(paymentId==itender)
        {
            NSInteger paymentServerSpecOption = [[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"] intValue ];
            switch (paymentServerSpecOption)
            {
                case SPEC_RAPID_SERVER:
                    applicableTransctionServer = @"RAPID CONNECT";
                    break;
                case SPEC_BRIDGEPAY_SERVER:
                    applicableTransctionServer = @"BRIDGEPAY";
                    break;
                default:
                    
                    break;
            }
        }
    }
    return applicableTransctionServer;
}



-(void)processVoidForBidgepay
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSString *strInvId = [self.paymentModesarray.firstObject valueForKey:@"TransactionNo"];
    
    NSString *strVoidAmount = [self.paymentModesarray.firstObject valueForKey:@"BillAmount"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self processVoidForCurrenTransctionId:strInvId withAmount:strVoidAmount];
    });
    self.rmsDbController.isVoidTrasnaction = FALSE;
    
}
-(void)processVoidForCurrenTransctionId:(NSString *)currentTransctionId withAmount:(NSString *)amount
{
    NSLog(@"processVoidForCurrenTransctionId");
    
    NSString *extData = [NSString stringWithFormat:@"<TransactionID><Target>%@</Target></TransactionID>",currentTransctionId];
    
    NSString *strTranType = @"Void";
    NSString *transDetails;
    
   transDetails  = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=%@&InvNum=&PNRef=%@&Zip=&Street=&CVNum=&ExtData=%@",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],strTranType,amount,currentTransctionId,extData];
    
    NSLog(@"transDetails = %@",transDetails);
    
    
    [self processVoidTransaction:[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"URL"] details:transDetails];

}
- (void)processVoidTransaction:(NSString *)url details:(NSString *)details
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",@"ProcessCreditCard"]];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseCreditCardVoidTransctionInvoiceResponse:response error:error];
        });
    };
    
    self.voidCreditCardTransctionWebserviceConnection = [self.voidCreditCardTransctionWebserviceConnection initWithAsyncRequestURL:url withDetailValues:details asyncCompletionHandler:asyncCompletionHandler];

    NSLog(@"url = %@",url);
}
-(NSString *)jsonStringForBridgePayVoidRespone:(NSString *)response
{
    NSMutableString *stringResult = [NSMutableString stringWithString:response];
    
    [self removeNameSpace: @" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://TPISoft.com/SmartPayments/\"" result:stringResult];
    
    NSString *authCode = [self bridgePayResponseValueForPath:@"/Response/AuthCode" forResponseString:stringResult];
    NSString *transaction = [self bridgePayResponseValueForPath:@"/Response/PNRef" forResponseString:stringResult];

    NSMutableDictionary *bridgePayVoidDictionary = [[NSMutableDictionary alloc] init];
    bridgePayVoidDictionary[@"AuthCode"] = authCode;
    bridgePayVoidDictionary[@"PNRef"] = transaction;
    return [self.rmsDbController jsonStringFromObject:bridgePayVoidDictionary];

}
-(NSString *)bridgePayResponseValueForPath:(NSString *)path forResponseString:(NSString *)responseString
{
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];

    DDXMLNode *rootNode = [document rootElement];
    
    NSArray *resultNode = [rootNode nodesForXPath:path error:nil];
    DDXMLElement *pumpElement;
    if (resultNode != nil && resultNode.count > 0) {
      pumpElement = resultNode[0];
    }
    NSString *strResult = [NSString stringWithFormat:@"%@",[pumpElement stringValue]];
    return strResult;
}

-(void)responseCreditCardVoidTransctionInvoiceResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    NSLog(@"responseCreditCardVoidTransctionInvoiceResponse = %@",response);
    
    if (response != nil) {
        if ([response isKindOfClass:[NSString class]]) {
            NSLog(@"responseString : %@",response);
            if ([self getResultofCreditCard:response] == 0 || [self getResultofCreditCard:response] == 108)
            {
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                NSMutableDictionary *itemVoid = [[NSMutableDictionary alloc]init];
                [itemVoid setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
                NSString *strInvoiceNO = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"InvoiceNo"]];
                
                [itemVoid setValue:strInvoiceNO forKey:@"InvoiceNo"];
                [itemVoid setValue:self.strVoidMessage forKey:@"Reason"];
                [itemVoid setValue:[self jsonStringForBridgePayVoidRespone:response] forKey:@"GatewayResponse"];
                [itemVoid setValue:@"" forKey:@"TransactionId"];
                
                AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self insertVoidInvoiceResponse:response error:error];
                    });
                };
                
                self.voidFromBackEndWebserviceConnection = [self.voidFromBackEndWebserviceConnection initWithAsyncRequest:KURL actionName:WSM_INSERT_VOID_INVOICE params:itemVoid asyncCompletionHandler:asyncCompletionHandler];
                
                _btnVoidTransaction.enabled = NO;
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [_activityIndicator hideActivityIndicator];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please try again later." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}
-(NSInteger)getResultofCreditCard:(NSString *)result
{
    
    NSMutableString *stringResult = [NSMutableString stringWithString:result];
    
    [self removeNameSpace: @" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://TPISoft.com/SmartPayments/\"" result:stringResult];
    
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:stringResult options:0 error:nil];
    
    DDXMLNode *rootNode = [document rootElement];
    
    NSArray *resultNode = [rootNode nodesForXPath:@"/Response/Result" error:nil];
    if (resultNode.count == 0) {
        // Pump not available
        return 0;
    }
    
    DDXMLElement *pumpElement = resultNode[0];
    NSString *strResult = [pumpElement stringValue];
    NSLog(@"Result=   %@",strResult);
    return strResult.integerValue ;
    
}

- (void)removeNameSpace:(NSString*)nameSpaceString result:(NSMutableString *)result {
    NSRange stringRange;
    stringRange.location = 0;
    stringRange.length = result.length;
    
    [result replaceOccurrencesOfString:nameSpaceString withString:@"" options:NSCaseInsensitiveSearch range:stringRange];
}


- (void)insertVoidInvoiceResponse:(id)response error:(NSError *)error
{
        [_activityIndicator hideActivityIndicator];
     //   btnLastInvRcpt.enabled = NO;
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [invoiceItemarray removeAllObjects];
                    [_tblInvoiceItemdetail reloadData];
                    [self GetInvoiceData];
                    _btnVoidTransaction.enabled=NO;
                    
                    DoCreditResponse *cr = (DoCreditResponse *)self.response;

                    dispatch_async(dispatch_get_main_queue(),  ^{
                        [self paxCreditCardLogWithDetail:[self insertPaxCreditCardLogWithDetail:[self parseCreditCardResponse:self.response] withCreditCardAdditionalDetail:cr.additionalInformation]];
                    });

                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Can not process for Void. Please try again. " buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

    
- (void)invoiceCustomeCell:(NSIndexPath *)indexPath tenderItemCell:(TenderItemTableCustomCell *)tenderItemCell
{
    NSMutableDictionary *dict = invoiceItemarray[indexPath.row];
    UIImageView *discountImage;
    UIImageView * background;
    if(dict[@"IdexPath"])
    {
        CGFloat itemPrice = [dict[@"itemPrice"] floatValue];
        
        if(itemPrice < 0 || [[[dict valueForKey:@"item"] valueForKey:@"isExtraCharge"] boolValue]== TRUE || [[[dict valueForKey:@"item"] valueForKey:@"isCheckCash"] boolValue] == TRUE)
        {
            
        }
        else
        {
            discountImage = [[UIImageView alloc] initWithFrame:CGRectMake(45, 30, 16, 16)];
            discountImage.tag = 345827;
            discountImage.image = [UIImage imageNamed:@"checkmarkimage.png"];
            [tenderItemCell.contentView addSubview:discountImage];
            
           background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tenderItemCell.frame.size.width, tenderItemCell.frame.size.height)];
            background.contentMode = UIViewContentModeScaleToFill;
            background.image = [UIImage imageNamed:@"gridDatabgActive.png"];
            tenderItemCell.backgroundView = background;
        }
    }
    else
    {
        if ([tenderItemCell.contentView viewWithTag:345827])
        {
            [[tenderItemCell.contentView viewWithTag:345827] removeFromSuperview];
            [tenderItemCell.backgroundView removeFromSuperview];
            [_tblInvoiceItemdetail reloadData];
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style = UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.backgroundColor = [UIColor clearColor];
    
    if(tableView == _tblinvtype)
    {
        InvoicePaymentTypeCell *invoicePaymentTypeCell = [tableView dequeueReusableCellWithIdentifier:@"InvoicePaymentTypeCell"];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor whiteColor];
        invoicePaymentTypeCell.backgroundView = selectionColor;
       
        UIView *backColor = [[UIView alloc] init];
        backColor.backgroundColor = [UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000];
        backColor.layer.cornerRadius = 5.0;
        invoicePaymentTypeCell.selectedBackgroundView = backColor;
                
        invoicePaymentTypeCell.paymentTypeName.text = [NSString stringWithFormat: @"%@",invtypearray[indexPath.row]];
        invoicePaymentTypeCell.backgroundColor = [UIColor clearColor];
        return invoicePaymentTypeCell;
    }

    else if(tableView == self.tblPaymentType){
        InvoicePaymentTypeCell *invoicePaymentTypeCell = [tableView dequeueReusableCellWithIdentifier:@"InvoicePaymentTypeCell"];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor whiteColor];
        invoicePaymentTypeCell.backgroundView = selectionColor;
        
        UIView *backColor = [[UIView alloc] init];
        backColor.backgroundColor = [UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000];
        backColor.layer.cornerRadius = 5.0;
        invoicePaymentTypeCell.selectedBackgroundView = backColor;
        
        invoicePaymentTypeCell.paymentTypeName.text = [NSString stringWithFormat: @"%@",[(self.arrayPaymentTypes)[indexPath.row]valueForKey:@"PaymentName"]];
        invoicePaymentTypeCell.backgroundColor = [UIColor clearColor];
        return invoicePaymentTypeCell;
        
    }

    else if(tableView == self.tblInvoicedetail)
    {
        InvoiceDetailCell *invoiceDetailCell = [tableView dequeueReusableCellWithIdentifier:@"InvoiceDetailCell"];
        [self configureInvoiceDetailWithOnlineDetail:invoiceDetailCell indexPath:indexPath];
        return invoiceDetailCell;
    }
    
    else
    {
        // InvoiceItemCustomCell
        static NSString *CellIdentifier = @"InvoiceItemCell";
        TenderItemTableCustomCell *tenderItemCell = (TenderItemTableCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        tenderItemCell.currencyFormatter = self.crmController.currencyFormatter;
        
       // tenderItemCell.indexPathForCell = indexPath;
        
        //tenderItemCell.tenderItemTableCellDelegate = self;
        
      //  NSSortDescriptor *sorting = [[NSSortDescriptor alloc]initWithKey:@"itemIndex" ascending:YES];
      //  NSArray *sortDescriptors = [NSArray arrayWithObject:sorting];
       // NSArray *sortedArray = [invoiceItemarray sortedArrayUsingDescriptors:sortDescriptors];
        
        NSDictionary *dictInvoiceItem = invoiceItemarray[indexPath.row];
        [self invoiceCustomeCell:indexPath tenderItemCell:tenderItemCell];

        [tenderItemCell updateCellWithInvoiceItem:dictInvoiceItem indexpath:indexPath];
        
         cell = tenderItemCell;

    }
    return cell;



    
 //   else
//    {
//        if([invoiceItemarray count]>0)
//        {
//            
//            NSString *strType = [[invoiceItemarray objectAtIndex:indexPath.row ] valueForKey:@"itemType"];
//            UILabel * itemNo = [[UILabel alloc] initWithFrame:CGRectMake(7, 15, 20, 15)];
//            NSInteger ino = indexPath.row+1;
//            itemNo.text = [NSString stringWithFormat:@"%ld",(long)ino];
//            itemNo.backgroundColor = [UIColor clearColor];
//            itemNo.textColor = [UIColor blackColor];
//            [itemNo setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//            [cell.contentView addSubview:itemNo];
////            [itemNo release];
//            
//            NSMutableArray *reciptDataArray = [[invoiceItemarray objectAtIndex:indexPath.row] valueForKey:@"item"];
//            AsyncImageView * itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(42, 4, 50, 50)];
//            [itemImage setBackgroundColor:[UIColor clearColor]];
//            // [itemImage.layer setCornerRadius:2];
//            [itemImage.layer setBorderColor:[[UIColor whiteColor] CGColor]];
//            // [itemImage.layer setBorderWidth:2];
//            NSString * imageImage = @"";
//			imageImage = [[invoiceItemarray objectAtIndex:indexPath.row ] valueForKey:@"itemImage"];
//            
//            if ([[imageImage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
//                [itemImage setImage:[UIImage imageNamed:@"noimage.png"]];
//            } else {
//                [itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageImage]]];
//            }
//            [cell.contentView addSubview:itemImage];
//            
//            UILabel * lblBarcode = [[UILabel alloc] initWithFrame:CGRectMake(140, 12, 135, 15)];
//            
//            NSString * barcode = @"";
//            barcode = [[invoiceItemarray objectAtIndex:indexPath.row ] valueForKey:@"Barcode"];
//            if([barcode isKindOfClass:[NSNull class]])
//            {
//                barcode = @"";
//            }
//            if ([[barcode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
//                
//                lblBarcode.text = @"";
//                lblBarcode.font = [UIFont boldSystemFontOfSize:14];
//            } else {
//                lblBarcode.text = barcode;
//                lblBarcode.font = [UIFont systemFontOfSize:14];
//            }
//            
//            lblBarcode.textAlignment = NSTextAlignmentLeft;
//            lblBarcode.backgroundColor = [UIColor clearColor];
//            lblBarcode.textColor = [UIColor blackColor];
//            [lblBarcode setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//            
//            [cell.contentView addSubview:lblBarcode];
//            UILabel * itemName = nil ;
//            
//            if (lblBarcode.text.length>0)
//            {
//                itemName = [[UILabel alloc] initWithFrame:CGRectMake(140, 35, 260, 15)];
//            }
//            else
//            {
//                if ([strType isEqualToString:@"Item"])
//                {
//                    itemName = [[UILabel alloc] initWithFrame:CGRectMake(140, 38, 260, 15)];
//                    itemName.textAlignment = NSTextAlignmentLeft;
//                }
//                else
//                {
//                    itemName = [[UILabel alloc] initWithFrame:CGRectMake(140, 12, 160, 15)];
//                    itemName.textAlignment = NSTextAlignmentLeft;
//                }
//                
//            }
//            itemName.text = [[invoiceItemarray objectAtIndex:indexPath.row] valueForKey:@"itemName"];
//            itemName.backgroundColor = [UIColor clearColor];
//            itemName.textColor = [UIColor blackColor];
//            [itemName setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//            [cell.contentView addSubview:itemName];
//            
//            UILabel * qty = [[UILabel alloc] initWithFrame:CGRectMake(320, 15, 45, 15)];
//            qty.text = [NSString stringWithFormat:@"%@",[[invoiceItemarray objectAtIndex:indexPath.row] valueForKey:@"itemQty"]];
//            qty.textAlignment = NSTextAlignmentCenter;
//            qty.backgroundColor = [UIColor clearColor];
//            qty.textColor = [UIColor blackColor];
//            [qty setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//            [cell.contentView addSubview:qty];
//            
//            UILabel * perItemCost = [[UILabel alloc] initWithFrame:CGRectMake(425, 15, 100, 15)];
//            float discountOnItem = [[[invoiceItemarray objectAtIndex:indexPath.row] valueForKey:@"ItemDiscount"] floatValue];
//            float itemCost = [[invoiceItemarray objectAtIndex:indexPath.row][@"itemPrice"] floatValue];
//            NSNumber *itmCst=[NSNumber numberWithFloat:itemCost];
//            NSString *itemCst =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:itmCst]];
//            perItemCost.text = [NSString stringWithFormat:@"%@",itemCst]; // -discountOnItem
//            perItemCost.textAlignment = NSTextAlignmentLeft;
//            perItemCost.backgroundColor = [UIColor clearColor];
//            perItemCost.textColor = [UIColor blackColor];
//            [perItemCost setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//            [cell.contentView addSubview:perItemCost];
//            
//            float totalTaxOnItem = 0;
//           totalTaxOnItem = [[invoiceItemarray objectAtIndex:indexPath.row][@"itemTax"] floatValue]*[qty.text intValue];
//            
//            float totalVariation = [self variationCostForbillEntryDictionary:[invoiceItemarray objectAtIndex:indexPath.row]];
//            
//            float totalItemAndVariationCost = itemCost + totalVariation;
//            
//            float totalItemCostValue = (totalItemAndVariationCost * [qty.text intValue]);
//            NSNumber *ttlItemCost=[NSNumber numberWithFloat:totalItemCostValue];
//            NSString *totalItmCostValue =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:ttlItemCost]];
//            UILabel * totalItemCost = [[UILabel alloc] initWithFrame:CGRectMake(545, 7.0, 150, 30)];
//            totalItemCost.text = [NSString stringWithFormat:@"%@\n ",totalItmCostValue];
//            totalItemCost.numberOfLines = 1;
//            totalItemCost.textAlignment = NSTextAlignmentLeft;
//            totalItemCost.backgroundColor = [UIColor clearColor];
//            if(discountOnItem>0)
//            {
//                totalItemCost.textColor = [UIColor blueColor];
//            }
//            else
//            {
//                totalItemCost.textColor = [UIColor blackColor];
//            }
//            [totalItemCost setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//            [cell.contentView addSubview:totalItemCost];
//            
//            UILabel * lblCheckCashCharge;
//            UILabel * lblExtraChargeAmt;
//            
//            if ([[reciptDataArray valueForKey:@"isCheckCash"] boolValue] == YES)
//            {
//                UILabel * lblCheckCash = [[UILabel alloc] initWithFrame:CGRectMake(110, 60, 200, 16)];
//                lblCheckCash.text = @"Fee:";
//                lblCheckCash.numberOfLines = 0;
//                lblCheckCash.backgroundColor = [UIColor clearColor];
//                lblCheckCash.textColor = [UIColor blackColor];
//                [lblCheckCash setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
//                [cell.contentView addSubview:lblCheckCash];
//                
//                UILabel * lblCheckCashCharge = [[UILabel alloc] initWithFrame:CGRectMake(520, 60, 100, 15)];
//                lblCheckCashCharge.text = [self.rmsDbController applyCurrencyFomatter:[reciptDataArray valueForKey:@"CheckCashCharge"]];
//                lblCheckCashCharge.numberOfLines = 0;
//                lblCheckCashCharge.backgroundColor = [UIColor clearColor];
//                lblCheckCashCharge.textColor = [UIColor blackColor];
//                [lblCheckCashCharge setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
//                [cell.contentView addSubview:lblCheckCashCharge];
//            }
//            
//            
//            if ([[reciptDataArray valueForKey:@"isExtraCharge"] boolValue] == YES)
//            {
//                UILabel * lblExtraCharge = [[UILabel alloc] initWithFrame:CGRectMake(112, 60, 200, 16)];
//                lblExtraCharge.text = @"Fee:";
//                lblExtraCharge.numberOfLines = 0;
//                lblExtraCharge.backgroundColor = [UIColor clearColor];
//                lblExtraCharge.textColor = [UIColor blackColor];
//                [lblExtraCharge setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
//                [cell.contentView addSubview:lblExtraCharge];
//                
//                
//                UILabel * lblExtraChargeAmt = [[UILabel alloc] initWithFrame:CGRectMake(520, 60, 100, 15)];
//                float extChargeAmount = [[reciptDataArray valueForKey:@"ExtraCharge"] floatValue];
//                float extAmount = extChargeAmount ;
//                NSNumber *extAmt=[NSNumber numberWithFloat:extAmount];
//                NSString *extraAmount =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:extAmt]];
//                lblExtraChargeAmt.text = [NSString stringWithFormat:@"%@",extraAmount];
//                lblExtraChargeAmt.numberOfLines = 0;
//                lblExtraChargeAmt.backgroundColor = [UIColor clearColor];
//                lblExtraChargeAmt.textColor = [UIColor blackColor];
//                [lblExtraChargeAmt setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//                [cell.contentView addSubview:lblExtraChargeAmt];
//            }
//            
//            if(discountOnItem>0)
//            {
//                CGRect  discTxtFrame;
//                if (discountOnItem > 0) {
//                    discTxtFrame = CGRectMake(475, 33, 20, 16);
//                } else {
//                    discTxtFrame = CGRectMake(485, 33, 20, 16);
//                }
//                UILabel * discTxt = [[UILabel alloc] initWithFrame:discTxtFrame];
//                discTxt.text = [NSString stringWithFormat:@"D"];
//                discTxt.backgroundColor = [UIColor clearColor];
//                discTxt.textColor = [UIColor blackColor];
//                [discTxt setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
//                [cell.contentView addSubview:discTxt];
//            }
//            
//            NSMutableArray *taxArray = [[invoiceItemarray objectAtIndex:indexPath.row] valueForKey:@"ItemTaxDetail"];
//            if([taxArray isKindOfClass:[NSMutableArray class]]){
//                
//                CGRect  taxTxtFrame;
//                if (discountOnItem > 0) {
//                    taxTxtFrame = CGRectMake(545, 33, 30, 15);
//                } else {
//                    taxTxtFrame = CGRectMake(555, 33, 30, 15);
//                }
//                UILabel * taxTxt = [[UILabel alloc] initWithFrame:taxTxtFrame];
//                taxTxt.text = [NSString stringWithFormat:@"Tax"];
//                taxTxt.backgroundColor = [UIColor clearColor];
//                taxTxt.textColor = [UIColor blackColor];
//                [taxTxt setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//                [cell.contentView addSubview:taxTxt];
//            }
//            
//            
//            if([[invoiceItemarray objectAtIndex:indexPath.row] objectForKey:@"InvoiceVariationdetail"])
//            {
//                float priceY = 60 ;
//                if ( lblExtraChargeAmt.text.length > 0 || lblCheckCashCharge.text.length > 0) {
//                    priceY =  80;
//                }
//                float Y = 64;
//                NSArray * variationArray = [[invoiceItemarray objectAtIndex:indexPath.row] objectForKey:@"InvoiceVariationdetail"];
//                if ([variationArray isKindOfClass:[NSArray class]])
//                {
//                    for (int i =0; i < [variationArray count]; i++) {
//                        UILabel * variationName = [[UILabel alloc] init];
//                        [variationName setFrame:CGRectMake(64,priceY, 100, 25)];
//                        variationName.text = [NSString stringWithFormat:@" %@",[[variationArray objectAtIndex:i] valueForKey:@"VariationItemName"]];
//                        variationName.tag = [[NSString stringWithFormat:@"1%d",i] integerValue];
//                        [variationName setFont:[UIFont fontWithName:@"Helvetica Neue" size:12.0]];
//                        [cell.contentView addSubview:variationName];
//                        
//                        
//                        UILabel * variationPrice = [[UILabel alloc] init];
//                        [variationPrice  setFrame:CGRectMake(520,priceY, 100, 25)];
//                        
//                        NSNumber *variationPriceFloat=[NSNumber numberWithFloat:[[[variationArray objectAtIndex:i] valueForKey:@"Price"] floatValue]];
//                        NSString *svariationPrice =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:variationPriceFloat]];
//                        variationPrice.text = svariationPrice;
//                        variationPrice.tag = [[NSString stringWithFormat:@"1%d",i] integerValue];
//                        [variationPrice setFont:[UIFont fontWithName:@"Helvetica Neue" size:12.0]];
//                        [cell.contentView addSubview:variationPrice];
//                        Y +=15;
//                        priceY+=15;
//                    }
//                }
//            }
//            
//            
//            
//
//            NSMutableDictionary *dict = [invoiceItemarray objectAtIndex:indexPath.row];
//            if([dict objectForKey:@"IdexPath"])
//            {
//
//                CGFloat itemPrice = [dict[@"itemPrice"] floatValue];
//                if(itemPrice < 0)
//                {
//                    
//                }
//                else
//                {
//                    UIImageView *discountImage = [[UIImageView alloc] initWithFrame:CGRectMake(110.0, 30, 16, 16)];
//                    discountImage.tag = 345827;
//                    discountImage.image = [UIImage imageNamed:@"checkmarkimage.png"];
//                    [cell.contentView addSubview:discountImage];
//                    
//                    UIImageView * background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
//                    [background setContentMode:UIViewContentModeScaleToFill];
//                    [background setImage:[UIImage imageNamed:@"gridDatabgActive.png"]];
//                    cell.backgroundView = background;
//                }
//            }
//            else
//            {
//                if ([cell.contentView viewWithTag:345827])
//                {
//                    [[cell.contentView viewWithTag:345827] removeFromSuperview];
//                }
//            }
//        }
//        else
//        {
//            UILabel * noitemLebel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
//            noitemLebel.text = @"No items were selected.";
//            noitemLebel.numberOfLines = 0;
//            noitemLebel.textAlignment = NSTextAlignmentCenter;
//            noitemLebel.backgroundColor = [UIColor clearColor];
//            noitemLebel.textColor = [UIColor darkGrayColor];
//            noitemLebel.font = [UIFont boldSystemFontOfSize:12];
//            [cell.contentView addSubview:noitemLebel];
//        }
//    }
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float headerHeight;
    if(tableView == _tblinvtype)
    {
        headerHeight = 35;
        return headerHeight;
    }
    if(tableView == self.tblPaymentType)
    {
        headerHeight = 35;
    }
    else if(tableView == tblInvoicedetail)
    {
        headerHeight = 142;
    }
    else
    {
        headerHeight = 58;
    }
    return headerHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    float headerHeight;
    if(tableView == _tblinvtype)
    {
        headerHeight = 35;
        return headerHeight;

    }
    if(tableView == self.tblPaymentType)
    {
        headerHeight = TABLE_PAYMENT_TYPE_ROW_HEIGHT;
    }
    else if(tableView == tblInvoicedetail)
    {
        headerHeight = 142;
    }
    else
    {
        headerHeight = 80;
        if (invoiceItemarray.count > 0 && invoiceItemarray.count > indexPath.row) {
            
            if ([[invoiceItemarray[indexPath.row][@"item"] valueForKey:@"isCheckCash"] boolValue] == YES) {
                headerHeight += 15.0;
            }
            if([[invoiceItemarray[indexPath.row][@"item"]valueForKey:@"isExtraCharge"]boolValue] == YES)
            {
                headerHeight+= 15.0;
            }
            if(invoiceItemarray[indexPath.row][@"InvoiceVariationdetail"])
            {
                headerHeight+= [invoiceItemarray[indexPath.row][@"InvoiceVariationdetail"] count ]* 15.0;
            }
        }
        
	}
    if (invoiceItemarray.count > 0)
    {
        //lblItemcount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[invoiceItemarray count]];
        CGFloat qty = 0;
        for (int i = 0 ; i < invoiceItemarray.count; i++) {
            CGFloat totalQty = [[invoiceItemarray[i] valueForKeyPath:@"itemQty"] floatValue] / [[invoiceItemarray[i] valueForKeyPath:@"PackageQty"] floatValue];
            qty += totalQty;
        }
        
        lblItemcount.text = [NSString stringWithFormat:@"%ld",(unsigned long)qty];
    }
    else
    {
        lblItemcount.text = @"0";
    }
    return headerHeight;
    
}
-(IBAction)btnCalcenderClick:(id)sender
{

    if(calendar.hidden == YES)
    {
        _btnLastInvRcpt.userInteractionEnabled = FALSE;
        _uvInvoiceItemDetail.hidden = YES;
        _btninvtype.enabled = YES;

        calendar.hidden = NO;
        _btnCalcender.hidden = YES;
        _lblinvtype.textColor=[UIColor whiteColor];
        
        _tipsButton.hidden = YES;
    }
    else
    {
        
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    _btnLastInvRcpt.userInteractionEnabled = TRUE;
    [self.crmController UserTouchEnable];
    if(tableView == _tblinvtype)
    {
        [self.uvCalender bringSubviewToFront:calendar];
        _lblinvtype.text = invtypearray[indexPath.row];
        _uvinvtype.hidden = YES;
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
        
        components.hour = -components.hour;
        components.minute = -components.minute;
        components.second = -components.second;
//        NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
        components.hour = -24;
        components.minute = 0;
        components.second = 0;
//        NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];

        
        components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[[NSDate alloc] init]];

        if([_lblinvtype.text isEqualToString:@"Today"])
        {
           // NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateFormat = @"MM/dd/yyyy";
            NSString *TodayDate = [dateFormat stringFromDate:[NSDate selectDay:[NSDate date] withDays:1]];
            
            strFromDate = [NSString stringWithFormat:@"%@ 12:00 am", TodayDate];
            strTodate = [NSString stringWithFormat:@"%@ 11:59 pm", TodayDate];
            
            _lblCalenderDetail.text = [NSString stringWithFormat:@"%@",TodayDate];
        }
        else if([_lblinvtype.text isEqualToString:@"Yesterday"])
        {
            //NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateFormat = @"MM/dd/yyyy";
            NSString *YesterdayDate = [dateFormat stringFromDate:[NSDate selectDay:[NSDate date] withDays:-1]];
            NSString *todayDate = [dateFormat stringFromDate:[NSDate date]];
            
            strFromDate = [NSString stringWithFormat:@"%@ 12:00 am", YesterdayDate];
            strTodate = [NSString stringWithFormat:@"%@ 11:59 pm", todayDate];
            
            _lblCalenderDetail.text = [NSString stringWithFormat:@"%@",YesterdayDate];
        }
        else if([_lblinvtype.text isEqualToString:@"This Week"])
        {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateFormat = @"MM/dd/yyyy";
            NSString *LastWeekF = [dateFormat stringFromDate:[self dateFormatFromDate:[NSDate startDateOfCurrentWeek]]];
            NSString *LastWeekL = [dateFormat stringFromDate:[self dateFormatFromDate:[NSDate endDateOfCurrentWeek]]];
            
            strFromDate = [NSString stringWithFormat:@"%@ 12:00 am", LastWeekF];
            strTodate = [NSString stringWithFormat:@"%@ 11:59 pm", LastWeekL];

            _lblCalenderDetail.text = [NSString stringWithFormat:@"%@ - %@",LastWeekF,LastWeekL];
        }
        else if([_lblinvtype.text isEqualToString:@"Last Week"])
        {

            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateFormat = @"MM/dd/yyyy";
            NSString *LastWeekF = [dateFormat stringFromDate:[self dateFormatFromDate:[NSDate startDateOfLastWeek]]];
            NSString *LastWeekL = [dateFormat stringFromDate:[self dateFormatFromDate:[NSDate startDateOfCurrentWeek]]];
            
            strFromDate = [NSString stringWithFormat:@"%@ 12:00 am", LastWeekF];
            strTodate = [NSString stringWithFormat:@"%@ 11:59 pm", LastWeekL];
            
            _lblCalenderDetail.text = [NSString stringWithFormat:@"%@ - %@",LastWeekF,LastWeekL];
        }
        else if([_lblinvtype.text isEqualToString:@"This Month"])
        {
            components.day = (components.day - (components.day -1));
            NSDate *thismonth = [cal dateFromComponents:components];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateFormat = @"MM/dd/yyyy";
            NSString *ThisMonth = [dateFormat stringFromDate:thismonth];
            NSString *todayDate = [dateFormat stringFromDate:[NSDate date]];
            
            strFromDate = [NSString stringWithFormat:@"%@ 12:00 am", ThisMonth];
            strTodate = [NSString stringWithFormat:@"%@ 11:59 pm", todayDate];
            
            _lblCalenderDetail.text = [NSString stringWithFormat:@"%@",ThisMonth];
        }
        
        else if([_lblinvtype.text isEqualToString:@"Last Month"])
        {
            components.month = (components.month - 1);
            NSDate *lastmonth = [cal dateFromComponents:components];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateFormat = @"MM";
            NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
            yearFormat.dateFormat = @"yyyy";
            NSString *LastMonth = [dateFormat stringFromDate:lastmonth];
            NSString *year = [yearFormat stringFromDate:lastmonth];

            
            strFromDate = [NSString stringWithFormat:@"%@/01/%@ 12:00 am", LastMonth , year];
            strTodate = [NSString stringWithFormat:@"%@/31/%@ 11:59 pm", LastMonth , year];
            _lblCalenderDetail.text = [NSString stringWithFormat:@"%@",LastMonth];
            
        }

        else if([_lblinvtype.text isEqualToString:@"Custome Date"])
        {
            _lblCalenderDetail.text = calselectedDate;
        }

        else
        {
            
        }
        
        [self GetInvoiceData];
    }
    else if(tableView == self.tblPaymentType)
    {
       self.uvPaymentTable.hidden = YES;
       NSPredicate *paymentTypePredicate = [self searchPredicateForText:[(self.arrayPaymentTypes)[indexPath.row]valueForKey:@"PaymentName"]];
       NSArray *filterInvoiceDetail = [self.globalInvoiceArray filteredArrayUsingPredicate:paymentTypePredicate];
      if(filterInvoiceDetail.count > 0)
      {
        [self.invoicearray removeAllObjects];
        self.invoicearray = [filterInvoiceDetail mutableCopy];
        invoiceIndexpath = -1;
        _lblInvoiceCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.invoicearray.count];

        [tblInvoicedetail reloadData];
      }
        else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Record found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            
        }
   }
   else if(tableView == tblInvoicedetail)
   {
       _btnAddCustomer.hidden = NO;
       _btnAddCustomer.userInteractionEnabled = YES;
       _btnRemoveCustomer.hidden = YES;
//       _activityIndicator = [RmsActivityIndicator showActivityIndicator:_tblInvoiceItemdetail];
       _lblinvtype.textColor=[UIColor grayColor];
       invoiceIndexpath = indexPath.row;
       [tblInvoicedetail reloadData];
       //_btninvtype.enabled = NO;
       invoiceItemarray = [[NSMutableArray alloc]init];
       _uvInvoiceItemDetail.hidden = NO;
       
       
       selectedRegInvoice = invoicearray[indexPath.row];
    
//       if([[selectedRegInvoice valueForKey:@"payName"] isEqualToString:@"Credit Card"] && [[selectedRegInvoice valueForKey:@"BillAmount"] floatValue]> 0 ){
//           
//           [_btnVoidTransaction setEnabled:YES];
//                  }
//       else{
//           [_btnVoidTransaction setEnabled:NO];
//       }
       
       if (isTipsSettingEnable)
       {
           _tipsButton.hidden = NO;
       }
       else
       {
           _tipsButton.hidden = YES;
       }
       
       calendar.hidden = YES;
       _btnCalcender.hidden = NO;
       NSString *strInvoiceNo = [invoicearray[indexPath.row] valueForKey:@"InvoiceNo"];
       registerInvoiceNoForSelectedInvoice = [invoicearray[indexPath.row] valueForKey:@"RegisterInvNo"];
       invoiceNoForSelectedInvoice = strInvoiceNo;
       
       NSDate *date = [self jsonStringToNSDate:[(self.invoicearray)[indexPath.row] valueForKey:@"InvoiceDate"]];
       
       NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
       formatterDate.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
       formatterDate.dateFormat = @"MM/dd/yyyy";
       NSString *stringFromDate = [formatterDate stringFromDate:date];
       
       NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
       formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
       formatter.dateFormat = @"hh:mm a";
       NSString *stringFromtime = [formatter stringFromDate:date];

    
       strinvoiceDate=stringFromDate;
       strinvoiceTime=stringFromtime;
       
       strInvoiceNoGloble = [invoicearray[indexPath.row] valueForKey:@"RegisterInvNo"];
       _strInvoiceNumber = [invoicearray[indexPath.row] valueForKey:@"InvoiceNo"];
       
       NSString *strPaymentType = [invoicearray[indexPath.row] valueForKey:@"payName"];
       
       if([strPaymentType isKindOfClass:[NSString class]])
       {
           if ([strPaymentType isEqualToString:@"<null>"])
           {
               
           }
           else
           {
               if ([strPaymentType isEqualToString:@"void Trans."])
               {
                   _tblInvoiceItemdetail.alpha = 0.9;
                   _btn_refund.enabled = NO;
                   _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

                   [_btnVoidTransaction setEnabled:NO];
                   NSMutableDictionary *itemVoid = [[NSMutableDictionary alloc]init];
                   [itemVoid setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                   [itemVoid setValue:strInvoiceNo forKey:@"InvoiceNo"];
                   
                   CompletionHandler completionHandler = ^(id response, NSError *error) {
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                           [self responseVoidResponse:response error:error];
                       });
                   };
                   
                   self.voidTransDetailsWC = [self.voidTransDetailsWC initWithRequest:KURL actionName:WSM_VOID_TARNS_DETAILS params:itemVoid completionHandler:completionHandler];

               }
               else
               {
                   _tblInvoiceItemdetail.alpha = 1.0;
                   _btn_refund.enabled = YES;
                   _btnLastInvRcpt.enabled=YES;
                   [self getInvoiceItemDetail:strInvoiceNo];
               }
               
           }
       }
       else
       {
            [_activityIndicator hideActivityIndicator];;
           UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
           {
           };
           [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Payment Type" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
       }
       [self.uvCalender bringSubviewToFront:_uvInvoiceItemDetail];
   }
    else
    {
        NSMutableDictionary *dict = invoiceItemarray[indexPath.row];
        if([[dict valueForKey:@"Barcode"] isEqualToString:@"GAS"]){
            [tableView deselectRowAtIndexPath:indexPath animated:true];
            return;
        }
        if(dict[@"IdexPath"]){
            [dict removeObjectForKey:@"IdexPath"];
            [refundCheckArray removeLastObject];
        }
        else{
           dict[@"IdexPath"] = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            [refundCheckArray addObject:@"1"];
        }
        invoiceItemarray[indexPath.row] = dict;
        [_tblInvoiceItemdetail reloadData];
       
    }
}

- (float)variationCostForbillEntryDictionary:(NSDictionary *)billEntryDictionary
{
    float variationCost=0.0;
   
    if(billEntryDictionary[@"InvoiceVariationdetail"] && [billEntryDictionary[@"InvoiceVariationdetail"] isKindOfClass:[NSArray class]])
    {
        variationCost = [[(NSArray *)billEntryDictionary[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.Price"] floatValue];
    }
    return variationCost;
}

- (IBAction)clearTextField:(id)sender
{
    _txtBarcode.text = @"";
}

-(NSPredicate *)searchPredicateForText:(NSString *)searchData
{
    NSMutableArray *textArray=[[searchData componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;

       dbFields = @[ @"payName contains[cd] %@"];

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
-(void)configurePaxVoidPaymentArray:(NSMutableArray *)paymentArray
{
    self.paymentModesarray = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *paymentDictonary in paymentArray) {
        NSDictionary *creditcardAdditionalFieldDictionary = [self.rmsDbController objectFromJsonString:[paymentDictonary valueForKey:@"GatewayResponse"]];
        paymentDictonary[@"AuthCode"] = [creditcardAdditionalFieldDictionary valueForKey:@"AuthCode"];
        paymentDictonary[@"TransactionNo"] = [creditcardAdditionalFieldDictionary valueForKey:@"TransactionNo"];
        [self.paymentModesarray  addObject:paymentDictonary];
    }
}


-(void)configureBridgeVoidPaymentArray:(NSMutableArray *)paymentArray
{
    self.paymentModesarray = [[NSMutableArray alloc] init];

    for (NSMutableDictionary *paymentDictonary in paymentArray) {
        NSDictionary *creditcardAdditionalFieldDictionary = [self.rmsDbController objectFromJsonString:[paymentDictonary valueForKey:@"GatewayResponse"]];
        paymentDictonary[@"AuthCode"] = [creditcardAdditionalFieldDictionary valueForKey:@"AuthCode"];
        paymentDictonary[@"TransactionNo"] = [creditcardAdditionalFieldDictionary valueForKey:@"PNRef"];
        [self.paymentModesarray  addObject:paymentDictonary];
    }
}
-(void)configureVoidPaymentArray:(NSMutableArray *)paymentArray
{
    NSDictionary *dictionary = paymentArray.firstObject;

    if ([[dictionary valueForKey:@"GatewayType"] isEqualToString:@"Pax"] )
    {
        [self configurePaxVoidPaymentArray:paymentArray];
    }
    else
    {
        [self configureBridgeVoidPaymentArray:paymentArray];
    }
}

- (void)responseVoidResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    //btnLastInvRcpt.enabled=NO;
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                isVoidInvoice = TRUE;
                self.InvRcptDetail = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                [self.paymentModesarray removeAllObjects];
                [self configureVoidPaymentArray:[[self.InvRcptDetail valueForKey:@"InvoicePaymentDetail"]firstObject]];
                [self InvoiceItemDetail:[self.InvRcptDetail valueForKey:@"InvoiceItemDetail"] withInvoiceMaster:[[self.InvRcptDetail valueForKey:@"InvoiceMst"] firstObject]];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Can not process for Void . Please try again ." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(IBAction)btnCameraScanSearch:(id)sender
{
    self.cameraScanVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    [self presentViewController:self.cameraScanVC animated:YES completion:^{
        self.cameraScanVC.delegate = self;
    }];
}

#pragma mark - Camera Scan Delegate Methods

-(void)barcodeScanned:(NSString *)strBarcode
{
    _txtBarcode.text = strBarcode;
    [self textFieldShouldReturn:_txtBarcode];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _txtBarcode)
    {
        if(_txtBarcode.text.length>0)
        {
              _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
            [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
            [itemparam setValue:_txtBarcode.text forKey:@"Barcode"];
            
            [itemparam setValue:strFromDate forKey:@"FromDate"];
            [itemparam setValue:strTodate forKey:@"ToDate"];

            
            lastCalledWebservice = @"InvoiceDetailBarcode" ;
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self responseInvoiceBarcodeResponse:response error:error];
                });
            };
            
            self.invoiceDetailBarcodeWC2 = [self.invoiceDetailBarcodeWC2 initWithRequest:KURL actionName:WSM_INVOICE_DETAIL_BARCODE params:itemparam completionHandler:completionHandler];
        }
        return NO;
    }
    [textField resignFirstResponder];
    return YES;
}
- (void)responseInvoiceBarcodeResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            [self.invoicearray removeAllObjects];
            [invoiceItemarray removeAllObjects];
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(responseArray.count>0)
                {
                    self.invoicearray = responseArray;
                    _txtBarcode.text = @"";
                }
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"No record found for %@ .",_txtBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            
        }
    }
    _lblInvoiceCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.invoicearray.count];
    invoiceIndexpath = -1;
    
    [_tblInvoiceItemdetail reloadData];
    [self.tblInvoicedetail reloadData];
    _txtBarcode.text = @"";
    [_txtBarcode becomeFirstResponder];
}

-(void)configurePrintProcess
{
    NSArray *itemDetails = [self itemDetailDictionary:[[self.InvRcptDetail valueForKey:@"InvoiceItemDetail"] firstObject]];
    [self configureItemTicketsPrintArrayForLastInvoice:itemDetails];
    currentPrintStep = Invoice_PrintBegin;
    [self nextPrint];
}
-(void)invoiceCardPrint
{
    NSArray *paymentArray = [[self.InvRcptDetail valueForKey:@"InvoicePaymentDetail"] firstObject];
    
    BOOL isCreditCardAvailable = [self isCreditCardAvailable:paymentArray];
    
    if (isCreditCardAvailable)
    {
        [self cardInvoicePrintReciept:paymentArray];
    }
    else
    {
        [self nextPrint];
    }
}

-(void)invoiceBillPrint
{
    NSArray *itemDetails = [self itemDetailDictionary:[[self.InvRcptDetail valueForKey:@"InvoiceItemDetail"] firstObject]];
    NSArray *paymentArray = [[self.InvRcptDetail valueForKey:@"InvoicePaymentDetail"] firstObject];

    NSString *portName = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    
    portName = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
//    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
//    
//    
//    if(!isBlueToothPrinter)
//    {
//        lastInvoiceRcptPrint = [[LastInvoiceReceiptPrint alloc] init];
//        [lastInvoiceRcptPrint printInvoiceReceiptFromHtml:self.emailReciptHtml withPort:portName portSettings:portSettings];
//    }
//    else
//    {
        NSString *receiptDate = [NSString stringWithFormat:@"%@ %@",strinvoiceDate,strinvoiceTime];
        LastInvoiceReceiptPrint *lastInvoiceReceiptPrint = [[LastInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:itemDetails withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:receiptDate];
        [lastInvoiceReceiptPrint printInvoiceReceiptForInvoiceNo:_lblLastInvoiceNo.text withChangeDue:_lblLastChangeDue.text withDelegate:self];
//    }
//
}



- (IBAction)btnInvRcptClick:(UIButton *)sender
{
    [self.rmsDbController playButtonSound];

    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self printTenderProcess];
        return ;

    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Do You Want To Print Receipt?" buttonTitles:@[@"Cancel",@"OK"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (NSArray *)itemDetailDictionary:(NSArray *)itemDetailsArray
{
    if (itemDetailsArray.count > 0 ) {
        for (NSMutableDictionary *dict in itemDetailsArray) {
            NSMutableDictionary *dictToAdd = [[NSMutableDictionary alloc] init];
            dictToAdd[@"CheckCashCharge"] = [dict valueForKey:@"CheckCashAmount"];
            dictToAdd[@"ExtraCharge"] = [dict valueForKey:@"ExtraCharge"];
            if ([[dict valueForKey:@"ExtraCharge"] floatValue] > 0) {
                dictToAdd[@"isExtraCharge"] = @(1);
            }
            else
            {
                dictToAdd[@"isExtraCharge"] = @(0);
            }
            dictToAdd[@"isAgeApply"] = [dict valueForKey:@"isAgeApply"];
            dictToAdd[@"isCheckCash"] = [dict valueForKey:@"isCheckCash"];
            dictToAdd[@"isDeduct"] = [dict valueForKey:@"isDeduct"];
            dict[@"Item"] = dictToAdd;
        }
    }
    return itemDetailsArray;
}

-(void) getInvoiceItemDetail:(NSString *)invoiceNo
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:invoiceNo forKey:@"InvoiceNo"];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doGetInvoiceItemDetailResponse:response error:error withInvoiceNo:invoiceNo];
        });
    };

    self.invoiceItemDetailWC = [self.invoiceItemDetailWC initWithRequest:KURL actionName:WSM_INVOICE_DETAIL_LIST params:itemparam completionHandler:completionHandler];
    
}

- (void)doGetInvoiceItemDetailResponse:(id)response error:(NSError *)error withInvoiceNo:(NSString *)invoiceNo
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                isVoidInvoice = FALSE;
                
                self.InvRcptDetail = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSMutableArray *InvoiceMstDetail =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
                NSString *custName = [NSString stringWithFormat:@"%@",[InvoiceMstDetail.firstObject valueForKey:@"CustomerEmail"]];
                
                if([custName isEqualToString:@""])
                {
                    _lblCustomerName.text = @"";
                    _btnSaveInvoice.hidden = YES;
                    _btnRemoveCustomer.enabled = YES;
                    _lblCustomerName.hidden = YES;
                    _btnAddCustomer.userInteractionEnabled = YES;
                    
                }
                else
                {
                    _lblCustomerName.text = custName;
                    _btnSaveInvoice.hidden = NO;
                    _btnRemoveCustomer.enabled = NO;
                    _btnAddCustomer.userInteractionEnabled = NO;
                    _lblCustomerName.hidden = NO;
                    
                }

                if([self checkGasPumpisActive]){
                    
                    [self updateBillAmountforCC:self.InvRcptDetail];
                }
                
                
                NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
                strInvoiceZid = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"ZId"]];
                self.paymentModesarray = [[self.InvRcptDetail valueForKey:@"InvoicePaymentDetail"]firstObject];
                
                NSPredicate *predicateForSelectedInvoice = [NSPredicate predicateWithFormat:@"InvoiceNo = %@",invoiceNo];
                NSArray *selectedInvoiceArray = [self.invoicearray filteredArrayUsingPredicate:predicateForSelectedInvoice];
                
                CGFloat tipsOfInvoice = [self getSumOfTheValue:@"TipsAmount"];
                
//                [self InvoiceItemPrint: withTotalTipsAmount:];
                [self InvoiceItemDisplay:[selectedInvoiceArray firstObject] withTotalTipsAmount:tipsOfInvoice paymentType:nil];
                
                self.arrayPumpCart = [[self.InvRcptDetail valueForKey:@"InvoicePumpCart"]firstObject];
                for (NSMutableDictionary *dictCart in self.arrayPumpCart) {
                    float amountLimit = [dictCart[@"AmountLimit"]floatValue];
                    dictCart[@"AmountLimit"] = [NSNumber numberWithFloat:amountLimit];
                }
                if([[selectedRegInvoice valueForKey:@"BillAmount"] floatValue]> 0 ){
                    [_btnVoidTransaction setEnabled:YES];
                }
                else{
                    [_btnVoidTransaction setEnabled:NO];
                }
                /*!
                 *   Here is the code for set the flag of isOnlyCreditCardTransaction. Which is used to identify whether the transaction is taken only with credit card or its include other payment mode also......
                 */
                if(self.paymentModesarray.count == 1)
                {
                    NSMutableDictionary *paymentDict = self.paymentModesarray.firstObject;
                    //Check if transaction taken through only Credit Card
                    if([[paymentDict valueForKey:@"AccNo"]length]>0 && [[paymentDict valueForKey:@"TransactionNo"]length]>0)
                    {
                        payId = @([paymentDict[@"PayId"] integerValue]);
                        self.isOnlyCreditCardTransaction = TRUE;
                        self.isOnlyHouseChargeTransaction = false;
                    }
                    else
                    {
                        //Check if transaction taken through only House Charge
                        NSString *strCardIntType = [NSString stringWithFormat:@"%@",[paymentDict valueForKey:@"CardIntType"]];
                        if ([strCardIntType isKindOfClass:[NSString class]] && strCardIntType.length > 0 && [strCardIntType isEqualToString:@"HouseCharge"]) {
                            self.isOnlyHouseChargeTransaction = true;
                        }
                        else {
                            self.isOnlyHouseChargeTransaction = false;
                        }
                        self.isOnlyCreditCardTransaction = FALSE;
                    }
                }
                else
                {
                    self.isOnlyHouseChargeTransaction = false;
                    self.isOnlyCreditCardTransaction = FALSE;
                }
                
                [self updateTipWithGrandTotalForInvoice];
                [self InvoiceItemDetail:[self.InvRcptDetail valueForKey:@"InvoiceItemDetail"] withInvoiceMaster:[[self.InvRcptDetail valueForKey:@"InvoiceMst"] firstObject]];
                
                NSArray *itemDetails = [self itemDetailDictionary:[[self.InvRcptDetail valueForKey:@"InvoiceItemDetail"] firstObject]];
                NSArray *paymentArray = [[self.InvRcptDetail valueForKey:@"InvoicePaymentDetail"] firstObject];
                
                
                NSString *itemname = [NSString stringWithFormat:@"%@",[itemDetails.firstObject valueForKey:@"ItemName"]];
                NSString *paymentmode = [NSString stringWithFormat:@"%@",[paymentArray.firstObject valueForKey:@"CardType"]];
                
                if([itemname isEqualToString:@"HouseCharge"] || [paymentmode isEqualToString:@"HouseCharge"])
                {
                    [self creditLimitForHouseCharge];
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
    }
	
    else
    {
        NSPredicate *predicateForSelectedInvoice = [NSPredicate predicateWithFormat:@"regInvoiceNo = %@",registerInvoiceNoForSelectedInvoice];
        NSArray *invoiceDetailForSelectedRecord = [self fetchInvoiceObjectFromDatabaseWithPredicate:predicateForSelectedInvoice];
        if (invoiceDetailForSelectedRecord.count > 0)
        {
            InvoiceData_T *invoice_data = invoiceDetailForSelectedRecord.firstObject;
            self.InvRcptDetail = [invoice_data totalInvoiceDetailForObject];
            NSArray *paymentMode = [[self.InvRcptDetail valueForKey:@"InvoicePaymentDetail"] valueForKey:@"PayMode"];

            
            self.paymentModesarray = [[self.InvRcptDetail valueForKey:@"InvoicePaymentDetail"] firstObject];
            CGFloat tipsOfInvoice = [self getSumOfTheValue:@"TipsAmount"];
            [self updateTipWithGrandTotalForInvoice];
            
            [self InvoiceItemDisplay:[[[self.InvRcptDetail valueForKey:@"InvoiceMst"] firstObject] firstObject] withTotalTipsAmount:tipsOfInvoice paymentType:paymentMode];
            
            [self InvoiceItemDetail:[self.InvRcptDetail valueForKey:@"InvoiceItemDetail"] withInvoiceMaster:[[self.InvRcptDetail valueForKey:@"InvoiceMst"] firstObject]];
        }
    }
}


-(void)updateBillAmountforCC:(NSMutableArray *)invoiceDetail{
    
    BOOL isPaxTransaction = NO;
    NSMutableArray *paymentArray = [[invoiceDetail valueForKey:@"InvoicePaymentDetail"]firstObject];
    
    for (NSMutableDictionary *dictPaymentDetail in paymentArray) {
        if([dictPaymentDetail[@"GatewayType"] isEqualToString:@"Pax"]){
            isPaxTransaction = YES;
        }
        
        float billAmount = [dictPaymentDetail[@"BillAmount"] floatValue] - [dictPaymentDetail[@"ReturnAmount"] floatValue];
        dictPaymentDetail[@"BillAmount"] = @(billAmount);
    }
    
    NSMutableArray *invoiceItemDetail = [[invoiceDetail valueForKey:@"InvoiceItemDetail"] firstObject];
    
    for (NSMutableDictionary *dictItemDetail in invoiceItemDetail) {
        if([dictItemDetail[@"Barcode"] isEqualToString:@"GAS"]){
         //   self.btnCapture.hidden = NO;
            dictItemDetail[@"ItemBasicAmount"] = dictItemDetail[@"ItemAmount"];
        }
    }
    

}
#pragma mark Gas Pump Is Active

-(BOOL)checkGasPumpisActive{
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (self.rmsDbController.globalDict)[@"DeviceId"]];
    
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

-(NSMutableArray *)getUserDetail{
    
    NSMutableArray *userDetail = [[NSMutableArray alloc]init];
    NSMutableDictionary *userDetailDict = [[NSMutableDictionary alloc]init];

    NSArray *invoiceMaster = [[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Customer" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"custId == %@", [invoiceMaster.firstObject valueForKey:@"CustId"]];

    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    

    NSLog(@"%@",resultSet.firstObject);
    if (resultSet.count > 0)
    {
        Customer *customer = resultSet.firstObject;
        userDetailDict[@"Custid"] = customer.custId;
        userDetailDict[@"CustName"] = customer.firstName;
        userDetailDict[@"CustEmail"] = customer.email;
        userDetailDict[@"CustContactNo"] = customer.contactNo;
        userDetailDict[@"AvailableBalance"] = [NSString stringWithFormat:@"%.2f",balaceAmount];
        userDetailDict[@"CreditLimit"] = [NSString stringWithFormat:@"%.2f",creditLimitValue];
        [userDetail addObject:userDetailDict];

    }
    return userDetail;

}
-(void)creditLimitForHouseCharge
{
    
    NSArray *invoiceMaster = [[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];

    NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
    [param setValue:[invoiceMaster.firstObject valueForKey:@"CustId"] forKey:@"CustomerId"];
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
            currentPrintStep++;
            [self nextPrint];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Can not reach to server for check credit limit. Do you want to retry?" buttonTitles:@[@"No",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}


-(void)printTenderProcess
{
    
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    
    NSMutableArray *itemDetail = [[self itemDetailDictionary:[[self.InvRcptDetail valueForKey:@"InvoiceItemDetail"] firstObject]] mutableCopy];
    NSMutableArray *paymentDetail = self.paymentModesarray;
    NSMutableArray *masterDetail = [[self.InvRcptDetail  valueForKey:@"InvoiceMst"]firstObject];
    
    RapidInvoicePrint *rapidInvoicePrint =[[RapidInvoicePrint alloc]init];
   
    rapidInvoicePrint.isFromCustomerLoyalty = FALSE;
    rapidInvoicePrint.rapidCustomerArray = [self getUserDetail];
    rapidInvoicePrint = [rapidInvoicePrint initWithPortName:portName portSetting:portSettings ItemDetail:itemDetail  withPaymentDetail:paymentDetail withMasterDetails:masterDetail fromViewController:self withTipSetting:self.tipSetting tipsPercentArray:nil withChangeDue:_lblLastChangeDue.text withPumpCart:self.arrayPumpCart];
    rapidInvoicePrint.isVoidInvoice = isVoidInvoice;
    rapidInvoicePrint.isInvoiceReceipt = YES;
    
    BOOL isOffline = [[masterDetail.firstObject valueForKey:@"IsOffline"] boolValue];
    if(isOffline)
    {
        rapidInvoicePrint.cashierName = [self userName];
        rapidInvoicePrint.registerName = [self registerName];
    }
    else{
        rapidInvoicePrint.cashierName = [NSString stringWithFormat:@"%@",[masterDetail.firstObject valueForKey:@"UserName"]];
        rapidInvoicePrint.registerName = [NSString stringWithFormat:@"%@",[masterDetail.firstObject valueForKey:@"RegisterName"]];
    }

    [rapidInvoicePrint startPrint];

    rapidInvoicePrint.rapidInvoicePrintDelegate = self;
}
-(void)didFinishPrintProcessSuccessFully
{
}
-(void)didFailPrintProcess
{
}

- (void) InvoiceItemDisplay:(NSMutableArray *)invoiceItemData withTotalTipsAmount:(CGFloat )totalTipsAmount paymentType:(NSArray *)paymentType{
    
    // SUB TOTAL
    NSNumber *sTotal=@([[invoiceItemData valueForKey:@"SubTotal"] floatValue ]);
    NSString *sbTotal =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sTotal]];
    _lblSubTotal.text = [NSString stringWithFormat:@"%@",sbTotal];
    
    // DISCOUNT AMOUNT
    NSNumber *dAmt=@([[invoiceItemData valueForKey:@"DiscountAmount"] floatValue ]);
    NSString *discountAmount =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:dAmt]];
    _lblDiscount.text = [NSString stringWithFormat:@"%@",discountAmount];
    
    // TAX AMOUNT
    NSNumber *tAmt=@([[invoiceItemData valueForKey:@"TaxAmount"] floatValue ]);
    NSString *txAmount =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:tAmt]];
    _lblTaxAmount.text = [NSString stringWithFormat:@"%@",txAmount];
    
    _lblLastInvoiceNo.text = [NSString stringWithFormat:@"%@",[invoiceItemData valueForKey:@"RegisterInvNo"]];
    if(paymentType == nil)
    {
        _lblLasttenderType.text = [NSString stringWithFormat:@"%@",[invoiceItemData valueForKey:@"payName"]];

    }
    else
    {
        _lblLasttenderType.text = [NSString stringWithFormat:@"%@",[[paymentType firstObject] firstObject]];
    }
    
    // TOTAL AMOUNT
    float billAmount = [[invoiceItemData valueForKey:@"BillAmount"] floatValue ];
    float changeDue = [[invoiceItemData valueForKey:@"ChangeDue"] floatValue ];
    float totalAmount = billAmount + changeDue + totalTipsAmount;
    
    NSNumber *ttlAmt=@(totalAmount);
    NSString *totalAmt =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:ttlAmt]];
    _lblLastBillAmount.text = [NSString stringWithFormat:@"%@",totalAmt];
    
    // LAST TENDER AMOUNT
    NSNumber *lstTndrAmt=@([[invoiceItemData valueForKey:@"BillAmount"] floatValue ]);
    NSString *lstTenderAmt =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:lstTndrAmt]];
    _lblLasttenderAmount.text = [NSString stringWithFormat:@"%@",lstTenderAmt];
//    _grandTotalOfInvoice.text = [self getStringWithUsingCurrencyFormatter:tipsOfInvoice + billAmountOfInvoice];
    
    if ([[invoiceItemData valueForKey:@"BillAmount"]floatValue] < 0 )
    {
        NSNumber *sLastChangeDue = @([[invoiceItemData valueForKey:@"BillAmount"]floatValue]);
        
        sLastChangeDue = @(sLastChangeDue.floatValue * -1);
        
        _lblLastChangeDue.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sLastChangeDue]];
        
        NSString * displyValue = @"0.00";
        NSNumber *sPrice = [NSNumber numberWithFloat:displyValue.integerValue];
        NSString *iAmount = [self.crmController.currencyFormatter stringFromNumber:sPrice];
        _lblLastBillAmount.text =iAmount;
    }
    else
    {
        NSNumber *sLastChangeDue = @([[invoiceItemData valueForKey:@"ChangeDue"]floatValue]);
        _lblLastChangeDue.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sLastChangeDue]];
    }
    
    float finalAmount = [[invoiceItemData valueForKey:@"BillAmount"] floatValue];
    
    NSNumber *numPrice=@(finalAmount);
    NSString *billPrice =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:numPrice]];
    _lblFinalPaidAmount.text = [NSString stringWithFormat:@"%@",billPrice];
    
}
-(NSString *)userName{
    
    NSArray *invoiceMaster = [[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
    NSString * uName = @"";
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId==%@", [invoiceMaster.firstObject valueForKey:@"UserId"]];
    UserInfo * userinfo = [self fetchUserFromDatabase:predicate withContext:privateContextObject];
    if (userinfo) {
        uName = userinfo.userName;
    }
    return uName;
}

- (UserInfo *)fetchUserFromDatabase:(NSPredicate *)predicate withContext:(NSManagedObjectContext *)context
{
    UserInfo *userInfo=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"UserInfo" inManagedObjectContext:context];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count > 0)
    {
        userInfo = resultSet.firstObject;
    }
    return userInfo;
}

-(NSString *)registerName{
    
    NSArray *invoiceMaster = [[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
    NSString * registerNameOfInvoice = @"";
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"registerId==%@", [invoiceMaster.firstObject valueForKey:@"RegisterId"]];
    RegisterInfo * registerInfo = [self fetchRegisterNameFromDatabase:predicate withContext:privateContextObject];
    if (registerInfo) {
        registerNameOfInvoice = registerInfo.registerName;
    }
    return registerNameOfInvoice;
}
- (RegisterInfo *)fetchRegisterNameFromDatabase:(NSPredicate *)predicate withContext:(NSManagedObjectContext *)context
{
    RegisterInfo *registerInfo=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"RegisterInfo" inManagedObjectContext:context];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count > 0)
    {
        registerInfo = resultSet.firstObject;
    }
    return registerInfo;
}

-(NSMutableDictionary *)createInvoicePumpCartDict:(NSMutableDictionary *)pumpCartDict{
    
    NSMutableDictionary *dictCart  = [NSMutableDictionary dictionary];
    if(pumpCartDict){
    
        dictCart[@"Amount"] = pumpCartDict[@"Amount"];
        dictCart[@"AmountLimit"] = pumpCartDict[@"AmountLimit"];
        dictCart[@"CartId"] = pumpCartDict[@"CartId"];
        dictCart[@"FuelId"] = pumpCartDict[@"FuelId"];
        dictCart[@"IsPaid"] = pumpCartDict[@"IsPaid"];
        dictCart[@"Isdeleted"] = pumpCartDict[@"Isdeleted"];
        dictCart[@"ItemCode"] = pumpCartDict[@"ItemCode"];
        dictCart[@"PricePerGallon"] = pumpCartDict[@"PricePerGallon"];
        dictCart[@"PumpId"] = pumpCartDict[@"PumpId"];
        dictCart[@"RowPosition"] = pumpCartDict[@"RowPosition"];
        dictCart[@"ServiceType"] = pumpCartDict[@"ServiceType"];
        dictCart[@"TransactionType"] = pumpCartDict[@"TransactionType"];
        dictCart[@"Volume"] = pumpCartDict[@"Volume"];
        dictCart[@"VolumeLimit"] = pumpCartDict[@"VolumeLimit"];
       

    }
    return dictCart;
}

- (void) InvoiceItemDetail:(NSMutableArray *)invoiceItemData withInvoiceMaster:(NSMutableArray *)invoiceMst {
    [invoiceItemarray removeAllObjects];
    
    for (int i = 0; i<[invoiceItemData.firstObject count]; i++) {
        
        NSMutableDictionary * tempItemData = invoiceItemData.firstObject[i];
        
        NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setValue:[tempItemData valueForKey:@"ItemCode"] forKey:@"itemId"];
        [tempDict setValue:[tempItemData valueForKey:@"RowPosition"] forKey:@"itemIndex"];
        [tempDict setValue:[self createInvoicePumpCartDict:[[tempItemData valueForKey:@"InvoicePumpCart"] firstObject]] forKey:@"InvoicePumpCart"];

        if([[tempItemData valueForKey:@"CardNo"] isKindOfClass:[NSString class]]){
            
            if([tempItemData valueForKey:@"CardNo"] && [tempItemData valueForKey:@"CardType"] && [tempItemData valueForKey:@"Remark"]){
                
                if([[tempItemData valueForKey:@"CardNo"] length]>0){
                    
                    [tempDict setValue:[tempItemData valueForKey:@"CardNo"] forKey:@"CardNo"];
                    [tempDict setValue:@"1" forKey:@"CardType"];
                    [tempDict setValue:[tempItemData valueForKey:@"Remark"] forKey:@"Remark"];
                }
                else{
                    
                    [tempDict setValue:[tempItemData valueForKey:@"CardNo"] forKey:@"CardNo"];
                    [tempDict setValue:[tempItemData valueForKey:@"CardType"] forKey:@"CardType"];
                    [tempDict setValue:[tempItemData valueForKey:@"Remark"] forKey:@"Remark"];
                }
            }
            
        }
        
        float variationAmount = 0.0;
        if (tempItemData[@"VariationAmount"])
        {
            variationAmount = [[tempItemData valueForKey:@"VariationAmount"] floatValue];
        }
        
        float itemAmount = [[tempItemData valueForKey:@"ItemAmount"] floatValue] - variationAmount;
        
        tempDict[@"itemPrice"] = @(itemAmount);
        
        [tempDict setValue:[tempItemData valueForKey:@"ItemBasicAmount"] forKey:@"ItemBasicPrice"];
        [tempDict setValue:[tempItemData valueForKey:@"PackageType"] forKey:@"PackageType"];
        [tempDict setValue:[tempItemData valueForKey:@"PackageQty"] forKey:@"PackageQty"];

        [tempDict setValue:[tempItemData valueForKey:@"ItemMemo"] forKey:@"ItemMemo"];
        [tempDict setValue:[tempItemData valueForKey:@"PackageType"] forKey:@"PackageType"];
        [tempDict setValue:[tempItemData valueForKey:@"PackageQty"] forKey:@"PackageQty"];
        
     //   [tempDict setValue:[NSString stringWithFormat:@"%@",[invoiceMst.firstObject valueForKey:@"RegisterInvNo"]] forKey:@"ItemInvoiceNo"];
        NSString *strDiscountAmount = [tempItemData valueForKey:@"ItemDiscountAmount"];
        if ([strDiscountAmount isEqualToString:@"0.00"]) {
            [tempDict setValue:@"0" forKey:@"ItemDiscountAmount"];
        }
        else
        {
            [tempDict setValue:strDiscountAmount forKey:@"ItemDiscount"];
        }
        
        
        if (tempItemData[@"InvoiceVariationdetail"]) {
            if ([tempItemData[@"InvoiceVariationdetail"] isKindOfClass:[NSArray class]]) {
                [tempDict setValue:[tempItemData valueForKey:@"InvoiceVariationdetail"] forKey:@"InvoiceVariationdetail"];
            }
        }
        
        if (tempItemData[@"VariationAmount"]) {
            [tempDict setValue:[tempItemData valueForKey:@"VariationAmount"] forKey:@"VariationAmount"];
        }
        if (tempItemData[@"RetailAmount"]) {
            [tempDict setValue:[tempItemData valueForKey:@"RetailAmount"] forKey:@"RetailAmount"];
        }
        
        
        
        [tempDict setValue:[tempItemData valueForKey:@"ItemDiscountAmount"] forKey:@"ItemDiscount"];
        
        tempDict[@"itemTax"] = @([[tempItemData valueForKey:@"ItemTaxAmount"] floatValue]);
        
        [tempDict setValue:[tempItemData valueForKey:@"ItemName"] forKey:@"itemName"];
        
        [tempDict setValue:[tempItemData valueForKey:@"ItemQty"] forKey:@"itemQty"];
        
        [tempDict setValue:[tempItemData valueForKey:@"ItemImage"] forKey:@"itemImage"];
        
        [tempDict setValue:[tempItemData valueForKey:@"ItemType"] forKey:@"itemType"];
        
        [tempDict setValue:[tempItemData valueForKey:@"departId"] forKey:@"departId"];
        [tempDict setValue:[tempItemData valueForKey:@"DeptTypeId"] forKey:@"DeptTypeId"];

        
        NSString *strBarcode = [tempItemData valueForKey:@"Barcode"];
        if ([strBarcode isEqual:[NSNull null]]) {
            [tempDict setValue:@"" forKey:@"Barcode"];
            
        }
        else
        {
            [tempDict setValue:[tempItemData valueForKey:@"Barcode"] forKey:@"Barcode"];
        }
        NSString *strCost = [tempItemData valueForKey:@"ItemCost"];
        if ([strCost isEqual:[NSNull null]]) {
            [tempDict setValue:@"0" forKey:@"ItemCost"];
            
        }
        else
        {
            [tempDict setValue:[NSString stringWithFormat:@"-%@",strCost] forKey:@"ItemCost"];
        }
        
        //  [tempDict setValue:[tempItemData valueForKey:@"ItemCost"] forKey:@"ItemCost"];
        
        // add item information.
        NSMutableDictionary * itemInfo = [[NSMutableDictionary alloc] init];
        
        // add data in data dictionary.
        itemInfo[@"itemId"] = [tempItemData valueForKey:@"ItemCode"];
        itemInfo[@"CheckCashCharge"] = [tempItemData valueForKey:@"CheckCashAmount"];
        CGFloat perItemExtraCharge = [[tempItemData valueForKey:@"ExtraCharge"] floatValue] / [[tempItemData valueForKey:@"ItemQty"] floatValue];
        itemInfo[@"ExtraCharge"] = [NSString stringWithFormat:@"%.2f",perItemExtraCharge];      //// change interger to flot
        CGFloat isExtCharge = [[tempItemData valueForKey:@"ExtraCharge"] floatValue];
        if(isExtCharge == 0)
        {
            itemInfo[@"isExtraCharge"] = @"0";//--
        }
        else
        {
            itemInfo[@"isExtraCharge"] = @"1";
        }
        
        itemInfo[@"isAgeApply"] = [tempItemData valueForKey:@"isAgeApply"];
        NSInteger iTaxAmount = [[tempItemData valueForKey:@"ItemTaxAmount"] intValue];
        if(iTaxAmount == 0)
        {
            itemInfo[@"isTax"] = @"0";
        }
        else
        {
            itemInfo[@"isTax"] = @"1";
        }
        itemInfo[@"isCheckCash"] = [tempItemData valueForKey:@"isCheckCash"];
        itemInfo[@"isDeduct"] = [tempItemData valueForKey:@"isDeduct"];
        
        if(itemInfo != nil) {
            tempDict[@"item"] = itemInfo;
        }
        
        if ([[tempItemData valueForKey:@"ItemTaxDetail"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *Itemtaxappray = [tempItemData valueForKey:@"ItemTaxDetail"];
            if (Itemtaxappray.count>0) {
                for (int j = 0; j<Itemtaxappray.count; j++) {
                    NSMutableDictionary *tmpItemTax = Itemtaxappray[j];
                    [tmpItemTax removeObjectForKey:@"ItemCode"];
                    [tmpItemTax removeObjectForKey:@"RowPosition"];
                }
                tempDict[@"ItemTaxDetail"] = Itemtaxappray;
            }
        }
        [invoiceItemarray addObject:tempDict];
    }
    
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    NSArray *itemDetails = [self itemDetailDictionary:[[self.InvRcptDetail valueForKey:@"InvoiceItemDetail"] firstObject]];
    NSArray *paymentArray = [[self.InvRcptDetail valueForKey:@"InvoicePaymentDetail"] firstObject];
    
    NSString *receiptDate = [NSString stringWithFormat:@"%@ %@",strinvoiceDate,strinvoiceTime];

   

    if([self.rmsDbController checkGasPumpisActive] && arrayPumpCart.count > 0){
        
        if([self isPrepayTransaction:arrayPumpCart]){
            
            LastGasInvoiceReceiptPrint *gaslastInvoiceReceiptPrint = [[LastGasInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:itemDetails withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:receiptDate];
             gaslastInvoiceReceiptPrint.isInvoiceReceipt = YES;
            NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
            BOOL isOffline = [[InvoiceMst.firstObject valueForKey:@"IsOffline"] boolValue];
            if(isOffline)
            {
                gaslastInvoiceReceiptPrint.cashierName = [self userName];
                gaslastInvoiceReceiptPrint.registerName = [self registerName];
            }
            else{
                gaslastInvoiceReceiptPrint.cashierName = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"UserName"]];
                gaslastInvoiceReceiptPrint.registerName = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"RegisterName"]];
            }
            gaslastInvoiceReceiptPrint.arrPumpCartArray = arrayPumpCart;
           self.emailReciptHtml = [gaslastInvoiceReceiptPrint generateHtmlForInvoiceNo:_lblLastInvoiceNo.text withChangeDue:_lblLastChangeDue.text];
        }
        else{
            
            LastPostpayGasInvoiceReceiptPrint *postpaylastInvoiceReceiptPrint = [[LastPostpayGasInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:itemDetails withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:receiptDate];
             postpaylastInvoiceReceiptPrint.isInvoiceReceipt = YES;
            NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
            BOOL isOffline = [[InvoiceMst.firstObject valueForKey:@"IsOffline"] boolValue];
            if(isOffline)
            {
                postpaylastInvoiceReceiptPrint.cashierName = [self userName];
                postpaylastInvoiceReceiptPrint.registerName = [self registerName];
            }
            else{
                postpaylastInvoiceReceiptPrint.cashierName = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"UserName"]];
                postpaylastInvoiceReceiptPrint.registerName = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"RegisterName"]];
            }
            postpaylastInvoiceReceiptPrint.arrPumpCartArray = self.arrayPumpCart;
            self.emailReciptHtml = [postpaylastInvoiceReceiptPrint generateHtmlForInvoiceNo:_lblLastInvoiceNo.text withChangeDue:_lblLastChangeDue.text];
        }
    }
    else{
        LastInvoiceReceiptPrint *lastInvoiceReceiptPrint = [[LastInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:itemDetails withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:receiptDate];
        lastInvoiceReceiptPrint.isInvoiceReceipt = YES;
        
        NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
        BOOL isOffline = [[InvoiceMst.firstObject valueForKey:@"IsOffline"] boolValue];
        if(isOffline)
        {
            lastInvoiceReceiptPrint.cashierName = [self userName];
            lastInvoiceReceiptPrint.registerName = [self registerName];
        }
        else{
            lastInvoiceReceiptPrint.cashierName = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"UserName"]];
            lastInvoiceReceiptPrint.registerName = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"RegisterName"]];
        }
        
        self.emailReciptHtml = [lastInvoiceReceiptPrint generateHtmlForInvoiceNo:_lblLastInvoiceNo.text withChangeDue:_lblLastChangeDue.text];
    }
    [_tblInvoiceItemdetail reloadData];
}
-(BOOL)isPrepayTransaction:(NSMutableArray *)gasArray{
    BOOL prepay = NO;
    if([gasArray[0][@"TransactionType"] isEqualToString:@"PRE-PAY"]){
        prepay = YES;
    }
    return prepay;
    
}

- (float)variationCostForPrintbillEntryDictionary:(NSDictionary *)billEntryDictionary withItemQty:(NSString *)keyName
{
    float variationCost=0.0;
    if(billEntryDictionary[@"InvoiceVariationdetail"])
    {
        NSArray *variationDetails = [billEntryDictionary valueForKey:@"InvoiceVariationdetail"];
        if ([variationDetails isKindOfClass:[NSArray class]] && variationDetails.count > 0)
        {
            variationCost = [[(NSArray *)billEntryDictionary[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.Price"] floatValue];
            variationCost = variationCost * [billEntryDictionary[keyName]floatValue];
        }
    }
    return variationCost;
}

- (void)printSignature:(UIImage *)signatureImage commands:(NSMutableData *)commands
{
    int maxWidth = signatureImage.size.width;
    BOOL pageModeEnable = NO;
    BOOL compressionEnable = YES;
    
    RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium endOfPageBehaviour:RasPageEndMode_None endOfDocumentBahaviour:RasPageEndMode_None topMargin:RasTopMargin_Standard pageLength:0 leftMargin:5 rightMargin:0];
    
    StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:signatureImage :maxWidth :pageModeEnable];
    
    NSMutableData *commandsToPrint = [[NSMutableData alloc] init];
    NSData *shortcommand = [rasterDoc BeginDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [starbitmap getImageDataForPrinting:compressionEnable];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [rasterDoc EndDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    [commands appendData:commandsToPrint];
}
- (void)printBarCode:(NSString *)textToBarCode commands:(NSMutableData *)commands
{
    /**
     \x1b\x62\x06\x02\x02\x60 explained:
     
     \x1b\x62 - For ESC b
     \x06 - For Barcode font character: 4 = Code39, 5 = ITF, 2 = JAN/EAN8 *, 6 = Code128
     \x02 - Under-bar character selection and added line feed selection
     \x02 - Specifies the size of the narrow and wide barcode lines
     \x60 - Barcode height (dot count)
     */
    
    NSData *barCodeCommand = [[NSString stringWithFormat:@"\x1b\x62\x06\x02\x02\x50%@\x1e\r\n", textToBarCode] dataUsingEncoding:NSASCIIStringEncoding];
    [commands appendData:barCodeCommand];
}

-(IBAction)btninvtypeClick:(id)sender
{
    _uvinvtype.hidden = NO;
    [self.view bringSubviewToFront:_uvinvtype];
    [self.uvCalender sendSubviewToBack:calendar];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)dateIsDisabled:(NSDate *)date {
    for (NSDate *disabledDate in self.disabledDates) {
        if ([disabledDate isEqualToDate:date]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark - CKCalendarDelegate

- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    // TODO: play with the coloring if we want to...
    if ([self dateIsDisabled:date]) {
        //dateItem.backgroundColor = [UIColor redColor];
       // dateItem.textColor = [UIColor whiteColor];
    }
}

- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date {
    return ![self dateIsDisabled:date];
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    
    if (date) {
        calselectedDate = [self.dateFormatter stringFromDate:date];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"MM/dd/yyyy";
        
        strFromDate = [NSString stringWithFormat:@"%@ 12:00 am" , [dateFormat stringFromDate:date]];
        strTodate = [NSString stringWithFormat:@"%@ 11:59 pm" , [dateFormat stringFromDate:date]];
        
        selectedCalenderDateForOffline =  [self dateFormatFromDate:date];
        [self GetInvoiceDatewiseData];
    }
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
     
    if ([date laterDate:self.minimumDate] == date) {
       // self.calendar.backgroundColor = [UIColor blueColor];
   
        return YES;
    } else {
      //  self.calendar.backgroundColor = [UIColor redColor];
        return NO;
    }
}
#pragma mark - 
#pragma Refund Item
-(IBAction)redundItems:(id)sender{
    switch ([sender tag]) {
		case 101:
            [self.rmsDbController playButtonSound];
			break;
		case 102:
            [self.rmsDbController playButtonSound];

            if (refundCheckArray.count > 0)
            {
                [refundCheckArray removeAllObjects];
                
			if (invoiceItemarray.count > 0) {
				[self setRefundInvoiceItem];
			} else {
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select an item before refund." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
			}
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select an item before refund." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            }
			break;
		default:
			break;
	}
    
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
//    [formatter release];
    // NSTimeInterval is specified in seconds.  The value we get back from the
    // web service is specified in milliseconds.  Both values are since 1st Jan
    // 1970 (epoch).
    NSTimeInterval seconds = milliseconds.longLongValue / 1000;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

#pragma mark -
#pragma mark Setup Invoice Refund Item data.
-(NSString *)getDepartmentTypeid:(NSNumber *)deptId{
    
    Department *dept = (Department *)[self.updateManager __fetchEntityWithName:@"Department" key:@"deptId" value:deptId shouldCreate:NO moc:self.managedObjectContext];
    
    return dept.deptTypeId.stringValue;
}

- (void) setRefundInvoiceItem {
	for (int i = 0; i<invoiceItemarray.count; i++)
    {
		//NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] initWithDictionary:[invoiceItemarray objectAtIndex:((NSIndexPath *)[invoiceItemarray objectAtIndex:i]).row]];
        
        NSMutableDictionary * tempDict = invoiceItemarray[i];
        if(tempDict[@"IdexPath"])
        {

            CGFloat itemPrice = [tempDict[@"itemPrice"] floatValue];
           if(itemPrice < 0 || [[[tempDict valueForKey:@"item"] valueForKey:@"isExtraCharge"] boolValue]== TRUE)
            {
                
            }
            else
            {
//                float perQtyDiscount = QtyDisCount/[[tempDict valueForKey:@"itemQty"] floatValue];
                
                
               /* if ([tempDict[@"ItemBasicPrice"] floatValue] > [[tempDict valueForKey:@"itemPrice"] floatValue])
                {
                    tempDict[@"PriceAtPos"] = [NSString stringWithFormat:@"-%.2f",[[tempDict valueForKey:@"itemPrice"] floatValue]];
                    tempDict[@"IsQtyEdited"] = @"0";
                    
                    float ItemDisCount=[tempDict[@"ItemBasicPrice"] floatValue]-[[tempDict valueForKey:@"itemPrice"] floatValue];
                    tempDict[@"ItemDiscount"] = [NSString stringWithFormat:@"-%.2f",ItemDisCount];
                    float  totalItemPercenatge = ItemDisCount / [tempDict[@"ItemBasicPrice"] floatValue] *100;
                    tempDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
                }
                else if ([tempDict[@"ItemBasicPrice"] floatValue] < [[tempDict valueForKey:@"itemPrice"] floatValue])
                {
                    tempDict[@"PriceAtPos"] = [NSString stringWithFormat:@"-%.2f",[[tempDict valueForKey:@"itemPrice"] floatValue]];
                    tempDict[@"IsQtyEdited"] = @"0";
                    
                }
                else if ([tempDict[@"ItemBasicPrice"] floatValue] == [[tempDict valueForKey:@"itemPrice"] floatValue])
                {
                    [tempDict removeObjectForKey:@"PriceAtPos"];
                }*/
                
                float discount=[[tempDict valueForKey:@"ItemDiscount"] floatValue];
                tempDict[@"ItemDiscount"] = [NSString stringWithFormat:@"-%.2f",discount];
                tempDict[@"DeptTypeId"] = [tempDict valueForKey:@"DeptTypeId"];

                if (tempDict[@"InvoiceVariationdetail"]) {
                    NSMutableArray *variationdetail = [tempDict valueForKey:@"InvoiceVariationdetail"];
                    for (int var = 0; var < variationdetail.count; var++) {
                        NSMutableDictionary *varDict = variationdetail[var];
                        float price = [[varDict valueForKey:@"Price"]floatValue];
                        [varDict setValue:[NSString stringWithFormat:@"-%.2f",price] forKey:@"Price"];
                        [varDict setValue:[NSString stringWithFormat:@"-%.2f",price] forKey:@"VariationBasicPrice"];
                    }
                    [tempDict setValue:[tempDict valueForKey:@"InvoiceVariationdetail"] forKey:@"InvoiceVariationdetail"];
                }
                
                if (tempDict[@"VariationAmount"]) {
                    [tempDict setValue:[NSString stringWithFormat:@"-%.2f",[[tempDict valueForKey:@"VariationAmount"]floatValue]] forKey:@"TotalVarionCost"];
                }
                if (tempDict[@"RetailAmount"]) {
                    [tempDict setValue:[NSString stringWithFormat:@"-%.2f",[[tempDict valueForKey:@"RetailAmount"]floatValue]] forKey:@"RetailAmount"];
                }
                
                
                
                tempDict[@"ItemBasicPrice"] = [NSString stringWithFormat:@"-%@",[tempDict valueForKey:@"ItemBasicPrice"]];
                tempDict[@"itemPrice"] = @(-itemPrice);
                tempDict[@"PackageType"] = [tempDict valueForKey:@"PackageType"];
                tempDict[@"PackageQty"] = [tempDict valueForKey:@"PackageQty"];
                
                
                NSString *strItemId=[NSString stringWithFormat:@"%ld",(long)[[tempDict valueForKey:@"itemId"] integerValue]];
                Item *anitem=[self fetchItemObjects:strItemId];
                if(anitem.itemGroupMaster.groupId)
                {
                    tempDict[@"categoryId"] = anitem.itemGroupMaster.groupId;
                    
                }
                else
                {
                    tempDict[@"categoryId"] = @"0";
                    
                }
                if(anitem.itemMixMatchDisc.mixMatchId)
                {
                    tempDict[@"mixMatchId"] = anitem.itemMixMatchDisc.mixMatchId;
                }
                else
                {
                    tempDict[@"mixMatchId"] = @"0";
                    
                }
                
                [tempDict setValue:[tempDict valueForKey:@"ItemMemo"] forKey:@"Memo"];

                tempDict[@"IsRefundFromInvoice"] = @(1);

                
                tempDict[@"IsQtyEdited"] = @"0";
                tempDict[@"ItemDiscountPercentage"] = @(0);
                tempDict[@"ItemExternalDiscount"] = @(0);
                tempDict[@"ItemInternalDiscount"] = @(0);
           
                /*  if (perQtyDiscount > 0)
                {
                    tempDict[@"ItemWiseDiscountValue"] = [NSString stringWithFormat:@"%f",perQtyDiscount];
                    tempDict[@"ItemWiseDiscountType"] = @"Amount";
                }*/
                
                NSMutableArray *itemTaxDetail = [tempDict valueForKey:@"ItemTaxDetail"];
                if(itemTaxDetail.count>0)
                {
                    for (int i = 0; i<itemTaxDetail.count; i++)
                    {
                        NSMutableDictionary *Dict = itemTaxDetail[i];
                        NSString *strItemTaxAmount = Dict[@"ItemTaxAmount"];
                        float ftAmount = strItemTaxAmount.floatValue;
                        float ftTaxAmount = ftAmount/[[tempDict valueForKey:@"itemQty"] floatValue];
                        NSString *strSetAmount = [NSString stringWithFormat:@"-%.2f",ftTaxAmount];
                        Dict[@"ItemTaxAmount"] = strSetAmount;
                        itemTaxDetail[i] = Dict;
                    }
                    tempDict[@"ItemTaxDetail"] = itemTaxDetail;
                }
                
                float ftAmount = [tempDict[@"itemTax"] floatValue];
                float ftTaxAmount = ftAmount/[[tempDict valueForKey:@"itemQty"] floatValue];
                
                tempDict[@"itemTax"] = @(-ftTaxAmount);
                
                if([tempDict valueForKey:@"item"] != nil) {
                    
                    [tempDict valueForKey:@"item"][@"isRefund"] = @"YES";
                }
                if([tempDict valueForKey:@"itemDetails"] != nil)
                {
                    if ([[tempDict valueForKey:@"itemDetails"] isKindOfClass:[NSMutableArray class]])
                    {
                        [[tempDict valueForKey:@"itemDetails"] firstObject][@"SellingPrice"] = [NSString stringWithFormat:@"-%@",[[[tempDict valueForKey:@"itemDetails"] firstObject] valueForKey:@"SellingPrice"]];
                        [[tempDict valueForKey:@"itemDetails"] firstObject][@"TaxAmount"] = [NSString stringWithFormat:@"-%@",[[[tempDict valueForKey:@"itemDetails"] firstObject] valueForKey:@"TaxAmount"]];
                    }
                }
                [self.invoiceDetailArray addObject:tempDict];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];;
    if (self.invoiceDetailDelegate)
    {
        [self.invoiceDetailDelegate didAddItemFromInvoiceListWithInvoiceDetail:self.invoiceDetailArray];
    }
    else
    {
    [self.view removeFromSuperview];
    }
}

- (Item*)fetchItemObjects :(NSString *)itemData
{
    Item *item=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d",itemData.integerValue];
    fetchRequest.predicate = predicate;
    
    //  NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}

-(IBAction)btnCancelClick:(id)sender;
{
    [self.rmsDbController playButtonSound];
    [_activityIndicator hideActivityIndicator];;
    
    if (self.invoiceDetailDelegate)
    {
        [self.invoiceDetailDelegate didCancelInvoiceList];
    }
    else
    {
        [self.view removeFromSuperview];
    }
}
- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonthlabel:(NSDate *)date
{
    lblmonthname.text = [self.dateFormatterMonth stringFromDate:self.calendar.monthShowing];
    return YES;
}
- (void)calendar:(CKCalendarView *)calendar didLayoutInRect:(CGRect)frame {
}
-(IBAction)sendEmail:(id)sender{
    
    if(self.InvRcptDetail.count>0){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
        
        NSData *myData = [NSData dataWithContentsOfFile:self.emailReciptHtml];
        NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
        
        
        NSString *strsubjectLine = [NSString stringWithFormat:@"Your Receipt from %@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]];
        
        NSMutableArray *InvoiceMst =[[self.InvRcptDetail valueForKey:@"InvoiceMst"]firstObject];
        NSString *custId = [NSString stringWithFormat:@"%@",[InvoiceMst.firstObject valueForKey:@"CustId"]];
    
        if (![custId isEqualToString:@"0"]) {
            RapidCustomerLoyalty *rapidCustomerLoyalty = [[RapidCustomerLoyalty alloc]init];
            [rapidCustomerLoyalty setCustomerId:custId customerEmail:[InvoiceMst.firstObject valueForKey:@"CustomerEmail"]];
            emailFromViewController.rapidEmailCustomerLoyalty = rapidCustomerLoyalty;
        }

        emailFromViewController.emailFromViewControllerDelegate = self;
        emailFromViewController.dictParameter =[[NSMutableDictionary alloc]init];
        (emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
        (emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
        (emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
        (emailFromViewController.dictParameter)[@"postfile"] = myData;
        (emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
        
        [self.view addSubview:emailFromViewController.view];
    }
}

-(void)didCancelEmail
{
    [emailFromViewController.view removeFromSuperview];
}

-(void)cardInvoicePrintReciept:(NSArray *)paymentDetails
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    NSString *receiptDate = [NSString stringWithFormat:@"%@ %@",strinvoiceDate,strinvoiceTime];
//    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
//    if(!isBlueToothPrinter)
//    {
//        cardRcptPrint = [[CardReceiptPrint alloc] initWithPortName:portName portSetting:portSettings withPaymentDatail:paymentDetails tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:receiptDate];
//        self.cardReciptHtml = [cardRcptPrint generateHtmlForCardRecieptForInvoiceNo:_lblLastInvoiceNo.text];
//        [cardRcptPrint printCardReceiptFromHtml:self.cardReciptHtml withPort:portName portSettings:portSettings];
//    }
//    else
//    {
        CardReceiptPrint *cardReceiptPrint = [[CardReceiptPrint alloc] initWithPortName:portName portSetting:portSettings withPaymentDatail:paymentDetails tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:receiptDate];
        [cardReceiptPrint printCardReceiptForInvoiceNo:_lblLastInvoiceNo.text withDelegate:self];
//    }
//    
}
-(BOOL)isCreditCardAvailable :(NSArray *)paymentArray
{
    BOOL isCreditCardAvailable = NO;
    
    if([paymentArray isKindOfClass:[NSArray class]] && paymentArray.count > 0){
        
        for(int i = 0;i<paymentArray.count;i++)
        {
            
            NSMutableDictionary *paymentDict = paymentArray[i];
            
            if([[paymentDict valueForKey:@"AuthCode"]length]>0 && [[paymentDict valueForKey:@"CardType"]length]>0 && [[paymentDict valueForKey:@"TransactionNo"]length]>0 && [[paymentDict valueForKey:@"AccNo"]length]>0)
            {
                if (!([[paymentDict valueForKey:@"SignatureImage"]length] > 0))
                {
                    isCreditCardAvailable = YES;
                }
            }
        }
    }
    
    return isCreditCardAvailable;
}

- (void)generatePrintCardReceiptCommands:(NSMutableData *)commands totlength:(int)totlength creditcartArray:(NSMutableArray *)cardArray
{
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // center
    
    [commands appendData:[[NSString stringWithFormat:@"%@\r\n",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]] dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[[NSString stringWithFormat:@"%@ , %@\r\n%@, %@ - %@\r\n\r\n",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]] dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
    
    [commands appendData:[@"\x1b\x34 Card Receipt \x1b\x35\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x44\x02\x10\x22\x00"
                   length:sizeof("\x1b\x44\x02\x10\x22\x00") - 1];    // SetHT
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
                   length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
    
    [commands appendData:[[NSString stringWithFormat:@"Invoice #: %@\r\n",_lblLastInvoiceNo.text] dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    NSString *salesPersonName=[NSString stringWithFormat:@"%@",userName];
    
    [commands appendBytes:"\x1b\x1d\x61\x02"
                   length:sizeof("\x1b\x1d\x61\x02") - 1];    // Alignment(right)
    
    [commands appendData:[[NSString stringWithFormat:@"Cashier #: %@",salesPersonName] dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[[NSString stringWithFormat:@"      Register #:%@\r\n",(self.rmsDbController.globalDict)[@"RegisterName"]]dataUsingEncoding:NSASCIIStringEncoding]];
    
    //NSDate * date = [NSDate date];
    //Create the dateformatter object
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    //Create the timeformatter object
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    
    //Get the string date
    NSString *printDate = strinvoiceDate;
    NSString *printTime = strinvoiceTime;
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
                   length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
    
    [commands appendData:[[NSString stringWithFormat:@"Date:%@ %@\r\n",printDate,printTime]dataUsingEncoding:NSASCIIStringEncoding]];
    
//    [commands appendBytes:" \x09 "
//                   length:sizeof(" \x09 ") - 1];
//    
//    [commands appendData:[[NSString stringWithFormat:@"Time:%@\r\n",printTime]dataUsingEncoding:NSASCIIStringEncoding]];
    
    for(int i = 0;i<cardArray.count;i++)
    {
        NSMutableDictionary *paymentDict = cardArray[i];
        
        if([[paymentDict valueForKey:@"AuthCode"]length]>0 && [[paymentDict valueForKey:@"CardType"]length]>0 && [[paymentDict valueForKey:@"TransactionNo"]length]>0 && [[paymentDict valueForKey:@"AccNo"]length]>0)
        {
            [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
            
            NSString *strAccountNo = [NSString stringWithFormat:@"%@",[paymentDict valueForKey:@"AccNo"]];
            
            NSString *strBillAmount=[NSString stringWithFormat:@"%@",[paymentDict valueForKey:@"BillAmount"]];
            
            NSNumber *numAmount=@(strBillAmount.floatValue);
            NSString *tenderAmount =[self.crmController.currencyFormatter stringFromNumber:numAmount];
            [commands appendData:[[NSString stringWithFormat:@"Card Holder Name :   %@\r\n",[paymentDict valueForKey:@"CardHolderName"]] dataUsingEncoding:NSASCIIStringEncoding]];
            [commands appendData:[[NSString stringWithFormat:@"Card Number      : %@\r\n",strAccountNo] dataUsingEncoding:NSASCIIStringEncoding]];
            [commands appendData:[[NSString stringWithFormat:@"Auth Code : %@\r\n",[paymentDict valueForKey:@"AuthCode"]] dataUsingEncoding:NSASCIIStringEncoding]];
            [commands appendData:[[NSString stringWithFormat:@"Amount    : %@\r\n",tenderAmount] dataUsingEncoding:NSASCIIStringEncoding]];
            
            
            CGFloat tipAmount = [[paymentDict valueForKey:@"TipsAmount"] floatValue];
            if(tipAmount>0){
                [commands appendData:[[NSString stringWithFormat:@"Tip : $%.2f\r\n",tipAmount] dataUsingEncoding:NSASCIIStringEncoding]];
                
                float totalAmount2 = strBillAmount.floatValue + tipAmount;
                
                [commands appendBytes:"\x1b\x45"
                               length:sizeof("\x1b\x45") - 1];    // SetBold
                
                [commands appendData:[[NSString stringWithFormat:@"Total : $%.2f\r\n",totalAmount2] dataUsingEncoding:NSASCIIStringEncoding]];
                
                [commands appendBytes:"\x1b\x46"
                               length:sizeof("\x1b\x46") - 1];// CancelBold
                
            }
            
        }
    }
    
    
    [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x02"
                   length:sizeof("\x1b\x1d\x61\x02") - 1];    // Alignment(right)
    
    [commands appendData:[@"Cardholder Signature \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@" X  _____________________________________\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
                   length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
    
    [commands appendData:[@" I AGREE TO PAY ABOVE TOTAL AMOUNT ACCORDING TO \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@" CARD ISSUER AGREEMENT. \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
    
    [commands appendData:[@" Thank You for Shopping \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSString *strBrnName=[NSString stringWithFormat:@"%@\r\n",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]] ;
    
    [commands appendData:[strBrnName dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@" We hope you'll come back soon! \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    //    NSString *textToBarCode = @"AbCdEf123987"; //@"12ab34cd56";
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    
    [self printBarCode:_lblLastInvoiceNo.text commands:commands];
    
    [commands appendBytes:"\x1b\x64\x02"
                   length:sizeof("\x1b\x64\x02") - 1];  //Cut Paper
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if((textField == _txtBarcode) && (self.btnItemKeYboard.tag == 1))
    {
        _txtBarcode.inputView = nil;
        [_txtBarcode becomeFirstResponder];
    }
    else
    {
        _txtBarcode.inputView = _dummyView;
    }
}
- (IBAction)btn_itemKeyboard:(id)sender
{
    if([sender tag]==0)
    {
        [self.keyBoardTextField becomeFirstResponder];
        self.btnItemKeYboard.selected = YES;
        [sender setTag:1];
    }
    else
    {
        [sender setTag:0];
        [self.keyBoardTextField resignFirstResponder];
        [_txtBarcode resignFirstResponder];
        self.btnItemKeYboard.selected = NO;
    }
    [_txtBarcode becomeFirstResponder];
    
}

-(void)addTipAtPaymentTypeWithDetail:(NSDictionary *)tipCreditCardDictionary withTipAmount:(CGFloat )tipAmount
{
    selectedTipDictionary = tipCreditCardDictionary;
    [tipsAdjustmentVC.view removeFromSuperview];
    NSString *transctionNo = [tipCreditCardDictionary valueForKey:@"TransactionNo"];
    NSArray *arrayForPayId = [self getPaymentDetailForEntity:@"TenderPay" withThePredicate:[NSPredicate predicateWithFormat:@"payId == %@",[selectedTipDictionary valueForKey:@"PayId"]]];
    
    NSString *transctionServerForSpecOption = [NSString stringWithFormat:@"%@",[self transctionServerForSpecOptionforPaymentId:[[selectedTipDictionary valueForKey:@"PayId"] integerValue]]];
    
    NSString *cardIntType = @"";
    if (arrayForPayId.count > 0) {
        cardIntType = [(TenderPay *)arrayForPayId.firstObject valueForKey:@"cardIntType"];
    }
    
    if (transctionNo.length > 0 && [cardIntType isEqualToString:@"Credit"]) {
        
        if([transctionServerForSpecOption isEqualToString:@"RAPID CONNECT"]){
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSString *extData = [NSString stringWithFormat:@"<TipAmt>%.2f</TipAmt>",tipAmount];
                NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
                dictParam[@"TransType"] = @"Adjustment";
                dictParam[@"Amount"] = @"";
                dictParam[@"InvNum"] = @"";
                dictParam[@"MagData"] = @"";
                dictParam[@"BranchId"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
                dictParam[@"ExtData"] = extData;
                dictParam[@"TransactionId"] = transctionNo;
                dictParam[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
                dictParam[@"CardNo"] = @"";
                adjustedTipAmount = tipAmount;
                [self tipAdjustMentformInvoice:dictParam];
                
            });
            
        }
        else{
            
            [self processTipToBridgePay:tipAmount withTransactionNo:transctionNo];
        }
        
    }
    else
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [self adjustTipInLocalDataBasewithTipAmount:tipAmount withTipDictionary:tipCreditCardDictionary withTransctionNo:@""];
    }
}

-(void)didCancelAdjustTip
{
    selectedTipDictionary = nil;
    [tipsAdjustmentVC.view removeFromSuperview];
}
-(void)didRemoveAdjustTip
{
    selectedTipDictionary = nil;
    [tipsAdjustmentVC.view removeFromSuperview];
}


-(void)processTipToBridgePay:(float)tipAmount withTransactionNo:(NSString *)transctionNo
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *paymentDictionary = self.rmsDbController.paymentCardTypearray.firstObject;
        NSString *extData = [NSString stringWithFormat:@"<TipAmt>%.2f</TipAmt>",tipAmount];
        NSString *transDetails = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=&InvNum=&PNRef=%@&Zip=&Street=&CVNum=&ExtData=%@",[paymentDictionary valueForKey:@"Username"],[paymentDictionary valueForKey:@"password"],@"Adjustment",transctionNo,extData];
        [self processTipAdjustment:[paymentDictionary valueForKey:@"URL"] details:transDetails withTipAmount:tipAmount];
    });
    
    
}


-(NSMutableArray *)fetchPaymentForTipsFromLocalDataBase
{
    
    NSMutableArray *fetchPaymentArray = [self.paymentModesarray mutableCopy];
    
    NSMutableArray *Allobjects = [[self getPaymentDetailForEntity:@"TenderPay" withThePredicate:nil] mutableCopy];
    
    NSArray *arrayOfPayId = [self.paymentModesarray valueForKey:@"PayId"];
    NSSet *arrayPayId = [NSSet setWithArray:arrayOfPayId];
    arrayOfPayId = arrayPayId.allObjects;
    
    NSMutableArray *paymentArrayOfPayid = [[self getPaymentDetailForEntity:@"TenderPay" withThePredicate:[NSPredicate predicateWithFormat:@"payId IN %@",arrayOfPayId]] mutableCopy];
    [Allobjects removeObjectsInArray:paymentArrayOfPayid];
    
    for (TenderPay *tenderPay in Allobjects)
    {
        NSMutableDictionary *paymentDict = [[NSMutableDictionary alloc]init];
        paymentDict[@"PayId"] = [NSString stringWithFormat:@"%@",tenderPay.payId.stringValue];
        paymentDict[@"CardIntType"] = [NSString stringWithFormat:@"%@",tenderPay.cardIntType];
        paymentDict[@"PaymentName"] = [NSString stringWithFormat:@"%@",tenderPay.paymentName];
        paymentDict[@"TransactionNo"] = @"";
        paymentDict[@"CardHolderName"] = @"";
        paymentDict[@"ExpireDate"] = @"";
        paymentDict[@"AccNo"] = @"";
        paymentDict[@"CardType"] = @"";
        paymentDict[@"BillAmount"] = @"";
        paymentDict[@"TipsAmount"] = @"";
        [fetchPaymentArray addObject:paymentDict];
    }
    return fetchPaymentArray;
}

-(NSArray *)getPaymentDetailForEntity:(NSString *)entityName withThePredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    if (predicate!=nil) {
        fetchRequest.predicate = predicate;
    }
    
    NSArray *paymentObjects = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return paymentObjects;
}


-(CGFloat)totalBillAmountOfPayment :(NSArray *)paymentArray
{
    CGFloat billAmount  = 0.00;
    for (NSDictionary *dictionary in paymentArray) {
        billAmount += [[dictionary valueForKey:@"BillAmount"] floatValue];
    }
    return billAmount;
}


-(CGFloat)getSumOfTheValue :(NSString *)key
{
    CGFloat sum  = 0.00;
    for (NSDictionary *dictionary in self.paymentModesarray) {
        sum += [[dictionary valueForKey:key] floatValue];
    }
    return sum;
}
-(void)updateTipWithGrandTotalForInvoice
{
    CGFloat billAmountOfInvoice = [self getSumOfTheValue:@"BillAmount"];
    CGFloat tipsOfInvoice = [self getSumOfTheValue:@"TipsAmount"];
    _tipOfInvoice.text = [self getStringWithUsingCurrencyFormatter:tipsOfInvoice];
    _grandTotalOfInvoice.text = [self getStringWithUsingCurrencyFormatter:tipsOfInvoice + billAmountOfInvoice];
}


-(IBAction)adjustTipsForInvoice:(id)sender
{
    [self fetchPaymentForTipsFromLocalDataBase];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    tipsAdjustmentVC = [storyBoard instantiateViewControllerWithIdentifier:@"TipsAdjustmentVC"];
    tipsAdjustmentVC.paymentTypeArray = [self fetchPaymentForTipsFromLocalDataBase];
    tipsAdjustmentVC.billAmountForTipCalculation = [self totalBillAmountOfPayment:[self fetchPaymentForTipsFromLocalDataBase]];
//    tipsAdjustmentVC.tipAmount = [[tipsDictionary valueForKey:@"TipsAmount"] floatValue];
    tipsAdjustmentVC.tipsAdjustmentVcDelegate = self;
    tipsAdjustmentVC.view.frame = self.view.bounds;
    [self.view addSubview:tipsAdjustmentVC.view];
    
}



- (DDXMLElement *)getValueFromXmlResponse:(NSString *)responseString string:(NSString *)string
{
   responseString = [RmsDbController removeNameSpaceFromXml:responseString rootTag:@"Response"];
    
    DDXMLDocument *fuelTypeDocument = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
    DDXMLNode *rootNode = [fuelTypeDocument rootElement];
    NSString *responseStr = [NSString stringWithFormat:@"/Response/%@",string];
    NSArray *FuelNodes = [rootNode nodesForXPath:responseStr error:nil];
    DDXMLElement *fuelElement = FuelNodes.firstObject;
    return fuelElement;
}

// Hiten Changes

- (void)tipAdjustMentformInvoice:(NSMutableDictionary *)paramValue
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
   
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self responseRapidServerTipAdjustmentResponse:response error:error];
    };
    
    self.tipAdjustmentFromInvoiceWebserviceConnection = [self.tipAdjustmentFromInvoiceWebserviceConnection initWithRequest:KURL_PAYMENT actionName:WSM_RAPID_SERVER_TIP_ADJUSTMENT_PROCESS params:paramValue completionHandler:completionHandler];

}

// Hiten Changes
// Rapid Server Tip Adjustment Result
-(void)responseRapidServerTipAdjustmentResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        
        if (response != nil) {
            if ([response isKindOfClass:[NSDictionary class]])
            {
                NSMutableDictionary *dictResponse = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                
                if ([dictResponse[@"RespMSG"]isEqualToString:@"Approved"])
                {
                    NSString *transcationNo = dictResponse[@"PNRef"];
                    [self adjustTipInLocalDataBasewithTipAmount:adjustedTipAmount withTipDictionary:selectedTipDictionary withTransctionNo:transcationNo];
                }
                else
                {
                    NSString *MsgElement = dictResponse[@"RespMSG"];
                    [_activityIndicator hideActivityIndicator];;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:MsgElement  buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }

            }
        }
        else
        {
            [_activityIndicator hideActivityIndicator];;
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Connection Dropped. Try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    });
}


-(void)responseCreditCardTipAdjustmentResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        
        if (response != nil) {
            if ([response isKindOfClass:[NSString class]]) {
                
                DDXMLElement *RespMSGElement = [self getValueFromXmlResponse:response string:@"RespMSG"];
                if ([RespMSGElement.stringValue isEqualToString:@"Approved"])
                {
                    DDXMLElement *PNRefElement = [self getValueFromXmlResponse:response string:@"PNRef"];
                    NSString *transcationNo = PNRefElement.stringValue;
                    [self adjustTipInLocalDataBasewithTipAmount:adjustedTipAmount withTipDictionary:selectedTipDictionary withTransctionNo:transcationNo];
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:RespMSGElement.stringValue  buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
        }
        else
        {
            [_activityIndicator hideActivityIndicator];;
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Connection Dropped. Try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    });
}

-(void)processTipAdjustmentWithURl:(NSString *)url transctionDetail:(NSString *)transDetail withTipAmount:(float)tipAmount
{
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseCreditCardTipAdjustmentResponse:response error:error];
        });
    };
    
    self.tipAdjustmentWebserviceConnection = [self.tipAdjustmentWebserviceConnection initWithAsyncRequestURL:url withDetailValues:transDetail asyncCompletionHandler:asyncCompletionHandler];

}

- (void)processTipAdjustment:(NSString *)url details:(NSString *)details withTipAmount:(float)tipAmount
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",@"ProcessCreditCard"]];
    adjustedTipAmount = tipAmount;
    [self processTipAdjustmentWithURl:url transctionDetail:details withTipAmount:tipAmount];
    return;
   /* NSURL *gateWayUrl=[NSURL URLWithString:url];
    
    NSData *postData=[details dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:gateWayUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    
    if(urlData)
    {
        NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        DDXMLElement *RespMSGElement = [self getValueFromXmlResponse:responseString string:@"RespMSG"];
        if ([RespMSGElement.stringValue isEqualToString:@"Approved"])
        {
            DDXMLElement *PNRefElement = [self getValueFromXmlResponse:responseString string:@"PNRef"];
            NSString *transcationNo = PNRefElement.stringValue;
            [self adjustTipInLocalDataBasewithTipAmount:tipAmount withTipDictionary:selectedTipDictionary withTransctionNo:transcationNo];
        }
        else
        {
            [_activityIndicator hideActivityIndicator];;
//            UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Info" message:RespMSGElement.stringValue delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
//            [alertError show];
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:RespMSGElement.stringValue  buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    }
    else
    {
        [_activityIndicator hideActivityIndicator];;
//        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Info" message:@"Connection Dropped. Try again." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
//        [alertError show];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Connection Dropped. Try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }*/
}


-(void)adjustTipInLocalDataBasewithTipAmount :(float)tipAmont withTipDictionary:(NSDictionary *)tipDictionary withTransctionNo:(NSString *)transActionNo
{
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:_lblLastInvoiceNo.text forKey:@"RegInvoiceNo"];
    [itemparam setValue:@"" forKey:@"TransactionNo"];
    [itemparam setValue:@"" forKey:@"AuthCode"];
    [itemparam setValue:[tipDictionary valueForKey:@"CardType"] forKey:@"CardType"];
    [itemparam setValue:[tipDictionary valueForKey:@"PayId"] forKey:@"PayId"];
    [itemparam setValue:[NSString stringWithFormat:@"%.2f",tipAmont] forKey:@"TipAmount"];
    [itemparam setValue:[tipDictionary valueForKey:@"AccNo"] forKey:@"AccNo"];
    itemparam[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    itemparam[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    itemparam[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    itemparam[@"BillDate"] = currentDateTime;
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self responseTipsTenderAdjustmentResponse:response error:error];
    };
    
    self.tipsAdjustmentInvoiceWC = [self.tipsAdjustmentInvoiceWC initWithRequest:KURL actionName:WSM_TIP_ADJUSTMENT params:itemparam completionHandler:completionHandler];

}
-(void)responseTipsTenderAdjustmentResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Tip Adjusted SuccessFully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
                [self getInvoiceItemDetail:invoiceNoForSelectedInvoice];
            }
            else
            {
                [_activityIndicator hideActivityIndicator];;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error occured in Tip Adjustment Process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
       else
    {
        [_activityIndicator hideActivityIndicator];;
    }
}

-(BOOL)checkTipAmount
{
    BOOL checkTip=NO;
    
    if(self.paymentModesarray.count>0){
       
        float tipAmout = [[self.paymentModesarray.firstObject valueForKey:@"TipsAmount"]floatValue];
        if(tipAmout>0)
        {
            checkTip=YES;
        }
        else{
            checkTip=NO;
        }
    }
    else{
        checkTip=NO;

    }
    
    
    return checkTip;
}


-(IBAction)previewandPrintReport:(id)sender{
   
    if(self.InvRcptDetail.count == 0){
        return;
    }
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emailReciptHtml]
                                         pathForPDF:@"~/Documents/previewreceiptInvoice.pdf".stringByExpandingTildeInPath
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

-(NSString *)getStringWithUsingCurrencyFormatter :(CGFloat)valueToConvertInString
{
   NSNumber *num=[NSNumber numberWithFloat:valueToConvertInString];
   return [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:num]];
}


#pragma mark - Reload Data For Invoice 
-(void)reloadMoreDataInTableView
{
    if ([lastCalledWebservice isEqualToString:WSM_INVOICE_LIST]) {
        [self reloadInvoiceData];
    }
    else if ([lastCalledWebservice isEqualToString:WSM_INVOICE_LIST_DATEWISE])
    {
        [self ReloadInvoiceDatewiseData];
    }
}

-(void)reloadInvoiceData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:_lblinvtype.text forKey:@"WType"];
        
        NSDate* sourceDate = [NSDate date];
        NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
        
        NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
        NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
        NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
        
        NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
        NSString *strDate = [NSString stringWithFormat:@"%@",destinationDate];
        param[@"Datetime"] = strDate;
        [param setValue:[NSString stringWithFormat:@"%lu",(unsigned long)self.invoicearray.count] forKey:@"RowIndex"];

        lastCalledWebservice = WSM_INVOICE_LIST;
        
//        CompletionHandler completionHandler = ^(id response, NSError *error) {
//            [self reloadResponseInvoiceResponse:response error:error];
//        };
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reloadResponseInvoiceResponse:response error:error];
            });
        };
        
        self.reloadInvoiceDetailConnection = [self.reloadInvoiceDetailConnection initWithRequest:KURL actionName:WSM_INVOICE_LIST params:param completionHandler:completionHandler];
        
    });
    
    
}
-(void)ReloadInvoiceDatewiseData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    _uvinvtype.hidden = YES;
    self.uvPaymentTable.hidden = YES;
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:calselectedDate forKey:@"sDate"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:[NSString stringWithFormat:@"%lu",(unsigned long)self.invoicearray.count] forKey:@"RowIndex"];

    lastCalledWebservice = WSM_INVOICE_LIST_DATEWISE ;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadResponseInvoiceDateWiseResponse:response error:error];
        });
    };
    
    self.reloadInvoiceDetailDateWiseConnection = [self.reloadInvoiceDetailDateWiseConnection initWithRequest:KURL actionName:WSM_INVOICE_LIST_DATEWISE params:param completionHandler:completionHandler];
}

- (void)reloadResponseInvoiceResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];;
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                if(responseArray.count>0)
                {
                    NSInteger oldCount = self.invoicearray.count;
                    NSInteger downloadCount = responseArray.count;
                    
                    NSMutableArray *indexPaths = [[NSMutableArray alloc]init];
                    
                    for (NSInteger i = oldCount; i < oldCount + downloadCount ; i++)
                    {
                        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        [indexPaths addObject:newIndexPath];
                    }
                    
                    NSArray *invoiceArray = responseArray;
                    //     invoiceArray = [invoiceArray arrayByAddingObjectsFromArray:self.invoicearray];
                    for (NSDictionary *invoiceDictionary in invoiceArray)
                    {
                        [self.invoicearray addObject:invoiceDictionary];
                    }
                    //   self.invoicearray = [invoiceArray mutableCopy];
                    [self.globalInvoiceArray removeAllObjects];
                    self.globalInvoiceArray = [self.invoicearray mutableCopy];
                    [self.tblInvoicedetail insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }
    }
    _lblInvoiceCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.invoicearray.count];
    invoiceIndexpath = -1;
}

- (void)reloadResponseInvoiceDateWiseResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                if(responseArray.count>0)
                {
                    NSInteger oldCount = self.invoicearray.count;
                    NSInteger downloadCount = responseArray.count;
                    
                    NSMutableArray *indexPaths = [[NSMutableArray alloc]init];
                    for (NSInteger i = oldCount; i < oldCount + downloadCount ; i++)
                    {
                        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        [indexPaths addObject:newIndexPath];
                    }
                    
                    NSArray *invoiceArray = responseArray;
                    //     invoiceArray = [invoiceArray arrayByAddingObjectsFromArray:self.invoicearray];
                    for (NSDictionary *invoiceDictionary in invoiceArray)
                    {
                        [self.invoicearray addObject:invoiceDictionary];
                    }
                    //   self.invoicearray = [invoiceArray mutableCopy];
                    _lblCalenderDetail.text = calselectedDate;
                    [self.globalInvoiceArray removeAllObjects];
                    self.globalInvoiceArray = [self.invoicearray mutableCopy];
                    
                    [self.tblInvoicedetail insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else
                {
                    _lblCalenderDetail.text = calselectedDate;
                }
            }
            _lblCalenderDetail.text = calselectedDate;
            _lblInvoiceCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.invoicearray.count];
            invoiceIndexpath = -1;
        }
    }
}

-(void)configureDateLabel:(UILabel *)label
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm ss";
    NSString *currentDateTime = [formatter stringFromDate:date];
    label.text = currentDateTime;
}

- (void)nextPassPrint
{
    
    if (localInvoiceTicketPassArray.count == 0) {
        [self nextPrint];
        return;
    }
    
    PassPrinting *passPrinting = [[PassPrinting alloc] init];
    passPrinting._printingData = localInvoiceTicketPassArray.lastObject;
    
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
        if (currentPrintStep == Invoice_PassPrint) {
            [localInvoiceTicketPassArray removeLastObject];
            [self nextPassPrint];
        }
        else
        {
            [self nextPrint];
        }
    }
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    NSString *retryMessage  ;
    if (currentPrintStep == Invoice_PassPrint) {
        retryMessage = @"Failed to pass print receipt. Would you like to retry.?";
        [self displayPassPrintRetryAlert:retryMessage];
    }
    else
    {
        if (currentPrintStep == Invoice_CardPrint) {
            retryMessage = @"Failed to Card print receipt. Would you like to retry.?";
        }
        else
        {
            retryMessage = @"Failed to Invoice print receipt. Would you like to retry.?";
        }
        [self displayLastInvoicePrintRetryAlert:retryMessage];
    }
}

- (void)nextPrint
{
    BOOL isApplicable = FALSE;
    currentPrintStep++;
    
    switch (currentPrintStep) {
        case   Invoice_PrintBegin:
            break;
        case Invoice_PassPrint:
            if (localInvoiceTicketPassArray.count > 0) {
                isApplicable = TRUE;
                [self nextPassPrint];
            }
            break;
        case Invoice_CardPrint:
            [self invoiceCardPrint];
            isApplicable = TRUE;
            
            break;
        case Invoice_BillPrint:
            [self invoiceBillPrint];
            isApplicable = TRUE;
            break;
            

        case Invoice_PrintDone:
        case Invoice_PrintCancel:
            return;
            break;
    }
    if (isApplicable == FALSE) {
        [self nextPrint];
    }
}

-(void)displayLastInvoicePrintRetryAlert :(NSString *)message
{
    InvoiceDetail * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep--;
        [myWeakReference nextPrint];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep = Invoice_PrintDone;
        [myWeakReference nextPrint];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}
-(void)displayPassPrintRetryAlert :(NSString *)message
{
    InvoiceDetail * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self nextPassPrint];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep = Invoice_PrintDone;
        [myWeakReference nextPrint];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}
- (void)configureItemTicketsPrintArrayForLastInvoice:(NSArray *)itemDetails
{
    localInvoiceTicketPassArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *item in itemDetails) {
        if (item[@"ItemTicketDetail"]) {
            
            NSArray * itemTicketDetail = item[@"ItemTicketDetail"];
            if ([itemTicketDetail isKindOfClass:[NSArray class]] && itemTicketDetail.count > 0) {
                
                for (NSMutableDictionary *itemTicketDictionary in itemTicketDetail) {
                    itemTicketDictionary[@"InvoiceNo"] = @"";
                    itemTicketDictionary[@"ItemName"] = [item valueForKey:@"ItemName"];
                    [localInvoiceTicketPassArray addObject:itemTicketDictionary];
                }
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
