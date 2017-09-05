//
//  ReportViewController.h
//  POSFrontEnd
//
//  Created by Nirav Patel on 06/11/12.
//
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
//#import "POSMainMenuView.h"
#import "CashinOutViewController.h"
#import "NDHTMLtoPDF.h"


@interface ReportViewController : UIViewController<UIPrintInteractionControllerDelegate,UITableViewDataSource,UITableViewDelegate,NSURLConnectionDataDelegate,NSXMLParserDelegate,NSStreamDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate>
{
    
}
@property (nonatomic,strong) NSString *strTypeofChart;


-(NSString *)printXFileReport :(NSMutableArray *)responseArray :(NSString *)reportName;
-(void)printZreport :(NSMutableArray *)responseArray;

-(IBAction)ccBatchClicked:(id)sender;

-(void)printShiftReport;

-(IBAction)printReport:(id)sender;
-(IBAction)close:(id)sender;
////Manger x

-(IBAction)getXreportDetail:(id)sender;
//genrate Z
-(void)getZReport;
-(IBAction)generateZReport:(id)sender;
-(void)getXReport;

//Manger Z
-(IBAction)showManagerView:(id)sender;
-(IBAction)closeMangerView:(id)sender;
-(IBAction)openDatePicker:(id)sender;

//generate ZZ
-(IBAction)getZZreportDetail:(id)sender;
-(void)getZZReportData;

//ZZ Manager
-(IBAction)showZZManagerView:(id)sender;

// % wise chart
-(IBAction)PercentageChartView:(id)sender;

// $ wise chart
-(IBAction)DollorChartView:(id)sender;

// Show ManagerReportview
-(IBAction)managerReportClicked:(id)sender;
-(IBAction)cancelManagerViewClicked:(id)sender;



@end
