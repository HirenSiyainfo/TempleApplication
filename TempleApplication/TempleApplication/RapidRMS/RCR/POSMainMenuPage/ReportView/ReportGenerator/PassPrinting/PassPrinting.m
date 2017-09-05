//
//  PassPrinting.m
//  RapidRMS
//
//  Created by Siya Infotech on 25/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PassPrinting.h"
#import "PassPrintingConstant.h"
#import "RasterPrintJob.h"
#import "RasterPrintJobBase.h"

@implementation PassPrinting

- (instancetype)init {
    self = [super init];
    if (self) {
        _sections = @[@(PrintingSectionStoreInfo),@(PrintingSectionPassHeader),@(PrintingSectionQRCode),@(PrintingSectionPassDetails),@(PrintingSectionFooter)];
        _fields = @[@[@(PrintingFieldStoreName),@(PrintingFieldAddressLine1),@(PrintingFieldAddressLine2),@(PrintingFieldEmail),@(PrintingFieldPhone)],
                    @[@(PrintingFieldTitle)],
                    @[@(PrintingFieldNoOfPassDays),@(PrintingFieldPassNo),@(PrintingFieldQRCode),@(PrintingFieldExpiryDays)],
                    @[@(PrintingFieldDateOfPurchase),@(PrintingFieldRegisterName),@(PrintingFieldUserName),@(PrintingFieldInvoiceNo),@(PrintingFieldPaymentType),@(PrintingFieldCCNo)],
                    @[@(PrintingFieldMessage),@(PrintingFieldStoreName)]
                    ];
        _rmsDbController = [RmsDbController sharedRmsDbController];
        currencyFormatter = [[NSNumberFormatter alloc] init];
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        currencyFormatter.maximumFractionDigits = 2;
        _printerWidth = 48;
   /*    self._printingData = @{@"PassType" : @"One Day Pass",
                               @"DateOfPurchase" : @"15/06/2015",
                               @"ExpiryDays" : @"365",
                               @"ValidityDays" : @"12",
                               @"InvoiceNo" : @"A256",
                               @"PassNo" : @"2525",
                               @"QRCode" : @"Hello..Dear",
                               };*/

    }
    return self;
}

#pragma mark - Generate html

- (NSString *)generateHtml
{
    NSMutableString *html = [[NSMutableString alloc] init];
    return html;
}


#pragma mark - Printing

- (PrintingSection)sectionAtSectionIndex:(NSInteger)sectionIndex {
    return [_sections[sectionIndex] integerValue];
}

- (void)configurePrint:(NSString *)portSettings portName:(NSString *)portName withDelegate:(id)delegate
{
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    
    if (isBlueToothPrinter) {
        _printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings  deviceName:@"Printer" withDelegate:delegate];
        [_printJob enableSlashedZero:YES];
    }
    else
    {
        _printJob = [[RasterPrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
    }
}

- (void)concludePrint
{
    [_printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [_printJob firePrint];
    _printJob = nil;
}

- (void)printingWithPort:(NSString *)portName portSettings:(NSString *)portSettings withDelegate:(id)delegate
{
//    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
//    if(!isBlueToothPrinter)
//    {
//     //   [self _tcpPrintingWithPort:portName portSettings:portSettings];
//    }
//    else
//    {
        [self _printingWithPort:portName portSettings:portSettings withDelegate:delegate];
//    }
}

#pragma mark - TCP Printing

- (void)_tcpPrintReportWithPort:(NSString*)portName portSettings:(NSString*)portSettings
{
    _printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"" withDelegate:nil];
    if ([self generateHtml].length > 0 && [self generateHtml] != nil) {
        [self LoadReceiptHtml:[self generateHtml]];
    }
}

-(void)LoadReceiptHtml:(NSString *)html{
    webViewForTCPPrinting = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 576, 200)];
    webViewForTCPPrinting.delegate = self;
    NSString *strHtml = [self createHTMLFormateForDisplayReportInWebView:html];
    [webViewForTCPPrinting loadHTMLString:strHtml baseURL:nil];
}

- (NSString *)createHTMLFormateForDisplayReportInWebView:(NSString *)html
{
    NSString *strReport = [html stringByReplacingOccurrencesOfString:@"$$STYLE$$" withString:@"<style>TD{} TD.TaxType {width: 25%;padding-bottom:3px;} TD.TaxSales {width: 25%;padding-bottom:3px;} TD.TaxTax {width: 25%;padding-bottom:3px;} TD.TaxCustCount {width: 25%;padding-bottom:3px;} TD.TederType { width: 30%;padding-bottom:3px;} TD.TederTypeAmount { width: 40%;padding-bottom:3px;} TD.TederTypeAvgTicket { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.TederTypePer { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.TederTypeCount { width: 30%;padding-bottom:3px;} TD.TipsTederType {width: 25%;padding-bottom:3px;} TD.TipsTederAmount {width: 25%;padding-bottom:3px;} TD.TipsTeder {width: 25%;padding-bottom:3px;}TD.TipsTederTotal {width: 25%;padding-bottom:3px;} TD.CardType { width: 30%;padding-bottom:3px;} TD.CardTypeAmount { width: 40%;padding-bottom:3px;} TD.CardTypeAvgTicket { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.CardTypeTypePer { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.CardTypeCount { width: 30%;padding-bottom:3px;} TD.DepartmentName { width: 25%; padding-bottom:3px;} TD.DepartmentCost { width: 0%; overflow: hidden; display: none; text-indent: -9999; padding-bottom:3px;} TD.DepartmentAmount { width: 25%;padding-bottom:3px;} TD.DepartmentMargin { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.DepartmentPer { width: 25%;padding-bottom:3px;} TD.DepartmentCount { width: 25%;padding-bottom:3px;}TD.HourlySales { width: 30%;padding-bottom:3px;} TD.HourlySalesCost { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.HourlySalesAmount { width: 40%;padding-bottom:3px;} TD.HourlySalesMargin { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.HourlySalesCount { width: 30%;padding-bottom:3px;}</style>"];
    strReport =  [strReport stringByReplacingOccurrencesOfString:@"$$WIDTH$$" withString:@"width:286px"];
    strReport = [strReport stringByReplacingOccurrencesOfString:@"$$WIDTHCOMMONHEADER$$" withString:@"width:300px"];
    return strReport;
}


#pragma mark - Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    CGFloat height = [webView stringByEvaluatingJavaScriptFromString:@"document.height"].floatValue;
    CGFloat width = [webView stringByEvaluatingJavaScriptFromString:@"document.width"].floatValue;
    CGRect frame = webView.frame;
    frame.size.height = height;
    frame.size.width = width;
    webView.frame = frame;
    [self printImagefromWebview:webView];
    [webViewForTCPPrinting removeFromSuperview];
}

#pragma mark - Print Image From Html WebView

-(void)printImagefromWebview:(UIWebView *)pwebview{
    UIImage *img = [UIImage imageWithData:[self getImageFromView:pwebview]];
    UIImage *printImage = [self imageResize:img andResizeTo:CGSizeMake(img.size.width * 1.4, img.size.height * 1.4)];
    [_printJob printImage:printImage];
    [_printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [_printJob firePrint];
}

#pragma mark - Image Resizing

- (UIImage *)imageResize:(UIImage*)img andResizeTo:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [img drawInRect:CGRectMake(-120,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(NSData *)getImageFromView:(UIView *)view  // Mine is UIWebView but should work for any
{
    NSData *pngImg;
//    CGFloat max;
//    CGSize viewSize = [view bounds].size;
    
    // Get the size of the the FULL Content, not just the bit that is visible
    CGSize size = [view sizeThatFits:CGSizeZero];
    
    // Scale down if on iPad to something more reasonable
//    max = (viewSize.width > viewSize.height) ? viewSize.width : viewSize.height;
    
    UIGraphicsBeginImageContextWithOptions( size, YES, 1.0 );
    
    // Set the view to the FULL size of the content.
    view.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    pngImg = UIImagePNGRepresentation(image);
    
    UIGraphicsEndImageContext();
    NSLog(@"Image size is  == %@",NSStringFromCGSize(image.size));
    return pngImg;    // Voila an image of the ENTIRE CONTENT, not just visible bit
}

#pragma mark - Bluetooth Printing

- (void)_printingWithPort:(NSString *)portName portSettings:(NSString *)portSettings withDelegate:(id)delegate
{
    [self configurePrint:portSettings portName:portName withDelegate:delegate];
    
    NSInteger sectionCount = _sections.count;
    for (int i = 0; i < sectionCount; i++) {
        PrintingSection section = [self sectionAtSectionIndex:i];
        [self printHeaderForSection:section];
        [self printCommandForSectionAtIndex:i];
        [self printFooterForSection:section];
    }
    
    [self concludePrint];
}

#pragma mark - Printing Header

- (void)printHeaderForSection:(NSInteger)section {
    switch (section) {
            
        case PrintingSectionStoreInfo:
            break;
            
        case PrintingSectionPassHeader:
            break;
            
        case PrintingSectionQRCode:
            break;

        case PrintingSectionPassDetails:
            break;
            
        case PrintingSectionFooter:
            break;

        default:
            break;
    }
}

#pragma mark - Printing Fields

- (void)printCommandForSectionAtIndex:(NSInteger)sectionIndex
{
    NSArray *sectionFields = _fields[sectionIndex];
    NSInteger fieldCount = sectionFields.count;
    for (int i = 0; i < fieldCount; i++) {
        [self printCommandForFieldAtIndex:i sectionIndex:sectionIndex];
    }
}

- (void)printCommandForFieldAtIndex:(NSInteger)fieldIndex sectionIndex:(NSInteger)sectionIndex
{
    NSNumber *fieldNumber = _fields[sectionIndex][fieldIndex];
    PrintingField fieldId = fieldNumber.integerValue;
    [self printFieldWithId:fieldId];
}

- (void)printFieldWithId:(NSInteger)fieldId {
    switch (fieldId) {
            
        case PrintingFieldStoreName:
            [self printStoreName];
            break;
            
        case PrintingFieldAddressLine1:
            [self printAddressLine1];
            break;
            
        case PrintingFieldAddressLine2:
            [self printAddressLine2];
            break;
            
        case PrintingFieldEmail:
            [self printEmail];
            break;
       
        case PrintingFieldPhone:
            [self printPhoneNo];
            break;

        case PrintingFieldTitle:
            [self printTitle];
            break;
       
        case PrintingFieldNoOfPassDays:
            [self printNoOfPassDays];
            break;

        case PrintingFieldPassNo:
            [self printPassNo];
            break;
            
        case PrintingFieldQRCode:
            [self printQRCode];
            break;
            
        case PrintingFieldExpiryDays:
            [self printExpiryDays];
            break;

        case PrintingFieldDateOfPurchase:
            [self printDateOfPurchase];
            break;
        
        case PrintingFieldRegisterName:
            [self printRegisterName];
            break;
            
        case PrintingFieldUserName:
            [self printUserName];
            break;

        case PrintingFieldInvoiceNo:
            [self printInvoiceNo];
            break;
       
        case PrintingFieldPaymentType:
            [self printPaymentType];
            break;
       
        case PrintingFieldCCNo:
            [self printCCNo];
            break;

        case PrintingFieldMessage:
            [self printMessage];
            break;
       
        case PrintingFieldWebsite:
            [self printWebsite];
            break;

        default:
            NSLog(@"Implement Field - %@", @(fieldId));
            break;
    }
}

- (void)printStoreName {
    [_printJob setTextAlignment:TA_CENTER];
    [_printJob setTextSize:1];
    [_printJob printLine:[[_rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]];
    [_printJob setTextSize:0];
}

- (void)printAddressLine1 {
    [_printJob setTextAlignment:TA_CENTER];
    NSDictionary *branchInfo = [_rmsDbController.globalDict valueForKey:@"BranchInfo"];
    NSString *addressLine1 = [NSString stringWithFormat:@"%@  , %@", [branchInfo valueForKey:@"Address1"],[branchInfo valueForKey:@"Address2"]];
    [_printJob printLine:addressLine1];
}

- (void)printAddressLine2 {
    [_printJob setTextAlignment:TA_CENTER];
    NSDictionary *branchInfo = [_rmsDbController.globalDict valueForKey:@"BranchInfo"];
    NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [branchInfo valueForKey:@"City"],[branchInfo valueForKey:@"State"],[branchInfo valueForKey:@"ZipCode"]];
    [_printJob printLine:addressLine2];
}

- (void)printEmail {
    [_printJob setTextAlignment:TA_CENTER];
    NSDictionary *branchInfo = [_rmsDbController.globalDict valueForKey:@"BranchInfo"];
    NSString *email = [NSString stringWithFormat:@"%@ %@",Printing_Email,[branchInfo valueForKey:@"Email"]];
    [_printJob printLine:email];
}

- (void)printPhoneNo {
    [_printJob setTextAlignment:TA_CENTER];
    NSDictionary *branchInfo = [_rmsDbController.globalDict valueForKey:@"BranchInfo"];
    NSString *phoneNo = [NSString stringWithFormat:@"%@ %@",Printing_Phone,[branchInfo valueForKey:@"PhoneNo1"]];
    [_printJob printLine:phoneNo];
    [_printJob printLine:@""];
}

- (void)printTitle {
    [_printJob setTextAlignment:TA_CENTER];
    [_printJob setTextSize:1];
    [_printJob printLine:self._printingData[@"ItemName"]];
    [_printJob setTextSize:0];
    [_printJob printLine:@""];
}

- (void)printNoOfPassDays {
    [_printJob setTextAlignment:TA_CENTER];
    NSString *noOfPassDays = [NSString stringWithFormat:@"%@ %@",self._printingData[@"NoOfDay"],Printing_Day_Pass];
    [_printJob printLine:noOfPassDays];
}

- (void)printPassNo {
    [_printJob setTextAlignment:TA_CENTER];
    [_printJob printLine:self._printingData[@"CRDNumber"]];
}

- (void)printQRCode {
    [_printJob printQRCodeText:self._printingData[@"QRCode"] model:2 correction:3 cellSize:8];
}

- (void)printExpiryDays {
    [_printJob setTextAlignment:TA_CENTER];
    NSString *expiryDays = [NSString stringWithFormat:@"%@ %@ %@",Printing_Valid_Only,self._printingData[@"ExpirationDay"],Printing_Days];
    [_printJob printLine:expiryDays];
    [_printJob printLine:@""];
}

- (void)printDateOfPurchase {
    [_printJob setTextAlignment:TA_LEFT];
    NSString *expiryDays = [NSString stringWithFormat:@"%@ %@",Printing_Purchase_Date,[self getCurrentDateAndTime]];
    [_printJob printLine:expiryDays];
}

- (NSString *)getCurrentDateAndTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *printDate = [dateFormatter stringFromDate:date];
    return printDate;
}

- (void)printRegisterName {
    [_printJob setTextAlignment:TA_LEFT];
    NSString *registerName = [NSString stringWithFormat:@"%@ %@",Printing_Register,_rmsDbController.globalDict [@"RegisterName"]];
    [_printJob printLine:registerName];
}

- (void)printUserName {
    [_printJob setTextAlignment:TA_LEFT];
    NSDictionary *userInfo = [_rmsDbController.globalDict valueForKey:@"UserInfo"];
    NSString *userName = [NSString stringWithFormat:@"%@ %@",Printing_User,userInfo [@"UserName"]];
    [_printJob printLine:userName];
}

- (void)printInvoiceNo {
    [_printJob setTextAlignment:TA_LEFT];
    NSString *invoiceNo = [NSString stringWithFormat:@"%@ %@",Printing_Invoice_No,self._printingData[@"InvoiceNo"]];
    [_printJob printLine:invoiceNo];
}

- (void)printPaymentType {
    NSDictionary *paymentDict = [self paymentDetails];
    if (paymentDict != nil) {
        [_printJob setTextAlignment:TA_LEFT];
        NSString *invoiceNo = [NSString stringWithFormat:@"%@ %@",Printing_Payment_Type,[self paymentDetails][@"PaymentType"]];
        [_printJob printLine:invoiceNo];
        if (![paymentDict[@"CCNo"] length] > 0 || paymentDict[@"CCNo"] == nil) {
            [_printJob printLine:@""];
        }
    }
}

- (void)printCCNo {
    if ([self paymentDetails][@"CCNo"] != nil && [[self paymentDetails][@"CCNo"] length] > 0) {
        [_printJob setTextAlignment:TA_LEFT];
        NSString *cCNo = [NSString stringWithFormat:@"%@ %@",Printing_CC_No,[self paymentDetails][@"CCNo"]];
        [_printJob printLine:cCNo];
        [_printJob printLine:@""];
    }
}

-(NSDictionary *)paymentDetails
{
    NSDictionary *paymentDetails;
    if([paymentDatailsArray isKindOfClass:[NSArray class]] && paymentDatailsArray.count > 0 ){
        NSString *strPaymentType = @"";
        NSString *strCCNo = @"";
        for(int i = 0;i<paymentDatailsArray.count;i++)
        {
            strPaymentType = [strPaymentType stringByAppendingString:[NSString stringWithFormat:@"%@,",paymentDatailsArray[i][@"PayMode"]]];
            if([strPaymentType isEqualToString:@"Credit"] || [strPaymentType isEqualToString:@"Debit"] ||  [strPaymentType isEqualToString:@"EBT/Food Stamp"])
            {
                if ([[paymentDatailsArray[i] valueForKey:@"AccNo"] length]>0)
                {
                   strCCNo  = [paymentDatailsArray[i] valueForKey:@"AccNo"];
                   strCCNo = [strCCNo substringFromIndex:strCCNo.length - 4];
                }
            }
        }
        if (strPaymentType.length > 0) {
            strPaymentType = [strPaymentType substringToIndex:strPaymentType.length - 1];
        }
        paymentDetails = @{@"PaymentType":strPaymentType,
                                         @"CCNo":strCCNo};
    }
    return paymentDetails;
}

- (void)printMessage {
    [_printJob setTextAlignment:TA_CENTER];
    [_printJob setTextSize:1];
    [_printJob printLine:@"Thank you for Visting"];
    [_printJob setTextSize:0];
}

- (void)printWebsite {
    [_printJob setTextAlignment:TA_CENTER];
    [_printJob setTextSize:1];
    [_printJob printLine:@"www.gotechtown.com"];
    [_printJob setTextSize:0];
}


#pragma mark - Printing Footer

- (void)printFooterForSection:(NSInteger)section {
    switch (section) {
            
        case PrintingSectionStoreInfo:
            [_printJob printSeparator];
            break;
            
        case PrintingSectionPassHeader:
            [_printJob printSeparator];
            break;
            
        case PrintingSectionQRCode:
            [_printJob printSeparator];
            break;

        case PrintingSectionPassDetails:
            [_printJob printSeparator];
            break;
            
        case PrintingSectionFooter:
            break;

        default:
            break;
    }
    [_printJob printLine:@""];
}

#pragma mark - Default Column Width Formating

- (void)defaultFormatForTwoColumn
{
    columnWidths[0] = 23;
    columnWidths[1] = 23;
    columnAlignments[0] = RCAlignmentLeft;
    columnAlignments[1] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForThreeColumn
{
    columnWidths[0] = 15;
    columnWidths[1] = 16;
    columnWidths[2] = 15;
    columnAlignments[0] = RCAlignmentLeft;
    columnAlignments[1] = RCAlignmentRight;
    columnAlignments[2] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForFourColumn
{
    columnWidths[0] = 14;
    columnWidths[1] = 11;
    columnWidths[2] = 9;
    columnWidths[3] = 11;
    columnAlignments[0] = RCAlignmentLeft;
    columnAlignments[1] = RCAlignmentRight;
    columnAlignments[2] = RCAlignmentRight;
    columnAlignments[3] = RCAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}


@end
