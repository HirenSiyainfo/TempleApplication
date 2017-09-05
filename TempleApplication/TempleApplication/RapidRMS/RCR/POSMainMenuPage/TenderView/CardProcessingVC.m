//
//  CreditCardViewController.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/26/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CardProcessingVC.h"
#import "CardDeviceManager.h"
#import "RcrController.h"
#import "RmsCardReader.h"
#import "RmsDbController.h"
#import "CreditCardPopOverVC.h"
#import "PaymentModeItem.h"
#import "PaymnetCreditModeData.h"
#import "WTReTextField.h"
#import "SignatureViewController.h"
#import "CustomerSignatureAlertVC.h"
#import "CreditCardReaderManager.h"
#import "PaxDeviceViewController.h"
#import "PaxConstants.h"
#import "PaymentGatewayResponse.h"
#import "TenderViewController.h"


typedef enum __CREDIT_TEXT_{
    CREDIT_ACCOUNT_TEXT = 10001,
    CREDIT_EXPIRATION_DATE_TEXT,
    CREDIT_CVV_NUMBER_TEXT,
   } __CREDIT_TEXT_;

typedef enum __CREDIT_PROCESS_STATUS_{
    CREDIT_PROCESS_SUCCESS,
    CREDIT_PROCESS_CANCEL,
    CREDIT_PROCESS_DECLINE,
} __CREDIT_PROCESS_STATUS_;

//#define PAX_DEVICE
//#define PAX_SERVICE_CALL
//#define PAX_STIMULATE_SERVICE_CALL

typedef enum _CreditTransction{
    Pax_DeviceIntialize,
    Pax_CardSwipe,
    Pax_SignatureCapture,
} _CreditTransction;

typedef enum __Signature_Spec_Options_ {
    CREDIT_SPEC_POS_SIGN_RECEIPT = 6,
    CREDIT_SPEC_CUSTOMER_DISPLAY_SIGN_RECEIPT = 7,
    CREDIT_SPEC_PAX_SIGNATURE = 14,
    CREDIT_SPEC_RCR_PAPER_SIGNATURE = 15,

} __CREDIT_SIGNATURE_SPEC_OPTIONS_;

typedef NS_ENUM (NSInteger, TransactionStatus) {
    TransactionStatusApproved = 1,
    TransactionStatusDeclined,
};

@interface CardProcessingVC () <UIPopoverControllerDelegate,SignatureViewControllerDelegate,CustomerSignatureAlertDelegate,CreditCardReaderManagerDelegate,PaxDeviceSettingVCDelegate , CardDeviceManagerDelegate>
{
    CustomerSignatureAlertVC *customerSignatureAlertVC;
    
    BOOL isFirstTimeNextCardSwipe;
    BOOL isDirection;

    NSInteger currentStep;
    NSInteger currentoffset;
    NSInteger currentTextFieldTag;
    NSInteger currentCreditProcess;
    NSNumber *currentPaymentId;

    NSString *currentTransactionCardIntType;
    NSString *currentCreditTransactionId;
    NSString *transactionServer;
    NSString *transactionNo;
    
    UIPopoverController *creditCardPopOverController;
    int i,j;
    CGFloat tipAmount;
    
    BOOL isAnyCardApprovedPartially;
}

@property (nonatomic, weak) IBOutlet UITextField *txtCardName;

@property (nonatomic, weak) IBOutlet UILabel *lblConnectionType;
@property (nonatomic, weak) IBOutlet UILabel *lblTransactionServer;
@property (nonatomic, weak) IBOutlet UILabel *lblCardType;
@property (nonatomic, weak) IBOutlet UILabel *lblPaymentGateway;
@property (nonatomic, weak) IBOutlet UILabel *lblAmount;

@property (nonatomic, weak) IBOutlet UIView *uvManualProcess;
@property (nonatomic, weak) IBOutlet UIView *uvSwipeView;
@property (nonatomic, weak) IBOutlet UIView *uvPaymentInfo;
@property (nonatomic, weak) IBOutlet UIView *uvAmount;
@property (nonatomic, weak) IBOutlet UIView *uvCardNumber;
@property (nonatomic, weak) IBOutlet UIView *uvExpirationDate;
@property (nonatomic, weak) IBOutlet UIView *uvCardName;
@property (nonatomic, weak) IBOutlet UIView *uvCreditCard;

@property (nonatomic, weak) IBOutlet UIScrollView *manualTextFieldScrollView;

@property (nonatomic, weak) IBOutlet UIButton *sendManualCardFlight;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *btn_Send;
@property (nonatomic, weak) IBOutlet UIButton *cancelCardFlight;
@property (nonatomic, weak) IBOutlet UIButton *manualProcessbutton;
@property (nonatomic, weak) IBOutlet UIButton *btnSwipeProcess;
@property (nonatomic, weak) IBOutlet  UIButton *timeOutButton;

@property (nonatomic, weak) IBOutlet WTReTextField *txtAccountNumber;
@property (nonatomic, weak) IBOutlet WTReTextField *txtExpirationDate;
@property (nonatomic, weak) IBOutlet WTReTextField *txtCVNum;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) PaymnetCreditModeData  *paymentCreditModeData;
@property (nonatomic, strong) CreditCardReaderManager *creditCardReaderManager;
@property (nonatomic, strong) CardDeviceManager *cardDeviceManager;

@property (nonatomic, strong) RapidWebServiceConnection  *refundCreditCardConnection;
@property (nonatomic, strong) RapidWebServiceConnection *creditCardAutoConnection;

@property (atomic) NSInteger currentIndexPath;
@property (atomic) int transactionTry;
@property (nonatomic,strong) NSString *transType;
@property (nonatomic,strong) NSString *deviceName;

@property (nonatomic,strong) NSMutableDictionary *cardTransactionRequestLog;
@property (nonatomic,strong) NSMutableArray *cardTransactionRequestArray;



@end

@implementation CardProcessingVC


@synthesize cardDeviceManager,cardProcessingArray,paymentCardData,invoiceNo,isGasItem;
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
    

    _manualTextFieldScrollView.layer.borderColor = [UIColor blackColor].CGColor;
    _manualTextFieldScrollView.layer.borderWidth = 1.0;
    _manualTextFieldScrollView.layer.cornerRadius = 5.0;

    _manualTextFieldScrollView.contentSize = CGSizeMake(360,43);
    _manualTextFieldScrollView.contentOffset = CGPointMake(0,0);

    currentoffset = 0;
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.refundCreditCardConnection = [[RapidWebServiceConnection alloc] init];
    self.creditCardAutoConnection = [[RapidWebServiceConnection alloc]init];
    _cardTransactionRequestArray = [[NSMutableArray alloc] init];
    self.paymentCreditModeData = [[PaymnetCreditModeData alloc]init];
    //Start CardSwipe Process...
    self.currentIndexPath = -1;
    self.transactionTry = 0;
    _btn_Send.enabled = NO;
    _btn_Send.hidden = YES;
    isFirstTimeNextCardSwipe = FALSE;
    
    transactionNo = @"";

    
    //Intialize Card Devicemanager...

    _uvManualProcess.frame = CGRectMake(55, 1000, _uvManualProcess.frame.size.width, _uvManualProcess.frame.size.height);
    [self.view addSubview:_uvManualProcess];
    _uvManualProcess.hidden = YES;

    _txtAccountNumber.pattern = @"^(\\d{4}(?: )){3}\\d{4}$";
    _txtExpirationDate.pattern = @"^(1[0-2]|(?:0)[1-9])(?:/)\\d{2}$";
    _txtCVNum.pattern = @"^\\d{3,4}$";
    i = 0;
    j = 0;
    [Appsee markViewAsSensitive:_manualTextFieldScrollView];
    [self swipeProcessButton:nil];
    
    [self setCornerRadiusToView:_uvPaymentInfo radius:2.0];
    [self setCornerRadiusToView:_uvCardNumber radius:2.0];
    [self setCornerRadiusToView:_uvExpirationDate radius:2.0];
    [self setCornerRadiusToView:_uvCardName radius:2.0];
    [self setCornerRadiusToView:_uvAmount radius:2.0];
    [self setCornerRadiusToView:_uvCreditCard radius:10.0];
}

- (void)setCornerRadiusToView:(UIView *)aView radius:(CGFloat)radious
{
    aView.layer.cornerRadius = radious;
}


-(void)configureCreditCardDevice
{
    if (isFirstTimeNextCardSwipe == FALSE) {
        self.paymentCreditModeData.creditPaymentArray = self.paymentCardData.creditSwipeArrayofPaymentModeItem;
    }
 
    NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
   // gateWay = @"Pax";
    _lblPaymentGateway.text = [[NSString alloc]initWithFormat:@"%@",gateWay].uppercaseString;
    if ([gateWay isEqualToString:@"Pax"])
    {
        _lblConnectionType.text = @"Pax DisConnected";
        if (isFirstTimeNextCardSwipe == FALSE) {
            [self checkPaxConfiguration];
           self.creditCardReaderManager = [[CreditCardReaderManager alloc] initWithDelegate:self withPaxConnectionStatus:self.isPaxConnectedToRapid];
            isFirstTimeNextCardSwipe = TRUE;
            if (self.isPaxConnectedToRapid == TRUE) {
                _lblConnectionType.text = @"Pax Connected";
                [self nextCardSwipe];
            }
        }
    }
    else
    {
        if (isFirstTimeNextCardSwipe == FALSE) {
            self.cardDeviceManager = [[CardDeviceManager alloc]initWithDelegate:self];
            isFirstTimeNextCardSwipe = TRUE;
            [self nextCardSwipe];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (currentCreditProcess == CREDIT_PROCESS_CANCEL) {
        [self.cardDeviceManager closeDevice];
        [self.cardProcessingDelegate cardProcessingDidCancel:isAnyCardApprovedPartially];
    }
}
//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self configureCreditCardDevice];
//}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureCreditCardDevice];
}



-(void)addPaymentView
{
    [[_uvManualProcess viewWithTag:112]removeFromSuperview];
}

-(void)nextCardSwipe
{
    self.currentIndexPath++;
    
    if (self.paymentCreditModeData.creditPaymentArray.count<= self.currentIndexPath)
    {
        [self dismissViewControllerAnimated:TRUE completion:^{
            [self.cardDeviceManager closeDevice];
            [self.cardProcessingDelegate cardProcessingDidFinish:isAnyCardApprovedPartially];
        }];
    }
    else
    {
        NSString *cardType = [self.paymentCreditModeData paymentTypeOfPaymentMode:(PaymentModeItem *)(self.paymentCreditModeData.creditPaymentArray)[self.currentIndexPath]];
        if ([cardType isEqualToString:@"Credit"] || [cardType isEqualToString:@"Debit"] || [cardType isEqualToString:@"EBT/Food Stamp"])
        {
            currentTransactionCardIntType = cardType;
            
            PaymentModeItem *paymentModeItem = (PaymentModeItem *)(self.paymentCreditModeData.creditPaymentArray)[self.currentIndexPath];
            
            float actualAmount = [self.paymentCreditModeData actualAmountOfPaymentMode:paymentModeItem] ;
           
            float calculatedAmount = [self.paymentCreditModeData calculatedAmountOfPaymentMode:paymentModeItem] ;
            
            tipAmount = [self.paymentCreditModeData tipAmountOfPaymentMode:paymentModeItem];
            
            BOOL isCreditCardSwiped = [self.paymentCreditModeData isCreditCardSwipedAtPaymentMode:paymentModeItem];
          
            [self updateTransactionId];
            
            
            currentPaymentId = [self.paymentCreditModeData paymentIdOfPaymentMode:paymentModeItem];
            
            transactionServer = [self.paymentCreditModeData tranctionServerPaymentMode:(PaymentModeItem *)(self.paymentCreditModeData.creditPaymentArray)[self.currentIndexPath]];
            
            _lblTransactionServer.text = transactionServer;
            
            NSLog(@"currentCreditTransactionId = %@",currentCreditTransactionId);
            if (actualAmount == 0)
            {
                actualAmount = calculatedAmount;
            }
            if (!(actualAmount == 0) && isCreditCardSwiped == NO )
            {
                NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
//              gateWay = @"Pax";
                
                dispatch_async(dispatch_get_main_queue(),  ^{
                    [self updateCoustmerDisplayCreditCardMessage:@"Please Swipe/Insert/Tap the card. \n \n Please enter the PIN if required."];
                });

                if ([gateWay isEqualToString:@"Pax"])
                {
                    currentStep = Pax_CardSwipe;
                    dispatch_async(dispatch_get_main_queue(),  ^{
                        [self displayCardView:actualAmount WithCardName:[self.paymentCreditModeData paymentTypeOfPaymentMode:paymentModeItem]];
                        _activityIndicator = [RmsActivityIndicator showActivityIndicator:_uvCreditCard];
                        [_activityIndicator updateLoadingMessage:@"Please swipe card....."];
                        
                        [self.paymentCreditModeData updatePaymentModeItem:paymentModeItem withTransactionId:currentCreditTransactionId withStatus:@(Requesting)];
                        [self.tenderProcessCreditManager updatePaymentDataWithCurrentStep];
                        
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.creditCardReaderManager doCreditCardReaderRequestWithPaymentModeItem:(self.paymentCreditModeData.creditPaymentArray)[self.currentIndexPath] WithRegisterInvNo:self.invoiceNo withTransactionId:currentCreditTransactionId isGasItem:self.isGasItem];
                        
                    });
                }
                else
                {
                       [self displayCardView:actualAmount WithCardName:[self.paymentCreditModeData paymentTypeOfPaymentMode:(PaymentModeItem *)(self.paymentCreditModeData.creditPaymentArray)[self.currentIndexPath]]];
                }
            }
            else
            {
                [self nextCardSwipe];
            }
        }
        else
        {
            [self nextCardSwipe];
        }
    }
}
-(void)updateTransactionId
{
    NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
    if ([gateWay isEqualToString:@"Pax"])
    {
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HHmmss";
        NSString *strDate = [formatter stringFromDate:date];
        currentCreditTransactionId =   [NSString stringWithFormat:@"%@%@",self.invoiceNo,strDate];
    }
    else
    {
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMddyyHHmmss";
        NSString *strDate = [formatter stringFromDate:date];
        currentCreditTransactionId = [NSString stringWithFormat:@"%@%@",self.regstrationPrefix,strDate];
    }
}

-(void)updateCoustmerDisplayCreditCardMessage:(NSString *)message
{
    NSDictionary *changeDueMessageDictionary = @{
                                                 @"Tender":@"CoustmerDisplayCreditCardMessage",
                                                 @"RCDCreditCardMessage":message,
                                                 };
    [self.crmController writeDictionaryToCustomerDisplay:changeDueMessageDictionary];

}
-(BOOL)isGasItem{
    BOOL isGas = NO;
    TenderViewController *tenderViewobjct =  (TenderViewController *)self.cardProcessingDelegate;
    
    NSMutableArray *tenderReciptDataAry = [tenderViewobjct reciptDataAryForBillOrder];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Barcode == %@",@"GAS"];
    NSArray *arrayGas = [tenderReciptDataAry filteredArrayUsingPredicate:predicate];
    if(arrayGas.count>0 && [arrayGas.firstObject[@"Discription"] isEqualToString:@"PRE-PAY"]){
        isGas = YES;
    }
    return isGas;
}
-(void)displayCardView:(float)billAmount WithCardName:(NSString *)cardName
{
    transactionNo = @"";
    if(self.isGasItem){
        if([self.rmsDbController isPreAuthEnabled]){
            self.transType = @"Auth";
        }else{
            self.transType = @"Sale";
        }

    }
    else{
        self.transType = @"Sale";
    }

    NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
    if ([gateWay isEqualToString:@"CardFlight"])
    {
    }
    else
    {
        if (billAmount<0) {
            billAmount = -1*billAmount;
            self.transType = @"Return";
        }
    }
   
    _lblCardType.text = cardName;
    NSNumber *sbillAmount = @(billAmount);
    NSString *sPrice =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sbillAmount]];
    _lblAmount.text = sPrice;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)send :(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:_uvCreditCard];
 /*   NSMutableDictionary *test = [[NSMutableDictionary alloc]init];
    [test setValue:@"test444444" forKey:@"AuthCode"];
    [test setValue:@"test444" forKey:@"ExtData"];
    [test setValue:@"test4545" forKey:@"PNRef"];
    [test setValue:@"Test1111" forKey:@"AccNo"];
    [test setValue:@"TestUser" forKey:@"CardHolderName"];

    [self.paymentCardData setCreditCardDictionary:test AtIndex:self.currentIndexPath];
    self.currentIndexPath++;
    [self nextCardSwipe];

    return;*/
 
    
    if (_lblAmount.text.length>0 && self.transType.length >0) {
        NSString *sInvAmt=[_lblAmount.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
        NSString *sInvAmtRemove=[NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:sInvAmt].floatValue];
        float amountTopass=sInvAmtRemove.floatValue;
        
        NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
        if ([gateWay isEqualToString:@"CardFlight"])
        {
            self.transType =_lblCardType.text;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self.cardDeviceManager processCreditCardWithDictionary:[self createCreditCardDictionaryWithAmount:amountTopass]];
        });
    }
}

-(NSMutableDictionary *)createCreditCardDictionaryWithAmount :(float)amount
{
    NSMutableDictionary *detailDict = [[NSMutableDictionary alloc]init];
    detailDict[@"accountNo"] = [NSString stringWithFormat:@"%@",[_txtAccountNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
   // [detailDict setObject:@"" forKey:@"accountNo"];
    
    detailDict[@"transType"] = self.transType;
    detailDict[@"expDate"] = [NSString stringWithFormat:@"%@",[_txtExpirationDate.text stringByReplacingOccurrencesOfString:@"/" withString:@""]];
    detailDict[@"cvNum"] = _txtCVNum.text;
    detailDict[@"amount"] = @(amount);
    detailDict[@"invoiceNo"] = self.invoiceNo;
    detailDict[@"TransactionNo"] = @"";
    detailDict[@"tip"] = @(tipAmount);
    detailDict[@"currentCreditTransactionId"] = currentCreditTransactionId;
    detailDict[@"TransactionServer"] = transactionServer;
    return detailDict;
}

-(IBAction)cancel :(id)sender
{
    [Appsee addEvent:kPosCardProcessingCancel];

    [self.cardDeviceManager closeDevice];
    currentCreditProcess = CREDIT_PROCESS_CANCEL;
    [self dismissViewControllerAnimated:TRUE completion:^{
        [self.cardDeviceManager closeDevice];
        [self.cardProcessingDelegate cardProcessingDidCancel:isAnyCardApprovedPartially];
    }];
}


-(IBAction)doneTransaction:(id)sender
{
    _txtAccountNumber.text = @"";
    _txtExpirationDate.text = @"";
    _txtCVNum.text = @"";
    _txtCardName.text = @"";
    [self nextCardSwipe];
}

#pragma mark - CardProcessing Methods

// delegate Method For Divice Connection Status......
- (void)didConnectToDevice :(NSString *)deviceName
{
    _lblConnectionType.text = @"Connected";
}
- (void)didDisconnectFromDevice :(NSString *)deviceName
{
    _lblConnectionType.text = @"Please connect the card swiper";
}

- (void)setAppSeeValue:(NSMutableDictionary *)cardInfoDict value:(NSString *)value forKey:(NSString *)key
{
    if (value) {
        cardInfoDict[key] = value;
    }
    else
    {
        cardInfoDict[key] = @"missing";
    }
}

// delegate Method For Card Swipe Process....
- (void)didSwipeFromDevice :(NSString *)accountNumber withExpirationDate:(NSString *)date WithNameOnCard :(NSString *)cardName deviceName:(NSString *)deviceName
{
    NSMutableDictionary *cardInfoDict = [[NSMutableDictionary alloc] init];
    
    [self setAppSeeValue:cardInfoDict value:accountNumber forKey:@"AccountNo"];
    [self setAppSeeValue:cardInfoDict value:date forKey:@"Date"];
    [self setAppSeeValue:cardInfoDict value:cardName forKey:@"CardName"];
    [self setAppSeeValue:cardInfoDict value:deviceName forKey:@"DeviceName"];

    NSDictionary *cardSwipeInfoDictionary = @{kPosCardSwipeKey: cardInfoDict};
    [Appsee addEvent:kPosCardSwipe withProperties:cardSwipeInfoDictionary];
    
    self.deviceName = deviceName;
    if (accountNumber.length > 0 && date.length > 0 && cardName.length > 0 )
    {
        _txtAccountNumber.text = accountNumber;
        _txtExpirationDate.text = date;
        _txtCardName.text = cardName;
        NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
        if ([gateWay isEqualToString:@"CardFlight"])
        {
            [self send:nil];
        }
        else
        {
            if ([self.transType isEqualToString:@"Return"] )
            {
                [self send:nil];
            }
            else
            {
                [self send:nil];
            }
        }
    }
}

// Method For Payment SuccessFully Finished.....
- (void)paymentProcessDidFinish :(NSDictionary *)cardPaymentDict
{
//    NSDictionary *cardPaymentProcessDict = @{kPosPaymentProcessDoneKey: cardPaymentDict};
//    [Appsee addEvent:kPosPaymentProcessDone withProperties:cardPaymentProcessDict];

    dispatch_async(dispatch_get_main_queue(),  ^{
        [_activityIndicator hideActivityIndicator];;
        
        [UIView animateWithDuration:0.5 animations:^{
            _uvManualProcess.frame = CGRectMake(55, 1000, _uvManualProcess.frame.size.width, _uvManualProcess.frame.size.height);
            
        } completion:^(BOOL finished) {
            _uvManualProcess.hidden = YES;
        }];
        
        _uvManualProcess.hidden = YES;
        
        NSMutableDictionary *creditCardDictionary = [cardPaymentDict mutableCopy];
        NSArray *myName = [_txtCardName.text componentsSeparatedByString:@"/"];
        NSString *s=myName.firstObject;
        NSString *trimmedString = [s stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceCharacterSet]];
        creditCardDictionary[@"CardHolderName"] = trimmedString;
        creditCardDictionary[@"ExpireDate"] = _txtExpirationDate.text;
        creditCardDictionary[@"RefundTransactionNo"] = transactionNo;
        NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
        creditCardDictionary[@"GatewayType"] = gateWay;
        creditCardDictionary[@"IsCreditCardSwipe"] = @"1";
        
        
        if([creditCardDictionary[@"CreditTransactionId"] isKindOfClass:[NSNull class]]
           || [creditCardDictionary[@"CreditTransactionId"]length] == 0)
        {
            creditCardDictionary[@"CreditTransactionId"] = currentCreditTransactionId;
        }

        transactionNo = @"";
        
        [self.paymentCreditModeData setCreditCardDictionaryAtIndex:self.currentIndexPath withDetail:creditCardDictionary];

        NSLog(@"remaining card = %lu",(unsigned long)self.paymentCardData.creditSwipeArrayofPaymentModeItem.count);
        
        if (self.paymentCardData.creditSwipeArrayofPaymentModeItem.count == 0) {
            [self.tenderProcessCreditManager insertInvoiceToLocalDatabase];
        }
        /*!
         *  incerement completedCreditCardSwipe count when transaction is approved.
         */
//        self.paymentCardData.completedCreditCardSwipe++;
        
        _txtAccountNumber.text = @"";
        _txtExpirationDate.text = @"";
        _txtCVNum.text = @"";
        _txtCardName.text = @"";
        tipAmount = 0.00;
        _manualTextFieldScrollView.contentOffset = CGPointMake(0,0);
        [self captureSignatureForCreditCardTransctionWithCreditInfo:creditCardDictionary];

    });

   }


- (void)transactionDeclinewithErrorMessage : (NSString *)errorMessage
{
    //    NSDictionary *cardPaymentProcessDict = @{kPosCardProcessFailedKey: errorMessage};
    //    [Appsee addEvent:kPosCardProcessFailed withProperties:cardPaymentProcessDict];
    [_activityIndicator hideActivityIndicator];
    transactionNo = @"";
    _txtExpirationDate.text = @"";
    _txtCVNum.text = @"";
    _txtCardName.text = @"";
    _txtAccountNumber.text = @"";
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [_manualTextFieldScrollView setContentOffset:CGPointMake(0, 0) animated:TRUE];
        [_txtAccountNumber becomeFirstResponder];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:errorMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}
// Delegate Method For Payment Process Failed.....
- (void)paymentProcessDidFailed
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        [self transactionDeclinewithErrorMessage:@"Connection Timed Out, please try again."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self processVoidForCurrentTransctionId];
        });
    });
}
- (void)paymentProcessDidFailedWithDuplicateTranactionWithError :(NSError *)error
{
    /*!
     *  incerement completedCreditCardSwipe count when Tranaction With Error.
     */
    
//    self.paymentCardData.completedCreditCardSwipe++;
    [self updateTransactionId];

    NSString * errorMessage = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
    dispatch_async(dispatch_get_main_queue(),  ^{
        
        [self transactionDeclinewithErrorMessage:errorMessage];
    });
}

-(void)didFailToRetriveCardInformation
{
    [Appsee addEvent:kPosCardSwipeNotProper];

    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Card swipe" message:@"Please swipe card Properly" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (void)paymentProcessDidFailedWithTimeOut
{

}

-(IBAction)swipeProcessButton:(id)sender
{
//    lblProcessType.text = @"SWIPE";
    _txtAccountNumber.enabled = NO;
    _txtExpirationDate.enabled = NO;
    _txtCVNum.enabled = NO;
    _txtCardName.enabled = NO;

    _txtAccountNumber.text = @"";
    _txtExpirationDate.text = @"";
    _txtCVNum.text = @"";
    _txtCardName.text = @"";

    _btn_Send.enabled = NO;
    _btn_Send.hidden = YES;
    _txtCVNum.hidden = YES;
    _txtCardName.hidden = NO;

    _btnSwipeProcess.selected = YES;
    _manualProcessbutton.selected = NO;
    
    CGRect frame = _cancelButton.frame;
    frame.origin.x = 191;
    _cancelButton.frame = frame;
}

-(IBAction)manualProcessButton:(id)sender
{
    [Appsee addEvent:kPosManualCardProcessing];
//    lblProcessType.text = @"MANUAL PROCESS";
    _txtCVNum.hidden = NO;
    _txtCardName.hidden = YES;
    _btnSwipeProcess.selected = NO;
    _manualProcessbutton.selected = YES;

    CGRect frame = _cancelButton.frame;
    frame.origin.x = 25;
    _cancelButton.frame = frame;
    
    NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
      //  gateWay = @"CardFlight";
    if ([gateWay isEqualToString:@"CardFlight"])
    {
        [self addPaymentView];
        
        [UIView animateWithDuration:0.5 animations:^{
            _uvManualProcess.hidden = NO;
            _uvManualProcess.frame = CGRectMake(55, 58, _uvManualProcess.frame.size.width, _uvManualProcess.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];

        _uvSwipeView.hidden = YES;
        _sendManualCardFlight.enabled = NO;
        [_sendManualCardFlight setTitleColor:[UIColor grayColor]forState:UIControlStateNormal];
    }
    else
    {
        _txtAccountNumber.enabled = YES;
        _txtExpirationDate.enabled = YES;
        _txtCVNum.enabled = YES;
        _txtCardName.enabled = YES;
        _btn_Send.enabled = YES;
        _btn_Send.hidden = NO;
    }
   
}


-(IBAction)manualSend:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
//        if (_card) {
//            NSString *sInvAmt=[lblAmount.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
//            NSString *sInvAmtRemove=[NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:sInvAmt].floatValue];
//            float amountTopass=[sInvAmtRemove floatValue];
//            
//            NSMutableDictionary *cardData = [[NSMutableDictionary alloc]init];
//            [cardData setObject:_card forKey:@"CardData"];
//            
//            [self.cardDeviceManager processCardFlightManual:cardData WithAmount:amountTopass withAccountNo:[NSString stringWithFormat:@"XXXX XXXX XXXX %@",_card.last4]];
//        }
    });
   
   
}
-(IBAction)manualProcessCancel:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        _uvManualProcess.frame = CGRectMake(55, 1000, _uvManualProcess.frame.size.width, _uvManualProcess.frame.size.height);
        
    } completion:^(BOOL finished) {
        _uvManualProcess.hidden = YES;
    }];
    
    _uvSwipeView.hidden = NO;
//    _card = nil;
    _sendManualCardFlight.enabled = NO;
    [_sendManualCardFlight setTitleColor:[UIColor grayColor]forState:UIControlStateNormal];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _txtAccountNumber.text = [_txtAccountNumber.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

    if(_txtAccountNumber.text.length > 0)
    {
        _btn_Send.enabled = YES;
    }
    else
    {
        _btn_Send.enabled = NO;
    }
    [textField resignFirstResponder];
    return YES;
}




-(void)didEnterCreditCardValue :(NSString *)value
{
    if (currentTextFieldTag == CREDIT_ACCOUNT_TEXT)
    {
        _txtAccountNumber.text = value;
    }
    else if (currentTextFieldTag == CREDIT_CVV_NUMBER_TEXT)
    {
        _txtCVNum.text = value;
    }
    else if (currentTextFieldTag == CREDIT_EXPIRATION_DATE_TEXT)
    {
        _txtExpirationDate.text = value;
    }
    else
    {
    }
    currentTextFieldTag = 0;
    [creditCardPopOverController dismissPopoverAnimated:YES];
    creditCardPopOverController = nil;
}
-(void)didCancelCreditcardPopOver
{
    currentTextFieldTag = 0;
    [creditCardPopOverController dismissPopoverAnimated:YES];
    creditCardPopOverController = nil;
}




-(void)processVoidForCurrentTransctionId
{
    NSLog(@"processVoidForCurrenTransctionId");
    
    NSString *extData = [NSString stringWithFormat:@"<TransactionID><Target>%@</Target></TransactionID>",currentCreditTransactionId];
    
    NSString *transDetails = [NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=&InvNum=&PNRef=&Zip=&Street=&CVNum=&ExtData=%@",[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Username"],[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"password"],@"Void",extData];
    
    NSLog(@"transDetails = %@",transDetails);
    
    NSString *sInvAmt=[_lblAmount.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    NSString *sInvAmtRemove=[NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:sInvAmt].floatValue];
    float amountTopass=sInvAmtRemove.floatValue;
    NSLog(@"amountTopass = %f",amountTopass);
    
    [self processVoidAdjustment:[self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"URL"] details:transDetails withAmount:amountTopass];
}
- (void)processVoidAdjustment:(NSString *)url details:(NSString *)details withAmount:(float)Amount
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",@"ProcessCreditCard"]];
    NSLog(@"url = %@",url);
    
    NSURL *gateWayUrl=[NSURL URLWithString:url];
    
    NSData *postData=[details dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)postData.length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = gateWayUrl;
    request.HTTPMethod = @"POST";
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = postData;
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [_activityIndicator hideActivityIndicator];
    
    if(urlData)
    {
        NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseString from Void = %@",responseString);
        DDXMLElement *RespMSGElement = [self getValueFromXmlResponse:responseString string:@"RespMSG"];
        if ([RespMSGElement.stringValue isEqualToString:@"Approved"])
        {
            self.rmsDbController.isVoidTrasnaction = FALSE;
            
            /*!
             *  incerement completedCreditCardSwipe count when Tranaction is void successfully.
             */
            
//            self.paymentCardData.completedCreditCardSwipe++;
            [self updateTransactionId];

            [self transactionDeclinewithErrorMessage:@"Previous transction void successfully.please swipe again."];
        }
        else
        {
            
            self.rmsDbController.isVoidTrasnaction = TRUE;

            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                /*!
                 *  incerement completedCreditCardSwipe count when Tranaction is failed to void and user denied to retry.
                 */
                
//                self.paymentCardData.completedCreditCardSwipe++;
                [self updateTransactionId];

            };
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [self processVoidForCurrentTransctionId];
            };
            
            NSString *rapidRMSErrorMsg = [NSString stringWithFormat:@"%@. Do you want to retry for void?",RespMSGElement.stringValue];
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:rapidRMSErrorMsg buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        }
    }
    else
    {
        /// Need To Disccuss For this Step..
        self.rmsDbController.isVoidTrasnaction = TRUE;

        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            /*!
             *  incerement completedCreditCardSwipe count when Tranaction is failed to void due to internet connection and user denied to retry.
             */
//            self.paymentCardData.completedCreditCardSwipe++;
            [self updateTransactionId];

        };
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self processVoidForCurrentTransctionId];
        };
        
        NSString *rapidRMSErrorMsg = [NSString stringWithFormat:@"Connection has dropped. Do you want to retry for void?"];
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:rapidRMSErrorMsg buttonTitles:@[@"No,Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}



-(void)launchRCRSignatureCaptureWithCardInfo:(NSDictionary *)cardInfo;
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignatureViewController *signatureViewController = [storyBoard instantiateViewControllerWithIdentifier:@"SignatureDashBoard"];
    signatureViewController.delegate = self;
    
    NSMutableDictionary *signDict = [[NSMutableDictionary alloc] init];
    signDict[@"CardInfo"] = cardInfo;
    signDict[@"TipInfo"] = self.tipInfo;
    signDict[@"AmountInfo"] = self.billInfo;
    signatureViewController.signatureDataDict = signDict;
    signatureViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:signatureViewController animated:YES completion:Nil];
}
- (void)signatureViewController:(SignatureViewController *)viewController didSign:(NSData *)signatur signature:(UIImage *)signatureImage withCustomerDisplayTipAmount:(CGFloat )tips
{
    [self.paymentCreditModeData setCustomerImageAtIndex:self.currentIndexPath withDetail:signatureImage];
    [self.paymentCreditModeData setCustomerDiplayTipAmountAtIndex:self.currentIndexPath withDetail:@(tips)];
    if (tips > 0) {
        [self.paymentCardData setIsTipAdjustmentApplicable:@(1)];
    }
    
    /// update payment data object in database.....
    [self.tenderProcessCreditManager updatePaymentDataWithCurrentStep];

    [self nextCardSwipe];
}
- (void) manualReceipt
{
    [self.paymentCreditModeData setManualReceiptAtIndex:self.currentIndexPath];
    
    /// update payment data object in database.....
    [self.tenderProcessCreditManager updatePaymentDataWithCurrentStep];

    [self nextCardSwipe];

}

-(void)launchRCDSignatureCaptureWithCardInfo:(NSDictionary *)cardInfo;
{
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
    dictTemp[@"SignatureView"] = @"1";
    NSMutableArray *arraycardInfo = [[NSMutableArray alloc] init];
    [arraycardInfo addObject:cardInfo];
    dictTemp[@"cardInfo"] = arraycardInfo;
    dictTemp[@"tipInfo"] = self.tipInfo;
    dictTemp[@"AmountInfo"] = self.billInfo;
    [self.crmController writeDictionaryToCustomerDisplay:dictTemp];
    
    customerSignatureAlertVC = [[CustomerSignatureAlertVC alloc] initWithNibName:@"CustomerSignatureAlertVC" bundle:NULL];
    customerSignatureAlertVC.customerSignatureAlertDelegate = self;
    customerSignatureAlertVC.creditCardDictionary = cardInfo;
    customerSignatureAlertVC.rcdSignatureDict = [dictTemp mutableCopy];
    customerSignatureAlertVC.billAmountDictionary = self.billInfo;
    customerSignatureAlertVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:customerSignatureAlertVC animated:YES completion:Nil];
}

- (void)didSignSignature:(NSData *)signature signature:(UIImage *)signatureImage withCustomerDisplayTipAmount:(CGFloat )tip
{
    NSDictionary *signatureDictionary = @{
                                          @"SignatureRecievedStatus":@"Signature Image Recieved",
                                          };
    [self.crmController writeDictionaryToCustomerDisplay:signatureDictionary];
    
    [self.paymentCreditModeData setCustomerImageAtIndex:self.currentIndexPath withDetail:signatureImage];
    [self.paymentCreditModeData setCustomerDiplayTipAmountAtIndex:self.currentIndexPath withDetail:@(tip)];
    if (tip > 0) {
        [self.paymentCardData setIsTipAdjustmentApplicable:@(1)];
    }
    
    /// update payment data object in database.....
    [self.tenderProcessCreditManager updatePaymentDataWithCurrentStep];
    
    [self nextCardSwipe];
}


-(void)captureSignatureForCreditCardTransctionWithCreditInfo:(NSDictionary *)creditInfoDictionary
{
    BOOL isRCRSignatureCapture = [self isSpecOptionApplicable:CREDIT_SPEC_POS_SIGN_RECEIPT forPaymentId:currentPaymentId];
    BOOL isRCDSignatureCapture = [self isSpecOptionApplicable:CREDIT_SPEC_CUSTOMER_DISPLAY_SIGN_RECEIPT forPaymentId:currentPaymentId];
    BOOL isRCRPaperSignatureCapture = [self isSpecOptionApplicable:CREDIT_SPEC_RCR_PAPER_SIGNATURE forPaymentId:currentPaymentId];
    
    if (isRCRSignatureCapture) {
        [self launchRCRSignatureCaptureWithCardInfo:creditInfoDictionary];
    }
    else if (isRCDSignatureCapture)
    {
        [self launchRCDSignatureCaptureWithCardInfo:creditInfoDictionary];
    }
    else if (isRCRPaperSignatureCapture)
    {
        [self.paymentCreditModeData setManualReceiptAtIndex:self.currentIndexPath];
        [self nextCardSwipe];
    }
    else
    {
        [self nextCardSwipe];
    }
}


-(BOOL)isSpecOptionApplicable:(int)specOption forPaymentId:(NSNumber *)paymentId
{
    BOOL isApplicable = FALSE;
    NSInteger ipay = paymentId.integerValue;
    
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
    return isApplicable;
}




- (DDXMLElement *)getValueFromXmlResponse:(NSString *)responseString string:(NSString *)string
{
    responseString = [responseString stringByReplacingOccurrencesOfString:@" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://TPISoft.com/SmartPayments/\"" withString:@""];
    DDXMLDocument *fuelTypeDocument = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
    DDXMLNode *rootNode = fuelTypeDocument.rootElement;
    NSString *responseStr = [NSString stringWithFormat:@"/Response/%@",string];
    NSArray *FuelNodes = [rootNode nodesForXPath:responseStr error:nil];
    DDXMLElement *fuelElement = FuelNodes.firstObject;
    return fuelElement;
}

-(IBAction)toggleTimeOfTimeOut:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1) {
        button.tag = 0;
        self.rmsDbController.serviceTimeOut = 20.0;
    }
    else
    {
        button.tag = 1;
        self.rmsDbController.serviceTimeOut = 1.0;

    }
    [_timeOutButton setTitle:[NSString stringWithFormat:@"%ld",(long)self.rmsDbController.serviceTimeOut] forState:UIControlStateNormal];

}



#pragma mark-
#pragma  mark- PAX_DEVICE Delegate Methods

-(void)didConnectedCreditCardReader:(NSString *)deviceName
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        _lblConnectionType.text = @"Pax Connected";
    });
    [self nextCardSwipe];

}
-(void)didDisconnectedCreditCardReader
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        _lblConnectionType.text = @"Pax Connection Failed";
    });
}
-(void)didFinishCreditCardReaderTransctionSuccessfullyWithDetail:(NSDictionary *)creditcardDetail withCreditCardAdditionalDetail:(NSMutableDictionary *)additionalDetailDict
{
    
    // update credit card detail in payment data....
    BOOL isPartiallyApprovedTransaction = [self.paymentCreditModeData setCreditCardDictionaryAtIndex:self.currentIndexPath withDetail:creditcardDetail withAdditionalCreditcardDetail:additionalDetailDict withPaymentData:self.paymentCardData];
    
    /// update payment data object in database.....
    [self.tenderProcessCreditManager updatePaymentDataWithCurrentStep];
    
    if ( isAnyCardApprovedPartially == FALSE && isPartiallyApprovedTransaction == TRUE) {
        isAnyCardApprovedPartially = TRUE;
    }
    
    dispatch_async(dispatch_get_main_queue(),  ^{
        [self paxCreditCardLogWithDetail:[self insertPaxCreditCardLogWithDetail:creditcardDetail withCreditCardAdditionalDetail:additionalDetailDict]];
    });
    
    
    if ([additionalDetailDict objectForKey:@"SN"]) {
        _paxSerialNo = [NSString stringWithFormat:@"%@ ",[additionalDetailDict valueForKey:@"SN"]];
    }
    NSDictionary *dictPaxDevice = @{
                                    @"PaxConnectionStatus" : @(1),
                                    @"PaxSerialNumber" : [NSString stringWithFormat:@"%@",_paxSerialNo],
                                    };
    [[NSUserDefaults standardUserDefaults] setObject:dictPaxDevice forKey:@"PaxDeviceStatus"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if (self.paymentCardData.creditSwipeArrayofPaymentModeItem.count == 0 && isAnyCardApprovedPartially == FALSE) {
        [self.tenderProcessCreditManager insertInvoiceToLocalDatabase];
    }
    
    NSLog(@"didFinishCreditCardReaderTransctionSuccessfullyWithDetail");
    
    currentStep = Pax_SignatureCapture;
    [self signatureCaptureForCreditCardDeviceWithCreditInfo:creditcardDetail withCreditCardAdditionalDetail:additionalDetailDict];
}

-(NSMutableDictionary *)insertPaxCreditCardLogWithDetail:(NSDictionary *)creditcardDetail withCreditCardAdditionalDetail:(NSMutableDictionary *)additionalDetailDict

{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];

    
    NSString *sInvAmt=[_lblAmount.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    NSString *sInvAmtRemove=[NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:sInvAmt].floatValue];
    
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
    dict[@"TransactionId"] = currentCreditTransactionId;
    dict[@"TransType"] = currentTransactionCardIntType;
    dict[@"Amount"] = sInvAmtRemove;
    dict[@"InvNum"] = self.invoiceNo;
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
    dict[@"DeviceNo"] = self.paxSerialNo;
    dict[@"BatchNo"] = [creditcardDetail valueForKey:@"BatchNo"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"TransactionStatus"] = @(TransactionStatusApproved);
    dict[@"ApproveAmount"] = [creditcardDetail valueForKey:@"ApprovedAmount"];
    dict[@"CardName"] = [creditcardDetail valueForKey:@"CardHolderName"];
    dict[@"CardType"] = [creditcardDetail valueForKey:@"CardType"];
    dict[@"Server"] = transactionServer;
    dict[@"PaymentType"] = currentTransactionCardIntType;
    return dict;

}


-(NSMutableDictionary *)insertPaxCreditCardLogWithDetail:(NSError *)error withResponseMessage:(PaxResponse *)response
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    PaymentModeItem *paymentModeItem = ( PaymentModeItem *)(self.paymentCreditModeData.creditPaymentArray)[self.currentIndexPath];
    [self.paymentCreditModeData updatePaymentModeItem:paymentModeItem withTransactionId:currentCreditTransactionId withStatus:@(Decline)];

    NSString *sInvAmt=[_lblAmount.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    NSString *sInvAmtRemove=[NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:sInvAmt].floatValue];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    
    dict[@"Id"] = @(0);
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"TransactionId"] = currentCreditTransactionId;
    dict[@"TransType"] = currentTransactionCardIntType;
    dict[@"Amount"] = sInvAmtRemove;
    dict[@"InvNum"] = self.invoiceNo;
    dict[@"MagData"] = @"";
    dict[@"ExtData"] = @"";
    if (response) {
        dict[@"RespMSG"] = [NSString stringWithFormat:@"%@",response.responseMessage];
    }
    else
    {
        dict[@"RespMSG"] = @"Decline";
    }
    dict[@"Message"] = @"Decline";
    dict[@"AuthCode"] = @"";
    dict[@"HostCode"] = @"";
    dict[@"CommercialCard"] = @"";
    dict[@"GateWayType"] = @"Pax";
    if (error == nil)
    {
        dict[@"Response"] = @"";
    }
    else{
        dict[@"Response"] = [NSString stringWithFormat:@"%@",error.localizedDescription];

    }
    dict[@"CreatedDate"] = currentDateTime;
    dict[@"CardNo"] = @"";
    dict[@"DeviceNo"] = self.paxSerialNo;
    dict[@"BatchNo"] = @"";
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"TransactionStatus"] = @(TransactionStatusDeclined);
    dict[@"ApproveAmount"] = @(0.00);
    dict[@"CardName"] = @"";
    dict[@"CardType"] = @"";
    dict[@"Server"] = transactionServer;
    dict[@"PaymentType"] = currentTransactionCardIntType;

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

}

-(void)createPaxPaymentGatewayResponseLogWithDetail:(NSDictionary *)creditcardDetail withCreditCardAdditionalDetail:(NSMutableDictionary *)additionalDetailDict
{
    PaymentGatewayResponse *paymentGatewayResponseObject = [[PaymentGatewayResponse alloc]init];
    
    NSMutableDictionary *paxResponceDict = [[NSMutableDictionary alloc]init];
    paxResponceDict[@"CreditcardDetail"] = creditcardDetail;
    paxResponceDict[@"AdditionalDetailDict"] = additionalDetailDict;
    
    paymentGatewayResponseObject.transactionStatus = YES;
    paymentGatewayResponseObject.paymentGateWayName = @"PAX";
    paymentGatewayResponseObject.paymentGateWayResponse = [NSString stringWithFormat:@"%@",paxResponceDict];

    [self.paymentCardData.paymentGatewayResponse addObject:paymentGatewayResponseObject];
    
    
}

-(BOOL)isSignatureRequireForThisCard:(NSDictionary *)additionalDetailDict
{
    BOOL isSignatureRequireForThisCard = TRUE;
    
    if ([currentTransactionCardIntType isEqualToString:@"Debit"]) {
        isSignatureRequireForThisCard = FALSE;
        return isSignatureRequireForThisCard;
    }
    if (additionalDetailDict != nil && additionalDetailDict[@"CVM"] )
    {
        if ([[additionalDetailDict valueForKey:@"CVM"] integerValue] == FailCVMProcessing ||
            [[additionalDetailDict valueForKey:@"CVM"] integerValue] == PlaintextOfflinePINandSignature || [[additionalDetailDict valueForKey:@"CVM"] integerValue] == EncipheredOfflinePINVerificationandSignature || [[additionalDetailDict valueForKey:@"CVM"] integerValue] == Signature)  {
            isSignatureRequireForThisCard = TRUE;
        }
        else
        {
            isSignatureRequireForThisCard = FALSE;
        }
    }
   
    return isSignatureRequireForThisCard;
}


-(void)signatureCaptureForCreditCardDeviceWithCreditInfo:(NSDictionary *)creditInfoDictionary withCreditCardAdditionalDetail:(NSMutableDictionary *)additionalDetailDict{
    if ([self isSignatureRequireForThisCard:additionalDetailDict] == TRUE) {
        BOOL isRCRSignatureCapture = [self isSpecOptionApplicable:CREDIT_SPEC_POS_SIGN_RECEIPT forPaymentId:currentPaymentId];
        BOOL isRCDSignatureCapture = [self isSpecOptionApplicable:CREDIT_SPEC_CUSTOMER_DISPLAY_SIGN_RECEIPT forPaymentId:currentPaymentId];
        BOOL isPaxSignatureCapture = [self isSpecOptionApplicable:CREDIT_SPEC_PAX_SIGNATURE forPaymentId:currentPaymentId];
        BOOL isRCRPaperSignatureCapture = [self isSpecOptionApplicable:CREDIT_SPEC_RCR_PAPER_SIGNATURE forPaymentId:currentPaymentId];

//        if ([[creditInfoDictionary valueForKey:@"EntryMode"] integerValue] == Chip || [currentTransactionCardIntType isEqualToString:@"Debit"]) {
//            [_activityIndicator hideActivityIndicator];
//            [self nextCardSwipe];
//        }
//        else
        if (isPaxSignatureCapture)
        {
            dispatch_async(dispatch_get_main_queue(),  ^{
                [_activityIndicator updateLoadingMessage:@"Waiting for signature....."];
                [self updateCoustmerDisplayCreditCardMessage:@"Waiting for signature....."];
                
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.creditCardReaderManager creditCardSignatureRequestWithId:PaxSignatureCapture_Request];
            });
            
        }
        else if (isRCRSignatureCapture) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_activityIndicator hideActivityIndicator];
                [self launchRCRSignatureCaptureWithCardInfo:creditInfoDictionary];
            });
        }
        else if (isRCDSignatureCapture)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_activityIndicator hideActivityIndicator];
                [self launchRCDSignatureCaptureWithCardInfo:creditInfoDictionary];
            });
        }
        else if (isRCRPaperSignatureCapture)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.paymentCreditModeData setManualReceiptAtIndex:self.currentIndexPath];
                [self nextCardSwipe];
            });
        }
        else
        {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_activityIndicator hideActivityIndicator];
                [self nextCardSwipe];
            });
        }

    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_activityIndicator hideActivityIndicator];
            [self nextCardSwipe];
        });
    }
}
-(void)didFailTransction:(NSError *)error response:(PaxResponse *)response
{
    NSString *errorMessage = @"";
    NSString *infoMessage = @"Info";
    
    if (response) {
        infoMessage = @"Pax response error";
        errorMessage = response.responseMessage;
    }
    else if (error)
    {
        if (currentStep == Pax_CardSwipe) {
            infoMessage = @"Pax cardSwipe error";
        }
        else if (currentStep == Pax_DeviceIntialize)
        {
            infoMessage = @"Pax intialize error";
        }
        else
        {
            infoMessage = @"Error";
        }
        errorMessage = error.localizedDescription;
    }
    else
    {
        errorMessage = @"Error occur in credit card trasnaction process. Do you want to retry?";
    }
    if (currentStep == Pax_CardSwipe)
    {
        
        [self paxCreditCardLogWithDetail:[self insertPaxCreditCardLogWithDetail:error withResponseMessage:response]];
        
    }
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [_activityIndicator hideActivityIndicator];
    };
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        if (currentStep == Pax_CardSwipe) {
            self.currentIndexPath --;
            [self nextCardSwipe];
        }
        else if (currentStep == Pax_DeviceIntialize)
        {
            self.creditCardReaderManager = [[CreditCardReaderManager alloc] initWithDelegate:self withPaxConnectionStatus:self.isPaxConnectedToRapid];
        }

    };
    [self.rmsDbController popupAlertFromVC:self title:infoMessage message:errorMessage buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

#pragma mark -
#pragma  mark- SIGNATURE CAPTURE METHODS

-(void)didFinishSignatureImage:(UIImage *)signatureImage
{
    NSLog(@"didFinishSignatureImage");
    [_activityIndicator hideActivityIndicator];
    [self updateSignatureImageToPaymentModeData:signatureImage];
}
-(void)didFailSignatureProcess
{
}
- (void)displayAlertInCreditCardProcessingWithTitle:(NSString*)title withMessage:(NSString *)message withButtonTitles:(NSArray *)buttonTitles withButtonHandlers:(NSArray *)buttonHandlers
{
    [self.rmsDbController popupAlertFromVC:self title:title message:message buttonTitles:buttonTitles buttonHandlers:buttonHandlers];
}


-(void)updateSignatureImageToPaymentModeData:(UIImage *)signatureImage
{
    NSLog(@"updateSignatureImageToPaymentModeData");
    [self.paymentCreditModeData setCustomerImageAtIndex:self.currentIndexPath withDetail:signatureImage];
    NSLog(@"updateSignatureImageToPaymentModeData with nextCardSwipe");
    
    /// update payment data object in database.....
    [self.tenderProcessCreditManager updatePaymentDataWithCurrentStep];

    [self nextCardSwipe];
}

- (void)continueNextCardWithoutSignature
{
    [_activityIndicator hideActivityIndicator];
    [self.paymentCreditModeData setManualReceiptAtIndex:self.currentIndexPath];
    
    /// update payment data object in database.....
    [self.tenderProcessCreditManager updatePaymentDataWithCurrentStep];

    [self nextCardSwipe];
}
- (void)didShowPaxSettingVC
{
    PaxDeviceViewController *paxDeviceViewController = [[PaxDeviceViewController alloc] initWithNibName:@"PaxDeviceViewController" bundle:NULL];
    paxDeviceViewController.paxDeviceSettingVCDelegate = self;
    paxDeviceViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:paxDeviceViewController animated:YES completion:Nil];
}

-(void)checkPaxConfiguration
{
    NSDictionary *dictDevice = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaxDeviceConfig"];
    if (dictDevice != nil)
    {
        return;
    }
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self didShowPaxSettingVC];
    };
       NSString *rapidRMSErrorMsg = [NSString stringWithFormat:@"Credit card reader setting has not configured. Please configure it."];
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:rapidRMSErrorMsg buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}
- (void)didUpdatePaxDeviceSetting
{
    self.creditCardReaderManager = [[CreditCardReaderManager alloc] initWithDelegate:self withPaxConnectionStatus:self.isPaxConnectedToRapid];
    currentStep = Pax_DeviceIntialize;
}


-(void)didSignatureHereWithCardInfo:(NSDictionary *)cardInfo
{
    NSDictionary *signatureDictionary = @{
                                          @"SignatureRecievedStatus":@"Signature Image Recieved",
                                          };
    
    [self.crmController writeDictionaryToCustomerDisplay:signatureDictionary];

    [self launchRCRSignatureCaptureWithCardInfo:cardInfo];

}
-(void)didManualReceiptForCustomerDisplay
{
    [self manualReceipt];
}

@end
