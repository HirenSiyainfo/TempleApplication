//
//  TenderViewController.m
//  POSRetail
//
//  Created by Keyur Patel on 29/04/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import "TenderViewController.h"
#import "UITableViewCell+NIB.h"
#import "CustomTenderCell.h"
#import "PrinterFunctions.h"
#import "RasterDocument.h"
#import "ActionSheetStringPicker.h"
#import "MyPrintPageRenderer.h"
#import "RmsDbController.h"
#import "PaymentData.h"
#import "PrintJob.h"
#import "InvoiceData_T+Dictionary.h"
#import "Configuration.h"
#import "Configuration+Dictionary.h"
#import "TenderPay+Dictionary.h"
#import "Keychain.h"
#import "CardProcessingVC.h"
#import <MessageUI/MessageUI.h>
#import "EmailFromViewController.h"
#import "StarBitmap.h"
#import "SignatureViewController.h"
#import "Configuration+Dictionary.h"
#import "PaymentModeItem.h"
#import "CreditcardCredetnial+Dictionary.h"
#import "UpdateManager.h"
#import "TenderSubTotalView.h"
#import "TipsVC.h"
#import "TipsAdjustmentVC.h"
#import "TipPercentageMaster.h"
#import "RestaurantOrder+Dictionary.h"
#import "RestaurantOrderList.h"
#import "GiftCardPosVC.h"
#import "InvoiceReceiptPrint.h"
#import "GasInvoiceReceiptPrint.h"
#import "PostpayGasInvoiceReceiptPrint.h"
#import "CardReceiptPrint.h"
#import "PassPrinting.h"
#import "CustomerViewController.h"
#import "PaxConstants.h"
#import "PaxMagneticCardReceipt.h"
#import "PaxEMVCardReceipt.h"
#import "RapidInvoicePrint.h"
#import "NSArray+Methods.h"
#import "LastInvoiceData+NSDictionary.h"
#import "RestaurantItem+Dictionary.h"

#import "ItemTax+Dictionary.h"
#import "DepartmentTax+Dictionary.h"
#import "TaxMaster+Dictionary.h"
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "PaxDevice.h"
#import "InitializeResponse.h"
#import "RcrPosVC.h"
#import "TenderProcessManager.h"
#import "PrintJobBase.h"
#import "DoCreditResponse.h"
#import "NSString+Methods.h"
#import "TenderGiftCardProcessVC.h"
#import "GiftCardReceiptPrint.h"
#import "HouseChargeReceiptPrint.h"
#import "EBTAdjustmentVC.h"

#define TCP_PRINT_SUPPORT


#define paymentTypePriceBtn 301
#define PRINT_RECEIPT_PROMT_ALERT 333

#define PRINT_ERROR_ALERT 444
#define OFFLINE_INVOICE_ALERT 1515

#define CUSTMER_DISPLAY_TIP_ADJUSTMENT 858

typedef enum TenderReceiptPrintEmailProcess {
    TenderReceiptPrint ,
    TenderReceiptPrintAndEmail,
    Email
} TenderReceiptPrintEmailProcess;



@interface TenderViewController () <MFMailComposeViewControllerDelegate,tipsSelectionDeletage,TipsAdjustmentVcDelegate,UITextFieldDelegate,CustomerSelectionDelegate,PrinterFunctionsDelegate,RapidInvoicePrintDelegate,PaxDeviceDelegate , TenderGiftCardProcessVCDelegate , EmailFromViewControllerDelegate , NSKeyedArchiverDelegate,EBTAdjustmentVCDelegate>
{
    GiftCardPosVC *giftcardVC;
    PaxDevice *paxDevice;
    InvoiceData_T *invoiceData;
    TipsVC *tipsVC;
    TipsAdjustmentVC *tipsAdjustmentVC;
    IntercomHandler *intercomHandler;
    TenderGiftCardProcessVC *tenderGiftCardProcessVC;
    EmailFromViewController *emailFromViewController;
    HouseChargeReceiptPrint *houseChargeReceiptPrint;
    
    RapidCustomerLoyalty *rapidCustomerLoyalty;
    
    UITapGestureRecognizer *singleTapChangeDue;
    UIViewController *viewsignAlert;
    
    NSMutableArray *receiptDataArray;
    NSArray *array_port;
    NSInteger selectedPort;
    NSIndexPath *currentIndexPath;
    BOOL istenderclick;
    BOOL isChangeDueOpen;
    NSString *strInvoiceNo;
    BOOL isPaxConnected;
    BOOL isPassDetailGenerated;
    
    float userEditedAmount;
    CGFloat quickAmount;
    CGFloat custBalanceAmount;
    CGFloat roundValue;
    NSTimer *watchDogTimer;
    NSString *paymentVar;
    NSInteger indexOfCashType;
    NSDictionary *selectedTipDictionary;
    NSTimer *changeDueTimer;
    CGFloat customerDiplayTipAmount;
    CGFloat changeDueTipAmount;
    NSMutableArray *filterItemTicketArray;
    NSMutableArray *filterManualReceiptDetaiArray;
    NSMutableArray *tipAdjustmentDetail;
    NSMutableArray *giftCardPrintDetail;
    NSMutableArray *houseChargePrintDetail;
    NSMutableArray *houseChargeArray;

    NSInteger tenderReceiptPrintEmailProcess;
    NSString *regstrationPrefix;
    NSMutableArray *paxVoidArray;
    NSInteger voidCardNumber;
    NSString *paxSerialNo;
}

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnDone;
@property (nonatomic, weak) IBOutlet UIButton *btnRounded;
@property (nonatomic, weak) IBOutlet UIButton *tipsButton;
@property (nonatomic, weak) IBOutlet UIView *tipsView;
@property (nonatomic, weak) IBOutlet UIView *uvDisplayBillAmountsview;
@property (nonatomic, weak) IBOutlet UIButton *btnContinueEBT;
@property (nonatomic, weak) IBOutlet UIButton *btnAdjustEBT;
@property (nonatomic, weak) IBOutlet UILabel *customerNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *removeCustomerButton;
@property (nonatomic, weak) IBOutlet UIButton *addCustomerButton;
@property (nonatomic, weak) IBOutlet UIView *transactionView;
@property (nonatomic, weak) IBOutlet UIView *printButtonContainerView;
@property (nonatomic, weak) IBOutlet UILabel *paxStatusDisplay;
@property (nonatomic, weak) IBOutlet TenderSubTotalView *tenderSubtotalViewWithOutTips;
@property (nonatomic, weak) IBOutlet TenderSubTotalView *tenderSubtotalViewWithTips;
@property (nonatomic, weak) IBOutlet UILabel *statusMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel *lblCompanyName;
@property (nonatomic, weak) IBOutlet UILabel *lblRegisterName;
@property (nonatomic, weak) IBOutlet UIView *uvTenderView;
@property (nonatomic, weak) IBOutlet UIView *uvFooterView;
@property (nonatomic, weak) IBOutlet UIView * currencyView;
@property (nonatomic, weak) IBOutlet UIButton * btnClose;
@property (nonatomic, weak) IBOutlet UIButton * tenderEnterBtn;
@property (nonatomic, weak) IBOutlet UITableView * tblPaymentData;
@property (nonatomic, weak) IBOutlet UIView * uvtendernumpad;
@property (nonatomic, weak) IBOutlet UILabel * lbltotItem;
@property (nonatomic, weak) IBOutlet UILabel * lblRegInvoiceNo;
@property (nonatomic, weak) IBOutlet UILabel * lblTransaction;
@property (nonatomic, weak) IBOutlet UIView * customSignatureAlert;
@property (nonatomic, weak) IBOutlet UILabel * lblCustSingAlert;
@property (nonatomic, weak) IBOutlet UILabel * lblAccountNo;
@property (nonatomic, weak) IBOutlet UILabel * lblcardholderName;
@property (nonatomic, weak) IBOutlet UILabel * lblAuthCodeTemp;
@property (nonatomic, weak) IBOutlet UILabel *lbltenderAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblDueAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblDiscount;
@property (nonatomic, weak) IBOutlet UILabel *lblSubTotal;
@property (nonatomic, weak) IBOutlet UILabel *lblTaxAmount;
@property (nonatomic, weak) IBOutlet UIButton *paxVoidButton;
@property (nonatomic, weak) IBOutlet UIButton *btnchangeMoveToGas;

@property (nonatomic, strong) TenderProcessManager *tenderProcessManager;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, weak)  TenderSubTotalView *tenderSubTotalView;
@property (nonatomic, strong) Configuration *configuration;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) PaymentData *paymentData;

@property (nonatomic,weak)IBOutlet UILabel *currentDate;

@property (atomic) BOOL webserviceCallInProgress;
@property (atomic) CGFloat collectionAmount;
@property (nonatomic, strong) NSMutableDictionary *emailTempDictionary;
@property (nonatomic, strong) NSString *emailReciptHtml;
@property (nonatomic, strong) NSString *cardReciptHtml;

@property (nonatomic, strong) RapidWebServiceConnection *tenderWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *cardTypeWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *tipAdjustmentWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *customerTipAdjustmentWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *voidCreditCardTransctionWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *customerTipAdjustmentCallWebservice;
@property (nonatomic, strong) RapidWebServiceConnection *sendBillDataWC;
@property (nonatomic, strong) RapidWebServiceConnection *voidTransactionProcessWC;
@property (nonatomic, strong) RapidWebServiceConnection *sendBillDataWatchDogWC;
@property (nonatomic, strong) RapidWebServiceConnection *tipsAdjustmentTenderWC;
@property (nonatomic, strong) RapidWebServiceConnection *CheckHouseChargeCreditLimitWC;


@property (nonatomic, strong) NSMutableDictionary *invoiceNotificationDict;
@property (nonatomic, strong) NSMutableArray *tipsPercentArray;
@property (nonatomic, strong) NSString  *serverInvoiceNo;

@property (nonatomic, strong) NSMutableArray *prepayPumpsArray;


//@property (atomic) TENDER_PROCESS_STEPS currentStep ;
@property (nonatomic, strong) UpdateManager *updateManager;


@property (nonatomic, strong) NSIndexPath * currentIndexPath;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;

@property (nonatomic, strong) NSNumber  *tipSetting;
@property (nonatomic, assign) NSInteger selectedPaymentModeIndex;
@property (nonatomic, strong) NSMutableDictionary *Payparam;
@property (nonatomic, strong) NSDate *doneButtonTimeStamp;
@property (atomic) NSInteger printJobCount;
@property (nonatomic, strong) NSIndexPath *selectedPaymentIndexPath;
@property (nonatomic, strong) NSLock *buttonLock;
@property (nonatomic, strong) NSDate *previousDate;

@end

@implementation TenderViewController

@synthesize currentIndexPath,lbltenderAmount,lblDiscount,lblSubTotal,lblTaxAmount;
@synthesize strInvoiceNo,loadingIndicator;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize updateManager,selectedFuelType ,receiptDataArray,isGasItem;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)addGestureToChangeDueScreen
{
    singleTapChangeDue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapChangeDue)];
    singleTapChangeDue.numberOfTapsRequired = 2;
    [_uvTenderView addGestureRecognizer:singleTapChangeDue];
    
    NSDictionary *changeDueTimeDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChangeDue_Setting"];
    if (changeDueTimeDictionary != nil) {
        if ([[changeDueTimeDictionary valueForKey:@"changeDueTimerSwitch"] boolValue] == TRUE) {
            changeDueTimer = [NSTimer scheduledTimerWithTimeInterval:[[changeDueTimeDictionary valueForKey:@"changeDueTimerValue"] floatValue] target:self selector:@selector(singleTapChangeDue) userInfo:nil repeats:NO];
            changeDueTimer.valid;
        }
        else
        {
            
        }
    }
    else
    {
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
//     crashLabel.text = [NSString stringWithFormat:@"Enter Any Number Between %d To %d",TP_BEGIN , TP_TRANSACTION_DECLINED];
    if (isPassDetailGenerated == FALSE) {
        [self configurePaymentView];
        [self generatePassDetail];
        isPassDetailGenerated = TRUE;
        [self configureCustomerButtons];
        
    }
    
    if (self.tenderItemCount != [self reciptDataAryForBillOrder].count)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"41 - Please Try Again. " buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;

    }
    
    [self configurePaxDevice];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lastTenderState) name:UIApplicationWillTerminateNotification object:nil];
    if (self.tenderType.length >0) {
        
        [self.paymentData setActualAmount:self.paymentData.amountToPay atPaymentType:self.tenderType withPayId:self.payId];
         [self updateTenderStatus];
        if([self.tenderType isEqualToString:@"Credit"] || [self.tenderType isEqualToString:@"Debit"])
        {
            [self btntenderClick:nil];
        }
        
        if ([self.tenderType isEqualToString:@"HouseCharge"] && self.paymentData.rapidCustomerLoyalty == nil)
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [self btnCustomerClick:nil];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select Customer for House Charge Payment. " buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            
            return;
            
        }
        
    }
    

    self.btnchangeMoveToGas.hidden = YES;
    self.tenderEnterBtn.frame = CGRectMake(716.0, 14.0, 289.0, 92.0);
    if([self.rmsDbController checkGasPumpisActive]){
        self.btnchangeMoveToGas.hidden = NO;
        self.tenderEnterBtn.frame = CGRectMake(826.0, 14.0, 190.0, 92.0);
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)lastTenderState
{
  
    NSString *currentStep = [self currentStepName:self.tenderProcessManager.currentStep];
    currentStep = [NSString stringWithFormat:@"Last Tender State = %@ - %@",currentStep,self.paymentData.strInvoiceNo];
    [[NSUserDefaults standardUserDefaults] setObject:currentStep forKey:@"TenderStateBeforeTermination"];
    [[NSUserDefaults standardUserDefaults] setObject:self.paymentData.strInvoiceNo forKey:@"LastInvoiceNo"];
    
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)updateViewWithTipSetting:(NSNumber *)tipSetting
{
//    tipSetting = @(0);
    if([tipSetting isEqual: @(1)])
    {
        _tipsButton.hidden = NO;
        _tenderSubTotalView = _tenderSubtotalViewWithTips;
    }
    else
    {
        _tipsButton.hidden = YES;
        _tenderSubTotalView = _tenderSubtotalViewWithOutTips;
    }
    [_uvDisplayBillAmountsview addSubview:_tenderSubTotalView];
    [_tenderSubTotalView updateSubtotalViewWithBillAmount:self.paymentData.amountToPay withCollectedAmount:0.00 withChangeDue:0.00 withTipAmount:0.00];
}

-(void)updatePaymentDetailForInsertGasItem
{
    NSString *invoiceTotal = [[self.dictAmoutInfo valueForKey:@"InvoiceTotal"] stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    self.paymentData.amountToPay = [self.crmController.currencyFormatter numberFromString:invoiceTotal].floatValue ;
    self.paymentData.billAmount = [self.crmController.currencyFormatter numberFromString:invoiceTotal].floatValue;
    
    self.lblSubTotal.text = [self.dictAmoutInfo valueForKey:@"InvoiceSubTotal"];
    self.lblTaxAmount.text = [self.dictAmoutInfo valueForKey:@"InvoiceTax"];
    self.lblDiscount.text =  [self.dictAmoutInfo valueForKey:@"InvoiceDiscount"];

}

- (void)configurePaymentView
{
    self.paymentData = [[PaymentData alloc]init];
    
    // Hide/Show tip button
    [self updateViewWithTipSetting:self.configuration.localTipsSetting];
   
    _tenderEnterBtn.enabled=NO;
    self.btnchangeMoveToGas.enabled=NO;
    _lblRegInvoiceNo.hidden = YES;
    _lblTransaction.hidden = YES;
    _transactionView.hidden = YES;
   
    BOOL isUncompeleteTenderProcess = FALSE;
    [self updateBillDetaiUI];
    if (self.restaurantOrderTenderObjectId)
    {
        NSManagedObjectContext *privateManageobjectContext = self.managedObjectContext;
        RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderTenderObjectId];
        if (restaurantOrder != nil && restaurantOrder.paymentData != nil) {
            self.paymentData = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantOrder.paymentData];
            isUncompeleteTenderProcess = TRUE;
            
            if ([self.paymentData isCreditCardApprovedPaymentMode] == TRUE) {
                self.btnClose.enabled = NO;
            }
            self.dictAmoutInfo = self.paymentData.dictAmoutInfo;
        }
        else
        {
            [self updatePaymentDataValue];
            [self GetPaymentData];
        }
    }
    else
    {
        [self updatePaymentDataValue];
        [self GetPaymentData];
    }
    
  

    if(self.paymentData.paymentForVoid.count>0){
        [self loadBalanceforVoidTransaction];
    }
    self.tipsPercentArray =[self fetchTipFromDatabase];
    self.currencyFormatter = [[NSNumberFormatter alloc] init];
    self.currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    self.currencyFormatter.maximumFractionDigits = 0;
    [self setCurrencyFormatterToButtontitle];
    
    if (isUncompeleteTenderProcess == TRUE) {
        [self updateTenderStatus];
        [_tblPaymentData reloadData];
    }
}

-(void)updateBillDetaiUI
{
    NSString *invoiceTotal = [[self.dictAmoutInfo valueForKey:@"InvoiceTotal"] stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    self.paymentData.amountToPay = [self.crmController.currencyFormatter numberFromString:invoiceTotal].floatValue ;
    self.paymentData.billAmount = [self.crmController.currencyFormatter numberFromString:invoiceTotal].floatValue;
    
    self.lblSubTotal.text = [self.dictAmoutInfo valueForKey:@"InvoiceSubTotal"];
    self.lblTaxAmount.text = [self.dictAmoutInfo valueForKey:@"InvoiceTax"];
    self.lblDiscount.text =  [self.dictAmoutInfo valueForKey:@"InvoiceDiscount"];

}

-(void)updatePaymentDataValue
{
    
    if (self.restaurantOrderTenderObjectId)
    {
        NSManagedObjectContext *privateManageobjectContext = self.managedObjectContext;
        RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderTenderObjectId];
        self.paymentData.numberOfGuest = [NSString stringWithFormat:@"%@",restaurantOrder.noOfGuest];
        self.paymentData.tableNo = [NSString stringWithFormat:@"%@",restaurantOrder.tabelName];
    }
    
    self.paymentData.rcrBillSummary = self.rcrBillSummary;
    self.paymentData.rapidCustomerLoyalty = self.tenderRapidCustomerLoyalty;
    self.paymentData.billAmountCalculator = self.billAmountCalculator;
    
    self.paymentData.isCheckCashApplicableAplliedToBill = self.isCheckCashApplicableAplliedToBill;
    self.paymentData.isVoidForInvoice = self.isVoidForInvoice;
    self.paymentData.isHouseChargePay = self.isHouseChargePay;
    self.paymentData.payId = self.payId;
    
    self.paymentData.receiptDataArray = self.receiptDataArray;
    self.paymentData.paymentForVoid = self.paymentForVoid;
    
    self.paymentData.dictCustomerInfo = self.dictCustomerInfo;
    self.paymentData.dictAmoutInfo = self.dictAmoutInfo;

    [self.paymentData setHouseChargeValue:self.houseChargeValue];
    [self.paymentData setEbtAmount:self.ebtAmount];
    [self.paymentData setHouseChargeAmount:self.houseChargeAmount];
    [self.paymentData setModuleIdentifier:self.moduleIdentifier];
    [self.paymentData setStrInvoiceNo:self.strInvoiceNo];
    [self.paymentData setBillItemDetailString:self.billItemDetailString];
    [self.paymentData setTenderType:self.tenderType];

}

-(void)configureCustomerButtons
{
    if (self.paymentData.rapidCustomerLoyalty) {
        _addCustomerButton.enabled = NO;
        _removeCustomerButton.hidden = YES;
        _customerNameLabel.text = self.paymentData.rapidCustomerLoyalty.customerName;
    }
}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    NSLog(@"%@",self.paymentData.rapidCustomerLoyalty);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _btnContinueEBT.hidden = YES;
    _btnAdjustEBT.hidden = YES;

    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.sendBillDataWC = [[RapidWebServiceConnection alloc]init];
    self.voidTransactionProcessWC = [[RapidWebServiceConnection alloc]init];
    self.sendBillDataWatchDogWC = [[RapidWebServiceConnection alloc]init];
    self.tipsAdjustmentTenderWC = [[RapidWebServiceConnection alloc]init];
    self.CheckHouseChargeCreditLimitWC = [[RapidWebServiceConnection alloc]init];

    if([[NSUserDefaults standardUserDefaults]valueForKey:@"BillData"])
    {
        
        NSString *strBillInfo = [NSString stringWithFormat:@"BillMasterBlock = %@ AND Bill Data = %@ AND %@ AND PaymentDetail = %@", [[NSUserDefaults standardUserDefaults]valueForKey:@"BillMasterBlock"],[[NSUserDefaults standardUserDefaults]valueForKey:@"BillData"],[[NSUserDefaults standardUserDefaults]valueForKey:@"TenderStateBeforeTermination"],[[NSUserDefaults standardUserDefaults]valueForKey:@"PaymentLocalDetailArray"]];
        
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        param[@"receiptarray"] = strBillInfo;
        param[@"registerid"] = (self.rmsDbController.globalDict)[@"RegisterId"];
        param[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        [param setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"BillDataDateTime"] forKey:@"currentDatetime"];
      
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self resonseSendBillDataResponse:response error:error];
        };
        
        self.sendBillDataWC = [self.sendBillDataWC initWithRequest:KURL actionName:WSM_INSERT_MISSED_INVOICE_DETAIL params:param completionHandler:completionHandler];

        
    }
    
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    istenderclick=FALSE;
    self.managedObjectContext=self.rmsDbController.managedObjectContext;

   // self.pumpManager = [[PumpManager alloc] initWithDelegate:self];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];

    self.lblCompanyName.text = [NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]];
    self.lblRegisterName.text = (self.rmsDbController.globalDict)[@"RegisterName"];
    _btnRounded.layer.cornerRadius = 10.0;
    //_tenderEnterBtn.layer.cornerRadius = 20.0;
    _uvFooterView.layer.borderWidth=1.0;
    _uvFooterView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _uvFooterView.layer.cornerRadius=4.0;
    _btnDone.layer.cornerRadius = 10.0;
    _uvTenderView.hidden=YES;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        _tblPaymentData.backgroundColor = [UIColor clearColor];
    }

    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(502, 430, 20, 20)];
    self.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.loadingIndicator.backgroundColor = [UIColor clearColor];
    self.loadingIndicator.hidesWhenStopped=NO;
    [self.loadingIndicator setHidden:NO];
    
    self.statusMessageLabel.text = @"Processing...";
    self.loadingIndicator.layer.cornerRadius = 5;
    
    _uvTenderView.frame = CGRectMake(0, 84, _uvTenderView.frame.size.width, _uvTenderView.frame.size.height);
   // [_uvTenderView addSubview:self.loadingIndicator];

    isChangeDueOpen=FALSE;
    
    self.selectedPaymentModeIndex = 0;
    self.tenderWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    self.cardTypeWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    self.tipAdjustmentWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    self.voidCreditCardTransctionWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    self.customerTipAdjustmentWebserviceConnection = [[RapidWebServiceConnection alloc]init];
     self.customerTipAdjustmentCallWebservice = [[RapidWebServiceConnection alloc]init];
    self.tenderProcessManager = [[TenderProcessManager alloc] initWithTenderDelegate:self];
    NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig" ];
    
    if(arrTemp.count > 0)
    {
        self.crmController.globalArrTenderConfig = [arrTemp mutableCopy];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PrintReq"]) {
        self.crmController.isPrintReq = TRUE;
    }
    else {
        self.crmController.isPrintReq = FALSE;
    }
    
    UIView *tmpview = [self.view viewWithTag:29876];
    tmpview.backgroundColor = [UIColor colorWithRed:2.0/255.0 green:115.0/255.0 blue:169.0/255.0 alpha:1];
    
    NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
    NSInteger number = keyChainInvoiceNo.integerValue;
    number++;
    
    self.configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    self.tipSetting = self.configuration.localTipsSetting;
    if (!self.configuration.localCustomerLoyalty.boolValue)
    {
        _addCustomerButton.hidden = YES ;
    }
    
    self.strInvoiceNo = [NSString stringWithFormat:@"%@%ld",self.configuration.regPrefixNo,(long)number ];
    regstrationPrefix = [NSString stringWithFormat:@"%@",self.configuration.regPrefixNo];
    
    // Do any additional setup after loading the view from its nib.

    self.printJobCount = 0;
    self.webserviceCallInProgress = NO;
    self.loadingIndicator.hidesWhenStopped = YES;
    
    
    [_tenderSubTotalView updateSubtotalViewWithBillAmount:[[self.dictAmoutInfo valueForKey:@"InvoiceTotal"] floatValue] withCollectedAmount:0.00 withChangeDue:0.00 withTipAmount:0.00 ];
 
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    
    [self updateBillDataWithInitialStep];
}

-(IBAction)btnDoneClick:(id)sender
{
    [self singleTapChangeDue];
}

-(void)loadBalanceforVoidTransaction{
    
    NSMutableArray *voidMutableArray = [self.paymentData.paymentForVoid mutableCopy];
    
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray *itemArrayAtIndex = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < itemArrayAtIndex.count; j++)
        {
            PaymentModeItem *paymentModeItem  = itemArrayAtIndex[j];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"PayId = %@",paymentModeItem.paymentId.stringValue];
            NSArray *array = [voidMutableArray filteredArrayUsingPredicate:predicate];
            if(array.count>0){
                float amount1 = [[array.firstObject valueForKey:@"BillAmount"] floatValue] - [[array.firstObject valueForKey:@"ReturnAmount"] floatValue];
                amount1 = amount1*-1;
                NSNumber *amount = @(amount1);
                paymentModeItem.actualAmount = amount;
                [voidMutableArray removeObject:array.firstObject];
            }
            NSLog(@"paymentModeItem with paymentType = %@",paymentModeItem.paymentType);
            NSLog(@"paymentModeItem with paymentName = %@",paymentModeItem.paymentName);
        }
    }
    
    [_tblPaymentData reloadData];
    [self updateTenderStatus];
}

- (void)setCurrencyFormatterToButtontitle
{
    NSArray *buttonTagArray = @[@"5",@"10",@"20",@"40",@"50",@"100"];
    for (int ind = 0; ind < buttonTagArray.count; ind++) {
        UIView *buttonview = [_currencyView viewWithTag:[buttonTagArray[ind] integerValue]];
        if ([buttonview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)buttonview;
            [button setTitle:[self applyCurrencyFomatter:buttonTagArray[ind]] forState:UIControlStateNormal];
            [button setTitle:[self applyCurrencyFomatter:buttonTagArray[ind]] forState:UIControlStateSelected];
        }
    }
}

- (NSString *)applyCurrencyFomatter:(NSString *)string
{
    if(string != nil)
    {
        NSNumber *number = @(string.floatValue);
        string = [self.currencyFormatter stringFromNumber:number];
        string = [string stringByReplacingOccurrencesOfString:@"," withString:@""];
        return string;
    }
    else
    {
        return nil;
    }
}

-(NSMutableArray *)fetchTipFromDatabase
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TipPercentageMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    NSMutableArray *tipDataBaseArray = [[NSMutableArray alloc]init];
    
    for (TipPercentageMaster *tipPercentageMaster in resultSet)
    {
        NSMutableDictionary *tipPercentageMasterDict = [[NSMutableDictionary alloc]init];
        tipPercentageMasterDict[@"TipsPercentage"] = tipPercentageMaster.tipPercentage;
        
        CGFloat tipCalculatedAmount = self.paymentData.amountToPay * tipPercentageMaster.tipPercentage.floatValue * 0.01;
        tipPercentageMasterDict[@"TipsAmount"] = [NSString stringWithFormat:@"%.2f",tipCalculatedAmount];
        [tipDataBaseArray addObject:tipPercentageMasterDict];
    }

    return tipDataBaseArray;
    
}

- (void)resonseSendBillDataResponse:(id)response error:(NSError *)error{
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            [self removeBillData];
        }
    }
}

- (void)setRoundValueForBillAmount:(CGFloat)billAmount
{
     roundValue  =  billAmount;
    if (roundValue < 0)
    {
        roundValue = (roundValue);
    }
    else
    {
        roundValue = ceilf(roundValue);
    }
    [_btnRounded setTitle:[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:@(roundValue)]] forState:UIControlStateNormal];
    _btnRounded.titleLabel.adjustsFontSizeToFitWidth = YES;
    _btnRounded.tag = roundValue;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CardTransactionRequest"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    
    if (self.paymentData.ebtAmount != 0)
    {
        _btnContinueEBT.hidden = NO;
        _btnAdjustEBT.hidden = NO;

    }
    else{
        _btnContinueEBT.hidden = YES;
        _btnAdjustEBT.hidden = YES;

    }
    [self setRoundValueForBillAmount:self.paymentData.
     billAmount];
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
    
    [TenderViewController setPortName:localPortName];
    [TenderViewController setPortSettings:array_port[selectedPort]];
}

-(void)setStatusmessage :(NSString *)message withWarning:(BOOL)isWarning
{
    if (isWarning)
    {
        self.statusMessageLabel.textColor = [UIColor redColor];
    }
    else
    {
        self.statusMessageLabel.textColor = [UIColor blackColor];
    }
    self.statusMessageLabel.text = message;
}

- (NSString *)formatedTextForAmount:(CGFloat)amount {
    NSString *billAmount = [NSString stringWithFormat:@"%.2f",amount];
    return billAmount;
}

-(NSString *)formatedTextForAmountWithCurrencyFormatter:(CGFloat)amount {
  
    if (amount <= 0.00 && amount > -0.009) {
        amount = 0.00;
    }
    NSNumber *amountNumber = @(amount);
    NSString * billAmount = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:amountNumber]];
    return billAmount;
}


- (void)storeBillData {
    [[NSUserDefaults standardUserDefaults]setObject:[self.rmsDbController jsonStringFromObject:[self reciptDataAryForBillOrder]] forKey:@"BillData"];
    
    NSMutableDictionary *billMasterBlock = [@{
                                              @"Invoice Amount":[self formatedTextForAmount:self.paymentData.billAmount],
                                              @"Subtotal Amount":[[self.dictAmoutInfo valueForKey:@"InvoiceSubTotal"] stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]],
                                              @"Discount Amount":[[self.dictAmoutInfo valueForKey:@"InvoiceDiscount"] stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]],
                                              @"Tax Amount":[[self.dictAmoutInfo valueForKey:@"InvoiceTax"] stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]],
                                              } mutableCopy ];
    
    [[NSUserDefaults standardUserDefaults]setObject:[self.rmsDbController jsonStringFromObject:billMasterBlock] forKey:@"BillMasterBlock"];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.paymentData.strInvoiceNo forKey:@"StoreInvoiceNo"];
    
    NSMutableArray *paymentArray = [self paymentLocalDetailArray];
    [[NSUserDefaults standardUserDefaults] setObject:[self.rmsDbController jsonStringFromObject:paymentArray] forKey:@"PaymentLocalDetailArray"];
    
    
    NSString *currentStep = [NSString stringWithFormat:@"Last Tender State = %@ - %@",[self currentStepName:self.tenderProcessManager.currentStep],self.paymentData.strInvoiceNo];
    [[NSUserDefaults standardUserDefaults] setObject:currentStep forKey:@"TenderStateBeforeTermination"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    [[NSUserDefaults standardUserDefaults]setObject:strDateTime forKey:@"BillDataDateTime"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


-(NSMutableArray *)paymentLocalDetailArray
{
    
    NSMutableArray *paymentDetailArray = [[NSMutableArray alloc]init];
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSMutableDictionary *paymentDetailDictioanry = [[NSMutableDictionary alloc]init];
        NSString *strPaymentType = [self.paymentData paymentTypeAtIndex:i];
        NSString *strPaymentName = [self.paymentData paymentNameAtIndex:i];
        
        float actualAmount = [self.paymentData actualAmountAtIndex:i] ;
        float calCulatedAmount = [self.paymentData calculatedAmountAtIndex:i] ;
        float displayAmount = [self.paymentData diplayAmountAtIndex:i];
        
        if (actualAmount == 0 )
        {
            actualAmount = calCulatedAmount;
            if (actualAmount == 0)
            {
                actualAmount = displayAmount;
            }
        }

        if (!(actualAmount == 0))
        {
            paymentDetailDictioanry[@"BillAmount"] = [NSString stringWithFormat:@"%.2f",actualAmount];
            paymentDetailDictioanry[@"PaymentType"] = [NSString stringWithFormat:@"%@",strPaymentType];
            paymentDetailDictioanry[@"PaymentName"] = [NSString stringWithFormat:@"%@",strPaymentName];
            
            [paymentDetailArray addObject:paymentDetailDictioanry];
            
        }
    }
    return paymentDetailArray;
    
}



- (void)removeBillData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BillData"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BillDataDateTime"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"StoreInvoiceNo"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TenderStateBeforeTermination"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BillMasterBlock"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PaymentLocalDetailArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateBillDataWithInitialStep {
}




- (void)updateBillDataWithCurrentStep {
    
//    NSArray *paymentDetail = [self.paymentData invoicePaymentdetail];
//    NSArray *itemDetail = [self generateInvoiceDetailWith];
//    NSArray *masterDetail = [self.paymentData tenderInvoiceMst];
//
//    NSDictionary *billData = @{@"InvoiceItemDetail":itemDetail,
//                               @"InvoicePaymentdetail":paymentDetail,
//                               @"InvoiceMaster":masterDetail,
//                               @"BillItemDetail":self.billItemDetailString,
//                               @"RegInvoiceNo":self.strInvoiceNo,
//                               @"CurrentStepName":[self currentStepName:self.tenderProcessManager.currentStep]
//                               };
//    
//    NSLog(@"%@",[self currentStepName:self.tenderProcessManager.currentStep]);
//    
//    [[NSUserDefaults standardUserDefaults]setObject:billData forKey:@"TenderBillData"];
//    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    if (self.restaurantOrderTenderObjectId)
    {
        NSManagedObjectContext *privateManageobjectContext = self.managedObjectContext;
        RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderTenderObjectId];
        restaurantOrder.paymentData = [NSKeyedArchiver archivedDataWithRootObject:self.paymentData];
        
        restaurantOrder.orderStatus = @(self.tenderProcessManager.currentStep);
        [UpdateManager saveContext:privateManageobjectContext];
    }
}


//-(BOOL)preProcess
//{
//    
//    BOOL status = YES;
//    
//    switch (self.tenderProcessManager.currentStep)
//    {
//        case TP_BEGIN:
//            
//            // increment
//            // Offline data store
//            // missing
//            
//            // alert
//            // return false
//            // alert ok go to Pos
//            
//            /*for (NSDictionary *prepayDict in self.rmsDbController.pumpManager.prePayArray) {
//                
//                    FuelPump *fuelPump = (FuelPump *)[self.updateManager __fetchEntityWithName:@"FuelPump" key:@"pumpIndex" value:[prepayDict valueForKey:@"selectedPump"] shouldCreate:NO moc:self.rmsDbController.rapidPetroPos.petroMOC];
//                    ;
//                    if([fuelPump.status isEqualToString:@"SIM_Auth"] || [fuelPump.status isEqualToString:@"SIM_Disp"] || [fuelPump.status isEqualToString:@"Authorized"] || [fuelPump.status isEqualToString:@"Dispensing"]){
//                        
//                        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//                        {
//                            [self btnCloseclick:nil];
//                        };
//                        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Pump is Already" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
//                        
//                        break;
//                    }
//            }*/
//            
//            if (![self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS] && ![self isSpecOptionApplicableGiftCard] && ![self isSpecOptionApplicableHouseCharge]) /// Cash Or Non CreditCard...
//            {
//                // check and increment keychain invoice no and save it...
//                [self increaseInvRegisterNumber];
//                
//                //    [self logForInvoiceDataWithMethodName:@"TP_BEGIN Before Insert"];
//                
//                //  insert the offline data to database...................
//                [self insertDataInLocalDataBase];
//                
//                //    [self logForInvoiceDataWithMethodName:@"TP_BEGIN After Insert"];
//                
//                
//                if (!invoiceData.invoicePaymentData) {
//                    status = NO;
//                    
//                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//                    {
//                        NSDictionary *cardSwipeInfoDictionary = @{@"ErrorCode": @"50 - Please try again."};
//                        [Appsee addEvent:@"TP_BEGIN nil paymentData" withProperties:cardSwipeInfoDictionary];
//                    };
//                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"50 - Please try again." buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
//                }
//            }
//            
//            
//            
//            
//            
//            //            // check and increment keychain invoice no and save it...
//            //            if (isInvoiveNumberIncremented == FALSE)
//            //            {
//            //                isInvoiveNumberIncremented = TRUE;
//            //                [self increaseInvRegisterNumber];
//            //
//            //                /// Update PaymentData With TransationId....
//            //
//            //                [self updatePaymentDataWithTransactionID];
//            //            }
//            //
//            //            //  remove the offline data to database...................
//            //            [self removeLocalDataFromTable];
//            //
//            //            //  insert the offline data to database...................
//            //            [self insertDataInLocalDataBase];
//            //
//            //            if (!invoiceData.invoicePaymentData) {
//            //                status = NO;
//            //
//            //                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//            //                {
//            //                };
//            //                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"100 - Please try again." buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
//            //
//            //            }
//            //
//            //            // store missing invoice data for credit card and remove it for cash.........
//            //            if ([self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS])
//            //            {
//            //                [self storeBillData];
//            //            }
//            //            else
//            //            {
//            //                [self removeBillData];
//            //            }
//            
//            break;
//        case TP_CHECK_HOUSE_CHARGE_DETAILS:
//            if ([self isSpecOptionApplicableHouseCharge] && ![self isSpecOptionApplicableGiftCard] && ![self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS] )
//            {
//                // check and increment keychain invoice no and save it...
//
//                [self increaseInvRegisterNumber];
//                //  insert the offline data to database...................
//
//                [self insertDataInLocalDataBase];
//            }
//            break;
//            
//            
//        case TP_CHECK_GIFT_CARD_DETAIL:
//            
//            if ([self isSpecOptionApplicableGiftCard] && ![self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS]  ) /// Gift
//            {
//                // check and increment keychain invoice no and save it...
//                [self increaseInvRegisterNumber];
//                
//                //  insert the offline data to database...................
//                [self insertDataInLocalDataBase];
//            }
//            break;
//            
//        
//
//            
//        case TP_OPENCASH_DRAWER:
//        {
//            [self setStatusmessage:@"" withWarning:FALSE];
//        }
//            break;
//        case TP_CHECK_CARD_PAYMENT_DETAIL:
//            
//            
//            break;
//        case TP_PROCESS_CARDS:
//        {
//            
//            if ([self isSpecOptionApplicableAfterCreditCard:SPEC_CARD_PROCESS] ) /// Cash Or Non CreditCard...
//            {
//                // check and increment keychain invoice no and save it...
//                [self increaseInvRegisterNumber];
//                
//                //  insert the offline data to database...................
//                [self insertDataInLocalDataBase];
//                
//                if (!invoiceData.invoicePaymentData) {
//                    status = NO;
//                    
//                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//                    {
//                        NSDictionary *cardSwipeInfoDictionary = @{@"ErrorCode": @"51 - Please try again."};
//                        [Appsee addEvent:@"TP_PROCESS_CARDS nil paymentData" withProperties:cardSwipeInfoDictionary];
//                    };
//                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"51 - Please try again." buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
//                    
//                }
//            }
//            
//            
//            
//            
//            /* if ([self isSpecOptionApplicableAfterCreditCard:SPEC_CARD_PROCESS])
//             {
//             [self configurePaymentData];
//             
//             if (isInvoiveNumberIncremented == FALSE)
//             {
//             isInvoiveNumberIncremented = TRUE;
//             [self increaseInvRegisterNumber];
//             }
//             [self insertDataInLocalDataBase];
//             
//             if (!invoiceData.invoicePaymentData) {
//             status = NO;
//             
//             UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//             {
//             };
//             [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"101 - Please try again." buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
//             
//             }
//             
//             [self removeBillData];
//             }*/
//        }            break;
//            
//        case TP_CAPTURE_SIGNATURE:
//            self.Payparam = nil;
//            //  insert the offline data with signature to database...................
//            [self insertLastInvoiceDataToLocalData];
//            break;
//        case TP_COUSTMER_TIP_ADJUSTMENT:
//            
//            break;
//            
//        case TP_PROCESS_CHANGEDUE:
//            break;
//            
//        case TP_PROCESS_CARDSRECIPTPRINT:
//            break;
//            
//        case TP_PROCESS_COUSTMERRECIPETPRINT:
//            break;
//        case TP_PRINT_PASS:
//            break;
//            
//        case TP_CALL_SERVICE:
//            break;
//            
//        case TP_PRINT_RECEIPT_PROMT:
//            break;
//        case TP_PROCESS_RECEIPT:
//            break;
//            
//        case TP_GASPUMP_PREPAY_PROCESS:
//            break;
//            
//        case TP_DONE:
//            break;
//        case TP_FINISH:
//            break;
//        case TP_TRANSACTION_DECLINED:
//            break;
//            
//        case TP_IDLE:
//            break;
//    }
//    return status;
//}
//
//- (void)performNextStep {
//    // Restart Watch dog timer
//    [self restartWatchDogTimer];
//    
//    if ([self preProcess] == FALSE) {
//        return;
//    }
//    
//    
//    BOOL isApplicable = FALSE;
//    
//  /*  if (crashStep == self.tenderProcessManager.currentStep) {
//        assert(0);
//    }*/
//    self.tenderProcessManager.currentStep++;
//    
//    [self updateBillDataWithCurrentStep];
//
//    
//    NSString *currentStep = [NSString stringWithFormat:@"Last Tender State = %@ - %@",[self currentStepName:self.tenderProcessManager.currentStep],self.strInvoiceNo];
//    [[NSUserDefaults standardUserDefaults] setObject:currentStep forKey:@"TenderStateBeforeTermination"];
//    
//    switch (self.tenderProcessManager.currentStep)
//    {
//            
//        case TP_CHECK_HOUSE_CHARGE_DETAILS:
//            isApplicable = [self isSpecOptionApplicableHouseCharge];
//            if (isApplicable)
//            {
//                [self creditLimitForHouseCharge];
//            }
//            break;
//            
//        case TP_CHECK_GIFT_CARD_DETAIL:
//            isApplicable = [self isSpecOptionApplicableGiftCard];
//            if (isApplicable)
//            {
//                NSString *strAmount = [self getGiftCardAmount];
//                [self loadGiftCardView:strAmount];
//            }
//            break;
//            
//       
//            
//        case TP_OPENCASH_DRAWER:
//            isApplicable = [self isSpecOptionApplicable:SPEC_OPEN_DRAWER];
//            if (isApplicable)
//            {
//                if(self.paymentData.billAmount == 0.00){
//                    
//                    [self.tenderProcessManager performNextStep];
//                }
//                else{
//                    [self setStatusmessage:@"Opening CashDrawer" withWarning:FALSE];
//                    [self OpenCashDrawer];
//                }
//               
//            }
//            break;
//        case TP_CHECK_CARD_PAYMENT_DETAIL:
//            isApplicable = [self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS];
//            if (isApplicable)
//            {
//                if (self.rmsDbController.paymentCardTypearray.count >0)
//                {
//                    [self.tenderProcessManager performNextStep];
//                }
//                else
//                {
//                    [self GetPaymentCardTypeDetail];
//                    // call webservice
//                }
//                
//            }
//            break;
//        case TP_PROCESS_CARDS:
//            [self stopWatchDogTimer];
//            isApplicable = [self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS];
//            if (isApplicable)
//            {
////                // remove offline....
////                [self decreaseInvRegisterNumber];
////                isInvoiveNumberIncremented = FALSE;
////                [self removeLocalDataFromTable];
//                
//                [self setStatusmessage:@"Processing Cards" withWarning:FALSE];
//                
//                NSDictionary *changeDueMessageDictionary = @{
//                                                             @"Tender":@"CreditCardProcessing",
//                                                             @"TenderSubTotals":_dictAmoutInfo,
//                                                             @"ChangeDue":[self formatedTextForAmount:-self.paymentData.balanceAmount],
//                                                             @"ShowTender":[self formatedTextForAmount:self.paymentData.totalCollection],
//                                                             @"Total":[self formatedTextForAmount:self.paymentData.billAmount],
//                                                             @"CreditCardMessage":@"Please Swipe Insert Tap the card. Please enter the PIN if required.",
//                                                             @"CreditCardStep":@(CreditCardProcessingStepBegan)
//                                                             };
//                [self.crmController writeDictionaryToCustomerDisplay:changeDueMessageDictionary];
//                CardProcessingVC *cardProcess = [[CardProcessingVC alloc]initWithNibName:@"CardProcessingVC" bundle:Nil];
//                
//                cardProcess.cardProcessingDelegate = self;
//                cardProcess.tipInfo = [self fetchTipFromLocalDatabase];
//                cardProcess.billInfo = _dictAmoutInfo;
//                cardProcess.invoiceNo = self.strInvoiceNo;
//                cardProcess.paymentCardData = self.paymentData;
//                cardProcess.regstrationPrefix = regstrationPrefix;
//                cardProcess.isPaxConnectedToRapid =  isPaxConnected;
//                cardProcess.paxSerialNo = paxSerialNo;
//                cardProcess.modalPresentationStyle = UIModalPresentationCustom;
//                [self presentViewController:cardProcess animated:YES completion:Nil];
//            }
//            else{
//                self.tenderProcessManager.currentStep++;
//            }
//            break;
//        case TP_CAPTURE_SIGNATURE:
//            
//            isApplicable = FALSE;
//          /*  [self stopWatchDogTimer];
//            
//            isApplicable = [self isSpecOptionApplicableAfterCreditCard:SPEC_POS_SIGN_RECEIPT];
//            
//            isApplicableCustomer = [self isSpecOptionApplicableAfterCreditCard:SPEC_CUSTOMER_DISPLAY_SIGN_RECEIPT];
//            if (isApplicable)
//            {
//                [self launchSignatureCapture];
//            }
//            else if (isApplicableCustomer)
//            {
//                isApplicable = YES;
//                [self launchSignatureCaptureforCustomerDisplay];
//            }*/
//            
//            break;
//            
//        case TP_COUSTMER_TIP_ADJUSTMENT:
//            if ( self.paymentData.isTipAdjustmentApplicable .boolValue == TRUE)
//            {
//                isApplicable = YES;
//                [self setStatusmessage:@"Tips Adjustment Process" withWarning:FALSE];
////                [self adjustCustomerDisplayTipAmountInBridgePay:customerDiplayTipAmount];
//                [self tipAdjustmentProcess];
//            }
//            break;
//            
//        case TP_PROCESS_CHANGEDUE:
//            if(self.rmsDbController.pumpManager){
//                self.prepayPumpsArray = [self.rmsDbController.pumpManager.prePayArray mutableCopy];
//                [self.rmsDbController.pumpManager updateUnPaidPumpDetail:[self insertPumpDataDictionary]];
//            }
//            
//            [self setStatusmessage:@"" withWarning:FALSE];
//            isApplicable = TRUE;
//            [self processChangeDue];
//            break;
//        case TP_PROCESS_CARDSRECIPTPRINT:
//            isApplicable = [self isSpecOptionApplicableAfterCreditCard:SPEC_PRINT_RECIPT];
//            
//            if (isApplicable)
//            {
//                [self setStatusmessage:@"Printing Cards Receipt" withWarning:FALSE];
//                [self manualReceiptPrintProcess];
//                
//                /*if([self isManualReceiptApplicableForBill] == FALSE)
//                {
//                    [self setStatusmessage:@"Printing Cards Receipt" withWarning:FALSE];
//                    [self cardPrintReciept];
//                }
//                else
//                {
//                    [self.tenderProcessManager performNextStep];
//                }*/
//            }
//            break;
//        case TP_PROCESS_COUSTMERRECIPETPRINT:
//            
//            isApplicable = NO;
//            break;
//        case TP_CALL_SERVICE:
//            isApplicable = TRUE;
//            [self callWebserice];
//            break;
//        case TP_PRINT_RECEIPT_PROMT:
//           // isApplicable = [self isSpecOptionApplicable:SPEC_PRINT_PROMT];
//            isApplicable = NO;
//            if (isApplicable)
//            {
////                [self stopWatchDogTimer];
////                [self setStatusmessage:@"Printing Bill Receipt" withWarning:FALSE];
////                [self PrintReceipt];
////                self.tenderProcessManager.currentStep++;
//
////                [self displayPrintReciptPromt];
//            }
//            break;
//        case TP_PROCESS_RECEIPT:
//            
//            isApplicable = [self isSpecOptionApplicable:SPEC_PRINT_RECIPT];
//            if (isApplicable)
//            {
//                [self setStatusmessage:@"Printing Bill Receipt" withWarning:FALSE];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [self PrintReceipt];
//                });
//            }
//            break;
//          
//        case TP_PRINT_PASS:
//            isApplicable = [self isAplicableForPassReceiptPrint];
//            if (isApplicable)
//            {
//                [self setStatusmessage:@"Printing Pass Receipt" withWarning:FALSE];
//                [self passReceiptPrint];
//            }
//            break;
//        case TP_GASPUMP_PREPAY_PROCESS:
//            
//            if(self.rmsDbController.pumpManager){
//                [self.rmsDbController.pumpManager doPumpPrePayProcess:[self insertPumpDataDictionary]];
//            }
//    
//            break;
//        case TP_DONE:
//            [self setStatusmessage:@"" withWarning:FALSE];
//            [self.loadingIndicator stopAnimating];
//            [self removeTenderBillData];
//            [self addGestureToChangeDueScreen];
//        case TP_FINISH:
//            isApplicable = TRUE;
//            [self stopWatchDogTimer];
//            [self tenderTaskDidFinish];
//            _printButtonContainerView.hidden = NO;
//            _btnDone.hidden = NO;
//            self.tenderProcessManager.currentStep++;
//            break;
//        case TP_TRANSACTION_DECLINED:
//            isApplicable = TRUE;
//            [self stopWatchDogTimer];
//            break;
//            
//        case TP_IDLE:
//            break;
//            
//        case TP_BEGIN:
//            break;
//            
//            
//            
//    }
//    if (!isApplicable) {
//        [self.tenderProcessManager performNextStep];
//    }
//}
-(NSArray *)fetchLastInvoiceArray
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LastInvoiceData" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *lastInvoice = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    lastInvoice = [lastInvoice sortingArrayWithValue:@"regInvoiceNo" WithAscendingType:NO];
    return lastInvoice;
}

-(void)printTenderProcess
{
    NSArray * lastInvoiceArray = [self fetchLastInvoiceArray];
    if (lastInvoiceArray.count > 0)
    {
        NSString *portName     = @"";
        NSString *portSettings = @"";
        
        [self SetPortInfo];
        portName     = [RcrController getPortName];
        portSettings = [RcrController getPortSettings];
        
        LastInvoiceData *lastInvoiceData = lastInvoiceArray.firstObject;
        NSMutableArray * invoiceDetails = [NSKeyedUnarchiver unarchiveObjectWithData:lastInvoiceData.invoiceData];
        
        NSMutableArray *itemDetails = [invoiceDetails.firstObject valueForKey:@"InvoiceItemDetail"];
        NSMutableArray *paymentDetails = [invoiceDetails.firstObject valueForKey:@"InvoicePaymentDetail"];
        NSMutableArray *masterDetails = [invoiceDetails.firstObject valueForKey:@"InvoiceMst"];

        NSString *regInvNo = [masterDetails.firstObject  valueForKey:@"RegisterInvNo"];
        NSMutableArray *pumpCart = [[self processForPumpCart:regInvNo]mutableCopy];
        if(pumpCart.count == 0){
            // for PrePay
            pumpCart = [[self processForPumpCartPrepay] mutableCopy];
        }
//        NSString *itemName = [[itemDetails valueForKey:@"ItemName"]firstObject];
//        NSString *paymentMode = [[paymentDetails valueForKey:@"PayMode"]firstObject];
//
//        if([itemName isEqualToString:@"HouseCharge"] || [paymentMode isEqualToString:@"HouseCharge"]){
//            [self printHouseChargeReceipt:TRUE];
//        }
        
            RapidInvoicePrint *rapidInvoicePrint = [[RapidInvoicePrint alloc ]init];
            rapidInvoicePrint.rapidCustomerArray = [self getHouseChargeDetails] ;
            rapidInvoicePrint = [rapidInvoicePrint initWithPortName:portName portSetting:portSettings ItemDetail:itemDetails  withPaymentDetail:paymentDetails withMasterDetails:masterDetails fromViewController:self withTipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray withChangeDue:_lblDueAmount.text withPumpCart:pumpCart];
            [rapidInvoicePrint startPrint];
            
            rapidInvoicePrint.rapidInvoicePrintDelegate = self;

        
    }
}
-(IBAction)printTenderReceipt:(id)sender
{
    tenderReceiptPrintEmailProcess = TenderReceiptPrint;
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self printTenderProcess];
    });
}

-(IBAction)printTenderReceiptAndEmail:(id)sender
{
    tenderReceiptPrintEmailProcess = TenderReceiptPrintAndEmail;
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [self printTenderProcess];

}
-(void)didFinishPrintProcessSuccessFully
{
    [_activityIndicator hideActivityIndicator];
    if (tenderReceiptPrintEmailProcess == TenderReceiptPrintAndEmail) {
        [self emailSend:nil];
    }
}
-(void)didFailPrintProcess
{
    [_activityIndicator hideActivityIndicator];
}
-(NSString *)strTransactionNo{
    
    
    NSString *trno = @"";
    
    trno  = [self.paymentData.receiptDataArray.firstObject valueForKey:@"VoidTransactionNo"];
    
    return trno;
}

-(void)loadGiftCardView:(NSString*)strAmount{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    tenderGiftCardProcessVC = [storyBoard instantiateViewControllerWithIdentifier:@"TenderGiftCardProcessVC"];
    tenderGiftCardProcessVC.tenderGiftCardProcessVCDelegate = self;
    tenderGiftCardProcessVC.paymentGiftData = self.paymentData;
    tenderGiftCardProcessVC.dictCustomerInfo = self.paymentData.dictCustomerInfo;
    tenderGiftCardProcessVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:tenderGiftCardProcessVC animated:YES completion:nil];
}

#pragma GiftCard Delegate Method

-(void)didCancelGiftCardProcess
{
    [tenderGiftCardProcessVC dismissViewControllerAnimated:YES completion:nil];
    [_tblPaymentData reloadData];
}

-(void)didFinishGiftCardProcess
{
      [self.tenderProcessManager performNextStep];
}

-(void)didFailGiftCardProcess
{
    
}


-(void)successfullDone:(NSString *)strAmount{
    
    if(giftcardVC.isFromTender){
        [giftcardVC dismissViewControllerAnimated:YES completion:nil];
    }
    [self.tenderProcessManager performNextStep];
}

-(void)didSuccessfullGiftCardWithAccountNo:(NSString *)strAccno{
 
    [self setGiftCardAccountNo:strAccno];
    if(giftcardVC.isFromTender){
        [giftcardVC dismissViewControllerAnimated:YES completion:nil];
    }
    [self.tenderProcessManager performNextStep];
}

-(void)setGiftCardAccountNo:(NSString *)strAccNo{
    
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            NSString *payType = paymentModeItem.paymentType;
            if([payType isEqualToString:@"RapidRMS Gift Card"]){
            
                NSMutableDictionary * paymentDictionary = [paymentModeItem.paymentModeDictionary mutableCopy];
                [paymentDictionary setValue:@"RMSGiftCard" forKey:@"CardType"];
                [paymentDictionary setValue:strAccNo forKey:@"AccNo"];
                paymentModeItem.paymentModeDictionary = paymentDictionary;
            }
        }
    }
    
}
-(void)didCancelGiftCard{
    if(giftcardVC.isFromTender){
        [giftcardVC dismissViewControllerAnimated:YES completion:nil];
    }
//    [self decreaseInvRegisterNumber];
//    isInvoiveNumberIncremented = FALSE;
//    [self removeLocalDataFromTable];
}

-(void)successfullDoneWithCardDetail:(NSMutableDictionary *)cardDetail
{

}

-(void)GetPaymentCardTypeDetail
{
    [self stopWatchDogTimer];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self responseGetPaymentCardTypeDetailResponse:response error:error];
    };
    
    self.cardTypeWebserviceConnection = [self.cardTypeWebserviceConnection initWithRequest:KURL actionName:WSM_GET_CARD_TYPE_DETAIL params:itemparam completionHandler:completionHandler];
}

-(void)responseGetPaymentCardTypeDetailResponse:(id)response error:(NSError *)error
{
    [self _responseGetCardTypeDetailResponse:response error:error];
}

-(void)_responseGetCardTypeDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.rmsDbController.paymentCardTypearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                if(self.rmsDbController.paymentCardTypearray.count>0)
                {
                    [self.updateManager updateCreditcardCredentialWithDetail:self.rmsDbController.paymentCardTypearray withContext:self.managedObjectContext];
                    [self.tenderProcessManager performNextStep];
                }
            }
        }
    }
    else
    {
        CreditcardCredetnial *creditcardCredetnial = [self.updateManager fetchCreditcardCredetnialMoc:self.managedObjectContext];
        if (creditcardCredetnial != nil)
        {
            if (creditcardCredetnial.creditcardCredetnialDictionary!=nil) {
                self.rmsDbController.paymentCardTypearray = [[NSMutableArray alloc]init];
                [self.rmsDbController.paymentCardTypearray addObject:creditcardCredetnial.creditcardCredetnialDictionary];
                if(self.rmsDbController.paymentCardTypearray.count>0) {
                    [self.tenderProcessManager performNextStep];
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"GetPaymentCardTypeDetail" object:nil];
}

-(BOOL)filterArrayForTenderDisableFromSettingForTenderPayId :(TenderPay *)tenderPay
{
    BOOL isTenderDisable = FALSE;
    
    NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig"];
    NSPredicate * filterTenderPrediacte = [NSPredicate predicateWithFormat:@"SpecOption == %@ AND (PayId == %@ OR PayId == %d)",@"11", tenderPay.payId.stringValue, tenderPay.payId.integerValue];
    
    NSArray  *filterTenderDisablearray = [arrTemp filteredArrayUsingPredicate:filterTenderPrediacte];
    if (filterTenderDisablearray.count > 0) {
        isTenderDisable = TRUE;
    }
    return  isTenderDisable;
}

-(NSMutableDictionary *)paxAdditionalFields
{
    NSMutableDictionary *paxAdditionalFieldsDictionary = [[NSMutableDictionary alloc] init];
    paxAdditionalFieldsDictionary[@"AppName"] = @"";
    paxAdditionalFieldsDictionary[@"AID"] = @"";
    paxAdditionalFieldsDictionary[@"ARQC"] = @"";
    paxAdditionalFieldsDictionary[@"EntryMode"] = @"";
    paxAdditionalFieldsDictionary[@"RemainingBalance"] = @"";
    paxAdditionalFieldsDictionary[@"CVM"] = @"";
    paxAdditionalFieldsDictionary[@"SN"] = @"";
    paxAdditionalFieldsDictionary[@"TransactionType"] = @"";
    paxAdditionalFieldsDictionary[@"PaxHostReferenceNumber"] = @""; /////PaxHostReferenceNumber
    paxAdditionalFieldsDictionary[@"PaxSerialNo"] = @""; /////PaxSerialNo
    paxAdditionalFieldsDictionary[@"BatchNo"] = @""; /////BatchNo

    return paxAdditionalFieldsDictionary;

}


-(NSMutableDictionary *)bridgepayAdditionalFieldsForTenderPay:(NSNumber *)paymentId
{
    NSMutableDictionary *bridgepayAdditionalFieldsDictionary = [[NSMutableDictionary alloc] init];
    NSString *transctionServerForSpecOption = [NSString stringWithFormat:@"%@",[self transctionServerForSpecOptionforPaymentId:paymentId.integerValue]];

    bridgepayAdditionalFieldsDictionary[@"TransactionServer"] = transctionServerForSpecOption;
    
    return bridgepayAdditionalFieldsDictionary;
    
}



- (NSMutableDictionary *)paymentModeDictionaryAtTenderPay:(TenderPay *)tender
{
    NSMutableDictionary *paymentDict=[[NSMutableDictionary alloc]init];
    paymentDict[@"CardIntType"] = tender.cardIntType;
    paymentDict[@"PayId"] = tender.payId;
    paymentDict[@"PayImage"] = tender.payImage;
    paymentDict[@"PaymentName"] = tender.paymentName;
    if ([tender.cardIntType isEqualToString:@"HouseCharge"])
    {
        paymentDict[@"CardType"] = @"HouseCharge";
    }
    else
    {
        paymentDict[@"CardType"] = @"";
    }
    
    paymentDict[@"AuthCode"] = @"";
    paymentDict[@"AccNo"] = @"";
    paymentDict[@"TransactionNo"] = @"";//PNRef
    paymentDict[@"CardHolderName"] = @"";//cardName
    paymentDict[@"ExpireDate"] = @"";//ExpireDate
    paymentDict[@"RefundTransactionNo"] = @"";//RefundTransactionNo
    paymentDict[@"GatewayType"] = @"";//GatewayType
    paymentDict[@"IsCreditCardSwipe"] = @"0";//GatewayType
    paymentDict[@"TipsAmount"] = @"0";//TipsAmount
    paymentDict[@"SignatureImage"] = @"";//SignatureImage
    paymentDict[@"IsManualReceipt"] = @(0);//IsManualReceipt
    paymentDict[@"CreditTransactionId"] = @"";//CreditTransactionId
    paymentDict[@"PaxAdditionalFields"] = [self paxAdditionalFields];////PaxAdditionalFields
    paymentDict[@"BridgepayAdditionalFields"] = [self bridgepayAdditionalFieldsForTenderPay:tender.payId];////PaxAdditionalFields
    
    paymentDict[@"GiftCardNumber"] = @"";////GiftCardNumber
    paymentDict[@"GiftCardApprovedAmount"] = @(0.00);////GiftCardApprovedAmount
    paymentDict[@"IsGiftCardApproved"] = @"0";////GiftCardApproveAmount
    paymentDict[@"GiftCardBalanceAmount"] = @(0.00);////GiftCardBalanceAmount

    NSString *transctionServerForSpecOption = [NSString stringWithFormat:@"%@",[self transctionServerForSpecOptionforPaymentId:tender.payId.integerValue]];
    paymentDict[@"TransactionServer"] = transctionServerForSpecOption;//TransactionServer
    paymentDict[@"CreditCardSwipeApplicable"] = @([self isSpecOptionApplicableForMultipeCreditCard:SPEC_CARD_PROCESS withPaymentId:tender.payId.integerValue]);//CreditCardSwipeApplicable
    paymentDict[@"MulipleCreditCardApplicable"] = @([self isSpecOptionApplicableForMultipeCreditCard:SPEC_MULTIPLE_CARD_PROCESS withPaymentId:tender.payId.integerValue]);
    return paymentDict;
}

-(void)GetPaymentData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"paymentName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    NSMutableArray *paymentResponse = [[NSMutableArray alloc] init];
    
    if (resultSet.count > 0)
    {
        for (TenderPay *tender in resultSet) {
            if ([self filterArrayForTenderDisableFromSettingForTenderPayId:tender]) {
                continue;
            }
            
//            if (!self.configuration.localEbt.boolValue && [tender.cardIntType isEqualToString:@"EBT/Food Stamp"]) {
//                continue;
//            }
            
            if (!self.configuration.houseCharge.boolValue && [tender.cardIntType isEqualToString:@"HouseCharge"]) {
                continue;
            }
            NSMutableDictionary *paymentDict;
            paymentDict = [self paymentModeDictionaryAtTenderPay:tender];//TipsAmount
            
            [paymentResponse addObject:paymentDict];
        }
    }
    
    if (paymentResponse.count > 0)
    {
        [self.paymentData configureWith:[paymentResponse mutableCopy]];
        for (int pay=0; pay<self.paymentData.countOfPaymentModes; pay++)
        {
            BOOL isMultipleCreditCardApplicable =[self.paymentData isMultipleCardIsApplicable:pay];
            if (isMultipleCreditCardApplicable)
            {
               // NSInteger paymnetId = [self.paymentData paymentIdAtIndex:pay].integerValue;
              //  [self.paymentData addPaymentItemAtPaymentId:paymnetId];
            }
        }
        
        
        indexOfCashType = self.paymentData.indexOfFirstCashType;
        //_tenderEnterBtn.enabled = NO;
        //lbltotItem.text=[NSString stringWithFormat:@"%lu",(unsigned long)[receiptDataArray count]];
        
        
        CGFloat qty = 0;
        for (int i = 0 ; i < self.paymentData.receiptDataArray.count; i++) {
            CGFloat totalQty = [[self.paymentData.receiptDataArray[i] valueForKeyPath:@"itemQty"] floatValue] / [[self.paymentData.receiptDataArray[i] valueForKeyPath:@"PackageQty"] floatValue];
            qty += totalQty;
        }

        
        
        _lbltotItem.text = [NSString stringWithFormat:@"%ld",(long)qty];
        
        
        if (self.paymentData.isCheckCashApplicableAplliedToBill == TRUE)
        {
            [self.paymentData setCheckCashActualAmount:self.checkcashAmount atPaymentType:@"Check"];
            //_tenderEnterBtn.enabled = NO;
        }
        
        if (self.paymentData.ebtAmount != 0) {
            [self.paymentData configureEBTPaymentModeWithEBTAmount:self.paymentData.ebtAmount];
            
        }
        if (self.paymentData.houseChargeValue < 0) {
            [self.paymentData configureHouseChargeModeWithHouseChargeAmount:self.paymentData.houseChargeValue];
        }
        
        [self updateTenderStatus];
        [_tblPaymentData reloadData];
    }
    else
    {
        _tenderEnterBtn.enabled = NO;
        self.btnchangeMoveToGas.enabled = NO;
        [self updateTenderStatus];
    }
    
    /* if(_paymentForVoid.count>0)
     {
     [self updateTenderStatus]; 
     }*/
    
}



- (NSMutableDictionary *) getPaymentProcessData
{
	NSMutableDictionary * invoiceDetailDictionary = [[NSMutableDictionary alloc] init];
	
	NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
	NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
	invoiceDetailDict[@"InvoiceMst"] = [self.paymentData tenderInvoiceMst];
	invoiceDetailDict[@"InvoiceItemDetail"] = [self.paymentData generateInvoiceItemDetailWith:[self reciptDataAryForBillOrder]];
	invoiceDetailDict[@"InvoicePaymentDetail"] = [self.paymentData invoicePaymentdetail];
    if(self.crmController.reciptItemLogDataAry.count > 0)
    {
       invoiceDetailDict[@"InvoiceItemLog"] = self.crmController.reciptItemLogDataAry;
    }
	[invoiceDetail addObject:invoiceDetailDict];
	invoiceDetailDictionary[@"InvoiceDetail"] = invoiceDetail;
    
	return invoiceDetailDictionary;
}

/*- (NSMutableArray *) tenderInvoiceMst
{
	NSMutableArray * invoiceMst = [[NSMutableArray alloc] init];
	
	NSMutableDictionary * invoiceDataDict = [[NSMutableDictionary alloc] init];
    
    
    invoiceDataDict[@"InvoiceNo"] = @"0";

    if (self.crmController.isbillOrderFromRecall == TRUE && self.crmController.isbillOrderFromRecallOffline == FALSE)
    {
        if (self.crmController.recallInvoiceId != nil) {
            invoiceDataDict[@"InvoiceholdId"] = self.crmController.recallInvoiceId;
        }
        else
        {
            invoiceDataDict[@"InvoiceholdId"] = @"0";
        }
    }
    else
    {
        invoiceDataDict[@"InvoiceholdId"] = @"0";
    }
    
    if(self.paymentData.rapidCustomerLoyalty)
    {
       invoiceDataDict[@"CustId"] = self.paymentData.rapidCustomerLoyalty.custId;
    }
    else{
       invoiceDataDict[@"CustId"] = @"0";
    }
    invoiceDataDict[@"IsOffline"] = @"0";
    invoiceDataDict[@"Remarks"] = @"";
    
    invoiceDataDict[@"RegisterInvNo"] = self.strInvoiceNo;
    
    
	invoiceDataDict[@"DiscountAmount"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceDiscount"]] ];
	invoiceDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
	invoiceDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    invoiceDataDict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    invoiceDataDict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    
    
	invoiceDataDict[@"SubTotal"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceSubTotal"]] ];
    
    
	invoiceDataDict[@"TaxAmount"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceTax"]] ];
    
//
	invoiceDataDict[@"BillAmount"] = [self formatedTextForAmount:self.paymentData.billAmount];
    invoiceDataDict[@"CheckCashAmount"] = [NSString stringWithFormat:@"%f",self.checkcashAmount];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:date];
    invoiceDataDict[@"Datetime"] = strDate;
    
    if (self.restaurantOrderTenderObjectId)
    {
        NSManagedObjectContext *privateManageobjectContext = self.managedObjectContext;
        RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderTenderObjectId];
        invoiceDataDict[@"NoOfGuest"] = [NSString stringWithFormat:@"%@",restaurantOrder.noOfGuest];
        invoiceDataDict[@"TableNo"] = [NSString stringWithFormat:@"%@",restaurantOrder.tabelName];
    }

	[invoiceMst addObject:invoiceDataDict];
	
	return invoiceMst;
}

-(CGFloat)RemoveSymbolFromString:(NSString *)stringToRemoveSymbol
{
    NSString *sAmount=[stringToRemoveSymbol stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    CGFloat fsAmount = [self.crmController.currencyFormatter numberFromString:sAmount].floatValue;
    return fsAmount;
}


- (NSMutableArray *) offlineInvoiceMasterDataWithErroeMessage :(NSString *)errorMessage
{
	NSMutableArray * offlineInvoiceMaster = [[NSMutableArray alloc] init];
	
	NSMutableDictionary * offlineInvoiceMasterDict = [[NSMutableDictionary alloc] init];
    
    
    offlineInvoiceMasterDict[@"InvoiceNo"] = @"0";
    
    if (self.crmController.isbillOrderFromRecall == TRUE && self.crmController.isbillOrderFromRecallOffline == FALSE)
    {
        offlineInvoiceMasterDict[@"InvoiceholdId"] = self.crmController.recallInvoiceId;
    }
    else
    {
        offlineInvoiceMasterDict[@"InvoiceholdId"] = @"0";
    }
   
	offlineInvoiceMasterDict[@"CustId"] = @"0";
    offlineInvoiceMasterDict[@"IsOffline"] = @"0";
    offlineInvoiceMasterDict[@"Remarks"] = errorMessage;
    
    
    offlineInvoiceMasterDict[@"RegisterInvNo"] = self.paymentData.strInvoiceNo;
    
    
    offlineInvoiceMasterDict[@"DiscountAmount"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceDiscount"]] ];
    
	offlineInvoiceMasterDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
	offlineInvoiceMasterDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    offlineInvoiceMasterDict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    offlineInvoiceMasterDict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
	
    
	offlineInvoiceMasterDict[@"SubTotal"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceSubTotal"]] ];
    

    
	offlineInvoiceMasterDict[@"TaxAmount"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceTax"]] ];
    
    
	offlineInvoiceMasterDict[@"BillAmount"] = [self formatedTextForAmount:self.paymentData.billAmount];
    offlineInvoiceMasterDict[@"CheckCashAmount"] = [NSString stringWithFormat:@"%f",self.checkcashAmount];

    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:date];
    offlineInvoiceMasterDict[@"Datetime"] = strDate;
    
    if (self.restaurantOrderTenderObjectId)
    {
        NSManagedObjectContext *privateManageobjectContext = self.managedObjectContext;
        RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderTenderObjectId];
        offlineInvoiceMasterDict[@"NoOfGuest"] = [NSString stringWithFormat:@"%@",restaurantOrder.noOfGuest];
        offlineInvoiceMasterDict[@"TableNo"] = [NSString stringWithFormat:@"%@",restaurantOrder.waiterName];
    }
    
	[offlineInvoiceMaster addObject:offlineInvoiceMasterDict];
	
	return offlineInvoiceMaster;
}*/




//- (NSMutableArray *) generateInvoiceDetailWith
//{
//	NSMutableArray * invoiceItemDetail = [[NSMutableArray alloc] init];
//    NSMutableArray *tenderReciptDataAry = [self reciptDataAryForBillOrder];
//	for (int i=0; i<tenderReciptDataAry.count; i++)
//    {
//		NSMutableDictionary * tempObject = tenderReciptDataAry[i];
//		NSMutableDictionary * itemsDataDict = [[NSMutableDictionary alloc] init];
//        
//        if([tempObject valueForKey:@"CardNo"] && [tempObject valueForKey:@"CardType"] && [tempObject valueForKey:@"Remark"]){
//            
//            itemsDataDict[@"CardNo"] = [tempObject valueForKey:@"CardNo"];
//            itemsDataDict[@"CardType"] = [tempObject valueForKey:@"CardType"];
//            itemsDataDict[@"Remark"] = [tempObject valueForKey:@"Remark"];
//        }
//        else if ([tempObject valueForKey:@"CardType"] && [tempObject valueForKey:@"HouseChargeAmount"] ){
//            itemsDataDict[@"CardType"] = [tempObject valueForKey:@"CardType"];
//        }
//        
//        itemsDataDict[@"ItemCode"] = [tempObject valueForKey:@"itemId"];
//        
//        if([tempObject valueForKey:@"Reason"]){
//            itemsDataDict[@"Reason"] = [tempObject valueForKey:@"Reason"];
//        }
//        
//        if([tempObject valueForKey:@"ReasonType"]){
//            itemsDataDict[@"ReasonType"] = [tempObject valueForKey:@"ReasonType"];
//        }
//        
//        float retailAmount = [tempObject[@"itemPrice"] floatValue];
//        float variationAmount = [tempObject[@"TotalVarionCost"] floatValue] / [[tempObject valueForKey:@"itemQty"] floatValue] ;
//        
//        itemsDataDict[@"VariationAmount"] = [NSString stringWithFormat:@"%f", variationAmount];
//        itemsDataDict[@"RetailAmount"] = [NSString stringWithFormat:@"%f", retailAmount];
//        
//        if (tempObject[@"InvoiceVariationdetail"])
//        {
//            NSMutableArray * variationDetail = tempObject[@"InvoiceVariationdetail"];
//            for (int iVar = 0; iVar < variationDetail.count; iVar++)
//            {
//                NSMutableDictionary *variatonDict = variationDetail[iVar];
//                variatonDict[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
//            }
//            itemsDataDict[@"InvoiceVariationdetail"] = variationDetail;
//        }
//        else
//        {
//            itemsDataDict[@"InvoiceVariationdetail"] = @"";
//        }
//        ///////////// DeptTypeId
//        itemsDataDict[@"DeptTypeId"] = [tempObject valueForKey:@"DeptTypeId"];
//
//        if (tempObject[@"guestId"])
//        {
//            itemsDataDict[@"GuestNo"] = [NSString stringWithFormat:@"%@", tempObject[@"guestId"]];
//        }
//        else
//        {
//            itemsDataDict[@"GuestNo"] = @"";
//        }
//       
//        if (tempObject[@"Discount"])
//        {
//            NSMutableArray * discountDetail = [tempObject objectForKey:@"Discount"];
//            for (int discountIndex = 0; discountIndex < [discountDetail count]; discountIndex++)
//            {
//                NSMutableDictionary *discountDetailDict = [discountDetail objectAtIndex:discountIndex];
//                [discountDetailDict setObject:[NSString stringWithFormat:@"%d",i+1] forKey:@"RowPosition"];
//            }
//            [itemsDataDict setObject: discountDetail forKey:@"ItemDiscountDetail"];
//        }
//        else
//        {
//            itemsDataDict[@"ItemDiscountDetail"] = [[NSMutableArray alloc] init];
//        }
//        
//        if (tempObject[@"PassData"])
//        {
//            NSMutableArray *passDataArray = [[NSMutableArray alloc]init];
//            NSMutableArray *itemPassDataArray = tempObject[@"PassData"];
//            for (int passDataCount = 0; passDataCount < itemPassDataArray.count; passDataCount++) {
//                NSDictionary *passDictionaryAtIndex = itemPassDataArray[passDataCount];
//                NSMutableDictionary *passDataDictionary = [[NSMutableDictionary alloc]init];
//                passDataDictionary[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
//                passDataDictionary[@"ItemCode"] = passDictionaryAtIndex[@"ItemCode"];
//                passDataDictionary[@"CRDNumber"] = passDictionaryAtIndex[@"CRDNumber"];
//                passDataDictionary[@"ExpirationDay"] = passDictionaryAtIndex[@"ExpirationDay"];
//                passDataDictionary[@"NoOfDay"] = passDictionaryAtIndex[@"NoOfDay"];
//                passDataDictionary[@"QRCode"] = passDictionaryAtIndex[@"QRCode"];
//                passDataDictionary[@"CustomerId"] = passDictionaryAtIndex[@"CustomerId"];
//                passDataDictionary[@"IsVoid"] = passDictionaryAtIndex[@"IsVoid"];
//                passDataDictionary[@"Remark"] = passDictionaryAtIndex[@"Remark"];
//                [passDataArray addObject:passDataDictionary];
//            }
//            itemsDataDict[@"ItemTicketDetail"] = passDataArray;
//        }
//        else
//        {
//            itemsDataDict[@"ItemTicketDetail"] = [[NSMutableArray alloc] init];
//        }
//
//    
//        float itemAmount = retailAmount + variationAmount;
//        itemsDataDict[@"ItemAmount"] = [NSString stringWithFormat:@"%f", itemAmount];
//        itemsDataDict[@"ItemImage"] = [tempObject valueForKey:@"itemImage"];
//        itemsDataDict[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
//        
//        NSMutableDictionary *gasItemData  = [[tempObject valueForKey:@"InvoicePumpCart"] mutableCopy];
//        BOOL isRefund = [[[tempObject valueForKey:@"item"] valueForKey:@"isRefund"]boolValue];
//        if(gasItemData!=nil && !isRefund)
//        {
//            if([gasItemData[@"TransactionType"] isEqualToString:@"PRE-PAY"]){
//                itemsDataDict[@"RefRowPosition"] = gasItemData[@"RowPosition"];
//                itemsDataDict[@"RefItemCode"] = gasItemData[@"ItemCode"];
//                itemsDataDict[@"RefRegInvNo"] = gasItemData[@"RegInvNo"];
//                [gasItemData removeObjectForKey:@"RegInvNo"];
//                [tempObject setObject:gasItemData forKey:@"InvoicePumpCart"];
//            }
//            else{
//                itemsDataDict[@"RefRowPosition"] = @"0";
//                itemsDataDict[@"RefItemCode"] = @"0";
//                itemsDataDict[@"RefRegInvNo"] = @"0";
//            }
//        }
//        else{
//            itemsDataDict[@"RefRowPosition"] = @"0";
//            itemsDataDict[@"RefItemCode"] = @"0";
//            itemsDataDict[@"RefRegInvNo"] = @"0";
//        }
//       
//
//    
//        itemsDataDict[@"isCheckCash"] = [tempObject valueForKey:@"item"][@"isCheckCash"];
//        itemsDataDict[@"isAgeApply"] = [tempObject valueForKey:@"item"][@"isAgeApply"];
//        itemsDataDict[@"CheckCashAmount"] = [tempObject valueForKey:@"item"][@"CheckCashCharge"];
//        itemsDataDict[@"isDeduct"] = [tempObject valueForKey:@"item"][@"isDeduct"];
//        itemsDataDict[@"isAgeApply"] = [tempObject valueForKey:@"item"][@"isAgeApply"];
//        
//        float totalExtraCharge=[[tempObject valueForKey:@"itemQty"] floatValue]*[[tempObject valueForKey:@"item"][@"ExtraCharge"] floatValue];
//        
//        NSString *ExtraCharge = [NSString stringWithFormat:@"%f",totalExtraCharge];
//        
//        itemsDataDict[@"ExtraCharge"] = ExtraCharge;
//        itemsDataDict[@"ItemType"] = [tempObject valueForKey:@"itemType"];
//        itemsDataDict[@"PackageQty"] = [tempObject valueForKey:@"PackageQty"];
//        itemsDataDict[@"PackageType"] = [tempObject valueForKey:@"PackageType"];
//
//        
//        itemsDataDict[@"UnitQty"] = @"";
//        itemsDataDict[@"UnitType"] = @"";
//        itemsDataDict[@"ItemMemo"] = [tempObject valueForKey:@"Memo"];
//      
//        if ([tempObject valueForKey:@"EBTApplied"])
//        {
//            itemsDataDict[@"IsEBT"] = [tempObject valueForKey:@"EBTApplied"];
//        }
//
//        
//        itemsDataDict[@"departId"] = [tempObject valueForKey:@"departId"];
//        if (tempObject[@"SubDeptId"])
//        {
//            itemsDataDict[@"SubDeptId"] = [tempObject valueForKey:@"SubDeptId"];
//        }
//        itemsDataDict[@"Barcode"] = [tempObject valueForKey:@"Barcode"];
//    
//        if ([tempObject[@"isDeduct"] boolValue] == TRUE )
//        {
//            itemsDataDict[@"ItemCost"] = [NSString stringWithFormat:@"-%@",[tempObject valueForKey:@"ItemCost"]];
//        }
//        else
//        {
//            itemsDataDict[@"ItemCost"] = [tempObject valueForKey:@"ItemCost"];
//        }
//        
//        itemsDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
//        itemsDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
//        
//        itemsDataDict[@"ItemName"] = [tempObject valueForKey:@"itemName"];
//        NSString *totalDiscount = @"0.00";
//        if ([tempObject objectForKey:@"Discount"])
//        {
//            NSMutableArray * discountArray = [tempObject valueForKey:@"Discount"];
//            float sum = [[discountArray valueForKeyPath:@"@sum.Amount"]floatValue];
//           totalDiscount  = [NSString stringWithFormat:@"%f",sum];
//        }
//        else{
//            totalDiscount  = [NSString stringWithFormat:@"%f",[[tempObject valueForKey:@"ItemDiscount"] floatValue]];
//
//        }
//        
//		itemsDataDict[@"ItemDiscountAmount"] = totalDiscount;
//        
//        
//		itemsDataDict[@"ItemQty"] = [tempObject valueForKey:@"itemQty"];
//        itemsDataDict[@"PackageQty"] = [tempObject valueForKey:@"PackageQty"];
//        itemsDataDict[@"PackageType"] = [tempObject valueForKey:@"PackageType"];
//		
//		if ([[tempObject valueForKey:@"ItemBasicPrice"] floatValue] < 1 && [[tempObject valueForKey:@"ItemBasicPrice"] floatValue] > 0) {
//			itemsDataDict[@"ItemBasicAmount"] = [NSString stringWithFormat:@"0%@",[tempObject valueForKey:@"ItemBasicPrice"]];
//		} else if ([[tempObject valueForKey:@"ItemBasicPrice"] floatValue] < 0) {
//			itemsDataDict[@"ItemBasicAmount"] = [NSString stringWithFormat:@"-0%@",[[tempObject valueForKey:@"ItemBasicPrice"] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
//		} else {
//			itemsDataDict[@"ItemBasicAmount"] = [tempObject valueForKey:@"ItemBasicPrice"];
//		}
//        
//        float TotTax=0.0;
//        
//        if (([tempObject[@"itemTax"] floatValue] != 0.0)) {
//            
//            TotTax=[tempObject[@"itemTax"] floatValue];
//            
//			itemsDataDict[@"ItemTaxAmount"] = [tempObject[@"itemTax"] stringValue];
//		}
//        else {
//			itemsDataDict[@"ItemTaxAmount"] = @"0.0";
//		}
//        float totalItemAmount = itemAmount *[[tempObject valueForKey:@"itemQty"] intValue] + TotTax;
//		itemsDataDict[@"TotalItemAmount"] = [NSString stringWithFormat:@"%f",totalItemAmount];
//		
//		itemsDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
//        
//		if (![[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"] isEqual:@""]) {
//			if ([[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"] count] > 0) {
//				NSMutableArray * itemTaxArray = [[NSMutableArray alloc] init];
//				for (int z=0; z<[[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"] count]; z++) {
//					NSMutableDictionary * tempTaxItem = [NSMutableDictionary dictionaryWithDictionary:[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"][z]];
//					tempTaxItem[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
//                    tempTaxItem[@"ItemCode"] = [tempObject valueForKey:@"itemId"];
//                    tempTaxItem[@"TaxId"] = [tempTaxItem valueForKey:@"TaxId"];
//                    tempTaxItem[@"TaxPercentage"] = [tempTaxItem valueForKey:@"TaxPercentage"];
//                    tempTaxItem[@"TaxAmount"] = [tempTaxItem valueForKey:@"TaxAmount"];
//                    NSString *strTaxAmount=[NSString stringWithFormat:@"%f",[[tempTaxItem valueForKey:@"ItemTaxAmount"] floatValue]];
//                    tempTaxItem[@"ItemTaxAmount"] = strTaxAmount;
//                    tempTaxItem[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
//                    
//					[itemTaxArray addObject:tempTaxItem];
//				}
//				itemsDataDict[@"ItemTaxDetail"] = itemTaxArray;
//			} else {
//				itemsDataDict[@"ItemTaxDetail"] = @"";
//			}
//		} else {
//			itemsDataDict[@"ItemTaxDetail"] = @"";
//		}
//        [self checkForFuelTypeSelected:itemsDataDict];
//        if([[itemsDataDict valueForKey:@"Barcode"] isEqualToString:@"GAS"] && [[itemsDataDict valueForKey:@"ItemName"] isEqualToString:@"GAS"]){
//            NSMutableArray *gasDetail = [[NSMutableArray alloc] init];
//
//            
//            NSMutableDictionary *gasItemData  = [[tempObject valueForKey:@"InvoicePumpCart"] mutableCopy];
//            gasItemData[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
//            [gasDetail addObject:gasItemData];
//            itemsDataDict[@"InvoicePumpCart"] = gasDetail;
//            
//        }
//		[invoiceItemDetail addObject:itemsDataDict];
//	}
//	return invoiceItemDetail;
//}

-(void)checkForFuelTypeSelected:(NSMutableDictionary *)itemsDataDict{
    
    if(self.selectedFuelType){
        
        if([[itemsDataDict valueForKey:@"Barcode"] isEqualToString:@"GAS"] && [[itemsDataDict valueForKey:@"ItemName"] isEqualToString:@"GAS"]){
            if([self isCreditCard]){
                itemsDataDict[@"Reason"] = [self.selectedFuelType valueForKey:@"CreditFull"];
            }
            else{
                itemsDataDict[@"Reason"] = [self.selectedFuelType valueForKey:@"CashFull"];
            }
        }
    }
    [itemsDataDict removeObjectForKey:@"Pump"];
    [itemsDataDict removeObjectForKey:@"FuelType"];
    
}

-(BOOL)isCreditCard{
    
    BOOL isCredit = NO;
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            NSString *payType = paymentModeItem.paymentType;
            if([payType isEqualToString:@"Credit"]){
                isCredit = YES;
            }
        }
    }
    return isCredit;
}



//-(NSMutableArray *)InvoicePaymentdetail
//{
//    NSMutableArray *paymentDetailArray = [[NSMutableArray alloc] init];
//    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
//    {
//        if (self.paymentData.amountToPay == 0)
//        {
//            NSInteger index = self.paymentData.indexOfFirstCashType;
//            NSArray *itemArrayAtIndex = [self.paymentData paymentModeArrayAtIndex:index];
//            PaymentModeItem *paymentModeItem  = itemArrayAtIndex.firstObject;
//            NSMutableDictionary * paymentDictionary = [paymentModeItem.paymentModeDictionary mutableCopy];
//            paymentDictionary[@"PayMode"] = [paymentDictionary valueForKey:@"PaymentName"];
//            [paymentDictionary removeObjectForKey:@"PaymentName"];
//            paymentDictionary[@"BillAmount"] = @"0.00";
//            paymentDictionary[@"ReturnAmount"] = @"0";
//            
//            if(self.paymentData.rapidCustomerLoyalty)
//            {
//                paymentDictionary[@"CustId"] = self.paymentData.rapidCustomerLoyalty.custId;
//            }
//            else{
//                paymentDictionary[@"CustId"] = @"0";
//            }
//            
//            paymentDictionary[@"Email"] = @"";
//            paymentDictionary[@"SurchargeAmount"] = @"0.0";
//            paymentDictionary[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
//            paymentDictionary[@"SignatureImage"] = @"";
//            paymentDictionary[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
//            paymentDictionary[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
//            [paymentDetailArray addObject:paymentDictionary];
//            break;
//        }
//        NSArray *itemArrayAtIndex = [self.paymentData paymentModeArrayAtIndex:i];
//        for (int j = 0; j < itemArrayAtIndex.count; j++)
//        {
//            PaymentModeItem *paymentModeItem  = itemArrayAtIndex[j];
//            float actualAmount = paymentModeItem.actualAmount.floatValue ;
//            float calculatedAmount =  paymentModeItem.calculatedAmount.floatValue ;
//            float displayAmount = paymentModeItem.displayAmount.floatValue;
//            
//            if (actualAmount == 0 )
//            {
//                actualAmount = calculatedAmount;
//                if (actualAmount == 0)
//                {
//                    actualAmount = displayAmount;
//                }
//            }
//            if(actualAmount!=0)
//            {
//                NSMutableDictionary * paymentDictionary = [[NSMutableDictionary alloc] init];
//                NSDictionary *paymentModeDictionary = paymentModeItem.paymentModeDictionary;
//                
//                NSString *returnAmount =  [self formatedTextForAmountWithCurrencyFormatter:-self.paymentData.balanceAmount];
//                returnAmount = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:returnAmount]];
//                
//                if ([paymentModeItem.paymentType isEqualToString:@"Cash"] && self.paymentData.amountToPay > 0)
//                {
//                    paymentDictionary[@"ReturnAmount"] = [NSString stringWithFormat:@"%@", returnAmount];
//                }
//                else
//                {
//                    paymentDictionary[@"ReturnAmount"] = @"0";
//                }
//                
//                if(self.paymentData.rapidCustomerLoyalty)
//                {
//                    paymentDictionary[@"CustId"] = self.paymentData.rapidCustomerLoyalty.custId;
//                }
//                else
//                {
//                    paymentDictionary[@"CustId"] = @"0";
//                }
//                
//                
//                
//                paymentDictionary[@"Email"] = @"";
//                paymentDictionary[@"SurchargeAmount"] = @"0.0";
//                paymentDictionary[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
//                
//                
//                paymentDictionary[@"PayMode"] = [paymentModeDictionary valueForKey:@"PaymentName"];
//                paymentDictionary[@"PayId"] = [paymentModeDictionary valueForKey:@"PayId"];
//                paymentDictionary[@"CardType"] = [paymentModeDictionary valueForKey:@"CardType"];
//                paymentDictionary[@"AuthCode"] = [paymentModeDictionary valueForKey:@"AuthCode"];
//                paymentDictionary[@"AccNo"] = [paymentModeDictionary valueForKey:@"AccNo"];
//                paymentDictionary[@"TransactionNo"] = [paymentModeDictionary valueForKey:@"TransactionNo"];
//                paymentDictionary[@"CardHolderName"] = [paymentModeDictionary valueForKey:@"CardHolderName"];
//                paymentDictionary[@"ExpireDate"] = [paymentModeDictionary valueForKey:@"ExpireDate"];
//                paymentDictionary[@"RefundTransactionNo"] = [paymentModeDictionary valueForKey:@"RefundTransactionNo"];
//                paymentDictionary[@"GatewayType"] = [paymentModeDictionary valueForKey:@"GatewayType"];
//                paymentDictionary[@"TransactionId"] = [paymentModeDictionary valueForKey:@"CreditTransactionId"];
//                paymentDictionary[@"BatchNo"] = @"";
//
//                NSString  *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
//                NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
//                if ([paymentDictionary[@"GatewayType"] isEqualToString:@"Pax"]) {
//                    
//                    NSMutableDictionary *paxAdditionalFieldDictionary = [paymentModeItem.paymentModeDictionary valueForKey:@"PaxAdditionalFields"];
//                  
//                    
//                    
//                    paxAdditionalFieldDictionary[@"PaxSerialNo"] = [NSString stringWithFormat:@"%@",paxSerialNo];
//                    paxAdditionalFieldDictionary[@"BuildVersion"] = [NSString stringWithFormat:@"%@",buildVersion];
//                    paxAdditionalFieldDictionary[@"AppVersion"] = [NSString stringWithFormat:@"%@",appVersion];
//                    
//                    paymentDictionary[@"GatewayResponse"] = [NSString stringWithFormat:@"%@",[self.rmsDbController jsonStringFromObject:paxAdditionalFieldDictionary]];
//                    if ([[paxAdditionalFieldDictionary objectForKey:@"SN"] isBlank] == NO)
//                    {
//                        paymentDictionary[@"PaxSerialNo"] = [NSString stringWithFormat:@"%@",[paxAdditionalFieldDictionary valueForKey:@"SN"]];
//                        
//                    }
//                    else
//                    {
//                        paymentDictionary[@"PaxSerialNo"] = [NSString stringWithFormat:@"%@",paxSerialNo];
//                    }
//                    paymentDictionary[@"BatchNo"] = paxAdditionalFieldDictionary[@"BatchNo"];
//                }
//                else
//                {
//                    NSMutableDictionary *bridgepayAdditionalFields = [paymentModeItem.paymentModeDictionary valueForKey:@"BridgepayAdditionalFields"];
//                    
//                    bridgepayAdditionalFields[@"BuildVersion"] = [NSString stringWithFormat:@"%@",buildVersion];
//                    bridgepayAdditionalFields[@"AppVersion"] = [NSString stringWithFormat:@"%@",appVersion];
//                    
//                    paymentDictionary[@"GatewayResponse"] = [NSString stringWithFormat:@"%@",bridgepayAdditionalFields];
//                }
//                
//                if ([[paymentModeDictionary valueForKey:@"SignatureImage"] isKindOfClass:[UIImage class]]) {
//                    if (![paymentModeItem.paymentType isEqualToString:@"Cash"])
//                    {
//                        UIImage *customerImage = [paymentModeDictionary valueForKey:@"SignatureImage"];
//                        NSData *imageData = UIImagePNGRepresentation(customerImage);
//                        if (imageData) {
//                            paymentDictionary[@"SignatureImage"] = [imageData base64EncodedStringWithOptions:0];
//                        }
//                        else
//                        {
//                            paymentDictionary[@"SignatureImage"] = @"";
//                        }
//                    }
//                    else
//                    {
//                        paymentDictionary[@"SignatureImage"] = @"";
//                    }
//                }
//                else
//                {
//                    paymentDictionary[@"SignatureImage"] = @"";
//                }
//                
//                paymentDictionary[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
//                paymentDictionary[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
//                
//                paymentDictionary[@"BillAmount"] = [NSString stringWithFormat:@"%.2f",actualAmount];
//                
//                
//                
//                CGFloat lastIndexTipAmount = 0.00;
//                if (self.paymentData.lastSelectedPaymentTypeIndexPath.section == i && self.paymentData.lastSelectedPaymentTypeIndexPath.row == j) {
//                    lastIndexTipAmount = self.paymentData.tipAmount;
//                }
//                CGFloat customerDisplayTipAmount = 0.00;
//                if (paymentModeItem.isCustomerDiplayTipAdjusted == TRUE) {
//                    customerDisplayTipAmount = paymentModeItem.customerDisplayTipAmount.floatValue;
//                }
//                
//                actualAmount = actualAmount - lastIndexTipAmount - customerDisplayTipAmount;
//                paymentDictionary[@"BillAmount"] = [NSString stringWithFormat:@"%.2f",actualAmount];
//                paymentDictionary[@"TipsAmount"] = [NSString stringWithFormat:@"%.2f",lastIndexTipAmount + customerDisplayTipAmount];
//
//                
//             /*   if (self.paymentData.lastSelectedPaymentTypeIndexPath.section == i && self.paymentData.lastSelectedPaymentTypeIndexPath.row == j) {
//                    [paymentDictionary setObject:[NSString stringWithFormat:@"%.2f",self.paymentData.tipAmount] forKey:@"TipsAmount"];
//                    actualAmount = actualAmount - self.paymentData.tipAmount;
//                    [paymentDictionary setObject:[NSString stringWithFormat:@"%.2f",actualAmount] forKey:@"BillAmount"];
//                }
//                else
//                {
//                    [paymentDictionary setObject:[NSString stringWithFormat:@"%.2f",0.00] forKey:@"TipsAmount"];
//                }*/
//                [paymentDetailArray addObject:paymentDictionary];
//            }
//        }
//    }
//    return paymentDetailArray;
//    
//}

-(NSString *)paymentNameAtSectionIndex :(NSInteger )sectionIndex
{
    return  [self.paymentData paymentNameAtIndex:sectionIndex];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.paymentData.countOfPaymentModes;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTenderCell *cell = [CustomTenderCell dequeOrCreateInTable:tableView];
    
    if(istenderclick==FALSE)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.paymentData.countOfPaymentModes>0)
        {
            cell.lblAmount.text = @"";
            
            if (self.paymentData.amountToPay == 0.0)
            {
                if (indexPath.section == indexOfCashType)
                {
                    if (indexPath.row == 0)
                    {
                        cell.lblAmount.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
                    }
                }
            }
            else
            {
                if ([self.paymentData actualAmountAtIndexPath:indexPath] != 0.0)
                {
                    cell.lblAmount.text = [self.crmController.currencyFormatter stringFromNumber:@([self.paymentData actualAmountAtIndexPath:indexPath])] ;
                }
                else if ([self.paymentData calculatedAmountAtIndexPath:indexPath] != 0.0)
                {
                    cell.lblAmount.text = [self.crmController.currencyFormatter stringFromNumber:@([self.paymentData calculatedAmountAtIndexPath:indexPath])] ;
                }
                else if ([self.paymentData displayAmountAtIndexPath :indexPath] != 0.0)
                {
                    cell.lblAmount.text = [self.crmController.currencyFormatter stringFromNumber:@([self.paymentData displayAmountAtIndexPath:indexPath])] ;
                    cell.lblAmount.textColor = [UIColor grayColor];
                }
                else
                {
                    
                }
            }
            
            cell.payImage.layer.cornerRadius = cell.payImage.frame.size.width/2;
            cell.payImage.clipsToBounds = TRUE;
            
            cell.lblPaymentName.text =[self.paymentData paymentNameAtIndexPath:indexPath];
            NSString * imageImage = @"";
            imageImage = [self.paymentData paymentImageAtIndexPath:indexPath];
            if ([[imageImage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
                [cell.payImage setImage:nil];
            } else {
                [cell.payImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageImage]]];
            }
            
            BOOL isMultipleCreditCardApplicable =[self.paymentData isMultiplePaymentModeAtIndexPathForPaymentMode:indexPath];
            if (isMultipleCreditCardApplicable && indexPath.row == 0)
            {
                cell.addPaymentMode.hidden = NO;
            }
            else
            {
                cell.addPaymentMode.hidden = YES;
            }
          
            BOOL isGiftCardApplicable =[self.paymentData isGiftCardApproveForPaymentMode:indexPath];
            if (isGiftCardApplicable == TRUE)
            {
                cell.btnCancel.hidden = NO;
            }
            else
            {
                cell.btnCancel.hidden = YES;
            }

            [cell.addPaymentMode addTarget:self action:@selector(addPaymentModeAtIndexapth:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.btnCancel addTarget:self action:@selector(btnCancelClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(IBAction)btnCancelClick:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tblPaymentData];
    NSIndexPath *indexPath = [_tblPaymentData indexPathForRowAtPoint:buttonPosition];
   
    PaymentModeItem *paymentmode= [self.paymentData setpaymentModeItemWithIndexPath:indexPath];
    [self resetPaymentModeItem:paymentmode];
    [_tblPaymentData reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.paymentData countOfPaymentModesInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
-(IBAction)addPaymentModeAtIndexapth:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tblPaymentData];
    NSIndexPath *indexPath = [_tblPaymentData indexPathForRowAtPoint:buttonPosition];
    NSInteger paymnetId = [self.paymentData paymentIdAtIndex:indexPath.section].integerValue;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
   
    NSPredicate *predicateForPayId = [NSPredicate predicateWithFormat:@"payId = %d",paymnetId];;
    fetchRequest.predicate = predicateForPayId;
    
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count > 0) {
        TenderPay *tenderPay = (TenderPay *) [resultSet firstObject];
        NSMutableDictionary *paymentDictionary = [self paymentModeDictionaryAtTenderPay:tenderPay];
     
        [_tblPaymentData beginUpdates];
        [self.paymentData addPaymentItemAtSection:indexPath.section withDictionary:paymentDictionary];
        NSIndexPath *addedItemAtIndexPath = [NSIndexPath indexPathForRow:[self.paymentData paymentModeCountAtSection:indexPath.section]-1 inSection:indexPath.section];
        [_tblPaymentData insertRowsAtIndexPaths:@[addedItemAtIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [_tblPaymentData endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. Play Sound
    [self.rmsDbController playButtonSound];
    
    // 2. Check Conditions that do not apply
    if ([self.paymentData isEbtPaymentModeAtIndexpath:indexPath])
    {
        if ([self shouldEBTRestrictedForBill] == FALSE)
        {
            if ([self applyEbtForBillCalculator] > 0) {
                [self.paymentData configureEBTPaymentModeWithEBTAmount:[self applyEbtForBillCalculator]];
                [self updateTenderStatus];
            }else{
                return;
            }
        }else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"You can not apply EBT paymode for this Bill" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        return;
    }
    if ([self.paymentData isHouseChargePaymentModeAtIndexpath:indexPath])
    {
        if (self.paymentData.rapidCustomerLoyalty == nil)
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [self btnCustomerClick:nil];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select Customer for House Charge Payment. " buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            
            return;
            
        }else{
            if (self.paymentData.houseChargeAmount == 0.00 && self.paymentData.isHouseChargePay )
            {
                return;
            }
            else{
                CGFloat houseCharge = self.paymentData.houseChargeAmount ;
                if (self.paymentData.rapidCustomerLoyalty.creditLimit.floatValue > self.paymentData.rcrBillSummary.totalBillAmount.floatValue)
                {
                    houseCharge = self.paymentData.houseChargeAmount;;
                }else{
                    if (self.paymentData.houseChargeAmount > 0 && self.paymentData.rapidCustomerLoyalty.creditLimit.floatValue == 0.00 )
                    {
                        houseCharge = self.paymentData.houseChargeAmount;
                    }else{
                        houseCharge =  self.paymentData.rapidCustomerLoyalty.creditLimit.floatValue;
                    }
                }
                [self.paymentData configureHouseChargeModeWithHouseChargeAmount:houseCharge];
                [self updateTenderStatus];
            }
        }
    }
    if ([self.paymentData isCreditCardSwipedForPayment:indexPath]) {
        return ;
    }
    
    if ([self.paymentData isGiftCardApproveForPaymentMode:indexPath]) {
        return ;
    }
    
    if (self.paymentData.amountToPay == 0)
    {
        return;
    }
    
    if ([self.paymentData displayAmountAtIndexPath:indexPath])
    {
        return;
    }
    
    if([self.paymentData displayTotalAmountAtIndexPath:indexPath] > 0.0)
    {
        [self.paymentData setActualAmount:0 AtIndexPath:indexPath];
        [self updateTenderStatus];
        return;

    }

    // 3. Set Indexpath and other Values that should be reset
    NSIndexPath *oldIndexPath2 = self.selectedPaymentIndexPath;
    currentIndexPath = [indexPath copy];
    self.selectedPaymentModeIndex = indexPath.row;
    self.selectedPaymentIndexPath = indexPath;
    userEditedAmount = 0;
    quickAmount = 0;
    
    CGFloat balanceAmount = self.paymentData.amountToPay - self.paymentData.collectionAmount;
    
    if (self.paymentData.amountToPay < 0) {
        if (self.paymentData.balanceAmount == 0.00) {
            balanceAmount = self.paymentData.amountToPay - self.paymentData.balanceAmount;
        }
    }
    if (self.paymentData.amountToPay < 0.0) {
        if (self.paymentData.totalCollection == self.paymentData.collectionAmount ) {
            [self.paymentData setCalculatedAmount:balanceAmount AtIndexPath:indexPath];
        }
        else
        {
            if (self.paymentData.totalCollection <= 0.0 && [self.paymentData actualAmountAtIndexPath:indexPath] == 0.0) {
                if (self.paymentData.balanceAmount < 0.0) {
                    [self.paymentData setActualAmount:self.paymentData.balanceAmount AtIndexPath:indexPath];
                }
            }
        }
    }else
    {
        if (self.paymentData.collectionAmount <= 0.0){
            [self.paymentData setCalculatedAmount:balanceAmount AtIndexPath:indexPath];
        }else
        {
            if ((self.paymentData.collectionAmount > 0.0) && ([self.paymentData actualAmountAtIndexPath:indexPath] == 0.0)) {
                if (self.paymentData.balanceAmount > 0.0) {
                    [self.paymentData setActualAmount:self.paymentData.balanceAmount AtIndexPath:indexPath];
                }
            }
        }
    }
    
    if (oldIndexPath2 && ![oldIndexPath2 isEqual:currentIndexPath]) {
        [tableView reloadRowsAtIndexPaths:@[oldIndexPath2, [NSIndexPath indexPathForRow:self.selectedPaymentIndexPath.row inSection:self.selectedPaymentIndexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self indexPathOfLastSelectedPaymenType:self.selectedPaymentIndexPath];
    
    [self updateTenderStatus];
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    UITableView *tv = (UITableView*)scrollView;
    NSIndexPath *indexPathOfTopRowAfterScrolling = [tv indexPathForRowAtPoint:
                                                    *targetContentOffset
                                                    ];
    CGRect rectForTopRowAfterScrolling = [tv rectForRowAtIndexPath:
                                          indexPathOfTopRowAfterScrolling
                                          ];
    targetContentOffset->y=rectForTopRowAfterScrolling.origin.y;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(IBAction)btnRoundNoteClick:(id)sender
{
    [self.rmsDbController playButtonSound];
    if (self.paymentData.amountToPay == 0)
    {
        return;
    }
    
    if ([self.paymentData isEbtPaymentModeAtIndexpath:self.selectedPaymentIndexPath]) {
        return;
    }
    if ([self.paymentData isCreditCardSwipedForPayment:self.selectedPaymentIndexPath])
    {
        return ;
    }
    if ([self.paymentData displayAmountAtIndexPath:self.selectedPaymentIndexPath] > 0) {
        return;
    }
    /*  NSDictionary *paymentDict = [self.paymentData creditCardDictionaryAtIndex:self.selectedPaymentModeIndex];
     if (paymentDict != nil)
     {
     return ;
     }*/
    
    if(self.paymentData.amountToPay < 0)
    {
        quickAmount = roundValue;
    }
    else{
        quickAmount = [sender tag];
    }
    
    if(self.paymentData.amountToPay < 0)
    {
        [self.paymentData setActualAmount:quickAmount AtIndexPath:self.selectedPaymentIndexPath];
    }
    else
    {
        [self.paymentData setActualAmount:quickAmount AtIndexPath:self.selectedPaymentIndexPath];
    }
    [self indexPathOfLastSelectedPaymenType:self.selectedPaymentIndexPath];
    [self updateTenderStatus];
}

-(void)indexPathOfLastSelectedPaymenType :(NSIndexPath*)indexpath
{
    float actualAmount = [self.paymentData actualAmountAtIndex:indexpath.section] ;
    float calCulatedAmount = [self.paymentData calculatedAmountAtIndex:indexpath.section] ;
    if (actualAmount == 0)
    {
        actualAmount = calCulatedAmount;
    }
    if (actualAmount < self.paymentData.tipAmount || actualAmount == 0) {
        return;
    }

    self.paymentData.lastSelectedPaymentTypeIndexPath = indexpath;
  // NSString *paymentType = [self.paymentData paymentNameAtIndex:self.paymentData.lastSelectedPaymentTypeIndexPath.section];
}

-(IBAction)btnNoteClick:(id)sender
{
    if (self.tenderType.length > 0 && self.selectedPaymentIndexPath == nil) {
        self.selectedPaymentIndexPath = [self.paymentData selectedIndexPathForPaymentMode] ;
    }

    [self.rmsDbController playButtonSound];
    if (self.paymentData.amountToPay == 0)
    {
        return;
    }
    
    if ([self.paymentData isEbtPaymentModeAtIndexpath:self.selectedPaymentIndexPath]) {
        return;
    }
    if ([self.paymentData displayAmountAtIndexPath:self.selectedPaymentIndexPath] > 0) {
        return;
    }
    
    //    NSDictionary *paymentDict = [self.paymentData isCreditCardSwipedForPayment:self.selectedPaymentIndexPath];
    if ([self.paymentData isCreditCardSwipedForPayment:self.selectedPaymentIndexPath])
    {
        return ;
    }
    
    quickAmount += [sender tag];
  
    if(self.paymentData.amountToPay < 0)
    {
        [self.paymentData setActualAmount:-quickAmount AtIndexPath:self.selectedPaymentIndexPath];
    }
    else
    {
        [self.paymentData setActualAmount:quickAmount AtIndexPath:self.selectedPaymentIndexPath];
    }
    
   
    [self indexPathOfLastSelectedPaymenType:self.selectedPaymentIndexPath];

    [self updateTenderStatus];
}

- (BOOL)enableTenderCondtion1
{
    CGFloat balanceAmount;
    BOOL enaleTenderButtton=FALSE;
    CGFloat totalCashOther = self.paymentData.totalCashAndOthers;
    NSString *totalCashOtherStr= [NSString stringWithFormat:@"%.2f",totalCashOther];
    totalCashOther = totalCashOtherStr.floatValue;
    balanceAmount = self.paymentData.balanceAmount;
    
    if (balanceAmount < 0.0) {
        balanceAmount = -balanceAmount;
        NSString *balanceFloatStr = [NSString stringWithFormat:@"%.2f",balanceAmount];
        float balance = balanceFloatStr.floatValue;
        if (totalCashOther >= balance)
        {
            enaleTenderButtton = YES;
        }
        else
        {
            enaleTenderButtton = FALSE;
        }
    }
    return enaleTenderButtton;
}

- (void)enableTenderButton:(BOOL)enaleTenderButtton
{
    if (enaleTenderButtton)
    {
        _tenderEnterBtn.enabled=YES;
        _tenderEnterBtn.userInteractionEnabled=YES;
        self.btnchangeMoveToGas.enabled=YES;
        self.btnchangeMoveToGas.userInteractionEnabled=YES;
    }
    else
    {
        _tenderEnterBtn.enabled=NO;
        _tenderEnterBtn.userInteractionEnabled=NO;
        self.btnchangeMoveToGas.enabled=NO;
        self.btnchangeMoveToGas.userInteractionEnabled=NO;
    }
}

- (BOOL)enableTenderCondition2:(CGFloat)difference
{
    BOOL isTenderEnable = FALSE;
    
    if (difference > 0.009)
    {
        isTenderEnable = FALSE;
        
    }
    else
    {
        isTenderEnable = TRUE;
    }
    return isTenderEnable;
}


-(void)updateTenderStatus
{
    CGFloat tipAmount = self.paymentData.tipAmount;
    CGFloat amountToPay = self.paymentData.amountToPay;
    CGFloat billAmount = self.paymentData.billAmount;
  
    CGFloat collectAmount = self.paymentData.totalCollection;
    CGFloat balanceAmount = self.paymentData.balanceAmount;
//    CGFloat displayBalanceAmount = balanceAmount;
    
    CGFloat totalCredit = self.paymentData.totalCredit;
    
    if (amountToPay == 0) {
        [self resetTotal];
        [self enableTenderButton:TRUE];
    }
    else if (amountToPay < 0)
    {
        CGFloat temp = collectAmount;
        collectAmount = balanceAmount;
        balanceAmount = temp;
        
        CGFloat difference = (balanceAmount) - (amountToPay);
        
        if (difference < 0) {
            difference = -difference;
        }
        [self enableTenderButton:[self enableTenderCondition2:difference]];
        
        
        float actualAmountAtPaymentIndex;
        for (int i =0; i<=self.paymentData.countOfPaymentModes; i++)
        {
            BOOL isCardApplicable = FALSE;
            NSString *cardType = [self.paymentData paymentTypeAtIndex:i];
            if ([cardType isEqualToString:@"Credit"] || [cardType isEqualToString:@"Debit"] ||  [cardType  isEqualToString:@"EBT/Food Stamp"])
            {
                actualAmountAtPaymentIndex = -[self.paymentData actualAmountAtIndex:i];
                if (actualAmountAtPaymentIndex ==0)
                {
                    actualAmountAtPaymentIndex =-[self.paymentData calculatedAmountAtIndex:i];
                }
                isCardApplicable = [self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS];
                if (isCardApplicable)
                {
                    balanceAmount +=actualAmountAtPaymentIndex;
                }
            }
        }
        
    }
    else
    {
        CGFloat totalDifference = totalCredit - amountToPay;
        
        if (totalDifference > 0.009) {
            [self enableTenderButton:FALSE];
        }
        else if (balanceAmount > 0)
        {
            [self enableTenderButton:FALSE];
        }
        else
        {
            [self enableTenderButton:TRUE];
        }
    }
    

    [_tblPaymentData reloadData];
    
    [_tenderSubTotalView updateSubtotalViewWithBillAmount:billAmount withCollectedAmount:collectAmount withChangeDue:balanceAmount withTipAmount:tipAmount];
}

-(BOOL)isPaymentOptionAllowed :(NSIndexPath *)paymentIndexpath
{
    BOOL isCardApplicable = TRUE;
    NSString *cardType = [self.paymentData paymentTypeAtIndex:paymentIndexpath.section];
    
    if (([cardType isEqualToString:@"Credit"] || [cardType isEqualToString:@"Debit"] || [cardType  isEqualToString:@"EBT/Food Stamp"]) && self.paymentData.amountToPay < 0)
    {
        isCardApplicable = [self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS];
    }
    return isCardApplicable;
}


- (CGFloat)configurePaymentData
{
    CGFloat collectAmt = 0;
    if (self.paymentData.amountToPay < 0)
    {
        CGFloat collectAmount = self.paymentData.totalCollection;
        CGFloat balanceAmount = collectAmount;
        self.paymentData.balanceAmount = balanceAmount;
    }
    
    _lblDueAmount.text =[self formatedTextForAmountWithCurrencyFormatter:-self.paymentData.balanceAmount];
    
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
      /* if (self.paymentData.amountToPay == 0)
        {
            NSInteger index = [self.paymentData indexOfFirstCashType];
            NSArray *itemArrayAtIndex = [self.paymentData paymentModeArrayAtIndex:index];
            PaymentModeItem *paymentModeItem  = [itemArrayAtIndex firstObject];
            NSMutableDictionary * paymentDictionary = [paymentModeItem.paymentModeDictionary mutableCopy];
            [paymentDictionary setObject:@"0.00" forKey:@"BillAmount"];
            [paymentDataArray addObject:paymentDictionary];
            break;
        }*/
        NSArray *itemArrayAtIndex = [self.paymentData paymentModeArrayAtIndex:i];
        
        for (int j = 0; j < itemArrayAtIndex.count; j++)
        {
            PaymentModeItem *paymentModeItem  = itemArrayAtIndex[j];
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount =  paymentModeItem.calculatedAmount.floatValue ;
            float displayAmount = paymentModeItem.displayAmount.floatValue;
            
            if (actualAmount == 0 )
            {
                actualAmount = calCulatedAmount;
                if (actualAmount == 0)
                {
                    actualAmount = displayAmount;
                }
            }
            if(actualAmount!=0)
            {
        //        NSMutableDictionary * paymentDictionary = [paymentModeItem.paymentModeDictionary mutableCopy];
             //   [paymentDictionary setObject:[NSString stringWithFormat:@"%.2f",actualAmount] forKey:@"BillAmount"];
                if (self.paymentData.lastSelectedPaymentTypeIndexPath.section == i && self.paymentData.lastSelectedPaymentTypeIndexPath.row == j)
                {
           //         [paymentDictionary setObject:[NSString stringWithFormat:@"%.2f",self.paymentData.tipAmount] forKey:@"TipsAmount"];
                    paymentModeItem.tipAmount = self.paymentData.tipAmount;
                    actualAmount = actualAmount - self.paymentData.tipAmount;
            //        [paymentDictionary setObject:[NSString stringWithFormat:@"%.2f",actualAmount] forKey:@"BillAmount"];
                }
                else
                {
               //     [paymentDictionary setObject:[NSString stringWithFormat:@"%.2f",0.00] forKey:@"TipsAmount"];
                    paymentModeItem.tipAmount = 0.00;
                }
                    collectAmt+= actualAmount;
            }
        }
    }
    return collectAmt;
}
// Method
- (BOOL)isQuickTap {
    BOOL isQuickTap = NO;
    [_buttonLock lock];
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeLapsed = [currentDate timeIntervalSinceDate:_previousDate];
    if (timeLapsed < 1.0) {
        isQuickTap = YES;
    }
    
    _previousDate = currentDate;
    
    [_buttonLock unlock];
    
    return isQuickTap;
}


-(IBAction)btntenderClick:(id)sender
{
    NSLog(@"tender button click date %@",[NSDate date]);
    if ([self isQuickTap]) {
        NSLog(@"You are too quick");
        return;
    }
    NSLog(@"block excute end date %@",[NSDate date]);
    
    self.collectionAmount = [self configurePaymentData];
    if ([self isPaymentDataCountGreaterThanZero] == FALSE)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Select the payment Mode." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    [self.rmsDbController playButtonSound];
    self.doneButtonTimeStamp = [NSDate date];
    self.tenderProcessManager.currentStep = TP_BEGIN;
    
        if (self.dictAmoutInfo != nil)
        {
            NSMutableDictionary *doneInfoForAppSee = [self.dictAmoutInfo mutableCopy];
            doneInfoForAppSee[@"RegisterInvoiceNo"] = self.paymentData.strInvoiceNo;
            // [Appsee addEvent:kPosDoneTender withProperties:doneInfoForAppSee];
        }
    
        [self.tenderProcessManager performNextStep];

}
-(void)creditLimitForHouseCharge
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
    [param setValue:self.paymentData.rapidCustomerLoyalty.custId forKey:@"CustomerId"];
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
              
                CGFloat balanceAmount = [[dictBalance valueForKey:@"Balance"] floatValue] ;
                CGFloat creditLimit = [[dictBalance valueForKey:@"CreditLimit"] floatValue];
                CGFloat houseChargeAmount1 = [[self getHouseChargeAmount] floatValue];
                CGFloat creditedAmount;
               
                if (self.paymentData.rapidCustomerLoyalty.balanceAmount == nil || self.paymentData.rapidCustomerLoyalty.balanceAmount.floatValue < 0) {
                    creditedAmount = 0;
                }
                else{
                    creditedAmount = self.paymentData.rapidCustomerLoyalty.balanceAmount.floatValue;
                }

                if (self.paymentData.isHouseChargePay)
                {
                    balanceAmount = [[self getHouseChargeAmount] floatValue];
                    custBalanceAmount = (creditedAmount + [[dictBalance valueForKey:@"Balance"] floatValue]) - balanceAmount;

                }
                else
                {
                    custBalanceAmount = (creditedAmount + balanceAmount ) - houseChargeAmount1;

                    balanceAmount = -(balanceAmount) + houseChargeAmount1;
                }

                if(balanceAmount <= creditLimit || creditLimit == 0)
                {
                    [self.tenderProcessManager performNextStep];
                }
                else
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Decline" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Error occur while verify Customer Credit Limit" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            self.tenderProcessManager.currentStep = TP_BEGIN;
            [self.tenderProcessManager performNextStep];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Can not reach to server for check credit limit. Do you want to retry?" buttonTitles:@[@"No",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    }
    
}

-(void)deleteDataFromHoldTable
{
    if (self.crmController.isbillOrderFromRecall == TRUE) {
        if (self.crmController.isbillOrderFromRecallOffline == TRUE) {
            [self.updateManager deleteHoldInvoiceForRecallInvoiceID:self.crmController.recallInvoiceId];
            NSLog(@"self.crmController.recallCount before %ld",(long)self.crmController.recallCount);
            self.crmController.recallCount--;
            self.crmController.recallCount = self.crmController.recallCount - [self.updateManager fetchEntityObjectsCounts:@"HoldInvoice" withManageObjectContext:self.managedObjectContext];
            NSLog(@"self.crmController.recallCount after %ld",(long)self.crmController.recallCount);
        }
    }
}

-(BOOL)isPaymentDataCountGreaterThanZero
{
    BOOL isPaymentDataCountGreaterThanZero = FALSE;
    
    if (self.paymentData.amountToPay == 0)
    {
        isPaymentDataCountGreaterThanZero = TRUE;
    }
    
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray *itemArrayAtIndex = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < itemArrayAtIndex.count; j++)
        {
            PaymentModeItem *paymentModeItem  = itemArrayAtIndex[j];
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount =  paymentModeItem.calculatedAmount.floatValue ;
            float displayAmount = paymentModeItem.displayAmount.floatValue;
            if (actualAmount == 0 )
            {
                actualAmount = calCulatedAmount;
                if (actualAmount == 0)
                {
                    actualAmount = displayAmount;
                }
            }
            if(actualAmount!=0)
            {
                isPaymentDataCountGreaterThanZero = TRUE;
            }
        }
    }
    return isPaymentDataCountGreaterThanZero;
}

-(void)callWebserice
{
    self.collectionAmount = [self configurePaymentData];
//    float collectAmt = self.collectionAmount;
//    if (collectAmt < 0) {
//        collectAmt = -collectAmt;
//        NSString *collectAmtStr= [NSString stringWithFormat:@"%.2f",collectAmt];
//        collectAmt = [collectAmtStr floatValue];
//    }
    if([self isPaymentDataCountGreaterThanZero] == TRUE)
    {
        istenderclick=TRUE;
        NSString *tempPrice = [self formatedTextForAmount:self.paymentData.billAmount];
        float ftenderAmount=tempPrice.floatValue;
        
        if (ftenderAmount < 0) {
            ftenderAmount = -ftenderAmount;
            NSString *collectAmtStr= [NSString stringWithFormat:@"%.2f",ftenderAmount];
            ftenderAmount = collectAmtStr.floatValue;
            
        }
        _lblDueAmount.text =[self formatedTextForAmountWithCurrencyFormatter:-self.paymentData.balanceAmount];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        dict[@"Tender"] = @"ChangeDueShow";
        dict[@"ChangeDue"] = _lblDueAmount.text;
        dict[@"ShowTender"] = [self formatedTextForAmount:self.paymentData.totalCollection];
        dict[@"Total"] = [self formatedTextForAmount:self.paymentData.billAmount];
        [self.crmController writeDictionaryToCustomerDisplay:dict];

        // Milan - Commented`
//        NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        [self deleteDataFromHoldTable];
        if(ftenderAmount>0)
        {
            // if(ftenderAmount<=collectAmt)
            {
                self.Payparam = [self getPaymentProcessData];
                self.webserviceCallInProgress = NO;
                
                // Intiate Webservice Call in BackGround Fom RCR........
                
                self.serverInvoiceNo  =  _lblRegInvoiceNo.text;
                
                [self.crmController didInsertInvoiceDataToServerWithDetail:self.Payparam withInvoiceObject:invoiceData.objectID];
                
                // Perform Next...
                
                [self.tenderProcessManager performNextStep];
                
                //             self.tenderWebserviceConnection =  [self.tenderWebserviceConnection initWithJSONKey:nil JSONValues:self.Payparam actionName:@"AddInvoice11192014" URL:KURL_INVOICE NotificationName:@"DonePayment"];
            }
        }
        else
        {
            //  if(ftenderAmount==collectAmt)
            {
                _lblDueAmount.text = [self formatedTextForAmountWithCurrencyFormatter:-self.paymentData.balanceAmount];
                self.Payparam = [self getPaymentProcessData];
                self.webserviceCallInProgress = NO;
                // Intiate Webservice Call in BackGround Fom RCR........
                
                // Perform Next...
                self.serverInvoiceNo  =  _lblRegInvoiceNo.text;
                [self.crmController didInsertInvoiceDataToServerWithDetail:self.Payparam withInvoiceObject:invoiceData.objectID];
                [self.tenderProcessManager performNextStep];
                
                //               self.tenderWebserviceConnection = [self.tenderWebserviceConnection initWithJSONKey:nil JSONValues:self.Payparam actionName:@"AddInvoice11192014" URL:KURL_INVOICE NotificationName:@"DonePayment"];
            }
        }
    }

    if ([self.paymentData.moduleIdentifier isEqualToString:@"RcrPosRestaurantVC"])
    {
        [self updateRestaurantOrder];
    }
}

-(IBAction)changeMovetoGas:(id)sender{
    if(-self.paymentData.balanceAmount > 0.0){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"GasPump" bundle:nil];
//        gasTransVC = [storyBoard instantiateViewControllerWithIdentifier:@"GasPumpTransferVC"];
//        gasTransVC.gasPumpTransferVCDelegate = self;
//        [self.view addSubview:gasTransVC.view];
 
    }
}

#pragma mark - Gas Pump Transfer View Delegate Method

-(void)didCancelGasPumpTransferview{
    
//    [gasTransVC.view removeFromSuperview];

}
-(void)didSelectPumpForTransfer:(NSNumber *)tranferPumpIndex{

    if([self checkPumpAlerayinList:tranferPumpIndex]){
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Already in list." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    else{
       
/*        RcrPosGasVC *posVc = (RcrPosGasVC *)self.tenderDelegate;

        [posVc authorizePumpWithChange:-self.paymentData.balanceAmount isAmount:YES withPump:tranferPumpIndex];

        [self.paymentData.rcrBillSummary updateBillSummrayWithDetail:[self reciptDataAryForBillOrder]];
        [self updateBillSummaryWithReceiptArray:[self reciptDataAryForBillOrder]];
        [self updatePaymentDetailForInsertGasItem];
        
        self.paymentData.balanceAmount = 0.00;
        [self setTotalItemQty:[self reciptDataAryForBillOrder]];
        [self updateTenderStatus];
        [gasTransVC.view removeFromSuperview];*/
    }
    
}
-(BOOL)checkPumpAlerayinList:(NSNumber *)pumpIndex{
    NSMutableArray *itemList = [self reciptDataAryForBillOrder];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"InvoicePumpCart.PumpId = %@",pumpIndex];
    NSArray *pumpList = [itemList filteredArrayUsingPredicate:predicate];
    if(pumpList.count > 0){
        return YES;
    }
    else{
       return NO;
    }
    
}
-(void)setTotalItemQty:(NSMutableArray *)itemArray{
    CGFloat qty = 0;
    for (int i = 0 ; i < itemArray.count; i++) {
        CGFloat totalQty = [[itemArray[i] valueForKeyPath:@"itemQty"] floatValue] / [[itemArray[i] valueForKeyPath:@"PackageQty"] floatValue];
        qty += totalQty;
    }
    _lbltotItem.text = [NSString stringWithFormat:@"%ld",(long)qty];
}
-(void)updateRestaurantOrder
{
    if (self.restaurantOrderTenderObjectId) {
        NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderTenderObjectId];
        restaurantOrder.state = @(COMPLETED_ORDER);
        [UpdateManager saveContext:privateManageobjectContext];
    }
}

-(void)processChangeDue
{
    BOOL isApplicableCustomer;
    
    _lblDueAmount.text = [self formatedTextForAmountWithCurrencyFormatter:-self.paymentData.balanceAmount];
    _tenderEnterBtn.hidden=YES;
    self.btnchangeMoveToGas.hidden=YES;
    _uvtendernumpad.hidden=YES;
    _lblRegInvoiceNo.hidden = NO;
   // emailButton.hidden = NO;
    _lblTransaction.hidden = NO;
    _lblRegInvoiceNo.text = self.paymentData.strInvoiceNo;
    _transactionView.hidden = NO;
    self.crmController.singleTap1.enabled=NO;
   // [self.view addSubview:_uvTenderView];
    
    isApplicableCustomer = [self isSpecOptionApplicableAfterCreditCard:SPEC_CUSTOMER_DISPLAY_SIGN_RECEIPT];
    if (isApplicableCustomer)
    {
        [self.view bringSubviewToFront:_customSignatureAlert];
    }
    // _btnClose.enabled=NO;
    _btnClose.hidden=YES;
    _btnClose.userInteractionEnabled=NO;
    _uvTenderView.hidden=NO;
    _addCustomerButton.hidden = YES;
    _customerNameLabel.hidden = YES;
    _removeCustomerButton.hidden = YES;
    _btnContinueEBT.hidden = YES;
    _btnAdjustEBT.hidden = YES;

    
    [self.loadingIndicator startAnimating];
    
    if (customerDiplayTipAmount > 0)
    {
        [self configurePaymentData];
    }
    
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];

    NSMutableArray *masterDetails = [[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceMst"];
    NSString *receiptDate = [self invoiceRecieptDate:[[masterDetails.firstObject firstObject] valueForKey:@"Datetime"]];

    NSString *regInvNo = [masterDetails.firstObject  valueForKey:@"RegisterInvNo"];
    
    NSMutableArray *pumpCart = [[self processForPumpCart:regInvNo]mutableCopy];
    if(pumpCart.count == 0){
        // for PrePay
        pumpCart = [[self processForPumpCartPrepay] mutableCopy];
    }
    
    if([self.rmsDbController checkGasPumpisActive] && pumpCart.count > 0){
        
        if([self isPrepayTransaction:pumpCart]){
            
            GasInvoiceReceiptPrint *gasinvoiceReceiptPrint = [[GasInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:[self reciptDataAryForBillOrder] withPaymentDatail:[self.paymentData invoicePaymentdetail] tipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray receiptDate:receiptDate];
            gasinvoiceReceiptPrint.arrPumpCartArray = pumpCart;
               self.emailReciptHtml = [gasinvoiceReceiptPrint generateHtmlForInvoiceNo:self.strInvoiceNo withChangeDue:_lblDueAmount.text];
            
        }
        else{
            PostpayGasInvoiceReceiptPrint *postpaygasinvoiceReceiptPrint = [[PostpayGasInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:[self reciptDataAryForBillOrder] withPaymentDatail:[self.paymentData invoicePaymentdetail] tipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray receiptDate:receiptDate];
            postpaygasinvoiceReceiptPrint.arrPumpCartArray = pumpCart;
            self.emailReciptHtml = [postpaygasinvoiceReceiptPrint generateHtmlForInvoiceNo:self.paymentData.strInvoiceNo withChangeDue:_lblDueAmount.text];
        }
    }
    else{
        
        InvoiceReceiptPrint *invoiceReceiptPrint = [[InvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:[self reciptDataAryForBillOrder] withPaymentDatail:[self.paymentData invoicePaymentdetail] tipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray receiptDate:receiptDate];
        self.emailReciptHtml = [invoiceReceiptPrint generateHtmlForInvoiceNo:self.paymentData.strInvoiceNo withChangeDue:_lblDueAmount.text];
    }
    
    //[self htmlBillText];
    
    [self.tenderProcessManager performNextStep];
}
- (void)increaseInvRegisterNumber
{
    NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
    NSInteger number = keyChainInvoiceNo.integerValue;
    number++;
    NSString *updatedTenderInvoiceNo = [NSString stringWithFormat: @"%d", (int)number];
    [Keychain saveString:updatedTenderInvoiceNo forKey:@"tenderInvoiceNo"];
}

- (void)decreaseInvRegisterNumber
{
    NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
    NSInteger number = keyChainInvoiceNo.integerValue;
    number--;
    NSString *updatedTenderInvoiceNo = [NSString stringWithFormat: @"%d", (int)number];
    [Keychain saveString:updatedTenderInvoiceNo forKey:@"tenderInvoiceNo"];
}

- (void)insertDataInLocalDataBase
{
    NSMutableDictionary *databaseInsertDictionary = [self getPaymentProcessData];
    databaseInsertDictionary[@"branchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    databaseInsertDictionary[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    databaseInsertDictionary[@"zId"] = [self.rmsDbController.globalDict valueForKey:@"ZId"];
    databaseInsertDictionary[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    databaseInsertDictionary[@"msgCode"] = @"-1";
    databaseInsertDictionary[@"message"] = @"Web services Connection Error. Try Again";
    [self insertTenderPaymentDataToDatabase:databaseInsertDictionary];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CardTransactionRequest"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self insertLastInvoiceDataToLocalData];


}

- (NSMutableDictionary *)insertPumpDataDictionary
{
    NSMutableDictionary *pumpCartInsertDictionary = [self getPaymentProcessData];
    pumpCartInsertDictionary[@"branchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    pumpCartInsertDictionary[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    pumpCartInsertDictionary[@"zId"] = [self.rmsDbController.globalDict valueForKey:@"ZId"];
    pumpCartInsertDictionary[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    pumpCartInsertDictionary[@"msgCode"] = @"-1";
    pumpCartInsertDictionary[@"message"] = @"Web services Connection Error. Try Again";
    return pumpCartInsertDictionary;
}


- (void)removeLocalDataFromTable
{
    if (invoiceData != nil) {
        // fetch data to delete the transaction.....
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        [UpdateManager deleteFromContext:privateContextObject objectId:invoiceData.objectID];
        [UpdateManager saveContext:privateContextObject];
        invoiceData = nil;
    } else {
    }
}

-(void)insertTenderPaymentDataToDatabase:(NSMutableDictionary *)tenderData
{
    NSManagedObjectContext *privateContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext ];
    invoiceData = [self.updateManager insertTenderPaymentDataFromDictionary:tenderData withContext:privateContext];
    
    invoiceData = (InvoiceData_T*)[self.managedObjectContext objectWithID:invoiceData.objectID];
}

-(void)displayPrintReciptPromt
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self.tenderProcessManager performNextStep];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self PrintReceipt];
        self.tenderProcessManager.currentStep++;
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Payment process done successfully.\nWould you like to print a receipt?" buttonTitles:@[@"Cancel",@"Print"] buttonHandlers:@[leftHandler,rightHandler]];
}


-(BOOL)isSpecOptionApplicable :(NSInteger)specOption
{
    BOOL isApplicable = FALSE;
    
    
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray *itemArrayAtIndex = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < itemArrayAtIndex.count; j++)
        {
            PaymentModeItem *paymentModeItem  = itemArrayAtIndex[j];
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount =  paymentModeItem.calculatedAmount.floatValue ;
            float displayAmount = paymentModeItem.displayAmount.floatValue;
            int ipay=paymentModeItem.paymentId.intValue;

            if (actualAmount == 0 )
            {
                actualAmount = calCulatedAmount;
                if (actualAmount == 0)
                {
                    actualAmount = displayAmount;
                }
            }
            if(actualAmount!=0)
            {
                for(int i = 0;i<self.crmController.globalArrTenderConfig.count;i++)
                {
                    int itender=[[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"PayId" ] intValue ];
                    if(ipay==itender)
                    {
                        if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"] intValue ] == specOption)
                        {
                            isApplicable = TRUE;
                            break;
                        }
                    }
                }
            }
        }
    }
     return isApplicable;
}


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
                case SPEC_BROD_POS_SERVER:
                    applicableTransctionServer = @"BROD POS";
                    break;
                default:
                   
                    break;
            }
        }
    }
    return applicableTransctionServer;
}



-(BOOL)isSpecOptionApplicableForMultipeCreditCard :(NSInteger)specOption withPaymentId:(NSInteger)paymentId
{
    BOOL isApplicable = FALSE;
        for(int i = 0;i<self.crmController.globalArrTenderConfig.count;i++)
        {
            int itender=[[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"PayId" ] intValue ];
            if(paymentId==itender)
            {
                if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"] intValue ] == specOption)
                {
                    isApplicable = TRUE;
                    break;
                }
            }
        }
    return isApplicable;
}
-(BOOL)isSpecOptionApplicableForCreditCard :(NSInteger)specOption withPaymentId:(NSInteger)paymentId
{
    BOOL isApplicable = FALSE;
    for(int i = 0;i<self.crmController.globalArrTenderConfig.count;i++)
    {
        int itender=[[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"PayId" ] intValue ];
        if(paymentId==itender)
        {
            if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"] intValue ] == specOption)
            {
                isApplicable = TRUE;
                break;
            }
        }
    }
    return isApplicable;
}



-(BOOL)isSpecOptionApplicableCreditCard :(int)specOption
{
    BOOL isApplicable = FALSE;
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            NSInteger ipay= paymentModeItem.paymentId.integerValue;
            
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
            BOOL isCreditCardSwipe = [self.paymentData isCreditCardSwipedAtPaymentMode:paymentModeItem];
            
            if (actualAmount == 0)
            {
                actualAmount = calCulatedAmount;
            }
            if (!(actualAmount == 0) && isCreditCardSwipe == FALSE && ![paymentModeItem.paymentType isEqualToString:@"RapidRMS Gift Card"])
            {
                for(int tenderConfig = 0; tenderConfig<self.crmController.globalArrTenderConfig.count; tenderConfig++)
                {
                    int itender=[[(self.crmController.globalArrTenderConfig)[tenderConfig] valueForKey:@"PayId" ] intValue ];
                    if(ipay==itender)
                    {
                        if([[(self.crmController.globalArrTenderConfig)[tenderConfig] valueForKey:@"SpecOption"] intValue ] == specOption)
                        {
                            isApplicable = TRUE;
                            break;
                        }
                    }
                }
                
            }
        }
    }
    return isApplicable;
}

-(NSString *)getGiftCardAmount
{
    NSString *strPrice = @"";
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            NSString *payType = paymentModeItem.paymentType;
            if([payType isEqualToString:@"RapidRMS Gift Card"]){
                
                float actualAmount = paymentModeItem.actualAmount.floatValue ;
                float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
                float total = actualAmount+calCulatedAmount;
                if(!(total == 0)){
                    strPrice = [NSString stringWithFormat:@"%.2f",total];
                    break;
                }
                
            }
        }
    }
    return strPrice;
}

-(NSNumber *)getHouseChargeAmount
{
    NSNumber * houseChargeAmount ;
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            NSString *payType = paymentModeItem.paymentType;
            if([payType isEqualToString:@"HouseCharge"]){
                
                float actualAmount = paymentModeItem.actualAmount.floatValue ;
                float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
                float total = actualAmount+calCulatedAmount;
                if(!(total == 0)){
                    houseChargeAmount = @(total);
                    break;
                }
                
            }
        }
    }
    return houseChargeAmount;
}

-(BOOL)isSpecOptionApplicableGiftCard
{
    BOOL isApplicable = FALSE;
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            NSString *payType = paymentModeItem.paymentType;
            if([payType isEqualToString:@"RapidRMS Gift Card"]){
                
                float actualAmount = paymentModeItem.actualAmount.floatValue ;
                float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
                float total = actualAmount+calCulatedAmount;
                if(!(total == 0)){
                    isApplicable = YES;
                    break;
                }

            }
        }
    }
    return isApplicable;
}
                                       
-(BOOL)isSpecOptionApplicableHouseCharge
{
    BOOL isApplicable = FALSE;
    NSMutableArray *itemDetails = [[[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceItemDetail"] firstObject];
    NSString *paymentItemName = [itemDetails.firstObject valueForKey:@"ItemName"];

    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            NSString *payType = paymentModeItem.paymentType;
            if([payType isEqualToString:@"HouseCharge"] || [paymentItemName isEqualToString:@"HouseCharge"]){
                
                float actualAmount = paymentModeItem.actualAmount.floatValue ;
                float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
                float total = actualAmount+calCulatedAmount;
                if(!(total == 0)){
                    isApplicable = YES;
                    break;
                }
                
            }
        }
    }
    return isApplicable;
}



-(BOOL)isSpecOptionApplicableAfterCreditCard :(int)specOption
{
    BOOL isApplicable = FALSE;
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            NSInteger ipay = paymentModeItem.paymentId.integerValue;
            
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
            BOOL isCreditCardSwipe = [self.paymentData isCreditCardSwipedAtPaymentMode:paymentModeItem];
            
            if (actualAmount == 0)
            {
                actualAmount = calCulatedAmount;
            }
            if (!(actualAmount == 0) && isCreditCardSwipe == TRUE)
            {
                for(int tenderConfig = 0; tenderConfig<self.crmController.globalArrTenderConfig.count; tenderConfig++)
                {
                    int itender=[[(self.crmController.globalArrTenderConfig)[tenderConfig] valueForKey:@"PayId" ] intValue ];
                    if(ipay==itender)
                    {
                        if([[(self.crmController.globalArrTenderConfig)[tenderConfig] valueForKey:@"SpecOption"] intValue ] == specOption)
                        {
                            isApplicable = TRUE;
                            break;
                        }
                    }
                }
                
            }
        }
    }
    return isApplicable;
}

-(BOOL)isSpecOptionApplicableAfterGiftCard :(int)specOption
{
    BOOL isApplicable = FALSE;
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            NSInteger ipay = paymentModeItem.paymentId.integerValue;
            
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
            
            if (actualAmount == 0)
            {
                actualAmount = calCulatedAmount;
            }
            if (!(actualAmount == 0))
            {
                for(int tenderConfig = 0; tenderConfig<self.crmController.globalArrTenderConfig.count; tenderConfig++)
                {
                    int itender=[[(self.crmController.globalArrTenderConfig)[tenderConfig] valueForKey:@"PayId" ] intValue ];
                    if(ipay==itender)
                    {
                        if([[(self.crmController.globalArrTenderConfig)[tenderConfig] valueForKey:@"SpecOption"] intValue ] == specOption)
                        {
                            isApplicable = TRUE;
                            break;
                        }
                    }
                }
                
            }
        }
    }
    return isApplicable;
}

-(BOOL)isSpecOptionApplicableAfterHouseCharge :(int)specOption
{
        BOOL isApplicable = FALSE;
    NSMutableArray *itemDetails = [[[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceItemDetail"] firstObject];
    NSString *paymentItemName = [itemDetails.firstObject valueForKey:@"ItemName"];

        for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
        {
            NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
            for (int j = 0; j < paymentSubArray.count; j++)
            {
                PaymentModeItem *paymentModeItem  = paymentSubArray[j];
                NSString *payType = paymentModeItem.paymentType;
                if([payType isEqualToString:@"HouseCharge"] || [paymentItemName isEqualToString:@"HouseCharge"]){
                    
                    float actualAmount = paymentModeItem.actualAmount.floatValue ;
                    float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
                    float total = actualAmount+calCulatedAmount;
                    if(!(total == 0)){
                        isApplicable = YES;
                        break;
                        
                    }
                    
                }
            }
        }
        return isApplicable;
    
}

-(NSMutableArray *)creditCardInformation
{
    NSMutableArray *creditCardArray = [[NSMutableArray alloc]init];
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
            BOOL isCreditCardSwipe = [self.paymentData isCreditCardSwipedAtPaymentMode:paymentModeItem];
            if (actualAmount == 0)
            {
                actualAmount = calCulatedAmount;
            }
            if (!(actualAmount == 0) && isCreditCardSwipe == TRUE)
            {
                [creditCardArray addObject:[paymentModeItem.paymentModeDictionary mutableCopy]];
            }
        }
    }
    return creditCardArray;
}



-(void)OpenChangeDue
{
    if (isChangeDueOpen==FALSE)
    {
//        NSString *temptxtBalanceAmount =[txtBalanceAmount.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
        NSString *temptxtRemovePrice=[self formatedTextForAmount:-self.paymentData.balanceAmount];
        float str=temptxtRemovePrice.floatValue;
        if (str==0.00)
        {
            isChangeDueOpen=FALSE;
            istenderclick=FALSE;
            [self resetTotal];
        }
        _uvTenderView.hidden=NO;
        _addCustomerButton.hidden = YES;
        _customerNameLabel.hidden = YES;
        _removeCustomerButton.hidden = YES;
        isChangeDueOpen=TRUE;
    }
}

-(void)PrintReceipt
{
    //  NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.doneButtonTimeStamp];
    self.printJobCount++;
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    NSMutableArray *masterDetails = [[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceMst"];
    NSString *receiptDate = [self invoiceRecieptDate:[[masterDetails.firstObject firstObject] valueForKey:@"Datetime"]];
    
    NSString *regInvNo = [[masterDetails.firstObject firstObject]  valueForKey:@"RegisterInvNo"];

    NSMutableArray *gasArray = [[self processForPumpCart:regInvNo]mutableCopy];
    if([gasArray count] == 0){
        // for PrePay
        gasArray = [[self processForPumpCartPrepay] mutableCopy];
    }
    
    if([self.rmsDbController checkGasPumpisActive] && gasArray.count > 0){
        
        if([self isPrepayTransaction:gasArray]){
           
            GasInvoiceReceiptPrint *gasinvoiceReceiptPrint = [[GasInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:[self reciptDataAryForBillOrder] withPaymentDatail:[self.paymentData invoicePaymentdetail] tipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray receiptDate:receiptDate];
            gasinvoiceReceiptPrint.arrPumpCartArray = gasArray;
            [gasinvoiceReceiptPrint printInvoiceReceiptForInvoiceNo:self.strInvoiceNo withChangeDue:_lblDueAmount.text withDelegate:self];

        }
        else{
            PostpayGasInvoiceReceiptPrint *postpaygasinvoiceReceiptPrint = [[PostpayGasInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:[self reciptDataAryForBillOrder] withPaymentDatail:[self.paymentData invoicePaymentdetail] tipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray receiptDate:receiptDate];
            postpaygasinvoiceReceiptPrint.arrPumpCartArray = gasArray;
            [postpaygasinvoiceReceiptPrint printInvoiceReceiptForInvoiceNo:self.paymentData.strInvoiceNo withChangeDue:_lblDueAmount.text withDelegate:self];
        }
        
    }
    else{
       
        InvoiceReceiptPrint *invoiceReceiptPrint = [[InvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:[self reciptDataAryForBillOrder] withPaymentDatail:[self.paymentData invoicePaymentdetail] tipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray receiptDate:receiptDate];
        [invoiceReceiptPrint printInvoiceReceiptForInvoiceNo:self.paymentData.strInvoiceNo withChangeDue:_lblDueAmount.text withDelegate:self];
    }
}
-(BOOL)isPrepayTransaction:(NSMutableArray *)gasArray{
    BOOL prepay = NO;
    if([gasArray[0][@"TransactionType"] isEqualToString:@"PRE-PAY"]){
        prepay = YES;
    }
    return prepay;
    
}

-(NSArray *)processForPumpCartPrepay{
    NSMutableArray *arrayPumpCart = [[NSMutableArray alloc]init];

    for (NSDictionary *prepayDict in self.prepayPumpsArray) {
        
        NSMutableDictionary *dictAuthCart = [[NSMutableDictionary alloc]init];
        dictAuthCart[@"PumpId"] = [prepayDict valueForKey:@"selectedPump"];
        dictAuthCart[@"AmountLimit"] = @([[prepayDict valueForKey:@"number"] floatValue]);
        dictAuthCart[@"TransactionType"] = @"PRE-PAY";
        [arrayPumpCart addObject:dictAuthCart];

    }
    return arrayPumpCart;
    
}

-(NSArray *)processForPumpCart:(NSString *)regInvNo{
    
    NSMutableArray *arrayPumpCart = [[NSMutableArray alloc]init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"PumpCartObjectID != nil"];
    NSArray *refundCart = [self.prepayPumpsArray filteredArrayUsingPredicate:predicate];
    if(refundCart.count>0){
        for (NSDictionary *refundDict in refundCart) {
            NSManagedObjectID *pumpCartid = (NSManagedObjectID *)[refundDict valueForKey:@"PumpCartObjectID"];
            
//            NSManagedObjectContext * privateMOC = [UpdateManager privateConextFromParentContext:self.rmsDbController.rapidPetroPos.petroMOC];
//            
//            PumpCart *pumpCart = [privateMOC objectWithID:pumpCartid];
/*            NSMutableDictionary *fuelPumpDict = [[pumpCart getCartDictionary] mutableCopy];
            
            float amountLimit = [fuelPumpDict[@"ApprovedAmount"]floatValue];
            fuelPumpDict[@"AmountLimit"] = [NSNumber numberWithFloat:amountLimit];
            fuelPumpDict[@"FuelId"] = [NSNumber numberWithFloat:[fuelPumpDict[@"FuelIndex"] floatValue]];
            fuelPumpDict[@"PumpId"] = [NSNumber numberWithFloat:[fuelPumpDict[@"PumpIndex"] floatValue]];
            fuelPumpDict[@"RegInvNum"] = regInvNo;
            [arrayPumpCart addObject:fuelPumpDict];*/
        }
    }
    return arrayPumpCart;
}

- (NSString *)invoiceRecieptDate:(NSString *)strLastInvoiceDate
{
    if ([strLastInvoiceDate isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSDate *lastInvoiceDate = [dateFormatter dateFromString:strLastInvoiceDate];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    dateFormatter2.dateFormat = @"MM/dd/yyyy hh:mm a";
    return [dateFormatter2 stringFromDate:lastInvoiceDate];
}

-(void)OpenCashDrawer
{
    self.printJobCount++;
    [self kickCashDrawer];
}

-(void)kickCashDrawer
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    PrintJob *printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"CashDrawer" withDelegate:self];
    [printJob openCashDrawer];
    [printJob firePrint];
}

-(IBAction)btnOkClick:(id)sender
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    dict[@"Tender"] = @"ChangeDueHide";
    [self.crmController writeDictionaryToCustomerDisplay:dict];
    [self.rmsDbController playButtonSound];
    isChangeDueOpen=FALSE;
    istenderclick=FALSE;
    [self resetTotal];
}

- (void)insertLastInvoiceDataToLocalData
{
    //// insert data to core data for last invoice......
    NSMutableDictionary *subDictionary = [[NSMutableDictionary alloc]init];
    subDictionary[@"branchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    subDictionary[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    subDictionary[@"zId"] = [self.rmsDbController.globalDict valueForKey:@"ZId"];
//    NSString *collectAmount = [lblCollectAmont.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
	subDictionary[@"collectAmount"] = [self formatedTextForAmount:self.paymentData.totalCollection];
    
//    NSString *changeDue = [txtBalanceAmount.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
	subDictionary[@"changeDue"] = [self formatedTextForAmount:-self.paymentData.balanceAmount];
    
	subDictionary[@"tenderAmount"] = [self formatedTextForAmount:self.paymentData.billAmount];
    
    subDictionary[@"paymentType"] = [NSString stringWithFormat:@"%@",paymentVar];
    
    
    if (self.Payparam == nil)
    {
        _lblDueAmount.text = [self formatedTextForAmountWithCurrencyFormatter:-self.paymentData.balanceAmount];
        self.Payparam =[self getPaymentProcessData];
    }
    [self updateDictionaryWithUserInfo:self.Payparam];
    [self.updateManager insertLastinvoiceDataFromDictionary:self.Payparam withSubDictionary:subDictionary];
}

-(void)updateDictionaryWithUserInfo :(NSMutableDictionary *)paymentDictionary
{
    NSMutableArray *invoiceMstData = [[paymentDictionary valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceMst"];
    NSMutableDictionary *invoiceMasterDictionary = [invoiceMstData.firstObject firstObject];
    invoiceMasterDictionary[@"UserName"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserName"];
    invoiceMasterDictionary[@"RegisterName"] = (self.rmsDbController.globalDict)[@"RegisterName"];
}

-(void)singleTapChangeDue
{
  //  [self insertLastInvoiceDataToLocalData];
    
    // call invoice push notification on double click
    NSMutableDictionary *ItemNotificationDict=[[NSMutableDictionary alloc]init];
    if (self.invoiceNotificationDict != nil)
    {
        NSString *str= (self.invoiceNotificationDict)[@"ItemCodes"];
        if (![str isEqualToString:@""])
        {
            ItemNotificationDict[@"Code"] = str;
            NSString *strAction= (self.invoiceNotificationDict)[@"Action"];
            ItemNotificationDict[@"Action"] = strAction;
            ItemNotificationDict[@"EntityId"] = (self.rmsDbController.globalDict)[@"BranchID"];
            [self.crmController tenderInvoiceNotificat:ItemNotificationDict];
        }
    }
    // end
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    dict[@"Tender"] = @"ChangeDueHide";
    [self.crmController writeDictionaryToCustomerDisplay:dict];
    [self.rmsDbController playButtonSound];
    isChangeDueOpen=FALSE;
    istenderclick=FALSE;
    _uvTenderView.hidden = YES;
    [self stopChangeDueTimer];
   
    [self tenderTaskDidFinish];
}

-(void)resetTenderData
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    dict[@"Tender"] = @"ChangeDueHide";
    [self.crmController writeDictionaryToCustomerDisplay:dict];
    [self.rmsDbController playButtonSound];
    isChangeDueOpen=FALSE;
    istenderclick=FALSE;
    [self resetTotal];
}

- (void)printReceiptAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [self PrintReceipt];
            self.tenderProcessManager.currentStep++;
        case 0:
            [self.tenderProcessManager performNextStep];
            break;
            
        default:
            break;
    }
}

- (void)printErrorAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            self.tenderProcessManager.currentStep--;
        case 0:
            [self.tenderProcessManager performNextStep];
            break;
            
        default:
            break;
    }
    
}

- (IBAction)pressKeyPadButton:(id)sender {
    
    if (self.tenderType.length > 0 && self.selectedPaymentIndexPath == nil) {
        self.selectedPaymentIndexPath = [self.paymentData selectedIndexPathForPaymentMode] ;
    }
    
    [self.rmsDbController playButtonSound];
    if (self.paymentData.amountToPay == 0)
    {
        return;
    }
    //    NSDictionary *paymentDict = [self.paymentData creditCardDictionaryAtIndex:self.selectedPaymentIndexPath];
    //    if (paymentDict != nil)
    //    {
    //        return ;
    //    }
    if ([self.paymentData isEbtPaymentModeAtIndexpath:self.selectedPaymentIndexPath]) {
        return;
    }
    
    if ([self.paymentData isCreditCardSwipedForPayment:self.selectedPaymentIndexPath])
    {
        return ;
    }
    
    if ([self.paymentData isGiftCardApproveForPaymentMode:self.selectedPaymentIndexPath]) {
        return;
    }
    
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        userEditedAmount *=10.0;
        userEditedAmount += ([sender tag]/100.0);
	} else if ([sender tag] == -99) {
		quickAmount = 0;
        userEditedAmount = 0;
	} else if ([sender tag] == 101) {
        userEditedAmount *=100.0;
	}
    if (self.paymentData.amountToPay < 0.0 )
    {
        [self.paymentData setActualAmount:-userEditedAmount AtIndexPath:self.selectedPaymentIndexPath];
    }
    else
    {
        if ([self.paymentData isHouseChargePaymentModeAtIndexpath:self.selectedPaymentIndexPath]) {
            if ( self.paymentData.houseChargeAmount > 0 && userEditedAmount > self.paymentData.houseChargeAmount)
            {
                userEditedAmount = self.paymentData.houseChargeAmount;
            }
        }
        [self.paymentData setActualAmount:userEditedAmount AtIndexPath:self.selectedPaymentIndexPath];
    }
    [self updateTenderStatus];
    
}


- (NSString *)getCurrentDate
{
    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    return [dateFormatter stringFromDate:date];
}

-(IBAction)emailSend:(id)sender
{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
    
    NSData *myData = [NSData dataWithContentsOfFile:self.emailReciptHtml];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    emailFromViewController.rapidEmailCustomerLoyalty = self.paymentData.rapidCustomerLoyalty;
    emailFromViewController.emailFromViewControllerDelegate = self;
    NSString *strsubjectLine = [NSString stringWithFormat:@"Your Receipt from %@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]];
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

-(void)writeDataOnCacheDirectory :(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.emailReciptHtml])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.emailReciptHtml error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.emailReciptHtml = [documentsDirectory stringByAppendingPathComponent:@"CustomerDetail.html"];
    [data writeToFile:self.emailReciptHtml atomically:YES];
}



- (void) resetTotal {
    [_tenderSubTotalView updateSubtotalViewWithBillAmount:0.00 withCollectedAmount:0.00 withChangeDue:0.00 withTipAmount:0.0];
}
- (IBAction)selectPort:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedPort = selectedIndex;
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Port" rows:array_port initialSelection:selectedPort doneBlock:done cancelBlock:cancel origin:sender];
}

-(void)cardPrintReciept
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    NSMutableArray *masterDetails = [[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceMst"];
    NSString *receiptDate = [self invoiceRecieptDate:[[masterDetails.firstObject firstObject] valueForKey:@"Datetime"]];

    CardReceiptPrint *cardReceiptPrint = [[CardReceiptPrint alloc] initWithPortName:portName portSetting:portSettings withPaymentDatail:[self.paymentData invoicePaymentdetail] tipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray receiptDate:receiptDate];
    [cardReceiptPrint printCardReceiptForInvoiceNo:self.paymentData.strInvoiceNo withDelegate:self];
}

-(void)hideTenderView
{
    _uvTenderView.hidden=YES;
    //  uvDueAmount.hidden=YES;
    _uvtendernumpad.hidden=YES;
}

- (void)popBackToMainView
{
    if ([self.paymentData.moduleIdentifier isEqualToString:@"RcrPosRestaurantVC"])
    {
        NSArray *viewControllerArray = self.navigationController.viewControllers;
        for (UIViewController *viewController in viewControllerArray)
        {
            if ([viewController isKindOfClass:[RestaurantOrderList class]])
            {
                [self.navigationController popToViewController:viewController animated:TRUE];
            }
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)btnCloseclick:(id)sender
{
    [self.rmsDbController playButtonSound];
    NSMutableArray *billEntriesArray = [self reciptDataAryForBillOrder];

    NSDictionary *changeDueMessageDictionary = @{
                                                 @"Tender":@"HideChangeDueScreen",
                                                 @"BillEntries" : billEntriesArray,
                                                 @"TenderSubTotals" : self.dictAmoutInfo
                                                 };
    [self.crmController writeDictionaryToCustomerDisplay:changeDueMessageDictionary];
    [self.tenderDelegate didCancelTransaction];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.restaurantOrderTenderObjectId)
    {
        NSManagedObjectContext *privateManageobjectContext = self.managedObjectContext;
        RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderTenderObjectId];
        restaurantOrder.paymentData = nil;
        [UpdateManager saveContext:privateManageobjectContext];
    }
    
    self.crmController.singleTap1.enabled = YES;
    self.rmsDbController.isVoidTrasnaction = FALSE;
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnTenderAmount:(id)sender
{
}

- (void)tenderTaskDidFinish {
    if (!self.webserviceCallInProgress && (self.printJobCount == 0)) {
        //        [self.loadingIndicator stopAnimating];
    }
    
    if (self.webserviceCallInProgress || (self.printJobCount > 0) || !_uvTenderView.hidden) {
        // We cannot close
        return;
    }
    
    [self.tenderDelegate didFinishTransactionSuccessFully];

 
    [self.rmsDbController playButtonSound];
    self.crmController.singleTap1.enabled=YES;
    [_activityIndicator hideActivityIndicator];;
    self.rmsDbController.isVoidTrasnaction = FALSE;

    [self popBackToMainView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)printNextPass
{
    if (filterItemTicketArray.count == 0) {
        [self.tenderProcessManager performNextStep];
        return;
    }
    PassPrinting *passPrinting = [[PassPrinting alloc] init];
    passPrinting._printingData = filterItemTicketArray.lastObject;
    
    NSString *portName     = @"";
    NSString *portSettings = @"";
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    [passPrinting printingWithPort:portName portSettings:portSettings withDelegate:self];
}

#pragma mark - Printer Function Delegate

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
   // if ([device isEqualToString:@"Printer"]) {
        self.printJobCount--;
        if (self.tenderProcessManager.currentStep == TP_PRINT_PASS) {
            if (filterItemTicketArray.count > 0) {
                [filterItemTicketArray removeLastObject];
            }
            [self printNextPass];
        }
        else if (self.tenderProcessManager.currentStep == TP_PROCESS_CARDSRECIPTPRINT) {
            if (filterManualReceiptDetaiArray.count > 0) {
                [filterManualReceiptDetaiArray removeLastObject];
            }
            [self processNextCardReceipt];
        }
    
        else if (self.tenderProcessManager.currentStep == TP_PRINT_HOUSECHARGE)
        {
            if(houseChargePrintDetail.count > 0)
            {
                [houseChargePrintDetail removeLastObject];
                
            }
            [self printNextHouseCharge:FALSE];

        }
        else if (self.tenderProcessManager.currentStep == TP_PRINT_HOUSECHARGE_SIGNATURE)
        {
            if(houseChargePrintDetail.count > 0)
            {
                [houseChargePrintDetail removeLastObject];
                
            }
            [self printNextHouseCharge:TRUE];
            
        }

        else if (self.tenderProcessManager.currentStep == TP_PRINT_GIFTCARD) {
            if (giftCardPrintDetail.count > 0) {
                [giftCardPrintDetail removeLastObject];
            }
            [self performNextGiftCardPrintProcess];
        }
        else
        {
            [self.tenderProcessManager performNextStep];
        }
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    if ([device isEqualToString:@"CashDrawer"]) {
        [Appsee addEvent:kDrawerFailedKey withProperties:@{kDrawerFailedKey:@(1)}];
        [self displayOpenCashDrawerRetryAlert:@"Failed to open Cash Drawer. Would you like to retry.?"];
    }
    else
    {
        [Appsee addEvent:kPrinterFailedKey withProperties:@{kPrinterFailedKey:@(1)}];
        self.printJobCount--;
        NSString *retryMessage;
        
        if (self.tenderProcessManager.currentStep == TP_PRINT_PASS) {
            retryMessage = @"Failed to pass print receipt. Would you like to retry.?";
            [self displayPassPrintRetryAlert:retryMessage];
        }
        else if (self.tenderProcessManager.currentStep == TP_PROCESS_CARDSRECIPTPRINT) {
            retryMessage = @"Failed to manual card print receipt. Would you like to retry.?";
            [self displayManualCardPrintReceiptRetryAlert:retryMessage];
        }
        
        else if (self.tenderProcessManager.currentStep == TP_PRINT_GIFTCARD) {
            retryMessage = @"Failed to gift card print receipt. Would you like to retry.?";
            [self displayGiftCardPrintReceiptRetryAlert:retryMessage];
        }
        else if (self.tenderProcessManager.currentStep == TP_PRINT_HOUSECHARGE){
            retryMessage = @"Failed to house charge print receipt. Would you like to retry.?";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self displayHouseChargePrintReceiptRetryAlert:retryMessage];
            });

        }

        else
        {
            retryMessage = @"Failed to print receipt. Would you like to retry.?";
            [self displayPrintRetryAlert:retryMessage];
        }
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- CardProcessing Delegete
-(void)cardProcessingDidFinish:(BOOL)isPartiallyApprovedTransaction
{
    NSDictionary *changeDueMessageDictionary = @{
                                                 @"Tender":@"CreditCardProcessing",
                                                 @"TenderSubTotals":self.dictAmoutInfo,
                                                 @"ChangeDue":[self formatedTextForAmount:-self.paymentData.balanceAmount],
                                                 @"ShowTender":[self formatedTextForAmount:self.paymentData.totalCollection],
                                                 @"Total":[self formatedTextForAmount:self.paymentData.billAmount],
                                                 @"CreditCardMessage":@"Card Processing finished",
                                                 @"CreditCardStep":@(CreditCardProcessingStepFinished)
                                                 };
    [self.crmController writeDictionaryToCustomerDisplay:changeDueMessageDictionary];
    
    if ( isPartiallyApprovedTransaction == TRUE) {
        
        NSString *partialAmount = [self.crmController.currencyFormatter stringFromNumber:@(self.paymentData.totalPartialAmount)] ;
        
        
        NSString *strMessage = [NSString stringWithFormat:@"There is Partial Payment of %@ is approved. Please collect remaning amount OR void the transaction on top right." ,partialAmount];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Partial Payment" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
        [self updateTenderStatus];
        self.paxVoidButton.hidden = NO;
        self.btnClose.enabled = NO;
        return;
        
    }
    
    //without this below line it prints credit card receipt two times.
    self.tenderType = @"";
    [self.tenderProcessManager performNextStep];
    
    //
   /* if(([self.paymentData totalCollection] + self.paymentData.balanceAmount - self.paymentData.billAmount) > 0.009)
    {
        [self updateTenderStatus];
        self.paxVoidButton.hidden = NO;
        self.btnClose.enabled = NO;
    }
    else
    {
        [self.tenderProcessManager performNextStep];
    }*/
}
/*-(IBAction)voidButton:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self processVoidForBidgepay];
    });
}*/

/*-(void)processVoidForBidgepay
{
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
            if (actualAmount == 0)
            {
                actualAmount = calCulatedAmount;
            }
            if (actualAmount!=0 &&  [paymentModeItem.paymentType isEqualToString: @"Credit"])
            {
                [self processVoidForCurrenTransctionId:paymentModeItem.creditTransactionId];
            }
        }
    }
    _btnClose.enabled = YES;
    _btnClose.userInteractionEnabled = YES;
    self.rmsDbController.isVoidTrasnaction = FALSE;
    [_activityIndicator hideActivityIndicator];
    [self VoidTransactionsProcessForCreditCard];
}*/

/*-(void)processVoidForCurrenTransctionId:(NSString *)currentTransctionId
{
    NSLog(@"processVoidForCurrenTransctionId");
    
    NSString *extData = [NSString stringWithFormat:@"<TransactionID><Target>%@</Target></TransactionID>",currentTransctionId];
    
    NSString *transDetails = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=&InvNum=&PNRef=&Zip=&Street=&CVNum=&ExtData=%@",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],@"Void",extData];
    
    NSLog(@"transDetails = %@",transDetails);
    
    [self processVoidTransaction:[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"URL"] details:transDetails ];
}
- (void)processVoidTransaction:(NSString *)url details:(NSString *)details
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",@"ProcessCreditCard"]];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseCreditCardVoidTransctionResponse:response error:error];
        });
    };
    
    self.voidCreditCardTransctionWebserviceConnection = [self.voidCreditCardTransctionWebserviceConnection initWithAsyncRequestURL:url withDetailValues:details asyncCompletionHandler:asyncCompletionHandler];

    NSLog(@"url = %@",url);
}
-(void)responseCreditCardVoidTransctionResponse:(id)response error:(NSError *)error
{
    NSLog(@"responseCreditCardVoidTransctionResponse = %@",response);

}*/

-(void)updateDataToDatabseTable
{
    [self configurePaymentData];
    
    NSMutableDictionary *databaseInsertDictionary = [self getPaymentProcessData];
    databaseInsertDictionary[@"branchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    databaseInsertDictionary[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    databaseInsertDictionary[@"zId"] = [self.rmsDbController.globalDict valueForKey:@"ZId"];
    databaseInsertDictionary[@"msgCode"] = @"-1";
    databaseInsertDictionary[@"message"] = @"Web services Connection Error. Try Again";
    invoiceData = [self.updateManager updateDataToDataTableWithObject:invoiceData.objectID withInvoiceDetail:databaseInsertDictionary];
}
/*-(void) VoidTransactionsProcessForCreditCard
{
    if ([self reciptDataAryForBillOrder].count>0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary * param = [self getCurrentBillDataForCreditVoidTransaction];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self voidTransactionProcessForCreditCardResponse:response error:error];
        };
        
        self.voidTransactionProcessWC = [self.voidTransactionProcessWC initWithRequest:KURL actionName:WSM_ADD_VOID_INVOICE_TRANS params:param completionHandler:completionHandler];

    }
}

- (void)voidTransactionProcessForCreditCardResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
                NSInteger number = keyChainInvoiceNo.integerValue;
                number++;
                NSString *updatedTenderInvoiceNo = [NSString stringWithFormat: @"%d", (int)number];
                [Keychain saveString:updatedTenderInvoiceNo forKey:@"tenderInvoiceNo"];
                number++;
                updatedTenderInvoiceNo = [NSString stringWithFormat: @"%d", (int)number];
                self.paymentData.strInvoiceNo = [NSString stringWithFormat:@"%@%@",self.configuration.regPrefixNo,updatedTenderInvoiceNo ];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];;
}

- (NSMutableDictionary *) getCurrentBillDataForCreditVoidTransaction
{
    NSMutableDictionary *currentInvoiceDic = [[NSMutableDictionary alloc] init];
    
    NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [self InvoiceBillMstForCreditCardVoidProcess];
    invoiceDetailDict[@"InvoiceItemDetail"] = [self InvoiceBillItemDetailForCreditCardVoidProcess];
    [invoiceDetail addObject:invoiceDetailDict];
    currentInvoiceDic[@"InvoiceDetail"] = invoiceDetail;
    return currentInvoiceDic;
}


- (NSMutableArray *) InvoiceBillMstForCreditCardVoidProcess
{
    NSMutableArray * invoiceMst = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDataDict = [[NSMutableDictionary alloc] init];
    if (self.crmController.isbillOrderFromRecall)
    {
        invoiceDataDict[@"InvoiceNo"] = self.crmController.recallInvoiceId;
    }
    else
    {
        invoiceDataDict[@"InvoiceNo"] = @"0";  // invoice no increment in server side and service side invoiceno datatype is long so Set Object is 0...
    }
    NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
    NSInteger number = keyChainInvoiceNo.integerValue;
    number++;
    Configuration *configuration = [UpdateManager getConfigurationMoc:[UpdateManager privateConextFromParentContext:self.managedObjectContext]];
    NSString *registerInNo = [NSString stringWithFormat:@"%@%ld",configuration.regPrefixNo,(long)number ];
    invoiceDataDict[@"RegisterInvNo"] = registerInNo;
    
    invoiceDataDict[@"CustRefID"] = @"0";
    invoiceDataDict[@"Discount"] = [self.rmsDbController.globalDict valueForKey:@"BillDiscount"];
    invoiceDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    invoiceDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    invoiceDataDict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    invoiceDataDict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    
    invoiceDataDict[@"SubTotal"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceSubTotal"]] ];
    
    
    
    invoiceDataDict[@"TaxAmount"] = [NSString stringWithFormat:@"%.2f",[self RemoveSymbolFromString:[self.dictAmoutInfo valueForKey:@"InvoiceTax"]] ];
    
    
    invoiceDataDict[@"BillAmount"] = [self formatedTextForAmount:self.paymentData.billAmount];
    
    
    
    invoiceDataDict[@"Message"] = @"";
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSString *strDate=[NSString stringWithFormat:@"%@",destinationDate];
    invoiceDataDict[@"Datetime"] = strDate;
    
    [invoiceMst addObject:invoiceDataDict];
    
    return invoiceMst;
}

- (NSMutableArray *) InvoiceBillItemDetailForCreditCardVoidProcess
{
    NSMutableArray *tenderReciptDataAry = [self reciptDataAryForBillOrder];
    
    NSMutableArray * invoiceItemDetail = [[NSMutableArray alloc] init];
    for (int i=0; i<tenderReciptDataAry.count; i++)
    {
        NSMutableDictionary * tempObject = tenderReciptDataAry[i];
        NSMutableDictionary * itemsDataDict = [[NSMutableDictionary alloc] init];
        
        itemsDataDict[@"ItemCode"] = [tempObject valueForKey:@"itemId"];
        itemsDataDict[@"ItemAmount"] = [NSString stringWithFormat:@"%.02f", [tempObject[@"itemPrice"] floatValue]];
        itemsDataDict[@"ItemImage"] = [tempObject valueForKey:@"itemImage"];
        itemsDataDict[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
        itemsDataDict[@"isAgeApply"] = [tempObject valueForKey:@"item"][@"isAgeApply"];
      //////////
        itemsDataDict[@"DeptTypeId"] = [tempObject valueForKey:@"DeptTypeId"];

        itemsDataDict[@"isCheckCash"] = [tempObject valueForKey:@"item"][@"isCheckCash"];
        itemsDataDict[@"CheckCashAmount"] = [tempObject valueForKey:@"item"][@"CheckCashCharge"];
        itemsDataDict[@"isDeduct"] = [tempObject valueForKey:@"item"][@"isDeduct"];
        itemsDataDict[@"isAgeApply"] = [tempObject valueForKey:@"item"][@"isAgeApply"];
        
        itemsDataDict[@"ExtraCharge"] = [tempObject valueForKey:@"item"][@"ExtraCharge"];
        itemsDataDict[@"ItemType"] = [tempObject valueForKey:@"itemType"];
        itemsDataDict[@"PackageQty"] = [tempObject valueForKey:@"PackageQty"];
        itemsDataDict[@"PackageType"] = [tempObject valueForKey:@"PackageType"];
        itemsDataDict[@"departId"] = [tempObject valueForKey:@"departId"];
        itemsDataDict[@"Barcode"] = [tempObject valueForKey:@"Barcode"];
        itemsDataDict[@"ItemCost"] = [tempObject valueForKey:@"ItemCost"];
        itemsDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        itemsDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        
        itemsDataDict[@"ItemName"] = [tempObject valueForKey:@"itemName"];
        
        itemsDataDict[@"ItemDiscountAmount"] = [tempObject valueForKey:@"ItemDiscount"];
        itemsDataDict[@"ItemQty"] = [tempObject valueForKey:@"itemQty"];
        itemsDataDict[@"PackageQty"] = [tempObject valueForKey:@"PackageQty"];
        itemsDataDict[@"PackageType"] = [tempObject valueForKey:@"PackageType"];
        
        if ([[tempObject valueForKey:@"ItemBasicPrice"] floatValue] < 1 && [[tempObject valueForKey:@"ItemBasicPrice"] floatValue] > 0) {
            itemsDataDict[@"ItemBasicAmount"] = [NSString stringWithFormat:@"0%@",[tempObject valueForKey:@"ItemBasicPrice"]];
        } else if ([[tempObject valueForKey:@"ItemBasicPrice"] floatValue] < 0) {
            itemsDataDict[@"ItemBasicAmount"] = [NSString stringWithFormat:@"-0%@",[[tempObject valueForKey:@"ItemBasicPrice"] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        } else {
            itemsDataDict[@"ItemBasicAmount"] = [tempObject valueForKey:@"ItemBasicPrice"];
        }
        float TotTax=0.0;
        
        if (([tempObject[@"itemTax"] floatValue] != 0.0) && !([tempObject[@"itemTax"] floatValue] < 0.0)) {
            
            TotTax=[[tempObject valueForKey:@"itemQty"] floatValue]*[tempObject[@"itemTax"] floatValue];
            
            
            itemsDataDict[@"ItemTaxAmount"] = [NSString stringWithFormat:@"%f",TotTax];
        } else {
            itemsDataDict[@"ItemTaxAmount"] = @"0.0";
        }
        itemsDataDict[@"TotalItemAmount"] = [NSString stringWithFormat:@"%.2f",[[tempObject valueForKey:@"itemQty"] intValue]*[tempObject[@"itemPrice"] floatValue]+TotTax];
        
        itemsDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        
        if (![[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"] isEqual:@""]) {
            if ([[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"] count] > 0) {
                NSMutableArray * itemRecptTaxarray = [[NSMutableArray alloc] init];
                for (int z=0; z<[[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"] count]; z++) {
                    NSMutableDictionary * tempTaxItem = [NSMutableDictionary dictionaryWithDictionary:[tenderReciptDataAry[i] valueForKey:@"ItemTaxDetail"][z]];
                    tempTaxItem[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
                    tempTaxItem[@"ItemCode"] = [tempObject valueForKey:@"itemId"];
                    tempTaxItem[@"TaxId"] = [tempTaxItem valueForKey:@"TaxId"];
                    tempTaxItem[@"TaxPercentage"] = [tempTaxItem valueForKey:@"TaxPercentage"];
                    tempTaxItem[@"TaxAmount"] = [tempTaxItem valueForKey:@"TaxAmount"];
                    //   [tempTaxItem setObject:[tempTaxItem valueForKey:@"ItemTaxAmount"] forKey:@"ItemTaxAmount"];
                    NSString *strTaxAmount=[NSString stringWithFormat:@"%f",[[tempObject valueForKey:@"itemQty"] intValue] *[[tempTaxItem valueForKey:@"ItemTaxAmount"] floatValue]];
                    tempTaxItem[@"ItemTaxAmount"] = strTaxAmount;
                    tempTaxItem[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
                    
                    [itemRecptTaxarray addObject:tempTaxItem];
                }
                itemsDataDict[@"ItemTaxDetail"] = itemRecptTaxarray;
            } else {
                itemsDataDict[@"ItemTaxDetail"] = @"";
            }
        } else {
            itemsDataDict[@"ItemTaxDetail"] = @"";
        }
        
        
        if (tempObject[@"InvoiceVariationdetail"])
        {
            NSMutableArray * variationDetail = tempObject[@"InvoiceVariationdetail"];
            for (int iVar = 0; iVar < variationDetail.count; iVar++)
            {
                NSMutableDictionary *variatonDict = variationDetail[iVar];
                variatonDict[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
            }
            itemsDataDict[@"InvoiceVariationdetail"] = variationDetail;
        }
        else
        {
            itemsDataDict[@"InvoiceVariationdetail"] = @"";
        }
        
        
        float retailAmount = [tempObject[@"itemPrice"] floatValue];
        float variationAmount = [tempObject[@"TotalVarionCost"] floatValue];
        
        itemsDataDict[@"VariationAmount"] = [NSString stringWithFormat:@"%f", variationAmount];
        itemsDataDict[@"RetailAmount"] = [NSString stringWithFormat:@"%f", retailAmount];
        itemsDataDict[@"UnitQty"] = @"0";
        itemsDataDict[@"UnitType"] = @"";
        itemsDataDict[@"ItemMemo"] = tempObject[@"Memo"];
        
        
        [invoiceItemDetail addObject:itemsDataDict];
    }
    return invoiceItemDetail;
}*/


-(NSMutableArray *)reciptDataAryForBillOrder
{
    NSMutableArray *reciptArray1 = [[NSMutableArray alloc]init];
    
    if (self.restaurantOrderTenderObjectId == nil) {
        if (self.paymentData.isVoidForInvoice == TRUE) {
            if (self.paymentData.receiptDataArray.count > 0) {
                return self.paymentData.receiptDataArray;
            }
        }
        
        NSSortDescriptor *sorting = [[NSSortDescriptor alloc]initWithKey:@"itemIndex" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sorting];
        NSArray *reciptArray = [reciptArray1 sortedArrayUsingDescriptors:sortDescriptors];
        
        return [reciptArray mutableCopy];
    }
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderTenderObjectId];
    NSPredicate *resturantPrintPredicate = [NSPredicate predicateWithFormat:@"isCanceled = %@ ",@(FALSE)];
    NSArray *filterRestaurantBillArray = [restaurantOrder.restaurantOrderItem.allObjects filteredArrayUsingPredicate:resturantPrintPredicate];
    for (RestaurantItem *restaurantItem in filterRestaurantBillArray) {
        NSDictionary *billDictionaryAtIndexPath  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail];
        [reciptArray1 addObject:billDictionaryAtIndexPath];
    }
    [privateManageobjectContext reset];
    
    
    NSSortDescriptor *sorting = [[NSSortDescriptor alloc]initWithKey:@"itemIndex" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sorting];
    NSArray *reciptArray = [reciptArray1 sortedArrayUsingDescriptors:sortDescriptors];
    
    return [reciptArray mutableCopy];
    
//    return reciptArray1;
}

-(BOOL)isCreditcardSwipeForThisTransaction
{
    BOOL iscreditCardSwiped = FALSE;
    
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            {
                float actualAmount = paymentModeItem.actualAmount.floatValue ;
                float calCulatedAmount =  paymentModeItem.calculatedAmount.floatValue ;
                if (actualAmount == 0 )
                {
                    actualAmount = calCulatedAmount;
                }
                
                if (actualAmount != 0 )
                {
                    NSString *isCreditCardSwipeString = [paymentModeItem isCreditCardSwipe];
                    if ([isCreditCardSwipeString isEqualToString:@"1"])
                    {
                        iscreditCardSwiped = TRUE;
                        break;
                    }
                }
            }
        }
    }
    return iscreditCardSwiped;
}

-(void)cardProcessingDidCancel:(BOOL)isPartiallyApprovedTransaction
{
    if (self.rmsDbController.isVoidTrasnaction == TRUE) {
        _btnClose.enabled = NO;
        _btnClose.userInteractionEnabled = NO;
        return;
    }
    
    if (self.tenderType.length >0) {
        [self btnCloseclick:nil];
    }
    else
    {
        if ([self isCreditcardSwipeForThisTransaction] == TRUE)
        {
            _btnContinueEBT.hidden = YES;
            _btnAdjustEBT.hidden = YES;

        }
                
//        if(([self.paymentData totalCollection] + self.paymentData.balanceAmount - self.paymentData.billAmount) > 0.009)

        if (isPartiallyApprovedTransaction == TRUE) {
            [self updateTenderStatus];
            self.paxVoidButton.hidden = NO;
            self.btnClose.enabled = NO;
        }
        
        NSDictionary *changeDueMessageDictionary = @{
                                                     @"Tender":@"CreditCardProcessing",
                                                     @"TenderSubTotals":self.dictAmoutInfo,
                                                     @"ChangeDue":[self formatedTextForAmount:-self.paymentData.balanceAmount],
                                                     @"ShowTender":[self formatedTextForAmount:self.paymentData.totalCollection],
                                                     @"Total":[self formatedTextForAmount:self.paymentData.billAmount],
                                                     @"CreditCardMessage":@"Card Processing canceled",
                                                     @"CreditCardStep":@(CreditCardProcessingStepCanceled)
                                                     };
        [self.crmController writeDictionaryToCustomerDisplay:changeDueMessageDictionary];
    }
}
-(void)cardProcessingDidFail
{
    NSDictionary *changeDueMessageDictionary = @{
                                                 @"Tender":@"CreditCardProcessing",
                                                 @"TenderSubTotals":self.dictAmoutInfo,
                                                 @"ChangeDue":[self formatedTextForAmount:-self.paymentData.balanceAmount],
                                                 @"ShowTender":[self formatedTextForAmount:self.paymentData.totalCollection],
                                                 @"Total":[self formatedTextForAmount:self.paymentData.billAmount],
                                                 @"CreditCardMessage":@"Card Processing failed",
                                                 @"CreditCardStep":@(CreditCardProcessingStepFailed)
                                                 };
    [self.crmController writeDictionaryToCustomerDisplay:changeDueMessageDictionary];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Transaction process is not Completed please change your payment type" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    
    [_tblPaymentData reloadData];
}

-(void)displayPrintRetryAlert :(NSString *)message
{
    [self stopWatchDogTimer];
    TenderProcessManager * __weak myWeakReference = self.tenderProcessManager;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        self.tenderProcessManager.currentStep--;
        [myWeakReference performNextStep];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference performNextStep];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}
-(void)displayPassPrintRetryAlert :(NSString *)message
{
    [self stopWatchDogTimer];
    TenderViewController * __weak myWeakReference = self;
    TenderProcessManager * __weak myWeakReferenceProcessManager = self.tenderProcessManager;

    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference printNextPass];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [myWeakReferenceProcessManager performNextStep];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(void)displayManualCardPrintReceiptRetryAlert :(NSString *)message
{
    [self stopWatchDogTimer];
    TenderViewController * __weak myWeakReference = self;
    TenderProcessManager * __weak myWeakReferenceProcessManager = self.tenderProcessManager;

    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference processNextCardReceipt];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [myWeakReferenceProcessManager performNextStep];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(void)displayGiftCardPrintReceiptRetryAlert :(NSString *)message
{
    [self stopWatchDogTimer];
    TenderViewController * __weak myWeakReference = self;
    TenderProcessManager * __weak myWeakReferenceProcessManager = self.tenderProcessManager;
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference performNextGiftCardPrintProcess];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [myWeakReferenceProcessManager performNextStep];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(void)displayHouseChargePrintReceiptRetryAlert :(NSString *)message
{
    [self stopWatchDogTimer];
    TenderViewController * __weak myWeakReference = self;
    TenderProcessManager * __weak myWeakReferenceProcessManager = self.tenderProcessManager;
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference printHouseChargeReceipt:FALSE];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [myWeakReferenceProcessManager performNextStep];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}


-(void)displayOpenCashDrawerRetryAlert:(NSString *)message
{
    TenderViewController * __weak myWeakReference = self;
    TenderProcessManager * __weak myWeakReferenceProcessManager = self.tenderProcessManager;

    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference kickCashDrawer];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        self.printJobCount--;
        [myWeakReferenceProcessManager performNextStep];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}


// Signature Receipt

-(void)launchSignatureCapture
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignatureViewController *signatureDashBoard = [storyBoard instantiateViewControllerWithIdentifier:@"SignatureDashBoard"];
    signatureDashBoard.delegate = self;
   
    NSMutableDictionary *signDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *arraycardInfo = [self creditCardInformation];
    signDict[@"CardInfo"] = arraycardInfo;
    NSArray *tipInfo = [self fetchTipFromLocalDatabase];
    signDict[@"TipInfo"] = tipInfo;
    signDict[@"AmountInfo"] = self.dictAmoutInfo;
    signatureDashBoard.signatureDataDict = signDict;
    signatureDashBoard.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:signatureDashBoard animated:YES completion:Nil];
}


-(NSMutableArray *)fetchTipFromLocalDatabase
{
    NSMutableArray *tipDataBaseArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    if (self.tipSetting.boolValue == FALSE) {
        return tipDataBaseArray;
    }
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TipPercentageMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    NSInteger buttonTag  = 10001;
    for (TipPercentageMaster *tipPercentageMaster in resultSet)
    {
        NSMutableDictionary *tipPercentageMasterDict = [[NSMutableDictionary alloc]init];
        tipPercentageMasterDict[@"TipsPercentage"] = tipPercentageMaster.tipPercentage;
        
        CGFloat tipCalculatedAmount = self.paymentData.billAmount * tipPercentageMaster.tipPercentage.floatValue * 0.01;
        tipPercentageMasterDict[@"TipsAmount"] = [NSString stringWithFormat:@"%.2f",tipCalculatedAmount];
        tipPercentageMasterDict[@"buttonTag"] = [NSString stringWithFormat:@"%ld",(long)buttonTag];
        [tipDataBaseArray addObject:tipPercentageMasterDict];
        buttonTag++;
    }
    return tipDataBaseArray;
    
}

// Signature Receipt for Customer Display

-(void)launchSignatureCaptureforCustomerDisplay
{
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
    dictTemp[@"SignatureView"] = @"1";
    NSMutableArray *arraycardInfo = [self creditCardInformation];
    dictTemp[@"cardInfo"] = arraycardInfo;
    NSArray *tipInfo = [self fetchTipFromLocalDatabase];
    dictTemp[@"tipInfo"] = tipInfo;
    dictTemp[@"AmountInfo"] = self.dictAmoutInfo;
    [self.crmController writeDictionaryToCustomerDisplay:dictTemp];
    [self setDateforAlert];
    self.crmController.tenderView=[[NSMutableDictionary alloc]init];
    (self.crmController.tenderView)[@"TenderView"] = self;
    
   
    viewsignAlert = [[UIViewController alloc]init];
    viewsignAlert.view = _customSignatureAlert;
    
    _lblAccountNo.text = [NSString stringWithFormat:@"Account No : %@", [arraycardInfo.firstObject valueForKey:@"AccNo"]];
    
    if([[arraycardInfo.firstObject valueForKey:@"CardHolderName"]isEqualToString:@""])
    {
        _lblcardholderName.text = @"Name : N/A";
    }
    else
    {
        _lblcardholderName.text = [NSString stringWithFormat:@"Name : %@", [arraycardInfo.firstObject valueForKey:@"CardHolderName"]];
    }
    
    _lblAuthCodeTemp.text = [NSString stringWithFormat:@"AuthCode : %@", [arraycardInfo.firstObject valueForKey:@"AuthCode"]];
    
    viewsignAlert.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:viewsignAlert animated:YES completion:Nil];
}

- (void)signatureViewController:(SignatureViewController *)viewController didSign:(NSData *)signatur signature:(UIImage *)signatureImage withCustomerDisplayTipAmount:(CGFloat )tips
{
    if (viewController == nil) {
        NSDictionary *signatureDictionary = @{
                                              @"SignatureRecievedStatus":@"Signature Image Recieved",
                                              };
        [self.crmController writeDictionaryToCustomerDisplay:signatureDictionary];
    }
 //   self.customerSignatureImage = signatureImage;
    customerDiplayTipAmount = tips;
    [self.tenderProcessManager performNextStep];
    [viewsignAlert dismissViewControllerAnimated:TRUE completion:^{}];
    self.crmController.tenderView=nil;
}


- (void) manualReceipt
{
    BOOL isApplicable = [self isSpecOptionApplicableAfterCreditCard:SPEC_PRINT_RECIPT];
    if(!isApplicable){
        [self setStatusmessage:@"Printing Cards Receipt" withWarning:FALSE];
        [self cardPrintReciept];
    }
    else{
        [self.tenderProcessManager performNextStep];
    }
    //    [self.tenderProcessManager performNextStep];
}

- (void)restartWatchDogTimer {
    [self stopWatchDogTimer];
    watchDogTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(onWatchDogTimer:) userInfo:nil repeats:NO];
}

- (NSString*)currentStepName :(TENDER_PROCESS_STEPS )step{
    NSString *currentStep;
    
    switch (step) {
        case TP_BEGIN:
            currentStep = @"TP_BEGIN";
            break;
      
        case TP_CHECK_HOUSE_CHARGE_DETAILS:
            currentStep = @"TP_CHECK_HOUSE_CHARGE_DETAILS";
            break;
            
        case TP_CHECK_GIFT_CARD_DETAIL:
            currentStep = @"TP_CHECK_GIFT_CARD_DETAIL";
            break;
      
        case TP_CHECK_CARD_PAYMENT_DETAIL:
            currentStep = @"TP_CHECK_CARD_PAYMENT_DETAIL";
            break;
            
        case TP_PROCESS_CARDS:
            currentStep = @"TP_PROCESS_CARDS";
            break;
            
        case TP_CAPTURE_SIGNATURE:
            currentStep = @"TP_CAPTURE_SIGNATURE";
            break;
            
        case TP_OPENCASH_DRAWER:
            currentStep = @"TP_OPENCASH_DRAWER";
            break;
            
        case TP_PROCESS_CHANGEDUE:
            currentStep = @"TP_PROCESS_CHANGEDUE";
            break;
            
        case TP_PROCESS_CARDSRECIPTPRINT:
            currentStep = @"TP_PROCESS_CARDSRECIPTPRINT";
            break;
            
        case TP_CALL_SERVICE:
            currentStep = @"TP_CALL_SERVICE";
            break;
            
        case TP_PROCESS_COUSTMERRECIPETPRINT:
            currentStep = @"TP_PROCESS_COUSTMERRECIPETPRINT";
            break;
            
        case TP_PRINT_RECEIPT_PROMT:
            currentStep = @"TP_PRINT_RECEIPT_PROMT";
            break;
            
        case TP_PROCESS_RECEIPT:
            currentStep = @"TP_PROCESS_RECEIPT";
            break;
        case TP_PRINT_PASS:
            currentStep = @"TP_PRINT_PASS";
            break;

            
        case TP_GASPUMP_PREPAY_PROCESS:
            currentStep = @"TP_GASPUMP_PREPAY_PROCESS";
            break;
            
        case TP_DONE:
            currentStep = @"TP_DONE";
            break;
            
        case TP_FINISH:
            currentStep = @"TP_FINISH";
            break;
            
        case TP_TRANSACTION_DECLINED:
            currentStep = @"TP_TRANSACTION_DECLINED";
            break;
            
        default:
            currentStep = [NSString stringWithFormat:@"Current step = %d", self.tenderProcessManager.currentStep];
            break;
    }
    
    return currentStep;
}

- (void)callWatchDogTimerServiceWithStepName:(NSString *)currentStep {
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    param[@"receiptarray"] = currentStep;
    
    param[@"registerid"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    
    
    param[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    [param setValue:strDateTime forKey:@"currentDatetime"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self resonseSendBillDataWatchDogResponse:response error:error];
    };
    
    self.sendBillDataWatchDogWC = [self.sendBillDataWatchDogWC initWithRequest:KURL actionName:WSM_INSERT_MISSED_INVOICE_DETAIL params:param completionHandler:completionHandler];
    
}

- (void)resonseSendBillDataWatchDogResponse:(id)response error:(NSError *)error {
    
}


- (void)onWatchDogTimer:(NSTimer *)timer {
    [self stopWatchDogTimer];
    
    
    NSString *currentStep = [self currentStepName:self.tenderProcessManager.currentStep];
    
    [self callWatchDogTimerServiceWithStepName:currentStep];
}

- (void)stopWatchDogTimer {
    [watchDogTimer invalidate];
    watchDogTimer = nil;
}

-(void)setDateforAlert{
    NSDate* date = [NSDate date];
    
    //Create the dateformatter object
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    //Set the required date format
    formatter.dateFormat = @"MMMM dd, yyyy";
    
    //Get the string date
    NSString* str = [formatter stringFromDate:date];
    _lblCustSingAlert.text = str;
}


-(IBAction)signeHereClick:(id)sender{
    
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
    dictTemp[@"SignatureView"] = @"0";
    
    [self.crmController writeDictionaryToCustomerDisplay:dictTemp];
    [viewsignAlert dismissViewControllerAnimated:TRUE completion:^{
        [self launchSignatureCapture];
    }];
}

-(IBAction)signatureViewManualClick:(id)sender
{    
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
    dictTemp[@"SignatureView"] = @"0";
    [self.crmController writeDictionaryToCustomerDisplay:dictTemp];
    [self manualReceipt];
    [viewsignAlert dismissViewControllerAnimated:TRUE completion:^{}];
    self.crmController.tenderView=nil;
}

-(IBAction)rcdNormalScreen:(id)sender
{
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
    dictTemp[@"fullscreen"] = @"0";
    [self.crmController writeDictionaryToCustomerDisplay:dictTemp];
}

-(void)stopChangeDueTimer
{
    [changeDueTimer invalidate];
    changeDueTimer = nil;
}


// Himanshu
// Tip Button function
-(IBAction)tipsButtonClicked:(id)sender
{
    if(_uvTenderView.hidden == NO && singleTapChangeDue != nil )
    {
        [self stopChangeDueTimer];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        tipsAdjustmentVC = [storyBoard instantiateViewControllerWithIdentifier:@"TipsAdjustmentVC"];
        tipsAdjustmentVC.billAmountForTipCalculation = self.paymentData.billAmount;
        tipsAdjustmentVC.paymentTypeArray = [self getPaymentArrayOfSelectedPaymentType];
        tipsAdjustmentVC.tipsAdjustmentVcDelegate = self;
        tipsAdjustmentVC.view.frame = self.view.bounds;
        [self.view addSubview:tipsAdjustmentVC.view];
    }
    else
    {
       // [self.view addSubview:_tipsView];
        _tipsView.hidden = NO;
        NSString *identiFier = @"TipsView";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        tipsVC = [storyBoard instantiateViewControllerWithIdentifier:identiFier];
        tipsVC.billAmountForTipCalculation = self.paymentData.billAmount;
        tipsVC.tipsSelectionDeletage = self;
        tipsVC.view.frame = _tipsView.bounds;
        [_tipsView addSubview:tipsVC.view];
        [self.view bringSubviewToFront:_tipsView];
    }
}

-(void)didSelectTip:(CGFloat)tipAmount
{
    _tipsView.hidden = YES;
    //[_tipsView removeFromSuperview];
    [tipsVC.view removeFromSuperview];
    self.paymentData.tipAmount = tipAmount;
    [self setRoundValueForBillAmount:self.paymentData.
     billAmount + tipAmount];
    
    [self updateTenderStatus];
}

-(void)didCancelTip
{
    _tipsView.hidden = YES;
    [tipsVC.view removeFromSuperview];
   // [_tipsView removeFromSuperview];
}

-(void)didRemoveTip
{
    _tipsView.hidden = YES;
  //  [_tipsView removeFromSuperview];
    [tipsVC.view removeFromSuperview];
    self.paymentData.tipAmount = 0.00;
    [self setRoundValueForBillAmount:self.paymentData.billAmount];
    [self updateTenderStatus];
}


-(NSMutableArray *)getPaymentArrayOfSelectedPaymentType
{
    
    NSMutableArray *paymentArray = [[NSMutableArray alloc]init];
    
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            if (paymentModeItem == nil)
            {
                continue;
            }
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
            float displayAmount = paymentModeItem.displayAmount.floatValue;
            
            if (actualAmount == 0 )
            {
                actualAmount = calCulatedAmount;
                if (actualAmount == 0)
                {
                    actualAmount = displayAmount;
                }
            }

            
            NSMutableDictionary *paymentDict = [[NSMutableDictionary alloc]init];
            paymentDict[@"PayId"] = paymentModeItem.paymentId;
            paymentDict[@"CardIntType"] = paymentModeItem.paymentType;
            paymentDict[@"PaymentName"] = paymentModeItem.paymentName;
            paymentDict[@"TransactionNo"] = [paymentModeItem.paymentModeDictionary valueForKey:@"TransactionNo"];
            paymentDict[@"CardHolderName"] = [paymentModeItem.paymentModeDictionary valueForKey:@"CardHolderName"];
            paymentDict[@"ExpireDate"] = [paymentModeItem.paymentModeDictionary valueForKey:@"ExpireDate"];
            paymentDict[@"AccNo"] = [paymentModeItem.paymentModeDictionary valueForKey:@"AccNo"];
            paymentDict[@"CardType"] = [paymentModeItem.paymentModeDictionary valueForKey:@"CardType"];
            paymentDict[@"BillAmount"] = [NSString stringWithFormat:@"%.2f",actualAmount];
            paymentDict[@"TipsAmount"] = [paymentModeItem.paymentModeDictionary valueForKey:@"TipsAmount"];
            [paymentArray addObject:paymentDict];
        }
    }
    return paymentArray;
}


-(void)addTipAtPaymentTypeWithDetail:(NSDictionary *)tipCreditCardDictionary withTipAmount:(CGFloat )tipAmount
{
    selectedTipDictionary = tipCreditCardDictionary;
    [tipsAdjustmentVC.view removeFromSuperview];
    
    NSString *transctionNo = [tipCreditCardDictionary valueForKey:@"TransactionNo"];
    
    NSString *transctionServerForSpecOption = [NSString stringWithFormat:@"%@",[self transctionServerForSpecOptionforPaymentId:[[selectedTipDictionary valueForKey:@"PayId"] integerValue]]];
    
    
    if (transctionNo.length > 0 && [[tipCreditCardDictionary valueForKey:@"CardIntType"] isEqualToString:@"Credit"]) {
        
        if([transctionServerForSpecOption isEqualToString:@"RAPID CONNECT"]){
            
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
            [self tipAdjustMentAfterTender:dictParam];
            
        }
        else{
            [self processTipToBridgePay:tipAmount withTransactionNo:transctionNo];
        }
        
    }
    else
    {
        [self adjustTipInLocalDataBasewithTipAmount:tipAmount withTipDictionary:tipCreditCardDictionary withTransctionNo:@""];
    }

}
// Hiten Changes

- (void)tipAdjustMentAfterTender:(NSMutableDictionary *)paramValue
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self tipAdjustmentAfterTenderResponse:response error:error];
        });
    };
    
    self.customerTipAdjustmentCallWebservice = [self.customerTipAdjustmentCallWebservice initWithAsyncRequest:KURL_PAYMENT actionName:WSM_RAPID_SERVER_TIP_ADJUSTMENT_PROCESS params:paramValue asyncCompletionHandler:asyncCompletionHandler];
    
}

// Hiten Changes
// Tip Adjustment After Tender (From Rapid Server Response)

-(void)tipAdjustmentAfterTenderResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        
        if (response != nil) {
            if ([response isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *dictResponse = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if ([dictResponse[@"RespMSG"]isEqualToString:@"Approved"])
                {
                    NSString *transcationNo = dictResponse[@"PNRef"];
                    [self adjustTipInLocalDataBasewithTipAmount:changeDueTipAmount withTipDictionary:selectedTipDictionary withTransctionNo:transcationNo];
                }
                else
                {
                    NSString *message = dictResponse[@"RespMSG"];
                    [_activityIndicator hideActivityIndicator];
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
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




- (DDXMLElement *)getValueFromXmlResponse:(NSString *)responseString string:(NSString *)string
{
  //  responseString = [responseString stringByReplacingOccurrencesOfString:@" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://TPISoft.com/SmartPayments/\"" withString:@""];
    
    responseString = [RmsDbController removeNameSpaceFromXml:responseString rootTag:@"Response"];
    DDXMLDocument *fuelTypeDocument = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
    DDXMLNode *rootNode = fuelTypeDocument.rootElement;
    NSString *responseStr = [NSString stringWithFormat:@"/Response/%@",string];
    NSArray *FuelNodes = [rootNode nodesForXPath:responseStr error:nil];
    DDXMLElement *fuelElement = FuelNodes.firstObject;
    return fuelElement;
}


-(void)responseTenderCreditCardTipAdjustmentResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        
        if (response != nil) {
            if ([response isKindOfClass:[NSString class]]) {
                DDXMLElement *RespMSGElement = [self getValueFromXmlResponse:response string:@"RespMSG"];
                if ([RespMSGElement.stringValue isEqualToString:@"Approved"])
                {
                    DDXMLElement *PNRefElement = [self getValueFromXmlResponse:response string:@"PNRef"];
                    NSString *transcationNo = PNRefElement.stringValue;
                    [self adjustTipInLocalDataBasewithTipAmount:changeDueTipAmount withTipDictionary:selectedTipDictionary withTransctionNo:transcationNo];
                    
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:RespMSGElement.stringValue buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
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
            [self responseTenderCreditCardTipAdjustmentResponse:response error:error];
        });
    };
    
    self.tipAdjustmentWebserviceConnection = [self.tipAdjustmentWebserviceConnection initWithAsyncRequestURL:url withDetailValues:transDetail asyncCompletionHandler:asyncCompletionHandler];

}


- (void)processTipAdjustment:(NSString *)url details:(NSString *)details withTipAmount:(float)tipAmount
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",@"ProcessCreditCard"]];
    changeDueTipAmount = tipAmount;
    [self processTipAdjustmentWithURl:url transctionDetail:details withTipAmount:tipAmount];
}


-(void)adjustTipInLocalDataBasewithTipAmount :(float)tipAmont withTipDictionary:(NSDictionary *)tipDictionary withTransctionNo:(NSString *)transActionNo
{
    changeDueTipAmount = tipAmont;
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:self.paymentData.strInvoiceNo forKey:@"RegInvoiceNo"];
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
    
//    CompletionHandler completionHandler = ^(id response, NSError *error) {
//        [self responseTipsTenderAdjustmentResponse:response error:error];
//    };
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseTipsTenderAdjustmentResponse:response error:error];
        });
    };
    
    self.tipsAdjustmentTenderWC = [self.tipsAdjustmentTenderWC initWithRequest:KURL actionName:WSM_TIP_ADJUSTMENT params:itemparam completionHandler:completionHandler];
    
}
-(void)responseTipsTenderAdjustmentResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                dispatch_async(dispatch_get_main_queue(),  ^{
                    [_tenderSubTotalView updateSubtotalViewWithTipAmount:changeDueTipAmount andWithCollectAmount:(self.paymentData).billAmount + changeDueTipAmount];
                });
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Tip Adjusted SuccessFully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error occured in Tip Adjustment Process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}


#pragma mark- BridgePayTipAdjustment

-(void)tipAdjustmentProcess
{
    
    tipAdjustmentDetail = [[NSMutableArray alloc] init];

    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            if (paymentModeItem == nil)
            {
                continue;
            }
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
            
            if (actualAmount == 0 )
            {
                actualAmount = calCulatedAmount;
            }
            
            if (actualAmount != 0 && [paymentModeItem.paymentType isEqualToString: @"Credit"])
            {
                if ([[paymentModeItem.paymentModeDictionary valueForKey:@"TransactionNo"] length] > 0 && paymentModeItem.customerDisplayTipAmount > 0)
                {
                    NSMutableDictionary *tipsAdjustmentDictionary = [[NSMutableDictionary alloc] init];
                    tipsAdjustmentDictionary[@"TipAmount"] = paymentModeItem.customerDisplayTipAmount;
                    tipsAdjustmentDictionary[@"TransactionNo"] = [paymentModeItem.paymentModeDictionary valueForKey:@"TransactionNo"];
                    tipsAdjustmentDictionary[@"PaymentModeItem"] = paymentModeItem;
                    tipsAdjustmentDictionary[@"TransactionServer"] = [paymentModeItem.paymentModeDictionary valueForKey:@"TransactionServer"];
                    [tipAdjustmentDetail addObject:tipsAdjustmentDictionary];
                }
            }
        }
    }
    if (tipAdjustmentDetail.count > 0) {
        [self performNextTipAdjustmentProcess];
    }
    else
    {
        [self.tenderProcessManager performNextStep];
    }
}


-(void)generateGiftCardPrintDetail
{
    
    giftCardPrintDetail = [[NSMutableArray alloc] init];
    
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            if (paymentModeItem == nil)
            {
                continue;
            }
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
            
            if (actualAmount == 0 )
            {
                actualAmount = calCulatedAmount;
            }
            
            if (actualAmount != 0 && [[paymentModeItem.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"RapidRMS Gift Card"])
            {
                NSString *isGiftCardApprovedCardNumber = [paymentModeItem isGiftCardApproved];
                if ([isGiftCardApprovedCardNumber isEqualToString:@"1"])
                {
                    NSPredicate *predicateForGiftCardNumber = [NSPredicate predicateWithFormat:@"GiftCardNumber == %@",paymentModeItem.giftCardNumber];
                    NSArray *giftCardNumberArray = [giftCardPrintDetail filteredArrayUsingPredicate:predicateForGiftCardNumber];
                    if (giftCardNumberArray.count > 0)
                    {
                        NSMutableDictionary *giftCardAlreadyDictionary = [giftCardNumberArray firstObject];
                       
                        NSMutableDictionary *giftCardPrintDetailDictionary = [[NSMutableDictionary alloc] init];
                        giftCardPrintDetailDictionary[@"GiftCardNumber"] = paymentModeItem.giftCardNumber;
                        NSNumber *giftCardAvailableBalance = @([giftCardAlreadyDictionary[@"GiftCardTotalBalance"] floatValue] -  actualAmount);
                        giftCardPrintDetailDictionary[@"GiftCardTotalBalance"] = giftCardAvailableBalance;
                        [giftCardPrintDetail addObject:giftCardPrintDetailDictionary];
                        
                        [giftCardPrintDetail removeObject:giftCardAlreadyDictionary];
                    }
                    else
                    {
                        NSMutableDictionary *giftCardPrintDetailDictionary = [[NSMutableDictionary alloc] init];
                        giftCardPrintDetailDictionary[@"GiftCardNumber"] = paymentModeItem.giftCardNumber;
                        NSNumber *giftCardAvailableBalance = @([paymentModeItem.giftCardBalanceAmount floatValue] -  actualAmount);
                        giftCardPrintDetailDictionary[@"GiftCardTotalBalance"] = giftCardAvailableBalance;
                        [giftCardPrintDetail addObject:giftCardPrintDetailDictionary];
                    }
                }
            }
        }
    }
    
    NSMutableArray *tenderReciptDataAry = [self reciptDataAryForBillOrder];
    NSPredicate *predicateForGiftCardItem = [NSPredicate predicateWithFormat:@"itemName == %@",@"RapidRMS Gift Card"];
    NSArray *giftCardItemArray = [tenderReciptDataAry filteredArrayUsingPredicate:predicateForGiftCardItem];
    for (NSDictionary *giftCardItemDictionary in giftCardItemArray) {
        NSMutableDictionary *giftCardPrintDetailDictionary = [[NSMutableDictionary alloc] init];
        giftCardPrintDetailDictionary[@"GiftCardNumber"] = giftCardItemDictionary[@"CardNo"];
        giftCardPrintDetailDictionary[@"GiftCardTotalBalance"] = giftCardItemDictionary[@"GiftCardTotalBalance"];
        [giftCardPrintDetail addObject:giftCardPrintDetailDictionary];
    }
    NSLog(@"giftCardPrintDetail = %@",giftCardPrintDetail);
    [self performNextGiftCardPrintProcess];
}


-(void)printHouseChargeReceipt:(BOOL)isSignature
{
    houseChargePrintDetail = [NSMutableArray array];
    
    NSMutableArray *paymentDetails = [[[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoicePaymentDetail"] firstObject];
    NSMutableArray *itemDetails = [[[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceItemDetail"] firstObject];
    
    NSPredicate *predicateForHouseChargeItem = [NSPredicate predicateWithFormat:@"ItemName == %@",@"HouseCharge"];
    NSArray *houseChargeItemArray = [itemDetails filteredArrayUsingPredicate:predicateForHouseChargeItem];
    
    NSPredicate *predicateForHouseChargePayment = [NSPredicate predicateWithFormat:@"CardType == %@",@"HouseCharge"];
    NSArray *houseChargePaymentArray = [paymentDetails filteredArrayUsingPredicate:predicateForHouseChargePayment];
    
    if (houseChargeItemArray.count > 0 || houseChargePaymentArray.count > 0  ) {
        NSMutableDictionary *houseChargeDictionary = [[NSMutableDictionary alloc]init];
        
        houseChargePrintDetail = [[NSMutableArray alloc] init];
        
        houseChargeDictionary[@"Custid"] = self.paymentData.rapidCustomerLoyalty.custId;
        houseChargeDictionary[@"CustName"] = self.paymentData.rapidCustomerLoyalty.customerName;
        houseChargeDictionary[@"CustEmail"] = self.paymentData.rapidCustomerLoyalty.email;
        houseChargeDictionary[@"CustContactNo"] = self.paymentData.rapidCustomerLoyalty.contactNo;
        houseChargeDictionary[@"AvailableBalance"] = [NSString stringWithFormat:@"%.2f",custBalanceAmount];
        houseChargeDictionary[@"CreditLimit"] = self.paymentData.rapidCustomerLoyalty.creditLimit;
        
        [houseChargePrintDetail addObject:houseChargeDictionary];
        
        
        [self printNextHouseCharge:isSignature];
        
    }
}

-(NSMutableArray *)getHouseChargeDetails{
    
    houseChargeArray = [[NSMutableArray alloc]init];
    NSMutableArray *paymentDetails = [[[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoicePaymentDetail"] firstObject];
    NSMutableArray *itemDetails = [[[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceItemDetail"] firstObject];
    
    NSPredicate *predicateForHouseChargeItem = [NSPredicate predicateWithFormat:@"ItemName == %@",@"HouseCharge"];
    NSArray *houseChargeItemArray = [itemDetails filteredArrayUsingPredicate:predicateForHouseChargeItem];
    
    NSPredicate *predicateForHouseChargePayment = [NSPredicate predicateWithFormat:@"CardType == %@",@"HouseCharge"];
    NSArray *houseChargePaymentArray = [paymentDetails filteredArrayUsingPredicate:predicateForHouseChargePayment];
    
    if (houseChargeItemArray.count > 0 || houseChargePaymentArray.count > 0  ) {
        NSMutableDictionary *houseChargeDictionary = [[NSMutableDictionary alloc]init];
        
        houseChargeDictionary[@"Custid"] = self.paymentData.rapidCustomerLoyalty.custId;
        houseChargeDictionary[@"CustName"] = self.paymentData.rapidCustomerLoyalty.customerName;
        houseChargeDictionary[@"CustEmail"] = self.paymentData.rapidCustomerLoyalty.email;
        houseChargeDictionary[@"CustContactNo"] = self.paymentData.rapidCustomerLoyalty.contactNo;
        houseChargeDictionary[@"AvailableBalance"] = [NSString stringWithFormat:@"%.2f",custBalanceAmount];
        houseChargeDictionary[@"CreditLimit"] = self.paymentData.rapidCustomerLoyalty.creditLimit;
        
        [houseChargeArray addObject:houseChargeDictionary];
        
    }
    return houseChargeArray;
}
-(void)printNextHouseCharge:(BOOL)isSignature{
    
    if (houseChargePrintDetail.count == 0) {
        [self.tenderProcessManager performNextStep];
        return;
    }
    NSString *portName     = @"";
    NSString *portSettings = @"";
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];

    NSMutableArray *masterDetails = [[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceMst"];
    NSString *receiptDate = [self invoiceRecieptDate:[[masterDetails.firstObject firstObject] valueForKey:@"Datetime"]];
    
    houseChargeReceiptPrint = [[HouseChargeReceiptPrint alloc]init];
    houseChargeReceiptPrint = [houseChargeReceiptPrint initWithPortName:portName portSetting:portSettings printData:houseChargePrintDetail withReceiptDate:receiptDate withIsSignature:isSignature];
    [houseChargeReceiptPrint printHouseChargeReceiptWithDelegate:self];
}

-(void)performNextGiftCardPrintProcess
{
    if (giftCardPrintDetail.count == 0) {
        [self.tenderProcessManager performNextStep];
        return;
    }
    
    NSString *portName     = @"";
    NSString *portSettings = @"";
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    NSMutableArray *masterDetails = [[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceMst"];
    NSString *receiptDate = [self invoiceRecieptDate:[[masterDetails.firstObject firstObject] valueForKey:@"Datetime"]];
    
    
    GiftCardReceiptPrint *giftCardReceiptPrint = [[GiftCardReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:giftCardPrintDetail.lastObject withReceiptDate:receiptDate];
    [giftCardReceiptPrint printGiftCardReceiptWithDelegate:self];
}

-(void)performNextTipAdjustmentProcess
{
    if (tipAdjustmentDetail.count == 0) {
        [self.tenderProcessManager performNextStep];
        return;
    }
    
    NSMutableDictionary *tipAdjustmentDictionary = tipAdjustmentDetail.lastObject;
    
    [self processCustomerDisplayTipToBridgePay:[[tipAdjustmentDictionary valueForKey:@"TipAmount"] floatValue] withTransactionNo:[tipAdjustmentDictionary valueForKey:@"TransactionNo"] withTransactionServer:[tipAdjustmentDictionary valueForKey:@"TransactionServer"]];


}

-(void)adjustCustomerDisplayTipAmountInBridgePay:(CGFloat )tipAmount
{
    NSString *transactionNo = @"";
    NSString *transactionServer = @"";
    
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            if (paymentModeItem == nil)
            {
                continue;
            }
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount = paymentModeItem.calculatedAmount.floatValue ;
            
            if (actualAmount == 0 )
            {
                actualAmount = calCulatedAmount;
            }
            
            if (actualAmount != 0 && [paymentModeItem.paymentType isEqualToString: @"Credit"])
            {
                if ([[paymentModeItem.paymentModeDictionary valueForKey:@"TransactionNo"] length] > 0)
                {
                    transactionNo = [paymentModeItem.paymentModeDictionary valueForKey:@"TransactionNo"];
                    transactionServer = [paymentModeItem.paymentModeDictionary valueForKey:@"TransactionServer"];
                }
            }
        }
    }
    
    [self processCustomerDisplayTipToBridgePay:tipAmount withTransactionNo:transactionNo withTransactionServer:transactionServer];
    
}

-(void)processCustomerDisplayTipToBridgePay:(float)tipAmount withTransactionNo:(NSString *)transctionNo withTransactionServer:(NSString *)strTransactionServer{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    if([strTransactionServer isEqualToString:@"RAPID CONNECT"]){
        
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
        [self tipAdjustMentforCustomer:dictParam];
        
    }
    else{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSDictionary *paymentDictionary = self.rmsDbController.paymentCardTypearray.firstObject;
            NSString *extData = [NSString stringWithFormat:@"<TipAmt>%.2f</TipAmt>",tipAmount];
            NSString *transDetails = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=&InvNum=&PNRef=%@&Zip=&Street=&CVNum=&ExtData=%@",[paymentDictionary valueForKey:@"Username"],[paymentDictionary valueForKey:@"password"],@"Adjustment",transctionNo,extData];
            [self processCustomerDisplayTipAdjustment:[paymentDictionary valueForKey:@"URL"] details:transDetails withTipAmount:tipAmount];
        });
    
    }
}

- (void)tipAdjustMentforCustomer:(NSMutableDictionary *)paramValue
{
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self tipAdjustmentforCustomerResponse:response error:error];
    };
    
    self.customerTipAdjustmentCallWebservice = [self.customerTipAdjustmentCallWebservice initWithAsyncRequest:KURL_PAYMENT actionName:WSM_RAPID_SERVER_TIP_ADJUSTMENT_PROCESS params:paramValue asyncCompletionHandler:asyncCompletionHandler];

}

-(void)tipAdjustmentforCustomerResponse:(id)response error:(NSError *)error{
    
    dispatch_async(dispatch_get_main_queue(),  ^{
        
        [_activityIndicator hideActivityIndicator];;

        if (response != nil) {
            if ([response isKindOfClass:[NSDictionary class]])
            {
                NSMutableDictionary *dictResponse = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                
                if ([dictResponse[@"RespMSG"]isEqualToString:@"Approved"])
                {
                    [self setCustomerDisplayTipAmountPaymentData:customerDiplayTipAmount];
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];;
                    
                    TenderViewController * __weak myWeakReference = self;
                    TenderProcessManager * __weak myWeakReferenceProcessManager = self.tenderProcessManager;

                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tipAdjustmentforCustomerResponse" object:nil];
                        
                        [myWeakReference adjustCustomerDisplayTipAmountInBridgePay:customerDiplayTipAmount];
                    };
                    
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        [myWeakReferenceProcessManager performNextStep];
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Tip is not adjusted. Do you want to retry?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                }

            }
        }
        else
        {
            [_activityIndicator hideActivityIndicator];;
            TenderViewController * __weak myWeakReference = self;
            TenderProcessManager * __weak myWeakReferenceProcessManager = self.tenderProcessManager;

            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tipAdjustmentforCustomerResponse" object:nil];
                
                [myWeakReference adjustCustomerDisplayTipAmountInBridgePay:customerDiplayTipAmount];
            };
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [myWeakReferenceProcessManager performNextStep];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Tip is not adjusted. Do you want to retry?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        }
        
    });
}

-(void)responseCustomerDisplayTipAdjustmentResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        
        [_activityIndicator hideActivityIndicator];
        
        if (response != nil) {
            if ([response isKindOfClass:[NSString class]]) {
                DDXMLElement *RespMSGElement = [self getValueFromXmlResponse:response string:@"RespMSG"];
                if ([RespMSGElement.stringValue isEqualToString:@"Approved"])
                {
                    NSDictionary *tipsAdjusmentDictionary = tipAdjustmentDetail.lastObject;
                    PaymentModeItem *paymentModeItem = (PaymentModeItem *)[tipsAdjusmentDictionary valueForKey:@"PaymentModeItem"];
                    if (paymentModeItem) {
                        paymentModeItem.isCustomerDiplayTipAdjusted = TRUE;
                        [self.paymentData addCustomerDisplayTipAmountAtForPaymentModeItem:paymentModeItem tipAmount:[[tipsAdjusmentDictionary valueForKey:@"TipAmount"] floatValue]];
                        dispatch_async(dispatch_get_main_queue(),  ^{
                            [_tenderSubTotalView updateSubtotalViewWithTipAmount:self.paymentData.totalTipAmountForBill andWithCollectAmount:self.paymentData.totalCollection];
                        });
                    }
                    [tipAdjustmentDetail removeLastObject];
                    [self performNextTipAdjustmentProcess];
                }
                else
                {
                    [_activityIndicator hideActivityIndicator];
                    
                    TenderViewController * __weak myWeakReference = self;
                    TenderProcessManager * __weak myWeakReferenceProcessManager = self.tenderProcessManager;

                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        [myWeakReferenceProcessManager performNextStep];
                    };
                    
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        [tipAdjustmentDetail removeLastObject];
                        [myWeakReference performNextTipAdjustmentProcess];
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Tip is not adjusted. Do you want to retry?" buttonTitles:@[@"Skip for this credit card",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
                }
            }
        }
        else
        {
            [_activityIndicator hideActivityIndicator];;
            TenderViewController * __weak myWeakReference = self;
            TenderProcessManager * __weak myWeakReferenceProcessManager = self.tenderProcessManager;

            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [myWeakReferenceProcessManager performNextStep];
            };
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [tipAdjustmentDetail removeLastObject];
                [myWeakReference performNextTipAdjustmentProcess];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Tip is not adjusted. Do you want to retry?" buttonTitles:@[@"Skip for this credit card",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
        }
    });
}

- (void)processCustomerDisplayTipAdjustment:(NSString *)url details:(NSString *)details withTipAmount:(float)tipAmount
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",@"ProcessCreditCard"]];
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseCustomerDisplayTipAdjustmentResponse:response error:error];
        });
    };
    
    self.customerTipAdjustmentWebserviceConnection = [self.customerTipAdjustmentWebserviceConnection initWithAsyncRequestURL:url withDetailValues:details asyncCompletionHandler:asyncCompletionHandler];
}
-(void)setCustomerDisplayTipAmountPaymentData:(CGFloat )tipAmount
{
    BOOL adjustmentDone = FALSE;
    for(int i = 0;i<self.paymentData.countOfPaymentModes && adjustmentDone == FALSE;i++)
    {
        NSArray *itemArrayAtIndex = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < itemArrayAtIndex.count && adjustmentDone == FALSE; j++)
        {
            PaymentModeItem *paymentModeItem  = itemArrayAtIndex[j];
            float actualAmount = paymentModeItem.actualAmount.floatValue ;
            float calCulatedAmount =  paymentModeItem.calculatedAmount.floatValue ;
            if (actualAmount == 0 )
            {
                actualAmount = calCulatedAmount;
            }
            if (actualAmount != 0 && [paymentModeItem.paymentType isEqualToString: @"Credit"])
            {
                if ([[paymentModeItem.paymentModeDictionary valueForKey:@"TransactionNo"] length] > 0)
                {
                    self.paymentData.lastSelectedPaymentTypeIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                    [self.paymentData setCustomerDisplayTipAmount :tipAmount];
                    [self.paymentData addTipAmountAtIndexpath:self.paymentData.lastSelectedPaymentTypeIndexPath tipAmount:tipAmount];
                    [_tenderSubTotalView updateSubtotalViewWithTipAmount:tipAmount andWithCollectAmount:self.paymentData.totalCollection];
                    adjustmentDone = TRUE;
                }
            }
        }
    }
    [self.tenderProcessManager performNextStep];
}

- (void)generatePassDetail
{
    NSMutableArray *tenderReciptDataAry = [self reciptDataAryForBillOrder];
    
    NSPredicate *predicateForItemTicket = [NSPredicate predicateWithFormat:@"IsTicket == %@",@(1)];
    NSArray *billItemArray = [tenderReciptDataAry filteredArrayUsingPredicate:predicateForItemTicket];
    filterItemTicketArray = [NSMutableArray array];
    
    int rowPostion = 1;
    int passCounter = 0;
    for (NSMutableDictionary *billDictionary in billItemArray) {
        NSInteger count = [[billDictionary valueForKey:@"itemQty"] integerValue];
        NSMutableArray *passData = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < count; i++) {
            passCounter++;
            NSMutableDictionary *passDictionary = [[NSMutableDictionary alloc]init];
            passDictionary[@"RowPosition"] = [NSString stringWithFormat:@"%d",rowPostion];
            passDictionary[@"ItemCode"] = billDictionary[@"itemId"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"MMdd";
            NSString *currentDateTime = [formatter stringFromDate:[NSDate date]];
            NSString *crdNumber = [NSString stringWithFormat:@"%@-%@%d",self.paymentData.strInvoiceNo,currentDateTime,passCounter];
            
            passDictionary[@"CRDNumber"] = crdNumber;
            passDictionary[@"QRCode"] = [NSUUID UUID].UUIDString;
            passDictionary[@"CustomerId"] = @"0";
            passDictionary[@"IsVoid"] = @"0";
            passDictionary[@"Remark"] = @"";
            passDictionary[@"ExpirationDay"] = [NSString stringWithFormat:@"%@",billDictionary[@"ExpirationDay"]];
            passDictionary[@"NoOfDay"] = [NSString stringWithFormat:@"%@",billDictionary[@"NoOfDay"]];
            passDictionary[@"InvoiceNo"] = self.paymentData.strInvoiceNo;
            passDictionary[@"ItemName"] = billDictionary[@"itemName"];
            [filterItemTicketArray addObject:passDictionary];
            [passData addObject:passDictionary];
        }
        rowPostion++;
        billDictionary[@"PassData"] = passData;
    }
    [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:tenderReciptDataAry];

}

-(void)passReceiptPrint
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self printNextPass];
    });
    
}

-(BOOL)isAplicableForPassReceiptPrint
{
    NSMutableArray *tenderReciptDataAry = [self reciptDataAryForBillOrder];

    BOOL isAplicableForPassReceiptPrint = FALSE;
    NSPredicate *predicateForItemTicket = [NSPredicate predicateWithFormat:@"IsTicket == %@",@(1)];
    NSArray *filterTicketArray = [tenderReciptDataAry filteredArrayUsingPredicate:predicateForItemTicket];
    if (filterTicketArray.count > 0) {
        isAplicableForPassReceiptPrint = TRUE;
    }
    return  isAplicableForPassReceiptPrint;
}

-(void)manualReceiptPrintProcess
{
    NSMutableArray *isManualReceiptApplicablePaymentId = [[NSMutableArray alloc] init];
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem * paymentModeItem = paymentSubArray[j];
            BOOL isCreditCardSwipe = [self.paymentData isCreditCardSwipedAtPaymentMode:paymentModeItem];
            if (paymentModeItem == nil) {
                continue;
            }
            if (paymentModeItem.manualReceipt == TRUE && isCreditCardSwipe == TRUE) {
                [isManualReceiptApplicablePaymentId addObject:paymentModeItem.paymentId];
            }
        }
    }
    
    if (isManualReceiptApplicablePaymentId.count > 0) {
        [self configureManualReceiptDetailWithArray:isManualReceiptApplicablePaymentId];
    }
    else
    {
        [self.tenderProcessManager performNextStep];
    }
}

-(void)configureManualReceiptDetailWithArray:(NSMutableArray *)manualReceiptDetail
{
    filterManualReceiptDetaiArray = [[NSMutableArray alloc] init];
    NSMutableArray *paymentDetail = [self.paymentData invoicePaymentdetail];
    NSSet *payIdSet = [NSSet setWithArray:manualReceiptDetail];
    for (NSNumber *paymentId in payIdSet) {
        NSPredicate *filterPaymentId = [NSPredicate predicateWithFormat:@"PayId = %d",paymentId.integerValue];
        NSArray *paymentDetailForPaymentId = [paymentDetail filteredArrayUsingPredicate:filterPaymentId];
        if (paymentDetailForPaymentId.count > 0) {
            for (NSDictionary *paymentDictionary in paymentDetailForPaymentId) {
                if (![[paymentDictionary valueForKey:@"SignatureImage"] isKindOfClass:[NSData class]] ) {
                    if ([[paymentDictionary valueForKey:@"SignatureImage"] length] == 0) {
                        [filterManualReceiptDetaiArray addObject:paymentDictionary];
                    }
                }
            }
        }
    }
    if (filterManualReceiptDetaiArray.count > 0) {
        [self processNextCardReceipt];
    }
    else
    {
        [self.tenderProcessManager performNextStep];
    }
}

-(void)processNextCardReceipt
{
    if (filterManualReceiptDetaiArray.count == 0) {
        [self.tenderProcessManager performNextStep];
        return;
    }
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self nextcardPrintRecieptWithDetail:filterManualReceiptDetaiArray.lastObject];
    });
    
}

-(void)nextcardPrintRecieptWithDetail:(NSDictionary *)paymentDetail
{
    NSMutableArray *paymentArray = [[NSMutableArray alloc] init];
    [paymentArray addObject:paymentDetail];
    
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    
    CardReceiptPrint *cardReceiptPrint;
    
    if ([[paymentDetail valueForKey:@"GatewayType"] isEqualToString:@"Pax"] )
    {
        NSDictionary *paxAdditionalFieldsDictionary = [self.rmsDbController objectFromJsonString:[paymentDetail valueForKey:@"GatewayResponse"]];
        if (paxAdditionalFieldsDictionary != nil) {
        if ([[paxAdditionalFieldsDictionary valueForKey:@"EntryMode"] integerValue] == Swipe) {
            cardReceiptPrint = [[PaxMagneticCardReceipt alloc] initWithPortName:portName portSetting:portSettings withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray receiptDate:nil];
        }
        else
        {
            cardReceiptPrint = [[PaxEMVCardReceipt alloc] initWithPortName:portName portSetting:portSettings withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray receiptDate:nil];
        }
        }
    }
    else
    {
        NSMutableArray *masterDetails = [[self.Payparam valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceMst"];
        NSString *receiptDate = [self invoiceRecieptDate:[[masterDetails.firstObject firstObject] valueForKey:@"Datetime"]];

        cardReceiptPrint = [[CardReceiptPrint alloc] initWithPortName:portName portSetting:portSettings withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:self.tipsPercentArray receiptDate:receiptDate];
    }

    [cardReceiptPrint printCardReceiptForInvoiceNo:self.paymentData.strInvoiceNo withDelegate:self];

}

#pragma mark-
#pragma mark Add Customer Flow

- (IBAction)btnCustomerClick:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustomerViewController *customerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CustomerViewController"];
    customerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    customerVC.customerSelectionDelegate = self;
    [self.navigationController pushViewController:customerVC animated:YES];
}

-(void)didCancelCustomerSelection
{
   // [customerVC.view removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];

}


-(void)didSelectCustomerWithDetail:(RapidCustomerLoyalty *)rapidCustomerLoyaltyDetail customerDictionary:(NSDictionary *)customerDictionary withIsCustomerFromHouseCharge:(BOOL)isCustomerFromHouseCharge withIscollectPay:(BOOL)isCollectPay;
{
    self.paymentData.rapidCustomerLoyalty = rapidCustomerLoyaltyDetail;
    _customerNameLabel.text = rapidCustomerLoyaltyDetail.customerName;
       [_removeCustomerButton setHidden:NO];
}

- (IBAction)RemoveCustomer:(id)sender
{
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self hideCustomerView];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to remove this customer?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(void)hideCustomerView{
    _customerNameLabel.text = @"";
    [_removeCustomerButton setHidden:YES];
    self.tenderRapidCustomerLoyalty = nil;
    [self updateReceiptArrayInDatabase:[self reciptDataAryForBillOrder]];
}


#pragma mark - Continue Without EBT

-(void)displayEBTAdjustmentVCWithEbtArray:(NSMutableArray *)ebtArray
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrPopUp" bundle:nil];
    EBTAdjustmentVC *ebtAdjustmentVC = [storyBoard instantiateViewControllerWithIdentifier:@"EBTAdjustmentVC"];
    ebtAdjustmentVC.reciptDataAry = ebtArray;
    ebtAdjustmentVC.ebtAdjustmentVCDelegate = self;
    ebtAdjustmentVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:ebtAdjustmentVC animated:TRUE completion:^{
    }];

}
-(void)didRemoveEbtForItems:(NSMutableArray *)removeEbtItems
{
    NSMutableArray *tenderReciptDataAry = [self reciptDataAryForBillOrder];
    
    for (NSDictionary *removeEbtItem in removeEbtItems) {
        for (NSMutableDictionary *receiptDictionary in tenderReciptDataAry) {
            if ([receiptDictionary[@"itemId"] integerValue] == [removeEbtItem[@"itemId"] integerValue] && [[receiptDictionary valueForKey:@"itemIndex"] isEqualToNumber:[removeEbtItem valueForKey:@"itemIndex"]]) {
                BOOL isEbtApplicable = [[receiptDictionary valueForKey:@"EBTApplicable"] boolValue];
                if (isEbtApplicable) {
                    receiptDictionary[@"EBTApplied"] = @(0);
                }
                Item *anItem = [self fetchItemWithItemId:receiptDictionary[@"itemId"]];
                NSMutableArray *taxDetail = [self getTaxDetailForItem:anItem];
                if (taxDetail != nil) {
                    receiptDictionary[@"ItemTaxDetail"] = taxDetail;
                }
            }
        }
    }
    [self updateReceiptArrayInDatabase:tenderReciptDataAry];
}


-(IBAction)adjustEBTbutton:(id)sender
{
    NSMutableArray *receiptDataArrayCopy = [self reciptDataAryForBillOrder];
    NSPredicate *ebtFilterPredicate = [NSPredicate predicateWithFormat:@"EBTApplicable = %d AND EBTApplied = %d",1 , 1];
    NSMutableArray *ebtDataArray = [[receiptDataArrayCopy filteredArrayUsingPredicate:ebtFilterPredicate] mutableCopy];
    if (ebtDataArray.count > 0) {
        [self displayEBTAdjustmentVCWithEbtArray:ebtDataArray];
    }
    else
    {
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            _btnContinueEBT.hidden = YES;
            _btnAdjustEBT.hidden = YES;
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No EBT Item Found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
   
}

-(IBAction)continueWithOutEBTbutton:(id)sender
{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self continueWithOutEBT];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Would you like to continue without EBT for All Items?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
}
-(void)updateReceiptArrayInDatabase:(NSMutableArray *)tenderReciptDataAry
{
    [self.paymentData.rcrBillSummary taxCalculateForReciptDataArray:tenderReciptDataAry withManagedObjectContext:self.managedObjectContext];
    [self.paymentData.rcrBillSummary updateBillSummrayWithDetail:tenderReciptDataAry];
    [self updateBillSummaryWithReceiptArray:tenderReciptDataAry];
    [self GetPaymentData];
    [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:tenderReciptDataAry];
    
}

-(BOOL)shouldEBTRestrictedForBill
{
    BOOL shouldEBTRestrictedForBill = FALSE;
    NSMutableArray *reciptArray = [self reciptDataAryForBillOrder];
    for (NSMutableDictionary *dict in reciptArray)
    {
        if ([dict[@"ItemBasicPrice"]floatValue] < 0 || [[dict[@"item"]valueForKey:@"isCheckCash"] boolValue] == TRUE || [[dict[@"item"]valueForKey:@"isDeduct"] boolValue] == TRUE)
        {
            shouldEBTRestrictedForBill = TRUE;
            break;
        }
        
    }
    return shouldEBTRestrictedForBill;
    
}

-(CGFloat )applyEbtForBillCalculator
{
    CGFloat ebtBillCalculator = 0.00;
    
    self.paymentData.billAmountCalculator.isEBTApplicaleForBill = TRUE;
    NSMutableArray *tenderReciptDataAry = [self reciptDataAryForBillOrder];
    
    for (NSMutableDictionary *receiptDictionary in tenderReciptDataAry) {
        if ([[receiptDictionary valueForKey:@"EBTApplicable"] boolValue] == TRUE)
        {
            _btnContinueEBT.hidden = NO;
            _btnAdjustEBT.hidden = NO;

            receiptDictionary [@"EBTApplied"] = @(TRUE);
            receiptDictionary[@"ItemTaxDetail"] = @"";
            receiptDictionary[@"TotalTaxPercentage"] = @"0.00";
            receiptDictionary[@"itemTax"] = @(0.0);
        }
        receiptDictionary [@"EBTApplicableForDisplay"] = @(FALSE);
    }
    [self updateReceiptArrayInDatabase:tenderReciptDataAry];
    
    ebtBillCalculator = self.paymentData.rcrBillSummary.totalEBTAmount.floatValue;

    return ebtBillCalculator;
}

-(void)continueWithOutEBT
{
    _btnContinueEBT.hidden = YES;
    _btnAdjustEBT.hidden = YES;

    self.paymentData.billAmountCalculator.isEBTApplicaleForBill = FALSE;
    NSMutableArray *tenderReciptDataAry = [self reciptDataAryForBillOrder];

    for (NSMutableDictionary *receiptDictionary in tenderReciptDataAry) {
        BOOL isEbtApplicable = [[receiptDictionary valueForKey:@"EBTApplicable"] boolValue];
        if (isEbtApplicable) {
            receiptDictionary[@"EBTApplied"] = @(0);
        }
        Item *anItem = [self fetchItemWithItemId:receiptDictionary[@"itemId"]];
        NSMutableArray *taxDetail = [self getTaxDetailForItem:anItem];
        if (taxDetail != nil) {
            receiptDictionary[@"ItemTaxDetail"] = taxDetail;
        }
    }
    [self updateReceiptArrayInDatabase:tenderReciptDataAry];
}


-(void)updateRestaurantItemIntoLocalDataBaseWithReciptArray:(NSMutableArray *)reciptArray
{
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantOrder * restaurantOrder;
    if (self.restaurantOrderTenderObjectId != nil) {
        restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderTenderObjectId];
    }
    for (RestaurantItem *restaurantItem in restaurantOrder.restaurantOrderItem.allObjects)
    {
        for (NSDictionary *restaurantItemDictionary in reciptArray) {
            if ([[restaurantItemDictionary valueForKey:@"itemIndex"] isEqualToNumber:restaurantItem.itemIndex]) {
                restaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:restaurantItemDictionary];
            }
        }
    }
    [UpdateManager saveContext:privateManageobjectContext];
}

- (void)updateBillSummaryWithReceiptArray:(NSArray *)reciptArray
{
    float total = self.paymentData.rcrBillSummary.totalSubTotalAmount.floatValue + self.paymentData.rcrBillSummary.totalTaxAmount.floatValue;
    NSNumber *totalBillAmount = @(total);
    
    [self.dictAmoutInfo setValue:[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:totalBillAmount]] forKey:@"InvoiceTotal"];
    [self.dictAmoutInfo setValue:[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:self.paymentData.rcrBillSummary.totalSubTotalAmount]] forKey:@"InvoiceSubTotal"];
    [self.dictAmoutInfo setValue:[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:self.paymentData.rcrBillSummary.totalTaxAmount]] forKey:@"InvoiceTax"];
    [self.dictAmoutInfo setValue:[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:self.paymentData.rcrBillSummary.totalDiscountAmount]] forKey:@"InvoiceDiscount"];
    if (reciptArray.count > 0)
    {
        NSString *strCount = [NSString stringWithFormat:@"%ld",(long)[[reciptArray valueForKeyPath:@"@sum.itemQty"] integerValue]];
        self.dictAmoutInfo[@"TotalItemCount"] = strCount;
    }
    else
    {
        self.dictAmoutInfo[@"TotalItemCount"] = @"0";
    }
    self.paymentData.ebtAmount = self.paymentData.rcrBillSummary.totalEBTAmount.floatValue;
    [self updateBillDetaiUI];
}


-(NSMutableArray *)getTaxDetailForItem:(Item *)anItem
{
    NSMutableArray *taxdetail = [[NSMutableArray alloc]init];
    if (anItem.taxApply.boolValue ==TRUE)
    {
        NSString *strTaxType = anItem.taxType;
        
        if([strTaxType isEqualToString:@"Tax wise"])
        {
            taxdetail = [self getitemTaxDetailFromTaxTable:anItem.itemCode.stringValue inTaxDetail:taxdetail];
        }
        else if([strTaxType isEqualToString:@"Department wise"])
        {
            Department *department=[self fetchDepartment:[NSString stringWithFormat:@"%ld",(long)anItem.deptId.integerValue]];
            
            if(department.chkExtra.boolValue)
            {
                //fExtraChargeAmt = [self getDepartmentExtraChargeAmount:department withSalesPrice:price];
            }
            taxdetail = [self getItemDepartmentTaxFromTaxTable:anItem.deptId.stringValue inTaxDetail:taxdetail];
        }
        else
        {
            taxdetail = nil;
        }
    }
    else
    {
        taxdetail = nil;
    }
    return taxdetail;
}

-(NSMutableArray *)getitemTaxDetailFromTaxTable :(NSString *)itemId inTaxDetail:(NSMutableArray *)taxDetail
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemTax" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId==%d",itemId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *taxListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    for (int i=0; i<taxListArray.count; i++)
    {
        ItemTax *tax=taxListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%d",tax.taxId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemTaxName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemTaxName.count>0)
        {
            TaxMaster *taxmaster=itemTaxName.firstObject;
            NSMutableDictionary *taxDict=[[NSMutableDictionary alloc]init];
            taxDict[@"ItemTaxAmount"] = @"0";
            taxDict[@"TaxPercentage"] = taxmaster.percentage;
            taxDict[@"TaxAmount"] = taxmaster.amount;
            taxDict[@"TaxId"] = taxmaster.taxId;
            [taxDetail addObject:taxDict];
        }
    }
    return taxDetail;
}

-(NSMutableArray *)getItemDepartmentTaxFromTaxTable :(NSString *)departMentTaxId inTaxDetail:(NSMutableArray *)taxDetail
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepartmentTax" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",departMentTaxId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *departmentTaxListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    for (int i=0; i<departmentTaxListArray.count; i++)
    {
        DepartmentTax *departmentTax=departmentTaxListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%d",departmentTax.taxId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemTaxName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemTaxName.count>0)
        {
            TaxMaster *taxmaster=itemTaxName.firstObject;
            NSMutableDictionary *departmentTaxDictionary=[[NSMutableDictionary alloc]init];
            departmentTaxDictionary[@"ItemTaxAmount"] = @"0";
            departmentTaxDictionary[@"TaxPercentage"] = taxmaster.percentage;
            departmentTaxDictionary[@"TaxAmount"] = taxmaster.amount;
            departmentTaxDictionary[@"TaxId"] = taxmaster.taxId;
            [taxDetail addObject:departmentTaxDictionary];
        }
    }
    
    return taxDetail;
}

- (Department*)fetchDepartment :(NSString *)strdeptId
{
    Department *department=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Department" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d", strdeptId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        department=resultSet.firstObject;
    }
    return department;
}

- (Item*)fetchItemWithItemId :(NSString *)itemId
{
    Item *item=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}

-(void)resetPaymentModeItem:(PaymentModeItem *)paymentModeItem
{
    NSMutableDictionary *paymentDict=[[NSMutableDictionary alloc]init];
    paymentDict[@"CardIntType"] = paymentModeItem.paymentType;
    paymentDict[@"PayId"] = paymentModeItem.paymentId;
    paymentDict[@"PayImage"] = paymentModeItem.paymentImage;
    paymentDict[@"PaymentName"] = paymentModeItem.paymentName;
    paymentDict[@"CardType"] = @"";
    paymentDict[@"AuthCode"] = @"";
    paymentDict[@"AccNo"] = @"";
    paymentDict[@"TransactionNo"] = @"";//PNRef
    paymentDict[@"CardHolderName"] = @"";//cardName
    paymentDict[@"ExpireDate"] = @"";//ExpireDate
    paymentDict[@"RefundTransactionNo"] = @"";//RefundTransactionNo
    paymentDict[@"GatewayType"] = @"";//GatewayType
    paymentDict[@"IsCreditCardSwipe"] = @"0";//GatewayType
    paymentDict[@"TipsAmount"] = @"0";//TipsAmount
    paymentDict[@"SignatureImage"] = @"";//SignatureImage
    paymentDict[@"IsManualReceipt"] = @(0);//IsManualReceipt
    paymentDict[@"CreditTransactionId"] = @"";//CreditTransactionId
    paymentDict[@"PaxAdditionalFields"] = [self paxAdditionalFields];////PaxAdditionalFields
    paymentDict[@"BridgepayAdditionalFields"] = [self bridgepayAdditionalFieldsForTenderPay:paymentModeItem.paymentId];////PaxAdditionalFields
    
    paymentDict[@"GiftCardNumber"] = @"";////GiftCardNumber
    paymentDict[@"GiftCardApprovedAmount"] = @(0.00);////GiftCardApprovedAmount
    paymentDict[@"IsGiftCardApproved"] = @"0";////GiftCardApproveAmount
    paymentDict[@"GiftCardBalanceAmount"] = @(0.00);////GiftCardBalanceAmount

    NSString *transctionServerForSpecOption = [NSString stringWithFormat:@"%@",[self transctionServerForSpecOptionforPaymentId:paymentModeItem.paymentId.integerValue]];
    paymentDict[@"TransactionServer"] = transctionServerForSpecOption;//TransactionServer
    
    paymentDict[@"CreditCardSwipeApplicable"] = @([self isSpecOptionApplicableForMultipeCreditCard:SPEC_CARD_PROCESS withPaymentId:paymentModeItem.paymentId.integerValue]);//CreditCardSwipeApplicable

    paymentDict[@"MulipleCreditCardApplicable"] = @([self isSpecOptionApplicableForMultipeCreditCard:SPEC_MULTIPLE_CARD_PROCESS withPaymentId:paymentModeItem.paymentId.integerValue]);//TipsAmount
    paymentModeItem.isPartialApprove = FALSE;
    paymentModeItem.paymentModeDictionary = paymentDict;
    [self.paymentData setActualAmount:0.00 forpaymentMode:paymentModeItem];
    
    
    dispatch_async(dispatch_get_main_queue(),  ^{
        [self updateTenderStatus];
    });
}

- (void)paxDevice:(PaxDevice*)paxDevice willSendRequest:(NSString*)request
{
    
}
- (void)paxDevice:(PaxDevice*)paxDevice response:(PaxResponse*)response
{
    
    if ([response isKindOfClass:[InitializeResponse class]]) {
        InitializeResponse *initializeResponse = (InitializeResponse *)response;
        if (initializeResponse.responseCode.integerValue == 0) {
            dispatch_async(dispatch_get_main_queue(),  ^{
                
                _paxStatusDisplay.hidden = NO;
                _paxStatusDisplay.text = @"Pax Connected Https";
                isPaxConnected = YES;
                self.paymentData.paxSerialNumber = [NSString stringWithFormat:@"%@",initializeResponse.serialNumber];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),  ^{
                _paxStatusDisplay.text = @"Pax DisConnected";
                
            });
        }
    }
    else
    {
        if (response.responseCode.integerValue == 0) {
            
            NSDictionary *paxVoidDictionary = paxVoidArray.lastObject;
            
            PaymentModeItem *paymentModeItem = (PaymentModeItem *)[paxVoidDictionary valueForKey:@"PaymentModeItem"];
            [self resetPaymentModeItem:paymentModeItem];
            [paxVoidArray removeLastObject];
            voidCardNumber++;
            [self performNextVoidTransactionForPax];
        }
        else
        {
            
            dispatch_async(dispatch_get_main_queue(),  ^{
                
                [_activityIndicator hideActivityIndicator];
                NSString *infoMessage = @"Pax void response error";
                NSString *errorMessage = [NSString stringWithFormat:@"%@",response.responseMessage];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [_activityIndicator hideActivityIndicator];
                };
                [self.rmsDbController popupAlertFromVC:self title:infoMessage message:errorMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];

            });
            
          
        }
    }
}
- (void)paxDevice:(PaxDevice*)paxDevice failed:(NSError*)error response:(PaxResponse *)response
{
    
    if ([response isKindOfClass:[InitializeResponse class]]) {
        dispatch_async(dispatch_get_main_queue(),  ^{
            [_activityIndicator hideActivityIndicator];
            _paxStatusDisplay.text = @"Pax DisConnected";
        });
    }
    else if([response isKindOfClass:[DoCreditResponse class]])
    {
            dispatch_async(dispatch_get_main_queue(),  ^{
                
                [_activityIndicator hideActivityIndicator];
                NSString *infoMessage = @"Pax void response error";
                NSString *errorMessage = [NSString stringWithFormat:@"%@",response.responseMessage];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [_activityIndicator hideActivityIndicator];
                };
                [self.rmsDbController popupAlertFromVC:self title:infoMessage message:errorMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            });
            
            
        }
}

- (void)paxDevice:(PaxDevice*)paxDevice isConnceted:(BOOL)isConncted
{
    
}
- (void)paxDeviceDidTimeout:(PaxDevice*)paxDevice
{
    
}
-(void)configurePaxDevice
{
    NSDictionary *dictDevice = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceConfig"];
    if (dictDevice != nil)
    {
        NSString *paxDeviceIP = dictDevice [@"PaxDeviceIp"];
        NSString *paxDevicePort = dictDevice [@"PaxDevicePort"];
        paxDevice = [[PaxDevice alloc] initWithIp:paxDeviceIP port:paxDevicePort];
        paxDevice.paxDeviceDelegate = self;
        
        NSDictionary *dictDeviceStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceStatus"];
        
        if([dictDeviceStatus[@"PaxConnectionStatus"] floatValue] == TRUE)
        {
            _paxStatusDisplay.hidden = NO;
            _paxStatusDisplay.text = @"Pax Connected Https";
            isPaxConnected = YES;
            self.paymentData.paxSerialNumber = [NSString stringWithFormat:@"%@",[dictDeviceStatus valueForKey:@"PaxSerialNumber"]];
            
        }
        else{
            _paxStatusDisplay.text = @"Pax DisConnected";
            
        }
    }
}


-(void)configureDataForPaxVoidProcess
{
     paxVoidArray = [[NSMutableArray alloc] init];
    
    for(int i = 0;i<self.paymentData.countOfPaymentModes;i++)
    {
        NSArray * paymentSubArray = [self.paymentData paymentModeArrayAtIndex:i];
        for (int j = 0; j < paymentSubArray.count; j++)
        {
            PaymentModeItem *paymentModeItem  = paymentSubArray[j];
            {
                float actualAmount = paymentModeItem.actualAmount.floatValue ;
                float calCulatedAmount =  paymentModeItem.calculatedAmount.floatValue ;
                if (actualAmount == 0 )
                {
                    actualAmount = calCulatedAmount;
                }
                
                if (actualAmount != 0 )
                {
                    NSString *isCreditCardSwipeString = [paymentModeItem isCreditCardSwipe];
                    if ([isCreditCardSwipeString isEqualToString:@"1"])
                    {
                        NSMutableDictionary *paxCreditCardVoidDictionary = [[NSMutableDictionary alloc] init];
                        paxCreditCardVoidDictionary[@"TransactionNo"] = [paymentModeItem.paymentModeDictionary valueForKey:@"TransactionNo"];
                        paxCreditCardVoidDictionary[@"TransactionId"] = [paymentModeItem.paymentModeDictionary valueForKey:@"CreditTransactionId"];
                        paxCreditCardVoidDictionary[@"PaymentModeItem"] = paymentModeItem;

                        [paxVoidArray addObject:paxCreditCardVoidDictionary];
                    }
                }
            }
        }
    }
    
    if (paxVoidArray.count > 0) {
        voidCardNumber++;
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [self performNextVoidTransactionForPax];
    }
}

-(void)performNextVoidTransactionForPax
{
    if (paxVoidArray.count == 0) {
        
        dispatch_async(dispatch_get_main_queue(),  ^{
            [_activityIndicator hideActivityIndicator];
            self.btnClose.enabled = YES;
            self.paxVoidButton.hidden = YES;
//            [self btnCloseclick:nil];
        });
       return;
    }
    
    
    NSString *voidMessage = [NSString stringWithFormat:@"Void card(%ld)........",(long)voidCardNumber];
    
    [_activityIndicator updateLoadingMessage:voidMessage];
    
    [self paxVoidTransaction:paxVoidArray.lastObject];
}
-(void)paxVoidTransaction:(NSDictionary *)paxVoidDictionary
{
    paxDevice.pdResonse = PDResponseDoCash;
    [paxDevice voidCreditTransactionNumber:paxVoidDictionary[@"TransactionNo"] invoiceNumber:self.paymentData.strInvoiceNo referenceNumber:[paxVoidDictionary valueForKey:@"TransactionId"]];
}
-(IBAction)paxVoidButton:(id)sender
{
    [self configureDataForPaxVoidProcess];
}


#pragma mark -
#pragma PerformNext Restucture
-(BOOL)checkHouseChargeDetail
{
    BOOL isApplicable = [self isSpecOptionApplicableHouseCharge];
    if (isApplicable)
    {
        [self creditLimitForHouseCharge];
    }
    return isApplicable;
}

-(BOOL)checkGiftCardDetail
{
   BOOL isApplicable = [self isSpecOptionApplicableGiftCard];
    if (isApplicable)
    {
        NSString *strAmount = [self getGiftCardAmount];
        [self loadGiftCardView:strAmount];
    }
    return isApplicable;
}

-(BOOL)checkOpenCashDrawer
{
   BOOL isApplicable = [self isSpecOptionApplicable:SPEC_OPEN_DRAWER];
    if (isApplicable)
    {
        if(self.paymentData.billAmount == 0.00){
            
            [self.tenderProcessManager performNextStep];
        }
        else{
            [self setStatusmessage:@"Opening CashDrawer" withWarning:FALSE];
            [self OpenCashDrawer];
        }
        
    }
    return isApplicable;
}

-(BOOL)checkPaymentDetail
{
   BOOL isApplicable = [self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS];
    if (isApplicable)
    {
        if (self.rmsDbController.paymentCardTypearray.count >0)
        {
            [self.tenderProcessManager performNextStep];
        }
        else
        {
            [self GetPaymentCardTypeDetail];
        }
        
    }
    return isApplicable;
}
-(BOOL)checkCardProcess
{
    [self stopWatchDogTimer];
   BOOL isApplicable = [self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS];
    if (isApplicable)
    {
        [self setStatusmessage:@"Processing Cards" withWarning:FALSE];
        
        NSDictionary *changeDueMessageDictionary = @{
                                                     @"Tender":@"CreditCardProcessing",
                                                     @"TenderSubTotals":self.dictAmoutInfo,
                                                     @"ChangeDue":[self formatedTextForAmount:-self.paymentData.balanceAmount],
                                                     @"ShowTender":[self formatedTextForAmount:self.paymentData.totalCollection],
                                                     @"Total":[self formatedTextForAmount:self.paymentData.billAmount],
                                                     @"CreditCardMessage":@"Please Swipe Insert Tap the card. Please enter the PIN if required.",
                                                     @"CreditCardStep":@(CreditCardProcessingStepBegan)
                                                     };
        [self.crmController writeDictionaryToCustomerDisplay:changeDueMessageDictionary];
        CardProcessingVC *cardProcess = [[CardProcessingVC alloc]initWithNibName:@"CardProcessingVC" bundle:Nil];
        
        cardProcess.cardProcessingDelegate = self;
        cardProcess.isGasItem = self.isGasItem;
        cardProcess.tipInfo = [self fetchTipFromLocalDatabase];
        cardProcess.billInfo = self.dictAmoutInfo;
        cardProcess.invoiceNo = self.paymentData.strInvoiceNo;
        cardProcess.paymentCardData = self.paymentData;
        cardProcess.regstrationPrefix = regstrationPrefix;
        cardProcess.isPaxConnectedToRapid =  isPaxConnected;
        cardProcess.paxSerialNo = self.paymentData.paxSerialNumber;
        cardProcess.tenderProcessCreditManager = self.tenderProcessManager;
        cardProcess.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:cardProcess animated:YES completion:Nil];
    }
    else{
        self.tenderProcessManager.currentStep++;
    }
    return isApplicable;
}
-(BOOL)checkCustomerTipAdjustment
{
    BOOL isApplicable = FALSE;
    if ( self.paymentData.isTipAdjustmentApplicable .boolValue == TRUE)
    {
        isApplicable = YES;
        [self setStatusmessage:@"Tips Adjustment Process" withWarning:FALSE];
        [self tipAdjustmentProcess];
    }
    return isApplicable;
}


-(void)checkProcessChangeDue
{
//    if(self.rmsDbController.rapidPetroPos){
//        self.prepayPumpsArray = [self.rmsDbController.rapidPetroPos.arrPumpCartTender mutableCopy];
//        [self.rmsDbController.rapidPetroPos updateUnPaidPumpDetail:[self insertPumpDataDictionary]];
//    }
    
    [self setStatusmessage:@"" withWarning:FALSE];
    [self processChangeDue];
}

-(BOOL)checkProcessForCradReceiptPrint
{
   BOOL isApplicable = [self isSpecOptionApplicableAfterCreditCard:SPEC_PRINT_RECIPT];
    
    if (isApplicable)
    {
        [self setStatusmessage:@"Printing Cards Receipt" withWarning:FALSE];
        [self manualReceiptPrintProcess];
    }
    return isApplicable;
}

-(void)checkWebserviceCall
{
    [self callWebserice];
}
-(BOOL)checkProcessReceipt
{
   BOOL isApplicable = [self isSpecOptionApplicable:SPEC_PRINT_RECIPT];
    if (isApplicable)
    {
        [self setStatusmessage:@"Printing Bill Receipt" withWarning:FALSE];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self PrintReceipt];
        });
    }
    return isApplicable;
}
-(BOOL)checkPassPrint
{
  BOOL isApplicable = [self isAplicableForPassReceiptPrint];
    if (isApplicable)
    {
        [self setStatusmessage:@"Printing Pass Receipt" withWarning:FALSE];
        [self passReceiptPrint];
    }
    return isApplicable;
}


-(BOOL)checkGiftCardPrint
{
    BOOL isApplicable = [self isSpecOptionApplicableAfterGiftCard:SPEC_PRINT_RECIPT];
    if (isApplicable)
    {
        [self setStatusmessage:@"Printing GiftCard Receipt" withWarning:FALSE];
        [self generateGiftCardPrintDetail];
    }
    return isApplicable;
}

-(BOOL)checkHouseChargePrint:(BOOL)isSignature
{
    BOOL isApplicable = [self isSpecOptionApplicableAfterHouseCharge:SPEC_PRINT_RECIPT];
    if (isApplicable)
    {
        [self setStatusmessage:@"Printing HouseCharge Receipt" withWarning:FALSE];
        [self printHouseChargeReceipt:isSignature];

    }
    return isApplicable;
}

-(void)checkGasPumpPrepayProcess
{
//    if(self.rmsDbController.rapidPetroPos){
////        [self.rmsDbController.rapidPetroPos updatePaymentAndPrePayData:[self insertPumpDataDictionary]];
//    }
}
-(void)checkDoneProcess
{
    [self setStatusmessage:@"" withWarning:FALSE];
    [self.loadingIndicator stopAnimating];
    [self addGestureToChangeDueScreen];
}
-(void)checkFinishProcess
{
    [self stopWatchDogTimer];
    [self tenderTaskDidFinish];
    _printButtonContainerView.hidden = NO;
    _btnDone.hidden = NO;
}
-(BOOL)preProcessForBegin
{
    BOOL status = YES;
    
    if (![self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS] && ![self isSpecOptionApplicableGiftCard] && ![self isSpecOptionApplicableHouseCharge]) /// Cash Or Non CreditCard...
    {
        // check and increment keychain invoice no and save it...
        [self increaseInvRegisterNumber];
        
        //    [self logForInvoiceDataWithMethodName:@"TP_BEGIN Before Insert"];
        
        //  insert the offline data to database...................
        [self insertDataInLocalDataBase];
        
        //    [self logForInvoiceDataWithMethodName:@"TP_BEGIN After Insert"];
        
        
        if (!invoiceData.invoicePaymentData) {
            status = NO;
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                NSDictionary *cardSwipeInfoDictionary = @{@"ErrorCode": @"50 - Please try again."};
                [Appsee addEvent:@"TP_BEGIN nil paymentData" withProperties:cardSwipeInfoDictionary];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"50 - Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    }
    
    return status;
}
-(void)preprocessHouseChargeDetail
{
    if ([self isSpecOptionApplicableHouseCharge] && ![self isSpecOptionApplicableGiftCard] && ![self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS] )
    {
        // check and increment keychain invoice no and save it...
        
        [self increaseInvRegisterNumber];
        //  insert the offline data to database...................
        
        [self insertDataInLocalDataBase];
    }

}
-(void)preprocessCheckPaymentDetail
{
    if ([self isSpecOptionApplicableGiftCard] && ![self isSpecOptionApplicableCreditCard:SPEC_CARD_PROCESS]  ) /// Gift
    {
        // check and increment keychain invoice no and save it...
        [self increaseInvRegisterNumber];
        
        //  insert the offline data to database...................
        [self insertDataInLocalDataBase];
    }
}


-(BOOL)preprocessProcessCard
{
    BOOL status = YES;

    if ([self isSpecOptionApplicableAfterCreditCard:SPEC_CARD_PROCESS] ) /// Cash Or Non CreditCard...
    {
        // check and increment keychain invoice no and save it...
        [self increaseInvRegisterNumber];
        
        //  insert the offline data to database...................
        [self insertDataInLocalDataBase];
        
        if (!invoiceData.invoicePaymentData) {
            status = NO;
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                NSDictionary *cardSwipeInfoDictionary = @{@"ErrorCode": @"51 - Please try again."};
                [Appsee addEvent:@"TP_PROCESS_CARDS nil paymentData" withProperties:cardSwipeInfoDictionary];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"51 - Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            
        }
    }
    return status;
}

-(void)preprocessSignatureCapture
{
    self.Payparam = nil;
    //  insert the offline data with signature to database...................
    [self insertLastInvoiceDataToLocalData];
}
@end
