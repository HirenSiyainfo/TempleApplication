//
//  ShiftOpenCloseVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ShiftOpenCloseVC.h"
#import "RmsDbController.h"
#import "RcrController.h"
#import "ShiftHistoryCell.h"
#import "UserShiftDetailCell.h"
#import <MessageUI/MessageUI.h>
#import "ShiftInOutPopOverVC.h"
#import "EmailFromViewController.h"
#import "InvoiceData_T+Dictionary.h"
#import "Configuration.h"
#import "ShiftReport.h"
#import "OflineShiftReportCalculation.h"

@interface ShiftOpenCloseVC ()<MFMailComposeViewControllerDelegate,ShiftInOutPopOverDelegate,UpdateDelegate , EmailFromViewControllerDelegate>
{
    NSString *shiftHtml;
    NSString *sourcePath;
    NSString *shiftHtmlEmail;
    NSString *strShiftNo;
    NSNumber *serverShiftId;
    NSNumber *currentUserId;
    NSNumber *openShiftUserId;
    NSMutableArray *shiftDetailArrayForPrint;
    NSArray *array_port;
    NSInteger selectedPort;
    NSMutableDictionary *dictshiftDetailTemp;
    NSMutableArray *shiftTenderArrayTemp;
    NSMutableArray *discountArrayTemp;
}
@property (nonatomic, weak) IBOutlet UILabel *lblRegisterName;
@property (nonatomic, weak) IBOutlet UILabel *lblOpeningAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblCloseDate;
@property (nonatomic, weak) IBOutlet UILabel *lblHistroyCount;
@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UILabel *closeShiftOpeningAmount;
@property (nonatomic, weak) IBOutlet UILabel *closeShiftClosingAmount;

@property (nonatomic, weak) IBOutlet UIView *shiftOpen;
@property (nonatomic, weak) IBOutlet UIView *shitNotOpen;
@property (nonatomic, weak) IBOutlet UIView *shiftClose;
@property (nonatomic, weak) IBOutlet UIView *viewHistory;

@property (nonatomic, weak) IBOutlet UITableView *historyTable;
@property (nonatomic, weak) IBOutlet UITableView *tbluserShiftDetail;

@property (nonatomic, weak) IBOutlet UIWebView *webHistoryWebView;
@property (nonatomic, weak) IBOutlet UIWebView *shiftReport;

@property (nonatomic, weak) IBOutlet UITextField *txtUseName;

@property (nonatomic, weak) IBOutlet UIButton *btnOpenShift;
@property (nonatomic, weak) IBOutlet UIButton *btnCloseShift;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnCurrentShiftDetail;
@property (nonatomic, weak) IBOutlet UIButton *btnlastShiftReport;
@property (nonatomic, weak) IBOutlet UIButton *btnPrintShift;
@property (nonatomic, weak) IBOutlet UIButton *btnEmail;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) EmailFromViewController *emailFromViewController;
@property (nonatomic, strong) ShiftReport *objShiftReport;
@property (nonatomic, strong) ShiftInOutPopOverVC *shift;
@property (nonatomic, strong) IntercomHandler *intercomHandler;
@property (nonatomic, strong) RapidWebServiceConnection *webServiceConnectionShiftOffline;
@property (nonatomic, strong) RapidWebServiceConnection *shiftOpenCurrentDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *shiftOpenCurrentDetailWC2;
@property (nonatomic, strong) RapidWebServiceConnection *shifHistoryListWC;
@property (nonatomic, strong) RapidWebServiceConnection *shiftHistoryDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *shiftCloseDetailWC;
@property (nonatomic, strong) UpdateManager *updateShiftManager;

@property (nonatomic, strong) NSMutableArray *historyArray;
@property (nonatomic, strong) NSMutableArray *userShiftDetailArray;
@property (nonatomic, strong) NSNumberFormatter *htmlCurrencyFormatter;
@property (atomic) NSInteger selectedIndexPath;
@property (nonatomic, strong) NSString *shiftType;
@property (nonatomic, strong) NSNumber  *tipSetting;
@property (nonatomic, strong) NSArray *offlineInvoice;
@property (nonatomic) NSInteger nextIndex;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;


@end

@implementation ShiftOpenCloseVC

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.webServiceConnectionShiftOffline = [[RapidWebServiceConnection alloc] init];
    self.shiftOpenCurrentDetailWC = [[RapidWebServiceConnection alloc] init];
    self.shiftOpenCurrentDetailWC2 = [[RapidWebServiceConnection alloc] init];
    self.shifHistoryListWC = [[RapidWebServiceConnection alloc] init];
    self.shiftHistoryDetailWC = [[RapidWebServiceConnection alloc] init];
    self.shiftCloseDetailWC = [[RapidWebServiceConnection alloc] init];
    self.updateShiftManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    _shiftOpen.hidden = YES;
    _shitNotOpen.hidden  = YES;
    _shiftClose.hidden = YES;
    self.historyArray = [[NSMutableArray alloc]init];
    self.userShiftDetailArray = [[NSMutableArray alloc]init];
    shiftDetailArrayForPrint = [[NSMutableArray alloc] init];
 
    _tbluserShiftDetail.hidden = YES;
    _tbluserShiftDetail.layer.borderColor=[UIColor colorWithRed:207.0/255.0 green:207.0/255.0  blue:207.0/255.0  alpha:1.0].CGColor ;
    _tbluserShiftDetail.layer.borderWidth=0.8;
    
    
    [_historyTable registerNib:[UINib nibWithNibName:@"ShiftHistoryCell" bundle:nil]forCellReuseIdentifier:@"ShiftHistoryCell"];
    
    [_tbluserShiftDetail registerNib:[UINib nibWithNibName:@"UserShiftDetailCell" bundle:nil]forCellReuseIdentifier:@"UserShiftDetailCell"];
    
    _viewHistory.frame = CGRectMake(320, _viewHistory.frame.origin.y, _viewHistory.frame.size.width, _viewHistory.frame.size.height);
    _viewHistory.hidden = YES;
    _webHistoryWebView.hidden= YES;
    [_tbluserShiftDetail reloadData];
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    _btnCurrentShiftDetail.hidden=YES;
    _btnPrintShift.hidden=YES;
    currentUserId = @([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] integerValue]);
    Configuration *configuration = [self.updateShiftManager insertConfigurationMoc:self.managedObjectContext];
    openShiftUserId = configuration.userId;
    serverShiftId = configuration.serverShiftId;
    [self sendShiftOfflineDataToServer];
    self.tipSetting = [self checkTipsSetting];
    self.intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (NSNumber *)checkTipsSetting
{
    NSNumber *tipSetting;
    Configuration *configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext ];
    tipSetting = configuration.localTipsSetting;
    return tipSetting;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.htmlCurrencyFormatter = [[NSNumberFormatter alloc] init];
    self.htmlCurrencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    self.htmlCurrencyFormatter.maximumFractionDigits = 2;
}

//hiten
-(IBAction)currentShiftDetail:(id)sender{
    [self ShiftOpenCurrentDetail];
    [self conFigureShiftStatus];
    _btnCurrentShiftDetail.hidden=YES;
    _btnPrintShift.hidden=YES;
    [_btnlastShiftReport setTitleColor:[UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _tbluserShiftDetail.hidden = YES;
}

#pragma mark -
#pragma mark Last Shift Print
-(void)shiftPrint
{
    [self shiftPrint:nil];
}

-(IBAction)shiftPrint:(id)sender{
    
    [self.rmsDbController playButtonSound];
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    [self PrintReport:portName portSettings:portSettings setReportObject:dictshiftDetailTemp ReportName:@"Shift"];
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
    [ShiftOpenCloseVC setPortName:localPortName];
    [ShiftOpenCloseVC setPortSettings:array_port[selectedPort]];
}


- (void)PrintReport:(NSString *)portName portSettings:(NSString *)portSettings setReportObject:(NSMutableDictionary *)ReportData  ReportName:(NSString *)RptName
{
    if(ReportData.count>0)
    {
        ShiftReport *xReportPrint = [[ShiftReport alloc] initWithDictionary:shiftDetailArrayForPrint.firstObject reportName:[NSString stringWithFormat:@"Shift #%ld",(long)[[ReportData valueForKey:@"ShiftNo"]integerValue]] isTips:self.tipSetting.boolValue];
        [xReportPrint printReportWithPort:portName portSettings:portSettings withDelegate:self];
        [_activityIndicator hideActivityIndicator];
    }
}

#pragma mark - Printer Function Delegate

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    NSString *retryMessage = @"Failed to Shift Report print receipt. Would you like to retry.?";
    [self displayShiftReportPrintRetryAlert:retryMessage];
}

-(void)displayShiftReportPrintRetryAlert:(NSString *)message
{
    ShiftOpenCloseVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference shiftPrint:nil];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)conFigureShiftStatus
{
    if ([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"CashInOutFlg"] boolValue] == TRUE)
    {
        _btnCloseShift.enabled = YES;
        _btnOpenShift.enabled = NO;
        [_btnCloseShift setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnOpenShift setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else
    {
        _btnCloseShift.enabled = NO;
        _btnOpenShift.enabled = YES;
        [_btnOpenShift setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnCloseShift setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

-(void)ShiftOpenCurrentDetail
{
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
	dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self shiftOpenCurrentDetailResponse:response error:error];
    };
    
    self.shiftOpenCurrentDetailWC = [self.shiftOpenCurrentDetailWC initWithRequest:KURL actionName:WSM_SHIFT_OPEN_CURRENT_DETAIL params:dict completionHandler:completionHandler];
}

-(NSString *)generateHTMLForShiftReportFromDictionary:(NSDictionary *)shiftReportDict
{
    self.objShiftReport = [[ShiftReport alloc] initWithDictionary:shiftReportDict reportName:@"Shift Report" isTips:self.tipSetting.boolValue];
    NSString *htmlData = self.objShiftReport.generateHtml;

    return htmlData;
}

-(void)shiftOpenCurrentDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                // ShiftDetail
                NSMutableArray *shiftDetailArray = [responseArray.firstObject valueForKey:@"objShiftDetail"];
                shiftDetailArrayForPrint = [responseArray mutableCopy];
                NSMutableDictionary *shiftDetailDict = shiftDetailArray.firstObject;
                
                // ShiftTender
                dictshiftDetailTemp = shiftDetailDict;
                
                NSMutableArray *shiftTenderArray = [[NSMutableArray alloc] init ];
                if (![[shiftDetailDict valueForKey:@"ShiftStatus"] isEqualToString:@"None"])
                {
                    shiftTenderArray = [responseArray.firstObject valueForKey:@"objShiftTender"];
                }
                
                shiftTenderArrayTemp = [shiftTenderArray mutableCopy];
                discountArrayTemp = [responseArray.firstObject valueForKey:@"objShiftDiscount"];
                
                //            [self updateShiftRportDetailWithOfflineData:responseArray];
                
                OflineShiftReportCalculation *oflineShiftReportCalculation = [[OflineShiftReportCalculation alloc]initWithArray:responseArray withZid:(self.rmsDbController.globalDict)[@"ZId"]];
                [oflineShiftReportCalculation updateReportWithOfflineDetail];
                
                
                if (self.userShiftDetailArray.count==0)
                {
                    self.userShiftDetailArray =[responseArray.firstObject valueForKey:@"objShiftUser"];
                    NSMutableDictionary *dictNone = [[NSMutableDictionary alloc]init];
                    dictNone[@"UserName"] = @"None";
                    [self.userShiftDetailArray insertObject:dictNone atIndex:self.userShiftDetailArray.count];
                }
                
                NSString *baseUrlPath = [[NSBundle mainBundle] pathForResource:@"ShiftReport" ofType:@"html"];
                shiftHtml = [NSString stringWithContentsOfFile:baseUrlPath encoding:NSUTF8StringEncoding error:nil];
                shiftHtml = [self htmlForShiftReport:shiftHtml replaceWithData:shiftDetailDict replaceWithTenderData:shiftTenderArray discountArray:discountArrayTemp];
                if ([self isShiftHasInvoiceInOffline] == FALSE)
                {
                    shiftHtml = [shiftHtml stringByReplacingOccurrencesOfString:@"OFFLINE" withString:@""];
                }
                NSData* data = [shiftHtml dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = paths.firstObject;
                sourcePath = [documentsDirectory stringByAppendingPathComponent:@"shiftDetail.html"];
                shiftHtml =[shiftHtml stringByReplacingOccurrencesOfString:@"$$SHIFT_STAR_END_DATE$$" withString:@""];
                [data writeToFile:sourcePath atomically:YES];
                [_shiftReport loadHTMLString:shiftHtml baseURL:nil];
            }
        }
    }
}
- (NSNumber *)calculateNetFuelSales:(NSMutableDictionary *)dataDict{
    float netFuelSales = [dataDict [@"GrossFuelSales"] floatValue] - [dataDict [@"FuelRefund"] floatValue];
    NSNumber *numNetFuelSales = @(netFuelSales);
    return numNetFuelSales;
}

-(NSString *)getFuelSummery:(NSMutableDictionary *)dataDict withHtml:(NSString *)html{
    
     NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (_rmsDbController.globalDict)[@"DeviceId"]];
    
    NSArray *activeModulesArray = [[_rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    NSNumber *numNetFuelSales = [self calculateNetFuelSales:dataDict];
    NSString *fuelSummery = @"";
    if([self isRcrGasActive:activeModulesArray]){
        
        fuelSummery  = [NSString stringWithFormat:@"<tr style=\"color:rgb(0,115,170);\"><td width=\"216\">Net Fuel Sales:</td><td width=\"216\">%@</td></tr><tr><td height=\"20\"></td><td></td></tr>",[self.htmlCurrencyFormatter stringFromNumber:numNetFuelSales]];
    }

    html = [html stringByReplacingOccurrencesOfString:@"$$FUELSUMMERY$$" withString:[NSString stringWithFormat:@"%@",fuelSummery]];
    
    return html;
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

-(NSString *)htmlForShiftReport :(NSString *)html replaceWithData :(NSMutableDictionary *)dataDict replaceWithTenderData :(NSMutableArray *)shiftTenderArray discountArray:(NSArray *)discountArray
{
    html = [html stringByReplacingOccurrencesOfString:@"$$GROSS_SALES$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber: dataDict [@"TotalSales"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TAXES$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber: dataDict [@"CollectTax"]]]];
    
    float netSales = [dataDict [@"TotalSales"] doubleValue] - [dataDict [@"CollectTax"]doubleValue];
    NSNumber *netSale = @(netSales);
    html = [html stringByReplacingOccurrencesOfString:@"$$NET_SALES$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:netSale]]];

    html = [self getFuelSummery:dataDict withHtml:html];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$OPENING_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"OpeningAmount"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$SALE$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"Sales"]]]];
    
    double returnAmount = [dataDict[@"Return"] doubleValue];
    NSNumber *returnAmountNumber = @(fabs(returnAmount));
    html =  [html stringByReplacingOccurrencesOfString:@"$$RETURN$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:returnAmountNumber]]];
    
    double sum1 = [dataDict [@"Sales"] doubleValue] + [dataDict [@"Return"] doubleValue];
    NSNumber *sum1number = @(sum1);
    html =  [html stringByReplacingOccurrencesOfString:@"$$NET_TOTAL$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:sum1number]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$TAXES$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"CollectTax"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$DEBIT_SURCHARGE$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"Surcharge"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$GIFT_CARD$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"LoadAmount"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$MONEY_ORDER$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"MoneyOrder"]]]];

    NSString *tips = [self htmlForTips:dataDict];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIPS$$" withString:tips];
    
    double totalopenAmount=[[dataDict valueForKey:@"OpeningAmount"]doubleValue]+[[dataDict valueForKey:@"Sales"]doubleValue]+[[dataDict valueForKey:@"Return"]doubleValue]+[[dataDict valueForKey:@"CollectTax"]doubleValue]+[[dataDict valueForKey:@"Surcharge"]doubleValue] + [[dataDict valueForKey:@"LoadAmount"]doubleValue] + [[dataDict valueForKey:@"MoneyOrder"]doubleValue];
    if (self.tipSetting.boolValue)
    {
        totalopenAmount = totalopenAmount + [dataDict [@"TotalTips"] doubleValue];
    }
    NSNumber *doubleTotal1number = @(totalopenAmount);
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_1$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:doubleTotal1number]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DROPS$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"DropAmount"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$CLOSING_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"ClosingAmount"]]]];
    // set Item Detail with only 1 qty....
    float fcardAmt=0;
    NSString *htmlTender = @"";
    for (int i=0; i < shiftTenderArray.count; i++)
    {
        NSMutableDictionary *TenderRptCard = shiftTenderArray[i];
        NSString *strCashType = [NSString stringWithFormat:@"%@",[TenderRptCard valueForKey:@"CashInType"]];
        if(![strCashType isEqualToString:@"Cash"])
        {
                NSString *strHTML = [self htmlBillTextGenericForItemwithDictionaryMain:TenderRptCard];
                htmlTender = [htmlTender stringByAppendingString:strHTML];
                NSString *scardamount=[NSString stringWithFormat:@"%.2f",[[TenderRptCard valueForKey:@"Amount"] floatValue]];
                fcardAmt+=scardamount.floatValue;
        }
    }
    html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TRANSACTION$$" withString:[NSString stringWithFormat:@"%@",htmlTender]];
    
    double payOutAmount = [dataDict[@"PayOut"] doubleValue];
    NSNumber *payOutAmountNumber = @(fabs(payOutAmount));
    
    double doubleTotal2 = [[dataDict valueForKey:@"ClosingAmount"]floatValue] + fcardAmt + payOutAmountNumber.floatValue + [[dataDict valueForKey:@"DropAmount"]floatValue];
    NSNumber *doubleTotal2number = @(doubleTotal2);
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_2$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:doubleTotal2number]]];
    
    double overShortValue = doubleTotal2 - totalopenAmount;
    
    // hiten for Payment Detail
    
    // set Item Detail with only 1 qty....
    double fcardAmttemp = 0.00;
    NSInteger fcardCount = 0;
    
    NSString *htmlTendertemp = @"";
    for (int i=0; i <=shiftTenderArray.count; i++)
    {
        if(i==0)
        {
            NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:nil];
            htmlTendertemp = [htmlTendertemp stringByAppendingString:strHTML];
            
        }
        else{
            NSMutableDictionary *TenderRptCard = shiftTenderArray[i-1];
            NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:TenderRptCard];
            htmlTendertemp = [htmlTendertemp stringByAppendingString:strHTML];
            fcardAmttemp += [[TenderRptCard valueForKey:@"Amount"] doubleValue];
            if (self.tipSetting.boolValue)
            {
                fcardAmttemp += [[TenderRptCard valueForKey:@"TipsAmount"] doubleValue];
            }
            fcardCount += [[TenderRptCard valueForKey:@"Count"] integerValue];
        }
    }
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TRANSACTION_DETAIL$$" withString:[NSString stringWithFormat:@"%@",htmlTendertemp]];
    NSNumber *doubleTotal3number = @(fcardAmttemp);
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_3$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:doubleTotal3number]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_COUNT$$" withString:[NSString stringWithFormat:@"%ld",(long)fcardCount]];
    
    if (self.tipSetting.boolValue) {
        double tenderAmount = 0.00;
        double tenderTipsAmount = 0.00;
        double tenderTipsAmountTotal = 0.00;
        
        NSString *htmlTenderTips = @"";
        for (int i=0; i <=shiftTenderArray.count; i++)
        {
            if(i==0)
            {
                NSString *strHTML = [self htmlForTenderTips:nil];
                htmlTenderTips = [htmlTenderTips stringByAppendingString:strHTML];
            }
            else{
                NSMutableDictionary *TenderRptCard = shiftTenderArray[i-1];
                NSString *strHTML = [self htmlForTenderTips:TenderRptCard];
                htmlTenderTips = [htmlTenderTips stringByAppendingString:strHTML];
                tenderAmount += [[TenderRptCard valueForKey:@"Amount"] doubleValue];
                tenderTipsAmount += [[TenderRptCard valueForKey:@"TipsAmount"] doubleValue];
                if (self.tipSetting.boolValue)
                {
                    tenderTipsAmountTotal += [[TenderRptCard valueForKey:@"Amount"] doubleValue] + [[TenderRptCard valueForKey:@"TipsAmount"] doubleValue];
                }
            }
        }
        html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TIPS_DETAIL$$" withString:[NSString stringWithFormat:@"%@",htmlTenderTips]];
        NSNumber *doubleTotalTenderAmount = @(tenderAmount);
        NSNumber *doubleTotalTenderTipsAmount = @(tenderTipsAmount);
        NSNumber *doubleTenderTipsAmountTotal = @(tenderTipsAmountTotal);
        
        NSString *htmlTipsTenderFooter = @"";
        if(self.emailFromViewController)
        {
            htmlTipsTenderFooter = [htmlTipsTenderFooter stringByAppendingFormat:@"<tr style=\"font-weight:bold\"><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];

            htmlTipsTenderFooter = [htmlTipsTenderFooter stringByAppendingFormat:@"<tr style=\"font-weight:bold\"><td style=\"border-bottom:1px solid #90BCC3;\">Total</td><td style=\"border-bottom:1px solid #90BCC3;\">%@</td><td style=\"border-bottom:1px solid #90BCC3;\">%@</td><td style=\"border-bottom:1px solid #90BCC3;\">%@</td></tr>",[self.htmlCurrencyFormatter stringFromNumber:doubleTotalTenderAmount],[self.htmlCurrencyFormatter stringFromNumber:doubleTotalTenderTipsAmount],[self.htmlCurrencyFormatter stringFromNumber:doubleTenderTipsAmountTotal]];
        }
        else
        {
            htmlTipsTenderFooter = [htmlTipsTenderFooter stringByAppendingFormat:@"<tr style=\"font-weight:bold\"><td width=\"162\">%@:</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td></tr>",@"Total",[self.htmlCurrencyFormatter stringFromNumber:doubleTotalTenderAmount],[self.htmlCurrencyFormatter stringFromNumber:doubleTotalTenderTipsAmount],[self.htmlCurrencyFormatter stringFromNumber:doubleTenderTipsAmountTotal]];
        }
        html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TIPS_DETAIL_FOOTER$$" withString:htmlTipsTenderFooter];
    }
    else
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TIPS_DETAIL$$" withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TIPS_DETAIL_FOOTER$$" withString:@""];
    }
    
    NSString *discountHtml = [self htmlDiscountDetail:discountArray];
    html = [html stringByReplacingOccurrencesOfString:@"$$DISCOUNT_DETAIL$$" withString:[NSString stringWithFormat:@"%@",discountHtml]];

    CGFloat totalSalesAmount = 0.00;
    CGFloat totalDiscountAmount = 0.00;
    NSInteger totalDiscountCount = 0;
    for (NSDictionary *discountDict in discountArray) {
        totalSalesAmount += [discountDict[@"Sales"] floatValue];
        totalDiscountAmount += [discountDict[@"Amount"] floatValue];
        totalDiscountCount += [discountDict[@"Count"] integerValue];
    }
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_DISCOUNT_SALES$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:@(totalSalesAmount)]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_DISCOUNT_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:@(totalDiscountAmount)]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_DISCOUNT_COUNT$$" withString:[NSString stringWithFormat:@"%ld",(long)totalDiscountCount]];
    
    NSString *strHTML = [self htmlGiftCardDetail:dataDict];
    html = [html stringByReplacingOccurrencesOfString:@"$$GIFT_CARD_TRANSACTION_DETAIL$$" withString:[NSString stringWithFormat:@"%@",strHTML]];
    
    NSInteger totalcount = [dataDict [@"LoadCount"]integerValue] + [dataDict [@"RedeemCount"]integerValue];
    float totalAmount = [dataDict [@"TotalGCADY"]floatValue] + [dataDict [@"TotalLoadAmount"]floatValue] + [dataDict [@"TotalRedeemAmount"]floatValue];
    NSNumber *numtotAmount = @(totalAmount);
    
    html = [html stringByReplacingOccurrencesOfString:@"$$GC_TOTAL$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:numtotAmount]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$GC_COUNT$$" withString:[NSString stringWithFormat:@"%ld",(long)totalcount]];
    

    NSNumber *overShortnumber = @(overShortValue);
    html = [html stringByReplacingOccurrencesOfString:@"$$OVER / SHORT$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:overShortnumber]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$GC_LIABIALITY$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"GCLiablity"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$CHECK_CASH$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"CheckCash"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$NON_TAX_SALES$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"NonTaxSales"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$LINE_ITEM_VOID$$" withString:[NSString stringWithFormat:@"%ld",(long)[[dataDict valueForKey:@"LineItemVoid"] integerValue]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$AVG_TICKET$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"AvgTicket"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$CSC$$" withString:[NSString stringWithFormat:@"%ld",(long)[[dataDict valueForKey:@"CustomerCount"] integerValue]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$ABT$$" withString:[NSString stringWithFormat:@"%ld",(long)[[dataDict valueForKey:@"AbortedTrans"] integerValue]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$NSC$$" withString:[NSString stringWithFormat:@"%ld",(long)[[dataDict valueForKey:@"NoSales"] integerValue]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TTD$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"Discount"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$PAYOUT$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:payOutAmountNumber]]];
    html = [html stringByReplacingOccurrencesOfString:@"[Register Name]" withString:[NSString stringWithFormat:@"%@",[self.rmsDbController.globalDict valueForKey:@"RegisterName"]]];
    html = [html stringByReplacingOccurrencesOfString:@"[User Name]" withString:[NSString stringWithFormat:@"%@",[dataDict valueForKey:@"UserName"]]];
    
    NSString *strShiftStatus = [NSString stringWithFormat:@"%@",[dataDict valueForKey:@"ShiftStatus"]];
    
    if ([strShiftStatus isEqualToString:@"ShiftOpen"] )
    {
        _shiftOpen.hidden = NO;
        _shitNotOpen.hidden  = YES;
        _shiftClose.hidden = YES;
        NSString *shiftNo = [NSString stringWithFormat:@"Shift #%ld - Open",(long)[[dataDict valueForKey:@"ShiftNo"] integerValue]];
        strShiftNo=shiftNo;
        html = [html stringByReplacingOccurrencesOfString:@"$$Shift$$" withString:shiftNo];
    }
    else if (([strShiftStatus isEqualToString:@"ShiftNotOpen"]) || ([strShiftStatus isEqualToString:@"None"]))
    {
        _shiftOpen.hidden = YES;
        _shitNotOpen.hidden  = NO;
        _shiftClose.hidden = YES;
        html = [html stringByReplacingOccurrencesOfString:@"$$Shift$$" withString:@"Shift NOT Open"];
    }
    else if ([strShiftStatus isEqualToString:@"ShiftClose"])
    {
        _shiftClose.hidden = NO;
        _shiftOpen.hidden = YES;
        _shitNotOpen.hidden  = YES;
        _lblCloseDate.text = [NSString stringWithFormat:@"%@ \n %@",[dataDict valueForKey:@"CloseDate"],[dataDict valueForKey:@"CloseTime"]];
        NSString *shiftNo = [NSString stringWithFormat:@"Shift #%ld - Close",(long)[[dataDict valueForKey:@"ShiftNo"] integerValue]];
        strShiftNo = shiftNo;
        html = [html stringByReplacingOccurrencesOfString:@"$$Shift$$" withString:shiftNo];
        
        _closeShiftClosingAmount.text = [NSString stringWithFormat:@"%@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",[[dataDict valueForKey:@"ClosingAmount"] floatValue]]]];
        
        _closeShiftOpeningAmount.text = [NSString stringWithFormat:@"%@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",[[dataDict valueForKey:@"OpeningAmount"] floatValue]]]];
    }
    html = [html stringByReplacingOccurrencesOfString:@"$$Shift$$" withString:[NSString stringWithFormat:@"%@",[dataDict valueForKey:@"UserName"]]];
    
    _lblOpeningAmount.text = [NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"OpeningAmount"]]];
    
    _lblDate.text = [NSString stringWithFormat:@"%@ \n %@",[dataDict valueForKey:@"Startdate"],[dataDict valueForKey:@"StartTime"]];
    
    _lblRegisterName.text =[NSString stringWithFormat:@"%@",[self.rmsDbController.globalDict valueForKey:@"RegisterName"]];
    return html;
}


-(NSString *)htmlBillTextGenericForItemwithDictionaryMain:(NSMutableDictionary *)tenderRptCard
{
    NSString *htmldata = @"";
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"Amount"]]]];
    return htmldata;
}

-(NSString *)htmlForTips:(NSDictionary *)dict
{
    NSString *htmlForTips = @"";
    if (self.tipSetting.boolValue)
    {
        htmlForTips = [htmlForTips stringByAppendingFormat:@"<tr><td width=\"216\">Tips</td><td align=\"left\" width=\"216\" >%@</td></tr>",[self.htmlCurrencyFormatter stringFromNumber:dict [@"TotalTips"]]];
    }
    return  htmlForTips;
}

-(NSString *)htmlBillTextGenericForItemwithDictionary:(NSMutableDictionary *)tenderRptCard
{
     NSString *htmldata = @"";
    if(tenderRptCard==nil)
    {
        htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"font-weight:bold; border-top:1px solid #90BCC3; border-bottom:1px solid #90BCC3;\" ><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"Type",@"Amount",@"Count"];

        if(self.emailFromViewController)
        {
            htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"color:#44546a;\"><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
        }
    }
    else{
        double fTenderAmount = [[tenderRptCard valueForKey:@"Amount"] doubleValue];
        if (self.tipSetting.boolValue)
        {
            fTenderAmount += [[tenderRptCard valueForKey:@"TipsAmount"] doubleValue];
        }
        NSNumber *fTenderAmountNum = @(fTenderAmount);
        if(self.emailFromViewController)
        {
            htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%ld</td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:fTenderAmountNum]],(long)[[tenderRptCard valueForKey:@"Count"] integerValue]];
        }
        else{
            htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%ld</td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:fTenderAmountNum]],(long)[[tenderRptCard valueForKey:@"Count"] integerValue]];
        }
    }
    return htmldata;
}

-(NSString *)htmlGiftCardDetail:(NSMutableDictionary *)dataDict
{
    NSString *htmldata = @"";
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"font-weight:bold; border-top:1px solid #90BCC3; border-bottom:1px solid #90BCC3;\" ><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"Gift Card",@"Register",@"Total",@"Count"];
    if(self.emailFromViewController)
    {
        htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"color:#44546a;\"><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
    }
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"GC ADY",@"",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"TotalGCADY"]],@""];
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%ld</td></tr>",@"Load",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"LoadAmount"]],[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"TotalLoadAmount"]],(long)[[dataDict valueForKey:@"LoadCount"] integerValue]];
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%ld</td></tr>",@"Redeem",[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"RedeemAmount"]],[self.htmlCurrencyFormatter stringFromNumber:[dataDict valueForKey:@"TotalRedeemAmount"]],(long)[[dataDict valueForKey:@"RedeemCount"] integerValue]];
    
    return htmldata;
}

-(NSString *)htmlDiscountDetail:(NSArray *)discountArray
{
    NSString *htmldata = @"";
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"font-weight:bold; border-top:1px solid #90BCC3; border-bottom:1px solid #90BCC3;\" ><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"Discount Type",@"Sales",@"Discount",@"Count"];
    if(self.emailFromViewController)
    {
        htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"color:#44546a;\"><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
    }
    
    if ([discountArray isKindOfClass:[NSArray class]] && discountArray != nil) {
        NSDictionary *customizedDiscountDict = [self customizedDiscountFromArray:discountArray];
        NSDictionary *manualDiscountDict = [self manualDiscountFromArray:discountArray];
        NSDictionary *preDefinedDiscountDict = [self preDefinedDiscountFromArray:discountArray];
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"Customized",[self.htmlCurrencyFormatter stringFromNumber: customizedDiscountDict [@"Sales"]],[self.htmlCurrencyFormatter stringFromNumber: customizedDiscountDict [@"Amount"]],customizedDiscountDict [@"Count"]];
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"Manual",[self.htmlCurrencyFormatter stringFromNumber: manualDiscountDict [@"Sales"]],[self.htmlCurrencyFormatter stringFromNumber: manualDiscountDict [@"Amount"]],manualDiscountDict [@"Count"]];
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"PreDefined",[self.htmlCurrencyFormatter stringFromNumber: preDefinedDiscountDict [@"Sales"]],[self.htmlCurrencyFormatter stringFromNumber: preDefinedDiscountDict [@"Amount"]],preDefinedDiscountDict [@"Count"]];
    }
    
    return htmldata;
}

- (NSDictionary *)customizedDiscountFromArray:(NSArray *)discountArray
{
    return [self discountDetailsForDiscountCategory:2 withDiscountArray:discountArray];
}

- (NSDictionary *)manualDiscountFromArray:(NSArray *)discountArray
{
    return [self discountDetailsForDiscountCategory:3 withDiscountArray:discountArray];
}

- (NSDictionary *)preDefinedDiscountFromArray:(NSArray *)discountArray
{
    return [self discountDetailsForDiscountCategory:1 withDiscountArray:discountArray];
}

- (NSDictionary *)discountDetailsForDiscountCategory:(NSInteger)discountCategory withDiscountArray:(NSArray *)discountArray{
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"DiscountCategory == %@", @(discountCategory)];
    NSArray *discount = [discountArray filteredArrayUsingPredicate:discountPredicate];
    NSMutableDictionary *discountDetail;
    if (discount.count > 0) {
        discountDetail = [discount.firstObject mutableCopy];
    }
    else
    {
        discountDetail = [[NSMutableDictionary alloc] init];
        discountDetail[@"Amount"] = @(0.00);
        discountDetail[@"Count"] = @(0);
        discountDetail[@"Sales"] = @(0.00);
        discountDetail[@"DiscountCategory"] = @(discountCategory);
    }
    return discountDetail;
}

-(NSString *)htmlForTenderTips:(NSMutableDictionary *)tenderRptCard 
{
    NSString *htmldata = @"";
    if (self.tipSetting.boolValue)
    {
        if(tenderRptCard==nil)
        {
            if (self.emailFromViewController) {
                htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"color:#44546a;\"><td style=\"border-bottom:1px solid #90BCC3;\">Tender Tips</td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
                htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"font-weight:bold;\"><td>%@</td><td>%@</td><td>%@</td><td>%@</td></tr>",@"Type",@"Amount",@"Tips",@"Total"];
                htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"color:#44546a;\"><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
            }
            else
            {
                htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"font-weight:bold;\" ><td width=\"162\">%@</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td></tr>",@"Type",@"Amount",@"Tips",@"Total"];
            }
        }
        else{
            double tenderAmount = [[tenderRptCard valueForKey:@"Amount"] doubleValue] + [[tenderRptCard valueForKey:@"TipsAmount"] doubleValue];
            NSNumber *numTenderAmount = @(tenderAmount);
            
            if(self.emailFromViewController)
            {
                htmldata = [htmldata stringByAppendingFormat:@"<tr><td>%@</td><td>%@</td><td>%@</td><td>%@</td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"Amount"]]],[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"TipsAmount"]]],[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:numTenderAmount]]];
            }
            else{
                htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"162\">%@</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"Amount"]]],[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"TipsAmount"]]],[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:numTenderAmount]]];
            }
        }
    }
    return htmldata;
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _historyTable)
    {
        return 95;
    }
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == _historyTable)
    {
        return self.historyArray.count;
    }
    else if (tableView == _tbluserShiftDetail)
    {
        return self.userShiftDetailArray.count;
    }
    return 1;
}

- (UITableViewCell *)historyCellConfigure:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    ShiftHistoryCell *cell = (ShiftHistoryCell*)[tableView dequeueReusableCellWithIdentifier:@"ShiftHistoryCell" forIndexPath:indexPath];
    
    if (indexPath.row == self.selectedIndexPath)
    {
        cell.lblRegName.textColor = [UIColor whiteColor];
        cell.lblCustDate.textColor = [UIColor whiteColor];
        cell.lblShift.textColor = [UIColor whiteColor];
        cell.lblCusSales.textColor = [UIColor whiteColor];
        cell.lblCusTax.textColor = [UIColor whiteColor];
        cell.lblToatalSales.textColor = [UIColor whiteColor];
        cell.backgroundImgView.contentMode = UIViewContentModeScaleToFill;
        cell.backgroundImgView.image = [UIImage imageNamed:@"ReportActiveRowBlogBg.png"];
    }
    else
    {
        cell.lblRegName.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255 alpha:1.0];
        cell.lblCustDate.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255 alpha:1.0];
        cell.lblShift.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255 alpha:1.0];
        cell.lblCusSales.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255 alpha:1.0];
        cell.lblCusTax.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255 alpha:1.0];
        cell.lblToatalSales.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255 alpha:1.0];
        cell.backgroundImgView.contentMode = UIViewContentModeScaleToFill;
        cell.backgroundImgView.image = [UIImage imageNamed:@"ReportBlogBg.png"];
    }
    return cell;
}

- (UITableViewCell *)userShiftDetailCellConfigure:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    UserShiftDetailCell *cell = (UserShiftDetailCell*)[tableView dequeueReusableCellWithIdentifier:@"UserShiftDetailCell" forIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell;
    if (tableView == _historyTable)
    {
        cell = [self historyCellConfigure:indexPath tableView:tableView];
        [(ShiftHistoryCell *)cell updateWithShiftDetailDict:(self.historyArray)[indexPath.row]];
    }
    if (tableView == _tbluserShiftDetail)
    {
        if (self.userShiftDetailArray.count >0 )
        {
            cell = [self userShiftDetailCellConfigure:indexPath tableView:tableView];
            [(UserShiftDetailCell *)cell updateWithUserDetailDict:(self.userShiftDetailArray)[indexPath.row]];
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == _historyTable)
    {
       
        self.selectedIndexPath = indexPath.row;
        [self historyUserDetail:(self.historyArray)[indexPath.row]];
        [_historyTable reloadData];
    }
    if (tableView == _tbluserShiftDetail)
    {
        _txtUseName.text = [(self.userShiftDetailArray)[indexPath.row] valueForKey:@"UserName"];
        if ([[(self.userShiftDetailArray)[indexPath.row] valueForKey:@"UserName"] isEqualToString:@"None"])
        {
            [self ShiftOpenCurrentDetail];
        }
        else
        {
            [self userShiftDetail:(self.userShiftDetailArray)[indexPath.row]];
        }
        _tbluserShiftDetail.hidden = YES;
    }
}

-(void)userShiftDetail :(NSMutableDictionary *)userDict
{
    _tbluserShiftDetail.hidden = YES;
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
	dict[@"UserId"] = [userDict valueForKey:@"UserId"];
    dict[@"ZId"] = userDict[@"ZId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self shiftOpenCurrentDetailResponse:response error:error];
    };
    
    self.shiftOpenCurrentDetailWC2 = [self.shiftOpenCurrentDetailWC2 initWithRequest:KURL actionName:WSM_SHIFT_OPEN_CURRENT_DETAIL params:dict completionHandler:completionHandler];
}

-(IBAction)history:(id)sender
{
     _btnPrintShift.hidden=YES;
    
    [self.rmsDbController playButtonSound];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    _lblUserName.text = [self.rmsDbController userNameOfApp];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    //  [dict setObject:[self.rmsDbController.globalDict objectForKey:@"RegisterId"] forKey:@"RegisterId"];
	dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shiftHistoryListResponse:response error:error];
        });
    };
    
    self.shifHistoryListWC = [self.shifHistoryListWC initWithRequest:KURL actionName:WSM_SHIFT_HISTORY_LIST params:dict completionHandler:completionHandler];
}

-(void)shiftHistoryListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _viewHistory.hidden = NO;
                _shiftReport.hidden = YES;
                _webHistoryWebView.hidden = NO;
                self.historyArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                _lblHistroyCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.historyArray.count];
                self.selectedIndexPath = 0;
                if (self.historyArray.count > 0) {
                    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                    [self historyUserDetail:self.historyArray.firstObject];
                }
                [_historyTable reloadData];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Shift Open | Close" message:@"No shift report found in history page" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(void)historyUserDetail :(NSMutableDictionary *)historyDetail
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    _btnPrintShift.hidden=NO;

    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = [historyDetail valueForKey:@"BranchId"];
    dict[@"RegisterId"] = [historyDetail valueForKey:@"RegisterId"];
	dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"ZId"] = [historyDetail valueForKey:@"ZId"];
	dict[@"BrnCashInOutId"] = [historyDetail valueForKey:@"BrnCashInOutId"];
	dict[@"ClosingDate"] = [historyDetail valueForKey:@"ClsDate"];
	dict[@"OpeningDate"] = [historyDetail valueForKey:@"OpnDate"];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shiftHistoryDetailResponse:response error:error];
        });
    };
    
    self.shiftHistoryDetailWC = [self.shiftHistoryDetailWC initWithRequest:KURL actionName:WSM_SHIFT_HISTORY_DETAIL params:dict completionHandler:completionHandler];
}

-(void)shiftHistoryDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                NSMutableArray *shiftDetailArray = [responseArray.firstObject valueForKey:@"objShiftDetail"];
                shiftDetailArrayForPrint = [responseArray mutableCopy];
                
                //NSMutableDictionary *shiftDetailDict = [shiftDetailArray firstObject];
                dictshiftDetailTemp = shiftDetailArray.firstObject;
                
                // objShiftTender
                shiftTenderArrayTemp = [responseArray.firstObject valueForKey:@"objShiftTender"];
                discountArrayTemp = [responseArray.firstObject valueForKey:@"objShiftDiscount"];
                
                NSString *baseUrlPath = [[NSBundle mainBundle] pathForResource:@"ShiftReport" ofType:@"html"];
                
                if (self.userShiftDetailArray.count==0) {
                    self.userShiftDetailArray =[responseArray.firstObject valueForKey:@"objShiftUser"];
                    NSMutableDictionary *dictNone = [[NSMutableDictionary alloc]init];
                    dictNone[@"UserName"] = @"None";
                    [self.userShiftDetailArray insertObject:dictNone atIndex:self.userShiftDetailArray.count];
                }
                shiftHtml = [NSString stringWithContentsOfFile:baseUrlPath encoding:NSUTF8StringEncoding error:nil];
                shiftHtml = [self htmlForShiftReport:shiftHtml replaceWithData:dictshiftDetailTemp replaceWithTenderData:shiftTenderArrayTemp discountArray:discountArrayTemp];
                NSData* data = [shiftHtml dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = paths.firstObject;
                sourcePath = [documentsDirectory stringByAppendingPathComponent:@"shiftDetail.html"];
                
                shiftHtml =[shiftHtml stringByReplacingOccurrencesOfString:@"$$SHIFT_STAR_END_DATE$$" withString:@""];
                [data writeToFile:sourcePath atomically:YES];
                
                
                NSString *htmldata = [self generateHTMLForShiftReportFromDictionary:responseArray.firstObject];
                htmldata =  [self createHTMLFormateForDisplayReportInWebView:htmldata];
                
                [_webHistoryWebView loadHTMLString:htmldata baseURL:nil];
            }
        }
    }
}

- (NSString *)createHTMLFormateForDisplayReportInWebView:(NSString *)html
{
    NSString *strReport = [html stringByReplacingOccurrencesOfString:@"$$STYLE$$" withString:@"<style>TD{} TD.TederType { width: 30%;padding-bottom:3px;} TD.TederTypeAmount { width: 40%;padding-bottom:3px;} TD.TederTypeAvgTicket { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.TederTypePer { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.TederTypeCount { width: 30%;padding-bottom:3px;} TD.CardType { width: 30%;padding-bottom:3px;}</style>"];
    strReport =  [strReport stringByReplacingOccurrencesOfString:@"$$WIDTH$$" withString:@"width:286px"];
    strReport = [strReport stringByReplacingOccurrencesOfString:@"$$WIDTHCOMMONHEADER$$" withString:@"width:300px"];
    return strReport;
}

-(IBAction)btnDropDown:(id)sender
{
    [self.rmsDbController playButtonSound];
    _tbluserShiftDetail.hidden = NO;
    [_tbluserShiftDetail reloadData];
}

-(IBAction)btnBack:(id)sender
{
    _btnPrintShift.hidden=YES;
    _viewHistory.hidden = YES;
    _webHistoryWebView.hidden = YES;
    _shiftReport.hidden = NO;
}

-(void)emailButtonPressed
{
    [self emailButtonPressed:nil];
}


- (IBAction)emailButtonPressed:(id)sender
{
    NSString *strShiftStatus = [NSString stringWithFormat:@"%@",[dictshiftDetailTemp valueForKey:@"ShiftStatus"]];
    if (![strShiftStatus isEqualToString:@"None"])
    {
        [self.rmsDbController playButtonSound];

        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        self.emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMM dd, yyyy";
        NSString *currentDateTime = [formatter stringFromDate:date];
        
        strShiftNo = [NSString stringWithFormat:@"Shift #%@ - %@",[dictshiftDetailTemp valueForKey:@"ShiftNo"],[dictshiftDetailTemp valueForKey:@"ShiftStatus"]];
        
        NSString *strsubjectLine = [NSString stringWithFormat:@"%@   %@   %@",[self.rmsDbController.globalDict valueForKey:@"RegisterName"],strShiftNo,currentDateTime];
        
        
        NSString *stringHtml=[self getHtmlStringFromData];
        
        // Store Shift File
        NSData* data = [stringHtml dataUsingEncoding:NSUTF8StringEncoding];
        
        //
        self.emailFromViewController.emailFromViewControllerDelegate = self;

        self.emailFromViewController.dictParameter =[[NSMutableDictionary alloc]init];
        (self.emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
        (self.emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
        (self.emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
        (self.emailFromViewController.dictParameter)[@"postfile"] = data;
        (self.emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
        
        [self.view addSubview:self.emailFromViewController.view];
        
    }
}

-(void)didCancelEmail
{
    [self.emailFromViewController.view removeFromSuperview];
}


-(NSString *)getHtmlStringFromData
{
    NSString *baseUrlPath = [[NSBundle mainBundle] pathForResource:@"EmailShiftReport" ofType:@"html"];
    shiftHtmlEmail = [NSString stringWithContentsOfFile:baseUrlPath encoding:NSUTF8StringEncoding error:nil];
    shiftHtmlEmail = [self htmlForShiftReport:shiftHtmlEmail replaceWithData:dictshiftDetailTemp replaceWithTenderData:shiftTenderArrayTemp discountArray:discountArrayTemp];
    
    return [self fillDataForEmail:shiftHtmlEmail];
}


-(NSString *)fillDataForEmail:(NSString *)html{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM dd,yyyy  h:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    strDateTime = [strDateTime stringByReplacingOccurrencesOfString:@"  " withString:@" @ "];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$SHIFT_EMAIL_DATE$$" withString:strDateTime];
    html = [html stringByReplacingOccurrencesOfString:@"$$BATCH_NO$$" withString:@"1"];
    html = [html stringByReplacingOccurrencesOfString:@"$$OPENING_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",@""]];
    
    NSString *strStrartDate = [self getStringFormate:[dictshiftDetailTemp valueForKey:@"Startdate"] fromFormate:@"MM/dd/yyyy" toFormate:@"MMM dd,yyyy"];
    NSString *strStrartTime = [self getStringFormate:[dictshiftDetailTemp valueForKey:@"StartTime"] fromFormate:@"HH:mm:ss" toFormate:@"hh:mm a"];
    NSString *stropeningDate= [NSString stringWithFormat:@"%@ $ %@",strStrartDate,strStrartTime];
    
    stropeningDate = [stropeningDate stringByReplacingOccurrencesOfString:@"$" withString:@"@"];
    
    NSString *strCloseDate = [self getStringFormate:[dictshiftDetailTemp valueForKey:@"CloseDate"] fromFormate:@"MM/dd/yyyy" toFormate:@"MMM dd,yyyy"];
    
    NSString *strCloseTime = [self getStringFormate:[dictshiftDetailTemp valueForKey:@"CloseTime"] fromFormate:@"HH:mm:ss" toFormate:@"hh:mm a"];
    
    NSString *strclosingdate= [NSString stringWithFormat:@"%@ $ %@",strCloseDate,strCloseTime];
    
    strclosingdate = [strclosingdate stringByReplacingOccurrencesOfString:@"$" withString:@"@"];
    
    
    NSString *strShiftStatus = [NSString stringWithFormat:@"%@",[dictshiftDetailTemp valueForKey:@"ShiftStatus"]];
    
    //if([dictshiftDetailTemp valueForKey:@"Startdate"] && [dictshiftDetailTemp valueForKey:@"StartTime"] && [dictshiftDetailTemp valueForKey:@"CloseDate"] && [dictshiftDetailTemp valueForKey:@"CloseTime"])
    
    if ([strShiftStatus isEqualToString:@"ShiftClose"] )
    {
        html =[html stringByReplacingOccurrencesOfString:@"$$OPEN_DATE$$" withString:stropeningDate];
        html =[html stringByReplacingOccurrencesOfString:@"$$CLOSE_DATE$$" withString:strclosingdate];
    }
    else if([strShiftStatus isEqualToString:@"ShiftOpen"]) {
        html =[html stringByReplacingOccurrencesOfString:@"$$OPEN_DATE$$" withString:stropeningDate];
        html =[html stringByReplacingOccurrencesOfString:@"$$CLOSE_DATE$$" withString:@"-"];
    }
    else{
        html =[html stringByReplacingOccurrencesOfString:@"$$OPEN_DATE$$" withString:@"-"];
        html =[html stringByReplacingOccurrencesOfString:@"$$CLOSE_DATE$$" withString:@"-"];
    }
    html = [html stringByReplacingOccurrencesOfString:@"$$GROSS_SALE$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dictshiftDetailTemp valueForKey:@"DailySales"]]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_TAX$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dictshiftDetailTemp valueForKey:@"CollectTax"]]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DISCOUNT_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:[dictshiftDetailTemp valueForKey:@"Discount"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$VOID$$" withString:[NSString stringWithFormat:@"%ld",(long)[[dictshiftDetailTemp valueForKey:@"AbortedTrans"] integerValue]]];
    
    NSNumber *checkcashamount = @0;
    html = [html stringByReplacingOccurrencesOfString:@"$$CHECK_CASH_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",[self.htmlCurrencyFormatter stringFromNumber:checkcashamount]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$BUSINESS_NAME$$" withString:[NSString stringWithFormat:@"Business Name - %@",(self.rmsDbController.globalDict)[@"BranchInfo"][@"BranchName"]]];
    return html;
}


-(NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
}

#pragma mark - Delegate Methods
// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			break;
		default:
			break;
	}
	[self dismissViewControllerAnimated:YES completion:NULL];
}
// -------------------------------------------------------------------------------
//	messageComposeViewController:didFinishWithResult:
//  Dismisses the message composition interface when users tap Cancel or Send.
//  Proceeds to update the feedback message field with the result of the
//  operation.
// -------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
			break;
		case MessageComposeResultSent:
			break;
		case MessageComposeResultFailed:
			break;
		default:
			break;
	}
	[self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)cancel:(id)sender
{
    if(self.isfromDashBoard){
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        
        [self.rmsDbController playButtonSound];
        NSArray *viewControllerArray = self.navigationController.viewControllers;
        for (UIViewController *viewController in viewControllerArray)
        {
            if ([viewController isKindOfClass:[DashBoardSettingVC class]])
            {
                [self.navigationController popToViewController:viewController animated:TRUE];
            }
        }
    }
}
-(IBAction)lastShiftCloseDetail:(id)sender
{
    [self.rmsDbController playButtonSound];
    self.emailFromViewController = nil;
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
	dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shiftCloseDetailResponse:response error:error];
        });
    };
    
    self.shiftCloseDetailWC = [self.shiftCloseDetailWC initWithRequest:KURL actionName:WSM_SHIFT_CLOSE_DETAIL params:dict completionHandler:completionHandler];
}

-(void)shiftCloseDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                //hiten
                _btnCurrentShiftDetail.hidden = NO;
                [_btnlastShiftReport setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                NSMutableArray  *shiftDetailArray = [responseArray.firstObject valueForKey:@"objShiftDetail"];
                shiftDetailArrayForPrint = [responseArray mutableCopy];
                
                NSMutableDictionary *shiftDetailDict = shiftDetailArray.firstObject;
                dictshiftDetailTemp = shiftDetailArray.firstObject;
                
                // objShiftTender
                shiftTenderArrayTemp = [responseArray.firstObject valueForKey:@"objShiftTender"];
                
                discountArrayTemp = [responseArray.firstObject valueForKey:@"objShiftDiscount"];
                
                NSLog(@"Close-Shift Server Id %@",[shiftDetailDict valueForKey:@"CashInOutId"]);
                
                serverShiftId  = @([[shiftDetailDict valueForKey:@"CashInOutId"] integerValue]);
                
                OflineShiftReportCalculation *oflineShiftReportCalculation = [[OflineShiftReportCalculation alloc]initWithArray:responseArray withZid:(self.rmsDbController.globalDict)[@"ZId"]];
                [oflineShiftReportCalculation updateReportWithOfflineDetail];
                
                if ([[shiftDetailDict valueForKey:@"ShiftStatus"] isEqualToString:@"None"])
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Shift Open | Close" message:@"No shift report found in last shift close report" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else
                {
                    NSString *baseUrlPath = [[NSBundle mainBundle] pathForResource:@"ShiftReport" ofType:@"html"];
                    shiftHtml = [NSString stringWithContentsOfFile:baseUrlPath encoding:NSUTF8StringEncoding error:nil];
                    shiftHtml = [self htmlForShiftReport:shiftHtml replaceWithData:shiftDetailDict replaceWithTenderData:shiftTenderArrayTemp discountArray:discountArrayTemp];
                    if ([self isShiftHasInvoiceInOffline] == FALSE)
                    {
                        shiftHtml = [shiftHtml stringByReplacingOccurrencesOfString:@"OFFLINE" withString:@""];
                    }
                    NSData* data = [shiftHtml dataUsingEncoding:NSUTF8StringEncoding];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = paths.firstObject;
                    sourcePath = [documentsDirectory stringByAppendingPathComponent:@"shiftDetail.html"];
                    [data writeToFile:sourcePath atomically:YES];
                    
                    shiftHtml =[shiftHtml stringByReplacingOccurrencesOfString:@"$$SHIFT_STAR_END_DATE$$" withString:@""];
                    
                    [_shiftReport loadHTMLString:shiftHtml baseURL:nil];
                }
            }
        }
    }
}

#pragma mark-
#pragma  Shift Open-Close Process

-(void)shiftOpenCloseProcess :(NSString *)shiftType
{
    self.shift = [[ShiftInOutPopOverVC alloc]initWithNibName:@"ShiftInOutPopOverVC" bundle:nil];
    self.shift.shiftInOutPopOverDelegate = self;
    self.shift.strType = shiftType;
    [self.view addSubview:self.shift.view];
}

-(IBAction)openShift:(id)sender
{
    [self.rmsDbController playButtonSound];
    self.shiftType =@"SHIFT OPEN";
    [self shiftOpenCloseProcess:@"SHIFT OPEN"];
}

-(IBAction)closeShift:(id)sender
{
    [self.rmsDbController playButtonSound];
    self.shiftType =@"SHIFT CLOSE";
    [self shiftOpenCloseProcess:@"SHIFT CLOSE"];
}

#pragma mark-
#pragma  ShiftInOutPopOverVC delegate Methods

-(void)shiftIn_OutSuccessfullyDone
{
    self.shift.view.hidden = YES;
    
    NSString *msg = [NSString stringWithFormat:@"%@ successfully",self.shiftType];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Shift Open | Close" message:msg buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    
    
    if ([self.shiftType isEqualToString:@"SHIFT OPEN"])
    {
        [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"CashInOutFlg"] = [NSNumber numberWithBool:1];
        
        [self ShiftOpenCurrentDetail];
    }
    else  if ([self.shiftType isEqualToString:@"SHIFT CLOSE"])
    {
        [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"CashInOutFlg"] = [NSNumber numberWithBool:0];
        self.isfromDashBoard = NO;
        [self lastShiftCloseDetail:nil];
    }
    [self conFigureShiftStatus];
    self.shiftType = @"";
}

-(void)ShiftIn_OutProcessFailed
{
    
}

-(void)dismissShiftIn_OutController
{
    self.shift.view.hidden = YES;
    if (self.isShifInOutFromReport == FALSE)
    {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

-(void)sendShiftOfflineDataToServer
{
    self.nextIndex = 0;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate= [self predicateForShiftUser];
    fetchRequest.predicate = predicate;
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    self.offlineInvoice = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(self.offlineInvoice.count > 0)
    {
#define UPLOAD_OFFLINE_INVOICES
#ifdef UPLOAD_OFFLINE_INVOICES
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self uploadNextInvoiceData];
        });
#else
        [self ShiftOpenCurrentDetail];
        [self conFigureShiftStatus];
#endif
    }
    else
    {
        [self ShiftOpenCurrentDetail];
        [self conFigureShiftStatus];
    }
}

- (void)uploadNextInvoiceData
{
    if(self.nextIndex >= self.offlineInvoice.count)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self ShiftOpenCurrentDetail];
            [self conFigureShiftStatus];
        });
        return;
    }
    InvoiceData_T *invoiceDataT = (self.offlineInvoice)[self.nextIndex];
    NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceMstData] firstObject];
    invoiceDetailDict[@"InvoiceItemDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceItemData] firstObject];
    invoiceDetailDict[@"InvoicePaymentDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoicePaymentData] firstObject];
    [invoiceDetail addObject:invoiceDetailDict];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init ];
    param[@"InvoiceDetail"] = invoiceDetail;
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self doAsynchOfflineShiftReportProcessResponse:response error:error];
    };
    
    self.webServiceConnectionShiftOffline = [self.webServiceConnectionShiftOffline initWithAsyncRequest:KURL_INVOICE actionName:WSM_INVOICE_INSERT_LIST params:param asyncCompletionHandler:asyncCompletionHandler];
}

- (void) doAsynchOfflineShiftReportProcessResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_queue_create("doAsynchOfflinePaymentProcess", NULL), ^{
        [self doAsynchOfflineProcessResponse:response error:error];
    });
}

- (void)doAsynchOfflineProcessResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                InvoiceData_T *invoiceDataT = (self.offlineInvoice)[self.nextIndex];
                
                NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                [UpdateManager saveContext:privateManagedObjectContext];
            }
            else  if ([[response valueForKey:@"IsError"] intValue] == -2)
            {
                InvoiceData_T *invoiceDataT = (self.offlineInvoice)[self.nextIndex];
                
                NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                [UpdateManager saveContext:privateManagedObjectContext];
            }
            else
            {
            }
        }
    }
    
    self.nextIndex++;
    [self uploadNextInvoiceData];
}


- (void)updatePaymentTypeWithOfflineData:(NSMutableArray *)shiftOnlineReportArray offlinePaymentArray:(NSMutableArray *)offlinePaymentArray
{
    NSMutableArray *shiftOnlinePaymentArray = shiftOnlineReportArray;
    
    if (offlinePaymentArray.count > 0)
    {
        for (int i=0; i < shiftOnlinePaymentArray.count; i++)
        {
            NSMutableDictionary *shiftOfflineDictionary = shiftOnlinePaymentArray[i];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"PayId == %@", [shiftOnlinePaymentArray[i]valueForKey:@"TenderId"]];
            
            NSMutableArray *paymentResultArray = [[offlinePaymentArray filteredArrayUsingPredicate:predicate] mutableCopy];
            NSNumber *paymentResultOfflineSum = 0;
            if(paymentResultArray.count>0)
            {
                paymentResultOfflineSum =[paymentResultArray valueForKeyPath:@"@sum.BillAmount"];
                float amount = [[shiftOnlinePaymentArray[i]valueForKey:@"Amount"] floatValue];
                amount = amount + paymentResultOfflineSum.floatValue;
                
                NSInteger tenderCount = [[shiftOnlinePaymentArray[i]valueForKey:@"Count"] integerValue] + paymentResultArray.count;
                
                shiftOfflineDictionary[@"Amount"] = @(amount);
                shiftOfflineDictionary[@"Count"] = [NSString stringWithFormat:@"%ld",(long)tenderCount];
            }
        }
    }
}



-(NSMutableArray *)fetchTaxDataFromInvoiceTable
{
    NSMutableArray *zOfflineArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate= [self predicateForShiftUser];
    fetchRequest.predicate = predicate;

    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(object.count>0)
    {
        for (InvoiceData_T *invoice in object)
        {
            if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoicePaymentData] firstObject] count]>0)
            {
                NSMutableArray *archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject];
                for(int i=0;i<archiveArray.count;i++){
                    
                    NSMutableArray * offlineTaxArray = [archiveArray[i] valueForKey:@"ItemTaxDetail"];
                    if ([offlineTaxArray isKindOfClass:[NSMutableArray class]])
                    {
                        if (offlineTaxArray.count > 0)
                        {
                            for(int j=0;j<offlineTaxArray.count;j++)
                            {
                                [zOfflineArray addObject:offlineTaxArray[j]];
                            }
                        }
                    }
                }
            }
        }
    }
    return zOfflineArray;
}


-(void)updateShiftRportDetailWithOfflineData :(NSMutableArray *)shiftReportArray
{
    NSMutableArray *offlinePaymentArray = [self fetchPaymentDataFromInvoiceTable];
    
    /// update payment type detail with offline data.....
    [self updatePaymentTypeWithOfflineData:[shiftReportArray.firstObject valueForKey:@"objShiftTender"] offlinePaymentArray:offlinePaymentArray];
    
    /// update main tender data with offline data.......
    [self updateMainTenderValueWithOfflineData:shiftReportArray offlinePaymentArray:offlinePaymentArray];
    
}

- (void)updateMainTenderValueWithOfflineData:(NSMutableArray *)zReportArray offlinePaymentArray:(NSMutableArray *)offlinePaymentArray
{
    NSMutableArray *zOnlineMainArray = [zReportArray.firstObject valueForKey:@"objShiftDetail"];
    if (zOnlineMainArray.count > 0)
    {
        NSMutableDictionary *zOnlineMainDictionary = zOnlineMainArray.firstObject;
        
        // update gross sales with offline data....
        CGFloat grossSales =  [self updateTotalSalesPriceWithofflineData:offlinePaymentArray withOnlinePaymentDictionary:zOnlineMainDictionary];
        
        //update avg ticket
        [self updateOfflineAvgTicket:offlinePaymentArray withOnlinePaymentDictionary:zOnlineMainDictionary];
        
        // update collected tax with offline data....
        CGFloat collectedTax = [self updateCollectedTaxWithofflineData:[self fetchTaxDataFromInvoiceTable] withOnlinePaymentDictionary:zOnlineMainDictionary];
        
        // update sales for with offline data...
        CGFloat offlineSale = grossSales - collectedTax;
        [self updateSalesWithOfflineSales:offlineSale withOnlineMainDictionary:zOnlineMainDictionary];
    }
}



-(void)updateSalesWithOfflineSales :(CGFloat )offlineSales withOnlineMainDictionary:(NSMutableDictionary *)zOnlineMainDictionary
{
    NSMutableArray *offlineSalesArray = [self fetchItemFromInvoiceTable];
    
    if (offlineSalesArray.count == 0) {
        return;
    }
    
    NSNumber *itemTotalOfflineSum = 0;
    NSNumber *itemTotalOfflineExtrachargeSum = 0;
    
    NSNumber *itemTotalOfflineCheckcashSum = 0;
    NSNumber *itemTotalOfflineExtrachargeCheckcaseSum = 0;
    
    NSNumber *itemReturnAmount = 0;
    double noTaxSalesDouble = 0;
    double isDiductDouble = 0;

    NSPredicate *isCheckcashFlasePredicate = [NSPredicate predicateWithFormat:@"isCheckCash == %@ OR isCheckCash == %@", @"0",@(0)];
    NSArray *isCheckcashFlaseArray = [offlineSalesArray filteredArrayUsingPredicate:isCheckcashFlasePredicate];
    if (isCheckcashFlaseArray.count > 0)
    {
        NSPredicate *isGreaterItemAmountPredicate = [NSPredicate predicateWithFormat:@"(ItemAmount > %@) AND (isDeduct == %@ OR isDeduct == %@)",@"0.00",@"0",@(0)];
       NSArray *isGreaterAnountArray = [isCheckcashFlaseArray filteredArrayUsingPredicate:isGreaterItemAmountPredicate];
        
        if (isGreaterAnountArray.count > 0)
        {
            itemTotalOfflineSum = [isGreaterAnountArray valueForKeyPath:@"@sum.ItemAmount"];
            itemTotalOfflineExtrachargeSum = [isGreaterAnountArray valueForKeyPath:@"@sum.ExtraCharge"];
        }
        
        NSPredicate *isLessItemAmountPredicate = [NSPredicate predicateWithFormat:@"(ItemAmount < %@) AND (isDeduct == %@ OR isDeduct == %@)",@"0.00",@"0",@(0)];
        NSArray *isLessItemAmountArray = [isCheckcashFlaseArray filteredArrayUsingPredicate:isLessItemAmountPredicate];
        
        if (isLessItemAmountArray.count > 0)
        {
            itemReturnAmount = [isLessItemAmountArray valueForKeyPath:@"@sum.ItemAmount"];
        }
    }
    
    NSPredicate *isNoTaxSales = [NSPredicate predicateWithFormat:@"(ItemTaxAmount == %@ OR ItemTaxAmount == %@) AND (isDeduct == %@ OR isDeduct == %@)",@"0.0",@(0.0),@"0",@(0)];
    NSArray *noTaxSalesArray = [offlineSalesArray filteredArrayUsingPredicate:isNoTaxSales];
    if (noTaxSalesArray.count > 0) {
        for (NSDictionary *dict in noTaxSalesArray) {
          noTaxSalesDouble += [[dict valueForKey:@"ItemBasicAmount"] floatValue] * [[dict valueForKey:@"ItemQty"] integerValue];
        }
    }
    
    CGFloat noTaxSales = [[zOnlineMainDictionary valueForKey:@"NonTaxSales"] floatValue] + @(noTaxSalesDouble).floatValue;
    zOnlineMainDictionary[@"NonTaxSales"] = [NSNumber numberWithFloat:noTaxSales];

    NSPredicate *isDeductPredicate = [NSPredicate predicateWithFormat:@"(isDeduct == %@ OR isDeduct == %@)",@"1",@(1)];
    NSArray *isDeductArray = [offlineSalesArray filteredArrayUsingPredicate:isDeductPredicate];
    if (isDeductArray.count > 0) {
        for (NSDictionary *dict in isDeductArray) {
            isDiductDouble += [[dict valueForKey:@"ItemBasicAmount"] floatValue] * [[dict valueForKey:@"ItemQty"] integerValue];
        }
    }

    CGFloat isDiduct = [[zOnlineMainDictionary valueForKey:@"PayOut"] floatValue] + @(isDiductDouble).floatValue;
    zOnlineMainDictionary[@"PayOut"] = [NSNumber numberWithFloat:isDiduct];

    NSInteger customerCount = [[zOnlineMainDictionary valueForKey:@"CustomerCount"] integerValue] + [self getOfflineCustomerCount];
    zOnlineMainDictionary[@"CustomerCount"] = @(customerCount);
    
    NSPredicate *isCheckcashTruePredicate = [NSPredicate predicateWithFormat:@"isCheckCash == %@ OR isCheckCash == %@", @"1",@(1)];
    NSArray *isCheckcashTrueArray = [offlineSalesArray filteredArrayUsingPredicate:isCheckcashTruePredicate];
    
    if (isCheckcashTrueArray.count > 0)
    {
        NSPredicate *isGreaterItemAmountPredicate = [NSPredicate predicateWithFormat:@"(ItemAmount > %@) AND (isDeduct == %@ OR isDeduct == %@)",@"0.00",@"0",@(0)];
        isCheckcashTrueArray = [isCheckcashTrueArray filteredArrayUsingPredicate:isGreaterItemAmountPredicate];
        if (isCheckcashTrueArray.count > 0)
        {
            itemTotalOfflineCheckcashSum = [isCheckcashTrueArray valueForKeyPath:@"@sum.CheckCashAmount"];
            itemTotalOfflineExtrachargeCheckcaseSum = [isCheckcashTrueArray valueForKeyPath:@"@sum.ExtraCharge"];
        }
    }
    
    CGFloat salesTotalOnlineAndOffline = [[zOnlineMainDictionary valueForKey:@"Sales"] floatValue] + itemTotalOfflineSum.floatValue + itemTotalOfflineExtrachargeSum.floatValue + itemTotalOfflineCheckcashSum.floatValue + itemTotalOfflineExtrachargeCheckcaseSum.floatValue;
    zOnlineMainDictionary[@"Sales"] = [NSNumber numberWithFloat:salesTotalOnlineAndOffline];

    CGFloat totalReturnAmount = [[zOnlineMainDictionary valueForKey:@"Return"] floatValue] + itemReturnAmount.floatValue;
    zOnlineMainDictionary[@"Return"] = [NSNumber numberWithFloat:totalReturnAmount];
}

-(void)updateOfflineAvgTicket:(NSMutableArray *)offlinePaymentArray withOnlinePaymentDictionary:(NSMutableDictionary *)zOnlineMainDictionary
{
    NSNumber *salesPriceOfflineSum = 0;
    NSNumber *cahngeOfflineSum = 0;
    if (offlinePaymentArray.count > 0)
    {
        salesPriceOfflineSum =[offlinePaymentArray valueForKeyPath:@"@sum.BillAmount"];
        cahngeOfflineSum = [offlinePaymentArray valueForKeyPath:@"@sum.ReturnAmount"]; //ReturnAmount;
        salesPriceOfflineSum = @(salesPriceOfflineSum.floatValue - cahngeOfflineSum.floatValue);
        float amount = [[zOnlineMainDictionary valueForKey:@"TotalTender"] floatValue];
        amount = amount + salesPriceOfflineSum.floatValue;
        zOnlineMainDictionary[@"TotalTender"] = @(amount);
        
        float change = [[zOnlineMainDictionary valueForKey:@"TotalChange"] floatValue];
        change = change + cahngeOfflineSum.floatValue;
        zOnlineMainDictionary[@"TotalChange"] = @(change);
        
        float offlineAvgTicket = salesPriceOfflineSum.floatValue - cahngeOfflineSum.floatValue;
        NSInteger customerCount = [self getOfflineCustomerCount];
        
        offlineAvgTicket = offlineAvgTicket/customerCount;
        
        float avgTicket = [[zOnlineMainDictionary valueForKey:@"AvgTicket"] floatValue];
        avgTicket = avgTicket + offlineAvgTicket;
        zOnlineMainDictionary[@"AvgTicket"] = @(avgTicket);
    }
}

-(CGFloat )updateCollectedTaxWithofflineData:(NSMutableArray *)offlineTaxArray withOnlinePaymentDictionary:(NSMutableDictionary *)zOnlineMainDictionary
{
    NSNumber *taxOfflineSum = 0;
    CGFloat amount =0.0;
    
    if (offlineTaxArray.count > 0)
    {
        taxOfflineSum =[offlineTaxArray valueForKeyPath:@"@sum.ItemTaxAmount"];
    }
    amount = [[zOnlineMainDictionary valueForKey:@"CollectTax"] floatValue];
    amount = amount + taxOfflineSum.floatValue;
    zOnlineMainDictionary[@"CollectTax"] = [NSNumber numberWithFloat:amount];
    
    return taxOfflineSum.floatValue;
}

-(CGFloat)updateTotalSalesPriceWithofflineData:(NSMutableArray *)offlinePaymentArray withOnlinePaymentDictionary:(NSMutableDictionary *)zOnlineMainDictionary
{
    NSNumber *salesPriceOfflineSum = 0;
    NSNumber *cahngeOfflineSum = 0;
    
    if (offlinePaymentArray.count > 0)
    {
        salesPriceOfflineSum =[offlinePaymentArray valueForKeyPath:@"@sum.BillAmount"];
        cahngeOfflineSum = [offlinePaymentArray valueForKeyPath:@"@sum.ReturnAmount"]; //ReturnAmount;
        salesPriceOfflineSum = @(salesPriceOfflineSum.floatValue - cahngeOfflineSum.floatValue);
    }
    
    float amount = [[zOnlineMainDictionary valueForKey:@"TotalSales"] floatValue];
    amount = amount + salesPriceOfflineSum.floatValue;
    zOnlineMainDictionary[@"TotalSales"] = @(amount);

    return amount;
}

-(NSPredicate *)predicateForShiftUser
{
    NSPredicate *predicate;
    if ([openShiftUserId isEqualToNumber:currentUserId])
    {
        predicate= [NSPredicate predicateWithFormat:@"zId==%@ AND serverShiftId==%@ AND isUpload==%@",(self.rmsDbController.globalDict)[@"ZId"],serverShiftId,@(FALSE)];
    }
    else
    {
        predicate= [NSPredicate predicateWithFormat:@"zId==%@ AND serverShiftId==%@ AND isUpload==%@ AND userId = %@ ",(self.rmsDbController.globalDict)[@"ZId"],serverShiftId,@(FALSE),currentUserId];
    }
    return predicate;
}


-(NSMutableArray *)fetchItemFromInvoiceTable
{
    NSMutableArray *zOfflineArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate= [self predicateForShiftUser];
    fetchRequest.predicate = predicate;
    fetchRequest.predicate = predicate;
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(object.count>0)
    {
        for (InvoiceData_T *invoice in object)
        {
            if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject] count]>0)
            {
                NSMutableArray *archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoiceItemData] firstObject];
                for(int i=0;i<archiveArray.count;i++){
                    
                    [zOfflineArray addObject:archiveArray[i]];
                }
            }
        }
    }
    return zOfflineArray;
}

-(NSInteger)getOfflineCustomerCount
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate= [self predicateForShiftUser];
    fetchRequest.predicate = predicate;
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return object.count;
}

-(NSMutableArray *)fetchPaymentDataFromInvoiceTable
{
    NSMutableArray *zOfflineArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate= [self predicateForShiftUser];
    fetchRequest.predicate = predicate;

    
    fetchRequest.predicate = predicate;
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(object.count>0)
    {
        for (InvoiceData_T *invoice in object)
        {
            if ([[[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoicePaymentData] firstObject] count]>0)
            {
                NSMutableArray *archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithData:invoice.invoicePaymentData] firstObject];
                for(int i=0;i<archiveArray.count;i++){
                    
                    [zOfflineArray addObject:archiveArray[i]];
                }
            }
            
        }
    }
    return zOfflineArray;
}

-(BOOL)isShiftHasInvoiceInOffline
{
    BOOL isShiftHasInvoiceInOffline = FALSE;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate= [self predicateForShiftUser];
      fetchRequest.predicate = predicate;
    
    NSArray *object = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (object.count > 0)
    {
        isShiftHasInvoiceInOffline = TRUE;
    }
    return isShiftHasInvoiceInOffline;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
