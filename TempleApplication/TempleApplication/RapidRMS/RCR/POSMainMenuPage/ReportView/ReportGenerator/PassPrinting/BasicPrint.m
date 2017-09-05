//
//  BasicPrint.m
//  RapidRMS
//
//  Created by Siya7 on 6/6/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "BasicPrint.h"
#import "PrintJob.h"
#import "RasterPrintJob.h"
#import "RasterPrintJobBase.h"

@interface BasicPrint () {
}
@end

@implementation BasicPrint


- (instancetype)init {
    self = [super init];
    if (self) {
        _sections = @[];
        _fields = @[];
        _rmsDbController = [RmsDbController sharedRmsDbController];
        currencyFormatter = [[NSNumberFormatter alloc] init];
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        currencyFormatter.maximumFractionDigits = 2;
        _printerWidth = 48;
    }
    return self;
}

#pragma mark - Printing
- (NSInteger)sectionAtSectionIndex:(NSInteger)sectionIndex {
    return [_sections[sectionIndex] integerValue];
}

- (void)configurePrint:(NSString *)portSettings portName:(NSString *)portName withDelegate:(id)delegate
{
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    
    if (isBlueToothPrinter) {
        _printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings   deviceName:@"Printer" withDelegate:delegate];
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

- (void)printReportWithPort:(NSString*)portName portSettings:(NSString*)portSettings withDelegate:(id)delegate
{
    //    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    //
    ////        #ifdef DEBUG
    ////                isBlueToothPrinter = NO;
    ////        #endif
    //
    //    if(!isBlueToothPrinter)
    //    {
    //        [self _tcpPrintReportWithPort:portName portSettings:portSettings];
    //    }
    //    else
    //    {
    [self _printReportWithPort:portName portSettings:portSettings withDelegate:delegate];
    //    }
}

#pragma mark - TCP Printing

- (void)_tcpPrintReportWithPort:(NSString*)portName portSettings:(NSString*)portSettings
{
    _printJob = [[PrintJob alloc] initWithPort:portName portSettings:portSettings deviceName:@"" withDelegate:nil];
    if (self.generateHtml.length > 0 && self.generateHtml != nil) {
        [self LoadReceiptHtml:self.generateHtml];
    }
}

#pragma mark - HTML

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
    //    CGFloat max, scale = 1.0;
    //    CGSize viewSize = [view bounds].size;
    
    // Get the size of the the FULL Content, not just the bit that is visible
    CGSize size = [view sizeThatFits:CGSizeZero];
    
    // Scale down if on iPad to something more reasonable
    //    max = (viewSize.width > viewSize.height) ? viewSize.width : viewSize.height;
    //    if( max > 960 )
    //        scale = 960/max;
    
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

#pragma mark - utility
- (NSString*)stringFromDate:(NSString*)inputDate inputFormat:(NSString*)inputFormat outputFormat:(NSString*)outputFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = inputFormat;
    NSDate *date = [dateFormatter dateFromString:inputDate];
    
    dateFormatter.dateFormat = outputFormat;
    
    NSString *outputDate = [dateFormatter stringFromDate:date];
    return outputDate;
}

- (NSString*)stringFromDate:(NSDate*)date format:(NSString*)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    
    NSString *dateAsString = [dateFormatter stringFromDate:date];
    return dateAsString;
}

- (NSString*)percentageFormattedAmount:(NSNumber*)amount {
    if (![amount isKindOfClass:[NSNumber class]]) {
        if ([amount isKindOfClass:[NSString class]]) {
            amount = @(amount.floatValue);
        }
    }
    
    NSString *formattedAmount = [NSString stringWithFormat:@"%.2f%%", amount.floatValue];
    return formattedAmount;
}

- (NSString*)currencyFormattedAmount:(NSNumber*)amount {
    if (![amount isKindOfClass:[NSNumber class]]) {
        if ([amount isKindOfClass:[NSString class]]) {
            amount = @(amount.floatValue);
        }
    }
    
    NSString *formattedAmount = [_rmsDbController.currencyFormatter stringFromNumber:amount];
    return formattedAmount;
}

- (NSString*)currencyFormattedAmountForKey:(NSString*)amountKey fromDictionary:(NSDictionary*)dictionary {
    NSNumber *amount = dictionary[amountKey];
    NSString *formattedAmount = [_rmsDbController.currencyFormatter stringFromNumber:amount];
    return formattedAmount;
}


-(NSDate*)jsonStringToNSDate:(NSString*)string
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
#pragma mark - Bluetooth Printing

- (void)_printReportWithPort:(NSString*)portName portSettings:(NSString*)portSettings  withDelegate:(id)delegate
{
    [self configurePrint:portSettings portName:portName withDelegate:delegate];
    
    NSInteger sectionCount = _sections.count;
    for (int i = 0; i < sectionCount; i++) {
        ReportSection section = [self sectionAtSectionIndex:i];
        [self printHeaderForSection:section];
        [self printCommandForSectionAtIndex:i];
        [self printFooterForSection:section];
    }
    
    [self concludePrint];
}

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
    ReportField fieldId = fieldNumber.integerValue;
    [self printFieldWithId:fieldId];
}


- (void)printHeaderForSection:(NSInteger)section
{
}
- (void)printFooterForSection:(NSInteger)section
{
}
- (void)printFieldWithId:(NSInteger)fieldId
{
}

@end
