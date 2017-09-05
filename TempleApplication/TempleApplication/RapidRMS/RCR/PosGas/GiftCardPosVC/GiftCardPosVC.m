//
//  GiftCardPosVC.m
//  RapidRMS
//
//  Created by Siya on 28/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GiftCardPosVC.h"
#import "RmsDbController.h"
#import "RimsController.h"

#define AMOUNT_CHARECTERS @"0123456789."
#define CARD_CHARECTERS @"0123456789"

@interface GiftCardPosVC ()
{
    
}
@property (nonatomic, weak) IBOutlet UIView *firstView;
@property (nonatomic, weak) IBOutlet UIView *secondView;
@property (nonatomic, weak) IBOutlet UIView *mainView;
@property (nonatomic, weak) IBOutlet UIView *uvManualTextField;
@property (nonatomic, weak) IBOutlet UIButton *btnSubmit;
@property (nonatomic, weak) IBOutlet UITextField *txtConfGiftCardNo;
@property (nonatomic, weak) IBOutlet UITextField *txtAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UILabel *lblEmail;
@property (nonatomic, weak) IBOutlet UITableView *tblTransDetail;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic,strong) RapidWebServiceConnection *checkRapidGiftCardConnection;
@property (nonatomic,strong) RapidWebServiceConnection *payGiftCardConnection;
@property (nonatomic,strong) RapidWebServiceConnection *checkGiftCardBalanceAmountConnection;
@property (nonatomic,strong) RapidWebServiceConnection *saveGiftCardConnection;
@property (nonatomic,strong) RapidWebServiceConnection *genrateGiftCardNoServiceConnection;

@property (nonatomic, strong) RimsController *_rimController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic,strong) NSMutableArray *transDetailArray;
@property (nonatomic,assign) BOOL isRapidGiftCard;
@property (nonatomic,assign) BOOL isCheckBalanceClick;

@end

@implementation GiftCardPosVC
@synthesize dictCustomerInfo,strInvoiceNo;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isCheckBalanceClick = NO;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
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

    if(dictCustomerInfo){
        
        if(self.isFromTender){
            _lblUserName.text = [NSString stringWithFormat:@"Customer Name : %@ %@",[dictCustomerInfo valueForKey:@"FirstName"],[dictCustomerInfo valueForKey:@"LastName"]];
            _lblEmail.text = [NSString stringWithFormat:@"Email : %@",[dictCustomerInfo valueForKey:@"Email"]];;
        }
        else{
            _lblUserName.text = [NSString stringWithFormat:@"%@ %@",[dictCustomerInfo valueForKey:@"FirstName"],[dictCustomerInfo valueForKey:@"LastName"]];
            _lblEmail.text = [NSString stringWithFormat:@"%@",[dictCustomerInfo valueForKey:@"Email"]];;
        }
    }
    if(self.isRefund){
        
        self.lblTitle.text = @"Refund Balance";
        self.lblAmount.text = @"Refund Amount";
    }
    
    _uvManualTextField.layer.borderColor = [UIColor blackColor].CGColor;
    _uvManualTextField.layer.borderWidth = 1.0;
    _uvManualTextField.layer.cornerRadius = 5.0;
    
    self.checkRapidGiftCardConnection = [[RapidWebServiceConnection alloc]init];
    self.payGiftCardConnection = [[RapidWebServiceConnection alloc]init];
    self.checkGiftCardBalanceAmountConnection = [[RapidWebServiceConnection alloc]init];
    self.saveGiftCardConnection = [[RapidWebServiceConnection alloc]init];
    self.genrateGiftCardNoServiceConnection = [[RapidWebServiceConnection alloc]init];
    self.isRapidGiftCard = NO;
    [self setFrameForView];
}


-(IBAction)manualProcessButton:(id)sender{
    
    [_btnSubmit setHidden:NO];
}

-(void)setFrameForView{
    
     if(!dictCustomerInfo){
        
         _mainView.frame = CGRectMake(_mainView.frame.origin.x, _mainView.frame.origin.y, _mainView.frame.size.width, _mainView.frame.size.height - _firstView.frame.size.height +69);
         
     }
     else{
         
         _mainView.frame = CGRectMake(_mainView.frame.origin.x, _mainView.frame.origin.y-120, _mainView.frame.size.width, _mainView.frame.size.height);

     }
}
#pragma mark Submit Click

-(IBAction)submitClick:(id)sender{
 
    self.isCheckBalanceClick = NO;
    
            if(!self.isFromTender){
                
                if(self.isLoad){
                    
                    [self loadBalanceWithAmount];
                }
            }
            else{
                
                [self checkBalancebeforePayment];
            }
   // }
}

-(IBAction)checkBalancebuttonClick:(id)sender{

    if(!self.isRapidGiftCard){
        self.isCheckBalanceClick = YES;
        [self CheckRapidGiftCard];
    }
    if(self.isRapidGiftCard){
        
        [self checkBalance];
    }
}

#pragma mark Check Rapid GiftCard

-(void)CheckRapidGiftCard{
    
    if([self.txtGiftCardNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else if([self.txtConfGiftCardNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Confirm Gift Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else if(![self.txtConfGiftCardNo.text isEqualToString:self.txtGiftCardNo.text]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Correct Gift Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else{
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
        [param setValue:self.txtGiftCardNo.text forKey:@"CRDNumber"];
        
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self checkRapidGiftCardResponse:response error:error];
        };
        
        self.checkRapidGiftCardConnection = [self.checkRapidGiftCardConnection initWithRequest:KURL actionName:WSM_CHECK_RAPID_GIFTCARD params:param completionHandler:completionHandler];
        
    }
    
}
- (void)checkRapidGiftCardResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.isRapidGiftCard = YES;
                if(self.isCheckBalanceClick){
                    [self checkBalancebuttonClick:nil];
                    self.isCheckBalanceClick = NO;
                }
                else{
                    [self submitClick:nil];
                }
            }
            else if([[response valueForKey:@"IsError"] intValue] == 1)
            {
                
                if(!self.isFromTender){
                    
                    self.txtAmount.placeholder = @"Balance";
                    
                    NSString *strMessage = [NSString stringWithFormat:@"This card is not active."];
                    
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        //[self clearAll:nil];
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Message" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
                else{
                    
                    NSString *strMessage = [NSString stringWithFormat:@"Decline, This card is not active"];
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Message" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
                
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

-(void)clearAllFields{
    
    self.txtAmount.text = @"";
    self.txtConfGiftCardNo.text = @"";
    self.txtGiftCardNo.text = @"";
    self.txtLoadAmount.text = @"";
    [self.txtGiftCardNo becomeFirstResponder];
}

#pragma mark Pay With Gift Card

-(void)paywithGiftCard{
    
    if([self.txtGiftCardNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
        [param setValue:[self createGiftCardDictionary] forKey:@"ObjGiftStock"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self payGiftCardResponse:response error:error];
        };
        
        self.payGiftCardConnection = [self.payGiftCardConnection initWithRequest:KURL actionName:WSM_PROCESS_RAPID_GIFTCARD params:param completionHandler:completionHandler];
        
    }
}
- (void)payGiftCardResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                // Sucessfull response
                [self.giftCardPosDelegate successfullDone:self.txtAmount.text];
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

-(NSMutableDictionary *)createGiftCardDictionary{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict[@"Id"] = @"0";
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"CRDNumber"] = self.txtGiftCardNo.text;
    dict[@"SrCRDNo"] = @"";
    dict[@"CustomerId"] = @"0";
    dict[@"CustomerDetail"] = @"0";
    dict[@"Remark"] = @"0";
    
    dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    [dict setValue:strDateTime forKey:@"Createddate"];
    dict[@"InvoiceId"] = @"0";
    
    if(self.txtLoadAmount){
        
        NSString *strAmount = [NSString stringWithFormat:@"%.2f",[self.rmsDbController removeCurrencyFomatter:self.txtLoadAmount.text]];
        dict[@"Amount"] = strAmount;
    }
    else{
        dict[@"Amount"] = @"0";
    }


    return dict;

}

#pragma mark Load Balance

-(void)loadBalanceWithAmount{
    
    if([self.txtGiftCardNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else if([self.txtConfGiftCardNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Confirm Gift Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else if(![self.txtConfGiftCardNo.text isEqualToString:self.txtGiftCardNo.text]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Correct Gift Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else if([self.txtLoadAmount.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Amount" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else
    {

        NSString *strMessage = @"";
        
        if(self.isRefund){
            
            strMessage = [NSString stringWithFormat:@"Refund %@ from card %@?", [self.rmsDbController applyCurrencyFomatter:self.txtLoadAmount.text],self.txtGiftCardNo.text];
        }
        else{
            strMessage = [NSString stringWithFormat:@"Would you like to add %@ to card #%@?", [self.rmsDbController applyCurrencyFomatter:self.txtLoadAmount.text],self.txtGiftCardNo.text];

        }
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
           // [self cancelClick:nil];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
            [self getBalanceForGiftCard];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:strMessage buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        
        
    }
}
- (void)loadGiftCardBalance:(NSNotification *)notification
{
    [_activityIndicator hideActivityIndicator];
    if (notification.object != nil)
    {
        // Barcode wise search result data
        if ([[notification.object valueForKey:@"LoadRapidGiftCardResult"] count] > 0)
        {
            if ([[[notification.object valueForKey:@"LoadRapidGiftCardResult"]  valueForKey:@"IsError"] intValue] == 0)
            {
                // Sucessfull response
                
                 [self.giftCardPosDelegate successfullDone:self.txtAmount.text];
                
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadGiftCardBalance" object:nil];
}

#pragma mark Check Balance
-(void)checkBalance{
    
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
            [self checkGiftCardBalanceAmountResponse:response error:error];
        };
        
        self.checkGiftCardBalanceAmountConnection = [self.checkGiftCardBalanceAmountConnection initWithRequest:KURL actionName:WSM_CHECK_BALANCE_RAPID_GIFTCARD params:param completionHandler:completionHandler];

    }
}
- (void)checkGiftCardBalanceAmountResponse:(id)response error:(NSError *)error
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
                [self.tblTransDetail reloadData];
                
                if(self.isFromTender){
                    
                    self.txtAmount.text = [NSString stringWithFormat:@"Available Balance : %@",[self.rmsDbController applyCurrencyFomatter:[dictBalance valueForKey:@"Balance"]]];
                    
                }
                else{
                    self.txtAmount.hidden = YES;
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Message" message:[NSString stringWithFormat:@"Available Balance : %@",[self.rmsDbController applyCurrencyFomatter:[dictBalance valueForKey:@"Balance"]]] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    
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



#pragma mark Check Balance Before Payment
-(void)checkBalancebeforePayment{
    
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
                [self checkBalancebeforePaymentResponse:response error:error];
            });
        };
        
        self.checkGiftCardBalanceAmountConnection = [self.checkGiftCardBalanceAmountConnection initWithRequest:KURL actionName:WSM_CHECK_BALANCE_RAPID_GIFTCARD params:param completionHandler:completionHandler];
        
    }
}
- (void)checkBalancebeforePaymentResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                // Display the Amount
                NSMutableDictionary *dictBalance = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                
                float loadAmount = [self.rmsDbController removeCurrencyFomatter:self.txtLoadAmount.text];
                
                if([[dictBalance valueForKey:@"Balance"]floatValue] >= loadAmount){
                    
                    [self.giftCardPosDelegate didSuccessfullGiftCardWithAccountNo:self.txtGiftCardNo.text];
                }
                else{
                    
                    self.txtAmount.text = [NSString stringWithFormat:@"Available Balance : %@",[self.rmsDbController applyCurrencyFomatter:[dictBalance valueForKey:@"Balance"]]];
                    
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
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Error occur while sending details" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


#pragma mark Save Gift Card

-(void)saveGiftCard{
    
    if([self.txtGiftCardNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else if([self.txtConfGiftCardNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Confirm Gift Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else if(![self.txtConfGiftCardNo.text isEqualToString:self.txtGiftCardNo.text]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Correct Gift Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else if([self.txtLoadAmount.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Amount" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
        [param setValue:[self createGiftCardDictionary] forKey:@"ObjGiftStock"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self saveGiftCardResponse:response error:error];
        };
        
        self.saveGiftCardConnection = [self.saveGiftCardConnection initWithRequest:KURL actionName:WSM_SAVE_RAPID_GIFTCARD params:param completionHandler:completionHandler];
        
    }
}
- (void)saveGiftCardResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.isRapidGiftCard = YES;
                [self submitClick:nil];
            }
            else{
                
                NSString *strMessage = [NSString stringWithFormat:@"%@",[response valueForKey:@"Data"]];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


-(void)getBalanceForGiftCard{
    if([_txtGiftCardNo.text isEqualToString:@""]){
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else{
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
        [param setValue:_txtGiftCardNo.text forKey:@"CRDNumber"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getBalanceForGiftCard:response error:error];
            });
        };
        
        self.checkGiftCardBalanceAmountConnection = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_CHECK_BALANCE_RAPID_GIFTCARD params:param completionHandler:completionHandler];
        
    }
}
-(void)getBalanceForGiftCard:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *dictBalance = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                dict[@"CardNo"] = self.txtGiftCardNo.text;
                dict[@"CardType"] = @"1";
                dict[@"Remark"] = @"";
                dict[@"LoadAmount"] = self.txtLoadAmount.text;
                dict[@"GiftCardTotalBalance"] = @(self.txtLoadAmount.text.floatValue + [[dictBalance valueForKey:@"Balance"] floatValue]);

                [self.giftCardPosDelegate successfullDoneWithCardDetail:dict];
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



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 25.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"tableview";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    UILabel *lbltemp = (UILabel *)[cell viewWithTag:500];
    [lbltemp removeFromSuperview];
    
    UILabel *lbltemp2 = (UILabel *)[cell viewWithTag:501];
    [lbltemp2 removeFromSuperview];

    
    UILabel *lbltemp3 = (UILabel *)[cell viewWithTag:502];
    [lbltemp3 removeFromSuperview];

    
    UILabel *lblDate = [[UILabel alloc]initWithFrame:CGRectMake(8, 4, 180, 21)];
    lblDate.text = [(self.transDetailArray)[indexPath.row]valueForKey:@"Amount"];
    lblDate.tag=500;
    [cell addSubview:lblDate];
    
    UILabel *lblDebit = [[UILabel alloc]initWithFrame:CGRectMake(205, 4, 180, 21)];
    lblDebit.text = [(self.transDetailArray)[indexPath.row]valueForKey:@"Amount"];
    lblDebit.tag=501;
    [cell addSubview:lblDebit];
    
    UILabel *lblAmount = [[UILabel alloc]initWithFrame:CGRectMake(317, 4, 180, 21)];
    lblAmount.text = [(self.transDetailArray)[indexPath.row]valueForKey:@"Amount"];
    lblAmount.tag=502;
    [cell addSubview:lblAmount];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transDetailArray.count;
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
    if (textField == self.txtConfGiftCardNo && self.txtGiftCardNo == nil) {
        self.GiftCadAutoGenerateBtn.hidden = false;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    else
    {
        BOOL isCharacterChange = [string isEqualToString:filtered];
        if(textField == self.txtGiftCardNo && isCharacterChange)
        {
            NSString * strNewString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            if(strNewString.length > 0) {
                self.GiftCadAutoGenerateBtn.hidden = true;
            }
            else {
                self.GiftCadAutoGenerateBtn.hidden = false;
            }
            
        }
        return isCharacterChange;
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];

    if(self.isFromTender){
        
        if(textField == self.txtGiftCardNo && self.txtGiftCardNo.text.length>0){
            
            [self submitClick:nil];
        }
    }
//    else if((textField == self.txtGiftCardNo && self.txtGiftCardNo.text.length>0) || (textField == self.txtConfGiftCardNo && self.txtConfGiftCardNo.text.length>0)){
//        
//        [self checkBalancebuttonClick:nil];
//    }
    return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    self.txtConfGiftCardNo.text = @"";
    self.GiftCadAutoGenerateBtn.hidden = false;
    return YES;
}

-(IBAction)cancelClick:(id)sender{
    
    [self.giftCardPosDelegate didCancelGiftCard];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)GiftCardAutoGenerateNumber:(id)sender
{
    NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
    CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self GenrateGiftCardNoResponse:response error:error];
    };
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    self.genrateGiftCardNoServiceConnection = [self.genrateGiftCardNoServiceConnection initWithRequest:KURL actionName:WSM_GENERATE_NUMBER_RAPID_GIFTCARD params:param completionHandler:completionHandler];
}
- (void)GenrateGiftCardNoResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([[response valueForKey:@"IsError"] intValue] == 0)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.txtGiftCardNo.text = [NSString stringWithFormat:@"%@",[response valueForKey:@"Data"]];
                self.txtConfGiftCardNo.text = [NSString stringWithFormat:@"%@",[response valueForKey:@"Data"]];
                self.GiftCadAutoGenerateBtn.hidden = true;
            });
        }
        else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //[self showMessage:@"Try again"];
            });
        }
    }
    else
    {
        NSLog(@"blanck");
    }
}

-(void)showMessage:(NSString *)strMessage{
//    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
//    {};
//    [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Giftcard"
                                                                   message:strMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction* action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault
//                                                   handler: buttonHandlers[i]];
//    [alert addAction:action];

    [self presentViewController:alert animated:TRUE completion:nil];
}

@end
