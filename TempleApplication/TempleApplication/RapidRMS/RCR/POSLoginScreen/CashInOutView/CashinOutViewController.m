//
//  CashinOutViewController.m
//  POSRetail
//
//  Created by Nirav Patel on 08/11/12.
//  Copyright (c) 2012 Nirav Patel. All rights reserved.
//

#import "CashinOutViewController.h"
#import "PopOverController.h"
#import "PrinterFunctions.h"
#import "RmsDbController.h"
#import "RcrController.h"
#import "RcrPosVC.h"
#define NName @"POSCashInOut"

@interface CashinOutViewController ()
{
    UITextField *currentTextField;
    NSArray *array_port;
    NSInteger selectedPort;
    UIPopoverPresentationController * cashInOutPopOver;
    BOOL isCashInOut;
    
    PopOverController * popoverController;
}
@property (nonatomic, weak) IBOutlet UIView *uvUserLogo;
@property (nonatomic, weak) IBOutlet UIView *cashView;
@property (nonatomic, weak) IBOutlet UIView *checkView;
@property (nonatomic, weak) IBOutlet UIView *payoutView;
@property (nonatomic, weak) IBOutlet UIView *subTotalView;
@property (nonatomic, weak) IBOutlet UIView *sideSubMenuview;
@property (nonatomic, weak) IBOutlet UILabel *lblCurrentDate;
@property (nonatomic, weak) IBOutlet UILabel *lblCashInDate;
@property (nonatomic, weak) IBOutlet UILabel *lblCashOutDate;

@property (nonatomic, weak) IBOutlet UITextField * txtCash;
@property (nonatomic, weak) IBOutlet UITextField * txtCheque;
@property (nonatomic, weak) IBOutlet UITextField * txt100Note;
@property (nonatomic, weak) IBOutlet UITextField * txt50Note;
@property (nonatomic, weak) IBOutlet UITextField * txt20Note;
@property (nonatomic, weak) IBOutlet UITextField * txt10Note;
@property (nonatomic, weak) IBOutlet UITextField * txt5Note;
@property (nonatomic, weak) IBOutlet UITextField * txt2Note;
@property (nonatomic, weak) IBOutlet UITextField * txt1Note;
@property (nonatomic, weak) IBOutlet UITextField * txt0_25Note;
@property (nonatomic, weak) IBOutlet UITextField * txt0_10Note;
@property (nonatomic, weak) IBOutlet UITextField * txt0_05Note;
@property (nonatomic, weak) IBOutlet UITextField * txt0_01Note;
@property (nonatomic, weak) IBOutlet UITextField * txtPayOut;

@property (nonatomic, weak) IBOutlet UILabel * lblSubTotal;
@property (nonatomic, weak) IBOutlet UILabel * lblTotal;
@property (nonatomic, weak) IBOutlet UILabel * lblCurrencySymbol;
@property (nonatomic, weak) IBOutlet UILabel * lblHundred;
@property (nonatomic, weak) IBOutlet UILabel * lblFifty;
@property (nonatomic, weak) IBOutlet UILabel * lblTwenty;
@property (nonatomic, weak) IBOutlet UILabel * lblTen;
@property (nonatomic, weak) IBOutlet UILabel * lblFive;
@property (nonatomic, weak) IBOutlet UILabel * lblTwo;
@property (nonatomic, weak) IBOutlet UILabel * lblOne;
@property (nonatomic, weak) IBOutlet UILabel * lblPointTwentyFive;
@property (nonatomic, weak) IBOutlet UILabel * lblPointTen;
@property (nonatomic, weak) IBOutlet UILabel * lblPointZeroFive;
@property (nonatomic, weak) IBOutlet UILabel * lblPointZeroOne;
@property (nonatomic, weak) IBOutlet UIButton * btnCashIn;
@property (nonatomic, weak) IBOutlet UIButton * btnCashOut;
@property (nonatomic, weak) IBOutlet UIButton * btnCashExit;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) POSLoginView *posLogin;
@property (nonatomic, strong) RapidWebServiceConnection *allEmployeeShiftEndWC;
@property (nonatomic, strong) RapidWebServiceConnection *doneCashInWC;
@property (nonatomic, strong) RapidWebServiceConnection *employeeShiftReportWC;
@property (nonatomic, strong) RapidWebServiceConnection *employeeShiftReportWC2;

@property (nonatomic, strong) NSString *typeValue;
@property (nonatomic, strong) NSString *lstUserId;
@property (nonatomic, strong) NSString *strZprint;
@property (nonatomic, strong) NSMutableArray *arrayShiftResponse;

@end

@implementation CashinOutViewController


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
    NSString *localPortName = @"BT:Star Micronics";
    [CashinOutViewController setPortName:localPortName];
    [CashinOutViewController setPortSettings:array_port[selectedPort]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.uvUserLogo.layer.cornerRadius = 96.0;
    self.allEmployeeShiftEndWC = [[RapidWebServiceConnection alloc] init];
    self.doneCashInWC = [[RapidWebServiceConnection alloc] init];
    self.employeeShiftReportWC = [[RapidWebServiceConnection alloc] init];
    self.employeeShiftReportWC2 = [[RapidWebServiceConnection alloc] init];
    [self setViewBorder];
    isCashInOut = FALSE;
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    self.arrayShiftResponse=[[NSMutableArray alloc]init];

    if ([_strZprint isEqualToString:@"Z print"])
    {
        [self cashinoutButtonDisable];
    }
    else
    {
        [self setCashInDisplay];

    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewPrice:) name:NName object:nil];
    
    [self setCurrencyFormatterToLabel];
    // Do any additional setup after loading the view from its nib.
}

- (void)setCurrencyFormatterToLabel
{
    _lblCurrencySymbol.text = self.rmsDbController.currencyFormatter.currencySymbol;
    _lblHundred.text = [self.rmsDbController applyCurrencyFomatter:@"100"];
    _lblFifty.text = [self.rmsDbController applyCurrencyFomatter:@"50"];
    _lblTwenty.text = [self.rmsDbController applyCurrencyFomatter:@"20"];
    _lblTen.text = [self.rmsDbController applyCurrencyFomatter:@"10"];
    _lblFive.text = [self.rmsDbController applyCurrencyFomatter:@"5"];
    _lblTwo.text = [self.rmsDbController applyCurrencyFomatter:@"2"];
    _lblOne.text = [self.rmsDbController applyCurrencyFomatter:@"1"];
    _lblPointTwentyFive.text = [self.rmsDbController applyCurrencyFomatter:@"0.25"];
    _lblPointTen.text = [self.rmsDbController applyCurrencyFomatter:@"0.10"];
    _lblPointZeroFive.text = [self.rmsDbController applyCurrencyFomatter:@"0.05"];
    _lblPointZeroOne.text = [self.rmsDbController applyCurrencyFomatter:@"0.01"];
    _lblSubTotal.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
    _lblTotal.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
}

-(void)setCashInDisplay
{
    if ( [[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"CashInOutFlg"] boolValue] == TRUE)
    {
        _btnCashIn.enabled = NO;
        _btnCashOut.enabled = YES;
        [_btnCashOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnCashIn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else
    {
        _btnCashIn.enabled = YES;
        _btnCashOut.enabled = NO;
        [_btnCashOut setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnCashIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}



-(void)setViewBorder

{
    _cashView.layer.borderColor=[UIColor colorWithRed:207.0/255.0 green:207.0/255.0  blue:207.0/255.0  alpha:1.0].CGColor ;
    _cashView.layer.borderWidth=0.8;
    
    _checkView.layer.borderColor=[UIColor colorWithRed:207.0/255.0 green:207.0/255.0  blue:207.0/255.0  alpha:1.0].CGColor ;
    _checkView.layer.borderWidth=0.8;
    
    _payoutView.layer.borderColor=[UIColor colorWithRed:207.0/255.0 green:207.0/255.0  blue:207.0/255.0  alpha:1.0].CGColor ;
    _payoutView.layer.borderWidth=0.8;
    
    _subTotalView.layer.borderColor=[UIColor colorWithRed:207.0/255.0 green:207.0/255.0  blue:207.0/255.0  alpha:1.0].CGColor ;
    _subTotalView.layer.borderWidth=0.5;
    
//    sideSubMenuview.layer.borderColor=[[UIColor colorWithRed:178.0/255.0 green:178.0/255.0  blue:178.0/255.0  alpha:1.0] CGColor] ;
//    sideSubMenuview.layer.borderWidth=0.8;
    
}
- (void) viewWillAppear:(BOOL)animated
{
    if ([_strZprint isEqualToString:@""])
    {
        
    }
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    _lblCurrentDate.text = [formatter stringFromDate:date];
    [super viewWillAppear:animated];
    [self resetCashInOutView];
    [self setViewBorder];
    self.typeValue=@"";
	[super viewWillAppear:YES];
}

-(void)cashinoutButtonEnable
{
    _btnCashIn.hidden=NO;
    _btnCashExit.hidden=NO;
    _btnCashExit.enabled=YES;
    _btnCashIn.enabled=YES;
    
}
- (void)resetCashInOutView {
	_txtCash.text = @""; _txtCheque.text = @""; _txt100Note.text = @""; _txt50Note.text = @""; _txt20Note.text = @""; _txt10Note.text = @"";
	_txt5Note.text = @""; _txt2Note.text = @""; _txt1Note.text = @""; _txt0_25Note.text = @""; _txt0_10Note.text = @""; _txt0_05Note.text = @"";
	_txt0_01Note.text = @""; _lblTotal.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
    _lblSubTotal.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
}
#pragma mark -
#pragma mark TextFiled Delegate method

//call when press return key in keyboard.
- (BOOL) textFieldShouldReturn:(UITextField *)textFiled
{
	[textFiled resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark TextFiled Delegate method

//call when press keyboard down key in keyboard.
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[textField resignFirstResponder];
}

//call when start editing the textfield.
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	   currentTextField = textField;

		[textField resignFirstResponder];
        cashInOutPopOver = nil;
		if (cashInOutPopOver == nil) {
			popoverController = [[PopOverController alloc] initWithNibName:@"PopOverController" bundle:nil];
			popoverController.notificationName = NName;
			popoverController.isFrom = NName;
			if ([textField isEqual:_txtCash] || [textField isEqual:_txtCheque] || [textField isEqual:_txtPayOut]) {
				popoverController.isPrice = YES;
			} else {
				popoverController.isPrice = NO;
			}
			popoverController.topingListAry = nil;
            
            
            // Present the view controller using the popover style.
            popoverController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:popoverController animated:YES completion:nil];
            
            // Get the popover presentation controller and configure it.
            cashInOutPopOver = [popoverController popoverPresentationController];
            cashInOutPopOver.delegate = self;
            popoverController.preferredContentSize = CGSizeMake(335, 596);
            if (![textField isEqual:_txtCash] && ![textField isEqual:_txtCheque] && ![textField isEqual:_txtPayOut]) {
                cashInOutPopOver.permittedArrowDirections = UIPopoverArrowDirectionLeft;
            } else {
                cashInOutPopOver.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            cashInOutPopOver.sourceView = textField.superview;
            cashInOutPopOver.sourceRect = textField.frame;
		}
}
- (void) addNewPrice:(NSNotification *) notification {
	if (notification.object == nil) {
		[popoverController dismissViewControllerAnimated:YES completion:nil];
		cashInOutPopOver = nil;
	} else {
		if ([currentTextField isEqual:_txtCash] || [currentTextField isEqual:_txtCheque]) {
			currentTextField.text = notification.object;
		} else {
			currentTextField.text = notification.object;
		}
		[self CalculateSubTotal];
        [popoverController dismissViewControllerAnimated:YES completion:nil];
        cashInOutPopOver = nil;
	}
}

- (void) CalculateSubTotal
{
    
	float subTotalValue = 0.00f;
	subTotalValue += _txt100Note.text.floatValue*100;
	subTotalValue += _txt50Note.text.floatValue*50;
	subTotalValue += _txt20Note.text.floatValue*20;
	subTotalValue += _txt10Note.text.floatValue*10;
	subTotalValue += _txt5Note.text.floatValue*5;
	subTotalValue += _txt2Note.text.floatValue*2;
	subTotalValue += _txt1Note.text.floatValue*1;
	subTotalValue += _txt0_25Note.text.floatValue*.25;
	subTotalValue += _txt0_10Note.text.floatValue*.10;
	subTotalValue += _txt0_05Note.text.floatValue*.5;
	subTotalValue += _txt0_01Note.text.floatValue*.1;
    
    _lblSubTotal.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",subTotalValue]];
	[self CalculateTotal];
}

- (void) CalculateTotal
{
	float totalValue = 0.00f;
	totalValue += [_lblSubTotal.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue;
	totalValue += [_txtCash.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue;
	totalValue += [_txtCheque.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue;
    _lblTotal.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",totalValue]];
}


#pragma mark -
#pragma mark Cash In Out Action.

- (IBAction)cashInOutActionHandler:(id)sender
{
    self.typeValue = @"";
    BOOL isAlradyCashIn = FALSE;
    switch ([sender tag]) {
        case 701:
            self.typeValue = @"CashIn";
            break;
        case 702:
            self.typeValue = @"CashOut";
            if (![_strZprint isEqualToString:@"Z print"])
            {
            }
            break;
        case 703:
            isAlradyCashIn = TRUE;
            break;
        default:
            break;
    }
    if (isAlradyCashIn)
    {
        [self hideCashInoutView];
    } else
    {
        if ([_lblTotal.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue > 0)
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            NSMutableDictionary * param = [self getCashInOutParaWithType:self.typeValue];
            if ([_strZprint isEqualToString:@"Z print"])
            {
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    [self AllEmployeeShiftEndResponse:response error:error];
                };
                
                self.allEmployeeShiftEndWC = [self.allEmployeeShiftEndWC initWithRequest:KURL actionName:WSM_ALL_EMPLOYEE_SHIFT_END params:param completionHandler:completionHandler];
            }
            else
            {
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    [self doCashInOutProcessResponse:response error:error];
                };
                
                self.doneCashInWC = [self.doneCashInWC initWithRequest:KURL actionName:WSM_ADD_CASH_IN_OUT params:param completionHandler:completionHandler];
            }
        } else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please fill the amount value. Before doing Cash In process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    }
}
- (NSMutableDictionary *) getCashInOutParaWithType:(NSString *)type {
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
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    dateFormat.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSTimeZone* sourceTime = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    dateFormat.timeZone = sourceTime;
    NSString *strDate=[dateFormat stringFromDate:destinationDate];
    cashInOutObject[@"CreatedDate"] = strDate;
    
    NSMutableArray *arrayNotes = [[NSMutableArray alloc]init];
    
    if(_txt100Note.text.length>0){
        NSMutableDictionary *dictTemp100 = [[NSMutableDictionary alloc]init];
        dictTemp100[@"NotesType"] = @"100";
        dictTemp100[@"NotesCount"] = [self getValue:_txt100Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp100];
//        [dictTemp100 release];
    }
    
    if(_txt50Note.text.length>0){
        NSMutableDictionary *dictTemp50 = [[NSMutableDictionary alloc]init];
        dictTemp50[@"NotesType"] = @"50";
        dictTemp50[@"NotesCount"] = [self getValue:_txt50Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp50];
//        [dictTemp50 release];
    }
    
    if(_txt20Note.text.length>0){
        NSMutableDictionary *dictTemp20 = [[NSMutableDictionary alloc]init];
        dictTemp20[@"NotesType"] = @"20";
        dictTemp20[@"NotesCount"] = [self getValue:_txt20Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp20];
//        [dictTemp20 release];
    }
    
    if(_txt10Note.text.length>0){
        NSMutableDictionary *dictTemp10 = [[NSMutableDictionary alloc]init];
        dictTemp10[@"NotesType"] = @"10";
        dictTemp10[@"NotesCount"] = [self getValue:_txt10Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp10];
//        [dictTemp10 release];
    }
    
    if(_txt5Note.text.length>0){
        NSMutableDictionary *dictTemp5 = [[NSMutableDictionary alloc]init];
        dictTemp5[@"NotesType"] = @"5";
        dictTemp5[@"NotesCount"] = [self getValue:_txt5Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp5];
//        [dictTemp5 release];
    }
    
    if(_txt2Note.text.length>0){
        NSMutableDictionary *dictTemp2 = [[NSMutableDictionary alloc]init];
        dictTemp2[@"NotesType"] = @"2";
        dictTemp2[@"NotesCount"] = [self getValue:_txt2Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp2];
//        [dictTemp2 release];
    }
    
    if(_txt1Note.text.length>0){
        NSMutableDictionary *dictTemp1 = [[NSMutableDictionary alloc]init];
        dictTemp1[@"NotesType"] = @"1";
        dictTemp1[@"NotesCount"] = [self getValue:_txt1Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp1];
//        [dictTemp1 release];
    }
    
    if(_txt0_25Note.text.length>0){
        NSMutableDictionary *dictTemp025 = [[NSMutableDictionary alloc]init];
        dictTemp025[@"NotesType"] = @"0.25";
        dictTemp025[@"NotesCount"] = [self getValue:_txt0_25Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp025];
//        [dictTemp025 release];
    }
    
    if(_txt0_10Note.text.length>0){
        NSMutableDictionary *dictTemp010 = [[NSMutableDictionary alloc]init];
        dictTemp010[@"NotesType"] = @"0.10";
        dictTemp010[@"NotesCount"] = [self getValue:_txt0_10Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp010];
//        [dictTemp010 release];
    }
    
    if(_txt0_05Note.text.length>0){
        NSMutableDictionary *dictTemp05 = [[NSMutableDictionary alloc]init];
        dictTemp05[@"NotesType"] = @"0.5";
        dictTemp05[@"NotesCount"] = [self getValue:_txt0_05Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp05];
//        [dictTemp05 release];
    }
    
    if(_txt0_01Note.text.length>0){
        NSMutableDictionary *dictTemp01 = [[NSMutableDictionary alloc]init];
        dictTemp01[@"NotesType"] = @"0.1";
        dictTemp01[@"NotesCount"] = [self getValue:_txt0_01Note.text withDecimal:NO];
        [arrayNotes addObject:dictTemp01];
//        [dictTemp01 release];
    }
    
    cashInOutObject[@"NotesDetail"] = arrayNotes;
	cashInOutObject[@"CashAmt"] = [self getValue:[_txtCash.text stringByReplacingOccurrencesOfString:@"$" withString:@""] withDecimal:YES];
	cashInOutObject[@"ChequeAmt"] = [self getValue:[_txtCheque.text stringByReplacingOccurrencesOfString:@"$" withString:@""] withDecimal:YES];
	cashInOutObject[@"TotalAmt"] = [self getValue:[_lblTotal.text stringByReplacingOccurrencesOfString:@"$" withString:@""] withDecimal:YES];
    
	cashInOutObject[@"RegisterId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
	cashInOutObject[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
	cashInOutObject[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    cashInOutObject[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    
	[innerObjects addObject:cashInOutObject];
//	[cashInOutObject release];
	mainObject[@"CashInOutDetail"] = innerObjects;
    
//	[innerObjects release];
    
	return mainObject;
}

- (NSString *) getValue:(NSString *)text withDecimal:(BOOL)isTrue {
	if (text.floatValue > 0) {
		return text;
	} else {
		if(isTrue) {
			return @"0.0";
		} else {
			return @"0";
		}
	}
}
- (void)AllEmployeeShiftEndResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    _strZprint=@"";
                    [self pushBackToReport];
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [self LastEmpoyeeShift];
                    _strZprint=@"";
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Shift Closed successfully,Do you want to print your shift Report?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                self.lstUserId=[response valueForKey:@"Data"];
            }
        }
    }
    _strZprint=nil;
}

- (void)doCashInOutProcessResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                if([self.typeValue isEqualToString:@"CashIn"])
                {
                    [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"CashInRequire"] = [NSNumber numberWithBool:0];
                    isCashInOut = TRUE;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Shift Start successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    [self hideCashInoutView];
                }
                else if([self.typeValue isEqualToString:@"CashOut"])
                {
                    [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"CashInRequire"] = [NSNumber numberWithBool:1];
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        [self hideCashInoutView];
                    };
                    
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        [self GetEmployeShiftReport];
                        [self hideCashInoutView];
                    };
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Shift Closed successfully,Do you want to print your shift Report?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                }
                self.posLogin.displayText.text = @"";
            }
            else
            {
                if([self.typeValue isEqualToString:@"CashIn"])
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"You have already cash in." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    
                }
                else if([self.typeValue isEqualToString:@"CashOut"])
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
    [self setCashInDisplay];
    self.typeValue=@"";
}

-(void)pushBackToReport
{
    [self.navigationController popViewControllerAnimated:TRUE];
}
-(void)LastEmpoyeeShift
{
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
	dict[@"UserId"] = self.lstUserId;
    dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self EmployeShiftReportResponse:response error:error];
    };
    
    self.employeeShiftReportWC = [self.employeeShiftReportWC initWithRequest:KURL actionName:WSM_EMPLOYEE_SHIFT_REPORT params:dict completionHandler:completionHandler];
}

-(void)GetEmployeShiftReport
{
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
	dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self EmployeShiftReportResponse:response error:error];
    };
    
    self.employeeShiftReportWC2 = [self.employeeShiftReportWC2 initWithRequest:KURL actionName:WSM_EMPLOYEE_SHIFT_REPORT params:dict completionHandler:completionHandler];
    self.lstUserId=@"";
}

-(void)EmployeShiftReportResponse:(id)response error:(NSError *)error
{
    if(![self.lstUserId isEqualToString:@""])
    {
        _strZprint=@"";
        [self pushBackToReport];
    }
    
    self.lstUserId=@"";
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                self.arrayShiftResponse = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSString *portName     = @"";
                NSString *portSettings = @"";
                
                [self SetPortInfo];
                portName     = [RcrController getPortName];
                portSettings = [RcrController getPortSettings];
                [self PrintReport:portName portSettings:portSettings SetShiftReportObject:self.arrayShiftResponse];
            }
        }
    }
}

- (void) cashOutActionHandler
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Cash out First." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (void) hideCashInoutView
{
    if ([ self.rmsDbController.selectedModule isEqualToString:@"RCR"])
    {
        // hiten
        
        
        NSArray *viewControllerArray = self.navigationController.viewControllers;
        for (UIViewController *viewController in viewControllerArray)
        {
            if ([viewController isKindOfClass:[RcrPosVC class]])
            {
                [self.navigationController popToViewController:viewController animated:TRUE];
                return;
            }
        }
        //
        
        POSLoginView * loginView = [[POSLoginView alloc] initWithNibName:@"POSLoginView" bundle:nil];
        [self.navigationController pushViewController:loginView animated:YES];
    }
    else
    {
        NSArray *viewControllerArray = self.navigationController.viewControllers;
        for (UIViewController *viewController in viewControllerArray)
        {
            if ([viewController isKindOfClass:[DashBoardSettingVC class]])
            {
                [self.navigationController popToViewController:viewController animated:TRUE];
            }
        }
    }
    
    
    
	/*CATransition * animation = [CATransition animation];
	animation.duration = 0.2f;
	animation.type = kCATransitionFade;
	animation.subtype = kCATransitionFromLeft;
	[btnCashOut setEnabled:YES];
	[btnCashIn setEnabled:YES];
	posLogin.cashInOutView.view.hidden = YES;
    txtCash.text=@"";
    UIView *view1=[self.view viewWithTag:1986];
    [view1 removeFromSuperview];
    view1.hidden=YES;
  	[posLogin.cashInOutView.view.layer addAnimation:animation forKey:nil];
    [posLogin setCashInLoginDetail];*/
}
-(void)cashinoutButtonDisable
{
    _btnCashExit.hidden=YES;
    _btnCashExit.enabled=NO;
    _btnCashIn.enabled=NO;
    _btnCashIn.hidden=YES;
}

#pragma mark -
#pragma mark PopOverPresentationController Delegate.

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController;
{
    return YES;
}


- (void)PrintReport:(NSString *)portName portSettings:(NSString *)portSettings SetShiftReportObject:(NSMutableArray *)ReportData
{
    if(ReportData.count>0)
    {
        NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        currencyFormatter.maximumFractionDigits = 2;
        NSInteger ispace = 0;
        NSString *space=@" ";
        NSString *rptfieldName=@"";
        NSUInteger fldlength=0;
        NSUInteger totlength=44;
        
        NSMutableData *commands = [[NSMutableData alloc] init];
        
        [commands appendBytes:"\x1b\x1d\x61\x01"
                       length:sizeof("\x1b\x1d\x61\x01") - 1];    // center
        
        [commands appendData:[[NSString stringWithFormat:@"%@\r\n",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]] dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendData:[[NSString stringWithFormat:@"%@ , %@\r\n%@, %@ - %@\r\n\r\n",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]] dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendBytes:"\x1b\x1d\x61\x01"
                       length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
        
        [commands appendData:[@"\x1b\x34 Shift Report \x1b\x35\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x1b\x1d\x61\x00"
                       length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
        
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
        NSMutableArray *MainReport= [ReportData valueForKey:@"RptMain"];
        NSMutableDictionary *MainRptDisc=[MainReport.firstObject firstObject];
        rptfieldName=printDate;
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-13;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        
        rptfieldName = [space stringByAppendingString:[NSString stringWithFormat:@"%@",rptfieldName]];
        
        [commands appendData:[[NSString stringWithFormat:@"Report Date :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        rptfieldName=printTime;
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-13;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        
        rptfieldName = [space stringByAppendingString:[NSString stringWithFormat:@"%@",rptfieldName]];
        
        [commands appendData:[[NSString stringWithFormat:@"Report Time :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        rptfieldName=[MainRptDisc valueForKey:@"BatchNo"];
        fldlength=[NSString stringWithFormat:@"%@",rptfieldName].length;
        ispace=totlength-fldlength-10;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        
        rptfieldName = [space stringByAppendingString:[NSString stringWithFormat:@"%@",rptfieldName]];
        
        [commands appendData:[[NSString stringWithFormat:@"Batch No :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        rptfieldName=[MainRptDisc valueForKey:@"RegisterName"];
        if ([rptfieldName isEqual:[NSNull null]])
        {
            rptfieldName=@"";
        }
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-15;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Register Name :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        rptfieldName=[MainRptDisc valueForKey:@"Startdate"];
        if ([rptfieldName isEqual:[NSNull null]])
        {
            rptfieldName=@"";
        }
        
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-12;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        [commands appendData:[[NSString stringWithFormat:@"Start Date :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        rptfieldName=[MainRptDisc valueForKey:@"StartTime"];
        if ([rptfieldName isEqual:[NSNull null]])
        {
            rptfieldName=@"";
        }
        
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-12;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        [commands appendData:[[NSString stringWithFormat:@"Start Time :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        rptfieldName=[MainRptDisc valueForKey:@"CurrentUser"];
        if ([rptfieldName isEqual:[NSNull null]])
        {
            rptfieldName=@"";
        }
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-14;
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Current User :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        rptfieldName=[NSString stringWithFormat:@"$ %@",[MainRptDisc valueForKey:@"TotalSales"]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-13;
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Total Sales :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"CollectTax"]]];
        
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-7;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Taxes :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        NSNumber *netSales=@([[MainRptDisc valueForKey:@"TotalSales"]doubleValue]-
                            [[MainRptDisc valueForKey:@"CollectTax"] doubleValue]);
        
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:netSales]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-11;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        [commands appendData:[[NSString stringWithFormat:@"Net Sales :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        // space add
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"OpeningAmount"]]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-16;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Opening Amount :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"Sales"]]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-7;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        [commands appendData:[[NSString stringWithFormat:@"Sales :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"Return"]]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-9;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        [commands appendData:[[NSString stringWithFormat:@"Returns :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"Surcharge"]]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-18;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        [commands appendData:[[NSString stringWithFormat:@"Surcharge Amount :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        double doubleTotal1=[[MainRptDisc valueForKey:@"OpeningAmount"]doubleValue]+[[MainRptDisc valueForKey:@"Fee"]doubleValue]+
        [[MainRptDisc valueForKey:@"CheckCashFee"] doubleValue]+[[MainRptDisc valueForKey:@"Sales"]doubleValue]+[[MainRptDisc valueForKey:@"Return"]doubleValue]+[[MainRptDisc valueForKey:@"Surcharge"]doubleValue];
        NSNumber *Total1=@(doubleTotal1);
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:Total1]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-8;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        
        [commands appendData:[[NSString stringWithFormat:@"Total : %@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"PayOut"]]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-10;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Paid Out :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"ClosingAmount"]]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-16;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Closing Amount :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        double doubleTotal2=[[MainRptDisc valueForKey:@"PayOut"]doubleValue]+
        [[MainRptDisc valueForKey:@"ClosingAmount"] doubleValue];
        NSNumber *Total2=@(doubleTotal2);
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:Total2]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-8;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Total : %@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        NSNumber *OverShort=@(doubleTotal2-doubleTotal1);
        
        rptfieldName=[NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:OverShort]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-14;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        [commands appendData:[[NSString stringWithFormat:@"Over / Short :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];

        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"Discount"]]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-10;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Discount :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"CheckCashAmount"]]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-19;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Check Cash Amount :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"TotalTender"]]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-14;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        [commands appendData:[[NSString stringWithFormat:@"Total Tender :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        rptfieldName=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[MainRptDisc valueForKey:@"TotalChange"]]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-14;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:rptfieldName];
        
        [commands appendData:[[NSString stringWithFormat:@"Total Change :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];

        rptfieldName=[NSString stringWithFormat:@"%@",[MainRptDisc valueForKey:@"NoSales"]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-15;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:[NSString stringWithFormat:@"%@",rptfieldName]];
        
        [commands appendData:[[NSString stringWithFormat:@"NoSales Count :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        rptfieldName=[NSString stringWithFormat:@"%@",[MainRptDisc valueForKey:@"CustomerCount"]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-16;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:[NSString stringWithFormat:@"%@",rptfieldName]];
        
        [commands appendData:[[NSString stringWithFormat:@"Customer Count :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        rptfieldName=[NSString stringWithFormat:@"%@",[MainRptDisc valueForKey:@"AbortedTrans"]];
        fldlength=rptfieldName.length;
        ispace=totlength-fldlength-14;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:[NSString stringWithFormat:@"%@",rptfieldName]];
        
        [commands appendData:[[NSString stringWithFormat:@"AbortedTrans :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        
        //--- Shift Detail
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        
        [commands appendData:[@"Shift Detail \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x09"
                       length:sizeof("\x09") - 1];    // HT
        
        [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        NSMutableArray *ShiftRptarray=[[ReportData valueForKey:@"RptShift"] firstObject];
        
        
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        
        if (ShiftRptarray.count>0)
        {
            
            rptfieldName=[NSString stringWithFormat:@"%@",[ShiftRptarray.firstObject valueForKey:@"ShiftUserName"]];
            fldlength=rptfieldName.length;
            ispace=totlength-fldlength-17;
            
            space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
            rptfieldName = [space stringByAppendingString:rptfieldName];
            
            [commands appendData:[[NSString stringWithFormat:@"Shift User Name :%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
            
            NSInteger lengthAmount = 0;
            for (int iShf=0; iShf<ShiftRptarray.count; iShf++)
            {
                NSMutableDictionary *ShiftRptDisc=ShiftRptarray[iShf];
                
                
                NSString *Description=[NSString stringWithFormat:@"%@",[ShiftRptDisc valueForKey:@"TenderType"]];
                
                NSString *Amount=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[ShiftRptDisc valueForKey:@"Amount"]]];
                
                rptfieldName=[NSString stringWithFormat:@"%@",Description];
                lengthAmount=Amount.length;
                fldlength=rptfieldName.length;
                ispace=totlength-fldlength-lengthAmount;
                
                space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
                rptfieldName = [space stringByAppendingString:Amount];
                
                
                [commands appendData:[[NSString stringWithFormat:@"%@%@\r\n",Description,rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
            }
            
            
        }
        
        
        
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        
        
        
        //------Tax Detail
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        
        [commands appendData:[@"Tax Name " dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x09"
                       length:sizeof("\x09") - 1];    // HT
        rptfieldName=@"Amount";
        ispace=totlength-13;
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        rptfieldName = [space stringByAppendingString:[NSString stringWithFormat:@"%@",rptfieldName]];
        
        [commands appendData:[[NSString stringWithFormat:@"%@\r\n",rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        
        NSMutableArray *TaxReport= [ReportData valueForKey:@"RptTax"];
        
        float txAmount=0;
        for (int itx=0; itx<[TaxReport.firstObject count]; itx++)
        {
            NSMutableDictionary *TaxRptDisc=TaxReport.firstObject[itx];
            
            
            NSString *Description=[NSString stringWithFormat:@"%@",[TaxRptDisc valueForKey:@"Descriptions"]];
            
            
            NSString *Amount=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[TaxRptDisc valueForKey:@"Amount"]]];
            
            txAmount+=[[TaxRptDisc valueForKey:@"Amount"] floatValue];
            
            
            rptfieldName=[NSString stringWithFormat:@"%@",Description];
            
            fldlength=rptfieldName.length;
            ispace=totlength-fldlength-8;
            
            space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
            rptfieldName = [space stringByAppendingString:Amount];
            
            
            [commands appendData:[[NSString stringWithFormat:@"%@%@\r\n",Description,rptfieldName] dataUsingEncoding:NSASCIIStringEncoding]];
        }
        
        // ispace=totlength-7-9;
        NSString *txtAmount=[NSString stringWithFormat:@"%.2f",txAmount];
        fldlength=txtAmount.length;
        ispace=totlength-fldlength-10;
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        NSNumber *Taxamt=@(txAmount);
        rptfieldName = [space stringByAppendingString:[currencyFormatter stringFromNumber:Taxamt]];
        
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        
        [commands appendData:[[NSString stringWithFormat:@"Total :%@\r\n",rptfieldName ]dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        //------Department Detail
        
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        
        [commands appendData:[@"Department \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x09"
                       length:sizeof("\x09") - 1];    // HT
        
        [commands appendData:[@"          Amount           (%)        Count\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        //10 space  after Amount,8 space after (%) and 11 space after count calculate
        [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        
        float dptAmount=0;
        float dptper=0;
        int dptcount=0;
        
        NSMutableArray *DepartmentReport= [ReportData valueForKey:@"RptDepartment"];
        
        for (int idpt=0; idpt<[DepartmentReport.firstObject count]; idpt++)
        {
            
            NSString *spaceAmount=@"";
            NSString *spaceper=@"";
            NSString *spaceCount=@"";
            
            NSMutableDictionary *DepartRptDisc=DepartmentReport.firstObject[idpt];
            
            // NSString *Description=[NSString stringWithFormat:@"%@",[XDepartRptDisc valueForKey:@"Descriptions"]];
            
            [commands appendData:[[NSString stringWithFormat:@"%@ \r\n",[DepartRptDisc valueForKey:@"Descriptions"]] dataUsingEncoding:NSASCIIStringEncoding]];
            
            NSString *Amount=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[DepartRptDisc valueForKey:@"Amount"]]];
            
            
            dptAmount+=[[DepartRptDisc valueForKey:@"Amount"] floatValue];
            
            NSString *per=[NSString stringWithFormat:@"%@%@",[DepartRptDisc valueForKey:@"Per"],@"%"];
            
            dptper+=[[DepartRptDisc valueForKey:@"Per"] floatValue];
            
            NSString *Count=[NSString stringWithFormat:@"%@",[DepartRptDisc valueForKey:@"Count"]];
            
            dptcount+=Count.intValue;
            
            ispace=9;// calculate in header spaceing
            
            space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
            spaceAmount = [space stringByAppendingString:Amount];
            
            fldlength=Amount.length;
            ispace=8+9-fldlength;
            
            // ispace=8;// calculate in header spaceing
            space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
            spaceper = [space stringByAppendingString:per];
            
            //int icount=[Count length];
            //fldlength=[spaceper length];
            //ispace=totlength-fldlength-3;
            fldlength=per.length;
            ispace=8+7-fldlength;
            
            
            space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
            spaceCount = [space stringByAppendingString:Count];
            
            
            
            [commands appendData:[[NSString stringWithFormat:@"%@%@%@\r\n",spaceAmount,spaceper,spaceCount] dataUsingEncoding:NSASCIIStringEncoding]];
            
        }
        
        NSString *spaceTotalCount=@"";
        NSString *spaceTotalper=@"";
        
        NSString *DeptAmount=[NSString stringWithFormat:@"$ %.2f",dptAmount];
        fldlength=DeptAmount.length;
        ispace=8+9-fldlength;
        
        NSString *Deptper=[NSString stringWithFormat:@"%.2f",dptper];
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        spaceTotalper = [space stringByAppendingString:Deptper];
        
        fldlength=Deptper.length;
        ispace=8+6-fldlength;
        
        NSString *DeptCount=[NSString stringWithFormat:@"%d",dptcount];
        
        space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
        spaceTotalCount = [space stringByAppendingString:DeptCount];
        
        
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        
        
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        
        
        [commands appendData:[[NSString stringWithFormat:@"Total:   %@%@%@\r\n",DeptAmount,spaceTotalper,spaceTotalCount ]dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        //------Hour Detail
        
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        
        // [commands appendData:[@"Hourly " dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x09"
                       length:sizeof("\x09") - 1];    // HT
        
        [commands appendData:[@"        Hourly        Amount        Count\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        
        float hrAmount=0;
        int hrCount=0;
        
        
        NSMutableArray *HoursReport= [ReportData valueForKey:@"RptHours"];
        for (int iHr=0; iHr<[HoursReport.firstObject count]; iHr++) {
            
            NSString *shrAmount=@"";
            NSString *shrCount=@"";
            
            NSMutableDictionary *HourRptDisc=HoursReport.firstObject[iHr];
            
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            format.dateFormat = @"hh:mm a";
            NSDate *now = [self.rmsDbController getDateFromJSONDate:[HourRptDisc valueForKey:@"Hours"]];
            NSString *dateString = [format stringFromDate:now];
            
            NSString *Hour=[NSString stringWithFormat:@"%@",dateString];
            
            NSString *Amount=[NSString stringWithFormat:@"$ %@",[HourRptDisc valueForKey:@"Amount"]];
            
            hrAmount+=[[HourRptDisc valueForKey:@"Amount"] floatValue];
            
            NSString *Count=[NSString stringWithFormat:@"%@",[HourRptDisc valueForKey:@"Count"]];
            
            hrCount+=Count.intValue;
            
            
            //rptfieldName=[NSString stringWithFormat:@"%@",Hour];
            
            //fldlength=[rptfieldName length];
            //ispace=8+fldlength;
            
            ispace=11;// calculate in header spaceing
            space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
            shrAmount = [space stringByAppendingString:Amount];
            
            // int icount=[Count length];
            //fldlength=[shrAmount length];
            //ispace=totlength-fldlength-3;
            fldlength=Amount.length;
            ispace=11+10-fldlength;
            space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
            shrCount = [space stringByAppendingString:Count];
            
            
            
            [commands appendData:[[NSString stringWithFormat:@"%@%@%@\r\n",Hour,shrAmount,shrCount] dataUsingEncoding:NSASCIIStringEncoding]];
            
            
        }
        
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        [commands appendData:[[NSString stringWithFormat:@"Total :             $%.2f             %d\r\n",hrAmount,hrCount ]dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        
        
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        
        [commands appendData:[@"" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x09"
                       length:sizeof("\x09") - 1];    // HT
        
        
        [commands appendData:[@"        Type         Amount          Count\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        NSMutableArray *TenderReport= [ReportData valueForKey:@"RptTender"];
        
        float tndAmount=0;
        int tndcount=0;
        for (int itnd=0; itnd<[TenderReport.firstObject count]; itnd++) {
            
            NSString *stndAmount=@"";
            NSString *stndcount=@"";
            
            NSMutableDictionary *TenderRptDisc=TenderReport.firstObject[itnd];
            
            
            NSString *Description=[NSString stringWithFormat:@"%@",[TenderRptDisc  valueForKey:@"Descriptions"]];
            
            NSString *Amount=[NSString stringWithFormat:@" %@",[currencyFormatter stringFromNumber:[TenderRptDisc valueForKey:@"Amount"]]];
            tndAmount+=[[TenderRptDisc valueForKey:@"Amount"] floatValue];
            
            NSString *Count=[NSString stringWithFormat:@"%@",[TenderRptDisc valueForKey:@"Count"]];
            
            tndcount+=Count.intValue;
            
            //fldlength=[Description length];
            fldlength=Description.length;
            ispace=15+5-fldlength;
            
            space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
            stndAmount = [space stringByAppendingString:Amount];
            
            //fldlength=[stndAmount length];
            //ispace=totlength-fldlength-3;
            fldlength=Amount.length;
            
            ispace=10+10-fldlength;
            space = [[NSString string] stringByPaddingToLength:ispace withString:@" " startingAtIndex:0];
            stndcount = [space stringByAppendingString:Count];
            
            
            [commands appendData:[[NSString stringWithFormat:@"%@%@%@\r\n",Description,stndAmount,stndcount] dataUsingEncoding:NSASCIIStringEncoding]];
            
        }
        
        [commands appendData:[@"        \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x1b\x45"
                       length:sizeof("\x1b\x45") - 1];    // SetBold
        
        
        [commands appendData:[[NSString stringWithFormat:@"Total :              $%.2f            %d\r\n",tndAmount,tndcount ]dataUsingEncoding:NSASCIIStringEncoding]];
        
        [commands appendBytes:"\x1b\x46"
                       length:sizeof("\x1b\x46") - 1];// CancelBold
        
        
        
        
        [commands appendBytes:"\x1b\x64\x02"
                       length:sizeof("\x1b\x64\x02") - 1];    // CutPaper
        
        // [self Cleardata];
        
        [PrinterFunctions sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000 deviceName:@"Printer" withDelegate:nil];
        
        }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
