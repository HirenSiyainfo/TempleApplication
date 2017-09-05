//
//  CL_InvoicesVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 27/11/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CL_InvoicesVC.h"
#import "CL_InvoiceListVC.h"
#import "CL_ItemListVC.h"
#import "RmsDbController.h"
#import "RmsActivityIndicator.h"
#import "CS_ReportGenerator.h"
#import "NDHTMLtoPDF.h"

@interface CL_InvoicesVC ()<ItemListVCDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate >
{
    NSMutableArray *arrInvoiceSearchList;
    NSMutableArray *arrItemSearchList;
    NSString *strDateAndTime;
}

@property (nonatomic, weak) IBOutlet UIButton *btnInvoiceList;
@property (nonatomic ,weak) IBOutlet UIButton *btnItemList;
@property (nonatomic ,weak) IBOutlet UIView *viewItemList;;
@property (nonatomic ,weak) IBOutlet UIView *viewInvoiceList;
@property (nonatomic ,weak) IBOutlet UITextField *txtSearchInvoice;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong)CL_InvoiceListVC *invoiceListVC;
@property (nonatomic, strong)CL_ItemListVC *itemListVC;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) CS_ReportGenerator *cs_ReportGenerator;
@property (nonatomic, strong) RapidCustomerLoyalty *rapidCustomerLoyaltyInvoiceObject;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) NSString *invoiceListSearchString;
@property (nonatomic, strong) NSString *itemListSearchString;
@property (nonatomic, strong) UIDocumentInteractionController *controller;

@end

@implementation CL_InvoicesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)updateInvoiceDataWith:(RapidCustomerLoyalty *)rapidCustomerloyaltyObject withInvoiceDetail:(NSMutableArray *)invoiceDetail withItemDetail:(NSMutableArray *)itemDetail strMonthDate:(NSString*)stringMonthdate
{
    /// assign customer loyalty object to local object of CL_InvoicesVC
    self.rapidCustomerLoyaltyInvoiceObject = rapidCustomerloyaltyObject;

    [self checkInvoiceSearch];
    arrInvoiceSearchList = invoiceDetail;
    arrItemSearchList = itemDetail;
    strDateAndTime = stringMonthdate;
    /// configure invoice list data......
    [self.invoiceListVC updateInvoiceListViewWithRapidCustomerLoyaltyObject:self.rapidCustomerLoyaltyInvoiceObject withInvoiceList:invoiceDetail];
    [self.itemListVC updateItemListViewWithRapidCustomerLoyaltyObject:itemDetail];
}

-(IBAction)btnInvoiceListClick:(id)sender
{
    [self selectedButton:self.btnInvoiceList];
    [self addViewFromContiner:self.invoiceListVC.view containerView:_viewInvoiceList];
}

-(IBAction)btnItemListClick:(id)sender
{
    [self selectedButton:self.btnItemList];
    [self addViewFromContiner:self.itemListVC.view containerView:_viewItemList];

}

- (void)checkInvoiceSearch
{
    _txtSearchInvoice.text = @"";

    if (self.btnInvoiceList.selected == YES)
    {
        if (self.invoiceListSearchString.length>0)
        {
            _txtSearchInvoice.text = self.invoiceListSearchString;
        }
        else
        {
            self.invoiceListSearchString = @"";
            _txtSearchInvoice.placeholder = @"Invoice No , Payment Type";
            [_txtSearchInvoice setValue:[UIColor colorWithRed:0.086 green:0.063 blue:0.141 alpha:1.000]
                            forKeyPath:@"_placeholderLabel.textColor"];
        }
        
    }
    else if(self.btnItemList.selected == YES)
    {
        if (self.itemListSearchString.length>0)
        {
            _txtSearchInvoice.text = self.itemListSearchString;
        }
        else
        {
            self.itemListSearchString = @"";
            _txtSearchInvoice.placeholder = @"Item Name , UPC";
            [_txtSearchInvoice setValue:[UIColor colorWithRed:0.086 green:0.063 blue:0.141 alpha:1.000]
                            forKeyPath:@"_placeholderLabel.textColor"];
        }
    }
}

-(void)addViewFromContiner:(UIView*)selectedView containerView:(UIView*)containerView
{
    self.invoiceListVC.view.hidden = YES;
    self.itemListVC.view.hidden = YES;
    _viewInvoiceList.hidden = YES;
    _viewItemList.hidden = YES;
    
    selectedView.hidden = NO;
    containerView.hidden = NO;
    [self.view bringSubviewToFront:containerView];
}

-(void)selectedButton:(UIButton*)btnSelect
{
    self.btnInvoiceList.selected = NO;
    self.btnItemList.selected = NO;
    btnSelect.selected = YES;
    [self checkInvoiceSearch];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"CL_InvoiceListVC"])
    {
        self.invoiceListVC = (CL_InvoiceListVC*) segue.destinationViewController;
    }
    if ([segueIdentifier isEqualToString:@"CL_ItemListVC"])
    {
        self.itemListVC  = (CL_ItemListVC*) segue.destinationViewController;
    }
}

- (IBAction)btnSearchClick:(id)sender
{
    if(self.btnInvoiceList.selected == YES)
    {
        if(_txtSearchInvoice.text.length>0)
        {
            [_txtSearchInvoice resignFirstResponder];
            [self.invoiceListVC searchInvoiceListData:self.invoiceListSearchString arrInvoicelListdata:arrInvoiceSearchList];
        }
    }
    else
    {
        if(_txtSearchInvoice.text.length>0)
        {
            [_txtSearchInvoice resignFirstResponder];
            [self.itemListVC searchItemListData:self.itemListSearchString arrItemList:arrItemSearchList];
        }
    }
    [_txtSearchInvoice resignFirstResponder];

}

-(IBAction)btnPrintReport:(id)sender
{
    [self generateHTMLForCustomerLoyaltyReport];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.btnInvoiceList.selected == YES)
    {
        if(_txtSearchInvoice.text.length>0)
        {
            [_txtSearchInvoice resignFirstResponder];
            [self.invoiceListVC searchInvoiceListData:self.invoiceListSearchString arrInvoicelListdata:arrInvoiceSearchList];
        }
        return NO;
    }
    else
    {
        if(_txtSearchInvoice.text.length>0)
        {
            [_txtSearchInvoice resignFirstResponder];
            [self.itemListVC searchItemListData:self.itemListSearchString arrItemList:arrItemSearchList];
        }
        return NO;
    }
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == _txtSearchInvoice)
    {
        _txtSearchInvoice.inputView = nil;
        [_txtSearchInvoice becomeFirstResponder];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == _txtSearchInvoice)
    {
        if (self.btnInvoiceList.selected == YES)
        {
            self.invoiceListSearchString = _txtSearchInvoice.text;
        }
        else
        {
            self.itemListSearchString = _txtSearchInvoice.text;
        }
    }

}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = @"";
    _txtSearchInvoice.text = @"";
    [_txtSearchInvoice becomeFirstResponder];

    if (self.btnInvoiceList.selected == YES)
    {
        self.invoiceListSearchString = @"";
        _txtSearchInvoice.placeholder = @"Invoice No , Payment Type";
        [_txtSearchInvoice setValue:[UIColor colorWithRed:0.086 green:0.063 blue:0.141 alpha:1.000]
                        forKeyPath:@"_placeholderLabel.textColor"];
        [self.invoiceListVC searchInvoiceListData:@"" arrInvoicelListdata:arrInvoiceSearchList];
    }
    else
    {
        self.itemListSearchString = @"";
        _txtSearchInvoice.placeholder = @"Item Name , UPC";
        [_txtSearchInvoice setValue:[UIColor colorWithRed:0.086 green:0.063 blue:0.141 alpha:1.000]
                        forKeyPath:@"_placeholderLabel.textColor"];
        [self.itemListVC searchItemListData:@"" arrItemList:arrItemSearchList];

    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(range.location == 0 && ([string isEqualToString:@""]))
    {
        _txtSearchInvoice.text = @"";
        if (self.btnInvoiceList.selected == YES)
        {
            self.invoiceListSearchString = @"";
            _txtSearchInvoice.placeholder = @"Invoice No , Payment Type";
            [_txtSearchInvoice setValue:[UIColor colorWithRed:0.086 green:0.063 blue:0.141 alpha:1.000]
                            forKeyPath:@"_placeholderLabel.textColor"];

            [self.invoiceListVC searchInvoiceListData:@"" arrInvoicelListdata:arrInvoiceSearchList];
        }
        else
        {
            self.itemListSearchString = @"";
            _txtSearchInvoice.placeholder = @"Item Name , UPC";
            [_txtSearchInvoice setValue:[UIColor colorWithRed:0.086 green:0.063 blue:0.141 alpha:1.000]
                            forKeyPath:@"_placeholderLabel.textColor"];
            [self.itemListVC searchItemListData:@"" arrItemList:arrItemSearchList];
            
        }
        [_txtSearchInvoice becomeFirstResponder];

    }
    return YES;
}
- (void)configureCSReportInvoiceHTMLDetail
{
    NSArray *headerFields = @[@(CS_InvoiceReportInvoiceDate),@(CS_InvoiceReportInvoiceNo),@(CS_InvoiceReportInvoicePrice),@(CS_InvoiceReportInvoiceQty),@(CS_InvoiceReportInvoicePaymentType)];
    
    NSArray *valueFields = @[@"invoiceDate",@"invoiceNo",@"amount",@"itemQty",@"paymentType"];
    
    
    
    self.cs_ReportGenerator = [[CS_ReportGenerator alloc] initWithCSReportHeaderFileds:headerFields withReportValueFields:valueFields withReportProcess:CS_InvoiceReport withReportDetails:[self.invoiceListVC invoiceListArray:self.invoiceListSearchString arrInvoicelListdata:arrInvoiceSearchList] customerDetail:self.rapidCustomerLoyaltyInvoiceObject withFromDateAndTime:strDateAndTime];
    [self.cs_ReportGenerator generateReportHTML];
}


- (void)configureCSReportItemHTMLDetail
{
    NSArray *headerFields = @[@(CS_ItemReportItemDate),@(CS_ItemReportInvoiceNo),@(CS_ItemReportUpc),@(CS_ItemReportItemName),@(CS_ItemReportItemCost),@(CS_ItemReportItemPrice),@(CS_ItemReportItemMargin)];
    
    NSArray *valueFields = @[@"invoiceDate",@"invoice",@"barcode",@"itemName",@"cost",@"price",@"margin"];
    
    self.cs_ReportGenerator = [[CS_ReportGenerator alloc] initWithCSReportHeaderFileds:headerFields withReportValueFields:valueFields withReportProcess:CS_ItemReport withReportDetails:[self.itemListVC itemListArray:self.itemListSearchString arrInvoicelListdata:arrItemSearchList] customerDetail:self.rapidCustomerLoyaltyInvoiceObject withFromDateAndTime:strDateAndTime];
    [self.cs_ReportGenerator generateReportHTML];
}


-(void)generateHTMLForCustomerLoyaltyReport
{
    if (self.btnInvoiceList.selected == YES)
    {
        [self configureCSReportInvoiceHTMLDetail];
    }
    else
    {
        [self configureCSReportItemHTMLDetail];
    }
    
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
