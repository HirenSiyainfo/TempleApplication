//
//  EmailFromViewController.m
//  RapidRMS
//
//  Created by Siya on 04/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "EmailFromViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "AsyncImageView.h"
#import "RmsDbController.h"
#import "NSString+Methods.h"

@interface EmailFromViewController ()
{
    IntercomHandler *intercomHandler;
    NSString *customerId;
}
@property (nonatomic, weak) IBOutlet UIWebView *emailReceipt;
@property (nonatomic, weak) IBOutlet UITextField *txtTo;
@property (nonatomic, weak) IBOutlet UITextField *txtcc;
@property (nonatomic, weak) IBOutlet UITextField *txtSubject;
@property (nonatomic, weak) IBOutlet UITextView *txtbody;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIView *viewEmail;


@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@end

@implementation EmailFromViewController
@synthesize dictParameter;

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
    
    _txtSubject.text=[ NSString stringWithFormat:@"SUBJECT : %@", [dictParameter valueForKey:@"Subject"]];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    [_emailReceipt loadHTMLString:[dictParameter valueForKey:@"HtmlString"] baseURL:nil];

    if([dictParameter valueForKey:@"invoiceNo"])
    {
//        txtbody.text=strBody;
        _txtbody.textAlignment = NSTextAlignmentCenter;
    }
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _viewEmail.layer.cornerRadius = 5.0;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    customerId = @"0";
    if (self.rapidEmailCustomerLoyalty) {
        if (self.rapidEmailCustomerLoyalty.email.blank == FALSE) {
            _txtTo.text = self.rapidEmailCustomerLoyalty.email.trimeString;
        }
        customerId = [NSString stringWithFormat:@"%@",self.rapidEmailCustomerLoyalty.custId];

    }
}

-(IBAction)EmailCandel:(id)sender{
    [self.rmsDbController playButtonSound];
    [self.emailFromViewControllerDelegate didCancelEmail];
 //   [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - 
#pragma mark Email Send Webservice call

-(BOOL)validateEmail:(NSString *)email

{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}


-(IBAction)sendEmail:(id)sender{
    [self.rmsDbController playButtonSound];
    if(_txtTo.text.length>0){
    
        BOOL eb=false;
        
        if ([_txtTo.text rangeOfString:@","].location != NSNotFound)
        {
            
            NSArray *arrayEmail  = [_txtTo.text componentsSeparatedByString:@","];
            for(int i=0;i<arrayEmail.count;i++){
                
                eb=[self validateEmail:arrayEmail[i]];
                if(eb==false)
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Enter Valid Email Address" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                     return;
                }
            }
        }
        else{
            eb=[self validateEmail:_txtTo.text];

        }
        
        if(!eb)
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Enter Valid Email Address" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
        else{
            
            UIView *viewTemp = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 768.0)];
            [self.view addSubview:viewTemp];
            viewTemp.tag=111;
            viewTemp.backgroundColor=[UIColor clearColor];
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:viewTemp];
            [self emailSend];
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Enter Email Address" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(void)emailSend
{
    NSString *strParameter = [NSString stringWithFormat:@"%@",[dictParameter valueForKey:@"BranchID"]];
    NSString *strCC = @"";
    if (_txtcc) {
        strCC = _txtcc.text;
    }
    NSString *strPar = [NSString stringWithFormat:@"http://www.rapidrms.com/WcfService/Service.svc/EmailReporting/%@?Subject=%@&To=%@&cc=%@&InvoiceNo=%@&body=%@&custid=%@",strParameter,[dictParameter valueForKey:@"Subject"],_txtTo.text,strCC,[dictParameter valueForKey:@"InvoiceNo"],(self.rmsDbController.globalDict)[@"DBName"],customerId];
    
    NSURL *url = [NSURL URLWithString:[strPar stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *fileData = [dictParameter valueForKey:@"postfile"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request appendPostData:fileData];
    request.didFinishSelector = @selector(uploadFinished:);
    request.didFailSelector = @selector(uploadFailed:);
    request.delegate = self;
    [request startAsynchronous];

}

- (void)uploadFinished:(ASIHTTPRequest *)request
{
    UIView *viewTemp = [self.view viewWithTag:111];
    [viewTemp removeFromSuperview];
    [self.emailFromViewControllerDelegate didCancelEmail];
    [_activityIndicator hideActivityIndicator];;
    NSMutableDictionary *dict = [self.rmsDbController objectFromJsonString:request.responseString];
    NSString *message = @"";
    if  (dict != nil)
    {
        NSMutableDictionary *receivedString = [dict valueForKey:@"EmailReportingResult"];
        if ([[receivedString valueForKey:@"IsError"] intValue]==0)
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [self dismissViewControllerAnimated:YES completion:NULL];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[receivedString valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        message = [receivedString valueForKey:@"Data"];
    }
    else
    {
       message = @"Email not sent. Please Try Again.";
    }
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (void)uploadFailed:(ASIHTTPRequest *)request {
	
    UIView *viewTemp = [self.view viewWithTag:111];
    [viewTemp removeFromSuperview];
    [self.emailFromViewControllerDelegate didCancelEmail];
    [_activityIndicator hideActivityIndicator];;
    NSString *receivedString  = [self.rmsDbController objectFromJsonString:request.responseString][@"EmailReportingResult"][@"IsError"];
    
    if(receivedString.intValue==-1)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Email not sent." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}


#pragma mark -
#pragma mark UITextView Delegate Method

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
#pragma mark -
#pragma mark UITextField Delegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
