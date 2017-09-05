//
//  ItemTicketValidation.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemTicketValidation.h"
#import "CameraScanVC.h"
#import "RmsDbController.h"
#import "RapidPass.h"
#import "TicketValidationDetail.h"
#import "PassInquiry.h"

@interface ItemTicketValidation ()<CameraScanVCDelegate,TicketValidationDetailDelegate>
{
    CameraScanVC *cameraScanVC ;
    TicketValidationDetail *ticketValidationDetail;
    PassInquiry *passInquiry;
}
@property (nonatomic, weak) IBOutlet UIView *mainContainerView;
@property (nonatomic, weak) IBOutlet UIButton *qrCodeButton;
@property (nonatomic, weak) IBOutlet UIButton *rePrintButton;

@property (nonatomic,strong) RmsDbController *rmsDbController;
@property (nonatomic,strong) RapidWebServiceConnection *itemTicketValidationServiceConnection;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) NSMutableArray <UIViewController *> *presentedViewControllers;

@end
@implementation ItemTicketValidation


- (void)viewDidLoad {
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.itemTicketValidationServiceConnection = [[RapidWebServiceConnection alloc]init];
    self.presentedViewControllers = [[NSMutableArray alloc] init];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  /*  RapidPass *rapidPass = [[RapidPass alloc]init];
    [rapidPass configureRapidPassWithDetail:nil];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    ticketValidationDetail = [storyBoard instantiateViewControllerWithIdentifier:@"TicketValidationDetail"];
    ticketValidationDetail.validationDetailRapidPass = rapidPass;
    [mainContainerView addSubview:ticketValidationDetail.view];*/
    
    [self configureQrCodeView];
}

-(void)configureQrCodeView
{
    [self removeSubViewsFromSuperview];
    _qrCodeButton.selected = YES;
    _rePrintButton.selected = NO;
    cameraScanVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    cameraScanVC.delegate = self;
    [self addViewToContainerView:cameraScanVC];
    cameraScanVC.backButton.hidden = YES;
}

-(void)configureReprintView
{
    [self removeSubViewsFromSuperview];
    _qrCodeButton.selected = NO;
    _rePrintButton.selected = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    passInquiry = [storyboard instantiateViewControllerWithIdentifier:@"PassInquiry"];
    [self addViewToContainerView:passInquiry];
}

- (void)addViewToContainerView:(UIViewController *)viewController {
    [self.presentedViewControllers addObject:viewController];
    [self addChildViewController:viewController];
    [_mainContainerView addSubview:viewController.view];
}

- (void)removeSubViewsFromSuperview
{
    [self.presentedViewControllers.lastObject.view removeFromSuperview];
    [self.presentedViewControllers.lastObject removeFromParentViewController];
    [self.presentedViewControllers removeLastObject];
}

-(void)barcodeScanned:(NSString *)strBarcode
{
    [self removeSubViewsFromSuperview];
    _qrCodeButton.selected = NO;
    [self getItemTicketValidationDetailForBacode:strBarcode];
}

-(void)getItemTicketValidationDetailForBacode:(NSString *)barcode
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"QRCode"] = barcode;

    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    dict[@"LocalDate"] = [dateFormatter stringFromDate:date];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseItemTicketValidationDetailResponse:response error:error];
        });
    };
    
    self.itemTicketValidationServiceConnection = [self.itemTicketValidationServiceConnection initWithRequest:KURL actionName:WSM_CHECK_TICKET_VALIDITY params:dict completionHandler:completionHandler];

}

-(void)responseItemTicketValidationDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if (responseArray != nil) {
                    RapidPass *rapidPass = [[RapidPass alloc]init];
                    [rapidPass configureRapidPassWithDetail:responseArray.firstObject];
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
                    ticketValidationDetail = [storyBoard instantiateViewControllerWithIdentifier:@"TicketValidationDetail"];
                    ticketValidationDetail.validationDetailRapidPass = rapidPass;
                    ticketValidationDetail.ticketValidationDetailDelegate = self;
                    [_mainContainerView addSubview:ticketValidationDetail.view];
                }
                else
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Data Available" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Data Available" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(IBAction)qrCodeScan:(id)sender
{
    [self configureQrCodeView];
}

-(IBAction)rePrintPassClicked:(id)sender
{
    [self configureReprintView];
}

-(void)hideTicketValidationDetail
{
    [self configureQrCodeView];
}

-(IBAction)cancelButton:(id)sender
{
    [self.itemTicketValidationDelegate hideItemTicketValidation];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
