//
//  ShiftInOutPopOverVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ShiftInOutPopOverVC.h"
#import "RmsDbController.h"
#import "RcrController.h"
#import "ShiftDetail+Dictionary.h"
#import "Configuration+Dictionary.h"
#import "XReport.h"
#import "ShiftReport.h"
#import "OflineShiftReportCalculation.h"
#import "PrintJobBase.h"
#import "DrawerStatus.h"

@interface ShiftInOutPopOverVC ()<UpdateDelegate,PrinterFunctionsDelegate>
{
    
    NSNumberFormatter *currencyFormat;
    NSArray *array_port;
    NSInteger selectedPort;
    NSString *zIdForOfflineCalculation;
    DrawerStatus *drawerStatus;
    BOOL needToCheckDrawerStatus;
}

@property (nonatomic, weak) IBOutlet UILabel *lblShiftInOutTitle;;
@property (nonatomic, weak) IBOutlet UIButton *btnShiftInOut;
@property (nonatomic, weak) IBOutlet UITextField *topinPrice;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *shiftWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *shiftEndWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *lastEmpoyeeShiftWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *noSaleInsertWebServiceConnection;
@property (nonatomic, strong) UpdateManager *updateShiftManager;

@property (nonatomic, strong) NSNumber  *tipSetting;
@property (nonatomic, strong) NSString *shiftInType;
@property (nonatomic, strong) NSString *lstUserId;
@property (nonatomic, strong) NSMutableArray *arrayShiftResponse;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation ShiftInOutPopOverVC
@synthesize strType,strZprint,strReportType;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [ShiftInOutPopOverVC setPortName:localPortName];
    [ShiftInOutPopOverVC setPortSettings:array_port[selectedPort]];
}
- (void)viewDidLoad
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateShiftManager = [[UpdateManager alloc]initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    if ([strType isEqualToString:@"SHIFT OPEN"])
    {
        self.shiftInType = @"CashIn";
    }
    else
    {
        self.shiftInType = @"CashOut";
    }
    [self cashInOutType:self.strType];

    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    self.shiftWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.shiftEndWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.lastEmpoyeeShiftWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.noSaleInsertWebServiceConnection = [[RapidWebServiceConnection alloc] init];

    self.tipSetting = [self checkTipsSetting];
    drawerStatus = [[DrawerStatus alloc] init];
    needToCheckDrawerStatus = [drawerStatus isDrawerConfigured];

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

-(void)cashInOutType :(NSString *)type
{
    if ([type isEqualToString:@"SHIFT OPEN"])
    {
        type = [NSString stringWithFormat:@"OPEN \n SHIFT"];
    }
    else
    {
        type = [NSString stringWithFormat:@"CLOSE \n SHIFT"];
    }
    _lblShiftInOutTitle.text = strType;
    [_btnShiftInOut setTitle:type forState:UIControlStateNormal];

}
- (IBAction) tenderNumPadButtonAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    currencyFormat = [[NSNumberFormatter alloc] init];
    currencyFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormat.maximumFractionDigits = 2;
    
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        if (_topinPrice.text==nil )
        {
            _topinPrice.text=@"";
        }
      
            _topinPrice.text = [_topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
            NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
            _topinPrice.text = displyValue;
	}
    else if ([sender tag] == -98)
    {
		if (_topinPrice.text.length > 0)
        {
            _topinPrice.text = [_topinPrice.text substringToIndex:_topinPrice.text.length-1];
		}
	}
    else if ([sender tag] == -99)
    {
		if (_topinPrice.text.length > 0)
        {
            _topinPrice.text = [_topinPrice.text substringToIndex:_topinPrice.text.length-1];
		}
	}

    else if ([sender tag] == 101)
    {
        _topinPrice.text = [_topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
      
        NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"00"];
        _topinPrice.text = displyValue;
	}
    
    if(_topinPrice.text.length > 0)
    {
        
            _topinPrice.text = [_topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            if ([_topinPrice.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length >= 2)
            {
                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                _topinPrice.text = [NSString stringWithFormat:@"%@.%@",[_topinPrice.text substringToIndex:_topinPrice.text.length-2],[_topinPrice.text substringFromIndex:_topinPrice.text.length-2]];
            }
            else if ([_topinPrice.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1)
            {
                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                _topinPrice.text = [NSString stringWithFormat:@"%@0.0%@",[_topinPrice.text substringToIndex:_topinPrice.text.length-2],[_topinPrice.text substringFromIndex:_topinPrice.text.length-2]];
            }
            else if ([_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1)
            {
                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                _topinPrice.text = [NSString stringWithFormat:@"0.0%@",_topinPrice.text];
            }
        
            NSNumber *dSales = @(_topinPrice.text.doubleValue);
            _topinPrice.text = [currencyFormat stringFromNumber:dSales];
            _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
}

-(IBAction)cleartxtField:(id)sender
{
    _topinPrice.text = @"";
}

-(IBAction)shiftIn_OutDismiss:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self.shiftInOutPopOverDelegate dismissShiftIn_OutController];
}

-(IBAction)shift_Process:(id)sender
{
    [self.rmsDbController playButtonSound];
    if ([_topinPrice.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue >=0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([strZprint isEqualToString:@"Z print"])
            {
                [self ShiftEndProcess];
            }
            else
            {
                [self shiftProcess];
            }
        });
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please fill the amount value. Before doing Cash In process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(void)shiftProcess
{
    NSMutableDictionary * param = [self getShiftInOutParaWithType:self.shiftInType];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doShiftInOutProcessResponse:response error:error];
        });
    };
    
    self.shiftWebServiceConnection = [self.shiftWebServiceConnection initWithRequest:KURL actionName:WSM_ADD_CASH_IN_OUT params:param completionHandler:completionHandler];
}

-(void)ShiftEndProcess
{
    NSMutableDictionary * param = [self getShiftInOutParaWithType:self.shiftInType];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self AllEmployeeShiftEndResponse:response error:error];
        });
    };
    
    self.shiftEndWebServiceConnection = [self.shiftEndWebServiceConnection initWithRequest:KURL actionName:WSM_ALL_EMPLOYEE_SHIFT_END params:param completionHandler:completionHandler];
}

- (void)AllEmployeeShiftEndResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"CashInOutFlg"] = [NSNumber numberWithBool:0];

                if ([strReportType isEqualToString:@"Z"])
                {
                    [self pushBackToReport];
                }
                else if ([strReportType isEqualToString:@"ZZ"])
                {
                    [self pushBackToReport];
                }
                self.lstUserId=[response valueForKey:@"Data"];
            }
        }
    }
    strZprint=nil;
}

- (NSMutableDictionary *) getShiftInOutParaWithType:(NSString *)type
{
    
	NSMutableDictionary * mainObject = [[NSMutableDictionary alloc] init];
	NSMutableArray * innerObjects = [[NSMutableArray alloc] init];
	NSMutableDictionary * cashInOutObject = [[NSMutableDictionary alloc] init];
    
	cashInOutObject[@"CashType"] = type;
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];

    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = sourceTimeZone;
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString* strDate = [formatter stringFromDate:destinationDate];
    [cashInOutObject setValue:strDate forKey:@"CreatedDate"];
    
    NSMutableArray *arrayNotes = [[NSMutableArray alloc]init];
    
  
    cashInOutObject[@"NotesDetail"] = arrayNotes;
	cashInOutObject[@"CashAmt"] = [_topinPrice.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
	cashInOutObject[@"ChequeAmt"] = @"0.00";
	cashInOutObject[@"TotalAmt"] = [_topinPrice.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    
	cashInOutObject[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
	cashInOutObject[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
	cashInOutObject[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    cashInOutObject[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    
	[innerObjects addObject:cashInOutObject];
	mainObject[@"CashInOutDetail"] = innerObjects;
    
    
	return mainObject;
}


-(void)insertShiftDetailWithServerShiftId:(NSNumber *)serverShiftId withDictionary:(NSMutableDictionary *)shiftDictionary
{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    shiftDictionary[@"ServerShiftId"] = serverShiftId;
    [self.updateShiftManager insertShiftDetailToLocalDatabase:shiftDictionary withContext:privateContextObject];
    Configuration *configuration = [self.updateShiftManager insertConfigurationMoc:privateContextObject];
    configuration.userId = @([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] integerValue]);
    configuration.serverShiftId = serverShiftId;
    [UpdateManager saveContext:privateContextObject];
}


- (void)doShiftInOutProcessResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSLog(@"Open-Shift Server Id %@",[response valueForKey:@"Data"]);
                
                if([self.shiftInType isEqualToString:@"CashIn"])
                {
                    [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"CashInOutFlg"] = [NSNumber numberWithBool:1];

                    NSNumber *shiftServerId = @([[response valueForKey:@"Data"] integerValue]) ;
                    [self insertShiftDetailWithServerShiftId:shiftServerId withDictionary:[[[self getShiftInOutParaWithType:@"CashIn"] valueForKey:@"CashInOutDetail"] firstObject]];
                    [self.shiftInOutPopOverDelegate shiftIn_OutSuccessfullyDone];
                }
                else if([self.shiftInType isEqualToString:@"CashOut"])
                {
                    [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"CashInOutFlg"] = [NSNumber numberWithBool:0];

                    [self.shiftInOutPopOverDelegate shiftIn_OutSuccessfullyDone];
                }
            }
            else
            {
                if([self.shiftInType isEqualToString:@"CashIn"])
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"You have already cash in." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else if([self.shiftInType isEqualToString:@"CashOut"])
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"You have already cash out." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else
                {
                    
                }
            }
        }
    }
}

-(void)LastEmpoyeeShiftWithZid :(NSString *)Zid
{
    if (_activityIndicator) {
        [_activityIndicator hideActivityIndicator];
    }
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
	dict[@"UserId"] = self.lstUserId;
    dict[@"ZId"] = Zid;
    zIdForOfflineCalculation = Zid;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self EmployeShiftReportResponse:response error:error];
    };
    
    self.lastEmpoyeeShiftWebServiceConnection = [self.lastEmpoyeeShiftWebServiceConnection initWithRequest:KURL actionName:@"EmployeeShiftReport28092016" params:dict completionHandler:completionHandler];
}

-(void)EmployeShiftReportResponse:(id)response error:(NSError *)error
{
    if ([strReportType isEqualToString:@"Z"])
    {
        if(![self.lstUserId isEqualToString:@""])
        {
            strZprint=@"";
        }
    }
    
    if (response != nil) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.arrayShiftResponse = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                OflineShiftReportCalculation *oflineShiftReportCalculation = [[OflineShiftReportCalculation alloc]initWithArray:self.arrayShiftResponse withZid:zIdForOfflineCalculation];
                [oflineShiftReportCalculation updateReportWithOfflineDetail];
                [self printShiftReport];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
}


-(void)NoSaleInsertShiftResponse:(id)response error:(NSError *)error
{
    
}

-(void)pushBackToReport
{
    [self.shiftInOutPopOverDelegate shiftIn_OutSuccessfullyDone];
}

- (void)printShiftReport
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    [self PrintReport:portName portSettings:portSettings SetShiftReportObject:self.arrayShiftResponse];
}

- (void)PrintReport:(NSString *)portName portSettings:(NSString *)portSettings SetShiftReportObject:(NSMutableArray *)ReportData
{
    if(ReportData.count>0)
    {
        ShiftReport *xReportPrint = [[ShiftReport alloc] initWithDictionary:ReportData.firstObject reportName:@"Shift Report" isTips:self.tipSetting.boolValue];
        [xReportPrint printReportWithPort:portName portSettings:portSettings withDelegate:self];
        [_activityIndicator hideActivityIndicator];
    }
}

- (void)hideActivity {
    [_activityIndicator hideActivityIndicator];;
}

- (void)showActivity {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
}

#pragma mark - Printer Function Delegate

-(void)actualDrawerStatus:(ActualDrawerStatus)actualDrawerStatus {
    [self hideActivity];
    if (actualDrawerStatus == ActualDrawerStatusOpen) {
        [self displayDrawerAlertWithTitle:@"Drawer Open" message:@"Please close the drawer and then tap on Continue button.If drawer is closed, then tap on Already closed button."];
    }
}

-(void)errorOccuredInGettingStatusWithTitle:(NSString *)title message:(NSString *)message {
    [self hideActivity];
    [self displayDrawerAlertWhileGettingErrorWithTitle:title message:message];
}

- (void)displayDrawerAlertWithTitle:(NSString *)title message:(NSString *)message {
    ShiftInOutPopOverVC * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [myWeakReference checkDrawerStatus:YES];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [myWeakReference checkDrawerStatus:NO];
    };
    
    [self.rmsDbController popupAlertFromVC:self title:title message:message buttonTitles:@[@"Already closed",@"Continue"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)displayDrawerAlertWhileGettingErrorWithTitle:(NSString *)title message:(NSString *)message {
    ShiftInOutPopOverVC * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [myWeakReference checkDrawerStatus:NO];
    };
    [self.rmsDbController popupAlertFromVC:self title:title message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
    if ([device isEqualToString:@"CashDrawer"]) {
        [self hideActivity];
        if (needToCheckDrawerStatus) {
            [self displayDrawerAlertWithTitle:@"Drawer Open" message:@"Please close the drawer and then tap on Continue button.If drawer is closed, then tap on Already closed button."];
        }
    }
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    if ([device isEqualToString:@"CashDrawer"]) {
        [self hideActivity];
        [self displayOpenCashDrawerRetryAlert:@"Failed to open Cash Drawer. Would you like to retry.?"];
    }
    else
    {
        [self.shiftInOutPopOverDelegate didFailToPrintShiftReport];
    }
}

-(void)displayOpenCashDrawerRetryAlert:(NSString *)message
{
    ShiftInOutPopOverVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference showActivity];
        [myWeakReference kickCashDrawer];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(NSDate*)jsonStringToNSDate :(NSString* ) string
{
    // Extract the numeric part of the date.  Dates should be in the format
    // "/Date(x)/", where x is a number.  This format is supplied automatically
    // by JSON serialisers in .NET.
    NSRange range = NSMakeRange(6, string.length - 8);
    NSString* substring = [string substringWithRange:range];

    // Have to use a number formatter to extract the value from the string into
    // a long long as the longLongValue method of the string doesn't seem to
    // return anything useful - it is always grossly incorrect.
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    NSNumber* milliseconds = [formatter numberFromString:substring];
    // NSTimeInterval is specified in seconds.  The value we get back from the
    // web service is specified in milliseconds.  Both values are since 1st Jan
    // 1970 (epoch).
    NSTimeInterval seconds = milliseconds.longLongValue / 1000;

    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

- (void)checkDrawerStatus:(BOOL)needToSwitchDrawerType {
    if (!drawerStatus) {
        drawerStatus = [[DrawerStatus alloc] init];
    }
    [drawerStatus checkDrawerStatusWithDelegate:self needToSwitchDrawerType:needToSwitchDrawerType];
}

//hiten
-(IBAction)OpenCloseDrawer:(id)sender
{
    [self.rmsDbController playButtonSound];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self showActivity];

        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        NSString *strDate = [formatter stringFromDate:date];
        
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
        [param setValue:(self.rmsDbController.globalDict)[@"ZId"] forKey:@"ZId"];
        param[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        param[@"Datetime"] = strDate;
        param[@"NoSaleType"] = _lblShiftInOutTitle.text;
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self NoSaleInsertShiftResponse:response error:error];
        };
        
        self.noSaleInsertWebServiceConnection = [self.noSaleInsertWebServiceConnection initWithRequest:KURL actionName:WSM_NO_SALE_INSERT params:param completionHandler:completionHandler];
        [self kickCashDrawer];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Do you want to Open drawer ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)kickCashDrawer
{
    [self SetPortInfo];
    NSString *portName     = [RcrController getPortName];
    NSString *portSettings = [RcrController getPortSettings];
    PrintJob *printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"CashDrawer" withDelegate:self];
    [printJob openCashDrawer];
    [printJob firePrint];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
