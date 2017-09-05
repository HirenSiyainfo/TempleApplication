//
//  CustomerSignatureAlertVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/3/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CustomerSignatureAlertVC.h"

@interface CustomerSignatureAlertVC ()
{
    BOOL isSignatureScreenOpen;
    BOOL isSignatureCapturing;
    NSTimer *signatureScreenOpenTimer;
    NSTimer *customerDisplayConnectionTimer;
}

@property(nonatomic , weak) IBOutlet UILabel *lblAccountNo;
@property(nonatomic , weak) IBOutlet UILabel *lblcardholderName;
@property(nonatomic , weak) IBOutlet UILabel *lblAuthCode;
@property(nonatomic , weak) IBOutlet UILabel *lblTotalPaid;
@property(nonatomic , weak) IBOutlet UILabel *lblItemCount;
@property(nonatomic , weak) IBOutlet UILabel *lblSubTotal;
@property(nonatomic , weak) IBOutlet UILabel *lblDiscount;
@property(nonatomic , weak) IBOutlet UILabel *lblTax;
@property(nonatomic , weak) IBOutlet UILabel *lblCardType;
@property(nonatomic , weak) IBOutlet UIButton *btnRequestSign;


@property (nonatomic, strong) RcrController *crmController;


@end

@implementation CustomerSignatureAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.crmController = [RcrController sharedCrmController];
    isSignatureScreenOpen = false;
    [self startSignatureScreenOpenTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isSignatureScreenOpened:) name:@"SignatureScreenNotification" object:nil];

    // Do any additional setup after loading the view from its nib.
}

-(void)startSignatureScreenOpenTimer
{
    signatureScreenOpenTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                target:self
                                                              selector:@selector(checkSignatureScreenOpenStatus)
                                                              userInfo:nil
                                                               repeats:NO];
}

-(void)startCustomerDisplayConnectionTimer
{
    customerDisplayConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:7.0
                                                                target:self
                                                              selector:@selector(checkCustomerDisplayConnection)
                                                              userInfo:nil
                                                               repeats:YES];
    NSLog(@"signture capturing status time: %@",[NSDate date]);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self configureCutomerSignatureAlertVC];
    [self updateUIWithBillAmountDetails];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDisplaySignatureResposne:) name:@"CustomerDisplaySignatureResponse" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CustomerDisplaySignatureResponse" object:nil];
}

-(IBAction)requestSignatureClicked:(id)sender
{
    self.btnRequestSign.enabled = false;
    [self startSignatureScreenOpenTimer];
    [self.crmController writeDictionaryToCustomerDisplay:_rcdSignatureDict];
}

-(void)checkSignatureScreenOpenStatus
{
    if(!isSignatureScreenOpen)
    {
        self.btnRequestSign.enabled = true;
    }
}

-(void)customerDisplaySignatureResposne:(NSNotification *)notification
{
    NSDictionary *signatureInformation = notification.object;
    NSData *signatureData = signatureInformation[@"CustomerSignatureImage"];
    UIImage *signatureImage = [UIImage imageWithData:signatureData];
    CGFloat tipsAmount = 0.00;
    
    if (signatureInformation[@"TipAmount"])
    {
        tipsAmount = [signatureInformation[@"TipAmount"] floatValue];
    }
    [self dismissViewControllerAnimated:TRUE completion:^{
        [self.customerSignatureAlertDelegate didSignSignature:signatureData signature:signatureImage withCustomerDisplayTipAmount:tipsAmount];
    }];
   
}
-(void)isSignatureScreenOpened:(NSNotification *)notification {
    self.btnRequestSign.enabled = false;
    isSignatureScreenOpen = true;
    isSignatureCapturing = false;
    [self stopCustomerDisplayConnectionTimer];
    [self startCustomerDisplayConnectionTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signatureCapturingNotification:) name:@"SignatureCapturingNotification" object:nil];
}

- (void)signatureCapturingNotification:(NSNotification *)notification {
    isSignatureCapturing = true;
}

-(void)checkCustomerDisplayConnection
{
    NSLog(@"Customer Display Connection Timer: %@",[NSDate date]);
    if(!isSignatureCapturing)
    {
        isSignatureScreenOpen = false;
        self.btnRequestSign.enabled = true;
        [self stopCustomerDisplayConnectionTimer];
    }
    else {
        isSignatureCapturing = false;
    }
}

- (void)stopCustomerDisplayConnectionTimer {
    NSLog(@"Stop Customer Display Connection Timer: %@",[NSDate date]);
    [customerDisplayConnectionTimer invalidate];
    customerDisplayConnectionTimer = nil;
}

-(void)configureCutomerSignatureAlertVC
{
    _lblAccountNo.text = [NSString stringWithFormat:@"%@", [self.creditCardDictionary valueForKey:@"AccNo"]];
    
    if([[self.creditCardDictionary valueForKey:@"CardHolderName"]isEqualToString:@""])
    {
        _lblcardholderName.text = @"N/A";
    }
    else
    {
        _lblcardholderName.text = [NSString stringWithFormat:@"%@", [[self.creditCardDictionary valueForKey:@"CardHolderName"] uppercaseString]];
    }
    _lblAuthCode.text = [NSString stringWithFormat:@"%@", [self.creditCardDictionary valueForKey:@"AuthCode"]];
    
    if([[self.creditCardDictionary valueForKey:@"CardType"]isEqualToString:@""])
    {
        _lblCardType.text = @"N/A";
    }
    else
    {
        _lblCardType.text = [NSString stringWithFormat:@"%@", [self.creditCardDictionary valueForKey:@"CardType"]];
    }
}

-(void)updateUIWithBillAmountDetails
{
    _lblTotalPaid.text = [NSString stringWithFormat:@"%@", [self.billAmountDictionary valueForKey:@"InvoiceTotal"]];
    _lblItemCount.text = [NSString stringWithFormat:@"%@", [self.billAmountDictionary valueForKey:@"TotalItemCount"]];
    _lblSubTotal.text = [NSString stringWithFormat:@"%@", [self.billAmountDictionary valueForKey:@"InvoiceSubTotal"]];
    _lblDiscount.text = [NSString stringWithFormat:@"%@", [self.billAmountDictionary valueForKey:@"InvoiceDiscount"]];
    _lblTax.text = [NSString stringWithFormat:@"%@", [self.billAmountDictionary valueForKey:@"InvoiceTax"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)manualRecriptTapped:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        [self.customerSignatureAlertDelegate didManualReceiptForCustomerDisplay];
    }];
}

- (IBAction)signatureTapped:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        [self.customerSignatureAlertDelegate didSignatureHereWithCardInfo:self.creditCardDictionary];
    }];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
