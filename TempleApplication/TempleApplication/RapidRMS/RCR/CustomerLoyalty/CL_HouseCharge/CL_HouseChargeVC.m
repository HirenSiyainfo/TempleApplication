//
//  CL_HouseChargeVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 18/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CL_HouseChargeVC.h"
#import "CL_HouseChargeListCell.h"
#import "CL_HouseChargePaymentVC.h"
#import "CustomerLoyaltyVC.h"
#import "RmsDbController.h"
#import "CS_ReportGenerator.h"
#import "NDHTMLtoPDF.h"

@interface CL_HouseChargeVC ()<UITableViewDelegate , UITableViewDataSource , CL_HouseChargePaymentVCDelegate , CustomerLoyaltyVCDelegate , NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate>

@property (nonatomic ,strong) CL_HouseChargePaymentVC *cl_HouseChargePaymentVC;
@property (nonatomic ,strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) CS_ReportGenerator *cs_ReportGenerator;
@property (nonatomic, strong) RapidCustomerLoyalty *rapidCustomerLoyaltyInvoiceObject;

@property (nonatomic, weak) IBOutlet UITableView *tblHouseChargeList;
@property (nonatomic, weak) IBOutlet UILabel *lblBalance;
@property (nonatomic, weak) IBOutlet UILabel *lblRecentAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblLastPayDate;
@property (nonatomic, weak) NSString *strMonthDate;
@property (nonatomic, weak) NSNumber *currentBalanceAmount;

@property (nonatomic, weak) IBOutlet UIButton *btnCollectBalance;
@property (nonatomic, weak) IBOutlet UIButton *btnAddCredit;

@property (nonatomic, strong) UIDocumentInteractionController *controller;

@end

@implementation CL_HouseChargeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCustomerHouseChargeInformation:(NSMutableArray *)arrHouseCharge withCustomerInfo:(RapidCustomerLoyalty *)customerInfo strdateTimeSet:(NSString *)strMonthlyDate withIsFromDashBoard:(BOOL)isFromDashBoard
{
    if (isFromDashBoard)
    {
        _btnCollectBalance.enabled = NO;
        _btnAddCredit.enabled = NO;
    }
    else{
        _btnCollectBalance.enabled = YES;
        _btnAddCredit.enabled = YES;

    }
    
    _strMonthDate = strMonthlyDate;
    self.rapidCustomerLoyaltyInvoiceObject = customerInfo;
    if (arrHouseCharge.count>0)
    {
    self.houseChargeListArray = arrHouseCharge;
        
    _currentBalanceAmount = [[arrHouseCharge objectAtIndex:0] valueForKey:@"balance"];
    _lblBalance.text = [NSString stringWithFormat:@"%.2f", _currentBalanceAmount.floatValue];
        
        if (_currentBalanceAmount.floatValue < 0) {
            _btnCollectBalance.enabled = YES;
        }
        else{
            _btnCollectBalance.enabled = NO;
        }

    for (CL_HouseCharge *cl_HouseCharge  in arrHouseCharge)
    {
        if (cl_HouseCharge.Credit.floatValue > 0 )
        {
             _lblRecentAmount.text = [NSString stringWithFormat:@"$ %.2f",cl_HouseCharge.Credit.floatValue];
            _lblLastPayDate.text = [NSString stringWithFormat:@"%@",[cl_HouseCharge.houseChageDate substringToIndex:20]];
            break;
        }
    }
    }
    else
    {
        _btnCollectBalance.enabled = NO;
        self.houseChargeListArray = nil;;
 
    }
    
    
    [_tblHouseChargeList reloadData];


}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.houseChargeListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CL_HouseChargeListCell";
    CL_HouseChargeListCell *houseChargeListCell = (CL_HouseChargeListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    CL_HouseCharge *cl_HouseCharge = (self.houseChargeListArray)[indexPath.row];

    houseChargeListCell.backgroundColor = [UIColor clearColor];
    houseChargeListCell.lblDateTime.text = [NSString stringWithFormat:@"%@",cl_HouseCharge.houseChageDate];
    houseChargeListCell.lblDateTime.numberOfLines = 2;
    
    houseChargeListCell.lblInvoiceNo.text = [NSString stringWithFormat:@"%@",cl_HouseCharge.invoice];
    houseChargeListCell.lblCredit.text = [NSString stringWithFormat:@"$ %.2f",cl_HouseCharge.Credit.floatValue];
    houseChargeListCell.lblDebit.text = [NSString stringWithFormat:@"$ %.2f",cl_HouseCharge.debit.floatValue];
    houseChargeListCell.lblBalance.text = [NSString stringWithFormat:@"$ %.2f",cl_HouseCharge.balance.floatValue];

    if (cl_HouseCharge.balance.floatValue < 0) {
        houseChargeListCell.lblBalance.textColor = [UIColor redColor];
    }
    else
    {
        houseChargeListCell.lblBalance.textColor = [UIColor blackColor];
    }

    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(246/255.f) green:(246/255.f) blue:(246/255.f) alpha:0.1];
    houseChargeListCell.selectedBackgroundView = selectionColor;
    return houseChargeListCell;
    
}

-(IBAction)btnBalancePayment:(id)sender
{
    [self.cl_HouseChageVCDelegate didShowHouseChargePopOverView:@"Collect Payment" withBalanceAmount: _currentBalanceAmount];
}

-(IBAction)btnAddCredit:(id)sender
{
    [self.cl_HouseChageVCDelegate didShowHouseChargePopOverView:@"Add Credit" withBalanceAmount:_currentBalanceAmount];
}

-(IBAction)btnSetCreditLimit:(id)sender
{
    [self.cl_HouseChageVCDelegate didShowHouseChargePopOverView:@"Credit Limit" withBalanceAmount:_currentBalanceAmount];

}

-(IBAction)btnRefundCredit:(id)sender
{
    [self.cl_HouseChageVCDelegate didShowHouseChargePopOverView:@"Refund Credit" withBalanceAmount:_currentBalanceAmount];
    
}
-(IBAction)btnPrint:(id)sender
{
    NSArray *headerFields = @[@(CS_HouseChargeReportDate),@(CS_HouseChargeReportInvoice),@(CS_HouseChargeReportCredit),@(CS_HouseChargeReportDebit),@(CS_HouseChargeReportBalance)];
    
    NSArray *valueFields = @[@"houseChageDate",@"invoice",@"Credit",@"debit",@"balance"];
    
    self.cs_ReportGenerator = [[CS_ReportGenerator alloc] initWithCSReportHeaderFileds:headerFields withReportValueFields:valueFields withReportProcess:CS_HouseCharge withReportDetails:self.houseChargeListArray customerDetail:self.rapidCustomerLoyaltyInvoiceObject withFromDateAndTime:_strMonthDate];
    [self.cs_ReportGenerator generateReportHTML];

    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.cs_ReportGenerator.reportHTMLString]
                                         pathForPDF:@"~/Documents/csInvoiceReport.pdf".stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
}

#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    //    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    //    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
}

-(void)openDocumentwithSharOption:(NSString *)strpdfUrl{
    // here's a URL from our bundle
    NSURL *documentURL = [[NSURL alloc]initFileURLWithPath:strpdfUrl];
    
    // pass it to our document interaction controller
    self.controller.URL = documentURL;
    // present the preview
    [self.controller presentPreviewAnimated:YES];
    
}


- (UIDocumentInteractionController *)controller {
    
    if (!_controller) {
        _controller = [[UIDocumentInteractionController alloc]init];
        _controller.delegate = self;
    }
    return _controller;
}



#pragma mark - Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}



- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}



@end
