//
//  DropAmountVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 13/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DropAmountVC.h"
#import "RmsDbController.h"
#import "PrintJob.h"
#import "RasterPrintJob.h"
#import "PrintJobBase.h"
#import "RasterPrintJobBase.h"
#import "DrawerStatus.h"

@interface DropAmountVC ()<PrinterFunctionsDelegate>
{
    NSArray *array_port;
    NSNumberFormatter *currencyFormat;
    NSInteger selectedPort;
    PrintJob *printJob;
    DrawerStatus *drawerStatus;
    NSInteger columnWidths[6];
    NSInteger columnAlignments[6];
    NSString *receiptName;
    BOOL needToCheckDrawerStatus;
}

@property (nonatomic, weak) IBOutlet UITextField *topinPrice;
@property (nonatomic, weak) IBOutlet UILabel *lblDropAmountTitle;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RapidWebServiceConnection *dropAmountWC;
@property (nonatomic, strong) RapidWebServiceConnection *noSaleInsertForDropWC;

@end

@implementation DropAmountVC
@synthesize strPrintBarcode;

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.dropAmountWC = [[RapidWebServiceConnection alloc] init];
    self.noSaleInsertForDropWC = [[RapidWebServiceConnection alloc] init];

    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    drawerStatus = [[DrawerStatus alloc] init];
    needToCheckDrawerStatus = [drawerStatus isDrawerConfigured];

    // Do any additional setup after loading the view from its nib.
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

        NSNumber *dSales = @(_topinPrice.text.doubleValue );
        _topinPrice.text = [currencyFormat stringFromNumber:dSales];
        _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
}

-(IBAction)dropAmountDismiss:(id)sender
{
    [self.rmsDbController playButtonSound];
    if (self.isDrawerOpened) {
        receiptName = @" No Sale ";
        [self printReceipt];
    }
    else
    {
        [self.dropAmountDelegate dismissDropAmountViewController];
    }
}

- (void)printReceipt
{
    [self SetPortInfo];
    NSString *portName     = [RcrController getPortName];
    NSString *portSettings = [RcrController getPortSettings];
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    [self printDropAmountPrintReceipt:portSettings portName:portName isBlueToothPrinter:isBlueToothPrinter];
}

-(IBAction)dropAmountProcess:(id)sender
{
    [self.rmsDbController playButtonSound];
    if (_topinPrice.text.length >0)
    {

        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
        param[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        param[@"Amount"] = [_topinPrice.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        param[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
        param[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
        param[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];

        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *currentDateTime = [formatter stringFromDate:date];
        param[@"DropDate"] = currentDateTime;

        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doDropAmountProcessResponse:response error:error];
            });
        };
        self.dropAmountWC = [self.dropAmountWC initWithRequest:KURL actionName:WSM_DROP_AMOUNT_ADD params:param completionHandler:completionHandler];
    }
    else
    {
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please fill the amount value. Before doing Drop Amount process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

- (void)doDropAmountProcessResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];

    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                receiptName = @" Drop Amount ";
                [self printReceipt];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}
-(IBAction)cleatxtField:(id)sender
{
    _topinPrice.text = @"";
}

- (void)checkDrawerStatus:(BOOL)needToSwitchDrawerType {
    if (!drawerStatus) {
        drawerStatus = [[DrawerStatus alloc] init];
    }
    [drawerStatus checkDrawerStatusWithDelegate:self needToSwitchDrawerType:needToSwitchDrawerType];
}

-(IBAction)OpenCloseDrawer:(id)sender{

    [self.rmsDbController playButtonSound];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
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
        param[@"NoSaleType"] = _lblDropAmountTitle.text;
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self NoSaleInsertDropResponse:response error:error];
            });
        };

        self.noSaleInsertForDropWC = [self.noSaleInsertForDropWC initWithRequest:KURL actionName:WSM_NO_SALE_INSERT params:param completionHandler:completionHandler];

    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@" Do you want to Open drawer ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}



-(void)NoSaleInsertDropResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([response valueForKey:@"IsError"])
            {
                strPrintBarcode = [response valueForKey:@"Data"];
            }
        }
    }
    [self KickCashDrawerForDropAmount];
}

- (void)printDropAmountPrintReceipt:(NSString *)portSettings portName:(NSString *)portName isBlueToothPrinter:(BOOL)isBlueToothPrinter
{
    if (isBlueToothPrinter) {
        printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:self];
        [printJob enableSlashedZero:YES];
    }
    else
    {
        printJob = [[RasterPrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:self];
    }
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"PrintRecieptStatus"] isEqualToString:@"Yes"]) {
        [self printDropAmountReceipt];
        [self concludePrint];
    }
    else
    {
        [self.dropAmountDelegate dismissDropAmountViewController];
    }
}

-(void)KickCashDrawerForDropAmount
{
    [self SetPortInfo];
    NSString *portName     = [RcrController getPortName];
    NSString *portSettings = [RcrController getPortSettings];
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    [self printDropAmountPrintReceipt:portSettings portName:portName isBlueToothPrinter:isBlueToothPrinter];
    [self openCashDrawerWithPort:portName portSettings:portSettings];
    strPrintBarcode = @"";
}

- (void)concludePrint
{
    [printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [printJob firePrint];
    printJob = nil;
}

- (void)openCashDrawerWithPort:(NSString *)portName portSettings:(NSString *)portSettings
{
    PrintJob *_printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"CashDrawer" withDelegate:self];
    [_printJob openCashDrawer];
    [_printJob firePrint];
}

- (void)printDropAmountReceipt
{
    [self printStoreName];
    [self printAddressline1];
    [self printAddressline2];
    [self printReceiptName];
    [self printRegisterName];
    [self printCashierName];
    [self printDateAndTime];
    [self printDropAmount];
    [self printComment];
    [self printSignature];
    [self printBarCode];
}

-(void)printStoreName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob printLine:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
}

-(void)printAddressline1 {
    [printJob setTextAlignment:TA_CENTER];
    NSString *addressLine1 = [NSString stringWithFormat:@"%@  , %@", [[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]];
    [printJob printLine:addressLine1];
}

-(void)printAddressline2 {
    [printJob setTextAlignment:TA_CENTER];
    NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]];
    [printJob printLine:addressLine2];
    [printJob printLine:@""];
}

-(void)printReceiptName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob enableInvertColor:YES];
    [printJob printLine:receiptName];
    [printJob enableInvertColor:NO];
}

-(void)printRegisterName {
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:[NSString stringWithFormat:@"Register Name: %@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
}

-(void)printCashierName {
    [printJob setTextAlignment:TA_LEFT];
    NSString *salesPersonName = [NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserName"]];
    
    [printJob printLine:[NSString stringWithFormat:@"Cashier Name: %@",salesPersonName]];
}

-(void)printDateAndTime {
    NSDate * date = [NSDate date];
    //Create the dateformatter object
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    //Create the timeformatter object
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    
    //Get the string date
    NSString *printDate = [dateFormatter stringFromDate:date];
    NSString *printTime = [timeFormatter stringFromDate:date];
    [self defaultFormatForDateAndTime];
    [printJob printText1:[NSString stringWithFormat:@"Date: %@",printDate] text2:[NSString stringWithFormat:@"Time: %@",printTime]];
    [printJob printSeparator];
}

-(void)printDropAmount {
    if ([receiptName isEqualToString:@" Drop Amount "]) {
        [printJob setTextAlignment:TA_LEFT];
        [printJob printLine:[NSString stringWithFormat:@"Drop Amount: %@",_topinPrice.text]];
    }
}

-(void)printComment {
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:@"Comment: "];
    [printJob printLine:@""];
    [printJob printLine:@""];
    [printJob printLine:@""];
}

-(void)printSignature {
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:@"Signature  _____________________________ \r\n"];
    [printJob printLine:@""];
}

-(void)printBarCode {
    if (![receiptName isEqualToString:@" Drop Amount "]) {
        [printJob setTextAlignment:TA_CENTER];
        if (strPrintBarcode != nil && strPrintBarcode.length > 0) {
            [printJob printBarCode:strPrintBarcode];
            [printJob printLine:@""];
        }
    }
}

- (void)defaultFormatForDateAndTime
{
    columnWidths[0] = 24;
    columnWidths[1] = 23;
    columnAlignments[0] = DAAlignmentLeft;
    columnAlignments[1] = DAAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
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
    [DropAmountVC setPortName:localPortName];
    [DropAmountVC setPortSettings:array_port[selectedPort]];
}

#pragma mark - Printer Function Delegate

-(void)actualDrawerStatus:(ActualDrawerStatus)actualDrawerStatus {
    [_activityIndicator hideActivityIndicator];;
    if (actualDrawerStatus == ActualDrawerStatusOpen) {
        [self displayDrawerAlertWithTitle:@"Drawer Open" message:@"Please close the drawer and then tap on Continue button.If drawer is closed, then tap on Already closed button."];
    }
}

-(void)errorOccuredInGettingStatusWithTitle:(NSString *)title message:(NSString *)message {
    [_activityIndicator hideActivityIndicator];;
    [self displayDrawerAlertWhileGettingErrorWithTitle:title message:message];
}

- (void)displayDrawerAlertWithTitle:(NSString *)title message:(NSString *)message {
    DropAmountVC * __weak myWeakReference = self;
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
    DropAmountVC * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [myWeakReference checkDrawerStatus:NO];
    };
    [self.rmsDbController popupAlertFromVC:self title:title message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
    if ([device isEqualToString:@"CashDrawer"]) {
        [_activityIndicator hideActivityIndicator];;
        if (needToCheckDrawerStatus) {
            [self displayDrawerAlertWithTitle:@"Drawer Open" message:@"Please close the drawer and then tap on Continue button.If drawer is closed, then tap on Already closed button."];
        }
    }
    else
    {
        if ([receiptName isEqualToString:@" Drop Amount "]) {
            [self.dropAmountDelegate dropAmountProcessSuccessfullyDone];
        }
        else if (self.isDrawerOpened) {
            [self.dropAmountDelegate dismissDropAmountViewController];
        }
    }
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp {
    if ([device isEqualToString:@"CashDrawer"]) {
        [_activityIndicator hideActivityIndicator];;
        [self displayOpenCashDrawerRetryAlert:@"Failed to open Cash Drawer. Would you like to retry.?"];
    }
    else
    {
        [self displayDropAmountPrintRetryAlert:@"Failed to Drop Amount print receipt. Would you like to retry.?"];
    }
}

-(void)displayOpenCashDrawerRetryAlert:(NSString *)message
{
    DropAmountVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [self SetPortInfo];
        NSString *portName     = [RcrController getPortName];
        NSString *portSettings = [RcrController getPortSettings];
        [myWeakReference openCashDrawerWithPort:portName portSettings:portSettings];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)displayDropAmountPrintRetryAlert:(NSString *)message
{
    DropAmountVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        if ([receiptName isEqualToString:@" Drop Amount "]) {
            [myWeakReference printReceipt];
        }
        else if (self.isDrawerOpened) {
            [myWeakReference dropAmountDismiss:nil];
        }
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        if ([receiptName isEqualToString:@" Drop Amount "]) {
            [myWeakReference.dropAmountDelegate dropAmountProcessSuccessfullyDone];
        }
        else
        {
            [myWeakReference.dropAmountDelegate dismissDropAmountViewController];
        }
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
