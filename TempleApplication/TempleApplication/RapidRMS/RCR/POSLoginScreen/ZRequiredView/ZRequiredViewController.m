//
//  ZRequiredViewController.m
//  POSFrontEnd
//
//  Created by Nirav Patel on 08/11/12.
//
//

#import "ZRequiredViewController.h"
#import "MyPrintPageRenderer.h"
#import "ReportViewController.h"
#import "RmsDbController.h"


@interface ZRequiredViewController ()
{
    NSArray *array_port;
    NSInteger selectedPort;
}

@property (nonatomic, weak) IBOutlet UITextField *txtOpeningAmt;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (strong,nonatomic) RapidWebServiceConnection *zReportGenerateWC;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@end

@implementation ZRequiredViewController
@synthesize objPL,objReport;

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
    self.crmController  = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.zReportGenerateWC = [[RapidWebServiceConnection alloc] init];
    [super viewDidLoad];
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    
   

    // Do any additional setup after loading the view from its nib.
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
    [ZRequiredViewController setPortName:localPortName];
    [ZRequiredViewController setPortSettings:array_port[selectedPort]];
}

- (IBAction) pressKeyPadButton:(id)sender
{

    
    
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
		if (_txtOpeningAmt.text.length > 0) {
			NSString * displyValue = [_txtOpeningAmt.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
			_txtOpeningAmt.text = displyValue;
		} else {
			NSString * displyValue = [_txtOpeningAmt.text stringByAppendingFormat:@"%@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%ld",(long)[sender tag]]]];
			_txtOpeningAmt.text = displyValue;
		}
	}
    else if ([sender tag] == -99)
    {
		if (_txtOpeningAmt.text.length > 0) {
			//displayText.text = [displayText.text substringToIndex:[displayText.text length]-1];
			//if ([displayText.text isEqual:@"$"] || [displayText.text isEqual:@"$."] || [displayText.text isEqual:@"$."])
            _txtOpeningAmt.text = @"";
		}
	}
    else if ([sender tag] == 101)
    {
		if (_txtOpeningAmt.text.length > 0) {
			NSString * displyValue = [_txtOpeningAmt.text stringByAppendingFormat:@"00"];
			_txtOpeningAmt.text = displyValue;
		}
		else {
			NSString * displyValue = [_txtOpeningAmt.text stringByAppendingFormat:@"%@",[self.rmsDbController applyCurrencyFomatter:@"00"]];
			_txtOpeningAmt.text = displyValue;
            [objPL.view sendSubviewToBack:self.view];
            [objPL doQuickLogin:sender];
		}
	}
	/*if (isQtyOn) {
     displayText.text = [displayText.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
     self.crmController.manualQtyValue = [NSString stringWithFormat:@"%@",displayText.text];
     } else {*/
    if ([[_txtOpeningAmt.text stringByReplacingOccurrencesOfString:@"$" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1) {
        _txtOpeningAmt.text = [_txtOpeningAmt.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        _txtOpeningAmt.text = [NSString stringWithFormat:@"%@.%@",[_txtOpeningAmt.text substringToIndex:_txtOpeningAmt.text.length-2],[_txtOpeningAmt.text substringFromIndex:_txtOpeningAmt.text.length-2]];
    }
    else if ([[_txtOpeningAmt.text stringByReplacingOccurrencesOfString:@"$" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1) {
        _txtOpeningAmt.text = [_txtOpeningAmt.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        _txtOpeningAmt.text = [NSString stringWithFormat:@"%@.%@",[_txtOpeningAmt.text substringToIndex:_txtOpeningAmt.text.length-1],[_txtOpeningAmt.text substringFromIndex:_txtOpeningAmt.text.length-1]];
    }

}
-(IBAction)OpeningAmt:(id)sender{
   [self.view removeFromSuperview];
}

#pragma mark-
#pragma mark Z Report Generating
-(void)generateZReport
{
    NSMutableArray *arrayMain =[[NSMutableArray alloc]init];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"Amount"] = [_txtOpeningAmt.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"] ;
    [arrayMain addObject:dict];
    
    NSMutableDictionary *dictMain =[[NSMutableDictionary alloc]init];
    dictMain[@"ZRequestData"] = arrayMain;

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self zReportResponse:response error:error];
    };
    
    self.zReportGenerateWC = [self.zReportGenerateWC initWithRequest:KURL actionName:WSM_Z_REPORT params:dictMain completionHandler:completionHandler];
}

#pragma mark -
#pragma mark Generate ZReport
- (void)zReportResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseZArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [objReport printZreport:responseZArray];
            }
        }
    }
}

#pragma mark -
#pragma mark Print Delegate Method
- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController {
    if(self.crmController.bZexit==TRUE){
        exit(0);
    }
}

- (void)printInteractionControllerWillDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
}

#pragma mark -
#pragma mark Create Html File

-(NSString *)printXFileReport:(NSMutableArray *)tempArray{
    
    NSString * htmlData = [[NSString alloc] initWithFormat:@"<html><body>"];
    htmlData = [htmlData stringByAppendingFormat:@"<div style=\"border-style:solid; border-width:1px; width:100%@\">",@"%"];
	htmlData = [htmlData stringByAppendingFormat:@"<table cellpadding=\"0\" cellspacing=\"0\" style=\"border-style:solid; border-width:1px; width:100%@; font-size: 11px;\" border=\"0\" width=100%@>",@"%",@"%"];
	htmlData = [htmlData stringByAppendingFormat:@"<tr><td align=\"center\" ><strong>Calhoun Liquor Store </strong></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td align=\"center\"><strong>960 N Wall St.</strong></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td align=\"center\"><strong>Calhoun , GA - 30701 </strong></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td align=\"center\"><strong>Phone No :706-629-1361, </strong></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><hr color=\"#000000\" /></td></tr>"];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td align=\"center\"><strong>X Report</strong></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><table cellpadding=\"0\" cellspacing=\"0\"  style=\"border-style:solid; border-width:0px; width:100%@; font-size: 11px;\" border=\"0\" width=100%@>",@"%",@"%"];
    
    NSDate * date = [NSDate date];
	//Create the dateformatter object
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"dd/MM/yyyy";
	
	//Create the timeformatter object
	NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
	timeFormatter.dateFormat = @"hh:mm a";
	
	//Get the string date
	NSString* printDate = [dateFormatter stringFromDate:date];
	NSString* printTime = [timeFormatter stringFromDate:date];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Report Date </strong></td><td><div align=\"right\">%@ </div></td></tr>",printDate];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Report Time </strong></td><td><div align=\"right\">%@ </div></td></tr>",printTime];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Register # </strong></td><td><div align=\"right\">%@</div></td></tr>",tempArray.firstObject[@"RegisterName"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Batch # </strong></td><td><div align=\"right\">%@</div></td></tr>",tempArray.firstObject[@"BatchNo"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Batch Status </strong></td><td><div align=\"right\">Open </div></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Start Date </strong></td><td><div align=\"right\">%@ </div></td></tr>",tempArray.firstObject[@"Startdate"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Start Time </strong></td><td><div align=\"right\">%@ </div></td></tr>",tempArray.firstObject[@"StartTime"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Current User </strong></td><td><div align=\"right\">%@ </div></td></tr>",tempArray.firstObject[@"CurrentUser"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td colspan=\"2\">&nbsp;</td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Total Sales </strong></td><td><div align=\"right\">$%@ </div></td></tr>",tempArray.firstObject[@"TotalSales"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td>&nbsp;</td><td><div align=\"right\"></div></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>OPening Amount </strong></td><td><div align=\"right\">$%@ </div></td></tr>",tempArray.firstObject[@"OpeningAmount"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Sales </strong></td><td><div align=\"right\">$%@ </div></td></tr>",tempArray.firstObject[@"Sales"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Returns </strong></td><td><div align=\"right\">%@ </div></td></tr>",tempArray.firstObject[@"Return"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>SurCharge </strong></td><td><div align=\"right\">$%@ </div></td></tr>",tempArray.firstObject[@"Surcharge"]];
    
    double doubleTotal1=[tempArray.firstObject[@"OpeningAmount"]doubleValue]+[tempArray.firstObject[@"Sales"]doubleValue]+[tempArray.firstObject[@"Return"]doubleValue]+[tempArray.firstObject[@"Surcharge"]doubleValue];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Total </strong></td><td><div align=\"right\">$%.2f </div></td></tr>",doubleTotal1];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td>&nbsp;</td><td><div align=\"right\"></div></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Collect Tax </strong></td><td><div align=\"right\">$%@</div></td></tr>",tempArray.firstObject[@"CollectTax"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Return Tax </strong></td><td><div align=\"right\">$%@ </div></td></tr>",tempArray.firstObject[@"ReturnTax"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Closing Amount </strong></td><td><div align=\"right\">$%@ </div></td></tr>",tempArray.firstObject[@"ClosingAmount"]];
    
    double doubleTotal2=[tempArray.firstObject[@"CollectTax"]doubleValue]+[tempArray.firstObject[@"ReturnTax"]doubleValue]+[tempArray.firstObject[@"ClosingAmount"]doubleValue];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Total </strong></td><td><div align=\"right\">$%.2f </div></td></tr>",doubleTotal2];;
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td>&nbsp;</td><td><div align=\"right\"></div></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td colspan=\"2\"><div align=\"right\"></div></td></tr><tr><td><strong>Over / Short </strong></td><td><div align=\"right\"><strong>$%.2f </strong></div></td></tr>",doubleTotal1 - doubleTotal2];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td>&nbsp;</td><td><div align=\"right\"></div></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td colspan=\"2\"><div align=\"right\"></div></td></tr><tr><td><strong>Drop Amount </strong></td><td><div align=\"right\">$0.00 </div></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Discount </strong></td><td><div align=\"right\">$%@</div></td></tr>",tempArray.firstObject[@"Discount"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Total Tenderd </strong></td><td><div align=\"right\">%@</div></td></tr>",tempArray.firstObject[@"TotalTender"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Total Changed </strong></td><td><div align=\"right\">%@</div></td></tr>",tempArray.firstObject[@"TotalChange"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Cost Of Goods </strong></td><td><div align=\"right\"></div></td></tr>"];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>No Sales Count </strong></td><td><div align=\"right\">%@ </div></td></tr>",tempArray.firstObject[@"NoSales"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Customer Count </strong></td><td><div align=\"right\">%@ </div></td></tr>",tempArray.firstObject[@"CustomerCount"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Aborted trans </strong></td><td><div align=\"right\">%@</div></td></tr>",tempArray.firstObject[@"AbortedTrans"]];
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td colspan=\"2\">&nbsp;</td></tr><tr><td><strong>Taxes Name </strong></td><td><div align=\"right\"><strong>Amount </strong></div></td></tr>"];
    
    NSArray *arrayRptTax =tempArray.firstObject[@"RptTax"];
    double rptRptTax=0.00;
    for(int i =0;i<arrayRptTax.count;i++)
    {
        htmlData = [htmlData stringByAppendingFormat:@"<tr><td>%@ </td><td><div align=\"right\">$%@ </div></td></tr>",arrayRptTax[i][@"Descriptions"],arrayRptTax[i][@"Amount"]];
        
        rptRptTax+=[arrayRptTax[i][@"Amount"]doubleValue];
    }
    /*htmlData = [htmlData stringByAppendingFormat:@"<tr><td>High Tax </td><td><div align=\"right\">$288.02 </div></td></tr>"];
     htmlData = [htmlData stringByAppendingFormat:@"<tr><td>Low Tax </td><td><div align=\"right\">$3.25 </div></td></tr>"];*/
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><div align=\"left\"><strong>Total </strong></div></td><td><div align=\"right\">$%.2f </div></td></tr></table>",rptRptTax];
    
    htmlData = [htmlData stringByAppendingFormat:@"</td><tr><td>&nbsp;</td></tr><tr><td ><table cellpadding=\"0\" cellspacing=\"0\"  style=\"border-style:solid; border-width:1px; width:100%@; font-size: 11px;\" border=\"0\" width=100%@>",@"%",@"%"];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td width=60 ><strong>Department </strong></td><td align=\"right\"><strong>Amount </strong></td><td width=60 align=\"right\"><strong>(%@) </strong></td><td align=\"right\"><p><strong>Cust. Count </strong></p></td></tr>",@"%"];
    
    
    NSArray *arrayRptDepartment =tempArray.firstObject[@"RptDepartment"];
    double rptDeptAmoutCount=0.00;
    double  rptDeptPerc=0;
    int  rptDeptCustCount=0;
    
    for(int i =0;i<arrayRptDepartment.count;i++)
    {
        htmlData = [htmlData stringByAppendingFormat:@"<tr><td>%@</td><td align=\"right\">$%@</td><td align=\"right\">%@</td><td align=\"right\">%@</td></tr>",arrayRptDepartment[i][@"Descriptions"],arrayRptDepartment[i][@"Amount"],arrayRptDepartment[i][@"Per"],arrayRptDepartment[i][@"Count"]];
        
        rptDeptAmoutCount+=[arrayRptDepartment[i][@"Amount"]doubleValue];
        rptDeptPerc+=[arrayRptDepartment[i][@"Per"]doubleValue];
        rptDeptCustCount+=[arrayRptDepartment[i][@"Count"]intValue];
        
    }
    
    /*htmlData = [htmlData stringByAppendingFormat:@"<tr><td>BEVERAGES GROCERY</td><td align=\"right\">$107.22</td><td align=\"right\">2</td><td align=\"right\">41</td></tr>"];
     
     htmlData = [htmlData stringByAppendingFormat:@"<tr><td>Cigarettes PK</td><td align=\"right\">$266.34</td><td align=\"right\">5.33</td><td align=\"right\">38</td></tr>"];
     
     
     htmlData = [htmlData stringByAppendingFormat:@"<tr><td>Beer</td><td align=\"right\">$1400</td><td align=\"right\">33</td><td align=\"right\">121</td></tr>"];
     
     htmlData = [htmlData stringByAppendingFormat:@"<tr><td>Liquor</td><td align=\"right\">$1757</td><td align=\"right\">41</td><td align=\"right\">118</td></tr>"];
     
     htmlData = [htmlData stringByAppendingFormat:@"<tr><td>Mix MISCELLANEOUS</td><td align=\"right\">$69.71</td><td align=\"right\">1.64</td><td align=\"right\">18</td></tr>"];
     
     htmlData = [htmlData stringByAppendingFormat:@"<tr><td>Wine</td><td align=\"right\">$131.73</td><td align=\"right\">3.11</td><td align=\"right\">14</td></tr>"];*/
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</tr>"];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Total</strong></td align=\"right\"><td><strong>$%.2f</strong></td><td align=\"right\"><strong>%.2f</strong></td><td align=\"right\"><strong>%d</strong></td></tr>",rptDeptAmoutCount,rptDeptPerc,rptDeptCustCount];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr></table><tr><td>&nbsp;</td></tr><tr><td><table cellpadding=\"0\" cellspacing=\"0\"  style=\"border-style:solid; border-width:1px; width:100%@; font-size: 11px;\" border=\"0\" width=100%@>",@"%",@"%"];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td width=\"26%@\" ><strong>Hour </strong></td><td width=\"31%@\" >&nbsp;</td><td  align=\"right\" width=\"22%@\" ><strong>Amount</strong></td><td align=\"right\" width=\"21%@\"><p><strong>Cust. Count </strong></p></td></tr>",@"%",@"%",@"%",@"%"];
    
    NSArray *arrayRptHours =tempArray.firstObject[@"RptHours"];
    double rptAmoutCount=0.00;
    int  rptCustCount=0;
    
    for(int i =0;i<arrayRptHours.count;i++)
    {
        htmlData = [htmlData stringByAppendingFormat:@"<tr><td>%@ </td><td>&nbsp;</td><td align=\"right\">$%@ </td><td align=\"right\">%@</td></tr>",arrayRptHours[i][@"Hours"],arrayRptHours[i][@"Amount"],arrayRptHours[i][@"Count"]];
        
        rptAmoutCount+=[arrayRptHours[i][@"Amount"]doubleValue];
        rptCustCount+=[arrayRptHours[i][@"Count"]intValue];
    }
    
    /*htmlData = [htmlData stringByAppendingFormat:@"<tr><td>8:00 am </td><td>&nbsp;</td><td align=\"right\">$20.83 </td><td align=\"right\">5</td></tr>"];
     
     htmlData = [htmlData stringByAppendingFormat:@"<tr><td>9:00 am </td><td>&nbsp;</td><td align=\"right\" >$131.20 </td><td align=\"right\">12</td></tr>"];*/
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>"];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Total </strong></td><td>&nbsp;</td><td align=\"right\"><strong>$%.2f </strong></td><td align=\"right\"><strong>%d </strong></td></tr>",rptAmoutCount,rptCustCount];
    htmlData = [htmlData stringByAppendingFormat:@"</table></td></tr><tr><td>&nbsp;</td><tr><td><table cellpadding=\"0\" cellspacing=\"0\"  style=\"border-style:solid; border-width:1px; width:100%@; font-size: 11px;\" border=\"0\" width=100%@>",@"%",@"%"];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Tender Type </strong></td><td>&nbsp;</td><td align=\"right\"><strong>Amount</strong></td><td align=\"right\"><p><strong>Tend. Count </strong></p></td></tr>"];
    
    
    NSArray *arryRptTender =tempArray.firstObject[@"RptTender"];
    double tenderAmoutCount=0.00;
    int  tenderCount=0;
    for(int i =0;i<arryRptTender.count;i++)
    {
        htmlData = [htmlData stringByAppendingFormat:@"<tr><td>%@ </td><td>&nbsp;</td><td align=\"right\">%@ </td><td align=\"right\">%@ </td></tr>",arryRptTender[i][@"Descriptions"],arryRptTender[i][@"Amount"],arryRptTender[i][@"Count"]];
        
        tenderAmoutCount+=[arryRptTender[i][@"Amount"]doubleValue];
        tenderCount+=[arryRptTender[i][@"Count"]intValue];
    }
    
    /*htmlData = [htmlData stringByAppendingFormat:@"<tr><td>Cash </td><td>&nbsp;</td><td align=\"right\">2,947.31 </td><td align=\"right\">225 </td></tr>"];
     
     htmlData = [htmlData stringByAppendingFormat:@"<tr><td>Credit Card </td><td>&nbsp;</td><td align=\"right\">0.00</td><td align=\"right\">0</td></tr>"];
     
     htmlData = [htmlData stringByAppendingFormat:@"<tr><td>Debit Card </td><td>&nbsp;</td><td align=\"right\">1,582.04 </td><td align=\"right\">63 </td></tr>"];
     
     htmlData = [htmlData stringByAppendingFormat:@"<tr><td>Check </td><td>&nbsp;</td><td align=\"right\">0.00</td><td align=\"right\">0</td></tr>"];*/
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>"];
    
    htmlData = [htmlData stringByAppendingFormat:@"<tr><td><strong>Total </strong></td><td>&nbsp;</td><td align=\"right\"><strong>%.2f</strong></td><td align=\"right\"><strong>%d </strong></td></tr>",tenderAmoutCount,tenderCount];
    
    htmlData = [htmlData stringByAppendingFormat:@"</table></td>"];
    htmlData = [htmlData stringByAppendingFormat:@"</table></div>"];
    htmlData = [htmlData stringByAppendingFormat:@"</body></html>"];
    
    return htmlData;
}

-(IBAction)cancel:(id)sender{
    [self.view removeFromSuperview];
   // [objPL sideBarbuttonActionHandler:objPL.btnUsername];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
