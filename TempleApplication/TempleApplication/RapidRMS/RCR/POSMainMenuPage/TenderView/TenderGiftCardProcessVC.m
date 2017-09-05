//
//  TenderGiftCardProcessVC.m
//  RapidRMS
//
//  Created by Siya-ios5 on 12/1/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "TenderGiftCardProcessVC.h"
#import "RmsDbController.h"

@interface TenderGiftCardProcessVC ()
{
    IBOutlet UITextField *txtGiftCardNo;
    IBOutlet UILabel *lblLoadAmount;
    
    IBOutlet UILabel *lblUserName;
    IBOutlet UILabel *lblEmail;

}
@property (nonatomic,strong)NSMutableArray *giftSwipeArray;


@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic,strong) RapidWebServiceConnection *checkGiftCardBalanceAmountConnection;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (atomic) NSInteger currentGiftCardIndex;
@end

@implementation TenderGiftCardProcessVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.currentGiftCardIndex = -1;
    

    if(_dictCustomerInfo)
    {
            lblUserName.text = [NSString stringWithFormat:@"Customer Name : %@ %@",[_dictCustomerInfo valueForKey:@"FirstName"],[_dictCustomerInfo valueForKey:@"LastName"]];
            lblEmail.text = [NSString stringWithFormat:@"Email : %@",[_dictCustomerInfo valueForKey:@"Email"]];;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.giftSwipeArray = self.paymentGiftData.giftSwipeArrayofPaymentModeItem;
    [self performNextGiftCardProcess];
    
}

-(void)performNextGiftCardProcess
{
    self.currentGiftCardIndex++;
    if (self.currentGiftCardIndex >= self.giftSwipeArray.count) {
        [self dismissViewControllerAnimated:TRUE completion:^{
            [self.tenderGiftCardProcessVCDelegate didFinishGiftCardProcess];
        }];
        return;
    }
    
    PaymentModeItem *paymentModeItem = (PaymentModeItem *)(self.giftSwipeArray)[self.currentGiftCardIndex] ;
    float amountToApprove = paymentModeItem.actualAmount.floatValue + paymentModeItem.calculatedAmount.floatValue;
    [self configureGiftCardViewWithAmount:amountToApprove];
    
}

-(IBAction)cancelButtonClick:(id)sender
{
    [self.tenderGiftCardProcessVCDelegate didCancelGiftCardProcess];
}

-(void)configureGiftCardViewWithAmount:(CGFloat )amountToApprove
{
    lblLoadAmount.text = [NSString stringWithFormat:@"%.2f",amountToApprove];
}

-(IBAction)checkBalance:(id)sender
{
    [self checkBalancebeforePayment];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)checkBalancebeforePayment{
    if([txtGiftCardNo.text isEqualToString:@""]){
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Card No" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else{
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
        [param setValue:txtGiftCardNo.text forKey:@"CRDNumber"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self checkBalancebeforePaymentResponse:response error:error];
            });
        };
        
        self.checkGiftCardBalanceAmountConnection = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_CHECK_BALANCE_RAPID_GIFTCARD params:param completionHandler:completionHandler];
        
    }
}
- (void)checkBalancebeforePaymentResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *dictBalance = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                
                PaymentModeItem *paymentModeItem = (PaymentModeItem *)(self.giftSwipeArray)[self.currentGiftCardIndex] ;
                float amountToApprove = paymentModeItem.actualAmount.floatValue + paymentModeItem.calculatedAmount.floatValue;

                
                if ([self.paymentGiftData isGiftCardAlreadyApprovedForCardNumber:txtGiftCardNo.text] == TRUE) {
                    amountToApprove = amountToApprove + [self.paymentGiftData totalAmountForApprovedGiftCard];
                }
                
                if([[dictBalance valueForKey:@"Balance"]floatValue] >= amountToApprove){
                    paymentModeItem.paymentModeDictionary = [self updatePaymentDictionaryWithDetailWithPaymentModeItem:paymentModeItem withGiftCardBalanceAmount:dictBalance];
                    txtGiftCardNo.text = @"";

                    [self performNextGiftCardProcess];
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
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Error occur while sending details" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}
-(NSDictionary *)updatePaymentDictionaryWithDetailWithPaymentModeItem:(PaymentModeItem *)paymentmodeItem withGiftCardBalanceAmount:(NSDictionary *)giftcardBalanceAmount
{
    NSMutableDictionary *paymentModeDictionary = [paymentmodeItem.paymentModeDictionary mutableCopy];
    [paymentModeDictionary setObject:txtGiftCardNo.text forKey:@"GiftCardNumber"];
    [paymentModeDictionary setObject:@"1" forKey:@"IsGiftCardApproved"];
    [paymentModeDictionary setObject:@(paymentmodeItem.actualAmount.floatValue + paymentmodeItem.calculatedAmount.floatValue) forKey:@"GiftCardApprovedAmount"];
    [paymentModeDictionary setObject:@([[giftcardBalanceAmount valueForKey:@"Balance"]floatValue]) forKey:@"GiftCardBalanceAmount"];
    [paymentModeDictionary setValue:@"RMSGiftCard" forKey:@"CardType"];
    [paymentModeDictionary setValue:txtGiftCardNo.text forKey:@"AccNo"];
    return paymentModeDictionary;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
