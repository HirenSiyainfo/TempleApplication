//
//  GiftCardCheckBalanceVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 29/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GiftCardCheckBalanceVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "GiftCardReceiptPrint.h"

#define AMOUNT_CHARECTERS @"0123456789."
#define CARD_CHARECTERS @"0123456789"


@interface GiftCardCheckBalanceVC ()
{
    NSArray *array_port;
    NSInteger selectedPort;
    NSMutableDictionary *giftCardDictionary;

}

@property(nonatomic,weak) IBOutlet UIView *firstView;
@property(nonatomic,weak) IBOutlet UIView *secondView;
@property(nonatomic,weak) IBOutlet UIView *mainView;
@property(nonatomic,weak)IBOutlet UITextField *txtGiftCardNo;
@property(nonatomic,weak)IBOutlet UITextField *txtAmount;
@property(nonatomic,weak)IBOutlet UITextField *txtLoadAmount;
@property(nonatomic,weak)IBOutlet UILabel *lblAmount;
@property(nonatomic,weak)IBOutlet UILabel *lblTitle;
@property(nonatomic,weak)IBOutlet UILabel *lblUserName;
@property(nonatomic,weak)IBOutlet UILabel *lblEmail;
@property(nonatomic,weak)IBOutlet UILabel *lblUsernam1;
@property(nonatomic,weak)IBOutlet UILabel *lblemail1;
@property(nonatomic,weak)IBOutlet UIView *viewGiftCardBG;
@property(nonatomic,weak)IBOutlet UIView *viewTransDetial;
@property(nonatomic,weak)IBOutlet UITableView *tblTransDetail;
@property(nonatomic,weak)IBOutlet UIButton *btnCheckBalance;


@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property(nonatomic,strong) RapidWebServiceConnection *checkGiftcardBalanceConnection;
@property(nonatomic,strong) RapidWebServiceConnection *checkRapidGiftCardBalanceConnection;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property(nonatomic,strong)NSMutableArray *transDetailArray;

@end

@implementation GiftCardCheckBalanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewTransDetial setHidden:YES];
    giftCardDictionary = [[NSMutableDictionary alloc]init];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    if(!self.isFromTender){
        [self registerNotifications];
        if(self.isLoad){
            
            self.lblAmount.text = @"Load Amount";
            self.lblTitle.text = @"LOAD BALANCE";
        }
        else{
            
            self.lblTitle.text = @"CHECK BALANCE";
        }
    }
    else
    {
        self.lblTitle.text = @"Gift Card Process";
        self.txtLoadAmount.enabled = NO;
        self.lblAmount.text = @"Amount";
        
    }
    
    if(_dictCustomerInfo){
        
        if(self.isFromTender){
            _lblUserName.text = [NSString stringWithFormat:@"Customer Name : %@ %@",[_dictCustomerInfo valueForKey:@"FirstName"],[_dictCustomerInfo valueForKey:@"LastName"]];
            _lblEmail.text = [NSString stringWithFormat:@"Email : %@",[_dictCustomerInfo valueForKey:@"Email"]];;
        }
        else{
            _lblUserName.text = [NSString stringWithFormat:@"%@ %@",[_dictCustomerInfo valueForKey:@"FirstName"],[_dictCustomerInfo valueForKey:@"LastName"]];
            _lblEmail.text = [NSString stringWithFormat:@"%@",[_dictCustomerInfo valueForKey:@"Email"]];;
        }
    }
    
    if(self.isRefund){
        
        self.lblTitle.text = @"Refund Balance";
        self.lblAmount.text = @"Refund Amount";
    }
    
    uvManualTextField.layer.borderColor = [UIColor blackColor].CGColor;
    uvManualTextField.layer.borderWidth = 1.0;
    uvManualTextField.layer.cornerRadius = 5.0;
   
    _btnCheckBalance.layer.cornerRadius = 5.0;
    _btnCheckBalance.clipsToBounds = YES;
    
    self.checkGiftcardBalanceConnection = [[RapidWebServiceConnection alloc]init];
    self.checkRapidGiftCardBalanceConnection = [[RapidWebServiceConnection alloc]init];
    
    self.isRapidGiftCard = NO;
    [self setFrameForView];

    // Do any additional setup after loading the view.
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    self.isRapidGiftCard = NO;
    
    NSCharacterSet *cs;
    if(textField == self.txtLoadAmount){
        
        cs  = [NSCharacterSet characterSetWithCharactersInString:AMOUNT_CHARECTERS].invertedSet;
        
    }
    else{
        cs  = [NSCharacterSet characterSetWithCharactersInString:CARD_CHARECTERS].invertedSet;
        
    }
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if ([textField.text rangeOfString:string].location != NSNotFound && [string  isEqualToString:@"."])
    {
        return NO;
    }
    else{
        return [string isEqualToString:filtered];
    }
    
    return YES;
    
}


-(void)keyboardWillShow:(NSNotification *)note
{
    //if(self.view.frame.origin.y != -150)
    {
        
        CGFloat kheight = [note.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        CGPoint centerPoint = self.view.center;
        centerPoint.y = self.view.frame.size.height/2 + 280 - kheight;
        self.view.center = centerPoint;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    // if(self.view.frame.origin.y == -150)
    {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        self.view.frame = self.view.bounds;
        [UIView commitAnimations];
        
    }
}

-(IBAction)checkBalancebuttonClick:(id)sender{
    
    [self checkBalanceforGiftCard];
    
}

#pragma mark Submit Click

-(IBAction)submitClick:(id)sender{
    
    if(!self.isRapidGiftCard){
        
        [self CheckRapidGiftCardBeforeCheckBalance];
    }
    
    if(self.isRapidGiftCard){
        
        [self checkBalanceforGiftCard];
    }
}

#pragma mark Check Balance
-(void)checkBalanceforGiftCard{
    
    if([self.txtGiftCardNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else{
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
        [param setValue:self.txtGiftCardNo.text forKey:@"CRDNumber"];
        
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self checkGiftCardBalanceResponse:response error:error];
            });
        };
        
        self.checkRapidGiftCardBalanceConnection = [self.checkRapidGiftCardBalanceConnection initWithRequest:KURL actionName:WSM_CHECK_BALANCE_RAPID_GIFTCARD params:param completionHandler:completionHandler];
        
    }
    
}
- (void)checkGiftCardBalanceResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
               NSMutableDictionary *dictBalance = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                self.lblAmount.hidden = NO;
                self.txtAmount.hidden = NO;
                self.txtAmount.enabled = NO;
                self.transDetailArray = [dictBalance valueForKey:@"Transction"];
                [giftCardDictionary setObject:[dictBalance valueForKey:@"Balance"] forKey:@"GiftCardTotalBalance"];
                [giftCardDictionary setObject:_txtGiftCardNo.text forKey:@"GiftCardNumber"];

                
                [self.tblTransDetail reloadData];
                
                if(self.isFromTender){
                    self.txtAmount.text = [NSString stringWithFormat:@"Available Balance : %@",[self.rmsDbController applyCurrencyFomatter:[dictBalance valueForKey:@"Balance"]]];
                }
                else{
                    self.txtAmount.text = [self.rmsDbController applyCurrencyFomatter:[dictBalance valueForKey:@"Balance"]];
                }
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Error occur while sending details" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

#pragma mark Check Rapid GiftCard

-(void)CheckRapidGiftCardBeforeCheckBalance{
    
    if([self.txtGiftCardNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else{
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
        [param setValue:self.txtGiftCardNo.text forKey:@"CRDNumber"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self checkRapidGiftCardBalanceResponse:response error:error];
        };
        
        self.checkGiftcardBalanceConnection = [self.checkGiftcardBalanceConnection initWithRequest:KURL actionName:WSM_CHECK_RAPID_GIFTCARD params:param completionHandler:completionHandler];
    }
    
}
- (void)checkRapidGiftCardBalanceResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.isRapidGiftCard = YES;
                [self submitClick:nil];
            }
            else if([[response valueForKey:@"IsError"] intValue] == 1)
            {
                self.txtAmount.text = @"-";
                NSString *strMessage = [NSString stringWithFormat:@"This Card is not Active. \n Would you like to add this Card?"];
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [self clearAll:nil];
                    
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [self.giftCardCheckBalancePosDelegate didCancelCheckBalanceGiftCard];
                    [self.giftCardCheckBalancePosDelegate opneLoadGiftCard:self.txtGiftCardNo.text];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:strMessage buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
            }
            else{
                
                self.isRapidGiftCard = NO;
                NSString *strerrorMessage = [NSString stringWithFormat:@"%@",[response valueForKey:@"IsError"]];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:strerrorMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}

-(IBAction)btnPrintClick:(id)sender
{
    if(giftCardDictionary.count > 0 && _txtGiftCardNo.text.length > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSString *portName     = @"";
        NSString *portSettings = @"";
        
        [self SetPortInfo];
        portName     = [RcrController getPortName];
        portSettings = [RcrController getPortSettings];
        
        
        NSDate * date = [NSDate date];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *printDate = [dateFormatter stringFromDate:date];
        NSString *strDate = [NSString stringWithFormat:@"%@" , printDate];
        
        GiftCardReceiptPrint *giftCardReceiptPrint = [[GiftCardReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:giftCardDictionary withReceiptDate:strDate];
        [giftCardReceiptPrint printGiftCardReceiptWithDelegate:self];

    }
        
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
    [GiftCardCheckBalanceVC setPortName:localPortName];
    [GiftCardCheckBalanceVC setPortSettings:array_port[selectedPort]];
}

+ (void)setPortName:(NSString *)m_portName
{
    [RcrController setPortName:m_portName];
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    [RcrController setPortSettings:m_portSettings];
}

-(IBAction)cancelClick:(id)sender{
    
    [self.giftCardCheckBalancePosDelegate didCancelCheckBalanceGiftCard];
}


-(void)setFrameForView{
    
    if(!_dictCustomerInfo){
        
        _mainView.frame = CGRectMake(_mainView.frame.origin.x, _mainView.frame.origin.y, _mainView.frame.size.width, _mainView.frame.size.height - _firstView.frame.size.height + 69);
        
    }
    else{
        
        _mainView.frame = CGRectMake(_mainView.frame.origin.x, _mainView.frame.origin.y-120, _mainView.frame.size.width, _mainView.frame.size.height);
        
    }
}
-(IBAction)clearAll:(id)sender{
    
    self.isRapidGiftCard = NO;
    self.txtAmount.text = @"-";
    self.txtGiftCardNo.text = @"";
    [self.txtGiftCardNo becomeFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if(textField == self.txtGiftCardNo && self.txtGiftCardNo.text.length>0){
        [self submitClick:nil];
    }
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
    [_activityIndicator hideActivityIndicator];

    
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    [_activityIndicator hideActivityIndicator];

    NSString *retryMessage = @"Failed to pass print receipt. Would you like to retry.?";
    [self displayLastInvoicePrintRetryAlert:retryMessage];
}



-(void)displayLastInvoicePrintRetryAlert :(NSString *)message
{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self btnPrintClick:nil];

    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

@end
