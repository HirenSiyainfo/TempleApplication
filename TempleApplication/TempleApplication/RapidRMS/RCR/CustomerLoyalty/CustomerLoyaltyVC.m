//
//  CustomerLoyaltyVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 01/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CustomerLoyaltyVC.h"
#import "CL_StatisticsVC.h"
#import "CL_CustomerProfileVC.h"
#import "CL_InvoicesVC.h"
#import "CL_OffersVC.h"
#import "RapidCustomerLoyalty.h"
#import "CS_Statistics.h"
#import "CS_Invoice.h"
#import "CS_Item.h"
#import "RmsDbController.h"
#import "CL_CustomerSearchVC.h"
#import "CL_CustomerSearchData.h"
#import "CL_HouseChargeVC.h"
#import "CL_HouseCharge.h"
#import "CL_HouseChargePaymentVC.h"
#import "CL_HouseChargeAddCreditVC.h"
#import "CL_HouseChargeCreditLimitVC.h"
#import "CL_HouseChargeRefundCreditVC.h"

#import "RcrPosVC.h"
#import "RcrPosRestaurantVC.h"
#import "Configuration.h"
#import "UpdateManager.h"


#define DATETIME_VIEW_TAG 999

@interface CustomerLoyaltyVC ()<StatisticsVCDelegate , CustomerProfileVCDelegate , InvoicesVCDelegate , OffersVCDelegate , CL_CustomerSearchVCDelegate ,CL_HouseChageVCDelegate , CL_HouseChargePaymentVCDelegate , CL_HouseChargeAddCreditVCDelegate , CL_HouseChargeCreditLimitVCDelegate , CL_HouseChargeRefundCreditVCDelegate>
{
    
    NSMutableArray *customerInvoicesArray;
    NSMutableArray *customerItemArray;
    NSMutableArray *customerHouseCharge;
    
    UITapGestureRecognizer *tap;
    NSString *strMonthlyDay;
    BOOL isFirstTimeLoadedCustomer;
    CGFloat setCreditLimit;
}

@property (nonatomic, weak) IBOutlet UIButton *btnStatistics;
@property (nonatomic, weak) IBOutlet UIButton *btnCustomerProfile;
@property (nonatomic, weak) IBOutlet UIButton *btnInvoices;
@property (nonatomic, weak) IBOutlet UIButton *btnOffers;
@property (nonatomic, weak) IBOutlet UIButton *btnHouseCharge;
@property (nonatomic, weak) IBOutlet UIView *statisticsContainerView;
@property (nonatomic, weak) IBOutlet UIView *customerProfileContainerView;
@property (nonatomic, weak) IBOutlet UIView *invoicesContainerView;
@property (nonatomic, weak) IBOutlet UIView *offersContainerView;
@property (nonatomic, weak) IBOutlet UIView *houseChargeContainerView;
@property (nonatomic, weak) IBOutlet UIView *customerloyaltyContainerView;

@property (nonatomic, strong) Configuration *objConfiguration;

@property (nonatomic, strong) CS_Statistics *cs_Statistics;
@property (nonatomic, strong) CL_CustomerSearchVC *cl_CustomerSearchVC;
@property (nonatomic, strong) CL_StatisticsVC *statisticsVC;
@property (nonatomic, strong) CL_CustomerProfileVC *customerProfileVC;
@property (nonatomic, strong) CL_InvoicesVC *invoicesVC;
@property (nonatomic, strong) CL_OffersVC *offersVC;
@property (nonatomic, strong) CL_HouseChargeVC *houseChargeVC;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *filterCustomLoyaltyConnection;
@property (nonatomic, strong) CL_CustomerSearchData *cl_CustomerSearchData;
@property (nonatomic, strong) CL_HouseChargePaymentVC *cl_HouseChargePaymentVC;
@property (nonatomic, strong) CL_HouseChargeAddCreditVC *cl_HouseChargeAddCreditVC;
@property (nonatomic, strong) CL_HouseChargeCreditLimitVC *cl_HouseChargeCreditLimitVC;
@property (nonatomic, strong) CL_HouseChargeRefundCreditVC *cl_HouseChargeRefundCreditVC;

@property (nonatomic, strong) RapidWebServiceConnection *updateCreditLimitConnection;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) RmsActivityIndicator * activityIndicator;

@end

@implementation CustomerLoyaltyVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    self.filterCustomLoyaltyConnection = [[RapidWebServiceConnection alloc] init];
    self.updateCreditLimitConnection = [[RapidWebServiceConnection alloc]init];
    self.cl_CustomerSearchData = [[CL_CustomerSearchData alloc] init];
    [self selectedButton:self.btnStatistics];
    [self addViewFromContiner:self.statisticsVC.view containerView:_statisticsContainerView];
    self.btnOffers.enabled = NO;
    
    _objConfiguration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    if (self.objConfiguration.houseCharge.boolValue)
    {
        _btnHouseCharge.enabled = YES;
    }
    else{
        _btnHouseCharge.enabled = NO;

    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view!=self.cl_CustomerSearchVC.view && self.cl_CustomerSearchVC.view) {
        [self.cl_CustomerSearchVC.view removeFromSuperview];
        [self.cl_CustomerSearchVC removeFromParentViewController];
        self.cl_CustomerSearchVC.view=nil;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isFirstTimeLoadedCustomer == FALSE) {
        strMonthlyDay =  [self.cl_CustomerSearchData fromDateToStartdateStringFor:self.cl_CustomerSearchData.cl_SelectedSerachType];
        if ([strMonthlyDay isEqualToString:@" - "])
        {
            strMonthlyDay = @"All History";
        }
        [self configureCustomerLoyaltyVC:strMonthlyDay];

        isFirstTimeLoadedCustomer = TRUE;
    }
}

-(void)configureCustomerLoyaltyVC:(NSString *)strMonthlyDate
{
    self.statisticsVC.rapidCustomerLoyaltyStatisticObject = self.rapidCustomerLoyaltyVCObject;

    [self configureCustomerStatatics:[self.customerLoyaltyDetail valueForKey:@"CustomerInfo"]];
    [self configureCustomerDepartment:[self.customerLoyaltyDetail valueForKey:@"DepartmentInfo"]];
    [self configureCustomerPaymentDetail:[self.customerLoyaltyDetail valueForKey:@"PaymentInfo"]];
    [self.statisticsVC setCustomerStatisticInformation:self.cs_Statistics strdateTimeSet:strMonthlyDate];
    [self configureCustomerInvoiceAndItemData];
}

-(void)configureCustomerInvoiceAndItemData
{
    [self configureCustomerInvoices:[self.customerLoyaltyDetail valueForKey:@"CustomerInvoiceList"]];
    [self configureCustomerItems:[self.customerLoyaltyDetail valueForKey:@"CustomerInvoiceItemList"]];
   [self configureCustomerHouseCharge:[self.customerLoyaltyDetail valueForKey:@"CustomerHouseCharge"]];

    [self.invoicesVC updateInvoiceDataWith:self.rapidCustomerLoyaltyVCObject withInvoiceDetail:customerInvoicesArray withItemDetail:customerItemArray strMonthDate:strMonthlyDay];
    
    [self.houseChargeVC setCustomerHouseChargeInformation:customerHouseCharge withCustomerInfo:self.rapidCustomerLoyaltyVCObject strdateTimeSet:strMonthlyDay withIsFromDashBoard:_isFromDashBoard];
    
}

-(void)configureCustomerStatatics:(NSDictionary *)customerStatatics
{
    if (customerStatatics.count>0)
    {
        self.cs_Statistics = [[CS_Statistics alloc] init];
        [self.cs_Statistics setupCustomerStatisticsDetail:customerStatatics];
    }
}
-(void)configureCustomerDepartment:(NSMutableArray *)customerDepartmentArray
{
    if (customerDepartmentArray.count>0)
    {
        self.cs_Statistics.departmentArray = customerDepartmentArray;
    }
}
-(void)configureCustomerPaymentDetail:(NSMutableArray *)customerPaymentTypeArray
{
        self.cs_Statistics.paymentType = customerPaymentTypeArray;
}

-(void)configureCustomerInvoices:(NSMutableArray *)customerInvoiceArray
{
        customerInvoicesArray = [[NSMutableArray alloc] init];
        for (NSDictionary *customerInvoiceDictionary  in customerInvoiceArray) {
            CS_Invoice *cs_Invoice = [[CS_Invoice alloc] init];
            [cs_Invoice setupCustomerInvoiceDetail:customerInvoiceDictionary];
            [customerInvoicesArray addObject:cs_Invoice];
        }
}

-(void)configureCustomerItems:(NSMutableArray *)customerItems
{
        customerItemArray = [[NSMutableArray alloc] init];
        for (NSDictionary *customerItemDictionary  in customerItems) {
            CS_Item *cs_Item = [[CS_Item alloc] init];
            [cs_Item setupCustomerItemDetail:customerItemDictionary];
            [customerItemArray addObject:cs_Item];
        }
}

-(void)configureCustomerHouseCharge:(NSMutableArray *)customerHC
{
    customerHouseCharge = [[NSMutableArray alloc] init];
    for (NSDictionary *customerItemDictionary  in customerHC) {
        CL_HouseCharge *cs_HouseCharge = [[CL_HouseCharge alloc] init];
        [cs_HouseCharge setupCustomerHouseChargeDetail:customerItemDictionary];
        [customerHouseCharge addObject:cs_HouseCharge];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)btnStatisticClick:(id)sender
{
    [self selectedButton:self.btnStatistics];
    self.statisticsVC.rapidCustomerLoyaltyStatisticObject = self.rapidCustomerLoyaltyVCObject;
    [self.statisticsVC setCustomerStatisticInformation:self.cs_Statistics strdateTimeSet:strMonthlyDay];
    [self addViewFromContiner:self.statisticsVC.view containerView:_statisticsContainerView];
}

-(IBAction)btnCustomerProfileClick:(id)sender
{
    [self selectedButton:self.btnCustomerProfile];
    self.customerProfileVC.rapidCustomerLoyaltyProfileObject = self.rapidCustomerLoyaltyVCObject;
    [self.customerProfileVC setCustomerInfoDetail] ;
    [self addViewFromContiner:self.customerProfileVC.view containerView:_customerProfileContainerView];
}

-(IBAction)btnInvoicesClick:(id)sender
{
    [self selectedButton:self.btnInvoices];
    [self addViewFromContiner:self.invoicesVC.view containerView:_invoicesContainerView];
}

-(IBAction)btnOffersClick:(id)sender
{
    [self selectedButton:self.btnOffers];
    [self addViewFromContiner:self.offersVC.view containerView:_offersContainerView];
}

-(IBAction)btnHouseChageClick:(id)sender
{
    [self selectedButton:self.btnHouseCharge];
    [self addViewFromContiner:self.houseChargeVC.view containerView:_houseChargeContainerView];
}

-(IBAction)btnDateRangeTimeClick:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomerLoyalty" bundle:nil];
    self.cl_CustomerSearchVC = [storyBoard instantiateViewControllerWithIdentifier:@"CL_CustomerSearchVC"];
    self.cl_CustomerSearchVC.cl_CustomerSearchVCDelegate = self;
    self.cl_CustomerSearchVC.view.frame = CGRectMake(622 , 80 ,365, 380) ;
    self.cl_CustomerSearchVC.view.layer.borderWidth = 1;
    self.cl_CustomerSearchVC.view.layer.cornerRadius = 10.0;
    self.cl_CustomerSearchVC.view.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.3].CGColor;
    self.cl_CustomerSearchVC.cl_CustomerSearchData = self.cl_CustomerSearchData;
    [self addChildViewController:self.cl_CustomerSearchVC];
    [self.view addSubview:self.cl_CustomerSearchVC.view];
}
-(void)removeViewFromMainViewWithTag :(NSInteger)tag
{
    [[self.view viewWithTag:tag] removeFromSuperview];
}

-(IBAction)btnSaveClick:(id)sender
{
    
}
-(IBAction)btnCancelClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addViewFromContiner:(UIView*)selectedView containerView:(UIView*)containerView
{
    self.statisticsVC.view.hidden = YES;
    self.customerProfileVC.view.hidden = YES;
    self.invoicesVC.view.hidden = YES;
    self.offersVC.view.hidden = YES;
    self.houseChargeVC.view.hidden = YES;
    
    _statisticsContainerView.hidden = YES;
    _customerProfileContainerView.hidden = YES;
    _invoicesContainerView.hidden = YES;
    _offersContainerView.hidden = YES;
    _houseChargeContainerView.hidden = YES;

    selectedView.hidden = NO;
    containerView.hidden = NO;
    [self.view bringSubviewToFront:containerView];
}

-(void)selectedButton:(UIButton*)btnSelect
{
    self.btnStatistics.selected = NO;
    self.btnCustomerProfile.selected = NO;
    self.btnInvoices.selected = NO;
    self.btnOffers.selected = NO;
    self.btnHouseCharge.selected = NO;
    btnSelect.selected = YES;

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"CL_StatisticsVC"])
    {
        self.statisticsVC = (CL_StatisticsVC*) segue.destinationViewController;
        self.statisticsVC.statisticsVCDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"CL_CustomerProfileVC"])
    {
        self.customerProfileVC  = (CL_CustomerProfileVC*) segue.destinationViewController;
        self.customerProfileVC.customerProfileVCDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"CL_InvoicesVC"])
    {
        self.invoicesVC  = (CL_InvoicesVC*) segue.destinationViewController;
        self.invoicesVC.invoicesVCDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"CL_OffersVC"])
    {
        self.offersVC  = (CL_OffersVC*) segue.destinationViewController;
        self.offersVC.offersVCDelegate = self;
    }
    
    if ([segueIdentifier isEqualToString:@"CL_HouseChargeVC"])
    {
        self.houseChargeVC  = (CL_HouseChargeVC *) segue.destinationViewController;
        self.houseChargeVC.cl_HouseChageVCDelegate = self;
    }
    
}
-(void)didUpdateCustomerWithStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate withSearchCustomType:(NSString *)customType
{
    NSLog(@"StartDate = %@",startDate);
    NSLog(@"EndDate = %@",endDate);
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:self.rapidCustomerLoyaltyVCObject.custId forKey:@"CustomerId"];
    [itemparam setValue:customType forKey:@"TimeDuration"];
    [itemparam setValue:[self stringFromDate:startDate] forKey:@"FromDate"];
    [itemparam setValue:[self stringFromDate:endDate] forKey:@"ToDate"];
    [itemparam setValue:strDateTime forKey:@"LocalDateTime"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self detailsForCustomerLoyaltyResponse:response error:error];
        });
    };
    self.filterCustomLoyaltyConnection = [self.filterCustomLoyaltyConnection initWithRequest:KURL actionName:WSM_DETAIL_FOR_CUSTOMER params:itemparam completionHandler:completionHandler];
    
}

-(NSString *)stringFromDate:(NSDate*)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:date];
    
    return strDate;
}

- (void)detailsForCustomerLoyaltyResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responsearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                self.customerLoyaltyDetail = responsearray;
                [self.cl_CustomerSearchVC.view removeFromSuperview];
                [self.cl_CustomerSearchVC removeFromParentViewController];
                strMonthlyDay =  [self.cl_CustomerSearchData fromDateToStartdateStringFor:self.cl_CustomerSearchData.cl_SelectedSerachType];
                [self configureCustomerLoyaltyVC:strMonthlyDay];
                
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error occured in Customer Detail View Process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(void)didShowHouseChargePopOverView:(NSString *)selectedView withBalanceAmount:(NSNumber *)balanceAmount{

    if ([selectedView isEqualToString: @"Collect Payment"])
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomerLoyalty" bundle:nil];
        self.cl_HouseChargePaymentVC = [storyBoard instantiateViewControllerWithIdentifier:@"CL_HouseChargePaymentVC"];
        self.cl_HouseChargePaymentVC.cl_HouseChargePaymentVCDelegate = self;
        self.cl_HouseChargePaymentVC.balance = balanceAmount;
        self.cl_HouseChargePaymentVC.customerNo = self.rapidCustomerLoyaltyVCObject.customerNo;
        _cl_HouseChargePaymentVC.view.frame = CGRectMake(297, 209, 420, 370);
        [self presentViewAsModal:self.cl_HouseChargePaymentVC.view];

    }
    else if([selectedView isEqualToString:@"Add Credit"])
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomerLoyalty" bundle:nil];
        self.cl_HouseChargeAddCreditVC = [storyBoard instantiateViewControllerWithIdentifier:@"CL_HouseChargeAddCreditVC"];
        self.cl_HouseChargeAddCreditVC.cl_HouseChargeAddCreditVCDelegate = self;
        self.cl_HouseChargeAddCreditVC.creditLimit = self.rapidCustomerLoyaltyVCObject.creditLimit;
        self.cl_HouseChargeAddCreditVC.balance = balanceAmount;
        _cl_HouseChargeAddCreditVC.view.frame = CGRectMake(297, 209, 420, 370);
        [self presentViewAsModal:self.cl_HouseChargeAddCreditVC.view];
    }
    else if([selectedView isEqualToString: @"Credit Limit"])
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomerLoyalty" bundle:nil];
        self.cl_HouseChargeCreditLimitVC = [storyBoard instantiateViewControllerWithIdentifier:@"CL_HouseChargeCreditLimitVC"];
        self.cl_HouseChargeCreditLimitVC.cl_HouseChargeCreditLimitVCDelegate = self;
        self.cl_HouseChargeCreditLimitVC.currentCreditLimit = self.rapidCustomerLoyaltyVCObject.creditLimit;
        _cl_HouseChargeCreditLimitVC.view.frame = CGRectMake(322, 224, 380, 320);
        [self presentViewAsModal:self.cl_HouseChargeCreditLimitVC.view];
    }
    else if([selectedView isEqualToString:@"Refund Credit"])
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomerLoyalty" bundle:nil];
        self.cl_HouseChargeRefundCreditVC = [storyBoard instantiateViewControllerWithIdentifier:@"CL_HouseChargeRefundCreditVC"];
        self.cl_HouseChargeRefundCreditVC.cl_HouseChargeRefundCreditVCDelegate = self;
        self.cl_HouseChargeRefundCreditVC.creditLimit = self.rapidCustomerLoyaltyVCObject.creditLimit;
        self.cl_HouseChargeRefundCreditVC.balance = balanceAmount;
        _cl_HouseChargeRefundCreditVC.view.frame = CGRectMake(297, 209, 420, 370);
        [self presentViewAsModal:self.cl_HouseChargeRefundCreditVC.view];
    }

}

- (void)presentViewAsModal :(UIView *)presentView
{
    presentView.center = _customerloyaltyContainerView.center;
    [_customerloyaltyContainerView addSubview:presentView];
    _customerloyaltyContainerView.hidden = NO;
    [self.view bringSubviewToFront:_customerloyaltyContainerView];
}

//// Refund Credit

-(void)didCancelHouseChargeRefundCreditVC
{
    [self removePresentModalView];
}

-(void)didRefundCreditAmount:(CGFloat)balanceAmount
{
    [self setCustomerAddCreditAndCollectPayment:balanceAmount withIsCollectPay:NO];
}



- (void)removePresentModalView
{
    for (UIView *presentView in _customerloyaltyContainerView.subviews)
    {
        [presentView removeFromSuperview];
    }
    _customerloyaltyContainerView.hidden = YES;
}
/// Add Credit
-(void)didCancelHouseChargeAddCreditVC
{
    [self removePresentModalView];
}

-(void)didAddCreditAmount:(CGFloat)balanceAmount
{
    [self setCustomerAddCreditAndCollectPayment:balanceAmount withIsCollectPay:YES];
}

//// Credit Limit

-(void)setCreditLimit:(CGFloat)balanceAmount
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    setCreditLimit = balanceAmount;
    NSMutableDictionary *creditLimitdict = [[NSMutableDictionary alloc]init];
    
    creditLimitdict[@"CustId"] =self.rapidCustomerLoyaltyVCObject.custId;
    creditLimitdict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    creditLimitdict[@"CreditLimit"] = @(balanceAmount);
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updatecreditLimitForCustomerResponse:response error:error];
        });
    };
    self.updateCreditLimitConnection = [self.updateCreditLimitConnection initWithRequest:KURL actionName:WSM_UPDATE_CREDIT_LIMIT params:creditLimitdict completionHandler:completionHandler];
}

- (void)updatecreditLimitForCustomerResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.rapidCustomerLoyaltyVCObject.creditLimit =  @(setCreditLimit);
                [self removePresentModalView];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [self removePresentModalView];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(void)didCancelHouseChargeCreditLimitVC
{
    [self removePresentModalView];
}
 ///// Collect Amount
-(void)didAddBalanceAmount:(CGFloat)balanceAmount
{
    [self setCustomerAddCreditAndCollectPayment:balanceAmount withIsCollectPay:YES];
}

-(void)didCancelHouseChargePaymentVC
{
    [self removePresentModalView];
}

-(void)setCustomerAddCreditAndCollectPayment:(CGFloat)balance withIsCollectPay:(BOOL)IsCollectPay
{
    [self.customerLoyaltyVCDelegate didCustomerWithHouseChargeDetail:[self.rapidCustomerLoyaltyVCObject customerDetailDictionary] withAmount:balance withIsCollectPay:IsCollectPay];
    
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    for (UIViewController *vc in viewControllerArray)
    {
        if ([vc isKindOfClass:[RcrPosVC class]] || [vc isKindOfClass:[RcrPosRestaurantVC class]] )
        {
            [self.navigationController popToViewController:vc animated:TRUE];
        }
    }

}



@end
